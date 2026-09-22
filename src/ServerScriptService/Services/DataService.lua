local DataStoreService = game:GetService("DataStoreService")

local DataService = {}
DataService.__index = DataService

local DEFAULT = {
    coins = 0,
    rating = 0,
    best = 0,
    equippedBike = "BMX",
    ownedBikes = {BMX = true},
}

local function cloneDefault()
    return {
        coins = DEFAULT.coins,
        rating = DEFAULT.rating,
        best = DEFAULT.best,
        equippedBike = DEFAULT.equippedBike,
        ownedBikes = {BMX = true},
    }
end

function DataService.new()
    local self = setmetatable({}, DataService)
    self.store = DataStoreService:GetDataStore("CityRush_PlayerData_v1")
    self.ratingStore = DataStoreService:GetOrderedDataStore("CityRush_Rating_v1")
    self.profiles = {}
    return self
end

function DataService:Load(player)
    local profile = cloneDefault()
    local ok, saved = pcall(function()
        return self.store:GetAsync("u_" .. player.UserId)
    end)

    if ok and type(saved) == "table" then
        profile.coins = tonumber(saved.coins) or 0
        profile.rating = tonumber(saved.rating) or 0
        profile.best = tonumber(saved.best) or 0
        profile.equippedBike = tostring(saved.equippedBike or "BMX")
        profile.ownedBikes = type(saved.ownedBikes) == "table" and saved.ownedBikes or {BMX = true}
        profile.ownedBikes.BMX = true
    end

    self.profiles[player] = profile

    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local rating = Instance.new("IntValue")
    rating.Name = "Rating"
    rating.Value = profile.rating
    rating.Parent = leaderstats

    local best = Instance.new("IntValue")
    best.Name = "Best"
    best.Value = profile.best
    best.Parent = leaderstats

    player:SetAttribute("Coins", profile.coins)
    player:SetAttribute("Rating", profile.rating)
    player:SetAttribute("Best", profile.best)
    player:SetAttribute("EquippedBike", profile.equippedBike)
    return profile
end

function DataService:Get(player)
    return self.profiles[player]
end

function DataService:Sync(player)
    local p = self.profiles[player]
    if not p then return end
    player:SetAttribute("Coins", p.coins)
    player:SetAttribute("Rating", p.rating)
    player:SetAttribute("Best", p.best)
    player:SetAttribute("EquippedBike", p.equippedBike)

    local ls = player:FindFirstChild("leaderstats")
    if ls then
        local r = ls:FindFirstChild("Rating")
        local b = ls:FindFirstChild("Best")
        if r then r.Value = p.rating end
        if b then b.Value = p.best end
    end
end

function DataService:AddCoins(player, amount)
    local p = self.profiles[player]
    if not p then return end
    p.coins = math.max(0, p.coins + math.floor(amount))
    self:Sync(player)
end

function DataService:FinishRun(player, score, coinsRun)
    local p = self.profiles[player]
    if not p then return 0 end

    score = math.max(0, math.floor(score or 0))
    if score > p.best then
        p.best = score
    end

    local gain = math.max(1, math.floor(score / 85) + math.floor((coinsRun or 0) / 12))
    p.rating += gain
    self:Sync(player)

    task.spawn(function()
        pcall(function()
            self.ratingStore:SetAsync(tostring(player.UserId), p.rating)
        end)
    end)
    return gain
end

function DataService:BuyBike(player, bikeName, bikeInfo)
    local p = self.profiles[player]
    if not p or not bikeInfo then return false, "Ошибка профиля" end
    if p.ownedBikes[bikeName] then
        p.equippedBike = bikeName
        self:Sync(player)
        return true, "Экипировано"
    end
    if p.coins < bikeInfo.price then
        return false, "Не хватает монет"
    end
    p.coins -= bikeInfo.price
    p.ownedBikes[bikeName] = true
    p.equippedBike = bikeName
    self:Sync(player)
    return true, "Куплено"
end

function DataService:GetPublicProfile(player)
    local p = self.profiles[player] or cloneDefault()
    local owned = {}
    for k,v in pairs(p.ownedBikes) do owned[k] = v == true end
    return {
        coins = p.coins,
        rating = p.rating,
        best = p.best,
        equippedBike = p.equippedBike,
        ownedBikes = owned,
    }
end

function DataService:GetTop(limit)
    local result = {}
    local ok, pages = pcall(function()
        return self.ratingStore:GetSortedAsync(false, math.clamp(limit or 10, 1, 25))
    end)
    if not ok then return result end

    for rank, item in ipairs(pages:GetCurrentPage()) do
        local userId = tonumber(item.key)
        local name = "User " .. tostring(item.key)
        if userId then
            pcall(function()
                name = game:GetService("Players"):GetNameFromUserIdAsync(userId)
            end)
        end
        table.insert(result, {rank = rank, name = name, rating = math.floor(item.value or 0)})
    end
    return result
end

function DataService:Save(player)
    local p = self.profiles[player]
    if not p then return end
    local payload = {
        coins = p.coins,
        rating = p.rating,
        best = p.best,
        equippedBike = p.equippedBike,
        ownedBikes = p.ownedBikes,
    }
    pcall(function()
        self.store:SetAsync("u_" .. player.UserId, payload)
    end)
    pcall(function()
        self.ratingStore:SetAsync(tostring(player.UserId), p.rating)
    end)
end

function DataService:Remove(player)
    self:Save(player)
    self.profiles[player] = nil
end

return DataService
