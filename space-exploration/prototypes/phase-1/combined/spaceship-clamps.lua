local data_util = require("data_util")

local clamp_health = 1000

local blank = {
  direction_count = 8,
  frame_count = 1,
  filename = "__space-exploration-graphics__/graphics/blank.png",
  width = 1,
  height = 1,
  priority = "low"
}
local picture_left = {
  filename = "__space-exploration-graphics__/graphics/entity/spaceship-clamps/spaceship-clamps.png",
  width = 192,
  height = 160,
  x = 192,
  y = 160,
  priority = "high",
  scale = 0.5,
  shift = {0,0},
  variation_count = 1,
}
local picture_right = {
  filename = "__space-exploration-graphics__/graphics/entity/spaceship-clamps/spaceship-clamps.png",
  width = 192,
  height = 160,
  y = 160,
  priority = "high",
  scale = 0.5,
  shift = {0,0},
  variation_count = 1,
}

data:extend({
    {
        type = "item",
        name = data_util.mod_prefix .. "spaceship-clamp",
        icon = "__space-exploration-graphics__/graphics/icons/spaceship-clamp.png",
        icon_size = 64,
        order = "c-a",
        subgroup = "spaceship-structure",
        stack_size = 50,
        place_result = data_util.mod_prefix .. "spaceship-clamp-place",
    },
    {
        type = "recipe",
        name = data_util.mod_prefix .. "spaceship-clamp",
        results = {
          {type = "item", name = data_util.mod_prefix .. "spaceship-clamp", amount = 1},
        },
        enabled = false,
        energy_required = 30,
        ingredients = {
          {type = "item", name = data_util.mod_prefix .. "aeroframe-scaffold", amount = 10 },
          {type = "item", name = data_util.mod_prefix .. "heavy-girder", amount = 6 },
          {type = "item", name = "electric-engine-unit", amount = 10 },
          {type = "item", name = "processing-unit", amount = 10 },
        },
        requester_paste_multiplier = 1,
        always_show_made_in = false,
    },
    --[[
    {
        type = "item",
        name = data_util.mod_prefix .. "spaceship-clamp-anchor",
        icon = "__space-exploration-graphics__/graphics/icons/spaceship-clamp-anchor.png",
        icon_size = 64,
        order = "c-b",
        subgroup = "energy",
        stack_size = 50,
        place_result = data_util.mod_prefix .. "spaceship-clamp-anchor",
    },
    {
        type = "recipe",
        name = data_util.mod_prefix .. "spaceship-clamp-anchor",
        result = {
          {type = "item", name = data_util.mod_prefix .. "spaceship-clamp-anchor", amount = 1},
        },
        enabled = false,
        energy_required = 30,
        ingredients = {
          {type = "item", name = data_util.mod_prefix .. "aeroframe-scaffold", amount = 6 },
          {type = "item", name = data_util.mod_prefix .. "heavy-girder", amount = 10 },
          {type = "item", name = "electric-engine-unit", amount = 10 },
          {type = "item", name = "processing-unit", amount = 10 },
        },
        requester_paste_multiplier = 1,
        always_show_made_in = true,
    },]]
    {
        type = "technology",
        name = data_util.mod_prefix .. "spaceship-clamps",
        effects = {
          { type = "unlock-recipe", recipe = data_util.mod_prefix .. "spaceship-clamp" },
          --{ type = "unlock-recipe", recipe = data_util.mod_prefix .. "spaceship-clamp-anchor" },
        },
        icon = "__space-exploration-graphics__/graphics/technology/spaceship-clamps.png",
        icon_size = 128,
        order = "e-g",
        prerequisites = {
          data_util.mod_prefix .. "spaceship",
          data_util.mod_prefix .. "heavy-girder",
        },
        unit = {
         count = 500,
         time = 60,
         ingredients = {
           { "automation-science-pack", 1 },
           { "logistic-science-pack", 1 },
           { "chemical-science-pack", 1 },
           { data_util.mod_prefix .. "rocket-science-pack", 1 },
           { data_util.mod_prefix .. "astronomic-science-pack-3", 1 },
           { data_util.mod_prefix .. "material-science-pack-1", 1 },
         }
       },
    },
    {
      type = "storage-tank",
      name = data_util.mod_prefix .. "spaceship-clamp-place",
      subgroup = "composite-entity-parts",
      hidden = true,
      icons = {{icon = "__space-exploration-graphics__/graphics/icons/spaceship-clamp.png",}},
      minable = {mining_time = 0.5, result = data_util.mod_prefix .. "spaceship-clamp"},
      se_allow_in_space = true,
      corpse = "legacy-straight-rail-remnants",
      collision_box = {{-0.99,-0.99},{0.99,0.99}},
      collision_mask = {
        layers ={
          player = true,
          floor = true,
          item = true,
        },
      },
      selection_box = {{-1,-1},{1,1}},
      flags = {
        "placeable-neutral",
        "player-creation",
      },
      max_health = clamp_health,
      pictures = {
        picture = {
          north = picture_right,
          east = picture_left,
          south = blank,
          west = blank,
        },
        window_background = blank,
        fluid_background = blank,
        flow_sprite = blank,
        gas_flow = blank
      },
      fluid_box = {
        volume = 100 * 0.000001, -- Just so it shows "Storage size: 0"
        pipe_connections = {},
        hide_connection_info = true
      },
      window_bounding_box = {{0,0},{0,0}},
      flow_length_in_ticks = 1,
      two_direction_only = true,
      draw_copper_wires = false,
      draw_circuit_wires = false,
      build_grid_size = 2,
    },
    {
      type = "constant-combinator",
      name = data_util.mod_prefix .. "spaceship-clamp",
      placeable_by = {item=data_util.mod_prefix .. "spaceship-clamp", count = 1},
      minable = {mining_time = 0.5, result = data_util.mod_prefix .. "spaceship-clamp"},
      flags = {
        "placeable-neutral",
        "player-creation",
        "hide-alt-info",
      },
      icon = "__space-exploration-graphics__/graphics/icons/spaceship-clamp.png",
      icon_size = 64,
      order="c",
      max_health = clamp_health,
      open_sound = data_util.machine_open_sound,
      close_sound = data_util.machine_close_sound,
      corpse = "small-remnants",
      collision_box = {{-0.99,-0.99},{0.99,0.99}},
      collision_mask = {
        layers = {
          player = true,
          floor = true,
          item = true,
        },
      },
      build_grid_size = 2,
      selection_box = {{-1,-1},{1,1}},
      scale_info_icons = false,
      item_slot_count = 1,
      sprites =
      {
        north = picture_left,
        east = picture_right,
        south = picture_right,
        west = picture_left
      },
      activity_led_sprites =
      {
          north = blank,
          east = blank,
          south = blank,
          west = blank
      },
      activity_led_light =
      {
          intensity = 0.8,
          size = 1,
      },
      activity_led_light_offsets =
      {
          {0, 0},
          {0, 0},
          {0, 0},
          {0, 0}
      },
      circuit_wire_connection_points =
      {
        {
          wire = { red = {0,0}, green = {0,0}, },
          shadow = { red = {0,0}, green = {0,0}, },
        },
        {
          wire = { red = {-0.5,0.8}, green = {-0.7,0.8}, },
          shadow = { red = {-0.5,0.8}, green = {-0.7,0.8}, },
        },
        {
          wire = { red = {0,0}, green = {0,0}, },
          shadow = { red = {0,0}, green = {0,0}, },
        },
        {
          wire = { red = {0.7,0.8}, green = {0.5,0.8}, },
          shadow = { red = {0.7,0.8}, green = {0.5,0.8}, },
        },
      },
      circuit_wire_max_distance = 8
    },
    {
      type = "electric-pole",
      name = data_util.mod_prefix .. "spaceship-clamp-power-pole-internal",
      subgroup = "composite-entity-parts",
      order = "a",
      factoriopedia_alternative = data_util.mod_prefix.."spaceship-clamp",
      localised_name = {"entity-name.se-spaceship-clamp"},
      hidden = true,
      selectable_in_game = false,
      maximum_wire_distance = 1.4,
      -- this pole is positioned on the front side of the clamp
      -- which is not necessarily over the top of spaceship flooring
      -- so if it has too small of a collision box, it will not be cloned
      -- with the ship (since the ship only clones things on tiles it cares about)
      -- so the collision box needs to be large enough such that the pole
      -- overlaps with the tiles on the back side of the clamp
      -- NOTE: if the collision box is too small it won't break anything,
      -- but it will force this power pole to be recreated every time the ship launches/lands
      -- which will mess with the autoconnection of electric wires
      collision_box = {{-0.6,-0.6},{0.6,0.6}},
      collision_mask = {layers={}},
      flags = { "placeable-neutral", "player-creation", "placeable-off-grid" },
      icons = data_util.add_icons(
        "__space-exploration-graphics__/graphics/icons/spaceship-clamp.png",
        "__space-exploration-graphics__/graphics/icons/addon-power-pole.png"
      ),
      pictures =
      {
        direction_count = 1,
        frame_count = 1,
        filename = "__space-exploration-graphics__/graphics/blank.png",
        width = 1,
        height = 1,
        priority = "low"
      },
      supply_area_distance = 0,
      connection_points = {
        {
          wire = { red = {0,0}, green = {0,0}, copper = {0,0}, },
          shadow = { red = {0,0}, green = {0,0}, copper = {0,0}, },
        },
      },
      draw_copper_wires = false,
      draw_circuit_wires = false,
    },
    {
      type = "electric-pole",
      name = data_util.mod_prefix .. "spaceship-clamp-power-pole-external-west",
      subgroup = "composite-entity-parts",
      order = "a",
      hidden = true,
      factoriopedia_alternative = data_util.mod_prefix.."spaceship-clamp",
      fast_replaceable_group = data_util.mod_prefix .. "spaceship-clamp-power-pole-external-west",
      placeable_by = {item = data_util.mod_prefix .. "struct-generic-clamp-west", count = 1},
      selection_box = {{-0.5,-0.5},{0.5,0.5}},
      collision_box = {{-0.1,-0.1},{0.1,0.1}},
      selection_priority = 150,
      maximum_wire_distance = 16,
      collision_mask = {
        layers = {
          [composite_entity_circuit_connection_layer] = true,
        },
      },
      flags = { "placeable-neutral", "player-creation", "placeable-off-grid", "not-rotatable", "not-deconstructable" },
      icons = data_util.add_icons(
        "__space-exploration-graphics__/graphics/icons/spaceship-clamp.png",
        data.raw.item["constant-combinator"].icon
      ),
      pictures =
      {
        direction_count = 1,
        frame_count = 1,
        filename = "__space-exploration-graphics__/graphics/blank.png",
        width = 1,
        height = 1,
        priority = "low"
      },
      supply_area_distance = 0,
      connection_points = {
        {
          wire = { red = {0.40,-0.32}, green = {0.40,-0.13}, copper = {0.17,-0.4}, },
          shadow = { red = {0.40,-0.32}, green = {0.40,-0.13}, copper = {0.17,-0.4}, },
        },
      },
      draw_copper_wires = true,
      draw_circuit_wires = true,
      open_sound = data_util.electric_network_open_sound,
      close_sound = data_util.electric_network_close_sound,
    },
    {
      type = "electric-pole",
      name = data_util.mod_prefix .. "spaceship-clamp-power-pole-external-east",
      subgroup = "composite-entity-parts",
      order = "a",
      hidden = true,
      factoriopedia_alternative = data_util.mod_prefix.."spaceship-clamp",
      fast_replaceable_group = data_util.mod_prefix .. "spaceship-clamp-power-pole-external-east",
      placeable_by = {item = data_util.mod_prefix .. "struct-generic-clamp-east", count = 1},
      selection_box = {{-0.5,-0.5},{0.5,0.5}},
      collision_box = {{-0.1,-0.1},{0.1,0.1}},
      selection_priority = 150,
      maximum_wire_distance = 16,
      collision_mask = {
        layers = {
          [composite_entity_circuit_connection_layer] = true,
        },
      },
      flags = { "placeable-neutral", "player-creation", "placeable-off-grid", "not-rotatable", "not-deconstructable" },
      icons = data_util.add_icons(
        "__space-exploration-graphics__/graphics/icons/spaceship-clamp.png",
        data.raw.item["constant-combinator"].icon
      ),
      pictures =
      {
        direction_count = 1,
        frame_count = 1,
        filename = "__space-exploration-graphics__/graphics/blank.png",
        width = 1,
        height = 1,
        priority = "low"
      },
      supply_area_distance = 0,
      connection_points = {
        {
          wire = { red = {-0.40,-0.32}, green = {-0.40,-0.13}, copper = {-0.17,-0.4}, },
          shadow = { red = {-0.40,-0.32}, green = {-0.40,-0.13}, copper = {-0.17,-0.4}, },
        },
      },
      draw_copper_wires = true,
      draw_circuit_wires = true,
      open_sound = data_util.electric_network_open_sound,
      close_sound = data_util.electric_network_close_sound,
    },
})
