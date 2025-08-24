local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local World = require(ReplicatedStorage.Common.World)

local Player_Cash_Rebirth_Query = World:query(Components.Player, Components.Cash, Components.Unboxes):cached()

return {
    name = script.Name,
    phase = Phases.Runservice.PreUpdate,
    system = function()
        for _, Player, Cash: number, Unboxes: number in Player_Cash_Rebirth_Query:iter() do
            local Leaderstats = Player:FindFirstChild("leaderstats")

            if not Leaderstats then
                Leaderstats = Instance.new("Folder")
                Leaderstats.Name = "leaderstats"
                Leaderstats.Parent = Player
            end

            local CashInstance = Leaderstats:FindFirstChild("💵 Cash")

            if not CashInstance then
                CashInstance = Instance.new("IntValue")
                CashInstance.Name = "💵 Cash"
                CashInstance.Parent = Leaderstats
            end

            CashInstance.Value = Cash

            local UnboxesInstance = Leaderstats:FindFirstChild("📦 Unboxes")

            if not UnboxesInstance then
                UnboxesInstance = Instance.new("IntValue")
                UnboxesInstance.Name = "📦 Unboxes"
                UnboxesInstance.Parent = Leaderstats
            end

            UnboxesInstance.Value = Unboxes
        end
    end,
    runConditions = {},
}
