local StatCalculator = {}

function StatCalculator.Calculate_Luck(Luck_Level: number)
    return 1 + 0.25 * (Luck_Level - 1)
end

return table.freeze(StatCalculator)
