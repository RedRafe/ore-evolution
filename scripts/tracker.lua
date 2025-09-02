-- == TRACKER =================================================================

local function on_script_trigger_effect(event)
    if event.effect_id ~= 'on_resource_created' then
        return
    end

    -- Do not ptocess lvl-0 because other scripts already create lvl-0 entities
    if storage.level == 0 then
        return
    end

    local entity = event.target_entity or event.cause_entity
    if not (entity and entity.valid) then
        return
    end

    storage.entities:push(entity)
end

local function on_resource_collapse(event)
    game.print({'oe.collapse_warning'}, { sound_path = 'utility/new_objective' })

    storage.level = event.level or (storage.level + 1)

    local q_data = storage.entities
    q_data:clear()

    for _, surface in pairs(game.surfaces) do
        for _, e in pairs(surface.find_entities_filtered{ type = 'resource' }) do
            q_data:push(e)
        end
    end
end

return {
    events = {
        [defines.events.on_script_trigger_effect] = on_script_trigger_effect,
        [defines.events.on_resource_collapse] = on_resource_collapse,
    }
}
