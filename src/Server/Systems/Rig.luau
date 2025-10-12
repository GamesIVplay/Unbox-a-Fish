local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local UIGradients = Assets:WaitForChild("UIGradients")
local Sounds = Assets:WaitForChild("Sounds")

local Fish_Sounds = Sounds:WaitForChild("Fish")

local Billboards = Assets:WaitForChild("Billboards")
local Fish_Overhead = Billboards:WaitForChild("Fish_Overhead") :: BillboardGui

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local World = require(ReplicatedStorage.Common.World)

local Fish = require(ReplicatedStorage.Common.Modules.Fish)
local Mutations = require(ReplicatedStorage.Common.Modules.Mutations)
local Util = require(ReplicatedStorage.Common.Modules.Util)

local Characters = World:query(Components.Renderable):with(Components.Player):cached()

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = function()
        for Player_Entity, Character: Model in Characters:iter() do
            local Character_Root = Character:FindFirstChild("HumanoidRootPart")

            if not Character_Root then
                continue
            end

            local Character_Arm = Character:FindFirstChild("Right Arm")

            if not Character_Arm then
                continue
            end

            local Rigged_Fish = Character:FindFirstChild("Rigged_Fish") :: Model

            local Equipped_Slot = World:get(Player_Entity, Components.Equipped_Slot)
            local Inventory = World:get(Player_Entity, Components.Inventory)

            local Equipped_Item = Inventory[Equipped_Slot]

            local Held_Fish_Name: string?
            local Held_Fish_Mutation: string?

            if Equipped_Slot ~= 1 and Equipped_Item then
                Held_Fish_Name = Equipped_Item.Name
                Held_Fish_Mutation = Equipped_Item.Mutation or "Normal"
            end

            if not Held_Fish_Name then
                if Rigged_Fish then
                    Rigged_Fish:Destroy()
                end

                continue
            end

            if
                Rigged_Fish
                and Rigged_Fish:GetAttribute("Name") == Held_Fish_Name
                and Rigged_Fish:GetAttribute("Mutation") == Held_Fish_Mutation
            then
                continue
            end

            if Rigged_Fish then
                Rigged_Fish:Destroy()
            end

            local Fish_Model = Fish[Held_Fish_Name].Models[Held_Fish_Mutation]:Clone() :: Model

            local IncomePerSec = Fish[Held_Fish_Name].IncomePerSec

            if Held_Fish_Mutation ~= "Normal" then
                local Mutation_Data = Mutations[Held_Fish_Mutation :: any]

                IncomePerSec *= Mutation_Data.Multiplier
            end

            local Overhead_Attachment = Fish_Model:FindFirstChild("Overhead_Attachment", true) :: Attachment

            local Overhead = Fish_Overhead:Clone()
            Overhead.Parent = Overhead_Attachment

            local Mutation_Text_Label = Overhead:FindFirstChild("Mutation") :: TextLabel

            if Held_Fish_Mutation ~= "Normal" then
                Mutation_Text_Label.Text = Held_Fish_Mutation

                if not Mutation_Text_Label:FindFirstChildOfClass("UIGradient") then
                    local MutationGradient = UIGradients:FindFirstChild(Held_Fish_Mutation)

                    MutationGradient:Clone().Parent = Mutation_Text_Label
                end
            else
                Mutation_Text_Label.Visible = false
            end

            local Rarity_Text_Label = Overhead:FindFirstChild("Rarity") :: TextLabel
            Rarity_Text_Label.Text = Fish[Held_Fish_Name].Rarity

            if not Rarity_Text_Label:FindFirstChildOfClass("UIGradient") then
                local RarityGradient = UIGradients:FindFirstChild(Fish[Held_Fish_Name].Rarity)

                RarityGradient:Clone().Parent = Rarity_Text_Label
            end

            local Title_Text_Label = Overhead:FindFirstChild("Title") :: TextLabel

            Title_Text_Label.Text = `{Held_Fish_Name}`

            local Income_Per_Sec_Text_Label = Overhead:FindFirstChild("IncomePerSec") :: TextLabel

            Income_Per_Sec_Text_Label.Text = `${Util.Format_Number_With_Commas(IncomePerSec)}/s`

            for _, Inst in Fish_Model:GetDescendants() do
                if Inst:IsA("BasePart") then
                    Inst.Anchored = false
                    Inst.Massless = true
                end
            end

            local Fish_Root = Fish_Model.PrimaryPart

            Fish_Model:PivotTo(Character_Arm.CFrame * CFrame.new(0, -3, 3) * CFrame.Angles(math.rad(-90), 0, 0))

            Fish_Model.Parent = Character

            -- Weld the trap to the character root
            local Weld = Instance.new("WeldConstraint")
            Weld.Name = "Fish_Weld"
            Weld.Part0 = Character_Arm
            Weld.Part1 = Fish_Root
            Weld.Parent = Fish_Root

            Fish_Model.Name = "Rigged_Fish"
            Fish_Model:SetAttribute("Name", Held_Fish_Name)
            Fish_Model:SetAttribute("Mutation", Held_Fish_Mutation)

            task.delay(0.5, function()
                local Voice_Sound = Fish_Sounds:FindFirstChild(Held_Fish_Name)

                if not Voice_Sound or not Fish_Root then
                    return
                end

                Voice_Sound = Voice_Sound:Clone()
                Voice_Sound.PlayOnRemove = true
                Voice_Sound.Parent = Fish_Root
                Voice_Sound:Destroy()
            end)
        end
    end,
    runConditions = {},
}
