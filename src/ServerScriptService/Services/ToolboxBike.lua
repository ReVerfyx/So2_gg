-- Creator Store geometry only; source scripts, constraints, seats and remotes never enter the DataModel.
local Assets=game:GetService("AssetService")
local RS=game:GetService("ReplicatedStorage")
local Config=require(RS.Shared.Config)
local Toolbox={}
local template=nil
Toolbox.AssetId=404397280 -- https://create.roblox.com/store/asset/404397280/BMX-Bike
local function visualChild(x)
    return x:IsA("DataModelMesh") or x:IsA("Decal") or x:IsA("SurfaceAppearance")
end
function Toolbox.Load()
    local ok,source=pcall(function() return Assets:LoadAssetAsync(Toolbox.AssetId) end)
    if not ok then RS:SetAttribute("BikeAssetStatus","Unavailable"); warn("BMX Creator Store asset unavailable",Toolbox.AssetId); return false end
    local clean=Instance.new("Model"); clean.Name="ToolboxBMX"
    local prepared,reason=pcall(function()
        local parts={}; local seatFrame=nil
        for _,x in ipairs(source:GetDescendants()) do
            if x:IsA("Seat") or x:IsA("VehicleSeat") then seatFrame=x.CFrame end
            if x:IsA("BasePart") and not x:IsA("Seat") and not x:IsA("VehicleSeat") then table.insert(parts,x) end
        end
        assert(#parts>0 and #parts<=500,"Unexpected model complexity")
        for _,original in ipairs(parts) do
            local p=original:Clone()
            for _,child in ipairs(p:GetChildren()) do
                if not visualChild(child) then child:Destroy()
                else for _,nested in ipairs(child:GetDescendants()) do nested:Destroy() end end
            end
            p.Anchored=true; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false; p.Massless=true
            p.Parent=clean
        end
        -- Use the artist's seat orientation when present, then normalize to bicycle dimensions.
        local box=clean:GetBoundingBox()
        local orientation=seatFrame and seatFrame.Rotation or box.Rotation
        clean.WorldPivot=CFrame.new(box.Position)*orientation
        clean:PivotTo(CFrame.new())
        local _,size=clean:GetBoundingBox()
        assert(size.Z>0 and size.Magnitude<100,"Unexpected model bounds")
        clean:ScaleTo(7.2/size.Z)
        local bounds,scaled=clean:GetBoundingBox()
        assert(scaled.X<=5 and scaled.Y<=6,"Model needs manual axis/scale setup")
        local bottom=bounds.Position.Y-scaled.Y/2
        clean:PivotTo(CFrame.new(0,-1.35-bottom,0))
        local pivot=Instance.new("Part"); pivot.Name="Chassis"; pivot.Size=Vector3.new(.2,.2,.2)
        pivot.Transparency=1; pivot.Anchored=true; pivot.CanCollide=false; pivot.CanQuery=false; pivot.CanTouch=false
        pivot.CFrame=CFrame.new(); pivot.Parent=clean; clean.PrimaryPart=pivot
    end)
    source:Destroy()
    if not prepared then clean:Destroy(); RS:SetAttribute("BikeAssetStatus","Invalid"); warn("BMX model rejected:",reason); return false end
    template=clean; RS:SetAttribute("BikeAssetStatus","Loaded"); RS:SetAttribute("BikeAssetId",Toolbox.AssetId)
    return true
end
function Toolbox.Clone(parent,name,level,cf)
    if not template then return nil end
    local m=template:Clone(); m.Name="DisplayBike"; m:PivotTo(cf)
    m:SetAttribute("BikeName",name); m:SetAttribute("Level",level); m:SetAttribute("DisplayFrame",cf)
    local color=(Config.BIKES[name] or Config.BIKES.BMX).color
    for _,part in ipairs(m:GetDescendants()) do
        if part:IsA("BasePart") then
            local _,saturation=part.Color:ToHSV()
            if saturation>.3 then part.Color=color end
        end
    end
    m:SetAttribute("ToolboxAssetId",Toolbox.AssetId); m.Parent=parent
    return m
end
return Toolbox
