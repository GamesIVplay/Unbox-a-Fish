local Types = require("../Types")

export type Mutation = {
    Chance: number,
    Multiplier: number,
}

local Mutations: { [Types.Mutation]: Mutation } = {
    ["Gold"] = {
        Chance = 0.05,
        Multiplier = 5,
    },
    ["Diamond"] = {
        Chance = 0.02,
        Multiplier = 20,
    },
    ["Rainbow"] = {
        Chance = 0.01,
        Multiplier = 50,
    },
}

return table.freeze(Mutations)
