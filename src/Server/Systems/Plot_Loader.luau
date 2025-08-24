local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local Sounds = Assets:WaitForChild("Sounds")

local World_Sounds = Sounds:WaitForChild("World")
local Crate_Spawn_Sound = World_Sounds:WaitForChild("CrateSpawn") :: Sound

local Fish_Folder = workspace:WaitForChild("Fish")

local Network = require(ServerScriptService.Network)

local Jecs = require(ReplicatedStorage.Packages.Jecs)
local Pair = Jecs.pair

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local World = require(ReplicatedStorage.Common.World)

local Fish = require(ReplicatedStorage.Common.Modules.Fish)
local Mutations = require(ReplicatedStorage.Common.Modules.Mutations)

local Queued_Fish =
    World:query(Components.Player, Components.LastPlayed, Pair(Components.Relationships.Queued, Components.Tags.Fish))
        :with(Pair(Components.Relationships.Plot, Jecs.Wildcard))
        :cached()

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = function()
        for Player_Entity, Player: Player, LastPlayed: number, Queued_Fish in Queued_Fish:iter() do
            local Plot_Entity = World:target(Player_Entity, Components.Relationships.Plot)

            local Plot_Model = World:get(Plot_Entity, Components.Renderable) :: Model
            local Stands = Plot_Model:FindFirstChild("Stands")

            local Total_Offline_Cash = 0

            for Stand_Name, Data in Queued_Fish do
                local Open_Stand = Stands:FindFirstChild(Stand_Name) :: Model
                local Stand = Open_Stand:FindFirstChild("Stand") :: Model

                Open_Stand:AddTag("Occupied")

                local Fish_Name = Data.Name
                local Fish_Mutation = Data.Mutation
                local Cash = Data.Cash
                local Offline_Cash = Data.Offline_Cash

                local Fish_Data = Fish[Data.Name]

                local IncomePerSec = Fish_Data.IncomePerSec

                if Fish_Mutation then
                    local Mutation_Data = Mutations[Fish_Mutation]

                    IncomePerSec *= Mutation_Data.Multiplier
                end

                if World:has(Player_Entity, Components.Tags.DoubleMoney) then
                    IncomePerSec *= 2
                end

                local TimeOffline = os.time() - LastPlayed

                local NewOfflineCash = math.round((TimeOffline * IncomePerSec) * 0.10)

                Offline_Cash += NewOfflineCash

                Total_Offline_Cash += NewOfflineCash

                local Fish_Model = Fish_Data.Models[Fish_Mutation and Fish_Mutation or "Normal"]:Clone() :: Model
                Fish_Model.Parent = Fish_Folder
                Fish_Model:PivotTo(Stand:GetPivot())
                local PrimaryPart = Fish_Model.PrimaryPart

                local Spawn_Sound = Crate_Spawn_Sound:Clone()
                Spawn_Sound.PlayOnRemove = true
                Spawn_Sound.Parent = PrimaryPart
                Spawn_Sound:Destroy()

                Network.NewFish.FireAll(Fish_Model)
                Network.AddOwnedHighlight.Fire(Player, Fish_Model)

                local Fish_Entity = World:entity()

                Open_Stand:SetAttribute("ServerEntity", Fish_Entity)

                World:set(Fish_Entity, Components.Name, Fish_Name)
                World:set(Fish_Entity, Components.Renderable, Fish_Model)
                World:set(Fish_Entity, Components.Stand, Open_Stand)
                World:set(Fish_Entity, Components.Cash, Cash)
                World:set(Fish_Entity, Pair(Components.Relationships.Offline, Components.Cash), Offline_Cash)

                if Fish_Mutation then
                    World:set(Fish_Entity, Components.Mutation, Fish_Mutation)
                end

                World:add(Fish_Entity, Components.Tags.Fish)
                World:add(Fish_Entity, Components.Tags.Networked)
                World:add(Fish_Entity, Pair(Components.Relationships.Owner, Player_Entity))
                World:add(Player_Entity, Pair(Components.Relationships.Fish, Fish_Entity))

                World:set(Fish_Entity, Components.Cleanup, function()
                    Fish_Model:Destroy()
                    Open_Stand:RemoveTag("Occupied")
                    Open_Stand:SetAttribute("ServerEntity", nil)
                end)
            end

            World:remove(Player_Entity, Pair(Components.Relationships.Queued, Components.Tags.Fish))

            if Total_Offline_Cash > 0 then
                Network.Notification.Fire(Player, {
                    Text = `You earned ${Total_Offline_Cash} while you were away!`,
                    Duration = 5,
                })
            end
        end
    end,
    runConditions = {},
}
