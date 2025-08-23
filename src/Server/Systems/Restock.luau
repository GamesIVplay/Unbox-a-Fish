local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ServerScriptService.Network)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local World = require(ReplicatedStorage.Common.World)

local Crates = require(ReplicatedStorage.Common.Modules.Crates)

local Stocks = World:query(Components.Player, Components.Restock_Time, Components.Stock):cached()

return {
    name = script.Name,
    phase = Phases.Runservice.PreUpdate,
    system = function()
        for Player_Entity, Player: Player, Restock_Time: number, Stock: { [string]: number } in Stocks:iter() do
            if os.time() >= Restock_Time then
                table.clear(Stock)

                World:set(Player_Entity, Components.Restock_Time, os.time() + 60 * 5)

                Network.Notification.Fire(Player, {
                    Text = "The shop has been restocked!",
                })
            end

            for Crate_Name, Crate_Data in Crates do
                if Stock[Crate_Name] then
                    continue
                end

                if math.random() <= Crate_Data.Restock_Chance then
                    Stock[Crate_Name] = math.random(Crate_Data.Min_Stock, Crate_Data.Max_Stock)
                else
                    Stock[Crate_Name] = 0
                end
            end

            World:set(Player_Entity, Components.Stock, Stock)
        end
    end,
    runConditions = {},
}
