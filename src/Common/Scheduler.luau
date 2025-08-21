local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Planck = require(ReplicatedStorage.Packages.Planck)
local Scheduler = Planck.Scheduler

local PlanckRunService = require(ReplicatedStorage.Packages.PlanckRunService)

local PlanckJabby = require(ReplicatedStorage.Packages.PlanckJabby)

local World = require("./World")

return Scheduler.new(World):addPlugin(PlanckRunService.Plugin.new()):addPlugin(PlanckJabby.new())
