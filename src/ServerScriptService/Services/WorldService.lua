local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)

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
end

function WorldService:GetSpawnPosition()
    return self.spawnPosition
end

local function addArenaBounds(folder, centerZ)
    local minZ=centerZ-305
    local maxZ=centerZ+305
    for _,spec in ipairs({
        {Vector3.new(0,14,minZ),Vector3.new(620,28,4)},
        {Vector3.new(0,14,maxZ),Vector3.new(620,28,4)},
        {Vector3.new(-308,14,centerZ),Vector3.new(4,28,610)},
        {Vector3.new(308,14,centerZ),Vector3.new(4,28,610)},
    }) do
        local p=makePart(folder,"ArenaBoundary",spec[2],spec[1],Color3.fromRGB(45,43,48),Enum.Material.Slate)
        p.Transparency=.08
    end
end

function WorldService:_makeBase(folder, chapter, rng)
    self.spawnPosition=Vector3.new(0,4,470)
    Lighting.ClockTime=18.4
    Lighting.FogStart=100
    Lighting.FogEnd=520

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
    makePart(folder,"Ground",Vector3.new(620,4,620),Vector3.new(0,-2,760),pal[1],pal[2])
    addArenaBounds(folder,760)
    sign(folder,chapter.title.."\n"..chapter.subtitle,Vector3.new(0,11,452),Vector3.new(38,10,1))

    if chapter.map=="Suburb" then
        makePart(folder,"Road",Vector3.new(42,1,520),Vector3.new(0,.2,760),Color3.fromRGB(72,72,72),Enum.Material.Concrete)
        for row=0,4 do
            for _,side in ipairs({-1,1}) do
                local x=side*(82+(row%2)*18)
                local z=530+row*105
                makePart(folder,"House",Vector3.new(38,22,34),Vector3.new(x,11,z),Color3.fromRGB(181,174,151),Enum.Material.Brick)
            end
        end
        for i=1,34 do tree(folder,rng:NextInteger(-270,270),rng:NextInteger(480,1030),rng:NextNumber(.6,1.0)) end
        sign(folder,"ШКОЛА / SCHOOL",Vector3.new(0,9,980),Vector3.new(26,8,1),Color3.fromRGB(66,52,48))
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

function WorldService:_objectiveNodes(folder,chapter,rng)
    for step,taskInfo in ipairs(chapter.tasks) do
        for i=1,taskInfo.count do
            local x=rng:NextInteger(-245,245)
            local z=510+(step-1)*120+rng:NextInteger(0,80)
            local obj=makePart(folder,"Objective_"..step.."_"..i,Vector3.new(6,8,6),Vector3.new(x,4,z),Color3.fromRGB(229,167-step*14,72+step*20),Enum.Material.Metal)
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
    Lighting.FogEnd=520-250*s
    Lighting.FogStart=100-45*s
    Lighting.ClockTime=18.4+3.8*s

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
