local Players=game:GetService("Players")
local CollectionService=game:GetService("CollectionService")
local RunService=game:GetService("RunService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")

local Config=require(ReplicatedStorage.Shared.Config)
local BikeFactory=require(script.Parent.BikeFactory)

local RunnerService={}
RunnerService.__index=RunnerService

local function findPlayer(hit)
    local model=hit and hit:FindFirstAncestorOfClass("Model")
    return model and Players:GetPlayerFromCharacter(model) or nil
end

function RunnerService.new(dataService,trackService,lobbyService,remotes)
    local self=setmetatable({},RunnerService)
    self.data=dataService
    self.track=trackService
    self.lobby=lobbyService
    self.remotes=remotes
    self.states={}
    self.connections={}
    self.lastUpdate=0
    return self
end

function RunnerService:_bikeInfo(player)
    local profile=self.data:Get(player)
    local name=profile and profile.equippedBike or "BMX"
    local level=profile and profile.bikeLevels[name] or 1
    return name,level,Config.GetBikeStats(name,level)
end

function RunnerService:_attachBike(player)
    local character=player.Character
    if not character then return end
    local name,level=self:_bikeInfo(player)
    BikeFactory.Attach(character,name,level)
end

function RunnerService:_removeBike(player)
    local character=player.Character
    local bike=character and character:FindFirstChild("RunnerBike")
    if bike then bike:Destroy() end
end

function RunnerService:_connectTagged(tag,callback)
    for _,inst in ipairs(CollectionService:GetTagged(tag)) do callback(inst) end
    table.insert(self.connections,CollectionService:GetInstanceAddedSignal(tag):Connect(callback))
end

function RunnerService:Start()
    self:_connectTagged("RunnerObstacle",function(obstacle)
        if obstacle:GetAttribute("_Hooked") then return end
        obstacle:SetAttribute("_Hooked",true)
        obstacle.Touched:Connect(function(hit)
            local player=findPlayer(hit)
            local state=player and self.states[player]
            if not state or not state.running then return end

            local kind=obstacle:GetAttribute("ObstacleType")
            if kind=="Slide" and state.sliding then return end

            if state.shield>0 then
                state.shield-=1
                player:SetAttribute("Shield",state.shield)
                self.remotes.Toast:FireClient(player,"Щит спас тебя!")
                obstacle.CanTouch=false
                task.delay(.8,function()
                    if obstacle.Parent then obstacle.CanTouch=true end
                end)
                return
            end
            self:EndRun(player,"CRASH")
        end)
    end)

    self:_connectTagged("RunnerCoin",function(coin)
        if coin:GetAttribute("_Hooked") then return end
        coin:SetAttribute("_Hooked",true)
        coin.Touched:Connect(function(hit)
            local player=findPlayer(hit)
            local state=player and self.states[player]
            if not state or not state.running or coin:GetAttribute("Taken") then return end

            coin:SetAttribute("Taken",true)
            coin.Transparency=1
            coin.CanTouch=false
            local value=coin:GetAttribute("CoinValue") or 1
            state.coins+=value
            self.data:AddCoins(player,value)
            player:SetAttribute("RunCoins",state.coins)
            task.delay(.2,function()
                if coin.Parent then coin:Destroy() end
            end)
        end)
    end)

    self.remotes.StartRun.OnServerEvent:Connect(function(player)
        self:BeginRun(player)
    end)

    self.remotes.RunAction.OnServerEvent:Connect(function(player,action,value)
        local state=self.states[player]
        if state and action=="Slide" then state.sliding=value==true end
    end)

    self.remotes.BikeAction.OnServerEvent:Connect(function(player,action,bikeName)
        if bikeName==nil then
            bikeName=action
            action="Select"
        end
        if type(bikeName)~="string" or not Config.BIKES[bikeName] then return end

        local ok,msg
        if action=="Upgrade" then
            ok,msg=self.data:UpgradeBike(player,bikeName)
        else
            ok,msg=self.data:BuyOrEquipBike(player,bikeName)
        end

        if ok then
            if self.lobby then self.lobby:RefreshPlayer(player) end
            if player:GetAttribute("Running") then self:_attachBike(player) end
        end
        self.remotes.Profile:FireClient(player,self.data:GetPublicProfile(player),Config.BIKES,msg)
    end)

    self.remotes.RequestProfile.OnServerInvoke=function(player)
        return self.data:GetPublicProfile(player),Config.BIKES
    end

    self.remotes.RequestTop.OnServerInvoke=function()
        return self.data:GetTop(10)
    end

    RunService.Heartbeat:Connect(function(dt)
        self.lastUpdate+=dt
        if self.lastUpdate<.15 then return end
        self.lastUpdate=0

        local maxZ=0
        for player,state in pairs(self.states) do
            if state.running then
                local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local score=math.max(0,math.floor(root.Position.Z-Config.START_Z))
                    state.score=score
                    maxZ=math.max(maxZ,root.Position.Z)
                    player:SetAttribute("Score",score)
                    local _,_,stats=self:_bikeInfo(player)
                    local speed=math.min(Config.MAX_SPEED,Config.BASE_SPEED+math.floor(score/250)*Config.SPEED_PER_250+stats.speedBonus)
                    player:SetAttribute("RunSpeed",speed)
                end
            end
        end

        if maxZ>self.track:GetEndZ()-1200 then
            self.track:GenerateMore(Config.GENERATE_BATCH)
        end
    end)
end

function RunnerService:BeginRun(player)
    if player:GetAttribute("Running") then return end
    local character=player.Character
    local root=character and character:FindFirstChild("HumanoidRootPart")
    local humanoid=character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then return end

    local _,level,stats=self:_bikeInfo(player)
    self.states[player]={
        running=true,
        score=0,
        coins=0,
        sliding=false,
        shield=stats.shield,
        coinBonus=stats.coinBonus,
        level=level,
    }

    humanoid.AutoRotate=false
    humanoid.WalkSpeed=0
    root.AssemblyLinearVelocity=Vector3.zero
    root.CFrame=CFrame.new(0,4,Config.START_Z)

    player:SetAttribute("Running",true)
    player:SetAttribute("Score",0)
    player:SetAttribute("RunCoins",0)
    player:SetAttribute("Shield",stats.shield)
    player:SetAttribute("RunSpeed",Config.BASE_SPEED+stats.speedBonus)

    self:_attachBike(player)
    self.remotes.RunStarted:FireClient(player)
end

function RunnerService:EndRun(player,reason)
    local state=self.states[player]
    if not state or not state.running then return end
    state.running=false

    local bonusCoins=math.floor(state.coins*(state.coinBonus or 0))
    if bonusCoins>0 then self.data:AddCoins(player,bonusCoins) end
    local totalCoins=state.coins+bonusCoins
    local gain=self.data:FinishRun(player,state.score,totalCoins)

    player:SetAttribute("Running",false)
    self.remotes.RunEnded:FireClient(player,{
        score=state.score,
        coins=totalCoins,
        bonusCoins=bonusCoins,
        ratingGain=gain,
        reason=reason,
        profile=self.data:GetPublicProfile(player),
    })

    task.delay(1.2,function()
        self:_removeBike(player)
        local character=player.Character
        local root=character and character:FindFirstChild("HumanoidRootPart")
        local humanoid=character and character:FindFirstChildOfClass("Humanoid")
        if root and humanoid then
            humanoid.AutoRotate=true
            humanoid.WalkSpeed=16
            root.AssemblyLinearVelocity=Vector3.zero
            if self.lobby then
                self.lobby:TeleportHome(player)
            else
                root.CFrame=CFrame.new(Config.LOBBY_SPAWN)
            end
        end
    end)
end

function RunnerService:PlayerRemoving(player)
    self.states[player]=nil
end

return RunnerService
