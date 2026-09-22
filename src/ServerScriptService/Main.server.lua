local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local DataService = require(script.Services.DataService)
local TrackService = require(script.Services.TrackService)
local RunnerService = require(script.Services.RunnerService)

local old = ReplicatedStorage:FindFirstChild("CityRushRemotes")
if old then old:Destroy() end

local remotes = Instance.new("Folder")
remotes.Name = "CityRushRemotes"
remotes.Parent = ReplicatedStorage

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

local data = DataService.new()
local track = TrackService.new()
track:Build()

local runner = RunnerService.new(data,track,R)
runner:Start()

local function onPlayer(player)
    data:Load(player)
    player:SetAttribute("Running",false)
    player:SetAttribute("Score",0)
    player:SetAttribute("RunCoins",0)
    player:SetAttribute("Shield",0)
    player:SetAttribute("RunSpeed",Config.BASE_SPEED)

    player.CharacterAdded:Connect(function(character)
        task.wait(.5)
        local root = character:FindFirstChild("HumanoidRootPart")
        if root and not player:GetAttribute("Running") then
            root.CFrame = CFrame.new(0,4,Config.START_Z)
        end
    end)
end

for _,p in ipairs(Players:GetPlayers()) do task.spawn(onPlayer,p) end
Players.PlayerAdded:Connect(onPlayer)
Players.PlayerRemoving:Connect(function(player)
    runner:PlayerRemoving(player)
    data:Remove(player)
end)

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
