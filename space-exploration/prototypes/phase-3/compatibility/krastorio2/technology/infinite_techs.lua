-- This source is dedicated to integrating SEs and K2s competing changes to infinite technologies.

-- This must be done in phase-3 as SE makes it's own changes in this phase and we don't want to fight technology.lua or technology-procedural.lua.

-- Infinite Techs SE Flavour:
---- Artillery Shell Range - Material
---- Artillery Shell Shooting Speed - Material
---- Mining Productivity - Biological
---- Energy Weapons Damage - Energy
---- Worker Robot Speed - Energy
---- Physical Projectile Damage - Material
---- Refined Flammables - Material
---- Stronger Explosives - Material
---- Follower Robot Count - Material
---- Factory Spaceship - All bar Biological
---- Rocket Cargo Safety - Astronomic
---- Rocket Survivability - Astronomic

local data_util = require("data_util")

local function alter_technology_cost(tech_name, cost_formula, cost)
  if    tech_name
    and data.raw.technology[tech_name]
  then
    if cost_formula then
      data.raw.technology[tech_name].unit.count = nil
      data.raw.technology[tech_name].unit.count_formula = cost_formula
    end
    if cost then
      data.raw.technology[tech_name].unit.count = cost
      data.raw.technology[tech_name].unit.count_formula = nil
    end
  end
end

local function move_technology(tech_name, techs_to_add, ingredients_to_add, techs_to_remove, ingredients_to_remove)
  if ingredients_to_remove then
    data_util.tech_remove_ingredients(tech_name, ingredients_to_remove)
  end
  if techs_to_remove then
    data_util.tech_remove_prerequisites(tech_name, techs_to_remove)
  end
  if ingredients_to_add then
    data_util.tech_add_ingredients(tech_name, ingredients_to_add)
  end
  if techs_to_add then
    data_util.tech_add_prerequisites(tech_name, techs_to_add)
  end
end

local function alter_technology_effect(tech_name, effects)
  if    tech_name
    and data.raw.technology[tech_name]
  then
    if effects then
      data.raw.technology[tech_name].effects = effects
    end
  end
end

-- Check whether a technology is infinite
local function tech_is_infinite(tech_name)
  local i = 1
  while data.raw.technology[tech_name.."-"..i] do
    if data.raw.technology[tech_name.."-"..i].max_level == "infinite" then
      return true
    else
      if data.raw.technology[tech_name.."-"..i].max_level then
        i = data.raw.technology[tech_name.."-"..i].max_level + 1
      else
        i = i + 1
      end
    end
  end
  return false
end

-- If a technology is not infinite, make it infinite
local function make_tech_infinite(tech_name)
  local i = 1
  local last_tech
  if not tech_is_infinite(tech_name) then
    while data.raw.technology[tech_name.."-"..i] do
      last_tech = data.raw.technology[tech_name.."-"..i]
      if last_tech.max_level then
        i = last_tech.max_level + 1
      else
        i = i + 1
      end
    end
    if last_tech then
      last_tech.max_level = "infinite"
      last_tech.unit.count = nil
    last_tech.unit.count_formula = last_tech.unit.count_formula or "2^(L-7)*1000"
    end
  end
end


---- Artillery Shell Range : Material Science ----
-- Base SE
-- PreRocket, Rocket, Space, Utility                         : +30% Range
-- PreRocket, Rocket, Space, Utility, Production, Mat1       : +30% Range
-- PreRocket, Rocket, Space, Utility, Production, Mat2       : +30% Range
-- PreRocket, Rocket, Space, Utility, Production, Mat3       : +30% Range
-- PreRocket, Rocket, Space, Utility, Production, Mat4       : +30% Range
-- PreRocket, Rocket, Space, Utility, Production, Mat4, DSS1 : +30% Range : Total Bonus +180% Range

-- K2SE
-- PreRocket, Rocket, Space, Utility                                                     : +25%
-- PreRocket, Rocket, Space, Utility, Production, Optimisation1                          : +25%
-- PreRocket, Rocket, Space, Utility, Production, Optimisation1, Mat1                    : +25%
-- PreRocket, Rocket, Space, Utility, Production, Optimisation1, Mat2                    : +25%
-- PreRocket, Rocket, Space, Utility, Production, Optimisation1, Mat3                    : +25%
-- PreRocket, Rocket, Space, Utility, Production, Optimisation2, Mat3                    : +25%
-- PreRocket, Rocket, Space, Utility, Production, Optimisation2, Mat4                    : +25%
-- PreRocket, Rocket, Space, Utility, Production, Optimisation2, Mat4, Matter 1          : +25%
-- PreRocket, Rocket, Space, Utility, Production, Optimisation2, Mat4, Matter 1, DSS1    : +25% Range : Total Bonus : 225% Range
-- PreRocket, Rocket, Space, Utility, Production, Optimisation2, Mat4, Matter 1, DSS2    :
-- PreRocket, Rocket, Space, Utility, Production, Optimisation2, Mat4, Matter 2, DSS2    :
-- PreRocket, Rocket, Space, Utility, Production, Optimisation2, Mat4, Matter 2, DSS3    :
-- PreRocket, Rocket, Space, Utility, Production, Optimisation3, Mat4, Matter 2, DSS3    :
-- PreRocket, Rocket, Space, Utility, Production, Optimisation3, Mat4, Matter 2, DSS4    :

local artillery_range_effect = {{type="artillery-range", modifier = 0.25}}

-- Artillery Shell Range requires seven additional technologies for the tech pack progression
data_util.tech_split_at_levels("artillery-shell-range",{2,4,6,7,8,9,10,11,12,13,14})

-- Utility
alter_technology_cost("artillery-shell-range-1", "(1.25^L)*3000")
alter_technology_effect("artillery-shell-range-1", artillery_range_effect)

-- Production & Optimisation 1
move_technology(
  "artillery-shell-range-2",
  {"kr-optimization-tech-card","kr-railgun-turret"},
  {"automation-science-pack","logistic-science-pack","military-science-pack","chemical-science-pack","kr-optimization-tech-card"},
  {"se-material-science-pack-1"},
  {"se-material-science-pack-1"}
)
alter_technology_cost("artillery-shell-range-2", "(1.25^L)*3000")
alter_technology_effect("artillery-shell-range-2", artillery_range_effect)

-- Material 1
move_technology(
  "artillery-shell-range-3",
  {"kr-rocket-turret"},
  {"automation-science-pack","logistic-science-pack","military-science-pack","chemical-science-pack","se-material-science-pack-1"},
  {"kr-advanced-tech-card", "kr-matter-tech-card"},
  {"kr-advanced-tech-card", "kr-matter-tech-card"}
)
alter_technology_cost("artillery-shell-range-3", "(1.25^L)*3000")
alter_technology_effect("artillery-shell-range-3", artillery_range_effect)

-- Material 2
move_technology(
  "artillery-shell-range-4",
  {"se-space-accumulator"},
  {"automation-science-pack","logistic-science-pack","military-science-pack","chemical-science-pack","se-material-science-pack-2"},
  {"se-material-science-pack-1"},
  {"kr-advanced-tech-card","kr-matter-tech-card"}
)
alter_technology_cost("artillery-shell-range-4", "(1.25^L)*3000")
alter_technology_effect("artillery-shell-range-4", artillery_range_effect)

-- Material 3
move_technology(
  "artillery-shell-range-5",
  {"stronger-explosives-9"},
  {"automation-science-pack","logistic-science-pack","military-science-pack","chemical-science-pack","se-material-science-pack-3"},
  {"kr-singularity-tech-card"},
  {"kr-advanced-tech-card","kr-matter-tech-card","kr-singularity-tech-card"}
)
alter_technology_cost("artillery-shell-range-5", "(1.25^L)*3000")
alter_technology_effect("artillery-shell-range-5", artillery_range_effect)

-- Optimisation 2
move_technology(
  "artillery-shell-range-6",
  {"stronger-explosives-10"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-material-science-pack-3"},
  {"se-material-science-pack-1"},
  {"kr-optimization-tech-card","kr-matter-tech-card","se-material-science-pack-1","kr-singularity-tech-card"}
)
alter_technology_cost("artillery-shell-range-6", "(1.25^L)*3000")
alter_technology_effect("artillery-shell-range-6", artillery_range_effect)

-- Material 4
move_technology(
  "artillery-shell-range-7",
  {"stronger-explosives-11"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-material-science-pack-4"},
  {"se-material-science-pack-2"},
  {"kr-optimization-tech-card","kr-matter-tech-card","se-material-science-pack-2","kr-singularity-tech-card"}
)
alter_technology_cost("artillery-shell-range-7", "(1.25^L)*3000")
alter_technology_effect("artillery-shell-range-7", artillery_range_effect)

-- Matter 1
move_technology(
  "artillery-shell-range-8",
  {"stronger-explosives-12"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-material-science-pack-4"},
  {"se-material-science-pack-3"},
  {"kr-optimization-tech-card","se-material-science-pack-3","kr-singularity-tech-card"}
)
alter_technology_cost("artillery-shell-range-8", "(1.25^L)*3000")
alter_technology_effect("artillery-shell-range-8", artillery_range_effect)

-- DSS 1
move_technology(
  "artillery-shell-range-9",
  {"stronger-explosives-13"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-deep-space-science-pack-1"},
  {"se-material-science-pack-4"},
  {"kr-optimization-tech-card","kr-singularity-tech-card"}
)
alter_technology_cost("artillery-shell-range-9", "(1.25^L)*3000")
alter_technology_effect("artillery-shell-range-9", artillery_range_effect)

-- DSS 2
move_technology(
  "artillery-shell-range-10",
  {"stronger-explosives-14"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-deep-space-science-pack-2"},
  {"se-deep-space-science-pack-1"},
  {"kr-optimization-tech-card","kr-singularity-tech-card"}
)
alter_technology_cost("artillery-shell-range-10", "(1.25^L)*3000")
alter_technology_effect("artillery-shell-range-10", artillery_range_effect)

-- Matter 2
move_technology(
  "artillery-shell-range-11",
  {"stronger-explosives-15"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-kr-matter-science-pack-2","se-deep-space-science-pack-2"},
  nil,
  {"kr-optimization-tech-card","kr-matter-tech-card","se-deep-space-science-pack-1","kr-singularity-tech-card"}
)
alter_technology_cost("artillery-shell-range-11", "(1.25^L)*3000")
alter_technology_effect("artillery-shell-range-11", artillery_range_effect)

-- DSS 3
move_technology(
  "artillery-shell-range-12",
  {"stronger-explosives-16"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-kr-matter-science-pack-2","se-deep-space-science-pack-3"},
  nil,
  {"kr-optimization-tech-card","kr-matter-tech-card","se-deep-space-science-pack-1","kr-singularity-tech-card"}
)
alter_technology_cost("artillery-shell-range-12", "(1.25^L)*3000")
alter_technology_effect("artillery-shell-range-12", artillery_range_effect)

-- Optimisation 3
move_technology(
  "artillery-shell-range-13",
  {"stronger-explosives-17"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-kr-matter-science-pack-2","se-deep-space-science-pack-3"},
  nil,
  {"kr-optimization-tech-card","kr-matter-tech-card","kr-advanced-tech-card","se-deep-space-science-pack-1"}
)
alter_technology_cost("artillery-shell-range-13", "(1.25^L)*3000")
alter_technology_effect("artillery-shell-range-13", artillery_range_effect)

-- DSS 4
move_technology(
  "artillery-shell-range-14",
  nil,
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-kr-matter-science-pack-2","se-deep-space-science-pack-4"},
  nil,
  {"kr-optimization-tech-card","kr-matter-tech-card","kr-advanced-tech-card","se-deep-space-science-pack-1"}
)
alter_technology_cost("artillery-shell-range-14", "(1.25^L)*3000")
alter_technology_effect("artillery-shell-range-14", artillery_range_effect)

---- Artillery Shell Shooting Speed : Material Science ----
-- Base SE
-- PreRocket, Rocket, Space, Utility                         : +100% Speed
-- PreRocket, Rocket, Space, Utility, Production, Mat1       : +100% Speed
-- PreRocket, Rocket, Space, Utility, Production, Mat2       : +100% Speed
-- PreRocket, Rocket, Space, Utility, Production, Mat3       : +100% Speed
-- PreRocket, Rocket, Space, Utility, Production, Mat4       : +100% Speed
-- PreRocket, Rocket, Space, Utility, Production, Mat4, DSS1 : +100% Speed : Total Bonus : +600% Speed

-- Base K2 goes 25% Speed for two levels and then +10% until infinite, this is a massive diference between the two
-- mods, likely due to the additional tiers of artillery shell, and other turrets K2 provides.

-- K2SE -- Much slower than base SE, much faster than base K2.
-- PreRocket, Rocket, Space, Utility                                                     : +30%
-- PreRocket, Rocket, Space, Utility, Production, Optimisation1                          : +30%
-- PreRocket, Rocket, Space, Utility, Production, Optimisation1, Mat1                    : +30%
-- PreRocket, Rocket, Space, Utility, Production, Optimisation1, Mat2                    : +30%
-- PreRocket, Rocket, Space, Utility, Production, Optimisation1, Mat3                    : +30%
-- PreRocket, Rocket, Space, Utility, Production, Optimisation2, Mat3                    : +30%
-- PreRocket, Rocket, Space, Utility, Production, Optimisation2, Mat4                    : +30%
-- PreRocket, Rocket, Space, Utility, Production, Optimisation2, Mat4, Matter 1          : +30%
-- PreRocket, Rocket, Space, Utility, Production, Optimisation2, Mat4, Matter 1, DSS1    : +30% Speed : Total Bonus : 270% Speed
-- PreRocket, Rocket, Space, Utility, Production, Optimisation2, Mat4, Matter 1, DSS2    :
-- PreRocket, Rocket, Space, Utility, Production, Optimisation2, Mat4, Matter 2, DSS2    :
-- PreRocket, Rocket, Space, Utility, Production, Optimisation2, Mat4, Matter 2, DSS3    :
-- PreRocket, Rocket, Space, Utility, Production, Optimisation3, Mat4, Matter 2, DSS3    :
-- PreRocket, Rocket, Space, Utility, Production, Optimisation3, Mat4, Matter 2, DSS4    :

local artillery_speed_effect = {{type="gun-speed", ammo_category="artillery-shell", modifier = 0.30}}

-- Artillery Shell Firing Speed requires seven additional technologies for the tech pack progression
data_util.tech_split_at_levels("artillery-shell-speed",{8,9,10,11,12,13,14})

-- Utility Science
alter_technology_cost("artillery-shell-speed-1", "(1.25^L)*3000")
alter_technology_effect("artillery-shell-speed-1", artillery_speed_effect)

-- Production & Optimization
move_technology(
  "artillery-shell-speed-2",
  {"kr-optimization-tech-card","kr-railgun-turret"},
  {"production-science-pack","kr-optimization-tech-card"},
  {"se-material-science-pack-1"},
  {"se-material-science-pack-1"}
)
alter_technology_cost("artillery-shell-speed-2", "(1.25^L)*3000")
alter_technology_effect("artillery-shell-speed-2", artillery_speed_effect)

-- Material 1
move_technology(
  "artillery-shell-speed-3",
  {"kr-rocket-turret"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-material-science-pack-1"},
  {"kr-advanced-tech-card","kr-matter-tech-card"},
  {"kr-advanced-tech-card","kr-matter-tech-card"}
)
alter_technology_cost("artillery-shell-speed-3", "(1.25^L)*3000")
alter_technology_effect("artillery-shell-speed-3", artillery_speed_effect)

-- Material 2
move_technology(
  "artillery-shell-speed-4",
  {"se-space-accumulator"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-material-science-pack-2"},
  {"se-material-science-pack-1"},
  {"kr-matter-tech-card","kr-advanced-tech-card"}
)
alter_technology_cost("artillery-shell-speed-4", "(1.25^L)*3000")
alter_technology_effect("artillery-shell-speed-4", artillery_speed_effect)

-- Material 3
move_technology(
  "artillery-shell-speed-5",
  {"stronger-explosives-9"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-material-science-pack-3"},
  {"kr-singularity-tech-card"},
  {"kr-matter-tech-card","kr-advanced-tech-card","kr-singularity-tech-card"}
)
alter_technology_cost("artillery-shell-speed-5", "(1.25^L)*3000")
alter_technology_effect("artillery-shell-speed-5", artillery_speed_effect)

-- Optimization 2
move_technology(
  "artillery-shell-speed-6",
  {"stronger-explosives-10"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-material-science-pack-3"},
  {"se-material-science-pack-1"},
  {"kr-matter-tech-card","kr-optimization-tech-card","se-material-science-pack-1","kr-singularity-tech-card"}
)
alter_technology_cost("artillery-shell-speed-6", "(1.25^L)*3000")
alter_technology_effect("artillery-shell-speed-6", artillery_speed_effect)

-- Material 4
move_technology(
  "artillery-shell-speed-7",
  {"stronger-explosives-11"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-material-science-pack-4"},
  {"se-material-science-pack-2"},
  {"kr-matter-tech-card","kr-optimization-tech-card","se-material-science-pack-2","kr-singularity-tech-card"}
)
alter_technology_cost("artillery-shell-speed-7", "(1.25^L)*3000")
alter_technology_effect("artillery-shell-speed-7", artillery_speed_effect)

-- Matter 1
move_technology(
  "artillery-shell-speed-8",
  {"stronger-explosives-12"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-material-science-pack-4"},
  {"se-material-science-pack-3"},
  {"kr-optimization-tech-card","se-material-science-pack-3","kr-singularity-tech-card"}
)
alter_technology_cost("artillery-shell-speed-8", "(1.25^L)*3000")
alter_technology_effect("artillery-shell-speed-8", artillery_speed_effect)

-- DSS 1
move_technology(
  "artillery-shell-speed-9",
  {"stronger-explosives-13"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-deep-space-science-pack-1"},
  {"se-material-science-pack-4"},
  {"kr-optimization-tech-card","kr-singularity-tech-card"}
)
alter_technology_cost("artillery-shell-speed-9", "(1.25^L)*3000")
alter_technology_effect("artillery-shell-speed-9", artillery_speed_effect)

-- DSS 2
move_technology(
  "artillery-shell-speed-10",
  {"stronger-explosives-14"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-deep-space-science-pack-2"},
  {"se-deep-space-science-pack-1"},
  {"kr-optimization-tech-card","kr-singularity-tech-card"}
)
alter_technology_cost("artillery-shell-speed-10", "(1.25^L)*3000")
alter_technology_effect("artillery-shell-speed-10", artillery_speed_effect)

-- Matter 2
move_technology(
  "artillery-shell-speed-11",
  {"stronger-explosives-15"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-kr-matter-science-pack-2","se-deep-space-science-pack-2"},
  nil,
  {"kr-optimization-tech-card","kr-matter-tech-card","se-deep-space-science-pack-1","kr-singularity-tech-card"}
)
alter_technology_cost("artillery-shell-speed-11", "(1.25^L)*3000")
alter_technology_effect("artillery-shell-speed-11", artillery_speed_effect)

-- DSS 3
move_technology(
  "artillery-shell-speed-12",
  {"stronger-explosives-16"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-kr-matter-science-pack-2","se-deep-space-science-pack-3"},
  nil,
  {"kr-optimization-tech-card","kr-matter-tech-card","se-deep-space-science-pack-1","kr-singularity-tech-card"}
)
alter_technology_cost("artillery-shell-speed-12", "(1.25^L)*3000")
alter_technology_effect("artillery-shell-speed-12", artillery_speed_effect)

-- Optimization 3
move_technology(
  "artillery-shell-speed-13",
  {"stronger-explosives-17"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-kr-matter-science-pack-2","se-deep-space-science-pack-3"},
  nil,
  {"kr-optimization-tech-card","kr-advanced-tech-card","kr-matter-tech-card","se-deep-space-science-pack-1"}
)
alter_technology_cost("artillery-shell-speed-13", "(1.25^L)*3000")
alter_technology_effect("artillery-shell-speed-13", artillery_speed_effect)

-- DSS 4
move_technology(
  "artillery-shell-speed-14",
  nil,
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-kr-matter-science-pack-2","se-deep-space-science-pack-4"},
  nil,
  {"kr-optimization-tech-card","kr-advanced-tech-card","kr-matter-tech-card","se-deep-space-science-pack-1"}
)
alter_technology_cost("artillery-shell-speed-14", "(1.25^L)*3000")
alter_technology_effect("artillery-shell-speed-14", artillery_speed_effect)

---- Laser Weapons Damage : Energy Science ----
-- Base SE
-- PreRocket                                                 : +20% Damage
-- PreRocket                                                 : +20% Damage
-- PreRocket, Rocket, Space                                  : +30% Damage
-- PreRocket, Rocket, Space                                  : +40% Damage
-- PreRocket, Rocket, Space, Utility                         : +50% Damage (Sheild +40%)
-- PreRocket, Rocket, Space, Utility, Energy1                : +70% Damage (Shield +60%)
-- PreRocket, Rocket, Space, Utility, Energy2                : +70% Damage (Shield +30%)
-- PreRocket, Rocket, Space, Utility, Energy3                : +70% Damage (Shield +30%)
-- PreRocket, Rocket, Space, Utility, Energy4                : +70% Damage (Shield +30%)
-- PreRocket, Rocket, Space, Utility, Energy4, DSS1          : +70% Damage (Shield +30%) : Total Bonus +510% Damage (Shield +220%)

-- K2SE
-- PreRocket                                                                   : +20%
-- PreRocket                                                                   : +20%
-- PreRocket, Rocket                                                           : +30%
-- PreRocket, Rocket, Space                                                    : +30%
-- PreRocket, Rocket, Space, Utility                                           : +40% (Shield +40%)
-- PreRocket, Rocket, Space, Utility, Optimisation1                            : +40% (Shield +40%)
-- PreRocket, Rocket, Space, Utility, Optimisation1, Energy1                   : +40% (Shield +30%)
-- PreRocket, Rocket, Space, Utility, Optimisation1, Energy2                   : +40% (Shield +30%)
-- PreRocket, Rocket, Space, Utility, Optimisation1, Energy3                   : +50% (Shield +30%)
-- PreRocket, Rocket, Space, Utility, Optimisation2, Energy3                   : +50% (Shield +30%)
-- PreRocket, Rocket, Space, Utility, Optimisation2, Energy4                   : +50% (Shield +30%)
-- PreRocket, Rocket, Space, Utility, Optimisation2, Energy4, Matter 1         : +50% (Shield +30%)
-- PreRocket, Rocket, Space, Utility, Optimisation2, Energy4, Matter 1, DSS1   : +50% Damage (Shield +30%) : Total Bonus : +510% Damage (Shield +290%)
-- PreRocket, Rocket, Space, Utility, Optimisation2, Energy4, Matter 1, DSS2   :
-- PreRocket, Rocket, Space, Utility, Optimisation2, Energy4, Matter 2, DSS2   :
-- PreRocket, Rocket, Space, Utility, Optimisation2, Energy4, Matter 2, DSS3   :
-- PreRocket, Rocket, Space, Utility, Optimisation3, Energy4, Matter 2, DSS3   :
-- PreRocket, Rocket, Space, Utility, Optimisation3, Energy4, Matter 2, DSS4   :

local function make_laser_damage_effect(amount, amount_shield, include_electric)
  local effect ={
    {type = "ammo-damage", ammo_category = "laser", modifier = amount},
    {type = "ammo-damage", ammo_category = "tesla", modifier = amount},
    {type = "ammo-damage", ammo_category = "cryogun", modifier = amount},
    {type = "ammo-damage", ammo_category = "kr-impulse-rifle", modifier = amount},
  }
  if amount_shield then
    table.insert(effect, {type = "ammo-damage", ammo_category = "beam", modifier = amount_shield})
  end
  if include_electric then
    table.insert(effect, {type = "ammo-damage", ammo_category = "electric", modifier = amount})
  end
  return effect
end

local laser_damage_effect_1 = make_laser_damage_effect(0.2)
local laser_damage_effect_2 = make_laser_damage_effect(0.3)
local laser_damage_effect_3 = make_laser_damage_effect(0.4, 0.4)
local laser_damage_effect_4 = make_laser_damage_effect(0.4, 0.3, true)
local laser_damage_effect_5 = make_laser_damage_effect(0.5, 0.3, true)

-- Energy Weapons Damage requies the group at 11-15 to be broken up, and techs after level 12 removed, and to be made infinite again
data_util.tech_split_at_levels("laser-weapons-damage",{12,13,14,15,17,18})

-- PreRocket
move_technology("laser-weapons-damage-1",{"laser-turret"},nil,{"laser","military-science-pack"})
alter_technology_effect("laser-weapons-damage-1", laser_damage_effect_1)

-- PreRocket
alter_technology_effect("laser-weapons-damage-2", laser_damage_effect_1)

-- Rocket
move_technology(
  "laser-weapons-damage-3",
  {"military-4"},
  nil,
  {"space-science-pack"},
  {"space-science-pack"}
)
alter_technology_effect("laser-weapons-damage-3", laser_damage_effect_2)

-- Space
move_technology(
  "laser-weapons-damage-4",
  {"kr-quarry-minerals-extraction"}
)
alter_technology_effect("laser-weapons-damage-4", laser_damage_effect_2)

-- Utility
move_technology(
  "laser-weapons-damage-5",
  {"se-space-laser-laboratory"},
  nil,
  {"utility-science-pack"}
)
alter_technology_effect("laser-weapons-damage-5", laser_damage_effect_3)

-- Optimization 1
move_technology(
  "laser-weapons-damage-6",
  {"kr-optimization-tech-card"},
  {"kr-optimization-tech-card"},
  {"se-energy-science-pack-1"},
  {"se-energy-science-pack-1"}
)
alter_technology_cost("laser-weapons-damage-6", nil, 1000)
alter_technology_effect("laser-weapons-damage-6", laser_damage_effect_3)

-- Energy 1
move_technology(
  "laser-weapons-damage-7",
  {"kr-imersite-weapons"},
  {"kr-optimization-tech-card","se-energy-science-pack-1"},
  {"se-energy-science-pack-2"},
  {"se-energy-science-pack-2"}
)
alter_technology_cost("laser-weapons-damage-7", "0.5*(((L-6)^2)*3000)")
alter_technology_effect("laser-weapons-damage-7", laser_damage_effect_4)

-- Energy 2
move_technology(
  "laser-weapons-damage-8",
  {"kr-personal-laser-defense-mk3-equipment"},
  {"kr-optimization-tech-card","se-energy-science-pack-2"},
  {"se-energy-science-pack-3"},
  {"se-energy-science-pack-3"}
)
alter_technology_cost("laser-weapons-damage-8", "0.4*(((L-6)^2)*3000)")
alter_technology_effect("laser-weapons-damage-8", laser_damage_effect_4)

-- Energy 3
move_technology(
  "laser-weapons-damage-9",
  {"se-energy-beaming"},
  {"kr-optimization-tech-card","se-energy-science-pack-3"},
  {"se-energy-science-pack-4"},
  {"se-energy-science-pack-4"}
)
alter_technology_cost("laser-weapons-damage-9", "0.3*(((L-6)^2)*3000)")
alter_technology_effect("laser-weapons-damage-9", laser_damage_effect_5)

-- Optimization 2
move_technology(
  "laser-weapons-damage-10",
  {"kr-personal-laser-defense-mk4-equipment"},
  {"kr-advanced-tech-card","se-energy-science-pack-3"},
  {"se-deep-space-science-pack-1"},
  {"se-energy-science-pack-4","se-deep-space-science-pack-1"}
)
alter_technology_cost("laser-weapons-damage-10", "0.2*(((L-6)^2)*3000)")
alter_technology_effect("laser-weapons-damage-10", laser_damage_effect_5)

-- Energy 4
move_technology(
  "laser-weapons-damage-11",
  {"se-dynamic-emitter"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack"},
  {"se-deep-space-science-pack-2","kr-matter-tech-card"},
  {"production-science-pack","kr-optimization-tech-card","kr-matter-tech-card","se-deep-space-science-pack-2"}
)
alter_technology_cost("laser-weapons-damage-11", "0.2*(((L-6)^2)*3000)")
alter_technology_effect("laser-weapons-damage-11", laser_damage_effect_5)

-- Matter 1
move_technology(
  "laser-weapons-damage-12",
  {"kr-matter-tech-card"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack"},
  nil,
  {"production-science-pack","kr-optimization-tech-card","se-deep-space-science-pack-2"}
)
alter_technology_cost("laser-weapons-damage-12", "0.4*((1.5^(L-2))*1000)")
alter_technology_effect("laser-weapons-damage-12", laser_damage_effect_5)

-- DSS 1
move_technology(
  "laser-weapons-damage-13",
  {"se-kr-advanced-stream-production"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-deep-space-science-pack-1"},
  nil,
  {"production-science-pack","kr-optimization-tech-card","se-deep-space-science-pack-2"}
)
alter_technology_cost("laser-weapons-damage-13", "0.4*((1.5^(L-2))*1000)")
alter_technology_effect("laser-weapons-damage-13", laser_damage_effect_5)

-- DSS 2
move_technology(
  "laser-weapons-damage-14",
  {"se-arcosphere-folding"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack"},
  nil,
  {"production-science-pack","kr-optimization-tech-card"}
)
alter_technology_cost("laser-weapons-damage-14", "0.4*((1.5^(L-2))*1000)")
alter_technology_effect("laser-weapons-damage-14", laser_damage_effect_5)

-- Matter 2
move_technology(
  "laser-weapons-damage-15",
  {"se-kr-matter-science-pack-2"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-kr-matter-science-pack-2"},
  nil,
  {"production-science-pack","kr-optimization-tech-card","kr-matter-tech-card"}
)
alter_technology_cost("laser-weapons-damage-15", "0.4*((1.5^(L-2))*1000)")
alter_technology_effect("laser-weapons-damage-15", laser_damage_effect_5)

-- DSS 3
move_technology(
  "laser-weapons-damage-16",
  {"kr-energy-storage"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-kr-matter-science-pack-2","se-deep-space-science-pack-3"},
  {"kr-singularity-tech-card","se-deep-space-science-pack-4"},
  {"production-science-pack","kr-optimization-tech-card","kr-matter-tech-card","kr-singularity-tech-card","kr-singularity-tech-card","se-deep-space-science-pack-4"}
)
alter_technology_cost("laser-weapons-damage-16", "0.4*((1.5^(L-2))*1000)")
alter_technology_effect("laser-weapons-damage-16", laser_damage_effect_5)

-- Optimization 3
move_technology(
  "laser-weapons-damage-17",
  {"kr-singularity-tech-card"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-kr-matter-science-pack-2","se-deep-space-science-pack-3"},
  nil,
  {"production-science-pack","kr-optimization-tech-card","kr-advanced-tech-card","kr-matter-tech-card","se-deep-space-science-pack-4"}
)
alter_technology_cost("laser-weapons-damage-17", "0.4*((1.5^(L-2))*1000)")
alter_technology_effect("laser-weapons-damage-17", laser_damage_effect_5)

-- DSS 4
move_technology(
  "laser-weapons-damage-18",
  {"se-deep-space-science-pack-4"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-kr-matter-science-pack-2"},
  nil,
  {"production-science-pack","kr-optimization-tech-card","kr-advanced-tech-card","kr-matter-tech-card"}
)
alter_technology_cost("laser-weapons-damage-18", "0.4*((1.5^(L-2))*1000)")
alter_technology_effect("laser-weapons-damage-18", laser_damage_effect_5)

---- Mining Productivity : Biological Science ----
-- Base SE
-- PreRocket                                                 : +10% Prod
-- PreRocket                                                 : +10% Prod
-- PreRocket, Rocket, Space                                  : +10% Prod
-- PreRocket, Rocket, Space, Production                      : +10% Prod
-- PreRocket, Rocket, Space, Production                      : +10% Prod
-- PreRocket, Rocket, Space, Production, Bio1                : +10% Prod
-- PreRocket, Rocket, Space, Production, Bio2                : +10% Prod
-- PreRocket, Rocket, Space, Production, Bio3                : +10% Prod
-- PreRocket, Rocket, Space, Production, Bio4                : +10% Prod
-- PreRocket, Rocket, Space, Production, Bio1, DSS1          : +10% Prod
-- PreRocket, Rocket, Space, Production, Bio1, DSS2          : +10% Prod
-- PreRocket, Rocket, Space, Production, Bio1, DSS3          : +10% Prod
-- PreRocket, Rocket, Space, Production, Bio1, DSS4          : +10% Prod

-- K2SE
-- PreRocket                                                                   : +10%
-- PreRocket                                                                   : +10%
-- PreRocket, Rocket, Space                                                    : +10%
-- PreRocket, Rocket, Space, Production                                        : +10%
-- PreRocket, Rocket, Space, Production, Optimisation1                         : +10%
-- PreRocket, Rocket, Space, Production, Optimisation1, Bio1                   : +10%
-- PreRocket, Rocket, Space, Production, Optimisation1, Bio2                   : +10%
-- PreRocket, Rocket, Space, Production, Optimisation1, Bio3                   : +10%
-- PreRocket, Rocket, Space, Production, Optimisation2, Bio3                   : +10%
-- PreRocket, Rocket, Space, Production, Optimisation2, Bio4                   : +10%
-- PreRocket, Rocket, Space, Production, Optimisation2, Bio4, Matter 1         : +10%
-- PreRocket, Rocket, Space, Production, Optimisation2, Bio4, Matter 1, DSS1   : +10% Prod
-- PreRocket, Rocket, Space, Production, Optimisation2, Bio4, Matter 1, DSS2   :
-- PreRocket, Rocket, Space, Production, Optimisation2, Bio4, Matter 2, DSS2   :
-- PreRocket, Rocket, Space, Production, Optimisation2, Bio4, Matter 2, DSS3   :
-- PreRocket, Rocket, Space, Production, Optimisation3, Bio4, Matter 2, DSS3   :
-- PreRocket, Rocket, Space, Production, Optimisation3, Bio4, Matter 2, DSS4   :

-- Mining Productivity requires the group at 13-15 to be broken up, and 17 needs to be added.
data_util.tech_split_at_levels("mining-productivity",{14,15,17})

-- PreRocket
alter_technology_cost("mining-productivity-1", "(L^2)*200")

-- PreRocket
move_technology("mining-productivity-2",{"kr-electric-mining-drill-mk2"},nil,{"chemicla-science-pack"})
alter_technology_cost("mining-productivity-2", "(L^2)*200")

-- Rocket, Space
move_technology(
  "mining-productivity-3",
  {"kr-quarry-minerals-extraction"},
  nil,
  {"utility-science-pack","production-science-pack"}
)
alter_technology_cost("mining-productivity-3", "(L^2)*200")

-- Production
move_technology(
  "mining-productivity-4",
  {"area-mining-drill"},
  nil,
  {"production-science-pack"}
)
alter_technology_cost("mining-productivity-4", "(max((L-3), 1)^1.25)*2000")

-- Optimization 1
move_technology(
  "mining-productivity-5",
  {"kr-optimization-tech-card"},
  {"kr-optimization-tech-card"}
)
alter_technology_cost("mining-productivity-5", "(max((L-3), 1)^1.25)*2000")

-- Bio 1
move_technology(
  "mining-productivity-6",
  {"se-vitalic-acid"},
  {"kr-optimization-tech-card"},
  {"se-biological-science-pack-1"}
)
alter_technology_cost("mining-productivity-6", "(max((L-3), 1)^1.25)*2000")

-- Bio 2
move_technology(
  "mining-productivity-7",
  {"se-vitalic-reagent"},
  {"kr-optimization-tech-card"},
  {"se-biological-science-pack-2"}
)
alter_technology_cost("mining-productivity-7", "(max((L-3), 1)^1.25)*2000")

-- Bio 3
move_technology(
  "mining-productivity-8",
  {"se-vitalic-epoxy"},
  {"kr-optimization-tech-card"},
  {"se-biological-science-pack-3"}
)
alter_technology_cost("mining-productivity-8", "(max((L-3), 1)^1.25)*2000")

-- Optimization 2
move_technology(
  "mining-productivity-9",
  {"kr-advanced-tech-card"},
  {"kr-advanced-tech-card","se-biological-science-pack-3"},
  {"se-biological-science-pack-4"},
  {"se-biological-science-pack-4"}
)
alter_technology_cost("mining-productivity-9", "(max((L-3), 1)^1.25)*2000")

-- Bio 4
move_technology(
  "mining-productivity-10",
  {"se-self-sealing-gel"},
  {"kr-advanced-tech-card","se-biological-science-pack-4"},
  {"se-deep-space-science-pack-1"},
  {"se-deep-space-science-pack-1"}
)
alter_technology_cost("mining-productivity-10", "(max((L-3), 1)^1.25)*2000")

-- Matter 1
move_technology(
  "mining-productivity-11",
  {"kr-matter-tech-card"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack"},
  {"se-deep-space-science-pack-2"},
  {"utility-science-pack","kr-optimization-tech-card","se-deep-space-science-pack-2"}
)
alter_technology_cost("mining-productivity-11", "(max((L-3), 1)^1.25)*2000")

-- DSS 1
move_technology(
  "mining-productivity-12",
  {"se-kr-advanced-stream-production"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","se-deep-space-science-pack-1"},
  {"se-deep-space-science-pack-3"},
  {"utility-science-pack","kr-optimization-tech-card","se-deep-space-science-pack-3"}
)
alter_technology_cost("mining-productivity-12", "(max((L-3), 1)^1.25)*2000")

-- DSS 2
move_technology(
  "mining-productivity-13",
  {"se-arcosphere-folding"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","se-deep-space-science-pack-2"},
  {"se-deep-space-science-pack-4"},
  {"utility-science-pack","kr-optimization-tech-card","se-deep-space-science-pack-4"}
)
alter_technology_cost("mining-productivity-13", "(max((L-3), 1)^1.25)*2000")

-- Matter 2
move_technology(
  "mining-productivity-14",
  {"se-kr-matter-science-pack-2"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","se-kr-matter-science-pack-2","se-deep-space-science-pack-2"},
  nil, --{"se-deep-space-scinec-pack-4"},
  {"utility-science-pack","kr-optimization-tech-card","kr-matter-tech-card","se-deep-space-science-pack-4"}
)
alter_technology_cost("mining-productivity-14", "(max((L-3), 1)^1.25)*2000")

-- DSS 3
move_technology(
  "mining-productivity-15",
  {"se-naquium-processor"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","se-kr-matter-science-pack-2","se-deep-space-science-pack-3"},
  nil,
  {"utility-science-pack","kr-optimization-tech-card","kr-matter-tech-card","se-deep-space-science-pack-4"}
)
alter_technology_cost("mining-productivity-15", "(max((L-3), 1)^1.25)*2000")

-- Optimization 3
move_technology(
  "mining-productivity-16",
  nil,
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","se-biological-science-pack-4","se-kr-matter-science-pack-2","se-deep-space-science-pack-3"},
  nil,
  {"utility-science-pack","kr-optimization-tech-card","kr-advanced-tech-card","kr-matter-tech-card"}
)
alter_technology_cost("mining-productivity-16", "(max((L-3), 1)^1.25)*2000")

-- DSS 4
move_technology(
  "mining-productivity-17",
  {"se-deep-space-science-pack-4"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","se-biological-science-pack-4","se-kr-matter-science-pack-2","se-deep-space-science-pack-4"},
  nil,
  {"utility-science-pack","kr-optimization-tech-card","kr-advanced-tech-card","kr-matter-tech-card"}
)
alter_technology_cost("mining-productivity-17", "(max((L-3), 1)^1.25)*2000")

---- Worker Robots Speed : Energy Science ----
-- Base SE
-- PreRocket                                                 : +35% Speed
-- PreRocket                                                 : +40% Speed
-- PreRocket, Rocket, Space                                  : +45% Speed
-- PreRocket, Rocket, Space                                  : +55% Speed
-- PreRocket, Rocket, Space, Utility                         : +65% Speed
-- PreRocket, Rocket, Space, Utility, Energy1                : +65% Speed
-- PreRocket, Rocket, Space, Utility, Energy2                : +65% Speed
-- PreRocket, Rocket, Space, Utility, Energy3                : +65% Speed
-- PreRocket, Rocket, Space, Utility, Energy4                : +65% Speed
-- PreRocket, Rocket, Space, Utility, Energy4, DSS1          : +65% Speed

-- K2SE
-- PreRocket                                                                   : +30%
-- PreRocket                                                                   : +35%
-- PreRocket, Rocket                                                           : +35%
-- PreRocket, Rocket, Space                                                    : +40%
-- PreRocket, Rocket, Space, Utility                                           : +40%
-- PreRocket, Rocket, Space, Utility, Optimisation1                            : +45%
-- PreRocket, Rocket, Space, Utility, Optimisation1, Energy1                   : +45%
-- PreRocket, Rocket, Space, Utility, Optimisation1, Energy2                   : +50%
-- PreRocket, Rocket, Space, Utility, Optimisation1, Energy3                   : +50%
-- PreRocket, Rocket, Space, Utility, Optimisation2, Energy3                   : +55%
-- PreRocket, Rocket, Space, Utility, Optimisation2, Energy4                   : +55%
-- PreRocket, Rocket, Space, Utility, Optimisation2, Energy4, Matter 1         : +60%
-- PreRocket, Rocket, Space, Utility, Optimisation2, Energy4, Matter 1, DSS1   : +60% Speed : Total : +600% Speed
-- PreRocket, Rocket, Space, Utility, Optimisation2, Energy4, Matter 1, DSS2   :
-- PreRocket, Rocket, Space, Utility, Optimisation2, Energy4, Matter 2, DSS2   :
-- PreRocket, Rocket, Space, Utility, Optimisation2, Energy4, Matter 2, DSS3   :
-- PreRocket, Rocket, Space, Utility, Optimisation3, Energy4, Matter 2, DSS3   :
-- PreRocket, Rocket, Space, Utility, Optimisation3, Energy4, Matter 2, DSS4   :

-- Worker Robot Speed requires eight levels added
data_util.tech_split_at_levels("worker-robots-speed",{11,12,13,14,15,16,17,18})

-- Function to make effect
local function worker_robot_speed_effect(modifier)
  return {
    {type = "worker-robot-speed", modifier = modifier}
  }
end

-- PreRocket
alter_technology_effect("worker-robots-speed-1", worker_robot_speed_effect(0.3))

-- PreRocket
alter_technology_effect("worker-robots-speed-2", worker_robot_speed_effect(0.35))

-- Rocket
move_technology(
  "worker-robots-speed-3",
  {"se-thruster-suit"},
  nil,
  {"space-science-pack","utility-science-pack"},
  {"space-science-pack","utility-science-pack"}
)
alter_technology_effect("worker-robots-speed-3", worker_robot_speed_effect(0.35))

-- Space
move_technology(
  "worker-robots-speed-4",
  {"logistics-3"},
  nil,
  {"utility-science-pack"},
  {"utility-science-pack"}
)
alter_technology_effect("worker-robots-speed-4", worker_robot_speed_effect(0.4))

-- Utility
move_technology(
  "worker-robots-speed-5",
  {"kr-advanced-additional-engine-equipment"},
  nil,
  {"utility-science-pack","production-science-pack"},
  {"production-science-pack"}
)
alter_technology_effect("worker-robots-speed-5", worker_robot_speed_effect(0.4))

-- Optimization
move_technology(
  "worker-robots-speed-6",
  {"kr-optimization-tech-card"},
  {"kr-optimization-tech-card"},
  {"se-energy-science-pack-1"},
  {"se-energy-science-pack-1"}
)
alter_technology_cost("worker-robots-speed-6", "0.6*((2^(L-6))*1000)")
alter_technology_effect("worker-robots-speed-6", worker_robot_speed_effect(0.45))

-- Energy 1
move_technology(
  "worker-robots-speed-7",
  {"kr-energy-control-unit"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","se-energy-science-pack-1"},
  {"kr-advanced-tech-card","se-energy-science-pack-2","kr-matter-tech-card"},
  {"production-science-pack","kr-advanced-tech-card","kr-matter-tech-card","se-energy-science-pack-2"}
)
alter_technology_cost("worker-robots-speed-7", "0.6*((2^(L-6))*1000)")
alter_technology_effect("worker-robots-speed-7", worker_robot_speed_effect(0.45))

-- Energy 2
move_technology(
  "worker-robots-speed-8",
  {"fission-reactor-equipment"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","se-energy-science-pack-2"},
  {"se-energy-science-pack-3"},
  {"production-science-pack","kr-advanced-tech-card","kr-matter-tech-card"}
)
alter_technology_cost("worker-robots-speed-8", "0.6*((2^(L-6))*1000)")
alter_technology_effect("worker-robots-speed-8", worker_robot_speed_effect(0.5))

-- Energy 3
move_technology(
  "worker-robots-speed-9",
  {"se-superconductive-cable"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","se-energy-science-pack-3"},
  {"se-energy-science-pack-4","kr-singularity-tech-card"},
  {"production-science-pack","kr-advanced-tech-card","kr-matter-tech-card","se-energy-science-pack-4","kr-singularity-tech-card"}
)
alter_technology_cost("worker-robots-speed-9", "0.6*((2^(L-6))*1000)")
alter_technology_effect("worker-robots-speed-9", worker_robot_speed_effect(0.5))

-- Optimization 2
move_technology(
  "worker-robots-speed-10",
  {"kr-advanced-tech-card"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","se-energy-science-pack-3"},
  {"se-deep-space-science-pack-1","se-energy-science-pack-4"},
  {"production-science-pack","kr-optimization-tech-card","kr-matter-tech-card","se-deep-space-science-pack-1","kr-singularity-tech-card"}
)
alter_technology_cost("worker-robots-speed-10", "0.6*((1.5^(L-4))*1000)")
alter_technology_effect("worker-robots-speed-10", worker_robot_speed_effect(0.55))

-- Energy 4
move_technology(
  "worker-robots-speed-11",
  {"se-fusion-reactor-equipment"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack"},
  nil,
  {"production-science-pack","kr-optimization-tech-card","kr-matter-tech-card","se-deep-space-science-pack-1","kr-singularity-tech-card"}
)
alter_technology_cost("worker-robots-speed-11", "0.6*((1.5^(L-4))*1000)")
alter_technology_effect("worker-robots-speed-11", worker_robot_speed_effect(0.55))

-- Matter 1
move_technology(
  "worker-robots-speed-12",
  {"kr-matter-tech-card"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack"},
  nil,
  {"production-science-pack","kr-optimization-tech-card","se-deep-space-science-pack-1","kr-singularity-tech-card"}
)
alter_technology_cost("worker-robots-speed-12", "0.6*((1.5^(L-4))*1000)")
alter_technology_effect("worker-robots-speed-12", worker_robot_speed_effect(0.6))

-- DSS 1
move_technology(
  "worker-robots-speed-13",
  {"se-space-accumulator-2"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack"},
  nil,
  {"production-science-pack","kr-optimization-tech-card","kr-singularity-tech-card"}
)
alter_technology_cost("worker-robots-speed-13", "0.6*((1.5^(L-4))*1000)")
alter_technology_effect("worker-robots-speed-13", worker_robot_speed_effect(0.6))

-- DSS 2
move_technology(
  "worker-robots-speed-14",
  {"se-deep-space-transport-belt"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","se-deep-space-science-pack-2"},
  nil,
  {"production-science-pack","kr-optimization-tech-card","se-deep-space-science-pack-1","kr-singularity-tech-card"}
)
alter_technology_cost("worker-robots-speed-14", "0.6*((1.5^(L-4))*1000)")
alter_technology_effect("worker-robots-speed-14", worker_robot_speed_effect(0.6))

-- Matter 2
move_technology(
  "worker-robots-speed-15",
  {"se-kr-matter-science-pack-2"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","se-kr-matter-science-pack-2","se-deep-space-science-pack-2"},
  nil,
  {"production-science-pack","kr-optimization-tech-card","kr-matter-tech-card","se-deep-space-science-pack-1","kr-singularity-tech-card"}
)
alter_technology_cost("worker-robots-speed-15", "0.6*((1.5^(L-4))*1000)")
alter_technology_effect("worker-robots-speed-15", worker_robot_speed_effect(0.6))

-- DSS 3
move_technology(
  "worker-robots-speed-16",
  {"kr-energy-storage"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","se-kr-matter-science-pack-2","se-deep-space-science-pack-3"},
  nil,
  {"production-science-pack","kr-optimization-tech-card","kr-matter-tech-card","se-deep-space-science-pack-1","kr-singularity-tech-card"}
)
alter_technology_cost("worker-robots-speed-16", "0.6*((1.5^(L-4))*1000)")
alter_technology_effect("worker-robots-speed-16", worker_robot_speed_effect(0.6))

-- Optimization 3
move_technology(
  "worker-robots-speed-17",
  {"kr-antimatter-reactor-equipment"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","se-kr-matter-science-pack-2","se-deep-space-science-pack-3"},
  nil,
  {"production-science-pack","kr-optimization-tech-card","kr-advanced-tech-card","kr-matter-tech-card","se-deep-space-science-pack-1"}
)
alter_technology_cost("worker-robots-speed-17", "0.6*((1.5^(L-4))*1000)")
alter_technology_effect("worker-robots-speed-17", worker_robot_speed_effect(0.6))

-- DSS 4
move_technology(
  "worker-robots-speed-18",
  {"se-deep-space-science-pack-4"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","se-kr-matter-science-pack-2","se-deep-space-science-pack-4"},
  nil,
  {"production-science-pack","kr-optimization-tech-card","kr-matter-tech-card","se-deep-space-science-pack-1","kr-singularity-tech-card"}
)
alter_technology_cost("worker-robots-speed-18", "0.6*((1.5^(L-4))*1000)")
alter_technology_effect("worker-robots-speed-18", worker_robot_speed_effect(0.6))


---- Projectile Physical Damage : Material Science ----
-- Base SE
-- PreRocket                                                 : +10% Damage
-- PreRocket                                                 : +10% Damage
-- PreRocket                                                 : +20% Damage
-- PreRocket                                                 : +20% Damage
-- PreRocket, Rocket, Space                                  : +20% Damage (Cannon +90%)
-- PreRocket, Rocket, Space, Utility, Production, Mat1       : +40% Damage (Cannon +130%)
-- PreRocket, Rocket, Space, Utility, Production, Mat2       : +40% Damage (Cannon +100%, Gun Turret 70%)
-- PreRocket, Rocket, Space, Utility, Production, Mat3       : +40% Damage (Cannon +100%, Gun Turret 70%)
-- PreRocket, Rocket, Space, Utility, Production, Mat4       : +40% Damage (Cannon +100%, Gun Turret 70%)
-- PreRocket, Rocket, Space, Utility, Production, Mat4, DSS1 : +40% Damage (Cannon +100%, Gun Turret 70%)

-- K2 raises the increase per level to +25% at the starting levels but lowers it at the later levels, as such
-- we decrease the gain per level back down early on, raise it back to just bellow SE due to the greater
-- number of levels present in the SE-K2 tech progression.

-- K2SE
-- PreRocket                                                                           : +10% Damage
-- PreRocket                                                                           : +10% Damage
-- PreRocket                                                                           : +20% Damage
-- PreRocket                                                                           : +20% Damage
-- PreRocket, Rocket, Space                                                            : +20% (Cannon +90%)
-- PreRocket, Rocket, Space, Utility, Production                                       : +20% (Cannon +80%)
-- PreRocket, Rocket, Space, Utility, Production, Optimisation1                        : +20% (Cannon +80%)
-- PreRocket, Rocket, Space, Utility, Production, Optimisation1, Mat1                  : +20% (Cannon +80%)
-- PreRocket, Rocket, Space, Utility, Production, Optimisation1, Mat2                  : +20% (Cannon +70%, Gun Turret 70%)
-- PreRocket, Rocket, Space, Utility, Production, Optimisation1, Mat3                  : +20% (Cannon +70%, Gun Turret 70%)
-- PreRocket, Rocket, Space, Utility, Production, Optimisation2, Mat3                  : +20% (Cannon +70%, Gun Turret 70%)
-- PreRocket, Rocket, Space, Utility, Production, Optimisation2, Mat4, Matter 1        : +30% (Cannon +60%, Gun Turret 60%) Mat4 and Matter1 so that it can have Nanomaterial as prereq
-- PreRocket, Rocket, Space, Utility, Production, Optimisation2, Mat4, Matter 1, DSS1  : +30% (Cannon +60%, Gun Turret 60%)
-- PreRocket, Rocket, Space, Utility, Production, Optimisation2, Mat4, Matter 1, DSS2  :
-- PreRocket, Rocket, Space, Utility, Production, Optimisation2, Mat4, Matter 2, DSS2  :
-- PreRocket, Rocket, Space, Utility, Production, Optimisation2, Mat4, Matter 2, DSS3  :
-- PreRocket, Rocket, Space, Utility, Production, Optimisation3, Mat4, Matter 2, DSS3  :
-- PreRocket, Rocket, Space, Utility, Production, Optimisation3, Mat4, Matter 2, DSS4  :

-- Effects table
local function physical_projectile_damage_effect(modifier, modifier_turret, modifier_cannon)
  local effect = {
    {type = "ammo-damage", ammo_category = "bullet", modifier = modifier},
    {type = "turret-attack", turret_id = "gun-turret", modifier = modifier_turret},
    {type = "ammo-damage", ammo_category = "shotgun-shell", modifier = modifier},
    {type = "ammo-damage", ammo_category = "railgun", modifier = modifier},
    {type = "ammo-damage", ammo_category = "artillery-shell", modifier = modifier},
    {type = "ammo-damage", ammo_category = "cannon-shell", modifier = modifier_cannon},
    {type = "ammo-damage", ammo_category = "kr-railgun-shell", modifier = modifier}
  }
  if settings.startup["kr-realistic-weapons"].value then
    table.insert(effect, {type = "ammo-damage", ammo_category = "kr-pistol", modifier = modifier})
    table.insert(effect, {type = "ammo-damage", ammo_category = "kr-anti-materiel-rifle-ammo", modifier = modifier})
  end
  return effect
end

-- Physical Projectile Damage requires the group at 11-15 to be broken up, and two techs added
data_util.tech_split_at_levels("physical-projectile-damage",{12,13,14,15,16,17,18})
make_tech_infinite("physical-projectile-damage")

-- PreRocket levels
alter_technology_effect("physical-projectile-damage-1", physical_projectile_damage_effect(0.1,0.1,0.1))
--
move_technology("physical-projectile-damage-2",{"military-2"},nil,{"logistic-science-pack"})
alter_technology_effect("physical-projectile-damage-2", physical_projectile_damage_effect(0.1,0.1,0.1))
--
move_technology("physical-projectile-damage-3",{"defender"},nil,{"military-science-pack"})
alter_technology_effect("physical-projectile-damage-3", physical_projectile_damage_effect(0.2,0.2,0.2))
--
move_technology("physical-projectile-damage-4",{"military-3"},nil,{"chemical-science-pack"})
alter_technology_effect("physical-projectile-damage-4", physical_projectile_damage_effect(0.2,0.2,0.2))

-- Rocket Science
move_technology(
  "physical-projectile-damage-5",
  {"uranium-ammo"},
  nil,
  {"space-science-pack"}
)
alter_technology_effect("physical-projectile-damage-5", physical_projectile_damage_effect(0.2,0.2,0.9))

-- Production, Utility
move_technology(
  "physical-projectile-damage-6",
  {"kr-railgun-turret"},
  nil,
  {"se-material-science-pack-1"},
  {"se-material-science-pack-1"}
)
alter_technology_cost("physical-projectile-damage-6", nil, 1000)
alter_technology_effect("physical-projectile-damage-6", physical_projectile_damage_effect(0.2,0.2,0.8))

-- Optimization 1
move_technology(
  "physical-projectile-damage-7",
  {"kr-optimization-tech-card"},
  {"kr-optimization-tech-card"},
  {"se-material-science-pack-2"},
  {"se-material-science-pack-2"}
)
alter_technology_cost("physical-projectile-damage-7", "0.5*(((L-6)^2)*3000)")
alter_technology_effect("physical-projectile-damage-7", physical_projectile_damage_effect(0.2,0.2,0.8))

-- Material 1
move_technology(
  "physical-projectile-damage-8",
  {"se-railgun"},
  {"kr-optimization-tech-card","se-material-science-pack-1"},
  {"se-material-science-pack-3"},
  {"se-material-science-pack-3"}
)
alter_technology_cost("physical-projectile-damage-8", "0.4*(((L-6)^2)*3000)")
alter_technology_effect("physical-projectile-damage-8", physical_projectile_damage_effect(0.2,0.2,0.8))

-- Material 2
move_technology(
  "physical-projectile-damage-9",
  {"se-heavy-bearing"},
  {"kr-optimization-tech-card","se-material-science-pack-2"},
  {"se-material-science-pack-4"},
  {"se-material-science-pack-4"}
)
alter_technology_cost("physical-projectile-damage-9", "0.3*(((L-6)^2)*3000)")
alter_technology_effect("physical-projectile-damage-9", physical_projectile_damage_effect(0.2,0.7,0.7))

-- Material 3
move_technology(
  "physical-projectile-damage-10",
  {"se-heavy-composite"},
  {"kr-optimization-tech-card","se-material-science-pack-3"},
  {"se-deep-space-science-pack-1"},
  {"se-material-science-pack-4","se-deep-space-science-pack-1"}
)
alter_technology_cost("physical-projectile-damage-10", "0.2*(((L-6)^2)*3000)")
alter_technology_effect("physical-projectile-damage-10", physical_projectile_damage_effect(0.2,0.7,0.7))

-- Optimization 2
move_technology(
  "physical-projectile-damage-11",
  {"kr-power-armor-mk4"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-material-science-pack-3"},
  {"se-deep-space-science-pack-2","kr-matter-tech-card"},
  {"kr-optimization-tech-card","se-material-science-pack-4","kr-matter-tech-card","se-deep-space-science-pack-2"}
)
alter_technology_cost("physical-projectile-damage-11", "0.2*(((L-6)^2)*3000)")
alter_technology_effect("physical-projectile-damage-11", physical_projectile_damage_effect(0.2,0.7,0.7))

-- Material 4, Matter 1
move_technology(
  "physical-projectile-damage-12",
  {"se-nanomaterial"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-material-science-pack-4"},
  nil,
  {"kr-optimization-tech-card","se-deep-space-science-pack-2"}
)
alter_technology_cost("physical-projectile-damage-12", "0.4*((1.5^(L-2))*1000)")
alter_technology_effect("physical-projectile-damage-12", physical_projectile_damage_effect(0.2,0.6,0.6))

-- DSS 1
move_technology(
  "physical-projectile-damage-13",
  {"se-naquium-cube"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-material-science-pack-4","se-deep-space-science-pack-1"},
  nil,
  {"kr-optimization-tech-card","se-deep-space-science-pack-2"}
)
alter_technology_cost("physical-projectile-damage-13", "0.4*((1.5^(L-2))*1000)")
alter_technology_effect("physical-projectile-damage-13", physical_projectile_damage_effect(0.2,0.6,0.6))

-- DSS 2
move_technology(
  "physical-projectile-damage-14",
  {"se-arcosphere-folding"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-material-science-pack-4"},
  nil,
  {"kr-optimization-tech-card"}
)
alter_technology_cost("physical-projectile-damage-14", "0.4*((1.5^(L-2))*1000)")
alter_technology_effect("physical-projectile-damage-14", physical_projectile_damage_effect(0.2,0.6,0.6))

-- Matter 2
move_technology(
  "physical-projectile-damage-15",
  {"se-kr-matter-science-pack-2"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-material-science-pack-4","se-kr-matter-science-pack-2","se-deep-space-science-pack-2"},
  {"kr-singularity-tech-card","se-deep-space-science-pack-4"},
  {"kr-optimization-tech-card","kr-matter-tech-card","kr-singularity-tech-card","se-deep-space-science-pack-4"}
)
alter_technology_cost("physical-projectile-damage-15", "0.4*((1.5^(L-2))*1000)")
alter_technology_effect("physical-projectile-damage-15", physical_projectile_damage_effect(0.2,0.6,0.6))

-- DSS 3
move_technology(
  "physical-projectile-damage-16",
  {"se-naquium-processor"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-material-science-pack-4","se-kr-matter-science-pack-2","se-deep-space-science-pack-3"},
  nil,
  {"kr-optimization-tech-card","kr-matter-tech-card","kr-singularity-tech-card","se-deep-space-science-pack-4"}
)
alter_technology_cost("physical-projectile-damage-16", "0.4*((1.5^(L-2))*1000)")
alter_technology_effect("physical-projectile-damage-16", physical_projectile_damage_effect(0.2,0.6,0.6))

-- Optimization 3
move_technology(
  "physical-projectile-damage-17",
  {"kr-singularity-tech-card"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-material-science-pack-4","se-kr-matter-science-pack-2","se-deep-space-science-pack-3"},
  nil,
  {"kr-optimization-tech-card","kr-advanced-tech-card","kr-matter-tech-card","se-deep-space-science-pack-4"}
)
alter_technology_cost("physical-projectile-damage-17", "0.4*((1.5^(L-2))*1000)")
alter_technology_effect("physical-projectile-damage-17", physical_projectile_damage_effect(0.2,0.6,0.6))

-- DSS 4
move_technology(
  "physical-projectile-damage-18",
  {"se-deep-space-science-pack-4"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-material-science-pack-4","se-kr-matter-science-pack-2"},
  nil,
  {"kr-optimization-tech-card","kr-advanced-tech-card","kr-matter-tech-card"}
)
alter_technology_cost("physical-projectile-damage-18", "0.4*((1.5^(L-2))*1000)")
alter_technology_effect("physical-projectile-damage-18", physical_projectile_damage_effect(0.2,0.6,0.6))

---- Refined Flammables : Material Science ----
-- Base SE
-- PreRocket                                                 : +20% Damage
-- PreRocket                                                 : +20% Damage
-- PreRocket                                                 : +20% Damage
-- PreRocket, Rocket, Space                                  : +30% Damage
-- PreRocket, Rocket, Space, Production                      : +30% Damage
-- PreRocket, Rocket, Space, Production, Mat1                : +40% Damage
-- PreRocket, Rocket, Space, Production, Mat2                : +20% Damage
-- PreRocket, Rocket, Space, Production, Mat3                : +20% Damage
-- PreRocket, Rocket, Space, Production, Mat4                : +20% Damage
-- PreRocket, Rocket, Space, Production, Mat4, DSS1          : +20% Damage

-- K2SE
-- PreRocket                                                                   : +20% Damage
-- PreRocket                                                                   : +20% Damage
-- PreRocket                                                                   : +20% Damage
-- PreRocket, Rocket, Space                                                    : +20% Damage
-- PreRocket, Rocket, Space, Production                                        : +20% Damage
-- PreRocket, Rocket, Space, Production, Optimisation1                         : +20% Damage
-- PreRocket, Rocket, Space, Production, Optimisation1, Mat1                   : +20% Damage
-- PreRocket, Rocket, Space, Production, Optimisation1, Mat2                   : +20% Damage
-- PreRocket, Rocket, Space, Production, Optimisation1, Mat3                   : +20% Damage
-- PreRocket, Rocket, Space, Production, Optimisation2, Mat3                   : +20% Damage
-- PreRocket, Rocket, Space, Production, Optimisation2, Mat4                   : +20% Damage
-- PreRocket, Rocket, Space, Production, Optimisation2, Mat4, Matter 1         : +20% Damage
-- PreRocket, Rocket, Space, Production, Optimisation2, Mat4, Matter 1, DSS1   : +20% Damage : Total : +260% Damage
-- PreRocket, Rocket, Space, Production, Optimisation2, Mat4, Matter 1, DSS2   :
-- PreRocket, Rocket, Space, Production, Optimisation2, Mat4, Matter 2, DSS2   :
-- PreRocket, Rocket, Space, Production, Optimisation2, Mat4, Matter 2, DSS3   :
-- PreRocket, Rocket, Space, Production, Optimisation3, Mat4, Matter 2, DSS3   :
-- PreRocket, Rocket, Space, Production, Optimisation3, Mat4, Matter 2, DSS4   :

-- Refined Flammables effect
local function refined_flammables_effect(modifier)
  return {
    {type = "ammo-damage", ammo_category = "flamethrower", modifier = modifier},
    {type = "turret-attack", turret_id = "flamethrower-turret", modifier = modifier},
  }
end

-- Refined Flammables requires the group at 11-15 to be broken up, and two techs added
data_util.tech_split_at_levels("refined-flammables",{12,13,14,15,16,17,18})

-- PreRocket
alter_technology_effect("refined-flammables-1", refined_flammables_effect(0.2))
alter_technology_effect("refined-flammables-2", refined_flammables_effect(0.2))
--
move_technology("refined-flammables-3",{"jetpack-1"},nil,{"chemical-science=pack"})
alter_technology_effect("refined-flammables-3", refined_flammables_effect(0.2))

-- Rocket
move_technology(
  "refined-flammables-4",
  {"jetpack-2"},
  nil,
  {"space-science-pack"}
)
alter_technology_effect("refined-flammables-4", refined_flammables_effect(0.2))

-- Production
move_technology(
  "refined-flammables-5",
  {"coal-liquefaction"},
  nil,
  {"production-science-pack"}
)
alter_technology_effect("refined-flammables-5", refined_flammables_effect(0.2))

-- Optimisation 1
move_technology(
  "refined-flammables-6",
  {"kr-optimization-tech-card"},
  {"kr-optimization-tech-card"},
  {"se-material-science-pack-1"},
  {"se-material-science-pack-1"}
)
alter_technology_cost("refined-flammables-6", nil, 1000)
alter_technology_effect("refined-flammables-6", refined_flammables_effect(0.2))

-- Material 1
move_technology(
  "refined-flammables-7",
  {"se-thruster-suit-2"},
  {"kr-optimization-tech-card","se-material-science-pack-1"},
  {"se-material-science-pack-2"},
  {"utility-science-pack","se-material-science-pack-2"}
)
alter_technology_cost("refined-flammables-7", "0.5*(((L-6)^2)*3000)")
alter_technology_effect("refined-flammables-7", refined_flammables_effect(0.2))

-- Material 2
move_technology(
  "refined-flammables-8",
  {"se-material-science-pack-2"}, -- There isn't really a good other option for this
  {"kr-optimization-tech-card","se-material-science-pack-2"},
  {"se-material-science-pack-3"},
  {"utility-science-pack","se-material-science-pack-3"}
)
alter_technology_cost("refined-flammables-8", "0.4*(((L-6)^2)*3000)")
alter_technology_effect("refined-flammables-8", refined_flammables_effect(0.2))

-- Material 3
move_technology(
  "refined-flammables-9",
  {"se-material-science-pack-3"}, -- There isn't really a good other option for this
  {"kr-optimization-tech-card","se-material-science-pack-3"},
  {"se-material-science-pack-4"},
  {"utility-science-pack","se-material-science-pack-4"}
)
alter_technology_cost("refined-flammables-9", "0.3*(((L-6)^2)*3000)")
alter_technology_effect("refined-flammables-9", refined_flammables_effect(0.2))

-- Optimisation 2
move_technology(
  "refined-flammables-10",
  {"kr-advanced-tech-card"},
  {"se-material-science-pack-3","kr-advanced-tech-card"},
  {"se-deep-space-science-pack-1"},
  {"utility-science-pack","se-material-science-pack-4","se-deep-space-science-pack-1"}
)
alter_technology_cost("refined-flammables-10", "0.2*(((L-6)^2)*3000)")
alter_technology_effect("refined-flammables-10", refined_flammables_effect(0.2))

-- Material 4
move_technology(
  "refined-flammables-11",
  {"se-material-science-pack-4"}, -- There isn't really a good other option for this
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack"},
  {"se-deep-space-science-pack-2","kr-matter-tech-card"},
  {"kr-optimization-tech-card","utility-science-pack","kr-matter-tech-card","se-deep-space-science-pack-2"}
)
alter_technology_cost("refined-flammables-11", "0.2*(((L-6)^2)*3000)")
alter_technology_effect("refined-flammables-11", refined_flammables_effect(0.2))

-- Matter 1
move_technology(
  "refined-flammables-12",
  {"kr-matter-tech-card"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack"},
  nil,
  {"kr-optimization-tech-card","utility-science-pack","se-deep-space-science-pack-2"}
)
alter_technology_cost("refined-flammables-12", "0.4*((1.5^(L-2))*1000)")
alter_technology_effect("refined-flammables-12", refined_flammables_effect(0.2))

-- DSS 1
move_technology(
  "refined-flammables-13",
  {"jetpack-4"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-deep-space-science-pack-1"},
  nil,
  {"kr-optimization-tech-card","utility-science-pack","se-deep-space-science-pack-2"}
)
alter_technology_cost("refined-flammables-13", "0.4*((1.5^(L-2))*1000)")
alter_technology_effect("refined-flammables-13", refined_flammables_effect(0.2))

-- DSS 2
move_technology(
  "refined-flammables-14",
  {"se-arcosphere-folding"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack"},
  nil,
  {"kr-optimization-tech-card","utility-science-pack"}
)
alter_technology_cost("refined-flammables-14", "0.4*((1.5^(L-2))*1000)")
alter_technology_effect("refined-flammables-14", refined_flammables_effect(0.2))

-- Matter 2
move_technology(
  "refined-flammables-15",
  {"se-kr-matter-science-pack-2"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-kr-matter-science-pack-2"},
  nil,
  {"kr-optimization-tech-card","utility-science-pack","kr-matter-tech-card"}
)
alter_technology_cost("refined-flammables-15", "0.4*((1.5^(L-2))*1000)")
alter_technology_effect("refined-flammables-15", refined_flammables_effect(0.2))

-- DSS 3
move_technology(
  "refined-flammables-16",
  {"se-thruster-suit-4"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-kr-matter-science-pack-2","se-deep-space-science-pack-3"},
  {"se-deep-space-science-pack-4"},
  {"kr-optimization-tech-card","utility-science-pack","kr-matter-tech-card","kr-singularity-tech-card","se-deep-space-science-pack-4"}
)
alter_technology_cost("refined-flammables-16", "0.4*((1.5^(L-2))*1000)")
alter_technology_effect("refined-flammables-16", refined_flammables_effect(0.2))

-- Optimisation 3
move_technology(
  "refined-flammables-17",
  {"kr-singularity-tech-card"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-kr-matter-science-pack-2","se-deep-space-science-pack-3"},
  nil,
  {"kr-optimization-tech-card","utility-science-pack","kr-advanced-tech-card","kr-matter-tech-card","se-deep-space-science-pack-4"}
)
alter_technology_cost("refined-flammables-17", "0.4*((1.5^(L-2))*1000)")
alter_technology_effect("refined-flammables-17", refined_flammables_effect(0.2))

-- DSS 4
move_technology(
  "refined-flammables-18",
  {"se-deep-space-science-pack-4"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-kr-matter-science-pack-2"},
  nil,
  {"kr-optimization-tech-card","utility-science-pack","kr-advanced-tech-card","kr-matter-tech-card"}
)
alter_technology_cost("refined-flammables-18", "0.4*((1.5^(L-2))*1000)")
alter_technology_effect("refined-flammables-18", refined_flammables_effect(0.2))

---- Stronger Explosives : Material Science ----
-- Base SE
-- PreRocket                                                 : +25% Damage
-- PreRocket                                                 : +20% Damage
-- PreRocket                                                 : +20% Damage (Rocket +30%)
-- PreRocket, Rocket, Space                                  : +20% Damage (Rocket +40%)
-- PreRocket, Rocket, Space, Production                      : +20% Damage (Rocket +50%)
-- PreRocket, Rocket, Space, Production, Mat1                : +20% Damage (Rocket +60%)
-- PreRocket, Rocket, Space, Production, Utility, Mat2       : +20% Damage (Rocket +50%)
-- PreRocket, Rocket, Space, Production, Utility, Mat3       : +20% Damage (Rocket +50%)
-- PreRocket, Rocket, Space, Production, Utility, Mat4       : +20% Damage (Rocket +50%)
-- PreRocket, Rocket, Space, Production, Utility, Mat4, DSS1 : +20% Damage (Rocket +50%)

-- K2SE
-- PreRocket                                                                           : +25% Damage       -- Just Grenade
-- PreRocket                                                                           : +20% Damage       -- Grenade, Mine
-- PreRocket                                                                           : +20% (Rocket +30%)
-- PreRocket, Rocket, Space                                                            : +20% (Rocket +30%)
-- PreRocket, Rocket, Space, Utility, Production                                       : +20% (Rocket +30%)
-- PreRocket, Rocket, Space, Utility, Production, Optimisation1                        : +20% (Rocket +40%)
-- PreRocket, Rocket, Space, Utility, Production, Optimisation1, Mat1                  : +20% (Rocket +40%)
-- PreRocket, Rocket, Space, Utility, Production, Optimisation1, Mat2                  : +20% (Rocket +50%)
-- PreRocket, Rocket, Space, Utility, Production, Optimisation1, Mat3                  : +20% (Rocket +50%)
-- PreRocket, Rocket, Space, Utility, Production, Optimisation2, Mat3                  : +20% (Rocket +50%)
-- PreRocket, Rocket, Space, Utility, Production, Optimisation2, Mat4                  : +20% (Rocket +50%)
-- PreRocket, Rocket, Space, Utility, Production, Optimisation2, Mat4, Matter 1        : +20% (Rocket +50%)
-- PreRocket, Rocket, Space, Utility, Production, Optimisation2, Mat4, Matter 1, DSS1  : +20% (Rocket +50%) : Total : +320% Damage
-- PreRocket, Rocket, Space, Utility, Production, Optimisation2, Mat4, Matter 1, DSS2  :
-- PreRocket, Rocket, Space, Utility, Production, Optimisation2, Mat4, Matter 2, DSS2  :
-- PreRocket, Rocket, Space, Utility, Production, Optimisation2, Mat4, Matter 2, DSS3  :
-- PreRocket, Rocket, Space, Utility, Production, Optimisation3, Mat4, Matter 2, DSS3  :
-- PreRocket, Rocket, Space, Utility, Production, Optimisation3, Mat4, Matter 2, DSS4  :

-- Stronger Explosives effect
local function stronger_explosives_effect(grenade, mine, rocket, heavy, turret)
  local effect = {
    {type = "ammo-damage", ammo_category = "grenade", modifier = grenade}
  }

  if mine then
    table.insert(effect, {type = "ammo-damage", ammo_category = "landmine", modifier = mine})
  end

  if rocket then
    table.insert(effect, {type = "ammo-damage", ammo_category = "rocket", modifier = rocket})
  end

  if heavy then
    table.insert(effect, {type = "ammo-damage", ammo_category = "kr-heavy-rocket", modifier = heavy})
  end

  if turret then
    table.insert(effect, {type = "ammo-damage", ammo_category = "kr-turret-missile", modifier = turret})
  end

  return effect
end

-- Stronger Explosives requires the group at 11-15 to be broken up, and the techs after level 12 removed, and to be made infinite again
data_util.tech_split_at_levels("stronger-explosives",{12,13,14,15,16,17,18})

-- PreRocket
alter_technology_effect("stronger-explosives-1", stronger_explosives_effect(0.2))
--
move_technology("stronger-explosives-2",{"rocketry"},nil,{"military-science-pack"})
alter_technology_effect("stronger-explosives-2", stronger_explosives_effect(0.2,0.2))
--
move_technology("stronger-explosives-3",{"military-3"},nil,{"chemical-science-pack"})
alter_technology_effect("stronger-explosives-3", stronger_explosives_effect(0.2,0.2))

-- Rocket
move_technology(
  "stronger-explosives-4",
  {"jetpack-2"},
  nil,
  {"space-science-pack"}
)
alter_technology_effect("stronger-explosives-4", stronger_explosives_effect(0.2,0.2,0.3))

-- Utility & Production
move_technology(
  "stronger-explosives-5",
  {"kr-railgun-turret"},
  {"utility-science-pack"},
  {"production-science-pack"}
)
alter_technology_effect("stronger-explosives-5", stronger_explosives_effect(0.2,0.2,0.3))

-- Optimisation 1
move_technology(
  "stronger-explosives-6",
  {"kr-optimization-tech-card"},
  {"utility-science-pack","kr-optimization-tech-card"},
  {"se-material-science-pack-1"},
  {"se-material-science-pack-1"}
)
alter_technology_cost("stronger-explosives-6", nil, 1000)
alter_technology_effect("stronger-explosives-6", stronger_explosives_effect(0.2,0.2,0.3,0.3))

-- Material 1
move_technology(
  "stronger-explosives-7",
  {"kr-rocket-turret"},
  {"kr-optimization-tech-card","se-material-science-pack-1"},
  {"se-material-science-pack-2"},
  {"se-material-science-pack-2"}
)
alter_technology_cost("stronger-explosives-7", "0.5*(((L-6)^2)*3000)")
alter_technology_effect("stronger-explosives-7", stronger_explosives_effect(0.2,0.2,0.3,0.3,0.3))

-- Material 2
move_technology(
  "stronger-explosives-8",
  {"se-material-science-pack-2"}, -- There isn't really a good other option for this
  {"kr-optimization-tech-card","se-material-science-pack-2"},
  {"se-material-science-pack-3"},
  {"se-material-science-pack-3"}
)
alter_technology_cost("stronger-explosives-8", "0.4*(((L-6)^2)*3000)")
alter_technology_effect("stronger-explosives-8", stronger_explosives_effect(0.2,0.2,0.3,0.3,0.3))

-- Material 3
move_technology(
  "stronger-explosives-9",
  {"se-material-science-pack-3"}, -- There isn't really a good other option for this
  {"kr-optimization-tech-card","se-material-science-pack-3"},
  {"se-material-science-pack-4"},
  {"se-material-science-pack-4"}
)
alter_technology_cost("stronger-explosives-9", "0.3*(((L-6)^2)*3000)")
alter_technology_effect("stronger-explosives-9", stronger_explosives_effect(0.2,0.2,0.3,0.3,0.3))

-- Optimisation 2
move_technology(
  "stronger-explosives-10",
  {"kr-advanced-tech-card"},
  {"se-material-science-pack-3","kr-advanced-tech-card"},
  {"se-deep-space-science-pack-1"},
  {"se-material-science-pack-4","se-deep-space-science-pack-1"}
)
alter_technology_cost("stronger-explosives-10", "0.2*(((L-6)^2)*3000)")
alter_technology_effect("stronger-explosives-10", stronger_explosives_effect(0.2,0.2,0.3,0.3,0.3))

-- Material 4
move_technology(
  "stronger-explosives-11",
  {"se-material-science-pack-4"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack"},
  {"se-deep-space-science-pack-2","kr-matter-tech-card"},
  {"kr-optimization-tech-card","kr-matter-tech-card","se-deep-space-science-pack-2"}
)
alter_technology_cost("stronger-explosives-11", "0.2*(((L-6)^2)*3000)")
alter_technology_effect("stronger-explosives-11", stronger_explosives_effect(0.2,0.2,0.3,0.3,0.3))

-- Matter 1
move_technology(
  "stronger-explosives-12",
  {"kr-matter-tech-card"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack"},
  nil,
  {"kr-optimization-tech-card","se-deep-space-science-pack-2"}
)
alter_technology_cost("stronger-explosives-12", "0.4*((1.5^(L-2))*1000)")
alter_technology_effect("stronger-explosives-12", stronger_explosives_effect(0.2,0.2,0.3,0.3,0.3))

-- DSS 1
move_technology(
  "stronger-explosives-13",
  {"jetpack-4"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-deep-space-science-pack-1"},
  nil,
  {"kr-optimization-tech-card","se-deep-space-science-pack-2"}
)
alter_technology_cost("stronger-explosives-13", "0.4*((1.5^(L-2))*1000)")
alter_technology_effect("stronger-explosives-13", stronger_explosives_effect(0.2,0.2,0.3,0.3,0.3))

-- DSS 2
move_technology(
  "stronger-explosives-14",
  {"se-arcosphere-folding"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack"},
  nil,
  {"kr-optimization-tech-card"}
)
alter_technology_cost("stronger-explosives-14", "0.4*((1.5^(L-2))*1000)")
alter_technology_effect("stronger-explosives-14", stronger_explosives_effect(0.2,0.2,0.3,0.3,0.3))

-- Matter 2
move_technology(
  "stronger-explosives-15",
  {"se-kr-matter-science-pack-2"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-kr-matter-science-pack-2"},
  nil,
  {"kr-optimization-tech-card","kr-matter-tech-card"}
)
alter_technology_cost("stronger-explosives-15", "0.4*((1.5^(L-2))*1000)")
alter_technology_effect("stronger-explosives-15", stronger_explosives_effect(0.2,0.2,0.3,0.3,0.3))

-- DSS 3
move_technology(
  "stronger-explosives-16",
  {"se-thruster-suit-4"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-kr-matter-science-pack-2","se-deep-space-science-pack-3"},
  {"kr-singularity-tech-card","se-deep-space-science-pack-4"},
  {"kr-optimization-tech-card","kr-matter-tech-card","kr-singularity-tech-card","se-deep-space-science-pack-4"}
)
alter_technology_cost("stronger-explosives-16", "0.4*((1.5^(L-2))*1000)")
alter_technology_effect("stronger-explosives-16", stronger_explosives_effect(0.2,0.2,0.3,0.3,0.3))

-- Optimisation 3
move_technology(
  "stronger-explosives-17",
  {"kr-singularity-tech-card"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-kr-matter-science-pack-2","se-deep-space-science-pack-3"},
  nil,
  {"kr-optimization-tech-card","kr-advanced-tech-card","kr-matter-tech-card","se-deep-space-science-pack-4"}
)
alter_technology_cost("stronger-explosives-17", "0.4*((1.5^(L-2))*1000)")
alter_technology_effect("stronger-explosives-17", stronger_explosives_effect(0.2,0.2,0.3,0.3,0.3))

-- DSS 4
move_technology(
  "stronger-explosives-18",
  {"se-deep-space-science-pack-4"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-kr-matter-science-pack-2"},
  nil,
  {"kr-optimization-tech-card","kr-advanced-tech-card","kr-matter-tech-card"}
)
alter_technology_cost("stronger-explosives-18", "0.4*((1.5^(L-2))*1000)")
alter_technology_effect("stronger-explosives-18", stronger_explosives_effect(0.2,0.2,0.3,0.3,0.3))

---- Follower Robot Count : Material Science ----
-- Base SE
-- PreRocket                                                 : +5 Count
-- PreRocket                                                 : +5 Count
-- PreRocket                                                 : +5 Count
-- PreRocket                                                 : +10 Count
-- PreRocket, Rocket, Space                                  : +10 Count
-- PreRocket, Rocket, Space, Production, Mat1                : +10 Count
-- PreRocket, Rocket, Space, Production, Utility, Mat2       : +10 Count
-- PreRocket, Rocket, Space, Production, Utility, Mat3       : +10 Count
-- PreRocket, Rocket, Space, Production, Utility, Mat4       : +10 Count
-- PreRocket, Rocket, Space, Production, Utility, Mat4, DSS1 : +10 Count

-- K2SE
-- PreRocket                                                                           : +5 Count
-- PreRocket                                                                           : +5 Count
-- PreRocket                                                                           : +5 Count
-- PreRocket                                                                           : +10 Count
-- PreRocket, Rocket, Space                                                            : +10 Count
-- PreRocket, Rocket, Space, Utility                                                   : +5 Count
-- PreRocket, Rocket, Space, Production                                                : +5 Count
-- PreRocket, Rocket, Space, Optimisation1                                             : +5 Count
-- PreRocket, Rocket, Space, Utility, Production, Optimisation1, Mat1                  : +10 Count
-- PreRocket, Rocket, Space, Utility, Production, Optimisation1, Mat2                  : +10 Count
-- PreRocket, Rocket, Space, Utility, Production, Optimisation1, Mat3                  : +10 Count
-- PreRocket, Rocket, Space, Utility, Production, Optimisation2, Mat3                  : +10 Count
-- PreRocket, Rocket, Space, Utility, Production, Optimisation2, Mat4                  : +10 Count
-- PreRocket, Rocket, Space, Utility, Production, Optimisation2, Mat4, Matter 1        : +10 Count
-- PreRocket, Rocket, Space, Utility, Production, Optimisation2, Mat4, Matter 1, DSS1  : +10 Count
-- PreRocket, Rocket, Space, Utility, Production, Optimisation2, Mat4, Matter 1, DSS2  :
-- PreRocket, Rocket, Space, Utility, Production, Optimisation2, Mat4, Matter 2, DSS2  :
-- PreRocket, Rocket, Space, Utility, Production, Optimisation2, Mat4, Matter 2, DSS3  :
-- PreRocket, Rocket, Space, Utility, Production, Optimisation3, Mat4, Matter 2, DSS3  :
-- PreRocket, Rocket, Space, Utility, Production, Optimisation3, Mat4, Matter 2, DSS4  :

-- Follower Robot Count required two additional technologies for the tech pack progression
data_util.tech_split_at_levels("follower-robot-count",{11,12,13,14,15,16,17,18})

-- PreRocket
move_technology("follower-robot-count-3",{"military-3"},nil,{"chemical-science-pack"})

-- Space
data_util.tech_remove_prerequisites("follower-robot-count-5", {"production-science-pack"})
data_util.tech_remove_ingredients("follower-robot-count-5", {"production-science-pack"})
alter_technology_cost("follower-robot-count-5", "1000")

-- Production, Utility, Optimisation 1
data_util.tech_remove_prerequisites("follower-robot-count-6", {"se-material-science-pack-1"})
data_util.tech_remove_ingredients("follower-robot-count-6", {"production-science-pack","se-material-science-pack-1","kr-optimization-tech-card","kr-advanced-tech-card","kr-matter-tech-card"})
data_util.tech_add_ingredients("follower-robot-count-6", {"automation-science-pack","logistic-science-pack","military-science-pack"})
alter_technology_effect("follower-robot-count-6", {{type = "maximum-following-robots-count", modifier = 5}})
alter_technology_cost("follower-robot-count-6", "(L-5)*1000")

local utility_tech = table.deepcopy(data.raw.technology["follower-robot-count-6"])
local optimisation_tech = table.deepcopy(data.raw.technology["follower-robot-count-6"])

utility_tech.name = "follower-robot-count-utility-6"
utility_tech.localised_name = {"", {"technology-name.follower-robot-count"}, " ", "6"}
utility_tech.localised_description = {"technology-description.follower-robot-count"}

optimisation_tech.name = "follower-robot-count-optimisation-6"
optimisation_tech.localised_name = {"", {"technology-name.follower-robot-count"}, " ", "6"}
optimisation_tech.localised_description = {"technology-description.follower-robot-count"}

-- adds the scienc icon above the ... modifer icon
local function add_tool_icons_to_tech_icon(tool_name, tech_prototype)
  tech_prototype.icons = tech_prototype.icons or {{icon = tech_prototype.icon, icon_size = tech_prototype.icon_size}}
  tech_prototype.icon = nil
  tech_prototype.icon_size = nil

  for _, layer in ipairs(data.raw.tool[tool_name].icons) do
    local new_layer = table.deepcopy(layer)
    new_layer.scale = 0.6
    new_layer.shift = {50, 22.5}
    new_layer.floating = true
    table.insert(tech_prototype.icons, new_layer)
  end
end

add_tool_icons_to_tech_icon("utility-science-pack", utility_tech)
add_tool_icons_to_tech_icon("kr-optimization-tech-card", optimisation_tech)
add_tool_icons_to_tech_icon("production-science-pack", data.raw.technology["follower-robot-count-6"])

data:extend({utility_tech,optimisation_tech})

move_technology(
  "follower-robot-count-6",
  {"effect-transmission"},
  {"production-science-pack"}
)
move_technology(
  "follower-robot-count-utility-6",
  {"kr-military-5"},
  {"utility-science-pack"}
)
move_technology(
  "follower-robot-count-optimisation-6",
  {"kr-optimization-tech-card"},
  {"kr-optimization-tech-card"}
)

-- Material 1
move_technology(
  "follower-robot-count-7",
  {"follower-robot-count-utility-6","follower-robot-count-optimisation-6", "kr-logistic-4"},
  {"kr-optimization-tech-card","se-material-science-pack-1"},
  {"se-material-science-pack-2"},
  {"se-material-science-pack-2","kr-matter-tech-card","kr-advanced-tech-card"}
)
alter_technology_cost("follower-robot-count-7", "(L-5)*1000")

-- Material 2
move_technology(
  "follower-robot-count-8",
  {"se-space-accumulator"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-material-science-pack-2"},
  {"kr-advanced-tech-card","se-material-science-pack-3","kr-matter-tech-card"},
  {"kr-matter-tech-card","kr-advanced-tech-card","se-material-science-pack-3"}
)
alter_technology_cost("follower-robot-count-8", "(L-5)*1000")

-- Material 3
move_technology(
  "follower-robot-count-9",
  {"se-superconductive-cable"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-material-science-pack-3"},
  {"kr-singularity-tech-card","se-material-science-pack-4"},
  {"kr-matter-tech-card","kr-advanced-tech-card","se-material-science-pack-4","kr-singularity-tech-card"}
)
alter_technology_cost("follower-robot-count-9", "(L-5)*1000")

-- Optimisation 2
move_technology(
  "follower-robot-count-10",
  {"kr-advanced-roboports"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-material-science-pack-3"},
  {"se-deep-space-science-pack-1","se-material-science-pack-4"},
  {"kr-optimization-tech-card","kr-matter-tech-card","se-material-science-pack-4","se-deep-space-science-pack-1","kr-singularity-tech-card"}
)
alter_technology_cost("follower-robot-count-10", "(L-5)*1000")

-- Material 4
move_technology(
  "follower-robot-count-11",
  {"se-material-science-pack-4"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack"},
  nil,
  {"kr-optimization-tech-card","kr-matter-tech-card","se-deep-space-science-pack-1","kr-singularity-tech-card"}
)
alter_technology_cost("follower-robot-count-11", "(L-5)*1000")

-- Matter 1
move_technology(
  "follower-robot-count-12",
  {"kr-matter-tech-card"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack"},
  nil,
  {"kr-optimization-tech-card","se-deep-space-science-pack-1","kr-singularity-tech-card"}
)
alter_technology_cost("follower-robot-count-12", "(L-5)*1000")

-- DSS 1
move_technology(
  "follower-robot-count-13",
  {"se-space-accumulator-2"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack"},
  nil,
  {"kr-optimization-tech-card","kr-singularity-tech-card"}
)
alter_technology_cost("follower-robot-count-13", "(L-5)*1000")

-- DSS 2
move_technology(
  "follower-robot-count-14",
  {"se-deep-space-transport-belt"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-deep-space-science-pack-2"},
  nil,
  {"kr-optimization-tech-card","se-deep-space-science-pack-1","kr-singularity-tech-card"}
)
alter_technology_cost("follower-robot-count-14", "(L-5)*1000")

-- Matter 2
move_technology(
  "follower-robot-count-15",
  {"se-kr-matter-science-pack-2"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-kr-matter-science-pack-2","se-deep-space-science-pack-2"},
  nil,
  {"kr-optimization-tech-card","kr-matter-tech-card","se-deep-space-science-pack-1","kr-singularity-tech-card"}
)
alter_technology_cost("follower-robot-count-15", "(L-5)*1000")

-- DSS 3
move_technology(
  "follower-robot-count-16",
  {"kr-energy-storage"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-kr-matter-science-pack-2","se-deep-space-science-pack-3"},
  nil,
  {"kr-optimization-tech-card","kr-matter-tech-card","se-deep-space-science-pack-1","kr-singularity-tech-card"}
)
alter_technology_cost("follower-robot-count-16", "(L-5)*1000")

-- Optimisation 3
move_technology(
  "follower-robot-count-17",
  {"kr-singularity-tech-card"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-kr-matter-science-pack-2","se-deep-space-science-pack-3"},
  nil,
  {"kr-optimization-tech-card","kr-advanced-tech-card","kr-matter-tech-card","se-deep-space-science-pack-1"}
)
alter_technology_cost("follower-robot-count-17", "(L-5)*1000")

-- DSS 4
move_technology(
  "follower-robot-count-18",
  {"se-deep-space-science-pack-4"},
  {"automation-science-pack","logistic-science-pack","chemical-science-pack","military-science-pack","se-kr-matter-science-pack-2","se-deep-space-science-pack-4"},
  nil,
  {"kr-optimization-tech-card","kr-advanced-tech-card","kr-matter-tech-card","se-deep-space-science-pack-1"}
)
alter_technology_cost("follower-robot-count-18", "(L-5)*1000")

---- Integrate K2 Science into Spaceship Structural Integrity
-- Optimization 1
move_technology(
  "se-spaceship-integrity-1",
  {"kr-optimization-tech-card"},
  {"kr-optimization-tech-card"}
)

-- Material 1
move_technology(
  "se-spaceship-integrity-2",
  nil,
  {"kr-optimization-tech-card"}
)

-- Material 2
move_technology(
  "se-spaceship-integrity-3",
  nil,
  {"kr-optimization-tech-card"}
)

-- Energy 1
move_technology(
  "se-spaceship-integrity-4",
  nil,
  {"kr-optimization-tech-card"}
)

-- Energy 2
move_technology(
  "se-spaceship-integrity-5",
  nil,
  {"kr-optimization-tech-card"}
)

-- Energy 3, Optimisation 2
move_technology(
  "se-spaceship-integrity-6",
  {"kr-advanced-tech-card"},
  {"kr-advanced-tech-card"}
)

-- Astronomic 4, Matter 1
move_technology(
  "se-spaceship-integrity-7",
  {"kr-matter-tech-card"},
  {"kr-advanced-tech-card"}
)

-- Enegy 4, Material 4, Matter 1, DSS 1
move_technology(
  "se-factory-spaceship-1",
  {"kr-matter-tech-card"},
  {"kr-advanced-tech-card"}
)

move_technology(
  "se-factory-spaceship-2",
  nil,
  {"kr-advanced-tech-card"}
)

-- DSS 2
move_technology(
  "se-factory-spaceship-3",
  nil,
  {"kr-advanced-tech-card"}
)

-- DSS 3, Matter 2
move_technology(
  "se-factory-spaceship-4",
  {"se-kr-matter-science-pack-2"},
  {"kr-advanced-tech-card","se-kr-matter-science-pack-2"},
  nil,
  {"kr-matter-tech-card"}
)

-- Optimisation 3, DSS 4
move_technology(
  "se-factory-spaceship-5",
  {"kr-singularity-tech-card"},
  {"se-kr-matter-science-pack-2","kr-singularity-tech-card"},
  nil,
  {"kr-matter-tech-card"}
)
