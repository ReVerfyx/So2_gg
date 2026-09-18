local Config = {}

Config.GAME_TITLE = "2015: CODE ROT"
Config.LOBBY_COUNTDOWN = 20
Config.INTERMISSION = 12
Config.MAX_BUILD_PARTS = 70
Config.BUILD_GRID = 4
Config.BUILD_RANGE = 48
Config.BUILD_SURVIVAL_CHANCE = 0.52
Config.WORLD_UPDATE_INTERVAL = 180 -- every 3 minutes
Config.BITS_PER_OBJECTIVE = 35
Config.BITS_CHAPTER = 180
Config.BITS_CAMPAIGN = 1200
Config.BITS_MEMORY = 40
Config.MEMORY_COUNT = 5

-- The ten chapter timers total 450 minutes = 7.5 hours.
-- Experienced players can finish somewhat faster because objectives can be solved before a timer expires,
-- but pulse-gates stop the whole campaign from becoming a 20-minute speedrun.
Config.CHAPTERS = {
    {
        id = 1, title = "ГЛАВА I — JOIN", subtitle = "Пригород, который помнит тебя", map = "Suburb",
        duration = 42 * 60, minPulseForExit = 12,
        intro = "Сервер 2015 года загружается не полностью. Найди, что удерживает район в памяти.",
        enemy = {name = "NULL_USER", speed = 12, damage = 28, spawnPulse = 2, count = 1},
        tasks = {
            {label = "Перезапусти домашние роутеры", action = "Reboot", object = "Old Router", count = 4, gatePulse = 0},
            {label = "Собери потерянные куски карты", action = "Recover", object = "Map Fragment", count = 5, gatePulse = 4},
            {label = "Открой школьный серверный шкаф", action = "Unlock", object = "Server Cabinet", count = 2, gatePulse = 8},
            {label = "Доберись до EXIT-терминала", action = "Leave 2015", object = "Exit Terminal", count = 1, gatePulse = 12},
        },
        eggs = {
            {name="TixPile", text="Под ковром лежат Tix. Они уже ничего не покупают, но почему-то тёплые.", reward=18},
            {name="OldMailbox", text="Непрочитанное сообщение датировано 2015-м. Текст стёрт ровно там, где должно быть имя.", reward=24},
            {name="PizzaBox", text="Кусок пиццы пережил три API и одну цивилизацию.", reward=12},
        },
        memoryIndex = 1,
    },
    {
        id = 2, title = "ГЛАВА II — PLACE DELETED", subtitle = "Парк obby после удаления", map = "ObbyPark",
        duration = 45 * 60, minPulseForExit = 13,
        intro = "Плейс удалён, но сервер продолжает достраивать его из кэша.",
        enemy = {name = "CHECKPOINT_0", speed = 13, damage = 30, spawnPulse = 3, count = 1},
        tasks = {
            {label="Включи старые чекпоинты", action="Touch / Repair", object="Checkpoint", count=6, gatePulse=0},
            {label="Верни пропавшие платформы", action="Restore", object="Missing Brick", count=6, gatePulse=4},
            {label="Перезапусти колесо парка", action="Restart", object="Ride Control", count=3, gatePulse=9},
            {label="Найди резервный телепорт", action="Use", object="Teleport Pad", count=1, gatePulse=13},
        },
        eggs = {
            {name="AdminCommand", text="На стене: ';fly me'. Сервер отвечает: 'permission denied since 2015'.", reward=20},
            {name="NoobStatue", text="Статуя нуба поворачивает голову только когда ты на неё не смотришь. Наверное.", reward=18},
            {name="BadgeDoor", text="Дверь требует badge, который был удалён девять лет назад.", reward=22},
        },
    },
    {
        id = 3, title = "ГЛАВА III — LAST ONLINE", subtitle = "Город без игроков", map = "City",
        duration = 45 * 60, minPulseForExit = 13,
        intro = "На табло десятки игроков Online. На улицах — никого.",
        enemy = {name = "LAST_ONLINE", speed = 13.5, damage = 32, spawnPulse = 2, count = 2},
        tasks = {
            {label="Запитай кварталы", action="Power", object="Street Relay", count=5, gatePulse=0},
            {label="Запусти метро", action="Reset", object="Subway Breaker", count=4, gatePulse=4},
            {label="Собери журналы сервера", action="Read", object="Server Log", count=6, gatePulse=9},
            {label="Открой диспетчерскую", action="Override", object="Control Desk", count=1, gatePulse=13},
        },
        eggs = {
            {name="EmptyCafe", text="В кафе играет анимация разговора, хотя стулья пустые.", reward=18},
            {name="GuestBus", text="Автобус маршрута GUEST едет только в сторону края карты.", reward=22},
            {name="Clock2015", text="Все часы в городе показывают одно и то же время. Ты не помнишь, было ли оно важным.", reward=28},
        },
        memoryIndex = 2,
    },
    {
        id = 4, title = "ГЛАВА IV — FREE MODEL", subtitle = "Склад, который установил себя сам", map = "Warehouse",
        duration = 42 * 60, minPulseForExit = 12,
        intro = "Кто-то вставил Free Model. Потом ещё один. Потом папка Workspace перестала помещаться в Explorer.",
        enemy = {name = "MODEL_SCRIPT", speed = 14, damage = 24, spawnPulse = 2, count = 3},
        tasks = {
            {label="Найди заражённые модели", action="Quarantine", object="Free Model", count=7, gatePulse=0},
            {label="Отключи неизвестные scripts", action="Disable", object="Unknown Script", count=5, gatePulse=4},
            {label="Очисти InsertService-кэш", action="Purge", object="Cache Node", count=4, gatePulse=8},
            {label="Закрой ворота склада", action="Seal", object="Emergency Gate", count=1, gatePulse=12},
        },
        eggs = {
            {name="VirusScript", text="Script называется 'ANTI VIRUS 100% WORKING'. Это почему-то самый подозрительный объект здесь.", reward=26},
            {name="LinkedSword", text="LinkedSword.lua найден без LinkedSword.lua. Не задавай вопросов.", reward=20},
            {name="ToolboxCat", text="Внутри ящика сидит кирпичный кот. Его creator указан как [Content Deleted].", reward=24},
        },
    },
    {
        id = 5, title = "ГЛАВА V — BUILD MODE", subtitle = "Каньон незаконченной карты", map = "Canyon",
        duration = 48 * 60, minPulseForExit = 14,
        intro = "Здесь почти нет готовой дороги. Сервер ждёт, что игрок достроит её сам.",
        enemy = {name = "ANCHOR_FALSE", speed = 12.5, damage = 36, spawnPulse = 4, count = 1},
        tasks = {
            {label="Активируй строительные маяки", action="Mark", object="Build Beacon", count=4, gatePulse=0},
            {label="Доберись до четырёх опор через разрывы", action = "Mark", object = "Bridge Anchor", count = 4, gatePulse = 4},
            {label="Проложи мост каньона", action="Tie", object="Rope Post", count=5, gatePulse=9},
            {label="Дострой до заражённого маяка", action="Enter", object="Canyon Gate", count=1, gatePulse=14},
        },
        eggs = {
            {name="Wallhop", text="Черны стартого прохода остались в камне. Они буквально подпрыгиваются когда то на них не смотришь.", reward=22},
            {name="StudPost", text="Скала поставила на один блок студы, который не может быть создан теперь.", reward=18},
            {name="FallingBridge", text="Мост изменяет свою физику каждые три минуты.", reward=26},
        },
        memoryIndex = 3,
    },
    {
        id = 6, title = "ГЛАВА VI — BACKUP OCEAN", subtitle = "Острова прошлого сервера", map = "Ocean",
        duration = 45 * 60, minPulseForExit = 13,
        intro = "Единственное целое место провалилось. Теѿерь каждый остров — следгющая копия.",
        enemy = {name = "BACKUP_GHOST", speed = 15, damage = 34, spawnPulse = 3, count = 2},
        tasks = {
            {label="Собери потерянные копии", action="Recover", object="Backup Crate", count=6, gatePulse=0},
            {label="Перезапусти антенны", action="Sync", object="Island Antenna", count=4, gatePulse=4},
            {label="Сравни checksum", action="Validate", object="Checksum Post", count=5, gatePulse=9},
            {label="Добраться до радиовышки", action="Signal", object="Radio Beacon", count=1, gatePulse=13},
        },
        eggs = {
            {name="DeadCamera", text="Камера смотрит на воду под островом. На экране последний кадр перед удалением.", reward=25},
            {name="LostBoat", text="Корабль назван ‘темха ктт проплылаем по перовам.’ -Внутри пусто.", reward=20},
            {name="MovingIsland", text="Остров подвинулся на три студа. Это очень плохой раз для волны.", reward=27},
        },
    },
    {
        id = 7, title = "ГЛАВА VII — CHAT", subtitle = "Лабиринт из старых сообщений", map = "Chat",
        duration = 42 * 60, minPulseForExit = 12,
        intro = "Стены собраны из чата. Сервер не понимает, что выдумано на машине, что — старая строка.",
        enemy = {name = "TOMBSTONE_TYPING", speed = 15, damage = 28, spawnPulse = 2, count = 2},
        tasks = {
            {label="Найди разорванные фрагменты", action="Read", object="Chat Fragment", count=7, gatePulse=0},
            {label="Выключи ложные стены", action="Silence", object="Chat Wall", count=6, gatePulse=4},
            {label="Проверь имена отправителя", action="Verify", object="Name Token", count=4, gatePulse=8},
            {label="Пробеги короткий выход", action="Exit", object="Typing Cursor", count=1, gatePulse=12},
        },
        eggs = {
            {name="SendKick", text="Чат бесконечно повторяет: 'Joined the game' и 'Left the game'.", reward=22},
            {name="TixWord", text="Один фильтр чата сломан и оставил только старые буъвы.", reward=20},
            {name="AFKChair", text="Над пустым стулом висит 'brb 5 min'. Таймер идёт уже много лет.", reward=30},
            {name="SmileFace", text="Смайлик на стене меняется на грустный, когда ты отходишь. Очень смешно, сервер.", reward=18},
        },
        memoryIndex = 4,
    },
    {
        id = 8, title = "ГЛАВА VIII — GUEST 0", subtitle = "Лес, где кто-то всегда за деревом", map = "Forest",
        duration = 45 * 60, minPulseForExit = 13,
        intro = "Список игроков показывает Guest 0. У него нет UserId. У него есть координаты.",
        enemy = {name = "GUEST_0", speed = 16, damage = 38, spawnPulse = 1, count = 3},
        tasks = {
            {label="Зажги лагерные вышки", action="Light", object="Signal Tower", count=5, gatePulse=0},
            {label="Найди следы Guest 0", action="Inspect", object="Guest Trace", count=6, gatePulse=4},
            {label="Сломай ложные SpawnLocation", action="Delete", object="Fake Spawn", count=4, gatePulse=9},
            {label="Переживи путь до радиовышки", action="Broadcast", object="Radio Tower", count=1, gatePulse=13},
        },
        eggs = {
            {name="Campfire", text="У костра четыре места. Сервер считает, что занято пять.", reward=26},
            {name="GuestHat", text="Шляпа Guest лежит на пне. В Properties поле Owner пустое.", reward=24},
            {name="TreeChat", text="На коре выцарапано: 'i can still see the server list'.", reward=30},
        },
    },
    {
        id = 9, title = "ГЛАВА IX — ADMIN ARCHIVE", subtitle = "Под картой всегда была ещё одна карта", map = "Archive",
        duration = 48 * 60, minPulseForExit = 14,
        intro = "Ты нашёл технический слой плейса: архив версий, старые ключи и то, что админ пытался удалить.",
        enemy = {name = "MODERATOR_BOT", speed = 14.5, damage = 36, spawnPulse = 2, count = 3},
        tasks = {
            {label="Собери ключ-карты", action="Take", object="Archive Key", count=6, gatePulse=0},
            {label="Открой серверные секции", action="Unlock", object="Rack Door", count=5, gatePulse=5},
            {label="Сверь резервные версии", action="Compare", object="Version Console", count=5, gatePulse=10},
            {label="Получить доступ к ноутбуку админа", action="Authorize", object="Admin Console", count=1, gatePulse=14},
        },
        eggs = {
            {name="BanHammer", text="Ban Hammer лежит за стеклом. Табличка: 'не использовать на себе'.", reward=28},
            {name="PasswordSticky", text="Стикер: 'пароль не password'. Ниже другим почерком: 'это ложь'.", reward=20},
            {name="OldVersion", text="Версия карты 0.0.0 содержит только два SpawnLocation и пустое небо.", reward=32},
        },
    },
    {
        id = 10, title = "ГЛАВА X — LAST SAVE", subtitle = "Всё, что сервер смог сохранить", map = "Finale",
        duration = 48 * 60, minPulseForExit = 14,
        intro = "Все прошлые карты загрузились одновременно. Где-то внутри этого мусора остался последний настоящий save.",
        enemy = {name = "CODE_ROT", speed = 16.5, damage = 40, spawnPulse = 1, count = 4},
        tasks = {
            {label="Стабилизируй фрагменты прошлых карт", action="Anchor", object="World Anchor", count=7, gatePulse=0},
            {label="Восстанови master backup", action="Restore", object="Master Fragment", count=6, gatePulse=5},
            {label="Включи питание админ-бункера", action="Power", object="Core Fuse", count=4, gatePulse=10},
            {label="Запусти rollback_2015.bat", action="PRESS F", object="Administrator Laptop", count=1, gatePulse=14},
        },
        eggs = {
            {name="FirstBrick", text="Первый кирпич карты. Created: 2015. Modified: сейчас.", reward=30},
            {name="ServerList", text="В старом списке серверов один закрытый сервер всё ещё показывает 2/8 игроков.", reward=35},
            {name="ThankYou", text="На обратной стороне стены: 'thanks for playing even when nothing worked'.", reward=25},
        },
        memoryIndex = 5,
        memoryIndices = {1,2,3,4,5}, -- final catch-up: no permanent missable memorial fragments
        final = true,
    },
}

Config.TOTAL_CAMPAIGN_SECONDS = 0
for _, chapter in ipairs(Config.CHAPTERS) do
    Config.TOTAL_CAMPAIGN_SECONDS += chapter.duration
end

-- Upload your own memorial image to Roblox and replace 0 with the asset id.
Config.MEMORIAL_IMAGE_ID = 0
Config.MEMORIAL_TITLE = "ДРУГУ ИЗ 2015"
Config.MEMORIAL_EPITAPH = "Сервер закрылся. Память — нет."
Config.MEMORY_BADGE_ID = 0

Config.CLASSES = {
    Archivist = {displayName="Archivist", price=0, description="Лучше замечает память и получает +1 подсказку к главе.", buildLimit=55, walkSpeed=16},
    Builder = {displayName="Builder", price=250, description="Строит больше деталей и легче переживает разрывы карты.", buildLimit=110, walkSpeed=16},
    Debugger = {displayName="Debugger", price=400, description="Debug-лампа и немного больше скорости.", buildLimit=75, walkSpeed=17},
    Guest1337 = {displayName="Guest 1337", price=700, description="Очень быстрый класс для рискованных маршрутов.", buildLimit=75, walkSpeed=19},
}

Config.MEMORIES = {
    {title="MEMORY 01 / JOIN", text="Список серверов был короче. Ты нажал Join, потому что твой друг уже был внутри."},
    {title="MEMORY 02 / BUILD", text="Два квадратных аватара строили что-то бессмысленное и идеальное. Этому не нужно было сохраниться, чтобы быть важным."},
    {title="MEMORY 03 / CHAT", text="Окно чата вспыхивает. Ритм сообщений помнится лучше, чем точные слова."},
    {title="MEMORY 04 / LAST SERVER", text="На секунду карта снова становится тёплой. Без гниения. Без задания. Просто чувство, что времени впереди ещё очень много."},
    {title="MEMORY 05 / PRESS F", text="Некоторые люди выходят с сервера, но остаются в мире, который помогли тебе построить. Press F, чтобы почтить память.", memorial=true},
}

return Config
