local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local VFX = Assets:WaitForChild("VFX")
local Buy_VFX = VFX:WaitForChild("Buy") :: Attachment

local Highlights = Assets:WaitForChild("Highlights")
local Buy_Highlight = Highlights:WaitForChild("Buy") :: Highlight

local Sounds = Assets:WaitForChild("Sounds")

local World_Sounds = Sounds:WaitForChild("World")
local Cash_Collect_Sound = World_Sounds:WaitForChild("CashCollect") :: Sound

local Network = require(ServerScriptService.Network)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

local Ratelimit = require(ReplicatedStorage.Packages.Ratelimit)
local Upgrade_Rate_Limit = Ratelimit(1, 0.5)

local Colors = require(ReplicatedStorage.Common.Modules.Colors)
local Luck_Prices = require(ReplicatedStorage.Common.Modules.Luck_Prices)

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = function()
        for _, Player in Network.Requests.UpgradeLuck.Iter() do
            if not Upgrade_Rate_Limit(Player) then
                continue
            end

            local Player_Entity = Registry.Get("Players", Player)

            if not Player_Entity then
                continue
            end

            local Character = World:get(Player_Entity, Components.Renderable) :: Model?

            if not Character then
                continue
            end

            local RootPart = Character:FindFirstChild("HumanoidRootPart") :: Part?

            if not RootPart then
                continue
            end

            local Luck_Level = World:get(Player_Entity, Components.Luck_Level)

            local Next_Luck_Price = Luck_Prices[Luck_Level + 1]

            if not Next_Luck_Price then
                Network.Notification.Fire(Player, {
                    Text = "You have max luck",
                    Color = Colors.Error,
                })
                continue
            end

            local Cash = World:get(Player_Entity, Components.Cash)

            if Cash < Next_Luck_Price then
                Network.Notification.Fire(Player, {
                    Text = "You can't afford this upgrade",
                    Color = Colors.Error,
                })
                continue
            end

            World:set(Player_Entity, Components.Luck_Level, Luck_Level + 1)
            World:set(Player_Entity, Components.Cash, Cash - Next_Luck_Price)

            Network.Notification.Fire(Player, {
                Text = "You upgraded your luck",
            })

            local Cash_Sound = Cash_Collect_Sound:Clone()
            Cash_Sound.PlayOnRemove = true
            Cash_Sound.Parent = RootPart
            Cash_Sound:Destroy()

            local Highlight = Buy_Highlight:Clone()
            Highlight.Parent = Character

            Debris:AddItem(Highlight, 0.15)

            local VFX = Buy_VFX:Clone()
            VFX.Parent = RootPart

            for _, Inst: ParticleEmitter in VFX:GetDescendants() do
                if Inst:IsA("ParticleEmitter") then
                    local EmitCount = Inst:GetAttribute("EmitCount") or 1

                    Inst:Emit(EmitCount)
                end
            end

            Debris:AddItem(VFX, 5)
        end
    end,
    runConditions = {},
}
