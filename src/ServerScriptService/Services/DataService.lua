local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)

local DataService = {}
DataService.__index = DataService

local function cloneDefault()
    return {
        coins = 0,
        rating = 0,
        best = 0,
        equippedBike = "BMX",
        ownedBikes = {BMX = true},
        bikeLevels = {BMX = 1},
    }
end

function DataService.new()
    local self=setmetatable({},DataService)
    self.store=DataStoreService:GetDataStore("CityRush_PlayerData_v2")
    self.legacyStore=DataStoreService:GetDataStore("CityRush_PlayerData_v1")
    self.ratingStore=DataStoreService:GetOrderedDataStore("CityRush_Rating_v1")
    self.profiles={}
    return self
end

function DataService:Load(player)
    local profile=cloneDefault()
    local ok,saved=pcall(function()
        return self.store:GetAsync("u_"..player.UserId)
    end)

    if ok and saved==nil then
        pcall(function()
            saved=self.legacyStore:GetAsync("u_"..player.UserId)
        end)
    end

    if type(saved)=="table" then
        profile.coins=tonumber(saved.coins) or 0
        profile.rating=tonumber(saved.rating) or 0
        profile.best=tonumber(saved.best) or 0
        profile.equippedBike=Config.BIKES[saved.equippedBike] and saved.equippedBike or "BMX"
        profile.ownedBikes=type(saved.ownedBikes)=="table" and saved.ownedBikes or {BMX=true}
        profile.bikeLevels=type(saved.bikeLevels)=="table" and saved.bikeLevels or {BMX=1}
    end

    profile.ownedBikes.BMX=true
    profile.bikeLevels.BMX=math.clamp(tonumber(profile.bikeLevels.BMX) or 1,1,Config.BIKE_MAX_LEVEL)

    for bikeName,owned in pairs(profile.ownedBikes) do
        if owned and Config.BIKES[bikeName] then
            profile.bikeLevels[bikeName]=math.clamp(tonumber(profile.bikeLevels[bikeName]) or 1,1,Config.BIKE_MAX_LEVEL)
        end
    end

    self.profiles[player]=profile

    local old=player:FindFirstChild("leaderstats")
    if old then old:Destroy() end
    local leaderstats=Instance.new("Folder")
    leaderstats.Name="leaderstats"
    leaderstats.Parent=player

    local rating=Instance.new("IntValue")
    rating.Name="Rating"
    rating.Value=profile.rating
    rating.Parent=leaderstats

    local best=Instance.new("IntValue")
    best.Name="Best"
    best.Value=profile.best
    best.Parent=leaderstats

    self:Sync(player)
    return profile
end

function DataService:Get(player)
    return self.profiles[player]
end

function DataService:Sync(player)
    local p=self.profiles[player]
    if not p then return end
    player:SetAttribute("Coins",p.coins)
    player:SetAttribute("Rating",p.rating)
    player:SetAttribute("Best",p.best)
    player:SetAttribute("EquippedBike",p.equippedBike)
    player:SetAttribute("BikeLevel",p.bikeLevels[p.equippedBike] or 1)

    local ls=player:FindFirstChild("leaderstats")
    if ls then
        if ls:FindFirstChild("Rating") then ls.Rating.Value=p.rating end
        if ls:FindFirstChild("Best") then ls.Best.Value=p.best end
    end
end

function DataService:AddCoins(player,amount)
    local p=self.profiles[player]
    if not p then return end
    p.coins=math.max(0,p.coins+math.floor(amount))
    self:Sync(player)
end

function DataService:FinishRun(player,score,coinsRun)
    local p=self.profiles[player]
    if not p then return 0 end
    score=math.max(0,math.floor(score or 0))
    p.best=math.max(p.best,score)
    local gain=math.max(1,math.floor(score/Config.RATING_DIVISOR)+math.floor((coinsRun or 0)/12))
    p.rating+=gain
    self:Sync(player)
    task.spawn(function()
        pcall(function()
            self.ratingStore:SetAsync(tostring(player.UserId),p.rating)
        end)
    end)
    return gain
end

function DataService:BuyOrEquipBike(player,bikeName)
    local p=self.profiles[player]
    local info=Config.BIKES[bikeName]
    if not p or not info then return false,"Ошибка профиля" end

    if p.ownedBikes[bikeName] then
        p.equippedBike=bikeName
        self:Sync(player)
        return true,"Велик выбран"
    end

    if p.coins<info.price then
        return false,"Не хватает монет"
    end

    p.coins-=info.price
    p.ownedBikes[bikeName]=true
    p.bikeLevels[bikeName]=1
    p.equippedBike=bikeName
    self:Sync(player)
    return true,"Велик куплен"
end

function DataService:UpgradeBike(player,bikeName)
    local p=self.profiles[player]
    local info=Config.BIKES[bikeName]
    if not p or not info then return false,"Ошибка профиля" end
    if not p.ownedBikes[bikeName] then return false,"Сначала купи велик" end

    local level=math.clamp(tonumber(p.bikeLevels[bikeName]) or 1,1,Config.BIKE_MAX_LEVEL)
    if level>=Config.BIKE_MAX_LEVEL then return false,"Максимальный уровень" end

    local cost=Config.GetUpgradeCost(bikeName,level)
    if p.coins<cost then return false,"Не хватает монет: "..cost end

    p.coins-=cost
    p.bikeLevels[bikeName]=level+1
    self:Sync(player)
    return true,"Уровень "..(level+1)
end

function DataService:GetPublicProfile(player)
    local p=self.profiles[player] or cloneDefault()
    local owned={}
    local levels={}
    for k,v in pairs(p.ownedBikes) do owned[k]=v==true end
    for k,v in pairs(p.bikeLevels) do levels[k]=v end
    return {
        coins=p.coins,
        rating=p.rating,
        best=p.best,
        equippedBike=p.equippedBike,
        ownedBikes=owned,
        bikeLevels=levels,
    }
end

function DataService:GetTop(limit)
    local result={}
    local ok,pages=pcall(function()
        return self.ratingStore:GetSortedAsync(false,math.clamp(limit or 10,1,25))
    end)
    if not ok then return result end

    for rank,item in ipairs(pages:GetCurrentPage()) do
        local userId=tonumber(item.key)
        local name="User "..tostring(item.key)
        if userId then
            pcall(function()
                name=game:GetService("Players"):GetNameFromUserIdAsync(userId)
            end)
        end
        table.insert(result,{rank=rank,name=name,rating=math.floor(item.value or 0)})
    end
    return result
end

function DataService:Save(player)
    local p=self.profiles[player]
    if not p then return end
    local payload={
        coins=p.coins,
        rating=p.rating,
        best=p.best,
        equippedBike=p.equippedBike,
        ownedBikes=p.ownedBikes,
        bikeLevels=p.bikeLevels,
    }
    pcall(function() self.store:SetAsync("u_"..player.UserId,payload) end)
    pcall(function() self.ratingStore:SetAsync(tostring(player.UserId),p.rating) end)
end

function DataService:Remove(player)
    self:Save(player)
    self.profiles[player]=nil
end

return DataService
