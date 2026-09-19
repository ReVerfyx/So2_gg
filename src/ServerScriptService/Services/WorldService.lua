local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local LevelDesign = require(script.Parent.LevelDesign)
local Suburb2015 = require(script.Parent.Suburb2015)

local WorldService = {}
WorldService.__index = WorldService

local function makePart(parent, name, size, position, color, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.Size = size
    p.Position = position
    p.Color = color or Color3.fromRGB(120,120,120)
    p.Material = material or Enum.Material.Plastic
    p.TopSurface = Enum.SurfaceType.Studs
    p.BottomSurface = Enum.SurfaceType.Inlet
    p.Parent = parent
    return p
end

local function addPrompt(parent, action, objectText, hold)
    local pp = Instance.new("ProximityPrompt")
    pp.KeyboardKeyCode = Enum.KeyCode.F
    pp.ActionText = action
    pp.ObjectText = objectText
    pp.HoldDuration = hold or 0.2
    pp.MaxActivationDistance = 12
    pp.RequiresLineOfSight = false
    pp.Parent = parent
    return pp
end

local function signFace(part, face, text, textColor)
    local gui = Instance.new("SurfaceGui")
    gui.Face = face
    gui.AlwaysOnTop = true
    gui.LightInfluence = 0
    gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud = 28
    gui.Parent = part

    local l = Instance.new("TextLabel")
    l.Size = UDim2.fromScale(1,1)
    l.BackgroundTransparency = 1
    l.TextWrapped = true
    l.TextScaled = true
    l.Font = Enum.Font.GothamBold
    l.TextColor3 = textColor or Color3.fromRGB(245,239,220)
    l.TextStrokeTransparency = 0.65
    l.Text = text
    l.Parent = gui
end

local function sign(parent, text, pos, size, color)
    local p = makePart(parent, "Sign", size or Vector3.new(24,8,1), pos, color or Color3.fromRGB(48,43,40), Enum.Material.WoodPlanks)
    signFace(p, Enum.NormalId.Front, text)
    signFace(p, Enum.NormalId.Back, text)
    return p
end

local function tree(parent, x, z, s)
    s = s or 1
    makePart(parent,"TreeTrunk",Vector3.new(3,12,3)*s,Vector3.new(x,6*s,z),Color3.fromRGB(96,67,43),Enum.Material.Wood)
    local leaves=makePart(parent,"TreeLeaves",Vector3.new(11,10,11)*s,Vector3.new(x,15*s,z),Color3.fromRGB(42,85,48),Enum.Material.Grass)
    leaves.CanCollide=false
end

local function lamp(parent, x, z)
    local post=makePart(parent,"LampPost",Vector3.new(1,10,1),Vector3.new(x,5,z),Color3.fromRGB(54,50,47),Enum.Material.Metal)
    local bulb=makePart(parent,"Lamp",Vector3.new(2.2,2.2,2.2),Vector3.new(x,10.5,z),Color3.fromRGB(255,214,146),Enum.Material.Neon)
    bulb.Shape=Enum.PartType.Ball
    bulb.CanCollide=false
    local light=Instance.new("PointLight")
    light.Color=Color3.fromRGB(255,205,135)
    light.Range=30
    light.Brightness=2
    light.Shadows=true
    light.Parent=bulb
    return post
end

local function booth(parent, name, center, title, accent)
    local m=Instance.new("Model")
    m.Name=name
    m.Parent=parent
    local x,z=center.X,center.Z
    makePart(m,"Floor",Vector3.new(34,1,24),Vector3.new(x,.5,z),Color3.fromRGB(67,57,49),Enum.Material.WoodPlanks)
    makePart(m,"Back",Vector3.new(34,14,1),Vector3.new(x,7,z+11.5),Color3.fromRGB(61,51,46),Enum.Material.WoodPlanks)
    makePart(m,"Left",Vector3.new(1,14,24),Vector3.new(x-16.5,7,z),Color3.fromRGB(61,51,46),Enum.Material.WoodPlanks)
    makePart(m,"Right",Vector3.new(1,14,24),Vector3.new(x+16.5,7,z),Color3.fromRGB(61,51,46),Enum.Material.WoodPlanks)
    makePart(m,"Roof",Vector3.new(36,1,26),Vector3.new(x,14,z),Color3.fromRGB(38,35,38),Enum.Material.Slate)
    local board=sign(m,title,Vector3.new(x,11,z-12),Vector3.new(30,6,1),accent)
    board.Name=name.."Sign"
    local counter=makePart(m,"Counter",Vector3.new(28,4,4),Vector3.new(x,2,z-8.5),Color3.fromRGB(91,72,54),Enum.Material.WoodPlanks)
    return m,counter
end

local function fenceSection(parent, pos, size)
    local p=makePart(parent,"Fence",size,pos,Color3.fromRGB(48,45,44),Enum.Material.WoodPlanks)
    return p
end


local function rock(parent, x, z, sx, sy, sz, color)
    local p=makePart(parent,"Rock",Vector3.new(sx or 6,sy or 4,sz or 6),Vector3.new(x,(sy or 4)/2,z),color or Color3.fromRGB(74,72,74),Enum.Material.Slate)
    p.Orientation=Vector3.new(math.random(-8,8),math.random(0,180),math.random(-8,8))
    return p
end

local function bush(parent,x,z,s)
    local p=makePart(parent,"Bush",Vector3.new(5,3.5,5)*(s or 1),Vector3.new(x,1.6*(s or 1),z),Color3.fromRGB(42,77,43),Enum.Material.Grass)
    p.Shape=Enum.PartType.Ball
    p.CanCollide=false
    return p
end

local function bench(parent,x,z,rot)
    local seat=makePart(parent,"BenchSeat",Vector3.new(8,.7,2.2),Vector3.new(x,2,z),Color3.fromRGB(95,69,47),Enum.Material.WoodPlanks)
    seat.Orientation=Vector3.new(0,rot or 0,0)
    local back=makePart(parent,"BenchBack",Vector3.new(8,2.5,.6),Vector3.new(x,3.2,z+((rot or 0)==0 and 1 or 0)),Color3.fromRGB(83,61,43),Enum.Material.WoodPlanks)
    back.Orientation=seat.Orientation
end

local function crate(parent,x,y,z,s)
    local p=makePart(parent,"Crate",Vector3.new(5,5,5)*(s or 1),Vector3.new(x,y,z),Color3.fromRGB(109,78,48),Enum.Material.WoodPlanks)
    p.Orientation=Vector3.new(0,math.random(0,3)*90,0)
    return p
end

local function barrel(parent,x,z,color)
    local p=makePart(parent,"Barrel",Vector3.new(3.2,5,3.2),Vector3.new(x,2.5,z),color or Color3.fromRGB(72,76,78),Enum.Material.Metal)
    p.Shape=Enum.PartType.Cylinder
    p.Orientation=Vector3.new(0,0,90)
    return p
end

local function utilityPole(parent,x,z)
    makePart(parent,"UtilityPole",Vector3.new(1.2,18,1.2),Vector3.new(x,9,z),Color3.fromRGB(78,56,39),Enum.Material.Wood)
    makePart(parent,"Crossbar",Vector3.new(8,.7,.7),Vector3.new(x,16.5,z),Color3.fromRGB(72,52,38),Enum.Material.Wood)
    for _,dx in ipairs({-3,0,3}) do
        local ins=makePart(parent,"Insulator",Vector3.new(.55,.55,.55),Vector3.new(x+dx,17,z),Color3.fromRGB(185,183,163),Enum.Material.SmoothPlastic)
        ins.Shape=Enum.PartType.Ball
        ins.CanCollide=false
    end
end

local function neonStrip(parent,name,pos,size,color)
    local p=makePart(parent,name,size,pos,color,Enum.Material.Neon)
    p.CanCollide=false
    return p
end

local function smallCampfire(parent,x,z)
    for i=1,6 do
        local a=(i/6)*math.pi*2
        rock(parent,x+math.cos(a)*3,z+math.sin(a)*3,2,1.5,2,Color3.fromRGB(83,78,72))
    end
    local glow=makePart(parent,"CampfireGlow",Vector3.new(2.4,2.4,2.4),Vector3.new(x,2,z),Color3.fromRGB(255,120,54),Enum.Material.Neon)
    glow.Shape=Enum.PartType.Ball
    glow.CanCollide=false
    local li=Instance.new("PointLight")
    li.Color=Color3.fromRGB(255,143,74)
    li.Range=26
    li.Brightness=2.2
    li.Shadows=true
    li.Parent=glow
end

local function setLightingProfile(map)
    local profiles={
        Suburb={clock=17.25,bright=2.8,fog=Color3.fromRGB(188,181,201),start=260,finish=1100,ambient=Color3.fromRGB(139,135,144),out=Color3.fromRGB(155,146,140),density=.13,haze=.45,bloom=.16,sat=.14,contrast=.04,tint=Color3.fromRGB(255,236,221)},
        ObbyPark={clock=17.7,bright=1.8,fog=Color3.fromRGB(108,112,128),start=110,finish=520,ambient=Color3.fromRGB(82,84,98),out=Color3.fromRGB(102,98,106),density=.2,haze=.9,bloom=.2,sat=-.02,contrast=.06,tint=Color3.fromRGB(244,236,255)},
        City={clock=20.8,bright=1.35,fog=Color3.fromRGB(62,68,79),start=70,finish=370,ambient=Color3.fromRGB(48,51,62),out=Color3.fromRGB(59,61,70),density=.32,haze=1.5,bloom=.28,sat=-.2,contrast=.1,tint=Color3.fromRGB(211,224,255)},
        Warehouse={clock=22.3,bright=1.05,fog=Color3.fromRGB(53,55,60),start=55,finish=310,ambient=Color3.fromRGB(43,44,49),out=Color3.fromRGB(52,49,47),density=.35,haze=1.1,bloom=.32,sat=-.25,contrast=.14,tint=Color3.fromRGB(224,216,203)},
        Canyon={clock=18.0,bright=1.9,fog=Color3.fromRGB(139,105,83),start=120,finish=500,ambient=Color3.fromRGB(103,76,64),out=Color3.fromRGB(130,97,76),density=.18,haze=.8,bloom=.12,sat=-.05,contrast=.06,tint=Color3.fromRGB(255,218,184)},
        Ocean={clock=19.4,bright=1.5,fog=Color3.fromRGB(58,88,116),start=85,finish=420,ambient=Color3.fromRGB(54,67,83),out=Color3.fromRGB(68,80,98),density=.28,haze=1.35,bloom=.24,sat=-.12,contrast=.07,tint=Color3.fromRGB(209,226,255)},
        Chat={clock=0.2,bright=.85,fog=Color3.fromRGB(30,31,39),start=45,finish=260,ambient=Color3.fromRGB(30,31,40),out=Color3.fromRGB(39,36,48),density=.42,haze=1.6,bloom=.4,sat=-.25,contrast=.18,tint=Color3.fromRGB(215,200,255)},
        Forest={clock=1.1,bright=.8,fog=Color3.fromRGB(39,54,48),start=42,finish=250,ambient=Color3.fromRGB(29,42,35),out=Color3.fromRGB(42,55,45),density=.48,haze=1.7,bloom=.18,sat=-.2,contrast=.12,tint=Color3.fromRGB(196,220,202)},
        Archive={clock=23.7,bright=.7,fog=Color3.fromRGB(27,30,38),start=38,finish=225,ambient=Color3.fromRGB(25,28,34),out=Color3.fromRGB(33,36,42),density=.45,haze=1.25,bloom=.5,sat=-.3,contrast=.2,tint=Color3.fromRGB(190,215,255)},
        Finale={clock=23.1,bright=.9,fog=Color3.fromRGB(49,37,61),start=50,finish=280,ambient=Color3.fromRGB(43,33,54),out=Color3.fromRGB(55,40,65),density=.4,haze=1.8,bloom=.45,sat=-.18,contrast=.18,tint=Color3.fromRGB(231,202,255)},
    }
    local p=profiles[map] or profiles.Finale
    Lighting.ClockTime=p.clock
    Lighting.Brightness=p.bright
    Lighting.Ambient=p.ambient
    Lighting.OutdoorAmbient=p.out
    Lighting.FogColor=p.fog
    Lighting.FogStart=p.start
    Lighting.FogEnd=p.finish
    local a=Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
    a.Density=p.density
    a.Haze=p.haze
    a.Color=p.tint
    a.Decay=p.fog
    a.Parent=Lighting
    local bloom=Lighting:FindFirstChild("ChapterBloom") or Lighting:FindFirstChild("LobbyBloom") or Instance.new("BloomEffect")
    bloom.Name="ChapterBloom"
    bloom.Intensity=p.bloom
    bloom.Size=22
    bloom.Threshold=1.1
    bloom.Parent=Lighting
    local cc=Lighting:FindFirstChild("ChapterColor") or Instance.new("ColorCorrectionEffect")
    cc.Name="ChapterColor"
    cc.Saturation=p.sat
    cc.Contrast=p.contrast
    cc.TintColor=p.tint
    cc.Parent=Lighting
end

function WorldService.new(remotes)
    local self=setmetatable({},WorldService)
    self.remotes=remotes
    self.root=workspace:FindFirstChild("GeneratedWorld") or Instance.new("Folder")
    self.root.Name="GeneratedWorld"
    self.root.Parent=workspace
    self.current=nil
    self.currentChapter=nil
    self.spawnPosition=Vector3.new(0,4,430)
    self.previousBuilds={}
    self.roundSeed=1
    return self
end

function WorldService:SetupLighting()
    Lighting.ClockTime=21.1
    Lighting.Brightness=1.7
    Lighting.GlobalShadows=true
    Lighting.ShadowSoftness=.35
    Lighting.EnvironmentDiffuseScale=.35
    Lighting.EnvironmentSpecularScale=.55
    Lighting.Ambient=Color3.fromRGB(58,62,79)
    Lighting.OutdoorAmbient=Color3.fromRGB(72,74,92)
    Lighting.FogColor=Color3.fromRGB(63,73,91)
    Lighting.FogStart=85
    Lighting.FogEnd=380

    local atmosphere=Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
    atmosphere.Density=.3
    atmosphere.Haze=1.4
    atmosphere.Glare=.05
    atmosphere.Color=Color3.fromRGB(149,164,191)
    atmosphere.Decay=Color3.fromRGB(61,48,72)
    atmosphere.Parent=Lighting

    local bloom=Lighting:FindFirstChild("LobbyBloom") or Instance.new("BloomEffect")
    bloom.Name="LobbyBloom"
    bloom.Intensity=.25
    bloom.Size=18
    bloom.Threshold=1.25
    bloom.Parent=Lighting

    local dof=Lighting:FindFirstChild("WorldDOF") or Instance.new("DepthOfFieldEffect")
    dof.Name="WorldDOF"
    dof.FarIntensity=.08
    dof.FocusDistance=75
    dof.InFocusRadius=48
    dof.NearIntensity=.04
    dof.Parent=Lighting

    local rays=Lighting:FindFirstChild("WorldSunRays") or Instance.new("SunRaysEffect")
    rays.Name="WorldSunRays"
    rays.Intensity=.035
    rays.Spread=.7
    rays.Parent=Lighting
end

function WorldService:BuildLobby()
    if self.current then self.current:Destroy(); self.current=nil end
    local old=self.root:FindFirstChild("Lobby")
    if old then old:Destroy() end

    Lighting.ClockTime=21.1
    Lighting.FogStart=85
    Lighting.FogEnd=380

    local f=Instance.new("Folder")
    f.Name="Lobby"
    f.Parent=self.root

    -- Compact, readable 176x176 hub. No more endless grass plate.
    makePart(f,"LobbyGround",Vector3.new(176,2,176),Vector3.new(0,-1,0),Color3.fromRGB(48,76,49),Enum.Material.Grass)

    -- Visible perimeter + invisible upper blocker so players cannot simply jump outside.
    fenceSection(f,Vector3.new(0,4,-87),Vector3.new(176,8,3))
    fenceSection(f,Vector3.new(0,4,87),Vector3.new(176,8,3))
    fenceSection(f,Vector3.new(-87,4,0),Vector3.new(3,8,176))
    fenceSection(f,Vector3.new(87,4,0),Vector3.new(3,8,176))
    for _,spec in ipairs({
        {Vector3.new(0,18,-89),Vector3.new(180,28,2)},
        {Vector3.new(0,18,89),Vector3.new(180,28,2)},
        {Vector3.new(-89,18,0),Vector3.new(2,28,180)},
        {Vector3.new(89,18,0),Vector3.new(2,28,180)},
    }) do
        local wall=makePart(f,"Boundary",spec[2],spec[1],Color3.new(1,1,1),Enum.Material.SmoothPlastic)
        wall.Transparency=1
    end

    -- Paths establish a clear visual hierarchy.
    makePart(f,"MainPath",Vector3.new(22,.35,145),Vector3.new(0,.15,3),Color3.fromRGB(88,83,78),Enum.Material.Cobblestone)
    makePart(f,"CrossPath",Vector3.new(145,.35,18),Vector3.new(0,.16,8),Color3.fromRGB(88,83,78),Enum.Material.Cobblestone)
    makePart(f,"Plaza",Vector3.new(46,.4,46),Vector3.new(0,.18,8),Color3.fromRGB(96,91,85),Enum.Material.Cobblestone)

    local sp=Instance.new("SpawnLocation")
    sp.Name="LobbySpawn"
    sp.Size=Vector3.new(8,1,8)
    sp.Position=Vector3.new(0,1,61)
    sp.Neutral=true
    sp.Transparency=1
    sp.CanCollide=false
    sp.Parent=f

    -- Main start gate.
    makePart(f,"GateLeft",Vector3.new(8,22,8),Vector3.new(-16,11,-66),Color3.fromRGB(56,51,48),Enum.Material.Brick)
    makePart(f,"GateRight",Vector3.new(8,22,8),Vector3.new(16,11,-66),Color3.fromRGB(56,51,48),Enum.Material.Brick)
    makePart(f,"GateTop",Vector3.new(40,6,8),Vector3.new(0,22,-66),Color3.fromRGB(45,42,43),Enum.Material.Brick)
    sign(f,"ИГРАТЬ  /  PLAY",Vector3.new(0,22,-70.2),Vector3.new(30,5,1),Color3.fromRGB(58,78,65))
    local roomTerminal=makePart(f,"RoomTerminal",Vector3.new(10,6,5),Vector3.new(0,3,-54),Color3.fromRGB(66,78,77),Enum.Material.Metal)
    local rp=addPrompt(roomTerminal,"Играть / Play","Комната / Room",0.25)
    rp.Name="RoomPrompt"

    -- Left: classes.
    local _,classCounter=booth(f,"ClassesHut",Vector3.new(-55,0,8),"КЛАССЫ / CLASSES",Color3.fromRGB(67,72,96))
    local cp=addPrompt(classCounter,"Открыть / Open","Классы / Classes",0.15)
    cp.Name="ClassPrompt"

    -- Right: class shop visual anchor, deliberately readable even before full shop logic.
    local _,shopCounter=booth(f,"ShopHut",Vector3.new(55,0,8),"МАГАЗИН / SHOP",Color3.fromRGB(90,68,52))
    sign(f,"ЕЖЕДНЕВНЫЙ МАГАЗИН\nDAILY SHOP",Vector3.new(55,7,-5),Vector3.new(24,5,1),Color3.fromRGB(88,64,47))
    shopCounter.Color=Color3.fromRGB(102,77,54)

    -- Archive / memories on the south side.
    local archive=makePart(f,"ArchiveStone",Vector3.new(30,10,4),Vector3.new(-45,5,61),Color3.fromRGB(58,60,70),Enum.Material.Slate)
    signFace(archive,Enum.NormalId.Front,"АРХИВ ПАМЯТИ\nMEMORY ARCHIVE",Color3.fromRGB(207,196,231))
    signFace(archive,Enum.NormalId.Back,"АРХИВ ПАМЯТИ\nMEMORY ARCHIVE",Color3.fromRGB(207,196,231))

    local guide=makePart(f,"GuideBoard",Vector3.new(30,10,4),Vector3.new(45,5,61),Color3.fromRGB(62,57,49),Enum.Material.WoodPlanks)
    signFace(guide,Enum.NormalId.Front,"1. ВЫБЕРИ КЛАСС\n2. ПОДОЙДИ К ВОРОТАМ\n3. НАЧНИ ГЛАВУ\n\nSELECT CLASS → PLAY",Color3.fromRGB(244,226,184))
    signFace(guide,Enum.NormalId.Back,"1. ВЫБЕРИ КЛАСС\n2. ПОДОЙДИ К ВОРОТАМ\n3. НАЧНИ ГЛАВУ\n\nSELECT CLASS → PLAY",Color3.fromRGB(244,226,184))

    -- Central safe-zone landmark.
    local fireBase=makePart(f,"CampfireBase",Vector3.new(10,1,10),Vector3.new(0,.5,8),Color3.fromRGB(73,67,62),Enum.Material.Cobblestone)
    fireBase.Shape=Enum.PartType.Cylinder
    fireBase.Orientation=Vector3.new(0,0,90)
    local fire=makePart(f,"Campfire",Vector3.new(3,3,3),Vector3.new(0,2.5,8),Color3.fromRGB(255,129,62),Enum.Material.Neon)
    fire.Shape=Enum.PartType.Ball
    fire.CanCollide=false
    local fireLight=Instance.new("PointLight")
    fireLight.Color=Color3.fromRGB(255,141,70)
    fireLight.Range=34
    fireLight.Brightness=2.5
    fireLight.Shadows=true
    fireLight.Parent=fire

    for _,p in ipairs({{-24,-38},{24,-38},{-24,38},{24,38},{-70,-35},{70,-35}}) do lamp(f,p[1],p[2]) end
    for _,p in ipairs({{-75,72},{-72,48},{75,72},{72,48},{-76,-72},{76,-72}}) do tree(f,p[1],p[2],.8) end

    sign(f,"2015: CODE ROT\nСЕРВЕР ПОМНИТ / THE SERVER REMEMBERS",Vector3.new(0,12,81),Vector3.new(48,10,1),Color3.fromRGB(46,42,45))
    self:_decorateLobby(f)
    LevelDesign.DecorateLobby(f)
end

function WorldService:_decorateLobby(f)
    -- Dense edge dressing: the hub should feel like a lived-in camp, not a flat dev base.
    for x=-76,76,19 do
        bush(f,x,78,.75)
        bush(f,x,-78,.8)
        if x%38==0 then rock(f,x+4,73,5,3,6) end
    end
    for z=-62,62,18 do
        bush(f,-78,z,.7)
        bush(f,78,z,.75)
    end
    bench(f,-18,31,0)
    bench(f,18,31,180)
    bench(f,-18,-18,0)
    bench(f,18,-18,180)
    crate(f,-69,2.5,-4,1)
    crate(f,-63,2.5,-2,.8)
    crate(f,69,2.5,-3,1)
    barrel(f,65,15,Color3.fromRGB(73,81,84))
    barrel(f,70,18,Color3.fromRGB(92,68,53))
    smallCampfire(f,-67,54)
    utilityPole(f,-78,-52)
    utilityPole(f,78,-52)
    sign(f,"НЕ ВЫХОДИ ЗА ОГРАЖДЕНИЕ\nDO NOT CROSS THE FENCE",Vector3.new(0,6,-83),Vector3.new(28,7,1),Color3.fromRGB(63,49,45))
    for _,p in ipairs({{-58,-63},{58,-63},{-81,25},{81,25},{-42,73},{42,73}}) do
        rock(f,p[1],p[2],math.random(4,8),math.random(2,5),math.random(4,8))
    end
end

function WorldService:GetSpawnPosition()
    return self.spawnPosition
end

local function addArenaBounds(folder, centerZ, map, rng)
    local minZ=centerZ-305
    local maxZ=centerZ+305

    -- Tall invisible collision shell. The visible border below is thematic.
    for _,spec in ipairs({
        {Vector3.new(0,32,minZ-3),Vector3.new(626,64,3)},
        {Vector3.new(0,32,maxZ+3),Vector3.new(626,64,3)},
        {Vector3.new(-311,32,centerZ),Vector3.new(3,64,626)},
        {Vector3.new(311,32,centerZ),Vector3.new(3,64,626)},
    }) do
        local wall=makePart(folder,"InvisibleBoundary",spec[2],spec[1],Color3.new(1,1,1),Enum.Material.SmoothPlastic)
        wall.Transparency=1
    end

    local function edgePiece(x,z,side)
        if map=="Canyon" then
            rock(folder,x,z,rng:NextInteger(26,42),rng:NextInteger(24,54),rng:NextInteger(22,40),Color3.fromRGB(130,85,58))
        elseif map=="Warehouse" or map=="Archive" then
            local p=makePart(folder,"PerimeterWall",side=="x" and Vector3.new(24,18,5) or Vector3.new(5,18,24),Vector3.new(x,9,z),Color3.fromRGB(48,49,54),Enum.Material.Metal)
            if rng:NextNumber()<.32 then neonStrip(folder,"WarningLamp",Vector3.new(x,15,z),Vector3.new(2,.8,2),Color3.fromRGB(255,92,55)) end
        elseif map=="City" then
            local p=makePart(folder,"Barricade",side=="x" and Vector3.new(20,7,5) or Vector3.new(5,7,20),Vector3.new(x,3.5,z),Color3.fromRGB(75,77,82),Enum.Material.Concrete)
            if rng:NextNumber()<.25 then barrel(folder,x+(side=="x" and 0 or 5),z+(side=="x" and 5 or 0)) end
        elseif map=="Ocean" then
            rock(folder,x,z,rng:NextInteger(18,32),rng:NextInteger(8,16),rng:NextInteger(18,32),Color3.fromRGB(62,73,83))
        elseif map=="Forest" or map=="Suburb" then
            if rng:NextNumber()<.75 then tree(folder,x,z,rng:NextNumber(.9,1.35)) else rock(folder,x,z,10,6,9) end
        elseif map=="Chat" or map=="Finale" then
            local p=makePart(folder,"GlitchBoundary",side=="x" and Vector3.new(24,rng:NextInteger(14,30),5) or Vector3.new(5,rng:NextInteger(14,30),24),Vector3.new(x,9,z),Color3.fromRGB(62,42,84),Enum.Material.Slate)
            if rng:NextNumber()<.22 then p.Material=Enum.Material.Neon; p.Color=Color3.fromRGB(155,54,220) end
        else
            rock(folder,x,z,18,11,16)
        end
    end

    for n=-288,288,24 do
        edgePiece(n,minZ+4,"x")
        edgePiece(n,maxZ-4,"x")
        edgePiece(-304,centerZ+n,"z")
        edgePiece(304,centerZ+n,"z")
    end
end

function WorldService:_makeBase(folder, chapter, rng)
    self.spawnPosition=Vector3.new(0,4,470)
    setLightingProfile(chapter.map)

    local palettes={
        Suburb={Color3.fromRGB(67,115,63),Enum.Material.Grass},
        ObbyPark={Color3.fromRGB(74,124,79),Enum.Material.Grass},
        City={Color3.fromRGB(74,77,82),Enum.Material.Concrete},
        Warehouse={Color3.fromRGB(83,80,76),Enum.Material.Concrete},
        Canyon={Color3.fromRGB(143,95,61),Enum.Material.Sandstone},
        Ocean={Color3.fromRGB(48,95,132),Enum.Material.SmoothPlastic},
        Chat={Color3.fromRGB(35,38,47),Enum.Material.Slate},
        Forest={Color3.fromRGB(42,72,45),Enum.Material.Grass},
        Archive={Color3.fromRGB(40,43,50),Enum.Material.Metal},
        Finale={Color3.fromRGB(65,57,74),Enum.Material.Slate},
    }
    local pal=palettes[chapter.map] or palettes.Finale
    if chapter.map=="Suburb" then
        -- Chapter 1 owns its full visual ground and scenery now.
        Suburb2015.Build(folder,rng)
    else
        makePart(folder,"Ground",Vector3.new(1050,6,1050),Vector3.new(0,-3,760),pal[1],pal[2])
    end
    addArenaBounds(folder,760,chapter.map,rng)
    sign(folder,chapter.title.."\n"..chapter.subtitle,Vector3.new(0,11,452),Vector3.new(38,10,1))

    if chapter.map=="Suburb" then
        -- Suburb2015.Build above creates the complete authored chapter-one environment.
    elseif chapter.map=="ObbyPark" then
        for lane=-2,2 do for i=1,9 do
            local p=makePart(folder,"DynamicPlatform",Vector3.new(24,3,24),Vector3.new(lane*85+rng:NextInteger(-14,14),3+((i+lane)%3)*5,500+i*55),Color3.fromRGB(170+rng:NextInteger(0,70),80+rng:NextInteger(0,100),90+rng:NextInteger(0,100)))
            p:SetAttribute("PulseToggle",true)
        end end
    elseif chapter.map=="City" then
        for x=-240,240,120 do makePart(folder,"Street",Vector3.new(26,1,560),Vector3.new(x,.1,760),Color3.fromRGB(42,44,48),Enum.Material.Concrete) end
        for gx=-2,2 do for gz=0,4 do if gx~=0 then
            local h=rng:NextInteger(35,82)
            makePart(folder,"Building",Vector3.new(70,h,70),Vector3.new(gx*105,h/2,535+gz*110),Color3.fromRGB(90+rng:NextInteger(0,35),90+rng:NextInteger(0,35),100+rng:NextInteger(0,35)),Enum.Material.Concrete)
        end end end
    elseif chapter.map=="Warehouse" then
        makePart(folder,"Warehouse",Vector3.new(540,32,500),Vector3.new(0,16,760),Color3.fromRGB(88,86,82),Enum.Material.Metal).Transparency=.08
        for i=1,48 do makePart(folder,"FreeModelCrate",Vector3.new(12,12,12),Vector3.new(rng:NextInteger(-250,250),6,rng:NextInteger(510,1010)),Color3.fromRGB(rng:NextInteger(80,200),rng:NextInteger(60,170),rng:NextInteger(80,210))) end
    elseif chapter.map=="Canyon" then
        for i=1,28 do
            local h=rng:NextInteger(25,85)
            makePart(folder,"CanyonPillar",Vector3.new(rng:NextInteger(28,64),h,rng:NextInteger(28,64)),Vector3.new(rng:NextInteger(-265,265),h/2,rng:NextInteger(490,1020)),Color3.fromRGB(151,100,66),Enum.Material.Sandstone)
        end
    elseif chapter.map=="Ocean" then
        local water=makePart(folder,"Water",Vector3.new(620,2,620),Vector3.new(0,-1,760),Color3.fromRGB(43,90,132),Enum.Material.Glass)
        water.Transparency=.2
        for i=1,12 do
            local island=Instance.new("Model"); island.Name="BackupIsland"; island:SetAttribute("DriftIsland",true); island.Parent=folder
            local b=makePart(island,"Island",Vector3.new(rng:NextInteger(58,95),8,rng:NextInteger(58,95)),Vector3.new(rng:NextInteger(-250,250),rng:NextInteger(8,20),rng:NextInteger(500,1010)),Color3.fromRGB(82,127,72),Enum.Material.Grass)
            island.PrimaryPart=b
        end
    elseif chapter.map=="Chat" then
        for x=-5,5 do for z=0,10 do
            if (x+z)%3~=0 then
                local w=makePart(folder,"ChatWall",Vector3.new(4,22,42),Vector3.new(x*50,11,500+z*50),Color3.fromRGB(55,59,73),Enum.Material.Slate)
                w:SetAttribute("ChatWall",true)
            end
        end end
    elseif chapter.map=="Forest" then
        for i=1,95 do tree(folder,rng:NextInteger(-280,280),rng:NextInteger(480,1040),rng:NextNumber(.6,1.15)) end
    elseif chapter.map=="Archive" then
        for x=-3,3 do for z=0,7 do
            makePart(folder,"ArchiveRack",Vector3.new(30,36,10),Vector3.new(x*80,18,520+z*72),Color3.fromRGB(52,55,62),Enum.Material.Metal)
        end end
    else
        makePart(folder,"RoadFragment",Vector3.new(46,1,360),Vector3.new(-190,.2,730),Color3.fromRGB(76,76,76),Enum.Material.Concrete)
        for i=1,18 do tree(folder,rng:NextInteger(-270,270),rng:NextInteger(490,1030),rng:NextNumber(.6,1.0)) end
        for i=1,18 do
            local p=makePart(folder,"MemoryPlatform",Vector3.new(26,3,26),Vector3.new(rng:NextInteger(-250,250),rng:NextInteger(2,24),rng:NextInteger(500,1015)),Color3.fromRGB(165,48,220),Enum.Material.Neon)
            p:SetAttribute("PulseToggle",true)
        end
    end
end


function WorldService:_decorateChapter(folder,chapter,rng)
    local map=chapter.map

    if map=="Suburb" then
        for z=520,980,92 do
            lamp(folder,-28,z)
            lamp(folder,28,z)
            if (z%184)<100 then utilityPole(folder,-165,z) else utilityPole(folder,165,z) end
        end
        for i=1,18 do
            local side=(i%2==0) and -1 or 1
            local z=500+i*28
            local x=side*rng:NextInteger(52,145)
            bush(folder,x,z,rng:NextNumber(.55,.95))
            if i%3==0 then
                local mb=makePart(folder,"Mailbox",Vector3.new(2.5,3,2.2),Vector3.new(x,1.8,z+3),Color3.fromRGB(74,81,91),Enum.Material.Metal)
                makePart(folder,"MailboxPost",Vector3.new(.6,2.2,.6),Vector3.new(x,.8,z+3),Color3.fromRGB(87,64,45),Enum.Material.Wood)
            end
        end
        sign(folder,"УЛ. SERVER LIST",Vector3.new(-26,7,610),Vector3.new(15,5,1),Color3.fromRGB(52,60,66))
        sign(folder,"ШКОЛА  →",Vector3.new(28,7,880),Vector3.new(14,5,1),Color3.fromRGB(58,55,51))
        crate(folder,135,2.5,930,.8)
        barrel(folder,143,929)
    elseif map=="ObbyPark" then
        for i=1,18 do
            local x=rng:NextInteger(-255,255)
            local z=rng:NextInteger(500,1010)
            local pole=makePart(folder,"FlagPole",Vector3.new(.5,10,.5),Vector3.new(x,5,z),Color3.fromRGB(75,75,78),Enum.Material.Metal)
            local flag=makePart(folder,"OldFlag",Vector3.new(5,3,.3),Vector3.new(x+2.5,9,z),Color3.fromRGB(180+rng:NextInteger(0,70),70+rng:NextInteger(0,100),80+rng:NextInteger(0,100)),Enum.Material.Fabric)
            flag.CanCollide=false
        end
        sign(folder,"OBBY OF THE YEAR 2015",Vector3.new(-170,10,535),Vector3.new(26,8,1),Color3.fromRGB(88,62,72))
        sign(folder,"CHECKPOINTS MAY LIE",Vector3.new(170,8,720),Vector3.new(22,7,1),Color3.fromRGB(67,54,77))
        for i=1,12 do rock(folder,rng:NextInteger(-270,270),rng:NextInteger(490,1020),rng:NextInteger(3,7),rng:NextInteger(2,4),rng:NextInteger(3,7),Color3.fromRGB(89,88,95)) end
    elseif map=="City" then
        for z=505,1010,70 do
            lamp(folder,-52,z)
            lamp(folder,52,z)
        end
        for i=1,14 do
            local x=(i%2==0) and -185 or 185
            local z=500+i*35
            if i%3==0 then bench(folder,x,z,90) else barrel(folder,x,z,Color3.fromRGB(65,70,74)) end
        end
        sign(folder,"METRO  ↓",Vector3.new(-85,8,760),Vector3.new(16,6,1),Color3.fromRGB(48,62,76))
        sign(folder,"LAST ONLINE: 27",Vector3.new(165,12,540),Vector3.new(26,8,1),Color3.fromRGB(48,55,66))
        for i=1,10 do crate(folder,rng:NextInteger(-245,245),2.5,rng:NextInteger(500,1010),.7) end
    elseif map=="Warehouse" then
        for row=-4,4 do
            for z=540,980,80 do
                if math.abs(row)%2==0 then
                    makePart(folder,"Shelf",Vector3.new(26,18,4),Vector3.new(row*54,9,z),Color3.fromRGB(61,62,64),Enum.Material.Metal)
                end
            end
        end
        for z=520,1000,96 do
            neonStrip(folder,"CeilingLight",Vector3.new(-150,27,z),Vector3.new(18,.5,1.5),Color3.fromRGB(220,232,221))
            neonStrip(folder,"CeilingLight",Vector3.new(150,27,z),Vector3.new(18,.5,1.5),Color3.fromRGB(220,232,221))
        end
        for i=1,22 do
            if i%2==0 then barrel(folder,rng:NextInteger(-245,245),rng:NextInteger(510,1010)) else crate(folder,rng:NextInteger(-245,245),2.5,rng:NextInteger(510,1010),rng:NextNumber(.65,1.0)) end
        end
        sign(folder,"QUARANTINE",Vector3.new(0,18,520),Vector3.new(28,8,1),Color3.fromRGB(91,56,45))
    elseif map=="Canyon" then
        for i=1,45 do rock(folder,rng:NextInteger(-275,275),rng:NextInteger(490,1030),rng:NextInteger(4,14),rng:NextInteger(2,8),rng:NextInteger(4,14),Color3.fromRGB(126+rng:NextInteger(0,25),82,57)) end
        for _,z in ipairs({545,675,805,935}) do
            local post1=makePart(folder,"RopePost",Vector3.new(1.2,9,1.2),Vector3.new(-42,4.5,z),Color3.fromRGB(87,61,41),Enum.Material.Wood)
            local post2=makePart(folder,"RopePost",Vector3.new(1.2,9,1.2),Vector3.new(42,4.5,z),Color3.fromRGB(87,61,41),Enum.Material.Wood)
            local l=makePart(folder,"Lantern",Vector3.new(1.7,2.2,1.7),Vector3.new(-42,9.5,z),Color3.fromRGB(255,171,82),Enum.Material.Neon); l.CanCollide=false
            local li=Instance.new("PointLight"); li.Range=20; li.Brightness=1.5; li.Color=Color3.fromRGB(255,155,75); li.Parent=l
        end
        sign(folder,"НЕ СМОТРИ ВНИЗ\\nDON'T LOOK DOWN",Vector3.new(0,10,720),Vector3.new(25,8,1),Color3.fromRGB(95,59,43))
    elseif map=="Ocean" then
        for i=1,16 do
            local x=rng:NextInteger(-260,260)
            local z=rng:NextInteger(500,1020)
            local buoy=makePart(folder,"Buoy",Vector3.new(2.5,5,2.5),Vector3.new(x,3,z),Color3.fromRGB(195,72,54),Enum.Material.Metal)
            buoy.Shape=Enum.PartType.Cylinder
            buoy.Orientation=Vector3.new(0,0,90)
        end
        local dock=makePart(folder,"BrokenDock",Vector3.new(16,2,100),Vector3.new(0,3,525),Color3.fromRGB(91,68,46),Enum.Material.WoodPlanks)
        for i=1,8 do crate(folder,rng:NextInteger(-60,60),5,rng:NextInteger(490,580),.8) end
        sign(folder,"BACKUP 03/??",Vector3.new(0,10,600),Vector3.new(22,7,1),Color3.fromRGB(54,67,80))
    elseif map=="Chat" then
        for i=1,28 do
            local x=rng:NextInteger(-255,255)
            local z=rng:NextInteger(500,1020)
            local h=rng:NextInteger(5,14)
            local p=makePart(folder,"MessageShard",Vector3.new(rng:NextInteger(8,18),h,.7),Vector3.new(x,h/2,z),Color3.fromRGB(57,49,75),Enum.Material.Neon)
            p.Transparency=rng:NextNumber(.15,.45)
            p.CanCollide=false
        end
        sign(folder,"[SERVER] joined the game",Vector3.new(-135,13,555),Vector3.new(30,9,1),Color3.fromRGB(52,43,68))
        sign(folder,"[???] is typing...",Vector3.new(145,11,820),Vector3.new(26,8,1),Color3.fromRGB(47,42,61))
    elseif map=="Forest" then
        for i=1,70 do
            if rng:NextNumber()<.62 then
                bush(folder,rng:NextInteger(-275,275),rng:NextInteger(490,1030),rng:NextNumber(.5,.9))
            else
                rock(folder,rng:NextInteger(-275,275),rng:NextInteger(490,1030),rng:NextInteger(3,8),rng:NextInteger(2,5),rng:NextInteger(3,8),Color3.fromRGB(60,68,62))
            end
        end
        smallCampfire(folder,-120,610)
        smallCampfire(folder,145,890)
        local cabin=makePart(folder,"Cabin",Vector3.new(36,18,28),Vector3.new(150,9,600),Color3.fromRGB(72,57,45),Enum.Material.WoodPlanks)
        sign(folder,"CABIN 2015",Vector3.new(150,12,585),Vector3.new(18,6,1),Color3.fromRGB(58,47,42))
        sign(folder,"НЕ КОРМИ GUEST 0\\nDO NOT FEED GUEST 0",Vector3.new(-140,8,960),Vector3.new(26,7,1),Color3.fromRGB(48,57,49))
    elseif map=="Archive" then
        for z=510,1010,58 do
            neonStrip(folder,"RackLight",Vector3.new(-255,8,z),Vector3.new(2,10,1),Color3.fromRGB(68,145,255))
            neonStrip(folder,"RackLight",Vector3.new(255,8,z),Vector3.new(2,10,1),Color3.fromRGB(255,75,75))
        end
        for i=1,26 do
            local x=rng:NextInteger(-230,230)
            local z=rng:NextInteger(500,1020)
            local cable=makePart(folder,"Cable",Vector3.new(rng:NextInteger(8,20),.45,.45),Vector3.new(x,.5,z),Color3.fromRGB(24,25,29),Enum.Material.SmoothPlastic)
            cable.Orientation=Vector3.new(0,rng:NextInteger(0,180),0)
            cable.CanCollide=false
        end
        sign(folder,"ACCESS LEVEL: OLD OWNER",Vector3.new(0,13,540),Vector3.new(32,8,1),Color3.fromRGB(42,52,66))
    else
        -- Finale deliberately looks like several old maps collided.
        for i=1,35 do
            local choice=rng:NextInteger(1,5)
            local x=rng:NextInteger(-260,260)
            local z=rng:NextInteger(500,1020)
            if choice==1 then tree(folder,x,z,rng:NextNumber(.5,.9))
            elseif choice==2 then barrel(folder,x,z)
            elseif choice==3 then crate(folder,x,2.5,z,.8)
            elseif choice==4 then rock(folder,x,z,8,5,8,Color3.fromRGB(81,62,94))
            else neonStrip(folder,"LostNeon",Vector3.new(x,4,z),Vector3.new(10,.8,1),Color3.fromRGB(186,61,246)) end
        end
        sign(folder,"LAST SAVE",Vector3.new(0,16,720),Vector3.new(36,10,1),Color3.fromRGB(65,42,78))
    end
end

function WorldService:_objectiveNodes(folder,chapter,rng)
    local suburbPositions={
        [1]={
            Vector3.new(-102,3,515), Vector3.new(108,3,523),
            Vector3.new(-118,3,630), Vector3.new(112,3,625),
        },
        [2]={
            Vector3.new(-74,2,625), Vector3.new(-142,2,812),
            Vector3.new(142,2,744), Vector3.new(-18,2,870),
            Vector3.new(82,2,755),
        },
        [3]={
            Vector3.new(-45,4,970), Vector3.new(45,4,970),
        },
        [4]={
            Vector3.new(0,4,1028),
        },
    }

    for step,taskInfo in ipairs(chapter.tasks) do
        for i=1,taskInfo.count do
            local pos
            if chapter.map=="Suburb" and suburbPositions[step] and suburbPositions[step][i] then
                pos=suburbPositions[step][i]
            else
                pos=Vector3.new(rng:NextInteger(-245,245),4,510+(step-1)*120+rng:NextInteger(0,80))
            end

            local size=Vector3.new(6,8,6)
            local color=Color3.fromRGB(229,167-step*14,72+step*20)
            local material=Enum.Material.Metal

            if chapter.map=="Suburb" then
                if step==1 then
                    size=Vector3.new(4,3,2)
                    color=Color3.fromRGB(92,129,160)
                    material=Enum.Material.SmoothPlastic
                elseif step==2 then
                    size=Vector3.new(3.5,.6,4.5)
                    color=Color3.fromRGB(255,224,127)
                    material=Enum.Material.Neon
                elseif step==3 then
                    size=Vector3.new(5,8,3)
                    color=Color3.fromRGB(77,91,102)
                    material=Enum.Material.Metal
                else
                    size=Vector3.new(8,6,3)
                    color=Color3.fromRGB(77,172,126)
                    material=Enum.Material.Neon
                end
            end

            local obj=makePart(folder,"Objective_"..step.."_"..i,size,pos,color,material)
            obj:SetAttribute("ObjectiveType","ChapterTask")
            obj:SetAttribute("TaskStep",step)
            obj:SetAttribute("ObjectiveIndex",i)
            local pp=addPrompt(obj,taskInfo.action,taskInfo.object,.3)
            pp.Enabled=(step==1)
        end
    end
end

function WorldService:_eggs(folder,chapter,rng)
    for _,egg in ipairs(chapter.eggs or {}) do
        local e=makePart(folder,"EasterEgg_"..egg.name,Vector3.new(4,4,4),Vector3.new(rng:NextInteger(-260,260),3,rng:NextInteger(500,1020)),Color3.fromRGB(255,214,92),Enum.Material.Neon)
        e:SetAttribute("EasterEggText",egg.text)
        e:SetAttribute("EasterEggReward",egg.reward or 10)
        addPrompt(e,"Осмотреть / Inspect","Секрет / Secret",.2)
    end
end

function WorldService:_memories(folder,chapter,rng)
    local ids=chapter.memoryIndices or (chapter.memoryIndex and {chapter.memoryIndex}) or nil
    if not ids then return end
    for _,idx in ipairs(ids) do
        local m=makePart(folder,"MemoryFragment"..idx,Vector3.new(3,6,1),Vector3.new(rng:NextInteger(-230,230),4,rng:NextInteger(540,1000)),Color3.fromRGB(255,245,205),Enum.Material.Neon)
        m:SetAttribute("MemoryIndex",idx)
        addPrompt(m,idx==5 and "Почтить / Remember" or "Вспомнить / Remember","Память / Memory",idx==5 and 1.5 or .35)
    end
end

function WorldService:_memorial(folder)
    local garden=Instance.new("Folder"); garden.Name="MemorialGarden"; garden.Parent=folder
    local base=makePart(garden,"MemorialBase",Vector3.new(70,2,70),Vector3.new(0,-180,800),Color3.fromRGB(62,97,63),Enum.Material.Grass)
    base.CanCollide=true
    makePart(garden,"MemorialStone",Vector3.new(9,13,3),Vector3.new(0,-172,820),Color3.fromRGB(105,105,110),Enum.Material.Slate)
    sign(garden,Config.MEMORIAL_TITLE.."\n"..Config.MEMORIAL_EPITAPH,Vector3.new(0,-166,817),Vector3.new(24,10,1))
    local sp=makePart(garden,"MemorialSpawn",Vector3.new(4,1,4),Vector3.new(0,-177,790),Color3.new(1,1,1))
    sp.Transparency=1
    sp.CanCollide=false
end

function WorldService:BuildChapter(chapter,seed)
    if self.current then self.current:Destroy() end
    local lobby=self.root:FindFirstChild("Lobby")
    if lobby then lobby:Destroy() end
    local f=Instance.new("Folder")
    f.Name="Arena"
    f.Parent=self.root
    self.current=f
    self.currentChapter=chapter
    self.roundSeed=seed or 1
    local rng=Random.new(self.roundSeed+chapter.id*1009)
    self:_makeBase(f,chapter,rng)
    if chapter.map~="Suburb" then
        self:_decorateChapter(f,chapter,rng)
        LevelDesign.DecorateChapter(f,chapter,rng)
    end
    self:_objectiveNodes(f,chapter,rng)
    self:_eggs(f,chapter,rng)
    self:_memories(f,chapter,rng)
    self:_memorial(f)
    self:RestorePreviousBuilds(f,rng)
    return f
end

function WorldService:SetTaskEnabled(step,enabled)
    if not self.current then return end
    for _,obj in ipairs(self.current:GetDescendants()) do
        if obj:IsA("BasePart") and obj:GetAttribute("TaskStep")==step then
            local pp=obj:FindFirstChildOfClass("ProximityPrompt")
            if pp then pp.Enabled=enabled end
            if enabled then obj.Material=Enum.Material.Neon end
        end
    end
end

function WorldService:StoreBuilds(buildFolder)
    self.previousBuilds={}
    if not buildFolder then return end
    for _,p in ipairs(buildFolder:GetChildren()) do
        if p:IsA("BasePart") then
            table.insert(self.previousBuilds,{cf=p.CFrame,size=p.Size,color=p.Color})
        end
    end
end

function WorldService:RestorePreviousBuilds(folder,rng)
    if #self.previousBuilds==0 then return end
    local g=Instance.new("Folder")
    g.Name="PreviousChapterGlitches"
    g.Parent=folder
    for _,info in ipairs(self.previousBuilds) do
        if rng:NextNumber()<=Config.BUILD_SURVIVAL_CHANCE then
            local p=makePart(g,"CorruptedBuild",info.size,info.cf.Position,info.color,Enum.Material.Neon)
            p.CFrame=info.cf
            p.Transparency=rng:NextNumber(.25,.62)
            p.Color=Color3.fromRGB(180,50,255)
            if rng:NextNumber()<.3 then p.CanCollide=false end
        end
    end
end

function WorldService:CorruptPlayerBuilds(buildFolder,stage)
    if not buildFolder then return end
    local rng=Random.new(self.roundSeed+stage*3779)
    for _,p in ipairs(buildFolder:GetChildren()) do
        if p:IsA("BasePart") then
            local r=rng:NextNumber()
            if r<.04 then
                p:Destroy()
            elseif r<.13 then
                p.Material=Enum.Material.Neon
                p.Color=Color3.fromRGB(180,40,255)
                p.Transparency=rng:NextNumber(.15,.5)
                if rng:NextNumber()<.3 then p.CanCollide=false end
            end
        end
    end
end

function WorldService:CorruptStage(stage,chapter)
    if not self.current then return end
    local maxStages=math.max(1,math.ceil((chapter.duration or 2700)/Config.WORLD_UPDATE_INTERVAL))
    local s=math.clamp(stage/maxStages,0,1)
    -- Rot thickens the existing chapter atmosphere instead of replacing it.
    Lighting.FogEnd=math.max(170,Lighting.FogEnd-(14+stage*2))
    Lighting.FogStart=math.max(22,Lighting.FogStart-3)
    Lighting.ClockTime=(Lighting.ClockTime+0.22)%24

    local rng=Random.new(self.roundSeed+stage*7919+chapter.id*53)
    local updates=self.current:FindFirstChild("LiveUpdates") or Instance.new("Folder")
    updates.Name="LiveUpdates"
    updates.Parent=self.current
    for i=1,4 do
        local p=makePart(updates,"Update_"..stage.."_"..i,Vector3.new(rng:NextInteger(6,18),rng:NextInteger(2,10),rng:NextInteger(6,18)),Vector3.new(rng:NextInteger(-250,250),rng:NextInteger(2,15),rng:NextInteger(500,1020)),Color3.fromRGB(rng:NextInteger(100,185),35,rng:NextInteger(160,250)),Enum.Material.Neon)
        p.Transparency=rng:NextNumber(.15,.48)
        p.CanCollide=rng:NextNumber()>.25
    end

    if chapter.map=="ObbyPark" or chapter.map=="Finale" then
        for _,p in ipairs(self.current:GetDescendants()) do
            if p:IsA("BasePart") and p:GetAttribute("PulseToggle") and rng:NextNumber()<.18 then
                p.CanCollide=not p.CanCollide
                p.Transparency=p.CanCollide and 0 or .72
            end
        end
    elseif chapter.map=="Ocean" then
        for _,m in ipairs(self.current:GetChildren()) do
            if m:IsA("Model") and m:GetAttribute("DriftIsland") and m.PrimaryPart and rng:NextNumber()<.3 then
                m:PivotTo(m:GetPivot()*CFrame.new(rng:NextInteger(-10,10),0,rng:NextInteger(-10,10)))
            end
        end
    elseif chapter.map=="Chat" then
        for _,p in ipairs(self.current:GetChildren()) do
            if p:IsA("BasePart") and p:GetAttribute("ChatWall") and rng:NextNumber()<.1 then
                p.CanCollide=not p.CanCollide
                p.Transparency=p.CanCollide and 0 or .68
            end
        end
    end

    local messages={
        "SERVER UPDATE: карта пересобрана из другого кэша.",
        "WARNING: сервер помнит объект, которого здесь не было.",
        "PATCH NOTE: исправлена ошибка, из-за которой существовал выход.",
        "CHANGELOG: +1 неизвестный игрок, -3 стабильных блока.",
    }
    self.remotes.WorldPulse:FireAllClients(stage,messages[((stage-1)%#messages)+1])
end

return WorldService
