local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(ReplicatedStorage.Common.Types)

local Log = require(ReplicatedStorage.Common.Log)

type ProfileData = {
    Cash: number,
    Tool_Level: number,
    Luck_Level: number,
    Auto_Swing_Level: number,
    Index: {
        [string]: { string },
    },
    Inventory: {
        [number]: Types.Item,
    },
    Crate_Queue: {
        [number]: string,
    },
    Fish: {
        [number]: Types.SerializedFish,
    },
    Stock: {
        [string]: number,
    },
    Tutorial_Step: number,
    Restock_Time: number,
    LastPlayed: number,
    Unboxes: number,
    BoughtOneTimeOffer: boolean,
    Double_Luck_Time_Remaining: number,
    Double_Mutation_Time_Remaining: number,
    Claimed_Group_Rewards: boolean,
}

local ProfileStore = require(ReplicatedStorage.Packages.ProfileStore)
type Profile = ProfileStore.Profile<ProfileData>

local PLAYER_DATA_TEMPLATE: ProfileData = {
    Cash = 600,
    Tool_Level = 1,
    Luck_Level = 1,
    Auto_Swing_Level = 1,
    Inventory = {},
    New_Inventory = {},
    Index = {},
    Crate_Queue = {},
    Fish = {},
    Stock = {},
    Tutorial_Step = 0,
    Restock_Time = os.time() + 60 * 2,
    LastPlayed = os.time(),
    Unboxes = 0,
    BoughtOneTimeOffer = false,
    Double_Luck_Time_Remaining = 0,
    Double_Mutation_Time_Remaining = 0,
    Claimed_Group_Rewards = false,
}

local PlayerProfileStore = ProfileStore.New("Not_Main", PLAYER_DATA_TEMPLATE)

local Profiles: { [Player]: Profile } = {}

function Load_Profile(Player: Player): Profile?
    if not Player:IsDescendantOf(Players) then
        return nil
    end

    local Profile

    if _G.IN_DEV == true then
        Profile = PlayerProfileStore.Mock:StartSessionAsync(tostring(Player.UserId), {
            Cancel = function()
                return not Player:IsDescendantOf(Players)
            end,
        })
    else
        Profile = PlayerProfileStore:StartSessionAsync(tostring(Player.UserId), {
            Cancel = function()
                return not Player:IsDescendantOf(Players)
            end,
        })
    end

    if Profile then
        Profile:AddUserId(Player.UserId)
        Profile:Reconcile()

        Profile.OnSessionEnd:Connect(function()
            Profiles[Player] = nil

            Player:Kick(`Profile session ended - please rejoin`)

            Log.Info(`Profile session ended for: '{Player.Name}'`)
        end)

        if Player.Parent == Players then
            Profiles[Player] = Profile

            Log.Info(`Profile loaded for: '{Player.Name}'`)

            return Profile
        else
            Profile:EndSession()

            Log.Info(`'{Player.Name}' left before their profile loaded`)

            return nil
        end
    else
        Player:Kick(`Profile failed to load`)

        Log.Warn(`Profile failed to load for: '{Player.Name}'`)

        return nil
    end
end

function Unload_Profile(Player: Player)
    local Profile = Profiles[Player]

    if Profile then
        Profile:EndSession()
        Profiles[Player] = nil

        Log.Info(`Profile unloaded for: '{Player.Name}'`)
    end
end

return table.freeze({
    Load = Load_Profile,
    Unload = Unload_Profile,
})
