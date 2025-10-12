local MarketPlaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Fish_Folder = workspace:WaitForChild("Fish")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local Sounds = Assets:WaitForChild("Sounds")

local World_Sounds = Sounds:WaitForChild("World")
local Crate_Spawn_Sound = World_Sounds:WaitForChild("CrateSpawn") :: Sound

local Fish_Sounds = Sounds:WaitForChild("Fish")

local Types = require(ReplicatedStorage.Common.Types)

local Jecs = require(ReplicatedStorage.Packages.Jecs)
local Pair = Jecs.pair

local Ratelimit = require(ReplicatedStorage.Packages.Ratelimit)
local Place_Rate_Limit = Ratelimit(1, 0.5)

local GamepassIds = require(ReplicatedStorage.Common.Modules.GamepassIds)

local Network = require(ServerScriptService.Network)

local Remove_Fish = require(ServerScriptService.Server.Modules.Remove_Fish)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

local Colors = require(ReplicatedStorage.Common.Modules.Colors)
local Fish = require(ReplicatedStorage.Common.Modules.Fish)

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = function()
        for _, Player: Player, Open_Stand: Model in Network.Requests.Place.Iter() do
            if not Place_Rate_Limit(Player) then
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

            local Plot_Entity = World:target(Player_Entity, Components.Relationships.Plot)

            if not Plot_Entity then
                continue
            end

            local Plot_Model = World:get(Plot_Entity, Components.Renderable) :: Model

            local Stands = Plot_Model:FindFirstChild("Stands")

            if Open_Stand.Parent ~= Stands then
                continue
            end

            if Open_Stand:HasTag("Occupied") then
                continue
            end

            local Tutorial_Step = World:get(Player_Entity, Components.Tutorial_Step)

            if not (Tutorial_Step > 10) then
                Network.Notification.Fire(Player, {
                    Text = "Complete the tutorial first",
                })
                continue
            end

            local Stand_Number = tonumber(Open_Stand.Name)

            if Stand_Number == 11 or Stand_Number == 12 then
                if not World:has(Player_Entity, Components.Tags.DoubleSlots) then
                    MarketPlaceService:PromptGamePassPurchase(Player, GamepassIds["x2 Slots"])
                    continue
                end
            end

            local Equipped_Slot = World:get(Player_Entity, Components.Equipped_Slot)
            local Inventory = World:get(Player_Entity, Components.Inventory)

            local Equipped_Item = Inventory[Equipped_Slot]

            local Held_Fish_Name: string?
            local Held_Fish_Mutation: Types.Mutation?

            if Equipped_Slot ~= 1 and Equipped_Item then
                Held_Fish_Name = Equipped_Item.Name
                Held_Fish_Mutation = Equipped_Item.Mutation
            end

            if not Held_Fish_Name then
                Network.Notification.Fire(Player, {
                    Text = "Your not holding a fish",
                    Color = Colors.Error,
                })
                continue
            end

            Remove_Fish(Inventory, Held_Fish_Name, Held_Fish_Mutation)

            local Stand = Open_Stand:FindFirstChild("Stand") :: Model

            Open_Stand:AddTag("Occupied")

            local Fish_Data = Fish[Held_Fish_Name]

            local Fish_Model = Fish_Data.Models[Held_Fish_Mutation or "Normal"]:Clone() :: Model
            Fish_Model.Parent = Fish_Folder
            Fish_Model:PivotTo(Stand:GetPivot())
            local PrimaryPart = Fish_Model.PrimaryPart

            task.delay(1, function()
                local Voice_Sound = Fish_Sounds:FindFirstChild(Held_Fish_Name)

                if not Voice_Sound or not PrimaryPart then
                    return
                end

                Voice_Sound = Voice_Sound:Clone()
                Voice_Sound.PlayOnRemove = true
                Voice_Sound.Parent = PrimaryPart
                Voice_Sound:Destroy()
            end)

            local Spawn_Sound = Crate_Spawn_Sound:Clone()
            Spawn_Sound.PlayOnRemove = true
            Spawn_Sound.Parent = PrimaryPart
            Spawn_Sound:Destroy()

            Network.NewFish.FireAll(Fish_Model)
            Network.AddPickupPrompt.Fire(Player, Fish_Model)
            Network.AddOwnedHighlight.Fire(Player, Fish_Model)

            local Fish_Entity = World:entity()

            Open_Stand:SetAttribute("ServerEntity", Fish_Entity)

            World:set(Fish_Entity, Components.Name, Held_Fish_Name)
            World:set(Fish_Entity, Components.Renderable, Fish_Model)
            World:set(Fish_Entity, Components.Stand, Open_Stand)
            World:set(Fish_Entity, Components.Cash, 0)
            World:set(Fish_Entity, Pair(Components.Relationships.Offline, Components.Cash), 0)

            if Held_Fish_Mutation ~= nil then
                World:set(Fish_Entity, Components.Mutation, Held_Fish_Mutation)
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

            World:set(Player_Entity, Components.Inventory, Inventory)

            Network.Notification.Fire(Player, {
                Text = "Fish was placed",
            })
        end
    end,
    runConditions = {},
}
