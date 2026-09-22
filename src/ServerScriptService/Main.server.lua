local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

-- Create the client contract before loading gameplay modules.
-- If a module ever fails again, the UI can still boot and report the error.
local old = ReplicatedStorage:FindFirstChild("CityRushRemotes")
if old then old:Destroy() end

local remotes = Instance.new("Folder")
remotes.Name = "CityRushRemotes"
remotes.Parent = ReplicatedStorage

local bootStatus = Instance.new("StringValue")
bootStatus.Name = "BootStatus"
bootStatus.Value = "BOOTING"
bootStatus.Parent = remotes

local function remoteEvent(name)
    local r = Instance.new("RemoteEvent")
    r.Name = name
    r.Parent = remotes
    return r
end

local function remoteFunction(name)
    local r = Instance.new("RemoteFunction")
    r.Name = name
    r.Parent = remotes
    return r
end

local R = {
    StartRun = remoteEvent("StartRun"),
    RunStarted = remoteEvent("RunStarted"),
    RunEnded = remoteEvent("RunEnded"),
    RunAction = remoteEvent("RunAction"),
    BikeAction = remoteEvent("BikeAction"),
    Profile = remoteEvent("Profile"),
    Toast = remoteEvent("Toast"),
    RequestProfile = remoteFunction("RequestProfile"),
    RequestTop = remoteFunction("RequestTop"),
}

-- Safety ground so a runtime error can never dump players into the void.
local fallback = Instance.new("Part")
fallback.Name = "CityRushSafetyGround"
fallback.Anchored = true
fallback.Size = Vector3.new(120, 4, 160)
fallback.Position = Vector3.new(0, -3, Config.START_Z + 35)
fallback.Color = Color3.fromRGB(73, 173, 101)
fallback.Material = Enum.Material.Grass
fallback.Parent = workspace

local fallbackSpawn = Instance.new("SpawnLocation")
fallbackSpawn.Name = "CityRushSafetySpawn"
fallbackSpawn.Anchored = true
fallbackSpawn.Size = Vector3.new(18, 1, 18)
fallbackSpawn.Position = Vector3.new(0, 1, Config.START_Z)
fallbackSpawn.Transparency = 1
fallbackSpawn.CanCollide = true
fallbackSpawn.Neutral = true
fallbackSpawn.Parent = workspace

local services = script.Parent:WaitForChild("Services")

local okData, DataService = pcall(require, services:WaitForChild("DataService"))
local okTrack, TrackService = pcall(require, services:WaitForChild("TrackService"))
local okRunner, RunnerService = pcall(require, services:WaitForChild("RunnerService"))

if not okData or not okTrack or not okRunner then
    local message = "MODULE ERROR"
    if not okData then message ..= " | DataService: " .. tostring(DataService) end
    if not okTrack then message ..= " | TrackService: " .. tostring(TrackService) end
    if not okRunner then message ..= " | RunnerService: " .. tostring(RunnerService) end
    bootStatus.Value = message
    warn("[CITY RUSH] " .. message)
    return
end

local data = DataService.new()
local track = TrackService.new()

local okBuild, buildErr = pcall(function()
    track:Build()
end)

if not okBuild then
    bootStatus.Value = "TRACK ERROR | " .. tostring(buildErr)
    warn("[CITY RUSH] Track build failed:", buildErr)
    return
end

-- The real track exists; the safety ground stays deep underneath as a catch plane.
fallback.Position = Vector3.new(0, -12, Config.START_Z + 35)
fallbackSpawn:Destroy()

local runner = RunnerService.new(data,track,R)
local okRunnerStart, runnerErr = pcall(function()
    runner:Start()
end)

if not okRunnerStart then
    bootStatus.Value = "RUNNER ERROR | " .. tostring(runnerErr)
    warn("[CITY RUSH] Runner failed:", runnerErr)
    return
end

local function onPlayer(player)
    data:Load(player)
    player:SetAttribute("Running",false)
    player:SetAttribute("Score",0)
    player:SetAttribute("RunCoins",0)
    player:SetAttribute("Shield",0)
    player:SetAttribute("RunSpeed",Config.BASE_SPEED)

    player.CharacterAdded:Connect(function(character)
        task.wait(.35)
        local root = character:FindFirstChild("HumanoidRootPart")
        if root and not player:GetAttribute("Running") then
            root.CFrame = CFrame.new(0,4,Config.START_Z)
            root.AssemblyLinearVelocity = Vector3.zero
        end
    end)

    if player.Character then
        task.spawn(function()
            task.wait(.35)
            local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = CFrame.new(0,4,Config.START_Z)
                root.AssemblyLinearVelocity = Vector3.zero
            end
        end)
    end
end

for _,p in ipairs(Players:GetPlayers()) do task.spawn(onPlayer,p) end
Players.PlayerAdded:Connect(onPlayer)
Players.PlayerRemoving:Connect(function(player)
    runner:PlayerRemoving(player)
    data:Remove(player)
end)

bootStatus.Value = "READY"

task.spawn(function()
    while task.wait(60) do
        for _,player in ipairs(Players:GetPlayers()) do
            data:Save(player)
        end
    end
end)

game:BindToClose(function()
    for _,player in ipairs(Players:GetPlayers()) do
        data:Save(player)
    end
    task.wait(2)
end)
