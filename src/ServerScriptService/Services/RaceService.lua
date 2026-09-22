local Config=require(game:GetService("ReplicatedStorage").Shared.Config)
local Race={}; Race.__index=Race
function Race.new(ride,data,R)
    local self=setmetatable({ride=ride,data=data,R=R,queue={},active=nil,nextStart=workspace:GetServerTimeNow()+Config.RACE_INTERVAL,serial=0},Race)
    ride.onFinish=function(player,id,seconds) self:Finish(player,id,seconds) end
    return self
end
function Race:Join(player)
    if self.active then return "Гонка уже идёт. Дождись следующей." end
    if self.ride.states[player] then return "Сначала вернись с трассы" end
    if self.queue[player] then self.queue[player]=nil; return "Ты вышел из очереди" end
    self.queue[player]=true; return "Ты в очереди. Минимум два гонщика." 
end
function Race:Status(player)
    local count=0; for _ in pairs(self.queue) do count+=1 end
    return {queued=self.queue[player]==true,count=count,nextStart=self.nextStart,active=self.active~=nil,
        remaining=self.active and math.max(0,self.active.deadline-workspace:GetServerTimeNow()) or 0,
        results=self.active and self.active.results or {}}
end
function Race:Update()
    local now=workspace:GetServerTimeNow()
    if self.active then
        local remaining=false
        for p in pairs(self.active.players) do
            local s=self.ride.states[p]
            if s and s.raceId==self.active.id then remaining=true end
        end
        if not remaining or now>=self.active.deadline then
            for p in pairs(self.active.players) do
                local s=self.ride.states[p]
                if s and s.raceId==self.active.id then self.ride:Stop(p,true); self.R.Toast:FireClient(p,"Время гонки истекло") end
            end
            self.active=nil; self.nextStart=now+Config.RACE_INTERVAL
        end
        return
    end
    if now<self.nextStart then return end
    local entrants={}
    for p in pairs(self.queue) do if p.Parent and self.data:Get(p) and not self.ride.states[p] then table.insert(entrants,p) end end
    if #entrants<2 then
        self.nextStart=now+30
        for _,p in ipairs(entrants) do self.R.Toast:FireClient(p,"Ждём второго гонщика. Следующая проверка через 30 секунд.") end
        return
    end
    table.sort(entrants,function(a,b) return a.UserId<b.UserId end)
    self.serial+=1; local id=self.serial
    self.active={id=id,players={},results={},deadline=now+5+Config.RACE_DURATION}
    self.queue={}
    for _,p in ipairs(entrants) do
        if self.ride:Start(p,1,false,id,now+5) then
            self.active.players[p]=true
            -- Identical performance for races, regardless of purchases.
            self.ride.states[p].stats=Config.GetBikeStats("BMX",1)
        end
    end
end
function Race:Finish(player,id,seconds)
    local race=self.active
    if not race or id~=race.id or not race.players[player] then return end
    race.players[player]=nil
    local rank=#race.results+1
    table.insert(race.results,{rank=rank,name=player.DisplayName,seconds=seconds})
    local p=self.data:Get(player)
    if p then p.coins+=math.max(75,350-(rank-1)*75); self.data:Sync(player) end
    self.R.Toast:FireClient(player,"Финиш в гонке: место "..rank)
end
function Race:Remove(player)
    self.queue[player]=nil
    if self.active then self.active.players[player]=nil end
end
return Race
