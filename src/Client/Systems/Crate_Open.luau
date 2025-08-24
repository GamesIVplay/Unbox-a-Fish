local Debris = game:GetService("Debris")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Debris_Folder = workspace:WaitForChild("Debris")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local UIGradients = Assets:WaitForChild("UIGradients")

local VFX = Assets:WaitForChild("VFX") :: Folder
local Spin_VFX = VFX:WaitForChild("Spin") :: Attachment
local CrateBreak = VFX:WaitForChild("CrateBreak") :: Attachment

local Billboards = Assets:WaitForChild("Billboards")
local Fish_Overhead = Billboards:WaitForChild("Fish_Overhead") :: BillboardGui

local Sounds = Assets:WaitForChild("Sounds")

local World_Sounds = Sounds:WaitForChild("World")
local Brainrot_Cycle_Sound = World_Sounds:WaitForChild("BrainrotCycle") :: Sound
local Crate_Result_Sound = World_Sounds:WaitForChild("CrateResult") :: Sound

local Fish_Sounds = Sounds:WaitForChild("Fish")

local Components = require(ReplicatedStorage.Common.Components)
local Network = require(ReplicatedFirst.Network)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

local AnimPlayer = require(ReplicatedStorage.Common.Modules.AnimPlayer)
local Fish = require(ReplicatedStorage.Common.Modules.Fish)
local Roll_Fish = require(ReplicatedStorage.Common.Modules.Roll_Fish)
local Util = require(ReplicatedStorage.Common.Modules.Util)

-- Configurable tunables
local BASE_CYCLE_DURATION = 6 -- total cycle time (seconds)
local BASE_ROLL_INTERVAL = 0.15 -- starting time between rolls
local BASE_ROLL_INCREMENT = 0.005 -- how much interval grows each roll (slowdown)

local START_SCALE = 0.1
local END_SCALE = 1

local FISH_BOUNCE_TIME = 0.15
local FISH_Bounce_Tween_Info = TweenInfo.new(FISH_BOUNCE_TIME, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

return {
    name = script.Name,
    phase = Phases.Runservice.PreRender,
    system = function()
        local LocalEntity = Registry.Get("Players", "Local")
        local LocalPlayer = World:get(LocalEntity, Components.Player) :: Player

        for _, Data in Network.OpenTrapEffect.Iter() do
            task.spawn(function()
                local Crate_Name = Data.Crate
                local Owner = Data.Owner
                local CF = Data.CF
                local Result_Name = Data.Result.Name
                local Result_Mutation = Data.Result.Mutation

                -- Spawn base effect part
                local Part = Instance.new("Part")
                Part.Transparency = 1
                Part.CFrame = CF * CFrame.new(0, 4, 0)
                Part.CanCollide = false
                Part.Anchored = true
                Part.Parent = Debris_Folder

                local VFX = Spin_VFX:Clone()
                VFX.Parent = Part
                for _, Inst: ParticleEmitter in VFX:GetDescendants() do
                    if Inst:IsA("ParticleEmitter") then
                        local EmitCount = Inst:GetAttribute("EmitCount") or 1
                        Inst:Emit(EmitCount)
                    end
                end
                Debris:AddItem(Part, 3)

                -- Rolling
                local Elapsed = 0
                local Interval = BASE_ROLL_INTERVAL
                local RollCount = 0

                while Elapsed + Interval < BASE_CYCLE_DURATION do
                    RollCount += 1

                    -- Roll a fish
                    local Fish_Name, Fish_Mutation = Roll_Fish(Crate_Name)
                    local Fish_Data = Fish[Fish_Name]

                    local Model = Fish_Data.Models[Fish_Mutation or "Normal"]:Clone() :: Model
                    Model.Parent = Debris_Folder
                    Model:PivotTo(CF)

                    local Overhead_Attachment = Model:FindFirstChild("Overhead_Attachment", true)

                    local Overhead = Fish_Overhead:Clone()
                    local Cash = Overhead:FindFirstChild("Cash") :: TextLabel
                    local Mutation = Overhead:FindFirstChild("Mutation") :: TextLabel
                    local OfflineCash = Overhead:FindFirstChild("OfflineCash") :: TextLabel
                    local Rarity = Overhead:FindFirstChild("Rarity") :: TextLabel
                    local Title = Overhead:FindFirstChild("Title") :: TextLabel

                    Cash.Visible = false

                    if Fish_Mutation then
                        Mutation.Text = Fish_Mutation

                        local Gradient = UIGradients:FindFirstChild(Fish_Mutation):Clone()

                        Gradient.Parent = Mutation
                    else
                        Mutation.Visible = false
                    end

                    OfflineCash.Visible = false

                    Rarity.Text = Fish_Data.Rarity

                    local Gradient = UIGradients:FindFirstChild(Fish_Data.Rarity):Clone()

                    Gradient.Parent = Rarity

                    Title.Text = Fish_Name

                    Overhead.Parent = Overhead_Attachment

                    Model:ScaleTo(START_SCALE)

                    local Root = Model.PrimaryPart
                    local Cycle_Sound = Brainrot_Cycle_Sound:Clone()
                    Cycle_Sound.PlayOnRemove = true
                    Cycle_Sound.Parent = Root
                    Cycle_Sound:Destroy()

                    -- Tween setup
                    local ScaleUpTime = Interval * 0.5
                    local ScaleDownTime = Interval * 0.5
                    local TweenInfoUp = TweenInfo.new(ScaleUpTime, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
                    local TweenInfoDown =
                        TweenInfo.new(ScaleDownTime, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

                    Util.Tween_Model_Scale(START_SCALE, END_SCALE, TweenInfoUp, Model)

                    task.delay(Interval - (ScaleDownTime * 0.5), function()
                        Util.Tween_Model_Scale(Model:GetScale(), START_SCALE, TweenInfoDown, Model)
                        task.delay(ScaleDownTime, function()
                            Model:Destroy()
                        end)
                    end)

                    task.wait(Interval)

                    Elapsed += Interval
                    Interval += BASE_ROLL_INCREMENT

                    -- If this is the one-before-last roll → slow down dramatically
                    if Elapsed + Interval >= BASE_CYCLE_DURATION then
                        Interval = Interval * 2.5
                    end
                end

                -- Final guaranteed server result
                do
                    local Fish_Data = Fish[Result_Name]
                    local Model = Fish_Data.Models[Result_Mutation or "Normal"]:Clone() :: Model
                    Model:PivotTo(CF)

                    local Overhead_Attachment = Model:FindFirstChild("Overhead_Attachment", true)

                    local Overhead = Fish_Overhead:Clone()
                    local Cash = Overhead:FindFirstChild("Cash") :: TextLabel
                    local Mutation = Overhead:FindFirstChild("Mutation") :: TextLabel
                    local OfflineCash = Overhead:FindFirstChild("OfflineCash") :: TextLabel
                    local Rarity = Overhead:FindFirstChild("Rarity") :: TextLabel
                    local Title = Overhead:FindFirstChild("Title") :: TextLabel

                    Cash.Visible = false

                    if Result_Mutation then
                        Mutation.Text = Result_Mutation

                        local Gradient = UIGradients:FindFirstChild(Result_Mutation):Clone()

                        Gradient.Parent = Mutation
                    else
                        Mutation.Visible = false
                    end

                    OfflineCash.Visible = false

                    Rarity.Text = Fish_Data.Rarity

                    local Gradient = UIGradients:FindFirstChild(Fish_Data.Rarity):Clone()

                    Gradient.Parent = Rarity

                    Title.Text = Result_Name

                    Overhead.Parent = Overhead_Attachment

                    Model:ScaleTo(END_SCALE)

                    Util.Tween_Model_Scale(END_SCALE, 0.5, FISH_Bounce_Tween_Info, Model)

                    task.wait(FISH_BOUNCE_TIME)

                    Model.Parent = Debris_Folder

                    local Root = Model.PrimaryPart

                    local Result_Sound = Crate_Result_Sound:Clone()
                    Result_Sound.PlayOnRemove = true
                    Result_Sound.Parent = Root
                    Result_Sound:Destroy()

                    task.delay(1, function()
                        local Voice_Sound = Fish_Sounds:FindFirstChild(Result_Name)

                        if not Voice_Sound then
                            return
                        end

                        Voice_Sound = Voice_Sound:Clone()
                        Voice_Sound.PlayOnRemove = true
                        Voice_Sound.Parent = Root
                        Voice_Sound:Destroy()
                    end)

                    local Animator = Model:FindFirstChild("Animator", true) :: Animator
                    AnimPlayer.Load(Animator)
                    AnimPlayer.PlayAnimation(Animator, {
                        Name = "Fish [Idle]",
                        Loop = true,
                    })

                    Util.Tween_Model_Scale(0.5, END_SCALE * 1.5, FISH_Bounce_Tween_Info, Model)

                    local NewPart = Instance.new("Part")
                    NewPart.Transparency = 1
                    NewPart.CFrame = CF * CFrame.new(0, 4.5, 0)
                    NewPart.CanCollide = false
                    NewPart.Anchored = true
                    NewPart.Parent = Debris_Folder

                    local NewVFX = CrateBreak:Clone()
                    NewVFX.Parent = NewPart
                    for _, Inst: ParticleEmitter in NewVFX:GetDescendants() do
                        if Inst:IsA("ParticleEmitter") then
                            local EmitCount = Inst:GetAttribute("EmitCount") or 1
                            Inst:Emit(EmitCount)
                        end
                    end

                    Debris:AddItem(NewPart, 3)

                    -- Crate break after 6s
                    task.delay(6, function()
                        local Part = Instance.new("Part")
                        Part.Transparency = 1
                        Part.CFrame = CF * CFrame.new(0, 4, 0)
                        Part.CanCollide = false
                        Part.Anchored = true
                        Part.Parent = Debris_Folder

                        local VFX = CrateBreak:Clone()
                        VFX.Parent = Part
                        for _, Inst: ParticleEmitter in VFX:GetDescendants() do
                            if Inst:IsA("ParticleEmitter") then
                                local EmitCount = Inst:GetAttribute("EmitCount") or 1
                                Inst:Emit(EmitCount)
                            end
                        end
                        Debris:AddItem(Part, 3)

                        Model:Destroy()
                    end)
                end

                -- Notification
                if Owner == LocalPlayer.UserId then
                    local Mutation_Text = Result_Mutation and (Result_Mutation .. " ") or ""
                    local Notification = World:entity()
                    World:set(Notification, Components.Text, `You unboxed a {Mutation_Text}{Result_Name}!`)
                    World:add(Notification, Components.Tags.Notification)
                end
            end)
        end
    end,
    runConditions = {},
}
