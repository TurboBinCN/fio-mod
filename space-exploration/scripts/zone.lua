local Zone = {}

Zone.on_zone_surface_created_event = util.get_custom_event("on_zone_surface_created")

-- constants
Zone.solar_multiplier = 1

Zone.discovery_scan_radius = 32
Zone.clear_enemies_radius = 512

Zone.travel_cost_interstellar = 400 -- stellar position distance, roughly 50 distance between stars, can be up to 300 apart
Zone.travel_cost_star_gravity = 500 -- roughly 10-20 base for a star
Zone.travel_cost_planet_gravity = 100 -- roughly 10-20 base for a planet
Zone.travel_cost_space_distortion = Zone.travel_cost_interstellar * 25 -- based on 0-1 range

Zone.name_tech_discover_random = mod_prefix.."zone-discovery-random"
Zone.name_tech_discover_targeted = mod_prefix.."zone-discovery-targeted"
Zone.name_tech_discover_deep = mod_prefix.."zone-discovery-deep"

Zone.name_setting_dropdowns_hide_low_priority = mod_prefix.."dropdowns-hide-low-priority-zones"
Zone.name_setting_dropdowns_priority_threshold = mod_prefix.."dropdowns-priority-threshold"

---Table of color codes, indexed by full zone type
---@type table<string, Color>
Zone.color_codes = {
  ["anomaly"] = {183, 125, 255},
  ["asteroid-field"] = {138, 161, 255},
  ["asteroid-belt"] = {152, 212, 254},
  ["star"] = {255, 168, 80},
  ["star-orbit"] = {255, 168, 80},
  ["planet"] = {92, 255, 102},
  ["planet-orbit"] = {143, 255, 153},
  ["moon"] = {249, 255, 130},
  ["moon-orbit"] = {249, 255, 181},
  ["spaceship"] = {110, 209, 214}
}

---Table of hex color codes, indexed by full zone type, for use in strings
---@type table<string, string>
Zone.color_codes_hex = {
  ["anomaly"] = "#B77DFF",
  ["asteroid-field"] = "#8AA1FF",
  ["asteroid-belt"] = "#98D4FE",
  ["star"] = "#FFA850",
  ["star-orbit"] = "#FFA850",
  ["planet"] = "#5CFF66",
  ["planet-orbit"] = "#8FFF99",
  ["moon"] = "#F9FF82",
  ["moon-orbit"] = "#F9FFB5",
  ["spaceship"] = "#6ED1D6"
}

-- based on alien biomes, unsure as to how to make this more dynamic
-- biome name = {tilenames}
Zone.biome_tiles = {
  ["out-of-map"] = {"out-of-map"}, -- always allowed
  ["water"] = {"water", "deepwater", "water-green", "deepwater-green", "water-shallow", "water-mud"},

  ["dirt-purple"] = {"mineral-purple-dirt-1", "mineral-purple-dirt-2", "mineral-purple-dirt-3", "mineral-purple-dirt-4", "mineral-purple-dirt-5", "mineral-purple-dirt-6"},
  ["dirt-violet"] = {"mineral-violet-dirt-1", "mineral-violet-dirt-2", "mineral-violet-dirt-3", "mineral-violet-dirt-4", "mineral-violet-dirt-5", "mineral-violet-dirt-6"},
  ["dirt-red"] = {"mineral-red-dirt-1", "mineral-red-dirt-2", "mineral-red-dirt-3", "mineral-red-dirt-4", "mineral-red-dirt-5", "mineral-red-dirt-6"},
  ["dirt-brown"] = {"mineral-brown-dirt-1", "mineral-brown-dirt-2", "mineral-brown-dirt-3", "mineral-brown-dirt-4", "mineral-brown-dirt-5", "mineral-brown-dirt-6"},
  ["dirt-tan"] = {"mineral-tan-dirt-1", "mineral-tan-dirt-2", "mineral-tan-dirt-3", "mineral-tan-dirt-4", "mineral-tan-dirt-5", "mineral-tan-dirt-6"},
  ["dirt-aubergine"] = {"mineral-aubergine-dirt-1", "mineral-aubergine-dirt-2", "mineral-aubergine-dirt-3", "mineral-aubergine-dirt-4", "mineral-aubergine-dirt-5", "mineral-aubergine-dirt-6"},
  ["dirt-dustyrose"] = {"mineral-dustyrose-dirt-1", "mineral-dustyrose-dirt-2", "mineral-dustyrose-dirt-3", "mineral-dustyrose-dirt-4", "mineral-dustyrose-dirt-5", "mineral-dustyrose-dirt-6"},
  ["dirt-beige"] = {"mineral-beige-dirt-1", "mineral-beige-dirt-2", "mineral-beige-dirt-3", "mineral-beige-dirt-4", "mineral-beige-dirt-5", "mineral-beige-dirt-6"},
  ["dirt-cream"] = {"mineral-cream-dirt-1", "mineral-cream-dirt-2", "mineral-cream-dirt-3", "mineral-cream-dirt-4", "mineral-cream-dirt-5", "mineral-cream-dirt-6"},
  ["dirt-black"] = {"mineral-black-dirt-1", "mineral-black-dirt-2", "mineral-black-dirt-3", "mineral-black-dirt-4", "mineral-black-dirt-5", "mineral-black-dirt-6"},
  ["dirt-grey"] = {"mineral-grey-dirt-1", "mineral-grey-dirt-2", "mineral-grey-dirt-3", "mineral-grey-dirt-4", "mineral-grey-dirt-5", "mineral-grey-dirt-6"},
  ["dirt-white"] = {"mineral-white-dirt-1", "mineral-white-dirt-2", "mineral-white-dirt-3", "mineral-white-dirt-4", "mineral-white-dirt-5", "mineral-white-dirt-6"},

  ["sand-purple"] = {"mineral-purple-sand-1", "mineral-purple-sand-2", "mineral-purple-sand-3"},
  ["sand-violet"] = {"mineral-violet-sand-1", "mineral-violet-sand-2", "mineral-violet-sand-3"},
  ["sand-red"] = {"mineral-red-sand-1", "mineral-red-sand-2", "mineral-red-sand-3"},
  ["sand-brown"] = {"mineral-brown-sand-1", "mineral-brown-sand-2", "mineral-brown-sand-3"},
  ["sand-tan"] = {"mineral-tan-sand-1", "mineral-tan-sand-2", "mineral-tan-sand-3"},
  ["sand-aubergine"] = {"mineral-aubergine-sand-1", "mineral-aubergine-sand-2", "mineral-aubergine-sand-3"},
  ["sand-dustyrose"] = {"mineral-dustyrose-sand-1", "mineral-dustyrose-sand-2", "mineral-dustyrose-sand-3"},
  ["sand-beige"] = {"mineral-beige-sand-1", "mineral-beige-sand-2", "mineral-beige-sand-3"},
  ["sand-cream"] = {"mineral-cream-sand-1", "mineral-cream-sand-2", "mineral-cream-sand-3"},
  ["sand-black"] = {"mineral-black-sand-1", "mineral-black-sand-2", "mineral-black-sand-3"},
  ["sand-grey"] = {"mineral-grey-sand-1", "mineral-grey-sand-2", "mineral-grey-sand-3"},
  ["sand-white"] = {"mineral-white-sand-1", "mineral-white-sand-2", "mineral-white-sand-3"},

  ["vegetation-green"] = {"vegetation-green-grass-1", "vegetation-green-grass-2", "vegetation-green-grass-3", "vegetation-green-grass-4"},
  ["vegetation-olive"] = {"vegetation-olive-grass-1", "vegetation-olive-grass-2"},
  ["vegetation-yellow"] = {"vegetation-yellow-grass-1", "vegetation-yellow-grass-2"},
  ["vegetation-orange"] = {"vegetation-orange-grass-1", "vegetation-orange-grass-2"},
  ["vegetation-red"] = {"vegetation-red-grass-1", "vegetation-red-grass-2"},
  ["vegetation-violet"] = {"vegetation-violet-grass-1", "vegetation-violet-grass-2"},
  ["vegetation-purple"] = {"vegetation-purple-grass-1", "vegetation-purple-grass-2"},
  ["vegetation-mauve"] = {"vegetation-mauve-grass-1", "vegetation-mauve-grass-2"},
  ["vegetation-blue"] = {"vegetation-blue-grass-1", "vegetation-blue-grass-2"},
  ["vegetation-turquoise"] = {"vegetation-turquoise-grass-1", "vegetation-turquoise-grass-2"},

  ["volcanic-orange"] = {"volcanic-orange-heat-1", "volcanic-orange-heat-2", "volcanic-orange-heat-3", "volcanic-orange-heat-4"},
  ["volcanic-green"] = {"volcanic-green-heat-1", "volcanic-green-heat-2", "volcanic-green-heat-3", "volcanic-green-heat-4"},
  ["volcanic-blue"] = {"volcanic-blue-heat-1", "volcanic-blue-heat-2", "volcanic-blue-heat-3", "volcanic-blue-heat-4"},
  ["volcanic-purple"] = {"volcanic-purple-heat-1", "volcanic-purple-heat-2", "volcanic-purple-heat-3", "volcanic-purple-heat-4"},

  ["frozen-snow"] = {"frozen-snow-0", "frozen-snow-1", "frozen-snow-2", "frozen-snow-3", "frozen-snow-4"},
  ["frozen-ice"] = {"frozen-snow-5", "frozen-snow-6", "frozen-snow-7", "frozen-snow-8", "frozen-snow-9"},
}
Zone.biome_collections = {
  ["all-sand"] = {"sand-purple", "sand-violet", "sand-red", "sand-brown", "sand-tan", "sand-aubergine", "sand-dustyrose", "sand-beige", "sand-cream", "sand-black", "sand-grey", "sand-white"},
  ["all-dirt"] = {"dirt-purple", "dirt-violet", "dirt-red", "dirt-brown", "dirt-tan", "dirt-aubergine", "dirt-dustyrose", "dirt-beige", "dirt-cream", "dirt-black", "dirt-grey", "dirt-white"},
  ["all-vegetation"] = {"vegetation-green", "vegetation-olive", "vegetation-yellow", "vegetation-orange", "vegetation-red",
                        "vegetation-violet", "vegetation-purple", "vegetation-mauve", "vegetation-blue", "vegetation-turquoise" },
  ["all-volcanic"] = {"volcanic-orange", "volcanic-green", "volcanic-blue", "volcanic-purple"},
  ["all-frozen"] = {"frozen-snow", "frozen-ice"},
}
Zone.signal_to_zone_type = {
  [mod_prefix.."planet"] = "planet",
  [mod_prefix.."moon"] = "moon",
  [mod_prefix.."planet-orbit"] = "orbit",
  [mod_prefix.."moon-orbit"] = "orbit",
  [mod_prefix.."star"] = "orbit",
  [mod_prefix.."asteroid-belt"] = "asteroid-belt",
  [mod_prefix.."asteroid-field"] = "asteroid-field",
  [mod_prefix.."anomaly"] = "anomaly",
}
Zone.controls_without_frequency_multiplier = {
  "trees",
  "enemy-base"
}
-- NOTE: cliff and base terrain sliders have special settings,

--[[ eg:
biome_replacements = {
  {replace = {"all-dirt", "all-sand", "all-volcanic"}, with="sand-red"},
  {replace = {"all-vegetation", "all-frozen"}, with="vegetation-red"}
} ]]--

---Gets the "Nauvis" zone
---@return PlanetType zone
function Zone.get_default()
  return Zone.from_name("Nauvis") --[[@as PlanetType]]
end

---Gets the homezone of a given force, given the force's name.
---@param force_name string Name of force
---@return PlanetType? homeworld
function Zone.get_force_home_zone(force_name)
  if storage.forces[force_name] and storage.forces[force_name].homeworld_index then
    return Zone.from_zone_index(storage.forces[force_name].homeworld_index)
  end
end

---Gets a LocalisedString reflecting the type of zone or spaceship given.
---@param zone AnyZoneType|StarType|SpaceshipType Zone or spaceship
---@return LocalisedString
function Zone.type_title(zone)
  if zone.type == "planet" then
    return {"space-exploration.planet"}
  elseif zone.type == "moon" then
    return {"space-exploration.moon"}
  elseif zone.type == "star" then
    return {"space-exploration.star"}
  elseif zone.type == "asteroid-field" then
    return {"space-exploration.asteroid-field"}
  elseif zone.type == "asteroid-belt" then
    return {"space-exploration.asteroid-belt"}
  elseif zone.type == "anomaly" then
    return {"space-exploration.anomaly"}
  elseif zone.type == "spaceship" then
    return {"space-exploration.spaceship"}
  elseif zone.type == "orbit" then
    return {"space-exploration.something_orbit", Zone.type_title(zone.parent)}
  end
end

---Gets the virtual signal name of a given zone or spaceship based on its type.
---@param zone AnyZoneType|StarType|SpaceshipType Zone or spaceship
---@return string signal_name
function Zone.get_signal_name(zone)
  -- used for rich text
  if zone.type == "orbit" and zone.parent.type == "star" then
    ---@cast zone OrbitType
    return mod_prefix.."star"
  elseif zone.type == "orbit" and zone.parent.type == "planet" then
    ---@cast zone OrbitType
    return mod_prefix.."planet-orbit"
  elseif zone.type == "orbit" and zone.parent.type == "moon" then
    ---@cast zone OrbitType
    return mod_prefix.."moon-orbit"
  else
    return mod_prefix..zone.type
  end
end

---Returns "virtual-signal/" concatenated with a zone/spaceship's virtual signal name
---@param zone AnyZoneType|StarType|SpaceshipType Zone or spaceship whose icon to get
---@return string icon_string
function Zone.get_icon(zone)
  -- used for rich text
  return "virtual-signal/" .. Zone.get_signal_name(zone)
end

---Returns a ready to use rich text tag for the zone icon
---@param zone AnyZoneType|StarType|SpaceshipType Zone or spaceship whose icon to get
---@return string rich_text
function Zone.get_rich_text_icon(zone)
  return "[img=" .. Zone.get_icon(zone) .. "]"
end

---Returns the color corresponding to the zone's type.
---@param zone AnyZoneType|StarType|SpaceshipType Zone or spaceship
---@return Color
function Zone.get_print_color(zone)
  return Zone.color_codes[Zone.get_full_type(zone)]
end

---Returns a color-coded string of the zone's icon and name.
---@param zone AnyZoneType|StarType|SpaceshipType Zone or spaceship
---@param no_icon? boolean Pass true to _not_ get an icon
---@param no_color? boolean Pass true to _not_ get colored output
function Zone.get_print_name(zone, no_icon, no_color)
  local zone_type = Zone.get_full_type(zone)
  local suffix = (zone_type == "spaceship") and
    string.format(" [font=default-small][%d][/font]", zone.index) or ""
  local name = no_color and (zone.name .. suffix) or
    "[color=" .. Zone.color_codes_hex[zone_type] .. "]".. zone.name .. suffix .. "[/color]"

  return (no_icon and "" or "[img=virtual-signal/" .. Zone.get_signal_name(zone) .. "] ") .. name
end

---Returns the full type of a given zone, allowing easier differentiation of different orbit types.
---@param zone AnyZoneType|StarType|SpaceshipType Zone whose type to get
---@return string type
function Zone.get_full_type(zone)
  local type

  if zone.type == "orbit" then
    ---@cast zone OrbitType
    if zone.parent.type == "star" then
      type = "star-orbit"
    elseif zone.parent.type == "planet" then
      type = "planet-orbit"
    elseif zone.parent.type == "moon" then
      type = "moon-orbit"
    end
  else
    type = zone.type
  end

  return type
end

---Returns true if a given zone is a planet or moon.
---if true, can ---@cast [zone] PlanetType|MoonType
---if false, can ---@cast [zone] -PlanetType, -MoonType
---@param zone AnyZoneType|StarType|SpaceshipType
---@return boolean is_solid
function Zone.is_solid(zone)
  return zone.type == "planet" or zone.type == "moon"
end

---Returns true if a given zone is _not_ a planet or moon. Returns true for spaceships.
---if true, can ---@cast [zone] -PlanetType, -MoonType
---if false, can ---@cast [zone] PlanetType|MoonType
---@param zone AnyZoneType|SpaceshipType|StarType Zone to evaluate
---@return boolean is_space
function Zone.is_space(zone)
  return not Zone.is_solid(zone)
end

---Returns a zone that can also defend against projectiles or energy beams in the current zone, if
---any.
---@param zone AnyZoneType|SpaceshipType Zone to evaluate
---@return AnyZoneType? Zone Zone that can also defend
function Zone.get_alternate_defence_zone(zone)
  if Zone.is_solid(zone) and zone.orbit then
    ---@cast zone PlanetType|MoonType
    return zone.orbit -- if the zone is a planet/moon, the orbit can also defend
  elseif zone.type == "orbit" and Zone.is_solid(zone.parent) then
    ---@cast zone OrbitType
    return zone.parent -- if the zone is an orbit, the planet/moon can also defend
  end
end

---Returns a zone with the given index number, if any.
---@param zone_index uint Zone index
---@return AnyZoneType|StarType? zone
function Zone.from_zone_index(zone_index)
  return storage.zone_index[zone_index]
end

---Returns a zone with the given name, if any
---@param name string Zone name
---@return AnyZoneType? zone
function Zone.from_name(name)
    return storage.zones_by_name[name]
end

---Returns a zone with the given name, if any
---@param name string Surface name
---@return AnyZoneType? zone
function Zone.from_surface_name(name)
  local surface = game.get_surface(name)
  if not surface then return end
  return storage.zones_by_surface[surface.index]
end

---Returns a zone associated with a given `surface_index`. Will _not_ find spaceships.
---@param surface_index uint Surface index
---@return AnyZoneType? zone
function Zone.from_surface_index(surface_index)
  return storage.zones_by_surface[surface_index]
end

---Returns a zone or spaceship associated with a given surface, if any.
---@param surface LuaSurface Surface whose zone to find
---@return AnyZoneType|SpaceshipType? zone
function Zone.from_surface(surface)
  local from_index = Zone.from_surface_index(surface.index)
  if from_index then return from_index end
  -- maybe a spaceship
  return Spaceship.from_own_surface_index(surface.index)
end

---Gets the effective stellar position of a given zone, recursively going through its parents if it
---does not have one.
---@param zone AnyZoneType|StarType|SpaceshipType Zone whose stellar position to find
---@return StellarPosition? stellar_position
function Zone.get_stellar_position(zone)
  if not zone then return nil end
  if zone.type == "anomaly" then return {x = 0, y = 0} end
  -- everything else should have a stellar position
  return zone.stellar_position or Zone.get_stellar_position(zone.parent)
end

---Are two zones in different stellar positions?
---@param zone_a AnyZoneType Zone for stellar position A
---@param zone_b AnyZoneType Zone for stellar position B
---@return boolean is_different
function Zone.is_interstellar(zone_a, zone_b)
  local stellar_position_a = Zone.get_stellar_position(zone_a)
  local stellar_position_b = Zone.get_stellar_position(zone_b)
  if not (stellar_position_a and stellar_position_b) then return true end
  return stellar_position_a.x ~= stellar_position_b.x or stellar_position_a.y ~= stellar_position_b.y
end

---Gets the stellar distance between two zones
---@param zone_a AnyZoneType Zone for stellar position A
---@param zone_b AnyZoneType Zone for stellar position B
---@return number? distance
function Zone.get_stellar_distance(zone_a, zone_b)
  local stellar_position_a = Zone.get_stellar_position(zone_a)
  local stellar_position_b = Zone.get_stellar_position(zone_b)
  if not (stellar_position_a and stellar_position_b) then return nil end
  return util.vectors_delta_length(stellar_position_a, stellar_position_b)
end

---@param zone AnyZoneType|StarType|SpaceshipType
---@return integer
function Zone.get_star_gravity_well(zone)
  if zone.type == "orbit" then
    ---@cast zone OrbitType
      return Zone.get_star_gravity_well(zone.parent)
  end
  return zone.star_gravity_well or 0
end

---@param zone AnyZoneType|SpaceshipType
---@return integer
function Zone.get_planet_gravity_well(zone)
  if zone.type == "orbit" then
    ---@cast zone OrbitType
    if zone.parent.type == "star" then
      return 0
    elseif zone.parent.type == "planet" then
      return Zone.get_planet_gravity_well(zone.parent) - 1
    else
      return Zone.get_planet_gravity_well(zone.parent) - 0.5
    end
  end
  return zone.planet_gravity_well or 0
end

---@param zone AnyZoneType|SpaceshipType
---@return number
function Zone.get_space_distortion(zone) -- anomaly
  if zone.space_distortion then
    return zone.space_distortion
  end
  return zone.type == "anomaly" and 1 or 0
end

---@param zone AnyZoneType
function Zone.apply_markers(zone)
  for force_name, force_data in pairs(storage.forces) do
    local force = game.forces[force_name]
    if force and force_data.zones_discovered[zone.index] then
      if not (force_data.zones_discovered[zone.index].marker and force_data.zones_discovered[zone.index].marker.valid) then
        local surface = Zone.get_surface(zone)
        if surface then
          force_data.zones_discovered[zone.index].marker = force.add_chart_tag(surface, {
            icon = {type = "virtual", name = Zone.get_signal_name(zone)},
            position = {0,0},
            text = zone.name
          })
        end
      end
    end
  end
end

--- unused
---@param controls table<string, AutoplaceControl>
function Zone.validate_controls_and_error(controls)
  if controls then
    for name, control in pairs(controls) do
      if type(name) ~= "string" then
        error(serpent.block(name))
      end
    end
  end
end

---@param controls table<string, AutoplaceControl>
function Zone.validate_controls(controls)
  if controls then
    for name, control in pairs(controls) do
      if type(name) ~= "string" then
        controls[name] = nil
      end
    end
  end
end

---@param zone AnyZoneType
---@param controls table<string, AutoplaceControl>
---@param mapgen MapGenSettings
function Zone.apply_controls_to_mapgen(zone, controls, mapgen)
  Zone.validate_controls(controls)
  local frequency_multiplier = Zone.get_frequency_multiplier(zone)
  for name, control in pairs(controls) do
    if type(name) == "string" then
      if name == "moisture" then
        mapgen.property_expression_names = mapgen.property_expression_names or {}
        if control.frequency then
          mapgen.property_expression_names["control-setting:moisture:frequency:multiplier"] = control.frequency
        end
        if control.bias then
          mapgen.property_expression_names["control-setting:moisture:bias"] = control.bias
        end
      elseif name == "aux" then
        mapgen.property_expression_names = mapgen.property_expression_names or {}
        if control.frequency then
          mapgen.property_expression_names["control-setting:aux:frequency:multiplier"] = control.frequency
        end
        if control.bias then
          mapgen.property_expression_names["control-setting:aux:bias"] = control.bias
        end
      elseif name == "water" then
        if control.frequency then
          mapgen.terrain_segmentation = control.frequency
        end
        if control.size then
          mapgen.water = control.size
        end
      elseif name == "cliff" then
        mapgen.cliff_settings = mapgen.cliff_settings or {
          name="cliff",
          cliff_elevation_0=10, -- default
          cliff_elevation_interval=400, -- when set from the GUI the value is 40 / frequency.
          richness=0, -- 0.17 to 6.
        }
        if control.frequency and control.frequency ~= 0 then
          mapgen.cliff_settings.cliff_elevation_interval = 40 / control.frequency
          mapgen.cliff_settings.cliff_elevation_0 = mapgen.cliff_settings.cliff_elevation_interval / 4
        end
        if control.richness then
          mapgen.cliff_settings.richness = control.richness
        end
      else
        if prototypes.autoplace_control[name] then
          mapgen.autoplace_controls[name] = table.deepcopy(control)
          if mapgen.autoplace_controls[name].frequency
            and (not zone.is_homeworld)
            and (not Util.table_contains(Zone.controls_without_frequency_multiplier, name)) then
            mapgen.autoplace_controls[name].frequency = mapgen.autoplace_controls[name].frequency * frequency_multiplier
          end
        else
          log("Zone.apply_controls_to_mapgen: Attempt to apply invalid control name to mapgen: "..name)
          controls[name] = nil
        end
      end
    end
  end
end

---@param zone AnyZoneType|StarType
function Zone.apply_controls_to_mapgen_if_existing_surface(zone)
  local surface = Zone.get_surface(zone)
  if surface then
    local mapgen = surface.map_gen_settings
    Zone.apply_controls_to_mapgen(zone, zone.controls, mapgen)
    surface.map_gen_settings = mapgen
  end
end

-- Apply zone flags to zone.controls
-- e.g. `zone.plague_used` and `zone.hostiles_exstinct
---@param zone AnyZoneType
function Zone.apply_flags_to_controls(zone)
  if zone.plague_used then
    Zone.apply_plague_to_controls(zone)
  end
  if zone.hostiles_extinct then
    zone.controls["enemy-base"] = {frequency = 1, size = 0, richness = 0}
    Zone.apply_controls_to_mapgen_if_existing_surface(zone)
  end
end

---@param zone AnyZoneType
function Zone.apply_plague_to_controls(zone)
  zone.controls["enemy-base"] = {frequency = 1, size = 0, richness = 0}
  zone.controls["trees"] = {frequency = 1, size = 0, richness = 0}
  if zone.controls["se-vitamelange"] then
    zone.controls["se-vitamelange"] = {frequency = 1, size = 0, richness = 0}
  end

  if zone.primary_resource == "se-vitamelange" then
    zone.primary_resource = "coal"
    zone.fragment_name = CoreMiner.resource_to_fragment_name(zone.primary_resource)
    CoreMiner.update_zone_fragment_resources(zone)
  end

  local surface = Zone.get_surface(zone)
  if not surface then return end
  local map_gen_settings = surface.map_gen_settings
  map_gen_settings.autoplace_controls["enemy-base"] = {frequency = 1, size = 0, richness = 0}
  map_gen_settings.autoplace_controls["trees"] = {frequency = 1, size = 0, richness = 0}
  if map_gen_settings.autoplace_controls["se-vitamelange"] then
    map_gen_settings.autoplace_controls["se-vitamelange"] = {frequency = 1, size = 0, richness = 0}
    Universe.remove_resource_from_zone_surface(zone, "se-vitamelange")
  end
  surface.map_gen_settings = map_gen_settings
end

---@param zone AnyZoneType
---@return number
function Zone.get_frequency_multiplier(zone)
  if zone.radius then
    return 5000 / zone.radius
  end
  return 1
end

---@param zone AnyZoneType
---@param map_gen_settings MapGenSettings table
function Zone.set_autoplace_settings_for_space(zone, map_gen_settings)
  -- Enforce autoplace_control minimums
  for control_name, control_settings in pairs(map_gen_settings.autoplace_controls) do
    if control_settings.richness and type(control_settings.richness) == "number" then
      control_settings.richness = math.max(0, control_settings.richness)
    end
    if control_settings.size and type(control_settings.size) == "number" then
      control_settings.size = math.max(0, control_settings.size)
    end
  end

  -- Define what is permisable to spawn
  map_gen_settings.autoplace_settings = {
    ["decorative"] = {
      treat_missing_as_default = false,
      settings = {
        ["se-crater3-huge"] = {},
        ["se-crater1-large-rare"] = {},
        ["se-crater1-large"] = {},
        ["se-crater2-medium"] = {},
        ["se-crater4-small"] = {},
        ["se-sand-decal-space"] = {},
        ["se-stone-decal-space"] = {},
        ["se-medium-rock-asteroid"] = {},
        ["se-rock-small-asteroid"] = {},
        ["se-rock-tiny-asteroid"] = {},
        ["se-sand-medium-rock-asteroid"] = {},
        ["se-sand-rock-small-asteroid"] = {}
      }
    },
    ["entity"] = {
      treat_missing_as_default = false,
      settings = {
        ["se-huge-rock-asteroid"] = {},
        ["se-big-rock-asteroid"] = {},
        ["se-sand-big-rock-asteroid"] = {},
        ["se-huge-rock-space"] = {},
        ["se-big-rock-space"] = {},
        -- resources included/excluded based on controls
        --[[["copper-ore"] = {},
        ["iron-ore"] = {},
        ["uranium-ore"] = {},
        ["stone"] = {},
        ["se-beryllium-ore"] = {},
        ["se-water-ice"] = {},
        ["se-methane-ice"] = {},
        ["se-naquium-ore"] = {},]]
      }
    },
    ["tile"] = {
      treat_missing_as_default = false,
      settings = {
        ["se-asteroid"] = {},
        ["se-space"] = {},
        ["out-of-map"] = {},
      }
    },
  }

  local resource_names ={"copper-ore", "iron-ore", "uranium-ore", "stone", "se-beryllium-ore", "se-water-ice", "se-methane-ice", "se-naquium-ore"}

  for _, resource_name in pairs(resource_names) do
    if map_gen_settings.autoplace_controls[resource_name] and map_gen_settings.autoplace_controls[resource_name].size > 0 then
      map_gen_settings.autoplace_settings.entity.settings[resource_name] = {}
    end
  end

end

---@param zone AnyZoneType
---@param map_gen_settings MapGenSettings table
function Zone.set_autoplace_settings_for_solid(zone, map_gen_settings)
  -- Enforce autoplace_control minimums
  for control_name, control_settings in pairs(map_gen_settings.autoplace_controls) do
    if control_settings.richness and type(control_settings.richness) == "number" then
      control_settings.richness = math.max(0, control_settings.richness)
    end
    if control_settings.size and type(control_settings.size) == "number" then
      control_settings.size = math.max(0, control_settings.size)
    end
  end

  -- Define what is permisable to spawn
  map_gen_settings.autoplace_settings = {
    ["decorative"] = {
      treat_missing_as_default = false,
      settings = {
        ["asterisk-blue"] = {},
        ["asterisk-green"] = {},
        ["asterisk-mauve"] = {},
        ["asterisk-mini-blue"] = {},
        ["asterisk-mini-green"] = {},
        ["asterisk-mini-mauve"] = {},
        ["asterisk-mini-olive"] = {},
        ["asterisk-mini-orange"] = {},
        ["asterisk-mini-purple"] = {},
        ["asterisk-mini-red"] = {},
        ["asterisk-mini-turquoise"] = {},
        ["asterisk-mini-violet"] = {},
        ["asterisk-mini-yellow"] = {},
        ["asterisk-olive"] = {},
        ["asterisk-orange"] = {},
        ["asterisk-purple"] = {},
        ["asterisk-red"] = {},
        ["asterisk-turquoise"] = {},
        ["asterisk-violet"] = {},
        ["asterisk-yellow"] = {},
        ["brown-asterisk"] = {},
        ["brown-asterisk-mini"] = {},
        ["brown-carpet-grass"] = {},
        ["brown-fluff"] = {},
        ["brown-fluff-dry"] = {},
        ["brown-hairy-grass"] = {},
        ["bush-mini-blue"] = {},
        ["bush-mini-green"] = {},
        ["bush-mini-mauve"] = {},
        ["bush-mini-olive"] = {},
        ["bush-mini-orange"] = {},
        ["bush-mini-purple"] = {},
        ["bush-mini-red"] = {},
        ["bush-mini-turquoise"] = {},
        ["bush-mini-violet"] = {},
        ["bush-mini-yellow"] = {},
        ["cane-cluster"] = {},
        ["cane-single"] = {},
        ["carpet-grass-blue"] = {},
        ["carpet-grass-green"] = {},
        ["carpet-grass-mauve"] = {},
        ["carpet-grass-olive"] = {},
        ["carpet-grass-orange"] = {},
        ["carpet-grass-purple"] = {},
        ["carpet-grass-red"] = {},
        ["carpet-grass-turquoise"] = {},
        ["carpet-grass-violet"] = {},
        ["carpet-grass-yellow"] = {},
        ["cracked-mud-decal"] = {},
        ["crater1-large"] = {},
        ["crater1-large-rare"] = {},
        ["crater2-medium"] = {},
        ["crater3-huge"] = {},
        ["crater4-small"] = {},
        ["croton-blue"] = {},
        ["croton-green"] = {},
        ["croton-mauve"] = {},
        ["croton-olive"] = {},
        ["croton-orange"] = {},
        ["croton-purple"] = {},
        ["croton-red"] = {},
        ["croton-turquoise"] = {},
        ["croton-violet"] = {},
        ["croton-yellow"] = {},
        ["dark-mud-decal"] = {},
        ["desert-bush-blue"] = {},
        ["desert-bush-green"] = {},
        ["desert-bush-mauve"] = {},
        ["desert-bush-olive"] = {},
        ["desert-bush-orange"] = {},
        ["desert-bush-purple"] = {},
        ["desert-bush-red"] = {},
        ["desert-bush-turquoise"] = {},
        ["desert-bush-violet"] = {},
        ["desert-bush-yellow"] = {},
        ["flower-bush-blue-pink"] = {},
        ["flower-bush-green-pink"] = {},
        ["flower-bush-green-yellow"] = {},
        ["flower-bush-red-blue"] = {},
        ["garballo"] = {},
        ["garballo-mini-dry"] = {},
        ["hairy-grass-blue"] = {},
        ["hairy-grass-green"] = {},
        ["hairy-grass-mauve"] = {},
        ["hairy-grass-olive"] = {},
        ["hairy-grass-orange"] = {},
        ["hairy-grass-purple"] = {},
        ["hairy-grass-red"] = {},
        ["hairy-grass-turquoise"] = {},
        ["hairy-grass-violet"] = {},
        ["hairy-grass-yellow"] = {},
        ["lava-decal-blue"] = {},
        ["lava-decal-green"] = {},
        ["lava-decal-orange"] = {},
        ["lava-decal-purple"] = {},
        ["medium-rock-aubergine"] = {},
        ["medium-rock-beige"] = {},
        ["medium-rock-black"] = {},
        ["medium-rock-brown"] = {},
        ["medium-rock-cream"] = {},
        ["medium-rock-dustyrose"] = {},
        ["medium-rock-grey"] = {},
        ["medium-rock-purple"] = {},
        ["medium-rock-red"] = {},
        ["medium-rock-tan"] = {},
        ["medium-rock-violet"] = {},
        ["medium-rock-volcanic"] = {},
        ["medium-rock-white"] = {},
        ["pita-blue"] = {},
        ["pita-green"] = {},
        ["pita-mauve"] = {},
        ["pita-mini-blue"] = {},
        ["pita-mini-green"] = {},
        ["pita-mini-mauve"] = {},
        ["pita-mini-olive"] = {},
        ["pita-mini-orange"] = {},
        ["pita-mini-purple"] = {},
        ["pita-mini-red"] = {},
        ["pita-mini-turquoise"] = {},
        ["pita-mini-violet"] = {},
        ["pita-mini-yellow"] = {},
        ["pita-olive"] = {},
        ["pita-orange"] = {},
        ["pita-purple"] = {},
        ["pita-red"] = {},
        ["pita-turquoise"] = {},
        ["pita-violet"] = {},
        ["pita-yellow"] = {},
        ["puddle-decal"] = {},
        ["red-asterisk"] = {},
        ["red-croton"] = {},
        ["red-desert-bush"] = {},
        ["red-pita"] = {},
        ["sand-decal-black"] = {},
        ["sand-decal-purple"] = {},
        ["sand-decal-red"] = {},
        ["sand-decal-tan"] = {},
        ["sand-decal-volcanic"] = {},
        ["sand-decal-white"] = {},
        ["sand-dune-decal-aubergine"] = {},
        ["sand-dune-decal-beige"] = {},
        ["sand-dune-decal-black"] = {},
        ["sand-dune-decal-brown"] = {},
        ["sand-dune-decal-cream"] = {},
        ["sand-dune-decal-dustyrose"] = {},
        ["sand-dune-decal-grey"] = {},
        ["sand-dune-decal-purple"] = {},
        ["sand-dune-decal-red"] = {},
        ["sand-dune-decal-tan"] = {},
        ["sand-dune-decal-violet"] = {},
        ["sand-dune-decal-white"] = {},
        ["sand-medium-rock-black"] = {},
        ["sand-medium-rock-purple"] = {},
        ["sand-medium-rock-red"] = {},
        ["sand-medium-rock-tan"] = {},
        ["sand-medium-rock-white"] = {},
        ["sand-small-rock-black"] = {},
        ["sand-small-rock-purple"] = {},
        ["sand-small-rock-red"] = {},
        ["sand-small-rock-tan"] = {},
        ["sand-small-rock-white"] = {},
        ["small-grass-blue"] = {},
        ["small-grass-green"] = {},
        ["small-grass-mauve"] = {},
        ["small-grass-olive"] = {},
        ["small-grass-orange"] = {},
        ["small-grass-purple"] = {},
        ["small-grass-red"] = {},
        ["small-grass-turquoise"] = {},
        ["small-grass-violet"] = {},
        ["small-grass-yellow"] = {},
        ["small-rock-aubergine"] = {},
        ["small-rock-beige"] = {},
        ["small-rock-black"] = {},
        ["small-rock-brown"] = {},
        ["small-rock-cream"] = {},
        ["small-rock-dustyrose"] = {},
        ["small-rock-grey"] = {},
        ["small-rock-purple"] = {},
        ["small-rock-red"] = {},
        ["small-rock-tan"] = {},
        ["small-rock-violet"] = {},
        ["small-rock-volcanic"] = {},
        ["small-rock-white"] = {},
        ["stone-decal-black"] = {},
        ["stone-decal-purple"] = {},
        ["stone-decal-red"] = {},
        ["stone-decal-tan"] = {},
        ["stone-decal-volcanic"] = {},
        ["stone-decal-white"] = {},
        ["tiny-rock-aubergine"] = {},
        ["tiny-rock-beige"] = {},
        ["tiny-rock-black"] = {},
        ["tiny-rock-brown"] = {},
        ["tiny-rock-cream"] = {},
        ["tiny-rock-dustyrose"] = {},
        ["tiny-rock-grey"] = {},
        ["tiny-rock-purple"] = {},
        ["tiny-rock-red"] = {},
        ["tiny-rock-tan"] = {},
        ["tiny-rock-violet"] = {},
        ["tiny-rock-volcanic"] = {},
        ["tiny-rock-white"] = {},
        ["wetland-decal"] = {},
        ["white-desert-bush"] = {}
      }
    },
    ["entity"] = {
      treat_missing_as_default = false,
      settings = {
        -- resources included/excluded based on controls
        --[[["coal"] = {},
        ["copper-ore"] = {},
        ["iron-ore"] = {},
        ["uranium-ore"] = {},
        ["stone"] = {},
        ["crude-oil"] = {},
        ["se-vulcanite"] = {},
        ["se-cryonite"] = {},
        ["se-holmium-ore"] = {},
        ["se-iridium-ore"] = {},
        ["se-beryllium-ore"] = {},
        ["se-vitamelange"] = {},]]

        ["big-rock-aubergine"] = {},
        ["big-rock-beige"] = {},
        ["big-rock-black"] = {},
        ["big-rock-brown"] = {},
        ["big-rock-cream"] = {},
        ["big-rock-dustyrose"] = {},
        ["big-rock-grey"] = {},
        ["big-rock-purple"] = {},
        ["big-rock-red"] = {},
        ["big-rock-tan"] = {},
        ["big-rock-violet"] = {},
        ["big-rock-volcanic"] = {},
        ["big-rock-white"] = {},
        ["huge-rock-aubergine"] = {},
        ["huge-rock-beige"] = {},
        ["huge-rock-black"] = {},
        ["huge-rock-brown"] = {},
        ["huge-rock-cream"] = {},
        ["huge-rock-dustyrose"] = {},
        ["huge-rock-grey"] = {},
        ["huge-rock-purple"] = {},
        ["huge-rock-red"] = {},
        ["huge-rock-tan"] = {},
        ["huge-rock-violet"] = {},
        ["huge-rock-volcanic"] = {},
        ["huge-rock-white"] = {},
        ["sand-big-rock-black"] = {},
        ["sand-big-rock-purple"] = {},
        ["sand-big-rock-red"] = {},
        ["sand-big-rock-tan"] = {},
        ["sand-big-rock-white"] = {},
        ["fish"] = {}, -- should be "has water" and "not plagued".
      }
    },
    ["tile"] = {
      treat_missing_as_default = false,
      settings = {
        ["out-of-map"] = {},
        ["frozen-snow-0"] = {},
        ["frozen-snow-1"] = {},
        ["frozen-snow-2"] = {},
        ["frozen-snow-3"] = {},
        ["frozen-snow-4"] = {},
        ["frozen-snow-5"] = {},
        ["frozen-snow-6"] = {},
        ["frozen-snow-7"] = {},
        ["frozen-snow-8"] = {},
        ["frozen-snow-9"] = {},
        ["mineral-aubergine-dirt-1"] = {},
        ["mineral-aubergine-dirt-2"] = {},
        ["mineral-aubergine-dirt-3"] = {},
        ["mineral-aubergine-dirt-4"] = {},
        ["mineral-aubergine-dirt-5"] = {},
        ["mineral-aubergine-dirt-6"] = {},
        ["mineral-aubergine-sand-1"] = {},
        ["mineral-aubergine-sand-2"] = {},
        ["mineral-aubergine-sand-3"] = {},
        ["mineral-beige-dirt-1"] = {},
        ["mineral-beige-dirt-2"] = {},
        ["mineral-beige-dirt-3"] = {},
        ["mineral-beige-dirt-4"] = {},
        ["mineral-beige-dirt-5"] = {},
        ["mineral-beige-dirt-6"] = {},
        ["mineral-beige-sand-1"] = {},
        ["mineral-beige-sand-2"] = {},
        ["mineral-beige-sand-3"] = {},
        ["mineral-black-dirt-1"] = {},
        ["mineral-black-dirt-2"] = {},
        ["mineral-black-dirt-3"] = {},
        ["mineral-black-dirt-4"] = {},
        ["mineral-black-dirt-5"] = {},
        ["mineral-black-dirt-6"] = {},
        ["mineral-black-sand-1"] = {},
        ["mineral-black-sand-2"] = {},
        ["mineral-black-sand-3"] = {},
        ["mineral-brown-dirt-1"] = {},
        ["mineral-brown-dirt-2"] = {},
        ["mineral-brown-dirt-3"] = {},
        ["mineral-brown-dirt-4"] = {},
        ["mineral-brown-dirt-5"] = {},
        ["mineral-brown-dirt-6"] = {},
        ["mineral-brown-sand-1"] = {},
        ["mineral-brown-sand-2"] = {},
        ["mineral-brown-sand-3"] = {},
        ["mineral-cream-dirt-1"] = {},
        ["mineral-cream-dirt-2"] = {},
        ["mineral-cream-dirt-3"] = {},
        ["mineral-cream-dirt-4"] = {},
        ["mineral-cream-dirt-5"] = {},
        ["mineral-cream-dirt-6"] = {},
        ["mineral-cream-sand-1"] = {},
        ["mineral-cream-sand-2"] = {},
        ["mineral-cream-sand-3"] = {},
        ["mineral-dustyrose-dirt-1"] = {},
        ["mineral-dustyrose-dirt-2"] = {},
        ["mineral-dustyrose-dirt-3"] = {},
        ["mineral-dustyrose-dirt-4"] = {},
        ["mineral-dustyrose-dirt-5"] = {},
        ["mineral-dustyrose-dirt-6"] = {},
        ["mineral-dustyrose-sand-1"] = {},
        ["mineral-dustyrose-sand-2"] = {},
        ["mineral-dustyrose-sand-3"] = {},
        ["mineral-grey-dirt-1"] = {},
        ["mineral-grey-dirt-2"] = {},
        ["mineral-grey-dirt-3"] = {},
        ["mineral-grey-dirt-4"] = {},
        ["mineral-grey-dirt-5"] = {},
        ["mineral-grey-dirt-6"] = {},
        ["mineral-grey-sand-1"] = {},
        ["mineral-grey-sand-2"] = {},
        ["mineral-grey-sand-3"] = {},
        ["mineral-purple-dirt-1"] = {},
        ["mineral-purple-dirt-2"] = {},
        ["mineral-purple-dirt-3"] = {},
        ["mineral-purple-dirt-4"] = {},
        ["mineral-purple-dirt-5"] = {},
        ["mineral-purple-dirt-6"] = {},
        ["mineral-purple-sand-1"] = {},
        ["mineral-purple-sand-2"] = {},
        ["mineral-purple-sand-3"] = {},
        ["mineral-red-dirt-1"] = {},
        ["mineral-red-dirt-2"] = {},
        ["mineral-red-dirt-3"] = {},
        ["mineral-red-dirt-4"] = {},
        ["mineral-red-dirt-5"] = {},
        ["mineral-red-dirt-6"] = {},
        ["mineral-red-sand-1"] = {},
        ["mineral-red-sand-2"] = {},
        ["mineral-red-sand-3"] = {},
        ["mineral-tan-dirt-1"] = {},
        ["mineral-tan-dirt-2"] = {},
        ["mineral-tan-dirt-3"] = {},
        ["mineral-tan-dirt-4"] = {},
        ["mineral-tan-dirt-5"] = {},
        ["mineral-tan-dirt-6"] = {},
        ["mineral-tan-sand-1"] = {},
        ["mineral-tan-sand-2"] = {},
        ["mineral-tan-sand-3"] = {},
        ["mineral-violet-dirt-1"] = {},
        ["mineral-violet-dirt-2"] = {},
        ["mineral-violet-dirt-3"] = {},
        ["mineral-violet-dirt-4"] = {},
        ["mineral-violet-dirt-5"] = {},
        ["mineral-violet-dirt-6"] = {},
        ["mineral-violet-sand-1"] = {},
        ["mineral-violet-sand-2"] = {},
        ["mineral-violet-sand-3"] = {},
        ["mineral-white-dirt-1"] = {},
        ["mineral-white-dirt-2"] = {},
        ["mineral-white-dirt-3"] = {},
        ["mineral-white-dirt-4"] = {},
        ["mineral-white-dirt-5"] = {},
        ["mineral-white-dirt-6"] = {},
        ["mineral-white-sand-1"] = {},
        ["mineral-white-sand-2"] = {},
        ["mineral-white-sand-3"] = {},
        ["vegetation-blue-grass-1"] = {},
        ["vegetation-blue-grass-2"] = {},
        ["vegetation-green-grass-1"] = {},
        ["vegetation-green-grass-2"] = {},
        ["vegetation-green-grass-3"] = {},
        ["vegetation-green-grass-4"] = {},
        ["vegetation-mauve-grass-1"] = {},
        ["vegetation-mauve-grass-2"] = {},
        ["vegetation-olive-grass-1"] = {},
        ["vegetation-olive-grass-2"] = {},
        ["vegetation-orange-grass-1"] = {},
        ["vegetation-orange-grass-2"] = {},
        ["vegetation-purple-grass-1"] = {},
        ["vegetation-purple-grass-2"] = {},
        ["vegetation-red-grass-1"] = {},
        ["vegetation-red-grass-2"] = {},
        ["vegetation-turquoise-grass-1"] = {},
        ["vegetation-turquoise-grass-2"] = {},
        ["vegetation-violet-grass-1"] = {},
        ["vegetation-violet-grass-2"] = {},
        ["vegetation-yellow-grass-1"] = {},
        ["vegetation-yellow-grass-2"] = {},
        ["volcanic-blue-heat-1"] = {},
        ["volcanic-blue-heat-2"] = {},
        ["volcanic-blue-heat-3"] = {},
        ["volcanic-blue-heat-4"] = {},
        ["volcanic-green-heat-1"] = {},
        ["volcanic-green-heat-2"] = {},
        ["volcanic-green-heat-3"] = {},
        ["volcanic-green-heat-4"] = {},
        ["volcanic-orange-heat-1"] = {},
        ["volcanic-orange-heat-2"] = {},
        ["volcanic-orange-heat-3"] = {},
        ["volcanic-orange-heat-4"] = {},
        ["volcanic-purple-heat-1"] = {},
        ["volcanic-purple-heat-2"] = {},
        ["volcanic-purple-heat-3"] = {},
        ["volcanic-purple-heat-4"] = {}
      }
    },
  }


  local resource_names = {"coal", "copper-ore", "iron-ore", "uranium-ore", "stone", "crude-oil",
  "se-vulcanite", "se-cryonite", "se-holmium-ore", "se-iridium-ore", "se-beryllium-ore", "se-vitamelange"}

  ---@TODO: Extract to raising a custom event to let mod compat script subscribers add their own resources here?
  if script.active_mods["Krastorio2"] then
    table.insert(resource_names, "kr-imersite")
    table.insert(resource_names, "kr-rare-metal-ore")
    table.insert(resource_names, "kr-mineral-water")
  end

  for _, resource_name in pairs(resource_names) do
    if map_gen_settings.autoplace_controls[resource_name] and map_gen_settings.autoplace_controls[resource_name].size > 0 then
      map_gen_settings.autoplace_settings.entity.settings[resource_name] = {}
    end
  end


  if Zone.get_threat(zone) > 0 then
    map_gen_settings.autoplace_settings.entity.settings["biter-spawner"] = {}
    map_gen_settings.autoplace_settings.entity.settings["spitter-spawner"] = {}
    map_gen_settings.autoplace_settings.entity.settings["small-worm-turret"] = {}
    map_gen_settings.autoplace_settings.entity.settings["medium-worm-turret"] = {}
    map_gen_settings.autoplace_settings.entity.settings["big-worm-turret"] = {}
    map_gen_settings.autoplace_settings.entity.settings["behemoth-worm-turret"] = {}
  end

  if not (zone.tags and util.table_contains(zone.tags, "water_none")) then
    map_gen_settings.autoplace_settings.tile.settings["deepwater"] = {}
    map_gen_settings.autoplace_settings.tile.settings["water"] = {}
    map_gen_settings.autoplace_settings.tile.settings["water-mud"] = {}
    map_gen_settings.autoplace_settings.tile.settings["water-shallow"] = {}
  end

  if not(zone.tags and util.table_contains(zone.tags, "trees_none")) then
    -- trees
    --[[
    ["tree-01"] = {},
    ["tree-02"] = {},
    ["tree-02-red"] = {},
    ["tree-03"] = {},
    ["tree-04"] = {},
    ["tree-05"] = {},
    ["tree-06"] = {},
    ["tree-06-brown"] = {},
    ["tree-07"] = {},
    ["tree-08"] = {},
    ["tree-08-brown"] = {},
    ["tree-08-red"] = {},
    ["tree-09"] = {},
    ["tree-09-brown"] = {},
    ["tree-09-red"] = {},
    ]]
    --[[ -- not sure if dead trees still have autoplace in AB
    map_gen_settings.autoplace_settings.entity.settings["dead-dry-hairy-tree"] = {}
    map_gen_settings.autoplace_settings.entity.settings["dead-grey-trunk"] = {}
    map_gen_settings.autoplace_settings.entity.settings["dead-tree-desert"] = {}
    map_gen_settings.autoplace_settings.entity.settings["dry-hairy-tree"] = {}
    map_gen_settings.autoplace_settings.entity.settings["dry-tree"] = {}
    ]]
    map_gen_settings.autoplace_settings.entity.settings["tree-desert-a"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-desert-b"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-desert-c"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-desert-d"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-desert-e"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-desert-f"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-desert-g"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-desert-h"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-desert-i"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-desert-j"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-desert-k"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-desert-l"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-desert-m"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-desert-n"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-dryland-a"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-dryland-b"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-dryland-c"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-dryland-d"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-dryland-e"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-dryland-f"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-dryland-g"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-dryland-h"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-dryland-i"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-dryland-j"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-dryland-k"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-dryland-l"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-dryland-m"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-dryland-n"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-dryland-o"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-grassland-a"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-grassland-b"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-grassland-c"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-grassland-d"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-grassland-e"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-grassland-f"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-grassland-g"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-grassland-h2"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-grassland-h3"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-grassland-h"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-grassland-i"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-grassland-j"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-grassland-k"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-grassland-l"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-grassland-m"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-grassland-n"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-grassland-o"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-grassland-p"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-grassland-q"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-palm-a"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-palm-b"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-snow-a"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-volcanic-a"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-wetland-a"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-wetland-b"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-wetland-c"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-wetland-d"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-wetland-e"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-wetland-f"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-wetland-g"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-wetland-h"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-wetland-i"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-wetland-j"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-wetland-k"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-wetland-l"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-wetland-m"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-wetland-n"] = {}
    map_gen_settings.autoplace_settings.entity.settings["tree-wetland-o"] = {}
  end

  if map_gen_settings.cliff_settings then
    map_gen_settings.cliff_settings.name = "cliff" -- or choose a more planet appropriate one
  end

end

---@param zone AnyZoneType
function Zone.create_surface(zone)

    if not zone.surface_index then

      Universe.inflate_climate_controls(zone) -- This also applies zone.tags to zone.controls
      Zone.apply_flags_to_controls(zone) -- Overwrite the changes from tags in inflate_climate_controls

      -- TODO planets should have customised controls

      local map_gen_settings = table.deepcopy(game.default_map_gen_settings)
      map_gen_settings.width = 0
      map_gen_settings.height = 0
      if not zone.seed then zone.seed = math.random(4294967295) end
      map_gen_settings.seed = zone.seed

      local autoplace_controls = map_gen_settings.autoplace_controls
      zone.controls = zone.controls or {}

      -- This is unused. Intentional?
      local frequency_multiplier = Zone.get_frequency_multiplier(zone) -- increase for small planets and moons

      -- For all possible controls set values so it can be regenreated consistently.
      for control_name, control_prototype in pairs(prototypes.autoplace_control) do
        if control_name ~= "planet-size" and prototypes.autoplace_control[control_name] then
          zone.controls[control_name] = zone.controls[control_name] or {}
          zone.controls[control_name].frequency = (zone.controls[control_name].frequency or (0.17 + math.random() * math.random() * 2))
          zone.controls[control_name].size = zone.controls[control_name].size or (0.1 + math.random() * 0.8)
          zone.controls[control_name].richness = zone.controls[control_name].richness or (0.1 + math.random() * 0.8)
        end
      end

      zone.controls.moisture = zone.controls.moisture or {}
      zone.controls.moisture.frequency = (zone.controls.moisture.frequency or (0.17 + math.random() * math.random() * 2))
      zone.controls.moisture.bias = zone.controls.moisture.bias or (math.random() - 0.5)

      zone.controls.aux = zone.controls.aux or {}
      zone.controls.aux.frequency = (zone.controls.aux.frequency or (0.17 + math.random() * math.random() * 2))
      zone.controls.aux.bias = zone.controls.aux.bias or (math.random() - 0.5)

      zone.controls.cliff = zone.controls.cliff or {}
      zone.controls.cliff.frequency = (zone.controls.cliff.frequency or (0.17 + math.random() * math.random() * 10)) --
      zone.controls.cliff.richness  = zone.controls.cliff.richness  or (math.random() * 1.25)

      Zone.apply_controls_to_mapgen(zone, zone.controls, map_gen_settings)

      autoplace_controls["planet-size"] = { frequency = 1, size = 1 } -- default
      -- planet_radius = 10000 / 6 * (6 + log(1/planet_frequency/6, 2))
      -- planet_frequency = 1 / 6 / 2 ^ (planet_radius * 6 / 10000 - 6)
      local planet_size_frequency = 1/6 -- 10000 radius planet
      if Zone.is_solid(zone) then
        ---@cast zone PlanetType|MoonType
        map_gen_settings.width = zone.radius*2+32
        map_gen_settings.height = zone.radius*2+32
        -- planet or moon
        --planet_size_frequency = 1 / (zone.radius / 10000)
        planet_size_frequency = 1 / 6 / 2 ^ (zone.radius * 6 / 10000 - 6)
        local penalty = -100000
        map_gen_settings.property_expression_names["decorative:se-crater3-huge:probability"] = penalty
        if not zone.is_homeworld then
          map_gen_settings.starting_area = 0.5
        end
      else
        ---@cast zone -PlanetType, -MoonType
        if zone.type == "orbit" then
          ---@cast zone OrbitType
          autoplace_controls["planet-size"].size = zone.parent.radius and (zone.parent.radius / 200) or 50
        elseif zone.type == "asteroid-belt" then
          ---@cast zone AsteroidBeltType
          autoplace_controls["planet-size"].size = 300
        elseif zone.type == "asteroid-field" then
          ---@cast zone AsteroidFieldType
          autoplace_controls["planet-size"].size = 10000
        end

        planet_size_frequency = 1/1000
        map_gen_settings.cliff_settings = {
          name="cliff", -- could be ""
          cliff_elevation_0=10, -- default
          cliff_elevation_interval=400, -- when set from the GUI the value is 40 / frequency.
          richness=0, -- 0.17 to 6.
        }
        zone.controls.cliff.frequency = 1
        zone.controls.cliff.size = 0
        zone.controls.cliff.richness = 0

        map_gen_settings.property_expression_names = {
          ---@diagnostic disable:assign-type-mismatch
          ["control-setting:moisture:frequency:multiplier"] = 10,
          ["control-setting:moisture:bias"] = -1,
          ["control-setting:aux:frequency:multiplier"] = 0,
          ["control-setting:aux:bias"] = 0,
          ---@diagnostic enable:assign-type-mismatch
        }
        map_gen_settings.starting_area = 0
      end
      autoplace_controls["planet-size"].frequency = planet_size_frequency

      if Zone.is_space(zone) then
        ---@cast zone -PlanetType, -MoonType
        -- Speed up terrain generation by excluding everything not specifically allowed to spawn
        --map_gen_settings.default_enable_all_autoplace_controls = false
        Zone.set_autoplace_settings_for_space(zone, map_gen_settings)
      else
        ---@cast zone PlanetType|MoonType
        Zone.set_autoplace_settings_for_solid(zone, map_gen_settings)
      end

      Log.debug_log("Creating surface " .. zone.name .. " with map_gen_settings: (see log)")
      Log.debug_log_without_print(util.table_to_string(map_gen_settings))

      local surface = game.get_surface(zone.name)
      if not surface then
        surface = game.create_surface(zone.name, map_gen_settings)
        surface.force_generate_chunk_requests()
        surface.localised_name = Zone.get_default_localised_name_for_surface(zone)

      else
        -- this happens if the mod was uninstalled and reinstalled. The surface will be invalid and unfaxable.
        -- game.delete_surface(zone.name) -- does not work in time to re make the surface
        surface.clear(false)

      end

      zone.surface_index = surface.index
      storage.zones_by_surface[surface.index] = zone

      -- Don't show clouds in space zones
      if Zone.is_space(zone) then surface.show_clouds = false end

      Zone.set_solar_and_daytime(zone)

      if zone.type == "planet" and not zone.is_homeworld then
        ---@cast zone PlanetType

        -- Vault planet
        if (not zone.ruins) and not zone.glyph then
          Ancient.assign_zone_next_glyph(zone)
        end
        Ancient.make_vault_exterior(zone) -- only makes the vault if glyph exists

        -- Interburbulator planet
        if (not zone.glyph) and (not zone.ruins) and not storage.interburbulator then
          Interburbulator.make_interburbulator(zone)
        end
        if zone.interburbulator then
          Interburbulator.build_platform()
        end

      end

      if zone.type == "asteroid-belt" and zone.parent.special_type == "homesystem" and zone.special_type == "beryllium" and not zone.ruins then
        ---@cast zone AsteroidBeltType
        -- make the asteroid belt ship ruin
        local ruin_name = "asteroid-belt-ship"
        local ruin_location = {name = ruin_name, position = {x=0,y=0}, zone_index = zone.index}
        zone.ruins = { [ruin_name] = ruin_location }
        Ruin.build({ruin_name = ruin_name, surface_index = surface.index, position = ruin_location.position})
      end

      if not zone.is_homeworld then
        -- Unique ruins
        Ruin.zone_assign_unique_ruins(zone)
        Ruin.zone_build_ruins(zone, surface)
      end

      if zone.type == "anomaly" then
        ---@cast zone AnomalyType
        Ancient.make_gate(Ancient.gate_default_position)
        Ruin.build({ruin_name = "galaxy-ship", surface_index = surface.index,  position = Ancient.galaxy_ship_default_position})
      end

      if Zone.is_solid(zone) then
        ---@cast zone PlanetType|MoonType
        CoreMiner.generate_core_seam_positions(zone)
        game.forces.enemy.set_evolution_factor(math.pow(Zone.get_threat(zone), 1/2), surface)
      end

      script.raise_event(Zone.on_zone_surface_created_event, {
        zone_index = zone.index,
        surface_index = surface.index,
      })
    end
end

---Gets the parent star of any planet, moon, orbit, or asteroid belt. Returns the star itself if
---given a star and nil for zones that don't have parent stars.
---@param zone AnyZoneType|StarType Zone to get parent of
---@return StarType? star
function Zone.get_star_from_child(zone)
  if zone.type == "star" then
    ---@cast zone StarType
    return zone
  elseif zone.parent then
    ---@cast zone -StarType
    return Zone.get_star_from_child(zone.parent)
  end
end

---@param zone AnyZoneType
---@return PlanetType?
function Zone.get_planet_from_child(zone)
  if zone.type == "planet" then
    ---@cast zone PlanetType
    return zone
  elseif zone.parent then
    ---@cast zone -PlanetType
    return Zone.get_planet_from_child(zone.parent)
  end
end

---Execute a function for every zone of the given parent,
---including the orbits. The function is executed on the
---parent's orbit, but not the parent itself.
---@param zone AnyZoneType|StarType
---@param fn fun(zone: AnyZoneType)
function Zone.apply_for_each_child_and_orbit(zone, fn)
  if zone.orbit then fn(zone.orbit) end

  for _, child in pairs(zone.children or { }) do
    fn(child)
    Zone.apply_for_each_child_and_orbit(child, fn)
  end
end

---Gets the parent stellar object for a zone, which is a star for everything inside a star system
---and an asteroid field if given that asteroid field. Returns nil for the anomaly.
---@param zone AnyZoneType Zone to get parent of
---@return StarType|AsteroidFieldType stellar_object
function Zone.get_stellar_object_from_child(zone)
  if zone.type == "asteroid-field" then
    ---@cast zone AsteroidFieldType
    return zone
  else
    ---@cast zone -AsteroidFieldType
    return Zone.get_star_from_child(zone)
  end
end

---@param zone AnyZoneType|SpaceshipType
---@return StarType?
function Zone.get_star_from_position(zone)
  if not zone.stellar_position then return end
  for _, star in pairs(storage.universe.stars) do
    if star.stellar_position.x == zone.stellar_position.x and star.stellar_position.y == zone.stellar_position.y then
      return star
    end
  end
end

---@param zone AnyZoneType
---@return (StarType|AsteroidFieldType)?
function Zone.get_stellar_object_from_position(zone)
  local star = Zone.get_star_from_position(zone)
  if star then return star end
  for _, asteroid_field in pairs(storage.universe.space_zones) do
    if asteroid_field.stellar_position.x == zone.stellar_position.x and asteroid_field.stellar_position.y == zone.stellar_position.y then
      return asteroid_field
    end
  end
end

---Gets the expected light percentage of a given zone or spaceship.
---@param zone AnyZoneType|SpaceshipType Zone or spaceship whose light % to get
---@return number
function Zone.get_solar(zone)
  -- return the actual expected light % including daytime for space zones and spaceships.
  -- return peak expected light % space solid zones.

  if zone.type == "anomaly" then
    ---@cast zone AnomalyType
    return 0
  end

  local star
  local star_gravity_well = 0

  if zone.type == "spaceship" then
    ---@cast zone SpaceshipType
    star = zone.near_star
    star_gravity_well = zone.star_gravity_well or 0
  else
    ---@cast zone -SpaceshipType
    star = Zone.get_star_from_child(zone)
    star_gravity_well = Zone.get_star_gravity_well(zone)
  end

  local light_percent = 0

  if star then
    light_percent = 1.6 * star_gravity_well / (star.star_gravity_well + 1)
  end

  if Zone.is_space(zone) then
    ---@cast zone -PlanetType, -MoonType
    if(zone.type == "orbit" and zone.parent and zone.parent.type == "star") then -- star
      ---@cast zone OrbitType
      light_percent = light_percent * 10 -- x20
    elseif zone.type == "asteroid-belt" then
      ---@cast zone AsteroidBeltType
      light_percent = light_percent * 2.5 -- x5
    else
      ---@cast zone -AsteroidBeltType
      light_percent = light_percent * 5 -- x10
      if zone.parent and zone.parent.radius then
        light_percent = light_percent * (1 - 0.1 * zone.parent.radius / 10000)
      end
    end
    light_percent = light_percent + 0.01
  else
    ---@cast zone PlanetType|MoonType
    if zone.radius then
      light_percent = light_percent * (1 - 0.1 * zone.radius / 10000)
      if zone.is_homeworld then
        light_percent = 1
      end
    end
  end

  if zone.space_distortion and zone.space_distortion > 0 then

    light_percent = light_percent * (1 - zone.space_distortion)

    if zone.is_homeworld then
      light_percent = 1
    end
  end
  return light_percent
end

---@param zone AnyZoneType|SpaceshipType
---@return number
function Zone.get_display_light_percent(zone)
  return Zone.get_solar(zone)
end

---Sets the zone's surface's daytime and solar multiplier
---@param zone AnyZoneType|SpaceshipType Zone or spaceship whose daytime and solar multiplier to set
function Zone.set_solar_and_daytime(zone)
  local surface
  if zone.type == "spaceship" then
    ---@cast zone SpaceshipType
    surface = Spaceship.get_own_surface(zone)
  else
    ---@cast zone -SpaceshipType
    surface = Zone.get_surface(zone)
  end
  if not surface then return end

  local light_percent = Zone.get_solar(zone)

  if Zone.is_space(zone) then
    ---@cast zone -PlanetType, -MoonType

    -- light_percent is the total output
    -- but we have most space zones daylight ranging from mid evening to night so that lights are active.
    -- so that is the main driving factor.
    -- except stars.

    surface.freeze_daytime = true

    if zone.type == "anomaly" then
      ---@cast zone AnomalyType
      -- Anomaly
      surface.daytime = 0.5 -- night
      surface.solar_power_multiplier = 0
    elseif zone.type == "orbit" and zone.parent.type == "star" then
      ---@cast zone OrbitType
      -- Star orbit
      surface.daytime = 0 -- very bright
      surface.solar_power_multiplier = Zone.solar_multiplier * light_percent
    else
      ---@cast zone -AnomalyType
      -- Other space zones, including spaceships
      Zone.set_solar_and_daytime_for_space_zone(surface, light_percent)
    end

  else
    ---@cast zone PlanetType|MoonType
    -- planet or moon
    -- has daytime

    surface.freeze_daytime = false

    surface.daytime = (game.tick / zone.ticks_per_day) % 1
    surface.solar_power_multiplier = Zone.solar_multiplier * light_percent

    if zone.ticks_per_day then
      surface.ticks_per_day = zone.ticks_per_day
    end

  end

end

---Sets the zone's surface's daytime and solar multiplier
---@param surface LuaSurface Surface of the zone to change
---@param light_percent number Light percentage taken from Zone.get_solar
function Zone.set_solar_and_daytime_for_space_zone(surface, light_percent)
  -- light_percent of 1 would be daytime 0.65 (half-light)
  -- light_percent of 0.5 would still be daytime 0.65
  -- between 0.5 to 0 light_percent, daytime decreases from 0.65 to 0.55
  -- light_percent of 0 would be daytime 0.55 (dark)

  if light_percent >= 0.5 then
    surface.daytime = 0.65 -- half light (sunrise)
    surface.solar_power_multiplier = Zone.solar_multiplier * light_percent * 2 -- x2 compensate for half light
  else
    surface.daytime = 0.55 + 0.2 * light_percent
    surface.solar_power_multiplier = Zone.solar_multiplier
  end
end

---Gets a weighted score for a zone, based on its flags; used for sorting in the Universe Explorer.
---@param zone AnyZoneType|SpaceshipType Zone to evaluate
---@param force_name string Force's name
---@param playerdata PlayerData Player data
---@return number weight
function Zone.get_flags_weight(zone, force_name, playerdata)
  local flags = playerdata.zonelist_enabled_flags --[[@as Flags]]
  local forcedata = storage.forces[force_name]
  local weight = 0

  if zone.type == "spaceship" then return weight end
  ---@cast zone -SpaceshipType

  if flags.vault then
    weight = weight + ((playerdata.track_glyphs and zone.glyph) and 0.96 or 0)
  end

  if flags.ruin then
    weight = weight + ((zone.interburbulator or zone.ruins) and 0.95 or 0)
  end

  if flags.visited then
    weight = weight + ((playerdata.visited_zone and playerdata.visited_zone[zone.index]) and 0.97 or 0)
  end

  local zone_assets = forcedata.zone_assets and forcedata.zone_assets[zone.index]
  if zone_assets then
    if flags.launchpad then
      weight = weight + (next(zone_assets.rocket_launch_pad_names) and 1.02 or 0)
    end
    if flags.landingpad then
      weight = weight + (next(zone_assets.rocket_landing_pad_names) and 1.01 or 0)
    end
    if flags.energy_beam_defence then
      weight = weight + (zone_assets.energy_beam_defence and next(zone_assets.energy_beam_defence) and 1 or 0)
    end
  end

  if flags.meteor_defence then
    weight = weight + (zone.meteor_defences and next(zone.meteor_defences) and 0.99 or 0)
  end

  if flags.meteor_point_defence then
    weight = weight + (zone.meteor_point_defences and next(zone.meteor_point_defences) and 0.98 or 0)
  end

  if flags.surface then
    weight = weight + (zone.surface_index and 0.94 or 0)
  end

  return weight
end

---Gets the surface of a given zone or spaceship, if any. Does not create it if it doesn't exist.
---@param zone AnyZoneType|SpaceshipType|StarType Zone or spaceship whose surface to get
---@return LuaSurface?
function Zone.get_surface(zone)
  if zone.type == "spaceship" then
    ---@cast zone SpaceshipType
    return Spaceship.get_current_surface(zone)
  end
  ---@cast zone -SpaceshipType
  if zone.surface_index then
    return game.get_surface(zone.surface_index)
  end
  return nil
end

---Gets the name of a given zone or spaceship's surface, if any.
---@param zone AnyZoneType|SpaceshipType Zone or spaceship whose name to get
---@return string? surface_name
function Zone.get_surface_name(zone)
  local surface = Zone.get_surface(zone)
  if surface then return surface.name end
end

---Gets the surface of a zone or creates one if it doesn't already exist.
---@param zone AnyZoneType|SpaceshipType Zone whose surface to get/make
---@return LuaSurface surface
function Zone.get_make_surface(zone)
  if zone.type == "spaceship" then
    ---@cast zone SpaceshipType
    return Spaceship.get_current_surface(zone)
  end
  ---@cast zone -SpaceshipType
  if not zone.surface_index then Zone.create_surface(zone) end
  return game.get_surface(zone.surface_index)
end

---@param force_name string
---@param zone AnyZoneType|StarType
---@param source LocalisedString
---@return boolean?
function Zone.discover(force_name, zone, source) -- source could be "Satellite "
  if not storage.forces[force_name] then return end
  storage.forces[force_name].zones_discovered = storage.forces[force_name].zones_discovered or {}
  storage.forces[force_name].zones_discovered_count = storage.forces[force_name].zones_discovered_count or 0

  if not storage.forces[force_name].zones_discovered[zone.index] then

      Universe.inflate_climate_controls(zone)

      storage.forces[force_name].zones_discovered[zone.index] = {
        discovered_at = game.tick,
        marker = nil
      }
      storage.forces[force_name].zones_discovered_count = storage.forces[force_name].zones_discovered_count + 1
      if zone.type == "planet" and (not zone.is_homeworld) and (not zone.ruins) and (not zone.glyph) then
        ---@cast zone PlanetType
        Ancient.assign_zone_next_glyph(zone)
      end

      -- Unique ruins
      Ruin.zone_assign_unique_ruins(zone)

      local message = nil
      if source then
        message = {"space-exploration.source-discovered-zone", source, Zone.type_title(zone), Zone.get_print_name(zone)}
      else
        message = {"space-exploration.discovered-zone", Zone.type_title(zone), Zone.get_print_name(zone)}
      end
      local force = game.forces[force_name]
      force.print(message)

      Zone.apply_markers(zone) -- in case the surface exists

      for _, player in pairs(force.connected_players) do
        Zonelist.update_list(player)
      end

      if zone.type == "anomaly" then
        ---@cast zone AnomalyType
        ---@type ForceMessageTickTask
        local tick_task = new_tick_task("force-message")
        tick_task.force_name = force_name
        tick_task.message = {"space-exploration.discovered-anomaly-additional"}
        tick_task.delay_until = game.tick + 300 --5s
      end

      if zone.glyph then
        for _, player in pairs(force.players) do
          if player.connected then
            local playerdata = get_make_playerdata(player)
            if playerdata.track_glyphs then
              player.print({"space-exploration.discovered-glyph-vault", Zone.get_print_name(zone)})
            end
          end
        end
      end

      if zone.type == "orbit" then
        ---@cast zone OrbitType
        Zone.discover(force_name, zone.parent, source)
      end

      return true

  end
  return false
end

---@param force_name string
---@param source LocalisedString
---@param allow_targeted boolean
---@return boolean?
function Zone.discover_next_research(force_name, source, allow_targeted)
  if not storage.forces[force_name] then return end
  storage.forces[force_name].zones_discovered = storage.forces[force_name].zones_discovered or {}
  storage.forces[force_name].zones_discovered_count = storage.forces[force_name].zones_discovered_count or 0

  local target_resource = "n/a"
  if allow_targeted then
    target_resource = storage.forces[force_name].search_for_resource
  end

  local can_discover = {}
  local can_discover_targeted = {}

  -- star and deep space discovery should be bias to nearer positions
  local closest_1 = nil
  local closest_stellar_distance = math.huge
  local pos1 = {x = 0, y = 0} -- focus on aeras close to the center of the star map

  for _, star in pairs(storage.universe.stars) do
    if not storage.forces[force_name].zones_discovered[star.index] then
      local pos2 = Zone.get_stellar_position(star)
      local distance = util.vectors_delta_length_sq(pos1, pos2)
      if distance < closest_stellar_distance then
        closest_stellar_distance = distance
        closest_1 = star
      end
    end
  end

  if closest_1 then
    -- x5
    table.insert(can_discover, closest_1)
    table.insert(can_discover, closest_1)
    table.insert(can_discover, closest_1)
    table.insert(can_discover, closest_1)
    table.insert(can_discover, closest_1)
  end

  for _, star in pairs(storage.universe.stars) do
    if storage.forces[force_name].zones_discovered[star.index] then
      for _, planet in pairs(star.children) do
        if not storage.forces[force_name].zones_discovered[planet.index] then
          if planet.primary_resource == target_resource then
            table.insert(can_discover_targeted, planet)
            if planet.type == "planet" then
              --x5 bias towards planets
              table.insert(can_discover_targeted, planet)
              table.insert(can_discover_targeted, planet)
              table.insert(can_discover_targeted, planet)
              table.insert(can_discover_targeted, planet)
            end
          else
            table.insert(can_discover, planet)
            if planet.type == "planet" then
              --x5 bias towards planets
              table.insert(can_discover, planet)
              table.insert(can_discover, planet)
              table.insert(can_discover, planet)
              table.insert(can_discover, planet)
            end
          end
        else
          if planet.children then
            for _, moon in pairs(planet.children) do
              if not storage.forces[force_name].zones_discovered[moon.index] then
                if moon.primary_resource == target_resource then
                  table.insert(can_discover_targeted, moon)
                else
                  table.insert(can_discover, moon)
                end
              end
            end
          end
        end
      end
    end
  end

  if next(can_discover_targeted) then
    return Zone.discover(force_name, Util.random_from_array(can_discover_targeted), source)
  end
  if next(can_discover) then
    return Zone.discover(force_name, Util.random_from_array(can_discover), source)
  end

end

---@param force_name string
---@param source LocalisedString
---@param allow_targeted boolean
---@return boolean?
function Zone.discover_next_research_deep_space(force_name, source, allow_targeted)
  if not storage.forces[force_name] then return end
  storage.forces[force_name].zones_discovered = storage.forces[force_name].zones_discovered or {}
  storage.forces[force_name].zones_discovered_count = storage.forces[force_name].zones_discovered_count or 0

  if game.forces[force_name].technologies[Zone.name_tech_discover_deep].level > 11 then
    -- should have discovered multiple stars at this point
    if not storage.forces[force_name].zones_discovered[storage.universe.anomaly.index] then
      return Zone.discover(force_name, storage.universe.anomaly, source)
    end
  end

  local target_resource = "n/a"
  if allow_targeted then
    target_resource = storage.forces[force_name].search_for_resource
  end

  local can_discover = {}
  local can_discover_targeted = {}
  for _, zone in pairs(storage.universe.space_zones) do
    if not storage.forces[force_name].zones_discovered[zone.index] then
      if zone.primary_resource == target_resource then
        table.insert(can_discover_targeted, zone)
      else
        table.insert(can_discover, zone)
      end
    end
  end

  if next(can_discover_targeted) then
    return Zone.discover(force_name, Util.random_from_array(can_discover_targeted), source)
  end
  if next(can_discover) then
    return Zone.discover(force_name, Util.random_from_array(can_discover), source)
  end
end

---@param force_name string
---@param source LocalisedString
---@return boolean?
function Zone.discover_first_moon(force_name, source)
  return Zone.discover(force_name, Zone.get_force_home_zone(force_name).children[1], source)
end

---@param force_name string
---@param source LocalisedString
---@param starting_zone AnyZoneType
---@return boolean?
function Zone.discover_first_asteroid_field(force_name, source, starting_zone)
  local home_zone = Zone.get_force_home_zone(force_name)
  local star = home_zone.parent
  for _, child in pairs(star.children) do
    if child.type == "asteroid-belt" then
      return Zone.discover(force_name, child, source)
    end
  end
  return Zone.discover_next_satellite(force_name, {"", "[img=item/satellite] ", {"space-exploration.satellite"}}, starting_zone)
end

---@param force_name string
---@param source LocalisedString
---@param starting_zone AnyZoneType
---@return boolean?
function Zone.discover_vulacnite_planet(force_name, source, starting_zone)
  local home_zone = Zone.get_force_home_zone(force_name)
  local star = home_zone.parent
  for _, child in pairs(star.children) do
    if child.primary_resource == mod_prefix .. "vulcanite" then
      return Zone.discover(force_name, child, source)
    end
  end
  return Zone.discover_next_satellite(force_name, {"", "[img=item/satellite] ", {"space-exploration.satellite"}}, starting_zone)
end

---@param force_name string
---@param source LocalisedString
---@param starting_zone AnyZoneType
---@return boolean?
function Zone.discover_cryonite_moon_or_parent(force_name, source, starting_zone)
  local home_zone = Zone.get_force_home_zone(force_name)
  local star = home_zone.parent
  for _, planet in pairs(star.children) do
    if planet.primary_resource == mod_prefix .. "cryonite" and not Zone.is_visible_to_force(planet, force_name) then
      return Zone.discover(force_name, planet, source)
    elseif planet.children then
      for _, moon in pairs(planet.children) do
        if moon.primary_resource == mod_prefix .. "cryonite" and not Zone.is_visible_to_force(moon, force_name) then
          if Zone.is_visible_to_force(planet, force_name) then
            return Zone.discover(force_name, moon, source)
          else
            return Zone.discover(force_name, planet, source)
          end
        end
      end
    end
  end
  return Zone.discover_next_satellite(force_name, {"", "[img=item/satellite] ", {"space-exploration.satellite"}}, starting_zone)
end

---@param force_name string
---@param source LocalisedString
---@param system_restriction AnyZoneType
---@return boolean?
function Zone.discover_next_satellite(force_name, source, system_restriction)
  if not storage.forces[force_name] then return end
  storage.forces[force_name].zones_discovered = storage.forces[force_name].zones_discovered or {}
  storage.forces[force_name].zones_discovered_count = storage.forces[force_name].zones_discovered_count or 0

  if system_restriction then
    ---@type AnyZoneType|StarType
    local star = system_restriction
    while star.parent do
      star = star.parent
    end
    ---@cast star StarType
    local last_valid
    if star.children then
      for _, planet in pairs(star.children) do
        if not storage.forces[force_name].zones_discovered[planet.index] then
          if math.random() < 0.5 then -- skip it
            last_valid = planet
          else
            return Zone.discover(force_name, planet, source)
          end
        elseif planet.children then
          for _, moon in pairs(planet.children) do
            if not storage.forces[force_name].zones_discovered[moon.index] then
              if math.random() < 0.5 then -- skip it
                last_valid = moon
              else
                return Zone.discover(force_name, moon, source)
              end
            end
          end
        end
      end
    end
    --skipped too much
    if last_valid then
      return Zone.discover(force_name, last_valid, source)
    end
    -- find stars now
    local closest_1 = nil
    local closest_stellar_distance = math.huge
    local pos1 = Zone.get_stellar_position(star)

    for _, star2 in pairs(storage.universe.stars) do
      if not storage.forces[force_name].zones_discovered[star2.index] then
        local pos2 = Zone.get_stellar_position(star2)
        local distance = util.vectors_delta_length_sq(pos1, pos2)
        if distance < closest_stellar_distance then
          closest_stellar_distance = distance
          closest_1 = star2
        end
      end
    end
    if closest_1 then
      return Zone.discover(force_name, closest_1, source)
    end
    return false
  end

end

---Finds the nearest star or asteroid field from a given stellar position.
---@param stellar_position StellarPosition
---@return StarType|AsteroidFieldType
function Zone.find_nearest_stellar_object(stellar_position)
  local closest_distance = math.huge
  local closest = nil

  for _, star in pairs(storage.universe.stars) do
    local distance = util.vectors_delta_length_sq(star.stellar_position, stellar_position)
    if distance < closest_distance then
      closest_distance = distance
      closest = star
    end
  end

  for _, space_zone in pairs(storage.universe.space_zones) do
    local distance = util.vectors_delta_length_sq(space_zone.stellar_position, stellar_position)
    if distance < closest_distance then
      closest_distance = distance
      closest = space_zone
    end
  end
  ---@cast closest -?
  return closest
end

---Finds the nearest star from a given stellar position.
---@param stellar_position StellarPosition
---@return StarType
function Zone.find_nearest_star(stellar_position)
  local closest_distance = math.huge
  local closest = nil

  for _, star in pairs(storage.universe.stars) do
    local distance = util.vectors_delta_length_sq(star.stellar_position, stellar_position)
    if distance < closest_distance then
      closest_distance = distance
      closest = star
    end
  end
  ---@cast closest -?
  return closest
end

---@param space_distortion number
---@param stellar_position StellarPosition
---@param star_gravity_well number
---@param planet_gravity_well number
---@return AnyZoneType|StarType
function Zone.find_nearest_zone(space_distortion, stellar_position, star_gravity_well, planet_gravity_well)

  if space_distortion > 0.4 then return storage.universe.anomaly end -- default from the anomaly

  local star = Zone.find_nearest_stellar_object(stellar_position) -- can be asteroid field
  if star_gravity_well > 0 then
    ---@type AnyZoneType|StarType
    local closest_zone = star
    local closest_distance =  math.abs((star.star_gravity_well or 0) - star_gravity_well)
    if closest_zone.type == "star" then
      ---@cast closest_zone StarType
      for _, planet in pairs(star.children) do
        local distance = math.abs(planet.star_gravity_well - star_gravity_well)
        if distance < closest_distance then
          closest_distance = distance
          closest_zone = planet
        end
      end
    end

    if closest_zone.type == "planet" then
      ---@cast closest_zone PlanetType
      local closest_zone2 = closest_zone
      closest_distance =  math.abs(closest_zone.planet_gravity_well - planet_gravity_well)
      for _, moon in pairs(closest_zone.children) do
        if moon.type == "moon" then
          local distance = math.abs(moon.planet_gravity_well - planet_gravity_well)
          if distance < closest_distance then
            closest_distance = distance
            closest_zone2 = moon
          end
        end
      end
      return closest_zone2
    end
    return closest_zone
  else
    if not star then return storage.universe.anomaly end
    if not star.children then return star end
    local last_child = star.children[#star.children]
    if last_child.children then
      last_child = last_child.children[#last_child.children]
    end
    return last_child
  end
  return Zone.get_default()

end

---@param space_distortion number
---@param stellar_position StellarPosition
---@param star_gravity_well integer
---@param planet_gravity_well integer
---@param allow_moon boolean
---@return AnyZoneType
function Zone.find_nearest_solid_zone(space_distortion, stellar_position, star_gravity_well, planet_gravity_well, allow_moon)
  if space_distortion == 1 then return Zone.get_default() end -- default from the anomaly

  if planet_gravity_well == 0 then -- if no moon
    planet_gravity_well = 100000 -- high to land on planet
  end

  if star_gravity_well == 0 then -- if no planet
    star_gravity_well = 100000 -- high to land on planet with high solar
  end

  local star = Zone.find_nearest_star(stellar_position)
  if not star then return Zone.get_default() end

  local closest_planet = nil
  local closest_distance = math.huge
  for _, planet in pairs(star.children) do
    if planet.type == "planet" then -- not an asteroid belt
      local distance = math.abs(planet.star_gravity_well - star_gravity_well)
      if distance < closest_distance then
        closest_distance = distance
        closest_planet = planet
      end
    end
  end

  if not closest_planet then return Zone.get_default() end

  local closest_body = closest_planet -- default to planet

  if allow_moon then
    closest_distance =  math.abs(closest_body.planet_gravity_well - planet_gravity_well)
    -- see if a moon is closer
    for _, moon in pairs(closest_planet.children) do
      if moon.type == "moon" then
        local distance = math.abs(moon.planet_gravity_well - planet_gravity_well)
        if distance < closest_distance then
          closest_distance = distance
          closest_body = moon
        end
      end
    end
  end

  return closest_body

end

---@param zone AnyZoneType
---@return AnyZoneType?
function Zone.find_nearest_solid_zone_from_zone(zone)
  -- typically used for escape pod
  if Zone.is_solid(zone) then return nil end -- already there
  ---@cast zone -PlanetType, -MoonType

  if zone.type == "orbit" and Zone.is_solid(zone.parent) then
    ---@cast zone OrbitType
    return zone.parent -- drop to planet / moon
  end

  return Zone.find_nearest_solid_zone(
    Zone.get_space_distortion(zone),
    Zone.get_stellar_position(zone),
    Zone.get_star_gravity_well(zone),
    Zone.get_planet_gravity_well(zone),
    true
  )
end

---Gets all zone assets of a given force.
---@param force_name string Force name
---@return IndexMap<ZoneAssetsInfo> zone_assets
function Zone.get_all_force_assets(force_name)
  if not storage.forces[force_name] then
    if game.forces[force_name] then
      setup_force(game.forces[force_name])
    else
      return {}
    end
  end
  if not storage.forces[force_name] then
    if game.forces[force_name] then
      game.forces[force_name].print("Error getting force data for invalid player force " .. force_name)
    else
      game.forces[force_name].print("Error getting force data for invalid force " .. force_name)
    end
    return {} -- invalid force
  end
  if not storage.forces[force_name].zone_assets then
    storage.forces[force_name].zone_assets = {}
  end
  return storage.forces[force_name].zone_assets
end

---Gets the zone assets of a given force located in a given zone.
---@param force_name string Force name
---@param zone_index uint Zone index
---@return ZoneAssetsInfo zone_assets
function Zone.get_force_assets(force_name, zone_index)
  local zone_assets = Zone.get_all_force_assets(force_name)
  if not zone_assets[zone_index] then
    zone_assets[zone_index] = {
      rocket_launch_pad_names = {},
      rocket_landing_pad_names = {},
    }
  end
  return zone_assets[zone_index]
end

---Gets all landing pads of a given force located in a given zone.
---@param force_name string Force name
---@param zone_index uint Zone index
---@return RocketLandingPadInfo[] zone_landing_pads
function Zone.get_force_landing_pads(force_name, zone_index)
  local zone_landing_pads = {}
  for _, rocket_landing_pad in pairs(storage.rocket_landing_pads) do
    if rocket_landing_pad.force_name == force_name
      and rocket_landing_pad.container and rocket_landing_pad.container.valid
      and rocket_landing_pad.zone.index == zone_index then
      table.insert(zone_landing_pads, rocket_landing_pad)
    end
  end
  return zone_landing_pads
end

---@param origin AnyZoneType|SpaceshipType
---@param destination AnyZoneType|SpaceshipType
---@return integer
function Zone.get_travel_delta_v_sub(origin, destination)
  -- expected ranges:
    -- 1500 planetary system
    -- 15000 solar system
    -- 50000 interstellarsystem
    -- 50000 to/from anomaly
  if origin == destination then return 0 end

  local origin_space_distorion = Zone.get_space_distortion(origin)
  local origin_stellar_position = Zone.get_stellar_position(origin)
  local origin_star_gravity_well = Zone.get_star_gravity_well(origin)
  local origin_planet_gravity_well = Zone.get_planet_gravity_well(origin)

  local destination_space_distorion = Zone.get_space_distortion(destination)
  local destination_stellar_position = Zone.get_stellar_position(destination)
  local destination_star_gravity_well = Zone.get_star_gravity_well(destination)
  local destination_planet_gravity_well = Zone.get_planet_gravity_well(destination)

  if origin_space_distorion > 0 and destination_space_distorion > 0 then -- spaceship partially in distortion
    return Zone.travel_cost_interstellar * math.abs(origin_space_distorion - destination_space_distorion)
  elseif origin_space_distorion > 0 then
    return Zone.travel_cost_space_distortion
      + Zone.travel_cost_star_gravity * destination_star_gravity_well
      + Zone.travel_cost_planet_gravity * destination_planet_gravity_well
  elseif destination_space_distorion > 0 then
    return Zone.travel_cost_space_distortion
      + Zone.travel_cost_star_gravity * origin_star_gravity_well
      + Zone.travel_cost_planet_gravity * origin_planet_gravity_well
  end

  if origin_stellar_position.x == destination_stellar_position.x and origin_stellar_position.y == destination_stellar_position.y then
    -- same solar system
    if origin_star_gravity_well == destination_star_gravity_well then
      -- same planetary system
      return Zone.travel_cost_planet_gravity * math.abs(origin_planet_gravity_well - destination_planet_gravity_well) -- the planet_gravity_well difference
    else
      -- different planetary systems
      return Zone.travel_cost_star_gravity * math.abs(destination_star_gravity_well - origin_star_gravity_well) -- the star_gravity_well difference
        + Zone.travel_cost_planet_gravity * origin_planet_gravity_well
        + Zone.travel_cost_planet_gravity * destination_planet_gravity_well
    end
  else
    -- interstellar
    return Zone.travel_cost_interstellar * util.vectors_delta_length(origin_stellar_position, destination_stellar_position)
      + Zone.travel_cost_star_gravity * origin_star_gravity_well
      + Zone.travel_cost_planet_gravity * origin_planet_gravity_well
      + Zone.travel_cost_star_gravity * destination_star_gravity_well
      + Zone.travel_cost_planet_gravity * destination_planet_gravity_well
  end

end

---Gets delta_v between two zones/spaceships; will fetch it from `storage.cache_travel_delta_v` if
---it has been previously calculated for that origin-destination pair.
---@param origin AnyZoneType|SpaceshipType Origin zone or spaceship
---@param destination AnyZoneType|SpaceshipType Destination zone or spaceship
---@return number? delta_v
function Zone.get_travel_delta_v(origin, destination)
  if not (origin and destination) then return end
  if origin.type == "spaceship" or destination.type == "spaceship" then
    return Zone.get_travel_delta_v_sub(origin, destination)
  end
  storage.cache_travel_delta_v[origin.index] = storage.cache_travel_delta_v[origin.index] or {}
  if not storage.cache_travel_delta_v[origin.index][destination.index] then
    storage.cache_travel_delta_v[origin.index][destination.index] = Zone.get_travel_delta_v_sub(origin, destination)
  end
  return storage.cache_travel_delta_v[origin.index][destination.index]
end

---@param zone AnyZoneType
---@return number
function Zone.get_launch_delta_v(zone)
  -- 10000 to 800 for planets, 0 for in space
  return 500 + (zone.radius or 50)
end

---@param origin AnyZoneType
---@param destination_list AnyZoneType[]
---@return AnyZoneType? destination
function Zone.get_closest_zone(origin, destination_list)
  if not (origin or destination_list) then return end
  if Util.table_contains(destination_list, origin) then return origin end
  local destination = nil
  local delta_v_closest = math.huge
  local delta_v_current = nil
  for _, zone in pairs(destination_list) do
    delta_v_current = Zone.get_travel_delta_v(origin, zone)
    if delta_v_current < delta_v_closest then
      delta_v_closest = delta_v_current
      destination = zone
    end
  end
  return destination
end

---@param zone AnyZoneType|SpaceshipType
---@param try_position? MapPosition
---@return MapPosition
function Zone.find_zone_landing_position(zone, try_position)
  Log.debug_log("Zone.find_zone_landing_position: " ..zone.name)
  local surface = Zone.get_make_surface(zone)

  if not try_position then
    if zone.type == "spaceship" then
      ---@cast zone SpaceshipType
      try_position = Spaceship.get_boarding_position(zone)
    elseif Zone.is_solid(zone) then
      ---@cast zone PlanetType|MoonType
      local try_angle = math.random() * math.pi * 2 -- rad
      local try_distance = math.random() * (zone.radius / 4 or 512)
      try_position = {x = math.cos(try_angle) * try_distance, y = math.sin(try_angle) * try_distance}
    else
      ---@cast zone -SpaceshipType, -PlanetType, -MoonType
      try_position = {x = math.random(-512, 512), y = math.random(-128, 128)}
    end
  end
  surface.request_to_generate_chunks(try_position, 2)
  surface.force_generate_chunk_requests()
  local safe_position
  if Zone.is_solid(zone) then
    ---@cast zone PlanetType|MoonType
    safe_position = surface.find_non_colliding_position(collision_rocket_destination_surface, try_position, 64, 1)
  else
    ---@cast zone -PlanetType, -MoonType
    safe_position = surface.find_non_colliding_position(collision_rocket_destination_orbit, try_position, 64, 1)
  end
  if not safe_position then
    local try_position_2 = {x = 64 * (math.random() - 0.5), y = 64 * (math.random() - 0.5)}
    surface.request_to_generate_chunks(try_position_2, 2)
    surface.force_generate_chunk_requests()
    if Zone.is_solid(zone) then
      ---@cast zone PlanetType|MoonType
      safe_position = surface.find_non_colliding_position(collision_rocket_destination_surface, try_position_2, 64, 1)
    else
      ---@cast zone -PlanetType, -MoonType
      safe_position = surface.find_non_colliding_position(collision_rocket_destination_orbit, try_position_2, 64, 1)
    end
  end
  if safe_position then
    Log.debug_log("Zone.find_zone_landing_position: safe_position found")
    return safe_position
  else
    Log.debug_log("Zone.find_zone_landing_position: safe_position not found, falling back to try_position")
    return try_position
  end
end

---@param zone AnyZoneType|SpaceshipType
---@param no_indent? boolean
---@return string
function Zone.dropdown_name_from_zone(zone, no_indent)
  local i1 = "    "
  local i2 = "        "
  local i3 = "              "
  if no_indent then
    i1 = ""
    i2 = ""
    i3 = ""
  end
  if zone.type == "orbit" then
    ---@cast zone OrbitType
    if zone.parent.type == "star" then
      return "[img=virtual-signal/se-star] " .. zone.name -- star orbit
    elseif zone.parent.type == "planet" then
      return i2.."[img=virtual-signal/se-planet-orbit] " .. zone.name  -- planet orbit
    elseif zone.parent.type == "moon" then
      return i3.."[img=virtual-signal/se-moon-orbit] " .. zone.name -- moon orbit
    end
  elseif zone.type == "asteroid-belt" then
    ---@cast zone AsteroidBeltType
    return i1 .. "[img=virtual-signal/se-asteroid-belt] " .. zone.name
  elseif zone.type == "planet" then
    ---@cast zone PlanetType
    return i1 .. "[img=virtual-signal/se-planet] " ..  zone.name
  elseif zone.type == "moon" then
    ---@cast zone MoonType
    return i2 .. "[img=virtual-signal/se-moon] " ..  zone.name
  elseif zone.type == "asteroid-field" then
    ---@cast zone AsteroidFieldType
    return "[img=virtual-signal/"..mod_prefix..zone.type .. "] " .. zone.name .. " [color=black](Asteroid Field)[/color]"
  elseif zone.type == "anomaly" then
    ---@cast zone AnomalyType
    return "[img=virtual-signal/"..mod_prefix..zone.type .. "] " .. zone.name .. " [color=black](Anomaly)[/color]"
  elseif zone.type == "spaceship" then
    ---@cast zone SpaceshipType
    return "[img=virtual-signal/"..mod_prefix..zone.type .. "] " .. zone.name .. " [color=blue]["..zone.index.."][/color] [color=black](Spaceship)[/color]"
  end
  return "[img=virtual-signal/"..mod_prefix..zone.type .. "] " .. zone.name
end

---@return SpaceshipType[]
function Zone.get_alphabetised()
  local zones_alphabetised = {}
  for _, zone in pairs(storage.zone_index) do
    table.insert(zones_alphabetised, zone)
  end
  for _, spaceship in pairs(storage.spaceships) do
    table.insert(zones_alphabetised, spaceship)
  end
  table.sort(zones_alphabetised, function(a,b) return a.name < b.name end)
  return zones_alphabetised
end

---@param zone AnyZoneType|SpaceshipType|StarType
---@param force_name string
---@return boolean
function Zone.is_visible_to_force(zone, force_name)
  if storage.debug_view_all_zones then return true end
  if zone.type == "spaceship" then return zone.force_name == force_name end
  ---@cast zone -SpaceshipType
  if not (storage.forces[force_name] and storage.forces[force_name].zones_discovered) then return false end
  return storage.forces[force_name].zones_discovered[zone.index] or (zone.type == "orbit" and storage.forces[force_name].zones_discovered[zone.parent.index]) and true or false
end

---@param target_table AnyZoneType|SpaceshipType[]
---@param zone AnyZoneType|SpaceshipType
---@param force_name string
function Zone.insert_if_visible_to_force(target_table, zone, force_name)
  if Zone.is_visible_to_force(zone, force_name) then table.insert(target_table, zone) end
end

---@class ZoneDropDownArguments
  ---@field alphabetical boolean?
  ---@field filter string?
  ---@field wildcard {list:LocalisedString, value:table, ignore_when_empty_list:boolean?}?
  ---@field star_restriction StarType?
  ---@field excluded_types string[]?
  ---@field only_with_train_stops boolean?
  ---@field only_with_spaceship_clamps boolean?
  ---@field allow_stars boolean?

---@param player LuaPlayer
---@param force_name string
---@param current AnyZoneType|StarType|SpaceshipType?
---@param args ZoneDropDownArguments?
---@return LocalisedString[]
---@return uint
---@return LocationReference[]
function Zone.dropdown_list_zone_destinations(player, force_name, current, args)
  -- excluded_types = {"spaceship", "star", "moon", "all"}
  local selected_index = 1
  ---@type LocalisedString
  local list = {""}
  ---@type LocationReference[]
  local values = {{type = "nil", index = nil}} -- zone indexes
  args = args or {}
  local alphabetical = args.alphabetical
  local filter = args.filter
  local wildcard = args.wildcard
  local star_restriction = args.star_restriction
  local excluded_types = core_util.list_to_map(args.excluded_types or {})
  local only_with_train_stops = args.only_with_train_stops
  local only_with_spaceship_clamps = args.only_with_spaceship_clamps
  local allow_stars = args.allow_stars

  local forcedata = storage.forces[force_name]
  if not forcedata then return list, selected_index, values end

  local playerdata = get_make_playerdata(player)
  playerdata.dropdowns_hide_low_priority_zones = playerdata.dropdowns_hide_low_priority_zones
    or settings.get_player_settings(player.index)["se-dropdowns-hide-low-priority-zones"].value
  playerdata.dropdowns_priority_threshold = playerdata.dropdowns_priority_threshold
    or settings.get_player_settings(player.index)["se-dropdowns-priority-threshold"].value

  ---@param zone AnyZoneType|SpaceshipType
  local function conditional_add_zone_to_list(zone)
    local priority_toggle = playerdata.dropdowns_hide_low_priority_zones
    local priority_threshold = playerdata.dropdowns_priority_threshold

    if storage.debug_view_all_zones
     or (zone.type == "spaceship" and forcedata.force_name == zone.force_name)
     or (zone.type ~= "spaceship" and (forcedata.zones_discovered[zone.index] or (zone.type == "orbit" and forcedata.zones_discovered[zone.parent.index]))) then
      local allowed_system = true
      if excluded_types[zone.type] then
        allowed_system = false
      end
      if star_restriction then
        allowed_system = false
        if zone == star_restriction
        or Zone.get_star_from_child(zone) == star_restriction then
          allowed_system = true
        end
      end
      if only_with_train_stops then
        local surface = Zone.get_surface(zone)
        if surface then
          local stops = game.train_manager.get_train_stops{surface = surface, force = player.force}
          if not (stops and next(stops)) then
            allowed_system = false
          end
        else
          allowed_system = false
        end
      end
      if only_with_spaceship_clamps then
        local surface_index = zone.surface_index
        if not surface_index then
          allowed_system = false
        else
          local surface_name = Zone.get_surface_name(zone)
          if allowed_system and surface_name then
            local found = false
            for _, clamp_info in pairs(storage.spaceship_clamps_by_surface[surface_name] or { }) do
              if clamp_info.force_name == force_name then
                found = true
                break
              end
            end
            if not found then allowed_system = false end
          end
        end
      end
      if allowed_system then
        if not priority_toggle
          or Zone.get_priority(zone, player.force.name) >= priority_threshold
          or (current and zone.type == current.type and zone.index == current.index) then
          if zone.type == "spaceship" then
            ---@cast zone SpaceshipType
            table.insert(list, Zone.dropdown_name_from_zone(zone, alphabetical or filter))
            table.insert(values, {type = "spaceship", index = zone.index})
            if current and zone.type == current.type and zone.index == current.index then selected_index = #list end
          else
            ---@cast zone -SpaceshipType
            table.insert(list, Zone.dropdown_name_from_zone(zone, alphabetical or filter))
            table.insert(values, {type = "zone", index = zone.index})
            if current and zone.type == current.type and zone.index == current.index then selected_index = #list end
          end
        end
      end
    end
  end

  if not excluded_types["all"] then
    if alphabetical == true or filter then
      for _, zone in pairs(Zone.get_alphabetised()) do
        if allow_stars or zone.type ~= "star" then
          ---@cast zone -StarType
          if (not filter) or string.find(string.lower(zone.name), string.lower(filter), 1, true) then
            conditional_add_zone_to_list(zone)
          end
        end
      end
    else
      conditional_add_zone_to_list(storage.universe.anomaly)

      for _, star in pairs(storage.universe.stars) do
        conditional_add_zone_to_list(star.orbit)
        for _, planet in pairs(star.children) do
          conditional_add_zone_to_list(planet)
          if planet.children then
            conditional_add_zone_to_list(planet.orbit)
            for _, moon in pairs(planet.children) do
              conditional_add_zone_to_list(moon)
              conditional_add_zone_to_list(moon.orbit)
            end
          end
        end
      end

      for _, zone in pairs(storage.universe.space_zones) do
        conditional_add_zone_to_list(zone)
      end

      if not excluded_types["spaceship"] then
        for _, spaceship in pairs(storage.spaceships) do
          conditional_add_zone_to_list(spaceship)
        end
      end
    end
  end

  local number_zones_found = #list - 1
  -- This assumes that a possible added wildcard should not be counted as zone

  if wildcard then
    if not wildcard.ignore_when_empty_list or number_zones_found > 0 then
      table.insert(list, 2, wildcard.list)
      table.insert(values, 2, wildcard.value)
      selected_index = selected_index + 1
    end
  end

  if star_restriction then
    if filter then
      list[1] = {"space-exploration.target-label-matching-locations-in-system", number_zones_found}
    else
      list[1] = {"space-exploration.target-label-known-locations-in-system", number_zones_found}
    end
  else
    if filter then
      list[1] = {"space-exploration.target-label-matching-locations", number_zones_found}
    else
      list[1] = {"space-exploration.target-label-known-locations", number_zones_found}
    end
  end

  return list, selected_index, values
end

---@param origin AnyZoneType|SpaceshipType
---@param zone_list (AnyZoneType|SpaceshipType)[]
---@return (AnyZoneType|SpaceshipType)[]
function Zone.sort_by_delta_v(origin, zone_list)
  local zone_list_sorted = util.shallow_copy(zone_list)
  table.sort(zone_list_sorted, function(a, b) return Zone.get_travel_delta_v(origin, a) < Zone.get_travel_delta_v(origin, b) end)
  return zone_list_sorted
end

---Returns an array of `JumpZoneInfo` tables accessible to a given force from a given zone using
---certain parameters.
---@param zone AnyZoneType|SpaceshipType Zone of origin
---@param force LuaForce Force to which the capsule belongs
---@param stellar_reach uint Number of stellar jump zones to include if appropriate
---@param allow_undiscovered boolean Whether zones undiscovered by the force should be included
---@return JumpZoneInfo[]
function Zone.get_space_jumps(zone, force, stellar_reach, allow_undiscovered)
  local force_name = force.name
  local jump_zones = {}
  local forcedata = storage.forces[force_name]
  local homeworld_emergency_jump
  if forcedata and forcedata.homeworld_index then
    local homeworld = Zone.from_zone_index(forcedata.homeworld_index)
    homeworld_emergency_jump = {zone=homeworld, field="homeworld-emergency"}
  end

  if not Capsule.can_launch_capsule(force.name) then -- launch is locked
    return {homeworld_emergency_jump}
  end

  ---Returns the index of a zone within its parent zone.
  ---@param zone PlanetType|MoonType|AsteroidBeltType|OrbitType Zone to evaluate, _must_ have a parent
  ---@return uint? index
  local function relative_index_search(zone)
    for index, zone_check in pairs(zone.parent.children) do
      if zone == zone_check then return index end
    end
  end

  ---Inserts the farthest zone associated with a given planet or asteroid belt within a star system.
  ---@param target_zone PlanetType|AsteroidBeltType Zone to be evaluated
  ---@param field string Field to associate with zone
  ---@return JumpZoneInfo
  local function get_outermost_associated_jump_zone(target_zone, field)
    if target_zone.children and next(target_zone.children) then
      -- target_zone is a planet with moons; get its farthest moon
      return {zone=target_zone.children[#target_zone.children].orbit, field=field}
    elseif target_zone.orbit then
      -- target_zone is a planet without moons; get its orbit
      return {zone=target_zone.orbit, field=field}
    else
      -- target_zone is an asteroid belt
      return {zone=target_zone, field=field}
    end
  end

  ---Inserts a JumpZoneInfo table into a target table if visible to a given force.
  ---@param target_table JumpZoneInfo[] _Must_ be a table, even an empty one
  ---@param jump_zone JumpZoneInfo Jump zone data
  ---@param force_name string Force name
  local function insert_if_visible_to_force(target_table, jump_zone, force_name)
    if Zone.is_visible_to_force(jump_zone.zone, force_name) then
      table.insert(target_table, jump_zone)
    elseif allow_undiscovered then
      jump_zone.undiscovered = true
      table.insert(target_table, jump_zone)
    end
  end

  -- Return an empty table if zone is nil
  if not zone then return jump_zones end

  -- If zone has an orbit, include it as a valid jump zone
  if zone.orbit then
    insert_if_visible_to_force(jump_zones, {zone=zone.orbit, field="launch"}, force_name)
  end

  local solar_index, lunar_index, parent_star, parent_planet, stellar_origin

  if Zone.is_space(zone) and zone.parent then
    ---@cast zone -PlanetType, -MoonType
    if zone.parent.type == "planet" then  -- Handle planet orbits
      -- Include the planet that orbit is associated with
      insert_if_visible_to_force(jump_zones, {zone=zone.parent, field="land"}, force_name)
      if zone.parent.children and next(zone.parent.children) then
        if zone.parent.children[1].orbit then
          -- Insert the orbit of the first moon orbiting the planet
          insert_if_visible_to_force(jump_zones, {zone=zone.parent.children[1].orbit, field="planet-out"}, force_name)
        else
          insert_if_visible_to_force(jump_zones, {zone=zone.parent.children[1], field="planet-out"}, force_name)
        end
      end
      solar_index = relative_index_search(zone.parent)
      parent_star = Zone.get_star_from_child(zone)
    elseif zone.parent.type == "moon" then -- Handle moon orbits
      -- Include the moon that orbit is associated with
      insert_if_visible_to_force(jump_zones, {zone=zone.parent, field="land"}, force_name)
      lunar_index = relative_index_search(zone.parent)
      solar_index = relative_index_search(zone.parent.parent)
      parent_planet = Zone.get_planet_from_child(zone)
      parent_star = Zone.get_star_from_child(zone)
    elseif zone.type == "asteroid-belt" then -- Handle asteroid belts
      ---@cast zone AsteroidBeltType
      solar_index = relative_index_search(zone)
      parent_star = Zone.get_star_from_child(zone)
    elseif zone.parent.type == "star" then -- Handle star orbits
      ---@type PlanetType|AsteroidBeltType
      local first_star_child = zone.parent.children[1]
      if first_star_child.children and next(first_star_child.children) then
        -- Include orbit of the farthest moon of planet closest to star if that planet has moons
        insert_if_visible_to_force(jump_zones, {zone=first_star_child.children[#first_star_child.children].orbit, field="star-out"}, force_name)
      elseif first_star_child.orbit then
        -- Include the orbit of the planet (since it doesn't have any moons)
        insert_if_visible_to_force(jump_zones, {zone=first_star_child.orbit, field="star-out"}, force_name)
      else
        -- Include the zone directly if it's neither a planet or moon (making it an asteroid belt)
        insert_if_visible_to_force(jump_zones, {zone=first_star_child, field="star-out"}, force_name)
      end
    end
  end

  if solar_index then
    if lunar_index then
      -- Insert orbits of adjacent moons or planet orbit if this happens to be the planet's closest moon
      if lunar_index == 1 then
        insert_if_visible_to_force(jump_zones, {zone=parent_planet.orbit, field="planet-in-end"}, force_name)
      else
        insert_if_visible_to_force(jump_zones, {zone=parent_planet.children[lunar_index-1].orbit, field="planet-in"}, force_name)
      end
      if lunar_index < #parent_planet.children then
        insert_if_visible_to_force(jump_zones, {zone=parent_planet.children[lunar_index+1].orbit, field="planet-out"}, force_name)
      end
    end

    -- Handle farthest moons, asteroid belts, and orbits of planets that have no moons
    if (lunar_index and lunar_index == #parent_planet.children) -- furthest moon from planet
      or not Zone.get_planet_from_child(zone) -- i.e. if zone is an asteroid belt
      or not Zone.get_planet_from_child(zone).children -- i.e. if zone is planet orbit of a planet without moons
      or not next(Zone.get_planet_from_child(zone).children) then -- i.e. if zone is a planet orbit of a planet with zero moons
      if solar_index == 1 then
        -- Insert the star orbit if they are or are associated with the closest zone orbiting the star
        insert_if_visible_to_force(jump_zones, {zone=parent_star.orbit, field="star-in-end"}, force_name)
      else
        -- Since zone is not the closest zone to the star, insert an appropriate zone that's one hop closer to the star
        insert_if_visible_to_force(jump_zones, get_outermost_associated_jump_zone(parent_star.children[solar_index-1], "star-in"), force_name)
      end
      -- Insert appropriate zone one hop farther away from the star if this is not already the farthest of the star's children
      if solar_index < #parent_star.children then
        insert_if_visible_to_force(jump_zones, get_outermost_associated_jump_zone(parent_star.children[solar_index+1], "star-out"), force_name)
      else
        stellar_origin = zone -- zone is the furthest zone (or orbit) for that star system
      end
    end
  elseif zone.type == "spaceship" then
    ---@cast zone SpaceshipType
    local nearest_zone = Zone.find_nearest_zone(zone.space_distortion, zone.stellar_position, zone.star_gravity_well, zone.planet_gravity_well)
    if nearest_zone.orbit then nearest_zone = nearest_zone.orbit end
    insert_if_visible_to_force(jump_zones, {zone=nearest_zone, field="land"}, force_name)
  elseif not Zone.get_star_from_child(zone) then
    ---@cast zone -SpaceshipType
    stellar_origin = zone -- zone is either an asteroid field or the anomaly
  end

  if stellar_origin then
    local stellar_jump_list = {}
    local zone_addition, last_star_child

    for _, zone_check in pairs(storage.universe.stars) do
      if zone_check.children and next(zone_check.children) then last_star_child = zone_check.children[#zone_check.children] end
      if last_star_child then
        if last_star_child.children and next(last_star_child.children) then
          -- Get the orbit of the outermost moon
          zone_addition = last_star_child.children[#last_star_child.children].orbit
        else
          -- Get the orbit of the moonless planet or the asteroid belt (which would lack an orbit)
          zone_addition = last_star_child.orbit or last_star_child
        end
      else
        zone_addition = zone_check
      end
      if zone_addition and zone_addition ~= stellar_origin then
        table.insert(stellar_jump_list, zone_addition)
      end
      zone_addition = nil
    end

    for _, zone_check in pairs(storage.universe.space_zones) do
      if zone_check and zone_check ~= stellar_origin then
        table.insert(stellar_jump_list, zone_check)
      end
    end

    stellar_jump_list = Zone.sort_by_delta_v(stellar_origin, stellar_jump_list)

    if stellar_origin.type == "anomaly" or stellar_reach >= #stellar_jump_list then
      for _, valid_jump_zone in pairs(stellar_jump_list) do
        if valid_jump_zone.type == "asteroid-field" then
          ---@cast valid_jump_zone AsteroidFieldType
          insert_if_visible_to_force(jump_zones, {zone=valid_jump_zone, field="interstellar-other"}, force_name)
        else
          ---@cast valid_jump_zone -AsteroidFieldType
          insert_if_visible_to_force(jump_zones, {zone=valid_jump_zone, field="interstellar-system"}, force_name)
        end
      end
    elseif stellar_reach > 0 then
      local valid_jump_zone
      for i=1, stellar_reach do
        valid_jump_zone = stellar_jump_list[i]
        if valid_jump_zone.type == "asteroid-field" then
          ---@cast valid_jump_zone AsteroidFieldType
          insert_if_visible_to_force(jump_zones, {zone=valid_jump_zone, field="interstellar-other"}, force_name)
        else
          ---@cast valid_jump_zone -AsteroidFieldType
          insert_if_visible_to_force(jump_zones, {zone=valid_jump_zone, field="interstellar-system"}, force_name)
        end
      end
    end
  end

  -- Add force's homeworld
  if homeworld_emergency_jump then
    table.insert(jump_zones, homeworld_emergency_jump)
  end

  return jump_zones
end

---Obtains the localized string from a given jump zone based on its `field` property.
---@param jump_zone JumpZoneInfo Jump zone data
---@return LocalisedString
function Zone.space_jump_readout(jump_zone)
  -- jump_zone is a table of two variables: zone and field
  -- different fields result in different string formats

  -- ⮨⮩⮪⮫⮬⮭⮮⮯ ↥⤓
  -- ↥ launch
  -- ⤓ land
  -- ⮪ planet-out
  -- ⮫ planet-in
  -- ⮬ star-in
  -- ⮮ star-out
  -- ⤩ interstellar

  if jump_zone.undiscovered then
    return {"space-exploration.space_jump_undiscovered"}
  end


  if jump_zone.field == "launch" then
    return {"space-exploration.space_jump_launch", Zone.get_rich_text_icon(jump_zone.zone) .. " " .. jump_zone.zone.name}

  elseif jump_zone.field == "land" then
    return {"space-exploration.space_jump_land", Zone.get_rich_text_icon(jump_zone.zone) .. " " .. jump_zone.zone.name}


  elseif jump_zone.field == "planet-in-end" then
    return {"space-exploration.space_jump_planet_in_end", Zone.get_rich_text_icon(jump_zone.zone) .. " " .. jump_zone.zone.name, Zone.get_rich_text_icon(Zone.get_planet_from_child(jump_zone.zone)) .. " " .. Zone.get_planet_from_child(jump_zone.zone).name}

  elseif jump_zone.field == "planet-in" then
    return {"space-exploration.space_jump_planet_in", Zone.get_rich_text_icon(jump_zone.zone) .. " " .. jump_zone.zone.name, Zone.get_rich_text_icon(Zone.get_planet_from_child(jump_zone.zone)) .. " " .. Zone.get_planet_from_child(jump_zone.zone).name}

  elseif jump_zone.field == "planet-out" then
    return {"space-exploration.space_jump_planet_out", Zone.get_rich_text_icon(jump_zone.zone) .. " " .. jump_zone.zone.name, Zone.get_rich_text_icon(Zone.get_planet_from_child(jump_zone.zone)) .. " " .. Zone.get_planet_from_child(jump_zone.zone).name}


  elseif jump_zone.field == "star-in-end" then
    return {"space-exploration.space_jump_star_in_end", Zone.get_rich_text_icon(jump_zone.zone) .. " " .. jump_zone.zone.name, Zone.get_rich_text_icon(Zone.get_star_from_child(jump_zone.zone)) .. " " .. Zone.get_star_from_child(jump_zone.zone).name}

  elseif jump_zone.field == "star-in" then
    return {"space-exploration.space_jump_star_in", Zone.get_rich_text_icon(jump_zone.zone) .. " " .. jump_zone.zone.name, Zone.get_rich_text_icon(Zone.get_star_from_child(jump_zone.zone)) .. " " .. Zone.get_star_from_child(jump_zone.zone).name}

  elseif jump_zone.field == "star-out" then
    return {"space-exploration.space_jump_star_out", Zone.get_rich_text_icon(jump_zone.zone) .. " " .. jump_zone.zone.name, Zone.get_rich_text_icon(Zone.get_star_from_child(jump_zone.zone)) .. " " .. Zone.get_star_from_child(jump_zone.zone).name}


  elseif jump_zone.field == "interstellar-system" then
    return {"space-exploration.space_jump_interstellar_system", Zone.get_rich_text_icon(jump_zone.zone) .. " " .. jump_zone.zone.name, Zone.get_rich_text_icon(Zone.get_star_from_child(jump_zone.zone)) .. " " .. Zone.get_star_from_child(jump_zone.zone).name}

  elseif jump_zone.field == "interstellar-other" then
    return {"space-exploration.space_jump_interstellar_other", Zone.get_rich_text_icon(jump_zone.zone) .. " " .. jump_zone.zone.name}


  elseif jump_zone.field == "homeworld" then
    return {"space-exploration.space_jump_homeworld", Zone.get_rich_text_icon(jump_zone.zone) .. " " .. jump_zone.zone.name}

  elseif jump_zone.field == "homeworld-emergency" then
    return {"space-exploration.space_jump_emergency_burn", Zone.get_rich_text_icon(jump_zone.zone) .. " " .. jump_zone.zone.name}


  else
    return {"space-exploration.space_jump_invalid_flag", jump_zone.zone.name}
  end
end

---@param event EventData.on_runtime_mod_setting_changed Event data
function Zone.on_runtime_mod_setting_changed(event)
  if event.player_index and event.setting_type == "runtime-per-user" then
    local player_index = event.player_index
    local playerdata = get_make_playerdata(game.get_player(player_index))

    if event.setting == Zone.name_setting_dropdowns_hide_low_priority then
      playerdata.dropdowns_hide_low_priority_zones = settings.get_player_settings(player_index)[Zone.name_setting_dropdowns_hide_low_priority].value
    elseif event.setting == Zone.name_setting_dropdowns_priority_threshold then
      playerdata.dropdowns_priority_threshold =  settings.get_player_settings(player_index)[Zone.name_setting_dropdowns_priority_threshold].value
    end
  end
end
Event.addListener(defines.events.on_runtime_mod_setting_changed, Zone.on_runtime_mod_setting_changed)

---@param zone AnyZoneType|SpaceshipType
function Zone.build_tile_replacements(zone)
    -- replaces biome_collections in replace specifications with the full biome names
    --[[
  convert :
  biome_replacement = {
    {replace = {"all-dirt", "all-sand", "all-volcanic"}, with="sand-red"},
    {replace = {"all-vegetation", "all-frozen"}, with="vegetation-red"}
  }
  to
    {
      ["tile-from-1"] = "tile-to-1",
      ["tile-from-2"] = "tile-to-1",
    }
  ]]--
  if zone.biome_replacements then

    -- expand replacement collections
    local biome_replacements_expanded = {}
    for _, replacement in pairs(zone.biome_replacements) do
      local replace_biomes = {}
      for _, replace in pairs(replacement.replace) do
        if Zone.biome_collections[replace] then -- this is a collection name
          for _, biome_name in pairs(Zone.biome_collections[replace]) do
            if biome_name ~= replacement.with then -- don't replace to iteself
              table.insert(replace_biomes, biome_name)
            end
          end
        elseif replace ~= replacement.with then -- this is a biome name
          table.insert(replace_biomes, replace)
        end
      end
      table.insert(biome_replacements_expanded, {replace = replace_biomes, with = replacement.with})
    end
    -- biome_replacements_expanded now has all of the replace names being all biome names
    -- build tile map
    local tile_replacements = {}
    for _, replacement in pairs(biome_replacements_expanded) do
      local to_tiles = Zone.biome_tiles[replacement.with]
      local i = 0
      for _, replace in pairs(replacement.replace) do
        for _, replace_tile in pairs(Zone.biome_tiles[replace]) do
          tile_replacements[replace_tile] = to_tiles[(i % #to_tiles) + 1]
          i = i + 1
        end
      end
    end

    zone.tile_replacements = tile_replacements
  end

end

---Handles tile replacements for solid zones that require them.
---@param event EventData.on_chunk_generated Event data
function Zone.on_chunk_generated(event)
  local zone = Zone.from_surface(event.surface)

  -- Only proceed if zone is solid and has biome replacements that would be made
  if not (zone and Zone.is_solid(zone)) then return end
  ---@cast zone PlanetType|MoonType
  if not (zone.biome_replacements and next(zone.biome_replacements)) then return end

  local surface = event.surface
  local area = event.area
  local set_tiles = {} -- by tile name, array of positions, for the surface.set_tiles function
  local count = 0

  if not zone.tile_replacements then
    Zone.build_tile_replacements(zone)
  end

  for x = area.left_top.x, area.right_bottom.x - 1 do
    for y = area.left_top.y, area.right_bottom.y - 1 do
      local tile = surface.get_tile(x, y)
      local tile_name = tile.name

      if zone.tile_replacements[tile_name] then
        count = count + 1
        set_tiles[count] = {
            name = zone.tile_replacements[tile_name],
            position = {x, y}
        }
      end
    end
  end

  if count > 0 then
    surface.set_tiles(set_tiles, true, true, false)
    surface.destroy_decoratives{area=area}
    surface.regenerate_decorative(nil, {{x=math.floor((area.left_top.x+16)/32), y=math.floor((area.left_top.y+16)/32)}})
  end
end
Event.addListener(defines.events.on_chunk_generated, Zone.on_chunk_generated)

--Deep copies a zone table to be exported. Replaces any sub reference to a zone with the corresponding zone index
---@param zone AnyZoneType
---@return AnyZoneType zone
function Zone.deep_copy_zone(zone)
  local zone_table = {}
  for _, v in pairs(storage.zone_index) do
    zone_table[v] = true
  end
  local lookup_table = {}
  local function _copy(object)
    if type(object) ~= "table" then
      return object
    -- don't copy factorio rich objects
    elseif type(object) == "userdata" then
      return object
    elseif lookup_table[object] then
      return lookup_table[object]
    end
    local new_table = {}
    lookup_table[object] = new_table
    for index, value in pairs(object) do
      if zone_table[value] then
        --if referencing a zone, replace with a zone index
        new_table[index.."_index"] = value.index
      else
        new_table[_copy(index)] = _copy(value)
      end
    end
    return new_table
  end
  return _copy(zone)
end

---@param zone AnyZoneType|StarType
---@return AnyZoneType|StarType?
function Zone.export_zone(zone)
  if not zone then return end
  -- not safe to deepcopy
  -- make all object table references id references instead.
  local export_zone = Util.shallow_copy(zone)
  if export_zone.children then
    export_zone.child_indexes = {}
    for i, child in pairs(export_zone.children) do
      export_zone.child_indexes[i] = child.index
    end
    export_zone.children = nil
  end
  if export_zone.ruins then
    export_zone.ruins = {}
    for ruin_name, ruin in pairs(zone.ruins) do
      --only copy the 3 relevant values as anything else may be invalid entities
      export_zone.ruins[ruin_name] = {}
      local export_ruin = export_zone.ruins[ruin_name]
      export_ruin.name = ruin.name
      export_ruin.position = ruin.position
      export_ruin.zone_index = ruin.zone_index
    end
  end
  -- should be safe to deepcopy now
  export_zone = Zone.deep_copy_zone(export_zone)
  return export_zone
end

---@param enemy_base_setting AutoplaceControl
---@return number
local function enemy_base_setting_to_threat(enemy_base_setting)
  return math.max(0, math.min(1, enemy_base_setting.size / 3))  -- 0-1
end

---@param zone AnyZoneType|SpaceshipType
---@return number
function Zone.get_threat(zone)
  if Zone.is_solid(zone) then
    ---@cast zone PlanetType|MoonType
    if zone.is_homeworld and zone.surface_index then
      ---@cast zone PlanetType
      local surface = Zone.get_surface(zone)
      local mapgen = surface.map_gen_settings
      if mapgen.autoplace_controls["enemy-base"] and mapgen.autoplace_controls["enemy-base"].size then
        return enemy_base_setting_to_threat(mapgen.autoplace_controls["enemy-base"])
      end
    end
    if zone.controls and zone.controls["enemy-base"] and zone.controls["enemy-base"].size then
      local threat = enemy_base_setting_to_threat(zone.controls["enemy-base"])
      if Zone.is_biter_meteors_hazard(zone) then
        return math.max(threat, 0.01)
      end
      return threat
    end
  end
  return 0
end

---@param zone AnyZoneType
---@return string[]
function Zone.get_hazards(zone)
  local hazards = {}
  if Zone.is_biter_meteors_hazard(zone) then
    table.insert(hazards, "biter-meteors")
  end
  if zone.plague_used then
    table.insert(hazards, "plague-world")
  end
  if zone.tags and util.table_contains(zone.tags, "water_none") then
    table.insert(hazards, "waterless")
  end
  return hazards
end

---@param zone AnyZoneType
---@return boolean
function Zone.is_biter_meteors_hazard(zone)
  return zone.controls and zone.controls["se-vitamelange"] and zone.controls["se-vitamelange"].richness > 0
end

---@param zone AnyZoneType|SpaceshipType|AnomalyType
---@param force_name string
---@return int
function Zone.get_priority(zone, force_name)
  if storage.forces[force_name] then
    if zone.type ~= "spaceship" and storage.forces[force_name].zone_priorities and storage.forces[force_name].zone_priorities[zone.index] then
      ---@cast zone -SpaceshipType
      return storage.forces[force_name].zone_priorities[zone.index]
    end
    if zone.type == "spaceship" and storage.forces[force_name].spaceship_priorities and storage.forces[force_name].spaceship_priorities[zone.index] then
      ---@cast zone SpaceshipType
      return storage.forces[force_name].spaceship_priorities[zone.index]
    end
  end
  return 0
end

--- Get the original threat of the zone when it was first created, using tags and resource controls.
--- This ignores changes to threat done after creation, such as with plague or extinction.
---@param zone AnyZoneType
---@return number
function Zone.get_original_threat(zone)
  local enemy_base_setting
  if zone.tags then
    for _, tag in pairs(zone.tags) do
      if util.table_contains(Universe.enemy_tags, tag) then
        enemy_base_setting = table.deepcopy(Universe.control_settings_from_tag[tag]["enemy-base"])
        break
      end
    end
  end
  if not enemy_base_setting then
    enemy_base_setting = table.deepcopy(Universe.control_settings_from_tag["enemy_none"]["enemy-base"])
  end
  if zone.controls["se-vitamelange"] and zone.controls["se-vitamelange"].richness > 0 then
    -- min threat, they like the spice
    enemy_base_setting.frequency = math.max(enemy_base_setting.frequency,  0.5)
    enemy_base_setting.size = math.max(enemy_base_setting.size, 0.5)
    enemy_base_setting.richness = math.max(enemy_base_setting.richness, 0.5)
  end
  return enemy_base_setting_to_threat(enemy_base_setting)
end

---Called for each zone during universe creation. Should not change unless the universe is modified (e.g. gravity well changes).
---This does not include the `robot-attrition-factor` setting which *can* change, and is accounted for in Zone.get_bot_attrition
---@param zone AnyZoneType|SpaceshipType
function Zone.calculate_base_bot_attrition(zone)
  if zone then
    if zone.type == "spaceship" then
      ---@cast zone SpaceshipType
      zone.base_bot_attrition = 0 -- no attrition
    elseif zone.type == "anomaly" then
      ---@cast zone AnomalyType
      zone.base_bot_attrition = 10
    elseif Zone.is_solid(zone) then -- planet or moon
      ---@cast zone PlanetType|MoonType
      local enemy = Zone.get_original_threat(zone)
      local rate = 0.5 * (1 - enemy * 0.9)
      rate = rate + 0.5 * zone.radius / 10000
      if enemy == 0 then -- add a penalty to enemy free zones
        rate = rate + 10
      end
      zone.base_bot_attrition = rate
    else -- space
      ---@cast zone -SpaceshipType, -AnomalyType, -PlanetType, -MoonType
      local star_gravity_well = Zone.get_star_gravity_well(zone)
      local planet_gravity_well = Zone.get_planet_gravity_well(zone)
      local base_rate = star_gravity_well / 20 + planet_gravity_well / 200
      local rate = 10 * (0.01 + 0.99 * base_rate) -- 0-1
      zone.base_bot_attrition = rate
    end
  end
end

Zone.attrition_factor_setting = 1
if not settings.global["robot-attrition-factor"] then
  log("Warning: Robot Attrition not installed?")
else
  Zone.attrition_factor_setting = settings.global["robot-attrition-factor"].value
end

---Get the current bot attrition value for a zone. This accounts for the `robot-attrition-factor` setting.
---@param zone AnyZoneType|SpaceshipType
---@return uint bot_attrition
function Zone.get_bot_attrition(zone)
  if not zone.base_bot_attrition then
    game.print("[color=red]Error: Zone "..zone.name.." is missing a bot attrition value. Please report the issue.[/color]")
    return 1
  end
  if zone.name == "Nauvis" or zone.is_homeworld then
    ---@cast zone PlanetType
    return Zone.attrition_factor_setting -- Always equal to the attrition factor setting
  elseif zone.type == "anomaly" then
    ---@cast zone AnomalyType
    return zone.base_bot_attrition + 2 * Zone.attrition_factor_setting  -- anomalies are dangerous, give them an absolute increase
  else
    ---@cast zone -AnomalyType
    return zone.base_bot_attrition * (0.5 + 0.5 * Zone.attrition_factor_setting) -- Setting affects half of the attrition
  end
end

function Zone.rebuild_surface_index()
  storage.zones_by_surface = {}
  for _, zone in pairs(storage.zone_index) do
    if zone.surface_index then
      if game.get_surface(zone.surface_index) then
        storage.zones_by_surface[zone.surface_index] = zone
      else
        zone.surface_index = nil
      end
    end
  end
end

---Trims a given zone's surface, deleting any chunks that don't fall _entirely_ within the given
---bounds. This function prioritizes deleting anything out-of-bounds over preserving what's within
---bounds, so use with caution.
---@param zone AnyZoneType Zone to trim
---@param left integer Left margin, in tiles
---@param top integer Top margin, in tiles
---@param right integer Right margin, in tiles
---@param bottom integer Bottom margin, in tiles
function Zone.trim_surface_to_bounding_box(zone, left, top, right, bottom)
  local surface = Zone.get_surface(zone)
  if not surface then return end

  for chunk in surface.get_chunks() do
    if chunk.area.left_top.x < left or
        chunk.area.right_bottom.x > right or
        chunk.area.left_top.y < top or
        chunk.area.right_bottom.y > bottom then
      surface.delete_chunk(chunk --[[@as ChunkPosition]])
    end
  end
end

---@param zone AnyZoneType Zone to trim chart tags
---@param min_x number
---@param max_x number
---@param min_y number
---@param max_y number
---@return LuaCustomChartTag[]
function Zone.get_out_of_bounds_chart_tags(zone, min_x, max_x, min_y, max_y)
  local surface = Zone.get_surface(zone)
  if not surface then return {} end

  local chart_tags = {}

  for _, force in pairs(game.forces) do
    local existing_tags = force.find_chart_tags(surface)
    for _, tag in pairs(existing_tags) do
      local tag_position = tag.position
      if tag_position.x < min_x or tag_position.x > max_x or
         tag_position.y < min_y or tag_position.y > max_y then
          table.insert(chart_tags, tag)
      end
    end
  end

  return chart_tags
end

---@param zone AnyZoneType
---@param player_index uint unused
function Zone.trim_surface(zone, player_index)
  local surface = Zone.get_surface(zone)
  if not surface then return end

  ---@type string[] forces that should be protected from having their entities destroyed
  local protected_forces = table.deepcopy(SystemForces.protected_system_forces)

  -- Protect the ship before its been visited
  if zone.type == "anomaly" then table.insert(protected_forces, "ignore") end

  for force_name, _ in pairs(storage.forces) do
    if game.forces[force_name] and not SystemForces.is_system_force(force_name) then
      table.insert(protected_forces, force_name)
    end
  end

  local protected_entities = table.deepcopy(Ancient.vault_entrance_structures)
  table.insert(protected_entities, Ancient.name_gate_blocker)
  table.insert(protected_entities, Ancient.name_gate_blocker_void)
  table.insert(protected_entities, "crash-site-chest-2") --weapons cache
  for name, _ in pairs(Ancient.gate_fragments) do
    table.insert(protected_entities, name)
  end

  local min_x = 1000000
  local max_x = -1000000
  local min_y = 1000000
  local max_y = -1000000

  local entities = surface.find_entities_filtered{name = protected_entities}
  for _, entity in pairs(entities) do
    local b = entity.bounding_box
    min_x = min_x and math.min(min_x, b.left_top.x) or b.left_top.x
    min_y = min_y and math.min(min_y, b.left_top.y) or b.left_top.y
    max_x = max_x and math.max(max_x, b.right_bottom.x) or b.right_bottom.x
    max_y = max_y and math.max(max_y, b.right_bottom.y) or b.right_bottom.y
  end


  for chunk in surface.get_chunks() do
    if surface.count_entities_filtered{force = protected_forces, area = chunk.area, limit = 1} > 0 then
      min_x = min_x and math.min(min_x, chunk.area.left_top.x) or chunk.area.left_top.x
      min_y = min_y and math.min(min_y, chunk.area.left_top.y) or chunk.area.left_top.y
      max_x = max_x and math.max(max_x, chunk.area.right_bottom.x) or chunk.area.right_bottom.x
      max_y = max_y and math.max(max_y, chunk.area.right_bottom.y) or chunk.area.right_bottom.y
    end
  end

  local chunk_min_x = math.floor(min_x/32) -1
  local chunk_max_x = math.floor(max_x/32) +1
  local chunk_min_y = math.floor(min_y/32) -1
  local chunk_max_y = math.floor(max_y/32) +1

  local chunks_deleted = 0
  for chunk in surface.get_chunks() do
    if chunk.x < chunk_min_x
      or chunk.x > chunk_max_x
      or chunk.y < chunk_min_y
      or chunk.y > chunk_max_y then
        chunks_deleted = chunks_deleted + 1
        surface.delete_chunk(chunk)
    end
  end

  -- delete core seam chart tags that are now in ungenerated chunks
  for _, chart_tag in ipairs(Zone.get_out_of_bounds_chart_tags(zone, min_x, max_x, min_y, max_y)) do
    if chart_tag.icon and chart_tag.icon.name == mod_prefix .. "core-seam" then
      chart_tag.destroy()
    end
  end

  rendering.draw_rectangle{
    color = {0,0,1},
    widht = 1,
    filled = false,
    left_top = {min_x, min_y},
    right_bottom = {max_x, max_y},
    surface = surface,
    time_to_live = 60
  }
  rendering.draw_rectangle{
    color = {1,0,0},
    widht = 1,
    filled = false,
    left_top = {chunk_min_x*32, chunk_min_y*32},
    right_bottom = {(chunk_max_x + 1)*32, (chunk_max_y + 1)*32},
    surface = surface,
    time_to_live = 60
  }
  game.print({"space-exploration.trim-zone-results", chunks_deleted, Zone.get_print_name(zone),
    chunk_min_x, chunk_max_x, chunk_min_y, chunk_max_y})
  --game.print("Deleted "..chunks_deleted.." from "..zone.name ..". Trimmed X ["..chunk_min_x.." to "..chunk_max_x.."] Y ["..chunk_min_y.." to "..chunk_max_y.."]")

end

---Deletes a surface associated with a zone after ensuring no player entities exist on that surface.
---@param zone AnyZoneType|SpaceshipType Zone to be deleted
---@param player_index? uint Index of player requesting the deletion
---@param ignore_entities_from_force? string Name of a force. Entities from this force will not prevent the deletion of the surface.
---@return boolean success If we successfully deleted the surface (or if it already had no surface)
function Zone.delete_surface(zone, player_index, ignore_entities_from_force)
  local player = player_index and game.get_player(player_index) or nil

  local fail_message
  if zone.surface_index == 1 then
    fail_message = {"space-exploration.delete-zone-fail-nauvis"}
  elseif zone.is_homeworld then
    fail_message = {"space-exploration.delete-zone-fail-homeworld"}
  elseif zone.type == "anomaly" then
    ---@cast zone AnomalyType
    fail_message = {"space-exploration.delete-zone-fail-anomaly"}
  elseif zone.type == "spaceship" then
    ---@cast zone SpaceshipType
    fail_message = {"space-exploration.delete-zone-fail-spaceship"}
  elseif not zone.surface_index then
    fail_message = {"space-exploration.delete-zone-fail-no-surface"}
  end
  if fail_message then
    if player then player.print(fail_message) end
    return false
  end

  local surface = Zone.get_surface(zone)
  if not surface then -- Already no surface
    zone.surface_index = nil
    Zone.rebuild_surface_index()
    return true
  end

  -- Explicitly check for player presence, abort if found.
  -- Looping through players is easier than searching every vehicle.
  local surface_index = surface.index
  for _, game_player in pairs(game.players) do
    local character = player_get_character(game_player)
    if character and character.surface_index == surface_index then
      game_player.print({"space-exploration.delete-surface-fail-players", Zone.get_print_name(zone)})
      return false
    end
  end

  -- Count entities belonging to player forces, limit=1 because we only care if nonzero
  local protected_forces = get_player_forces()
  table.insert(protected_forces, "friendly")
  table.insert(protected_forces, "capture")
  if ignore_entities_from_force then
    util.remove_from_table(protected_forces, ignore_entities_from_force)
  end
  local count_entities = surface.count_entities_filtered{
    force=protected_forces,
    type = {"character", "electric-pole", "container", "logistic-container",
          "car", "spider-vehicle", "locomotive", "cargo-wagon", "fluid-wagon", "artillery-wagon"},
    limit=1
  }

  if count_entities > 0 then
    if player then player.print({"space-exploration.delete-surface-fail-entities", Zone.get_print_name(zone)}) end
    return false
  end

  local event = {
    player_index = player_index,
    surface_index = surface.index,
    zone_index = zone.index,
    zone_name = zone.name
  }

  -- Run `space_exploration_delete_surface` functions in other mods' remote interfaces
  for interface, functions in pairs(remote.interfaces) do
    if functions["space_exploration_delete_surface"] then
      ---@type table<string, boolean|LocalisedString|string>
      local result = remote.call(interface, "space_exploration_delete_surface", event)
      if type(result) == "table" and result.allow_delete == false then
        if player and (type(result.message) == "table" or type(result.message) == "string") then
          player.print(result.message)
          log("Deletion of surface of " .. zone.name .. " was stopped by " .. interface)
        end
        return false
      end
    end
  end

  -- All checks passed, surface will be deleted
  log("Deleting surface for zone: " .. zone.name)

  -- Find all players viewing that surface and teleport their controller to their character or their homeworlds
  for _, player in pairs(game.connected_players) do
    if player.surface == surface then
      if player.character then
        player.teleport( player.character.position, player.character.surface)
      else
        local playerdata = get_make_playerdata(player)
        if playerdata.character and playerdata.character.valid then
          player.teleport( playerdata.character.position, playerdata.character.surface)
        else
          local force = player.force
          local home_zone
          if storage.forces[force.name] and storage.forces[force.name].homeworld_index then
            home_zone = Zone.from_zone_index(storage.forces[force.name].homeworld_index)
            ---@cast home_zone PlanetType
          end
          if not home_zone then home_zone = Zone.get_default() end
          player.teleport({0,0}, Zone.get_make_surface(home_zone))
        end
      end
    end
  end

  -- Remove zone from meteor zones
  storage.meteor_zones[zone.index] = nil

  -- Delete the surface
  game.delete_surface(surface)
  Zone.clean_global_after_surface_deletion(zone)
  zone.deleted_surface = {tick = game.tick, player_index = player_index}
  Zone.rebuild_surface_index()
  return true
end

---Sets the solar multiplier of a newly created surface that is not associated with an SE zone.
---@param event EventData.on_surface_created Event data
function Zone.on_surface_created(event)
  local zone = Zone.from_surface_index(event.surface_index)
  if not zone then
    game.get_surface(event.surface_index).solar_power_multiplier = Zone.solar_multiplier * 0.5
  end
end
Event.addListener(defines.events.on_surface_created, Zone.on_surface_created)

---@param event EventData.on_research_finished Event data
function Zone.on_research_finished(event)

  local force = event.research.force
  local source = {"", "[img=item/se-space-telescope] ", {"space-exploration.telescope-data-analysis"}}

  if event.research.name == Zone.name_tech_discover_random then
    local dicovered_something = Zone.discover_next_research(force.name, source, false)
    if not dicovered_something then
      force.print({"space-exploration.tech-discovered-nothing"})
    end
  elseif  event.research.name == Zone.name_tech_discover_targeted then
    local dicovered_something = Zone.discover_next_research(force.name, source, true)
    if not dicovered_something then
      force.print({"space-exploration.tech-discovered-nothing"})
    end
  elseif  event.research.name == Zone.name_tech_discover_deep then
    local dicovered_something = Zone.discover_next_research_deep_space(force.name, source, false)
    if not dicovered_something then
      force.print({"space-exploration.tech-deep-discovered-nothing"})
    end
  end
end
Event.addListener(defines.events.on_research_finished, Zone.on_research_finished)

---Deletes solid zone surfaces that are _entirely_ made up of out-of-map tiles and were previously
---deleted. Deletes chunks in space zones that have out-of-map tiles, and deletes the surfaces they
---belong to if no remaining properly generated chunks are found.
function Zone.fix_out_of_map_tiles()
  for _, zone in pairs(storage.zones_by_name) do
    local surface = Zone.get_surface(zone)

    if surface then
      if Zone.is_solid(zone) and zone.deleted_surface then
        ---@cast zone PlanetType|MoonType
        local chunk_count = 0
        local contains_other_tiles = false

        for chunk in surface.get_chunks() do
          if surface.count_tiles_filtered{name="out-of-map", area=chunk.area} < 1024 then
            contains_other_tiles = true
            break
          end
          chunk_count = chunk_count + 1
        end
        if not contains_other_tiles then
          log("Zone.fix_out_of_map_tiles: All " .. chunk_count .. " chunks in " .. zone.name .. " (" .. zone.type .. ") found to have only out-of-map tiles" )
          Zone.delete_surface(zone)
        end
      elseif Zone.is_space(zone) and zone.type ~= "spaceship" then
        ---@cast zone -SpaceshipType
        ---@cast zone -PlanetType, -MoonType
        local chunks_checked, chunks_deleted = 0, 0
        for chunk in surface.get_chunks() do
            local count = surface.count_tiles_filtered{
                name="out-of-map", area=chunk.area, limit=1}
            if count > 0 and surface.count_entities_filtered{area=chunk.area, limit=1} == 0 then
                surface.delete_chunk(chunk)
                chunks_deleted = chunks_deleted + 1
            end
            chunks_checked = chunks_checked + 1
        end
        log("Zone.fix_out_of_map_tiles: Deleted " .. chunks_deleted .. "/" .. chunks_checked .. " chunks from " .. zone.name .. " (" .. zone.type .. ")")
        if zone.deleted_surface and chunks_checked == chunks_deleted then
          Zone.delete_surface(zone)
        end
      end
    end
  end
end

---@param zone AnyZoneType|StarType|SpaceshipType
function Zone.zone_fix_all_tiles(zone) -- or spaceship
  -- debug command
  --/c p = game.player po = p.position for x = -5,5 do for y = -5,5 do p.surface.set_tiles{{name = "dirt-1", position = {x+po.x, y=y+po.y}}} end end
  local surface = Zone.get_surface(zone)
  if surface and (not is_testing_surface(surface)) then
    if Zone.is_space(zone) then
      ---@cast zone -PlanetType, -MoonType
      if zone.type ~= "spaceship" or zone.on_own_surface then
        -- remove planet tiles
        local tiles = surface.find_tiles_filtered{
          collision_mask = storage.named_collision_masks.planet_collision_layer
        }
        local set_tiles = {}
        for _, tile in pairs(tiles) do
          if not Util.table_contains(tiles_allowed_in_space, tile.name) then
            -- remove the tile
            table.insert(set_tiles, {name = name_space_tile, position = tile.position})
            surface.set_hidden_tile(tile.position, nil)
          end
        end

        if next(set_tiles) then
          surface.set_tiles(
            set_tiles,
            true, -- corect tiles
            true, -- remove_colliding_entities
            true, -- remove_colliding_decoratives
            true -- raise_event
          )
          log("Zone.zone_fix_all_tiles: " .. zone.type.." " .. zone.name.." is_space "..#set_tiles.." tiles changed surface_index "..surface.index.." surface_name " .. surface.name)
        end
      else
        -- nothing to do if anchored
        --log("Zone.zone_fix_all_tiles: " .. zone.type.." " .. zone.name.." anchored surface_index "..surface.index.." surface_name " .. surface.name)
      end
    else
      ---@cast zone PlanetType|MoonType
      -- remove space tiles
      local tiles = surface.find_tiles_filtered{
        collision_mask = storage.named_collision_masks.space_collision_layer
      }
      local set_tiles = {}
      for _, tile in pairs(tiles) do
        if not Util.table_contains(Spaceship.names_spaceship_floors, tile.name) then -- spacehip floor is allowed
          -- remove the tile
          table.insert(set_tiles, {name = "nuclear-ground", position = tile.position})
          surface.set_hidden_tile(tile.position, nil)
        end
      end

      if next(set_tiles) then
        surface.set_tiles(
          set_tiles,
          true, -- corect tiles
          true, -- remove_colliding_entities
          true, -- remove_colliding_decoratives
          true -- raise_event
        )
        log("Zone.zone_fix_all_tiles: " .. zone.type.." " ..zone.name.." is_land "..#set_tiles.." tiles changed surface_index "..surface.index.." surface_name " .. surface.name)
      end

    end
  end
end

function Zone.zones_fix_all_tiles()
  for _, zone in pairs(storage.zone_index) do
    Zone.zone_fix_all_tiles(zone)
  end
  for _, spaceship in pairs(storage.spaceships) do
    Zone.zone_fix_all_tiles(spaceship)
  end
end

---Sets a given zone as the homeworld of a given force. Only planets can be set as homeworlds.
---@param data table Arguments can include zone_name, match_nauvis_seed, and reset_surface
---@return PlanetType?
function Zone.set_zone_as_homeworld(data)
  local zone = Zone.from_name(data.zone_name)
  local nauvis = Zone.from_name("Nauvis") --[[@as PlanetType]]
  if not zone then
    game.print("No zone found")
  else
    if zone.type ~= "planet" then
      ---@cast zone -PlanetType
      game.print("Zone type must be planet, selected zone is: " .. zone.type)
      return
    else
      ---@cast zone PlanetType
      zone.is_homeworld = true
      zone.inflated = true
      zone.resources = {}
      zone.ticks_per_day = 25000
      zone.fragment_name = "se-core-fragment-omni"
      zone.radius = nauvis.radius

      local nauvis_map_gen = table.deepcopy(game.get_surface(1).map_gen_settings)

      if not zone.original_seed then
        zone.original_seed = zone.seed
      end
      if data.match_nauvis_seed then
        zone.seed = nauvis_map_gen.seed
      else
        nauvis_map_gen.seed = zone.seed
      end

      local surface = Zone.get_surface(zone)
      if surface and data.reset_surface ~= false then
        surface.map_gen_settings = nauvis_map_gen
        surface.clear()
      else
        surface = Zone.get_make_surface(zone)
        surface.map_gen_settings = nauvis_map_gen
      end

      UniverseHomesystem.make_validate_homesystem(zone)
      storage.resources_and_controls_compare_string = nil -- force udpate resources
      Universe.load_resource_data()

      -- Calculate or recalculate all bot attritions of the system (because make_validate_homesystem may have created some moons/planets/belts).
      local star = zone.parent
      for _, child in pairs(star.children) do
         -- planet or belt
        if not child.controls then
          Universe.apply_zone_resource_assignments(child)
        end
        Zone.calculate_base_bot_attrition(child)
        if child.orbit then
          if not child.orbit.controls then
            Universe.apply_zone_resource_assignments(child.orbit)
          end
          Zone.calculate_base_bot_attrition(child.orbit)
        end
        if child.children then
          for _, moon in pairs(child.children) do
            if not moon.controls then
              Universe.apply_zone_resource_assignments(moon)
            end
            if not moon.orbit.controls then
              Universe.apply_zone_resource_assignments(moon.orbit)
            end
            Zone.calculate_base_bot_attrition(moon)
            Zone.calculate_base_bot_attrition(moon.orbit)
          end
        end
      end

      surface.request_to_generate_chunks({0,0}, 4)
      surface.force_generate_chunk_requests()

      if settings.startup[mod_prefix.."spawn-small-resources"].value then
        Zone.spawn_small_resources(surface)
      end

      CoreMiner.reset_seams(zone)

    end
  end

  return Zone.export_zone(Zone.from_name(data.zone_name))
end

---@param surface LuaSurface
function Zone.spawn_small_resources(surface)

  local seed = surface.map_gen_settings.seed
  local autoplace_controls = surface.map_gen_settings.autoplace_controls
  local rng = game.create_random_generator(seed)
  -- The starting resourecs of the map generation are inconsistent and spread out.
  -- Add some tiny patches to reduce the amount of running around at the start.
  -- We only care about super-early game, so just iron, copper, stone, and coal.
  -- If there are other resources added to the game then the naturally spawned resources will have to do for now.
  -- These resources are not designed to replace the normal starting resources at all.
  local valid_position_search_range = 256
  local cluster_primary_radius = 50 -- get away from crash site
  local cluster_secondary_radius = 25
  local resources = {}
  if    prototypes.entity["iron-ore"]
    and autoplace_controls["iron-ore"]
    and autoplace_controls["iron-ore"].size > 0
  then
    table.insert(resources, { name = "iron-ore", tiles = 200, amount = 100000})
  end
  if    prototypes.entity["copper-ore"]
    and autoplace_controls["copper-ore"]
    and autoplace_controls["copper-ore"].size > 0
  then
    table.insert(resources, { name = "copper-ore", tiles = 150, amount = 80000})
  end
  if    prototypes.entity["stone"]
    and autoplace_controls["stone"]
    and autoplace_controls["stone"].size > 0
  then
    table.insert(resources, { name = "stone", tiles = 150, amount = 80000})
  end
  if    prototypes.entity["coal"]
    and autoplace_controls["coal"]
    and autoplace_controls["coal"].size > 0
  then
    table.insert(resources, { name = "coal", tiles = 150, amount = 80000})
  end

  local cluster_orientation = rng()
  local secondary_orientation = rng()
  local cluster_position = Util.orientation_to_vector(cluster_orientation, cluster_primary_radius)
  surface.request_to_generate_chunks(cluster_position, 4)
  surface.force_generate_chunk_requests()

  Log.debug("Spawning small resources at [gps="..math.floor(cluster_position.x)..","..math.floor(cluster_position.y).."]")
  local closed_tiles = {} -- 2d disctionary
  local open_tiles = {} -- 1d array
  ---@param position MapPosition.0
  local function close_tile(position)
    closed_tiles[position.x] = closed_tiles[position.x] or {}
    closed_tiles[position.x][position.y] = true
  end
  ---@param set MapPosition.0[]
  ---@param position MapPosition.0
  local function open_tile(set, position) -- don't open if closed
    if not (closed_tiles[position.x] and closed_tiles[position.x][position.y]) then
      table.insert(set, position)
      close_tile(position)
    end
  end
  ---@param set MapPosition.0[]
  ---@param position MapPosition.0
  local function open_neighbour_tiles(set, position)
    open_tile(set, Util.vectors_add(position, {x=0,y=-1}))
    open_tile(set, Util.vectors_add(position, {x=1,y=0}))
    open_tile(set, Util.vectors_add(position, {x=0,y=1}))
    open_tile(set, Util.vectors_add(position, {x=-1,y=0}))
  end
  for i, resource in pairs(resources) do
    resource.orientation = secondary_orientation + rng()
    local offset = Util.orientation_to_vector(resource.orientation, rng(cluster_secondary_radius/2, cluster_secondary_radius))
    local position = Util.tile_to_position(Util.vectors_add(offset, cluster_position))
    local valid = surface.find_non_colliding_position(resource.name, position, valid_position_search_range, 1, true)
    if not valid then Log.debug("no valid position found") end
    resource.start_point = surface.find_non_colliding_position(resource.name, position, valid_position_search_range, 1, true) or position
    resource.open_tiles = {resource.start_point}
    resource.entities = {}
    resource.amount_placed = 0
  end
  local continue = true
  local repeats = 0
  while continue and repeats < 1000 do
    repeats = repeats + 1
    continue = false
    for _, resource in pairs(resources) do
      --if #resource.entities < resource.tiles then
      if resource.amount_placed < resource.amount then
        continue = true
        local try_tile
        if next(resource.open_tiles) then
          local choose = rng(#resource.open_tiles)
          try_tile = resource.open_tiles[choose]
          close_tile(try_tile)
        end
        if not try_tile then -- handle tiny island case
          try_tile = resource.start_point
        end
        local position = surface.find_non_colliding_position(resource.name, try_tile, valid_position_search_range, 1, true)
        if not position then -- exit
          resource.amount_placed = resource.amount
          log("Space Exploration failed to place starting resource, no valid positions in range. [".. resource.name.."]")
        else
          close_tile(try_tile)
          close_tile(position)
          local remaining = resource.amount - resource.amount_placed
          local amount = math.ceil(math.min( remaining * (0.01 + rng() * 0.005) + 100 + rng() * 100, remaining))
          resource.amount_placed = resource.amount_placed + amount
          table.insert(resource.entities, surface.create_entity{name = resource.name, position=position, amount=amount, enable_tree_removal=true, snap_to_tile_center =true})
          --Log.debug("Starting resource entity created "..resource.name.." ".. position.x.." "..position.y)
          open_neighbour_tiles(resource.open_tiles, position)
        end
      end
    end
  end

end

---Iterates over every game surface, and if it's part of a zone, creates an `inhabited_chunks`
---table that it populates with positions of chunks that have eletric poles, assembling machines,
---or ammo turrets.
function Zone.create_inhabited_chunks()
  for _, surface in pairs(game.surfaces) do
    local zone = Zone.from_surface(surface)

    if zone and zone.type ~= "spaceship" and not zone.inhabited_chunks then
      ---@cast zone -SpaceshipType
      zone.inhabited_chunks = {}

      local entities = surface.find_entities_filtered{
        type = {"electric-pole", "assembling-machine", "ammo-turret"},
        force=get_player_forces()
      }
      for __, entity in pairs(entities) do
        local chunks = Zone.get_chunks_from_bounding_box(entity.bounding_box)

        for key, chunk in pairs(chunks) do
          if not zone.inhabited_chunks[key] then zone.inhabited_chunks[key] = chunk end
        end
      end
    end
  end
end

---Returns an array containing the chunk or chunks that intersect a given BoundingBox.
---@param box BoundingBox Bounding box of the entity of interest
---@return table<string, ChunkPosition> chunks
function Zone.get_chunks_from_bounding_box(box)
  local vertices, chunks = {}, {}

  -- Get the four vertices of the bounding box
  vertices[1] = {x=box.left_top.x, y=box.left_top.y}
  vertices[2] = {x=box.right_bottom.x, y=box.left_top.y}
  vertices[3] = {x=box.right_bottom.x, y=box.right_bottom.y}
  vertices[4] = {x=box.left_top.x, y=box.right_bottom.y}

  --Rotate vertices if an orientation is provided
  if box.orientation then
    local angle = box.orientation * 2 * math.pi
    local origin_x = box.left_top.x + ((box.right_bottom.x - box.left_top.x) / 2)
    local origin_y = box.left_top.y + ((box.right_bottom.y - box.left_top.y) / 2)

    for _, vertex in pairs(vertices) do
      local x, y = vertex.x-origin_x, vertex.y-origin_y
      vertex.x = x*math.cos(angle) - y*math.sin(angle) + origin_x
      vertex.y = x*math.sin(angle) + y*math.cos(angle) + origin_y
    end
  end

  -- Collect all the unique chunks that the vertices are positioned in
  for _, vertex in pairs(vertices) do
    local chunk_x = math.floor(vertex.x / 32)
    local chunk_y = math.floor(vertex.y / 32)

    local key = chunk_x .. "/" .. chunk_y
    if not chunks[key] then chunks[key] = {x=chunk_x, y=chunk_y} end
  end

  return chunks
end

---Returns an array containing the chunk coordinates that compose the full planet
---@param zone SolidBodyType
---@return ChunkPosition[]? chunks
function Zone.get_all_chunk_positions(zone)
  if not zone.radius then return end
  local chunks = {}

  -- We consider the horizontal line between chunks, starting at the top one
  -- e.g. for a planet of radius 68, that starting line would be y=-64
  local bottom_of_top_chunk = - (zone.radius - (zone.radius % 32))

  -- For each horizontal line between chunks
  -- We also do the bottom half of the circle at the same time since planets are symmetrical and centered on the origin
  for y = bottom_of_top_chunk, 0, 32 do
    -- Coordinates of a circle: x^2 + y^2 = r^2
    -- which gives us x = +/- sqrt(r^2 - y^2)
    local x = (zone.radius^2 - y^2) ^ 0.5
    local left_chunk_x = - math.floor(x / 32) - 1
    local right_chunk_x = math.floor(x / 32)

    -- Top half of the circle, we add the chunks *above* the y line we are considering
    -- Bottom half of the circle, we add the chunks *below* the y line we are considering
    -- (Both will be done for y == 0)
    local chunk_y_top_half = math.floor(y / 32) - 1
    local chunk_y_bottom_half = math.floor(- y / 32)

    for chunk_x=left_chunk_x, right_chunk_x do
      table.insert(chunks, {x=chunk_x, y=chunk_y_top_half})
      table.insert(chunks, {x=chunk_x, y=chunk_y_bottom_half})
    end
  end

  return chunks
end

---Checks whether all chunks of a zone have been generated
---@param zone AnyZoneType
---@return boolean
function Zone.is_every_chunk_generated(zone)
  if not zone.radius then return false end -- Zones without radius are infinite

  local surface = Zone.get_surface(zone)
  for _, chunk_position in pairs(Zone.get_all_chunk_positions(zone)) do
    if not surface.is_chunk_generated(chunk_position) then
      return false
    end
  end

  return true
end

---Verifies zone is fully generated and hostiles are cleared, prints messages, lowers threat if needed.
---Called when clicking the "Confirm hostile extinction" button in Universe Explorer
---@param zone AnyZoneType
---@param player_index uint Player that called this.
function Zone.confirm_extinction(zone, player_index)
  if not zone.radius then return end
  if not zone.surface_index then return end

  local surface = Zone.get_surface(zone)
  local player = game.get_player(player_index)
  local enemy = surface.find_entities_filtered{
    force = enemy_forces(player.force),
    type = {"unit-spawner", "turret"},
    limit = 1
  }[1]
  if enemy then
    player.print{"space-exploration.confirm-extinction-failure-not-fully-extinct", Zone.get_print_name(zone), "[gps="..math.floor(enemy.position.x)..","..math.floor(enemy.position.y)..","..surface.name.."]"}
    return
  end

  if not Zone.is_every_chunk_generated(zone) then
    player.print{"space-exploration.confirm-extinction-failure-not-fully-generated", Zone.get_print_name(zone)}
    return
  end

  -- Success!
  zone.hostiles_extinct = true
  zone.controls["enemy-base"] = {frequency = 1, size = 0, richness = 0}
  local map_gen_settings = surface.map_gen_settings
  map_gen_settings.autoplace_controls["enemy-base"] = {frequency = 1, size = 0, richness = 0}
  surface.map_gen_settings = map_gen_settings

  for _, connected_player in pairs(game.connected_players) do
    if Zonelist.get(connected_player) then
      Zonelist.update_zone_in_list(connected_player, zone)
      Zonelist.update(connected_player)
    end
    MapView.gui_update(connected_player)
  end

  if Zone.is_biter_meteors_hazard(zone) then
    player.force.print{"space-exploration.confirm-extinction-success-biter-meteors", Zone.get_print_name(zone)}
  else
    player.force.print{"space-exploration.confirm-extinction-success", Zone.get_print_name(zone)}
  end
end

---Adds chunk position to `zone.inhabited_chunks` upon building an electric pole, assembling
---machine, or ammo turret, if not already present.
---@param event EntityCreationEvent Event data
function Zone.on_entity_created(event)
  local entity = event.entity
  if not entity.valid then return end
  if entity.type ~= "electric-pole" and
    entity.type ~= "assembling-machine" and
    entity.type ~= "ammo-turret" then
    return
  end

  -- Abort if entity surface is not part of a zone or belongs to a spaceship (in flight)
  local zone = Zone.from_surface(entity.surface)
  if not zone or zone.type == "spaceship" then return end
  ---@cast zone -SpaceshipType

  -- Abort if this is not a player force
  if not is_player_force(entity.force.name) then return end

  zone.inhabited_chunks = zone.inhabited_chunks or {}

  -- Add each chunk to `zone.inhabited_chunks` if it doens't exist
  local chunks = Zone.get_chunks_from_bounding_box(entity.bounding_box)
  for key, chunk in pairs(chunks) do
    if not zone.inhabited_chunks[key] then zone.inhabited_chunks[key] = chunk end
  end
end
Event.addOnEntityCreatedListeners(Zone.on_entity_created)

---Searches the chunk in which the electric pole, assembling machine, or ammo turret were removed
---and deletes the chunk reference from `zone.inabited_chunks` if no other entities are found.
---@param event EntityRemovalEvent Event data
function Zone.on_entity_removed(event)
  local entity = event.entity
  if not entity.valid then return end
  if entity.type ~= "electric-pole" and
    entity.type ~= "assembling-machine" and
    entity.type ~= "ammo-turret" then
    return
  end

  -- Abort if entity surface is not part of a zone or belongs to a spaceship (in flight)
  local zone = Zone.from_surface(entity.surface)
  if not zone or zone.type == "spaceship" or not zone.inhabited_chunks then return end
  ---@cast zone -SpaceshipType

  -- Abort if this is not a player force
  if not is_player_force(entity.force.name) then return end

  local chunks = Zone.get_chunks_from_bounding_box(entity.bounding_box)

  for key, chunk in pairs(chunks) do
    local count = entity.surface.count_entities_filtered{
      type = {"electric-pole", "assembling-machine", "ammo-turret"},
      area = {
        left_top = {x=chunk.x*32, y=chunk.y*32},
        right_bottom = {x=(chunk.x+1)*32, y=(chunk.y+1)*32}
      },
      limit=2
    }

    -- Removed entity still gets counted by game
    if count <= 1 then zone.inhabited_chunks[key] = nil end
  end
end
Event.addOnEntityRemovedListeners(Zone.on_entity_removed)

---@param zone AnyZoneType|SpaceshipType
function Zone.clean_global_after_surface_deletion(zone)
  zone.surface_index = nil

  local surface_name
  if zone.type == "spaceship" then
    ---@cast zone SpaceshipType
    surface_name = Spaceship.get_own_surface(zone).name
  else
    ---@cast zone -SpaceshipType
    surface_name = zone.name
  end
  if storage.spaceship_clamps_by_surface[surface_name] then
    for unit_number, _clamp in pairs(storage.spaceship_clamps_by_surface[surface_name]) do
      storage.spaceship_clamps[unit_number] = nil
    end
    storage.spaceship_clamps_by_surface[surface_name] = nil
  end

  if zone.type ~= "spaceship" then
    -- spaceships cannot have launch or landing pads anyway
    ---@cast zone -SpaceshipType
    zone.inhabited_chunks = nil
    zone.meteor_defences = {}
    zone.meteor_point_defences = {}

    for force_name, forcedata in pairs(storage.forces) do
      local zone_assets = Zone.get_force_assets(force_name, zone.index)
      for _launch_pad_name, launch_pads in pairs(zone_assets.rocket_launch_pad_names) do
        for unit_number, _launch_pad in pairs(launch_pads) do
          storage.rocket_launch_pads[unit_number] = nil
        end
      end
      for _landing_pad_name, landing_pads in pairs(zone_assets.rocket_landing_pad_names) do
        for unit_number, _landing_pad in pairs(landing_pads) do
          storage.rocket_landing_pads[unit_number] = nil
        end
      end
      forcedata.zone_assets[zone.index] = {
        rocket_launch_pad_names = {},
        rocket_landing_pad_names = {},
      }
    end
  end

  if zone.energy_transmitters then
    for unit_number, _transmitter in pairs(zone.energy_transmitters) do
      storage.energy_transmitters[unit_number] = nil
    end
    zone.energy_transmitters = nil
  end

  -- Delivery cannons, space elevators, and anchored spaceships will take care of themselves through their on_tick

end

---Deletes `inhabited_chunks` table since it's no longer accurate.
---@param event EventData.on_surface_deleted Event data
function Zone.on_surface_deleted(event)
  local zone = Zone.from_surface_index(event.surface_index)
  if zone then Zone.clean_global_after_surface_deletion(zone) end
end
Event.addListener(defines.events.on_surface_deleted, Zone.on_surface_deleted)

---Returns a shallower version of the zone table, which only contains the names of other zones and not references to their table
---Useful for using serpent.block and serpent.line
---@param zone AnyZoneType
function Zone.shallow_table(zone)
  local shallow_table = table.deepcopy(zone)

  if zone.children then
    local children_names = {}
    for _, child in pairs(zone.children) do
      table.insert(children_names, child.name)
    end
    shallow_table.children = children_names
  end

  if zone.parent then
    shallow_table.parent = zone.parent.name
  end

  if zone.orbit then
    shallow_table.orbit = zone.orbit.name
  end

  return shallow_table
end

---@param zone AnyZoneType
---@return LocalisedString
function Zone.get_default_localised_name_for_surface(zone)
  return {"space-exploration.simple-a-b-space", Zone.get_rich_text_icon(zone), zone.name}
end

---Resets the localised names of all surfaces belonging to a zone
function Zone.reset_localised_names_of_zone_surfaces()
  for _, surface in pairs(game.surfaces) do
    local zone = Zone.from_surface(surface)
    if zone then
      surface.localised_name = Zone.get_default_localised_name_for_surface(zone)
    end
  end
end

function Zone.on_init()
  storage.zones_by_surface = {}
  storage.cache_travel_delta_v = {}
end
Event.addListener("on_init", Zone.on_init, true)

return Zone
