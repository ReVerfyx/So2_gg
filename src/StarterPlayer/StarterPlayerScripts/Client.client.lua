local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local UIS=game:GetService("UserInputService")
local Run=game:GetService("RunService")
local Tween=game:GetService("TweenService")
local Sound=game:GetService("SoundService")
local player=Players.LocalPlayer
local Config=require(RS:WaitForChild("Shared"):WaitForChild("Config"))
local Courses=require(RS.Shared.Courses)
local R=RS:WaitForChild("CityRushRemotes")
local profile=nil
local current=nil
local requestVersion=0
local camera=workspace.CurrentCamera
local controls=require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetControls()
local colors={ink=Color3.fromRGB(20,29,43),panel=Color3.fromRGB(29,41,57),card=Color3.fromRGB(39,54,72),
    white=Color3.fromRGB(246,242,231),muted=Color3.fromRGB(158,179,194),mint=Color3.fromRGB(141,235,198),orange=Color3.fromRGB(255,193,124)}
local function make(class,parent,props)
    local x=Instance.new(class); for k,v in pairs(props or {}) do x[k]=v end; x.Parent=parent; return x
end
local function round(x,r) make("UICorner",x,{CornerRadius=UDim.new(0,r or 14)}) end
local function text(parent,value,size,color)
    return make("TextLabel",parent,{BackgroundTransparency=1,Text=value,TextSize=size or 16,TextColor3=color or colors.white,
        Font=Enum.Font.GothamMedium,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,Size=UDim2.new(1,0,0,28)})
end
local function button(parent,value,fn,color)
    local b=make("TextButton",parent,{Text=value,TextColor3=colors.ink,TextSize=14,Font=Enum.Font.GothamBold,
        BackgroundColor3=color or colors.mint,BorderSizePixel=0,Size=UDim2.fromOffset(130,40),AutoButtonColor=true})
    round(b,10); b.Activated:Connect(fn); return b
end
local gui=make("ScreenGui",player:WaitForChild("PlayerGui"),{Name="CityRush",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
    ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets,DisplayOrder=5})
local top=make("Frame",gui,{Position=UDim2.fromOffset(18,12),Size=UDim2.new(1,-36,0,58),BackgroundColor3=colors.ink,BorderSizePixel=0,BackgroundTransparency=.04})
round(top,16)
local logo=text(top,"CITY / RUSH",19); logo.Position=UDim2.fromOffset(16,6); logo.Size=UDim2.fromOffset(150,26); logo.Font=Enum.Font.GothamBlack
local sub=text(top,"BIKE DISTRICT",10,colors.mint); sub.Position=UDim2.fromOffset(17,32); sub.Size=UDim2.fromOffset(150,16)
local wallet=text(top,"0   /   COINS",15,colors.orange); wallet.AnchorPoint=Vector2.new(1,0); wallet.Position=UDim2.new(1,-16,0,7); wallet.Size=UDim2.fromOffset(180,24); wallet.TextXAlignment=Enum.TextXAlignment.Right
local rating=text(top,"0 RATING",11,colors.muted); rating.AnchorPoint=Vector2.new(1,0); rating.Position=UDim2.new(1,-16,0,33); rating.Size=UDim2.fromOffset(180,17); rating.TextXAlignment=Enum.TextXAlignment.Right
local dock=make("Frame",gui,{AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,-12),Size=UDim2.new(1,-24,0,54),BackgroundColor3=colors.ink,BorderSizePixel=0})
round(dock,16)
make("UISizeConstraint",dock,{MaxSize=Vector2.new(780,54),MinSize=Vector2.new(280,54)})
make("UIListLayout",dock,{FillDirection=Enum.FillDirection.Horizontal,HorizontalAlignment=Enum.HorizontalAlignment.Center,VerticalAlignment=Enum.VerticalAlignment.Center,Padding=UDim.new(0,5)})
local shade=make("Frame",gui,{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=.4,Visible=false,BorderSizePixel=0,ZIndex=10})
local panel=make("Frame",shade,{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.49),Size=UDim2.new(1,-28,1,-100),BackgroundColor3=colors.panel,BorderSizePixel=0,ZIndex=11})
round(panel,20); make("UISizeConstraint",panel,{MaxSize=Vector2.new(800,650),MinSize=Vector2.new(260,200)})
local title=text(panel,"",25); title.Position=UDim2.fromOffset(22,15); title.Size=UDim2.new(1,-85,0,35); title.ZIndex=12; title.Font=Enum.Font.GothamBlack
local close=button(panel,"×",function() shade.Visible=false; current=nil; requestVersion+=1 end,colors.muted)
close.Size=UDim2.fromOffset(38,38); close.Position=UDim2.new(1,-54,0,14); close.ZIndex=12
local list=make("ScrollingFrame",panel,{Position=UDim2.fromOffset(16,63),Size=UDim2.new(1,-32,1,-79),BackgroundTransparency=1,BorderSizePixel=0,
    ScrollBarThickness=3,ScrollBarImageColor3=colors.mint,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),ZIndex=12})
local layout=make("UIListLayout",list,{Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder})
local toast=text(gui,"",15); toast.AnchorPoint=Vector2.new(.5,1); toast.Position=UDim2.new(.5,0,1,-80); toast.Size=UDim2.new(1,-40,0,48)
toast.TextXAlignment=Enum.TextXAlignment.Center; toast.BackgroundColor3=colors.ink; toast.BackgroundTransparency=.05; toast.Visible=false; toast.ZIndex=30; round(toast,12)
make("UISizeConstraint",toast,{MaxSize=Vector2.new(520,80),MinSize=Vector2.new(200,48)})
local toastVersion=0
local function notify(msg)
    if not msg then return end
    toastVersion+=1; local v=toastVersion; toast.Text=tostring(msg); toast.Visible=true
    task.delay(3.5,function() if toastVersion==v then toast.Visible=false end end)
end
local save=text(gui,"Сохранение задерживается. Не выходи из игры.",12,colors.orange)
save.Position=UDim2.fromOffset(20,74); save.Size=UDim2.new(1,-40,0,22); save.Visible=false
player:GetAttributeChangedSignal("SaveWarning"):Connect(function() save.Visible=player:GetAttribute("SaveWarning")==true end)
local function card(height)
    local c=make("Frame",list,{Size=UDim2.new(1,-5,0,height),BackgroundColor3=colors.card,BorderSizePixel=0,ZIndex=13}); round(c,14)
    c.LayoutOrder=#list:GetChildren(); return c
end
local function line(c,value,y,size,color)
    local t=text(c,value,size,color); t.Position=UDim2.fromOffset(16,y); t.Size=UDim2.new(1,-32,0,28); t.ZIndex=14; return t
end
local function action(c,value,fn,x,y,color)
    local b=button(c,value,fn,color)
    b.Position=x>100 and UDim2.new(.5,3,0,y) or UDim2.fromOffset(16,y)
    b.Size=UDim2.new(.5,-19,0,40); b.ZIndex=14; return b
end
local function clear()
    for _,x in ipairs(list:GetChildren()) do if x~=layout then x:Destroy() end end
    list.CanvasPosition=Vector2.zero
end
local function sync()
    wallet.Text=tostring(player:GetAttribute("Coins") or 0).."   /   COINS"
    rating.Text=tostring(player:GetAttribute("Rating") or 0).." RATING"
end
for _,a in ipairs({"Coins","Rating"}) do player:GetAttributeChangedSignal(a):Connect(sync) end
sync()
local open
local function preview(c,name)
    local folder=RS:FindFirstChild("BikePreviews"); local source=folder and folder:FindFirstChild(name)
    if not source then return end
    local view=make("ViewportFrame",c,{Size=UDim2.fromOffset(108,84),Position=UDim2.new(1,-118,0,9),BackgroundTransparency=1,
        Ambient=Color3.fromRGB(195,210,226),LightColor=Color3.fromRGB(255,226,193),LightDirection=Vector3.new(-1,-2,-1),ZIndex=14})
    local model=source:Clone(); model.Parent=view
    local cam=make("Camera",view,{CFrame=CFrame.lookAt(Vector3.new(7,3,8),Vector3.new(0,.5,0)),FieldOfView=40}); view.CurrentCamera=cam
end
local function worlds()
    title.Text="ВЫБЕРИ СВОЮ ЛИНИЮ"
    for i,w in ipairs(Config.WORLDS) do
        local c=card(177); local locked=i>(profile.unlocked or 1)
        local n=line(c,string.format("0%d / %s",i,w.name),10,21,w.color); n.Font=Enum.Font.GothamBlack
        line(c,w.subtitle.."  ·  12 этапов",42,13,colors.muted)
        local best=profile.bestTimes[tostring(i)]
        local medal=({[0]="—","Бронза","Серебро","Золото"})[profile.medals[tostring(i)] or 0]
        line(c,best and string.format("Рекорд %.2f с   /   %s",best,medal) or "Пройди мир и открой следующий",69,13)
        action(c,locked and "ЗАКРЫТО" or "НА СТАРТ",function()
            if locked then notify("Сначала пройди предыдущий мир"); return end
            R.Action:FireServer("Start",i,false); shade.Visible=false
        end,16,116,locked and colors.muted or w.color)
        local cp=profile.checkpoints[tostring(i)] or 0
        if cp>0 and not locked then
            local b=action(c,"ЭТАП "..(cp+1),function() R.Action:FireServer("Start",i,true); shade.Visible=false end,153,116,colors.white)
        end
    end
end
local function bikes()
    title.Text="THE CYCLE ATELIER"
    for _,name in ipairs(Config.BIKE_ORDER) do
        local info=Config.BIKES[name]; local owned=profile.ownedBikes[name]; local level=profile.bikeLevels[name] or 1
        local c=card(194)
        local n=line(c,info.displayName,12,16,info.color); n.Size=UDim2.new(1,-138,0,48)
        local levelText=line(c,"LEVEL "..level.." / "..Config.BIKE_MAX_LEVEL,60,11,colors.muted); levelText.Size=UDim2.new(1,-130,0,24)
        line(c,string.format("Скорость %d  ·  Разгон %d  ·  Руль %.1f",info.speed,info.acceleration,info.handling),94,12)
        preview(c,name)
        local selected=profile.equippedBike==name
        action(c,selected and "ВЫБРАН" or (owned and "ВЫБРАТЬ" or tostring(info.price).." COINS"),function() R.Action:FireServer("Select",name) end,16,139,selected and colors.muted or colors.mint)
        if owned then
            local cost=level>=Config.BIKE_MAX_LEVEL and "MAX" or "+ LV / "..Config.GetUpgradeCost(name,level)
            local b=action(c,cost,function() R.Action:FireServer("Upgrade",name) end,153,139,info.color)
        end
    end
end
local function daily()
    title.Text="DAILY CLUB"
    local day=math.floor(os.time()/86400); local claimed=profile.lastDaily>=day
    local nextDay=profile.lastDaily==day-1 and (profile.streak%7)+1 or (claimed and profile.streak or 1)
    for i,reward in ipairs(Config.DAILY_REWARDS) do
        local c=card(62); line(c,"День "..i.."   /   "..reward.." COINS",16,16,i==nextDay and colors.mint or colors.muted)
    end
    local c=card(70); action(c,claimed and "ПОЛУЧЕНО" or "ЗАБРАТЬ",function() R.Action:FireServer("Daily") end,16,15,colors.orange)
end
local function settings()
    title.Text="НАСТРОЙКИ"
    for _,item in ipairs({{"music","Музыка"},{"reducedMotion","Меньше движения камеры"}}) do
        local key,label=table.unpack(item); local c=card(100)
        line(c,label,8,16)
        action(c,profile.settings[key] and "ВКЛ" or "ВЫКЛ",function() R.Action:FireServer("Settings",key,not profile.settings[key]) end,16,47)
    end
    local c=card(100); line(c,"Гонки проходят на одинаковых характеристиках велосипедов.",12,14,colors.muted)
    local t=line(c,"Возврат к чекпоинту доступен в любой момент заезда.",47,13,colors.muted); t.Size=UDim2.new(1,-32,0,45)
end
open=function(page)
    if not profile then notify("Загружаем гараж…"); return end
    requestVersion+=1; local version=requestVersion
    current=page; shade.Visible=true; clear()
    if page=="Worlds" then worlds()
    elseif page=="Bikes" then bikes()
    elseif page=="Daily" then daily()
    elseif page=="Settings" then settings()
    elseif page=="Social" or page=="Top" or page=="Race" then
        title.Text=page=="Social" and "BIKE DISTRICT" or (page=="Top" and "GLOBAL RIDERS" or "RACE CLUB")
        line(card(60),"Загрузка…",15,15,colors.muted)
        task.spawn(function()
            local ok,result=pcall(function()
                if page=="Social" then return R.RequestSocial:InvokeServer() end
                if page=="Top" then return R.RequestTop:InvokeServer() end
                return R.RequestRace:InvokeServer()
            end)
            if current~=page or version~=requestVersion then return end
            clear()
            if not ok or not result then line(card(65),"Не удалось загрузить. Попробуй ещё раз.",12,14); return end
            if page=="Race" then
                local c=card(210)
                line(c,"COASTLINE / EQUAL BIKES",12,18,colors.mint)
                line(c,"Одинаковая скорость. Побеждает точность.",47,14,colors.muted)
                local statusLine=line(c,"",80,14)
                statusLine:SetAttribute("RaceTime",result.active and 0 or result.nextStart)
                statusLine.Text=result.active and "Гонка идёт" or "Старт через "..math.max(0,math.ceil(result.nextStart-workspace:GetServerTimeNow())).." с"
                line(c,"В очереди: "..result.count.." / минимум 2",111,14)
                action(c,result.queued and "ВЫЙТИ" or "УЧАСТВОВАТЬ",function() R.Action:FireServer("Queue"); task.delay(.3,function() if current=="Race" then open("Race") end end) end,16,155,colors.orange)
                for _,row in ipairs(result.results) do line(card(65),string.format("#%d  %s  /  %.2f с",row.rank,row.name,row.seconds),15,15) end
            else
                if #result==0 then line(card(70),page=="Top" and "Рейтинг появится после первых прохождений." or "Гаражи пока пустуют.",12,14) end
                for _,row in ipairs(result) do
                    local c=card(page=="Social" and 115 or 68)
                    line(c,string.format("#%02d / %s",row.plot or row.rank,row.name),10,16)
                    if page=="Social" then
                        action(c,"ПОСЕТИТЬ",function() R.Action:FireServer("Visit",row.userId); shade.Visible=false end,16,57,colors.mint)
                    else line(c,tostring(row.rating).." RATING",36,12,colors.orange) end
                end
            end
        end)
    end
    if not (profile.settings and profile.settings.reducedMotion) then
        panel.Position=UDim2.fromScale(.5,.51); Tween:Create(panel,TweenInfo.new(.18,Enum.EasingStyle.Quad),{Position=UDim2.fromScale(.5,.49)}):Play()
    end
end
for _,item in ipairs({{"ЕХАТЬ","Worlds"},{"БАЙКИ","Bikes"},{"ГАРАЖИ","Social"},{"ТОП","Top"},{"КЛУБ","Daily"},{"ОПЦИИ","Settings"}}) do
    local page=item[2]; local b=button(dock,item[1],function() open(page) end,page=="Worlds" and colors.mint or colors.card)
    b.Size=UDim2.new(1/6,-8,0,40); b.TextSize=11; if page~="Worlds" then b.TextColor3=colors.white end
end
local hud=make("Frame",gui,{Position=UDim2.fromOffset(18,82),Size=UDim2.new(1,-36,0,80),BackgroundColor3=colors.ink,BorderSizePixel=0,Visible=false})
round(hud,15)
local stageText=text(hud,"",17); stageText.Position=UDim2.fromOffset(14,6); stageText.Size=UDim2.new(.68,0,0,24)
local timer=text(hud,"",18,colors.mint); timer.Position=UDim2.new(.7,0,0,8); timer.Size=UDim2.new(.3,-14,0,24); timer.TextXAlignment=Enum.TextXAlignment.Right
local progress=make("Frame",hud,{Position=UDim2.new(0,14,1,-20),Size=UDim2.new(1,-28,0,5),BorderSizePixel=0,BackgroundColor3=colors.card}); round(progress,3)
local fill=make("Frame",progress,{Size=UDim2.fromScale(0,1),BorderSizePixel=0,BackgroundColor3=colors.mint}); round(fill,3)
local stageName=text(hud,"",11,colors.muted); stageName.Position=UDim2.fromOffset(14,32); stageName.Size=UDim2.new(1,-28,0,20)
local rideBar=make("Frame",gui,{AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,-12),Size=UDim2.fromOffset(286,48),BackgroundTransparency=1,Visible=false})
local retry=button(rideBar,"ЧЕКПОИНТ",function() R.Action:FireServer("Retry") end,colors.white)
local home=button(rideBar,"В ГАРАЖ",function() R.Action:FireServer("Home") end,colors.muted); home.Position=UDim2.fromOffset(145,0)
local jumpPressed=false; local brakePressed=false; local touchButtons={}
local function touchButton(label,x,fnDown,fnUp)
    local b=button(gui,label,function() end,colors.white); b.AnchorPoint=Vector2.new(1,1); b.Position=UDim2.new(1,x,1,-92); b.Size=UDim2.fromOffset(86,65); b.Visible=false
    b.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then fnDown() end end)
    b.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then fnUp() end end)
    table.insert(touchButtons,b)
end
touchButton("ПРЫЖОК",-18,function() jumpPressed=true end,function() jumpPressed=false end)
touchButton("ТОРМОЗ",-112,function() brakePressed=true end,function() brakePressed=false end)
UIS.JumpRequest:Connect(function() jumpPressed=true; task.delay(.12,function() jumpPressed=false end) end)
UIS.WindowFocusReleased:Connect(function() jumpPressed=false; brakePressed=false; R.Input:FireServer(0,0,false) end)
local function riding()
    local on=player:GetAttribute("Riding")==true
    hud.Visible=on; rideBar.Visible=on; dock.Visible=not on
    for _,b in ipairs(touchButtons) do b.Visible=on and UIS.TouchEnabled end
    if on then shade.Visible=false; current=nil; camera.CameraType=Enum.CameraType.Scriptable
    else
        camera.CameraType=Enum.CameraType.Custom; camera.FieldOfView=70
        local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid"); if h then camera.CameraSubject=h; h:SetStateEnabled(Enum.HumanoidStateType.Jumping,true) end
    end
end
player:GetAttributeChangedSignal("Riding"):Connect(riding)
R.Toast.OnClientEvent:Connect(notify)
R.Open.OnClientEvent:Connect(open)
R.Action.OnClientEvent:Connect(function(actionName) if actionName=="Daily" then open("Daily") end end)
local music=make("Sound",Sound,{Name="CityRushMusic",SoundId=Config.MUSIC_ID,Volume=.18,Looped=true})
local function applyProfile(p)
    if not p then return end
    profile=p
    if Config.MUSIC_ID~="" then if profile.settings.music then if not music.IsPlaying then music:Play() end else music:Pause() end end
    if shade.Visible and (current=="Bikes" or current=="Daily" or current=="Settings") then open(current) end
end
R.Profile.OnClientEvent:Connect(applyProfile)
R.State.OnClientEvent:Connect(function(state)
    if state.kind=="Checkpoint" then
        notify("CHECKPOINT "..state.stage.." / 12")
        if not (profile and profile.settings.reducedMotion) then
            fill.BackgroundColor3=colors.white; Tween:Create(fill,TweenInfo.new(.5),{BackgroundColor3=colors.mint}):Play()
        end
    elseif state.kind=="Finish" then
        current="Result"; shade.Visible=true; clear(); title.Text="ЛИНИЯ ПРОЙДЕНА"
        local c=card(230)
        line(c,Config.WORLDS[state.world].name,12,23,colors.mint)
        line(c,string.format("%.2f с   /   %d падений",state.seconds,state.deaths),56,19)
        line(c,"+"..state.reward.." COINS"..(state.first and "   /   ПЕРВОЕ ПРОХОЖДЕНИЕ" or ""),99,14,colors.orange)
        line(c,state.ranked and "Результат сохранён" or "Продолженный заезд — без рекорда времени",131,12,colors.muted)
        action(c,"ЕЩЁ РАЗ",function() R.Action:FireServer("Start",state.world,false); shade.Visible=false end,16,178)
        action(c,"МИРЫ",function() open("Worlds") end,153,178,colors.white)
    end
end)
local send=0
Run.RenderStepped:Connect(function(dt)
    if current=="Race" and shade.Visible then
        for _,x in ipairs(list:GetDescendants()) do
            local t=x:GetAttribute("RaceTime")
            if t and t>0 then x.Text="Старт через "..math.max(0,math.ceil(t-workspace:GetServerTimeNow())).." с" end
        end
    end
    if not player:GetAttribute("Riding") then return end
    local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    -- Native Roblox thumbstick, keyboard and gamepad all feed the same input path.
    local move=controls:GetMoveVector()
    local throttle=brakePressed and 0 or math.clamp(-move.Z,-1,1)
    local steer=math.clamp(move.X,-1,1)
    if UIS:GetFocusedTextBox() then throttle=0; steer=0 end
    send+=dt
    if send>=.05 then send=0; R.Input:FireServer(throttle,steer,jumpPressed or UIS:IsKeyDown(Enum.KeyCode.Space)) end
    if h then h.Jump=false; h:SetStateEnabled(Enum.HumanoidStateType.Jumping,false) end
    local seat=h and h.SeatPart
    local frame=seat and seat.CFrame or root.CFrame
    local dir=Vector3.new(frame.LookVector.X,0,frame.LookVector.Z)
    if dir.Magnitude<.01 then dir=Vector3.new(0,0,-1) else dir=dir.Unit end
    local target=root.Position+Vector3.new(0,2,0)
    local desired=target-dir*17+Vector3.new(0,8,0)
    local params=RaycastParams.new(); params.FilterDescendantsInstances={player.Character,workspace:FindFirstChild("ActiveBikes")}; params.RespectCanCollide=true
    local hit=workspace:Raycast(target,desired-target,params)
    if hit then desired=hit.Position+hit.Normal*.7 end
    local cf=CFrame.lookAt(desired,target+dir*4)
    local reduced=profile and profile.settings.reducedMotion
    camera.CFrame=camera.CFrame:Lerp(cf,1-math.exp(-dt*(reduced and 14 or 6)))
    camera.FieldOfView=reduced and 70 or 70+math.min(root.AssemblyLinearVelocity.Magnitude/8,6)
    local world=player:GetAttribute("World") or 1; local cp=player:GetAttribute("Checkpoint") or 0
    stageText.Text=Config.WORLDS[world].name.." / "..math.min(cp+1,12).." из 12"
    stageName.Text=Courses[Config.WORLDS[world].id][math.min(cp+1,12)].name
    local elapsed=workspace:GetServerTimeNow()-(player:GetAttribute("RunStart") or workspace:GetServerTimeNow())
    timer.Text=elapsed<0 and tostring(math.ceil(-elapsed)) or string.format("%02d:%05.2f",math.floor(elapsed/60),elapsed%60)
    fill.Size=UDim2.fromScale(cp/12,1)
end)
task.spawn(function()
    for _=1,30 do
        local ok,p=pcall(function() return R.RequestProfile:InvokeServer() end)
        if ok and p then applyProfile(p); return end
        task.wait(1)
    end
    notify("Профиль недоступен. Переподключись к игре.")
end)
riding()
