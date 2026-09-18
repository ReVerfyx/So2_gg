local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)

local DataService = {}
DataService.__index = DataService

function DataService.new()
    local self = setmetatable({}, DataService)
    self.store = DataStoreService:GetDataStore("CodeRot_PlayerData_v2_campaign")
    self.cache = {}
    return self
end

local function copyDefault()
    return {
        bits = 0,
        selectedClass = "Archivist",
        ownedClasses = {Archivist = true},
        memories = {},
        campaignChapter = 1,
        completedCampaigns = 0,
    }
end

function DataService:Load(player)
    local data = copyDefault()
    local ok, saved = pcall(function()
        return self.store:GetAsync("u_" .. player.UserId)
    end)
    if ok and type(saved) == "table" then
        data.bits = tonumber(saved.bits) or 0
        data.selectedClass = saved.selectedClass or "Archivist"
        if type(saved.ownedClasses) == "table" then data.ownedClasses = saved.ownedClasses end
        if type(saved.memories) == "table" then data.memories = saved.memories end
        data.campaignChapter = math.clamp(tonumber(saved.campaignChapter) or 1, 1, #Config.CHAPTERS)
        data.completedCampaigns = math.max(0, tonumber(saved.completedCampaigns) or 0)
        data.ownedClasses.Archivist = true
    end
    self.cache[player] = data
    player:SetAttribute("Bits", data.bits)
    player:SetAttribute("SelectedClass", data.selectedClass)
    player:SetAttribute("CampaignChapter", data.campaignChapter)
    return data
end

function DataService:Get(player)
    return self.cache[player]
end

function DataService:AddBits(player, amount)
    local data = self.cache[player]
    if not data then return end
    data.bits = math.max(0, math.floor((data.bits or 0) + amount))
    player:SetAttribute("Bits", data.bits)
end

function DataService:OwnsClass(player, className)
    local data = self.cache[player]
    return data and data.ownedClasses and data.ownedClasses[className] == true
end

function DataService:BuyClass(player, className, price)
    local data = self.cache[player]
    if not data then return false, "Данные недоступны" end
    if data.ownedClasses[className] then return true, "Уже куплено" end
    if data.bits < price then return false, "Недостаточно Bits" end
    data.bits -= price
    data.ownedClasses[className] = true
    player:SetAttribute("Bits", data.bits)
    return true, "Класс куплен"
end

function DataService:SelectClass(player, className)
    local data = self.cache[player]
    if not data or not data.ownedClasses[className] then return false end
    data.selectedClass = className
    player:SetAttribute("SelectedClass", className)
    return true
end

function DataService:MarkMemory(player, index)
    local data = self.cache[player]
    if not data then return false end
    local key = tostring(index)
    if data.memories[key] then return false end
    data.memories[key] = true
    return true
end

function DataService:HasMemory(player, index)
    local data = self.cache[player]
    return data and data.memories[tostring(index)] == true
end

function DataService:MemoryCount(player)
    local data = self.cache[player]
    if not data then return 0 end
    local n = 0
    for i = 1, Config.MEMORY_COUNT do
        if data.memories[tostring(i)] then n += 1 end
    end
    return n
end

function DataService:SetCampaignChapter(player, chapterId)
    local data = self.cache[player]
    if not data then return end
    data.campaignChapter = math.clamp(chapterId, 1, #Config.CHAPTERS)
    player:SetAttribute("CampaignChapter", data.campaignChapter)
end

function DataService:CompleteChapter(player, chapterId)
    local data = self.cache[player]
    if not data then return end
    if chapterId < #Config.CHAPTERS then
        data.campaignChapter = math.max(data.campaignChapter or 1, chapterId + 1)
        player:SetAttribute("CampaignChapter", data.campaignChapter)
    else
        data.completedCampaigns = (data.completedCampaigns or 0) + 1
        data.campaignChapter = 1
        player:SetAttribute("CampaignChapter", 1)
    end
    self:Save(player)
end

function DataService:GetCampaignChapter(player)
    local data = self.cache[player]
    return data and data.campaignChapter or 1
end

function DataService:Save(player)
    local data = self.cache[player]
    if not data then return end
    local payload = {
        bits = data.bits,
        selectedClass = data.selectedClass,
        ownedClasses = data.ownedClasses,
        memories = data.memories,
        campaignChapter = data.campaignChapter,
        completedCampaigns = data.completedCampaigns,
    }
    pcall(function()
        self.store:SetAsync("u_" .. player.UserId, payload)
    end)
end

function DataService:Remove(player)
    self:Save(player)
    self.cache[player] = nil
end

return DataService
