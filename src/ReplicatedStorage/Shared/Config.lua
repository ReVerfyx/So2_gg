local Config = {}

Config.GAME_TITLE = "CITY RUSH"

Config.LANES = {-8, 0, 8}
Config.START_Z = 24
Config.BASE_SPEED = 27
Config.MAX_SPEED = 50
Config.SPEED_PER_250 = 1.15
Config.SEGMENT_LENGTH = 60
Config.INITIAL_SEGMENTS = 70
Config.GENERATE_BATCH = 24
Config.TRACK_WIDTH = 30
Config.COIN_VALUE = 1
Config.RATING_DIVISOR = 85

Config.LOBBY_CENTER = Vector3.new(500, 0, 20)
Config.LOBBY_SPAWN = Vector3.new(500, 5, 15)
Config.SHOWROOM_CENTER = Vector3.new(500, 0, 245)
Config.MAX_GARAGES = 11
Config.LOBBY_MUSIC_ID = "rbxassetid://9046863579"

Config.BIKE_MAX_LEVEL = 10
Config.BIKE_LEVEL_SPEED = 0.32
Config.BIKE_LEVEL_COIN_BONUS = 0.05

Config.BIKES = {
    BMX = {
        displayName = "BMX",
        price = 0,
        upgradeBase = 120,
        speedBonus = 0,
        shield = 0,
        color = Color3.fromRGB(255, 174, 66),
        accent = Color3.fromRGB(255, 226, 122),
        wheelSize = 2.9,
        description = "Манёвренный стартовый BMX.",
    },
    Street = {
        displayName = "STREET",
        price = 650,
        upgradeBase = 280,
        speedBonus = 1.5,
        shield = 0,
        color = Color3.fromRGB(70, 162, 255),
        accent = Color3.fromRGB(150, 218, 255),
        wheelSize = 3.2,
        description = "Городской велик для скорости.",
    },
    Neon = {
        displayName = "NEON",
        price = 2200,
        upgradeBase = 650,
        speedBonus = 2.5,
        shield = 1,
        color = Color3.fromRGB(223, 75, 255),
        accent = Color3.fromRGB(104, 236, 255),
        wheelSize = 3.25,
        description = "Неоновый байк с защитой.",
    },
    Carbon = {
        displayName = "CARBON",
        price = 6000,
        upgradeBase = 1400,
        speedBonus = 4,
        shield = 1,
        color = Color3.fromRGB(71, 78, 91),
        accent = Color3.fromRGB(95, 255, 174),
        wheelSize = 3.4,
        description = "Топовый карбоновый велосипед.",
    },
}

function Config.GetUpgradeCost(bikeName, level)
    local info = Config.BIKES[bikeName]
    if not info then return math.huge end
    level = math.clamp(tonumber(level) or 1, 1, Config.BIKE_MAX_LEVEL)
    return math.floor(info.upgradeBase * (1.5 ^ (level - 1)))
end

function Config.GetBikeStats(bikeName, level)
    local info = Config.BIKES[bikeName] or Config.BIKES.BMX
    level = math.clamp(tonumber(level) or 1, 1, Config.BIKE_MAX_LEVEL)
    return {
        speedBonus = info.speedBonus + (level - 1) * Config.BIKE_LEVEL_SPEED,
        shield = info.shield + math.floor((level - 1) / 5),
        coinBonus = (level - 1) * Config.BIKE_LEVEL_COIN_BONUS,
    }
end

return Config
