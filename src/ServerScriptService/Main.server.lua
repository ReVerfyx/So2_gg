local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local DataService = require(script.Parent.Services.DataService)
local WorldService = require(script.Parent.Services.WorldService)
local BuildService = require(script.Parent.Services.BuildService)
local MemoryService = require(script.Parent.Services.MemoryService)
local EnemyService = require(script.Parent.Services.EnemyService)
local RoundService = require(script.Parent.Services.RoundService)

local remotes = Instance.new("Folder")
remotes.Name = "CodeRotRemotes"
remotes.Parent = ReplicatedStorage

local function remote(name)
    local r = Instance.new("RemoteEvent")
    r.Name = name
    r.Parent = remotes
    return r
end

local names = {
    "Toast", "MemoryFlash", "WorldPulse", "Objective", "RoundTime", "RoundEnd", "FinalSequence",
    "RoomState", "Countdown", "OpenClassMenu", "BuildPlace", "BuildDelete", "ClassAction",
    "ChapterChanged", "ChapterCompleted"
}
local R = {}
for _, n in ipairs(names) do R[n] = remote(n) end

local data = DataService.new()
local world = WorldService.new(R)
local build = BuildService.new(R)
local memory = MemoryService.new(R, data)
local enemy = EnemyService.new(R)
local round = RoundService.new(R, world, build, memory, enemy, data)

world:SetupLighting()
world:BuildLobby()

local function hookLobbyPrompts()
    task.wait(0.2)
    local lobby = world.root:FindFirstChild("Lobby")
    if not lobby then return end
    local roomPrompt = lobby:FindFirstChild("RoomPrompt", true)
    local classPrompt = lobby:FindFirstChild("ClassPrompt", true)
    if roomPrompt then roomPrompt.Triggered:Connect(function(player) round:JoinRoom(player) end) end
    if classPrompt then classPrompt.Triggered:Connect(function(player) R.OpenClassMenu:FireClient(player, Config.CLASSES, data:Get(player)) end) end
end
hookLobbyPrompts()

-- Re-hook prompts whenever lobby is recreated.
world.root.ChildAdded:Connect(function(child)
    if child.Name == "Lobby" then hookLobbyPrompts() end
end)

R.BuildPlace.OnServerEvent:Connect(function(player, position, normal)
    if round:IsMember(player) then build:HandlePlace(player, position, normal) end
end)
R.BuildDelete.OnServerEvent:Connect(function(player, target)
    if round:IsMember(player) then build:HandleDelete(player, target) end
end)

R.ClassAction.OnServerEvent:Connect(function(player, action, className)
    local class = Config.CLASSES[className]
    if not class then return end
    if action == "Buy" then
        local ok, msg = data:BuyClass(player, className, class.price)
        R.Toast:FireClient(player, msg)
        if ok then data:SelectClass(player, className) end
    elseif action == "Select" then
        local ok = data:SelectClass(player, className)
        R.Toast:FireClient(player, ok and ("Выбран класс: " .. class.displayName) or "Класс заблокирован.")
    end
    R.OpenClassMenu:FireClient(player, Config.CLASSES, data:Get(player))
end)

local function hookCharacter(player, character)
    local hum = character:WaitForChild("Humanoid", 10)
    if not hum then return end
    task.wait(0.1)
    if player:GetAttribute("InRound") then round:ApplyClass(player) end
    hum.Died:Connect(function()
        if not player:GetAttribute("InRound") then return end
        if player:GetAttribute("HasRose") and not player:GetAttribute("RoseUsedThisRound") then
            player:SetAttribute("RoseUsedThisRound", true)
            player:SetAttribute("HasRose", false)
            local backpack = player:FindFirstChildOfClass("Backpack")
            local rose = backpack and backpack:FindFirstChild("Роза памяти")
            if not rose and player.Character then rose = player.Character:FindFirstChild("Роза памяти") end
            if rose then rose:Destroy() end
            R.Toast:FireClient(player, "Роза помнит тебя.")
            task.delay(2.5, function()
                if player.Parent == Players and player:GetAttribute("InRound") then
                    player:LoadCharacter()
                    task.wait(0.2)
                    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if root then root.CFrame = CFrame.new(round:GetSpawnPosition() + Vector3.new(0, 3, 0)) end
                    round:ApplyClass(player)
                end
            end)
        else
            player:SetAttribute("InRound", false)
            R.Toast:FireClient(player, "Ты погиб в этом цикле. Роза дала бы одно возвращение.")
        end
    end)
end

Players.PlayerAdded:Connect(function(player)
    data:Load(player)
    player:SetAttribute("InRound", false)
    player:SetAttribute("InRoom", false)
    player:SetAttribute("HasRose", false)
    player.CharacterAdded:Connect(function(character) hookCharacter(player, character) end)
    if player.Character then task.spawn(hookCharacter, player, player.Character) end
end)

for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(function()
        data:Load(player)
        player.CharacterAdded:Connect(function(character) hookCharacter(player, character) end)
    end)
end

Players.PlayerRemoving:Connect(function(player)
    round:PlayerRemoving(player)
    data:Remove(player)
end)

game:BindToClose(function()
    for _, player in ipairs(Players:GetPlayers()) do data:Save(player) end
end)
