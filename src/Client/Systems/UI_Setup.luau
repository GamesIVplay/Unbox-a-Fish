local Lighting = game:GetService("Lighting")
local MarketPlaceService = game:GetService("MarketplaceService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Debris_Folder = workspace:WaitForChild("Debris")

local ActivateHaptic = Instance.new("HapticEffect")
ActivateHaptic.Position = Vector3.new(0, 0, 0)
ActivateHaptic.Radius = 1
ActivateHaptic.Type = Enum.HapticEffectType.UIHover
ActivateHaptic.Parent = workspace

local Network = require(ReplicatedFirst.Network)

local Map = workspace:WaitForChild("Map")

local Plots = Map:WaitForChild("Plots")

local Interactables = Map:WaitForChild("Interactables")

local Upgrade_Shop = Interactables:WaitForChild("Upgrade_Shop") :: Model
local Upgrade_Shop_Npc = Upgrade_Shop:WaitForChild("Npc") :: Model
local Upgrade_Shop_Teleport = Upgrade_Shop:WaitForChild("Teleport") :: Part

local Sell_Shop = Interactables:WaitForChild("Sell_Shop") :: Model
local Sell_Shop_Teleport = Sell_Shop:WaitForChild("Teleport") :: Part

local Crate_Shop = Interactables:WaitForChild("Crate_Shop") :: Model
local Crate_Shop_Npc = Crate_Shop:WaitForChild("Npc") :: Model

local Assets = ReplicatedStorage:WaitForChild("Assets")

local UIGradients = Assets:WaitForChild("UIGradients")

local Sounds = Assets:WaitForChild("Sounds")

local UISounds = Sounds:WaitForChild("UI")
local CashChange = UISounds:WaitForChild("CashChange") :: Sound
local Activate = UISounds:WaitForChild("Activate") :: Sound
local Hover = UISounds:WaitForChild("Hover") :: Sound
local TypeWriter = UISounds:WaitForChild("TypeWriter") :: Sound
local TutorialComplete = UISounds:WaitForChild("TutorialComplete") :: Sound

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local Peek = Fusion.peek

local Fusion_Values = require(ReplicatedFirst.Client.Modules.Fusion_Values)

local Types = require(ReplicatedStorage.Common.Types)

local Confetti = require(ReplicatedStorage.Common.Modules.Confetti)

local Auto_Swing_Upgrades = require(ReplicatedStorage.Common.Modules.AutoSwing_Upgrades)
local Crates = require(ReplicatedStorage.Common.Modules.Crates)
local Hammers = require(ReplicatedStorage.Common.Modules.Hammers)
local Luck_Prices = require(ReplicatedStorage.Common.Modules.Luck_Prices)
local Rebirths = require(ReplicatedStorage.Common.Modules.Rebirths)

local Log = require(ReplicatedStorage.Common.Log)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

local Abbreviate_Number = require(ReplicatedStorage.Common.Modules.Abbreviate_Number)
local AnimPlayer = require(ReplicatedStorage.Common.Modules.AnimPlayer)
local Fish = require(ReplicatedStorage.Common.Modules.Fish)
local GamepassIds = require(ReplicatedStorage.Common.Modules.GamepassIds)
local Mutations = require(ReplicatedStorage.Common.Modules.Mutations)
local ProductIds = require(ReplicatedStorage.Common.Modules.ProductIds)
local Ratelimit = require(ReplicatedStorage.Packages.Ratelimit)
local StatCalculator = require(ReplicatedStorage.Common.Modules.StatCalculator)
local Util = require(ReplicatedStorage.Common.Modules.Util)

local Clock = require(ReplicatedStorage.Packages.Clock)

local DEFAULT_SIZE_MULTIPLIER = 1
local HOVER_SIZE_MULTIPLIER = 1.05
local ACTIVATE_VELOCITY = 2

local Scope = Fusion.scoped(Fusion)

local Camera = workspace.CurrentCamera

local function Get_Product_Price(Id: number): number?
    local Attempts = 0

    local Success, Info
    repeat
        Success, Info = pcall(function()
            return MarketPlaceService:GetProductInfo(Id, Enum.InfoType.Product)
        end)

        if Success and Info then
            return Info.PriceInRobux
        else
            Attempts = Attempts + 1

            warn("Attempt " .. Attempts .. " failed to retrieve product info")
            task.wait(1)
        end
    until Success or Attempts >= 3

    if not Success or not Info then
        Log.Warn("Failed to retrieve product info after 3 attempts")
    end

    return
end

local function Get_Gamepass_Price(Id: number): number?
    local Attempts = 0

    local Success, Info
    repeat
        Success, Info = pcall(function()
            return MarketPlaceService:GetProductInfo(Id, Enum.InfoType.GamePass)
        end)

        if Success and Info then
            return Info.PriceInRobux
        else
            Attempts = Attempts + 1

            warn("Attempt " .. Attempts .. " failed to retrieve product info")
            task.wait(1)
        end
    until Success or Attempts >= 3

    if not Success or not Info then
        Log.Warn("Failed to retrieve product info after 3 attempts")
    end

    return
end

local CameraFovTween: Tween?
local BlurEffect: BlurEffect?

local function TweenFov(Time: number, Value: number)
    if CameraFovTween then
        CameraFovTween:Destroy()
    end

    CameraFovTween = TweenService:Create(
        Camera,
        TweenInfo.new(Time, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
        { FieldOfView = Value }
    ):Play()
end

local function Remove_Blur()
    if BlurEffect then
        BlurEffect:Destroy()
        BlurEffect = nil
    end
end

local function Add_Blur(Size: number)
    Remove_Blur()

    local BlurEffectInstance = Instance.new("BlurEffect")
    BlurEffectInstance.Size = Size
    BlurEffectInstance.Parent = Lighting

    BlurEffect = BlurEffectInstance
end

local function Hydrate_Button(GuiButton: GuiButton, OnActivate: () -> (), HMultiplier: number?, AVelocity: number?)
    local SizeMultiplier = Scope:Value(DEFAULT_SIZE_MULTIPLIER)
    local Hovering = Scope:Value(false)
    local SizeMultiplierSpring = Scope:Spring(SizeMultiplier, 17, 0.5)

    Scope:Observer(Hovering):onBind(function()
        if Peek(Hovering) then
            SizeMultiplier:set(HMultiplier or HOVER_SIZE_MULTIPLIER)
        else
            SizeMultiplier:set(DEFAULT_SIZE_MULTIPLIER)
        end
    end)

    Scope:Hydrate(GuiButton)({
        [OnEvent("MouseEnter")] = function()
            Hover:Play()
            Hovering:set(true)
        end,
        [OnEvent("MouseLeave")] = function()
            Hovering:set(false)
        end,
        [OnEvent("Activated")] = function()
            Activate:Play()
            ActivateHaptic:Play()
            SizeMultiplierSpring:addVelocity(AVelocity or ACTIVATE_VELOCITY)

            OnActivate()
        end,
        [Children] = {
            Scope:New("UIScale")({
                Scale = SizeMultiplierSpring,
            }),
        },
    })
end

local function Setup_Hotbar(LocalEntity: Types.Entity, PlayerGui: PlayerGui)
    local HUD = PlayerGui:WaitForChild("HUD") :: ScreenGui

    local Hotbar = HUD:WaitForChild("Hotbar")
    local Template = Hotbar:WaitForChild("Template")

    for i = 1, 8 do
        local Slot = Template:Clone()
        local Title = Slot:WaitForChild("Title") :: TextLabel
        local UIStroke = Slot:WaitForChild("UIStroke")

        local Number = Slot:WaitForChild("Number") :: TextLabel
        local Number_UIStroke = Number:WaitForChild("UIStroke") :: UIStroke

        Number.Text = i

        Scope:Hydrate(Number_UIStroke)({
            Transparency = Scope:Computed(function(Use)
                if Use(Fusion_Values.Equipped_Slot) == i then
                    return 0.1
                else
                    return 0.6
                end
            end),
        })

        local Item = Scope:Computed(function(Use)
            return Use(Fusion_Values.Inventory)[i]
        end)

        Scope:Observer(Item):onBind(function()
            local Data = Peek(Item)

            local Rarity = Data and Fish[Data.Name] and Fish[Data.Name].Rarity
            if i == 1 then
                Rarity = "Hammer"
            end

            local Old_Gradient = Slot:FindFirstChildOfClass("UIGradient")

            if Old_Gradient then
                Old_Gradient:Destroy()
            end

            if not Rarity then
                return
            end

            UIGradients:FindFirstChild(Rarity):Clone().Parent = Slot
        end)

        Scope:Observer(Item):onBind(function()
            local Data = Peek(Item)

            local Old_Gradient = Title:FindFirstChildOfClass("UIGradient")

            if Old_Gradient then
                Old_Gradient:Destroy()
            end

            if not Data then
                return
            end

            if Data.Mutation then
                UIGradients:FindFirstChild(Data.Mutation):Clone().Parent = Title
            end
        end)

        Scope:Hydrate(Title)({
            Text = Scope:Computed(function(Use)
                local Item = Use(Item)

                if not Item then
                    return ""
                end

                local Item_Name = Item.Name
                local Item_Mutation = Item.Mutation
                local Item_Amount = Item.Amount

                local Mutation_Text = Item_Mutation and Item_Mutation .. " " or ""
                local Amount_Text = Item_Amount > 1 and ` [x{Item_Amount}]` or ""

                return Item and `{Mutation_Text}{Item_Name}{Amount_Text}` or ""
            end),
        })

        Scope:Hydrate(UIStroke)({
            Transparency = Scope:Computed(function(Use)
                if Use(Fusion_Values.Equipped_Slot) == i then
                    return 0.1
                else
                    return 0.6
                end
            end),
        })

        Scope:Hydrate(Slot)({
            BackgroundTransparency = Scope:Computed(function(Use)
                if Use(Fusion_Values.Equipped_Slot) == i then
                    return 0.1
                else
                    return 0.15
                end
            end),
        })

        local SizeMultiplier = Scope:Value(DEFAULT_SIZE_MULTIPLIER)
        local Hovering = Scope:Value(false)
        local SizeMultiplierSpring = Scope:Spring(SizeMultiplier, 17, 0.5)

        Scope:Observer(Hovering):onBind(function()
            if Peek(Hovering) then
                SizeMultiplier:set(HOVER_SIZE_MULTIPLIER)
            else
                SizeMultiplier:set(DEFAULT_SIZE_MULTIPLIER)
            end
        end)

        local function OnActivate()
            Activate:Play()
            ActivateHaptic:Play()
            SizeMultiplierSpring:addVelocity(ACTIVATE_VELOCITY)

            Network.Requests.EquipSlot.Fire(i)
        end

        Scope:Hydrate(Slot)({
            [OnEvent("MouseEnter")] = function()
                Hover:Play()
                Hovering:set(true)
            end,
            [OnEvent("MouseLeave")] = function()
                Hovering:set(false)
            end,
            [OnEvent("Activated")] = OnActivate,
            [Children] = {
                Scope:New("UIScale")({
                    Scale = SizeMultiplierSpring,
                }),
            },
        })

        --[[UserInputService.InputBegan:Connect(function(Input, Processed)
            if Processed then
                return
            end

            local KeyCodes = {
                Enum.KeyCode.One,
                Enum.KeyCode.Two,
                Enum.KeyCode.Three,
                Enum.KeyCode.Four,
                Enum.KeyCode.Five,
                Enum.KeyCode.Six,
                Enum.KeyCode.Seven,
                Enum.KeyCode.Eight,
            }

            if Input.KeyCode == KeyCodes[i] then
                OnActivate()
            end
        end)]]

        Slot.Visible = true
        Slot.Parent = Hotbar
    end

    UserInputService.InputBegan:Connect(function(Input, Processed)
        if Processed then
            return
        end

        local KeyCodes = {
            Enum.KeyCode.One,
            Enum.KeyCode.Two,
            Enum.KeyCode.Three,
            Enum.KeyCode.Four,
            Enum.KeyCode.Five,
            Enum.KeyCode.Six,
            Enum.KeyCode.Seven,
            Enum.KeyCode.Eight,
        }

        local Num = table.find(KeyCodes, Input.KeyCode)

        if Num then
            Network.Requests.EquipSlot.Fire(Num)
        end
    end)
end

local function Setup_Hud(LocalEntity: Types.Entity, PlayerGui: PlayerGui)
    local HUD = PlayerGui:WaitForChild("HUD") :: ScreenGui

    local Top = HUD:WaitForChild("Top")
    local House = Top:WaitForChild("House") :: ImageButton
    local Sell = Top:WaitForChild("Sell") :: ImageButton
    local Upgrade = Top:WaitForChild("Upgrade") :: ImageButton

    local Left = HUD:WaitForChild("Left")
    local Store = Left:WaitForChild("Store") :: ImageButton
    local Index = Left:WaitForChild("Index") :: ImageButton
    local Items = Left:WaitForChild("Items") :: ImageButton

    local Tutorial = HUD:WaitForChild("Tutorial") :: Frame
    local Tutorial_Text_Label = Tutorial:WaitForChild("TextLabel") :: TextLabel

    local Tutorial_Arrow = HUD:WaitForChild("Tutorial_Arrow") :: ImageLabel

    local OneTimeOffer = HUD:WaitForChild("OneTimeOffer")

    local AutoSwing = HUD:WaitForChild("AutoSwing")

    local Right = HUD:WaitForChild("Right")
    local Free_Reward = Right:WaitForChild("FreeReward") :: ImageButton
    local Rebirth = Right:WaitForChild("Rebirth") :: ImageButton

    Setup_Hotbar(LocalEntity, PlayerGui)

    Hydrate_Button(Free_Reward, function()
        if Peek(Fusion_Values.Screen) == "FreeReward" then
            Fusion_Values.Screen:set("HUD")
        else
            Fusion_Values.Screen:set("FreeReward")
        end
    end)

    Scope:Hydrate(Free_Reward)({
        Visible = Scope:Computed(function(Use)
            return (Use(Fusion_Values.Tutorial_Step) > 9)
        end),
    })

    Hydrate_Button(AutoSwing, function()
        if Peek(Fusion_Values.Auto_Swing) == true then
            Fusion_Values.Auto_Swing:set(false)
        else
            Fusion_Values.Auto_Swing:set(true)
        end
    end)

    Scope:Hydrate(AutoSwing)({
        Visible = Scope:Computed(function(Use)
            return Use(Fusion_Values.Auto_Swing_Visible)
        end),
    })

    Scope:Hydrate(AutoSwing)({
        ImageColor3 = Scope:Computed(function(Use)
            if Use(Fusion_Values.Auto_Swing) then
                return Color3.fromRGB(21, 255, 80)
            else
                return Color3.fromRGB(255, 71, 71)
            end
        end),
    })

    Hydrate_Button(House, function()
        local PlotEntity = World:target(LocalEntity, Components.Relationships.Plot)

        if not PlotEntity then
            return
        end

        local PlotModel = World:get(PlotEntity, Components.Renderable) :: Model

        local PlotSpawn = PlotModel:WaitForChild("Spawn") :: Part

        local Character: Model? = World:get(LocalEntity, Components.Renderable)

        if not Character then
            return
        end

        Character:PivotTo(PlotSpawn.CFrame)
    end)

    Hydrate_Button(Sell, function()
        local Character: Model? = World:get(LocalEntity, Components.Renderable)

        if not Character then
            return
        end

        Character:PivotTo(Sell_Shop_Teleport.CFrame)
    end)

    Hydrate_Button(Upgrade, function()
        local Character: Model? = World:get(LocalEntity, Components.Renderable)

        if not Character then
            return
        end

        Character:PivotTo(Upgrade_Shop_Teleport.CFrame)
    end)

    local Money = HUD:WaitForChild("Money")
    local Amount = Money:WaitForChild("Amount") :: TextLabel
    local FriendBoost = Money:WaitForChild("FriendBoost") :: TextLabel

    local FriendBoostSizeMultiplierSpring = Scope:Spring(Scope:Value(1), 17, 0.5)

    Scope:Observer(Fusion_Values.Friend_Boost):onBind(function()
        FriendBoostSizeMultiplierSpring:addVelocity(ACTIVATE_VELOCITY)
    end)

    Scope:Hydrate(FriendBoost)({
        Text = Scope:Computed(function(Use)
            local Percent = math.round((Use(Fusion_Values.Friend_Boost) - 1) * 100)
            return string.format("%d%% Friend Boost", Percent)
        end),
        [Children] = {
            Scope:New("UIScale")({
                Scale = FriendBoostSizeMultiplierSpring,
            }),
        },
    })

    local MoneySizeMultiplierSpring = Scope:Spring(Scope:Value(1), 17, 0.5)
    local OldCash = Peek(Fusion_Values.Cash)

    Scope:Observer(Fusion_Values.Cash):onBind(function()
        local NewCash = Peek(Fusion_Values.Cash)

        local Difference = math.round(math.abs(NewCash - OldCash))

        if Difference == 0 then
            return
        end

        CashChange:Play()

        OldCash = NewCash

        MoneySizeMultiplierSpring:addVelocity(ACTIVATE_VELOCITY)
    end)

    Scope:Hydrate(Amount)({
        Text = Scope:Computed(function(Use)
            return `${Util.Format_Number_With_Commas(Use(Fusion_Values.Cash))}`
        end),
        [Children] = {
            Scope:New("UIScale")({
                Scale = MoneySizeMultiplierSpring,
            }),
        },
    })

    Hydrate_Button(Store, function()
        if Peek(Fusion_Values.Screen) == "Store" then
            Fusion_Values.Screen:set("HUD")
        else
            Fusion_Values.Screen:set("Store")
        end
    end)

    Scope:Hydrate(Store)({
        Visible = Scope:Computed(function(Use)
            return (Use(Fusion_Values.Tutorial_Step) > 9)
        end),
    })

    Hydrate_Button(Items, function()
        if Peek(Fusion_Values.Screen) == "Items" then
            Fusion_Values.Screen:set("HUD")
        else
            Fusion_Values.Screen:set("Items")
        end
    end)

    Hydrate_Button(Index, function()
        if Peek(Fusion_Values.Screen) == "Index" then
            Fusion_Values.Screen:set("HUD")
        else
            Fusion_Values.Screen:set("Index")
        end
    end)

    Scope:Hydrate(Index)({
        Visible = Scope:Computed(function(Use)
            return (Use(Fusion_Values.Tutorial_Step) > 9)
        end),
    })

    Hydrate_Button(Rebirth, function()
        if Peek(Fusion_Values.Screen) == "Rebirth" then
            Fusion_Values.Screen:set("HUD")
        else
            Fusion_Values.Screen:set("Rebirth")
        end
    end)

    Scope:Hydrate(Rebirth, {
        Visible = Scope:Computed(function(Use)
            return (Use(Fusion_Values.Tutorial_Step) > 9)
        end),
    })

    local Tutorial_Text_Value = Scope:Value("")

    local Tutorial_Text_Options = {
        [0] = "Break the Wood Crate",
        [1] = "Wait for a new fish",
        [2] = "Collect your cash",
        [3] = "Upgrade your hammer",
        [4] = "Buy a Mossy Crate",
        [5] = "Skip the crate",
        [6] = "Break the Mossy Crate",
        [7] = "Wait for a fish",
        [8] = "Pickup your first fish",
        [9] = "Sell the fish",
        [10] = "Tutorial Complete!",
    }

    local Type_Writer_Task: thread?

    Scope:Observer(Fusion_Values.Tutorial_Step):onBind(function()
        local New_Step = Peek(Fusion_Values.Tutorial_Step)

        if Type_Writer_Task then
            task.cancel(Type_Writer_Task)
        end

        local Text = Tutorial_Text_Options[New_Step]

        if not Text then
            Tutorial.Visible = false
            return
        end

        Tutorial.Visible = true

        if New_Step == 4 or New_Step == 5 or New_Step == #Tutorial_Text_Options then
            Fusion_Values.Screen:set("HUD")
        end

        if New_Step == #Tutorial_Text_Options then
            Confetti({ GUI = HUD, Count = 200 } :: any)

            TutorialComplete:Play()
        end

        Type_Writer_Task = task.spawn(function()
            for i = 1, #Text do
                Tutorial_Text_Value:set(string.sub(Text, 1, i))

                TypeWriter:Play()

                task.wait(0.05)
            end
        end)
    end)

    local START_TUTORIAL_ARROW_POSITION = UDim2.fromScale(0.247, 0.067)
    local END_TUTORIAL_ARROW_POSITION = UDim2.fromScale(0.256, 0.067)

    local Tutorial_Arrow_Tween_Info = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

    local Tutorial_Arrow_Position = Scope:Value(START_TUTORIAL_ARROW_POSITION)
    local Tutorial_Arrow_Position_Tween = Scope:Tween(Tutorial_Arrow_Position, Tutorial_Arrow_Tween_Info)

    Scope:Hydrate(Tutorial_Arrow)({
        Position = Tutorial_Arrow_Position_Tween,
        Visible = Scope:Computed(function(Use)
            return Use(Fusion_Values.Tutorial_Step) == 3 and Use(Fusion_Values.Screen) ~= "Upgrades"
        end),
    })

    Clock(0.5, function()
        if Peek(Fusion_Values.Tutorial_Step) > 3 then
            return
        end

        if Peek(Tutorial_Arrow_Position) == START_TUTORIAL_ARROW_POSITION then
            Tutorial_Arrow_Position:set(END_TUTORIAL_ARROW_POSITION)
        else
            Tutorial_Arrow_Position:set(START_TUTORIAL_ARROW_POSITION)
        end
    end)

    local Second_Tutorial_Arrow = HUD:WaitForChild("Second_Tutorial_Arrow")

    local START_SELL_TUTORIAL_ARROW_POSITION = UDim2.fromScale(0.702, 0.15)
    local END_SELL_TUTORIAL_ARROW_POSITION = UDim2.fromScale(0.702, 0.13)

    local Second_Tutorial_Arrow_Position = Scope:Value(START_SELL_TUTORIAL_ARROW_POSITION)
    local Second_Tutorial_Arrow_Position_Tween = Scope:Tween(Second_Tutorial_Arrow_Position, Tutorial_Arrow_Tween_Info)

    Scope:Hydrate(Second_Tutorial_Arrow)({
        Position = Second_Tutorial_Arrow_Position_Tween,
        Visible = Scope:Computed(function(Use)
            return Use(Fusion_Values.Tutorial_Step) == 9 and Use(Fusion_Values.Screen)
        end),
    })

    Clock(0.5, function()
        if Peek(Fusion_Values.Tutorial_Step) > 9 then
            return
        end

        if Peek(Second_Tutorial_Arrow_Position) == START_SELL_TUTORIAL_ARROW_POSITION then
            Second_Tutorial_Arrow_Position:set(END_SELL_TUTORIAL_ARROW_POSITION)
        else
            Second_Tutorial_Arrow_Position:set(START_SELL_TUTORIAL_ARROW_POSITION)
        end
    end)

    Scope:Hydrate(Tutorial_Text_Label)({
        Text = Scope:Computed(function(Use)
            return Use(Tutorial_Text_Value)
        end),
    })

    Scope:Hydrate(OneTimeOffer)({
        Visible = Scope:Computed(function(Use)
            return (Use(Fusion_Values.Bought_One_Time_Offer) == false and Use(Fusion_Values.Tutorial_Step) > 9)
        end),
    })

    Hydrate_Button(OneTimeOffer, function()
        if Peek(Fusion_Values.Screen) == "OneTimeOffer" then
            Fusion_Values.Screen:set("HUD")
        else
            Fusion_Values.Screen:set("OneTimeOffer")
        end
    end)

    local OneTimeOffer_Gradient = OneTimeOffer:FindFirstChild("UIGradient", true) :: UIGradient

    local StartOffset = Vector2.new(-0.6, 0)
    local EndOffset = Vector2.new(0.6, 0)

    local function StartScrollLoop()
        OneTimeOffer_Gradient.Offset = StartOffset

        local TweenInfo = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.In)

        local Tween = TweenService:Create(OneTimeOffer_Gradient, TweenInfo, { Offset = EndOffset })

        Tween.Completed:Connect(function()
            StartScrollLoop() -- Restart loop
        end)

        Tween:Play()
    end

    StartScrollLoop()
end

local function Setup_Items(LocalEntity: Types.Entity, PlayerGui: PlayerGui)
    local LocalPlayer = World:get(LocalEntity, Components.Player)

    local Panels = PlayerGui:WaitForChild("Panels") :: ScreenGui

    local Items_Panel = Panels:WaitForChild("Items")
    local Scroll = Items_Panel:WaitForChild("Scroll") :: ScrollingFrame
    local Close = Items_Panel:WaitForChild("Close") :: ImageButton

    local Template = Scroll:WaitForChild("Template") :: ImageButton

    Scope:Hydrate(Scroll)({
        [Children] = {
            Scope:Computed(function(Use, Processor: Fusion.Scope<Fusion.Fusion>)
                local Inventory = Use(Fusion_Values.Inventory)

                local Slots = {}

                for Slot, Item in Inventory do
                    if Slot <= 8 then
                        continue
                    end

                    local Button = Template:Clone()
                    local Title = Button:WaitForChild("Title")

                    local Item_Name = Item.Name
                    local Item_Mutation = Item.Mutation
                    local Item_Amount = Item.Amount

                    local Fish_Data = Fish[Item_Name]

                    local IncomePerSecValue = Fish_Data.IncomePerSec

                    if Item_Mutation then
                        local Mutation_Data = Mutations[Item_Mutation]

                        IncomePerSecValue *= Mutation_Data.Multiplier
                    end

                    Button.LayoutOrder = -IncomePerSecValue

                    local Mutation_Text = Item_Mutation and Item_Mutation .. " " or ""
                    local Amount_Text = Item_Amount > 1 and ` [x{Item_Amount}]` or ""

                    Title.Text = `{Mutation_Text}{Item_Name}{Amount_Text}`

                    local Rarity = Fish[Item.Name].Rarity

                    UIGradients:FindFirstChild(Rarity):Clone().Parent = Button

                    if Item.Mutation then
                        UIGradients:FindFirstChild(Item.Mutation):Clone().Parent = Title
                    end

                    local SizeMultiplier = Scope:Value(DEFAULT_SIZE_MULTIPLIER)
                    local Hovering = Scope:Value(false)
                    local SizeMultiplierSpring = Scope:Spring(SizeMultiplier, 17, 0.5)

                    Scope:Observer(Hovering):onBind(function()
                        if Peek(Hovering) then
                            SizeMultiplier:set(HOVER_SIZE_MULTIPLIER)
                        else
                            SizeMultiplier:set(DEFAULT_SIZE_MULTIPLIER)
                        end
                    end)

                    local function OnActivate()
                        Activate:Play()
                        ActivateHaptic:Play()
                        SizeMultiplierSpring:addVelocity(ACTIVATE_VELOCITY)

                        Network.Requests.Swap.Fire(Slot)
                    end

                    Scope:Hydrate(Button)({
                        [OnEvent("MouseEnter")] = function()
                            Hover:Play()
                            Hovering:set(true)
                        end,
                        [OnEvent("MouseLeave")] = function()
                            Hovering:set(false)
                        end,
                        [OnEvent("Activated")] = function()
                            OnActivate()
                        end,
                        [Children] = {
                            Scope:New("UIScale")({
                                Scale = SizeMultiplierSpring,
                            }),
                        },
                    })

                    Button.Visible = true

                    table.insert(Slots, Button)
                end

                return Slots
            end),
        },
    })

    Scope:Hydrate(Items_Panel)({
        Visible = Scope:Computed(function(Use)
            return Use(Fusion_Values.Screen) == "Items"
        end),
    })

    Hydrate_Button(Close, function()
        Fusion_Values.Screen:set("HUD")
    end)
end

local function Setup_Store(LocalEntity: Types.Entity, PlayerGui: PlayerGui)
    local LocalPlayer = World:get(LocalEntity, Components.Player)

    local Panels = PlayerGui:WaitForChild("Panels") :: ScreenGui

    local Store_Panel = Panels:WaitForChild("Store")
    local Scroll = Store_Panel:WaitForChild("Scroll") :: ScrollingFrame
    local Close = Store_Panel:WaitForChild("Close") :: ImageButton

    local KrakenCrate = Scroll:WaitForChild("KrakenCrate")
    local KrakenCrate_Buy_Button = KrakenCrate:WaitForChild("Buy") :: ImageButton
    local KrakenCrate_Buy_Price_Text_Label = KrakenCrate_Buy_Button:WaitForChild("Price") :: TextLabel
    local KrakenCrate_Product_Id = Crates["Kraken Crate"].ProductId
    local KrakenCrate_Cost = Get_Product_Price(KrakenCrate_Product_Id)

    KrakenCrate_Buy_Price_Text_Label.Text = `{KrakenCrate_Cost}`

    Hydrate_Button(KrakenCrate_Buy_Button, function()
        MarketPlaceService:PromptProductPurchase(LocalPlayer, KrakenCrate_Product_Id)
    end)

    local Passes = Scroll:WaitForChild("Passes")

    local DoubleCash = Passes:WaitForChild("DoubleCash")
    local Double_Cash_Buy_Button = DoubleCash:WaitForChild("Buy") :: ImageButton
    local Double_Cash_Price_Text_Label = Double_Cash_Buy_Button:WaitForChild("Price") :: TextLabel
    local Double_Cash_Robux_Price = Get_Gamepass_Price(GamepassIds["x2 Cash"])

    Double_Cash_Price_Text_Label.Text = `{Double_Cash_Robux_Price}`

    Hydrate_Button(Double_Cash_Buy_Button, function()
        MarketPlaceService:PromptGamePassPurchase(LocalPlayer, GamepassIds["x2 Cash"])
    end)

    local DoubleSlots = Passes:WaitForChild("DoubleSlots")
    local Double_Slots_Buy_Button = DoubleSlots:WaitForChild("Buy") :: ImageButton
    local Double_Slots_Price_Text_Label = Double_Slots_Buy_Button:WaitForChild("Price") :: TextLabel
    local Double_Slots_Robux_Price = Get_Gamepass_Price(GamepassIds["x2 Slots"])

    Double_Slots_Price_Text_Label.Text = `{Double_Slots_Robux_Price}`

    Hydrate_Button(Double_Slots_Buy_Button, function()
        MarketPlaceService:PromptGamePassPurchase(LocalPlayer, GamepassIds["x2 Slots"])
    end)

    local DoubleLuck = Passes:WaitForChild("DoubleLuck")
    local Double_Luck_Buy_Button = DoubleLuck:WaitForChild("Buy") :: ImageButton
    local Double_Luck_Price_Text_Label = Double_Luck_Buy_Button:WaitForChild("Price") :: TextLabel
    local Double_Luck_Robux_Price = Get_Gamepass_Price(GamepassIds["x2 Luck"])

    Double_Luck_Price_Text_Label.Text = `{Double_Luck_Robux_Price}`

    Hydrate_Button(Double_Luck_Buy_Button, function()
        MarketPlaceService:PromptGamePassPurchase(LocalPlayer, GamepassIds["x2 Luck"])
    end)

    local DoubleMutations = Passes:WaitForChild("DoubleMutations")
    local Double_Mutations_Buy_Button = DoubleMutations:WaitForChild("Buy") :: ImageButton
    local Double_Mutations_Price_Text_Label = Double_Mutations_Buy_Button:WaitForChild("Price") :: TextLabel
    local Double_Mutations_Robux_Price = Get_Gamepass_Price(GamepassIds["x2 Mutations"])

    Double_Mutations_Price_Text_Label.Text = `{Double_Mutations_Robux_Price}`

    Hydrate_Button(Double_Mutations_Buy_Button, function()
        MarketPlaceService:PromptGamePassPurchase(LocalPlayer, GamepassIds["x2 Mutations"])
    end)

    local PackBuyButtons = Scroll:WaitForChild("PackBuyButtons")

    local Starter_Buy_Button = PackBuyButtons:WaitForChild("Starter") :: ImageButton
    local Starter_Buy_Button_Price_Text_Label = Starter_Buy_Button:WaitForChild("Price") :: TextLabel
    local Starter_Price = Get_Product_Price(ProductIds["Starter Pack"])

    Starter_Buy_Button_Price_Text_Label.Text = `{Starter_Price}`

    Hydrate_Button(Starter_Buy_Button, function()
        MarketPlaceService:PromptProductPurchase(LocalPlayer, ProductIds["Starter Pack"])
    end)

    local Ultimate_Buy_Button = PackBuyButtons:WaitForChild("Ultimate") :: ImageButton
    local Ultimate_Buy_Button_Price_Text_Label = Ultimate_Buy_Button:WaitForChild("Price") :: TextLabel
    local Ultimate_Price = Get_Product_Price(ProductIds["Ultimate Pack"])

    Ultimate_Buy_Button_Price_Text_Label.Text = `{Ultimate_Price}`

    Hydrate_Button(Ultimate_Buy_Button, function()
        MarketPlaceService:PromptProductPurchase(LocalPlayer, ProductIds["Ultimate Pack"])
    end)

    local ServerLuck = Scroll:WaitForChild("ServerLuck")
    local ServerLuck_Buy_Button = ServerLuck:WaitForChild("Buy") :: ImageButton
    local ServerLuck_Price_Text_Label = ServerLuck_Buy_Button:WaitForChild("Price") :: TextLabel
    local ServerLuck_Price = Get_Product_Price(ProductIds["15 Min Server Luck x2"])

    ServerLuck_Price_Text_Label.Text = `{ServerLuck_Price}`

    Hydrate_Button(ServerLuck_Buy_Button, function()
        MarketPlaceService:PromptProductPurchase(LocalPlayer, ProductIds["15 Min Server Luck x2"])
    end)

    Scope:Hydrate(Store_Panel)({
        Visible = Scope:Computed(function(Use)
            return Use(Fusion_Values.Screen) == "Store"
        end),
    })

    Hydrate_Button(Close, function()
        Fusion_Values.Screen:set("HUD")
    end)
end

local function Setup_Index(LocalEntity: Types.Entity, PlayerGui: PlayerGui)
    local Panels = PlayerGui:WaitForChild("Panels") :: ScreenGui

    local Index_Panel = Panels:WaitForChild("Index")
    local Scroll = Index_Panel:WaitForChild("Scroll") :: ScrollingFrame
    local Template = Scroll:WaitForChild("Template") :: ImageLabel

    for Fish_Name, Fish_Data in Fish do
        local ImageLabel = Template:Clone()
        local Title = ImageLabel:WaitForChild("Title") :: TextLabel
        local Rarity = ImageLabel:WaitForChild("Rarity") :: TextLabel
        local Viewport = ImageLabel:WaitForChild("Viewport") :: ViewportFrame

        local Owns = Scope:Computed(function(Use)
            local Index = Use(Fusion_Values.Index)

            local List = Index["Normal"]

            if not List then
                return false
            end

            if not table.find(List, Fish_Name) then
                return false
            end

            return true
        end)

        Title.Text = Fish_Name
        Rarity.Text = Fish_Data.Rarity

        Scope:Hydrate(Title)({
            Visible = Scope:Computed(function(Use)
                return Use(Owns)
            end),
        })

        Scope:Hydrate(Rarity)({
            Visible = Scope:Computed(function(Use)
                return Use(Owns)
            end),
        })

        local Rarity_Gradient = UIGradients:FindFirstChild(Fish_Data.Rarity)

        if Rarity_Gradient then
            Rarity_Gradient:Clone().Parent = Rarity
        end

        Scope:Hydrate(Viewport)({
            ImageColor3 = Scope:Computed(function(Use)
                if Use(Owns) then
                    return Color3.new(1, 1, 1)
                else
                    return Color3.new(0, 0, 0)
                end
            end),
        })

        local Camera = Instance.new("Camera")
        Camera.CFrame = CFrame.new(Vector3.zero)
        Camera.FieldOfView = 70
        Camera.Parent = Viewport

        Viewport.CurrentCamera = Camera

        local WorldModel = Instance.new("WorldModel")
        WorldModel.Parent = Viewport

        local Model = Fish_Data.Models.Normal:Clone()
        Model.Parent = Debris_Folder
        Model:PivotTo(Fish_Data.Viewport_CFrame)

        local Animator = Model:FindFirstChild("Animator", true) :: Animator

        AnimPlayer.Load(Animator)

        AnimPlayer.PlayAnimation(Animator, {
            Name = "Fish [Idle]",
            Loop = true,
        })

        Model.Parent = WorldModel

        ImageLabel.LayoutOrder = Fish_Data.IncomePerSec
        ImageLabel.Parent = Scroll
        ImageLabel.Visible = true
    end

    local Close = Index_Panel:WaitForChild("Close") :: ImageButton

    Scope:Hydrate(Index_Panel)({
        Visible = Scope:Computed(function(Use)
            return Use(Fusion_Values.Screen) == "Index"
        end),
    })

    Hydrate_Button(Close, function()
        Fusion_Values.Screen:set("HUD")
    end)
end

local function Setup_Upgrade_Shop(LocalEntity: Types.Entity, PlayerGui: PlayerGui)
    local Panels = PlayerGui:WaitForChild("Panels") :: ScreenGui

    local Upgrades_Panel = Panels:WaitForChild("Upgrades")
    local Close = Upgrades_Panel:WaitForChild("Close") :: ImageButton

    local Scroll = Upgrades_Panel:WaitForChild("Scroll") :: ScrollingFrame

    local Tool = Scroll:WaitForChild("Tool") :: ImageLabel
    local Tool_Buy_Button = Tool:WaitForChild("Buy") :: ImageButton
    local Tool_Price_Text = Tool_Buy_Button:WaitForChild("Price") :: TextLabel
    local Tool_Info = Tool:WaitForChild("Info") :: Frame
    local Tool_Title = Tool_Info:WaitForChild("Title") :: TextLabel
    local Tool_Boost = Tool_Info:WaitForChild("Boost") :: TextLabel
    local Tool_Icon = Tool:WaitForChild("Icon") :: ImageLabel
    local Tool_Viewport = Tool_Icon:WaitForChild("Viewport") :: ViewportFrame

    local Tutorial_Arrow = Tool:WaitForChild("Tutorial_Arrow")

    local Luck = Scroll:WaitForChild("Luck") :: ImageLabel
    local Luck_Buy_Button = Luck:WaitForChild("Buy") :: ImageButton
    local Luck_Price_Text = Luck_Buy_Button:WaitForChild("Price") :: TextLabel
    local Luck_Info = Luck:WaitForChild("Info") :: Frame
    local Luck_Boost = Luck_Info:WaitForChild("Boost") :: TextLabel

    local Auto_Swing = Scroll:WaitForChild("AutoSwing") :: ImageLabel
    local Auto_Swing_Buy_Button = Auto_Swing:WaitForChild("Buy") :: ImageButton
    local Auto_Swing_Price_Text = Auto_Swing_Buy_Button:WaitForChild("Price") :: TextLabel
    local Auto_Swing_Info = Auto_Swing:WaitForChild("Info") :: Frame
    local Auto_Swing_Boost = Auto_Swing_Info:WaitForChild("Boost") :: TextLabel

    local Current_Auto_Swing_Upgrade_Data = Scope:Computed(function(Use)
        return Auto_Swing_Upgrades[Use(Fusion_Values.Auto_Swing_Level)]
    end)

    local Next_Auto_Swing_Upgrade_Data = Scope:Computed(function(Use)
        return Auto_Swing_Upgrades[Use(Fusion_Values.Auto_Swing_Level) + 1]
    end)

    Scope:Hydrate(Auto_Swing_Price_Text)({
        Text = Scope:Computed(function(Use)
            local Next_Data = Use(Next_Auto_Swing_Upgrade_Data)

            return Next_Data and `${Util.Format_Number_With_Commas(Next_Data.Price)}` or "Max"
        end),
    })

    Scope:Hydrate(Auto_Swing_Boost)({
        Text = Scope:Computed(function(Use)
            local Current_Data = Use(Current_Auto_Swing_Upgrade_Data)
            local Next_Data = Use(Next_Auto_Swing_Upgrade_Data)

            return `{Current_Data.Cooldown}s -> {Next_Data and Next_Data.Cooldown .. "s" or "?"}`
        end),
    })

    Hydrate_Button(Auto_Swing_Buy_Button, function()
        Network.Requests.UpgradeAutoSwing.Fire()
    end)

    local Current_Tool_Data = Scope:Computed(function(Use)
        local Current_Tool_Level = Use(Fusion_Values.Tool_Level)

        return Hammers[Current_Tool_Level]
    end)

    local Next_Tool_Data = Scope:Computed(function(Use)
        local Current_Tool_Level = Use(Fusion_Values.Tool_Level)

        return Hammers[Current_Tool_Level + 1]
    end)

    Scope:Hydrate(Tool_Boost)({
        Text = Scope:Computed(function(Use)
            local Current_Data = Use(Current_Tool_Data)
            local Next_Data = Use(Next_Tool_Data)

            return `{Current_Data.Damage} -> {Next_Data and Next_Data.Damage or "?"}`
        end),
    })

    Scope:Hydrate(Upgrades_Panel)({
        Visible = Scope:Computed(function(Use)
            return Use(Fusion_Values.Screen) == "Upgrades"
        end),
    })

    Scope:Hydrate(Tool_Viewport)({
        [Children] = Scope:Computed(function(Use, Processor: Fusion.Scope<Fusion.Fusion>)
            local Children = {}

            local Data = Use(Next_Tool_Data)

            if not Data then
                return Children
            end

            local Camera = Instance.new("Camera")
            Camera.CFrame = CFrame.new(Vector3.zero)
            Camera.FieldOfView = 70
            Camera.Parent = Tool_Viewport

            table.insert(Processor, Camera)

            Tool_Viewport.CurrentCamera = Camera

            local Model = Data.Model:Clone() :: Model
            Model.Parent = Tool_Viewport
            Model:PivotTo(Data.Viewport_CFrame)

            table.insert(Children, Model)

            return Children
        end),
    })

    Scope:Hydrate(Tool_Price_Text)({
        Text = Scope:Computed(function(Use)
            local Next_Data = Use(Next_Tool_Data)

            return Next_Data and `${Util.Format_Number_With_Commas(Next_Data.Price)}` or "Max"
        end),
    })

    Hydrate_Button(Tool_Buy_Button, function()
        Network.Requests.UpgradeTool.Fire()
    end)

    Scope:Hydrate(Luck_Price_Text)({
        Text = Scope:Computed(function(Use)
            local Luck_Level = Use(Fusion_Values.Luck_Level)

            return Luck_Prices[Luck_Level + 1] and `${Util.Format_Number_With_Commas(Luck_Prices[Luck_Level + 1])}`
                or "Max"
        end),
    })

    Scope:Hydrate(Luck_Boost)({
        Text = Scope:Computed(function(Use)
            local Luck_Level = Use(Fusion_Values.Luck_Level)

            return `{StatCalculator.Calculate_Luck(Luck_Level)} -> {Luck_Prices[Luck_Level + 1] and StatCalculator.Calculate_Luck(
                Luck_Level + 1
            ) or "?"}`
        end),
    })

    Hydrate_Button(Luck_Buy_Button, function()
        Network.Requests.UpgradeLuck.Fire()
    end)

    Hydrate_Button(Close, function()
        Fusion_Values.Screen:set("HUD")
    end)

    local RootPart = Upgrade_Shop_Npc:WaitForChild("HumanoidRootPart")

    local ProximityPrompt = Instance.new("ProximityPrompt")
    ProximityPrompt.ClickablePrompt = true
    ProximityPrompt.Enabled = true
    ProximityPrompt.Exclusivity = Enum.ProximityPromptExclusivity.OneGlobally
    ProximityPrompt.GamepadKeyCode = Enum.KeyCode.ButtonX
    ProximityPrompt.KeyboardKeyCode = Enum.KeyCode.E
    ProximityPrompt.MaxActivationDistance = 15
    ProximityPrompt.RequiresLineOfSight = false
    ProximityPrompt.HoldDuration = 0
    ProximityPrompt.ActionText = "Open Upgrades"
    ProximityPrompt.ObjectText = ""
    ProximityPrompt.Style = Enum.ProximityPromptStyle.Custom
    ProximityPrompt.Parent = RootPart

    ProximityPrompt.Triggered:Connect(function(TargetPlayer)
        Fusion_Values.Screen:set("Upgrades")
    end)

    local START_TUTORIAL_ARROW_POSITION = UDim2.fromScale(0.81, 1.294)
    local END_TUTORIAL_ARROW_POSITION = UDim2.fromScale(0.81, 1.181)

    local Tutorial_Arrow_Tween_Info = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

    local Tutorial_Arrow_Position = Scope:Value(START_TUTORIAL_ARROW_POSITION)
    local Tutorial_Arrow_Position_Tween = Scope:Tween(Tutorial_Arrow_Position, Tutorial_Arrow_Tween_Info)

    Scope:Hydrate(Tutorial_Arrow)({
        Position = Tutorial_Arrow_Position_Tween,
        Visible = Scope:Computed(function(Use)
            return Use(Fusion_Values.Tutorial_Step) == 3
        end),
    })

    Clock(0.5, function()
        if Peek(Fusion_Values.Tutorial_Step) > 3 then
            return
        end

        if Peek(Tutorial_Arrow_Position) == START_TUTORIAL_ARROW_POSITION then
            Tutorial_Arrow_Position:set(END_TUTORIAL_ARROW_POSITION)
        else
            Tutorial_Arrow_Position:set(START_TUTORIAL_ARROW_POSITION)
        end
    end)
end

local function Setup_Crate_Shop(LocalEntity: Types.Entity, PlayerGui)
    local LocalPlayer = World:get(LocalEntity, Components.Player)

    local Panels = PlayerGui:WaitForChild("Panels") :: ScreenGui

    local Crates_Panel = Panels:WaitForChild("Crates")
    local Scroll = Crates_Panel:WaitForChild("Scroll") :: ScrollingFrame
    local Purchase_Frame = Scroll:WaitForChild("Purchase")
    local Purchase_Frame_Buy_Button = Purchase_Frame:WaitForChild("Buy") :: ImageButton
    local Purchase_Frame_Buy_Button_Title = Purchase_Frame_Buy_Button:WaitForChild("Title") :: TextLabel
    local Purchase_Frame_Robux_Buy_Button = Purchase_Frame:WaitForChild("Robux_Buy") :: ImageButton
    local Purchase_Frame_Robux_Buy_Button_Title = Purchase_Frame_Robux_Buy_Button:WaitForChild("Title") :: TextLabel
    local Template = Scroll:WaitForChild("Template") :: ImageButton
    local Restock = Crates_Panel:WaitForChild("Restock") :: ImageButton
    local Timer = Crates_Panel:WaitForChild("Timer")
    local Timer_Title = Timer:WaitForChild("Title") :: TextLabel

    local PURCHASE_FRAME_ENABLED_SIZE = UDim2.fromScale(0.96, 0.184)
    local PURCHASE_FRAME_DISABLED_SIZE = UDim2.fromScale(0.96, 0)

    local Purchase_Frame_Name = Scope:Value(nil)
    local Purchase_Frame_Size = Scope:Value(PURCHASE_FRAME_DISABLED_SIZE)
    local Purchase_Frame_Size_Spring = Scope:Spring(Purchase_Frame_Size, 30, 1)
    local Purchase_Frame_Layout_Order = Scope:Value(0)

    Scope:Hydrate(Purchase_Frame)({
        LayoutOrder = Scope:Computed(function(Use)
            return Use(Purchase_Frame_Layout_Order)
        end),
        Size = Purchase_Frame_Size_Spring,
    })

    Scope:Observer(Fusion_Values.Screen):onChange(function()
        if Peek(Fusion_Values.Screen) ~= "Crates" then
            Purchase_Frame_Size:set(PURCHASE_FRAME_DISABLED_SIZE)

            Purchase_Frame_Size_Spring:setPosition(PURCHASE_FRAME_DISABLED_SIZE)
        end
    end)

    for Crate_Name, Crate_Data in Crates do
        if Crate_Data.Restock_Chance == 0 then
            continue
        end

        local Frame = Template:Clone()

        local NoStock = Frame:WaitForChild("NoStock")

        local Icon = Frame:WaitForChild("Icon")
        local Viewport = Icon:WaitForChild("Viewport") :: ViewportFrame

        local Rarity = Frame:WaitForChild("Rarity") :: ImageLabel
        local Rarity_Title = Rarity:WaitForChild("Title") :: TextLabel

        local Info = Frame:WaitForChild("Info")
        local Title = Info:WaitForChild("Title") :: TextLabel
        local Stock = Info:WaitForChild("Stock") :: TextLabel
        local Price = Info:WaitForChild("Price") :: TextLabel

        local Robux_Cost = Get_Product_Price(Crate_Data.ProductId)

        Scope:Hydrate(NoStock)({
            Visible = Scope:Computed(function(Use)
                local Current_Stock = Use(Fusion_Values.Stock)
                local Crate_Stock = Current_Stock[Crate_Name] or 0

                return (Crate_Stock == 0)
            end),
        })

        local Camera = Instance.new("Camera")
        Camera.CFrame = CFrame.new(Vector3.zero)
        Camera.Parent = Viewport

        Viewport.CurrentCamera = Camera

        local Model = Crate_Data.Model:Clone()
        Model.Parent = Viewport

        Model:PivotTo(Crate_Data.Viewport_CFrame)

        Rarity_Title.Text = Crate_Data.Rarity

        local Gradient = UIGradients:WaitForChild(Crate_Data.Rarity)
        Gradient:Clone().Parent = Rarity

        Title.Text = Crate_Name

        Scope:Hydrate(Stock)({
            Text = Scope:Computed(function(Use)
                local Current_Stock = Use(Fusion_Values.Stock)

                return `x{Current_Stock[Crate_Name] and Current_Stock[Crate_Name] or 0}`
            end),
        })

        Price.Text = `${Util.Format_Number_With_Commas(Crate_Data.Price)}`

        Hydrate_Button(Frame, function()
            if Peek(Purchase_Frame_Name) == Crate_Name and Peek(Purchase_Frame_Size) == PURCHASE_FRAME_ENABLED_SIZE then
                Purchase_Frame_Size:set(PURCHASE_FRAME_DISABLED_SIZE)

                Purchase_Frame_Name:set(nil)
                return
            end

            Purchase_Frame_Size_Spring:setPosition(PURCHASE_FRAME_DISABLED_SIZE)

            Purchase_Frame_Layout_Order:set(Crate_Data.Price + 1)

            Purchase_Frame_Size:set(PURCHASE_FRAME_ENABLED_SIZE)

            Purchase_Frame_Name:set(Crate_Name)

            Purchase_Frame_Buy_Button_Title.Text = `${Util.Format_Number_With_Commas(Crate_Data.Price)}`
            Purchase_Frame_Robux_Buy_Button_Title.Text = `{Robux_Cost}`
        end, 1.02, 1.05)

        if Crate_Name == "Mossy Crate" then
            local Tutorial_Arrow = Frame:WaitForChild("Tutorial_Arrow")
            local START_TUTORIAL_ARROW_POSITION = UDim2.fromScale(1.045, 0.541)
            local END_TUTORIAL_ARROW_POSITION = UDim2.fromScale(1.03, 0.541)

            local Tutorial_Arrow_Tween_Info = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

            local Tutorial_Arrow_Position = Scope:Value(START_TUTORIAL_ARROW_POSITION)
            local Tutorial_Arrow_Position_Tween = Scope:Tween(Tutorial_Arrow_Position, Tutorial_Arrow_Tween_Info)

            Scope:Hydrate(Tutorial_Arrow)({
                Position = Tutorial_Arrow_Position_Tween,
                Visible = Scope:Computed(function(Use)
                    return Use(Fusion_Values.Tutorial_Step) == 4
                end),
            })

            Clock(0.5, function()
                if Peek(Fusion_Values.Tutorial_Step) > 4 then
                    return
                end

                if Peek(Tutorial_Arrow_Position) == START_TUTORIAL_ARROW_POSITION then
                    Tutorial_Arrow_Position:set(END_TUTORIAL_ARROW_POSITION)
                else
                    Tutorial_Arrow_Position:set(START_TUTORIAL_ARROW_POSITION)
                end
            end)
        end

        Frame.Parent = Scroll
        Frame.LayoutOrder = Crate_Data.Price
        Frame.Visible = true
    end

    Hydrate_Button(Purchase_Frame_Buy_Button, function()
        local Crate_Name = Peek(Purchase_Frame_Name)

        if not Crate_Name then
            return
        end

        Network.Requests.BuyCrate.Fire(Crate_Name)
    end)

    Hydrate_Button(Purchase_Frame_Robux_Buy_Button, function()
        local Crate_Name = Peek(Purchase_Frame_Name)

        if not Crate_Name then
            return
        end

        if not (Peek(Fusion_Values.Tutorial_Step) > 9) then
            local Notification = World:entity()
            World:set(Notification, Components.Text, "Complete the tutorial first")
            World:add(Notification, Components.Tags.Notification)

            return
        end

        MarketPlaceService:PromptProductPurchase(LocalPlayer, Crates[Crate_Name].ProductId)
    end)

    Hydrate_Button(Restock, function()
        MarketPlaceService:PromptProductPurchase(LocalPlayer, ProductIds.Restock)
    end)

    Clock(1, function()
        local Current_Time = os.time()
        local Restock_Time = Peek(Fusion_Values.Restock_Time)

        local SecondsLeft = math.max(Restock_Time - Current_Time, 0)

        local Minutes = math.floor(SecondsLeft / 60)
        local Seconds = SecondsLeft % 60
        Timer_Title.Text = string.format("Restock in %02d:%02d", Minutes, Seconds)
    end)

    local Close = Crates_Panel:WaitForChild("Close") :: ImageButton

    Scope:Hydrate(Crates_Panel)({
        Visible = Scope:Computed(function(Use)
            return Use(Fusion_Values.Screen) == "Crates"
        end),
    })

    Hydrate_Button(Close, function()
        Fusion_Values.Screen:set("HUD")
    end)

    local RootPart = Crate_Shop_Npc:WaitForChild("HumanoidRootPart")

    local ProximityPrompt = Instance.new("ProximityPrompt")
    ProximityPrompt.ClickablePrompt = true
    ProximityPrompt.Enabled = true
    ProximityPrompt.Exclusivity = Enum.ProximityPromptExclusivity.OneGlobally
    ProximityPrompt.GamepadKeyCode = Enum.KeyCode.ButtonX
    ProximityPrompt.KeyboardKeyCode = Enum.KeyCode.E
    ProximityPrompt.MaxActivationDistance = 15
    ProximityPrompt.RequiresLineOfSight = false
    ProximityPrompt.HoldDuration = 0
    ProximityPrompt.ActionText = "Open Crates"
    ProximityPrompt.ObjectText = ""
    ProximityPrompt.Style = Enum.ProximityPromptStyle.Custom
    ProximityPrompt.Parent = RootPart

    ProximityPrompt.Triggered:Connect(function(TargetPlayer)
        Fusion_Values.Screen:set("Crates")
    end)
end

local function Setup_One_Time_Offer(LocalEntity: Types.Entity, PlayerGui: PlayerGui)
    local LocalPlayer = World:get(LocalEntity, Components.Player)

    local Panels = PlayerGui:WaitForChild("Panels") :: ScreenGui

    local One_Time_Offer_Panel = Panels:WaitForChild("OneTimeOffer")
    local Buy_Button = One_Time_Offer_Panel:WaitForChild("Buy") :: ImageButton
    local Price_Text_Label = Buy_Button:WaitForChild("Price") :: TextLabel
    local Close = One_Time_Offer_Panel:WaitForChild("Close") :: ImageButton

    Scope:Hydrate(One_Time_Offer_Panel)({
        Visible = Scope:Computed(function(Use)
            return (Use(Fusion_Values.Screen) == "OneTimeOffer" and Use(Fusion_Values.Bought_One_Time_Offer) == false)
        end),
    })

    Scope:Observer(Fusion_Values.Bought_One_Time_Offer):onChange(function()
        if Peek(Fusion_Values.Bought_One_Time_Offer) == true then
            Fusion_Values.Screen:set("HUD")
        end
    end)

    local Price = Get_Product_Price(ProductIds["One Time Offer"])

    Price_Text_Label.Text = `{Price}`

    Hydrate_Button(Buy_Button, function()
        MarketPlaceService:PromptProductPurchase(LocalPlayer, ProductIds["One Time Offer"])
    end)

    Hydrate_Button(Close, function()
        Fusion_Values.Screen:set("HUD")
    end)
end

local function Setup_Notifications(LocalEntity: Types.Entity, PlayerGui: PlayerGui)
    local Notifications = PlayerGui:WaitForChild("Notifications") :: ScreenGui
    local Notifications_Frame = Notifications:WaitForChild("Notifications") :: Frame

    Scope:Hydrate(Notifications_Frame)({
        Position = Scope:Computed(function(Use)
            if Use(Fusion_Values.Auto_Swing_Visible) then
                return UDim2.fromScale(0.5, 0.76)
            else
                return UDim2.fromScale(0.5, 0.83)
            end
        end),
    })
end

local function Setup_Free_Reward(LocalEntity: Types.Entity, PlayerGui: PlayerGui)
    local Panels = PlayerGui:WaitForChild("Panels") :: ScreenGui

    local FreeReward = Panels:WaitForChild("FreeReward") :: ImageLabel
    local Verify_Button = FreeReward:WaitForChild("Verify") :: ImageButton

    local Close = FreeReward:WaitForChild("Close") :: ImageButton

    Hydrate_Button(Close, function()
        Fusion_Values.Screen:set("HUD")
    end)

    Scope:Hydrate(FreeReward)({
        Visible = Scope:Computed(function(Use)
            return Use(Fusion_Values.Screen) == "FreeReward"
        end),
    })

    Hydrate_Button(Verify_Button, function()
        Network.Requests.GroupReward.Fire()
    end)
end

local function Setup_Max_Auto_Swing_Prompts(LocalEntity: Types.Entity)
    local LocalPlayer = World:get(LocalEntity, Components.Player)

    for _, Plot_Model: Model in Plots:GetChildren() do
        local AutoClickerPass = Plot_Model:WaitForChild("AutoClickerPass")

        local Image_Button = AutoClickerPass:FindFirstChild("ImageButton", true) :: ImageButton

        Hydrate_Button(Image_Button, function()
            MarketPlaceService:PromptProductPurchase(LocalPlayer, ProductIds["Max Auto Swing"])
        end)
    end
end

local function Setup_Rebirth(LocalEntity: Types.Entity, PlayerGui: PlayerGui)
    local Next_Rebirth_Data_Computed = Scope:Computed(function(Use)
        return Rebirths[Use(Fusion_Values.Rebirth) + 1]
    end)

    local Can_Rebirth_Computed = Scope:Computed(function(Use)
        local Next_Rebirth_Data = Use(Next_Rebirth_Data_Computed)
        local Cash = Use(Fusion_Values.Cash)
        local Inventory = Use(Fusion_Values.Inventory)

        if not Next_Rebirth_Data then
            return false
        end

        if Cash < Next_Rebirth_Data.Requirements.Cash then
            return false
        end

        for _, Name in Next_Rebirth_Data.Requirements.Fish do
            local HasFish = false

            for _, Item in Inventory do
                if Item.Name == Name then
                    HasFish = true
                    break
                end
            end

            if not HasFish then
                return false
            end
        end

        return true
    end)

    local Rebirth_Button_Text_Computed = Scope:Computed(function(Use)
        local Current_Rebirth = Use(Fusion_Values.Rebirth)

        if Current_Rebirth == #Rebirths then
            return "Max Rebirth"
        end

        return "Rebirth"
    end)

    local Cash_Progress_Text_Computed = Scope:Computed(function(Use)
        local Next_Rebirth_Data = Use(Next_Rebirth_Data_Computed)

        if not Next_Rebirth_Data then
            return ""
        end

        local Current_Cash = Use(Fusion_Values.Cash)
        local Cash_Required = Next_Rebirth_Data.Requirements.Cash

        return `${Abbreviate_Number(Current_Cash)}/${Abbreviate_Number(Cash_Required)}`
    end)

    local Cash_Percentage = Scope:Computed(function(Use)
        local Next_Rebirth_Data = Use(Next_Rebirth_Data_Computed)

        if not Next_Rebirth_Data then
            return 0
        end

        local Current_Cash = Use(Fusion_Values.Cash)
        local Cash_Required = Next_Rebirth_Data.Requirements.Cash

        return math.clamp(Current_Cash / Cash_Required, 0, 1)
    end)

    Scope:Observer(Can_Rebirth_Computed):onBind(function()
        if Peek(Can_Rebirth_Computed) == true then
            local Notification = World:entity()

            World:set(Notification, Components.Text, "You can rebirth!")
            World:add(Notification, Components.Tags.Notification)
        end
    end)

    -- Handle HUD rebirth
    local HUD = PlayerGui:WaitForChild("HUD") :: ScreenGui
    local Rebirth_Progress = HUD:WaitForChild("Rebirth_Progress") :: Frame
    local Rebirth_Progress_Inside = Rebirth_Progress:WaitForChild("Inside")

    Scope:Hydrate(Rebirth_Progress)({
        Visible = Scope:Computed(function(Use)
            return Use(Fusion_Values.Screen) == "HUD"
        end),
    })

    Scope:Hydrate(Rebirth_Progress_Inside)({
        Size = Scope:Tween(Scope:Computed(function(Use)
            return UDim2.fromScale(Use(Cash_Percentage), 1)
        end)),
    })

    local Rebirth_Cash_Progress = Rebirth_Progress:WaitForChild("Title") :: TextLabel

    Scope:Hydrate(Rebirth_Cash_Progress)({
        Text = Cash_Progress_Text_Computed,
    })

    local Rebirth_Button = HUD:WaitForChild("Rebirth") :: ImageButton
    local Rebirth_Button_Text = Rebirth_Button:WaitForChild("Title") :: TextLabel
    local Rebirth_UIGradient = Rebirth_Button:FindFirstChildOfClass("UIGradient")

    Scope:Hydrate(Rebirth_UIGradient)({
        Enabled = Can_Rebirth_Computed,
    })

    Scope:Hydrate(Rebirth_Button)({
        Visible = Scope:Computed(function(Use)
            return Use(Fusion_Values.Screen) == "HUD"
        end),
        ImageColor3 = Scope:Computed(function(Use)
            if Use(Can_Rebirth_Computed) then
                return Color3.fromRGB(255, 255, 255)
            else
                return Color3.fromRGB(148, 148, 148)
            end
        end),
    })

    Hydrate_Button(Rebirth_Button, function()
        Network.Requests.Rebirth.Fire()
    end)

    Scope:Hydrate(Rebirth_Button_Text)({
        Text = Rebirth_Button_Text_Computed,
    })

    -- Handle rebirth frame

    local Panels = PlayerGui:WaitForChild("Panels") :: ScreenGui
    local Rebirth = Panels:WaitForChild("Rebirth") :: ImageLabel
    local Contents = Rebirth:WaitForChild("Contents") :: Frame
    local Close = Rebirth:WaitForChild("Close") :: ImageButton

    Hydrate_Button(Close, function()
        Fusion_Values.Screen:set("HUD")
    end)

    Scope:Hydrate(Rebirth)({
        Visible = Scope:Computed(function(Use)
            return Use(Fusion_Values.Screen) == "Rebirth"
        end),
    })

    local Rebirth_Panel_Button = Rebirth:WaitForChild("Rebirth") :: ImageButton
    local Rebirth_Panel_Button_Text = Rebirth_Panel_Button:WaitForChild("Title") :: TextLabel
    local Rebirth_Panel_Button_UIGradient = Rebirth_Panel_Button:FindFirstChildOfClass("UIGradient")

    Scope:Hydrate(Rebirth_Panel_Button)({
        ImageColor3 = Scope:Computed(function(Use)
            if Use(Can_Rebirth_Computed) then
                return Color3.fromRGB(255, 255, 255)
            else
                return Color3.fromRGB(148, 148, 148)
            end
        end),
    })

    Hydrate_Button(Rebirth_Panel_Button, function()
        Network.Requests.Rebirth.Fire()
    end)

    Scope:Hydrate(Rebirth_Panel_Button_Text)({
        Text = Rebirth_Button_Text_Computed,
    })

    Scope:Hydrate(Rebirth_Panel_Button_UIGradient)({
        Enabled = Can_Rebirth_Computed,
    })

    local Rebirth_Panel_Progress = Contents:WaitForChild("Progress")
    local Rebirth_Panel_Progress_Inside = Rebirth_Panel_Progress:WaitForChild("Inside") :: Frame
    local Rebirth_Panel_Progress_Text = Rebirth_Panel_Progress:WaitForChild("Title")

    Scope:Hydrate(Rebirth_Panel_Progress_Inside)({
        Size = Scope:Tween(Scope:Computed(function(Use)
            return UDim2.fromScale(Use(Cash_Percentage), 1)
        end)),
    })

    Scope:Hydrate(Rebirth_Panel_Progress_Text)({
        Text = Cash_Progress_Text_Computed,
    })

    local Rebirth_Panel_Cash_Text = Contents.Requirements.Cash.Amount :: TextLabel

    Scope:Hydrate(Rebirth_Panel_Cash_Text)({
        Text = Scope:Computed(function(Use)
            local Next_Rebirth_Data = Use(Next_Rebirth_Data_Computed)

            if not Next_Rebirth_Data then
                return "?"
            end

            return `${Util.Format_Number_With_Commas(Next_Rebirth_Data.Requirements.Cash)}`
        end),
    })

    local Rebirth_Panel_Cash_Multiplier_Text = Contents.Rewards.Cash_Multiplier.Multiplier :: TextLabel

    Scope:Hydrate(Rebirth_Panel_Cash_Multiplier_Text)({
        Text = Scope:Computed(function(Use)
            local Next_Rebirth_Data = Use(Next_Rebirth_Data_Computed)

            if not Next_Rebirth_Data then
                return "?"
            end

            return `x{Next_Rebirth_Data.Rewards.Cash_Multiplier}`
        end),
    })

    -- Handle Viewports :D

    local Fish_Template = Contents.Requirements.Fish_Template :: ImageButton

    Scope:Hydrate(Contents.Requirements)({
        [Children] = {
            Scope:Computed(function(Use, Processor: Fusion.Scope<Fusion.Fusion>)
                local T = {}
                local Next_Rebirth_Data = Use(Next_Rebirth_Data_Computed)

                if not Next_Rebirth_Data then
                    return T
                end

                for _, Name in Next_Rebirth_Data.Requirements.Fish do
                    local ImageLabel = Fish_Template:Clone()
                    ImageLabel.Visible = true

                    local Title = ImageLabel.Title
                    Title.Text = Name

                    local Fish_Data = Fish[Name]

                    local Old_Viewport_Frame = ImageLabel:FindFirstChildOfClass("ViewportFrame")

                    if Old_Viewport_Frame then
                        Old_Viewport_Frame:Destroy()
                    end

                    local Viewport = Instance.new("ViewportFrame")
                    Viewport.Ambient = Color3.fromRGB(255, 255, 255)
                    Viewport.LightColor = Color3.fromRGB(255, 255, 255)
                    Viewport.BackgroundTransparency = 1
                    Viewport.AnchorPoint = Vector2.new(0.5, 0.5)
                    Viewport.Position = UDim2.fromScale(0.5, 0.5)
                    Viewport.Size = UDim2.fromScale(0.9, 0.9)
                    Viewport.Parent = ImageLabel

                    local WorldModel = Instance.new("WorldModel")
                    WorldModel.Parent = Viewport

                    local Camera = Instance.new("Camera")
                    Camera.CFrame = CFrame.new(Vector3.zero)
                    Camera.Parent = Viewport

                    Viewport.CurrentCamera = Camera

                    local Model = Fish_Data.Models.Normal:Clone()
                    Model.Parent = Debris_Folder
                    Model:PivotTo(Fish_Data.Viewport_CFrame)

                    local Animator = Model:FindFirstChild("Animator", true) :: Animator

                    AnimPlayer.Load(Animator)

                    AnimPlayer.PlayAnimation(Animator, {
                        Name = "Fish [Idle]",
                        Loop = true,
                    })

                    Model.Parent = WorldModel

                    table.insert(T, ImageLabel)
                end

                return T
            end),
        },
    })

    Scope:Hydrate(Contents.Rewards)({
        [Children] = {
            Scope:Computed(function(Use, Processor: Fusion.Scope<Fusion.Fusion>)
                local T = {}
                local Next_Rebirth_Data = Use(Next_Rebirth_Data_Computed)

                if not Next_Rebirth_Data then
                    return T
                end

                for _, Name in Next_Rebirth_Data.Rewards.Fish do
                    local ImageLabel = Fish_Template:Clone()
                    ImageLabel.Visible = true

                    local Title = ImageLabel.Title
                    Title.Text = Name

                    local Fish_Data = Fish[Name]

                    local Old_Viewport_Frame = ImageLabel:FindFirstChildOfClass("ViewportFrame")

                    if Old_Viewport_Frame then
                        Old_Viewport_Frame:Destroy()
                    end

                    local Viewport = Instance.new("ViewportFrame")
                    Viewport.Ambient = Color3.fromRGB(255, 255, 255)
                    Viewport.LightColor = Color3.fromRGB(255, 255, 255)
                    Viewport.BackgroundTransparency = 1
                    Viewport.AnchorPoint = Vector2.new(0.5, 0.5)
                    Viewport.Position = UDim2.fromScale(0.5, 0.5)
                    Viewport.Size = UDim2.fromScale(0.9, 0.9)
                    Viewport.Parent = ImageLabel

                    local WorldModel = Instance.new("WorldModel")
                    WorldModel.Parent = Viewport

                    local Camera = Instance.new("Camera")
                    Camera.CFrame = CFrame.new(Vector3.zero)
                    Camera.Parent = Viewport

                    Viewport.CurrentCamera = Camera

                    local Model = Fish_Data.Models.Normal:Clone()
                    Model.Parent = Debris_Folder
                    Model:PivotTo(Fish_Data.Viewport_CFrame)

                    local Animator = Model:FindFirstChild("Animator", true) :: Animator

                    AnimPlayer.Load(Animator)

                    AnimPlayer.PlayAnimation(Animator, {
                        Name = "Fish [Idle]",
                        Loop = true,
                    })

                    Model.Parent = WorldModel

                    table.insert(T, ImageLabel)
                end

                return T
            end),
        },
    })
end

return {
    name = script.Name,
    phase = Phases.InitPhases.Init,
    system = function()
        task.spawn(function()
            local LocalEntity = Registry.Get("Players", "Local")

            local LocalPlayer = World:get(LocalEntity, Components.Player) :: Player

            local PlayerGui = LocalPlayer.PlayerGui

            Setup_Hud(LocalEntity, PlayerGui)
            Setup_Items(LocalEntity, PlayerGui)
            Setup_Store(LocalEntity, PlayerGui)
            Setup_Index(LocalEntity, PlayerGui)
            Setup_Crate_Shop(LocalEntity, PlayerGui)
            Setup_Upgrade_Shop(LocalEntity, PlayerGui)
            Setup_One_Time_Offer(LocalEntity, PlayerGui)
            Setup_Notifications(LocalEntity, PlayerGui)
            Setup_Free_Reward(LocalEntity, PlayerGui)
            Setup_Max_Auto_Swing_Prompts(LocalEntity)
            Setup_Rebirth(LocalEntity, PlayerGui)

            Scope:Observer(Fusion_Values.Screen):onBind(function()
                if Peek(Fusion_Values.Screen) == "HUD" then
                    TweenFov(0.15, 70)
                    Remove_Blur()
                else
                    TweenFov(0.15, 50)
                    Add_Blur(30)
                end
            end)

            Log.Info("UI was setup")
        end)
    end,
    runConditions = {},
}
