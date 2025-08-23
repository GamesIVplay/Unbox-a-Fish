local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

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

local REACH = 10

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = function()
        local Local_Entity = Registry.Get("Players", "Local")
        local Local_Player = World:get(Local_Entity, Components.Player) :: Player

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
            return
        end

        local Swung = false

        for Input, GPE in InputBegan do
            if GPE then
                continue
            end

            if Input.UserInputState ~= Enum.UserInputState.Begin then
                continue
            end

            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.KeyCode == Enum.KeyCode.ButtonR2 then
                Swung = true
            end
        end

        for _, GPE in TouchTap do
            if GPE then
                continue
            end

            Swung = true
        end

        if Swung and Swing_Rate_Limit() then
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
                Hitbox.Visualizer = _G.IN_DEV

                local HitCrate

                Hitbox.Touched:Connect(function(Hit)
                    local Crate = Hit.Parent :: Model

                    if Crate:GetAttribute("Owner") ~= Local_Player.UserId then
                        return
                    end

                    HitCrate = Crate
                end)

                task.wait(0.15)
                Hitbox:Start()
                task.wait(0.15)
                Hitbox:Stop()
            end)
        end
    end,
    runConditions = {},
}
