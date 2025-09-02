data:extend({
    {
        type = 'string-setting',
        name = 'oe-tiers',
        setting_type = 'startup',
        default_value = '2,4,8,16,32,64,128,256,512',
        allow_blank = false,
        auto_trim = true,
    },
    {
        type = 'string-setting',
        name = 'oe-goals',
        setting_type = 'runtime-global',
        default_value = '5e6,15e6,45e6,135e6,270e6,350e6,425e6,500e6,1e9',
        allow_blank = false,
        auto_trim = true,
    },
    {
        type = 'int-setting',
        name = 'oe-processed-units',
        setting_type = 'runtime-global',
        default_value = 10,
        minimum_value = 1,
        maximum_value = 1000,
    }
})


