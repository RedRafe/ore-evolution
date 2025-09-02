local default_values = '2,4,8,16,32,64,128,256,512'

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
    local values = settings.startup['oe-tiers'].value
    if not values or #values == 0 then
        values = default_values
    end

    return split(values, '([^,]+)')
end
