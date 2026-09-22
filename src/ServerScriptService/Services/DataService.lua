local DSS=game:GetService("DataStoreService")
local Http=game:GetService("HttpService")
local Shared=game:GetService("ReplicatedStorage").Shared
local Config=require(Shared.Config)
local Economy=require(Shared.Economy)
local Data={}; Data.__index=Data
local function default()
    return {version=3,coins=0,rating=0,equippedBike="BMX",ownedBikes={BMX=true},bikeLevels={BMX=1},unlocked=1,
        completed={},bestTimes={},medals={},lastDaily=0,streak=0,checkpoints={},settings={music=true,reducedMotion=false}}
end
local function number(value,low,high)
    if type(value)~="number" or value~=value then return low end
    return math.clamp(math.floor(value),low,high)
end
local function normalize(raw)
    local p=default()
    if type(raw)~="table" then return p end
    p.coins=number(raw.coins,0,1000000000); p.rating=number(raw.rating,0,1000000000)
    p.unlocked=number(raw.unlocked,1,#Config.WORLDS)
    for _,name in ipairs(Config.BIKE_ORDER) do
        if type(raw.ownedBikes)=="table" and raw.ownedBikes[name]==true then p.ownedBikes[name]=true end
        if p.ownedBikes[name] then p.bikeLevels[name]=number(type(raw.bikeLevels)=="table" and raw.bikeLevels[name],1,Config.BIKE_MAX_LEVEL) end
    end
    if p.ownedBikes[raw.equippedBike] then p.equippedBike=raw.equippedBike end
    for i=1,#Config.WORLDS do
        local k=tostring(i)
        for _,field in ipairs({"bestTimes","medals","checkpoints"}) do
            if type(raw[field])=="table" and type(raw[field][k])=="number" then
                if field=="bestTimes" then
                    local t=raw[field][k]
                    if t==t and t>0 and t<=86400 then p[field][k]=t end
                else
                    p[field][k]=number(raw[field][k],0,field=="medals" and 3 or 11)
                end
            end
        end
        if type(raw.completed)=="table" and raw.completed[k]==true then p.completed[k]=true end
    end
    p.lastDaily=number(raw.lastDaily,0,1000000); p.streak=number(raw.streak,0,7)
    if type(raw.settings)=="table" then
        p.settings.music=raw.settings.music~=false; p.settings.reducedMotion=raw.settings.reducedMotion==true
    end
    return p
end
function Data.new()
    return setmetatable({store=DSS:GetDataStore("CityRush_PlayerData_v3"),legacy=DSS:GetDataStore("CityRush_PlayerData_v2"),
        oldest=DSS:GetDataStore("CityRush_PlayerData_v1"),ranking=DSS:GetOrderedDataStore("CityRush_BikeRating_v3"),
        profiles={},sessions={},busy={},tops={},token=game.JobId..Http:GenerateGUID(false)},Data)
end
function Data:Load(player)
    local key="u_"..player.UserId
    local ok,record
    for attempt=1,3 do
        ok,record=pcall(function()
            return self.store:UpdateAsync(key,function(old)
                old=type(old)=="table" and old or {}
                if old.lock and old.lock.token~=self.token and old.lock.expires>os.time() then return nil end
                old.lock={token=self.token,expires=os.time()+180}
                return old
            end)
        end)
        if ok and record then break end
        task.wait(attempt)
    end
    if not ok or not record then
        player:Kick("Профиль пока недоступен. Подожди минуту и войди снова — прогресс сохранён.")
        return nil
    end
    local raw=record.profile
    if not raw then
        local migrated,legacy=pcall(function() return self.legacy:GetAsync(key) end)
        if migrated and legacy==nil then migrated,legacy=pcall(function() return self.oldest:GetAsync(key) end) end
        if not migrated then
            pcall(function() self.store:UpdateAsync(key,function(old)
                if old and old.lock and old.lock.token==self.token then old.lock=nil; return old end
                return nil
            end) end)
            player:Kick("Не удалось загрузить старое сохранение. Попробуй позже.")
            return nil
        end
        raw=legacy
    end
    self.profiles[player]=normalize(raw); self.sessions[player]=true
    local stats=Instance.new("Folder"); stats.Name="leaderstats"; stats.Parent=player
    local rating=Instance.new("IntValue"); rating.Name="Rating"; rating.Parent=stats
    self:Sync(player)
    return self.profiles[player]
end
function Data:Get(player) return self.profiles[player] end
function Data:Sync(player)
    local p=self:Get(player); if not p then return end
    player:SetAttribute("Coins",p.coins); player:SetAttribute("Rating",p.rating)
    player:SetAttribute("EquippedBike",p.equippedBike); player:SetAttribute("BikeLevel",p.bikeLevels[p.equippedBike])
    player:SetAttribute("UnlockedWorld",p.unlocked)
    if player:FindFirstChild("leaderstats") then player.leaderstats.Rating.Value=p.rating end
end
function Data:Public(player)
    local p=self:Get(player)
    return p and Http:JSONDecode(Http:JSONEncode(p)) or nil
end
function Data:Bike(player,action,name)
    local p=self:Get(player); local b=Config.BIKES[name]
    if not p or not b then return "Велосипед не найден" end
    if action=="Upgrade" then
        if not p.ownedBikes[name] then return "Сначала купи велосипед" end
        local level=p.bikeLevels[name]
        if level>=Config.BIKE_MAX_LEVEL then return "Максимальный уровень" end
        local cost=Config.GetUpgradeCost(name,level)
        if p.coins<cost then return "Не хватает монет" end
        p.coins-=cost; p.bikeLevels[name]+=1
    elseif action=="Select" then
        if not p.ownedBikes[name] then
            if p.coins<b.price then return "Не хватает монет" end
            p.coins-=b.price; p.ownedBikes[name]=true; p.bikeLevels[name]=1
        end
        p.equippedBike=name
    else return "Неизвестное действие" end
    self:Sync(player); return "Гараж обновлён"
end
function Data:Daily(player)
    local p=self:Get(player); if not p then return end
    local day=math.floor(os.time()/86400)
    local streak=Economy.daily(day,p.lastDaily,p.streak)
    if not streak then return "Сегодня награда уже получена" end
    p.lastDaily=day; p.streak=streak; p.coins+=Config.DAILY_REWARDS[streak]
    self:Sync(player); return "+"..Config.DAILY_REWARDS[streak].." монет · день "..streak
end
function Data:Finish(player,world,seconds,ranked)
    local p=self:Get(player); if not p then return 0 end
    -- Resumed runs unlock worlds and earn coins, but cannot set time records.
    local reward,first
    if ranked then reward,first=Economy.finish(p,world,seconds,Config.WORLDS[world])
    else
        local k=tostring(world); first=not p.completed[k]
        p.completed[k]=true; p.unlocked=math.max(p.unlocked,math.min(#Config.WORLDS,world+1))
        reward=Config.WORLDS[world].reward*(first and 2 or 1)
        p.coins+=reward; p.rating+=first and 100 or 20
    end
    p.checkpoints[tostring(world)]=0
    self:Sync(player)
    return reward,first
end
function Data:Save(player,release)
    if self.busy[player] then
        if not release then return false end
        local deadline=os.clock()+12
        repeat task.wait(.1) until not self.busy[player] or os.clock()>deadline
        if self.busy[player] then return false end
    end
    local p=self:Get(player); if not p or not self.sessions[player] then return false end
    self.busy[player]=true
    local snapshot=self:Public(player)
    local ok,result
    for attempt=1,3 do
        ok,result=pcall(function()
            return self.store:UpdateAsync("u_"..player.UserId,function(old)
                if not old or not old.lock or old.lock.token~=self.token then return nil end
                return {profile=snapshot,lock=not release and {token=self.token,expires=os.time()+180} or nil}
            end)
        end)
        if ok then break end
        task.wait(attempt)
    end
    self.busy[player]=nil
    if ok and result then
        if release then self.sessions[player]=nil end
        player:SetAttribute("SaveWarning",false)
        task.spawn(function() pcall(function() self.ranking:SetAsync(tostring(player.UserId),snapshot.rating) end) end)
        return true
    end
    player:SetAttribute("SaveWarning",true)
    warn("CITY RUSH profile save failed",player.UserId)
    if ok and not result then
        self.sessions[player]=nil
        player:Kick("Сессия сохранения закрыта. Войди снова.")
    end
    return false
end
function Data:Top()
    if self.topTime and os.clock()-self.topTime<60 then return self.tops end
    if self.topBusy then return self.tops end
    self.topBusy=true
    local ok,pages=pcall(function() return self.ranking:GetSortedAsync(false,10) end)
    if ok then
        local rows={}
        for rank,item in ipairs(pages:GetCurrentPage()) do
            local name="Rider "..item.key
            pcall(function() name=game:GetService("Players"):GetNameFromUserIdAsync(tonumber(item.key)) end)
            table.insert(rows,{rank=rank,name=name,rating=item.value})
        end
        self.tops=rows; self.topTime=os.clock()
    end
    self.topBusy=false
    return self.tops
end
function Data:Remove(player)
    self:Save(player,true); self.profiles[player]=nil; self.sessions[player]=nil
end
return Data
