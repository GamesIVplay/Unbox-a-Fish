local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local Highlights = Assets:WaitForChild("Highlights")
local Damage_Highlight = Highlights:WaitForChild("Damage") :: Highlight

local Sounds = Assets:WaitForChild("Sounds")

local World_Sounds = Sounds:WaitForChild("World")
local Swing_Sound = World_Sounds:WaitForChild("Swing") :: Sound
local Impact_Sound = World_Sounds:WaitForChild("Impact") :: Sound

local Network = require(ServerScriptService.Network)

local Ratelimit = require(ReplicatedStorage.Packages.Ratelimit)
local Swing_Rate_Limit = Ratelimit(1, 0.2)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

local Types = require(ReplicatedStorage.Common.Types)

local Hammers = require(ReplicatedStorage.Common.Modules.Hammers)

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = function()
        for _, Swinger_Player: Player, Crate_Entity: Types.Entity? in Network.Requests.Swing.Iter() do
            if not Swing_Rate_Limit(Swinger_Player) then
                continue
            end

            local Swinger_Player_Entity = Registry.Get("Players", Swinger_Player)

            if not Swinger_Player_Entity then
                continue
            end

            local Character = World:get(Swinger_Player_Entity, Components.Renderable) :: Model?

            if not Character then
                continue
            end

            local RootPart = Character:FindFirstChild("HumanoidRootPart") :: Part?

            if not RootPart then
                continue
            end

            local S_Sound = Swing_Sound:Clone()
            S_Sound.PlayOnRemove = true
            S_Sound.Parent = RootPart
            S_Sound:Destroy()

            if
                not Crate_Entity
                or not World:contains(Crate_Entity)
                or not World:has(Crate_Entity, Components.Tags.Crate)
            then
                continue
            end

            local Crate_Health = World:get(Crate_Entity, Components.Health)

            if Crate_Health == 0 then
                continue
            end

            local Swinger_Plot_Entity = World:target(Swinger_Player_Entity, Components.Relationships.Plot)

            if not Swinger_Plot_Entity then
                continue
            end

            local Crate_Plot_Entity = World:target(Crate_Entity, Components.Relationships.Owner)
            local Crate_Owner_Entity = World:target(Crate_Plot_Entity, Components.Relationships.Owner)

            if not Crate_Owner_Entity then
                continue
            end

            local Swinger_Tutorial_Step = World:get(Swinger_Player_Entity, Components.Tutorial_Step)

            local Crate_Owner_Tutorial_Step = World:get(Crate_Owner_Entity, Components.Tutorial_Step)

            local Owns = Crate_Plot_Entity == Swinger_Plot_Entity

            if Owns then
                if
                    Crate_Owner_Tutorial_Step ~= 0
                    and Crate_Owner_Tutorial_Step ~= 6
                    and not (Crate_Owner_Tutorial_Step > 9)
                then
                    Network.Notification.Fire(Swinger_Player, {
                        Text = "Complete the tutorial first",
                    })

                    continue
                end
            else
                if not (Swinger_Tutorial_Step > 9) then
                    Network.Notification.Fire(Swinger_Player, {
                        Text = "Complete the tutorial first",
                    })
                    continue
                end

                if not (Crate_Owner_Tutorial_Step > 9) then
                    Network.Notification.Fire(Swinger_Player, {
                        Text = "This player is in the tutorial",
                    })
                    continue
                end
            end

            local Crate_Model = World:get(Crate_Entity, Components.Renderable) :: Model
            local PrimaryPart = Crate_Model.PrimaryPart :: Part

            local I_Sound = Impact_Sound:Clone()
            I_Sound.PlayOnRemove = true
            I_Sound.Parent = PrimaryPart
            I_Sound:Destroy()

            local Highlight = Damage_Highlight:Clone()
            Highlight.Parent = Crate_Model

            Debris:AddItem(Highlight, 0.15)

            local Tool_Level = World:get(Swinger_Player_Entity, Components.Tool_Level)
            local Hammer_Data = Hammers[Tool_Level]

            local Damage = Owns and Hammer_Data.Damage or Hammer_Data.Damage / 2

            Damage = math.max(math.round(Damage), 1)

            local New_Crate_Health = math.max(Crate_Health - Damage, 0)

            World:set(Crate_Entity, Components.Health, New_Crate_Health)

            Network.BounceCrate.FireAll(Crate_Model)
        end
    end,
    runConditions = {},
}
