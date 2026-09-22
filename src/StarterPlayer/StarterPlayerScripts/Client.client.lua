local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local RunService=game:GetService("RunService")
local UserInputService=game:GetService("UserInputService")

local player=Players.LocalPlayer
local playerGui=player:WaitForChild("PlayerGui")
local R=ReplicatedStorage:WaitForChild("CityRushRemotes")
local bootStatus=R:WaitForChild("BootStatus")
local camera=workspace.CurrentCamera

local function portrait()
    pcall(function() playerGui.ScreenOrientation=Enum.ScreenOrientation.Portrait end)
end
portrait()
task.delay(1,portrait)
task.delay(3,portrait)

local lanes={-8,0,8}
local laneIndex=2
local running=false
local touchStart=nil
local slideUntil=0
local defaultHip=2
local profile=nil
local bikes=nil

local gui=Instance.new("ScreenGui")
gui.Name="CityRushUI"
gui.ResetOnSpawn=false
gui.DisplayOrder=20
gui.Parent=playerGui

local function corner(obj,r)
    local c=Instance.new("UICorner")
    c.CornerRadius=UDim.new(0,r or 12)
    c.Parent=obj
end

local function stroke(obj,t)
    local s=Instance.new("UIStroke")
    s.Color=Color3.new(1,1,1)
    s.Transparency=t or .75
    s.Parent=obj
end

local function label(parent,text,pos,size,fontSize,bold)
    local l=Instance.new("TextLabel")
    l.Position=pos
    l.Size=size
    l.BackgroundTransparency=1
    l.Text=text
    l.TextColor3=Color3.new(1,1,1)
    l.TextSize=fontSize or 16
    l.TextWrapped=true
    l.Font=bold and Enum.Font.GothamBold or Enum.Font.GothamMedium
    l.Parent=parent
    return l
end

local function button(parent,text,pos,size,color)
    local b=Instance.new("TextButton")
    b.Position=pos
    b.Size=size
    b.BackgroundColor3=color
    b.TextColor3=Color3.new(1,1,1)
    b.Text=text
    b.Font=Enum.Font.GothamBold
    b.TextSize=13
    b.BorderSizePixel=0
    corner(b,12)
    stroke(b,.72)
    b.Parent=parent
    return b
end

local topBar=Instance.new("Frame")
topBar.Position=UDim2.new(.5,-155,0,10)
topBar.Size=UDim2.fromOffset(310,58)
topBar.BackgroundColor3=Color3.fromRGB(26,29,44)
topBar.BackgroundTransparency=.08
topBar.BorderSizePixel=0
corner(topBar,16)
stroke(topBar,.76)
topBar.Parent=gui

local title=label(topBar,"CITY RUSH",UDim2.fromOffset(12,5),UDim2.fromOffset(95,24),16,true)
title.TextColor3=Color3.fromRGB(255,214,82)
local coins=label(topBar,"0 coins",UDim2.fromOffset(112,5),UDim2.fromOffset(90,24),14,true)
coins.TextColor3=Color3.fromRGB(255,214,82)
local rating=label(topBar,"R 0",UDim2.fromOffset(208,5),UDim2.fromOffset(88,24),14,true)
local best=label(topBar,"BEST 0",UDim2.fromOffset(12,30),UDim2.fromOffset(100,20),12,false)
best.TextColor3=Color3.fromRGB(126,217,255)
local bikeInfo=label(topBar,"BMX LV.1",UDim2.fromOffset(120,30),UDim2.fromOffset(170,20),12,true)
bikeInfo.TextXAlignment=Enum.TextXAlignment.Right

local lobbyButtons=Instance.new("Frame")
lobbyButtons.Position=UDim2.new(.5,-155,1,-72)
lobbyButtons.Size=UDim2.fromOffset(310,58)
lobbyButtons.BackgroundTransparency=1
lobbyButtons.Parent=gui

local home=button(lobbyButtons,"МОЙ ГАРАЖ",UDim2.fromOffset(0,0),UDim2.fromOffset(98,52),Color3.fromRGB(225,158,66))
local shop=button(lobbyButtons,"ВЕЛИКИ",UDim2.fromOffset(106,0),UDim2.fromOffset(98,52),Color3.fromRGB(73,151,238))
local topBtn=button(lobbyButtons,"ТОП",UDim2.fromOffset(212,0),UDim2.fromOffset(98,52),Color3.fromRGB(171,86,225))

local hud=Instance.new("Frame")
hud.Size=UDim2.fromScale(1,1)
hud.BackgroundTransparency=1
hud.Visible=false
hud.Parent=gui
local score=label(hud,"0 m",UDim2.new(.5,-100,.06,0),UDim2.fromOffset(200,50),34,true)
local runCoins=label(hud,"● 0",UDim2.fromOffset(16,20),UDim2.fromOffset(110,36),17,true)
runCoins.TextColor3=Color3.fromRGB(255,218,74)
local shield=label(hud,"",UDim2.new(1,-126,0,20),UDim2.fromOffset(110,36),15,true)
shield.TextColor3=Color3.fromRGB(100,232,255)
local swipe=label(hud,"SWIPE",UDim2.new(.5,-60,1,-58),UDim2.fromOffset(120,30),12,true)
swipe.TextTransparency=.5

local modal=Instance.new("Frame")
modal.Position=UDim2.new(.5,-165,.13,0)
modal.Size=UDim2.new(0,330,.70,0)
modal.BackgroundColor3=Color3.fromRGB(24,27,43)
modal.BorderSizePixel=0
modal.Visible=false
corner(modal,18)
stroke(modal,.7)
modal.Parent=gui

local modalTitle=label(modal,"",UDim2.fromOffset(16,10),UDim2.new(1,-70,0,40),21,true)
modalTitle.TextXAlignment=Enum.TextXAlignment.Left
local close=button(modal,"×",UDim2.new(1,-50,0,8),UDim2.fromOffset(40,40),Color3.fromRGB(87,58,82))

local list=Instance.new("ScrollingFrame")
list.Position=UDim2.fromOffset(10,58)
list.Size=UDim2.new(1,-20,1,-68)
list.BackgroundTransparency=1
list.BorderSizePixel=0
list.ScrollBarThickness=4
list.CanvasSize=UDim2.fromOffset(0,0)
list.Parent=modal
local layout=Instance.new("UIListLayout")
layout.Padding=UDim.new(0,8)
layout.Parent=list

local toast=label(gui,"",UDim2.new(.5,-145,.78,0),UDim2.fromOffset(290,54),15,true)
toast.BackgroundTransparency=.08
toast.BackgroundColor3=Color3.fromRGB(25,29,43)
toast.Visible=false
corner(toast,14)
stroke(toast,.74)

local boot=label(gui,"CITY RUSH • загрузка",UDim2.new(.5,-145,0,74),UDim2.fromOffset(290,32),12,true)
boot.BackgroundTransparency=.12
boot.BackgroundColor3=Color3.fromRGB(25,29,43)
corner(boot,10)

local function showToast(text)
    toast.Text=tostring(text)
    toast.Visible=true
    task.delay(2.2,function()
        if toast.Text==tostring(text) then toast.Visible=false end
    end)
end

local function refreshBoot()
    local s=bootStatus.Value
    if s=="READY" then boot.Visible=false
    else
        boot.Visible=true
        boot.Text=s
        boot.TextColor3=string.find(s,"ERROR",1,true) and Color3.fromRGB(255,125,125) or Color3.new(1,1,1)
    end
end
bootStatus:GetPropertyChangedSignal("Value"):Connect(refreshBoot)
refreshBoot()

local function refreshStats()
    coins.Text=tostring(player:GetAttribute("Coins") or 0).." coins"
    rating.Text="R "..tostring(player:GetAttribute("Rating") or 0)
    best.Text="BEST "..tostring(player:GetAttribute("Best") or 0)
    bikeInfo.Text=tostring(player:GetAttribute("EquippedBike") or "BMX").." LV."..tostring(player:GetAttribute("BikeLevel") or 1)
end
for _,a in ipairs({"Coins","Rating","Best","EquippedBike","BikeLevel"}) do
    player:GetAttributeChangedSignal(a):Connect(refreshStats)
end
refreshStats()

local function clearList()
    for _,x in ipairs(list:GetChildren()) do
        if not x:IsA("UIListLayout") then x:Destroy() end
    end
end

local bikeOrder={"BMX","Street","Neon","Carbon"}
local function openGarage()
    profile,bikes=R.RequestProfile:InvokeServer()
    clearList()
    modalTitle.Text="ВЕЛИКИ"
    modal.Visible=true

    for _,name in ipairs(bikeOrder) do
        local info=bikes[name]
        local level=profile.bikeLevels[name] or 1
        local owned=profile.ownedBikes[name]==true
        local equipped=profile.equippedBike==name
        local card=Instance.new("Frame")
        card.Size=UDim2.new(1,-4,0,116)
        card.BackgroundColor3=Color3.fromRGB(39,43,64)
        card.BorderSizePixel=0
        corner(card,12)
        card.Parent=list

        local color=Instance.new("Frame")
        color.Position=UDim2.fromOffset(10,12)
        color.Size=UDim2.fromOffset(54,54)
        color.BackgroundColor3=info.color
        color.BorderSizePixel=0
        corner(color,27)
        color.Parent=card

        local n=label(card,info.displayName.."  LV."..level,UDim2.fromOffset(74,8),UDim2.new(1,-170,0,26),17,true)
        n.TextXAlignment=Enum.TextXAlignment.Left
        local d=label(card,info.description,UDim2.fromOffset(74,34),UDim2.new(1,-170,0,42),11,false)
        d.TextXAlignment=Enum.TextXAlignment.Left
        d.TextColor3=Color3.fromRGB(198,201,215)

        local actionText=equipped and "ВЫБРАН" or (owned and "ВЫБРАТЬ" or tostring(info.price))
        local select=button(card,actionText,UDim2.new(1,-94,0,12),UDim2.fromOffset(84,38),owned and Color3.fromRGB(62,153,107) or Color3.fromRGB(194,118,60))
        select.TextSize=11
        select.Activated:Connect(function()
            R.BikeAction:FireServer("Select",name)
        end)

        local upCost=level>=10 and "MAX" or tostring(math.floor(info.upgradeBase*(1.5^(level-1))))
        local upgrade=button(card,"UP "..upCost,UDim2.new(1,-94,0,61),UDim2.fromOffset(84,38),Color3.fromRGB(210,145,64))
        upgrade.TextSize=10
        upgrade.Visible=owned
        upgrade.Activated:Connect(function()
            R.BikeAction:FireServer("Upgrade",name)
        end)
    end

    task.wait()
    list.CanvasSize=UDim2.fromOffset(0,layout.AbsoluteContentSize.Y+8)
end

local function openTop()
    local rows=R.RequestTop:InvokeServer()
    clearList()
    modalTitle.Text="ГЛОБАЛЬНЫЙ ТОП"
    modal.Visible=true
    for _,row in ipairs(rows) do
        local card=Instance.new("Frame")
        card.Size=UDim2.new(1,-4,0,48)
        card.BackgroundColor3=Color3.fromRGB(39,43,64)
        card.BorderSizePixel=0
        corner(card,10)
        card.Parent=list
        local l=label(card,string.format("#%d  %s",row.rank,row.name),UDim2.fromOffset(10,0),UDim2.new(1,-90,1,0),13,true)
        l.TextXAlignment=Enum.TextXAlignment.Left
        local r=label(card,tostring(row.rating),UDim2.new(1,-80,0,0),UDim2.fromOffset(70,48),13,true)
        r.TextColor3=Color3.fromRGB(255,216,82)
    end
    task.wait()
    list.CanvasSize=UDim2.fromOffset(0,layout.AbsoluteContentSize.Y+8)
end

home.Activated:Connect(function() R.LobbyAction:FireServer("Home") end)
shop.Activated:Connect(function() R.LobbyAction:FireServer("Bikes") end)
topBtn.Activated:Connect(openTop)
close.Activated:Connect(function() modal.Visible=false end)

R.Toast.OnClientEvent:Connect(showToast)
R.Profile.OnClientEvent:Connect(function(p,b,msg)
    profile,bikes=p,b
    refreshStats()
    if msg then showToast(msg) end
    if modal.Visible and modalTitle.Text=="ВЕЛИКИ" then openGarage() end
end)

local function setSlide(on)
    local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if on then
        slideUntil=tick()+.72
        hum.HipHeight=math.max(0,defaultHip-1.6)
        R.RunAction:FireServer("Slide",true)
        task.delay(.72,function()
            if tick()>=slideUntil and hum.Parent then
                hum.HipHeight=defaultHip
                R.RunAction:FireServer("Slide",false)
            end
        end)
    else
        hum.HipHeight=defaultHip
        R.RunAction:FireServer("Slide",false)
    end
end

local function moveLane(d)
    laneIndex=math.clamp(laneIndex+d,1,3)
end

local function jump()
    local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum and hum.FloorMaterial~=Enum.Material.Air then hum.Jump=true end
end

UserInputService.InputBegan:Connect(function(input,gp)
    if gp or not running then return end
    if input.UserInputType==Enum.UserInputType.Touch then touchStart=input.Position
    elseif input.KeyCode==Enum.KeyCode.Left or input.KeyCode==Enum.KeyCode.A then moveLane(-1)
    elseif input.KeyCode==Enum.KeyCode.Right or input.KeyCode==Enum.KeyCode.D then moveLane(1)
    elseif input.KeyCode==Enum.KeyCode.Up or input.KeyCode==Enum.KeyCode.W or input.KeyCode==Enum.KeyCode.Space then jump()
    elseif input.KeyCode==Enum.KeyCode.Down or input.KeyCode==Enum.KeyCode.S then setSlide(true) end
end)

UserInputService.InputEnded:Connect(function(input,gp)
    if gp or not running then return end
    if input.UserInputType==Enum.UserInputType.Touch and touchStart then
        local d=input.Position-touchStart
        touchStart=nil
        if d.Magnitude<35 then return end
        if math.abs(d.X)>math.abs(d.Y) then moveLane(d.X>0 and 1 or -1)
        else if d.Y<0 then jump() else setSlide(true) end end
    end
end)

R.RunStarted.OnClientEvent:Connect(function()
    running=true
    laneIndex=2
    topBar.Visible=false
    lobbyButtons.Visible=false
    modal.Visible=false
    hud.Visible=true
    camera.CameraType=Enum.CameraType.Scriptable
    local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then defaultHip=hum.HipHeight end
end)

R.RunEnded.OnClientEvent:Connect(function(result)
    running=false
    hud.Visible=false
    topBar.Visible=true
    lobbyButtons.Visible=true
    camera.CameraType=Enum.CameraType.Custom
    setSlide(false)
    refreshStats()
    showToast(string.format("%d м • %d монет (+%d бонус) • +%d рейтинга",result.score or 0,result.coins or 0,result.bonusCoins or 0,result.ratingGain or 0))
end)

RunService.RenderStepped:Connect(function(dt)
    if not running then return end
    local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local speed=player:GetAttribute("RunSpeed") or 27
    local targetX=lanes[laneIndex]
    local x=root.Position.X+(targetX-root.Position.X)*math.min(1,dt*12)
    local z=root.Position.Z+speed*dt
    local y=root.Position.Y

    root.CFrame=CFrame.new(x,y,z)
    root.AssemblyAngularVelocity=Vector3.zero

    camera.CFrame=CFrame.lookAt(Vector3.new(x*.2,y+7,z-15),Vector3.new(x,y+2.5,z+13))
    camera.FieldOfView=72

    score.Text=tostring(player:GetAttribute("Score") or 0).." m"
    runCoins.Text="● "..tostring(player:GetAttribute("RunCoins") or 0)
    local s=player:GetAttribute("Shield") or 0
    shield.Text=s>0 and ("ЩИТ ×"..s) or ""
end)
