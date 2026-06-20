-- 修改 rocket-fuel 的堆叠数量为 1000
if data.raw.item["rocket-fuel"] then
  data.raw.item["rocket-fuel"].stack_size = 1000
  -- 同时修改默认请求数量
  data.raw.item["rocket-fuel"].default_request_amount = 1000
end

--插件分享塔的堆叠数量为 1000
if data.raw.item["beacon"] then
  data.raw.item["beacon"].stack_size = 1000
  -- 同时修改默认请求数量
  data.raw.item["beacon"].default_request_amount = 1000
end

--电力机械抓的堆叠数量为 1000
if data.raw.item["inserter"] then
  data.raw.item["inserter"].stack_size = 1000
  -- 同时修改默认请求数量
  data.raw.item["inserter"].default_request_amount = 1000
end

-- 修改 wood 的堆叠数量为 24k
if data.raw.item["wood"] then
  data.raw.item["wood"].stack_size = 24000
  -- 同时修改默认请求数量
  data.raw.item["wood"].default_request_amount = 24000
end
-- 修改 laser-turret 的攻速与伤害
if data.raw["electric-turret"]["laser-turret"] then
  local laser_turret = data.raw["electric-turret"]["laser-turret"]
  -- 攻速: 从 40 tick 改为 20 tick（攻速翻倍）
  laser_turret.attack_parameters.cooldown = 20
  -- 伤害倍率: 从 2 改为 4（伤害翻倍）
  laser_turret.attack_parameters.damage_modifier = 4
end
