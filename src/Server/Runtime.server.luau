local ReplicatedStorage = game:GetService("ReplicatedStorage")

require(ReplicatedStorage.Common.Modules.Crates)
require(ReplicatedStorage.Common.Modules.Fish)

local Start = require(ReplicatedStorage.Common.Start)

local Systems = script.Parent.Systems

Start({
    require(Systems.Purchase_Handler),
    require(Systems.Plot_Setup),
    require(Systems.Player_Session),
    require(Systems.Plot_Assign),
    require(Systems.Plot_Loader),
    require(Systems.Upgrade_Tool),
    require(Systems.Upgrade_Luck),
    require(Systems.Upgrade_Auto_Swing),
    require(Systems.Restock),
    require(Systems.Crate_Buy),
    require(Systems.Crate_Spawner),
    require(Systems.Skip_Crate),
    require(Systems.Swing),
    require(Systems.Crate_Display),
    require(Systems.Place),
    require(Systems.Crate_Open),
    require(Systems.Cash_Generator),
    require(Systems.Collect),
    require(Systems.Pickup),
    require(Systems.Sell),
    require(Systems.Rig),
    require(Systems.Reducer),
    require(Systems.GroupReward),
    require(Systems.Fish_Cleanup),
    require(Systems.Leaderstats),
    require(Systems.Leaderboard),
    require(Systems.Player_Data_Replication),
})
