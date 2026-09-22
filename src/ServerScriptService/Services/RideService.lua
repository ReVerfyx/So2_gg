local Players=game:GetService("Players")
local Config=require(game:GetService("ReplicatedStorage").Shared.Config)
local Bike=require(script.Parent.BikeFactory)
local Rules=require(game:GetService("ReplicatedStorage").Shared.RideRules)
local Ride={}; Ride.__index=Ride
function Ride.new(data,track,lobby,R)
    local folder=Instance.new("Folder"); folder.Name="ActiveBikes"; folder.Parent=workspace
    return setmetatable({data=data,track=track,lobby=lobby,R=R,states={},folder=folder},Ride)
end
function Ride:Create(player,state,cf)
    if state.bike then state.bike:Destroy() end
    local p=self.data:Get(player); local c=player.Character
    local h=c and c:FindFirstChildOfClass("Humanoid")
    local root=c and c:FindFirstChild("HumanoidRootPart")
    if not p or not h or not root or h.Health<=0 then return false end
    state.original=state.original or {walk=h.WalkSpeed,jumpPower=h.JumpPower,jumpHeight=h.JumpHeight,
        useJumpPower=h.UseJumpPower,autoJump=h.AutoJumpEnabled,autoRotate=h.AutoRotate}
    h.Sit=false; h.AutoRotate=true; h.AutoJumpEnabled=false
    h.UseJumpPower=true; h.JumpPower=38
    h:SetStateEnabled(Enum.HumanoidStateType.Jumping,true)
    c:PivotTo(cf*CFrame.new(0,4,0))
    root.AssemblyLinearVelocity=Vector3.zero; root.AssemblyAngularVelocity=Vector3.zero
    root:SetNetworkOwnershipAuto()
    state.stats=state.raceId and Config.GetBikeStats("BMX",1) or Config.GetBikeStats(p.equippedBike,p.bikeLevels[p.equippedBike])
    h.WalkSpeed=state.stats.speed
    state.bike=Bike.Attach(c,p.equippedBike,p.bikeLevels[p.equippedBike])
    state.grace=os.clock()+.65; state.lastPosition=root.Position; state.motionCredit=state.stats.speed*.8+8
    return true
end
function Ride:Start(player,world,resume,raceId,startAt)
    local p=self.data:Get(player)
    if not p or type(world)~="number" or world%1~=0 or not Config.WORLDS[world] or world>p.unlocked then return false end
    local route=self.track.worlds[world]
    self:Stop(player,false)
    local cp=resume and (p.checkpoints[tostring(world)] or 0) or 0
    local state={world=world,checkpoint=cp,started=startAt or workspace:GetServerTimeNow(),deaths=0,
        ranked=cp==0,raceId=raceId,lastCheckpoint=os.clock()}
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
    if h and s and s.original then
        local old=s.original
        h.WalkSpeed=old.walk; h.JumpPower=old.jumpPower; h.JumpHeight=old.jumpHeight
        h.UseJumpPower=old.useJumpPower; h.AutoJumpEnabled=old.autoJump; h.AutoRotate=old.autoRotate
    end
    if home then task.defer(function() if player.Parent then self.lobby:Teleport(player) end end) end
end
function Ride:Update(dt)
    for player,s in pairs(self.states) do
        local character=player.Character
        local root=character and character:FindFirstChild("HumanoidRootPart")
        local h=character and character:FindFirstChildOfClass("Humanoid")
        if not root or not s.bike or not s.bike.Parent or not h or h.Health<=0 then self:Stop(player,false); continue end
        local waiting=workspace:GetServerTimeNow()<s.started
        h.WalkSpeed=waiting and 0 or s.stats.speed
        h.JumpPower=waiting and 0 or s.stats.jump
        local position=root.Position
        local delta=position-s.lastPosition
        local horizontal=Vector3.new(delta.X,0,delta.Z).Magnitude
        local valid
        s.motionCredit,valid=Rules.motion(s.motionCredit,horizontal,dt,waiting and 0 or s.stats.speed)
        if not valid then
            root.CFrame=CFrame.new(s.lastPosition)*root.CFrame.Rotation
            root.AssemblyLinearVelocity=Vector3.zero
            continue
        end
        s.lastPosition=position
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
