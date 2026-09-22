local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local RunnerService = {}
RunnerService.__index = RunnerService

local function findPlayer(hit)
    if not hit then return nil end
    local model = hit:FindFirstAncestorOfClass("Model")
    if not model then return nil end
    return Players:GetPlayerFromCharacter(model)
end

function RunnerService.new(dataService, trackService, remotes)
    local self = setmetatable({}, RunnerService)
    self.data = dataService
    self.track = trackService
    self.remotes = remotes
    self.states = {}
    self.connections = {}
    self.lastUpdate = 0
    return self
end

function RunnerService:_bikeInfo(player)
    local profile = self.data:Get(player)
    local name = profile and profile.equippedBike or "BMX"
    return name, Config.BIKES[name] or Config.BIKES.BMX
end

function RunnerService:_clearBike(character)
    local old = character and character:FindFirstChild("RunnerBike")
    if old then old:Destroy() end
end

function RunnerService:_attachBike(player)
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    self:_clearBike(character)

    local name, info = self:_bikeInfo(player)
    local model = Instance.new("Model")
    model.Name = "RunnerBike"
    model.Parent = character

    local function welded(namePart,size,offset,color,shape)
        local p = Instance.new("Part")
        p.Name = namePart
        p.Size = size
        p.Color = color
        p.Material = Enum.Material.Metal
        p.CanCollide = false
        p.CanTouch = false
        p.Massless = true
        p.Anchored = false
        if shape then p.Shape = shape end
        p.CFrame = root.CFrame * CFrame.new(offset)
        p.Parent = model
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = root
        weld.Part1 = p
        weld.Parent = p
        return p
    end

    local frameColor = info.color
    local back = welded("BackWheel",Vector3.new(2.6,2.6,.65),Vector3.new(0,-2.1,-2.1),Color3.fromRGB(32,34,39),Enum.PartType.Cylinder)
    back.Orientation = Vector3.new(0,0,90)
    local front = welded("FrontWheel",Vector3.new(2.6,2.6,.65),Vector3.new(0,-2.1,2.1),Color3.fromRGB(32,34,39),Enum.PartType.Cylinder)
    front.Orientation = Vector3.new(0,0,90)
    welded("Frame",Vector3.new(.55,.55,4.1),Vector3.new(0,-1.5,0),frameColor)
    local bar = welded("Handlebar",Vector3.new(3,.35,.35),Vector3.new(0,-.7,1.6),frameColor)
    welded("Seat",Vector3.new(2,.35,1),Vector3.new(0,-.7,-1.2),Color3.fromRGB(44,45,50))

    if name == "Neon" or name == "Carbon" then
        for _,wheel in ipairs({back,front}) do
            wheel.Material = Enum.Material.Neon
            wheel.Color = frameColor
        end
    end
end

function RunnerService:_connectTagged(tag, callback)
    for _,inst in ipairs(CollectionService:GetTagged(tag)) do callback(inst) end
    table.insert(self.connections, CollectionService:GetInstanceAddedSignal(tag):Connect(callback))
end

function RunnerService:Start()
    self:_connectTagged("RunnerObstacle", function(obstacle)
        if obstacle:GetAttribute("_Hooked") then return end
        obstacle:SetAttribute("_Hooked",true)
        obstacle.Touched:Connect(function(hit)
            local player = findPlayer(hit)
            if not player then return end
            local state = self.states[player]
            if not state or not state.running then return end

            local kind = obstacle:GetAttribute("ObstacleType")
            if kind == "Slide" and state.sliding then return end

            if state.shield and state.shield > 0 then
                state.shield -= 1
                player:SetAttribute("Shield",state.shield)
                self.remotes.Toast:FireClient(player,"Щит спас тебя!")
                obstacle.CanTouch = false
                task.delay(.8,function()
                    if obstacle.Parent then obstacle.CanTouch = true end
                end)
                return
            end
            self:EndRun(player,"CRASH")
        end)
    end)

    self:_connectTagged("RunnerCoin", function(coin)
        if coin:GetAttribute("_Hooked") then return end
        coin:SetAttribute("_Hooked",true)
        coin.Touched:Connect(function(hit)
            local player = findPlayer(hit)
            if not player then return end
            local state = self.states[player]
            if not state or not state.running then return end
            if coin:GetAttribute("Taken") then return end
            coin:SetAttribute("Taken",true)
            coin.Transparency = 1
            coin.CanTouch = false
            local value = coin:GetAttribute("CoinValue") or 1
            state.coins += value
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
        local state = self.states[player]
        if not state then return end
        if action == "Slide" then
            state.sliding = value == true
        end
    end)

    self.remotes.BikeAction.OnServerEvent:Connect(function(player,bikeName)
        if type(bikeName) ~= "string" then return end
        local info = Config.BIKES[bikeName]
        if not info then return end
        local ok,msg = self.data:BuyBike(player,bikeName,info)
        if ok then self:_attachBike(player) end
        self.remotes.Profile:FireClient(player,self.data:GetPublicProfile(player),Config.BIKES,msg)
    end)

    self.remotes.RequestProfile.OnServerInvoke = function(player)
        return self.data:GetPublicProfile(player), Config.BIKES
    end

    self.remotes.RequestTop.OnServerInvoke = function(player)
        return self.data:GetTop(10)
    end

    RunService.Heartbeat:Connect(function(dt)
        self.lastUpdate += dt
        if self.lastUpdate < .15 then return end
        self.lastUpdate = 0

        local maxZ = 0
        for player,state in pairs(self.states) do
            if state.running then
                local character = player.Character
                local root = character and character:FindFirstChild("HumanoidRootPart")
                if root then
                    local score = math.max(0,math.floor(root.Position.Z - Config.START_Z))
                    state.score = score
                    maxZ = math.max(maxZ,root.Position.Z)
                    player:SetAttribute("Score",score)
                    local _,bike = self:_bikeInfo(player)
                    local speed = math.min(Config.MAX_SPEED, Config.BASE_SPEED + math.floor(score/250)*Config.SPEED_PER_250 + bike.speedBonus)
                    player:SetAttribute("RunSpeed",speed)
                end
            end
        end

        if maxZ > self.track:GetEndZ() - 1200 then
            self.track:GenerateMore(Config.GENERATE_BATCH)
        end
    end)
end

function RunnerService:BeginRun(player)
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then return end

    local _,bike = self:_bikeInfo(player)
    self.states[player] = {
        running = true,
        score = 0,
        coins = 0,
        sliding = false,
        shield = bike.shield or 0,
    }

    humanoid.AutoRotate = false
    humanoid.WalkSpeed = 0
    root.AssemblyLinearVelocity = Vector3.zero
    root.CFrame = CFrame.new(0,4,Config.START_Z)

    player:SetAttribute("Running",true)
    player:SetAttribute("Score",0)
    player:SetAttribute("RunCoins",0)
    player:SetAttribute("Shield",bike.shield or 0)
    player:SetAttribute("RunSpeed",Config.BASE_SPEED + bike.speedBonus)
    self:_attachBike(player)
    self.remotes.RunStarted:FireClient(player)
end

function RunnerService:EndRun(player,reason)
    local state = self.states[player]
    if not state or not state.running then return end
    state.running = false

    local gain = self.data:FinishRun(player,state.score,state.coins)
    player:SetAttribute("Running",false)
    self.remotes.RunEnded:FireClient(player,{
        score = state.score,
        coins = state.coins,
        ratingGain = gain,
        reason = reason,
        profile = self.data:GetPublicProfile(player),
    })

    task.delay(1.5,function()
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if root and humanoid then
            root.CFrame = CFrame.new(0,4,Config.START_Z)
            humanoid.AutoRotate = true
            humanoid.WalkSpeed = 16
            root.AssemblyLinearVelocity = Vector3.zero
        end
    end)
end

function RunnerService:PlayerRemoving(player)
    self.states[player] = nil
end

return RunnerService
