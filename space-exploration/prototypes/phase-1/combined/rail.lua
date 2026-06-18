local data_util = require("data_util")

local collision_floor = {
  layers = {
    --item = true, -- stops player from dropping items on belts.
    floor = true,
    --object = true,
    water_tile = true,
    rail = true,
  }
}

data.raw["rail-signal"]["rail-signal"].collision_mask = collision_floor
data.raw["rail-chain-signal"]["rail-chain-signal"].collision_mask = collision_floor

-------------NORMAL RAILS SECTION----------------
---The goal of this section is to adjust the collision mask of "ground" rails to prevent them from being built in space.

local vanilla_rails = {
  data.raw["straight-rail"]["straight-rail"],
  data.raw["curved-rail-a"]["curved-rail-a"],
  data.raw["curved-rail-b"]["curved-rail-b"],
  data.raw["half-diagonal-rail"]["half-diagonal-rail"]
}

local vanilla_rails_mask = table.deepcopy(collision_mask_util.get_mask(vanilla_rails[1]))
local space_rails_mask = table.deepcopy(vanilla_rails_mask)

vanilla_rails_mask.layers["space_tile"] = true
space_rails_mask.layers.object = nil

for _, rail_prototype in pairs(vanilla_rails) do
  rail_prototype.collision_mask = vanilla_rails_mask
end


-----------------LEGACY SPACE RAILS SECTION-----------------
---CURVED
local legacy_curved_rail = table.deepcopy(data.raw["legacy-curved-rail"]["legacy-curved-rail"])
legacy_curved_rail.name = data_util.mod_prefix .. "space-legacy-curved-rail"
legacy_curved_rail.localised_description = {"entity-description."..data_util.mod_prefix .. "space-legacy-straight-rail"}
legacy_curved_rail.icon = "__space-exploration-graphics__/graphics/icons/space-rail.png"
legacy_curved_rail.icon_size = 64
legacy_curved_rail.minable = { mining_time = 0.2, count = 4, result = data_util.mod_prefix .. "space-rail"}
legacy_curved_rail.fast_replaceable_group = "space-curved-rail"
legacy_curved_rail.next_upgrade = nil
legacy_curved_rail.placeable_by = { count = 4, item = data_util.mod_prefix .. "space-rail"}
legacy_curved_rail.collision_mask = space_rails_mask

data_util.replace_filenames_recursive(legacy_curved_rail.pictures, "__base__/graphics/entity/legacy-curved-rail/", "__space-exploration-graphics__/graphics/entity/space-rail/")
data_util.replace_filenames_recursive(legacy_curved_rail.pictures, "__base__/graphics/entity/rail-endings/rail-endings-background.png", "__space-exploration-graphics__/graphics/entity/space-rail/legacy-rail-endings-background.png")

---STRAIGHT
local legacy_straight_rail = table.deepcopy(data.raw["legacy-straight-rail"]["legacy-straight-rail"])
legacy_straight_rail.name = data_util.mod_prefix .. "space-legacy-straight-rail"
legacy_straight_rail.icon = "__space-exploration-graphics__/graphics/icons/space-rail.png"
legacy_straight_rail.icon_size = 64
legacy_straight_rail.minable = {
  mining_time = 0.2,
  result = data_util.mod_prefix .. "space-rail"
}

legacy_straight_rail.fast_replaceable_group = "space-rail"
legacy_straight_rail.next_upgrade = nil
legacy_straight_rail.placeable_by = { count = 1, item = data_util.mod_prefix .. "space-rail"}
legacy_straight_rail.collision_mask = space_rails_mask

data_util.replace_filenames_recursive(legacy_straight_rail.pictures, "__base__/graphics/entity/legacy-straight-rail/", "__space-exploration-graphics__/graphics/entity/space-rail/")
data_util.replace_filenames_recursive(legacy_straight_rail.pictures, "__base__/graphics/entity/rail-endings/rail-endings-background.png", "__space-exploration-graphics__/graphics/entity/space-rail/legacy-rail-endings-background.png")


data:extend({
  legacy_straight_rail,
  legacy_curved_rail
})

------------NEW SPACE RAILS SECTION-------------
---Adjust graphics

local ground_rail_render_layers =
{
  stone_path_lower = "rail-stone-path-lower",
  stone_path = "rail-stone-path",
  tie = "rail-tie",
  screw = "rail-screw",
  metal = "rail-metal"
}

local rail_segment_visualisation_endings =
{
  filename = "__base__/graphics/entity/rails/rail/rail-segment-visualisations-endings.png",
  priority = "extra-high",
  flags = { "low-object" },
  width = 64,
  height = 64,
  scale = 0.5,
  direction_count = 16,
  frame_count = 6,
  usage = "rail"
}

local function make_new_rail_pictures(keys, elems, max_variations)
  local function make_sprite_definition(filename, elem, key, variation_count)
    return
    {
      filename = filename,
      priority = elem.priority or "extra-high",
      flags = elem.mipmap and { "trilinear-filtering" } or { "low-object" },
      draw_as_shadow = elem.draw_as_shadow,
      allow_forced_downscale = elem.allow_forced_downscale,
      width = key[3][1],
      height = key[3][2],
      x = key[2][1],
      y = key[2][2],
      scale = 0.5;
      shift = util.by_pixel(key[4][1], key[4][2]),
      variation_count = variation_count,
      usage = "rail"
    }
  end

  local res = {}
  for _ , key in ipairs(keys) do
    local part = {}
    --local variation_count = key[5] or 1
    local variation_count = 1 -- lock to 1 for the temp sprite sheet
    if max_variations then
      variation_count = math.min(variation_count, max_variations)
    end
    if (variation_count > 0) then
      for _ , elem in ipairs(elems) do
        local layers = nil
        local variations = variation_count;
        if (elem[1] == "segment_visualisation_middle") then
          variations = nil
        end
        if (type(elem[2]) == "table") then
          layers = { layers = {} }
          for _, subelem in ipairs(elem[2]) do
            table.insert(layers.layers, make_sprite_definition(subelem[1], subelem, key, variations))
          end
        else
          layers = make_sprite_definition(elem[2], elem, key, variations)
        end

        if (elem[1] ~= nil) then
          part[elem[1]] = layers
        else
          part = layers
        end
      end
    end

    res[key[1]] = part
  end
  return res
end

function new_rail_pictures(rail_type)
  local keys
  local NOT_USED_POSITION = {0, 0}
  local NOT_USED_SIZE = {1, 1}
  local NOT_USED_SHIFT = {0, 0}
  if rail_type == "straight" then
    keys =
    {
      {"north",     { 0,  256 }, {256, 256}, {0,0}, 8},
      {"northeast", { 0, 2048 }, {384, 384}, {0,0}, 3},
      {"east",      { 0,    0 }, {256, 256}, {0,0}, 8},
      {"southeast", { 0,  896 }, {384, 384}, {0,0}, 3},
      {"south",     NOT_USED_POSITION, NOT_USED_SIZE, NOT_USED_SHIFT, 0},
      {"southwest", NOT_USED_POSITION, NOT_USED_SIZE, NOT_USED_SHIFT, 0},
      {"west",      NOT_USED_POSITION, NOT_USED_SIZE, NOT_USED_SHIFT, 0},
      {"northwest", NOT_USED_POSITION, NOT_USED_SIZE, NOT_USED_SHIFT, 0}
    }
  elseif rail_type == "half-diagonal" then
    keys =
    {
      {"north",     { 0, 1280 }, {384, 384}, {0,0}, 3},
      {"northeast", { 0, 1664 }, {384, 384}, {0,0}, 3},
      {"east",      { 0, 2432 }, {384, 384}, {0,0}, 3},
      {"southeast", { 0,  512 }, {384, 384}, {0,0}, 3},
      {"south",     NOT_USED_POSITION, NOT_USED_SIZE, NOT_USED_SHIFT, 0},
      {"southwest", NOT_USED_POSITION, NOT_USED_SIZE, NOT_USED_SHIFT, 0},
      {"west",      NOT_USED_POSITION, NOT_USED_SIZE, NOT_USED_SHIFT, 0},
      {"northwest", NOT_USED_POSITION, NOT_USED_SIZE, NOT_USED_SHIFT, 0}
    }
  elseif rail_type == "curved-a" then
    keys =
    {
      {"north",     { 2048,  3 * 512 }, {512, 512}, {0,0}, 4},-- piece 04
      {"northeast", { 2048, 12 * 512 }, {512, 512}, {0,0}, 4},-- piece 13
      {"east",      { 2048,  7 * 512 }, {512, 512}, {0,0}, 4},-- piece 08
      {"southeast", { 2048,  0 * 512 }, {512, 512}, {0,0}, 4},-- piece 01
      {"south",     { 2048, 11 * 512 }, {512, 512}, {0,0}, 4},-- piece 12
      {"southwest", { 2048,  4 * 512 }, {512, 512}, {0,0}, 4},-- piece 05
      {"west",      { 2048, 15 * 512 }, {512, 512}, {0,0}, 4},-- piece 16
      {"northwest", { 2048,  8 * 512 }, {512, 512}, {0,0}, 4},-- piece 09
    }
  elseif rail_type == "curved-b" then
    keys =
    {
      {"north",     { 2048,  2 * 512 }, {512, 512}, {0,0}, 4},-- piece 03
      {"northeast", { 2048, 13 * 512 }, {512, 512}, {0,0}, 4},-- piece 14
      {"east",      { 2048,  6 * 512 }, {512, 512}, {0,0}, 4},-- piece 07
      {"southeast", { 2048,  1 * 512 }, {512, 512}, {0,0}, 4},-- piece 02
      {"south",     { 2048, 10 * 512 }, {512, 512}, {0,0}, 4},-- piece 11
      {"southwest", { 2048,  5 * 512 }, {512, 512}, {0,0}, 4},-- piece 06
      {"west",      { 2048, 14 * 512 }, {512, 512}, {0,0}, 4},-- piece 15
      {"northwest", { 2048,  9 * 512 }, {512, 512}, {0,0}, 4},-- piece 10
    }
  end
  local elems =
  {
    { "metals",                       "__space-exploration-graphics__/graphics/entity/space-rail/space-rail-layer-5.png", mipmap = true },
    { "backplates",                   "__space-exploration-graphics__/graphics/entity/space-rail/space-rail-layer-4.png", mipmap = true },
    { "ties",                         "__space-exploration-graphics__/graphics/entity/space-rail/space-rail-layer-3.png"},
    { "stone_path",                   "__space-exploration-graphics__/graphics/entity/space-rail/space-rail-layer-2.png"},
    { "stone_path_background",        "__space-exploration-graphics__/graphics/entity/space-rail/space-rail-layer-1.png"},
    { "segment_visualisation_middle", "__base__/graphics/entity/rails/rail/rail-segment-visualisations-middle.png"},
  }

  local res = make_new_rail_pictures(keys, elems)
  res["rail_endings"] =
  {
    sheets =
    {
      {
        --filename = "__base__/graphics/entity/rails/rail/rail-endings-background.png",
        filename = "__space-exploration-graphics__/graphics/entity/space-rail/rail-endings-background-16.png",
        priority = "high",
        flags = { "low-object" },
        width = 256,
        height = 256,
        scale = 0.5,
        usage = "rail"
      },
      {
        filename = "__base__/graphics/entity/rails/rail/rail-endings-foreground.png",
        priority = "high",
        flags = { "trilinear-filtering" },
        width = 256,
        height = 256,
        scale = 0.5,
        usage = "rail"
      }
    }
  }
  res["render_layers"] = ground_rail_render_layers
  res["segment_visualisation_endings"] = rail_segment_visualisation_endings
  return res
end

local function apply_grey_tint(rail_pictures)
  for _, property in pairs(rail_pictures) do
    if property.stone_path then
      property.stone_path = nil
      property.stone_path_background = nil
    end
    if property.ties then
      property.ties = nil

    end
  end
  rail_pictures.front_rail_endings = nil
  rail_pictures.back_rail_endings = nil
  rail_pictures.rail_endings = nil

  return rail_pictures
end

local use_new_space_rail_graphics = settings.startup[data_util.mod_prefix.."use-new-space-rail-graphics"].value

local curved_rail_a = table.deepcopy(data.raw["curved-rail-a"]["curved-rail-a"])
curved_rail_a.name = data_util.mod_prefix .. "space-curved-rail-a"
curved_rail_a.localised_description = {"entity-description."..data_util.mod_prefix .. "space-straight-rail"}
curved_rail_a.factoriopedia_alternative = data_util.mod_prefix.."space-straight-rail"
curved_rail_a.icon = "__space-exploration-graphics__/graphics/icons/space-rail.png"
curved_rail_a.icon_size = 64
curved_rail_a.minable.result = data_util.mod_prefix .. "space-rail"
curved_rail_a.placeable_by.item = data_util.mod_prefix .. "space-rail"
curved_rail_a.collision_mask = space_rails_mask
curved_rail_a.next_upgrade = nil
curved_rail_a.pictures = use_new_space_rail_graphics and new_rail_pictures("curved-a") or apply_grey_tint(curved_rail_a.pictures)
curved_rail_a.deconstruction_alternative = "se-space-straight-rail"

local curved_rail_b = table.deepcopy(data.raw["curved-rail-b"]["curved-rail-b"])
curved_rail_b.name = data_util.mod_prefix .. "space-curved-rail-b"
curved_rail_b.localised_description = {"entity-description."..data_util.mod_prefix .. "space-straight-rail"}
curved_rail_b.factoriopedia_alternative = data_util.mod_prefix.."space-straight-rail"
curved_rail_b.icon = "__space-exploration-graphics__/graphics/icons/space-rail.png"
curved_rail_b.icon_size = 64
curved_rail_b.minable.result = data_util.mod_prefix .. "space-rail"
curved_rail_b.placeable_by.item = data_util.mod_prefix .. "space-rail"
curved_rail_b.collision_mask = space_rails_mask
curved_rail_b.next_upgrade = nil
curved_rail_b.pictures = use_new_space_rail_graphics and new_rail_pictures("curved-b") or apply_grey_tint(curved_rail_b.pictures)
curved_rail_b.deconstruction_alternative = "se-space-straight-rail"

local half_diag_rail = table.deepcopy(data.raw["half-diagonal-rail"]["half-diagonal-rail"])
half_diag_rail.name = data_util.mod_prefix .. "space-half-diagonal-rail"
half_diag_rail.localised_description = {"entity-description."..data_util.mod_prefix .. "space-straight-rail"}
half_diag_rail.factoriopedia_alternative = data_util.mod_prefix.."space-straight-rail"
half_diag_rail.icon = "__space-exploration-graphics__/graphics/icons/space-rail.png"
half_diag_rail.icon_size = 64
half_diag_rail.minable.result = data_util.mod_prefix .. "space-rail"
half_diag_rail.placeable_by.item = data_util.mod_prefix .. "space-rail"
half_diag_rail.collision_mask = space_rails_mask
half_diag_rail.next_upgrade = nil
half_diag_rail.pictures = use_new_space_rail_graphics and new_rail_pictures("half-diagonal") or apply_grey_tint(half_diag_rail.pictures)
half_diag_rail.deconstruction_alternative = "se-space-straight-rail"


local straight_rail = table.deepcopy(data.raw["straight-rail"]["straight-rail"])
straight_rail.name = data_util.mod_prefix .. "space-straight-rail"
straight_rail.factoriopedia_alternative = data_util.mod_prefix.."space-straight-rail"
straight_rail.icon = "__space-exploration-graphics__/graphics/icons/space-rail.png"
straight_rail.icon_size = 64
straight_rail.minable = {
  mining_time = 0.2,
  result = data_util.mod_prefix .. "space-rail"
}
straight_rail.placeable_by.item = data_util.mod_prefix .. "space-rail"
straight_rail.collision_mask = space_rails_mask
straight_rail.next_upgrade = nil
straight_rail.pictures = use_new_space_rail_graphics and new_rail_pictures("straight") or apply_grey_tint(straight_rail.pictures)
straight_rail.order = "c[space-rail]-a[straight-rail]"

rails_list = { straight_rail.name, curved_rail_a.name, curved_rail_b.name, half_diag_rail.name }

local rail_planner = table.deepcopy(data.raw["rail-planner"]["rail"])
rail_planner.name = data_util.mod_prefix .. "space-"..rail_planner.name
rail_planner.rails = rails_list
rail_planner.place_result = straight_rail.name
rail_planner.localised_name = { "item-name.".. data_util.mod_prefix .. "space-rail"}
rail_planner.icon = "__space-exploration-graphics__/graphics/icons/space-rail.png"
rail_planner.icon_size = 64
rail_planner.subgroup = "rail"

data:extend(
  {
    straight_rail,
    curved_rail_a,
    curved_rail_b,
    half_diag_rail,
  }
)



--- ELEVATED SPACE RAILS ---
---
if mods["elevated-rails"] then
    local e_vanilla_rails = {
      data.raw["elevated-straight-rail"]["elevated-straight-rail"],
      data.raw["elevated-curved-rail-a"]["elevated-curved-rail-a"],
      data.raw["elevated-curved-rail-b"]["elevated-curved-rail-b"],
      data.raw["elevated-half-diagonal-rail"]["elevated-half-diagonal-rail"]
    }

    local e_vanilla_rails_mask = table.deepcopy(collision_mask_util.get_mask(e_vanilla_rails[1]))
    local e_space_rails_mask = table.deepcopy(e_vanilla_rails_mask)

    for _, rail in pairs(e_vanilla_rails) do
      rail.collision_mask = e_vanilla_rails_mask
      rail.collision_mask.layers["space_tile"] = nil
    end

    e_space_rails_mask.layers.object = nil
    e_space_rails_mask.layers.space_tile = nil

    local e_curved_rail_a = table.deepcopy(data.raw["elevated-curved-rail-a"]["elevated-curved-rail-a"])
    e_curved_rail_a.name = data_util.mod_prefix .. "elevated-space-curved-rail-a"
    e_curved_rail_a.localised_description = {"entity-description."..data_util.mod_prefix .. "space-straight-rail"}
    e_curved_rail_a.icon = "__space-exploration-graphics__/graphics/icons/space-rail.png"
    e_curved_rail_a.icon_size = 64
    e_curved_rail_a.minable.result = data_util.mod_prefix .. "space-rail"
    e_curved_rail_a.placeable_by.item = data_util.mod_prefix .. "space-rail"
    e_curved_rail_a.collision_mask = e_space_rails_mask
    --e_curved_rail_a.fast_replaceable_group = "space-curved-rail"
    e_curved_rail_a.next_upgrade = nil
    e_curved_rail_a.pictures = apply_grey_tint(e_curved_rail_a.pictures)
    e_curved_rail_a.se_allow_in_space = true
    e_curved_rail_a.deconstruction_alternative = "se-elevated-space-straight-rail"

    local e_curved_rail_b = table.deepcopy(data.raw["elevated-curved-rail-b"]["elevated-curved-rail-b"])
    e_curved_rail_b.name = data_util.mod_prefix .. "elevated-space-curved-rail-b"
    e_curved_rail_b.localised_description = {"entity-description."..data_util.mod_prefix .. "space-straight-rail"}
    e_curved_rail_b.icon = "__space-exploration-graphics__/graphics/icons/space-rail.png"
    e_curved_rail_b.icon_size = 64
    e_curved_rail_b.minable.result = data_util.mod_prefix .. "space-rail"
    e_curved_rail_b.placeable_by.item = data_util.mod_prefix .. "space-rail"
    e_curved_rail_b.collision_mask = e_space_rails_mask
    --e_curved_rail_b.fast_replaceable_group = "space-curved-rail"
    e_curved_rail_b.next_upgrade = nil
    e_curved_rail_b.pictures = apply_grey_tint(e_curved_rail_b.pictures)
    e_curved_rail_b.se_allow_in_space = true
    e_curved_rail_b.deconstruction_alternative = "se-elevated-space-straight-rail"

    local e_half_diag_rail = table.deepcopy(data.raw["elevated-half-diagonal-rail"]["elevated-half-diagonal-rail"])
    e_half_diag_rail.name = data_util.mod_prefix .. "elevated-space-half-diagonal-rail"
    e_half_diag_rail.localised_description = {"entity-description."..data_util.mod_prefix .. "space-straight-rail"}
    e_half_diag_rail.icon = "__space-exploration-graphics__/graphics/icons/space-rail.png"
    e_half_diag_rail.icon_size = 64
    e_half_diag_rail.minable.result = data_util.mod_prefix .. "space-rail"
    e_half_diag_rail.placeable_by.item = data_util.mod_prefix .. "space-rail"
    e_half_diag_rail.collision_mask = e_space_rails_mask
    --e_half_diag_rail.fast_replaceable_group = "space-curved-rail"
    e_half_diag_rail.next_upgrade = nil
    e_half_diag_rail.pictures = apply_grey_tint(e_half_diag_rail.pictures)
    e_half_diag_rail.se_allow_in_space = true
    e_half_diag_rail.deconstruction_alternative = "se-elevated-space-straight-rail"

    local e_straight_rail = table.deepcopy(data.raw["elevated-straight-rail"]["elevated-straight-rail"])
    e_straight_rail.name = data_util.mod_prefix .. "elevated-space-straight-rail"
    e_straight_rail.icon = "__space-exploration-graphics__/graphics/icons/space-rail.png"
    e_straight_rail.icon_size = 64
    e_straight_rail.minable = {
      mining_time = 0.2,
      result = data_util.mod_prefix .. "space-rail"
    }
    e_straight_rail.placeable_by.item = data_util.mod_prefix .. "space-rail"
    e_straight_rail.collision_mask = e_space_rails_mask
    --e_straight_rail.fast_replaceable_group = "space-rail"
    e_straight_rail.next_upgrade = nil
    e_straight_rail.pictures = apply_grey_tint(e_straight_rail.pictures)
    e_straight_rail.se_allow_in_space = true
    e_straight_rail.order = "d[elevated-space-rail]-a[elevated-straight-rail]"

    for _, e_rail in ipairs({e_curved_rail_a, e_curved_rail_b, e_half_diag_rail, e_straight_rail}) do
      for _, side in ipairs({"A", "B"}) do
        local rail_fence_picture_set = e_rail.fence_pictures["side_" .. side]
        local rail_fence_direction_sets = {
          rail_fence_picture_set.fence,
          rail_fence_picture_set.fence_upper,
        }
        for _, rail_fence_direction_set in ipairs(rail_fence_picture_set.ends) do
          table.insert(rail_fence_direction_sets, rail_fence_direction_set)
        end
        for _, rail_fence_direction_set in ipairs(rail_fence_picture_set.ends_upper) do
          table.insert(rail_fence_direction_sets, rail_fence_direction_set)
        end
        local search = "__elevated-rails__/graphics/entity/elevated-rail/elevated-rail"
        local replace = "__space-exploration-graphics__/graphics/entity/elevated-space-rail/elevated-space-rail"
        if mods["elevated-rails-recolor"] then
          search = "__elevated-rails-recolor__/graphics/entity/elevated-rail/elevated-rail"
        end
        for _, rail_fence_direction_set in ipairs(rail_fence_direction_sets) do
          for direction, sprite_variations in pairs(rail_fence_direction_set) do
            if sprite_variations.layers then -- apparently one of the south ones can be totally empty?
              -- for _, layer in ipairs(sprite_variations.layers) do
              --   layer.filename = replace .. string.sub(layer.filename, #search + 1)
              -- end
              local layer = sprite_variations.layers[1] -- 2 has the shadow, we do not have graphics for that
              layer.filename = replace .. string.sub(layer.filename, #search + 1)
            end
          end
        end
      end
    end

    local rail_ramp = data.raw["rail-ramp"]["rail-ramp"]

    -- has no space corpse/item/recipe/tech yet
    local e_rail_ramp = table.deepcopy(rail_ramp)
    e_rail_ramp.name = data_util.mod_prefix .. "space-rail-ramp"
    e_rail_ramp.icon = "__space-exploration-graphics__/graphics/icons/space-rail-ramp.png"
    e_rail_ramp.se_allow_in_space = true

    local e_rail_ramp_item = table.deepcopy(data.raw["rail-planner"]["rail-ramp"])
    e_rail_ramp_item.name = e_rail_ramp.name
    e_rail_ramp_item.icon = e_rail_ramp.icon
    e_rail_ramp_item.order = "a[rail]-e[se-space-rail-ramp]"
    e_rail_ramp_item.place_result = e_rail_ramp.name
    e_rail_ramp.minable.result = e_rail_ramp_item.name
    data:extend{e_rail_ramp_item}

    data_util.make_recipe({
      name = e_rail_ramp_item.name,
      ingredients = {
        { type = "item", name = data_util.mod_prefix .. "holmium-cable", amount = 10},
        { type = "item", name = "steel-plate", amount = 10},
        { type = "item", name = "rail-ramp", amount = 10},
        { type = "item", name = data_util.mod_prefix .. "energy-catalogue-1", amount = 1},
      },
      results = {
        { type = "item", name = e_rail_ramp_item.name, amount = 10},
      },
      energy_required = 10,
      category = "space-manufacturing",
      enabled = false,
      always_show_made_in = true,
    })
    table.insert(data.raw["technology"][data_util.mod_prefix .. "space-rail"].effects, {
      type = "unlock-recipe", recipe = e_rail_ramp_item.name,
    })

    e_rail_ramp.collision_mask = {layers={elevated_rail=true, rail=true, rail_support=true, is_lower_object=true, is_object=true, floor=true, player=true}} -- default - object + floor + player
    e_rail_ramp.collision_mask_allow_on_deep_oil_ocean = {layers={elevated_rail=true, rail=true, is_lower_object=true, is_object=true, floor=true, player=true}} -- above - rail_support
    e_rail_ramp.tile_buildability_rules = nil
    rail_ramp.tile_buildability_rules[1].required_tiles.layers.planet_tile = true -- allows placing the rail ramp on lab tiles (collision-common.lua removes ground_tile from lab tiles)

    -- todo: also use space remnant graphics present in space-exploration-graphics
    for _, direction in ipairs({"north", "east", "south", "west"}) do
      e_rail_ramp.pictures[direction].ties.filename = "__space-exploration-graphics__/graphics/entity/elevated-space-rail-ramp/elevated-space-rail-ramp-base.png"
      e_rail_ramp.pictures[direction].stone_path.filename = "__space-exploration-graphics__/graphics/entity/elevated-space-rail-ramp/elevated-space-rail-ramp.png"
      e_rail_ramp.pictures[direction].shadow_subtract_mask.filename = "__space-exploration-graphics__/graphics/entity/elevated-space-rail-ramp/elevated-space-rail-ramp.png"
      e_rail_ramp.pictures[direction].shadow_mask.filename = "__space-exploration-graphics__/graphics/entity/elevated-space-rail-ramp/elevated-space-rail-ramp-mask.png"
    end
    for _, side in ipairs({"A", "B"}) do
      local rail_fence_picture_set = e_rail_ramp.fence_pictures["side_" .. side]
      for _, direction in ipairs({"north", "east", "south", "west"}) do
        rail_fence_picture_set.fence[direction].filename = "__space-exploration-graphics__/graphics/entity/elevated-space-rail-ramp/elevated-space-rail-ramp-fence-" .. side .. ".png"
        rail_fence_picture_set.ends[1][direction].filename = "__space-exploration-graphics__/graphics/entity/elevated-space-rail-ramp/elevated-space-rail-ramp-fence-" .. side .. ".png"
        rail_fence_picture_set.ends[2][direction].filename = "__space-exploration-graphics__/graphics/entity/elevated-space-rail-ramp/elevated-space-rail-ramp-fence-" .. side .. ".png"
        rail_fence_picture_set.ends[3][direction].filename = "__space-exploration-graphics__/graphics/entity/elevated-space-rail-ramp/elevated-space-rail-ramp-fence-" .. side .. "-end.png"
        rail_fence_picture_set.ends[4][direction].filename = "__space-exploration-graphics__/graphics/entity/elevated-space-rail-ramp/elevated-space-rail-ramp-fence-" .. side .. "-end.png"
      end
    end

    local e_rail_support = table.deepcopy(data.raw["rail-support"]["rail-support"])
    e_rail_support.name = data_util.mod_prefix .. "space-rail-support"
    e_rail_support.icon = "__space-exploration-graphics__/graphics/icons/space-rail-support.png"
    e_rail_support.se_allow_in_space = true

    local e_rail_support_item = table.deepcopy(data.raw["item"]["rail-support"])
    e_rail_support_item.name = e_rail_support.name
    e_rail_support_item.icon = e_rail_support.icon
    e_rail_support_item.order = "a[rail]-f[se-space-rail-support]"
    e_rail_support_item.place_result = e_rail_support.name
    e_rail_support.minable.result = e_rail_support_item.name
    data:extend{e_rail_support_item}

    data_util.make_recipe({
      name = e_rail_support_item.name,
      ingredients = {
        { type = "item", name = data_util.mod_prefix .. "holmium-cable", amount = 20},
        { type = "item", name = "steel-plate", amount = 20},
        { type = "item", name = "rail-support", amount = 20},
        { type = "item", name = data_util.mod_prefix .. "energy-catalogue-1", amount = 1},
      },
      results = {
        { type = "item", name = e_rail_support_item.name, amount = 20},
      },
      energy_required = 20,
      category = "space-manufacturing",
      enabled = false,
      always_show_made_in = true,
    })
    table.insert(data.raw["technology"][data_util.mod_prefix .. "space-rail"].effects, {
      type = "unlock-recipe", recipe = e_rail_support_item.name,
    })
    data_util.tech_add_prerequisites("elevated-rail", {"railway"})

    do -- move elevated rails to pre-space
      data_util.tech_remove_prerequisites("elevated-rail", {"space-science-pack", "production-science-pack"})
      data_util.tech_remove_ingredients("elevated-rail", {"space-science-pack", "production-science-pack"})

      data_util.tech_add_prerequisites("elevated-rail", {data_util.mod_prefix .. "rocket-science-pack"})
      data_util.tech_add_ingredients("elevated-rail", {data_util.mod_prefix .. "rocket-science-pack"})
    end

    e_rail_support.collision_mask = {layers={rail=true, rail_support=true, is_lower_object=true, is_object=true, floor=true, player=true}} -- default - object + floor + player
    e_rail_support.collision_mask_allow_on_deep_oil_ocean = {layers={rail=true, is_lower_object=true, is_object=true, floor=true, player=true}} -- above - rail_support
    e_rail_support.tile_buildability_rules =
    {
      {
        area = {{-1.9, -1.9}, {1.9, 1.9}},
        colliding_tiles = {layers = {moving_tile = true}},
        remove_on_collision = true
      }
    }

    -- todo: also use space remnant graphics present in space-exploration-graphics
    e_rail_support.graphics_set.structure.layers[1].filename = "__space-exploration-graphics__/graphics/entity/elevated-space-rail-pylon/elevated-space-rail-pylon.png"

    e_rails_list = {e_curved_rail_a.name, e_curved_rail_b.name, e_half_diag_rail.name, e_straight_rail.name, e_rail_ramp.name }

    for _, rail in pairs(e_rails_list) do
      table.insert(rails_list, rail)
    end

    rail_planner.rails = rails_list
    rail_planner.support = e_rail_support.name

    -- for some reason the rail ramp item itself is a planner too, so we will have to override the contents with space versions
    e_rail_ramp_item.rails = table.deepcopy(rail_planner.rails)
    e_rail_ramp_item.support = rail_planner.support

    data:extend(
    {
      e_curved_rail_a,
      e_curved_rail_b,
      e_half_diag_rail,
      e_straight_rail,
      e_rail_ramp,
      e_rail_support,
    }
    )
else



end

data:extend(
  {
    rail_planner
  }
)

-- elevated space rail checklist:
-- - space rail ramp CANNOT be placed on a space assembling machine
-- - space rail support CANNOT be placed on a space assembling machine
-- - space rail ramp CANNOT be placed on a space transport belt
-- - space rail support CANNOT be placed on a space transport belt
-- - space rail ramp CANNOT be placed on a spaceship floor
-- - space rail support CANNOT be placed on a spaceship floor
-- - elevated space rail CAN connect to a space rail support
