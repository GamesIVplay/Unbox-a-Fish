local MarketPlaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ServerScriptService.Network)

local Assets = ReplicatedStorage:WaitForChild("Assets")

local Types = require(ReplicatedStorage.Common.Types)

local GamepassIds = require(ReplicatedStorage.Common.Modules.GamepassIds)

local Collect = require(ReplicatedStorage.Common.Collect)
local Components = require(ReplicatedStorage.Common.Components)
local Log = require(ReplicatedStorage.Common.Log)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

return function(PlayerEntity: Types.Entity)
    local Player = World:get(PlayerEntity, Components.Player) :: Player

    if MarketPlaceService:UserOwnsGamePassAsync(Player.UserId, GamepassIds["x2 Cash"]) then
        World:add(PlayerEntity, Components.Tags.DoubleMoney)
    end

    if MarketPlaceService:UserOwnsGamePassAsync(Player.UserId, GamepassIds["x2 Luck"]) then
        World:add(PlayerEntity, Components.Tags.DoubleLuck)
    end

    if MarketPlaceService:UserOwnsGamePassAsync(Player.UserId, GamepassIds["x2 Slots"]) then
        World:add(PlayerEntity, Components.Tags.DoubleSlots)
    end

    if MarketPlaceService:UserOwnsGamePassAsync(Player.UserId, GamepassIds["x2 Mutations"]) then
        World:add(PlayerEntity, Components.Tags.DoubleMutations)
    end
end
