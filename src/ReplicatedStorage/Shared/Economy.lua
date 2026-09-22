-- Pure rules, shared with automated tests. Call mutations on the server only.
local E={}
function E.daily(day,last,streak)
    if last>=day then return nil end
    return last==day-1 and (streak%7)+1 or 1
end
function E.medal(seconds, thresholds)
    for rank,limit in ipairs(thresholds) do if seconds<=limit then return 4-rank end end
    return 0
end
function E.finish(profile, world, seconds, config)
    local key=tostring(world)
    local old=profile.bestTimes[key]
    profile.bestTimes[key]=old and math.min(old,seconds) or seconds
    profile.medals[key]=math.max(profile.medals[key] or 0,E.medal(seconds,config.medals))
    local first=not profile.completed[key]
    profile.completed[key]=true
    profile.unlocked=math.max(profile.unlocked,math.min(3,world+1))
    local reward=config.reward+(first and config.reward or 0)
    profile.coins+=reward
    profile.rating+=first and 100 or 20
    return reward,first
end
return E
