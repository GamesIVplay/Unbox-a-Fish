local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Jecs = require(ReplicatedStorage.Packages.Jecs)
local Pair = Jecs.pair

local Characters = workspace:WaitForChild("Characters") :: Folder

PhysicsService:RegisterCollisionGroup("Character")
PhysicsService:CollisionGroupSetCollidable("Character", "Character", false)

local Network = require(ServerScriptService.Network)

local Profile = require(ServerScriptService.Server.Modules.Profile)

local Collect = require(ReplicatedStorage.Common.Collect)
local Components = require(ReplicatedStorage.Common.Components)
local Log = require(ReplicatedStorage.Common.Log)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

local PlayersRemoving = Collect(Players.PlayerRemoving)

local function Update_Character_Collision_Groups(Character: Model)
    for _, Part in Character:GetDescendants() do
        if not Part:IsA("BasePart") then
            continue
        end

        Part.CollisionGroup = "Character"
    end
end

local function Update_Friend_Boosts()
    for _, Player in Players:GetPlayers() do
        local PlayerEntity = Registry.Get("Players", Player)

        if not PlayerEntity then
            continue
        end

        local Friends = 0

        for _, TargetPlayer in Players:GetPlayers() do
            if TargetPlayer == Player then
                continue
            end

            if Player:IsFriendsWith(TargetPlayer.UserId) then
                Friends += 1
                break
            end
        end

        World:set(PlayerEntity, Components.FriendBoost, (Friends * 0.1) + 1)
    end
end

local function Handle_New_Players()
    for _, Player in Network.ClientLoaded.Iter() do
        task.spawn(function()
            if Registry.Get("Players", Player) ~= nil then
                return
            end

            local PlayerProfile = Profile.Load(Player)

            if not PlayerProfile then
                return
            end

            local ProfileData = PlayerProfile.Data

            local PlayerEntity = World:entity()
            Registry.Define("Players", Player, PlayerEntity)

            World:set(PlayerEntity, Components.Name, Player.Name)
            World:set(PlayerEntity, Components.Player, Player)

            World:set(PlayerEntity, Components.Cash, ProfileData.Cash)
            World:set(PlayerEntity, Components.Tool_Level, ProfileData.Tool_Level)
            World:set(PlayerEntity, Components.Luck_Level, ProfileData.Luck_Level)
            World:set(PlayerEntity, Components.Index, ProfileData.Index)
            World:set(PlayerEntity, Components.Inventory, ProfileData.Inventory)
            World:set(PlayerEntity, Components.Crate_Queue, ProfileData.Crate_Queue)
            World:set(PlayerEntity, Components.Stock, ProfileData.Stock)

            World:set(
                PlayerEntity,
                Components.Tutorial_Step,
                ProfileData.Tutorial_Step ~= 4 and ProfileData.Tutorial_Step or 5
            )

            if ProfileData.BoughtOneTimeOffer then
                World:add(PlayerEntity, Components.Tags.BoughtOneTimeOffer)
            end

            World:set(PlayerEntity, Components.LastPlayed, ProfileData.LastPlayed)
            World:set(PlayerEntity, Components.Unboxes, ProfileData.Unboxes)
            World:set(PlayerEntity, Components.Restock_Time, ProfileData.Restock_Time)

            World:set(PlayerEntity, Pair(Components.Relationships.Queued, Components.Tags.Fish), ProfileData.Fish)

            World:add(PlayerEntity, Components.Tags.Networked)

            World:set(PlayerEntity, Components.Cleanup, function()
                Profile.Unload(Player)

                Registry.Undefine("Players", Player)

                Log.Info(`Cleaned up {Player.Name}'s entity`)
            end)

            PlayerProfile.OnSave:Connect(function()
                if World:has(PlayerEntity, Pair(Components.Relationships.Queued, Components.Tags.Fish)) then
                    return
                end

                ProfileData.Cash = World:get(PlayerEntity, Components.Cash)
                ProfileData.Tool_Level = World:get(PlayerEntity, Components.Tool_Level)
                ProfileData.Luck_Level = World:get(PlayerEntity, Components.Luck_Level)
                ProfileData.Inventory = World:get(PlayerEntity, Components.Inventory)
                ProfileData.Index = World:get(PlayerEntity, Components.Index)
                ProfileData.Crate_Queue = World:get(PlayerEntity, Components.Crate_Queue)
                ProfileData.Stock = World:get(PlayerEntity, Components.Stock)
                ProfileData.Tutorial_Step = World:get(PlayerEntity, Components.Tutorial_Step)
                ProfileData.LastPlayed = os.time()
                ProfileData.Restock_Time = World:get(PlayerEntity, Components.Restock_Time)
                ProfileData.Unboxes = World:get(PlayerEntity, Components.Unboxes)
                ProfileData.BoughtOneTimeOffer = World:has(PlayerEntity, Components.Tags.BoughtOneTimeOffer)

                local Fish = {}

                for Fish_Entity, Fish_Name: string, Cash: number, Offline_Cash: number, Stand: Model in
                    World:query(
                        Components.Name,
                        Components.Cash,
                        Pair(Components.Relationships.Offline, Components.Cash),
                        Components.Stand
                    ):with(Pair(Components.Relationships.Owner, PlayerEntity))

                do
                    Fish[Stand.Name] = {
                        Name = Fish_Name,
                        Mutation = World:get(Fish_Entity, Components.Mutation),
                        Cash = Cash,
                        Offline_Cash = Offline_Cash,
                    }
                end

                ProfileData.Fish = Fish
            end)

            if Player.Character then
                Update_Character_Collision_Groups(Player.Character)

                Player.Character.Parent = Characters

                World:set(PlayerEntity, Components.Renderable, Player.Character)
            end

            Player.CharacterAdded:Connect(function(Character)
                World:set(PlayerEntity, Components.Renderable, Character)

                local PlotEntity = World:target(PlayerEntity, Components.Relationships.Plot)

                if not PlotEntity then
                    return
                end

                local PlotModel = World:get(PlotEntity, Components.Renderable) :: Model
                local Spawn = PlotModel:WaitForChild("Spawn") :: Part

                Character:PivotTo(Spawn.CFrame)
            end)

            Player.CharacterAppearanceLoaded:Connect(function(Character)
                Update_Character_Collision_Groups(Character)

                Character.Parent = Characters

                World:remove(PlayerEntity, Pair(Components.Relationships.Previous, Components.Tool_Level))
                World:remove(PlayerEntity, Pair(Components.Relationships.Previous, Components.Inventory))
            end)

            Player.CharacterRemoving:Connect(function()
                World:remove(PlayerEntity, Components.Renderable)
            end)

            Update_Friend_Boosts()

            for _, Fish_Model: Model in World:query(Components.Renderable):with(Components.Tags.Fish) do
                Network.NewFish.Fire(Player, Fish_Model)
            end

            Log.Info(`Setup {Player.Name}'s entity`)
        end)
    end
end

local function Handle_Leaving_Players()
    for Player in PlayersRemoving do
        Registry.Delete("Players", Player)

        Update_Friend_Boosts()
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.First,
    system = function()
        Handle_New_Players()

        Handle_Leaving_Players()
    end,
    runConditions = {},
}
