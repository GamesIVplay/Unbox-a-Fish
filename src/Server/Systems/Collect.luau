local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local VFX = Assets:WaitForChild("VFX")
local Collect_VFX = VFX:WaitForChild("Buy") :: Attachment

local Highlights = Assets:WaitForChild("Highlights")
local Collect_Highlight = Highlights:WaitForChild("Collect") :: Highlight

local Sounds = Assets:WaitForChild("Sounds")

local World_Sounds = Sounds:WaitForChild("World")
local Cash_Collect_Sound = World_Sounds:WaitForChild("CashCollect") :: Sound

local Network = require(ServerScriptService.Network)

local Ratelimit = require(ReplicatedStorage.Packages.Ratelimit)
local Collect_Rate_Limit = Ratelimit(1, 0.5)

local Jecs = require(ReplicatedStorage.Packages.Jecs)
local Pair = Jecs.pair

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

local Types = require(ReplicatedStorage.Common.Types)

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = function()
        for _, Player: Player, ServerEntity: Types.Entity in Network.Requests.Collect.Iter() do
            if not World:contains(ServerEntity) then
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

            if not World:has(ServerEntity, Components.Tags.Fish) then
                continue
            end

            if not World:has(ServerEntity, Pair(Components.Relationships.Owner, Player_Entity)) then
                continue
            end

            if not Collect_Rate_Limit(ServerEntity) then
                continue
            end

            local Tutorial_Step = World:get(Player_Entity, Components.Tutorial_Step)

            if Tutorial_Step == 2 then
                World:set(Player_Entity, Components.Tutorial_Step, 3)
            end

            local Player_Cash = World:get(Player_Entity, Components.Cash)

            local Cash = World:get(ServerEntity, Components.Cash)
            local OfflineCash = World:get(ServerEntity, Pair(Components.Relationships.Offline, Components.Cash))

            World:set(Player_Entity, Components.Cash, Player_Cash + Cash + OfflineCash)

            World:set(ServerEntity, Components.Cash, 0)
            World:set(ServerEntity, Pair(Components.Relationships.Offline, Components.Cash), 0)

            local Cash_Sound = Cash_Collect_Sound:Clone()
            Cash_Sound.PlayOnRemove = true
            Cash_Sound.Parent = RootPart
            Cash_Sound:Destroy()

            local Highlight = Collect_Highlight:Clone()
            Highlight.Parent = Character

            Debris:AddItem(Highlight, 0.15)

            local VFX = Collect_VFX:Clone()
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
