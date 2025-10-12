if not game:IsLoaded() then
    game.Loaded:Wait()
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local Start = require(ReplicatedStorage.Common.Start)

local Systems = script.Parent.Systems

repeat
    local Success = pcall(function()
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
        StarterGui:SetCore("ResetButtonCallback", false)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
    end)
    task.wait(1)
until Success == true

Start({
    require(Systems.Init_Local_Entity),
    require(Systems.UI_Setup),
    require(Systems.Crate_Open),
    require(Systems.Notification),
    require(Systems.Swing),
    require(Systems.Player_Data_Replication_Receiver),
})

require(game:GetService("ReplicatedFirst").Network).ClientLoaded.Fire()
