if not game:IsLoaded() then
    game.Loaded:Wait()
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Start = require(ReplicatedStorage.Common.Start)

local Systems = script.Parent.Systems

Start({
    require(Systems.Init_Local_Entity),
})

require(game:GetService("ReplicatedFirst").Network).ClientLoaded.Fire()
