local Queue = require 'utils.queue'
local Goals = require 'utils.goals'

-- == SETUP ===================================================================

local function on_init()
    storage.processed_units = settings.global['oe-processed-units'].value or 10
    storage.level = 0
    storage.entities = Queue.new()
    storage.collapses = Goals()
end

local function on_runtime_mod_setting_changed()
    storage.processed_units = settings.global['oe-processed-units'].value or 10
    storage.collapses = Goals()
end

-- == REMOTE INTERFACE ========================================================

local function add_remote_interface()
    remote.add_interface('ore_evolution', {
        get = function(key)
            return storage[key]
        end,
        set = function(key, value)
            storage[key] = value
        end,
    })
end

-- ============================================================================

return {
    on_init = on_init,
    add_remote_interface = add_remote_interface,
    events = {
        [defines.events.on_runtime_mod_setting_changed] = on_runtime_mod_setting_changed
    }
}