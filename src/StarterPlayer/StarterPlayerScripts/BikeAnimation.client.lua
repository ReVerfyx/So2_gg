local Tags=game:GetService("CollectionService")
local Run=game:GetService("RunService")
local wheels={}
local function register(bike)
    task.defer(function()
        if not bike.Parent then return end
        local motors={}
        for _,x in ipairs(bike:GetDescendants()) do if x:IsA("Motor6D") and x.Name=="WheelMotor" then table.insert(motors,x) end end
        wheels[bike]={motors=motors,angle=0}
    end)
end
for _,bike in ipairs(Tags:GetTagged("CityBike")) do register(bike) end
Tags:GetInstanceAddedSignal("CityBike"):Connect(register)
Tags:GetInstanceRemovedSignal("CityBike"):Connect(function(bike) wheels[bike]=nil end)
Run.PreSimulation:Connect(function(dt)
    for bike,state in pairs(wheels) do
        local root=bike.PrimaryPart
        if root and root.Parent then
            state.angle=(state.angle+root.AssemblyLinearVelocity:Dot(root.CFrame.LookVector)/1.35*dt)%(2*math.pi)
            for _,motor in ipairs(state.motors) do if motor.Parent then motor.Transform=CFrame.Angles(-state.angle,0,0) end end
        end
    end
end)
