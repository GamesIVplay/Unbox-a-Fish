local Debris = game:GetService("Debris")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local Sounds = Assets:WaitForChild("Sounds")

local UISounds = Sounds:WaitForChild("UI")
local TypeWriter = UISounds:WaitForChild("TypeWriter") :: Sound

local Network = require(ReplicatedFirst.Network)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

local DEFAULT_NOTIFICATION_DURATION = 2
local TIME_PER_LETTER = 0.05

local Notification_Query = World:query(Components.Text):with(Components.Tags.Notification):cached()

local function Handle_Server_Notifications()
    for _, Notification in Network.Notification.Iter() do
        local Duration = Notification.Duration or DEFAULT_NOTIFICATION_DURATION

        local Entity = World:entity()

        World:set(Entity, Components.Text, Notification.Text)
        World:set(Entity, Components.Duration, Duration)

        if Notification.Color then
            World:set(Entity, Components.Color, Notification.Color)
        end

        World:add(Entity, Components.Tags.Notification)
    end
end

local function Create_Notifications()
    local LocalEntity = Registry.Get("Players", "Local")

    local LocalPlayer = World:get(LocalEntity, Components.Player) :: Player

    local PlayerGui = LocalPlayer.PlayerGui

    local Notification_Screen_Gui = PlayerGui:FindFirstChild("Notifications")

    if not Notification_Screen_Gui then
        return
    end

    local Notifications = Notification_Screen_Gui:FindFirstChild("Notifications")

    if not Notifications then
        return
    end

    local Template = Notifications:FindFirstChild("Template") :: TextLabel?

    if not Template then
        return
    end

    for Entity, Text in Notification_Query:iter() do
        local Duration = World:get(Entity, Components.Duration) or DEFAULT_NOTIFICATION_DURATION
        local Color = World:get(Entity, Components.Color)

        -- ⚠️ Enforce max of 3 notifications
        local VisibleNotifications = {}
        for _, Child in Notifications:GetChildren() do
            if Child:IsA("TextLabel") and Child.Name ~= "Template" then
                table.insert(VisibleNotifications, Child)
            end
        end

        -- Sort by LayoutOrder (oldest first)
        table.sort(VisibleNotifications, function(A, B)
            return A.LayoutOrder < B.LayoutOrder
        end)

        -- Delete oldest if there are already 3
        if #VisibleNotifications >= 3 then
            VisibleNotifications[1]:Destroy()
        end

        local Notification = Template:Clone()
        Notification.Name = Text
        Notification.Text = Text
        Notification.Visible = true
        Notification.LayoutOrder = os.time()

        if Color then
            Notification.TextColor3 = Color
        end

        Notification.Parent = Notifications

        task.spawn(function()
            for i = 1, #Text do
                if Notification.Parent ~= Notifications then
                    return
                end

                Notification.Text = string.sub(Text, 1, i)

                TypeWriter:Play()

                task.wait(TIME_PER_LETTER)
            end
        end)

        local Time_To_Type_Out = #Text * TIME_PER_LETTER

        Debris:AddItem(Notification, Time_To_Type_Out + Duration)

        World:delete(Entity)
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = function()
        Handle_Server_Notifications()

        Create_Notifications()
    end,
    runConditions = {},
}
