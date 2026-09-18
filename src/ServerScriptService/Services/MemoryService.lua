local BadgeService = game:GetService("BadgeService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)

local MemoryService = {}
MemoryService.__index = MemoryService

function MemoryService.new(remotes, dataService)
    local self = setmetatable({}, MemoryService)
    self.remotes = remotes
    self.data = dataService
    self.sessionFound = {}
    return self
end

function MemoryService:ResetRound()
    -- Memories are campaign-wide now. We intentionally do not erase sequence progress here.
end

function MemoryService:GiveRose(player)
    player:SetAttribute("HasRose", true)
    player:SetAttribute("RoseUsedThisRound", false)
    local backpack = player:FindFirstChildOfClass("Backpack") or player:WaitForChild("Backpack", 3)
    if backpack and not backpack:FindFirstChild("Роза памяти") then
        local rose = Instance.new("Tool")
        rose.Name = "Роза памяти"
        rose.ToolTip = "Одно возрождение в текущей главе"
        rose.RequiresHandle = false
        rose.CanBeDropped = false
        rose.Parent = backpack
    end
end

function MemoryService:RefreshRose(player)
    if self.data:MemoryCount(player) >= Config.MEMORY_COUNT then
        self:GiveRose(player)
    end
end

function MemoryService:Collect(player, index)
    if type(index) ~= "number" or index < 1 or index > Config.MEMORY_COUNT then return end
    if self.data:HasMemory(player, index) then
        self.remotes.Toast:FireClient(player, "Это воспоминание уже восстановлено.")
        return
    end
    if index > 1 and not self.data:HasMemory(player, index - 1) then
        self.remotes.Toast:FireClient(player, "Воспоминание не складывается. Сначала найди предыдущий фрагмент.")
        return
    end

    local isNew = self.data:MarkMemory(player, index)
    if not isNew then return end
    self.data:AddBits(player, Config.BITS_MEMORY)
    local count = self.data:MemoryCount(player)
    self.remotes.MemoryFlash:FireClient(player, index, Config.MEMORIES[index], count)

    if count >= Config.MEMORY_COUNT then
        self:GiveRose(player)
        self.remotes.Toast:FireClient(player, "Роза памяти восстановлена: одно возвращение в каждой главе.")
        task.delay(0.8, function()
            local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            local arena = workspace:FindFirstChild("GeneratedWorld") and workspace.GeneratedWorld:FindFirstChild("Arena")
            local spawn = arena and arena:FindFirstChild("MemorialSpawn", true)
            if root and spawn and player:GetAttribute("InRound") then
                local returnCFrame = root.CFrame
                root.CFrame = spawn.CFrame + Vector3.new(0, 3, 0)
                task.delay(10.8, function()
                    local currentRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if currentRoot and player:GetAttribute("InRound") then currentRoot.CFrame = returnCFrame end
                end)
            end
        end)
        if Config.MEMORY_BADGE_ID > 0 then
            pcall(function() BadgeService:AwardBadge(player.UserId, Config.MEMORY_BADGE_ID) end)
        end
    end
    self.data:Save(player)
end

return MemoryService
