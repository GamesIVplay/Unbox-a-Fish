local Lighting = game:GetService("Lighting")
local MarketPlaceService = game:GetService("MarketplaceService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Map = workspace:WaitForChild("Map")

local Interactables = Map:WaitForChild("Interactables")

local Upgrade_Shop = Interactables:WaitForChild("Upgrade_Shop") :: Model
local Upgrade_Shop_Teleport = Upgrade_Shop:WaitForChild("Teleport") :: Part

local Sell_Shop = Interactables:WaitForChild("Sell_Shop") :: Model
local Sell_Shop_Teleport = Sell_Shop:WaitForChild("Teleport") :: Part

local Assets = ReplicatedStorage:WaitForChild("Assets")

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

local Log = require(ReplicatedStorage.Common.Log)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

local Abbreviate_Number = require(ReplicatedStorage.Common.Modules.Abbreviate_Number)
local Util = require(ReplicatedStorage.Common.Modules.Util)

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

local function Hydrate_Button(GuiButton: GuiButton, OnActivate: () -> ())
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
            SizeMultiplierSpring:addVelocity(ACTIVATE_VELOCITY)

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
    local House = HUD:WaitForChild("House") :: ImageButton
    local Sell = HUD:WaitForChild("Sell") :: ImageButton
    local Upgrade = HUD:WaitForChild("Upgrade") :: ImageButton

    Hydrate_Button(House, function()
        if LocalPlayer:HasTag("IsStealing") then
            return
        end

        local Character: Model? = World:get(LocalEntity, Components.Renderable)

        if not Character then
            return
        end
    end)

    Hydrate_Button(Sell, function()
        local Character: Model? = World:get(LocalEntity, Components.Renderable)

        if not Character then
            return
        end

        Character:PivotTo(Sell_Shop_Teleport.CFrame)
    end)

    Hydrate_Button(Tools, function()
        local Character: Model? = World:get(LocalEntity, Components.Renderable)

        if not Character then
            return
        end

        Character:PivotTo(Tool_Shop_Spawn.CFrame)
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
            local Percent = math.round((Use(Fusion_Values.FriendBoost) - 1) * 100)
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
