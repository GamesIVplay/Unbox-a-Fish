local Debris = game:GetService("Debris")
local MarketPlaceService = game:GetService("MarketplaceService")
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
local Hammers = require(ReplicatedStorage.Common.Modules.Hammers)

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = function()
        for _, Player in Network.Requests.UpgradeTool.Iter() do
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

            local Humanoid = Character:FindFirstChildOfClass("Humanoid")

            if not Humanoid then
                continue
            end

            local RootPart = Character:FindFirstChild("HumanoidRootPart") :: Part?

            if not RootPart then
                continue
            end

            local Tool_Level = World:get(Player_Entity, Components.Tool_Level)

            local Next_Tool_Data = Hammers[Tool_Level + 1]

            if not Next_Tool_Data then
                Network.Notification.Fire(Player, {
                    Text = "You have the strongest tool",
                    Color = Colors.Error,
                })
                continue
            end

            local Cash = World:get(Player_Entity, Components.Cash)

            if Cash < Next_Tool_Data.Price then
                Network.Notification.Fire(Player, {
                    Text = "You can't afford this tool",
                    Color = Colors.Error,
                })

                local ProductId = Hammers[Tool_Level + 1].ProductId
                MarketPlaceService:PromptProductPurchase(Player, ProductId)
                continue
            end

            local Tutorial_Step = World:get(Player_Entity, Components.Tutorial_Step)

            if Tutorial_Step == 3 then
                World:set(Player_Entity, Components.Tutorial_Step, 4)
            elseif Tutorial_Step < 11 then
                Network.Notification.Fire(Player, {
                    Text = "Complete the tutorial first",
                })
                continue
            end

            World:set(Player_Entity, Components.Tool_Level, Tool_Level + 1)
            World:set(Player_Entity, Components.Cash, Cash - Next_Tool_Data.Price)

            Network.Notification.Fire(Player, {
                Text = "You upgraded your tool",
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
