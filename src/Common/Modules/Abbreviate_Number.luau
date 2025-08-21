local Abbreviations = {
    "K",
    "M",
    "B",
    "T",
    "QD",
    "QT",
    "SXT",
    "SEPT",
    "OCT",
    "NON",
    "DEC",
    "UDEC",
    "DDEC",
}

return function(Number: number, Decimals: number?)
    if Number < 1000 then
        return tostring(Number)
    end

    Decimals = Decimals or 1

    local Digits = math.floor(math.log10(Number)) + 1
    local Index = math.min(#Abbreviations, math.floor((Digits - 1) / 3))
    local Visible = Number / math.pow(10, Index * 3 - Decimals :: number)
    local Suffix = Abbreviations[Index] --[[.. "+"]]

    local Front = Visible / math.pow(10, Decimals :: number)
    local Back = Visible % math.pow(10, Decimals :: number)

    if Decimals > 0 and Back > 0 then
        return string.format("%i.%0." .. tostring(Decimals) .. "i%s", Front, Back, Suffix)
    else
        return string.format("%i%s", Front, Suffix)
    end
end
