--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local Fish_Models = Assets:WaitForChild("Fish")
local Normal_Models = Fish_Models:WaitForChild("Normal")
local Gold_Models = Fish_Models:WaitForChild("Gold")
local Diamond_Models = Fish_Models:WaitForChild("Diamond")
local Rainbow_Models = Fish_Models:WaitForChild("Rainbow")

local Types = require(ReplicatedStorage.Common.Types)

type Fish = {
    Rarity: Types.Rarity,
    IncomePerSec: number,
    Sell_Price: number,
    Models: {
        Normal: Model,
        Gold: Model,
        Diamond: Model,
        Rainbow: Model,
    },
    Viewport_CFrame: CFrame,
}

local Fish: { [string]: Fish } = {
    -- Common

    ["Lirilli Larila"] = {
        Rarity = "Common",
        IncomePerSec = 1,
        Sell_Price = 20,
        Models = {
            Normal = Normal_Models:WaitForChild("Lirilli Larila"),
            Gold = Gold_Models:WaitForChild("Lirilli Larila"),
            Diamond = Diamond_Models:WaitForChild("Lirilli Larila"),
            Rainbow = Rainbow_Models:WaitForChild("Lirilli Larila"),
        },
        Viewport_CFrame = CFrame.new(0, -3.21, -8.35)
            * CFrame.fromEulerAnglesYXZ(math.rad(0), math.rad(209), math.rad(-1)),
    },
    ["Boneca Ambalabu"] = {
        Rarity = "Common",
        IncomePerSec = 2,
        Sell_Price = 40,
        Models = {
            Normal = Normal_Models:WaitForChild("Boneca Ambalabu"),
            Gold = Gold_Models:WaitForChild("Boneca Ambalabu"),
            Diamond = Diamond_Models:WaitForChild("Boneca Ambalabu"),
            Rainbow = Rainbow_Models:WaitForChild("Boneca Ambalabu"),
        },
        Viewport_CFrame = CFrame.new(-0.99, -3.21, -7.61)
            * CFrame.fromEulerAnglesYXZ(math.rad(0), math.rad(209), math.rad(-1)),
    },
    ["Trulimero Trulicina"] = {
        Rarity = "Common",
        IncomePerSec = 3,
        Sell_Price = 60,
        Models = {
            Normal = Normal_Models:WaitForChild("Trulimero Trulicina"),
            Gold = Gold_Models:WaitForChild("Trulimero Trulicina"),
            Diamond = Diamond_Models:WaitForChild("Trulimero Trulicina"),
            Rainbow = Rainbow_Models:WaitForChild("Trulimero Trulicina"),
        },
        Viewport_CFrame = CFrame.new(-0.99, -2.92, -7.61)
            * CFrame.fromEulerAnglesYXZ(math.rad(0), math.rad(209), math.rad(-1)),
    },
    ["Trippi Troppi"] = {
        Rarity = "Common",
        IncomePerSec = 4,
        Sell_Price = 80,
        Models = {
            Normal = Normal_Models:WaitForChild("Trippi Troppi"),
            Gold = Gold_Models:WaitForChild("Trippi Troppi"),
            Diamond = Diamond_Models:WaitForChild("Trippi Troppi"),
            Rainbow = Rainbow_Models:WaitForChild("Trippi Troppi"),
        },
        Viewport_CFrame = CFrame.new(-0.99, -2.92, -7.61)
            * CFrame.fromEulerAnglesYXZ(math.rad(0), math.rad(209), math.rad(-1)),
    },
    ["Brr Brr Patapim"] = {
        Rarity = "Common",
        IncomePerSec = 5,
        Sell_Price = 120,
        Models = {
            Normal = Normal_Models:WaitForChild("Brr Brr Patapim"),
            Gold = Gold_Models:WaitForChild("Brr Brr Patapim"),
            Diamond = Diamond_Models:WaitForChild("Brr Brr Patapim"),
            Rainbow = Rainbow_Models:WaitForChild("Brr Brr Patapim"),
        },
        Viewport_CFrame = CFrame.new(-0.99, -3.51, -7.61)
            * CFrame.fromEulerAnglesYXZ(math.rad(0), math.rad(209), math.rad(-1)),
    },
    ["Frulli Frulla"] = {
        Rarity = "Common",
        IncomePerSec = 6,
        Sell_Price = 150,
        Models = {
            Normal = Normal_Models:WaitForChild("Frulli Frulla"),
            Gold = Gold_Models:WaitForChild("Frulli Frulla"),
            Diamond = Diamond_Models:WaitForChild("Frulli Frulla"),
            Rainbow = Rainbow_Models:WaitForChild("Frulli Frulla"),
        },
        Viewport_CFrame = CFrame.new(0.12, -3.81, -6.13)
            * CFrame.fromEulerAnglesYXZ(math.rad(-4), math.rad(198), math.rad(1)),
    },
    ["Tung Tung Sahur"] = {
        Rarity = "Common",
        IncomePerSec = 7,
        Sell_Price = 200,
        Models = {
            Normal = Normal_Models:WaitForChild("Tung Tung Sahur"),
            Gold = Gold_Models:WaitForChild("Tung Tung Sahur"),
            Diamond = Diamond_Models:WaitForChild("Tung Tung Sahur"),
            Rainbow = Rainbow_Models:WaitForChild("Tung Tung Sahur"),
        },
        Viewport_CFrame = CFrame.new(0.05, -3.81, -6.13)
            * CFrame.fromEulerAnglesYXZ(math.rad(-4), math.rad(198), math.rad(1)),
    },
    ["Ta Ta Sahur"] = {
        Rarity = "Common",
        IncomePerSec = 8,
        Sell_Price = 250,
        Models = {
            Normal = Normal_Models:WaitForChild("Ta Ta Sahur"),
            Gold = Gold_Models:WaitForChild("Ta Ta Sahur"),
            Diamond = Diamond_Models:WaitForChild("Ta Ta Sahur"),
            Rainbow = Rainbow_Models:WaitForChild("Ta Ta Sahur"),
        },
        Viewport_CFrame = CFrame.new(0.2, -3.66, -6.13)
            * CFrame.fromEulerAnglesYXZ(math.rad(-4), math.rad(198), math.rad(1)),
    },

    -- Rare

    ["Pipi Avocado"] = {
        Rarity = "Rare",
        IncomePerSec = 10,
        Sell_Price = 400,
        Models = {
            Normal = Normal_Models:WaitForChild("Pipi Avocado"),
            Gold = Gold_Models:WaitForChild("Pipi Avocado"),
            Diamond = Diamond_Models:WaitForChild("Pipi Avocado"),
            Rainbow = Rainbow_Models:WaitForChild("Pipi Avocado"),
        },
        Viewport_CFrame = CFrame.new(-0.25, -3.66, -9.09)
            * CFrame.fromEulerAnglesYXZ(math.rad(2), math.rad(213), math.rad(2)),
    },
    ["Ballerina Cappuccina"] = {
        Rarity = "Rare",
        IncomePerSec = 20,
        Sell_Price = 800,
        Models = {
            Normal = Normal_Models:WaitForChild("Ballerina Cappuccina"),
            Gold = Gold_Models:WaitForChild("Ballerina Cappuccina"),
            Diamond = Diamond_Models:WaitForChild("Ballerina Cappuccina"),
            Rainbow = Rainbow_Models:WaitForChild("Ballerina Cappuccina"),
        },
        Viewport_CFrame = CFrame.new(-1.51, -3.73, -9.09)
            * CFrame.fromEulerAnglesYXZ(math.rad(2), math.rad(213), math.rad(2)),
    },
    ["Bananita Dolfinita"] = {
        Rarity = "Rare",
        IncomePerSec = 35,
        Sell_Price = 1200,
        Models = {
            Normal = Normal_Models:WaitForChild("Bananita Dolfinita"),
            Gold = Gold_Models:WaitForChild("Bananita Dolfinita"),
            Diamond = Diamond_Models:WaitForChild("Bananita Dolfinita"),
            Rainbow = Rainbow_Models:WaitForChild("Bananita Dolfinita"),
        },
        Viewport_CFrame = CFrame.new(-0.47, -4.77, -7.61)
            * CFrame.fromEulerAnglesYXZ(math.rad(2), math.rad(213), math.rad(2)),
    },
    ["Cappuccino Assassino"] = {
        Rarity = "Rare",
        IncomePerSec = 50,
        Sell_Price = 2000,
        Models = {
            Normal = Normal_Models:WaitForChild("Cappuccino Assassino"),
            Gold = Gold_Models:WaitForChild("Cappuccino Assassino"),
            Diamond = Diamond_Models:WaitForChild("Cappuccino Assassino"),
            Rainbow = Rainbow_Models:WaitForChild("Cappuccino Assassino"),
        },
        Viewport_CFrame = CFrame.new(0, -3.09, -9) * CFrame.fromEulerAnglesYXZ(math.rad(0), math.rad(180), math.rad(0)),
    },
    ["Zibra Zubra Zibralini"] = {
        Rarity = "Rare",
        IncomePerSec = 65,
        Sell_Price = 2500,
        Models = {
            Normal = Normal_Models:WaitForChild("Zibra Zubra Zibralini"),
            Gold = Gold_Models:WaitForChild("Zibra Zubra Zibralini"),
            Diamond = Diamond_Models:WaitForChild("Zibra Zubra Zibralini"),
            Rainbow = Rainbow_Models:WaitForChild("Zibra Zubra Zibralini"),
        },
        Viewport_CFrame = CFrame.new(0.17, -4.5, -8)
            * CFrame.fromEulerAnglesYXZ(math.rad(0), math.rad(180), math.rad(0)),
    },
    ["Chef Crabacadabra"] = {
        Rarity = "Rare",
        IncomePerSec = 80,
        Sell_Price = 3000,
        Models = {
            Normal = Normal_Models:WaitForChild("Chef Crabacadabra"),
            Gold = Gold_Models:WaitForChild("Chef Crabacadabra"),
            Diamond = Diamond_Models:WaitForChild("Chef Crabacadabra"),
            Rainbow = Rainbow_Models:WaitForChild("Chef Crabacadabra"),
        },
        Viewport_CFrame = CFrame.new(0, -5.07, -8) * CFrame.fromEulerAnglesYXZ(math.rad(0), math.rad(180), math.rad(0)),
    },

    -- Epic

    ["Burbaloni Luliloli"] = {
        Rarity = "Epic",
        IncomePerSec = 95,
        Sell_Price = 4000,
        Models = {
            Normal = Normal_Models:WaitForChild("Burbaloni Luliloli"),
            Gold = Gold_Models:WaitForChild("Burbaloni Luliloli"),
            Diamond = Diamond_Models:WaitForChild("Burbaloni Luliloli"),
            Rainbow = Rainbow_Models:WaitForChild("Burbaloni Luliloli"),
        },
        Viewport_CFrame = CFrame.new(-0.92, -3.67, -9)
            * CFrame.fromEulerAnglesYXZ(math.rad(0), math.rad(214), math.rad(0)),
    },
    ["Chimpanzini Bananini"] = {
        Rarity = "Epic",
        IncomePerSec = 110,
        Sell_Price = 6000,
        Models = {
            Normal = Normal_Models:WaitForChild("Chimpanzini Bananini"),
            Gold = Gold_Models:WaitForChild("Chimpanzini Bananini"),
            Diamond = Diamond_Models:WaitForChild("Chimpanzini Bananini"),
            Rainbow = Rainbow_Models:WaitForChild("Chimpanzini Bananini"),
        },
        Viewport_CFrame = CFrame.new(-0.47, -3.99, -8)
            * CFrame.fromEulerAnglesYXZ(math.rad(0), math.rad(214), math.rad(0)),
    },
    ["Bluberini Octopusini"] = {
        Rarity = "Epic",
        IncomePerSec = 120,
        Sell_Price = 10000,
        Models = {
            Normal = Normal_Models:WaitForChild("Bluberini Octopusini"),
            Gold = Gold_Models:WaitForChild("Bluberini Octopusini"),
            Diamond = Diamond_Models:WaitForChild("Bluberini Octopusini"),
            Rainbow = Rainbow_Models:WaitForChild("Bluberini Octopusini"),
        },
        Viewport_CFrame = CFrame.new(-0.47, -3.99, -8)
            * CFrame.fromEulerAnglesYXZ(math.rad(0), math.rad(214), math.rad(0)),
    },

    ["Glorbo Fruttodrillo"] = {
        Rarity = "Epic",
        IncomePerSec = 150,
        Sell_Price = 15000,
        Models = {
            Normal = Normal_Models:WaitForChild("Glorbo Fruttodrillo"),
            Gold = Gold_Models:WaitForChild("Glorbo Fruttodrillo"),
            Diamond = Diamond_Models:WaitForChild("Glorbo Fruttodrillo"),
            Rainbow = Rainbow_Models:WaitForChild("Glorbo Fruttodrillo"),
        },
        Viewport_CFrame = CFrame.new(-0.47, -3.99, -8)
            * CFrame.fromEulerAnglesYXZ(math.rad(0), math.rad(214), math.rad(0)),
    },

    ["Pipi Kiwi"] = {
        Rarity = "Epic",
        IncomePerSec = 180,
        Sell_Price = 18000,
        Models = {
            Normal = Normal_Models:WaitForChild("Pipi Kiwi"),
            Gold = Gold_Models:WaitForChild("Pipi Kiwi"),
            Diamond = Diamond_Models:WaitForChild("Pipi Kiwi"),
            Rainbow = Rainbow_Models:WaitForChild("Pipi Kiwi"),
        },
        Viewport_CFrame = CFrame.new(-0.47, -3.99, -8)
            * CFrame.fromEulerAnglesYXZ(math.rad(0), math.rad(214), math.rad(0)),
    },

    ["Espressona Signora"] = {
        Rarity = "Epic",
        IncomePerSec = 200,
        Sell_Price = 20000,
        Models = {
            Normal = Normal_Models:WaitForChild("Espressona Signora"),
            Gold = Gold_Models:WaitForChild("Espressona Signora"),
            Diamond = Diamond_Models:WaitForChild("Espressona Signora"),
            Rainbow = Rainbow_Models:WaitForChild("Espressona Signora"),
        },
        Viewport_CFrame = CFrame.new(-0.47, -3.99, -8)
            * CFrame.fromEulerAnglesYXZ(math.rad(0), math.rad(214), math.rad(0)),
    },

    -- Legendary

    ["Girafa Celeste"] = {
        Rarity = "Legendary",
        IncomePerSec = 300,
        Sell_Price = 50000,
        Models = {
            Normal = Normal_Models:WaitForChild("Girafa Celeste"),
            Gold = Gold_Models:WaitForChild("Girafa Celeste"),
            Diamond = Diamond_Models:WaitForChild("Girafa Celeste"),
            Rainbow = Rainbow_Models:WaitForChild("Girafa Celeste"),
        },
        Viewport_CFrame = CFrame.new(-0.47, -3.99, -8)
            * CFrame.fromEulerAnglesYXZ(math.rad(0), math.rad(214), math.rad(0)),
    },

    ["Bombombini Gusin"] = {
        Rarity = "Legendary",
        IncomePerSec = 500,
        Sell_Price = 70000,
        Models = {
            Normal = Normal_Models:WaitForChild("Bombombini Gusin"),
            Gold = Gold_Models:WaitForChild("Bombombini Gusin"),
            Diamond = Diamond_Models:WaitForChild("Bombombini Gusin"),
            Rainbow = Rainbow_Models:WaitForChild("Bombombini Gusin"),
        },
        Viewport_CFrame = CFrame.new(-0.47, -3.99, -8)
            * CFrame.fromEulerAnglesYXZ(math.rad(0), math.rad(214), math.rad(0)),
    },

    ["Bombardiro Crocodilo"] = {
        Rarity = "Legendary",
        IncomePerSec = 600,
        Sell_Price = 90000,
        Models = {
            Normal = Normal_Models:WaitForChild("Bombardiro Crocodilo"),
            Gold = Gold_Models:WaitForChild("Bombardiro Crocodilo"),
            Diamond = Diamond_Models:WaitForChild("Bombardiro Crocodilo"),
            Rainbow = Rainbow_Models:WaitForChild("Bombardiro Crocodilo"),
        },
        Viewport_CFrame = CFrame.new(-0.47, -3.99, -8)
            * CFrame.fromEulerAnglesYXZ(math.rad(0), math.rad(214), math.rad(0)),
    },

    ["Madudungdung"] = {
        Rarity = "Legendary",
        IncomePerSec = 800,
        Sell_Price = 120000,
        Models = {
            Normal = Normal_Models:WaitForChild("Madudungdung"),
            Gold = Gold_Models:WaitForChild("Madudungdung"),
            Diamond = Diamond_Models:WaitForChild("Madudungdung"),
            Rainbow = Rainbow_Models:WaitForChild("Madudungdung"),
        },
        Viewport_CFrame = CFrame.new(-0.47, -3.99, -8)
            * CFrame.fromEulerAnglesYXZ(math.rad(0), math.rad(214), math.rad(0)),
    },

    -- Mythic

    ["Rhino toasterino"] = {
        Rarity = "Mythic",
        IncomePerSec = 1000,
        Sell_Price = 250000,
        Models = {
            Normal = Normal_Models:WaitForChild("Rhino toasterino"),
            Gold = Gold_Models:WaitForChild("Rhino toasterino"),
            Diamond = Diamond_Models:WaitForChild("Rhino toasterino"),
            Rainbow = Rainbow_Models:WaitForChild("Rhino toasterino"),
        },
        Viewport_CFrame = CFrame.new(-0.47, -3.99, -8)
            * CFrame.fromEulerAnglesYXZ(math.rad(0), math.rad(214), math.rad(0)),
    },

    ["Tralalero Tralala"] = {
        Rarity = "Mythic",
        IncomePerSec = 3000,
        Sell_Price = 600000,
        Models = {
            Normal = Normal_Models:WaitForChild("Tralalero Tralala"),
            Gold = Gold_Models:WaitForChild("Tralalero Tralala"),
            Diamond = Diamond_Models:WaitForChild("Tralalero Tralala"),
            Rainbow = Rainbow_Models:WaitForChild("Tralalero Tralala"),
        },
        Viewport_CFrame = CFrame.new(-0.47, -3.99, -8)
            * CFrame.fromEulerAnglesYXZ(math.rad(0), math.rad(214), math.rad(0)),
    },

    ["Los Tralalelitos"] = {
        Rarity = "Mythic",
        IncomePerSec = 5000,
        Sell_Price = 900000,
        Models = {
            Normal = Normal_Models:WaitForChild("Los Tralalelitos"),
            Gold = Gold_Models:WaitForChild("Los Tralalelitos"),
            Diamond = Diamond_Models:WaitForChild("Los Tralalelitos"),
            Rainbow = Rainbow_Models:WaitForChild("Los Tralalelitos"),
        },
        Viewport_CFrame = CFrame.new(-0.47, -3.99, -8)
            * CFrame.fromEulerAnglesYXZ(math.rad(0), math.rad(214), math.rad(0)),
    },

    ["Trippi Troppi Troppa Trippa"] = {
        Rarity = "Mythic",
        IncomePerSec = 8000,
        Sell_Price = 1400000,
        Models = {
            Normal = Normal_Models:WaitForChild("Trippi Troppi Troppa Trippa"),
            Gold = Gold_Models:WaitForChild("Trippi Troppi Troppa Trippa"),
            Diamond = Diamond_Models:WaitForChild("Trippi Troppi Troppa Trippa"),
            Rainbow = Rainbow_Models:WaitForChild("Trippi Troppi Troppa Trippa"),
        },
        Viewport_CFrame = CFrame.new(-0.47, -3.99, -8)
            * CFrame.fromEulerAnglesYXZ(math.rad(0), math.rad(214), math.rad(0)),
    },

    -- Secret

    ["Cannelloni Dragoni"] = {
        Rarity = "Secret",
        IncomePerSec = 50000,
        Sell_Price = 6000000,
        Models = {
            Normal = Normal_Models:WaitForChild("Cannelloni Dragoni"),
            Gold = Gold_Models:WaitForChild("Cannelloni Dragoni"),
            Diamond = Diamond_Models:WaitForChild("Cannelloni Dragoni"),
            Rainbow = Rainbow_Models:WaitForChild("Cannelloni Dragoni"),
        },
        Viewport_CFrame = CFrame.new(-0.47, -3.99, -8)
            * CFrame.fromEulerAnglesYXZ(math.rad(0), math.rad(214), math.rad(0)),
    },

    ["La Vacca Saturno Saturnita"] = {
        Rarity = "Secret",
        IncomePerSec = 100000,
        Sell_Price = 10000000,
        Models = {
            Normal = Normal_Models:WaitForChild("La Vacca Saturno Saturnita"),
            Gold = Gold_Models:WaitForChild("La Vacca Saturno Saturnita"),
            Diamond = Diamond_Models:WaitForChild("La Vacca Saturno Saturnita"),
            Rainbow = Rainbow_Models:WaitForChild("La Vacca Saturno Saturnita"),
        },
        Viewport_CFrame = CFrame.new(-0.47, -3.99, -8)
            * CFrame.fromEulerAnglesYXZ(math.rad(0), math.rad(214), math.rad(0)),
    },
}

return table.freeze(Fish)
