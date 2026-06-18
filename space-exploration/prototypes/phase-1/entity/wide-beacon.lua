local data_util = require("data_util")


local blank_image = {
    filename = "__space-exploration-graphics__/graphics/blank.png",
    width = 1,
    height = 1,
    frame_count = 1,
    line_length = 1,
    shift = { 0, 0 },
    repeat_count = 32,
}
data.raw.beacon.beacon.energy_usage = "100kW"
data.raw.beacon.beacon.module_slots = 8
data.raw.beacon.beacon.icons_positioning = {
  {inventory_index = defines.inventory.beacon_modules, shift = {x=0,y=0}, max_icons_per_row = 4},
}
data:extend({
  {
    type = "beacon",
    name = data_util.mod_prefix .. "wide-beacon",
    icon = "__space-exploration-graphics__/graphics/icons/wide-beacon.png",
    icon_size = 64,
    flags = { "placeable-player", "player-creation" },
    minable = {
      mining_time = 0.25,
      result = data_util.mod_prefix .. "wide-beacon"
    },
    next_upgrade = data_util.mod_prefix .. "wide-beacon-2",
    fast_replaceable_group = "wide-beacon",
    se_allow_in_space = true,
    profile = {1, 0},
    allowed_effects = data_util.all_effects_except("productivity", "quality"),
    animation = {
      layers = {
        {
          animation_speed = 0.5,
          filename = "__space-exploration-graphics-4__/graphics/entity/wide-beacon/wide-beacon.png",
          frame_count = 32,
          width = 256,
          height = 320,
          line_length = 8,
          shift = { 0, -0.5 },
          scale = 0.5,
        },
        {
          draw_as_shadow = true,
          animation_speed = 0.5,
          filename = "__space-exploration-graphics-4__/graphics/entity/wide-beacon/wide-beacon-shadow.png",
          frame_count = 32,
          width = 330,
          height = 174,
          line_length = 4,
          shift = { 0.5+4/32, 0.5+4/32 },
          scale = 0.5,
        },
      }
    },
    animation_shadow = blank_image,
    base_picture = blank_image,
    collision_box = { { -1.7, -1.7 }, { 1.7, 1.7 } },
    drawing_box_vertical_extension = 0.7,
    selection_box = { { -2, -2 }, { 2, 2 } },
    corpse = "medium-remnants",
    damaged_trigger_effect = {
      entity_name = "spark-explosion",
      offset_deviation = { { -0.5, -0.5 }, { 0.5, 0.5 } },
      offsets = { { 0, 1 } },
      type = "create-entity"
    },
    dying_explosion = "beacon-explosion",
    energy_source = {
      type = "electric",
      usage_priority = "secondary-input"
    },
    energy_usage = "10000kW",
    max_health = 800,
    module_slots = 15,
    icons_positioning = {
      {inventory_index = defines.inventory.beacon_modules, shift = {x=0,y=-0.5}, max_icons_per_row = 5},
    },
    distribution_effectivity = 0.5,
    supply_area_distance = 14, -- extends from edge of collision box, actual is 16
    radius_visualisation_picture = {
      filename = "__base__/graphics/entity/beacon/beacon-radius-visualization.png",
      height = 10,
      priority = "extra-high-no-scale",
      width = 10
    },
    impact_category = "metal",
    open_sound = data.raw.beacon.beacon.open_sound,
    close_sound = data.raw.beacon.beacon.close_sound
  }
})

local wide_beacon_2 = table.deepcopy(data.raw.beacon[data_util.mod_prefix .. "wide-beacon"])
wide_beacon_2.name = data_util.mod_prefix .. "wide-beacon-2"
wide_beacon_2.icon = "__space-exploration-graphics__/graphics/icons/wide-beacon-2.png"
wide_beacon_2.minable.result = data_util.mod_prefix .. "wide-beacon-2"
wide_beacon_2.animation.layers[1].filename = "__space-exploration-graphics-4__/graphics/entity/wide-beacon/wide-beacon-2.png"
wide_beacon_2.next_upgrade = nil
wide_beacon_2.module_slots = 20
data:extend({wide_beacon_2})
