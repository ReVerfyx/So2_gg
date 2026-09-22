local RS=game:GetService("ReplicatedStorage")
local Config=require(RS.Shared.Config)
local A=require(script.Parent.Art)
local Bike=require(script.Parent.BikeFactory)
local Lobby={}; Lobby.__index=Lobby
function Lobby.new(data,remotes) return setmetatable({data=data,R=remotes,plots={},owners={}},Lobby) end
function Lobby:Build()
    self.root=A.model(workspace,"CityRushDistrict")
    A.part(self.root,"DistrictFoundation",Vector3.new(340,5,340),Vector3.new(0,-2.5,0),Color3.fromRGB(209,219,210),Enum.Material.Concrete,true)
    A.part(self.root,"CentralPromenade",Vector3.new(64,.12,270),Vector3.new(0,.07,0),A.white,Enum.Material.Concrete,true)
    A.part(self.root,"CrossPromenade",Vector3.new(290,.12,35),Vector3.new(0,.08,0),A.white,Enum.Material.Concrete,true)
    for _,x in ipairs({-33,33}) do
        A.part(self.root,"CycleLane",Vector3.new(8,.13,270),Vector3.new(x,.08,0),Color3.fromRGB(127,191,177),Enum.Material.SmoothPlastic,true)
        for z=-120,120,15 do A.part(self.root,"LaneMark",Vector3.new(.15,.04,5),Vector3.new(x,.17,z),A.white,nil,false) end
    end
    local spawn=Instance.new("SpawnLocation"); spawn.Name="DistrictSpawn"; spawn.Size=Vector3.new(10,.2,10)
    spawn.Position=Vector3.new(0,.15,36); spawn.Anchored=true; spawn.Transparency=1; spawn.CanCollide=false
    spawn.Neutral=true; spawn.Duration=0; spawn.Parent=self.root
    for i=1,Config.MAX_GARAGES do
        local side=i<=6 and -1 or 1; local row=i<=6 and i or i-6
        local position=Vector3.new(side*102,0,-117+(row-1)*47)
        local cf=CFrame.lookAt(position,Vector3.new(0,0,position.Z))
        self:Garage(i,cf)
    end
    -- A low pavilion anchors the view from spawn; portals sit in its open facade.
    A.building(self.root,CFrame.new(0,0,-150),95,24,30,Color3.fromRGB(242,192,159))
    A.sign(self.root,CFrame.new(0,20,-132)*CFrame.Angles(0,math.pi,0),"CITY RUSH",66,7,Color3.fromRGB(255,203,127))
    for i,w in ipairs(Config.WORLDS) do
        local cf=CFrame.new((i-2)*30,0,-110)*CFrame.Angles(0,math.pi,0)
        for _,x in ipairs({-10,10}) do A.part(self.root,"PortalColumn",Vector3.new(1.2,14,1.2),cf*CFrame.new(x,7,0),w.color,Enum.Material.Neon,false) end
        A.part(self.root,"PortalHeader",Vector3.new(21,1.2,1.2),cf*CFrame.new(0,14,0),w.color,Enum.Material.Neon,false)
        local pad=A.part(self.root,"WorldPortal",Vector3.new(20,.3,16),cf*CFrame.new(0,.2,0),w.color,nil,true)
        A.sign(self.root,cf*CFrame.new(0,10,0),w.name.."\n12 STAGES",18,5,w.color)
        A.prompt(pad,"Выбрать трассу",w.name,function(p) self.R.Open:FireClient(p,"Worlds") end)
    end
    local shop=A.model(self.root,"CycleAtelier")
    A.part(shop,"AtelierDeck",Vector3.new(86,.4,32),Vector3.new(0,.2,111),A.ink,Enum.Material.Concrete,true)
    A.sign(shop,CFrame.new(0,13,128),"THE CYCLE ATELIER",60,5,Color3.fromRGB(255,207,129))
    A.part(shop,"AtelierCanopy",Vector3.new(90,.5,36),Vector3.new(0,17,111),A.white,Enum.Material.Metal,true)
    for _,x in ipairs({-42,42}) do A.part(shop,"AtelierPillar",Vector3.new(.6,17,.6),Vector3.new(x,8.5,126),A.ink,Enum.Material.Metal,true) end
    for i,name in ipairs(Config.BIKE_ORDER) do
        local x=(i-3.5)*13
        local pad=A.cylinder(shop,"DisplayPlinth",Vector3.new(.6,10,10),CFrame.new(x,.7,111)*CFrame.Angles(0,0,math.pi/2),Color3.fromRGB(98,120,140),Enum.Material.Metal,true)
        Bike.Build(shop,name,1,CFrame.new(x,2.5,111)*CFrame.Angles(0,math.pi/2,0),false)
        A.prompt(pad,"Велосипеды",Config.BIKES[name].displayName,function(p) self.R.Open:FireClient(p,"Bikes") end)
    end
    for _,side in ipairs({-1,1}) do
        for z=-90,90,45 do
            A.tree(self.root,CFrame.new(side*48,0,z),Color3.fromRGB(104,163,137),.85)
            A.lamp(self.root,CFrame.new(side*27,0,z+20),Color3.fromRGB(255,219,168))
            A.part(self.root,"BenchSeat",Vector3.new(3,.5,8),Vector3.new(side*43,1.8,z+13),Color3.fromRGB(174,123,88),Enum.Material.Wood,true)
            A.part(self.root,"BenchSupport",Vector3.new(2,1.5,6),Vector3.new(side*43,.75,z+13),A.ink,Enum.Material.Metal,true)
        end
    end
    local daily=A.cylinder(self.root,"DailyKiosk",Vector3.new(2,10,10),CFrame.new(16,1,45)*CFrame.Angles(0,0,math.pi/2),Color3.fromRGB(255,198,109),Enum.Material.Metal,true)
    A.sign(self.root,CFrame.new(16,7,45),"DAILY CLUB",12,3,Color3.fromRGB(255,207,129))
    A.prompt(daily,"Забрать награду","DAILY CLUB",function(p) self.R.Action:FireClient(p,"Daily") end)
    local race=A.part(self.root,"RaceMeetup",Vector3.new(18,.2,18),Vector3.new(-14,.15,45),Color3.fromRGB(174,155,229),nil,true)
    A.sign(self.root,CFrame.new(-14,7,45),"RACE CLUB",13,3,Color3.fromRGB(198,179,255))
    A.prompt(race,"Гонки","RACE CLUB",function(p) self.R.Open:FireClient(p,"Race") end)
end
function Lobby:Garage(index,cf)
    local m=A.model(self.root,string.format("Garage_%02d",index))
    local accent=({Color3.fromRGB(114,183,174),Color3.fromRGB(225,165,139),Color3.fromRGB(164,169,219)})[(index-1)%3+1]
    A.part(m,"Floor",Vector3.new(39,.4,44),cf*CFrame.new(0,.2,0),A.white,Enum.Material.Concrete,true)
    A.part(m,"Backwall",Vector3.new(39,16,1),cf*CFrame.new(0,8,21.5),accent,Enum.Material.Concrete,true)
    A.part(m,"Sidewall",Vector3.new(1,16,44),cf*CFrame.new(-19,8,0),A.white,Enum.Material.Concrete,true)
    local glass=A.part(m,"CornerGlazing",Vector3.new(.3,14,30),cf*CFrame.new(19,7,6),Color3.fromRGB(181,220,229),Enum.Material.Glass,true); glass.Transparency=.65
    A.part(m,"FloatingRoof",Vector3.new(43,.8,48),cf*CFrame.new(0,16.4,0),A.white,Enum.Material.Concrete,true)
    for x=-16,16,4 do A.part(m,"FasciaFin",Vector3.new(.4,3,2),cf*CFrame.new(x,14.8,-23),accent,Enum.Material.Wood,false) end
    A.part(m,"CeilingLight",Vector3.new(30,.1,.3),cf*CFrame.new(0,15.8,-6),Color3.fromRGB(255,225,181),Enum.Material.Neon,false)
    local _,label=A.sign(m,cf*CFrame.new(0,11.5,-22.2),string.format("%02d / AVAILABLE",index),29,3,accent)
    A.part(m,"Workbench",Vector3.new(14,3.5,4),cf*CFrame.new(-8,1.75,17),A.ink,Enum.Material.Metal,true)
    A.part(m,"ToolWall",Vector3.new(15,6,.3),cf*CFrame.new(-8,7,20.8),A.ink,Enum.Material.Metal,false)
    for j=1,5 do A.part(m,"Tool",Vector3.new(.2,1.7,.2),cf*CFrame.new(-15+j*2,7,20.5),Color3.fromRGB(193,201,211),Enum.Material.Metal,false) end
    A.cylinder(m,"DisplayTurntable",Vector3.new(.4,13,13),cf*CFrame.new(3,.65,0)*CFrame.Angles(0,0,math.pi/2),accent,Enum.Material.Metal,true)
    local marker=A.part(m,"GarageTablet",Vector3.new(2,3,.25),cf*CFrame.new(14,3,-17),A.ink,Enum.Material.Metal,false)
    A.prompt(marker,"Осмотреть","Гараж "..index,function(p) self.R.Open:FireClient(p,"Social") end)
    self.plots[index]={model=m,cf=cf,label=label,display=A.model(m,"Collection"),owner=nil}
end
function Lobby:Assign(player)
    for index,plot in ipairs(self.plots) do
        if not plot.owner then self.owners[player]=index; plot.owner=player; self:Refresh(player); return end
    end
end
function Lobby:Refresh(player)
    local plot=self.plots[self.owners[player]]; local p=self.data:Get(player)
    if not plot or not p then return end
    plot.label.Text=string.format("%02d / %s",self.owners[player],player.DisplayName)
    plot.display:ClearAllChildren()
    Bike.Build(plot.display,p.equippedBike,p.bikeLevels[p.equippedBike],plot.cf*CFrame.new(3,2.2,0)*CFrame.Angles(0,math.pi/2,0),false)
    local shown=0
    for _,name in ipairs(Config.BIKE_ORDER) do
        if p.ownedBikes[name] and name~=p.equippedBike and shown<3 then
            shown+=1
            Bike.Build(plot.display,name,p.bikeLevels[name],plot.cf*CFrame.new(-10+shown*8,2,12)*CFrame.Angles(0,math.pi/2,0),false)
        end
    end
end
function Lobby:Teleport(player,target)
    local c=player.Character; if not c then return end
    local plot=self.plots[self.owners[target or player]]
    local cf=plot and plot.cf*CFrame.new(0,4,-12) or CFrame.new(Config.LOBBY_SPAWN)
    c:PivotTo(cf)
    local r=c:FindFirstChild("HumanoidRootPart"); if r then r.AssemblyLinearVelocity=Vector3.zero end
end
function Lobby:Social()
    local rows={}
    for i,p in ipairs(self.plots) do
        if p.owner then table.insert(rows,{plot=i,userId=p.owner.UserId,name=p.owner.DisplayName,bike=p.owner:GetAttribute("EquippedBike")}) end
    end
    return rows
end
function Lobby:Release(player)
    local plot=self.plots[self.owners[player]]
    if plot then plot.owner=nil; plot.label.Text="AVAILABLE"; plot.display:ClearAllChildren() end
    self.owners[player]=nil
end
return Lobby
