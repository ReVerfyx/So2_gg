local LevelDesign = {}

local function part(parent,name,size,pos,color,material,collide)
    local p=Instance.new("Part")
    p.Name=name
    p.Anchored=true
    p.Size=size
    p.Position=pos
    p.Color=color or Color3.fromRGB(110,110,110)
    p.Material=material or Enum.Material.SmoothPlastic
    p.TopSurface=Enum.SurfaceType.Smooth
    p.BottomSurface=Enum.SurfaceType.Smooth
    p.CanCollide=collide ~= false
    p.Parent=parent
    return p
end

local function light(parent,color,range,brightness)
    local l=Instance.new("PointLight")
    l.Color=color
    l.Range=range or 24
    l.Brightness=brightness or 1.5
    l.Shadows=true
    l.Parent=parent
    return l
end

local function glow(parent,name,pos,size,color,range,brightness)
    local p=part(parent,name,size,pos,color,Enum.Material.Neon,false)
    light(p,color,range or 22,brightness or 1.5)
    return p
end

local function labelSurface(p,face,text,color)
    local gui=Instance.new("SurfaceGui")
    gui.Face=face
    gui.AlwaysOnTop=false
    gui.LightInfluence=.15
    gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud=24
    gui.Parent=p

    local t=Instance.new("TextLabel")
    t.Size=UDim2.fromScale(1,1)
    t.BackgroundTransparency=1
    t.TextWrapped=true
    t.TextScaled=true
    t.Font=Enum.Font.GothamBold
    t.TextColor3=color or Color3.fromRGB(240,235,220)
    t.TextStrokeTransparency=.7
    t.Text=text
    t.Parent=gui
end

local function sign(parent,text,pos,size,bg,fg)
    local p=part(parent,"DecorSign",size,pos,bg or Color3.fromRGB(47,44,44),Enum.Material.WoodPlanks,true)
    labelSurface(p,Enum.NormalId.Front,text,fg)
    labelSurface(p,Enum.NormalId.Back,text,fg)
    return p
end

local function crate(parent,pos,scale)
    local s=5*(scale or 1)
    local p=part(parent,"DecorCrate",Vector3.new(s,s,s),pos,Color3.fromRGB(111,79,48),Enum.Material.WoodPlanks,true)
    p.Orientation=Vector3.new(0,math.random(0,3)*90,0)
    return p
end

local function barrel(parent,pos,color)
    local p=part(parent,"DecorBarrel",Vector3.new(3.4,5,3.4),pos,color or Color3.fromRGB(71,76,78),Enum.Material.Metal,true)
    p.Shape=Enum.PartType.Cylinder
    p.Orientation=Vector3.new(0,0,90)
    return p
end

local function rock(parent,pos,size,color,collide)
    local p=part(parent,"DecorRock",size,pos,color or Color3.fromRGB(75,73,74),Enum.Material.Slate,collide ~= false)
    p.Orientation=Vector3.new(math.random(-12,12),math.random(0,180),math.random(-12,12))
    return p
end

local function bush(parent,pos,scale,color)
    local s=scale or 1
    local p=part(parent,"DecorBush",Vector3.new(5,3.5,5)*s,pos+Vector3.new(0,1.6*s,0),color or Color3.fromRGB(40,75,42),Enum.Material.Grass,false)
    p.Shape=Enum.PartType.Ball
    p.CastShadow=false
    return p
end

local function tree(parent,pos,scale,dark)
    local s=scale or 1
    part(parent,"DecorTreeTrunk",Vector3.new(3,12,3)*s,pos+Vector3.new(0,6*s,0),Color3.fromRGB(86,61,42),Enum.Material.Wood,true)
    local leaves=part(parent,"DecorTreeLeaves",Vector3.new(11,10,11)*s,pos+Vector3.new(0,15*s,0),dark and Color3.fromRGB(29,55,36) or Color3.fromRGB(43,79,46),Enum.Material.Grass,false)
    leaves.CastShadow=true
end

local function bench(parent,pos,rotation)
    local seat=part(parent,"DecorBenchSeat",Vector3.new(8,.7,2.2),pos+Vector3.new(0,2,0),Color3.fromRGB(91,66,47),Enum.Material.WoodPlanks,true)
    seat.Orientation=Vector3.new(0,rotation or 0,0)
    local back=part(parent,"DecorBenchBack",Vector3.new(8,2.4,.6),pos+Vector3.new(0,3.2,1),Color3.fromRGB(80,59,44),Enum.Material.WoodPlanks,true)
    back.Orientation=seat.Orientation
    for _,dx in ipairs({-3,3}) do
        local leg=part(parent,"BenchLeg",Vector3.new(.5,2,.5),pos+Vector3.new(dx,1,0),Color3.fromRGB(48,48,50),Enum.Material.Metal,true)
        leg.Orientation=seat.Orientation
    end
end

local function streetLamp(parent,pos,warm)
    part(parent,"DecorLampPost",Vector3.new(.8,11,.8),pos+Vector3.new(0,5.5,0),Color3.fromRGB(45,45,47),Enum.Material.Metal,true)
    local c=warm and Color3.fromRGB(255,188,105) or Color3.fromRGB(192,218,255)
    glow(parent,"DecorLampBulb",pos+Vector3.new(0,11.5,0),Vector3.new(1.8,1.8,1.8),c,28,1.9).Shape=Enum.PartType.Ball
end

local function fence(parent,a,b,height)
    local h=height or 5
    local d=b-a
    local len=d.Magnitude
    if len<1 then return end
    local mid=(a+b)/2
    local yaw=math.deg(math.atan2(-d.Z,d.X))
    local rail1=part(parent,"DecorFenceRail",Vector3.new(len,.55,.55),mid+Vector3.new(0,h*.45,0),Color3.fromRGB(79,58,42),Enum.Material.Wood,true)
    rail1.Orientation=Vector3.new(0,yaw,0)
    local rail2=part(parent,"DecorFenceRail",Vector3.new(len,.55,.55),mid+Vector3.new(0,h*.78,0),Color3.fromRGB(79,58,42),Enum.Material.Wood,true)
    rail2.Orientation=rail1.Orientation
    local steps=math.max(1,math.floor(len/8))
    for i=0,steps do
        local q=a:Lerp(b,i/steps)
        part(parent,"DecorFencePost",Vector3.new(.65,h,.65),q+Vector3.new(0,h/2,0),Color3.fromRGB(73,54,40),Enum.Material.Wood,true)
    end
end

local function stringLights(parent,a,b,count,color)
    local n=count or 10
    local c=color or Color3.fromRGB(255,198,118)
    for i=0,n do
        local alpha=i/n
        local p=a:Lerp(b,alpha)
        p=p-Vector3.new(0,math.sin(alpha*math.pi)*2,0)
        local bulb=part(parent,"StringBulb",Vector3.new(.65,.65,.65),p,c,Enum.Material.Neon,false)
        bulb.Shape=Enum.PartType.Ball
        bulb.CastShadow=false
        if i%3==0 then light(bulb,c,10,.5) end
    end
end

local function window(parent,pos,size,color)
    local p=part(parent,"Window",size,pos,color or Color3.fromRGB(111,151,178),Enum.Material.Glass,false)
    p.Transparency=.32
    return p
end

local function openRoom(parent,name,center,size,height,wallColor,material)
    local m=Instance.new("Model")
    m.Name=name
    m.Parent=parent

    local w,d=size.X,size.Z
    local h=height or 18
    local c=wallColor or Color3.fromRGB(92,86,79)
    local mat=material or Enum.Material.Brick

    part(m,"Floor",Vector3.new(w,1,d),center+Vector3.new(0,.5,0),Color3.fromRGB(72,68,64),Enum.Material.Concrete,true)
    part(m,"BackWall",Vector3.new(w,h,1),center+Vector3.new(0,h/2,d/2),c,mat,true)
    part(m,"LeftWall",Vector3.new(1,h,d),center+Vector3.new(-w/2,h/2,0),c,mat,true)
    part(m,"RightWall",Vector3.new(1,h,d),center+Vector3.new(w/2,h/2,0),c,mat,true)
    part(m,"Roof",Vector3.new(w+1,1,d+1),center+Vector3.new(0,h,0),Color3.fromRGB(48,47,49),Enum.Material.Slate,true)

    -- Front wall is split, leaving a broad entrance so the interior is playable.
    local sideW=(w-10)/2
    part(m,"FrontLeft",Vector3.new(sideW,h,1),center+Vector3.new(-(w/4+2.5),h/2,-d/2),c,mat,true)
    part(m,"FrontRight",Vector3.new(sideW,h,1),center+Vector3.new((w/4+2.5),h/2,-d/2),c,mat,true)
    return m
end

local function desk(parent,pos)
    part(parent,"DeskTop",Vector3.new(7,.7,3),pos+Vector3.new(0,3,0),Color3.fromRGB(92,70,51),Enum.Material.WoodPlanks,true)
    for _,dx in ipairs({-2.7,2.7}) do
        part(parent,"DeskLeg",Vector3.new(.5,3,.5),pos+Vector3.new(dx,1.5,0),Color3.fromRGB(51,51,54),Enum.Material.Metal,true)
    end
end

local function shelf(parent,pos,width,height)
    local w=width or 10
    local h=height or 10
    part(parent,"ShelfSide",Vector3.new(.5,h,3),pos+Vector3.new(-w/2,h/2,0),Color3.fromRGB(57,59,63),Enum.Material.Metal,true)
    part(parent,"ShelfSide",Vector3.new(.5,h,3),pos+Vector3.new(w/2,h/2,0),Color3.fromRGB(57,59,63),Enum.Material.Metal,true)
    for y=1,h-1,3 do
        part(parent,"ShelfBoard",Vector3.new(w,.4,3),pos+Vector3.new(0,y,0),Color3.fromRGB(66,68,72),Enum.Material.Metal,true)
    end
end

local function lockerRow(parent,pos,count)
    for i=1,count do
        local x=(i-(count+1)/2)*3.2
        local l=part(parent,"Locker",Vector3.new(2.8,7,2.2),pos+Vector3.new(x,3.5,0),Color3.fromRGB(78,91,101),Enum.Material.Metal,true)
        local slot=part(parent,"LockerSlot",Vector3.new(1.5,.22,.12),pos+Vector3.new(x,5.4,-1.12),Color3.fromRGB(28,32,35),Enum.Material.Metal,false)
    end
end

local function playground(parent,center)
    -- Swing frame.
    part(parent,"PlaygroundTop",Vector3.new(18,.8,.8),center+Vector3.new(0,10,0),Color3.fromRGB(68,83,105),Enum.Material.Metal,true)
    for _,x in ipairs({-8,8}) do
        local leg1=part(parent,"PlaygroundLeg",Vector3.new(.8,11,.8),center+Vector3.new(x,5,3),Color3.fromRGB(68,83,105),Enum.Material.Metal,true)
        leg1.Orientation=Vector3.new(0,0,x<0 and -12 or 12)
        local leg2=part(parent,"PlaygroundLeg",Vector3.new(.8,11,.8),center+Vector3.new(x,5,-3),Color3.fromRGB(68,83,105),Enum.Material.Metal,true)
        leg2.Orientation=leg1.Orientation
    end
    for _,x in ipairs({-4,4}) do
        part(parent,"SwingRope",Vector3.new(.18,6,.18),center+Vector3.new(x,7,0),Color3.fromRGB(35,35,36),Enum.Material.Metal,false)
        part(parent,"SwingSeat",Vector3.new(3,.35,1.4),center+Vector3.new(x,4,0),Color3.fromRGB(91,62,43),Enum.Material.WoodPlanks,true)
    end
    -- Simple slide.
    local slide=part(parent,"Slide",Vector3.new(5,.7,14),center+Vector3.new(18,4,0),Color3.fromRGB(161,67,66),Enum.Material.Metal,true)
    slide.Orientation=Vector3.new(0,0,-24)
end

local function buildSchool(folder)
    local c=Vector3.new(0,0,976)
    local m=openRoom(folder,"POI_School",c,Vector3.new(92,1,58),24,Color3.fromRGB(151,139,119),Enum.Material.Brick)
    sign(m,"ШКОЛА №15 / SCHOOL 15",c+Vector3.new(0,18,-29.7),Vector3.new(42,6,1),Color3.fromRGB(65,57,50))
    window(m,c+Vector3.new(-28,12,-29.6),Vector3.new(14,7,.4))
    window(m,c+Vector3.new(28,12,-29.6),Vector3.new(14,7,.4))
    lockerRow(m,c+Vector3.new(-24,0,23),8)
    lockerRow(m,c+Vector3.new(24,0,23),8)
    for row=0,2 do
        for col=-2,2 do
            desk(m,c+Vector3.new(col*12,0,-4+row*10))
        end
    end
    glow(m,"SchoolEmergencyLight",c+Vector3.new(0,18,22),Vector3.new(3,1,1),Color3.fromRGB(214,75,58),20,1.2)
end

local function buildBusStop(folder)
    local c=Vector3.new(-74,0,624)
    part(folder,"BusStopFloor",Vector3.new(24,.5,10),c+Vector3.new(0,.25,0),Color3.fromRGB(85,82,79),Enum.Material.Concrete,true)
    part(folder,"BusStopBack",Vector3.new(24,8,.6),c+Vector3.new(0,4,4),Color3.fromRGB(57,63,69),Enum.Material.Metal,true)
    part(folder,"BusStopRoof",Vector3.new(25,.6,11),c+Vector3.new(0,8,0),Color3.fromRGB(50,53,58),Enum.Material.Metal,true)
    window(folder,c+Vector3.new(0,4,3.65),Vector3.new(20,6,.2),Color3.fromRGB(118,145,158))
    bench(folder,c+Vector3.new(0,0,1),0)
    sign(folder,"SERVER BUS\nLAST STOP: 2015",c+Vector3.new(0,11,3.5),Vector3.new(18,5,.8),Color3.fromRGB(53,57,63))
end

local function buildSuburbShop(folder)
    local c=Vector3.new(128,0,744)
    local m=openRoom(folder,"POI_SuburbShop",c,Vector3.new(48,1,36),18,Color3.fromRGB(135,116,91),Enum.Material.Brick)
    sign(m,"24/7 MINI MART",c+Vector3.new(0,14,-18.6),Vector3.new(28,5,.8),Color3.fromRGB(76,55,45),Color3.fromRGB(255,225,174))
    shelf(m,c+Vector3.new(-12,0,7),14,10)
    shelf(m,c+Vector3.new(12,0,7),14,10)
    part(m,"Counter",Vector3.new(22,4,4),c+Vector3.new(0,2,-7),Color3.fromRGB(87,67,50),Enum.Material.WoodPlanks,true)
    glow(m,"ShopLight",c+Vector3.new(0,14,0),Vector3.new(18,.5,1.2),Color3.fromRGB(240,229,190),26,1.5)
end

local function buildObbyPOI(folder)
    local c=Vector3.new(0,0,492)
    part(folder,"ObbyArchLeft",Vector3.new(6,20,6),c+Vector3.new(-18,10,0),Color3.fromRGB(81,69,95),Enum.Material.Brick,true)
    part(folder,"ObbyArchRight",Vector3.new(6,20,6),c+Vector3.new(18,10,0),Color3.fromRGB(81,69,95),Enum.Material.Brick,true)
    part(folder,"ObbyArchTop",Vector3.new(42,5,6),c+Vector3.new(0,20,0),Color3.fromRGB(65,54,79),Enum.Material.Brick,true)
    sign(folder,"PLACE DELETED\nOBBY 2015",c+Vector3.new(0,21,-3.2),Vector3.new(28,7,.7),Color3.fromRGB(63,48,75))
    for side=-1,1,2 do
        for row=0,3 do
            local base=Vector3.new(side*170,0,600+row*30)
            part(folder,"StandStep",Vector3.new(56,3,24),base+Vector3.new(0,1.5,row*3),Color3.fromRGB(74,71,80),Enum.Material.Concrete,true)
        end
    end
    local win=openRoom(folder,"POI_WinnerRoom",Vector3.new(0,0,1000),Vector3.new(54,1,34),18,Color3.fromRGB(96,75,104),Enum.Material.Brick)
    sign(win,"WINNERS ONLY?",Vector3.new(0,14,982.5),Vector3.new(26,5,.8),Color3.fromRGB(69,48,76))
    glow(win,"WinnerGlow",Vector3.new(0,12,1007),Vector3.new(18,.6,1),Color3.fromRGB(116,220,255),25,1.5)
end

local function buildCityPOI(folder)
    local metro=Vector3.new(-95,0,750)
    local m=openRoom(folder,"POI_MetroEntrance",metro,Vector3.new(48,1,38),17,Color3.fromRGB(65,69,77),Enum.Material.Concrete)
    sign(m,"METRO\nLAST ONLINE",metro+Vector3.new(0,13,-19.5),Vector3.new(24,7,.8),Color3.fromRGB(45,51,62),Color3.fromRGB(202,220,255))
    for i=0,5 do
        part(m,"MetroStep",Vector3.new(24,1.2,4),metro+Vector3.new(0,.6+i*.45,-10+i*4),Color3.fromRGB(57,60,66),Enum.Material.Concrete,true)
    end
    glow(m,"MetroColdLight",metro+Vector3.new(0,12,10),Vector3.new(14,.5,1),Color3.fromRGB(174,209,255),25,1.7)

    local shop=Vector3.new(155,0,695)
    local s=openRoom(folder,"POI_Electronics",shop,Vector3.new(52,1,38),19,Color3.fromRGB(79,82,88),Enum.Material.Concrete)
    sign(s,"BYTE BOX\nELECTRONICS",shop+Vector3.new(0,15,-19.5),Vector3.new(28,6,.8),Color3.fromRGB(45,48,55),Color3.fromRGB(111,208,255))
    for x=-15,15,10 do shelf(s,shop+Vector3.new(x,0,8),8,10) end
    for x=-12,12,12 do
        local screen=part(s,"DeadMonitor",Vector3.new(7,4,.8),shop+Vector3.new(x,6,-2),Color3.fromRGB(22,27,32),Enum.Material.SmoothPlastic,false)
        glow(s,"MonitorGlow",shop+Vector3.new(x,6,-2.45),Vector3.new(5.5,2.5,.1),Color3.fromRGB(55,119,148),12,.5)
    end

    -- Alley cluster.
    for i=0,5 do
        barrel(folder,Vector3.new(225,2.5,555+i*14),i%2==0 and Color3.fromRGB(63,70,75) or Color3.fromRGB(83,63,55))
        crate(folder,Vector3.new(240,2.5,560+i*18),.75)
    end
end

local function buildWarehousePOI(folder)
    local office=Vector3.new(-190,0,610)
    local m=openRoom(folder,"POI_ForemanOffice",office,Vector3.new(56,1,34),17,Color3.fromRGB(83,87,89),Enum.Material.Metal)
    sign(m,"FOREMAN / 2015",office+Vector3.new(0,13,-17.5),Vector3.new(24,5,.7),Color3.fromRGB(48,51,53))
    desk(m,office+Vector3.new(0,0,4))
    shelf(m,office+Vector3.new(-16,0,9),10,10)
    window(m,office+Vector3.new(15,9,-17.4),Vector3.new(15,7,.25),Color3.fromRGB(134,157,166))

    local gen=Vector3.new(185,0,890)
    local g=openRoom(folder,"POI_GeneratorRoom",gen,Vector3.new(54,1,40),18,Color3.fromRGB(70,72,73),Enum.Material.Metal)
    sign(g,"GENERATOR\nAUTHORIZED ONLY",gen+Vector3.new(0,14,-20.5),Vector3.new(26,6,.8),Color3.fromRGB(62,54,49),Color3.fromRGB(255,198,99))
    for x=-14,14,14 do
        local unit=part(g,"Generator",Vector3.new(10,8,8),gen+Vector3.new(x,4,5),Color3.fromRGB(61,67,67),Enum.Material.Metal,true)
        glow(g,"GeneratorStatus",gen+Vector3.new(x,6,.9),Vector3.new(4,.5,.2),x==0 and Color3.fromRGB(255,84,65) or Color3.fromRGB(78,220,124),10,.7)
    end

    -- Loading dock.
    part(folder,"LoadingDock",Vector3.new(120,4,30),Vector3.new(0,2,1015),Color3.fromRGB(70,70,69),Enum.Material.Concrete,true)
    for x=-45,45,30 do
        crate(folder,Vector3.new(x,6,1008),1.2)
        barrel(folder,Vector3.new(x+10,4.5,1006))
    end
end

local function buildCanyonPOI(folder)
    local z=760
    for i=-6,6 do
        local plank=part(folder,"SuspensionBridgePlank",Vector3.new(11,.7,5),Vector3.new(i*10,12-math.abs(i)*.4,z),Color3.fromRGB(102,72,47),Enum.Material.WoodPlanks,true)
        plank.Orientation=Vector3.new(0,0,i*.7)
    end
    for _,x in ipairs({-70,70}) do
        part(folder,"BridgeTower",Vector3.new(3,22,3),Vector3.new(x,11,z),Color3.fromRGB(78,57,41),Enum.Material.Wood,true)
        glow(folder,"BridgeLantern",Vector3.new(x,20,z),Vector3.new(1.8,2.2,1.8),Color3.fromRGB(255,156,72),22,1.5)
    end

    local camp=Vector3.new(-165,0,600)
    part(folder,"CampMat",Vector3.new(44,.5,34),camp+Vector3.new(0,.25,0),Color3.fromRGB(112,83,59),Enum.Material.Sandstone,true)
    for i=1,8 do crate(folder,camp+Vector3.new(math.random(-18,18),2.5,math.random(-12,12)),.65) end
    sign(folder,"BUILD CREW CAMP",camp+Vector3.new(0,7,-17),Vector3.new(22,6,.8),Color3.fromRGB(91,60,43))

    local cave=Vector3.new(205,0,930)
    for i=-3,3 do
        rock(folder,cave+Vector3.new(i*8,8+math.abs(i)*2,0),Vector3.new(11,18,16),Color3.fromRGB(117,78,57),true)
    end
    local dark=part(folder,"CaveDarkness",Vector3.new(38,20,2),cave+Vector3.new(0,9,-2),Color3.fromRGB(14,14,16),Enum.Material.SmoothPlastic,false)
    sign(folder,"OLD MINE",cave+Vector3.new(0,21,-3),Vector3.new(18,5,.7),Color3.fromRGB(76,52,42))
end

local function buildOceanPOI(folder)
    -- Fixed lighthouse island.
    local island=part(folder,"LighthouseIsland",Vector3.new(100,7,90),Vector3.new(195,7,930),Color3.fromRGB(74,116,68),Enum.Material.Grass,true)
    for y=0,2 do
        local tower=part(folder,"LighthouseTower",Vector3.new(22,16,22),Vector3.new(195,14+y*14,930),y%2==0 and Color3.fromRGB(205,205,194) or Color3.fromRGB(169,65,58),Enum.Material.Brick,true)
    end
    local beacon=glow(folder,"LighthouseBeacon",Vector3.new(195,48,930),Vector3.new(8,8,8),Color3.fromRGB(255,229,157),70,3)
    beacon.Shape=Enum.PartType.Ball
    sign(folder,"BACKUP LIGHT",Vector3.new(195,28,918),Vector3.new(18,5,.7),Color3.fromRGB(73,57,52))

    local hut=Vector3.new(-185,5,690)
    part(folder,"RescueIsland",Vector3.new(90,7,80),Vector3.new(-185,3,690),Color3.fromRGB(76,117,70),Enum.Material.Grass,true)
    local h=openRoom(folder,"POI_RescueHut",hut,Vector3.new(42,1,30),16,Color3.fromRGB(106,84,63),Enum.Material.WoodPlanks)
    sign(h,"RESCUE / SYNC",hut+Vector3.new(0,12,-15.5),Vector3.new(22,5,.7),Color3.fromRGB(68,55,47))
    crate(h,hut+Vector3.new(-10,2.5,5),.8)
    barrel(h,hut+Vector3.new(10,2.5,5),Color3.fromRGB(63,76,82))

    -- Broken boat silhouette.
    local boat=part(folder,"BrokenBoat",Vector3.new(42,5,16),Vector3.new(-65,4,880),Color3.fromRGB(82,62,48),Enum.Material.WoodPlanks,true)
    boat.Orientation=Vector3.new(8,22,-10)
end

local function buildChatPOI(folder)
    local terminal=Vector3.new(0,0,955)
    local m=openRoom(folder,"POI_ChatTerminal",terminal,Vector3.new(70,1,48),20,Color3.fromRGB(46,41,58),Enum.Material.Slate)
    sign(m,"CHAT ARCHIVE",terminal+Vector3.new(0,16,-24.5),Vector3.new(32,7,.8),Color3.fromRGB(54,42,72),Color3.fromRGB(219,196,255))
    for x=-22,22,11 do
        local screen=part(m,"ChatScreen",Vector3.new(9,6,.7),terminal+Vector3.new(x,8,18),Color3.fromRGB(20,20,26),Enum.Material.SmoothPlastic,false)
        local words={"joined","brb 5 min","...","left","typing"}
        labelSurface(screen,Enum.NormalId.Front,words[((x+22)/11)%#words+1],Color3.fromRGB(197,175,239))
    end
    glow(m,"ChatCeiling",terminal+Vector3.new(0,16,0),Vector3.new(30,.5,1),Color3.fromRGB(144,78,214),32,1.4)

    for i=0,7 do
        local z=560+i*46
        sign(folder,(i%2==0 and "[SERVER] " or "[GUEST] ")..(i%3==0 and "joined the game" or "message unavailable"),Vector3.new((i%2==0 and -125 or 125),9,z),Vector3.new(34,7,.7),Color3.fromRGB(49,42,62),Color3.fromRGB(208,190,235))
    end
end

local function buildForestPOI(folder)
    local cabin=Vector3.new(150,0,610)
    local m=openRoom(folder,"POI_ForestCabin",cabin,Vector3.new(46,1,36),18,Color3.fromRGB(75,57,43),Enum.Material.WoodPlanks)
    sign(m,"RANGER CABIN\n2015",cabin+Vector3.new(0,14,-18.5),Vector3.new(24,6,.7),Color3.fromRGB(54,44,39))
    desk(m,cabin+Vector3.new(0,0,5))
    crate(m,cabin+Vector3.new(-13,2.5,8),.7)
    glow(m,"CabinLamp",cabin+Vector3.new(0,13,0),Vector3.new(2,2,2),Color3.fromRGB(255,178,92),25,1.6).Shape=Enum.PartType.Ball

    -- Watchtower.
    local base=Vector3.new(-180,0,870)
    for _,dx in ipairs({-7,7}) do for _,dz in ipairs({-7,7}) do
        part(folder,"TowerLeg",Vector3.new(1.2,28,1.2),base+Vector3.new(dx,14,dz),Color3.fromRGB(78,58,43),Enum.Material.Wood,true)
    end end
    part(folder,"TowerDeck",Vector3.new(22,1,22),base+Vector3.new(0,28,0),Color3.fromRGB(83,62,45),Enum.Material.WoodPlanks,true)
    part(folder,"TowerRoof",Vector3.new(24,1,24),base+Vector3.new(0,38,0),Color3.fromRGB(43,43,45),Enum.Material.Slate,true)
    for _,side in ipairs({-1,1}) do
        part(folder,"TowerWall",Vector3.new(1,10,22),base+Vector3.new(side*10,33,0),Color3.fromRGB(71,55,44),Enum.Material.WoodPlanks,true)
    end
    glow(folder,"TowerBeacon",base+Vector3.new(0,35,0),Vector3.new(2,2,2),Color3.fromRGB(255,205,121),45,2).Shape=Enum.PartType.Ball

    -- Creek gives the forest a landmark without turning it into a flat tree field.
    local water=part(folder,"ForestCreek",Vector3.new(42,.5,330),Vector3.new(-40,.2,760),Color3.fromRGB(48,88,94),Enum.Material.Glass,false)
    water.Transparency=.25
    water.Orientation=Vector3.new(0,-10,0)
    for i=1,28 do rock(folder,Vector3.new(-55+math.random(-10,10),2,610+i*11),Vector3.new(math.random(3,7),math.random(2,4),math.random(3,7)),Color3.fromRGB(63,70,65),false) end
end

local function buildArchivePOI(folder)
    local scan=Vector3.new(0,0,610)
    local m=openRoom(folder,"POI_ScanRoom",scan,Vector3.new(76,1,48),19,Color3.fromRGB(47,51,58),Enum.Material.Metal)
    sign(m,"ARCHIVE SCAN\nACCESS 2015",scan+Vector3.new(0,15,-24.5),Vector3.new(30,7,.8),Color3.fromRGB(38,45,57),Color3.fromRGB(177,211,255))
    for x=-24,24,12 do
        glow(m,"ScannerColumn",scan+Vector3.new(x,8,9),Vector3.new(1,14,1),x%24==0 and Color3.fromRGB(70,146,255) or Color3.fromRGB(228,68,79),20,.8)
    end
    desk(m,scan+Vector3.new(0,0,-5))

    local server=Vector3.new(0,0,925)
    local s=openRoom(folder,"POI_ServerCore",server,Vector3.new(96,1,58),22,Color3.fromRGB(42,45,51),Enum.Material.Metal)
    sign(s,"MASTER BACKUP",server+Vector3.new(0,17,-29.5),Vector3.new(34,7,.8),Color3.fromRGB(37,43,53),Color3.fromRGB(211,227,255))
    for row=-2,2 do
        for col=-2,2 do
            local rackPos=server+Vector3.new(row*17,0,8+col*8)
            part(s,"CoreRack",Vector3.new(10,15,5),rackPos+Vector3.new(0,7.5,0),Color3.fromRGB(34,37,43),Enum.Material.Metal,true)
            glow(s,"RackLED",rackPos+Vector3.new(0,9,-2.6),Vector3.new(6,.4,.1),(row+col)%2==0 and Color3.fromRGB(62,151,255) or Color3.fromRGB(255,75,94),9,.35)
        end
    end
end

local function buildFinalePOI(folder)
    -- Deliberate fragments of recognizable earlier locations.
    local school=openRoom(folder,"Finale_SchoolFragment",Vector3.new(-175,0,650),Vector3.new(54,1,34),16,Color3.fromRGB(98,83,92),Enum.Material.Brick)
    lockerRow(school,Vector3.new(-175,0,662),5)
    sign(school,"SCHOOL // NULL",Vector3.new(-175,12,632.5),Vector3.new(24,5,.7),Color3.fromRGB(64,42,72))

    local cabin=openRoom(folder,"Finale_CabinFragment",Vector3.new(170,0,820),Vector3.new(38,1,30),15,Color3.fromRGB(70,49,65),Enum.Material.WoodPlanks)
    glow(cabin,"WrongCabinLight",Vector3.new(170,11,820),Vector3.new(2,2,2),Color3.fromRGB(185,72,255),24,1.5).Shape=Enum.PartType.Ball

    local bunker=Vector3.new(0,0,995)
    local b=openRoom(folder,"POI_AdminBunker",bunker,Vector3.new(88,1,54),22,Color3.fromRGB(46,42,53),Enum.Material.Metal)
    sign(b,"ADMIN // LAST SAVE",bunker+Vector3.new(0,17,-27.5),Vector3.new(36,7,.8),Color3.fromRGB(53,38,65),Color3.fromRGB(235,207,255))
    desk(b,bunker+Vector3.new(0,0,7))
    local screen=part(b,"AdminScreen",Vector3.new(18,10,.8),bunker+Vector3.new(0,10,23),Color3.fromRGB(18,17,22),Enum.Material.SmoothPlastic,false)
    labelSurface(screen,Enum.NormalId.Front,"rollback_2015.bat\nREADY_",Color3.fromRGB(206,164,255))
    for x=-30,30,15 do glow(b,"BunkerStrip",bunker+Vector3.new(x,17,0),Vector3.new(8,.5,1),Color3.fromRGB(151,68,220),15,.7) end
end

local function backdrop(folder,map,rng)
    -- Cheap silhouettes outside the playable shell make borders feel like part of a larger world.
    local centerZ=760
    if map=="City" then
        for i=1,24 do
            local side=i%2==0 and -1 or 1
            local x=side*rng:NextInteger(325,390)
            local z=rng:NextInteger(470,1050)
            local h=rng:NextInteger(45,110)
            local b=part(folder,"BackdropBuilding",Vector3.new(rng:NextInteger(38,72),h,rng:NextInteger(36,64)),Vector3.new(x,h/2-2,z),Color3.fromRGB(44,47,54),Enum.Material.Concrete,false)
            b.CastShadow=false
        end
    elseif map=="Canyon" then
        for i=1,28 do
            local side=i%2==0 and -1 or 1
            local x=side*rng:NextInteger(325,390)
            local z=rng:NextInteger(470,1050)
            rock(folder,Vector3.new(x,35,z),Vector3.new(rng:NextInteger(30,65),rng:NextInteger(50,95),rng:NextInteger(30,65)),Color3.fromRGB(105,72,56),false)
        end
    elseif map=="Forest" or map=="Suburb" then
        for i=1,36 do
            local side=i%2==0 and -1 or 1
            tree(folder,Vector3.new(side*rng:NextInteger(320,365),0,rng:NextInteger(465,1055)),rng:NextNumber(.9,1.4),true)
        end
    elseif map=="Ocean" then
        for i=1,14 do
            rock(folder,Vector3.new(rng:NextInteger(-360,360),3,rng:NextInteger(445,1075)),Vector3.new(rng:NextInteger(18,35),rng:NextInteger(8,16),rng:NextInteger(18,35)),Color3.fromRGB(50,64,72),false)
        end
    else
        for i=1,18 do
            local x=(i%2==0 and -1 or 1)*rng:NextInteger(322,370)
            local z=rng:NextInteger(470,1050)
            local p=part(folder,"BackdropShard",Vector3.new(rng:NextInteger(10,28),rng:NextInteger(20,55),rng:NextInteger(4,12)),Vector3.new(x,15,z),Color3.fromRGB(48,43,58),Enum.Material.Slate,false)
            p.Orientation=Vector3.new(rng:NextInteger(-8,8),rng:NextInteger(0,180),rng:NextInteger(-8,8))
        end
    end
end

function LevelDesign.DecorateLobby(folder)
    local d=Instance.new("Folder")
    d.Name="LevelDesign_Lobby"
    d.Parent=folder

    -- More visual density around the central hub, but keep walking lanes clear.
    for _,x in ipairs({-68,-52,-36,36,52,68}) do
        bush(d,Vector3.new(x,0,72),.7)
        bush(d,Vector3.new(x,0,-72),.75)
    end
    for _,z in ipairs({-52,-30,30,52}) do
        rock(d,Vector3.new(-78,2,z),Vector3.new(6,4,6),Color3.fromRGB(63,63,65),false)
        rock(d,Vector3.new(78,2,z),Vector3.new(6,4,6),Color3.fromRGB(63,63,65),false)
    end

    -- Market clutter.
    for i=1,5 do
        crate(d,Vector3.new(45+i*5,2.5,-10+((i%2)*6)),.65)
    end
    for i=1,4 do
        barrel(d,Vector3.new(-46-i*5,2.5,-9+((i%2)*6)),i%2==0 and Color3.fromRGB(69,76,78) or Color3.fromRGB(89,65,51))
    end

    -- Warm overhead bulbs around the safe camp.
    stringLights(d,Vector3.new(-40,14,-18),Vector3.new(40,14,-18),14,Color3.fromRGB(255,191,108))
    stringLights(d,Vector3.new(-40,14,34),Vector3.new(40,14,34),14,Color3.fromRGB(255,191,108))
    stringLights(d,Vector3.new(-38,14,-18),Vector3.new(-38,14,34),10,Color3.fromRGB(255,191,108))
    stringLights(d,Vector3.new(38,14,-18),Vector3.new(38,14,34),10,Color3.fromRGB(255,191,108))

    bench(d,Vector3.new(-28,0,48),0)
    bench(d,Vector3.new(28,0,48),180)
    streetLamp(d,Vector3.new(-58,0,48),true)
    streetLamp(d,Vector3.new(58,0,48),true)

    sign(d,"SAFE SERVER HUB\nBUILD 2015.08",Vector3.new(-55,6,35),Vector3.new(20,6,.8),Color3.fromRGB(55,48,44),Color3.fromRGB(237,209,164))
    sign(d,"NEXT WORLD UPDATE\nEVERY 03:00",Vector3.new(55,6,35),Vector3.new(20,6,.8),Color3.fromRGB(49,53,59),Color3.fromRGB(188,211,235))

    -- Natural border fillers to hide the square silhouette.
    for i=1,24 do
        local side=i%4
        local x,z
        if side==0 then x=math.random(-78,78); z=-80
        elseif side==1 then x=math.random(-78,78); z=80
        elseif side==2 then x=-80; z=math.random(-75,75)
        else x=80; z=math.random(-75,75) end
        if i%3==0 then tree(d,Vector3.new(x,0,z),math.random(70,95)/100,true)
        elseif i%3==1 then bush(d,Vector3.new(x,0,z),math.random(55,85)/100)
        else rock(d,Vector3.new(x,2,z),Vector3.new(5,4,6),Color3.fromRGB(65,64,65),false) end
    end
end

function LevelDesign.DecorateChapter(folder,chapter,rng)
    local d=Instance.new("Folder")
    d.Name="LevelDesign_POI"
    d.Parent=folder

    backdrop(d,chapter.map,rng)

    if chapter.map=="Suburb" then
        buildSchool(d)
        buildBusStop(d)
        buildSuburbShop(d)
        playground(d,Vector3.new(-135,0,815))
        fence(d,Vector3.new(-180,0,760),Vector3.new(-90,0,760),5)
        fence(d,Vector3.new(90,0,760),Vector3.new(180,0,760),5)
    elseif chapter.map=="ObbyPark" then
        buildObbyPOI(d)
    elseif chapter.map=="City" then
        buildCityPOI(d)
    elseif chapter.map=="Warehouse" then
        buildWarehousePOI(d)
    elseif chapter.map=="Canyon" then
        buildCanyonPOI(d)
    elseif chapter.map=="Ocean" then
        buildOceanPOI(d)
    elseif chapter.map=="Chat" then
        buildChatPOI(d)
    elseif chapter.map=="Forest" then
        buildForestPOI(d)
    elseif chapter.map=="Archive" then
        buildArchivePOI(d)
    else
        buildFinalePOI(d)
    end
end

return LevelDesign
