local DataStoreService = game:GetService("DataStoreService")
local Debris = game:GetService("Debris")
local MarketPlaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Handle_Gamepasses = require(ServerScriptService.Server.Modules.Handle_Gamepasses)

local Network = require(ServerScriptService.Network)

local Assets = ReplicatedStorage:WaitForChild("Assets")

local VFX = Assets:WaitForChild("VFX") :: Folder
local Robux_Buy_VFX = VFX:WaitForChild("RobuxBuy") :: Attachment

local Highlights = Assets:WaitForChild("Highlights")
local Robux_Purchase_Highlight = Highlights:WaitForChild("RobuxPurchase") :: Highlight

local Sounds = Assets:WaitForChild("Sounds")

local World_Sounds = Sounds:WaitForChild("World")
local Robux_Purchase_Sound = World_Sounds:WaitForChild("RobuxPurchase") :: Sound

local PurchaseHistoryStore = DataStoreService:GetDataStore("PurchaseHistory")

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

local Log = require(ReplicatedStorage.Common.Log)

local ProductIds = require(ReplicatedStorage.Common.Modules.ProductIds)

local Auto_Swing_Upgrades = require(ReplicatedStorage.Common.Modules.AutoSwing_Upgrades)
local Colors = require(ReplicatedStorage.Common.Modules.Colors)
local Crates = require(ReplicatedStorage.Common.Modules.Crates)
local Hammers = require(ReplicatedStorage.Common.Modules.Hammers)

local Add_Fish = require(ServerScriptService.Server.Modules.Add_Fish)

local Types = require(ReplicatedStorage.Common.Types)

local Grant_Purchase_By_Product_Id = {
    [ProductIds["Max Auto Swing"]] = function(_, Player_Entity: Types.Entity)
        World:set(Player_Entity, Components.Auto_Swing_Level, #Auto_Swing_Upgrades)

        return true
    end,
    [ProductIds["Restock"]] = function(_, Player_Entity: Types.Entity)
        World:set(Player_Entity, Components.Restock_Time, os.time())

        return true
    end,
    [ProductIds["Break Crate"]] = function(_, Player_Entity: Types.Entity)
        local Plot_Entity = World:target(Player_Entity, Components.Relationships.Plot)

        if not Plot_Entity then
            return true
        end

        local Crate_Entity = World:target(Plot_Entity, Components.Relationships.Crate)

        if not Crate_Entity then
            return true
        end

        World:set(Crate_Entity, Components.Health, 0)

        return true
    end,
    [ProductIds["One Time Offer"]] = function(_, Player_Entity: Types.Entity)
        local Crate_Queue = World:get(Player_Entity, Components.Crate_Queue)

        table.insert(Crate_Queue, "Abyssal Crate")

        local Inventory = World:get(Player_Entity, Components.Inventory)

        Add_Fish(Inventory, "Girafa Celeste")

        Add_Fish(Inventory, "Burbaloni Luliloli")

        World:add(Player_Entity, Components.Tags.BoughtOneTimeOffer)

        return true
    end,
    [ProductIds["Starter Pack"]] = function(_, Player_Entity: Types.Entity)
        local Current_Tool_Level = World:get(Player_Entity, Components.Tool_Level)

        if Current_Tool_Level < 4 then
            World:set(Player_Entity, Components.Tool_Level, 4)
        end

        local Inventory = World:get(Player_Entity, Components.Inventory)

        Add_Fish(Inventory, "Chimpanzini Bananini")

        World:set(Player_Entity, Components.Double_Luck_Time_Remaining, 60 * 10)
        World:set(Player_Entity, Components.Double_Mutation_Time_Remaining, 60 * 10)

        return true
    end,
    [ProductIds["Ultimate Pack"]] = function(_, Player_Entity: Types.Entity)
        local Current_Tool_Level = World:get(Player_Entity, Components.Tool_Level)

        if Current_Tool_Level < 9 then
            World:set(Player_Entity, Components.Tool_Level, 9)
        end

        local Inventory = World:get(Player_Entity, Components.Inventory)

        Add_Fish(Inventory, "Rhino toasterino")

        World:set(Player_Entity, Components.Double_Luck_Time_Remaining, 60 * 15)
        World:set(Player_Entity, Components.Double_Mutation_Time_Remaining, 60 * 15)

        return true
    end,
    [ProductIds["x2 Luck 10 Min"]] = function(_, Player_Entity: Types.Entity)
        World:set(Player_Entity, Components.Double_Luck_Time_Remaining, 60 * 10)

        return true
    end,
    [ProductIds["x2 Mutation 10 Min"]] = function(_, Player_Entity: Types.Entity)
        World:set(Player_Entity, Components.Double_Mutation_Time_Remaining, 60 * 10)

        return true
    end,

    [ProductIds["15 Min Server Luck x2"]] = function(_, Player_Entity: Types.Entity)
        local Player = World:get(Player_Entity, Components.Player)

        World:set(Components.Server_Double_Luck_End_Time, Components.Server_Double_Luck_End_Time, os.time() + (60 * 15))

        Network.Notification.FireAll({
            Text = `{Player.Name} activated x2 Server Luck!`,
        })

        return true
    end,
    [ProductIds["Legendary Offer"]] = function(_, Player_Entity: Types.Entity)
        local Inventory = World:get(Player_Entity, Components.Inventory)

        Add_Fish(Inventory, "Bombardiro Crocodilo")

        World:set(Player_Entity, Components.Inventory, Inventory)

        return true
    end,
    [ProductIds["Mythic Offer"]] = function(_, Player_Entity: Types.Entity)
        local Inventory = World:get(Player_Entity, Components.Inventory)

        Add_Fish(Inventory, "Tralalero Tralala")

        World:set(Player_Entity, Components.Inventory, Inventory)

        return true
    end,
}

local function ProcessReceipt(ReceiptInfo)
    local Success, Result = pcall(
        PurchaseHistoryStore.UpdateAsync,
        PurchaseHistoryStore,
        ReceiptInfo.PurchaseId,
        function(IsPurchased)
            if IsPurchased then
                return true
            end

            local Player = Players:GetPlayerByUserId(ReceiptInfo.PlayerId)

            if not Player then
                return nil
            end

            local PlayerEntity = Registry.Get("Players", Player)

            if not PlayerEntity then
                return nil
            end

            local Character = World:get(PlayerEntity, Components.Renderable) :: Model?

            if not Character then
                return nil
            end

            local RootPart = Character:FindFirstChild("HumanoidRootPart")

            if not RootPart then
                return nil
            end

            local GrantPurchaseHandler = Grant_Purchase_By_Product_Id[ReceiptInfo.ProductId]

            if not GrantPurchaseHandler then
                warn(`No purchase handler defined for product ID '{ReceiptInfo.ProductId}'`)

                return nil
            end

            local HandlerSucceeded, HandlerResult = pcall(GrantPurchaseHandler, ReceiptInfo, PlayerEntity)

            if not HandlerSucceeded then
                local errorMessage = HandlerResult

                warn(

                    `Grant purchase handler errored while processing purchase from '{Player.Name}' of product ID '{ReceiptInfo.ProductId}': {errorMessage}`
                )

                return nil
            end

            local DidHandlerGrantPurchase = HandlerResult == true

            if not DidHandlerGrantPurchase then
                return nil
            end

            local Highlight = Robux_Purchase_Highlight:Clone()
            Highlight.Parent = Character

            Debris:AddItem(Highlight, 0.15)

            local Sound = Robux_Purchase_Sound:Clone()
            Sound.PlayOnRemove = true
            Sound.Parent = RootPart

            Sound:Destroy()

            local VFX = Robux_Buy_VFX:Clone()
            VFX.Parent = RootPart

            for _, Inst: ParticleEmitter in VFX:GetDescendants() do
                if Inst:IsA("ParticleEmitter") then
                    local EmitCount = Inst:GetAttribute("EmitCount") or 1

                    Inst:Emit(EmitCount)
                end
            end

            Debris:AddItem(VFX, 5)

            Network.Notification.Fire(
                Player,
                { Text = "Thanks for your purchase!", Color = Color3.new(0.541176, 1, 0.439216) }
            )

            Network.Confetti.Fire(Player)

            return true
        end
    )

    if not Success then
        Log.Warn(`Failed to process receipt due to data store error: {Result}`)

        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    local DidGrantPurchase = Result == true

    return if DidGrantPurchase

        then Enum.ProductPurchaseDecision.PurchaseGranted
        else Enum.ProductPurchaseDecision.NotProcessedYet
end

return {
    name = script.Name,
    phase = Phases.InitPhases.PreInit,
    system = function()
        for Index, Hammer_Data in Hammers do
            Grant_Purchase_By_Product_Id[Hammer_Data.ProductId] = function(_, Player_Entity: Types.Entity)
                World:set(Player_Entity, Components.Tool_Level, Index)

                return true
            end
        end

        for Crate_Name, Crate_Data in Crates do
            Grant_Purchase_By_Product_Id[Crate_Data.ProductId] = function(_, Player_Entity: Types.Entity)
                local Player = World:get(Player_Entity, Components.Player)
                local Crate_Queue = World:get(Player_Entity, Components.Crate_Queue)

                table.insert(Crate_Queue, Crate_Name)

                World:set(Player_Entity, Components.Crate_Queue, Crate_Queue)

                Network.Notification.Fire(Player, {
                    Text = `{Crate_Name} added to queue`,
                })
                return true
            end
        end

        MarketPlaceService.ProcessReceipt = ProcessReceipt

        MarketPlaceService.PromptGamePassPurchaseFinished:Connect(function(Player, _, IsPurchased)
            local PlayerEntity = Registry.Get("Players", Player)

            if not PlayerEntity then
                return
            end

            Handle_Gamepasses(PlayerEntity)

            if not IsPurchased then
                return
            end

            local Character = PlayerEntity and World:get(PlayerEntity, Components.Renderable) :: Model?

            local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")

            if RootPart then
                local Highlight = Robux_Purchase_Highlight:Clone()
                Highlight.Parent = Character

                Debris:AddItem(Highlight, 0.15)

                local Sound = Robux_Purchase_Sound:Clone()
                Sound.PlayOnRemove = true
                Sound.Parent = RootPart

                Sound:Destroy()

                local VFX = Robux_Buy_VFX:Clone()
                VFX.Parent = RootPart

                for _, Inst: ParticleEmitter in VFX:GetDescendants() do
                    if Inst:IsA("ParticleEmitter") then
                        local EmitCount = Inst:GetAttribute("EmitCount") or 1

                        Inst:Emit(EmitCount)
                    end
                end

                Debris:AddItem(VFX, 5)

                Network.Notification.Fire(
                    Player,
                    { Text = "Thanks for your purchase!", Color = Color3.new(0.541176, 1, 0.439216) }
                )

                Network.Confetti.Fire(Player)
            end
        end)
    end,
    runConditions = {},
}
