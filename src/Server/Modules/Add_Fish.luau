local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(ReplicatedStorage.Common.Types)

return function(Inventory: { Types.Item }, Name: string, Mutation: Types.Mutation?)
    for Slot: number, Item in Inventory do
        if Item.Name == Name and Item.Mutation == Mutation then
            Item.Amount += 1

            return
        end
    end

    for i = 1, #Inventory do
        if Inventory[i] ~= nil then
            continue
        end

        Inventory[i] = {
            Name = Name,
            Amount = 1,
            Mutation = Mutation,
        }

        return
    end

    table.insert(Inventory, {
        Name = Name,
        Amount = 1,
        Mutation = Mutation,
    })
end
