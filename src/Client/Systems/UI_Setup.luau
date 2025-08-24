local Lighting = game:GetService("Lighting")
local MarketPlaceService = game:GetService("MarketplaceService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ActivateHaptic = Instance.new("HapticEffect")
ActivateHaptic.Position = Vector3.new(0, 0, 0)
ActivateHaptic.Radius = 1
ActivateHaptic.Type = Enum.HapticEffectType.UIHover
ActivateHaptic.Parent = workspace

local Network = require(ReplicatedFirst.Network)

local Map = workspace:WaitForChild("Map")

local Interactables = Map:WaitForChild("Interactables")

local Upgrade_Shop = Interactables:WaitForChild("Upgrade_Shop") :: Model
local Upgrade_Shop_Npc = Upgrade_Shop:WaitForChild("Npc") :: Model
local Upgrade_Shop_Teleport = Upgrade_Shop:WaitForChild("Teleport") :: Part

local Sell_Shop = Interactables:WaitForChild("Sell_Shop") :: Model
local Sell_Shop_Npc = Sell_Shop:WaitForChild("Npc") :: Model
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

local Crates = require(ReplicatedStorage.Common.Modules.Crates)
local Hammers = require(ReplicatedStorage.Common.Modules.Hammers)
local Luck_Prices = require(ReplicatedStorage.Common.Modules.Luck_Prices)

local Log = require(ReplicatedStorage.Common.Log)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

local Abbreviate_Number = require(ReplicatedStorage.Common.Modules.Abbreviate_Number)
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

local function Setup_Hud(LocalEntity: Types.Entity, PlayerGui: PlayerGui)
    local LocalPlayer = World:get(LocalEntity, Components.Player)

    local HUD = PlayerGui:WaitForChild("HUD") :: ScreenGui

    local Top = HUD:WaitForChild("Top")
    local House = Top:WaitForChild("House") :: ImageButton
    local Sell = Top:WaitForChild("Sell") :: ImageButton
    local Upgrade = Top:WaitForChild("Upgrade") :: ImageButton

    local Left = HUD:WaitForChild("Left")
    local Store = Left:WaitForChild("Store") :: ImageButton
    local Index = Left:WaitForChild("Index")

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

    Hydrate_Button(Index, function()
        if Peek(Fusion_Values.Screen) == "Index" then
            Fusion_Values.Screen:set("HUD")
        else
            Fusion_Values.Screen:set("Index")
        end
    end)
end

local function Setup_Store(LocalEntity: Types.Entity, PlayerGui: PlayerGui)
    local Panels = PlayerGui:WaitForChild("Panels") :: ScreenGui

    local Store_Panel = Panels:WaitForChild("Store")
    local Close = Store_Panel:WaitForChild("Close") :: ImageButton

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

    local Luck = Scroll:WaitForChild("Luck") :: ImageLabel
    local Luck_Buy_Button = Luck:WaitForChild("Buy") :: ImageButton
    local Luck_Price_Text = Luck_Buy_Button:WaitForChild("Price") :: TextLabel
    local Luck_Info = Luck:WaitForChild("Info") :: Frame
    local Luck_Boost = Luck_Info:WaitForChild("Boost") :: TextLabel

    local Current_Tool_Data = Scope:Computed(function(Use)
        local Current_Tool_Level = Use(Fusion_Values.Tool_Level)

        return Hammers[Current_Tool_Level]
    end)

    local Next_Tool_Data = Scope:Computed(function(Use)
        local Current_Tool_Level = Use(Fusion_Values.Tool_Level)

        return Hammers[Current_Tool_Level + 1]
    end)

    Scope:Hydrate(Tool_Title)({
        Text = Scope:Computed(function(Use)
            local Data = Use(Next_Tool_Data)
            return Data and Data.Name or "?"
        end),
    })

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
end

local function Setup_Crate_Shop(LocalEntity: Types.Entity, PlayerGui)
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
            if NoStock.Visible then
                return
            end

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
        end, 1.02, 1.05)

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

    Hydrate_Button(Purchase_Frame_Robux_Buy_Button, function() end)

    Hydrate_Button(Restock, function() end)

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

local function Setup_Sell_Shop(LocalEntity: Types.Entity, PlayerGui: PlayerGui)
    local RootPart = Sell_Shop_Npc:WaitForChild("HumanoidRootPart")

    local ProximityPrompt = Instance.new("ProximityPrompt")
    ProximityPrompt.ClickablePrompt = true
    ProximityPrompt.Enabled = true
    ProximityPrompt.Exclusivity = Enum.ProximityPromptExclusivity.OneGlobally
    ProximityPrompt.GamepadKeyCode = Enum.KeyCode.ButtonX
    ProximityPrompt.KeyboardKeyCode = Enum.KeyCode.E
    ProximityPrompt.MaxActivationDistance = 15
    ProximityPrompt.RequiresLineOfSight = false
    ProximityPrompt.HoldDuration = 0
    ProximityPrompt.ActionText = "Open Sell"
    ProximityPrompt.ObjectText = ""
    ProximityPrompt.Style = Enum.ProximityPromptStyle.Custom
    ProximityPrompt.Parent = RootPart

    ProximityPrompt.Triggered:Connect(function(TargetPlayer)
        -- To Be Done
    end)
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
            Setup_Store(LocalEntity, PlayerGui)
            Setup_Index(LocalEntity, PlayerGui)
            Setup_Crate_Shop(LocalEntity, PlayerGui)
            Setup_Upgrade_Shop(LocalEntity, PlayerGui)
            Setup_Sell_Shop(LocalEntity, PlayerGui)

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
