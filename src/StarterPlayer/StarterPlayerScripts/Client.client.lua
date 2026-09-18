local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local UIS=game:GetService("UserInputService")
local player=Players.LocalPlayer
local R=RS:WaitForChild("CodeRotRemotes")

local gui=Instance.new("ScreenGui")
gui.Name="CodeRotUI"
gui.ResetOnSpawn=false
gui.Parent=player:WaitForChild("PlayerGui")

local function mk(name,pos,size,text)
 local x=Instance.new("TextLabel")
 x.Name=name;x.Position=pos;x.Size=size;x.BackgroundColor3=Color3.fromRGB(20,22,28);x.BackgroundTransparency=.2
 x.TextColor3=Color3.fromRGB(240,238,225);x.Font=Enum.Font.Code;x.TextSize=18;x.TextWrapped=true;x.Text=text;x.Parent=gui
 return x
end

local chapter=mk("Chapter",UDim2.fromOffset(12,12),UDim2.fromOffset(430,48),"2015: CODE ROT")
local objective=mk("Objective",UDim2.fromOffset(12,66),UDim2.fromOffset(500,64),"Waiting...")
local timer=mk("Timer",UDim2.new(1,-150,0,12),UDim2.fromOffset(138,44),"--:--")
local toast=mk("Toast",UDim2.new(.5,-230,0,145),UDim2.fromOffset(460,70),"")
toast.Visible=false

local build=Instance.new("TextButton")
build.Size=UDim2.fromOffset(120,48);build.Position=UDim2.new(1,-260,1,-60);build.Text="BUILD";build.Visible=UIS.TouchEnabled;build.Parent=gui
local del=build:Clone();del.Position=UDim2.new(1,-130,1,-60);del.Text="DELETE";del.Parent=gui

local mouse=player:GetMouse()
local function say(t)
 toast.Text=tostring(t);toast.Visible=true
 task.delay(3,function() if toast.Text==tostring(t) then toast.Visible=false end end)
end
local function place()
 if not player:GetAttribute("InRound") then return end
 local p=mouse.Hit.Position
 R.BuildPlace:FireServer(p,Vector3.new(0,1,0))
end
local function remove()
 if player:GetAttribute("InRound") and mouse.Target then R.BuildDelete:FireServer(mouse.Target) end
end
build.Activated:Connect(place);del.Activated:Connect(remove)
UIS.InputBegan:Connect(function(i,gp)
 if gp then return end
 if i.KeyCode==Enum.KeyCode.B then place() elseif i.KeyCode==Enum.KeyCode.X then remove() end
end)

R.Toast.OnClientEvent:Connect(say)
R.RoundTime.OnClientEvent:Connect(function(s) s=math.max(0,tonumber(s) or 0);timer.Text=string.format("%02d:%02d",math.floor(s/60),s%60) end)
R.Objective.OnClientEvent:Connect(function(t) objective.Text=tostring(t) end)
R.ChapterChanged.OnClientEvent:Connect(function(id,total,t,sub,intro)
 chapter.Text=string.format("CHAPTER %d/%d  %s",id,total,tostring(t))
 say(tostring(sub).."\n"..tostring(intro))
end)
R.WorldPulse.OnClientEvent:Connect(function(stage,msg) say("SERVER UPDATE #"..stage.."\n"..tostring(msg)) end)
R.ChapterCompleted.OnClientEvent:Connect(function(id,t) say("CHAPTER COMPLETE: "..tostring(t)) end)
R.Countdown.OnClientEvent:Connect(function(n) if n>0 then say("START IN "..n) end end)
R.FinalSequence.OnClientEvent:Connect(function() say("ROLLBACK COMPLETE. The server remembers.") end)

R.MemoryFlash.OnClientEvent:Connect(function(index,info,count)
 local f=Instance.new("Frame");f.Size=UDim2.fromScale(1,1);f.BackgroundColor3=Color3.new(1,1,1);f.Parent=gui
 local m=mk("Memory",UDim2.new(.5,-300,.5,-120),UDim2.fromOffset(600,240),(info and info.title or "MEMORY").."\n\n"..(info and info.text or ""))
 m.ZIndex=10;f.ZIndex=9
 task.wait(.25);f.BackgroundTransparency=.9
 task.wait(index==5 and 8 or 4)
 f:Destroy();m:Destroy()
end)

R.OpenClassMenu.OnClientEvent:Connect(function(classes,data)
 local old=gui:FindFirstChild("ClassMenu");if old then old:Destroy() end
 local frame=Instance.new("Frame");frame.Name="ClassMenu";frame.Size=UDim2.fromOffset(430,350);frame.Position=UDim2.new(.5,-215,.5,-175);frame.BackgroundColor3=Color3.fromRGB(18,20,26);frame.Parent=gui
 local y=12
 for name,info in pairs(classes) do
  local b=Instance.new("TextButton");b.Size=UDim2.new(1,-24,0,62);b.Position=UDim2.fromOffset(12,y);b.Text=info.displayName.."  "..info.price.." Bits\n"..info.description;b.TextWrapped=true;b.Parent=frame
  b.Activated:Connect(function()
   local owned=data and data.ownedClasses and data.ownedClasses[name]
   R.ClassAction:FireServer(owned and "Select" or "Buy",name);frame:Destroy()
  end)
  y+=68
 end
end)
