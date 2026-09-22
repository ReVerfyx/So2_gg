local Tags=game:GetService("CollectionService")
local Players=game:GetService("Players")
local Run=game:GetService("RunService")
local wheels={}
local function register(bike)
    if wheels[bike] then return end
    local state={motors={},angle=0}; wheels[bike]=state
    local function add(x) if x:IsA("Motor6D") and x.Name=="WheelMotor" then state.motors[x]=true end end
    for _,x in ipairs(bike:GetDescendants()) do add(x) end
    state.connection=bike.DescendantAdded:Connect(add)
end
for _,bike in ipairs(Tags:GetTagged("CityBike")) do register(bike) end
Tags:GetInstanceAddedSignal("CityBike"):Connect(register)
Tags:GetInstanceRemovedSignal("CityBike"):Connect(function(bike)
    if wheels[bike] then wheels[bike].connection:Disconnect(); wheels[bike]=nil end
end)
local riders={}
local function character(c)
    local joints={}
    for _,x in ipairs(c:GetDescendants()) do if x:IsA("Motor6D") then joints[x.Name]=x end end
    return joints
end
Run.PreSimulation:Connect(function(dt)
    for bike,state in pairs(wheels) do
        local root=bike.PrimaryPart
        if root and root.Parent then
            state.angle=(state.angle+root.AssemblyLinearVelocity:Dot(root.CFrame.LookVector)/1.35*dt)%(2*math.pi)
            for motor in pairs(state.motors) do if motor.Parent then motor.Transform=CFrame.Angles(-state.angle,0,0) else state.motors[motor]=nil end end
        end
    end
    for _,p in ipairs(Players:GetPlayers()) do
        local c=p.Character
        if p:GetAttribute("Riding") and c then
            local state=riders[p]
            if not state or state.c~=c then state={c=c,joints=character(c),phase=0}; riders[p]=state end
            local root=c:FindFirstChild("HumanoidRootPart")
            state.phase+=dt*(root and root.AssemblyLinearVelocity.Magnitude or 0)*.35
            local function pose(name,x,z)
                local joint=state.joints[name]
                if joint and joint.Parent then joint.Transform=CFrame.Angles(x,0,z or 0) end
            end
            pose("Waist",-.22)
            pose("LeftShoulder",1.1,-.1); pose("RightShoulder",1.1,.1)
            pose("LeftElbow",-.35); pose("RightElbow",-.35)
            pose("LeftHip",1+.25*math.sin(state.phase)); pose("RightHip",1-.25*math.sin(state.phase))
            pose("LeftKnee",-1.1); pose("RightKnee",-1.1)
            pose("Left Shoulder",1.1,-.1); pose("Right Shoulder",1.1,.1)
            pose("Left Hip",.8+.2*math.sin(state.phase)); pose("Right Hip",.8-.2*math.sin(state.phase))
        elseif riders[p] then
            for _,joint in pairs(riders[p].joints) do if joint.Parent then joint.Transform=CFrame.new() end end
            riders[p]=nil
        end
    end
end)
Players.PlayerRemoving:Connect(function(p) riders[p]=nil end)
