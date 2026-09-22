local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)

local BikeFactory = {}

local function makePart(parent,name,size,cframe,color,material,anchored)
    local p=Instance.new("Part")
    p.Name=name
    p.Size=size
    p.CFrame=cframe
    p.Color=color
    p.Material=material or Enum.Material.Metal
    p.Anchored=anchored
    p.CanCollide=false
    p.CanTouch=false
    p.Massless=not anchored
    p.TopSurface=Enum.SurfaceType.Smooth
    p.BottomSurface=Enum.SurfaceType.Smooth
    p.Parent=parent
    return p
end

local function tube(parent,name,base,a,b,thickness,color,material,anchored)
    local wa=base:PointToWorldSpace(a)
    local wb=base:PointToWorldSpace(b)
    local mid=(wa+wb)/2
    local len=(wb-wa).Magnitude
    local cf=CFrame.lookAt(mid,wb)
    return makePart(parent,name,Vector3.new(thickness,thickness,len),cf,color,material,anchored)
end

local function wheel(parent,name,base,z,diameter,frameColor,accent,anchored)
    local tire=makePart(parent,name.."Tire",Vector3.new(.52,diameter,diameter),base*CFrame.new(0,0,z),Color3.fromRGB(29,31,36),Enum.Material.SmoothPlastic,anchored)
    tire.Shape=Enum.PartType.Cylinder
    local rim=makePart(parent,name.."Rim",Vector3.new(.16,diameter*.76,diameter*.76),base*CFrame.new(0,0,z),frameColor,Enum.Material.Metal,anchored)
    rim.Shape=Enum.PartType.Cylinder
    local hub=makePart(parent,name.."Hub",Vector3.new(.78,.48,.48),base*CFrame.new(0,0,z),accent,Enum.Material.Neon,anchored)
    hub.Shape=Enum.PartType.Cylinder
end

local function weldAll(model,root)
    for _,obj in ipairs(model:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Anchored=false
            obj.CanCollide=false
            obj.CanTouch=false
            obj.Massless=true
            local w=Instance.new("WeldConstraint")
            w.Part0=root
            w.Part1=obj
            w.Parent=obj
        end
    end
end

function BikeFactory.Build(parent,bikeName,level,base,anchored)
    local info=Config.BIKES[bikeName] or Config.BIKES.BMX
    level=math.clamp(level or 1,1,Config.BIKE_MAX_LEVEL or 10)
    anchored=anchored~=false

    local model=Instance.new("Model")
    model.Name="Bike_"..bikeName
    model:SetAttribute("BikeName",bikeName)
    model:SetAttribute("BikeLevel",level)
    model.Parent=parent

    local frame=info.color
    local accent=info.accent or info.color:Lerp(Color3.new(1,1,1),.25)
    local tireD=info.wheelSize or 3.1
    local rearZ=-2.45
    local frontZ=2.45

    wheel(model,"Rear",base,rearZ,tireD,frame,accent,anchored)
    wheel(model,"Front",base,frontZ,tireD,frame,accent,anchored)

    local rear=Vector3.new(0,0,rearZ)
    local crank=Vector3.new(0,.25,-.45)
    local seatJoint=Vector3.new(0,1.55,-1.15)
    local headLow=Vector3.new(0,.65,1.45)
    local headHigh=Vector3.new(0,1.65,1.55)
    local front=Vector3.new(0,0,frontZ)

    tube(model,"ChainStay",base,rear,crank,.30,frame,Enum.Material.Metal,anchored)
    tube(model,"SeatStay",base,rear,seatJoint,.28,frame,Enum.Material.Metal,anchored)
    tube(model,"SeatTube",base,crank,seatJoint,.34,frame,Enum.Material.Metal,anchored)
    tube(model,"DownTube",base,crank,headLow,.38,frame,Enum.Material.Metal,anchored)
    tube(model,"TopTube",base,seatJoint,headHigh,.34,frame,Enum.Material.Metal,anchored)
    tube(model,"HeadTube",base,headLow,headHigh,.38,accent,Enum.Material.Metal,anchored)
    tube(model,"ForkA",base,headLow,front,.24,frame,Enum.Material.Metal,anchored)
    tube(model,"ForkB",base,headHigh,front,.20,frame,Enum.Material.Metal,anchored)

    makePart(model,"Seat",Vector3.new(1.5,.28,.85),base*CFrame.new(0,1.9,-1.3),Color3.fromRGB(43,44,49),Enum.Material.SmoothPlastic,anchored)
    tube(model,"Stem",base,Vector3.new(0,1.65,1.55),Vector3.new(0,2.05,1.8),.22,accent,Enum.Material.Metal,anchored)
    tube(model,"Handlebar",base,Vector3.new(-1.2,2.08,1.8),Vector3.new(1.2,2.08,1.8),.22,accent,Enum.Material.Metal,anchored)

    local crankHub=makePart(model,"CrankHub",Vector3.new(.65,.65,.65),base*CFrame.new(0,.25,-.45),accent,Enum.Material.Metal,anchored)
    crankHub.Shape=Enum.PartType.Ball
    tube(model,"LeftPedalArm",base,Vector3.new(-.15,.25,-.45),Vector3.new(-.9,.05,-.45),.16,Color3.fromRGB(65,67,72),Enum.Material.Metal,anchored)
    tube(model,"RightPedalArm",base,Vector3.new(.15,.25,-.45),Vector3.new(.9,.45,-.45),.16,Color3.fromRGB(65,67,72),Enum.Material.Metal,anchored)
    makePart(model,"PedalL",Vector3.new(.6,.16,.4),base*CFrame.new(-1,.04,-.45),Color3.fromRGB(40,41,44),Enum.Material.Metal,anchored)
    makePart(model,"PedalR",Vector3.new(.6,.16,.4),base*CFrame.new(1,.46,-.45),Color3.fromRGB(40,41,44),Enum.Material.Metal,anchored)

    for _,z in ipairs({rearZ,frontZ}) do
        local disc=makePart(model,"BrakeDisc",Vector3.new(.08,tireD*.42,tireD*.42),base*CFrame.new(.30,0,z),Color3.fromRGB(183,188,196),Enum.Material.Metal,anchored)
        disc.Shape=Enum.PartType.Cylinder
    end

    if level>=4 then
        tube(model,"LevelAccent",base,Vector3.new(.25,.35,-.55),Vector3.new(.25,1.45,1.35),.12,accent,Enum.Material.Neon,anchored)
    end
    if level>=7 then
        local glow=makePart(model,"RearGlow",Vector3.new(.13,tireD*.9,tireD*.9),base*CFrame.new(.34,0,rearZ),accent,Enum.Material.Neon,anchored)
        glow.Shape=Enum.PartType.Cylinder
        glow.Transparency=.28
    end
    if level>=10 then
        local max=makePart(model,"MaxLevelGlow",Vector3.new(.13,tireD*.92,tireD*.92),base*CFrame.new(.34,0,frontZ),Color3.fromRGB(255,215,83),Enum.Material.Neon,anchored)
        max.Shape=Enum.PartType.Cylinder
        max.Transparency=.2
    end

    return model
end

function BikeFactory.BuildDisplay(parent,bikeName,level,cframe)
    return BikeFactory.Build(parent,bikeName,level,cframe,true)
end

function BikeFactory.Attach(character,bikeName,level)
    local root=character and character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local old=character:FindFirstChild("RunnerBike")
    if old then old:Destroy() end
    local base=root.CFrame*CFrame.new(0,-2.25,-.15)
    local model=BikeFactory.Build(character,bikeName,level,base,false)
    model.Name="RunnerBike"
    weldAll(model,root)
    return model
end

return BikeFactory
