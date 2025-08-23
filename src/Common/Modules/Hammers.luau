local Hammer_Models = game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Hammers")

type Hammer = {
    Name: string,
    Price: number,
    Damage: number,
    Model: Model,
    Viewport_CFrame: CFrame,
    --  ProductId: string,
}

local Hammers: { Hammer } = {

    [1] = {
        Name = "Wood Hammer",
        Price = 0,
        Damage = 1,
        Model = Hammer_Models:WaitForChild("Wood Hammer"),
        Viewport_CFrame = CFrame.new(-0.3, -1.42, -3.37)
            * CFrame.fromEulerAnglesYXZ(math.rad(10), math.rad(90), math.rad(0)),
    },
    [2] = {
        Name = "Stone Hammer",
        Price = 100,
        Damage = 2,
        Model = Hammer_Models:WaitForChild("Stone Hammer"),
        Viewport_CFrame = CFrame.new(-0.3, -1.62, -4.05)
            * CFrame.fromEulerAnglesYXZ(math.rad(10), math.rad(90), math.rad(0)),
    },
    [3] = {
        Name = "Bone Hammer",
        Price = 1000,
        Damage = 4,
        Model = Hammer_Models:WaitForChild("Bone Hammer"),
        Viewport_CFrame = CFrame.new(-0.3, -1.62, -4.05)
            * CFrame.fromEulerAnglesYXZ(math.rad(10), math.rad(90), math.rad(0)),
    },
    [4] = {
        Name = "Barrel Hammer",
        Price = 10000,
        Damage = 7,
        Model = Hammer_Models:WaitForChild("Barrel Hammer"),
        Viewport_CFrame = CFrame.new(-0.3, -1.62, -4.05)
            * CFrame.fromEulerAnglesYXZ(math.rad(10), math.rad(90), math.rad(0)),
    },
    [5] = {
        Name = "Coral Hammer",
        Price = 50000,
        Damage = 10,
        Model = Hammer_Models:WaitForChild("Coral Hammer"),
        Viewport_CFrame = CFrame.new(-0.3, -1.62, -4.05)
            * CFrame.fromEulerAnglesYXZ(math.rad(10), math.rad(90), math.rad(0)),
    },
    [6] = {
        Name = "Crab Hammer",
        Price = 200000,
        Damage = 14,
        Model = Hammer_Models:WaitForChild("Crab Hammer"),
        Viewport_CFrame = CFrame.new(-0.3, -1.89, -4.72)
            * CFrame.fromEulerAnglesYXZ(math.rad(10), math.rad(90), math.rad(0)),
    },
    [7] = {
        Name = "Spikey Hammer",
        Price = 800000,
        Damage = 18,
        Model = Hammer_Models:WaitForChild("Spikey Hammer"),
        Viewport_CFrame = CFrame.new(-0.3, -1.55, -4.05)
            * CFrame.fromEulerAnglesYXZ(math.rad(10), math.rad(90), math.rad(0)),
    },
    [8] = {
        Name = "Anchor Hammer",
        Price = 3000000,
        Damage = 23,
        Model = Hammer_Models:WaitForChild("Anchor Hammer"),
        Viewport_CFrame = CFrame.new(-0.3, -1.69, -4.05)
            * CFrame.fromEulerAnglesYXZ(math.rad(10), math.rad(90), math.rad(0)),
    },
    [9] = {
        Name = "Lightning Hammer",
        Price = 12000000,
        Damage = 29,
        Model = Hammer_Models:WaitForChild("Lightning Hammer"),
        Viewport_CFrame = CFrame.new(-0.3, -1.76, -4.05)
            * CFrame.fromEulerAnglesYXZ(math.rad(10), math.rad(90), math.rad(0)),
    },
    [10] = {
        Name = "Jelly Hammer",
        Price = 50000000,
        Damage = 35,
        Model = Hammer_Models:WaitForChild("Jelly Hammer"),
        Viewport_CFrame = CFrame.new(-0.3, -1.49, -3.37)
            * CFrame.fromEulerAnglesYXZ(math.rad(10), math.rad(90), math.rad(0)),
    },
    [11] = {
        Name = "Abyssal Hammer",
        Price = 200000000,
        Damage = 42,
        Model = Hammer_Models:WaitForChild("Abyssal Hammer"),
        Viewport_CFrame = CFrame.new(-0.27, -2.23, -4.72)
            * CFrame.fromEulerAnglesYXZ(math.rad(-80), math.rad(90), math.rad(2)),
    },
    [12] = {
        Name = "Kraken Hammer",
        Price = 1000000000,
        Damage = 49,
        Model = Hammer_Models:WaitForChild("Kraken Hammer"),
        Viewport_CFrame = CFrame.new(-0.27, -1.89, -6.07)
            * CFrame.fromEulerAnglesYXZ(math.rad(-80), math.rad(90), math.rad(2)),
    },
}

return table.freeze(Hammers)
