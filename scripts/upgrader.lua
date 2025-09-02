local math_min = math.min
local string_match = string.match
local string_sub = string.sub
local tonumber = tonumber

-- == UPGRADER ================================================================

local max_mining_radius = 1
do
    local mining_drills = prototypes.get_entity_filtered{ { filter = 'type', type = 'mining-drill' } }
    for _, drill in pairs(mining_drills) do
        max_mining_radius = math.max(max_mining_radius, drill.mining_drill_radius)
    end
end

local function get_entity_info(name)
    local level = 0
    local base_name = name
    local prefix = 'oe_'

    if string_sub(name, 1, #prefix) == prefix then
        -- Extract the substring after "oe_"
        local rest = string_sub(name, #prefix + 1)
        -- Capture the number at the beginning of rest
        local number = string_match(rest, '^(%d+)')
        if number then
            level = tonumber(number)
            -- Remove the number and the following underscore from rest to get base name
            base_name = string_sub(rest, #number + 2) -- +2 to skip number and underscore
        else
            -- If no number, the entire rest is the base name
            base_name = rest
        end
    end

    return level, base_name
end

local function process_resource(entity)
    if not (entity and entity.valid) then
        return
    end

    local current_level = storage.level
    local entity_level, base_name = get_entity_info(entity.name)
    if entity_level == current_level then
        return
    end

    local new = entity.surface.create_entity {
        position = entity.position,
        name = ('oe_%d_%s'):format(current_level, base_name),
        raise_built = false,
        amount = entity.amount,
        enable_tree_removal = false,
        enable_cliff_removal = false,
    }

    if not (new and new.valid) then
        return
    end

    new.graphics_variation = entity.graphics_variation
    entity.destroy()

    for _, e in pairs(new.surface.find_entities_filtered{
        position = new.position,
        radius = 1.5 * max_mining_radius, -- approx sqrt(2)
        type = 'mining-drill',
    }) do
        e.update_connections()
    end
end

local function on_tick()
    local q_data = storage.entities

    local q_size = math_min(storage.processed_units, q_data:size())
    while q_size > 0 do
        process_resource(q_data:pop())
        q_size = q_size - 1
    end
end

return {
    events = {
        [defines.events.on_tick] = on_tick
    }
}
