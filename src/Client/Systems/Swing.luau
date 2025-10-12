local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Peek = Fusion.peek

local Fusion_Values = require(ReplicatedFirst.Client.Modules.Fusion_Values)

local Auto_Swing_Upgrades = require(ReplicatedStorage.Common.Modules.AutoSwing_Upgrades)

local ImpactHaptic = Instance.new("HapticEffect")
ImpactHaptic.Position = Vector3.new(0, 0, 0)
ImpactHaptic.Radius = 1
ImpactHaptic.Type = Enum.HapticEffectType.UIHover
ImpactHaptic.Parent = workspace

local Network = require(ReplicatedFirst.Network)

local Crates_Folder = workspace:WaitForChild("Crates")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local MuchachoHitbox = require(Assets.MuchachoHitbox) :: any

local Ratelimit = require(ReplicatedStorage.Packages.Ratelimit)
local Swing_Rate_Limit = Ratelimit(1, 0.5)

local AnimPlayer = require(ReplicatedStorage.Common.Modules.AnimPlayer)

local Collect = require(ReplicatedStorage.Common.Collect)
local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

local InputBegan = Collect(UserInputService.InputBegan)
local TouchTap = Collect(UserInputService.TouchTap)

local SwingParams = OverlapParams.new()
SwingParams.FilterType = Enum.RaycastFilterType.Include

local REACH = 12
local LAST_AUTO_SWING = os.time()

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = function()
        local Local_Entity = Registry.Get("Players", "Local")

        local Auto_Swing_Level = World:get(Local_Entity, Components.Auto_Swing_Level)

        local Character = World:get(Local_Entity, Components.Renderable) :: Model?

        if not Character then
            return
        end

        local RootPart = Character:FindFirstChild("HumanoidRootPart") :: Part?

        if not RootPart then
            return
        end

        local Animator = Character:FindFirstChild("Animator", true) :: Animator?

        if not Animator then
            return
        end

        local FoundTool = false

        for _, Inst in Character:GetChildren() do
            if Inst:HasTag("Hammer") then
                FoundTool = true
            end
        end

        if not FoundTool then
            Fusion_Values.Auto_Swing_Visible:set(false)
            return
        end

        if Peek(Fusion_Values.Screen) == "HUD" and Peek(Fusion_Values.Tutorial_Step) > 9 then
            Fusion_Values.Auto_Swing_Visible:set(true)
        else
            Fusion_Values.Auto_Swing_Visible:set(false)
        end

        local Swung = false
        local SwingRequest = false
        local AutoSwingRequest = false

        if Peek(Fusion_Values.Auto_Swing) then
            AutoSwingRequest = true
        end

        for Input, GPE in InputBegan do
            if AutoSwingRequest then
                continue
            end

            if GPE then
                continue
            end

            if Input.UserInputState ~= Enum.UserInputState.Begin then
                continue
            end

            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.KeyCode == Enum.KeyCode.ButtonR2 then
                SwingRequest = true
            end
        end

        for _, GPE in TouchTap do
            if AutoSwingRequest then
                continue
            end

            if GPE then
                continue
            end

            SwingRequest = true
        end

        if SwingRequest and Swing_Rate_Limit() then
            Swung = true
        end

        if
            AutoSwingRequest
            and ((os.time() - LAST_AUTO_SWING) > Auto_Swing_Upgrades[Auto_Swing_Level].Cooldown)
            and Swing_Rate_Limit()
        then
            Swung = true

            LAST_AUTO_SWING = os.time()
        end

        if Swung then
            AnimPlayer.PlayAnimation(Animator, {
                Name = "Hammer [Swing]",
                Priority = Enum.AnimationPriority.Action,
            })

            task.spawn(function()
                SwingParams.FilterDescendantsInstances = { Crates_Folder }

                local Hitbox = MuchachoHitbox.CreateHitbox()
                Hitbox.CFrame = RootPart.CFrame * CFrame.new(0, 0, -(REACH / 2))
                Hitbox.Size = Vector3.new(10, 10, REACH)
                Hitbox.OverlapParams = SwingParams
                Hitbox.DetectionMode = "HitParts"
                Hitbox.Visualizer = false

                local Hit_Crate_Entity

                Hitbox.Touched:Connect(function(Hit)
                    local Crate = Hit.Parent :: Model

                    local ServerEntity = Crate:GetAttribute("ServerEntity")

                    if ServerEntity then
                        Hit_Crate_Entity = ServerEntity
                    end
                end)

                task.wait(0.05)
                Hitbox:Start()
                task.wait(0.15)
                Hitbox:Stop()

                Network.Requests.Swing.Fire(Hit_Crate_Entity)

                if Hit_Crate_Entity then
                    task.delay(0.1, function()
                        ImpactHaptic:Play()
                    end)
                end
            end)
        end
    end,
    runConditions = {},
}
