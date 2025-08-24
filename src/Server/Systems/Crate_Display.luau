local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local Billboards = Assets:WaitForChild("Billboards")
local Crate_Overhead = Billboards:WaitForChild("Crate_Overhead") :: BillboardGui

local Jecs = require(ReplicatedStorage.Packages.Jecs)
local Pair = Jecs.pair

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local World = require(ReplicatedStorage.Common.World)

local Crate_Query = World:query(
    Components.Name,
    Components.Health,
    Pair(Components.Relationships.Max, Components.Health),
    Components.Renderable
)
    :with(Components.Tags.Crate)
    :cached()

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = function()
        for Crate_Entity, Crate_Name: string, Crate_Health: number, Crate_Max_Health: number, Crate_Model: Model in
            Crate_Query:iter()
        do
            local Overhead_Attachment = Crate_Model:FindFirstChild("Overhead_Attachment", true)

            local Crate_OH = Overhead_Attachment:FindFirstChildOfClass("BillboardGui")

            if not Crate_OH then
                Crate_OH = Crate_Overhead:Clone()

                Crate_OH.Parent = Overhead_Attachment
            end

            local Title = Crate_OH:FindFirstChild("Title") :: TextLabel

            local Health = Crate_OH:FindFirstChild("Health") :: Frame
            local Health_Inside = Health:FindFirstChild("Inside") :: Frame
            local Health_Title = Health:FindFirstChild("Title") :: Frame

            Title.Text = Crate_Name

            Health_Inside.Size = UDim2.fromScale(math.clamp(Crate_Health / Crate_Max_Health, 0, 1), 1)
            Health_Title.Text = `{Crate_Health}/{Crate_Max_Health}`
        end
    end,
    runConditions = {},
}
