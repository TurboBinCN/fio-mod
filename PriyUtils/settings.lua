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

    -- 采矿机速度倍数
    {
        type = "double-setting",
        name = "priyutils-mining-drill-output-speed-factor",
        localised_name = {"mod-setting-name.priyutils-mining-drill-output-speed-factor"},
        localised_description = {"mod-setting-description.priyutils-mining-drill-output-speed-factor"},
        setting_type = "startup",
        default_value = 1,
        minimum_value = 0.01,
        maximum_value = 1000,
        order = "a"
    },
    -- 采矿机区域大小倍数
    {
        type = "double-setting",
        name = "priyutils-mining-drill-mining-area-size",
        localised_name = {"mod-setting-name.priyutils-mining-drill-mining-area-size"},
        localised_description = {"mod-setting-description.priyutils-mining-drill-mining-area-size"},
        setting_type = "startup",
        default_value = 1,
        minimum_value = 1,
        maximum_value = 32,
        order = "b"
    },
    -- 抽油机速度倍数
    {
        type = "double-setting",
        name = "priyutils-pumpjack-output-speed-factor",
        localised_name = {"mod-setting-name.priyutils-pumpjack-output-speed-factor"},
        localised_description = {"mod-setting-description.priyutils-pumpjack-output-speed-factor"},
        setting_type = "startup",
        default_value = 100,
        minimum_value = 0.01,
        maximum_value = 100,
        order = "c"
    },
    -- 额外模块槽数量
    {
        type = "double-setting",
        name = "priyutils-extra-module-slots",
        localised_name = {"mod-setting-name.priyutils-extra-module-slots"},
        localised_description = {"mod-setting-description.priyutils-extra-module-slots"},
        setting_type = "startup",
        default_value = 0,
        minimum_value = 0,
        maximum_value = 20,
        order = "d"
    },
    -- 手动排除列表
    {
        type = "string-setting",
        name = "priyutils-parameter-change-exclusions",
        localised_name = {"mod-setting-name.priyutils-parameter-change-exclusions"},
        localised_description = {"mod-setting-description.priyutils-parameter-change-exclusions"},
        setting_type = "startup",
        default_value = "",
        allow_blank = true,
        auto_trim = true,
        order = "e"
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