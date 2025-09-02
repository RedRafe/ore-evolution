local default_values = '5e6,15e6,45e6,135e6,270e6,350e6,425e6,500e6,1e9'

---@param text string
---@param delimiter string
local split = function(text, delimiter)
    local parts = {}
    for part in string.gmatch(text, delimiter) do
        table.insert(parts, tonumber(part))
    end
    return parts
end

return function()
    local values = settings.global['oe-goals'].value
    if not values or #values == 0 then
        values = default_values
    end

    return split(values, '([^,]+)')
end

