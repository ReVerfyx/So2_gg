-- Executed against the production modules by tools/test_luau.py.
local passed=0
local function check(value, message)
    assert(value,message); passed+=1
end
check(Economy.daily(100,100,3)==nil,"No double daily claim")
check(Economy.daily(101,100,7)==1,"Weekly streak wraps")
check(Economy.daily(103,100,4)==1,"Missed day resets streak")
check(Economy.daily(101,100,4)==5,"Consecutive claim increments streak")
check(Economy.daily(100,101,4)==nil,"Clock rollback cannot grant reward")
check(Economy.medal(150,{150,220,330})==3,"Gold boundary inclusive")
check(Economy.medal(150.01,{150,220,330})==2,"Silver boundary")
check(Economy.medal(331,{150,220,330})==0,"No automatic medal")
local p={bestTimes={},medals={},completed={},unlocked=1,coins=0,rating=0}
local reward,first=Economy.finish(p,1,180,Config.WORLDS[1])
check(first and reward==600 and p.coins==600,"First finish reward")
check(p.unlocked==2 and p.rating==100,"Unlock next world")
Economy.finish(p,1,240,Config.WORLDS[1])
check(p.bestTimes['1']==180 and p.medals['1']==2,"Slower time never erases record or medal")
check(p.coins==900 and p.rating==120,"Replay has smaller reward")
Economy.finish(p,3,100,Config.WORLDS[3])
check(p.unlocked==3,"No nonexistent fourth world")
for _,world in ipairs(Config.WORLDS) do
    local course=Courses[world.id]
    check(#course==12,"Every world has twelve stages")
    for _,s in ipairs(course) do
        check(s.width>=6 and s.length>=80,"Bike clearance and section length")
        check(math.abs(s.rise/s.length)<.26,"Climb slopes within controller budget")
        if s.kind=='gaps' then
            local step=s.length/math.ceil(s.length/8)
            local jumpRange=Config.BIKES.BMX.speed*(2*38/140)
            check(jumpRange>step+5,"Starter bike clears every designed gap with margin")
        end
    end
end
local function player(id)
    local p={UserId=id,attrs={}}
    function p:SetAttribute(k,v) self.attrs[k]=v end
    function p:FindFirstChild(k) return self[k] end
    function p:Kick(message) self.kicked=message end
    return p
end
local storeData={}
local failReads=false
local store={}
function store:GetAsync(key) if failReads then error('outage') end; return storeData[key] end
function store:UpdateAsync(key,fn)
    if failReads then error('outage') end
    local v=fn(deepcopy(storeData[key])); if v then storeData[key]=deepcopy(v) end; return v
end
local function data()
    local d=Data.new(); d.store=store; d.legacy={GetAsync=function() return nil end}; d.oldest=d.legacy; return d
end
local d=data(); local u=player(1)
d:Load(u)
check(d:Get(u).ownedBikes.BMX and d:Get(u).bikeLevels.BMX==1,"Default profile owns BMX")
d:Bike(u,'Select','Carbon')
check(d:Get(u).coins==0 and d:Get(u).equippedBike=='BMX',"Cannot buy without coins")
d:Get(u).coins=10000
d:Bike(u,'Select','Carbon')
check(d:Get(u).coins==4000 and d:Get(u).ownedBikes.Carbon,"Purchase deducts exact price")
d:Bike(u,'Select','Carbon')
check(d:Get(u).coins==4000,"Equipping never charges again")
d:Bike(u,'Upgrade','Carbon')
check(d:Get(u).bikeLevels.Carbon==2 and d:Get(u).coins==3300,"Upgrade applies once")
d:Daily(u); local coins=d:Get(u).coins; d:Daily(u)
check(d:Get(u).coins==coins,"Repeated daily remote cannot duplicate reward")
d:Get(u).bestTimes['1']=134.25
d:Save(u,true)
check(storeData.u_1.lock==nil,"Release removes lock")
local d2=data(); d2:Load(u)
check(d2:Get(u).bestTimes['1']==134.25,"Fractional times survive reconnect")
check(d2:Get(u).coins==coins,"Currency survives reconnect")
local d3=data(); d3.token='another-server'; local second=player(1); d3:Load(second)
check(second.kicked~=nil and d3:Get(second)==nil,"Concurrent session rejected")
storeData.u_1.lock.token='new-session'
local oldCoins=storeData.u_1.profile.coins
d2:Get(u).coins=123456; d2:Save(u,false)
check(storeData.u_1.profile.coins==oldCoins,"Stale session cannot overwrite profile")
failReads=true
local outage=data(); local o=player(8); outage:Load(o)
check(o.kicked~=nil and outage:Get(o)==nil,"Outage does not load/save defaults")
failReads=false
local legacy=data(); local l=player(9)
legacy.legacy={GetAsync=function() return {coins=456,equippedBike='Neon',ownedBikes={Neon=true},bikeLevels={Neon=10}} end}
legacy:Load(l)
check(legacy:Get(l).coins==456 and legacy:Get(l).equippedBike=='Neon',"Legacy wallet and bikes migrate")
check(legacy:Get(l).bikeLevels.Neon==5,"Legacy level clamped to new maximum")
local bad=data(); local b=player(10)
bad.legacy={GetAsync=function() error('legacy down') end}; bad:Load(b)
check(b.kicked~=nil and bad:Get(b)==nil and storeData.u_10.lock==nil,"Legacy outage releases reservation without erasing progress")
print('PASS: '..passed..' rules, route and persistence checks')
