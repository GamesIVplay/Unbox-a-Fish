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
local Crate_Buy_Rate_Limit = Ratelimit(1, 0.5)

local Colors = require(ReplicatedStorage.Common.Modules.Colors)
local Crates = require(ReplicatedStorage.Common.Modules.Crates)

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = function()
        for _, Player: Player, Crate_Name: string in Network.Requests.BuyCrate.Iter() do
            if not Crate_Buy_Rate_Limit(Player) then
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

            local Stock = World:get(Player_Entity, Components.Stock)

            if not Stock[Crate_Name] or Stock[Crate_Name] == 0 then
                continue
            end

            local Crate_Data = Crates[Crate_Name]

            local Cash = World:get(Player_Entity, Components.Cash)

            if Cash < Crate_Data.Price then
                Network.Notification.Fire(Player, {
                    Text = "You can't afford this crate",
                    Color = Colors.Error,
                })
                continue
            end

            local Plot_Entity = World:target(Player_Entity, Components.Relationships.Plot)

            if not Plot_Entity then
                continue
            end

            local Plot_Model = World:get(Plot_Entity, Components.Renderable) :: Model
            local Plot_Spawn = Plot_Model:FindFirstChild("Spawn") :: Part

            local Tutorial_Step = World:get(Player_Entity, Components.Tutorial_Step)

            if Tutorial_Step == 4 then
                if Crate_Name ~= "Mossy Crate" then
                    Network.Notification.Fire(Player, {
                        Text = "Complete the tutorial first",
                    })
                    continue
                end

                Character:PivotTo(Plot_Spawn.CFrame)

                World:set(Player_Entity, Components.Tutorial_Step, 5)
            elseif Tutorial_Step < 11 then
                Network.Notification.Fire(Player, {
                    Text = "Complete the tutorial first",
                })
                continue
            end

            Stock[Crate_Name] = math.max(Stock[Crate_Name] - 1, 0)

            local Crate_Queue = World:get(Player_Entity, Components.Crate_Queue)

            table.insert(Crate_Queue, Crate_Name)

            World:set(Player_Entity, Components.Cash, Cash - Crate_Data.Price)
            World:set(Player_Entity, Components.Crate_Queue, Crate_Queue)

            Network.Notification.Fire(Player, {
                Text = `{Crate_Name} added to queue`,
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
