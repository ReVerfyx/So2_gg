local CollectionService=game:GetService("CollectionService")
local Lighting=game:GetService("Lighting")
local ReplicatedStorage=game:GetService("ReplicatedStorage")

local Config=require(ReplicatedStorage.Shared.Config)

local TrackService={}
TrackService.__index=TrackService

local BUILDING_COLORS={
    Color3.fromRGB(255,126,112),
    Color3.fromRGB(99,183,255),
    Color3.fromRGB(255,203,87),
    Color3.fromRGB(157,113,235),
    Color3.fromRGB(87,205,153),
    Color3.fromRGB(244,139,206),
}

local function part(parent,name,size,pos,color,material,collide)
    local p=Instance.new("Part")
    p.Name=name
    p.Anchored=true
    p.Size=size
    p.Position=pos
    p.Color=color
    p.Material=material or Enum.Material.SmoothPlastic
    p.TopSurface=Enum.SurfaceType.Smooth
    p.BottomSurface=Enum.SurfaceType.Smooth
    p.CanCollide=collide~=false
    p.Parent=parent
    return p
end

local function glow(parent,name,size,pos,color)
    local p=part(parent,name,size,pos,color,Enum.Material.Neon,false)
    p.CastShadow=false
    return p
end

local function billboard(parent,text,pos,color)
    local board=part(parent,"Billboard",Vector3.new(18,9,1),pos,Color3.fromRGB(28,31,44),Enum.Material.SmoothPlastic,true)
    local gui=Instance.new("SurfaceGui")
    gui.Face=Enum.NormalId.Front
    gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud=22
    gui.Parent=board
    local label=Instance.new("TextLabel")
    label.Size=UDim2.fromScale(1,1)
    label.BackgroundTransparency=1
    label.Text=text
    label.TextScaled=true
    label.TextWrapped=true
    label.Font=Enum.Font.GothamBlack
    label.TextColor3=color
    label.Parent=gui
end

local function tree(parent,x,z)
    part(parent,"TreeTrunk",Vector3.new(2,8,2),Vector3.new(x,4,z),Color3.fromRGB(111,76,45),Enum.Material.Wood,true)
    local crown=part(parent,"TreeCrown",Vector3.new(8,8,8),Vector3.new(x,11,z),Color3.fromRGB(69,174,92),Enum.Material.Grass,false)
    crown.Shape=Enum.PartType.Ball
end

local function lamp(parent,x,z)
    part(parent,"LampPost",Vector3.new(.5,10,.5),Vector3.new(x,5,z),Color3.fromRGB(52,57,69),Enum.Material.Metal,true)
    local bulb=glow(parent,"Lamp",Vector3.new(1.5,1.5,1.5),Vector3.new(x,10.5,z),Color3.fromRGB(255,211,120))
    bulb.Shape=Enum.PartType.Ball
    local light=Instance.new("PointLight")
    light.Color=bulb.Color
    light.Range=24
    light.Brightness=1.5
    light.Parent=bulb
end

function TrackService.new()
    return setmetatable({root=nil,nextIndex=0,endZ=0},TrackService)
end

function TrackService:SetupLighting()
    Lighting.ClockTime=17.4
    Lighting.Brightness=2.6
    Lighting.GlobalShadows=true
    Lighting.ShadowSoftness=.25
    Lighting.Ambient=Color3.fromRGB(138,137,154)
    Lighting.OutdoorAmbient=Color3.fromRGB(151,145,153)
    Lighting.FogColor=Color3.fromRGB(197,181,222)
    Lighting.FogStart=350
    Lighting.FogEnd=1800

    local atmosphere=Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
    atmosphere.Density=.13
    atmosphere.Haze=.45
    atmosphere.Glare=.12
    atmosphere.Color=Color3.fromRGB(226,211,244)
    atmosphere.Decay=Color3.fromRGB(164,125,169)
    atmosphere.Parent=Lighting
end

function TrackService:Build()
    local old=workspace:FindFirstChild("RunnerWorld")
    if old then old:Destroy() end
    self:SetupLighting()

    self.root=Instance.new("Folder")
    self.root.Name="RunnerWorld"
    self.root.Parent=workspace
    self.nextIndex=0
    self.endZ=0

    part(self.root,"RunnerStart",Vector3.new(28,1,28),Vector3.new(0,.5,Config.START_Z),Color3.fromRGB(57,62,75),Enum.Material.Asphalt,true)
    billboard(self.root,"CITY RUSH",Vector3.new(-22,8,34),Color3.fromRGB(255,197,74))
    billboard(self.root,"SWIPE • JUMP • RIDE",Vector3.new(22,8,34),Color3.fromRGB(99,208,255))

    self:GenerateMore(Config.INITIAL_SEGMENTS)
end

function TrackService:GetEndZ()
    return self.endZ
end

function TrackService:GenerateMore(count)
    for _=1,count do
        self:GenerateSegment(self.nextIndex)
        self.nextIndex+=1
    end
end

function TrackService:GenerateSegment(index)
    local rng=Random.new(index*9173+41)
    local len=Config.SEGMENT_LENGTH
    local z=index*len+len/2
    local folder=Instance.new("Folder")
    folder.Name=string.format("Segment_%04d",index)
    folder.Parent=self.root

    part(folder,"Road",Vector3.new(Config.TRACK_WIDTH,1,len),Vector3.new(0,0,z),Color3.fromRGB(54,59,71),Enum.Material.Asphalt,true)
    part(folder,"WalkL",Vector3.new(7,1.3,len),Vector3.new(-18.5,.65,z),Color3.fromRGB(197,195,190),Enum.Material.Concrete,true)
    part(folder,"WalkR",Vector3.new(7,1.3,len),Vector3.new(18.5,.65,z),Color3.fromRGB(197,195,190),Enum.Material.Concrete,true)

    for _,x in ipairs({-4,4}) do
        for dz=-25,25,12 do
            glow(folder,"LaneStripe",Vector3.new(.35,.05,6),Vector3.new(x,.55,z+dz),Color3.fromRGB(244,236,213))
        end
    end

    for _,side in ipairs({-1,1}) do
        local baseX=side*rng:NextInteger(31,38)
        local height=rng:NextInteger(22,52)
        local width=rng:NextInteger(20,34)
        local color=BUILDING_COLORS[rng:NextInteger(1,#BUILDING_COLORS)]
        part(folder,"Building",Vector3.new(width,height,44),Vector3.new(baseX,height/2,z),color,Enum.Material.SmoothPlastic,true)

        for floorY=7,height-5,9 do
            local wx=baseX-side*(width/2+.03)
            local win=glow(folder,"WindowGlow",Vector3.new(.12,4,12),Vector3.new(wx,floorY,z),Color3.fromRGB(255,235,160))
            win.Orientation=Vector3.new(0,side>0 and 90 or -90,0)
        end

        if index%2==0 then lamp(folder,side*23,z-18) end
        if index%3==0 then tree(folder,side*23,z+15) end
    end

    if index>1 then
        local pattern=rng:NextInteger(1,7)
        local lanes=Config.LANES

        local function barrier(laneIndex,kind)
            local x=lanes[laneIndex]
            if kind=="slide" then
                local gate=part(folder,"SlideGate",Vector3.new(6,3,2),Vector3.new(x,6,z+7),Color3.fromRGB(255,104,139),Enum.Material.Neon,true)
                gate:SetAttribute("ObstacleType","Slide")
                CollectionService:AddTag(gate,"RunnerObstacle")
            elseif kind=="bus" then
                local bus=part(folder,"Bus",Vector3.new(6,7,18),Vector3.new(x,3.5,z+5),Color3.fromRGB(63,149,255),Enum.Material.SmoothPlastic,true)
                bus:SetAttribute("ObstacleType","Solid")
                CollectionService:AddTag(bus,"RunnerObstacle")
                glow(folder,"BusWindow",Vector3.new(4.8,2,.2),Vector3.new(x,5.2,z-4.1),Color3.fromRGB(170,228,255))
            else
                local bar=part(folder,"Barrier",Vector3.new(6,3,2),Vector3.new(x,1.5,z+6),Color3.fromRGB(255,177,68),Enum.Material.Metal,true)
                bar:SetAttribute("ObstacleType","Jump")
                CollectionService:AddTag(bar,"RunnerObstacle")
            end
        end

        if pattern==1 then
            barrier(rng:NextInteger(1,3),"jump")
        elseif pattern==2 then
            local open=rng:NextInteger(1,3)
            for lane=1,3 do if lane~=open then barrier(lane,"jump") end end
        elseif pattern==3 then
            barrier(rng:NextInteger(1,3),"slide")
        elseif pattern==4 then
            barrier(rng:NextInteger(1,3),"bus")
        elseif pattern==5 then
            local open=rng:NextInteger(1,3)
            for lane=1,3 do if lane~=open then barrier(lane,lane%2==0 and "slide" or "jump") end end
        end

        local coinLane=rng:NextInteger(1,3)
        for c=0,6 do
            local coin=glow(folder,"Coin",Vector3.new(1.3,1.3,.45),Vector3.new(lanes[coinLane],2.2,z-22+c*6),Color3.fromRGB(255,218,74))
            coin.Shape=Enum.PartType.Cylinder
            coin.Orientation=Vector3.new(0,90,0)
            coin:SetAttribute("CoinValue",Config.COIN_VALUE)
            CollectionService:AddTag(coin,"RunnerCoin")
        end
    end

    if index%6==0 and index>0 then
        billboard(folder,index%12==0 and "RIDE FASTER" or "CITY RUSH",Vector3.new(-27,11,z),index%12==0 and Color3.fromRGB(112,255,189) or Color3.fromRGB(255,132,209))
    end

    self.endZ=(index+1)*len
end

return TrackService
