local data_util = require("data_util")

local blank = {
  direction_count = 8,
  frame_count = 1,
  filename = "__space-exploration-graphics__/graphics/blank.png",
  width = 1,
  height = 1,
  priority = "low"
}

local function make_openable_entity(name, locale, icon, width, height)
  height = height or width
  data:extend({
    {
      type = "lamp",
      name = name,
      subgroup = "universe-explorer",
      hidden = true,
      order = "a",
      icon = icon,
      icon_size = 64,
      circuit_wire_max_distance = 0,
      collision_box = {{-width/2,-height/2},{width/2,height/2}},
      selection_box = {{-width/2,-height/2},{width/2,height/2}},
      corpse = "lamp-remnants",
      energy_source = {
        type = "void",
      },
      energy_usage_per_tick = "1W",
      flags = {
        "placeable-neutral",
        "not-blueprintable",
        "not-deconstructable",
        "placeable-off-grid"
      },
      glow_color_intensity = 0.135,
      glow_size = width,
      light = { intensity = 0, size = 0 },
      max_health = 100,
      picture_off = blank,
      picture_on = blank,
      localised_name = locale,
      always_on = true
    }
  })
end

data:extend({
  {
    type = "sprite",
    name = data_util.mod_prefix .. "map-star",
    filename = "__space-exploration-graphics__/graphics/entity/starmap/star.png",
    priority = "extra-high",
    width = 512,
    height = 512,
    shift = {0,0}
  },
  {
    type = "animation",
    name = data_util.mod_prefix .. "map-star-cloud",
    animation_speed = 0.5,
    filename = "__space-exploration-graphics__/graphics/entity/cloud/cloud-45-frames.png",
    frame_count = 45,
    line_length = 7,
    priority = "low",
    scale = 3,
    width = 256,
    height = 256,
    apply_runtime_tint = true,
    blend_mode = "additive", --"additive-soft"
  },
  {
    type = "sprite",
    name = data_util.mod_prefix .. "map-planet",
    filename = "__space-exploration-graphics__/graphics/entity/starmap/planet-base.png",
    priority = "extra-high",
    width = 512,
    height = 512,
    shift = {0,0},
    apply_runtime_tint = true,
  },
  {
    type = "sprite",
    name = data_util.mod_prefix .. "map-planet-detail",
    filename = "__space-exploration-graphics__/graphics/entity/starmap/planet-detail.png",
    priority = "extra-high",
    width = 512,
    height = 512,
    shift = {0,0},
    apply_runtime_tint = true,
  },
  {
    type = "sprite",
    name = data_util.mod_prefix .. "map-planet-water",
    filename = "__space-exploration-graphics__/graphics/entity/starmap/planet-water.png",
    priority = "extra-high",
    width = 512,
    height = 512,
    shift = {0,0},
    apply_runtime_tint = true,
  },
  {
    type = "sprite",
    name = data_util.mod_prefix .. "map-planet-cloud-ice",
    filename = "__space-exploration-graphics__/graphics/entity/starmap/planet-cloud-ice.png",
    priority = "extra-high",
    width = 512,
    height = 512,
    shift = {0,0},
    apply_runtime_tint = true,
  },
  {
    type = "sprite",
    name = data_util.mod_prefix .. "map-planet-haze",
    filename = "__space-exploration-graphics__/graphics/entity/starmap/planet-haze.png",
    priority = "extra-high",
    width = 512,
    height = 512,
    shift = {0,0},
    apply_runtime_tint = true,
  },
  {
    type = "sprite",
    name = data_util.mod_prefix .. "map-planet-atmosphere",
    filename = "__space-exploration-graphics__/graphics/entity/starmap/planet-atmosphere.png",
    priority = "extra-high",
    width = 512,
    height = 512,
    shift = {0,0},
    apply_runtime_tint = true,
  },
  {
    type = "sprite",
    name = data_util.mod_prefix .. "map-asteroid-belt",
    filename = "__space-exploration-graphics__/graphics/entity/starmap/asteroid-belt.png",
    priority = "extra-high",
    width = 512,
    height = 512,
    shift = {0, 0}
  },
  {
    type = "sprite",
    name = data_util.mod_prefix .. "map-asteroid-belt-detail",
    filename = "__space-exploration-graphics__/graphics/entity/starmap/asteroid-belt-detail.png",
    priority = "extra-high",
    width = 512,
    height = 512,
    shift = {0, 0},
    apply_runtime_tint = true,
  },
  {
    type = "sprite",
    name = data_util.mod_prefix .. "map-asteroid-belt-scatter",
    filename = "__space-exploration-graphics__/graphics/entity/starmap/asteroid-belt-scatter.png",
    priority = "high",
    width = 511,
    height = 128,
    shift = {0, 0}
  },
  {
    type = "sprite",
    name = data_util.mod_prefix .. "map-asteroid-belt-scatter-detail",
    filename = "__space-exploration-graphics__/graphics/entity/starmap/asteroid-belt-scatter-detail.png",
    priority = "high",
    width = 511,
    height = 128,
    shift = {0, 0},
    apply_runtime_tint = true,
  },
  {
    type = "sprite",
    name = data_util.mod_prefix .. "map-asteroid-field",
    filename = "__space-exploration-graphics__/graphics/entity/starmap/asteroid-field.png",
    priority = "extra-high",
    width = 512,
    height = 512,
    shift = {0, 0}
  },
  {
    type = "sprite",
    name = data_util.mod_prefix .. "map-asteroid-field-scatter",
    filename = "__space-exploration-graphics__/graphics/entity/starmap/asteroid-field-scatter.png",
    priority = "high",
    width = 512,
    height = 512,
    shift = {0, 0}
  },
  {
    type = "sprite",
    name = data_util.mod_prefix .. "map-asteroid-field-scatter-detail",
    filename = "__space-exploration-graphics__/graphics/entity/starmap/asteroid-field-scatter-detail.png",
    priority = "high",
    width = 512,
    height = 512,
    shift = {0, 0},
    apply_runtime_tint = true,
  },
  {
    type = "sprite",
    name = data_util.mod_prefix .. "map-spaceship",
    filename = "__space-exploration-graphics__/graphics/entity/starmap/spaceship.png",
    priority = "extra-high",
    width = 87,
    height = 256,
    shift = {0,0},
    apply_runtime_tint = true,
  },
  {
    type = "sprite",
    name = data_util.mod_prefix .. "gradient-sprite",
    filename = "__space-exploration-graphics__/graphics/gradient-white.png",
    priority = "high",
    width = 4,
    height = 512,
    frame_count = 1,
    line_length = 1,
    apply_runtime_tint = true,
    --blend_mode = "additive",
  },
  {
    type = "sprite",
    name = data_util.mod_prefix .. "map-starmap",
    filename = "__space-exploration-graphics__/graphics/entity/starmap/starmap.png",
    priority = "extra-high",
    width = 512,
    height = 512,
    shift = {0,0},
    apply_runtime_tint = true,
  },
  {
    type = "sprite",
    name = data_util.mod_prefix .. "map-gui-starmap",
    filename = "__space-exploration-graphics__/graphics/icons/starmap-transparent.png",
    priority = "extra-high",
    width = 64,
    height = 64,
    shift = {0,0},
    apply_runtime_tint = true,
  },
  {
    type = "sprite",
    name = data_util.mod_prefix .. "map-gui-starmap-small",
    filename = "__space-exploration-graphics__/graphics/icons/starmap-transparent.png",
    priority = "extra-high",
    width = 64,
    height = 64,
    scale = 0.5,
    shift = {0,0},
    apply_runtime_tint = true,
  },
  {
    type = "sprite",
    name = data_util.mod_prefix .. "map-gui-universe-explorer",
    filename = "__space-exploration-graphics__/graphics/icons/universe-explorer.png",
    priority = "extra-high",
    width = 64,
    height = 64,
    shift = {0,0},
    apply_runtime_tint = true,
  },
  {
    type = "sprite",
    name = data_util.mod_prefix .. "map-gui-right-arrow",
    filename = "__space-exploration-graphics__/graphics/icons/astronomic/right-arrow.png",
    priority = "extra-high",
    width = 16,
    height = 32,
    shift = {0,0},
    apply_runtime_tint = true,
  },
  {
    type = "sprite",
    name = data_util.mod_prefix .. "map-gui-system",
    filename = "__space-exploration-graphics__/graphics/technology/discovery.png",
    priority = "extra-high",
    width = 128,
    height = 128,
    shift = {0,0},
    apply_runtime_tint = true,
  },
})

make_openable_entity(data_util.mod_prefix .. "interstellar-map-star", {"space-exploration.star"}, "__space-exploration-graphics__/graphics/icons/astronomic/star.png", 2 * Shared.interstellar_map_scale) -- used for stars on starmap
make_openable_entity(data_util.mod_prefix .. "interstellar-map-asteroid-field", {"space-exploration.asteroid-field"}, "__space-exploration-graphics__/graphics/icons/astronomic/asteroid-field.png", 5 * Shared.interstellar_map_scale)
make_openable_entity(data_util.mod_prefix .. "interstellar-map-spaceship", {"space-exploration.spaceship"}, "__space-exploration-graphics__/graphics/icons/spaceship.png", 0.75 * Shared.interstellar_map_scale)

make_openable_entity(data_util.mod_prefix .. "system-map-star", {"space-exploration.star"}, "__space-exploration-graphics__/graphics/icons/astronomic/star.png", 22 * Shared.system_map_scale) -- used for star on solarmap
for i = 1, 20 do
  make_openable_entity(data_util.mod_prefix .. "system-map-planet-"..i, {"space-exploration.planet"}, "__space-exploration-graphics__/graphics/icons/astronomic/planet.png", 4 * ((i+1)/11) * Shared.system_map_scale) -- different sizes of planet based on radius
  make_openable_entity(data_util.mod_prefix .. "system-map-moon-"..i, {"space-exploration.moon"}, "__space-exploration-graphics__/graphics/icons/astronomic/moon.png", 4 * ((i+1)/11) * Shared.system_map_scale)  -- different sizes of moon based on radius
end
make_openable_entity(data_util.mod_prefix .. "system-map-asteroid-belt", {"space-exploration.asteroid-belt"}, "__space-exploration-graphics__/graphics/icons/astronomic/asteroid-belt.png", 3 * Shared.system_map_scale)
make_openable_entity(data_util.mod_prefix .. "system-map-spaceship", {"space-exploration.spaceship"}, "__space-exploration-graphics__/graphics/icons/spaceship.png", 0.75 * Shared.system_map_scale)
make_openable_entity(data_util.mod_prefix .. "system-map-interstellar-space", {"space-exploration.interstellar-map"}, "__space-exploration-graphics__/graphics/icons/astronomic/star.png", 8 * Shared.system_map_scale, 8 * Shared.system_map_scale)

data.raw.lamp[data_util.mod_prefix .. "interstellar-map-spaceship"].selection_priority = 100
data.raw.lamp[data_util.mod_prefix .. "system-map-spaceship"].selection_priority = 100
