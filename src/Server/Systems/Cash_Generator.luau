local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local UIGradients = Assets:WaitForChild("UIGradients")

local Billboards = Assets:WaitForChild("Billboards")
local Fish_Overhead = Billboards:WaitForChild("Fish_Overhead") :: BillboardGui

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local World = require(ReplicatedStorage.Common.World)

local Jecs = require(ReplicatedStorage.Packages.Jecs)
local Pair = Jecs.pair

local Abbreviate_Number = require(ReplicatedStorage.Common.Modules.Abbreviate_Number)
local Fish = require(ReplicatedStorage.Common.Modules.Fish)
local Mutations = require(ReplicatedStorage.Common.Modules.Mutations)
local Util = require(ReplicatedStorage.Common.Modules.Util)

local Ratelimit = require(ReplicatedStorage.Packages.Ratelimit)
local Can_Generate = Ratelimit(1, 1)

local Fish_Query = World:query(
    Components.Name,
    Components.Renderable,
    Components.Cash,
    Pair(Components.Relationships.Offline, Components.Cash)
)
    :with(Components.Tags.Fish, Pair(Components.Relationships.Owner, Jecs.Wildcard))
    :cached()

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = function()
        for Fish_Entity, Fish_Name: string, Fish_Model: Model, Cash: number, Offline_Cash: number in Fish_Query:iter() do
            local Owner_Entity = World:target(Fish_Entity, Components.Relationships.Owner)

            local FriendBoost = World:get(Owner_Entity, Components.FriendBoost)

            local Mutation = World:get(Fish_Entity, Components.Mutation)

            local Overhead_Attachment = Fish_Model:FindFirstChild("Overhead_Attachment", true) :: Attachment

            local Fish_Data = Fish[Fish_Name]
            local IncomePerSec = Fish_Data.IncomePerSec

            if Mutation then
                local Mutation_Data = Mutations[Mutation]

                IncomePerSec *= Mutation_Data.Multiplier
            end

            IncomePerSec *= FriendBoost

            if World:has(Owner_Entity, Components.Tags.DoubleMoney) then
                IncomePerSec *= 2
            end

            IncomePerSec = math.round(IncomePerSec)

            local NewCash = Cash

            if Can_Generate(Fish_Entity) then
                NewCash += math.round(IncomePerSec)
            end

            local Overhead = Overhead_Attachment:FindFirstChild("Fish_Overhead")

            if not Overhead then
                Overhead = Fish_Overhead:Clone()

                Overhead.Parent = Overhead_Attachment
            end

            local Mutation_Text_Label = Overhead:FindFirstChild("Mutation") :: TextLabel

            if Mutation then
                Mutation_Text_Label.Text = Mutation

                if not Mutation_Text_Label:FindFirstChildOfClass("UIGradient") then
                    local MutationGradient = UIGradients:FindFirstChild(Mutation)

                    MutationGradient:Clone().Parent = Mutation_Text_Label
                end
            else
                Mutation_Text_Label.Visible = false
            end

            local Cash_Text_Label = Overhead:FindFirstChild("Cash") :: TextLabel
            Cash_Text_Label = Cash_Text_Label:FindFirstChildOfClass("TextLabel")
            Cash_Text_Label.Text = `${Util.Format_Number_With_Commas(NewCash)}`

            local Rarity_Text_Label = Overhead:FindFirstChild("Rarity") :: TextLabel
            Rarity_Text_Label.Text = Fish_Data.Rarity

            if not Rarity_Text_Label:FindFirstChildOfClass("UIGradient") then
                local RarityGradient = UIGradients:FindFirstChild(Fish_Data.Rarity)

                RarityGradient:Clone().Parent = Rarity_Text_Label
            end

            local Offline_Cash_Text_Label = Overhead:FindFirstChild("OfflineCash") :: TextLabel
            Offline_Cash_Text_Label.Text = `(Offline cash: ${Util.Format_Number_With_Commas(Offline_Cash)})`

            if Offline_Cash > 0 then
                Offline_Cash_Text_Label.Visible = true
            else
                Offline_Cash_Text_Label.Visible = false
            end

            local Title_Text_Label = Overhead:FindFirstChild("Title") :: TextLabel

            Title_Text_Label.Text = `{Fish_Name} (${Util.Format_Number_With_Commas(IncomePerSec)}/s)`

            World:set(Fish_Entity, Components.Cash, NewCash)
        end
    end,
    runConditions = {},
}
