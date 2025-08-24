local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Temp = ReplicatedStorage:WaitForChild("Temp")

local Fish_Folder = workspace:WaitForChild("Fish")
local Debris_Folder = workspace:WaitForChild("Debris")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local Sounds = Assets:WaitForChild("Sounds")

local World_Sounds = Sounds:WaitForChild("World")
local Crate_Spawn_Sound = World_Sounds:WaitForChild("CrateSpawn") :: Sound

local VFX = Assets:WaitForChild("VFX")
local CrateBreak = VFX:WaitForChild("CrateBreak") :: Attachment

local Network = require(ServerScriptService.Network)

local Jecs = require(ReplicatedStorage.Packages.Jecs)
local Pair = Jecs.pair

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local World = require(ReplicatedStorage.Common.World)

local Fish = require(ReplicatedStorage.Common.Modules.Fish)

local Roll_Fish = require(ReplicatedStorage.Common.Modules.Roll_Fish)

local Crates = World:query(Components.Name, Components.Renderable, Components.Health)
    :with(Components.Tags.Crate)
    :without(Components.Tags.Opening)
    :cached()

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = function()
        for Crate_Entity, Crate_Name: string, Crate_Model: Model, Crate_Health: number in Crates:iter() do
            if Crate_Health > 0 then
                continue
            end

            local Plot_Entity = World:target(Crate_Entity, Components.Relationships.Owner)

            local Plot_Owner = World:target(Plot_Entity, Components.Relationships.Owner)

            if not Plot_Owner then
                continue
            end

            local Plot_Owner_Player = World:get(Plot_Owner, Components.Player) :: Player

            Crate_Model.Parent = Temp

            local Part = Instance.new("Part")
            Part.Transparency = 1
            Part.CFrame = Crate_Model:GetPivot() * CFrame.new(0, 4, 0)
            Part.CanCollide = false
            Part.Anchored = true
            Part.Parent = Debris_Folder

            local VFX = CrateBreak:Clone()
            VFX.Parent = Part

            for _, Inst: ParticleEmitter in VFX:GetDescendants() do
                if Inst:IsA("ParticleEmitter") then
                    local EmitCount = Inst:GetAttribute("EmitCount") or 1

                    Inst:Emit(EmitCount)
                end
            end

            Debris:AddItem(Part, 3)

            local Fish_Name, Fish_Mutation = Roll_Fish(Crate_Name)

            Network.OpenTrapEffect.FireAll({
                Crate = Crate_Name,
                CF = Crate_Model:GetPivot(),
                Owner = Plot_Owner_Player.UserId,
                Result = {
                    Name = Fish_Name,
                    Mutation = Fish_Mutation,
                },
            })

            task.delay(8.5, function()
                if not World:contains(Crate_Entity) then
                    return
                end

                local Unboxes = World:get(Plot_Owner, Components.Unboxes)

                local Plot_Model = World:get(Plot_Entity, Components.Renderable) :: Model
                local Stands = Plot_Model:FindFirstChild("Stands")

                local Stand_Count = World:has(Plot_Owner, Components.Tags.DoubleSlots) and 12 or 10

                local Open_Stand: Model?

                for Stand = 1, Stand_Count do
                    local Stand_Model = Stands:FindFirstChild(Stand)

                    if Stand_Model:HasTag("Occupied") then
                        continue
                    end

                    Open_Stand = Stand_Model
                    break
                end

                local Fish_Data = Fish[Fish_Name]

                if Open_Stand then
                    local Stand = Open_Stand:FindFirstChild("Stand") :: Model

                    Open_Stand:AddTag("Occupied")

                    local Fish_Model = Fish_Data.Models[Fish_Mutation and Fish_Mutation or "Normal"]:Clone() :: Model
                    Fish_Model.Parent = Fish_Folder
                    Fish_Model:PivotTo(Stand:GetPivot())
                    local PrimaryPart = Fish_Model.PrimaryPart

                    local Spawn_Sound = Crate_Spawn_Sound:Clone()
                    Spawn_Sound.PlayOnRemove = true
                    Spawn_Sound.Parent = PrimaryPart
                    Spawn_Sound:Destroy()

                    Network.NewFish.FireAll(Fish_Model)
                    Network.AddOwnedHighlight.Fire(Plot_Owner_Player, Fish_Model)

                    local Fish_Entity = World:entity()

                    Open_Stand:SetAttribute("ServerEntity", Fish_Entity)

                    World:set(Fish_Entity, Components.Name, Fish_Name)
                    World:set(Fish_Entity, Components.Renderable, Fish_Model)
                    World:set(Fish_Entity, Components.Stand, Open_Stand)
                    World:set(Fish_Entity, Components.Cash, 0)
                    World:set(Fish_Entity, Pair(Components.Relationships.Offline, Components.Cash), 0)

                    if Fish_Mutation then
                        World:set(Fish_Entity, Components.Mutation, Fish_Mutation)
                    end

                    World:add(Fish_Entity, Components.Tags.Fish)
                    World:add(Fish_Entity, Components.Tags.Networked)
                    World:add(Fish_Entity, Pair(Components.Relationships.Owner, Plot_Owner))
                    World:add(Plot_Owner, Pair(Components.Relationships.Fish, Fish_Entity))

                    World:set(Fish_Entity, Components.Cleanup, function()
                        Fish_Model:Destroy()
                        Open_Stand:RemoveTag("Occupied")
                        Open_Stand:SetAttribute("ServerEntity", nil)
                    end)
                else
                end

                World:set(Plot_Owner, Components.Unboxes, Unboxes + 1)

                World:delete(Crate_Entity)
            end)

            World:add(Crate_Entity, Components.Tags.Opening)
        end
    end,
    runConditions = {},
}
