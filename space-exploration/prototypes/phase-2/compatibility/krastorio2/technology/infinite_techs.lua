-- This source is dedicated to integrating SEs and K2s competing changes to infinite technologies.

-- This must be done in phase-3 as SE makes it's own changes in this phase and we don't want to fight technology.lua or technology-procedural.lua.
-- What we must do in phase-2 is ensure that technology.lua and technology-prodecural.lua do not crash due to the restructuring of K2s science packs
-- deeper into the SE tech tree.

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

-- Follower Robot Count
-- If we do not remove the advanced tech card, recursively removing the utility science pack will break
-- the tech tree.
data_util.tech_remove_prerequisites("follower-robot-count-6", {"kr-advanced-tech-card"})
