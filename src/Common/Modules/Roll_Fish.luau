local Crates = require("./Crates")
local Mutations = require("./Mutations")

local Types = require("../Types")

local function Roll_Fish(Crate: string)
    local Crate_Data = Crates[Crate]

    local Roll = math.random()
    local Cumulative = 0

    for Name, Chance in Crate_Data.Fish do
        if Chance == 0 then
            continue
        end

        Cumulative += Chance
        if Roll <= Cumulative then
            return Name
        end
    end

    return
end

local function Roll_Mutation(Mutation_Multiplier: number?, Guarantee_Mutation: boolean): Types.Mutation?
    if Guarantee_Mutation then
        local total = 0
        for _, Data in Mutations do
            total += Data.Chance
        end

        local roll = math.random()
        local cumulative = 0
        for Mutation_Name, Data in Mutations do
            if Data.Chance == 0 then
                continue
            end

            cumulative += Data.Chance / total
            if roll <= cumulative then
                return Mutation_Name
            end
        end
    else
        for Mutation_Name, Data in Mutations do
            if Data.Chance == 0 then
                continue
            end
            
            local Chance = Data.Chance
            if Mutation_Multiplier then
                Chance *= Mutation_Multiplier
            end

            if math.random() < Chance then
                return Mutation_Name
            end
        end
    end

    return nil
end
return function(Crate: string, Mutation_Multiplier: number?, Gurantee_Mutation: boolean)
    return Roll_Fish(Crate), Roll_Mutation(Mutation_Multiplier, Gurantee_Mutation)
end
