local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local Run=game:GetService("RunService")
local Physics=game:GetService("PhysicsService")
local R={}
local folder=Instance.new("Folder"); folder.Name="CityRushRemotes"; folder.Parent=RS
for _,name in ipairs({"Action","Input","State","Profile","Toast","Open"}) do
    local r=Instance.new("RemoteEvent"); r.Name=name; r.Parent=folder; R[name]=r
end
for _,name in ipairs({"RequestProfile","RequestTop","RequestSocial","RequestRace"}) do
    local r=Instance.new("RemoteFunction"); r.Name=name; r.Parent=folder; R[name]=r
end
local status=Instance.new("StringValue"); status.Name="BootStatus"; status.Value="Loading"; status.Parent=folder
local S=script.Parent.Services
local Data=require(S.DataService)
local Track=require(S.TrackService)
local Lobby=require(S.LobbyService)
local Ride=require(S.RideService)
local Race=require(S.RaceService)
local data=Data.new(); local track=Track.new(); local lobby=Lobby.new(data,R)
local ok,err=xpcall(function() track:Build(); lobby:Build() end,debug.traceback)
if not ok then status.Value="Unavailable"; warn(err); return end
local previews=Instance.new("Folder"); previews.Name="BikePreviews"; previews.Parent=RS
local Bike=require(S.BikeFactory)
for _,name in ipairs(require(RS.Shared.Config).BIKE_ORDER) do
    local model=Bike.Build(previews,name,1,CFrame.new(),false); model.Name=name
end
local ride=Ride.new(data,track,lobby,R); local race=Race.new(ride,data,R)
Physics:RegisterCollisionGroup("CityBikes"); Physics:RegisterCollisionGroup("CityRiders")
Physics:CollisionGroupSetCollidable("CityBikes","CityBikes",false)
Physics:CollisionGroupSetCollidable("CityBikes","CityRiders",false)
Physics:CollisionGroupSetCollidable("CityRiders","CityRiders",false)
ride.folder.DescendantAdded:Connect(function(p) if p:IsA("BasePart") then p.CollisionGroup="CityBikes" end end)
local limits={}
local function limited(p,key,seconds)
    limits[p]=limits[p] or {}; local now=os.clock()
    if now-(limits[p][key] or -100)<seconds then return true end
    limits[p][key]=now; return false
end
R.RequestProfile.OnServerInvoke=function(p)
    if limited(p,"profile",.5) then return nil end
    return data:Public(p)
end
R.RequestTop.OnServerInvoke=function(p)
    if limited(p,"top",3) then return {} end
    return data:Top()
end
R.RequestSocial.OnServerInvoke=function(p)
    if limited(p,"social",1) then return {} end
    return lobby:Social()
end
R.RequestRace.OnServerInvoke=function(p)
    if limited(p,"race",1) then return nil end
    return race:Status(p)
end
R.Input.OnServerEvent:Connect(function(p,a,b,c) ride:Input(p,a,b,c) end)
R.Action.OnServerEvent:Connect(function(p,action,value,extra)
    if type(action)~="string" or limited(p,"action",.2) or not data:Get(p) then return end
    if action=="Start" then
        race:Remove(p); ride:Start(p,value,extra==true)
    elseif action=="Home" then
        race:Remove(p); ride:Stop(p,true)
    elseif action=="Retry" then ride:Respawn(p)
    elseif action=="Visit" and type(value)=="number" and not ride.states[p] then
        local target=Players:GetPlayerByUserId(value)
        if target then lobby:Teleport(p,target) end
    elseif action=="Shop" then
        race:Remove(p); ride:Stop(p,false)
        if p.Character then p.Character:PivotTo(CFrame.new(0,5,90)*CFrame.Angles(0,math.pi,0)) end
        R.Open:FireClient(p,"Bikes")
    elseif action=="Select" or action=="Upgrade" then
        if ride.states[p] then R.Toast:FireClient(p,"Менять велосипед можно в гараже"); return end
        if type(value)~="string" then return end
        local msg=data:Bike(p,action,value); lobby:Refresh(p)
        R.Toast:FireClient(p,msg); R.Profile:FireClient(p,data:Public(p))
    elseif action=="Daily" then
        R.Toast:FireClient(p,data:Daily(p)); R.Profile:FireClient(p,data:Public(p))
    elseif action=="Queue" then R.Toast:FireClient(p,race:Join(p))
    elseif action=="Settings" and (value=="music" or value=="reducedMotion") and type(extra)=="boolean" then
        data:Get(p).settings[value]=extra; R.Profile:FireClient(p,data:Public(p))
    end
end)
local function added(p)
    if not data:Load(p) then return end
    if not p.Parent then data:Remove(p); return end
    lobby:Assign(p)
    local function character(c)
        ride:Stop(p,false)
        local function collision(part) if part:IsA("BasePart") then part.CollisionGroup="CityRiders" end end
        for _,part in ipairs(c:GetDescendants()) do collision(part) end
        c.DescendantAdded:Connect(collision)
        local h=c:WaitForChild("Humanoid",10)
        if h then h.Died:Connect(function() ride:Stop(p,false); race:Remove(p) end) end
        c:WaitForChild("HumanoidRootPart",10)
        if p.Character==c then lobby:Teleport(p) end
    end
    p.CharacterAdded:Connect(character)
    if p.Character then task.spawn(character,p.Character) end
    R.Profile:FireClient(p,data:Public(p))
end
Players.PlayerAdded:Connect(added)
for _,p in ipairs(Players:GetPlayers()) do task.spawn(added,p) end
Players.PlayerRemoving:Connect(function(p)
    race:Remove(p); ride:Stop(p,false); lobby:Release(p); limits[p]=nil; data:Remove(p)
end)
local raceTick=0
Run.Heartbeat:Connect(function(dt)
    track:Update(workspace:GetServerTimeNow()); ride:Update(dt)
    raceTick+=dt; if raceTick>1 then raceTick=0; race:Update() end
end)
task.spawn(function()
    while task.wait(50) do
        for _,p in ipairs(Players:GetPlayers()) do task.spawn(function() data:Save(p,false) end) end
    end
end)
game:BindToClose(function()
    local left=0
    for p in pairs(data.profiles) do
        left+=1; task.spawn(function() data:Save(p,true); left-=1 end)
    end
    local endAt=os.clock()+25
    repeat task.wait(.1) until left==0 or os.clock()>endAt
end)
status.Value="Ready"
