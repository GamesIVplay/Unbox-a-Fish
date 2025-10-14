local MarketPlaceService = game:GetService("MarketplaceService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Characters = workspace:WaitForChild("Characters")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local Highlights = Assets:WaitForChild("Highlights")
local Owned_Highlight = Highlights:WaitForChild("Owned") :: Highlight

local VFX = Assets:WaitForChild("VFX")
local Arrow_Beam = VFX:WaitForChild("ArrowBeam") :: Beam

local Map = workspace:WaitForChild("Map")

local Plots = Map:WaitForChild("Plots")

local Interactables = Map:WaitForChild("Interactables")
local Upgrade_Shop = Interactables:WaitForChild("Upgrade_Shop")
local Sell_Shop = Interactables:WaitForChild("Sell_Shop")
local Crate_Shop = Interactables:WaitForChild("Crate_Shop")

local SimpleZone = require(Assets.SimpleZone) :: any

local Billboards = Assets:WaitForChild("Billboards")
local YourPlot_Billboard = Billboards:WaitForChild("YourPlot") :: BillboardGui

local Jecs = require(ReplicatedStorage.Packages.Jecs)
local Pair = Jecs.pair

local Ratelimit = require(ReplicatedStorage.Packages.Ratelimit)
local Collect_Rate_Limit = Ratelimit(1, 1)

local Network = require(ReplicatedFirst.Network)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

local Types = require(ReplicatedStorage.Common.Types)

local AnimPlayer = require(ReplicatedStorage.Common.Modules.AnimPlayer)
local Confetti = require(ReplicatedStorage.Common.Modules.Confetti)
local ProductIds = require(ReplicatedStorage.Common.Modules.ProductIds)
local Util = require(ReplicatedStorage.Common.Modules.Util)

local BOUNCE_TIME = 0.08
local Bounce_Tween_Info = TweenInfo.new(BOUNCE_TIME, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

local Fusion_Values = require(ReplicatedFirst.Client.Modules.Fusion_Values)

local function Handle_Cash_Changes(LocalEntity: Types.Entity)
    for _, Value in Network.PlayerChanges.Cash.Iter() do
        World:set(LocalEntity, Components.Cash, Value)

        Fusion_Values.Cash:set(Value)
    end
end

local function Handle_Tool_Level_Changes(LocalEntity: Types.Entity)
    for _, Value in Network.PlayerChanges.ToolLevel.Iter() do
        World:set(LocalEntity, Components.Tool_Level, Value)

        Fusion_Values.Tool_Level:set(Value)
    end
end

local function Handle_Auto_Swing_Level_Changes(LocalEntity: Types.Entity)
    for _, Value in Network.PlayerChanges.AutoSwingLevel.Iter() do
        World:set(LocalEntity, Components.Auto_Swing_Level, Value)

        Fusion_Values.Auto_Swing_Level:set(Value)
    end
end

local function Handle_Luck_Level_Changes(LocalEntity: Types.Entity)
    for _, Value in Network.PlayerChanges.LuckLevel.Iter() do
        World:set(LocalEntity, Components.Luck_Level, Value)

        Fusion_Values.Luck_Level:set(Value)
    end
end

local function Handle_Index_Changes(LocalEntity: Types.Entity)
    for _, Value in Network.PlayerChanges.Index.Iter() do
        World:set(LocalEntity, Components.Index, Value)

        Fusion_Values.Index:set(Value)
    end
end

local function Handle_Tutorial_Step_Changes(LocalEntity: Types.Entity)
    for _, Value in Network.PlayerChanges.TutorialStep.Iter() do
        World:set(LocalEntity, Components.Tutorial_Step, Value)

        Fusion_Values.Tutorial_Step:set(Value)
    end
end

local function Handle_Friend_Boost_Changes(LocalEntity: Types.Entity)
    for _, Value in Network.PlayerChanges.FriendBoost.Iter() do
        World:set(LocalEntity, Components.FriendBoost, Value)

        Fusion_Values.Friend_Boost:set(Value)
    end
end

local function Handle_Plot_Assign(LocalEntity: Types.Entity)
    local LocalPlayer = World:get(LocalEntity, Components.Player) :: Player

    for _, Value in Network.PlayerChanges.PlotChosen.Iter() do
        for _, Inst in Interactables.Guranteed_Mutations:GetDescendants() do
            if Inst.Name == "Touch" then
                local Zone = SimpleZone.fromPart(Inst)

                Zone:BindToHeartbeat()

                Zone:ListenTo("Player", "Entered", function(TargetPlayer: Player)
                    if TargetPlayer ~= LocalPlayer then
                        return
                    end

                    MarketPlaceService:PromptProductPurchase(LocalPlayer, 3389821746)
                end)
            end
        end

        local Legendary_Offer = Interactables.Legendary_Offer
        local Legendary_Zone = SimpleZone.fromPart(Legendary_Offer.Touch)

        Legendary_Zone:BindToHeartbeat()

        Legendary_Zone:ListenTo("Player", "Entered", function(TargetPlayer: Player)
            if TargetPlayer ~= LocalPlayer then
                return
            end

            MarketPlaceService:PromptProductPurchase(LocalPlayer, ProductIds["Legendary Offer"])
        end)

        local Mythic_Offer = Interactables.Mythic_Offer
        local Mythic_Zone = SimpleZone.fromPart(Mythic_Offer.Touch)

        Mythic_Zone:BindToHeartbeat()

        Mythic_Zone:ListenTo("Player", "Entered", function(TargetPlayer: Player)
            if TargetPlayer ~= LocalPlayer then
                return
            end

            MarketPlaceService:PromptProductPurchase(LocalPlayer, ProductIds["Mythic Offer"])
        end)

        for _, Model: Model in Plots:GetChildren() do
            local Luck_Boost = Model:WaitForChild("Luck_Boost") :: Model
            local Mutation_Boost = Model:WaitForChild("Mutation_Boost")

            local Luck_Zone = SimpleZone.fromPart(Luck_Boost.Touch)

            Luck_Zone:BindToHeartbeat()

            Luck_Zone:ListenTo("Player", "Entered", function(TargetPlayer: Player)
                if TargetPlayer ~= LocalPlayer then
                    return
                end

                MarketPlaceService:PromptProductPurchase(LocalPlayer, ProductIds["x2 Luck 10 Min"])
            end)

            local Mutation_Zone = SimpleZone.fromPart(Mutation_Boost.Touch)

            Mutation_Zone:BindToHeartbeat()

            Mutation_Zone:ListenTo("Player", "Entered", function(TargetPlayer: Player)
                if TargetPlayer ~= LocalPlayer then
                    return
                end

                MarketPlaceService:PromptProductPurchase(LocalPlayer, ProductIds["x2 Mutation 10 Min"])
            end)
        end

        YourPlot_Billboard:Clone().Parent = Value

        local Stands = Value:FindFirstChild("Stands")

        for _, Stand_Model in Stands:GetChildren() do
            local Place_Attachment = Stand_Model:FindFirstChild("Place_Attachment", true)
            local Collect_Model = Stand_Model:FindFirstChild("Collect")
            local Touch_Part = Collect_Model:FindFirstChild("Touch") :: Part

            local Tween_Up = TweenService:Create(Touch_Part, Bounce_Tween_Info, {
                Position = Touch_Part.Position,
            })

            local Tween_Down = TweenService:Create(Touch_Part, Bounce_Tween_Info, {
                Position = Touch_Part.Position - Vector3.new(0, 0.35, 0),
            })

            local PlacePrompt = Instance.new("ProximityPrompt")
            PlacePrompt.ClickablePrompt = true
            PlacePrompt.Enabled = false
            PlacePrompt.Exclusivity = Enum.ProximityPromptExclusivity.OneGlobally
            PlacePrompt.GamepadKeyCode = Enum.KeyCode.ButtonX
            PlacePrompt.KeyboardKeyCode = Enum.KeyCode.E
            PlacePrompt.MaxActivationDistance = 10
            PlacePrompt.RequiresLineOfSight = false
            PlacePrompt.HoldDuration = 0.5
            PlacePrompt.ActionText = "Place"
            PlacePrompt.ObjectText = ""
            PlacePrompt.Style = Enum.ProximityPromptStyle.Custom
            PlacePrompt.Parent = Place_Attachment

            local function Update_Prompt()
                if Stand_Model:GetAttribute("ServerEntity") then
                    PlacePrompt.Enabled = false
                else
                    PlacePrompt.Enabled = true
                end
            end

            Stand_Model:GetAttributeChangedSignal("ServerEntity"):Connect(Update_Prompt)

            Update_Prompt()

            PlacePrompt.Triggered:Connect(function()
                Network.Requests.Place.Fire(Stand_Model)
            end)

            local Collect_Zone = SimpleZone.fromPart(Touch_Part)

            Collect_Zone:BindToHeartbeat()

            Collect_Zone:ListenTo("Player", "Entered", function(TargetPlayer: Player)
                if TargetPlayer ~= LocalPlayer then
                    return
                end

                if not Collect_Rate_Limit(Stand_Model) then
                    return
                end

                local ServerEntity = Stand_Model:GetAttribute("ServerEntity")

                if ServerEntity then
                    Network.Requests.Collect.Fire(ServerEntity)
                end

                Tween_Down:Play()

                task.wait(0.8)

                Tween_Up:Play()
            end)
        end

        local Skip = Value:FindFirstChild("Skip") :: Model
        local Skip_Screen = Skip:FindFirstChild("Screen") :: Part

        local SkipPrompt = Instance.new("ProximityPrompt")
        SkipPrompt.ClickablePrompt = true
        SkipPrompt.Enabled = true
        SkipPrompt.Exclusivity = Enum.ProximityPromptExclusivity.OneGlobally
        SkipPrompt.GamepadKeyCode = Enum.KeyCode.ButtonX
        SkipPrompt.KeyboardKeyCode = Enum.KeyCode.E
        SkipPrompt.MaxActivationDistance = 10
        SkipPrompt.RequiresLineOfSight = false
        SkipPrompt.HoldDuration = 0.5
        SkipPrompt.ActionText = "Skip ⏩"
        SkipPrompt.ObjectText = ""
        SkipPrompt.Style = Enum.ProximityPromptStyle.Custom
        SkipPrompt.Parent = Skip_Screen

        SkipPrompt.Triggered:Connect(function()
            Network.Requests.SkipCrate.Fire()
        end)

        local Instant_Break = Value:FindFirstChild("Instant_Break") :: Model
        local Instant_Break_Screen = Instant_Break:WaitForChild("Screen") :: Part

        local Instant_Break_Prompt = Instance.new("ProximityPrompt")
        Instant_Break_Prompt.ClickablePrompt = true
        Instant_Break_Prompt.Enabled = true
        Instant_Break_Prompt.Exclusivity = Enum.ProximityPromptExclusivity.OneGlobally
        Instant_Break_Prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
        Instant_Break_Prompt.KeyboardKeyCode = Enum.KeyCode.E
        Instant_Break_Prompt.MaxActivationDistance = 10
        Instant_Break_Prompt.RequiresLineOfSight = false
        Instant_Break_Prompt.HoldDuration = 0.5
        Instant_Break_Prompt.ActionText = "Break 🔨"
        Instant_Break_Prompt.ObjectText = ""
        Instant_Break_Prompt.Style = Enum.ProximityPromptStyle.Custom
        Instant_Break_Prompt.Parent = Instant_Break_Screen

        Instant_Break_Prompt.Triggered:Connect(function()
            MarketPlaceService:PromptProductPurchase(LocalPlayer, ProductIds["Break Crate"])
        end)

        local PlotEntity = World:entity()

        World:set(PlotEntity, Components.Renderable, Value)

        World:add(PlotEntity, Components.Tags.Plot)
        World:add(PlotEntity, Pair(Components.Relationships.Owner, LocalEntity))

        World:add(LocalEntity, Pair(Components.Relationships.Plot, PlotEntity))
    end
end

local function Handle_Restock_Time(LocalEntity: Types.Entity)
    for _, Value in Network.PlayerChanges.RestockTime.Iter() do
        World:set(LocalEntity, Components.Restock_Time, Value)

        Fusion_Values.Restock_Time:set(Value)
    end
end

local function Handle_Stock_Changes(LocalEntity: Types.Entity)
    for _, Value in Network.PlayerChanges.Stock.Iter() do
        World:set(LocalEntity, Components.Stock, Value)

        Fusion_Values.Stock:set(Value)
    end
end

local function Handle_Crate_Bounces()
    for _, Value in Network.BounceCrate.Iter() do
        if not Value:IsDescendantOf(workspace) then
            continue
        end

        task.spawn(function()
            Util.Tween_Model_Scale(1, 0.8, Bounce_Tween_Info, Value)

            task.wait(BOUNCE_TIME)

            Util.Tween_Model_Scale(0.8, 1, Bounce_Tween_Info, Value)
        end)
    end
end

local function Handle_New_Fish()
    for _, Value in Network.NewFish.Iter() do
        if not Value:IsDescendantOf(workspace) then
            continue
        end

        local Animator = Value:FindFirstChild("Animator", true) :: Animator
        AnimPlayer.Load(Animator)
        AnimPlayer.PlayAnimation(Animator, {
            Name = "Fish [Idle]",
            Loop = true,
        })

        task.spawn(function()
            Util.Tween_Model_Scale(1, 0.8, Bounce_Tween_Info, Value)

            task.wait(BOUNCE_TIME)

            Util.Tween_Model_Scale(0.8, 1, Bounce_Tween_Info, Value)
        end)
    end
end

local function Handle_Owned_Highlight()
    for _, Value in Network.AddOwnedHighlight.Iter() do
        Owned_Highlight:Clone().Parent = Value
    end
end

local function Handle_Add_Pickup_Prompts()
    for _, Value in Network.AddPickupPrompt.Iter() do
        local Torso = Value:FindFirstChild("Torso")

        local PickupPrompt = Instance.new("ProximityPrompt")
        PickupPrompt.ClickablePrompt = true
        PickupPrompt.Enabled = true
        PickupPrompt.Exclusivity = Enum.ProximityPromptExclusivity.OneGlobally
        PickupPrompt.GamepadKeyCode = Enum.KeyCode.ButtonX
        PickupPrompt.KeyboardKeyCode = Enum.KeyCode.E
        PickupPrompt.MaxActivationDistance = 5
        PickupPrompt.RequiresLineOfSight = false
        PickupPrompt.HoldDuration = 0.5
        PickupPrompt.ActionText = "Pickup"
        PickupPrompt.ObjectText = ""
        PickupPrompt.Style = Enum.ProximityPromptStyle.Custom
        PickupPrompt.Parent = Torso

        PickupPrompt.Triggered:Connect(function()
            local ServerEntity = Value:GetAttribute("ServerEntity")

            if not ServerEntity then
                return
            end

            Network.Requests.Pickup.Fire(ServerEntity)
        end)
    end
end

local function Handle_Tutorial_Attachment(LocalEntity: Types.Entity)
    local Character = World:get(LocalEntity, Components.Renderable)

    if not Character then
        return
    end

    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    if not RootPart then
        return
    end

    local Tutorial_Step = World:get(LocalEntity, Components.Tutorial_Step) :: number
    local Character_Tutorial_Attachment = RootPart:FindFirstChild("Character_Tutorial_Attachment")

    if not Character_Tutorial_Attachment and Tutorial_Step < 10 then
        Character_Tutorial_Attachment = Instance.new("Attachment")
        Character_Tutorial_Attachment.Name = "Character_Tutorial_Attachment"
        Character_Tutorial_Attachment.Parent = RootPart
    elseif Character_Tutorial_Attachment and Tutorial_Step >= 10 then
        Character_Tutorial_Attachment:Destroy()
        return
    end

    local Character_Tutorial_Beam = RootPart:FindFirstChild("Character_Tutorial_Beam")

    if not Character_Tutorial_Beam and Tutorial_Step < 10 then
        Character_Tutorial_Beam = Arrow_Beam:Clone()
        Character_Tutorial_Beam.Attachment0 = Character_Tutorial_Attachment
        Character_Tutorial_Beam.Name = "Character_Tutorial_Beam"
        Character_Tutorial_Beam.Parent = RootPart
    elseif Character_Tutorial_Beam and Tutorial_Step >= 10 then
        Character_Tutorial_Beam:Destroy()
        return
    end

    if Tutorial_Step >= 10 then
        return
    end

    local Plot_Entity = World:target(LocalEntity, Components.Relationships.Plot)

    if not Plot_Entity then
        return
    end

    local Plot_Model = World:get(Plot_Entity, Components.Renderable)
    local Stands = Plot_Model:FindFirstChild("Stands")

    if Tutorial_Step < 2 then
        local Plot_Tutorial_Attachment = Plot_Model:FindFirstChild("Tutorial_Attachment", true)

        Character_Tutorial_Beam.Attachment1 = Plot_Tutorial_Attachment
    elseif Tutorial_Step == 2 then
        for Stand_Number = 1, 12 do
            local Stand = Stands:FindFirstChild(Stand_Number) :: Model

            if not Stand:HasTag("Occupied") then
                continue
            end

            local Touch = Stand:FindFirstChild("Touch", true) :: Part

            local Collect_Attachment = Touch:FindFirstChildOfClass("Attachment")

            if not Collect_Attachment then
                Collect_Attachment = Instance.new("Attachment")
                Collect_Attachment.Parent = Touch
            end

            Character_Tutorial_Beam.Attachment1 = Collect_Attachment
            break
        end
    elseif Tutorial_Step == 3 then
        local Upgrade_Shop_Tutorial_Attachment = Upgrade_Shop:FindFirstChild("Tutorial_Attachment", true)

        Character_Tutorial_Beam.Attachment1 = Upgrade_Shop_Tutorial_Attachment
    elseif Tutorial_Step == 4 then
        local Crate_Shop_Tutorial_Attachment = Crate_Shop:FindFirstChild("Tutorial_Attachment", true)

        Character_Tutorial_Beam.Attachment1 = Crate_Shop_Tutorial_Attachment
    elseif Tutorial_Step == 5 then
        local Skip = Plot_Model:FindFirstChild("Skip")
        local Skip_Screen = Skip:FindFirstChild("Screen") :: Part

        local Skip_Attachment = Skip_Screen:FindFirstChildOfClass("Attachment")

        if not Skip_Attachment then
            Skip_Attachment = Instance.new("Attachment")
            Skip_Attachment.Parent = Skip_Screen
        end

        Character_Tutorial_Beam.Attachment1 = Skip_Attachment
    elseif Tutorial_Step == 6 then
        local Plot_Tutorial_Attachment = Plot_Model:FindFirstChild("Tutorial_Attachment", true)

        Character_Tutorial_Beam.Attachment1 = Plot_Tutorial_Attachment
    elseif Tutorial_Step == 8 then
        if Character_Tutorial_Beam.Attachment1 and Character_Tutorial_Beam.Attachment1:IsDescendantOf(Stands) then
            return
        end

        for Stand_Number = 1, 12 do
            local Stand = Stands:FindFirstChild(Stand_Number) :: Model

            if not Stand:HasTag("Occupied") then
                continue
            end

            local Floor = Stand:FindFirstChild("Floor", true) :: Part

            local Floor_Attachment = Floor:FindFirstChildOfClass("Attachment")

            if not Floor_Attachment then
                Floor_Attachment = Instance.new("Attachment")
                Floor_Attachment.Parent = Floor
            end

            Character_Tutorial_Beam.Attachment1 = Floor_Attachment
            break
        end
    elseif Tutorial_Step == 9 then
        local Sell_Shop_Tutorial_Attachment = Sell_Shop:FindFirstChild("Tutorial_Attachment", true)

        Character_Tutorial_Beam.Attachment1 = Sell_Shop_Tutorial_Attachment
    end
end

local function Handle_Confetti(LocalEntity: Types.Entity)
    local LocalPlayer = World:get(LocalEntity, Components.Player) :: Player

    for _, _ in Network.Confetti.Iter() do
        local HUD = LocalPlayer.PlayerGui:FindFirstChild("HUD") :: ScreenGui

        Confetti({ GUI = HUD, Count = 200 } :: any)
    end
end

local function Handle_One_Time_Offer_Bought(LocalEntity: Types.Entity)
    for _, Value in Network.PlayerChanges.BoughtOneTimeOffer.Iter() do
        Fusion_Values.Bought_One_Time_Offer:set(Value)

        if Value == true then
            World:add(LocalEntity, Components.Tags.BoughtOneTimeOffer)
        else
            World:remove(LocalEntity, Components.Tags.BoughtOneTimeOffer)
        end
    end
end

local function Handle_Tool_Rigged_Animation(LocalEntity: Types.Entity)
    local Character = World:get(LocalEntity, Components.Renderable) :: Model

    if not Character then
        return
    end

    local Animator = Character:FindFirstChild("Animator", true)

    if not Animator then
        return
    end

    if not Character:FindFirstChild("Rigged_Fish") then
        AnimPlayer.StopAnimation(Animator, {
            Name = "Carry",
        })
        return
    end

    AnimPlayer.PlayAnimation(Animator, {
        Name = "Carry",
        Loop = true,
        Priority = Enum.AnimationPriority.Action,
    })
end

local function Add_Gift_Prompts(LocalEntity: Types.Entity)
    local LocalCharacter = World:get(LocalEntity, Components.Renderable)

    if not LocalCharacter then
        return
    end

    local FoundItem = false

    local Equipped_Slot = World:get(LocalEntity, Components.Equipped_Slot)
    local Inventory = World:get(LocalEntity, Components.Inventory)

    local Equipped_Item = Inventory[Equipped_Slot]

    if Equipped_Slot ~= 1 and Equipped_Item then
        FoundItem = true
    end

    for _, Character: Model in Characters:GetChildren() do
        if Character == LocalCharacter then
            continue
        end

        local RootPart = Character:FindFirstChild("HumanoidRootPart")

        if not RootPart then
            continue
        end

        local Prompt = RootPart:FindFirstChildOfClass("ProximityPrompt")

        if not Prompt then
            Prompt = Instance.new("ProximityPrompt")
            Prompt.ClickablePrompt = true
            Prompt.Enabled = true
            Prompt.Exclusivity = Enum.ProximityPromptExclusivity.OneGlobally
            Prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
            Prompt.KeyboardKeyCode = Enum.KeyCode.E
            Prompt.MaxActivationDistance = 5
            Prompt.RequiresLineOfSight = false
            Prompt.HoldDuration = 0.5
            Prompt.ActionText = "Gift"
            Prompt.ObjectText = ""
            Prompt.Style = Enum.ProximityPromptStyle.Custom
            Prompt.Parent = RootPart

            Prompt.Triggered:Connect(function()
                local ServerEntity = Character:GetAttribute("ServerEntity")

                if not ServerEntity then
                    return
                end

                Network.Requests.Gift.Fire(ServerEntity)
            end)
        end

        Prompt.Enabled = FoundItem
    end
end

local function Handle_Inventory(LocalEntity: Types.Entity)
    for _, Data in Network.PlayerChanges.Inventory.Iter() do
        local Converted = {}

        for index, value in Data do
            Converted[tonumber(index)] = value
        end

        World:set(LocalEntity, Components.Inventory, Converted)

        Fusion_Values.Inventory:set(Converted)
    end
end

local function Handle_Equipped_Slot(LocalEntity: Types.Entity)
    for _, Data in Network.PlayerChanges.EquippedSlot.Iter() do
        World:set(LocalEntity, Components.Equipped_Slot, Data)

        Fusion_Values.Equipped_Slot:set(Data)
    end
end

local function Handle_Rebirth_Changes(LocalEntity: Types.Entity)
    for _, Data in Network.PlayerChanges.Rebirth.Iter() do
        World:set(LocalEntity, Components.Rebirth, Data)

        Fusion_Values.Rebirth:set(Data)
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.First,
    system = function()
        local LocalEntity = Registry.Get("Players", "Local")

        Handle_Cash_Changes(LocalEntity)

        Handle_Tool_Level_Changes(LocalEntity)

        Handle_Luck_Level_Changes(LocalEntity)

        Handle_Auto_Swing_Level_Changes(LocalEntity)

        Handle_Index_Changes(LocalEntity)

        Handle_Tutorial_Step_Changes(LocalEntity)

        Handle_Friend_Boost_Changes(LocalEntity)

        Handle_Plot_Assign(LocalEntity)

        Handle_Restock_Time(LocalEntity)

        Handle_Stock_Changes(LocalEntity)

        Handle_Crate_Bounces()

        Handle_New_Fish()

        Handle_Owned_Highlight()

        Handle_Add_Pickup_Prompts()

        Handle_Tutorial_Attachment(LocalEntity)

        Handle_Confetti(LocalEntity)

        Handle_One_Time_Offer_Bought(LocalEntity)

        Handle_Tool_Rigged_Animation(LocalEntity)

        Add_Gift_Prompts(LocalEntity)

        Handle_Inventory(LocalEntity)

        Handle_Equipped_Slot(LocalEntity)

        Handle_Rebirth_Changes(LocalEntity)
    end,
    runConditions = {},
}
