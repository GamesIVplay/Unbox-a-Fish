local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local VFX = Assets:WaitForChild("VFX")
local Tutorial_Complete_VFX = VFX:WaitForChild("TutorialComplete") :: Attachment

local Network = require(ServerScriptService.Network)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

local Add_Fish = require(ServerScriptService.Server.Modules.Add_Fish)
local Rebirths = require(ReplicatedStorage.Common.Modules.Rebirths)
local Remove_Fish = require(ServerScriptService.Server.Modules.Remove_Fish)

return {
    name = script.Name,
    phase = Phases.Runservice.PreUpdate,
    system = function()
        for _, Player: Player in Network.Requests.Rebirth.Iter() do
            local Player_Entity = Registry.Get("Players", Player)

            if not Player_Entity then
                continue
            end

            local Character = World:get(Player_Entity, Components.Renderable) :: Model?

            if not Character then
                continue
            end

            local RootPart = Character:FindFirstChild("HumanoidRootPart")

            if not RootPart then
                continue
            end

            local Plot_Entity = World:target(Player_Entity, Components.Relationships.Plot)

            if not Plot_Entity then
                continue
            end

            local Plot_Model = World:get(Plot_Entity, Components.Renderable) :: Model
            local Plot_Spawn = Plot_Model:FindFirstChild("Spawn") :: Part

            local Rebirth = World:get(Player_Entity, Components.Rebirth)

            local Next_Rebirth_Data = Rebirths[Rebirth + 1]

            if not Next_Rebirth_Data then
                Network.Notification.Fire(Player, { Text = "Your already max rebirth" })
                continue
            end

            local Cash = World:get(Player_Entity, Components.Cash)

            if not Cash then
                continue
            end

            local Inventory = World:get(Player_Entity, Components.Inventory)

            if not Inventory then
                continue
            end

            local Requirements_Met = true

            if Cash < Next_Rebirth_Data.Requirements.Cash then
                Requirements_Met = false
            end

            for _, Name in Next_Rebirth_Data.Requirements.Fish do
                local HasFish = false

                for _, Item in Inventory do
                    if Item.Name == Name then
                        HasFish = true
                        break
                    end
                end

                if not HasFish then
                    Requirements_Met = false
                end
            end

            if not Requirements_Met then
                Network.Notification.Fire(Player, { Text = "Requirements not met" })
                continue
            end

            World:set(Player_Entity, Components.Cash, Cash - Next_Rebirth_Data.Requirements.Cash)

            for _, Name in Next_Rebirth_Data.Requirements.Fish do
                Remove_Fish(Inventory, Name)
            end

            for _, Name in Next_Rebirth_Data.Rewards.Fish do
                Add_Fish(Inventory, Name)
            end

            World:set(Player_Entity, Components.Rebirth, Rebirth + 1)

            Character:PivotTo(Plot_Spawn.CFrame)

            local VFX = Tutorial_Complete_VFX:Clone()
            VFX.Parent = RootPart

            for _, Inst: ParticleEmitter in VFX:GetDescendants() do
                if Inst:IsA("ParticleEmitter") then
                    local EmitCount = Inst:GetAttribute("EmitCount") or 1

                    Inst:Emit(EmitCount)
                end
            end

            Debris:AddItem(VFX, 5)

            Network.Notification.Fire(Player, { Text = `You rebirthed to rebirth {Rebirth + 1}` })
            Network.Confetti.Fire(Player)
        end
    end,
    runConditions = {},
}
