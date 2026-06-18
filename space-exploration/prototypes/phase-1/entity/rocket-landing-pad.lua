local data_util = require("data_util")

-- The old SE version <3
--[[
local landing_pad_collision_box = {{-4.35, -4.35}, {4.35, 4.35}}
data:extend({
  {
      type = "container",
      name = data_util.mod_prefix .. "rocket-landing-pad", -- "rocket-launch-pad-chest",
      icon = "__space-exploration-graphics__/graphics/icons/rocket-landing-pad.png",
      icon_size = 64,
      order = "z-z",
      flags = {"placeable-neutral", "player-creation"},
      minable = {mining_time = 0.5, result = data_util.mod_prefix .. "rocket-landing-pad"},
      max_health = 5000,
      corpse = "big-remnants",
      dying_explosion = "medium-explosion",
      icon_draw_specification = { shift = {0, -1}, scale = 3, scale_for_many = 2.5 },
      collision_box = landing_pad_collision_box,
      collision_mask = {
        layers ={
          water_tile = true,
          item = true,
          object = true,
          player = true,
          [spaceship_collision_layer] = true, -- not spaceship
        },
      },
      selection_box = {{-4.35, -4.35}, {4.35, 4.35}},
      drawing_box = {{-4.35, -4.35 - 1}, {4.35, 4.35}},
      inventory_size = rocket_capacity + 110, -- 100 for potential recovered rocket sections and space capsule, plus another 10 to prevent deleting cargo from overflowing reused rocket sections
      resistances = {
        { type = "meteor", percent = 99 },
        { type = "explosion", percent = 99 },
        { type = "impact", percent = 99 },
        { type = "fire", percent = 99 },
      },
      open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.65 },
      close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7 },
      impact_category = "metal-large",
      picture = {
              filename = "__space-exploration-graphics-5__/graphics/entity/rocket-landing-pad/rocket-landing-pad.png",
              height = 384 * 2,
              shift = { 0, -0.5 },
              width = 352 * 2,
              scale = 0.5
      },
      circuit_connector =
      {
        points = {
          shadow =
            {
              red = {-3.5, 2.7},
              green = {-3.6, 2.6},
            },
          wire =
            {
              red = {-3.5, 2.7},
              green = {-3.6, 2.6},
            }
        }
      },
      circuit_wire_max_distance = 12.5,
  },
})
]]

if mods["space-age"] then

  -- in hindsight SE should probably have made a "se-cargo-landing-pad" instead of modifying the vanilla one directly,
  -- instead of migrating this now we will just make an SA version of the landing pad to place on surfaces with no zone.
  -- (that way primarily the inventory size and entity flags do not get modified, and we get more control over cargo pods)
  local vanilla_cargo_landing_pad = table.deepcopy(data.raw["cargo-landing-pad"]["cargo-landing-pad"])
  vanilla_cargo_landing_pad.localised_name = {"space-exploration.simple-a-b-space", {"entity-name." .. vanilla_cargo_landing_pad.name}, "[space-age]"}
  vanilla_cargo_landing_pad.localised_description = {"entity-description." .. vanilla_cargo_landing_pad.name}
  vanilla_cargo_landing_pad.placeable_by = {item = vanilla_cargo_landing_pad.name, count = 1}
  vanilla_cargo_landing_pad.name = "sa-" .. vanilla_cargo_landing_pad.name
  vanilla_cargo_landing_pad.hidden = true
  data:extend{vanilla_cargo_landing_pad}

end

-- Use the base version as it has hatch animations and silos require it to be able to launch.

 -- 100 for potential recovered rocket sections and space capsule,
 -- plus another 10 to prevent deleting cargo from overflowing reused rocket sections
data.raw["cargo-landing-pad"]["cargo-landing-pad"].inventory_size = rocket_capacity + 110
data.raw["cargo-landing-pad"]["cargo-landing-pad"].flags = {"placeable-player", "player-creation"} -- Allow automated insertion
data.raw["cargo-landing-pad"]["cargo-landing-pad"].collision_mask = {
  layers ={
    water_tile = true,
    item = true,
    object = true,
    player = true,
    [spaceship_collision_layer] = true, -- not spaceship
  },
}
data.raw["cargo-landing-pad"]["cargo-landing-pad"].resistances = {
  { type = "meteor", percent = 99 },
  { type = "explosion", percent = 99 },
  { type = "impact", percent = 99 },
  { type = "fire", percent = 99 },
}
-- make sure wire reach is at least what the SE version was
data.raw["cargo-landing-pad"]["cargo-landing-pad"].circuit_wire_max_distance = math.max(data.raw["cargo-landing-pad"]["cargo-landing-pad"].circuit_wire_max_distance, 12.5)
