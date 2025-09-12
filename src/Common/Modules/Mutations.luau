local Types = require("../Types")

export type Mutation = {
    Chance: number,
    Multiplier: number,
}

local Mutations: { [Types.Mutation]: Mutation } = {
    -- Regular Mutations
    ["Gold"] = {
        Chance = 0.05,
        Multiplier = 2,
    },
    ["Diamond"] = {
        Chance = 0.02,
        Multiplier = 3,
    },
    ["Rainbow"] = {
        Chance = 0.01,
        Multiplier = 10,
    },

    -- Event Mutations
    ["Shocked"] = {
        Chance = 0, 
        Multiplier = 1
    },
    ["Candy"] = {
        Chance = 0,
        Multiplier = 1
    },
    ["BloodMoon"] = {
        Chance = 0, 
        Multiplier = 3
    }
    
}

return table.freeze(Mutations)