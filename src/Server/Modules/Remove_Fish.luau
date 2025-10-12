local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(ReplicatedStorage.Common.Types)

return function(Inventory: { Types.Item }, Name: string, Mutation: Types.Mutation?)
    for Slot, Item in pairs(Inventory) do
        if Item and Item.Name == Name and Item.Mutation == Mutation then
            Item.Amount -= 1

            if Item.Amount <= 0 then
                Inventory[Slot] = nil
            end
        end
    end
end
