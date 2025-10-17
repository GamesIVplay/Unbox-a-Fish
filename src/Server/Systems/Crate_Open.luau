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

local Fish_Sounds = Sounds:WaitForChild("Fish")

local VFX = Assets:WaitForChild("VFX")
local CrateBreak = VFX:WaitForChild("CrateBreak") :: Attachment

local Network = require(ServerScriptService.Network)

local Add_Fish = require(ServerScriptService.Server.Modules.Add_Fish)

local Jecs = require(ReplicatedStorage.Packages.Jecs)
local Pair = Jecs.pair

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local World = require(ReplicatedStorage.Common.World)

local Fish = require(ReplicatedStorage.Common.Modules.Fish)
local Mutations = require(ReplicatedStorage.Common.Modules.Mutations)

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

            local Inventory = World:get(Plot_Owner, Components.Inventory)
            local Tutorial_Step = World:get(Plot_Owner, Components.Tutorial_Step)

            if Tutorial_Step == 0 then
                World:set(Plot_Owner, Components.Tutorial_Step, 1)
            elseif Tutorial_Step == 6 then
                World:set(Plot_Owner, Components.Tutorial_Step, 7)
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

            local Mutation_Multiplier = World:has(Plot_Owner, Components.Tags.DoubleMutations) and 2 or 1

            if World:get(Plot_Owner, Components.Double_Mutation_Time_Remaining) > 0 then
                Mutation_Multiplier *= 2
            end

            if World:get(Plot_Owner, Components.Unboxes) <= 20 then
                Mutation_Multiplier *= 4
            end

            local Gurantee_Mutation = false

            if string.find(string.lower(Crate_Name), "mutate") then
                Gurantee_Mutation = true
            end

            local Fish_Name, Fish_Mutation = Roll_Fish(Crate_Name, Mutation_Multiplier, Gurantee_Mutation)

            if Tutorial_Step == 0 then
                Fish_Mutation = nil
            end

            local Rolled_Fish_Data = Fish[Fish_Name]
            local Rolled_Fish_Income_Per_Sec = Rolled_Fish_Data.IncomePerSec

            if Fish_Mutation then
                Rolled_Fish_Income_Per_Sec *= Mutations[Fish_Mutation].Multiplier
            end

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

            if not Open_Stand then
                local Fish_To_Replace_Entity
                local Fish_To_Replace_Name
                local Fish_To_Replace_Mutation
                local Stand_To_Replace
                local Lowest_Income_Per_Sec = math.huge -- start very high

                for Fish_Entity, Target_Fish_Name: string, Stand: Model in
                    World:query(Components.Name, Components.Stand)
                        :with(Pair(Components.Relationships.Owner, Plot_Owner))
                do
                    local Mutation = World:get(Fish_Entity, Components.Mutation)

                    local Fish_Data = Fish[Target_Fish_Name]
                    local IncomePerSec = Fish_Data.IncomePerSec

                    if Mutation then
                        IncomePerSec *= Mutations[Mutation].Multiplier
                    end

                    -- Track the lowest income/sec fish
                    if IncomePerSec < Lowest_Income_Per_Sec then
                        Fish_To_Replace_Entity = Fish_Entity
                        Fish_To_Replace_Name = Target_Fish_Name
                        Fish_To_Replace_Mutation = Mutation
                        Lowest_Income_Per_Sec = IncomePerSec
                        Stand_To_Replace = Stand
                    end
                end

                if Rolled_Fish_Income_Per_Sec > Lowest_Income_Per_Sec then
                    World:delete(Fish_To_Replace_Entity)

                    Open_Stand = Stand_To_Replace

                    Add_Fish(Inventory, Fish_To_Replace_Name, Fish_To_Replace_Mutation)

                    local Mutation_Text = Fish_To_Replace_Mutation ~= nil and (Fish_To_Replace_Mutation .. " ") or ""

                    Network.Notification.Fire(Plot_Owner_Player, {
                        Text = `{Mutation_Text}{Fish_To_Replace_Name} was moved to inventory`,
                    })

                    World:set(Plot_Owner, Components.Inventory, Inventory)
                end
            end

            if Open_Stand then
                Open_Stand:AddTag("Occupied")
            end

            Network.OpenTrapEffect.FireAll({
                Crate = Crate_Name,
                CF = Crate_Model:GetPivot(),
                Owner = Plot_Owner_Player.UserId,
                MutationMultiplier = Mutation_Multiplier,
                GuranteeMutation = Gurantee_Mutation,
                Result = {
                    Name = Fish_Name,
                    Mutation = Fish_Mutation,
                    Stand = Open_Stand,
                },
            })

            task.delay(3.5, function()
                if not World:contains(Crate_Entity) or not World:contains(Plot_Owner) then
                    return
                end

                if Tutorial_Step == 0 then
                    World:set(Plot_Owner, Components.Tutorial_Step, 2)
                elseif Tutorial_Step == 6 then
                    World:set(Plot_Owner, Components.Tutorial_Step, 8)
                end

                local Unboxes = World:get(Plot_Owner, Components.Unboxes)

                local Fish_Data = Fish[Fish_Name]

                if Open_Stand then
                    local Stand = Open_Stand:FindFirstChild("Stand") :: Model

                    local Fish_Model = Fish_Data.Models[Fish_Mutation and Fish_Mutation or "Normal"]:Clone() :: Model
                    Fish_Model.Parent = Fish_Folder
                    Fish_Model:PivotTo(Stand:GetPivot())
                    local PrimaryPart = Fish_Model.PrimaryPart

                    task.delay(1, function()
                        local Voice_Sound = Fish_Sounds:FindFirstChild(Fish_Name)

                        if not Voice_Sound then
                            return
                        end

                        Voice_Sound = Voice_Sound:Clone()
                        Voice_Sound.PlayOnRemove = true
                        Voice_Sound.Parent = PrimaryPart
                        Voice_Sound:Destroy()
                    end)

                    local Spawn_Sound = Crate_Spawn_Sound:Clone()
                    Spawn_Sound.PlayOnRemove = true
                    Spawn_Sound.Parent = PrimaryPart
                    Spawn_Sound:Destroy()

                    Network.NewFish.FireAll(Fish_Model)
                    Network.AddPickupPrompt.Fire(Plot_Owner_Player, Fish_Model)
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
                    Add_Fish(Inventory, Fish_Name, Fish_Mutation)

                    World:set(Plot_Owner, Components.Inventory, Inventory)

                    local Mutation_Text = Fish_Mutation ~= nil and (Fish_Mutation .. " ") or ""

                    Network.Notification.Fire(Plot_Owner_Player, {
                        Text = `{Mutation_Text}{Fish_Name} was added to inventory`,
                    })
                end

                World:set(Plot_Owner, Components.Unboxes, Unboxes + 1)

                World:delete(Crate_Entity)
            end)

            World:add(Crate_Entity, Components.Tags.Opening)
        end
    end,
    runConditions = {},
}
