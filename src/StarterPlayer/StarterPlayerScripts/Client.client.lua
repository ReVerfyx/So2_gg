local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local UIS=game:GetService("UserInputService")
local LocalizationService=game:GetService("LocalizationService")
local TweenService=game:GetService("TweenService")

local player=Players.LocalPlayer
local R=RS:WaitForChild("CodeRotRemotes")
local mouse=player:GetMouse()

local locales={"ru","en","es","pt","tr"}
local localeNames={ru="RU",en="EN",es="ES",pt="PT",tr="TR"}
local rawLocale=string.lower(LocalizationService.RobloxLocaleId or "en-us")
local lang="en"
for _,code in ipairs(locales) do
    if string.sub(rawLocale,1,#code)==code then lang=code break end
end

local T={
    ru={
        lobby_hint="Выбери класс слева и подойди к воротам ИГРАТЬ",
        objective="ЦЕЛЬ",
        build="СТРОИТЬ",
        delete="УДАЛИТЬ",
        classes="КЛАССЫ",
        bits="Bits",
        close="ЗАКРЫТЬ",
        owned="ВЫБРАТЬ",
        buy="КУПИТЬ",
        room="Комната",
        starts="Старт через",
        memory="ВОСПОМИНАНИЕ",
        content_warning="Предупреждение: в игре есть мигающие эффекты, тревожные сцены и тема утраты.",
        understood="ПОНЯТНО",
        class_Archivist="АРХИВИСТ",
        class_Builder="СТРОИТЕЛЬ",
        class_Debugger="ОТЛАДЧИК",
        class_Guest1337="GUEST 1337",
        desc_Archivist="Легче замечает фрагменты памяти.",
        desc_Builder="Больше лимит строительных деталей.",
        desc_Debugger="Фонарь и немного больше скорости.",
        desc_Guest1337="Очень быстрый, но для рискованных маршрутов.",
    },
    en={
        lobby_hint="Choose a class on the left, then walk to the PLAY gate",
        objective="OBJECTIVE",
        build="BUILD",
        delete="DELETE",
        classes="CLASSES",
        bits="Bits",
        close="CLOSE",
        owned="SELECT",
        buy="BUY",
        room="Room",
        starts="Starts in",
        memory="MEMORY",
        content_warning="Notice: this game contains flashing effects, unsettling scenes and themes of loss.",
        understood="OK",
        class_Archivist="ARCHIVIST",
        class_Builder="BUILDER",
        class_Debugger="DEBUGGER",
        class_Guest1337="GUEST 1337",
        desc_Archivist="Spots memory fragments more easily.",
        desc_Builder="Higher building-part limit.",
        desc_Debugger="A lamp and slightly higher speed.",
        desc_Guest1337="Very fast, intended for risky routes.",
    },
    es={
        lobby_hint="Elige una clase a la izquierda y ve a la puerta JUGAR",
        objective="OBJETIVO",
        build="CONSTRUIR",
        delete="BORRAR",
        classes="CLASES",
        bits="Bits",
        close="CERRAR",
        owned="ELEGIR",
        buy="COMPRAR",
        room="Sala",
        starts="Empieza en",
        memory="RECUERDO",
        content_warning="Aviso: hay destellos, escenas inquietantes y temas de pérdida.",
        understood="ENTENDIDO",
        class_Archivist="ARCHIVISTA",class_Builder="CONSTRUCTOR",class_Debugger="DEPURADOR",class_Guest1337="GUEST 1337",
        desc_Archivist="Detecta recuerdos con más facilidad.",desc_Builder="Puede construir más piezas.",desc_Debugger="Lámpara y algo más de velocidad.",desc_Guest1337="Muy rápido para rutas arriesgadas.",
    },
    pt={
        lobby_hint="Escolha uma classe à esquerda e vá até o portão JOGAR",
        objective="OBJETIVO",
        build="CONSTRUIR",
        delete="APAGAR",
        classes="CLASSES",
        bits="Bits",
        close="FECHAR",
        owned="SELECIONAR",
        buy="COMPRAR",
        room="Sala",
        starts="Começa em",
        memory="MEMÓRIA",
        content_warning="Aviso: há flashes, cenas inquietantes e temas de perda.",
        understood="OK",
        class_Archivist="ARQUIVISTA",class_Builder="CONSTRUTOR",class_Debugger="DEBUGGER",class_Guest1337="GUEST 1337",
        desc_Archivist="Percebe memórias com mais facilidade.",desc_Builder="Limite maior de peças.",desc_Debugger="Lanterna e um pouco mais de velocidade.",desc_Guest1337="Muito rápido para rotas arriscadas.",
    },
    tr={
        lobby_hint="Soldan bir sınıf seç, sonra OYNA kapısına git",
        objective="HEDEF",
        build="İNŞA ET",
        delete="SİL",
        classes="SINIFLAR",
        bits="Bits",
        close="KAPAT",
        owned="SEÇ",
        buy="SATIN AL",
        room="Oda",
        starts="Başlamasına",
        memory="HAFIZA",
        content_warning="Uyarı: yanıp sönen efektler, rahatsız edici sahneler ve kayıp temaları içerir.",
        understood="TAMAM",
        class_Archivist="ARŞİVCİ",class_Builder="İNŞAATÇI",class_Debugger="HATA AYIKLAYICI",class_Guest1337="GUEST 1337",
        desc_Archivist="Hafıza parçalarını daha kolay fark eder.",desc_Builder="Daha fazla parça inşa eder.",desc_Debugger="Lamba ve biraz daha hız.",desc_Guest1337="Riskli yollar için çok hızlı.",
    }
}
local function tr(k)
    local pack=T[lang] or T.en
    return pack[k] or T.en[k] or k
end

local gui=Instance.new("ScreenGui")
gui.Name="CodeRotUI"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=false
gui.Parent=player:WaitForChild("PlayerGui")

local function corner(obj,r)
    local c=Instance.new("UICorner")
    c.CornerRadius=UDim.new(0,r or 10)
    c.Parent=obj
end
local function stroke(obj,trans)
    local s=Instance.new("UIStroke")
    s.Color=Color3.fromRGB(110,113,125)
    s.Transparency=trans or .45
    s.Thickness=1
    s.Parent=obj
end
local function gradient(obj,a,b,rotation)
    local g=Instance.new("UIGradient")
    g.Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,a),
        ColorSequenceKeypoint.new(1,b)
    })
    g.Rotation=rotation or 90
    g.Parent=obj
    return g
end
local function accent(parent,color)
    local a=Instance.new("Frame")
    a.Name="Accent"
    a.Size=UDim2.new(0,4,1,-16)
    a.Position=UDim2.fromOffset(7,8)
    a.BackgroundColor3=color
    a.BorderSizePixel=0
    corner(a,3)
    a.Parent=parent
    return a
end
local function txt(parent,name,text,pos,size,textSize)
    local x=Instance.new("TextLabel")
    x.Name=name
    x.Position=pos
    x.Size=size
    x.BackgroundTransparency=1
    x.TextColor3=Color3.fromRGB(242,240,232)
    x.Font=Enum.Font.GothamMedium
    x.TextSize=textSize or 16
    x.TextWrapped=true
    x.Text=text
    x.Parent=parent
    return x
end
local function panel(parent,name,pos,size)
    local f=Instance.new("Frame")
    f.Name=name
    f.Position=pos
    f.Size=size
    f.BackgroundColor3=Color3.fromRGB(24,26,34)
    f.BackgroundTransparency=.08
    f.BorderSizePixel=0
    corner(f,12)
    stroke(f,.5)
    gradient(f,Color3.fromRGB(33,35,46),Color3.fromRGB(18,20,26),90)
    f.Parent=parent
    return f
end

-- Lobby UI is intentionally minimal.
local lobbyHint=panel(gui,"LobbyHint",UDim2.new(.5,-220,1,-82),UDim2.fromOffset(440,50))
accent(lobbyHint,Color3.fromRGB(232,170,93))
local lobbyHintText=txt(lobbyHint,"Text",tr("lobby_hint"),UDim2.fromOffset(20,5),UDim2.new(1,-34,1,-10),15)
lobbyHintText.TextXAlignment=Enum.TextXAlignment.Left

local topRight=panel(gui,"TopRight",UDim2.new(1,-190,0,12),UDim2.fromOffset(178,44))
accent(topRight,Color3.fromRGB(116,189,137))
local bitsText=txt(topRight,"Bits","0 Bits",UDim2.fromOffset(18,0),UDim2.fromOffset(92,44),15)
bitsText.TextXAlignment=Enum.TextXAlignment.Left
local langButton=Instance.new("TextButton")
langButton.Size=UDim2.fromOffset(54,32)
langButton.Position=UDim2.new(1,-62,.5,-16)
langButton.BackgroundColor3=Color3.fromRGB(69,73,91)
langButton.TextColor3=Color3.fromRGB(255,255,255)
langButton.Font=Enum.Font.GothamBold
langButton.TextSize=15
langButton.Text=localeNames[lang]
corner(langButton,8)
stroke(langButton,.55)
gradient(langButton,Color3.fromRGB(82,88,109),Color3.fromRGB(52,56,70),90)
langButton.Parent=topRight

-- Round HUD.
local chapterBox=panel(gui,"ChapterBox",UDim2.fromOffset(12,12),UDim2.fromOffset(360,52))
accent(chapterBox,Color3.fromRGB(179,93,221))
local chapterText=txt(chapterBox,"Text","2015: CODE ROT",UDim2.fromOffset(20,0),UDim2.new(1,-34,1,0),17)
chapterText.TextXAlignment=Enum.TextXAlignment.Left

local objectiveBox=panel(gui,"ObjectiveBox",UDim2.fromOffset(12,70),UDim2.fromOffset(430,72))
accent(objectiveBox,Color3.fromRGB(95,156,223))
local objectiveHeader=txt(objectiveBox,"Header",tr("objective"),UDim2.fromOffset(20,7),UDim2.fromOffset(130,20),12)
objectiveHeader.TextColor3=Color3.fromRGB(174,178,196)
objectiveHeader.TextXAlignment=Enum.TextXAlignment.Left
local objectiveText=txt(objectiveBox,"Text","",UDim2.fromOffset(20,25),UDim2.new(1,-34,1,-31),15)
objectiveText.TextXAlignment=Enum.TextXAlignment.Left

local timerBox=panel(gui,"TimerBox",UDim2.new(1,-132,0,64),UDim2.fromOffset(120,44))
accent(timerBox,Color3.fromRGB(229,172,91))
local timerText=txt(timerBox,"Text","--:--",UDim2.fromOffset(6,0),UDim2.new(1,-6,1,0),18)

local toastBox=panel(gui,"Toast",UDim2.new(.5,-210,0,150),UDim2.fromOffset(420,64))
accent(toastBox,Color3.fromRGB(192,109,225))
local toastText=txt(toastBox,"Text","",UDim2.fromOffset(20,6),UDim2.new(1,-32,1,-12),15)
toastBox.Visible=false

local function makeActionButton(textValue,x)
    local b=Instance.new("TextButton")
    b.Size=UDim2.fromOffset(98,44)
    b.Position=UDim2.new(1,x,1,-58)
    b.BackgroundColor3=Color3.fromRGB(67,72,87)
    b.TextColor3=Color3.fromRGB(248,248,248)
    b.Font=Enum.Font.GothamBold
    b.TextSize=13
    b.Text=textValue
    b.AutoButtonColor=true
    corner(b,10)
    stroke(b,.45)
    gradient(b,Color3.fromRGB(83,89,108),Color3.fromRGB(49,53,65),90)
    b.Parent=gui
    return b
end
local buildButton=makeActionButton(tr("build"),-212)
local deleteButton=makeActionButton(tr("delete"),-106)

local function refreshBits()
    bitsText.Text=tostring(player:GetAttribute("Bits") or 0).." "..tr("bits")
end
player:GetAttributeChangedSignal("Bits"):Connect(refreshBits)
refreshBits()

local function updateVisibility()
    local inRound=player:GetAttribute("InRound")==true
    chapterBox.Visible=inRound
    objectiveBox.Visible=inRound
    timerBox.Visible=inRound
    lobbyHint.Visible=not inRound
    buildButton.Visible=inRound and UIS.TouchEnabled
    deleteButton.Visible=inRound and UIS.TouchEnabled
end
player:GetAttributeChangedSignal("InRound"):Connect(updateVisibility)
updateVisibility()

local function say(message,duration)
    toastText.Text=tostring(message)
    toastBox.Visible=true
    toastBox.BackgroundTransparency=.15
    toastText.TextTransparency=0
    task.delay(duration or 3,function()
        if toastText.Text==tostring(message) then
            TweenService:Create(toastBox,TweenInfo.new(.25),{BackgroundTransparency=1}):Play()
            TweenService:Create(toastText,TweenInfo.new(.25),{TextTransparency=1}):Play()
            task.delay(.28,function()
                if toastText.Text==tostring(message) then toastBox.Visible=false end
            end)
        end
    end)
end

local function worldPoint()
    if mouse.Target then return mouse.Hit.Position end
    local char=player.Character
    local root=char and char:FindFirstChild("HumanoidRootPart")
    return root and (root.Position+root.CFrame.LookVector*10) or nil
end
local function place()
    if not player:GetAttribute("InRound") then return end
    local p=worldPoint()
    if p then R.BuildPlace:FireServer(p,Vector3.new(0,1,0)) end
end
local function remove()
    if player:GetAttribute("InRound") and mouse.Target then
        R.BuildDelete:FireServer(mouse.Target)
    end
end
buildButton.Activated:Connect(place)
deleteButton.Activated:Connect(remove)
UIS.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode==Enum.KeyCode.B then place()
    elseif i.KeyCode==Enum.KeyCode.X then remove() end
end)

local classFrame=nil
local function openClassMenu(classes,data)
    if classFrame then classFrame:Destroy() end
    classFrame=panel(gui,"ClassMenu",UDim2.new(.5,-250,.5,-210),UDim2.fromOffset(500,420))
    accent(classFrame,Color3.fromRGB(167,104,218))

    local title=txt(classFrame,"Title",tr("classes"),UDim2.fromOffset(24,12),UDim2.new(1,-106,0,36),24)
    title.TextXAlignment=Enum.TextXAlignment.Left

    local close=Instance.new("TextButton")
    close.Size=UDim2.fromOffset(70,34)
    close.Position=UDim2.new(1,-82,0,12)
    close.BackgroundColor3=Color3.fromRGB(69,56,61)
    close.TextColor3=Color3.new(1,1,1)
    close.Font=Enum.Font.GothamBold
    close.TextSize=12
    close.Text=tr("close")
    corner(close,8)
    close.Parent=classFrame
    close.Activated:Connect(function() classFrame:Destroy(); classFrame=nil end)

    local order={"Archivist","Builder","Debugger","Guest1337"}
    local y=58
    for _,name in ipairs(order) do
        local info=classes[name]
        if info then
            local card=panel(classFrame,name,UDim2.fromOffset(14,y),UDim2.new(1,-28,0,76))
            card.BackgroundTransparency=.03
            local classColors={
                Archivist=Color3.fromRGB(170,129,214),
                Builder=Color3.fromRGB(222,165,84),
                Debugger=Color3.fromRGB(93,168,225),
                Guest1337=Color3.fromRGB(111,205,139),
            }
            accent(card,classColors[name] or Color3.fromRGB(160,160,175))
            local nameLabel=txt(card,"Name",tr("class_"..name),UDim2.fromOffset(20,8),UDim2.new(1,-138,0,24),17)
            nameLabel.TextXAlignment=Enum.TextXAlignment.Left
            local desc=txt(card,"Desc",tr("desc_"..name),UDim2.fromOffset(20,31),UDim2.new(1,-138,0,35),13)
            desc.TextColor3=Color3.fromRGB(188,191,202)
            desc.TextXAlignment=Enum.TextXAlignment.Left

            local owned=data and data.ownedClasses and data.ownedClasses[name]
            local action=Instance.new("TextButton")
            action.Size=UDim2.fromOffset(104,44)
            action.Position=UDim2.new(1,-116,.5,-22)
            action.BackgroundColor3=owned and Color3.fromRGB(63,101,75) or Color3.fromRGB(91,74,54)
            action.TextColor3=Color3.new(1,1,1)
            action.Font=Enum.Font.GothamBold
            action.TextSize=12
            action.Text=owned and tr("owned") or (tr("buy").."\n"..tostring(info.price).." Bits")
            corner(action,8)
            stroke(action,.55)
            gradient(action,owned and Color3.fromRGB(76,122,91) or Color3.fromRGB(111,86,60),owned and Color3.fromRGB(52,87,65) or Color3.fromRGB(73,59,47),90)
            action.Parent=card
            action.Activated:Connect(function()
                R.ClassAction:FireServer(owned and "Select" or "Buy",name)
            end)
            y+=84
        end
    end
end

local function refreshLanguage()
    langButton.Text=localeNames[lang]
    lobbyHintText.Text=tr("lobby_hint")
    objectiveHeader.Text=tr("objective")
    buildButton.Text=tr("build")
    deleteButton.Text=tr("delete")
    refreshBits()
    if classFrame then classFrame:Destroy(); classFrame=nil end
end

langButton.Activated:Connect(function()
    local idx=table.find(locales,lang) or 1
    idx=(idx % #locales)+1
    lang=locales[idx]
    refreshLanguage()
end)

R.Toast.OnClientEvent:Connect(function(msg) say(msg,3) end)
R.RoundTime.OnClientEvent:Connect(function(s)
    s=math.max(0,tonumber(s) or 0)
    timerText.Text=string.format("%02d:%02d",math.floor(s/60),s%60)
end)
R.Objective.OnClientEvent:Connect(function(t)
    objectiveText.Text=tostring(t)
end)
R.ChapterChanged.OnClientEvent:Connect(function(id,total,title,subtitle,intro)
    chapterText.Text=string.format("%d/%d  %s",id,total,tostring(title))
    say(tostring(subtitle).."\n"..tostring(intro),5)
    updateVisibility()
end)
R.ChapterCompleted.OnClientEvent:Connect(function(_,title)
    say("✓ "..tostring(title),4)
end)
R.WorldPulse.OnClientEvent:Connect(function(stage,msg)
    say("#"..tostring(stage).."  "..tostring(msg),4)
end)
R.Countdown.OnClientEvent:Connect(function(n)
    if tonumber(n) and n>0 then say(tr("starts").." "..tostring(n),1) end
end)
R.RoomState.OnClientEvent:Connect(function(state)
    if not player:GetAttribute("InRound") and state and state.members and #state.members>0 then
        lobbyHintText.Text=tr("room")..": "..table.concat(state.members,", ")
    elseif not player:GetAttribute("InRound") then
        lobbyHintText.Text=tr("lobby_hint")
    end
end)
R.OpenClassMenu.OnClientEvent:Connect(openClassMenu)

R.MemoryFlash.OnClientEvent:Connect(function(index,info)
    local overlay=Instance.new("Frame")
    overlay.Size=UDim2.fromScale(1,1)
    overlay.BackgroundColor3=Color3.fromRGB(242,237,224)
    overlay.BackgroundTransparency=.05
    overlay.ZIndex=20
    overlay.Parent=gui

    local card=panel(overlay,"MemoryCard",UDim2.new(.5,-260,.5,-125),UDim2.fromOffset(520,250))
    card.ZIndex=21
    local h=txt(card,"Header",tr("memory").." "..tostring(index),UDim2.fromOffset(20,18),UDim2.new(1,-40,0,30),18)
    h.ZIndex=22
    local body=txt(card,"Body",(info and info.text) or "",UDim2.fromOffset(20,60),UDim2.new(1,-40,1,-80),18)
    body.ZIndex=22
    task.wait(index==5 and 7 or 4)
    overlay:Destroy()
end)

R.FinalSequence.OnClientEvent:Connect(function()
    say("ROLLBACK_2015.BAT",6)
end)

-- Compact first-session warning instead of a full-screen wall of text.
task.delay(1,function()
    if gui:FindFirstChild("WarningCard") then return end
    local w=panel(gui,"WarningCard",UDim2.new(.5,-230,.5,-100),UDim2.fromOffset(460,200))
    accent(w,Color3.fromRGB(223,154,84))
    local wt=txt(w,"Text",tr("content_warning"),UDim2.fromOffset(28,20),UDim2.new(1,-48,0,105),17)
    local ok=Instance.new("TextButton")
    ok.Size=UDim2.fromOffset(130,42)
    ok.Position=UDim2.new(.5,-65,1,-58)
    ok.BackgroundColor3=Color3.fromRGB(67,92,74)
    ok.TextColor3=Color3.new(1,1,1)
    ok.Font=Enum.Font.GothamBold
    ok.TextSize=13
    ok.Text=tr("understood")
    corner(ok,9)
    stroke(ok,.55)
    gradient(ok,Color3.fromRGB(82,113,91),Color3.fromRGB(52,76,61),90)
    ok.Parent=w
    ok.Activated:Connect(function() w:Destroy() end)
end)
