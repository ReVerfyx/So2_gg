-- Server motion allowance for native, client-owned Humanoid replication.
local Rules={}
function Rules.motion(credit,distance,dt,speed)
    if distance~=distance or distance==math.huge or distance<0 then return credit,false end
    local ceiling=speed*.8+8
    local nextCredit=math.min(ceiling,credit+math.max(0,dt)*speed*1.4)
    if distance>nextCredit then return nextCredit,false end
    return nextCredit-distance,true
end
return Rules
