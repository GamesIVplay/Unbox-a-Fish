local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local Fish_Sounds = Sounds:WaitForChild("Fish")

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

local Fish = require(ReplicatedStorage.Common.Modules.Fish)
local Mutations = require(ReplicatedStorage.Common.Modules.Mutations)

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

            local Held_Fish_Name: string?
            local Held_Fish_Mutation: string?

            for _, Tool in Character:GetChildren() do
                if Tool:IsA("Tool") and Tool:HasTag("Item") then
                    local Name = Tool.Name

                    -- Extract count if formatted like "Name [x3]"
                    local BaseName = Name:match("^(.*)%s%[x(%d+)%]$")
                    if BaseName then
                        Name = BaseName
                    end

                    -- Extract mutation + item name
                    local FirstWord, Rest = Name:match("^(%S+)%s+(.*)$")

                    if FirstWord and Mutations[FirstWord] then
                        Held_Fish_Mutation = FirstWord
                        Held_Fish_Name = Rest
                    else
                        Held_Fish_Name = Name
                        Held_Fish_Mutation = "Normal"
                    end

                    break
                end
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
