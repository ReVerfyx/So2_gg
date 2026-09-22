local C = {}
C.GAME_TITLE = "CITY RUSH"
C.MAX_GARAGES = 11
C.LOBBY_SPAWN = Vector3.new(0, 5, 36)
C.BIKE_MAX_LEVEL = 5
C.BIKE_ORDER = {"BMX", "Street", "Trail", "Neon", "Carbon", "Apex"}
C.BIKES = {
    BMX = {displayName="ORIGIN / BMX", price=0, upgradeBase=180, speed=34, acceleration=22, handling=2.1, color=Color3.fromRGB(255,153,77), accent=Color3.fromRGB(255,220,150)},
    Street = {displayName="METRO / STREET", price=900, upgradeBase=260, speed=38, acceleration=24, handling=2, color=Color3.fromRGB(75,164,242), accent=Color3.fromRGB(166,230,255)},
    Trail = {displayName="TERRA / TRAIL", price=1800, upgradeBase=350, speed=35, acceleration=27, handling=2.5, color=Color3.fromRGB(100,203,157), accent=Color3.fromRGB(212,255,152)},
    Neon = {displayName="PULSE / NEON", price=3500, upgradeBase=500, speed=40, acceleration=25, handling=2.2, color=Color3.fromRGB(180,110,244), accent=Color3.fromRGB(106,242,237)},
    Carbon = {displayName="MONO / CARBON", price=6000, upgradeBase=700, speed=43, acceleration=27, handling=2.2, color=Color3.fromRGB(53,64,79), accent=Color3.fromRGB(255,198,91)},
    Apex = {displayName="APEX / RACING", price=9500, upgradeBase=900, speed=45, acceleration=29, handling=2.4, color=Color3.fromRGB(247,102,129), accent=Color3.fromRGB(255,230,222)},
}
C.WORLDS = {
    {id="Coast", name="COASTLINE", subtitle="Набережная и крыши", color=Color3.fromRGB(74,207,192), origin=Vector3.new(0,30,-500), reward=300, medals={150,220,330}},
    {id="Garden", name="SKY GARDENS", subtitle="Сады над облаками", color=Color3.fromRGB(173,148,242), origin=Vector3.new(1800,85,-500), reward=450, medals={170,250,370}},
    {id="Metro", name="AFTERHOURS", subtitle="Ночной мегаполис", color=Color3.fromRGB(255,143,116), origin=Vector3.new(3600,130,-500), reward=600, medals={190,280,410}},
}
C.DAILY_REWARDS = {100,150,200,250,300,400,600}
C.RACE_INTERVAL = 150
C.RACE_DURATION = 420
C.MUSIC_ID = "" -- Only set an audio asset owned/licensed by this experience.
function C.GetUpgradeCost(name, level)
    return math.floor(C.BIKES[name].upgradeBase * 1.65 ^ (level-1))
end
function C.GetBikeStats(name, level)
    local b=C.BIKES[name] or C.BIKES.BMX
    level=math.clamp(level or 1,1,C.BIKE_MAX_LEVEL)
    return {speed=b.speed+(level-1)*.8, acceleration=b.acceleration+(level-1)*1.2, handling=b.handling, jump=38}
end
return C
