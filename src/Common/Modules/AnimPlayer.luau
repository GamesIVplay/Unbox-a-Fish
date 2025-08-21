local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Common = ReplicatedStorage.Common
local Log = require(Common.Log)
local Types = require(Common.Types)
type AnimationInfo = Types.AnimationInfo

local AnimPlayer = {}
local Data: { [Animator]: { [string]: AnimationTrack? } } = {}

function AnimPlayer.Load(Animator: Animator)
    if Data[Animator] then
        return
    end

    Data[Animator] = {}

    for _, Inst in ReplicatedStorage:GetDescendants() do
        if not Inst:IsA("Animation") then
            continue
        end

        local AnimationName = Inst.Name
        local Success, Result = pcall(function()
            return Animator:LoadAnimation(Inst)
        end)

        if Success then
            if Data[Animator][AnimationName] then
                Log.Warn(`Duplicate animation name detected: '{AnimationName}'. This may cause unexpected behavior.`)
            end

            Data[Animator][AnimationName] = Result
        else
            warn(Result)
        end
    end

    Animator.Destroying:Once(function()
        Data[Animator] = nil
    end)
end

function AnimPlayer.PlayAnimation(Animator: Animator, Info: AnimationInfo): AnimationTrack?
    local Tracks = Data[Animator]

    if not Tracks then
        return
    end

    local Track = Tracks[Info.Name]

    if not Track then
        return
    end

    local Weight = Info.Weight or 1
    local Priority = Info.Priority or Enum.AnimationPriority.Core
    local Loop = Info.Loop or false
    local Speed = Info.Speed or 1
    local Fadetime = Info.Fadetime or 0.2
    local Stack = Info.Stack or false

    if not Stack and Track.IsPlaying then
        return Track
    end

    Track:Play(Fadetime, Weight, Speed)
    Track.Priority = Priority
    Track.Looped = Loop

    return Track
end

function AnimPlayer.StopAnimation(Animator: Animator, Info: AnimationInfo): AnimationTrack?
    local Tracks = Data[Animator]

    if not Tracks then
        return
    end

    local Track = Tracks[Info.Name]

    if not Track then
        return
    end

    local Fadetime = Info.Fadetime or 0.2

    if Track.IsPlaying then
        Track:Stop(Fadetime)
    end

    return Track
end

function AnimPlayer.StopAnims(Animator: Animator, Names: { string })
    for _, Name in Names do
        AnimPlayer.StopAnimation(Animator, { Name = Name })
    end
end

function AnimPlayer.StopAllTracks(Animator)
    local Tracks = Data[Animator]
    if not Tracks then
        return
    end

    for _, Track in Tracks do
        if not Track then
            return
        end
        Track:Stop(0.2)
    end
end

return table.freeze(AnimPlayer)
