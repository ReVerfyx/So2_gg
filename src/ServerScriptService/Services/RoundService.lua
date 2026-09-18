local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)

local RoundService = {}
RoundService.__index = RoundService

function RoundService.new(remotes, world, build, memory, enemy, data)
    local self = setmetatable({}, RoundService)
    self.remotes = remotes
    self.world = world
    self.build = build
    self.memory = memory
    self.enemy = enemy
    self.data = data
    self.roomMembers = {}
    self.roomHost = nil
    self.running = false
    self.counting = false
    self.runSeed = 0
    self.currentChapterId = 0
    self.currentChapter = nil
    self.currentPulse = 0
    self.stepIndex = 1
    self.stepFound = {}
    self.easterFound = {}
    self.chapterToken = 0
    self.completingChapter = false
    return self
end

function RoundService:IsMember(player)
    return self.roomMembers[player] == true
end

function RoundService:GetSpawnPosition()
    return self.world:GetSpawnPosition()
end

function RoundService:JoinRoom(player)
    if self.running then
        self.remotes.Toast:FireClient(player, "Кампания уже идёт. Дождись следующего запуска сервера.")
        return
    end
    if self.roomMembers[player] then
        self.roomMembers[player] = nil
        player:SetAttribute("InRoom", false)
        if self.roomHost == player then
            self.roomHost = next(self.roomMembers)
        end
        self.remotes.Toast:FireClient(player, "Ты вышел из комнаты.")
    else
        self.roomMembers[player] = true
        player:SetAttribute("InRoom", true)
        if not self.roomHost then self.roomHost = player end
        local chapter = self.data:GetCampaignChapter(player)
        self.remotes.Toast:FireClient(player, ("Ты вошёл в комнату. Твой чекпоинт: глава %d/%d."):format(chapter, #Config.CHAPTERS))
    end
    self:BroadcastRoom()
    if self:RoomCount() >= 1 and not self.counting then self:StartCountdown() end
end

function RoundService:RoomCount()
    local n = 0
    for p in pairs(self.roomMembers) do if p.Parent == Players then n += 1 end end
    return n
end

function RoundService:BroadcastRoom()
    local names = {}
    for p in pairs(self.roomMembers) do if p.Parent == Players then table.insert(names, p.DisplayName) end end
    table.sort(names)
    self.remotes.RoomState:FireAllClients({running=self.running, members=names, host=self.roomHost and self.roomHost.DisplayName or nil})
end

function RoundService:StartCountdown()
    if self.counting or self.running then return end
    self.counting = true
    task.spawn(function()
        for t = Config.LOBBY_COUNTDOWN, 1, -1 do
            if self.running or self:RoomCount() == 0 then self.counting=false return end
            self.remotes.Countdown:FireAllClients(t)
            task.wait(1)
        end
        self.counting = false
        if self:RoomCount() > 0 then self:StartRound() end
    end)
end

function RoundService:ApplyClass(player)
    local className = player:GetAttribute("SelectedClass") or "Archivist"
    local class = Config.CLASSES[className] or Config.CLASSES.Archivist
    player:SetAttribute("BuildLimit", class.buildLimit)
    player:SetAttribute("ClassName", className)
    local character = player.Character
    local hum = character and character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = class.walkSpeed end
    local head = character and character:FindFirstChild("Head")
    if head then
        local old = head:FindFirstChild("DebugLamp")
        if old then old:Destroy() end
        if className == "Debugger" then
            local light = Instance.new("PointLight")
            light.Name = "DebugLamp"; light.Brightness=1.5; light.Range=25; light.Color=Color3.fromRGB(185,225,255); light.Parent=head
        end
    end
end

function RoundService:TeleportMembers(position)
    local index = 0
    for p in pairs(self.roomMembers) do
        if p.Parent == Players then
            index += 1
            p:SetAttribute("InRound", true)
            p:SetAttribute("RoseUsedThisRound", false)
            p:SetAttribute("HasRose", false)
            p:LoadCharacter()
            task.wait(0.12)
            local root = p.Character and p.Character:WaitForChild("HumanoidRootPart", 5)
            if root then root.CFrame = CFrame.new(position + Vector3.new((index-1)*5, 3, 0)) end
            self:ApplyClass(p)
            self.memory:RefreshRose(p)
        end
    end
end

function RoundService:ActivePlayerCount()
    local n = 0
    for p in pairs(self.roomMembers) do
        if p.Parent == Players and p:GetAttribute("InRound") == true then n += 1 end
    end
    return n
end

function RoundService:CurrentTask()
    return self.currentChapter and self.currentChapter.tasks[self.stepIndex] or nil
end

function RoundService:CountFound()
    local n = 0
    for _ in pairs(self.stepFound) do n += 1 end
    return n
end

function RoundService:ObjectiveText()
    local taskInfo = self:CurrentTask()
    if not taskInfo then return "..." end
    local found = self:CountFound()
    local gate = taskInfo.gatePulse or 0
    if self.currentPulse < gate then
        local left = gate - self.currentPulse
        return ("%s — сервер ещё не загрузил этот слой. Обновлений до доступа: %d"):format(taskInfo.label, left)
    end
    return ("%s  [%d/%d]"):format(taskInfo.label, found, taskInfo.count)
end

function RoundService:BroadcastObjective()
    self.remotes.Objective:FireAllClients(self:ObjectiveText(), self.stepIndex)
end

function RoundService:TryEnableCurrentStep()
    local taskInfo = self:CurrentTask()
    if not taskInfo then return end
    local allowed = self.currentPulse >= (taskInfo.gatePulse or 0)
    self.world:SetTaskEnabled(self.stepIndex, allowed)
    self:BroadcastObjective()
    if allowed then
        self.remotes.Toast:FireAllClients("Новый слой карты доступен: " .. taskInfo.label)
    end
end

function RoundService:CheckPrompts()
    local arena = self.world.current
    if not arena then return end
    for _, obj in ipairs(arena:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local parent = obj.Parent
            if parent and parent:GetAttribute("ObjectiveType") then
                obj.Triggered:Connect(function(player)
                    if not self.running or not self:IsMember(player) or not player:GetAttribute("InRound") then return end
                    self:ObjectiveTriggered(player, parent)
                end)
            elseif parent and parent:GetAttribute("EasterEggText") then
                obj.Triggered:Connect(function(player)
                    if not self.running or not self:IsMember(player) then return end
                    self:EasterEggTriggered(player, parent)
                end)
            elseif parent and parent:GetAttribute("MemoryIndex") then
                obj.Triggered:Connect(function(player)
                    if not self.running or not self:IsMember(player) then return end
                    self.memory:Collect(player, parent:GetAttribute("MemoryIndex"))
                end)
            end
        end
    end
end

function RoundService:EasterEggTriggered(player, object)
    local key = tostring(self.currentChapterId) .. ":" .. object.Name
    local found = self.easterFound[player] or {}
    if found[key] then
        self.remotes.Toast:FireClient(player, "Эту пасхалку ты уже нашёл в этой главе.")
        return
    end
    found[key] = true
    self.easterFound[player] = found
    self.data:AddBits(player, object:GetAttribute("EasterEggReward") or 10)
    self.remotes.Toast:FireClient(player, object:GetAttribute("EasterEggText") or "Пасхалка найдена.")
end

function RoundService:ObjectiveTriggered(player, object)
    if object:GetAttribute("ObjectiveType") ~= "ChapterTask" then return end
    local step = object:GetAttribute("TaskStep")
    local idx = object:GetAttribute("ObjectiveIndex")
    local taskInfo = self:CurrentTask()
    if not taskInfo then return end
    if step ~= self.stepIndex then
        self.remotes.Toast:FireClient(player, step < self.stepIndex and "Этот объект уже относится к прошлому слою карты." or "Сервер ещё не знает, зачем это нужно.")
        return
    end
    if self.currentPulse < (taskInfo.gatePulse or 0) then
        self.remotes.Toast:FireClient(player, "Объект существует, но его код появится после следующего обновления мира.")
        return
    end
    if self.stepFound[idx] then return end
    self.stepFound[idx] = true
    local pp = object:FindFirstChildOfClass("ProximityPrompt")
    if pp then pp.Enabled = false end
    object.Color = Color3.fromRGB(89, 255, 135)
    object.Material = Enum.Material.Neon
    self.data:AddBits(player, Config.BITS_PER_OBJECTIVE)
    local count = self:CountFound()
    if count < taskInfo.count then
        self:BroadcastObjective()
        return
    end

    self.world:SetTaskEnabled(self.stepIndex, false)
    if self.stepIndex >= #self.currentChapter.tasks then
        self:CompleteChapter(player)
        return
    end

    self.stepIndex += 1
    self.stepFound = {}
    self:TryEnableCurrentStep()
end

function RoundService:StartRound()
    if self.running then return end
    self.running = true
    self.runSeed = math.random(1, 999999999)
    self.easterFound = {}
    self:BroadcastRoom()
    local startChapter = 1
    if self.roomHost and self.roomHost.Parent == Players then
        startChapter = self.data:GetCampaignChapter(self.roomHost)
    end
    self:StartChapter(startChapter)
end

function RoundService:StartChapter(chapterId)
    if not self.running then return end
    local chapter = Config.CHAPTERS[chapterId]
    if not chapter then self:EndRound(true); return end
    self.chapterToken += 1
    local token = self.chapterToken
    self.completingChapter = false
    self.currentChapterId = chapterId
    self.currentChapter = chapter
    self.currentPulse = 0
    self.stepIndex = 1
    self.stepFound = {}

    self.enemy:Stop()
    self.build:SetEnabled(false)
    self.build:Reset()
    self.world:BuildChapter(chapter, self.runSeed + chapterId * 971)
    self.build:SetEnabled(true)
    self:CheckPrompts()
    self:TeleportMembers(self.world:GetSpawnPosition())
    self.world:SetTaskEnabled(1, true)
    self.remotes.ChapterChanged:FireAllClients(chapter.id, #Config.CHAPTERS, chapter.title, chapter.subtitle, chapter.intro, chapter.duration)
    self:BroadcastObjective()
    self.enemy:Start(chapter, self.world:GetSpawnPosition())

    task.spawn(function()
        local startClock = os.clock()
        local nextPulse = Config.WORLD_UPDATE_INTERVAL
        local zeroActiveFor = 0
        while self.running and token == self.chapterToken and not self.completingChapter do
            local elapsed = os.clock() - startClock
            local remaining = math.max(0, chapter.duration - elapsed)
            self.remotes.RoundTime:FireAllClients(math.floor(remaining))

            if elapsed >= nextPulse then
                self.currentPulse += 1
                nextPulse += Config.WORLD_UPDATE_INTERVAL
                self.world:CorruptStage(self.currentPulse, chapter)
                self.world:CorruptPlayerBuilds(self.build:GetFolder(), self.currentPulse)
                local taskInfo = self:CurrentTask()
                if taskInfo and self.currentPulse == (taskInfo.gatePulse or 0) then self:TryEnableCurrentStep() end
            end

            if self:ActivePlayerCount() == 0 then zeroActiveFor += 1 else zeroActiveFor = 0 end
            if zeroActiveFor >= 8 then
                self:EndRound(false)
                break
            end
            if remaining <= 0 then
                self:EndRound(false)
                break
            end
            task.wait(1)
        end
    end)
end

function RoundService:CompleteChapter(triggerPlayer)
    if self.completingChapter or not self.running then return end
    local chapter = self.currentChapter
    if not chapter then return end
    self.completingChapter = true
    self.chapterToken += 1
    self.enemy:Stop()
    self.build:SetEnabled(false)
    self.world:StoreBuilds(self.build:GetFolder())

    for p in pairs(self.roomMembers) do
        if p.Parent == Players then
            self.data:AddBits(p, Config.BITS_CHAPTER)
            self.data:CompleteChapter(p, chapter.id)
        end
    end

    self.remotes.ChapterCompleted:FireAllClients(chapter.id, chapter.title, chapter.final == true)
    if chapter.final then
        for p in pairs(self.roomMembers) do
            if p.Parent == Players then self.data:AddBits(p, Config.BITS_CAMPAIGN) end
        end
        self.remotes.FinalSequence:FireAllClients()
        task.delay(11, function()
            if self.running then self:EndRound(true) end
        end)
    else
        local nextId = chapter.id + 1
        task.delay(7, function()
            if self.running then self:StartChapter(nextId) end
        end)
    end
end

function RoundService:EndRound(won)
    if not self.running then return end
    self.running = false
    self.chapterToken += 1
    self.enemy:Stop()
    self.build:SetEnabled(false)
    self.build:Reset()
    self.remotes.RoundEnd:FireAllClients(won, self.currentChapterId)
    for p in pairs(self.roomMembers) do
        if p.Parent == Players then
            p:SetAttribute("InRound", false)
            p:SetAttribute("InRoom", false)
            self.data:Save(p)
            p:LoadCharacter()
        end
    end
    task.wait(Config.INTERMISSION)
    self.world:BuildLobby()
    self.roomMembers = {}
    self.roomHost = nil
    self.currentChapter = nil
    self.currentChapterId = 0
    self:BroadcastRoom()
end

function RoundService:PlayerRemoving(player)
    self.roomMembers[player] = nil
    if self.roomHost == player then self.roomHost = next(self.roomMembers) end
end

return RoundService
