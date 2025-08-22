local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Start = require(ReplicatedStorage.Common.Start)

local Systems = script.Parent.Systems

Start({ require(Systems.Plot_Setup), require(Systems.Player_Session), require(Systems.Plot_Assign), require(Systems.Player_Data_Replication) })
