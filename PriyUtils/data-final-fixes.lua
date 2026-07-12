require("prototypes.mining.mining")
require("prototypes.data-stack_size-fixes")
require("prototypes.trashcan.data-fixes")
-- 修改 laser-turret 的攻速与伤害
if data.raw["electric-turret"]["laser-turret"] then
  local laser_turret = data.raw["electric-turret"]["laser-turret"]
  -- 攻速: 从 40 tick 改为 20 tick（攻速翻倍）
  laser_turret.attack_parameters.cooldown = 20
  -- 伤害倍率: 从 2 改为 4（伤害翻倍）
  laser_turret.attack_parameters.damage_modifier = 4
end
