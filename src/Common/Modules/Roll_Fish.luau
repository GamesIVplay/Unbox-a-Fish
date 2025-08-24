local Crates = require("./Crates")
local Mutations = require("./Mutations")

local Types = require("../Types")

local function Roll_Fish(Crate: string)
    local Crate_Data = Crates[Crate]

    local Roll = math.random()
    local Cumulative = 0

    for Name, Chance in Crate_Data.Fish do
        Cumulative += Chance
        if Roll <= Cumulative then
            return Name
        end
    end

    return
end

local function Roll_Mutation(): Types.Mutation?
    for Mutation_Name, Data in Mutations do
        if math.random() < Data.Chance then
            return Mutation_Name
        end
    end
    return nil
end

return function(Crate: string)
    return Roll_Fish(Crate), Roll_Mutation()
end
