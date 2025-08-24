local Types = require("../Types")

export type Mutation = {
    Chance: number,
    Multiplier: number,
}

local Mutations: { [Types.Mutation]: Mutation } = {
    ["Gold"] = {
        Chance = 0.05,
        Multiplier = 2,
    },
    ["Diamond"] = {
        Chance = 0.02,
        Multiplier = 3,
    },
    --[[    ["Huge"] = {
        Chance = 0.015,
        Multiplier = 3.5,
    }, ]]
    ["Rainbow"] = {
        Chance = 0.01,
        Multiplier = 4,
    },
}

return table.freeze(Mutations)
