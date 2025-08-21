local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Start = require(ReplicatedStorage.Common.Start)

local Systems = script.Parent.Systems

Start({ require(Systems.Player_Session) })
