local Jecs = require(game:GetService("ReplicatedStorage").Packages.Jecs)
local World = require("./World")

local Types = require("./Types")

local Components: {
    Player: Types.Id<Player>,
    Renderable: Types.Id<Model>,
    Cleanup: Types.Id<() -> ()>,

    Cash: Types.Id<number>,
    Tool_Level: Types.Id<number>,
    Luck_Level: Types.Id<number>,
    Index: Types.Id<{ any }>,
    Crate_Queue: Types.Id<{ [number]: string }>,

    Name: Types.Id<string>,
    Mutation: Types.Id<Types.Mutation>,

    CollisionGroup: Types.Id<string>,

    LastPlayed: Types.Id<number>,

    FriendBoost: Types.Id<number>,

    Tutorial_Step: Types.Id<number>,

    Text: Types.Id<string>,
    Duration: Types.Id<number>,

    Color: Types.Id<Color3>,

    Restock_Time: Types.Id<number>,

    Stock: Types.Id<{ [string]: number }>,

    Health: Types.Id<number>,

    Tags: {
        Networked: Types.Entity,
        Plot: Types.Entity,
        Fish: Types.Entity,
        Notification: Types.Entity,
        Crate: Types.Entity,
        Opening: Types.Entity,
    },

    Relationships: {
        Max: Types.Entity,
        Previous: Types.Entity,
        Owner: Types.Entity,
        Plot: Types.Entity,
        Offline: Types.Entity,
        Queued: Types.Entity,
        Crate: Types.Entity,
    },
} =
    {
        Player = World:component(),
        Renderable = World:component(),
        Cleanup = World:component(),

        Cash = World:component(),
        Tool_Level = World:component(),
        Luck_Level = World:component(),
        Index = World:component(),
        Crate_Queue = World:component(),

        Name = World:component(),
        Mutation = World:component(),

        CollisionGroup = World:component(),

        LastPlayed = World:component(),

        FriendBoost = World:component(),

        Tutorial_Step = World:component(),

        Text = World:component(),
        Duration = World:component(),

        Color = World:component(),

        Restock_Time = World:component(),

        Stock = World:component(),

        Health = World:component(),

        Tags = {
            Networked = World:component(),
            Plot = World:component(),
            Fish = World:component(),
            Notification = World:component(),
            Crate = World:component(),
            Opening = World:component(),
        },
        Relationships = {
            Max = World:component(),
            Previous = World:component(),
            Owner = World:component(),
            Plot = World:component(),
            Offline = World:component(),
            Queued = World:component(),
            Crate = World:component(),
        },
    }

local function Setup_Hooks()
    World:set(Components.Renderable, Jecs.OnAdd, function(Entity)
        if not World:has(Entity, Components.Tags.Networked) then
            return
        end

        local Model: Model? = World:get(Entity, Components.Renderable)

        if Model then
            Model:SetAttribute("ServerEntity", Entity)
        end
    end)

    World:set(Components.Renderable, Jecs.OnChange, function(Entity)
        if not World:has(Entity, Components.Tags.Networked) then
            return
        end

        local Model: Model? = World:get(Entity, Components.Renderable)

        if Model then
            Model:SetAttribute("ServerEntity", Entity)
        end
    end)

    World:set(Components.Tags.Networked, Jecs.OnAdd, function(Entity)
        local Model: Model? = World:get(Entity, Components.Renderable)

        if Model then
            Model:SetAttribute("ServerEntity", Entity)
        end
    end)

    World:set(Components.Tags.Networked, Jecs.OnRemove, function(Entity)
        local Model: Model? = World:get(Entity, Components.Renderable)

        if Model then
            Model:SetAttribute("ServerEntity", Entity)
        end
    end)

    World:set(Components.Cleanup, Jecs.OnRemove, function(Entity)
        local Cleanup = World:get(Entity, Components.Cleanup)

        if Cleanup then
            Cleanup()
        end
    end)
end

local function Name_Components(Cts)
    for Name, Component in Cts do
        if type(Component) == "table" then
            Name_Components(Component)
        else
            World:set(Component, Jecs.Name, Name)
        end
    end
end

Setup_Hooks()

Name_Components(Components)

return table.freeze(Components)
