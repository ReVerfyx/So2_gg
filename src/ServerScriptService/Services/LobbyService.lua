local SoundService=game:GetService("SoundService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")

local Config=require(ReplicatedStorage.Shared.Config)
local BikeFactory=require(script.Parent.BikeFactory)

local LobbyService={}
LobbyService.__index=LobbyService

local function part(parent,name,size,pos,color,material,collide)
    local p=Instance.new("Part")
    p.Name=name
    p.Anchored=true
    p.Size=size
    p.Position=pos
    p.Color=color
    p.Material=material or Enum.Material.SmoothPlastic
    p.CanCollide=collide~=false
    p.TopSurface=Enum.SurfaceType.Smooth
    p.BottomSurface=Enum.SurfaceType.Smooth
    p.Parent=parent
    return p
end

local function cornerLight(parent,pos,color)
    part(parent,"LobbyLamp",Vector3.new(1.2,10,1.2),pos+Vector3.new(0,5,0),Color3.fromRGB(48,52,64),Enum.Material.Metal,true)
    local bulb=part(parent,"LobbyLampGlow",Vector3.new(2,2,2),pos+Vector3.new(0,10.5,0),color,Enum.Material.Neon,false)
    bulb.Shape=Enum.PartType.Ball
    local l=Instance.new("PointLight")
    l.Color=color
    l.Range=30
    l.Brightness=2
    l.Shadows=true
    l.Parent=bulb
end

local function surface(partObj,text,color)
    local gui=Instance.new("SurfaceGui")
    gui.Face=Enum.NormalId.Front
    gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud=24
    gui.Parent=partObj
    local t=Instance.new("TextLabel")
    t.Size=UDim2.fromScale(1,1)
    t.BackgroundTransparency=1
    t.Text=text
    t.TextScaled=true
    t.TextWrapped=true
    t.Font=Enum.Font.GothamBold
    t.TextColor3=color or Color3.new(1,1,1)
    t.TextStrokeTransparency=.65
    t.Parent=gui
    return t
end

local function prompt(parent,action,object,hold)
    local p=Instance.new("ProximityPrompt")
    p.ActionText=action
    p.ObjectText=object
    p.HoldDuration=hold or 0
    p.MaxActivationDistance=12
    p.RequiresLineOfSight=false
    p.Parent=parent
    return p
end

function LobbyService.new(data,remotes)
    local self=setmetatable({},LobbyService)
    self.data=data
    self.remotes=remotes
    self.root=nil
    self.plots={}
    self.playerPlot={}
    self.runner=nil
    return self
end

function LobbyService:SetRunner(runner)
    self.runner=runner
end

function LobbyService:_garagePosition(index)
    local left=index<=6
    local row=left and index or (index-6)
    local x=Config.LOBBY_CENTER.X+(left and -88 or 88)
    local z=Config.LOBBY_CENTER.Z-145+(row-1)*56
    return Vector3.new(x,0,z),left
end

function LobbyService:_buildGarage(index)
    local pos,left=self:_garagePosition(index)
    local m=Instance.new("Model")
    m.Name="Garage_"..index
    m.Parent=self.root
    m:SetAttribute("PlotIndex",index)

    local accent=({Color3.fromRGB(255,173,77),Color3.fromRGB(74,173,255),Color3.fromRGB(103,218,143),Color3.fromRGB(219,103,255)})[((index-1)%4)+1]

    part(m,"Plot",Vector3.new(68,1,48),pos+Vector3.new(0,.5,0),Color3.fromRGB(77,83,96),Enum.Material.Concrete,true)
    part(m,"Back",Vector3.new(64,18,2),pos+Vector3.new(0,9,left and -22 or 22),Color3.fromRGB(42,46,58),Enum.Material.Concrete,true)
    part(m,"SideA",Vector3.new(2,18,48),pos+Vector3.new(-31,9,0),Color3.fromRGB(47,51,64),Enum.Material.Concrete,true)
    part(m,"SideB",Vector3.new(2,18,48),pos+Vector3.new(31,9,0),Color3.fromRGB(47,51,64),Enum.Material.Concrete,true)
    part(m,"Roof",Vector3.new(66,1,50),pos+Vector3.new(0,18,0),Color3.fromRGB(30,33,43),Enum.Material.Metal,true)

    part(m,"AccentStrip",Vector3.new(50,.6,.6),pos+Vector3.new(0,16,left and -23.1 or 23.1),accent,Enum.Material.Neon,false)

    local sign=part(m,"OwnerSign",Vector3.new(42,7,.8),pos+Vector3.new(0,12,left and -23.2 or 23.2),Color3.fromRGB(31,34,45),Enum.Material.SmoothPlastic,true)
    if left then sign.Orientation=Vector3.new(0,180,0) end
    local signText=surface(sign,"СВОБОДНЫЙ ГАРАЖ",Color3.fromRGB(210,214,225))

    part(m,"BikePedestal",Vector3.new(16,1,13),pos+Vector3.new(0,1,0),Color3.fromRGB(29,32,42),Enum.Material.Metal,true)
    local displayFolder=Instance.new("Folder")
    displayFolder.Name="BikeDisplay"
    displayFolder.Parent=m

    local visit=part(m,"VisitPad",Vector3.new(18,.7,8),pos+Vector3.new(0,.4,left and 19 or -19),accent,Enum.Material.Neon,true)
    visit.Transparency=.18
    local pp=prompt(visit,"ПОСЕТИТЬ / VISIT","Гараж "..index,.1)
    pp.Enabled=false

    self.plots[index]={
        model=m,pos=pos,left=left,signText=signText,
        display=displayFolder,visitPrompt=pp,owner=nil,
    }

    pp.Triggered:Connect(function(player)
        local plot=self.plots[index]
        if plot and plot.owner then self:TeleportToPlot(player,index) end
    end)
end

function LobbyService:_buildShowroom()
    local c=Config.SHOWROOM_CENTER
    local room=Instance.new("Model")
    room.Name="BikeShowroom"
    room.Parent=self.root

    part(room,"Floor",Vector3.new(150,1,92),c+Vector3.new(0,.5,0),Color3.fromRGB(55,59,73),Enum.Material.Concrete,true)
    part(room,"BackWall",Vector3.new(150,25,2),c+Vector3.new(0,12.5,44),Color3.fromRGB(35,39,51),Enum.Material.Concrete,true)
    part(room,"Roof",Vector3.new(154,1,96),c+Vector3.new(0,25,0),Color3.fromRGB(25,28,38),Enum.Material.Metal,true)

    local title=part(room,"Title",Vector3.new(70,9,1),c+Vector3.new(0,19,43),Color3.fromRGB(28,31,42),Enum.Material.SmoothPlastic,true)
    surface(title,"BIKE SHOP • ПРОКАЧКА",Color3.fromRGB(255,216,91))

    local order={"BMX","Street","Neon","Carbon"}
    for i,name in ipairs(order) do
        local info=Config.BIKES[name]
        local x=(i-2.5)*34
        part(room,"Stand_"..name,Vector3.new(26,1,24),c+Vector3.new(x,1,4),Color3.fromRGB(37,41,54),Enum.Material.Metal,true)
        BikeFactory.BuildDisplay(room,name,1,CFrame.new(c+Vector3.new(x,3,4))*CFrame.Angles(0,math.rad(90),0))

        local plate=part(room,"Plate_"..name,Vector3.new(24,7,1),c+Vector3.new(x,10,16.5),Color3.fromRGB(29,32,43),Enum.Material.SmoothPlastic,true)
        surface(plate,info.displayName.."\n"..info.price.." COINS",info.accent)

        local buyPad=part(room,"Buy_"..name,Vector3.new(11,.7,5),c+Vector3.new(x-6,.4,-8),Color3.fromRGB(71,190,124),Enum.Material.Neon,true)
        prompt(buyPad,"КУПИТЬ / ВЫБРАТЬ",info.displayName,.15).Triggered:Connect(function(player)
            local ok,msg=self.data:BuyOrEquipBike(player,name)
            self.remotes.Toast:FireClient(player,msg)
            if ok then self:RefreshPlayer(player) end
        end)

        local upPad=part(room,"Upgrade_"..name,Vector3.new(11,.7,5),c+Vector3.new(x+6,.4,-8),Color3.fromRGB(222,153,67),Enum.Material.Neon,true)
        prompt(upPad,"ПРОКАЧАТЬ",info.displayName,.2).Triggered:Connect(function(player)
            local ok,msg=self.data:UpgradeBike(player,name)
            self.remotes.Toast:FireClient(player,msg)
            if ok then self:RefreshPlayer(player) end
        end)
    end

    local back=part(room,"BackToLobby",Vector3.new(30,.8,10),c+Vector3.new(0,.5,-36),Color3.fromRGB(87,147,255),Enum.Material.Neon,true)
    prompt(back,"В ЛОББИ","Назад",0).Triggered:Connect(function(player) self:TeleportLobby(player) end)
end

function LobbyService:Build()
    if workspace:FindFirstChild("CityRushLobby") then workspace.CityRushLobby:Destroy() end
    self.root=Instance.new("Folder")
    self.root.Name="CityRushLobby"
    self.root.Parent=workspace

    local c=Config.LOBBY_CENTER
    part(self.root,"Ground",Vector3.new(310,3,380),c+Vector3.new(0,-1.5,25),Color3.fromRGB(84,156,88),Enum.Material.Grass,true)
    part(self.root,"MainRoad",Vector3.new(86,1,340),c+Vector3.new(0,.1,20),Color3.fromRGB(57,62,75),Enum.Material.Asphalt,true)
    part(self.root,"Plaza",Vector3.new(100,1,85),c+Vector3.new(0,.12,-105),Color3.fromRGB(191,188,181),Enum.Material.Concrete,true)

    local spawn=Instance.new("SpawnLocation")
    spawn.Name="LobbySpawn"
    spawn.Anchored=true
    spawn.Neutral=true
    spawn.Size=Vector3.new(16,1,16)
    spawn.Position=Config.LOBBY_SPAWN
    spawn.Transparency=1
    spawn.CanCollide=true
    spawn.Parent=self.root

    for i=1,Config.MAX_GARAGES do self:_buildGarage(i) end

    for _,z in ipairs({-135,-75,-15,45,105,165}) do
        cornerLight(self.root,c+Vector3.new(-38,0,z),Color3.fromRGB(255,204,120))
        cornerLight(self.root,c+Vector3.new(38,0,z),Color3.fromRGB(255,204,120))
    end

    local myPad=part(self.root,"MyGaragePad",Vector3.new(24,.8,15),c+Vector3.new(-30,.45,-105),Color3.fromRGB(255,186,67),Enum.Material.Neon,true)
    prompt(myPad,"К СЕБЕ","МОЙ ГАРАЖ",0).Triggered:Connect(function(player) self:TeleportHome(player) end)

    local bikesPad=part(self.root,"BikesPad",Vector3.new(24,.8,15),c+Vector3.new(0,.45,-105),Color3.fromRGB(74,164,255),Enum.Material.Neon,true)
    prompt(bikesPad,"ТЕЛЕПОРТ","ВЕЛИКИ",0).Triggered:Connect(function(player) self:TeleportShowroom(player) end)

    local racePad=part(self.root,"RacePad",Vector3.new(24,.8,15),c+Vector3.new(30,.45,-105),Color3.fromRGB(76,211,126),Enum.Material.Neon,true)
    prompt(racePad,"СТАРТ","ГОНКА",.15).Triggered:Connect(function(player)
        if self.runner then self.runner:BeginRun(player) end
    end)

    local board=part(self.root,"LobbyBoard",Vector3.new(60,16,1),c+Vector3.new(0,11,-142),Color3.fromRGB(30,34,45),Enum.Material.SmoothPlastic,true)
    surface(board,"CITY RUSH\nГАРАЖНЫЙ ХАБ",Color3.fromRGB(255,218,91))

    for _,dx in ipairs({-135,135}) do
        for z=-130,170,48 do
            part(self.root,"TreeTrunk",Vector3.new(2,9,2),c+Vector3.new(dx,4.5,z),Color3.fromRGB(111,77,48),Enum.Material.Wood,true)
            local crown=part(self.root,"TreeCrown",Vector3.new(9,9,9),c+Vector3.new(dx,13,z),Color3.fromRGB(67,157,80),Enum.Material.Grass,false)
            crown.Shape=Enum.PartType.Ball
        end
    end

    self:_buildShowroom()

    local music=SoundService:FindFirstChild("CityRushLobbyMusic") or Instance.new("Sound")
    music.Name="CityRushLobbyMusic"
    music.SoundId=Config.LOBBY_MUSIC_ID
    music.Looped=true
    music.Volume=.28
    music.Parent=SoundService
    pcall(function() music:Play() end)
end

function LobbyService:AssignPlayer(player)
    if self.playerPlot[player] then return self.playerPlot[player] end
    for i=1,Config.MAX_GARAGES do
        if not self.plots[i].owner then
            self.plots[i].owner=player
            self.playerPlot[player]=i
            self.plots[i].visitPrompt.Enabled=true
            self:RefreshPlayer(player)
            return i
        end
    end
    return nil
end

function LobbyService:ReleasePlayer(player)
    local index=self.playerPlot[player]
    if not index then return end
    local plot=self.plots[index]
    if plot then
        plot.owner=nil
        plot.signText.Text="СВОБОДНЫЙ ГАРАЖ"
        plot.visitPrompt.Enabled=false
        plot.visitPrompt.ObjectText="Гараж "..index
        for _,x in ipairs(plot.display:GetChildren()) do x:Destroy() end
    end
    self.playerPlot[player]=nil
end

function LobbyService:RefreshPlayer(player)
    local index=self.playerPlot[player]
    local profile=self.data:Get(player)
    if not index or not profile then return end
    local plot=self.plots[index]
    if not plot then return end

    plot.signText.Text=player.DisplayName.."\n@"..player.Name.."  •  RATING "..profile.rating
    plot.visitPrompt.ObjectText=player.DisplayName

    for _,x in ipairs(plot.display:GetChildren()) do x:Destroy() end
    local level=profile.bikeLevels[profile.equippedBike] or 1
    local facing=plot.left and math.rad(90) or math.rad(-90)
    BikeFactory.BuildDisplay(plot.display,profile.equippedBike,level,CFrame.new(plot.pos+Vector3.new(0,3,0))*CFrame.Angles(0,facing,0))
end

function LobbyService:TeleportToPlot(player,index)
    local plot=self.plots[index]
    local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root and plot then
        root.CFrame=CFrame.new(plot.pos+Vector3.new(0,4,plot.left and 13 or -13))
        root.AssemblyLinearVelocity=Vector3.zero
    end
end

function LobbyService:TeleportHome(player)
    local index=self.playerPlot[player] or self:AssignPlayer(player)
    if index then self:TeleportToPlot(player,index) else self:TeleportLobby(player) end
end

function LobbyService:TeleportLobby(player)
    local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame=CFrame.new(Config.LOBBY_SPAWN)
        root.AssemblyLinearVelocity=Vector3.zero
    end
end

function LobbyService:TeleportShowroom(player)
    local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame=CFrame.new(Config.SHOWROOM_CENTER+Vector3.new(0,4,-28))
        root.AssemblyLinearVelocity=Vector3.zero
    end
end

return LobbyService
