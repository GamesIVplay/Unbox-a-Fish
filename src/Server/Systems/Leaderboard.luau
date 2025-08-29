local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Cash_Leaderboard_Data_Store = DataStoreService:GetOrderedDataStore("Cash")
local Unbox_Leaderboard_Data_Store = DataStoreService:GetOrderedDataStore("Unbox")

local Map = workspace:WaitForChild("Map")

local Leaderboards = Map:WaitForChild("Leaderboards")

local Cash_Leaderboard = Leaderboards:WaitForChild("Cash_Leaderboard")
local Cash_Scrolling_Frame = Cash_Leaderboard:FindFirstChild("ScrollingFrame", true) :: ScrollingFrame

local Unbox_Leaderboard = Leaderboards:WaitForChild("Unbox_Leaderboard")
local Unbox_Scrolling_Frame = Unbox_Leaderboard:FindFirstChild("ScrollingFrame", true) :: ScrollingFrame

local Phases = require(ReplicatedStorage.Common.Phases)

local Util = require(ReplicatedStorage.Common.Modules.Util)
local Abbreviate_Number = require(ReplicatedStorage.Common.Modules.Abbreviate_Number)

local Log = require(ReplicatedStorage.Common.Log)

local Ratelimit = require(ReplicatedStorage.Packages.Ratelimit)
local Can_Run = Ratelimit(1, 60 * 5)

local MAX_ATTEMPTS = 3

local function Fetch_Leaderboard_Data(OrderedDataStore: OrderedDataStore)
    local Attempts = 0

    local New_Entries = {}

    while Attempts < MAX_ATTEMPTS do
        local Success, Error = pcall(function()
            local TopData = OrderedDataStore:GetSortedAsync(false, 20)

            for Index, Data in ipairs(TopData:GetCurrentPage()) do
                local UserId: number = Data.key
                local PlayerInfo = Util.Get_Player_Info(UserId)

                New_Entries[Index] = {
                    Name = PlayerInfo.Name,
                    Image = PlayerInfo.Image,
                    Value = Data.value,
                }
            end
        end)

        if Success then
            break
        else
            Log.Warn(`Failed to fetch leaderboard data :C`, Error)
            Attempts += 1
            task.wait(5 * Attempts)
        end
    end

    return New_Entries
end

local function Update_Catches_Leaderboard()
    local Template = Cash_Scrolling_Frame:WaitForChild("Template")
    Template.Visible = false

    local Entries = Fetch_Leaderboard_Data(Cash_Leaderboard_Data_Store)

    for _, Inst in Cash_Scrolling_Frame:GetChildren() do
        if Inst:HasTag("Can_Delete") then
            Inst:Destroy()
        end
    end

    for Rank, Data in Entries do
        local Clone = Template:Clone()
        Clone.Rank.ImageLabel.Image = Data.Image
        Clone.Rank.TextLabel.Text = Rank .. "."
        Clone.Username.TextLabel.Text = Data.Name
        Clone.Amount.TextLabel.Text = `${Abbreviate_Number(Data.Value, 2)}`
        Clone:AddTag("Can_Delete")

        Clone.Visible = true
        Clone.Parent = Cash_Scrolling_Frame
    end
end

local function Update_Steals_Leaderboard()
    local Template = Unbox_Scrolling_Frame:WaitForChild("Template")
    Template.Visible = false

    local Entries = Fetch_Leaderboard_Data(Unbox_Leaderboard_Data_Store)

    for _, Inst in Unbox_Scrolling_Frame:GetChildren() do
        if Inst:HasTag("Can_Delete") then
            Inst:Destroy()
        end
    end

    for Rank, Data in Entries do
        local Clone = Template:Clone()
        Clone.Rank.ImageLabel.Image = Data.Image
        Clone.Rank.TextLabel.Text = Rank .. "."
        Clone.Username.TextLabel.Text = Data.Name
        Clone.Amount.TextLabel.Text = Abbreviate_Number(Data.Value, 2)
        Clone:AddTag("Can_Delete")

        Clone.Visible = true
        Clone.Parent = Unbox_Scrolling_Frame
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.PreUpdate,
    system = function()
        task.spawn(function()
            Update_Catches_Leaderboard()

            Update_Steals_Leaderboard()
        end)
    end,
    runConditions = {
        function()
            return Can_Run()
        end,
    },
}