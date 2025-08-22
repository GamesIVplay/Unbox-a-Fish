local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Jecs = require(ReplicatedStorage.Packages.Jecs)
local Pair = Jecs.pair

local Network = require(ServerScriptService.Network)

local Components = require(ReplicatedStorage.Common.Components)
local Log = require(ReplicatedStorage.Common.Log)
local Phases = require(ReplicatedStorage.Common.Phases)
local World = require(ReplicatedStorage.Common.World)

local Util = require(ReplicatedStorage.Common.Modules.Util)

local Types = require(ReplicatedStorage.Common.Types)

local Player_Entities = World:query(Components.Player):cached()

local function Replicate_Cash(Player: Player, Entity: Types.Entity)
    local Cash = World:get(Entity, Components.Cash)
    local Previous_Cash = World:get(Entity, Pair(Components.Relationships.Previous, Components.Cash))

    if Cash ~= Previous_Cash then
        Network.PlayerChanges.Cash.Fire(Player, Cash)

        World:set(Entity, Pair(Components.Relationships.Previous, Components.Cash), Cash)

        Log.Info(`{Player.Name}'s cash was changed to {Cash}`)
    end
end

local function Replicate_Tool_Level(Player: Player, Entity: Types.Entity)
    local Tool_Level = World:get(Entity, Components.Tool_Level)
    local Previous_Tool_Level = World:get(Entity, Pair(Components.Relationships.Previous, Components.Tool_Level))

    if Tool_Level ~= Previous_Tool_Level then
        Network.PlayerChanges.ToolLevel.Fire(Player, Tool_Level)

        World:set(Entity, Pair(Components.Relationships.Previous, Components.Tool_Level), Tool_Level)

        Log.Info(`{Player.Name}'s tool level was changed to {Tool_Level}`)
    end
end

local function Replicate_Luck_Level(Player: Player, Entity: Types.Entity)
    local Luck_Level = World:get(Entity, Components.Luck_Level)
    local Previous_Luck_Level = World:get(Entity, Pair(Components.Relationships.Previous, Components.Luck_Level))

    if Luck_Level ~= Previous_Luck_Level then
        Network.PlayerChanges.LuckLevel.Fire(Player, Luck_Level)

        World:set(Entity, Pair(Components.Relationships.Previous, Components.Luck_Level), Luck_Level)

        Log.Info(`{Player.Name}'s luck level was changed to {Luck_Level}`)
    end
end

local function Replicate_Index(Player: Player, Entity: Types.Entity)
    local Index = World:get(Entity, Components.Index)

    local Previous_Index = World:get(Entity, Pair(Components.Relationships.Previous, Components.Index)) or {}

    for Fish_Entity, Fish_Name in
        World:query(Components.Name):with(Components.Tags.Fish, Pair(Components.Relationships.Owner, Entity))
    do
        local Fish_Mutation = World:get(Fish_Entity, Components.Mutation) or "Normal"

        if not Index[Fish_Mutation] then
            Index[Fish_Mutation] = {}
        end

        if not table.find(Index[Fish_Mutation], Fish_Name) then
            table.insert(Index[Fish_Mutation], Fish_Name)
        end
    end

    if not Util.TablesAreEqual(Index, Previous_Index) then
        Network.PlayerChanges.Index.Fire(Player, Index)

        World:set(Entity, Pair(Components.Relationships.Previous, Components.Index), Util.CopyTable(Index, true))

        Log.Info(`{Player.Name}'s index was changed`)
    end
end

local function Replicate_Tutorial_Step(Player: Player, Entity: Types.Entity)
    local Tutorial_Step = World:get(Entity, Components.Tutorial_Step)
    local Previous_Tutorial_Step = World:get(Entity, Pair(Components.Relationships.Previous, Components.Tutorial_Step))

    if Tutorial_Step ~= Previous_Tutorial_Step then
        Network.PlayerChanges.TutorialStep.Fire(Player, Tutorial_Step)

        World:set(Entity, Pair(Components.Relationships.Previous, Components.Tutorial_Step), Tutorial_Step)

        Log.Info(`{Player.Name}'s tutorial step was changed to {Tutorial_Step}`)
    end
end

local function Replicate_Friend_Boost(Player: Player, Entity: Types.Entity)
    local FriendBoost = World:get(Entity, Components.FriendBoost)
    local PreviousFriendBoost = World:get(Entity, Pair(Components.Relationships.Previous, Components.FriendBoost))

    if FriendBoost ~= PreviousFriendBoost then
        Network.PlayerChanges.FriendBoost.Fire(Player, FriendBoost)

        World:set(Entity, Pair(Components.Relationships.Previous, Components.FriendBoost), FriendBoost)

        Log.Info(`{Player.Name}'s friend boost was changed to {FriendBoost}`)
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.PostUpdate,
    system = function()
        for Entity, Player in Player_Entities:iter() do
            Replicate_Cash(Player, Entity)

            Replicate_Tool_Level(Player, Entity)

            Replicate_Luck_Level(Player, Entity)

            Replicate_Index(Player, Entity)

            Replicate_Tutorial_Step(Player, Entity)

            Replicate_Friend_Boost(Player, Entity)
        end
    end,
    runConditions = {},
}
