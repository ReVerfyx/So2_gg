local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local R = ReplicatedStorage:WaitForChild("CityRushRemotes")
local bootStatus = R:WaitForChild("BootStatus")
local camera = workspace.CurrentCamera

local function forcePortrait()
    pcall(function()
        playerGui.ScreenOrientation = Enum.ScreenOrientation.Portrait
    end)
end

forcePortrait()
task.delay(1, forcePortrait)
task.delay(3, forcePortrait)

local lanes = {-8,0,8}
local laneIndex = 2
local running = false
local slideUntil = 0
local defaultHip = 2
local touchStart = nil
local profile = nil
local bikes = nil

local gui = Instance.new("ScreenGui")
gui.Name = "CityRushUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 20
gui.Parent = playerGui

local function corner(obj,r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,r or 14)
    c.Parent = obj
end

local function stroke(obj,trans)
    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(255,255,255)
    s.Transparency = trans or .75
    s.Thickness = 1
    s.Parent = obj
end

local function gradient(obj,a,b,rot)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(a,b)
    g.Rotation = rot or 90
    g.Parent = obj
end

local function label(parent,text,pos,size,fontSize,bold)
    local l = Instance.new("TextLabel")
    l.Position = pos
    l.Size = size
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.new(1,1,1)
    l.TextSize = fontSize or 18
    l.TextWrapped = true
    l.Font = bold and Enum.Font.GothamBlack or Enum.Font.GothamMedium
    l.Parent = parent
    return l
end

local function button(parent,text,pos,size,color)
    local b = Instance.new("TextButton")
    b.Position = pos
    b.Size = size
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.TextSize = 18
    b.Font = Enum.Font.GothamBold
    b.BackgroundColor3 = color
    b.BorderSizePixel = 0
    b.AutoButtonColor = true
    corner(b,14)
    stroke(b,.72)
    gradient(b,color:Lerp(Color3.new(1,1,1),.12),color:Lerp(Color3.new(0,0,0),.18),90)
    b.Parent = parent
    return b
end

local menu = Instance.new("Frame")
menu.Size = UDim2.fromScale(1,1)
menu.BackgroundTransparency = 1
menu.Parent = gui

local bootBanner = Instance.new("TextLabel")
bootBanner.AnchorPoint = Vector2.new(.5,0)
bootBanner.Position = UDim2.new(.5,0,0,8)
bootBanner.Size = UDim2.new(.82,0,0,36)
bootBanner.BackgroundColor3 = Color3.fromRGB(28,31,48)
bootBanner.BackgroundTransparency = .08
bootBanner.BorderSizePixel = 0
bootBanner.TextColor3 = Color3.fromRGB(255,230,155)
bootBanner.TextSize = 13
bootBanner.Font = Enum.Font.GothamBold
bootBanner.Text = "CITY RUSH • загрузка..."
corner(bootBanner,12)
stroke(bootBanner,.72)
bootBanner.Parent = gui

local function refreshBoot()
    local status = bootStatus.Value
    if status == "READY" then
        bootBanner.Visible = false
    elseif string.find(status,"ERROR",1,true) then
        bootBanner.Visible = true
        bootBanner.Text = "ОШИБКА ЗАПУСКА: " .. status
        bootBanner.TextColor3 = Color3.fromRGB(255,130,130)
    else
        bootBanner.Visible = true
        bootBanner.Text = "CITY RUSH • " .. status
    end
end
bootStatus:GetPropertyChangedSignal("Value"):Connect(refreshBoot)
refreshBoot()

local titleShadow = label(menu,"CITY\nRUSH",UDim2.new(.5,-150,.08,6),UDim2.fromOffset(300,150),54,true)
titleShadow.TextColor3 = Color3.fromRGB(63,48,88)
local title = label(menu,"CITY\nRUSH",UDim2.new(.5,-154,.08,0),UDim2.fromOffset(300,150),54,true)
title.TextColor3 = Color3.fromRGB(255,211,75)

local subtitle = label(menu,"ВЕРТИКАЛЬНЫЙ CITY RUNNER",UDim2.new(.5,-150,.27,0),UDim2.fromOffset(300,34),14,true)
subtitle.TextColor3 = Color3.fromRGB(240,240,250)

local statCard = Instance.new("Frame")
statCard.Position = UDim2.new(.5,-145,.34,0)
statCard.Size = UDim2.fromOffset(290,72)
statCard.BackgroundColor3 = Color3.fromRGB(31,35,54)
statCard.BackgroundTransparency = .08
statCard.BorderSizePixel = 0
corner(statCard,18)
stroke(statCard,.75)
statCard.Parent = menu

local coinsLabel = label(statCard,"0 coins",UDim2.fromOffset(16,7),UDim2.fromOffset(130,26),17,true)
coinsLabel.TextXAlignment = Enum.TextXAlignment.Left
coinsLabel.TextColor3 = Color3.fromRGB(255,216,82)
local ratingLabel = label(statCard,"0 rating",UDim2.fromOffset(16,38),UDim2.fromOffset(130,26),15,false)
ratingLabel.TextXAlignment = Enum.TextXAlignment.Left
local bestLabel = label(statCard,"BEST 0",UDim2.new(1,-136,0,21),UDim2.fromOffset(120,30),15,true)
bestLabel.TextColor3 = Color3.fromRGB(114,219,255)

local play = button(menu,"ИГРАТЬ",UDim2.new(.5,-145,.55,0),UDim2.fromOffset(290,64),Color3.fromRGB(67,196,122))
local garage = button(menu,"ВЕЛИКИ",UDim2.new(.5,-145,.65,0),UDim2.fromOffset(140,54),Color3.fromRGB(88,134,242))
local top = button(menu,"ТОП",UDim2.new(.5,5,.65,0),UDim2.fromOffset(140,54),Color3.fromRGB(180,91,231))
local hint = label(menu,"Свайп ← →  •  вверх = прыжок  •  вниз = подкат",UDim2.new(.5,-170,.78,0),UDim2.fromOffset(340,54),13,false)
hint.TextColor3 = Color3.fromRGB(220,220,230)

local hud = Instance.new("Frame")
hud.Size = UDim2.fromScale(1,1)
hud.BackgroundTransparency = 1
hud.Visible = false
hud.Parent = gui

local score = label(hud,"0",UDim2.new(.5,-100,.04,0),UDim2.fromOffset(200,60),38,true)
score.TextColor3 = Color3.fromRGB(255,255,255)
local runCoins = label(hud,"● 0",UDim2.fromOffset(18,22),UDim2.fromOffset(120,40),18,true)
runCoins.TextColor3 = Color3.fromRGB(255,218,74)
local shield = label(hud,"",UDim2.new(1,-130,0,22),UDim2.fromOffset(110,40),16,true)
shield.TextColor3 = Color3.fromRGB(103,229,255)
local swipeHint = label(hud,"SWIPE",UDim2.new(.5,-60,1,-72),UDim2.fromOffset(120,34),13,true)
swipeHint.TextTransparency = .5

local modal = Instance.new("Frame")
modal.Position = UDim2.new(.5,-165,.12,0)
modal.Size = UDim2.new(0,330,.76,0)
modal.BackgroundColor3 = Color3.fromRGB(24,27,43)
modal.BackgroundTransparency = .03
modal.BorderSizePixel = 0
modal.Visible = false
corner(modal,20)
stroke(modal,.7)
modal.Parent = gui

local modalTitle = label(modal,"",UDim2.fromOffset(18,12),UDim2.new(1,-76,0,42),24,true)
modalTitle.TextXAlignment = Enum.TextXAlignment.Left
local close = button(modal,"×",UDim2.new(1,-52,0,10),UDim2.fromOffset(42,42),Color3.fromRGB(86,57,80))

local list = Instance.new("ScrollingFrame")
list.Position = UDim2.fromOffset(12,62)
list.Size = UDim2.new(1,-24,1,-74)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 4
list.CanvasSize = UDim2.fromOffset(0,0)
list.Parent = modal
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0,10)
layout.Parent = list

local function refreshStats()
    coinsLabel.Text = tostring(player:GetAttribute("Coins") or 0) .. " coins"
    ratingLabel.Text = tostring(player:GetAttribute("Rating") or 0) .. " rating"
    bestLabel.Text = "BEST " .. tostring(player:GetAttribute("Best") or 0)
end

for _,attr in ipairs({"Coins","Rating","Best"}) do
    player:GetAttributeChangedSignal(attr):Connect(refreshStats)
end

local function clearList()
    for _,c in ipairs(list:GetChildren()) do
        if not c:IsA("UIListLayout") then c:Destroy() end
    end
end

local bikeOrder = {"BMX","Street","Neon","Carbon"}
local function openGarage()
    profile,bikes = R.RequestProfile:InvokeServer()
    clearList()
    modalTitle.Text = "ВЕЛИКИ"
    modal.Visible = true

    for _,name in ipairs(bikeOrder) do
        local info = bikes[name]
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1,-4,0,105)
        card.BackgroundColor3 = Color3.fromRGB(39,43,64)
        card.BorderSizePixel = 0
        corner(card,14)
        card.Parent = list

        local swatch = Instance.new("Frame")
        swatch.Position = UDim2.fromOffset(12,14)
        swatch.Size = UDim2.fromOffset(54,54)
        swatch.BackgroundColor3 = info.color
        swatch.BorderSizePixel = 0
        corner(swatch,27)
        swatch.Parent = card

        local n = label(card,info.displayName,UDim2.fromOffset(76,10),UDim2.new(1,-170,0,28),18,true)
        n.TextXAlignment = Enum.TextXAlignment.Left
        local d = label(card,info.description,UDim2.fromOffset(76,38),UDim2.new(1,-170,0,44),12,false)
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.TextColor3 = Color3.fromRGB(195,198,215)

        local owned = profile.ownedBikes[name] == true
        local equipped = profile.equippedBike == name
        local text = equipped and "ВЫБРАН" or (owned and "ВЫБРАТЬ" or tostring(info.price))
        local buy = button(card,text,UDim2.new(1,-96,.5,-21),UDim2.fromOffset(84,42),owned and Color3.fromRGB(64,151,107) or Color3.fromRGB(196,121,65))
        buy.TextSize = 12
        buy.Activated:Connect(function()
            R.BikeAction:FireServer(name)
        end)
    end

    task.wait()
    list.CanvasSize = UDim2.fromOffset(0,layout.AbsoluteContentSize.Y+8)
end

local function openTop()
    local rows = R.RequestTop:InvokeServer()
    clearList()
    modalTitle.Text = "ГЛОБАЛЬНЫЙ ТОП"
    modal.Visible = true

    if #rows == 0 then
        local empty = label(list,"Рейтинг пока пуст.",UDim2.fromOffset(0,0),UDim2.new(1,0,0,50),16,false)
        empty.Parent = list
    else
        for _,row in ipairs(rows) do
            local card = Instance.new("Frame")
            card.Size = UDim2.new(1,-4,0,52)
            card.BackgroundColor3 = Color3.fromRGB(39,43,64)
            card.BorderSizePixel = 0
            corner(card,12)
            card.Parent = list
            local l = label(card,string.format("#%d  %s",row.rank,row.name),UDim2.fromOffset(12,0),UDim2.new(1,-100,1,0),14,true)
            l.TextXAlignment = Enum.TextXAlignment.Left
            local r = label(card,tostring(row.rating),UDim2.new(1,-90,0,0),UDim2.fromOffset(76,52),14,true)
            r.TextColor3 = Color3.fromRGB(255,216,82)
        end
    end
    task.wait()
    list.CanvasSize = UDim2.fromOffset(0,layout.AbsoluteContentSize.Y+8)
end

close.Activated:Connect(function() modal.Visible=false end)
garage.Activated:Connect(openGarage)
top.Activated:Connect(openTop)

R.Profile.OnClientEvent:Connect(function(newProfile,newBikes,message)
    profile,bikes = newProfile,newBikes
    refreshStats()
    if modal.Visible and modalTitle.Text == "ВЕЛИКИ" then
        openGarage()
    end
end)

local function setSlide(on)
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if on then
        slideUntil = tick()+.75
        hum.HipHeight = math.max(0,defaultHip-1.6)
        R.RunAction:FireServer("Slide",true)
        task.delay(.75,function()
            if tick() >= slideUntil and hum.Parent then
                hum.HipHeight = defaultHip
                R.RunAction:FireServer("Slide",false)
            end
        end)
    else
        slideUntil = 0
        hum.HipHeight = defaultHip
        R.RunAction:FireServer("Slide",false)
    end
end

local function moveLane(delta)
    laneIndex = math.clamp(laneIndex + delta,1,3)
end

local function jump()
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and hum.FloorMaterial ~= Enum.Material.Air then
        hum.Jump = true
    end
end

UserInputService.InputBegan:Connect(function(input,gp)
    if gp or not running then return end
    if input.UserInputType == Enum.UserInputType.Touch then
        touchStart = input.Position
    elseif input.KeyCode == Enum.KeyCode.Left or input.KeyCode == Enum.KeyCode.A then
        moveLane(-1)
    elseif input.KeyCode == Enum.KeyCode.Right or input.KeyCode == Enum.KeyCode.D then
        moveLane(1)
    elseif input.KeyCode == Enum.KeyCode.Up or input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.Space then
        jump()
    elseif input.KeyCode == Enum.KeyCode.Down or input.KeyCode == Enum.KeyCode.S then
        setSlide(true)
    end
end)

UserInputService.InputEnded:Connect(function(input,gp)
    if gp or not running then return end
    if input.UserInputType == Enum.UserInputType.Touch and touchStart then
        local delta = input.Position - touchStart
        touchStart = nil
        if delta.Magnitude < 35 then return end
        if math.abs(delta.X) > math.abs(delta.Y) then
            moveLane(delta.X > 0 and 1 or -1)
        else
            if delta.Y < 0 then jump() else setSlide(true) end
        end
    end
end)

play.Activated:Connect(function()
    modal.Visible = false
    R.StartRun:FireServer()
end)

R.RunStarted.OnClientEvent:Connect(function()
    running = true
    laneIndex = 2
    menu.Visible = false
    modal.Visible = false
    hud.Visible = true
    camera.CameraType = Enum.CameraType.Scriptable

    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then defaultHip = hum.HipHeight end
end)

R.RunEnded.OnClientEvent:Connect(function(result)
    running = false
    hud.Visible = false
    menu.Visible = true
    camera.CameraType = Enum.CameraType.Custom
    setSlide(false)
    refreshStats()

    local summary = Instance.new("TextLabel")
    summary.AnchorPoint = Vector2.new(.5,.5)
    summary.Position = UDim2.fromScale(.5,.46)
    summary.Size = UDim2.fromOffset(300,130)
    summary.BackgroundColor3 = Color3.fromRGB(28,31,48)
    summary.BackgroundTransparency = .04
    summary.BorderSizePixel = 0
    summary.TextColor3 = Color3.new(1,1,1)
    summary.TextSize = 20
    summary.Font = Enum.Font.GothamBold
    summary.TextWrapped = true
    summary.Text = string.format("ЗАЕЗД ОКОНЧЕН\n%d м   •   %d монет\n+%d рейтинга",result.score or 0,result.coins or 0,result.ratingGain or 0)
    corner(summary,18)
    stroke(summary,.7)
    summary.Parent = gui
    task.delay(3,function() if summary.Parent then summary:Destroy() end end)
end)

RunService.RenderStepped:Connect(function(dt)
    if not running then return end
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    local speed = player:GetAttribute("RunSpeed") or 27
    local targetX = lanes[laneIndex]
    local x = root.Position.X + (targetX-root.Position.X) * math.min(1,dt*12)
    local z = root.Position.Z + speed*dt
    local y = root.Position.Y

    root.CFrame = CFrame.new(x,y,z)
    root.AssemblyAngularVelocity = Vector3.zero

    local camPos = Vector3.new(x*0.2,y+7,z-15)
    local look = Vector3.new(x,y+2.5,z+13)
    camera.CFrame = CFrame.lookAt(camPos,look)
    camera.FieldOfView = 72

    score.Text = tostring(player:GetAttribute("Score") or 0) .. " m"
    runCoins.Text = "● " .. tostring(player:GetAttribute("RunCoins") or 0)
    local s = player:GetAttribute("Shield") or 0
    shield.Text = s > 0 and ("ЩИТ ×"..s) or ""
end)

refreshStats()
