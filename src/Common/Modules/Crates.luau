local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Crate_Models = Assets:WaitForChild("Crates")

local Fish = require("./Fish")

local Types = require("../Types")

export type Crate = {
    Rarity: Types.Rarity,
    Chance: number,
    Health: number,
    Price: number,
    Restock_Chance: number,
    Min_Stock: number,
    Max_Stock: number,
    Model: Model,
    Viewport_CFrame: CFrame,
    Fish: {
        [string]: number,
    },
    ProductId: number,
}

local Crates: { [string]: Crate } = {
    ["Wood Crate"] = {
        Rarity = "Common",
        Chance = 0.28,
        Health = 5,
        Price = 100,
        Restock_Chance = 1 / 1,
        Min_Stock = 1,
        Max_Stock = 10,
        Model = Crate_Models:WaitForChild("Wood Crate"),
        Viewport_CFrame = CFrame.new(0.07, -1.97, -6)
            * CFrame.fromEulerAnglesYXZ(math.rad(0), math.rad(0), math.rad(0)),
        Fish = {
            -- Common
            ["Lirilli Larila"] = 0.33,
            ["Boneca Ambalabu"] = 0.28,
            ["Trulimero Trulicina"] = 0.20,
            ["Trippi Troppi"] = 0.13,
            ["Brr Brr Patapim"] = 0.05,
            ["Frulli Frulla"] = 0.01,
        },
        ProductId = 3380324227,
    },
    ["Mossy Crate"] = {
        Rarity = "Common",
        Chance = 0.29,
        Health = 15,
        Price = 500,
        Restock_Chance = 1 / 1,
        Min_Stock = 1,
        Max_Stock = 9,
        Model = Crate_Models:WaitForChild("Mossy Crate"),
        Viewport_CFrame = CFrame.new(0.01, -2.5, -7)
            * CFrame.fromEulerAnglesYXZ(math.rad(0), math.rad(180), math.rad(0)),
        Fish = {
            -- Common
            ["Trulimero Trulicina"] = 0.33,
            ["Trippi Troppi"] = 0.28,
            ["Brr Brr Patapim"] = 0.20,
            ["Frulli Frulla"] = 0.13,
            ["Tung Tung Sahur"] = 0.05,
            ["Ta Ta Sahur"] = 0.01,
        },
        ProductId = 3380324352,
    },
    ["Bone Crate"] = {
        Rarity = "Rare",
        Chance = 0.17,
        Health = 25,
        Price = 2000,
        Restock_Chance = 1 / 3,
        Min_Stock = 1,
        Max_Stock = 7,
        Model = Crate_Models:WaitForChild("Bone Crate"),
        Viewport_CFrame = CFrame.new(0.07, -2.56, -8)
            * CFrame.fromEulerAnglesYXZ(math.rad(0), math.rad(0), math.rad(0)),
        Fish = {
            -- Common
            ["Lirilli Larila"] = 0.33,
            ["Boneca Ambalabu"] = 0.28,

            -- Rare
            ["Pipi Avocado"] = 0.20,
            ["Cappuccino Assassino"] = 0.13,
            ["Ballerina Cappuccina"] = 0.05,
            ["Bananita Dolfinita"] = 0.01,
        },
        ProductId = 3380324547,
    },
    ["Steel Crate"] = {
        Rarity = "Rare",
        Chance = 0.12,
        Health = 60,
        Price = 8000,
        Restock_Chance = 1 / 4,
        Min_Stock = 1,
        Max_Stock = 7,
        Model = Crate_Models:WaitForChild("Steel Crate"),
        Viewport_CFrame = CFrame.new(0.12, -3.01, -9)
            * CFrame.fromEulerAnglesYXZ(math.rad(0), math.rad(0), math.rad(0)),
        Fish = {
            -- Common
            ["Tung Tung Sahur"] = 0.33,
            ["Ta Ta Sahur"] = 0.28,

            -- Rare
            ["Pipi Avocado"] = 0.20,
            ["Cappuccino Assassino"] = 0.13,
            ["Zibra Zubra Zibralini"] = 0.05,
            ["Chef Crabacadabra"] = 0.01,
        },
        ProductId = 3380324807,
    },
    ["Spikey Crate"] = {
        Rarity = "Epic",
        Chance = 0.06,
        Health = 125,
        Price = 20000,
        Restock_Chance = 1 / 10,
        Min_Stock = 1,
        Max_Stock = 5,
        Model = Crate_Models:WaitForChild("Spikey Crate"),
        Viewport_CFrame = CFrame.new(0.17, -3.56, -10)
            * CFrame.fromEulerAnglesYXZ(math.rad(0), math.rad(0), math.rad(0)),
        Fish = {
            -- Rare
            ["Ballerina Cappuccina"] = 0.33,
            ["Bananita Dolfinita"] = 0.28,

            -- Epic
            ["Burbaloni Luliloli"] = 0.20,
            ["Chimpanzini Bananini"] = 0.13,
            ["Bluberini Octopusini"] = 0.06,
        },
        ProductId = 3380324979,
    },
    ["Lightning Crate"] = {
        Rarity = "Epic",
        Chance = 0.05,
        Health = 250,
        Price = 60000,
        Restock_Chance = 1 / 14,
        Min_Stock = 1,
        Max_Stock = 5,
        Model = Crate_Models:WaitForChild("Lightning Crate"),
        Viewport_CFrame = CFrame.new(-0.06, -3.88, -11)
            * CFrame.fromEulerAnglesYXZ(math.rad(0), math.rad(0), math.rad(0)),
        Fish = {
            -- Rare
            ["Zibra Zubra Zibralini"] = 0.33,
            ["Chef Crabacadabra"] = 0.28,

            -- Epic
            ["Glorbo Fruttodrillo"] = 0.20,
            ["Pipi Kiwi"] = 0.13,
            ["Espressona Signora"] = 0.06,
        },
        ProductId = 3380325162,
    },
    ["Abyssal Crate"] = {
        Rarity = "Legendary",
        Chance = 0.02,
        Health = 700,
        Price = 200000,
        Restock_Chance = 1 / 100,
        Min_Stock = 1,
        Max_Stock = 3,
        Model = Crate_Models:WaitForChild("Abyssal Crate"),
        Viewport_CFrame = CFrame.new(0, -3.6, -12) * CFrame.fromEulerAnglesYXZ(math.rad(0), math.rad(180), math.rad(0)),
        Fish = {
            -- Epic
            ["Glorbo Fruttodrillo"] = 0.33,
            ["Pipi Kiwi"] = 0.28,

            -- Legendary
            ["Girafa Celeste"] = 0.20,
            ["Bombombini Gusin"] = 0.07,
            ["Bombardiro Crocodilo"] = 0.06,
            ["Madudungdung"] = 0.06,
        },
        ProductId = 3380325284,
    },
    ["Kraken Crate"] = {
        Rarity = "Mythic",
        Chance = 0.01,
        Health = 1400,
        Price = 1000000,
        Restock_Chance = 1 / 240,
        Min_Stock = 1,
        Max_Stock = 2,
        Model = Crate_Models:WaitForChild("Kraken Crate"),
        Viewport_CFrame = CFrame.new(0, -3.6, -18) * CFrame.fromEulerAnglesYXZ(math.rad(0), math.rad(180), math.rad(0)),
        Fish = {
            -- Legendary
            ["Girafa Celeste"] = 0.25,
            ["Bombombini Gusin"] = 0.20,
            ["Bombardiro Crocodilo"] = 0.15,
            ["Madudungdung"] = 0.10,

            -- Mythic
            ["Los Tralalelitos"] = 0.10,
            ["Rhino toasterino"] = 0.08,
            ["Tralalero Tralala"] = 0.06,
            ["Trippi Troppi Troppa Trippa"] = 0.05,

            -- Secret
            ["Cannelloni Dragoni"] = 0.005,
            ["La Vacca Saturno Saturnita"] = 0.005,
        },
        ProductId = 3377759503,
    },
    ["Mutated Abyssal Crate"] = {
        Rarity = "Legendary",
        Chance = 0,
        Health = 800,
        Price = 9999999999,
        Restock_Chance = 0,
        Min_Stock = 1,
        Max_Stock = 3,
        Model = Crate_Models:WaitForChild("Mutated Abyssal Crate"),
        Viewport_CFrame = CFrame.new(0, -3.6, -12) * CFrame.fromEulerAnglesYXZ(math.rad(0), math.rad(180), math.rad(0)),
        Fish = {
            -- Epic
            ["Glorbo Fruttodrillo"] = 0.33,
            ["Pipi Kiwi"] = 0.28,

            -- Legendary
            ["Girafa Celeste"] = 0.20,
            ["Bombombini Gusin"] = 0.07,
            ["Bombardiro Crocodilo"] = 0.06,
            ["Madudungdung"] = 0.06,
        },
        ProductId = 3389821746,
    },
}

local function IsClose(a, b, eps)
    return math.abs(a - b) < (eps or 1e-6)
end

local function Verify_Integrity()
    local Total_Crate_Chances = 0

    for Crate_Name, Crate_Data in Crates do
        Total_Crate_Chances += Crate_Data.Chance

        local Total_Fish_Chance = 0

        for Fish_Name, Chance in Crate_Data.Fish do
            if not Fish[Fish_Name] then
                error(
                    string.format("Invalid Fish '%s' in Crate '%s' — not found in Fish table", Fish_Name, Crate_Name)
                )
            end
            Total_Fish_Chance += Chance
        end

        if not IsClose(Total_Fish_Chance, 1) then
            error(
                string.format(
                    "Total fish chance for crate '%s' must equal 1 (currently %.6f)",
                    Crate_Name,
                    Total_Fish_Chance
                )
            )
        end
    end

    if not IsClose(Total_Crate_Chances, 1) then
        error(string.format("Total trap chance must equal 1 (currently %.6f)", Total_Crate_Chances))
    end
end

Verify_Integrity()

return table.freeze(Crates)
