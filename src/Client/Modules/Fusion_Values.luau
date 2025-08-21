local Fusion = require(game:GetService("ReplicatedStorage").Packages.Fusion)

local Scope = Fusion.scoped(Fusion)

return table.freeze({
    Screen = Scope:Value("HUD"),
    Cash = Scope:Value(0),
    Tool_Level = Scope:Value(1),
    Luck_Level = Scope:Value(1),
    Index = Scope:Value({}),
    Tutorial_Step = Scope:Value(0),
    Friend_Boost = Scope:Value(1),
})
