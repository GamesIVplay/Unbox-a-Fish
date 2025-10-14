local Fish = require("./Fish")

type Rebirth = {
    Requirements: {
        Cash: number,
        Fish: { string },
    },
    Rewards: {
        Cash_Multiplier: number,
        Fish: { string },
    },
}

local Rebirths: { Rebirth } = {
    [1] = {
        Requirements = {
            Cash = 100000,
            Fish = { "Boneca Ambalabu", "Ta Ta Sahur" },
        },
        Rewards = {
            Cash_Multiplier = 1.1,
            Fish = { "Bananita Dolfinita" },
        },
    },
    [2] = {
        Requirements = {
            Cash = 500000,
            Fish = { "Brr Brr Patapim", "Lirilli Larila", "Zibra Zubra Zibralini" },
        },
        Rewards = {
            Cash_Multiplier = 1.2,
            Fish = { "Cappuccino Assassino" },
        },
    },
    [3] = {
        Requirements = {
            Cash = 1000000,
            Fish = { "Zibra Zubra Zibralini", "Bananita Dolfinita" },
        },
        Rewards = {
            Cash_Multiplier = 1.3,
            Fish = {},
        },
    },
    [4] = {
        Requirements = {
            Cash = 5000000,
            Fish = { "Pipi Kiwi", "Girafa Celeste" },
        },
        Rewards = {
            Cash_Multiplier = 1.4,
            Fish = { "Espressona Signora" },
        },
    },
    [5] = {
        Requirements = {
            Cash = 10000000,
            Fish = { "Bombardiro Crocodilo", "Bombombini Gusin" },
        },
        Rewards = {
            Cash_Multiplier = 1.5,
            Fish = { "Bluberini Octopusini" },
        },
    },
}

local function Verify_Integrity()
    for Index, Rebirth in Rebirths do
        for _, Name in Rebirth.Requirements.Fish do
            if not Fish[Name] then
                error(`Invalid fish in rebirth {Index} requirements: '{Name}'`)
            end
        end

        for _, Name in Rebirth.Rewards.Fish do
            if not Fish[Name] then
                error(`Invalid fish in rebirth {Index} rewards: '{Name}'`)
            end
        end
    end
end

Verify_Integrity()

return table.freeze(Rebirths)
