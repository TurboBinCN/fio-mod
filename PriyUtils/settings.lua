data:extend({
    -- 装备小型化设置
    {
    type = "bool-setting",
    name = "priyutils-tinyenergyshield",
    localised_name = "最小化能量盾",
    localised_description = "是否最小化能量盾",
    setting_type = "startup",
    default_value = true
    },
    {
    type = "bool-setting",
    name = "priyutils-tinysolarpanel",
    localised_name = "最小化太阳能板",
    localised_description = "是否最小化太阳能板",
    setting_type = "startup",
    default_value = true
    },  
    {
    type = "bool-setting",
    name = "priyutils-tinyreactor",
    localised_name = "最小化反应堆",
    localised_description = "是否最小化反应堆",
    setting_type = "startup",
    default_value = true
    },
    {
    type = "bool-setting",
    name = "priyutils-tinybattery",
    localised_name = "最小化电池",
    localised_description = "是否最小化电池",
    setting_type = "startup",
    default_value = true
    },
    {
    type = "bool-setting",
    name = "priyutils-tinyroboport",
    localised_name = "最小化机器人端口",
    localised_description = "是否最小化机器人端口",
    setting_type = "startup",
    default_value = true
    },
    {
    type = "bool-setting",
    name = "priyutils-tinynightvision",
    localised_name = "最小化夜视",
    localised_description = "是否最小化夜视",
    setting_type = "startup",
    default_value = true
    },
    {
    type = "bool-setting",
    name = "priyutils-tinyexoskeleton",
    localised_name = "最小化外骨骼",
    localised_description = "是否最小化外骨骼",
    setting_type = "startup",
    default_value = true
    },
    {
    type = "bool-setting",
    name = "priyutils-tinyactivedefense",
    localised_name = "最小化主动防御",
    localised_description = "是否最小化主动防御",
    setting_type = "startup",
    default_value = true
    },
    
    -- 机械臂速度设置
    {
    type = "double-setting",
    name = "priyutils-faster-inserters-speed",
    localised_name = "机械臂速度倍数",
    localised_description = "使用 1 作为倍数以获得基础游戏速度",
    setting_type = "startup",
    minimum_value = 0,
    default_value = 5
    },

    --泵浦速率
    {
    type = "double-setting",
    name = "priyutils-pump-speed",
    localised_name = "泵浦速率倍数",
    localised_description = "使用 1 作为倍数以获得基础游戏速度",
    setting_type = "startup",
    minimum_value = 0,
    default_value = 1
    },
    
    -- 机械臂吞吐量设置
    {
        type = 'bool-setting',
        name = 'priyutils-inserter-throughput-enabled',
        localised_name = "启用机械臂吞吐量显示",
        localised_description = "是否显示机械臂的吞吐量",
        setting_type = 'runtime-per-user',
        default_value = true
    },
    {
        type = 'bool-setting',
        name = 'priyutils-inserter-throughput-show-toggle',
        localised_name = "显示切换按钮",
        localised_description = "是否在界面上显示切换按钮",
        setting_type = 'runtime-per-user',
        default_value = true
    },
    {
        type = 'int-setting',
        name = 'priyutils-inserter-throughput-rounding-precision',
        localised_name = "小数精度",
        localised_description = "吞吐量显示的小数位数",
        setting_type = 'runtime-per-user',
        default_value = 2,
        minimum_value = 0
    }
})