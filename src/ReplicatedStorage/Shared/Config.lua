local Config = {}

Config.GAME_TITLE = "CITY RUSH"
Config.LANES = {-8, 0, 8}
Config.START_Z = 24
Config.BASE_SPEED = 27
Config.MAX_SPEED = 48
Config.SPEED_PER_250 = 1.15
Config.SEGMENT_LENGTH = 60
Config.INITIAL_SEGMENTS = 80
Config.GENERATE_BATCH = 30
Config.TRACK_WIDTH = 30
Config.COIN_VALUE = 1
Config.RATING_DIVISOR = 85

Config.BIKES = {
    BMX = {
        displayName = "BMX",
        price = 0,
        speedBonus = 0,
        shield = 0,
        color = Color3.fromRGB(255, 174, 66),
        description = "Лёгкий стартовый велик.",
    },
    Street = {
        displayName = "STREET",
        price = 650,
        speedBonus = 1.5,
        shield = 0,
        color = Color3.fromRGB(70, 162, 255),
        description = "+1.5 скорости.",
    },
    Neon = {
        displayName = "NEON",
        price = 2200,
        speedBonus = 2.5,
        shield = 1,
        color = Color3.fromRGB(223, 75, 255),
        description = "+2.5 скорости и 1 защита.",
    },
    Carbon = {
        displayName = "CARBON",
        price = 6000,
        speedBonus = 4,
        shield = 1,
        color = Color3.fromRGB(95, 255, 174),
        description = "+4 скорости и 1 защита.",
    },
}

return Config
