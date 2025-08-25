local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local VFX = Assets:WaitForChild("VFX")
local Sell_VFX = VFX:WaitForChild("Sell") :: Attachment
local Tutorial_Complete_VFX = VFX:WaitForChild("TutorialComplete") :: Attachment

local Highlights = Assets:WaitForChild("Highlights")
local Sell_Highlight = Highlights:WaitForChild("Sell") :: Highlight

local Sounds = Assets:WaitForChild("Sounds")

local World_Sounds = Sounds:WaitForChild("World")
local Cash_Collect_Sound = World_Sounds:WaitForChild("CashCollect") :: Sound

local Network = require(ServerScriptService.Network)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

local Fish = require(ReplicatedStorage.Common.Modules.Fish)
local Mutations = require(ReplicatedStorage.Common.Modules.Mutations)
local Util = require(ReplicatedStorage.Common.Modules.Util)

local function Handle_Sell_Single_Requests()
    for _, Player: Player in Network.Requests.SellSingle.Iter() do
        local Player_Entity = Registry.Get("Players", Player)

        if not Player_Entity then
            continue
        end

        local Character = World:get(Player_Entity, Components.Renderable) :: Model?

        if not Character then
            continue
        end

        local RootPart = Character:FindFirstChild("HumanoidRootPart")

        if not RootPart then
            continue
        end

        local Plot_Entity = World:target(Player_Entity, Components.Relationships.Plot)

        if not Plot_Entity then
            continue
        end

        local Plot_Model = World:get(Plot_Entity, Components.Renderable) :: Model
        local Plot_Spawn = Plot_Model:FindFirstChild("Spawn") :: Part

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
            Network.EndDialouge.Fire(Player, "Your not holding a fish")
            continue
        end

        local Tutorial_Step = World:get(Player_Entity, Components.Tutorial_Step)

        if Tutorial_Step == 9 then
            World:set(Player_Entity, Components.Tutorial_Step, 10)

            Character:PivotTo(Plot_Spawn.CFrame)

            local VFX = Tutorial_Complete_VFX:Clone()
            VFX.Parent = RootPart

            for _, Inst: ParticleEmitter in VFX:GetDescendants() do
                if Inst:IsA("ParticleEmitter") then
                    local EmitCount = Inst:GetAttribute("EmitCount") or 1

                    Inst:Emit(EmitCount)
                end
            end

            Debris:AddItem(VFX, 5)

            task.delay(4, function()
                if not World:contains(Player_Entity) then
                    return
                end

                World:set(Player_Entity, Components.Tutorial_Step, 11)
            end)
        elseif not (Tutorial_Step > 10) then
            Network.EndDialouge.Fire(Player, "Complete the tutorial first")
            continue
        end

        local Inventory = World:get(Player_Entity, Components.Inventory)
        local Cash = World:get(Player_Entity, Components.Cash)

        local Mutation_Table = Inventory[Held_Fish_Mutation]

        if not Mutation_Table then
            continue
        end

        local CurrentAmount = Mutation_Table[Held_Fish_Name]

        if not CurrentAmount then
            continue
        end

        -- Subtract 1
        local NewAmount = CurrentAmount - 1

        if NewAmount > 0 then
            Mutation_Table[Held_Fish_Name] = NewAmount
        else
            Mutation_Table[Held_Fish_Name] = nil
        end

        -- If mutation table is now empty, remove it entirely
        if next(Mutation_Table) == nil then
            Inventory[Held_Fish_Mutation] = nil
        end

        local Fish_Data = Fish[Held_Fish_Name]

        local Sell_Price = Fish_Data.Sell_Price

        if Held_Fish_Mutation ~= "Normal" then
            local Mutation_Data = Mutations[Held_Fish_Mutation :: any]

            Sell_Price *= Mutation_Data.Multiplier
        end

        World:set(Player_Entity, Components.Cash, Cash + Sell_Price)
        World:set(Player_Entity, Components.Inventory, Inventory)

        local Mutation_Text = Held_Fish_Mutation ~= "Normal" and `{Held_Fish_Mutation} ` or ""

        local Cash_Sound = Cash_Collect_Sound:Clone()
        Cash_Sound.PlayOnRemove = true
        Cash_Sound.Parent = RootPart
        Cash_Sound:Destroy()

        local Highlight = Sell_Highlight:Clone()
        Highlight.Parent = Character

        Debris:AddItem(Highlight, 0.15)

        local VFX = Sell_VFX:Clone()
        VFX.Parent = RootPart

        for _, Inst: ParticleEmitter in VFX:GetDescendants() do
            if Inst:IsA("ParticleEmitter") then
                local EmitCount = Inst:GetAttribute("EmitCount") or 1

                Inst:Emit(EmitCount)
            end
        end

        Debris:AddItem(VFX, 5)

        Network.EndDialouge.Fire(
            Player,
            `x1 {Mutation_Text}{Held_Fish_Name} sold for ${Util.Format_Number_With_Commas(Sell_Price)}`
        )
    end
end

local function Handle_Sell_All_Requests()
    for _, Player: Player in Network.Requests.SellAll.Iter() do
        local Player_Entity = Registry.Get("Players", Player)

        if not Player_Entity then
            continue
        end

        local Character = World:get(Player_Entity, Components.Renderable) :: Model?

        if not Character then
            continue
        end

        local RootPart = Character:FindFirstChild("HumanoidRootPart")

        if not RootPart then
            continue
        end

        local Plot_Entity = World:target(Player_Entity, Components.Relationships.Plot)

        if not Plot_Entity then
            continue
        end

        local Plot_Model = World:get(Plot_Entity, Components.Renderable) :: Model
        local Plot_Spawn = Plot_Model:FindFirstChild("Spawn") :: Part

        local Tutorial_Step = World:get(Player_Entity, Components.Tutorial_Step)

        if Tutorial_Step == 9 then
            World:set(Player_Entity, Components.Tutorial_Step, 10)

            Character:PivotTo(Plot_Spawn.CFrame)

            local VFX = Tutorial_Complete_VFX:Clone()
            VFX.Parent = RootPart

            for _, Inst: ParticleEmitter in VFX:GetDescendants() do
                if Inst:IsA("ParticleEmitter") then
                    local EmitCount = Inst:GetAttribute("EmitCount") or 1

                    Inst:Emit(EmitCount)
                end
            end

            Debris:AddItem(VFX, 5)

            task.delay(4, function()
                if not World:contains(Player_Entity) then
                    return
                end

                World:set(Player_Entity, Components.Tutorial_Step, 11)
            end)
        elseif not (Tutorial_Step > 10) then
            Network.EndDialouge.Fire(Player, "Complete the tutorial first")
            continue
        end
        local Cash = World:get(Player_Entity, Components.Cash)
        local Inventory = World:get(Player_Entity, Components.Inventory)

        local Cash_Earned = 0

        for Fish_Mutation, Fishes in Inventory do
            for Fish_Name, Fish_Amount in Fishes do
                local Fish_Data = Fish[Fish_Name]

                local Sell_Price = Fish_Data.Sell_Price

                if Fish_Mutation ~= "Normal" then
                    local Mutation_Data = Mutations[Fish_Mutation :: any]

                    Sell_Price *= Mutation_Data.Multiplier
                end

                Sell_Price *= Fish_Amount

                Cash_Earned += Sell_Price
            end
        end

        table.clear(Inventory)

        World:set(Player_Entity, Components.Inventory, Inventory)
        World:set(Player_Entity, Components.Cash, Cash + Cash_Earned)

        if Cash_Earned == 0 then
            Network.EndDialouge.Fire(Player, "Your inventory is empty")
            continue
        end

        local Cash_Sound = Cash_Collect_Sound:Clone()
        Cash_Sound.PlayOnRemove = true
        Cash_Sound.Parent = RootPart
        Cash_Sound:Destroy()

        local Highlight = Sell_Highlight:Clone()
        Highlight.Parent = Character

        Debris:AddItem(Highlight, 0.15)

        local VFX = Sell_VFX:Clone()
        VFX.Parent = RootPart

        for _, Inst: ParticleEmitter in VFX:GetDescendants() do
            if Inst:IsA("ParticleEmitter") then
                local EmitCount = Inst:GetAttribute("EmitCount") or 1

                Inst:Emit(EmitCount)
            end
        end

        Debris:AddItem(VFX, 5)

        Network.EndDialouge.Fire(Player, `Sold inventory for ${Util.Format_Number_With_Commas(Cash_Earned)}`)
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = function()
        Handle_Sell_Single_Requests()

        Handle_Sell_All_Requests()
    end,
    runConditions = {},
}
