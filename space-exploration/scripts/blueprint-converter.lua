local BlueprintConverter = {}

BlueprintConverter.name_shortcut = mod_prefix.."blueprint-converter"

--list of entity types per subgroup to check for as well as their corresponding conversion target if any. If no conversion target given, will default to first in the item list.
BlueprintConverter.suggested_entity_targets = {
  ["curved-rail-a"] = {},
  ["curved-rail-b"] = {},
  ["straight-rail"] = {},
  ["half-diagonal-rail"] = {},
  ["elevated-curved-rail-a"] = {},
  ["elevated-curved-rail-b"] = {},
  ["elevated-straight-rail"] = {},
  ["elevated-half-diagonal-rail"] = {},
  ["legacy-straight-rail"] = {},
  ["legacy-curved-rail"] = {},
  ["transport-belt"] = {["transport-belt"] = {ground = "express-transport-belt"}},
  ["splitter"] = {["splitter"] = {ground = "express-splitter"}},
  ["underground-belt"] = {["underground-belt"] = {ground = "express-underground-belt"}},
  ["loader"] = {},
  ["loader-1x1"] = {
    ["loader"] = {ground = "aai-express-loader"}, --AAI loaders
    ["belt"] = {ground = "kr-express-loader"} --Krastorio 2
  },
  ["pipe"] = {},
  ["pipe-to-ground"] = {},
}

--forced entity->entity conversion lists per mod
BlueprintConverter.modded_entity_targets = {
  [{"space-exploration"}] = { --hard code these so we don't have to worry about auto detection on the vast number of assembling machines
    ["burner-assembling-machine"] = "se-space-assembling-machine",
    ["assembling-machine-1"] = "se-space-assembling-machine",
    ["assembling-machine-2"] = "se-space-assembling-machine",
    ["assembling-machine-3"] = "se-space-assembling-machine",
    ["se-space-assembling-machine"] = "assembling-machine-3",
  },
  [{"underground-pipe-pack"}] = { --these don't have a decent way to be auto detected because of how they are grouped
    ["one-to-one-forward-pipe"] = "one-to-one-forward-space-pipe",
    ["one-to-one-forward-t2-pipe"] = "one-to-one-forward-space-pipe",
    ["one-to-one-forward-t3-pipe"] = "one-to-one-forward-space-pipe",
    ["one-to-one-forward-space-pipe"] = "one-to-one-forward-pipe",
    ["one-to-two-perpendicular-pipe"] = "one-to-two-perpendicular-space-pipe",
    ["one-to-two-perpendicular-t2-pipe"] = "one-to-two-perpendicular-space-pipe",
    ["one-to-two-perpendicular-t3-pipe"] = "one-to-two-perpendicular-space-pipe",
    ["one-to-two-perpendicular-space-pipe"] = "one-to-two-perpendicular-pipe",
    ["one-to-three-forward-pipe"] = "one-to-three-forward-space-pipe",
    ["one-to-three-forward-t2-pipe"] = "one-to-three-forward-space-pipe",
    ["one-to-three-forward-t3-pipe"] = "one-to-three-forward-space-pipe",
    ["one-to-three-forward-space-pipe"] = "one-to-three-forward-pipe",
    ["one-to-four-pipe"] = "one-to-four-space-pipe",
    ["one-to-four-t2-pipe"] = "one-to-four-space-pipe",
    ["one-to-four-t3-pipe"] = "one-to-four-space-pipe",
    ["one-to-four-space-pipe"] = "one-to-four-pipe",
    ["underground-i-pipe"] = "underground-i-space-pipe",
    ["underground-i-t2-pipe"] = "underground-i-space-pipe",
    ["underground-i-t3-pipe"] = "underground-i-space-pipe",
    ["underground-i-space-pipe"] = "underground-i-pipe",
    ["underground-L-pipe"] = "underground-L-space-pipe",
    ["underground-L-t2-pipe"] = "underground-L-space-pipe",
    ["underground-L-t3-pipe"] = "underground-L-space-pipe",
    ["underground-L-space-pipe"] = "underground-L-pipe",
    ["underground-t-pipe"] = "underground-t-space-pipe",
    ["underground-t-t2-pipe"] = "underground-t-space-pipe",
    ["underground-t-t3-pipe"] = "underground-t-space-pipe",
    ["underground-t-space-pipe"] = "underground-t-pipe",
    ["underground-cross-pipe"] = "underground-cross-space-pipe",
    ["underground-cross-t2-pipe"] = "underground-cross-space-pipe",
    ["underground-cross-t3-pipe"] = "underground-cross-space-pipe",
    ["underground-cross-space-pipe"] = "underground-cross-pipe",
  },
  [{"miniloader"}] = { --miniloaders are coded as inserters and we don't want to auto detect because of the vast number of inserters out there
    ["chute-miniloader-inserter"] = "space-miniloader-inserter",
    ["miniloader-inserter"] = "space-miniloader-inserter",
    ["fast-miniloader-inserter"] = "space-miniloader-inserter",
    ["express-miniloader-inserter"] = "space-miniloader-inserter",
    ["filter-miniloader-inserter"] = "space-filter-miniloader-inserter",
    ["fast-filter-miniloader-inserter"] = "space-filter-miniloader-inserter",
    ["express-filter-miniloader-inserter"] = "space-filter-miniloader-inserter",
    ["space-miniloader-inserter"] = "express-miniloader-inserter",
    ["deep-space-miniloader-inserter"] = "express-miniloader-inserter",
    ["space-filter-miniloader-inserter"] = "express-filter-miniloader-inserter",
    ["deep-space-filter-miniloader-inserter"] = "express-filter-miniloader-inserter",
  },
  [{"miniloader", "Krastorio2"}] = {
    ["kr-advanced-miniloader-inserter"] = "space-miniloader-inserter",
    ["kr-advanced-filter-miniloader-inserter"] = "space-filter-miniloader-inserter",
    ["kr-superior-miniloader-inserter"] = "space-miniloader-inserter",
    ["kr-superior-filter-miniloader-inserter"] = "space-filter-miniloader-inserter",
  },
  [{"elevated-rails"}] = {
    ["rail-ramp"] = "se-space-rail-ramp",
    ["rail-support"] = "se-space-rail-support",
    ["elevated-curved-rail-a"] = "se-elevated-space-curved-rail-a",
    ["elevated-curved-rail-b"] = "se-elevated-space-curved-rail-b",
    ["elevated-straight-rail"] = "se-elevated-space-straight-rail",
    ["elevated-half-diagonal-rail"] = "se-elevated-space-half-diagonal-rail",

    ["se-space-rail-ramp"] = "rail-ramp",
    ["se-space-rail-support"] = "rail-support",
    ["se-elevated-space-curved-rail-a"] = "elevated-curved-rail-a",
    ["se-elevated-space-curved-rail-b"] = "elevated-curved-rail-b",
    ["se-elevated-space-straight-rail"] = "elevated-straight-rail",
    ["se-elevated-space-half-diagonal-rail"] = "elevated-half-diagonal-rail",
  }
}

--contains mapping of entity->entity to convert
--needs BlueprintConverter.create_converter_list_entities() to populate
BlueprintConverter.converter_list_entities = nil

--contains mapping of tile->tile to convert
--needs BlueprintConverter.create_converter_list_tiles() to populate
BlueprintConverter.converter_list_tiles = nil

--contains mapping of item->item for blueprint icon conversion
--populates during .create_converter_list_entities() and .create_converter_list_tiles()
BlueprintConverter.convert_list_items = nil

--list of tile targets for conversion
BlueprintConverter.tile_targets = {
  ground = "landfill",
  space = mod_prefix.."space-platform-scaffold"
}

--Returns filters needed to find space/ground prototypes. Cannot be a constant due to use of `storage`
---@param invert? boolean Invert the filter for tiles vs entities
---@return { [string]: { [string]: string} } prototype_filters_by_location
function BlueprintConverter.get_locations_filters(invert)
  local filters = {
    space = {filter="collision-mask", mask={layers={[storage.named_collision_masks.space_collision_layer] = true}}, mask_mode="contains-any", invert=true},
    ground = {filter="collision-mask", mask={layers={[storage.named_collision_masks.space_collision_layer] = true}}, mask_mode="contains-any", invert=false}
  }
  if invert then
    for _, v in pairs(filters) do
      v.invert = not v.invert
    end
  end
  return filters
end

--Finds a target prototype name in a list of prototypes. Returns the suggested if valid, else returns the first one to appear in the crafting menu
---@param suggested_target? string Name of suggested target
---@param prototype_targets (LuaEntityPrototype|LuaTilePrototype)[] List of prototypes as potential targets
---@param item_per_entity table<string, string> mapping of entity name -> item name
---@return string target Selected target prototype
function BlueprintConverter.find_target(suggested_target, prototype_targets, item_per_entity)
  --check if the suggested is valid
  if suggested_target and prototype_targets[suggested_target] then
    return suggested_target
  else
    --if no target, sort the associated item list (NOT the entity list) and grab the first one
    local sort_list = {}
    local prototype_to_item = {}
    for entity_name, _ in pairs(prototype_targets) do
      if item_per_entity[entity_name] then
        prototype_to_item[entity_name] = prototypes.item[item_per_entity[entity_name]]
        table.insert(sort_list, entity_name)
      end
    end
    table.sort(sort_list, function(e1, e2)
      return prototype_to_item[e1].subgroup.order == prototype_to_item[e2].subgroup.order
        and prototype_to_item[e1].order < prototype_to_item[e2].order
        or prototype_to_item[e1].subgroup.order < prototype_to_item[e2].subgroup.order
    end)
    return sort_list[1]
  end
end

--creates cache of tile->tile conversions
function BlueprintConverter.create_converter_list_tiles()
  BlueprintConverter.converter_list_tiles = {}
  BlueprintConverter.converter_list_items = BlueprintConverter.converter_list_items or {}
  --get prototypes
  local tiles_per_location = {}
  local item_per_tile = {}
  local tile_data = {}
  for location_name, filter in pairs(BlueprintConverter.get_locations_filters(true)) do
    tiles_per_location[location_name] = prototypes.get_tile_filtered({
      filter,
      {filter="blueprintable", mode="and"}
    })
    item_per_tile[location_name] = BlueprintConverter.get_item_names(tiles_per_location[location_name])
    --find a valid target
    tile_data[location_name] = BlueprintConverter.find_target(BlueprintConverter.tile_targets[location_name], tiles_per_location[location_name], item_per_tile[location_name])
  end

  --set conversion targets
  for from_location, to_location in pairs({ground = "space", space = "ground"}) do
    for convert_from_name, item_name in pairs(item_per_tile[from_location]) do
      BlueprintConverter.converter_list_tiles[convert_from_name] = tile_data[to_location]
      BlueprintConverter.converter_list_items[item_name] = item_per_tile[to_location][tile_data[to_location]]
    end
  end
end

--creates cache of entity->entity conversions
function BlueprintConverter.create_converter_list_entities()
  BlueprintConverter.converter_list_entities = {}
  BlueprintConverter.converter_list_items = BlueprintConverter.converter_list_items or {}
  --for rails, we want to have them tied to a rail-planner, so get a list of valid names through that first
  local name_filters = {}
  local rail_planners = prototypes.get_item_filtered({
    {filter="type", type="rail-planner"}
  })
  for _, rail_type_name in pairs({
    "curved-rail-a",
    "curved-rail-b",
    "straight-rail",
    "half-diagonal-rail",
    "legacy-straight-rail",
    "legacy-curved-rail"
  }) do
    name_filters[rail_type_name] = {}
    for _, rail_planner in pairs(rail_planners) do
      for _, rail_planner_rail in pairs(rail_planner.rails) do
        if rail_type_name == rail_planner_rail.type then
          table.insert(name_filters[rail_type_name], rail_planner_rail.name)
        end
      end
    end
  end

  -- Special Case to handle Legacy Rails in existing games / blueprints. Suggested removal during 0.8 development.
  table.insert(name_filters["legacy-straight-rail"], "legacy-straight-rail")
  table.insert(name_filters["legacy-straight-rail"], "se-space-legacy-straight-rail")
  table.insert(name_filters["legacy-curved-rail"], "legacy-curved-rail")
  table.insert(name_filters["legacy-curved-rail"], "se-space-legacy-curved-rail")


  --get prototypes
  for entity_type, suggested_entity_data in pairs(BlueprintConverter.suggested_entity_targets) do
    local entities_per_location = {}
    local item_per_entity = {}
    local entity_data_per_location_per_subgroup = {}
    local subgroup_per_entity = {}
    for location_name, filter in pairs(BlueprintConverter.get_locations_filters()) do
      entities_per_location[location_name] = {}
      for name, proto in pairs(prototypes.get_entity_filtered({
        filter,
        {filter="type", type=entity_type, mode="and"},
        {filter="hidden", invert=true, mode="and"},
        --if we have valid names, filter those as well
        name_filters[entity_type] and {filter="name", name=name_filters[entity_type], mode="and"} or nil
      })) do
        entities_per_location[location_name][name] = proto
      end
      -- Handle Legacy Rails as these are hidden.
      if entity_type == "legacy-straight-rail" or entity_type == "legacy-curved-rail"then
        for name, proto in pairs(prototypes.get_entity_filtered({
          filter,
          {filter="type", type=entity_type, mode="and"},
          --if we have valid names, filter those as well
          name_filters[entity_type] and {filter="name", name=name_filters[entity_type], mode="and"} or nil
        })) do
          game.print(serpent.block(entities_per_location[location_name]))
          game.print(serpent.block(proto))
          entities_per_location[location_name][name] = proto
        end
      end
      item_per_entity[location_name] = BlueprintConverter.get_item_names(entities_per_location[location_name])
      --find a valid target
      local entities_per_subgroup = {}
      for name, prototype in pairs(entities_per_location[location_name]) do
        local subgroup = prototype.subgroup.name
        subgroup_per_entity[name] = subgroup
        entities_per_subgroup[subgroup] = entities_per_subgroup[subgroup] or {}
        entities_per_subgroup[subgroup][name] = prototype
      end
      entity_data_per_location_per_subgroup[location_name] = {}
      for subgroup, entities in pairs(entities_per_subgroup) do
        entity_data_per_location_per_subgroup[location_name][subgroup] = BlueprintConverter.find_target(suggested_entity_data[subgroup] and suggested_entity_data[subgroup][location_name], entities, item_per_entity[location_name])
      end
    end

    --set conversion targets
    for from_location, to_location in pairs({ground = "space", space = "ground"}) do
      for convert_from_name, item_name in pairs(item_per_entity[from_location]) do
        --check for matching subgroup
        local convert_from_subgroup = subgroup_per_entity[convert_from_name]
        local convert_to_name = entity_data_per_location_per_subgroup[to_location][convert_from_subgroup]
        if not convert_to_name then
          --check for another item with matching fast_replaceable_group
          local convert_from_entity = entities_per_location[from_location][convert_from_name]
          local fast_replaceable_group = convert_from_entity.fast_replaceable_group
          for subgroup, entity_name in pairs(entity_data_per_location_per_subgroup[from_location]) do
            if subgroup ~= convert_from_subgroup
              and fast_replaceable_group == entities_per_location[from_location][entity_name].fast_replaceable_group
            then
              convert_to_name = entity_data_per_location_per_subgroup[to_location][subgroup]
              break
            end
          end
        end
        if convert_to_name then
          --verify validity of entity conversion
          local convert_to_entity = entities_per_location[to_location][convert_to_name]
          local convert_from_entity = entities_per_location[from_location][convert_from_name]
          if convert_from_entity.group.name == convert_to_entity.group.name
            and convert_from_entity.tile_width == convert_to_entity.tile_width
            and convert_from_entity.tile_height == convert_to_entity.tile_height
          then
            BlueprintConverter.converter_list_entities[convert_from_name] = convert_to_name
            BlueprintConverter.converter_list_items[item_name] = item_per_entity[to_location][convert_to_name]
          end
        end
      end
    end
  end

  --add hard coded conversions
  local active_mods = script.active_mods
  for mod_list, entity_targets in pairs(BlueprintConverter.modded_entity_targets) do
    local mods_enabled = true
    for _, mod in pairs(mod_list) do
      if not active_mods[mod] then
        mods_enabled = false
        break
      end
    end
    if mods_enabled then
      for convert_from, convert_to in pairs(entity_targets) do
        local items = BlueprintConverter.get_item_names({[convert_from] = prototypes.entity[convert_from], [convert_to] = prototypes.entity[convert_to]})
        if items[convert_from] and items[convert_to] then
          BlueprintConverter.converter_list_entities[convert_from] = convert_to
          BlueprintConverter.converter_list_items[items[convert_from]] = items[convert_to]
        end
      end
    end
  end
end

---Returns a mapping of prototype name -> item name
---@param placeable_prototypes (LuaEntityPrototype|LuaTilePrototype)[] prototypes to find .items_to_place_this
---@return table<string, string> item_per item name per prototype name
function BlueprintConverter.get_item_names(placeable_prototypes)
  local item_per = {}
  for name, prototype in pairs(placeable_prototypes) do
    local items = prototype.items_to_place_this
    if items then
      local item = type(items[1]) == "string" and items[1] or items[1].name
      item_per[name] = item
    end
  end
  return item_per
end

--replace the icons on the blueprint item or book
---@param blueprint_item LuaItemStack
function BlueprintConverter.convert_icons(blueprint_item)
  local icons = blueprint_item.preview_icons
  if not icons then return end
  local changed = false
  for _, icon in pairs(icons) do
    if (icon.signal.type or "item") == "item" and icon.signal.name and BlueprintConverter.converter_list_items[icon.signal.name] then
      changed = true
      icon.signal.name = BlueprintConverter.converter_list_items[icon.signal.name]
    end
  end
  if changed then
    blueprint_item.preview_icons = icons
  end
end

--iterate conversion lists and replace anything listed
---@param item LuaItemStack Blueprint item to convert
---@return boolean converted whether or not a conversion happened
function BlueprintConverter.convert_blueprint(item)
  if not BlueprintConverter.converter_list_entities then BlueprintConverter.create_converter_list_entities() end
  if not BlueprintConverter.converter_list_tiles then BlueprintConverter.create_converter_list_tiles() end
  local converted = false
  local snap_to = item.blueprint_snap_to_grid
  local snap_position = item.blueprint_position_relative_to_grid
  local snap_absolulte = item.blueprint_absolute_snapping
  local entities = item.get_blueprint_entities()
  if entities then
    for _, entity in pairs(entities) do
      if BlueprintConverter.converter_list_entities[entity.name] then
        entity.name = BlueprintConverter.converter_list_entities[entity.name]
        converted = true
      end
    end
    item.set_blueprint_entities(entities)
  end
  local tiles = item.get_blueprint_tiles()
  if tiles then
    for _, tile in pairs(tiles) do
      if BlueprintConverter.converter_list_tiles[tile.name] then
        tile.name = BlueprintConverter.converter_list_tiles[tile.name]
        converted = true
      end
    end
    item.set_blueprint_tiles(tiles)
  end
  item.blueprint_absolute_snapping = snap_absolulte
  item.blueprint_position_relative_to_grid = snap_position
  item.blueprint_snap_to_grid = snap_to
  BlueprintConverter.convert_icons(item)
  return converted
end

--Recursive search through blueprint book, converting everything
---@param blueprint_book LuaItemStack Blueprint book to converter
---@return boolean converted whether or not a conversion happened
function BlueprintConverter.convert_blueprint_book(blueprint_book)
  local blueprints = blueprint_book.get_inventory(defines.inventory.item_main)
  ---@cast blueprints -? --books always have an inventory
  local converted = false
  for i = 1, #blueprints do
    local blueprint = blueprints[i]
    if blueprint.valid_for_read then
      if blueprint.is_blueprint then
        converted = BlueprintConverter.convert_blueprint(blueprint) or converted
      elseif blueprint.is_blueprint_book then
        converted = BlueprintConverter.convert_blueprint_book(blueprint) or converted
      end
    end
  end
  BlueprintConverter.convert_icons(blueprint_book)
  return converted
end

--find a blueprint to convert
---@param event EventData.on_lua_shortcut|EventData.CustomInputEvent Event data
function BlueprintConverter.on_lua_shortcut(event)
  if event.input_name == mod_prefix..'blueprint-converter' or event.prototype_name == BlueprintConverter.name_shortcut then
    local player = game.get_player(event.player_index)
    ---@cast player -?
    local item = player.blueprint_to_setup
    local converted
    if item.valid_for_read then
      --from swipe selection
      converted = BlueprintConverter.convert_blueprint(item)
    else
      local item = player.cursor_stack
      if item and item.valid_for_read then
        --from cursor
        if item.is_blueprint and item.is_blueprint_setup() then
          converted = BlueprintConverter.convert_blueprint(item)
        elseif item.is_blueprint_book then
          converted = BlueprintConverter.convert_blueprint_book(item)
        end
      end
    end
    local msg
    if converted == true then
      msg = {"space-exploration.blueprint-converter-success"}
    elseif converted == false then
      msg = {"space-exploration.blueprint-converter-nothing-converted"}
    else
      --if something had attempted conversion, `converted` would not be nil
      if player.is_cursor_blueprint() then
        --cursor has a blueprint but it wasn't detected as an item, must be from library
        msg = {"space-exploration.blueprint-converter-no-library"}
      else
        --nothing converted, display error message
        msg = {"space-exploration.blueprint-converter-error"}
      end
    end
    player.create_local_flying_text{text = msg, create_at_cursor = true}
  end
end
Event.addListener(defines.events.on_lua_shortcut, BlueprintConverter.on_lua_shortcut)
Event.addListener(mod_prefix..'blueprint-converter', BlueprintConverter.on_lua_shortcut)

return BlueprintConverter
