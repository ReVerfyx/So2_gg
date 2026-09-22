local Config=require(game:GetService("ReplicatedStorage").Shared.Config)
local A=require(script.Parent.Art)
local Bike={}
local function weld(part,root)
    part.Anchored=false; part.CanCollide=false; part.CanTouch=false; part.CanQuery=false; part.Massless=true
    local w=Instance.new("WeldConstraint"); w.Part0=root; w.Part1=part; w.Parent=part
end
function Bike.Build(parent,name,level,cf,ride)
    local info=Config.BIKES[name] or Config.BIKES.BMX
    local m=A.model(parent,ride and "RideBike" or "DisplayBike")
    local chassis=A.part(m,"Chassis",Vector3.new(1.5,1.8,4.8),cf*CFrame.new(0,-.45,0),A.ink,nil,ride)
    chassis.Transparency=1; m.PrimaryPart=chassis
    local tubeParent=m
    local function tube(n,a,b,d,c)
        return A.tube(tubeParent,n,cf:PointToWorldSpace(a),cf:PointToWorldSpace(b),d,c,Enum.Material.Metal)
    end
    local v=Vector3.new
    local rear=v(0,0,2.3); local front=v(0,0,-2.3); local crank=v(0,.1,.35)
    local saddle=v(0,1.55,.85); local head=v(0,1.5,-1.5)
    tube("TopTube",saddle,head,.28,info.color); tube("SeatTube",saddle,crank,.3,info.color)
    tube("DownTube",head,crank,.38,info.color)
    for _,x in ipairs({-.25,.25}) do
        tube("RearStay",rear+v(x,0,0),saddle,.17,info.color)
        tube("ChainStay",rear+v(x,0,0),crank,.17,info.color)
        tube("Fork",head+v(x,0,0),front+v(x,0,0),name=="Trail" and .28 or .17,info.accent)
    end
    tube("HandleStem",head,head+v(0,.8,-.1),.18,info.accent)
    tube("Handlebar",head+v(-1.2,.8,-.1),head+v(1.2,.8,-.1),.18,info.accent)
    for _,x in ipairs({-1,1}) do
        tube("Grip",head+v(x*.8,.8,-.1),head+v(x*1.3,.8,-.1),.27,A.ink)
        tube("Crank",crank+v(x*.4,0,0),crank+v(x*.4,x*.6,0),.14,A.ink)
        A.part(m,"Pedal",v(.7,.15,.5),cf*CFrame.new(x*.65,.1+x*.6,.35),A.ink,Enum.Material.Metal,false)
    end
    A.part(m,"Saddle",v(1,.3,1.6),cf*CFrame.new(0,1.8,.95),A.ink,nil,false)
    local wheels={}
    for _,z in ipairs({-2.3,2.3}) do
        local wheel=A.model(m,z<0 and "FrontWheel" or "RearWheel")
        local axle=A.part(wheel,"WheelPivot",v(.2,.2,.2),cf*CFrame.new(0,0,z),A.ink,nil,false)
        axle.Transparency=1; wheel.PrimaryPart=axle
        table.insert(wheels,wheel); tubeParent=wheel
        local radius=name=="Trail" and 1.5 or 1.35
        for i=1,24 do
            local a=(i-1)*math.pi/12; local b=i*math.pi/12
            tube("Tire",v(0,math.sin(a)*radius,z+math.cos(a)*radius),v(0,math.sin(b)*radius,z+math.cos(b)*radius),name=="Trail" and .35 or .24,Color3.fromRGB(28,34,43))
            tube("Rim",v(0,math.sin(a)*(radius-.17),z+math.cos(a)*(radius-.17)),v(0,math.sin(b)*(radius-.17),z+math.cos(b)*(radius-.17)),.07,info.accent)
        end
        for i=1,8 do
            local a=i*math.pi/4
            tube("Spoke",v(0,0,z),v(0,math.sin(a)*(radius-.2),z+math.cos(a)*(radius-.2)),.035,Color3.fromRGB(184,196,207))
        end
        tube("Axle",v(-.4,0,z),v(.4,0,z),.23,info.accent)
    end
    tubeParent=m
    if not ride then return m end
    for _,part in ipairs(m:GetChildren()) do if part:IsA("BasePart") and part~=chassis then weld(part,chassis) end end
    for _,wheel in ipairs(wheels) do
        local pivot=wheel.PrimaryPart
        for _,part in ipairs(wheel:GetChildren()) do if part:IsA("BasePart") and part~=pivot then weld(part,pivot) end end
        pivot.Anchored=false; pivot.Massless=true
        local motor=Instance.new("Motor6D"); motor.Name="WheelMotor"; motor.Part0=chassis; motor.Part1=pivot
        motor.C0=chassis.CFrame:ToObjectSpace(pivot.CFrame); motor.Parent=pivot
    end
    local seat=Instance.new("Seat"); seat.Name="RiderSeat"; seat.Size=v(1,.25,1)
    seat.CFrame=cf*CFrame.new(0,1.85,.7); seat.Transparency=1; seat.Parent=m; weld(seat,chassis)
    chassis.Anchored=false; chassis.CanCollide=true; chassis.CanQuery=true; chassis.Massless=false
    chassis.CustomPhysicalProperties=PhysicalProperties.new(2,.3,0,1,1)
    local attachment=Instance.new("Attachment"); attachment.Parent=chassis
    local align=Instance.new("AlignOrientation"); align.Attachment0=attachment; align.Mode=Enum.OrientationAlignmentMode.OneAttachment
    align.MaxTorque=90000; align.Responsiveness=18; align.CFrame=cf.Rotation; align.Parent=chassis
    chassis:SetNetworkOwner(nil)
    game:GetService("CollectionService"):AddTag(m,"CityBike")
    m:SetAttribute("BikeName",name); m:SetAttribute("Level",level)
    return m,seat,align
end
return Bike
