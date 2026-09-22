local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")

local Config=require(ReplicatedStorage.Shared.Config)

local old=ReplicatedStorage:FindFirstChild("CityRushRemotes")
if old then old:Destroy() end

local remotes=Instance.new("Folder")
remotes.Name="CityRushRemotes"
remotes.Parent=ReplicatedStorage

local bootStatus=Instance.new("StringValue")
bootStatus.Name="BootStatus"
bootStatus.Value="BOOTING"
bootStatus.Parent=remotes

local function remoteEvent(name)
    local r=Instance.new("RemoteEvent")
    r.Name=name
    r.Parent=remotes
    return r
end

local function remoteFunction(name)
    local r=Instance.new("RemoteFunction")
    r.Name=name
    r.Parent=remotes
    return r
end

local R={
    StartRun=remoteEvent("StartRun"),
    RunStarted=remoteEvent("RunStarted"),
    RunEnded=remoteEvent("RunEnded"),
    RunAction=remoteEvent("RunAction"),
    BikeAction=remoteEvent("BikeAction"),
    LobbyAction=remoteEvent("LobbyAction"),
    Profile=remoteEvent("Profile"),
    Toast=remoteEvent("Toast"),
    RequestProfile=remoteFunction("RequestProfile"),
    RequestTop=remoteFunction("RequestTop"),
}

local fallback=Instance.new("Part")
fallback.Name="CityRushSafetyGround"
fallback.Anchored=true
fallback.Size=Vector3.new(330,4,400)
fallback.Position=Config.LOBBY_CENTER+Vector3.new(0,-8,20)
fallback.Color=Color3.fromRGB(73,173,101)
fallback.Material=Enum.Material.Grass
fallback.Parent=workspace

local services=script.Parent:WaitForChild("Services")
local okData,DataService=pcall(require,services:WaitForChild("DataService"))
local okTrack,TrackService=pcall(require,services:WaitForChild("TrackService"))
local okRunner,RunnerService=pcall(require,services:WaitForChild("RunnerService"))
local okLobby,LobbyService=pcall(require,services:WaitForChild("LobbyService"))

if not okData or not okTrack or not okRunner or not okLobby then
    local message="MODULE ERROR"
    if not okData then message..=" | Data: "..tostring(DataService) end
    if not okTrack then message..=" | Track: "..tostring(TrackService) end
    if not okRunner then message..=" | Runner: "..tostring(RunnerService) end
    if not okLobby then message..=" | Lobby: "..tostring(LobbyService) end
    bootStatus.Value=message
    warn("[CITY RUSH] "..message)
    return
end

local data=DataService.new()
local track=TrackService.new()
local lobby=LobbyService.new(data,R)

local okBuild,buildErr=pcall(function()
    track:Build()
    lobby:Build()
end)
if not okBuild then
    bootStatus.Value="WORLD ERROR | "..tostring(buildErr)
    warn("[CITY RUSH] build failed:",buildErr)
    return
end

fallback.Position=Config.LOBBY_CENTER+Vector3.new(0,-16,20)

local runner=RunnerService.new(data,track,lobby,R)
lobby:SetRunner(runner)

local okRunnerStart,runnerErr=pcall(function() runner:Start() end)
if not okRunnerStart then
    bootStatus.Value="RUNNER ERROR | "..tostring(runnerErr)
    warn("[CITY RUSH] runner failed:",runnerErr)
    return
end

R.LobbyAction.OnServerEvent:Connect(function(player,action)
    if action=="Home" then lobby:TeleportHome(player)
    elseif action=="Bikes" then lobby:TeleportShowroom(player)
    elseif action=="Lobby" then lobby:TeleportLobby(player)
    elseif action=="Race" then runner:BeginRun(player) end
end)

local function onPlayer(player)
    data:Load(player)
    lobby:AssignPlayer(player)

    player:SetAttribute("Running",false)
    player:SetAttribute("Score",0)
    player:SetAttribute("RunCoins",0)
    player:SetAttribute("Shield",0)
    player:SetAttribute("RunSpeed",Config.BASE_SPEED)

    local function place(character)
        task.wait(.35)
        if player:GetAttribute("Running") then return end
        local root=character:FindFirstChild("HumanoidRootPart")
        if root then
            lobby:TeleportHome(player)
        end
    end

    player.CharacterAdded:Connect(place)
    if player.Character then task.spawn(place,player.Character) end
end

for _,p in ipairs(Players:GetPlayers()) do task.spawn(onPlayer,p) end
Players.PlayerAdded:Connect(onPlayer)
Players.PlayerRemoving:Connect(function(player)
    runner:PlayerRemoving(player)
    lobby:ReleasePlayer(player)
    data:Remove(player)
end)

bootStatus.Value="READY"

task.spawn(function()
    while task.wait(60) do
        for _,player in ipairs(Players:GetPlayers()) do data:Save(player) end
    end
end)

game:BindToClose(function()
    for _,player in ipairs(Players:GetPlayers()) do data:Save(player) end
    task.wait(2)
end)
