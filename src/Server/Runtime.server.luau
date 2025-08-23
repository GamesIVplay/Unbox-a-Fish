local ReplicatedStorage = game:GetService("ReplicatedStorage")

require(ReplicatedStorage.Common.Modules.Crates)
require(ReplicatedStorage.Common.Modules.Fish)

local Start = require(ReplicatedStorage.Common.Start)

local Systems = script.Parent.Systems

Start({
    require(Systems.Plot_Setup),
    require(Systems.Player_Session),
    require(Systems.Plot_Assign),
    require(Systems.Upgrade_Tool),
    require(Systems.Upgrade_Luck),
    require(Systems.Restock),
    require(Systems.Crate_Buy),
    require(Systems.Crate_Spawner),
    require(Systems.Crate_Display),
    require(Systems.Player_Data_Replication),
})
