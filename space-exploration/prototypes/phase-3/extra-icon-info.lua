--this code adds some useful icons to certain items, such as numbers to indicate science pack levels

local data_util = require("data_util")
local characterdir = "__space-exploration-graphics__/graphics/icons/number/"

local function find_make_icons(thing_with_icons) --finds icon or icons and returns a table of icons (single icon becomes icons table)
  if thing_with_icons.main_product then -- Recipe icon
    item = data.raw["item"][thing_with_icons.main_product] or data.raw["tool"][thing_with_icons.main_product]
    if item.icon then
      return table.deepcopy({ { icon = item.icon, icon_size = item.icon_size } })
    end
    if item.icons then
      return table.deepcopy(item.icons)
    end
  else -- Item or tool icon
      if thing_with_icons.icons then
      return table.deepcopy(thing_with_icons.icons)
    end
    if thing_with_icons.icon then
      return table.deepcopy({ { icon = thing_with_icons.icon, icon_size = thing_with_icons.icon_size } })
    end
  end
end

local function add_number_or_letter_to_icon(proto_name, proto_type, numbers_or_letters, kerning)
  the_thing = data.raw[proto_type][proto_name]
  local new_icons = find_make_icons(the_thing)
  if proto_type == "item" and not the_thing.pictures then
    the_thing.pictures = {}
    for _,ico in pairs(new_icons) do
      table.insert(the_thing.pictures, {
        filename = ico.icon,
        width = ico.icon_size,
        height = ico.icon_size,
        tint = ico.tint,
        scale = .25 * (ico.scale or 1)
      })
    end
  end
  local basic_icon = {
    --icon = characterdir .. num .. ".png",
    scale = 0.5,
    shift = { -10, -10 },
    icon_size = 20
  }
  if not kerning then kerning = { 0, 8, 16, 24, 32, 40, 48, 56, 64 } end
  local shift = -10
  for i = 1, #numbers_or_letters do
    local num_or_letter = string.sub(numbers_or_letters, i, i)
    local kern = kerning[i] or 0;
    num_or_letter = string.upper(num_or_letter)
    local new_icon = table.deepcopy(basic_icon)
    new_icon.icon = characterdir .. num_or_letter .. ".png"
    shift = shift + kern
    new_icon.shift[1] = shift
    table.insert(new_icons, new_icon)
  end
  the_thing.icons = new_icons
end

local function add_number_or_letter_to_icon_multiple_types(proto_name, type_table, numbers_or_letters, kerning) --clutter reducing helper function
  for _,proto_type in pairs(type_table) do
    add_number_or_letter_to_icon(proto_name, proto_type, numbers_or_letters, kerning)
  end
end

if settings.startup["se-add-icon-labels"].value then
  --science pack "items"
  add_number_or_letter_to_icon(data_util.mod_prefix .. "astronomic-science-pack-1", "tool", "1", { 0 })
  add_number_or_letter_to_icon(data_util.mod_prefix .. "astronomic-science-pack-2", "tool", "2", { 0 })
  add_number_or_letter_to_icon(data_util.mod_prefix .. "astronomic-science-pack-3", "tool", "3", { 0 })
  add_number_or_letter_to_icon(data_util.mod_prefix .. "astronomic-science-pack-4", "tool", "4", { 0 })

  add_number_or_letter_to_icon(data_util.mod_prefix .. "biological-science-pack-1", "tool", "1", { 0 })
  add_number_or_letter_to_icon(data_util.mod_prefix .. "biological-science-pack-2", "tool", "2", { 0 })
  add_number_or_letter_to_icon(data_util.mod_prefix .. "biological-science-pack-3", "tool", "3", { 0 })
  add_number_or_letter_to_icon(data_util.mod_prefix .. "biological-science-pack-4", "tool", "4", { 0 })

  add_number_or_letter_to_icon(data_util.mod_prefix .. "material-science-pack-1", "tool", "1", { 0 })
  add_number_or_letter_to_icon(data_util.mod_prefix .. "material-science-pack-2", "tool", "2", { 0 })
  add_number_or_letter_to_icon(data_util.mod_prefix .. "material-science-pack-3", "tool", "3", { 0 })
  add_number_or_letter_to_icon(data_util.mod_prefix .. "material-science-pack-4", "tool", "4", { 0 })

  add_number_or_letter_to_icon(data_util.mod_prefix .. "energy-science-pack-1", "tool", "1", { 0 })
  add_number_or_letter_to_icon(data_util.mod_prefix .. "energy-science-pack-2", "tool", "2", { 0 })
  add_number_or_letter_to_icon(data_util.mod_prefix .. "energy-science-pack-3", "tool", "3", { 0 })
  add_number_or_letter_to_icon(data_util.mod_prefix .. "energy-science-pack-4", "tool", "4", { 0 })

  --deep space science pack
  add_number_or_letter_to_icon_multiple_types(data_util.mod_prefix .. "deep-space-science-pack-1", {"tool", "recipe"}, "1", { 0 })
  add_number_or_letter_to_icon_multiple_types(data_util.mod_prefix .. "deep-space-science-pack-2", {"tool", "recipe"}, "2", { 0 })
  add_number_or_letter_to_icon_multiple_types(data_util.mod_prefix .. "deep-space-science-pack-3", {"tool", "recipe"}, "3", { 0 })
  add_number_or_letter_to_icon_multiple_types(data_util.mod_prefix .. "deep-space-science-pack-4", {"tool", "recipe"}, "4", { 0 })

  --catalogue items and recipes
  add_number_or_letter_to_icon_multiple_types(data_util.mod_prefix .. "astronomic-catalogue-1", {"item", "recipe"}, "1", { 0 })
  add_number_or_letter_to_icon_multiple_types(data_util.mod_prefix .. "astronomic-catalogue-2", {"item", "recipe"}, "2", { 0 })
  add_number_or_letter_to_icon_multiple_types(data_util.mod_prefix .. "astronomic-catalogue-3", {"item", "recipe"}, "3", { 0 })
  add_number_or_letter_to_icon_multiple_types(data_util.mod_prefix .. "astronomic-catalogue-4", {"item", "recipe"}, "4", { 0 })

  add_number_or_letter_to_icon_multiple_types(data_util.mod_prefix .. "biological-catalogue-1", {"item", "recipe"}, "1", { 0 })
  add_number_or_letter_to_icon_multiple_types(data_util.mod_prefix .. "biological-catalogue-2", {"item", "recipe"}, "2", { 0 })
  add_number_or_letter_to_icon_multiple_types(data_util.mod_prefix .. "biological-catalogue-3", {"item", "recipe"}, "3", { 0 })
  add_number_or_letter_to_icon_multiple_types(data_util.mod_prefix .. "biological-catalogue-4", {"item", "recipe"}, "4", { 0 })

  add_number_or_letter_to_icon_multiple_types(data_util.mod_prefix .. "material-catalogue-1", {"item", "recipe"}, "1", { 0 })
  add_number_or_letter_to_icon_multiple_types(data_util.mod_prefix .. "material-catalogue-2", {"item", "recipe"}, "2", { 0 })
  add_number_or_letter_to_icon_multiple_types(data_util.mod_prefix .. "material-catalogue-3", {"item", "recipe"}, "3", { 0 })
  add_number_or_letter_to_icon_multiple_types(data_util.mod_prefix .. "material-catalogue-4", {"item", "recipe"}, "4", { 0 })

  add_number_or_letter_to_icon_multiple_types(data_util.mod_prefix .. "energy-catalogue-1", {"item", "recipe"}, "1", { 0 })
  add_number_or_letter_to_icon_multiple_types(data_util.mod_prefix .. "energy-catalogue-2", {"item", "recipe"}, "2", { 0 })
  add_number_or_letter_to_icon_multiple_types(data_util.mod_prefix .. "energy-catalogue-3", {"item", "recipe"}, "3", { 0 })
  add_number_or_letter_to_icon_multiple_types(data_util.mod_prefix .. "energy-catalogue-4", {"item", "recipe"}, "4", { 0 })

  add_number_or_letter_to_icon_multiple_types(data_util.mod_prefix .. "deep-catalogue-1", {"item", "recipe"}, "1", { 0 })
  add_number_or_letter_to_icon_multiple_types(data_util.mod_prefix .. "deep-catalogue-2", {"item", "recipe"}, "2", { 0 })
  add_number_or_letter_to_icon_multiple_types(data_util.mod_prefix .. "deep-catalogue-3", {"item", "recipe"}, "3", { 0 })
  add_number_or_letter_to_icon_multiple_types(data_util.mod_prefix .. "deep-catalogue-4", {"item", "recipe"}, "4", { 0 })

  -- lenses
  add_number_or_letter_to_icon_multiple_types(data_util.mod_prefix .. "observation-frame-radio", {"item", "recipe"}, "r", { 0 })
  add_number_or_letter_to_icon_multiple_types(data_util.mod_prefix .. "observation-frame-microwave", {"item", "recipe"}, "m", { 0 })
  add_number_or_letter_to_icon_multiple_types(data_util.mod_prefix .. "observation-frame-infrared", {"item", "recipe"}, "ir", { 0, 6 })
  add_number_or_letter_to_icon_multiple_types(data_util.mod_prefix .. "observation-frame-visible", {"item", "recipe"}, "v", { 0 })
  add_number_or_letter_to_icon_multiple_types(data_util.mod_prefix .. "observation-frame-uv", {"item", "recipe"}, "uv", { 0, 8 })
  add_number_or_letter_to_icon_multiple_types(data_util.mod_prefix .. "observation-frame-xray", {"item", "recipe"}, "x", { 0 })
  add_number_or_letter_to_icon_multiple_types(data_util.mod_prefix .. "observation-frame-gammaray", {"item", "recipe"}, "g", { 0 })

  --observation data
  add_number_or_letter_to_icon_multiple_types(data_util.mod_prefix .. "radio-observation-data", {"item", "recipe"}, "r", { 0 })
  add_number_or_letter_to_icon_multiple_types(data_util.mod_prefix .. "microwave-observation-data", {"item", "recipe"}, "m", { 0 })
  add_number_or_letter_to_icon_multiple_types(data_util.mod_prefix .. "infrared-observation-data", {"item", "recipe"}, "ir", { 0, 6 })
  add_number_or_letter_to_icon_multiple_types(data_util.mod_prefix .. "visible-observation-data", {"item", "recipe"}, "v", { 0 })
  add_number_or_letter_to_icon_multiple_types(data_util.mod_prefix .. "uv-observation-data", {"item", "recipe"}, "uv", { 0, 8 })
  add_number_or_letter_to_icon_multiple_types(data_util.mod_prefix .. "xray-observation-data", {"item", "recipe"}, "x", { 0 })
  add_number_or_letter_to_icon_multiple_types(data_util.mod_prefix .. "gammaray-observation-data", {"item", "recipe"}, "g", { 0 })
end
