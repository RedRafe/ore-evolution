local Tiers = require 'utils.tiers'()

local function add_effect(prototype)
    prototype.created_effect = prototype.created_effect or {}
    table.insert(prototype.created_effect, {
        type = 'direct',
        action_delivery = {
            type = 'instant',
            source_effects = {
                type = 'script',
                effect_id = 'on_resource_created'
            }
        }
    })
end

local function make_tier(base, index, multiplier)
    if not (base and base.minable) then
        return
    end

    if (base.minable.result == nil) and (#base.minable.results == 0) then
        return
    end

    local ore = table.deepcopy(base)
    ore.name = ('oe_%d_%s'):format(index, base.name)
    ore.autoplace = nil
    ore.localised_name = { 'entity-name.'..base.name }
    ore.hidden_in_factoriopedia = true
    ore.tree_removal_probability = 0
    ore.cliff_removal_probability = 0

    if ore.minable.mining_time then
        ore.minable.mining_time = ore.minable.mining_time * multiplier
    end

    data:extend({ ore })
end

-- Deepcopy original elements so we don't make tiers of tiers
for _, resource in pairs(table.deepcopy(data.raw.resource)) do
    for index, multiplier in pairs(Tiers) do
        make_tier(resource, index, multiplier)
    end
end

for _, resource in pairs(data.raw.resource) do
    add_effect(resource)
end
