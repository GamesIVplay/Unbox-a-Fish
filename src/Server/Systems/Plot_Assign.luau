local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ServerScriptService.Network)

local Jecs = require(ReplicatedStorage.Packages.Jecs)
local Pair = Jecs.pair

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

local Util = require(ReplicatedStorage.Common.Modules.Util)

local Players_Without_Plot = World:query(Components.Player, Components.Renderable)
    :without(Pair(Components.Relationships.Plot, Jecs.Wildcard))
    :cached()

local Plots_Without_Owner = World:query(Components.Renderable)
    :with(Components.Tags.Plot)
    :without(Pair(Components.Relationships.Owner, Jecs.Wildcard))
    :cached()

return {
    name = script.Name,
    phase = Phases.Runservice.PreUpdate,
    system = function()
        for PlayerEntity, Player: Player, Character: Model in Players_Without_Plot:iter() do
            for PlotNumber = 1, 8 do
                local PlotEntity = Registry.Get("Plots", PlotNumber)

                local Owner = World:target(PlotEntity, Components.Relationships.Owner)

                if Owner then
                    continue
                end

                local PlotModel = World:get(PlotEntity, Components.Renderable) :: Model
                local SpawnPart = PlotModel:FindFirstChild("Spawn") :: Part
                local Avatar = PlotModel:FindFirstChild("Avatar", true) :: ImageLabel
                local Title = PlotModel:FindFirstChild("Title", true) :: TextLabel

                task.spawn(function()
                    local PlayerInfo = Util.Get_Player_Info(Player.UserId)
                    Avatar.Image = PlayerInfo.Image
                    Title.Text = PlayerInfo.Name .. "'s plot"

                    Avatar.Visible = true
                    Title.Visible = true
                end)

                Character:PivotTo(SpawnPart.CFrame)

                World:add(PlayerEntity, Pair(Components.Relationships.Plot, PlotEntity))

                World:add(PlotEntity, Pair(Components.Relationships.Owner, PlayerEntity))

                Network.PlayerChanges.PlotChosen.Fire(Player, PlotModel)
                break
            end
        end

        for _, PlotModel: Model in Plots_Without_Owner:iter() do
            local Avatar = PlotModel:FindFirstChild("Avatar", true) :: ImageLabel
            local Title = PlotModel:FindFirstChild("Title", true) :: TextLabel

            Avatar.Image = ""
            Title.Text = ""

            Avatar.Visible = false
            Title.Visible = false
        end
    end,
    runConditions = {},
}
