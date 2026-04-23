-- 机械臂能力修改（从 fpc_inster_capacity_size_2.0.1 mod）
data.raw["inserter"]["bulk-inserter"].stack_size_bonus = 97

-- 机械臂速度修改（从 faster-inserters mod）
local speedMultiplier = settings.startup["priyutils-faster-inserters-speed"].value

for _, inserter in pairs(data.raw["inserter"]) do
    inserter.extension_speed = inserter.extension_speed * speedMultiplier
    inserter.rotation_speed = inserter.rotation_speed * speedMultiplier
end
