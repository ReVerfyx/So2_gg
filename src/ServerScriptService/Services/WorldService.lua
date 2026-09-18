local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)

local WorldService = {}
WorldService.__index = WorldService

local function part(parent, name, size, pos, color, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.Size = size
    p.Position = pos
    p.Color = color or Color3.fromRGB(130,130,130)
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
    pp.HoldDuration = hold or 0.25
    pp.MaxActivationDistance = 13
    pp.RequiresLineOfSight = false
    pp.Parent = parent
    return pp
end

local function sign(parent, text, pos, size)
    local p = part(parent, "Sign", size or Vector3.new(24,10,1), pos, Color3.fromRGB(66,58,53), Enum.Material.WoodPlanks)
    local gui = Instance.new("SurfaceGui")
    gui.Face = Enum.NormalId.Front
    gui.Parent = p
    local l = Instance.new("TextLabel")
    l.Size = UDim2.fromScale(1,1)
    l.BackgroundTransparency = 1
    l.TextWrapped = true
    l.TextScaled = true
    l.Font = Enum.Font.Legacy
    l.TextColor3 = Color3.fromRGB(245,239,220)
    l.Text = text
    l.Parent = gui
    return p
end

local function tree(parent, x, z, s)
    s = s or 1
    part(parent,"TreeTrunk",Vector3.new(3,12,3)*s,Vector3.new(x,6*s,z),Color3.fromRGB(100,72,45),Enum.Material.Wood)
    local leaves=part(parent,"TreeLeaves",Vector3.new(11,10,11)*s,Vector3.new(x,15*s,z),Color3.fromRGB(62,118,61),Enum.Material.Grass)
    leaves.CanCollide=false
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
    Lighting.ClockTime=17.4
    Lighting.Brightness=2
    Lighting.Ambient=Color3.fromRGB(105,108,125)
    Lighting.OutdoorAmbient=Color3.fromRGB(126,112,101)
    Lighting.FogColor=Color3.fromRGB(120,130,143)
    Lighting.FogStart=100
    Lighting.FogEnd=720
    local a=Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
    a.Density=.22
    a.Haze=1
    a.Color=Color3.fromRGB(205,214,225)
    a.Decay=Color3.fromRGB(110,78,89)
    a.Parent=Lighting
end

function WorldService:BuildLobby()
    if self.current then self.current:Destroy(); self.current=nil end
    local old=self.root:FindFirstChild("Lobby")
    if old then old:Destroy() end
    local f=Instance.new("Folder"); f.Name="Lobby"; f.Parent=self.root
    part(f,"LobbyBase",Vector3.new(200,2,200),Vector3.new(0,-1,0),Color3.fromRGB(78,142,72),Enum.Material.Grass)
    local sp=Instance.new("SpawnLocation"); sp.Name="LobbySpawn"; sp.Size=Vector3.new(8,1,8); sp.Position=Vector3.new(0,2,0); sp.Neutral=true; sp.Transparency=1; sp.Parent=f
    sign(f,"2015: CODE ROT\n10 CHAPTERS / ~7.5 HOURS\nWorld update every 3 minutes",Vector3.new(0,11,-35),Vector3.new(34,12,1))
    local room=part(f,"RoomTerminal",Vector3.new(10,7,7),Vector3.new(-30,3.5,5),Color3.fromRGB(185,178,157),Enum.Material.Metal)
    local rp=addPrompt(room,"Create / Join Room","2015 Server Browser"); rp.Name="RoomPrompt"
    local cls=part(f,"ClassTerminal",Vector3.new(10,7,7),Vector3.new(30,3.5,5),Color3.fromRGB(88,103,123),Enum.Material.Metal)
    local cp=addPrompt(cls,"Open Classes","Class Archive"); cp.Name="ClassPrompt"
    sign(f,"Your old builds may return as glitches.",Vector3.new(0,7,60),Vector3.new(28,8,1))
    for i=1,10 do tree(f,-90+i*18,55+(i%2)*20,.8+(i%3)*.1) end
end

function WorldService:GetSpawnPosition()
    return self.spawnPosition
end

function WorldService:_makeBase(folder, chapter, rng)
    self.spawnPosition=Vector3.new(0,4,430)
    local palettes={
        Suburb={Color3.fromRGB(80,145,76),Enum.Material.Grass},
        ObbyPark={Color3.fromRGB(74,142,82),Enum.Material.Grass},
        City={Color3.fromRGB(78,82,88),Enum.Material.Concrete},
        Warehouse={Color3.fromRGB(91,88,82),Enum.Material.Concrete},
        Canyon={Color3.fromRGB(150,101,66),Enum.Material.Sandstone},
        Islands={Color3.fromRGB(47,101,145),Enum.Material.SmoothPlastic},
        ChatMaze={Color3.fromRGB(35,38,47),Enum.Material.Slate},
        Forest={Color3.fromRGB(47,83,50),Enum.Material.Grass},
        Archive={Color3.fromRGB(40,43,50),Enum.Material.Metal},
        Finale={Color3.fromRGB(68,60,78),Enum.Material.Slate},
    }
    local pal=palettes[chapter.map] or palettes.Finale
    part(folder,"Ground",Vector3.new(1000,4,820),Vector3.new(0,-2,760),pal[1],pal[2])
    sign(folder,chapter.title.."\n"..chapter.subtitle,Vector3.new(0,13,455),Vector3.new(36,11,1))

    if chapter.map=="Suburb" then
        part(folder,"Road",Vector3.new(52,1,700),Vector3.new(0,.2,760),Color3.fromRGB(82,82,82),Enum.Material.Concrete)
        for row=0,5 do
            for _,side in ipairs({-1,1}) do
                local x=side*(100+(row%2)*30); local z=520+row*95
                part(folder,"House",Vector3.new(42,24,38),Vector3.new(x,12,z),Color3.fromRGB(190+side*10,185,160),Enum.Material.Brick)
            end
        end
        for i=1,28 do tree(folder,rng:NextInteger(-440,440),rng:NextInteger(470,1110),rng:NextNumber(.65,1.1)) end
    elseif chapter.map=="ObbyPark" then
        for lane=-2,2 do for i=1,10 do
            local p=part(folder,"DynamicPlatform",Vector3.new(28,3,28),Vector3.new(lane*110+rng:NextInteger(-20,20),3+((i+lane)%3)*5,480+i*60),Color3.fromRGB(180+rng:NextInteger(0,70),80+rng:NextInteger(0,100),90+rng:NextInteger(0,100)))
            p:SetAttribute("PulseToggle",true)
        end end
    elseif chapter.map=="City" then
        for x=-360,360,120 do part(folder,"Street",Vector3.new(28,1,780),Vector3.new(x,.1,760),Color3.fromRGB(42,44,48),Enum.Material.Pavement) end
        for gx=-3,3 do for gz=0,5 do if gx~=0 then
            local h=rng:NextInteger(35,100)
            part(folder,"Building",Vector3.new(78,h,78),Vector3.new(gx*115,h/2,500+gz*105),Color3.fromRGB(90+rng:NextInteger(0,50),90+rng:NextInteger(0,50),100+rng:NextInteger(0,50)),Enum.Material.Concrete)
        end end end
    elseif chapter.map=="Warehouse" then
        part(folder,"Warehouse",Vector3.new(820,32,620),Vector3.new(0,16,760),Color3.fromRGB(92,91,87),Enum.Material.Metal).Transparency=.12
        for i=1,70 do part(folder,"FreeModelCrate",Vector3.new(14,14,14),Vector3.new(rng:NextInteger(-390,390),7,rng:NextInteger(500,1040)),Color3.fromRGB(rng:NextInteger(80,220),rng:NextInteger(60,180),rng:NextInteger(80,220))) end
    elseif chapter.map=="Canyon" then
        for i=1,24 do
            local x=rng:NextInteger(-430,430); local z=rng:NextInteger(480,1100); local h=rng:NextInteger(30,110)
            part(folder,"CanyonPillar",Vector3.new(rng:NextInteger(35,80),h,rng:NextInteger(35,80)),Vector3.new(x,h/2,z),Color3.fromRGB(156,103,67),Enum.Material.Sandstone)
        end
    elseif chapter.map=="Islands" then
        part(folder,"Water",Vector3.new(1000,2,820),Vector3.new(0,-1,760),Color3.fromRGB(45,99,145),Enum.Material.Glass)
        for i=1,14 do
            local island=Instance.new("Model"); island.Name="BackupIsland"; island:SetAttribute("DriftIsland",true); island.Parent=folder
            local b=part(island,"Island",Vector3.new(rng:NextInteger(70,120),8,rng:NextInteger(70,120)),Vector3.new(rng:NextInteger(-420,420),rng:NextInteger(8,24),rng:NextInteger(500,1080)),Color3.fromRGB(91,137,77),Enum.Material.Grass)
            island.PrimaryPart=b
        end
    elseif chapter.map=="ChatMaze" then
        for x=-8,8 do for z=0,12 do
            if (x+z)%3~=0 then
                local w=part(folder,"ChatWall",Vector3.new(4,24,48),Vector3.new(x*55,12,470+z*50),Color3.fromRGB(60,64,79),Enum.Material.Slate)
                w:SetAttribute("ChatWall",true)
            end
        end end
    elseif chapter.map=="Forest" then
        for i=1,120 do tree(folder,rng:NextInteger(-470,470),rng:NextInteger(450,1120),rng:NextNumber(.65,1.25)) end
    elseif chapter.map=="Archive" then
        for x=-4,4 do for z=0,8 do
            part(folder,"ArchiveRack",Vector3.new(34,40,12),Vector3.new(x*95,20,500+z*72),Color3.fromRGB(56,59,66),Enum.Material.Metal)
        end end
        for i=1,10 do local l=part(folder,"ArchiveLaser",Vector3.new(780,.6,.6),Vector3.new(0,4+i*2,480+i*55),Color3.fromRGB(255,50,80),Enum.Material.Neon); l:SetAttribute("ArchiveLaser",true); l.CanCollide=false end
    else
        -- finale deliberately mixes fragments from all earlier maps
        part(folder,"RoadFragment",Vector3.new(50,1,400),Vector3.new(-260,.2,720),Color3.fromRGB(80,80,80),Enum.Material.Concrete)
        for i=1,18 do tree(folder,rng:NextInteger(-440,440),rng:NextInteger(470,1100),rng:NextNumber(.6,1.0)) end
        for i=1,22 do
            local p=part(folder,"MemoryPlatform",Vector3.new(30,3,30),Vector3.new(rng:NextInteger(-390,390),rng:NextInteger(2,30),rng:NextInteger(500,1080)),Color3.fromRGB(120+rng:NextInteger(0,120),40,180+rng:NextInteger(0,70)),Enum.Material.Neon)
            p:SetAttribute("PulseToggle",true)
        end
    end
end

function WorldService:_objectiveNodes(folder,chapter,rng)
    for step,taskInfo in ipairs(chapter.tasks) do
        for i=1,taskInfo.count do
            local x=rng:NextInteger(-420,420)
            local z=500+(step-1)*140+rng:NextInteger(0,110)
            local obj=part(folder,"Objective_"..step.."_"..i,Vector3.new(6,8,6),Vector3.new(x,4,z),Color3.fromRGB(245,197-step*20,74+step*25),Enum.Material.Metal)
            obj:SetAttribute("ObjectiveType","ChapterTask")
            obj:SetAttribute("TaskStep",step)
            obj:SetAttribute("ObjectiveIndex",i)
            local pp=addPrompt(obj,taskInfo.action,taskInfo.object,.35)
            pp.Enabled=(step==1)
        end
    end
end

function WorldService:_eggs(folder,chapter,rng)
    for i,egg in ipairs(chapter.eggs or {}) do
        local e=part(folder,"EasterEgg_"..egg.name,Vector3.new(4,4,4),Vector3.new(rng:NextInteger(-440,440),3,rng:NextInteger(500,1090)),Color3.fromRGB(255,218,92),Enum.Material.Neon)
        e:SetAttribute("EasterEggText",egg.text)
        e:SetAttribute("EasterEggReward",egg.reward or 10)
        addPrompt(e,"Inspect","Old secret",.2)
    end
end

function WorldService:_memories(folder,chapter,rng)
    local ids=chapter.memoryIndices or (chapter.memoryIndex and {chapter.memoryIndex}) or nil
    if not ids then return end
    for _,idx in ipairs(ids) do
        local m=part(folder,"MemoryFragment"..idx,Vector3.new(3,6,1),Vector3.new(rng:NextInteger(-360,360),4,rng:NextInteger(550,1040)),Color3.fromRGB(255,245,205),Enum.Material.Neon)
        m:SetAttribute("MemoryIndex",idx)
        addPrompt(m,idx==5 and "Press F" or "Remember","Faint memory",idx==5 and 1.5 or .4)
    end
end

function WorldService:_memorial(folder)
    local garden=Instance.new("Folder"); garden.Name="MemorialGarden"; garden.Parent=folder
    local base=part(garden,"MemorialBase",Vector3.new(70,2,70),Vector3.new(0,-180,800),Color3.fromRGB(62,97,63),Enum.Material.Grass)
    base.CanCollide=true
    local stone=part(garden,"MemorialStone",Vector3.new(9,13,3),Vector3.new(0,-172,820),Color3.fromRGB(105,105,110),Enum.Material.Slate)
    sign(garden,Config.MEMORIAL_TITLE.."\n"..Config.MEMORIAL_EPITAPH,Vector3.new(0,-166,817),Vector3.new(24,10,1))
    local sp=part(garden,"MemorialSpawn",Vector3.new(4,1,4),Vector3.new(0,-177,790),Color3.new(1,1,1)); sp.Transparency=1; sp.CanCollide=false
end

function WorldService:BuildChapter(chapter,seed)
    if self.current then self.current:Destroy() end
    local lobby=self.root:FindFirstChild("Lobby"); if lobby then lobby:Destroy() end
    local f=Instance.new("Folder"); f.Name="Arena"; f.Parent=self.root
    self.current=f; self.currentChapter=chapter; self.roundSeed=seed or 1
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
        if p:IsA("BasePart") then table.insert(self.previousBuilds,{cf=p.CFrame,size=p.Size,color=p.Color}) end
    end
end

function WorldService:RestorePreviousBuilds(folder,rng)
    if #self.previousBuilds==0 then return end
    local g=Instance.new("Folder"); g.Name="PreviousChapterGlitches"; g.Parent=folder
    for _,info in ipairs(self.previousBuilds) do
        if rng:NextNumber()<=Config.BUILD_SURVIVAL_CHANCE then
            local p=part(g,"CorruptedBuild",info.size,info.cf.Position,info.color,Enum.Material.Neon)
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
            if r<.055 then p:Destroy()
            elseif r<.16 then
                p.Material=Enum.Material.Neon
                p.Color=Color3.fromRGB(180,40,255)
                p.Transparency=rng:NextNumber(.15,.55)
                if rng:NextNumber()<.35 then p.CanCollide=false end
            end
        end
    end
end

function WorldService:CorruptStage(stage,chapter)
    if not self.current then return end
    local maxStages=math.max(1,math.ceil((chapter.duration or 2700)/Config.WORLD_UPDATE_INTERVAL))
    local s=math.clamp(stage/maxStages,0,1)
    Lighting.FogEnd=720-430*s
    Lighting.FogStart=100-60*s
    Lighting.ClockTime=17.4+4.2*s
    local rng=Random.new(self.roundSeed+stage*7919+chapter.id*53)
    local updates=self.current:FindFirstChild("LiveUpdates") or Instance.new("Folder")
    updates.Name="LiveUpdates"; updates.Parent=self.current
    for i=1,5 do
        local p=part(updates,"Update_"..stage.."_"..i,Vector3.new(rng:NextInteger(7,24),rng:NextInteger(3,14),rng:NextInteger(7,24)),Vector3.new(rng:NextInteger(-430,430),rng:NextInteger(2,18),rng:NextInteger(470,1110)),Color3.fromRGB(rng:NextInteger(90,190),30,rng:NextInteger(150,255)),Enum.Material.Neon)
        p.Transparency=rng:NextNumber(.1,.5)
        p.CanCollide=rng:NextNumber()>.25
    end
    if chapter.map=="ObbyPark" or chapter.map=="Finale" then
        for _,p in ipairs(self.current:GetDescendants()) do
            if p:IsA("BasePart") and p:GetAttribute("PulseToggle") and rng:NextNumber()<.22 then
                p.CanCollide=not p.CanCollide
                p.Transparency=p.CanCollide and 0 or .75
            end
        end
    elseif chapter.map=="Islands" then
        for _,m in ipairs(self.current:GetChildren()) do
            if m:IsA("Model") and m:GetAttribute("DriftIsland") and m.PrimaryPart and rng:NextNumber()<.35 then
                m:PivotTo(m:GetPivot()*CFrame.new(rng:NextInteger(-16,16),0,rng:NextInteger(-16,16)))
            end
        end
    elseif chapter.map=="ChatMaze" then
        for _,p in ipairs(self.current:GetChildren()) do
            if p:IsA("BasePart") and p:GetAttribute("ChatWall") and rng:NextNumber()<.12 then p.CanCollide=not p.CanCollide; p.Transparency=p.CanCollide and 0 or .7 end
        end
    end
    local messages={
        "SERVER UPDATE: map rebuilt from another cache.",
        "WARNING: the server remembers an object that was never here.",
        "PATCH NOTE: fixed a bug where the exit existed.",
        "CHANGELOG: +1 unknown player, -3 stable bricks.",
    }
    self.remotes.WorldPulse:FireAllClients(stage,messages[((stage-1)%#messages)+1])
end

return WorldService
