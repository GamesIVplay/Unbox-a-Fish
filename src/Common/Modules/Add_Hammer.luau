local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Components = require(ReplicatedStorage.Common.Components)
local World = require(ReplicatedStorage.Common.World)

local Types = require(ReplicatedStorage.Common.Types)

local Hammers = require(ReplicatedStorage.Common.Modules.Hammers)

return function(Entity: Types.Entity, Player: Player)
    local Tool_Level = World:get(Entity, Components.Tool_Level)

    for _, Inst in Player.Backpack:GetChildren() do
        if Inst:HasTag("Hammer") then
            Inst:Destroy()
        end
    end

    if Player.Character then
        for _, Inst in Player.Character:GetChildren() do
            if Inst:HasTag("Hammer") then
                Inst:Destroy()
            end
        end
    end

    local Hammer = Hammers[Tool_Level].Model:Clone()
    Hammer:AddTag("Hammer")
    Hammer.Parent = Player.Backpack
end
