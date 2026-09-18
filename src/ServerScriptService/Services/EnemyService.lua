local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)

local EnemyService = {}
EnemyService.__index = EnemyService

function EnemyService.new(remotes)
    local self = setmetatable({}, EnemyService)
    self.remotes = remotes
    self.folder = workspace:FindFirstChild("CodeRotEnemies") or Instance.new("Folder")
    self.folder.Name = "CodeRotEnemies"
    self.folder.Parent = workspace
    self.active = false
    self.connection = nil
    self.enemies = {}
    self.profile = nil
    return self
end

function EnemyService:Stop()
    self.active = false
    if self.connection then self.connection:Disconnect(); self.connection = nil end
    self.folder:ClearAllChildren()
    self.enemies = {}
end

function EnemyService:SpawnEnemy(index, spawnPosition)
    local profile = self.profile or {name="NULL_USER", speed=13, damage=30}
    local model = Instance.new("Model")
    model.Name = profile.name .. (index > 1 and ("_" .. index) or "")
    local root = Instance.new("Part")
    root.Name = "HumanoidRootPart"
    root.Size = Vector3.new(3.2, 6.2, 2.4)
    local angle = (index / math.max(1, profile.count or 1)) * math.pi * 2
    root.CFrame = CFrame.new(spawnPosition + Vector3.new(math.cos(angle)*220, 3, math.sin(angle)*220 + 120))
    root.Color = Color3.fromRGB(7 + index*3, 7, 10 + index*4)
    root.Material = Enum.Material.SmoothPlastic
    root.Anchored = true
    root.CanCollide = false
    root.Parent = model
    local face = Instance.new("SurfaceGui"); face.Face=Enum.NormalId.Front; face.Parent=root
    local label = Instance.new("TextLabel"); label.Size=UDim2.fromScale(1,1); label.BackgroundTransparency=1; label.Text="["..profile.name.."]"; label.TextColor3=Color3.fromRGB(255,255,255); label.TextScaled=true; label.Font=Enum.Font.Code; label.Parent=face
    local light = Instance.new("PointLight"); light.Color=Color3.fromRGB(170,70,255); light.Range=12; light.Brightness=0.7; light.Parent=root
    model.PrimaryPart = root
    model.Parent = self.folder
    table.insert(self.enemies, model)
end

function EnemyService:Start(chapter, spawnPosition)
    self:Stop()
    self.active = true
    self.profile = chapter.enemy or {name="NULL_USER", speed=13, damage=30, spawnPulse=2, count=1}
    local delaySeconds = math.max(3, (self.profile.spawnPulse or 1) * Config.WORLD_UPDATE_INTERVAL)
    task.delay(delaySeconds, function()
        if not self.active then return end
        for i = 1, math.max(1, self.profile.count or 1) do self:SpawnEnemy(i, spawnPosition) end
        self.remotes.Toast:FireAllClients((self.profile.name or "NULL_USER") .. " подключился к серверу.")
        self:RunAI()
    end)
end

function EnemyService:RunAI()
    if self.connection then self.connection:Disconnect() end
    local lastHit = {}
    self.connection = RunService.Heartbeat:Connect(function(dt)
        if not self.active then return end
        for index, model in ipairs(self.enemies) do
            if model.Parent and model.PrimaryPart then
                local root = model.PrimaryPart
                local nearestRoot, nearestHum, nearestDist = nil, nil, math.huge
                for _, player in ipairs(Players:GetPlayers()) do
                    if player:GetAttribute("InRound") then
                        local char = player.Character
                        local pr = char and char:FindFirstChild("HumanoidRootPart")
                        local hum = char and char:FindFirstChildOfClass("Humanoid")
                        if pr and hum and hum.Health > 0 then
                            local d = (pr.Position - root.Position).Magnitude
                            if d < nearestDist then nearestRoot, nearestHum, nearestDist = pr, hum, d end
                        end
                    end
                end
                if nearestRoot then
                    local flat = Vector3.new(nearestRoot.Position.X-root.Position.X, 0, nearestRoot.Position.Z-root.Position.Z)
                    if flat.Magnitude > 1 then
                        local wobble = Vector3.new(math.sin(os.clock()*1.7 + index)*0.8, 0, math.cos(os.clock()*1.3 + index)*0.8)
                        local speed = (self.profile.speed or 13) * (1 + math.min(index-1,3)*0.03)
                        local direction = (flat.Unit + wobble*0.08).Unit
                        local nextPos = root.Position + direction * speed * dt
                        root.CFrame = CFrame.lookAt(nextPos, Vector3.new(nearestRoot.Position.X, nextPos.Y, nearestRoot.Position.Z))
                    end
                    if nearestDist < 5.2 then
                        local now = os.clock()
                        if (lastHit[model] or 0) + 1.25 < now then
                            lastHit[model] = now
                            nearestHum:TakeDamage(self.profile.damage or 30)
                        end
                    end
                end
            end
        end
    end)
end

return EnemyService
