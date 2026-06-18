local data_util = require("data_util")

local function crater_picture (name, width, height)
  return {
    filename = "__alien-biomes-graphics__/graphics/decorative/crater/crater-"..name..".png",
    width = width,
    height = height,
    scale = 0.5
  }
end
local i = 0
local function make_crater(name, box, max_probability, random_probability_penalty, pictures)
  i = i + 1
  return {
    name = data_util.mod_prefix..name,
    localised_name = {"space-exploration."..data_util.mod_prefix.."crater"},
    type = "optimized-decorative",
    subgroup = "grass",
    order = "b[decorative]-b[crater-decal]-"..i,
    collision_box = {{-box, -box*0.75}, {box, box*0.75}},
    collision_mask = {
      layers ={
        doodad = true,
        water_tile = true,
      },
    },
    render_layer = "decals",
    tile_layer = 50, -- as long as it is over asteroid layer
    pictures = pictures,
    autoplace = {
      order = "a[doodad]-b[decal]",
      probability_expression = "max_probability * sharpness_filter",
      local_expressions = {
        max_probability = max_probability,
        sharpness_filter = "ab_sharpness_function(peaks_expr, 0.7)",
        peaks_expr = "influence_modifier + peak1_expr + peak2_expr",
        peak1_expr = "0.4",
        peak2_expr = "0.15 * multioctave_noise{\z
          x = x,\z
          y = y,\z
          persistence = 0.9,\z
          seed0 = map_seed,\z
          seed1 = 'trees-"..i.."',\z
          octaves = default_octaves - 3,\z
          input_scale = 1,\z
          output_scale = 1\z
        }",
        default_octaves = "10 - log2(var('control:rocks:frequency'))",
        influence_modifier = "0.1 - quantile",
        quantile = 0.1
      },
      tile_restriction = {data_util.mod_prefix.."asteroid"}
    },
  }
end
data:extend({
  make_crater("crater3-huge", 3, 0.01, 0.95, {
    crater_picture("huge-01", 1249, 877),
  }),
  make_crater("crater1-large-rare", 2, 0.01, 0.95, {
    crater_picture("large-01", 679, 513),
  }),
  make_crater("crater1-large", 1, 0.1, 0.7, {
    crater_picture("large-02", 327, 284),
    crater_picture("large-03", 481, 393),
    crater_picture("large-04", 406, 382),
    crater_picture("large-05", 363, 301),
  }),
  make_crater("crater2-medium", 0.5, 0.1, 0.5, {
    crater_picture("medium-01", 283, 231),
    crater_picture("medium-02", 213, 182),
    crater_picture("medium-03", 243, 189),
    crater_picture("medium-04", 237, 173),
    crater_picture("medium-05", 195, 182),
    crater_picture("medium-06", 146, 125),
    crater_picture("medium-07", 180, 127),
  }),
  make_crater("crater4-small", 0.25, 0.1, 0.8, {
    crater_picture("small-01", 122, 108),
  }),
})
