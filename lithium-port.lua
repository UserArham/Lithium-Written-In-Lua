
-- ============================================
-- Lithium
-- Minecraft Performance Optimization Mod
-- Zeus API
-- ============================================

-- name: Lithium
-- version: 0.1.1
-- description: A lightweight Minecraft performance optimization mod for Eaglercraft, featuring FPS monitoring, optimized client settings, performance presets, and a customizable HUD.
-- author: UserArham

local Lithium = {
    NAME = "Lithium",
    VERSION = "0.1.1",
    DESCRIPTION = "A lightweight Minecraft performance optimization mod for Eaglercraft, featuring FPS monitoring, optimized client settings, performance presets, and a customizable HUD.",

    enabled = true,
    visible = true,

    startTime = timer.time(),

    fps = {
        current = 0,
        minimum = 9999,
        maximum = 0,
        average = 0,
        samples = {},
        sampleCount = 0
    },

    stats = {
        frames = 0,
        updates = 0,
        sessionTime = 0
    },

    config = {
        hud = true,
        showFPS = true,
        showAverage = true,
        showMinimum = true,
        showMaximum = true,
        showSession = true,
        compact = false,
        background = true,
        color = "#55FF55",
        x = 8,
        y = 8,
        renderDistance = 8,
        autoOptimize = false
    }
}

-- ============================================
-- COLORS
-- ============================================

local COLORS = {
    background = "#15191F",
    border = "#343C48",
    title = "#A5F3FC",
    green = "#55FF55",
    yellow = "#FFFF55",
    red = "#FF5555",
    white = "#FFFFFF",
    gray = "#A0AAB8",
    cyan = "#55FFFF"
}

-- ============================================
-- SAFE EXECUTION
-- ============================================

local function safeCall(fn, fallback)
    local ok, result = pcall(fn)

    if ok then
        return result
    end

    return fallback
end

local function getFPS()
    return safeCall(function()
        return game.fps()
    end, 0)
end

local function getTime()
    return timer.time()
end

local function formatNumber(number)
    return tostring(math.floor(number or 0))
end

-- ============================================
-- FPS COLOR
-- ============================================

local function getFPSColor(fps)
    if fps >= 120 then
        return COLORS.green
    elseif fps >= 60 then
        return COLORS.yellow
    else
        return COLORS.red
    end
end

-- ============================================
-- FPS TRACKING
-- ============================================

local function updateFPS()
    if not Lithium.enabled then
        return
    end

    local fps = getFPS()

    Lithium.fps.current = fps

    Lithium.stats.frames =
        Lithium.stats.frames + 1

    if fps > 0 then
        Lithium.fps.minimum = math.min(
            Lithium.fps.minimum,
            fps
        )

        Lithium.fps.maximum = math.max(
            Lithium.fps.maximum,
            fps
        )

        local samples = Lithium.fps.samples

        table.insert(samples, fps)

        if #samples > 120 then
            table.remove(samples, 1)
        end

        local total = 0

        for _, value in ipairs(samples) do
            total = total + value
        end

        Lithium.fps.sampleCount = #samples

        Lithium.fps.average =
            total / #samples
    end

    Lithium.stats.sessionTime =
        getTime() - Lithium.startTime

    Lithium.stats.updates =
        Lithium.stats.updates + 1
end

-- ============================================
-- FPS UPDATE TIMER
-- ============================================

timer.every(0.25, function()
    updateFPS()
end)

-- ============================================
-- HUD RENDERING
-- ============================================

local function drawHUD(ctx)
    if not Lithium.enabled then
        return
    end

    if not Lithium.visible then
        return
    end

    if not Lithium.config.hud then
        return
    end

    local x = Lithium.config.x
    local y = Lithium.config.y

    local width =
        Lithium.config.compact and 112 or 164

    local height =
        Lithium.config.compact and 27 or 94

    if Lithium.config.background then
        ctx:rect(
            x, y,
            width, height,
            COLORS.background
        )

        ctx:outline(
            x, y,
            width, height,
            COLORS.border
        )
    end

    ctx:text(
        "LITHIUM",
        x + 7,
        y + 5,
        COLORS.title
    )

    ctx:text(
        "v" .. Lithium.VERSION,
        x + width - 40,
        y + 5,
        COLORS.gray
    )

    if Lithium.config.showFPS then
        ctx:text(
            "FPS: " ..
            formatNumber(Lithium.fps.current),
            x + 7,
            y + 20,
            getFPSColor(Lithium.fps.current)
        )
    end

    if Lithium.config.compact then
        return
    end

    if Lithium.config.showAverage then
        ctx:text(
            "Average: " ..
            formatNumber(Lithium.fps.average),
            x + 7,
            y + 34,
            COLORS.white
        )
    end

    if Lithium.config.showMinimum then
        ctx:text(
            "Minimum: " ..
            formatNumber(Lithium.fps.minimum),
            x + 7,
            y + 48,
            COLORS.gray
        )
    end

    if Lithium.config.showMaximum then
        ctx:text(
            "Maximum: " ..
            formatNumber(Lithium.fps.maximum),
            x + 7,
            y + 62,
            COLORS.gray
        )
    end

    if Lithium.config.showSession then
        ctx:text(
            "Session: " ..
            util.formatTime(Lithium.stats.sessionTime),
            x + 7,
            y + 76,
            COLORS.cyan
        )
    end
end

hud.add("lithium_hud", drawHUD)

-- ============================================
-- SETTINGS
-- ============================================

settings.toggle("hud", {
    label = "Lithium HUD",
    description = "Show the performance HUD",
    default = true
})

settings.toggle("compact", {
    label = "Compact HUD",
    description = "Use a smaller display",
    default = false
})

settings.toggle("background", {
    label = "HUD Background",
    description = "Show the HUD background",
    default = true
})

settings.toggle("average", {
    label = "Average FPS",
    description = "Display average FPS",
    default = true
})

settings.toggle("minimum", {
    label = "Minimum FPS",
    description = "Display minimum FPS",
    default = true
})

settings.toggle("maximum", {
    label = "Maximum FPS",
    description = "Display maximum FPS",
    default = true
})

settings.toggle("session", {
    label = "Session Timer",
    description = "Display session duration",
    default = true
})

settings.toggle("auto", {
    label = "Automatic Optimization",
    description = "Adjust supported client settings automatically",
    default = false
})

-- ============================================
-- LOAD SETTINGS
-- ============================================

local function loadSettings()
    Lithium.config.hud =
        settings.get("hud") ~= false

    Lithium.config.compact =
        settings.get("compact") == true

    Lithium.config.background =
        settings.get("background") ~= false

    Lithium.config.showAverage =
        settings.get("average") ~= false

    Lithium.config.showMinimum =
        settings.get("minimum") ~= false

    Lithium.config.showMaximum =
        settings.get("maximum") ~= false

    Lithium.config.showSession =
        settings.get("session") ~= false

    Lithium.config.autoOptimize =
        settings.get("auto") == true
end

loadSettings()

settings.onChange(function()
    loadSettings()
end)

-- ============================================
-- PERFORMANCE PRESETS
-- ============================================

Lithium.presets = {
    balanced = {
        renderDistance = 8,
        name = "Balanced"
    },

    performance = {
        renderDistance = 6,
        name = "Performance"
    },

    maximum = {
        renderDistance = 4,
        name = "Maximum Performance"
    },

    quality = {
        renderDistance = 12,
        name = "Quality"
    }
}

function Lithium.applyPreset(name)
    local preset = Lithium.presets[name]

    if not preset then
        return false
    end

    local ok = pcall(function()
        game.setOption(
            "renderDistance",
            preset.renderDistance
        )
    end)

    if ok then
        Lithium.config.renderDistance =
            preset.renderDistance

        chat.print(
            "[Lithium] Applied " ..
            preset.name .. " preset."
        )

        return true
    end

    chat.print(
        "[Lithium] Could not apply preset."
    )

    return false
end

-- ============================================
-- PERFORMANCE REPORT
-- ============================================

function Lithium.report()
    chat.print("========== LITHIUM ==========")

    chat.print(
        "Version: " .. Lithium.VERSION
    )

    chat.print(
        "FPS: " ..
        formatNumber(Lithium.fps.current)
    )

    chat.print(
        "Average FPS: " ..
        formatNumber(Lithium.fps.average)
    )

    chat.print(
        "Minimum FPS: " ..
        formatNumber(Lithium.fps.minimum)
    )

    chat.print(
        "Maximum FPS: " ..
        formatNumber(Lithium.fps.maximum)
    )

    chat.print(
        "Render Distance: " ..
        tostring(safeCall(function()
            return game.option("renderDistance")
        end, "Unknown"))
    )

    chat.print(
        "Session: " ..
        util.formatTime(Lithium.stats.sessionTime)
    )

    chat.print(
        "Frames tracked: " ..
        formatNumber(Lithium.stats.frames)
    )

    chat.print("=============================")
end

-- ============================================
-- COMMANDS
-- ============================================

commands.register(
    "lithium",
    function(args, raw)

        local subcommand = args[1] or "help"

        if subcommand == "help" then

            chat.print("===== LITHIUM 0.1.1 =====")
            chat.print("/lithium")
            chat.print("/lithium help")
            chat.print("/lithium stats")
            chat.print("/lithium hud")
            chat.print("/lithium hide")
            chat.print("/lithium show")
            chat.print("/lithium enable")
            chat.print("/lithium disable")
            chat.print("/lithium settings")
            chat.print("/lithium balanced")
            chat.print("/lithium performance")
            chat.print("/lithium maximum")
            chat.print("/lithium quality")
            chat.print("/lithium reset")
            chat.print("=========================")

        elseif subcommand == "stats" then

            Lithium.report()

        elseif subcommand == "hud" then

            Lithium.config.hud =
                not Lithium.config.hud

            settings.set(
                "hud",
                Lithium.config.hud
            )

            chat.print(
                "HUD: " ..
                tostring(Lithium.config.hud)
            )

        elseif subcommand == "hide" then

            Lithium.visible = false
            chat.print("HUD hidden.")

        elseif subcommand == "show" then

            Lithium.visible = true
            chat.print("HUD visible.")

        elseif subcommand == "enable" then

            Lithium.enabled = true
            chat.print("Lithium enabled.")

        elseif subcommand == "disable" then

            Lithium.enabled = false
            chat.print("Lithium disabled.")

        elseif subcommand == "settings" then

            settings.open()

        elseif subcommand == "balanced" then

            Lithium.applyPreset("balanced")

        elseif subcommand == "performance" then

            Lithium.applyPreset("performance")

        elseif subcommand == "maximum" then

            Lithium.applyPreset("maximum")

        elseif subcommand == "quality" then

            Lithium.applyPreset("quality")

        elseif subcommand == "reset" then

            Lithium.fps.minimum = 9999
            Lithium.fps.maximum = 0
            Lithium.fps.average = 0
            Lithium.fps.samples = {}
            Lithium.fps.sampleCount = 0

            Lithium.stats.frames = 0
            Lithium.stats.updates = 0

            Lithium.startTime = getTime()

            chat.print(
                "Lithium statistics reset."
            )

        else

            chat.print(
                "Unknown command. Use /lithium help"
            )

        end
    end,
    "Lithium performance commands"
)

-- ============================================
-- AUTOMATIC OPTIMIZATION
-- ============================================

timer.every(5, function()

    if not Lithium.enabled then
        return
    end

    if not Lithium.config.autoOptimize then
        return
    end

    if not game.inWorld() then
        return
    end

    local fps = Lithium.fps.current

    if fps > 0 and fps < 30 then

        local distance = safeCall(function()
            return game.option("renderDistance")
        end, nil)

        if distance and distance > 4 then

            pcall(function()
                game.setOption(
                    "renderDistance",
                    math.max(4, distance - 2)
                )
            end)

        end
    end
end)

-- ============================================
-- RESET FUNCTION
-- ============================================

function Lithium.reset()
    Lithium.fps.current = 0
    Lithium.fps.minimum = 9999
    Lithium.fps.maximum = 0
    Lithium.fps.average = 0
    Lithium.fps.samples = {}
    Lithium.fps.sampleCount = 0

    Lithium.stats.frames = 0
    Lithium.stats.updates = 0

    Lithium.startTime = getTime()

    chat.print("[Lithium] Statistics reset.")
end

-- ============================================
-- STARTUP
-- ============================================

chat.print(
    "b[Lithium] aLithium 0.1.1 loaded!"
)

chat.print(
    "7" .. Lithium.DESCRIPTION
)

chat.print(
    "7Type /lithium help for commands."
)

mod.log(
    "Lithium 0.1.1 initialized."
)

-- ============================================
-- EXPORT
-- ============================================

mod.export = Lithium
