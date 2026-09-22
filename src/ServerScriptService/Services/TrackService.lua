local RS=game:GetService("ReplicatedStorage")
local Lighting=game:GetService("Lighting")
local Config=require(RS.Shared.Config)
local Courses=require(RS.Shared.Courses)
local A=require(script.Parent.Art)
local Track={}; Track.__index=Track
function Track.new() return setmetatable({worlds={},hazards={}},Track) end
function Track:Build()
    Lighting.ClockTime=15.8; Lighting.Brightness=2.5; Lighting.GlobalShadows=true
    Lighting.Ambient=Color3.fromRGB(130,141,167); Lighting.OutdoorAmbient=Color3.fromRGB(148,157,175)
    local atm=Instance.new("Atmosphere"); atm.Density=.24; atm.Offset=.15; atm.Haze=1.3
    atm.Color=Color3.fromRGB(210,229,245); atm.Decay=Color3.fromRGB(155,171,208); atm.Parent=Lighting
    local bloom=Instance.new("BloomEffect"); bloom.Intensity=.18; bloom.Size=24; bloom.Threshold=1.5; bloom.Parent=Lighting
    local grade=Instance.new("ColorCorrectionEffect"); grade.Saturation=.08; grade.Contrast=.06; grade.Parent=Lighting
    self.root=A.model(workspace,"CityRushWorlds")
    for index,world in ipairs(Config.WORLDS) do self:World(index,world) end
end
function Track:World(index,world)
    local m=A.model(self.root,world.id)
    local route={checkpoints={},segments={},root=m}; self.worlds[index]=route
    local cf=CFrame.new(world.origin)
    local function island(frame,label)
        A.part(m,"CheckpointIsland",Vector3.new(26,2,24),frame*CFrame.new(0,-1,0),A.white,Enum.Material.Concrete,true)
        A.part(m,"CheckpointPaint",Vector3.new(23,.08,6),frame*CFrame.new(0,.05,0),world.color,Enum.Material.SmoothPlastic,false)
        for _,x in ipairs({-12,12}) do
            A.part(m,"GatePillar",Vector3.new(.8,9,.8),frame*CFrame.new(x,4.5,0),A.ink,Enum.Material.Metal,false)
        end
        A.part(m,"GateLight",Vector3.new(25,.4,.6),frame*CFrame.new(0,9,0),world.color,Enum.Material.Neon,false)
        A.sign(m,frame*CFrame.new(0,7,.4),label,14,2.2,world.color)
    end
    island(cf,world.name.." / START"); route.checkpoints[1]=cf
    for stage,spec in ipairs(Courses[world.id]) do
        local section=A.model(m,string.format("%02d_%s",stage,spec.kind))
        local start=cf*CFrame.new(0,0,-12)
        local count=math.ceil(spec.length/8)
        local angle=math.rad(spec.turn)
        local pieces={}
        local last=start.Position
        for j=1,count do
            local t=j/count
            local heading=angle*(j-.5)/count
            local step=Vector3.new(-math.sin(heading)*spec.length/count,spec.rise/count,-math.cos(heading)*spec.length/count)
            local nextPoint=last+start:VectorToWorldSpace(step)
            local middle=(last+nextPoint)/2
            local tileCF=CFrame.lookAt(middle,nextPoint)
            -- Two readable gaps, each one 8-stud tile. All sections include run-up/landing.
            local gap=spec.kind=="gaps" and (j==math.floor(count*.38) or j==math.floor(count*.7))
            if not gap then
                local deck=A.part(section,"RideSurface",Vector3.new(spec.width,1.2,(nextPoint-last).Magnitude+.18),tileCF*CFrame.new(0,-.6,0),
                    index==3 and Color3.fromRGB(57,63,86) or Color3.fromRGB(228,227,215),Enum.Material.Concrete,true)
                table.insert(pieces,deck)
                for _,side in ipairs({-1,1}) do
                    A.part(section,"EdgeInlay",Vector3.new(.22,.07,(nextPoint-last).Magnitude),tileCF*CFrame.new(side*(spec.width/2-.3),.04,0),world.color,Enum.Material.Neon,false)
                    if spec.kind=="road" or spec.kind=="curve" then
                        A.part(section,"GuardRail",Vector3.new(.35,1,(nextPoint-last).Magnitude+.2),tileCF*CFrame.new(side*spec.width/2,1.1,0),A.white,Enum.Material.Metal,true)
                    end
                end
            else
                A.part(section,"JumpCue",Vector3.new(spec.width,.1,1.2),CFrame.new(last)*start.Rotation,Color3.fromRGB(255,185,90),Enum.Material.Neon,false)
            end
            if spec.kind=="slalom" and j%4==2 and j<count-1 then
                local side=(math.floor(j/4)%2==0) and -1 or 1
                A.part(section,"SlalomPlanter",Vector3.new(spec.width*.48,3.5,2),tileCF*CFrame.new(side*spec.width*.26,1.75,0),world.color,Enum.Material.Concrete,true)
            end
            if spec.kind=="sweeper" and j==math.floor(count/2) then
                local base=CFrame.new(middle+Vector3.new(0,1.8,0))
                local bar=A.part(section,"RotatingHazard",Vector3.new(spec.width-2,.8,1.2),base,Color3.fromRGB(255,103,122),Enum.Material.Neon,false)
                table.insert(self.hazards,{part=bar,base=base,speed=.8+index*.15,phase=stage})
            end
            last=nextPoint
        end
        local endRot=start.Rotation*CFrame.Angles(0,angle,0)
        cf=CFrame.new(last)*endRot*CFrame.new(0,0,-12)
        island(cf,stage==#Courses[world.id] and "FINISH" or string.format("%02d / %s",stage,spec.name))
        table.insert(route.checkpoints,cf)
        route.segments[stage]={name=spec.name,start=start,finish=cf}
        -- Deliberate skyline rhythm, leaving the ride silhouette unobstructed.
        local side=(stage%2==0) and 1 or -1
        local scenery=start*CFrame.new(side*52,-35,-spec.length*.45)
        if index~=2 then
            A.building(section,scenery,28,30+(stage%3)*8,28,stage%2==0 and Color3.fromRGB(240,180,151) or Color3.fromRGB(160,197,212))
        else
            A.cylinder(section,"GardenIsland",Vector3.new(5,42,42),scenery*CFrame.Angles(0,0,math.pi/2),A.white,Enum.Material.Concrete,true)
            for n=-1,1 do A.tree(section,scenery*CFrame.new(n*11,3,0),Color3.fromRGB(133,182,158),1.1) end
        end
        A.tree(section,cf*CFrame.new(18,0,0),index==2 and Color3.fromRGB(213,161,206) or Color3.fromRGB(100,170,144),.7)
        if stage%3==0 then A.lamp(section,cf*CFrame.new(-17,0,0),world.color) end
    end
    route.killY=world.origin.Y-28
end
function Track:Update(now)
    for _,h in ipairs(self.hazards) do h.part.CFrame=h.base*CFrame.Angles(0,now*h.speed+h.phase,0) end
end
function Track:HazardAt(position)
    for _,h in ipairs(self.hazards) do
        if (h.part.Position-position).Magnitude<16 then
            local p=h.part.CFrame:PointToObjectSpace(position)
            local half=h.part.Size/2+Vector3.new(1.1,1.5,1.1)
            if math.abs(p.X)<half.X and math.abs(p.Y)<half.Y and math.abs(p.Z)<half.Z then return true end
        end
    end
    return false
end
return Track
