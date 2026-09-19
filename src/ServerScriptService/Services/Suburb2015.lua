local Lighting = game:GetService("Lighting")

local Suburb2015 = {}

local function p(parent,name,size,pos,color,material,collide)
    local x=Instance.new("Part")
    x.Name=name
    x.Anchored=true
    x.Size=size
    x.Position=pos
    x.Color=color
    x.Material=material or Enum.Material.SmoothPlastic
    x.TopSurface=Enum.SurfaceType.Smooth
    x.BottomSurface=Enum.SurfaceType.Smooth
    x.CanCollide=collide ~= false
    x.Parent=parent
    return x
end

local function glow(parent,name,size,pos,color,range,brightness)
    local x=p(parent,name,size,pos,color,Enum.Material.Neon,false)
    local l=Instance.new("PointLight")
    l.Color=color
    l.Range=range or 22
    l.Brightness=brightness or 1.5
    l.Shadows=true
    l.Parent=x
    return x
end

local function surfaceText(part,text,color)
    local gui=Instance.new("SurfaceGui")
    gui.Face=Enum.NormalId.Front
    gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud=28
    gui.LightInfluence=.2
    gui.Parent=part
    local t=Instance.new("TextLabel")
    t.Size=UDim2.fromScale(1,1)
    t.BackgroundTransparency=1
    t.TextScaled=true
    t.TextWrapped=true
    t.Font=Enum.Font.GothamBold
    t.TextColor3=color or Color3.fromRGB(248,244,230)
    t.TextStrokeTransparency=.65
    t.Text=text
    t.Parent=gui
end

local function sign(parent,text,pos,size,bg,fg)
    local s=p(parent,"SuburbSign",size,pos,bg or Color3.fromRGB(78,64,55),Enum.Material.WoodPlanks,true)
    surfaceText(s,text,fg)
    return s
end

local function bush(parent,pos,scale,flowerColor)
    local s=scale or 1
    local b=p(parent,"Bush",Vector3.new(5,3.5,5)*s,pos+Vector3.new(0,1.7*s,0),Color3.fromRGB(61,121,65),Enum.Material.Grass,false)
    b.Shape=Enum.PartType.Ball
    if flowerColor then
        for i=1,3 do
            local a=(i/3)*math.pi*2
            local f=p(parent,"Flower",Vector3.new(.55,.55,.55),pos+Vector3.new(math.cos(a)*1.5*s,2.7*s,math.sin(a)*1.5*s),flowerColor,Enum.Material.Neon,false)
            f.Shape=Enum.PartType.Ball
        end
    end
end

local function tree(parent,pos,scale)
    local s=scale or 1
    p(parent,"TreeTrunk",Vector3.new(2.8,11,2.8)*s,pos+Vector3.new(0,5.5*s,0),Color3.fromRGB(112,78,52),Enum.Material.Wood,true)
    local leaves=p(parent,"TreeLeaves",Vector3.new(10,9,10)*s,pos+Vector3.new(0,13.5*s,0),Color3.fromRGB(60,132,70),Enum.Material.Grass,false)
    leaves.Shape=Enum.PartType.Ball
end

local function streetLamp(parent,pos)
    p(parent,"LampPost",Vector3.new(.7,10,.7),pos+Vector3.new(0,5,0),Color3.fromRGB(55,58,64),Enum.Material.Metal,true)
    local head=glow(parent,"LampHead",Vector3.new(2.4,1.2,2.4),pos+Vector3.new(0,10.5,0),Color3.fromRGB(255,201,117),28,1.8)
    head.Shape=Enum.PartType.Ball
end

local function fence(parent,startPos,endPos)
    local d=endPos-startPos
    local len=d.Magnitude
    if len<1 then return end
    local mid=(startPos+endPos)/2
    local yaw=math.deg(math.atan2(-d.Z,d.X))
    for y=2,4 do
        local r=p(parent,"FenceRail",Vector3.new(len,.45,.45),mid+Vector3.new(0,y,0),Color3.fromRGB(228,218,192),Enum.Material.WoodPlanks,true)
        r.Orientation=Vector3.new(0,yaw,0)
    end
    local n=math.max(1,math.floor(len/7))
    for i=0,n do
        local q=startPos:Lerp(endPos,i/n)
        p(parent,"FencePost",Vector3.new(.55,5,.55),q+Vector3.new(0,2.5,0),Color3.fromRGB(236,226,202),Enum.Material.WoodPlanks,true)
    end
end

local function car(parent,pos,color,rotation)
    local body=p(parent,"CarBody",Vector3.new(12,3,6),pos+Vector3.new(0,2,0),color,Enum.Material.SmoothPlastic,true)
    body.Orientation=Vector3.new(0,rotation or 0,0)
    local cab=p(parent,"CarCab",Vector3.new(6,2.8,5.2),pos+Vector3.new(1.2,4.5,0),color:Lerp(Color3.new(1,1,1),.08),Enum.Material.SmoothPlastic,true)
    cab.Orientation=body.Orientation
    for _,dx in ipairs({-4,4}) do
        for _,dz in ipairs({-2.6,2.6}) do
            local w=p(parent,"CarWheel",Vector3.new(2.2,2.2,1),pos+Vector3.new(dx,1,dz),Color3.fromRGB(35,35,38),Enum.Material.SmoothPlastic,true)
            w.Shape=Enum.PartType.Cylinder
            w.Orientation=Vector3.new(0,0,90)
        end
    end
end

local function mailbox(parent,pos,color)
    p(parent,"MailboxPost",Vector3.new(.5,3,.5),pos+Vector3.new(0,1.5,0),Color3.fromRGB(115,79,51),Enum.Material.Wood,true)
    local box=p(parent,"Mailbox",Vector3.new(2.8,2.2,3),pos+Vector3.new(0,3.5,0),color or Color3.fromRGB(79,112,150),Enum.Material.Metal,true)
    return box
end

local function house(parent,center,bodyColor,roofColor,doorColor,number)
    local m=Instance.new("Model")
    m.Name="House_"..tostring(number or "")
    m.Parent=parent

    local w,d,h=42,34,18
    p(m,"Foundation",Vector3.new(w+4,1,d+4),center+Vector3.new(0,.5,0),Color3.fromRGB(213,207,192),Enum.Material.Concrete,true)
    p(m,"Body",Vector3.new(w,h,d),center+Vector3.new(0,h/2+1,0),bodyColor,Enum.Material.WoodPlanks,true)

    -- Two angled roof slabs create a recognizable suburban silhouette.
    local left=p(m,"RoofLeft",Vector3.new(23,1.3,d+5),center+Vector3.new(-10,21,0),roofColor,Enum.Material.Slate,true)
    left.Orientation=Vector3.new(0,0,-24)
    local right=p(m,"RoofRight",Vector3.new(23,1.3,d+5),center+Vector3.new(10,21,0),roofColor,Enum.Material.Slate,true)
    right.Orientation=Vector3.new(0,0,24)

    local frontZ=center.Z-d/2-.55
    local door=p(m,"FrontDoor",Vector3.new(6,10,.8),Vector3.new(center.X,6,frontZ),doorColor,Enum.Material.WoodPlanks,true)
    local knob=p(m,"DoorKnob",Vector3.new(.5,.5,.5),Vector3.new(center.X+2,6,frontZ-.5),Color3.fromRGB(233,192,88),Enum.Material.Metal,false)
    knob.Shape=Enum.PartType.Ball

    for _,xoff in ipairs({-12,12}) do
        local win=p(m,"Window",Vector3.new(8,7,.45),Vector3.new(center.X+xoff,11,frontZ-.25),Color3.fromRGB(166,220,244),Enum.Material.Glass,false)
        win.Transparency=.18
        p(m,"WindowFrameV",Vector3.new(.45,7,.2),Vector3.new(center.X+xoff,11,frontZ-.55),Color3.fromRGB(245,239,222),Enum.Material.WoodPlanks,false)
        p(m,"WindowFrameH",Vector3.new(8,.45,.2),Vector3.new(center.X+xoff,11,frontZ-.55),Color3.fromRGB(245,239,222),Enum.Material.WoodPlanks,false)
    end

    -- Porch and steps.
    p(m,"Porch",Vector3.new(20,1,7),Vector3.new(center.X,.5,frontZ-4),Color3.fromRGB(147,114,80),Enum.Material.WoodPlanks,true)
    p(m,"Step1",Vector3.new(8,.7,3),Vector3.new(center.X,.35,frontZ-8),Color3.fromRGB(177,153,123),Enum.Material.Concrete,true)

    -- Small garden.
    bush(m,Vector3.new(center.X-16,0,frontZ-6),.72,Color3.fromRGB(255,122,163))
    bush(m,Vector3.new(center.X+16,0,frontZ-6),.72,Color3.fromRGB(255,205,83))

    if number then
        local plate=p(m,"HouseNumber",Vector3.new(2.8,1.5,.18),Vector3.new(center.X+4.5,9,frontZ-.65),Color3.fromRGB(59,62,68),Enum.Material.Metal,false)
        surfaceText(plate,tostring(number),Color3.fromRGB(255,255,245))
    end

    return m
end

local function school(parent)
    local c=Vector3.new(0,0,982)
    local m=Instance.new("Model")
    m.Name="School"
    m.Parent=parent

    p(m,"SchoolBody",Vector3.new(132,28,62),c+Vector3.new(0,14,0),Color3.fromRGB(207,157,109),Enum.Material.Brick,true)
    p(m,"SchoolRoof",Vector3.new(136,2,66),c+Vector3.new(0,29,0),Color3.fromRGB(86,69,68),Enum.Material.Slate,true)
    p(m,"Entrance",Vector3.new(36,20,8),c+Vector3.new(0,10,-35),Color3.fromRGB(192,140,97),Enum.Material.Brick,true)
    local signPart=sign(m,"ROBLOXIA SCHOOL\nEST. 2011",c+Vector3.new(0,23,-39.2),Vector3.new(46,8,.8),Color3.fromRGB(79,60,52),Color3.fromRGB(255,239,191))

    for _,xoff in ipairs({-48,-30,-12,12,30,48}) do
        local w=p(m,"SchoolWindow",Vector3.new(11,8,.45),c+Vector3.new(xoff,15,-31.25),Color3.fromRGB(152,213,243),Enum.Material.Glass,false)
        w.Transparency=.15
    end

    for _,xoff in ipairs({-10,10}) do
        p(m,"SchoolDoor",Vector3.new(8,12,.7),c+Vector3.new(xoff,6,-39.4),Color3.fromRGB(68,103,136),Enum.Material.Metal,true)
    end

    -- Playground and courtyard.
    p(m,"SchoolCourt",Vector3.new(95,.5,60),c+Vector3.new(-115,.25,0),Color3.fromRGB(99,141,94),Enum.Material.Grass,true)
    fence(m,Vector3.new(-160,0,952),Vector3.new(-70,0,952))
    fence(m,Vector3.new(-160,0,1012),Vector3.new(-70,0,1012))

    -- Server room visual landmark inside the front-right section.
    glow(m,"ServerRoomWindow",Vector3.new(10,7,.25),c+Vector3.new(50,12,-31.7),Color3.fromRGB(104,226,255),25,1.1)
    return m
end

local function busStop(parent)
    local c=Vector3.new(-74,0,625)
    p(parent,"BusPad",Vector3.new(32,.5,14),c+Vector3.new(0,.25,0),Color3.fromRGB(186,184,177),Enum.Material.Concrete,true)
    p(parent,"BusBack",Vector3.new(30,9,.6),c+Vector3.new(0,4.5,5),Color3.fromRGB(87,117,134),Enum.Material.Metal,true)
    local glass=p(parent,"BusGlass",Vector3.new(26,7,.2),c+Vector3.new(0,4.7,4.65),Color3.fromRGB(156,219,239),Enum.Material.Glass,false)
    glass.Transparency=.28
    p(parent,"BusRoof",Vector3.new(32,.7,15),c+Vector3.new(0,9,0),Color3.fromRGB(66,90,105),Enum.Material.Metal,true)
    p(parent,"BusBench",Vector3.new(16,1,3),c+Vector3.new(0,2,-1),Color3.fromRGB(233,175,81),Enum.Material.WoodPlanks,true)
    sign(parent,"SERVER BUS\nNEXT: ???",c+Vector3.new(0,12,4.7),Vector3.new(20,5,.5),Color3.fromRGB(64,87,101),Color3.fromRGB(255,245,209))
end

local function miniMart(parent)
    local c=Vector3.new(142,0,744)
    p(parent,"MartBody",Vector3.new(58,20,44),c+Vector3.new(0,10,0),Color3.fromRGB(244,218,161),Enum.Material.Brick,true)
    p(parent,"MartRoof",Vector3.new(62,2,48),c+Vector3.new(0,21,0),Color3.fromRGB(193,74,70),Enum.Material.Slate,true)
    p(parent,"MartAwning",Vector3.new(50,2,7),c+Vector3.new(0,14,-25),Color3.fromRGB(223,87,76),Enum.Material.Fabric,true)
    sign(parent,"24/7 PIXEL MART",c+Vector3.new(0,18,-22.5),Vector3.new(36,7,.6),Color3.fromRGB(213,79,69),Color3.fromRGB(255,247,199))
    for _,xoff in ipairs({-17,17}) do
        local w=p(parent,"MartWindow",Vector3.new(14,8,.4),c+Vector3.new(xoff,8,-22.2),Color3.fromRGB(158,224,241),Enum.Material.Glass,false)
        w.Transparency=.2
    end
    p(parent,"MartDoor",Vector3.new(9,12,.6),c+Vector3.new(0,6,-22.5),Color3.fromRGB(69,128,159),Enum.Material.Metal,true)
    glow(parent,"MartSignGlow",Vector3.new(7,2,.25),c+Vector3.new(0,18,-22.9),Color3.fromRGB(255,200,89),16,.7)
end

local function playground(parent)
    local c=Vector3.new(-142,0,812)
    p(parent,"PlayArea",Vector3.new(78,.5,64),c+Vector3.new(0,.25,0),Color3.fromRGB(92,143,81),Enum.Material.Grass,true)
    for _,x in ipairs({-20,20}) do
        p(parent,"SwingLeg",Vector3.new(1,12,1),c+Vector3.new(x,6,-10),Color3.fromRGB(67,118,169),Enum.Material.Metal,true)
    end
    p(parent,"SwingTop",Vector3.new(42,1,1),c+Vector3.new(0,12,-10),Color3.fromRGB(67,118,169),Enum.Material.Metal,true)
    for _,x in ipairs({-11,11}) do
        p(parent,"SwingRope",Vector3.new(.18,7,.18),c+Vector3.new(x,8.5,-10),Color3.fromRGB(43,43,45),Enum.Material.Metal,false)
        p(parent,"SwingSeat",Vector3.new(4,.5,2),c+Vector3.new(x,5,-10),Color3.fromRGB(244,178,65),Enum.Material.WoodPlanks,true)
    end
    local slide=p(parent,"Slide",Vector3.new(7,1,22),c+Vector3.new(19,5,11),Color3.fromRGB(233,92,85),Enum.Material.Metal,true)
    slide.Orientation=Vector3.new(-23,0,0)
    sign(parent,"HAPPY BRICKS PARK",c+Vector3.new(0,7,28),Vector3.new(28,6,.6),Color3.fromRGB(73,117,73),Color3.fromRGB(255,244,187))
end

local function addRoads(parent)
    p(parent,"VisualGround",Vector3.new(1400,5,1400),Vector3.new(0,-4,760),Color3.fromRGB(78,144,75),Enum.Material.Grass,true)

    -- Main road and a cross street.
    p(parent,"MainRoad",Vector3.new(58,1,650),Vector3.new(0,.15,760),Color3.fromRGB(64,68,74),Enum.Material.Asphalt,true)
    p(parent,"CrossRoad",Vector3.new(520,1,54),Vector3.new(0,.16,735),Color3.fromRGB(64,68,74),Enum.Material.Asphalt,true)

    -- Sidewalks.
    p(parent,"SidewalkL",Vector3.new(10,1.2,650),Vector3.new(-34,.6,760),Color3.fromRGB(193,192,185),Enum.Material.Concrete,true)
    p(parent,"SidewalkR",Vector3.new(10,1.2,650),Vector3.new(34,.6,760),Color3.fromRGB(193,192,185),Enum.Material.Concrete,true)
    p(parent,"CrossWalkA",Vector3.new(520,1.2,8),Vector3.new(0,.6,702),Color3.fromRGB(193,192,185),Enum.Material.Concrete,true)
    p(parent,"CrossWalkB",Vector3.new(520,1.2,8),Vector3.new(0,.6,768),Color3.fromRGB(193,192,185),Enum.Material.Concrete,true)

    -- Center lane markings.
    for z=480,1040,26 do
        p(parent,"LaneMark",Vector3.new(1.2,.08,10),Vector3.new(0,.72,z),Color3.fromRGB(244,211,83),Enum.Material.Neon,false)
    end
    for x=-240,240,28 do
        p(parent,"CrossLaneMark",Vector3.new(10,.08,1.2),Vector3.new(x,.72,735),Color3.fromRGB(244,211,83),Enum.Material.Neon,false)
    end
end

function Suburb2015.ApplyLighting()
    Lighting.ClockTime=17.25
    Lighting.Brightness=2.8
    Lighting.Ambient=Color3.fromRGB(139,135,144)
    Lighting.OutdoorAmbient=Color3.fromRGB(155,146,140)
    Lighting.FogColor=Color3.fromRGB(188,181,201)
    Lighting.FogStart=260
    Lighting.FogEnd=1100

    local a=Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
    a.Density=.13
    a.Haze=.45
    a.Glare=.12
    a.Color=Color3.fromRGB(222,206,225)
    a.Decay=Color3.fromRGB(151,125,151)
    a.Parent=Lighting

    local cc=Lighting:FindFirstChild("ChapterColor") or Instance.new("ColorCorrectionEffect")
    cc.Name="ChapterColor"
    cc.Saturation=.14
    cc.Contrast=.04
    cc.Brightness=.03
    cc.TintColor=Color3.fromRGB(255,236,221)
    cc.Parent=Lighting

    local bloom=Lighting:FindFirstChild("ChapterBloom") or Instance.new("BloomEffect")
    bloom.Name="ChapterBloom"
    bloom.Intensity=.16
    bloom.Size=24
    bloom.Threshold=1.35
    bloom.Parent=Lighting
end

function Suburb2015.Build(parent,rng)
    Suburb2015.ApplyLighting()

    local root=Instance.new("Folder")
    root.Name="Suburb2015V2"
    root.Parent=parent

    addRoads(root)

    local colors={
        {Color3.fromRGB(236,176,132),Color3.fromRGB(111,68,62),Color3.fromRGB(74,124,151)},
        {Color3.fromRGB(166,210,223),Color3.fromRGB(75,91,113),Color3.fromRGB(224,139,87)},
        {Color3.fromRGB(224,205,145),Color3.fromRGB(118,82,58),Color3.fromRGB(87,133,91)},
        {Color3.fromRGB(192,176,226),Color3.fromRGB(88,66,111),Color3.fromRGB(216,109,112)},
        {Color3.fromRGB(174,219,171),Color3.fromRGB(70,102,76),Color3.fromRGB(86,123,173)},
    }

    local houseData={
        {-102,540,101},{108,548,102},{-118,655,103},{112,650,104},
        {-110,840,105},{108,850,106},{-125,925,107},{120,920,108},
    }
    for i,h in ipairs(houseData) do
        local c=colors[((i-1)%#colors)+1]
        house(root,Vector3.new(h[1],0,h[2]),c[1],c[2],c[3],h[3])
        mailbox(root,Vector3.new(h[1]+(h[1]<0 and 22 or -22),0,h[2]-23),c[3])
    end

    busStop(root)
    miniMart(root)
    playground(root)
    school(root)

    -- Street furniture and lush yards.
    for z=500,1030,70 do
        streetLamp(root,Vector3.new(-29,0,z))
        streetLamp(root,Vector3.new(29,0,z))
    end
    for _,z in ipairs({530,610,680,790,865,940,1015}) do
        tree(root,Vector3.new(-205,0,z),rng:NextNumber(.8,1.15))
        tree(root,Vector3.new(205,0,z+15),rng:NextNumber(.8,1.15))
        bush(root,Vector3.new(-183,0,z+14),rng:NextNumber(.6,.9),Color3.fromRGB(255,150,190))
        bush(root,Vector3.new(183,0,z-10),rng:NextNumber(.6,.9),Color3.fromRGB(255,220,94))
    end

    -- Cars make the roads feel like a real place instead of an empty test level.
    car(root,Vector3.new(-82,1,730),Color3.fromRGB(224,81,79),90)
    car(root,Vector3.new(83,1,755),Color3.fromRGB(73,139,207),90)
    car(root,Vector3.new(-18,1,870),Color3.fromRGB(240,193,67),0)
    car(root,Vector3.new(18,1,590),Color3.fromRGB(124,190,119),0)

    -- White fences around a few gardens.
    fence(root,Vector3.new(-158,0,505),Vector3.new(-65,0,505))
    fence(root,Vector3.new(65,0,515),Vector3.new(158,0,515))
    fence(root,Vector3.new(-165,0,885),Vector3.new(-72,0,885))
    fence(root,Vector3.new(72,0,890),Vector3.new(165,0,890))

    -- Natural visual boundary; collision is still handled by WorldService.
    for z=455,1065,22 do
        tree(root,Vector3.new(-300,0,z),rng:NextNumber(.9,1.3))
        tree(root,Vector3.new(300,0,z+8),rng:NextNumber(.9,1.3))
    end
    for x=-280,280,25 do
        tree(root,Vector3.new(x,0,455),rng:NextNumber(.85,1.25))
        tree(root,Vector3.new(x,0,1065),rng:NextNumber(.85,1.25))
    end

    -- Warm welcome sign: nostalgic first, unsettling second.
    sign(root,"WELCOME TO ROBLOXIA\nSERVER BUILD 2015",Vector3.new(0,13,474),Vector3.new(42,10,.9),Color3.fromRGB(73,101,83),Color3.fromRGB(255,242,188))

    -- Very limited corruption at start; the map becomes wrong over time.
    for _,pos in ipairs({Vector3.new(210,3,610),Vector3.new(-225,5,910)}) do
        local shard=glow(root,"EarlyCodeRot",Vector3.new(5,6,1),pos,Color3.fromRGB(190,88,255),12,.7)
        shard.Transparency=.18
    end

    return root
end

return Suburb2015
