local Fusion = require(game:GetService("ReplicatedStorage").Packages.Fusion)

local Scope = Fusion.scoped(Fusion)

return table.freeze({
    Screen = Scope:Value("HUD"),
    Cash = Scope:Value(0),
    Tool_Level = Scope:Value(1),
    Luck_Level = Scope:Value(1),
    Auto_Swing_Level = Scope:Value(1),
    Index = Scope:Value({}),
    Inventory = Scope:Value({}),
    Tutorial_Step = Scope:Value(11),
    Friend_Boost = Scope:Value(1),
    Restock_Time = Scope:Value(0),
    Stock = Scope:Value({}),
    Bought_One_Time_Offer = Scope:Value(true),
    Auto_Swing = Scope:Value(false),
    Auto_Swing_Visible = Scope:Value(false),
    Equipped_Slot = Scope:Value(0),
})
