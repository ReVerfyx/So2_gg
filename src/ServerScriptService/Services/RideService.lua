local Players=game:GetService("Players")
local Config=require(game:GetService("ReplicatedStorage").Shared.Config)
local Bike=require(script.Parent.BikeFactory)
local Ride={}; Ride.__index=Ride
function Ride.new(data,track,lobby,R)
    local folder=Instance.new("Folder"); folder.Name="ActiveBikes"; folder.Parent=workspace
    return setmetatable({data=data,track=track,lobby=lobby,R=R,states={},folder=folder},Ride)
end
function Ride:Create(player,state,cf)
    if state.bike then state.bike:Destroy() end
    local previousHumanoid=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if previousHumanoid then for _,x in ipairs(previousHumanoid:GetChildren()) do if x.Name=="BikeGrip" then x:Destroy() end end end
    local p=self.data:Get(player); local c=player.Character
    local h=c and c:FindFirstChildOfClass("Humanoid")
    if not p or not h or h.Health<=0 then return false end
    h:SetStateEnabled(Enum.HumanoidStateType.Jumping,false)
    h.Sit=false; c:PivotTo(cf*CFrame.new(0,5,0))
    local bike,seat,align=Bike.Build(self.folder,p.equippedBike,p.bikeLevels[p.equippedBike],cf*CFrame.new(0,1.5,0),true)
    state.bike=bike; state.seat=seat; state.align=align; state.speed=0; state.input={0,0,false}
    state.yaw=math.atan2(-cf.LookVector.X,-cf.LookVector.Z); state.lastJump=0; state.grace=os.clock()+2
    state.stats=Config.GetBikeStats(p.equippedBike,p.bikeLevels[p.equippedBike])
    state.lastPosition=bike.PrimaryPart.Position
    seat:Sit(h)
    for _,side in ipairs({"Left","Right"}) do
        local hand=c:FindFirstChild(side.."Hand"); local upper=c:FindFirstChild(side.."UpperArm")
        if hand and upper then
            local target=Instance.new("Attachment"); target.Name=side.."GripTarget"
            target.Position=Vector3.new(side=="Left" and -1 or 1,2.75,-1.6); target.Parent=bike.PrimaryPart
            local ik=Instance.new("IKControl"); ik.Name="BikeGrip"; ik.Type=Enum.IKControlType.Position
            ik.ChainRoot=upper; ik.EndEffector=hand; ik.Target=target; ik.SmoothTime=.12; ik.Weight=1; ik.Parent=h
        end
    end
    task.delay(.15,function()
        if state.bike==bike and h.Parent and bike.Parent then seat:Sit(h); bike.PrimaryPart:SetNetworkOwner(nil) end
    end)
    return true
end
function Ride:Start(player,world,resume,raceId,startAt)
    local p=self.data:Get(player)
    if not p or type(world)~="number" or world%1~=0 or not Config.WORLDS[world] or world>p.unlocked then return false end
    local route=self.track.worlds[world]
    self:Stop(player,false)
    local cp=resume and (p.checkpoints[tostring(world)] or 0) or 0
    local state={world=world,checkpoint=cp,started=startAt or workspace:GetServerTimeNow(),deaths=0,
        ranked=cp==0,raceId=raceId,lastInput=0,lastCheckpoint=os.clock(),distance=0}
    self.states[player]=state
    if not self:Create(player,state,route.checkpoints[cp+1]) then self.states[player]=nil; return false end
    player:SetAttribute("Riding",true); player:SetAttribute("World",world); player:SetAttribute("Checkpoint",cp)
    player:SetAttribute("RunStart",state.started); player:SetAttribute("Deaths",0)
    self.R.State:FireClient(player,{kind="Start",world=world,checkpoint=cp,start=state.started,ranked=state.ranked})
    return true
end
function Ride:Respawn(player)
    local s=self.states[player]; if not s then return end
    if s.respawning or os.clock()<(s.grace or 0) then return end
    s.respawning=true; s.deaths+=1; player:SetAttribute("Deaths",s.deaths)
    local ok=self:Create(player,s,self.track.worlds[s.world].checkpoints[s.checkpoint+1])
    s.respawning=false
    if not ok then self:Stop(player,true) end
end
function Ride:Stop(player,home)
    local s=self.states[player]; if s and s.bike then s.bike:Destroy() end
    self.states[player]=nil; player:SetAttribute("Riding",false)
    local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if h then
        h.Sit=false; h:SetStateEnabled(Enum.HumanoidStateType.Jumping,true)
        for _,x in ipairs(h:GetChildren()) do if x.Name=="BikeGrip" then x:Destroy() end end
    end
    if home then task.defer(function() if player.Parent then self.lobby:Teleport(player) end end) end
end
function Ride:Input(player,throttle,steer,jump)
    local s=self.states[player]; if not s then return end
    if type(throttle)~="number" or type(steer)~="number" or throttle~=throttle or steer~=steer then return end
    if math.abs(throttle)>1 or math.abs(steer)>1 then return end
    local now=os.clock(); if now-s.lastInput<.025 then return end
    s.lastInput=now; s.input={throttle,steer,jump==true}
end
function Ride:Update(dt)
    dt=math.min(dt,.05)
    for player,s in pairs(self.states) do
        local root=s.bike and s.bike.PrimaryPart
        local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if not root or not root.Parent or not h or h.Health<=0 then self:Stop(player,false); continue end
        if os.clock()-s.lastInput>.4 then s.input={0,0,false} end
        local throttle,steer,jump=table.unpack(s.input)
        if workspace:GetServerTimeNow()<s.started then throttle=0; steer=0; jump=false end
        if not s.seat.Occupant and os.clock()>s.grace then self:Respawn(player); continue end
        local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude
        local excluded={self.folder}; for _,p in ipairs(Players:GetPlayers()) do if p.Character then table.insert(excluded,p.Character) end end
        params.FilterDescendantsInstances=excluded; params.RespectCanCollide=true
        local ground=workspace:Raycast(root.Position,Vector3.new(0,-2.6,0),params)
        local grounded=ground~=nil and ground.Normal.Y>.45
        local target=throttle>=0 and throttle*s.stats.speed or throttle*10
        local rate=throttle==0 and 30 or s.stats.acceleration
        if s.speed*throttle<0 then rate=55 end
        s.speed+=math.clamp(target-s.speed,-rate*dt,rate*dt)
        if math.abs(s.speed)>1 then s.yaw-=steer*s.stats.handling*dt*math.clamp(math.abs(s.speed)/15,.15,1)*(s.speed<0 and -1 or 1) end
        local heading=Vector3.new(-math.sin(s.yaw),0,-math.cos(s.yaw))
        local up=grounded and ground.Normal or Vector3.yAxis
        local forward=(heading-up*heading:Dot(up)).Unit
        s.align.CFrame=CFrame.lookAt(Vector3.zero,forward,up)
        local velocity=root.AssemblyLinearVelocity
        local y=grounded and forward.Y*s.speed or velocity.Y
        if jump and grounded and os.clock()-s.lastJump>.7 and workspace:GetServerTimeNow()>=s.started then y=s.stats.jump; s.lastJump=os.clock() end
        -- Preserve jump impulse while the ground probe still overlaps the takeoff surface.
        if os.clock()-s.lastJump<.18 then y=math.max(y,velocity.Y) end
        root.AssemblyLinearVelocity=Vector3.new(forward.X*s.speed,y,forward.Z*s.speed)
        local position=root.Position
        s.distance+=(position-s.lastPosition).Magnitude; s.lastPosition=position
        if position.Y<self.track.worlds[s.world].killY or self.track:HazardAt(position) then self:Respawn(player); continue end
        if workspace:GetServerTimeNow()<s.started then continue end
        local route=self.track.worlds[s.world]
        local nextCF=route.checkpoints[s.checkpoint+2]
        if nextCF then
            local delta=nextCF:PointToObjectSpace(position)
            if math.abs(delta.X)<12 and math.abs(delta.Y)<7 and math.abs(delta.Z)<9 and os.clock()-s.lastCheckpoint>.5 then
                s.checkpoint+=1; s.lastCheckpoint=os.clock(); player:SetAttribute("Checkpoint",s.checkpoint)
                local p=self.data:Get(player)
                if s.checkpoint<#route.checkpoints-1 then
                    p.checkpoints[tostring(s.world)]=s.checkpoint
                    self.R.State:FireClient(player,{kind="Checkpoint",stage=s.checkpoint})
                else
                    local seconds=workspace:GetServerTimeNow()-s.started
                    local reward,first=self.data:Finish(player,s.world,math.floor(seconds*100)/100,s.ranked)
                    local raceId=s.raceId
                    self:Stop(player,true)
                    if self.onFinish then self.onFinish(player,raceId,seconds) end
                    self.R.State:FireClient(player,{kind="Finish",seconds=seconds,reward=reward,first=first,ranked=s.ranked,world=s.world,deaths=s.deaths})
                    self.R.Profile:FireClient(player,self.data:Public(player))
                    task.spawn(function() self.data:Save(player,false) end)
                end
            end
        end
    end
end
return Ride
