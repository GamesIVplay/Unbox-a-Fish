if not game:IsLoaded() then
    game.Loaded:Wait()
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Start = require(ReplicatedStorage.Common.Start)

local Systems = script.Parent.Systems

Start({
    require(Systems.Init_Local_Entity),
    require(Systems.UI_Setup),
    require(Systems.Notification),
    require(Systems.Swing),
    require(Systems.Player_Data_Replication_Receiver),
})

require(game:GetService("ReplicatedFirst").Network).ClientLoaded.Fire()
