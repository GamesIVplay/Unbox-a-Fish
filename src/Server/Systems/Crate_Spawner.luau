local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local Sounds = Assets:WaitForChild("Sounds")

local World_Sounds = Sounds:WaitForChild("World")
local Crate_Spawn_Sound = World_Sounds:WaitForChild("CrateSpawn") :: Sound

local Network = require(ServerScriptService.Network)

local Crates_Folder = workspace:WaitForChild("Crates")

local Jecs = require(ReplicatedStorage.Packages.Jecs)
local Pair = Jecs.pair

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local World = require(ReplicatedStorage.Common.World)

local Crates = require(ReplicatedStorage.Common.Modules.Crates)
local StatCalculator = require(ReplicatedStorage.Common.Modules.StatCalculator)

local Plots_With_Owner_Without_Crate = World:query(Components.Renderable)
    :with(Components.Tags.Plot, Pair(Components.Relationships.Owner, Jecs.Wildcard))
    :without(Pair(Components.Relationships.Crate, Jecs.Wildcard))
    :cached()

--[[ OLD ROLL

    local function Roll_Crate(LuckMultiplier: number)
    LuckMultiplier = LuckMultiplier

    local Total = 0
    local Adjusted = {}

    for Name, Data in Crates do
        local Weighted = Data.Chance ^ (1 / LuckMultiplier)
        Adjusted[Name] = Weighted
        Total += Weighted
    end

    local Roll = math.random() * Total
    local Cumulative = 0

    for Name, Weight in Adjusted do
        Cumulative += Weight
        if Roll <= Cumulative then
            return Name, Crates[Name]
        end
    end

    return
end]]

local function Roll_Crate(LuckMultiplier: number)
    local Total = 0
    local Adjusted = {}

    for Name, Data in Crates do
        -- Blend original chance with a flat 1 using luck
        -- Lower weight still means rarer
        local LerpFactor = (LuckMultiplier - 1) / 200 -- Tune this number (200) to control how fast luck scales
        local Weighted = Data.Chance * (1 - LerpFactor) + 1 * LerpFactor
        Adjusted[Name] = Weighted
        Total += Weighted
    end

    local Roll = math.random() * Total
    local Cumulative = 0

    for Name, Weight in Adjusted do
        Cumulative += Weight
        if Roll <= Cumulative then
            return Name, Crates[Name]
        end
    end

    return
end


return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = function()
        for Plot_Entity, Plot_Model: Model in Plots_With_Owner_Without_Crate:iter() do
            local Crate_Stand = Plot_Model:FindFirstChild("Crate_Stand") :: Model

            local Owner_Entity = World:target(Plot_Entity, Components.Relationships.Owner)
            local Owner_Player = World:get(Owner_Entity, Components.Player) :: Player

            local Tutorial_Step = World:get(Owner_Entity, Components.Tutorial_Step)

            local Crate_Queue = World:get(Owner_Entity, Components.Crate_Queue)
            local Luck_Level = World:get(Owner_Entity, Components.Luck_Level)
            local Luck_Multiplier = StatCalculator.Calculate_Luck(Luck_Level)

            if World:has(Owner_Entity, Components.Tags.DoubleLuck) then
                Luck_Multiplier *= 2
            end

            if World:get(Owner_Entity, Components.Double_Luck_Time_Remaining) > 0 then
                Luck_Multiplier *= 2
            end

            if
                World:get(Components.Server_Double_Luck_End_Time, Components.Server_Double_Luck_End_Time) > os.time()
            then
                Luck_Multiplier *= 2
            end

            local Crate_Name
            local Crate_Data

            if Tutorial_Step ~= 6 and not (Tutorial_Step > 10) then
                Crate_Name = "Wood Crate"
                Crate_Data = Crates[Crate_Name]
            elseif #Crate_Queue > 0 then
                Crate_Name = Crate_Queue[1]
                Crate_Data = Crates[Crate_Name]

                table.remove(Crate_Queue, 1)

                Network.Notification.Fire(Owner_Player, {
                    Text = `Your queued {Crate_Name} spawned!`,
                })

                World:set(Owner_Entity, Components.Crate_Queue, Crate_Queue)
            else
                Crate_Name, Crate_Data = Roll_Crate(Luck_Multiplier)
            end

            local Crate_Model = Crate_Data.Model:Clone()
            Crate_Model:PivotTo(Crate_Stand:GetPivot())
            Crate_Model:SetAttribute("Owner", Owner_Player.UserId)

            Crate_Model.Parent = Crates_Folder

            local PrimaryPart = Crate_Model.PrimaryPart

            local Spawn_Sound = Crate_Spawn_Sound:Clone()
            Spawn_Sound.PlayOnRemove = true
            Spawn_Sound.Parent = PrimaryPart
            Spawn_Sound:Destroy()

            Network.BounceCrate.FireAll(Crate_Model)

            local Crate_Entity = World:entity()

            World:set(Crate_Entity, Components.Name, Crate_Name)
            World:set(Crate_Entity, Components.Renderable, Crate_Model)
            World:set(Crate_Entity, Components.Health, Crate_Data.Health)
            World:set(Crate_Entity, Pair(Components.Relationships.Max, Components.Health), Crate_Data.Health)

            World:add(Crate_Entity, Components.Tags.Crate)
            World:add(Crate_Entity, Components.Tags.Networked)
            World:add(Crate_Entity, Pair(Components.Relationships.Owner, Plot_Entity))

            World:add(Plot_Entity, Pair(Components.Relationships.Crate, Crate_Entity))

            World:set(Crate_Entity, Components.Cleanup, function()
                Crate_Model:Destroy()
            end)
        end
    end,
    runConditions = {},
}
