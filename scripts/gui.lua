local Gui = require 'utils.gui'
local math_abs = math.abs
local math_ceil = math.ceil
local math_floor = math.floor
local math_log = math.log
local math_min = math.min

local main_frame_name = Gui.uid_name('main-frame')
local resources = {}

do
    for _, entity in pairs(prototypes.get_entity_filtered({ { filter = 'type', type = 'resource' } })) do
        for _, item in pairs(entity.mineable_properties.products or {}) do
            if item.type == 'item' then
                resources[item.name] = true
            end
        end
    end
end

local function on_player_created(event)
    local player = game.get_player(event.player_index)
    local data = {}

    local frame = Gui.add_top_element(player, {
        name = main_frame_name,
        type = 'frame',
    })
    Gui.set_style(frame, {
        natural_height = 40,
        bottom_padding = 5,
        left_padding = 12,
        right_padding = 12,
    })
    Gui.set_data(frame, data)

    local flow = frame.add { type = 'flow', direction = 'horizontal' }

    local label = flow.add {
        type = 'label',
        style = 'bold_label',
        caption = { 'oe.label_caption', (storage.level + 1) },
        tooltip = { 'oe.label_tooltip' },
    }
    data.label = label

    local progressbar = flow.add {
        type = 'progressbar',
        style = 'achievement_progressbar',
        value = 0,
    }
    Gui.set_style(progressbar, {
        width = 96,
        height = 20,
        --top_padding = 1,
        --bottom_padding = -1,
        --left_padding = -1,
        --right_padding = -1,
    })
    data.progressbar = progressbar

    local info = flow.add { type = 'label', caption = '[img=info]' }
    info.visible = player.admin
    data.info = info
end

local si_prefixes = {
    { 'Q', 1e30 }, -- quetta
    { 'R', 1e27 }, -- ronna
    { 'Y', 1e24 }, -- yotta
    { 'Z', 1e21 }, -- zetta
    { 'E', 1e18 }, -- exa
    { 'P', 1e15 }, -- peta
    { 'T', 1e12 }, -- tera
    { 'G', 1e09 }, -- giga
    { 'M', 1e06 }, -- mega
    { 'k', 1e03 }, -- kilo
}

local function format_si(amount)
    local suffix = ''
    for _, suf in pairs(si_prefixes) do
        local letter, limit = suf[1], suf[2]
        if math_abs(amount) >= limit then
            amount = math_floor(amount / (limit / 10)) / 10
            suffix = letter
            break
        end
    end
    local formatted, k = amount, nil
    while true do
        formatted, k = string.gsub(formatted, '^(-?%d+)(%d%d%d)', '%1,%2')
        if k == 0 then
            break
        end
    end
    return formatted .. suffix
end

local function on_nth_tick()
    local ore_mined = 0
    local get_stats = game.forces.player.get_item_production_statistics

    for _, surface in pairs(game.surfaces) do
        local get_count = get_stats(surface).get_input_count
        for resource in pairs(resources) do
            ore_mined = ore_mined + get_count(resource)
        end
    end

    local r, color, goal_str
    local next_level = storage.level + 1
    local goal = storage.collapses[next_level]
    local ore_str = format_si(ore_mined)
    if goal == nil or goal == 'inf' then
        goal_str = 'inf'
        r = 0.5
        color = { 0, 255, 0}
    else
        goal_str = format_si(goal)
        r = math_min(1, ore_mined / goal)
        color = { r = r, g = 1 - r, b = 0 }
    end
    local q_size = storage.entities:size()

    for _, p in pairs(game.connected_players) do
        local data = Gui.get_data(Gui.get_top_element(p, main_frame_name))

        data.progressbar.style.color = color
        data.progressbar.value = r
        data.progressbar.tooltip = { 'oe.progressbar_tooltip', ore_str, goal_str }
        data.label.caption = { 'oe.label_caption', next_level }
        data.info.visible = p.admin
        data.info.tooltip = { 'oe.info_tooltip', q_size }
    end

    if goal > 1 and ore_mined >= goal then
        script.raise_event(defines.events.on_resource_collapse, { level = next_level })
    end
end

return {
    events = {
        [defines.events.on_player_created] = on_player_created,
    },
    on_nth_tick = {
        [60 * 30] = on_nth_tick,
    },
}
