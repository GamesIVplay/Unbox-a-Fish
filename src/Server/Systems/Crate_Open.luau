local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local VFX = Assets:WaitForChild("VFX")
local CrateBreak = VFX:WaitForChild("CrateBreak") :: Attachment

local Debris_Folder = workspace:WaitForChild("Debris")

local Network = require(ServerScriptService.Network)

local Temp = ReplicatedStorage:WaitForChild("Temp")

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local World = require(ReplicatedStorage.Common.World)

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
            if Crate_Health <= 0 then
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
                    Owner = 1,
                    Result = {
                        Name = Fish_Name,
                        Mutation = Fish_Mutation,
                    },
                })

                task.delay(12.5, function()
                    if World:contains(Crate_Entity) then
                        World:delete(Crate_Entity)
                    end
                end)

                World:add(Crate_Entity, Components.Tags.Opening)
            end
        end
    end,
    runConditions = {},
}
