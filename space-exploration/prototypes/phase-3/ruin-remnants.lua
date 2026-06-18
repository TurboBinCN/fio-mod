local data_util = require("data_util")

local base_remnants = {
  --"small-scorchmark",

  "1x2-remnants",
  "small-remnants",
  "small-generic-remnants",
  "medium-small-remnants",
  "medium-remnants",
  "big-remnants",

  "wooden-chest-remnants",
  "iron-chest-remnants",
  "active-provider-chest-remnants",
  "buffer-chest-remnants",
  "passive-provider-chest-remnants",
  "requester-chest-remnants",
  "steel-chest-remnants",
  "storage-chest-remnants",

  "arithmetic-combinator-remnants",
  "constant-combinator-remnants",
  "decider-combinator-remnants",
  "programmable-speaker-remnants",

  "big-electric-pole-remnants",
  "medium-electric-pole-remnants",
  "small-electric-pole-remnants",
  "substation-remnants",

  "assembling-machine-1-remnants",
  "assembling-machine-2-remnants",
  "assembling-machine-3-remnants",
  "accumulator-remnants",
  "artillery-turret-remnants",
  "boiler-remnants",
  "burner-mining-drill-remnants",
  "electric-mining-drill-remnants",
  "area-mining-drill-remnants",
  "centrifuge-remnants",
  "chemical-plant-remnants",
  "electric-furnace-remnants",
  "heat-exchanger-remnants",
  "heat-pipe-remnants",
  "lab-remnants",
  "nuclear-reactor-remnants",
  "oil-refinery-remnants",
  "pumpjack-remnants",
  "radar-remnants",
  "roboport-remnants",
  "rocket-silo-generic-remnants",
  "rocket-silo-remnants",
  "solar-panel-remnants",
  "steam-engine-remnants",
  "steam-turbine-remnants",
  "steel-furnace-remnants",
  "stone-furnace-remnants",
  "centrifuge-remnants",
  "beacon-remnants",

  "train-stop-remnants",
  "rail-chain-signal-remnants",
  "rail-signal-remnants",

  "transport-belt-remnants",
  "underground-belt-remnants",
  "splitter-remnants",
  "express-splitter-remnants",
  "express-transport-belt-remnants",
  "express-underground-belt-remnants",
  "fast-splitter-remnants",
  "fast-transport-belt-remnants",
  "fast-underground-belt-remnants",

  "pipe-remnants",
  "pipe-to-ground-remnants",
  "pump-remnants",
  "storage-tank-remnants",

  "wall-remnants",
  "gate-remnants",
  "gun-turret-remnants",
  "flamethrower-turret-remnants",
  "laser-turret-remnants",

  "artillery-wagon-remnants",
  "car-remnants",
  "tank-remnants",
  "cargo-wagon-remnants",
  "fluid-wagon-remnants",
  "locomotive-remnants",

  "burner-inserter-remnants",
  "fast-inserter-remnants",
  "filter-inserter-remnants",
  "inserter-remnants",
  "long-handed-inserter-remnants",
  "stack-filter-inserter-remnants",
  "bulk-inserter-remnants",
}

local function search_animations_recursive(set, directioned_animations, directionless_animations)
  if type(set) == "table" then
    if set.filename then
      if set.tiny or set.blend_mode or set.apply_runtime_tint then
        -- figure out some sort of layering in the layers stack?
      else
        if set.direction_count and set.direction_count > 1 then
          table.insert(directioned_animations, set)
        else
          set.direction_count = nil
          table.insert(directionless_animations, set)
        end
      end
    else
      for _, subset in pairs(set) do
        search_animations_recursive(subset, directioned_animations, directionless_animations)
      end
    end
  end
end

local function direction_to_variant(version, i)
  local step = ((i - 1) * (version.frame_count or 1)) or 1
  local x = version.x or (0 + step * version.width)

  if version.line_length then
    x = x % (version.line_length * version.width)
    local y = (version.y or 0) + version.height * (math.floor(((version.x or 0) + step * version.width) / (version.line_length * version.width)))
    version.y = y
  end
  version.x = x
end

-- remnants and corpses that can be used for ruins decoration.
for _, corpse_name in pairs(base_remnants) do
  local corpse = data.raw.corpse[corpse_name]
  if corpse then
    local ruin = table.deepcopy(corpse)
    ruin.name = "ruin-"..corpse.name
    ruin.localised_name = {"space-exploration.ruin"}
    ruin.type = "simple-entity-with-force"
    ruin.time_before_removed = nil

    --ruin.animations = corpse.animation

    local animations = table.deepcopy(corpse.animation)
    if animations.filename then
      animations = {animations}
    end
    local directioned_animations = {}
    local directionless_animations = {}
    search_animations_recursive(animations, directioned_animations, directionless_animations)

    for _, animation in pairs(directioned_animations) do
      local direction_count = animation.direction_count
      for i = 1, direction_count do
        local variant = table.deepcopy(animation)
        variant.direction_count = nil
        if i ~= 1 then
          direction_to_variant(variant, i)
        end
        table.insert(directionless_animations, variant)
      end
    end
    ruin.animations = directionless_animations

    ruin.collision_mask = {
      layers = {
        object = true,
        player = true,
      },
      not_colliding_with_itself = true,
    }
    ruin.minable = {
      mining_time = 0.1,
      results={
        {type = "item", name=data_util.mod_prefix .. "scrap", amount = 1},
      }
    }
    ruin.order = "r[ruin]-" .. (corpse.order or "")
    ruin.collision_box = corpse.collision_box or {{-0.45,-0.45},{0.45,0.45}}
    local left_top = ruin.collision_box[1] or ruin.collision_box.left_top
    local right_bottom = ruin.collision_box[2] or ruin.collision_box.right_bottom
    local min_extent = math.min(
      math.min( -(left_top[1] or left_top.x),
                -(left_top[2] or left_top.y)),
      math.min( right_bottom[1] or right_bottom.x,
                right_bottom[2] or right_bottom.y))
    ruin.collision_box = {{-min_extent,-min_extent},{min_extent,min_extent}}
    ruin.selectable_in_game = true
    ruin.flags = ruin.flags or {}
    ruin.resistances = {
      { type = "suffocation", percent = 100 },
      { type = "meteor", percent = 100 },
      { type = "poison", percent = 100 },
      { type = "cold", percent = 100 },
      { type = "fire", percent = 90 },
    }
    data_util.remove_from_table(ruin.flags, "placeable-neutral")
    if not data_util.table_contains(ruin.flags, "placeable-player") then
      table.insert(ruin.flags, "placeable-player")
    end
    if not data_util.table_contains(ruin.flags, "player-creation") then
      table.insert(ruin.flags, "player-creation")
    end
    ruin.icons = data_util.add_icon_to_stack({{
      icon = "__space-exploration-graphics__/graphics/icons/scrap.png",
      icon_size = 64,
    }}, ruin, {scale = 0.75})
    ruin.icon = nil
    ruin.icon_size = nil
    data:extend({
      {
        type = "item",
        name = ruin.name,
        icons = ruin.icons,
        order = ruin.order,
        stack_size = 50,
        subgroup = "ruins",
        place_result = ruin.name,
        flags = {},
        hidden = true,
        localised_name = ruin.localised_name
      },
      ruin
    })
  end
end

--[[
-- TODO: corpses that don't time out
local base_corpses = {
  "behemoth-biter-corpse", "behemoth-spitter-corpse", "behemoth-worm-corpse",
  "big-biter-corpse", "big-spitter-corpse", "big-worm-corpse",
  "medium-biter-corpse", "medium-spitter-corpse", "medium-worm-corpse",
  "small-biter-corpse", "small-spitter-corpse", "small-worm-corpse",
  "biter-spawner-corpse", "spiter-spawner-corpse"
}]]--

data:extend({
  {
    type = "item",
    name = data_util.mod_prefix .. "blueprint-registration-point",
    icon = "__space-exploration-graphics__/graphics/icons/circle-x.png",
    icon_size = 64,
    stack_size = 50,
    subgroup = "ruins",
    order = "a",
    flags = {},
    hidden = true,
    place_result = data_util.mod_prefix .. "blueprint-registration-point",
  },
  {
    type = "simple-entity-with-force",
    name = data_util.mod_prefix .. "blueprint-registration-point",
    collision_box = {{-0.45,-0.45}, {0.45,0.45}},
    collision_mask = {
      layers = {},
      not_colliding_with_itself = true,
    },
    selection_box = {{-0.45,-0.45}, {0.45,0.45}},
    selection_priority = 200,
    icon = "__space-exploration-graphics__/graphics/icons/circle-x.png",
    icon_size = 64,
    animations = {
      filename = "__space-exploration-graphics__/graphics/icons/circle-x.png",
      width = 32,
      height = 32,
    },
    flags = {},
    hidden = true,
    minable = {mining_time = 0.2, result = data_util.mod_prefix .. "blueprint-registration-point"},
  },
})
