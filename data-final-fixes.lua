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

    local minable = ore.minable
    if not minable then
        return
    end

    -- minable.mining_time = minable.mining_time * multiplier
    if minable.result then
        minable.results = {
            {
                type = 'item',
                name = minable.result,
                amount_min = minable.count or 1,
                amount_max = minable.count or 1,
                probability = math.max(0.01, 1 / multiplier)
            }
        }
        minable.result = nil
        minable.count = nil
    else
        for _, result in pairs(minable.results or {}) do
            result.amount_min = result.amount_min or result.amount
            result.amount_max = result.amount_max or result.amount
            result.probability = result.probability or 1
            result.probability = math.max(0.01, result.probability / multiplier)
        end
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
