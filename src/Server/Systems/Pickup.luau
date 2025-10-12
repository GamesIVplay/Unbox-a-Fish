local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Debris_Folder = workspace:WaitForChild("Debris")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local Sounds = Assets:WaitForChild("Sounds")

local World_Sounds = Sounds:WaitForChild("World")
local Pickup_Sound = World_Sounds:WaitForChild("Pickup")

local Ratelimit = require(ReplicatedStorage.Packages.Ratelimit)
local Pickup_Rate_Limit = Ratelimit(1, 0.5)

local Network = require(ServerScriptService.Network)

local Add_Fish = require(ServerScriptService.Server.Modules.Add_Fish)

local Jecs = require(ReplicatedStorage.Packages.Jecs)
local Pair = Jecs.pair

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = function()
        for _, Player: Player, ServerEntity in Network.Requests.Pickup.Iter() do
            if not Pickup_Rate_Limit(Player) then
                continue
            end

            if not World:contains(ServerEntity) then
                continue
            end

            local Player_Entity = Registry.Get("Players", Player)

            if not Player_Entity then
                continue
            end

            if not World:has(Player_Entity, Pair(Components.Relationships.Fish, ServerEntity)) then
                continue
            end

            local Stand = World:get(ServerEntity, Components.Stand)

            local Tutorial_Step = World:get(Player_Entity, Components.Tutorial_Step)

            if Tutorial_Step == 8 and Stand.Name == "1" then
                World:set(Player_Entity, Components.Tutorial_Step, 9)
            elseif not (Tutorial_Step > 10) and not (Tutorial_Step == 8 and Stand.Name == "1") then
                Network.Notification.Fire(Player, {
                    Text = "Complete the tutorial first",
                })
                continue
            end

            local Inventory = World:get(Player_Entity, Components.Inventory)

            local Fish_Name = World:get(ServerEntity, Components.Name)
            local Fish_Mutation = World:get(ServerEntity, Components.Mutation)
            local Fish_Model = World:get(ServerEntity, Components.Renderable)

            Add_Fish(Inventory, Fish_Name, Fish_Mutation)

            Network.Notification.Fire(Player, {
                Text = `Fish picked up`,
            })

            local Part = Instance.new("Part")
            Part.Transparency = 1
            Part.CFrame = Fish_Model:GetPivot() * CFrame.new(0, 4, 0)
            Part.CanCollide = false
            Part.Anchored = true
            Part.Parent = Debris_Folder

            local Remove_Sound = Pickup_Sound:Clone()
            Remove_Sound.PlayOnRemove = true
            Remove_Sound.Parent = Part
            Remove_Sound:Destroy()

            Debris:AddItem(Part, 2)

            World:delete(ServerEntity)
        end
    end,
    runConditions = {},
}
