local Jecs = require(game:GetService("ReplicatedStorage").Packages.Jecs)

export type World = typeof(Jecs.world())
export type Entity = Jecs.Entity
export type Id<T> = Jecs.Id<T>

export type Mutation = "Gold" | "Diamond" | "Huge" | "Rainbow"

export type SerializedFish = {
    Name: string,
    Mutation: Mutation?,
    Cash: number,
    OfflineCash: number,
}

export type Rarity = "Common" | "Rare" | "Epic" | "Legendary" | "Mythic" | "Secret"

export type AnimationInfo = {
    Name: string,
    Weight: number?,
    Priority: Enum.AnimationPriority?,
    Loop: boolean?,
    Speed: number?,
    Fadetime: number?,
    Stack: boolean?,
}

return {}
