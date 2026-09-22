local Art={}
Art.ink=Color3.fromRGB(30,43,60)
Art.white=Color3.fromRGB(243,238,223)
function Art.part(parent,name,size,cf,color,material,collide)
    local p=Instance.new("Part"); p.Name=name; p.Size=size
    p.CFrame=typeof(cf)=="Vector3" and CFrame.new(cf) or cf
    p.Color=color; p.Material=material or Enum.Material.SmoothPlastic
    p.Anchored=true; p.CanCollide=collide~=false; p.CanTouch=false; p.CanQuery=p.CanCollide
    p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth; p.Parent=parent
    return p
end
function Art.cylinder(parent,name,size,cf,color,material,collide)
    local p=Art.part(parent,name,size,cf,color,material,collide); p.Shape=Enum.PartType.Cylinder; return p
end
function Art.tube(parent,name,a,b,r,color,material)
    return Art.cylinder(parent,name,Vector3.new((b-a).Magnitude,r,r),CFrame.lookAt((a+b)/2,b)*CFrame.Angles(0,math.pi/2,0),color,material,false)
end
function Art.model(parent,name)
    local m=Instance.new("Model"); m.Name=name; m.Parent=parent; return m
end
function Art.sign(parent,cf,text,width,height,color)
    local p=Art.part(parent,"Sign",Vector3.new(width,height,.18),cf,Art.ink,nil,false)
    local ui=Instance.new("SurfaceGui"); ui.Face=Enum.NormalId.Front; ui.PixelsPerStud=40
    ui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud; ui.LightInfluence=0; ui.Parent=p
    local t=Instance.new("TextLabel"); t.Size=UDim2.fromScale(.94,.85); t.Position=UDim2.fromScale(.03,.075)
    t.BackgroundTransparency=1; t.Text=text; t.TextColor3=color or Art.white; t.Font=Enum.Font.GothamBold
    t.TextScaled=true; t.TextWrapped=true; t.Parent=ui
    return p,t
end
function Art.prompt(p,action,object,fn)
    local q=Instance.new("ProximityPrompt"); q.ActionText=action; q.ObjectText=object; q.MaxActivationDistance=12
    q.RequiresLineOfSight=false; q.HoldDuration=.15; q.Parent=p; q.Triggered:Connect(fn); return q
end
function Art.tree(parent,cf,color,scale)
    scale=scale or 1
    local m=Art.model(parent,"SculptedTree")
    Art.cylinder(m,"Planter",Vector3.new(1.5,9,9)*scale,cf*CFrame.new(0,.75*scale,0)*CFrame.Angles(0,0,math.pi/2),Art.white,Enum.Material.Concrete,true)
    Art.tube(m,"Trunk",cf.Position+Vector3.new(0,1,0)*scale,cf.Position+Vector3.new(0,10,0)*scale,1.1*scale,Color3.fromRGB(123,90,70),Enum.Material.Wood)
    for i=1,3 do
        local crown=Art.part(m,"Canopy",Vector3.new(8,6,7)*scale,cf*CFrame.new((i-2)*2.5*scale,(9+i)*scale,0),color,nil,false)
        crown.Shape=Enum.PartType.Ball
    end
    return m
end
function Art.lamp(parent,cf,color)
    Art.tube(parent,"LampColumn",cf.Position,cf.Position+Vector3.new(0,13,0),.4,Art.ink,Enum.Material.Metal)
    local head=Art.part(parent,"Lantern",Vector3.new(2,.3,3),cf*CFrame.new(0,13,0),color,Enum.Material.Neon,false)
    local l=Instance.new("PointLight"); l.Color=color; l.Range=22; l.Brightness=.6; l.Parent=head
end
function Art.building(parent,cf,width,height,depth,color)
    local m=Art.model(parent,"TerracedArchitecture")
    Art.part(m,"Facade",Vector3.new(width,height,depth),cf*CFrame.new(0,height/2,0),color,Enum.Material.Concrete,true)
    for y=7,height-3,8 do
        Art.part(m,"ContinuousGlazing",Vector3.new(width+.15,3.8,depth+.15),cf*CFrame.new(0,y,0),Color3.fromRGB(80,126,151),Enum.Material.Glass,false)
        Art.part(m,"Sunshade",Vector3.new(width+1.2,.35,depth+1.2),cf*CFrame.new(0,y+2.2,0),Art.white,Enum.Material.Metal,false)
    end
    for x=-width/2+2,width/2,6 do
        Art.part(m,"VerticalFin",Vector3.new(.5,height+1,.6),cf*CFrame.new(x,height/2,-depth/2-.5),Art.white,Enum.Material.Metal,false)
    end
    Art.part(m,"RoofGarden",Vector3.new(width+2,.6,depth+2),cf*CFrame.new(0,height+.3,0),Art.white,Enum.Material.Concrete,true)
    Art.part(m,"PlantBed",Vector3.new(width-4,1.1,4),cf*CFrame.new(0,height+1,depth/2-3),Color3.fromRGB(105,168,135),Enum.Material.Grass,false)
    return m
end
return Art
