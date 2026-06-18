local data_util = require("data_util")
local make_recipe = data_util.make_recipe
local obs_types = data_util.obs_types

make_recipe({
  name = data_util.mod_prefix .. "astrometric-data",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "visible-observation-data", amount = 1 },
    { type = "item", name = data_util.mod_prefix .. "uv-observation-data", amount = 1 },
    { type = "item", name = data_util.mod_prefix .. "infrared-observation-data", amount = 1 },
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-cold", amount = 10},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "astrometric-data", amount = 3 },
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-hot", amount = 10},
  },
  main_product = data_util.mod_prefix .. "astrometric-data",
  energy_required = 3,
  icons = data_util.sub_icons("__space-exploration-graphics__/graphics/icons/data/astrometric.png",
                              { icon = "__space-exploration-graphics__/graphics/icons/number/1.png", scale = 0.5, icon_size = 20 }),
  icon_size = 64,
  category = "space-astrometrics",
  subgroup = "data-astronomic",
  enabled = false,
  always_show_made_in = true,
  order = "a-04-a"
})
make_recipe({
  name = data_util.mod_prefix .. "astrometric-analysis-multispectral-2",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "empty-data", amount = 5 },
    { type = "item", name = data_util.mod_prefix .. "visible-observation-data", amount = 1 },
    { type = "item", name = data_util.mod_prefix .. "uv-observation-data", amount = 1 },
    { type = "item", name = data_util.mod_prefix .. "infrared-observation-data", amount = 1 },
    { type = "item", name = data_util.mod_prefix .. "microwave-observation-data", amount = 1 },
    { type = "item", name = data_util.mod_prefix .. "xray-observation-data", amount = 1 },
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-cold", amount = 10},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "astrometric-data", amount = 10 },
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-hot", amount = 10},
  },
  main_product = data_util.mod_prefix .. "astrometric-data",
  icons = data_util.sub_icons("__space-exploration-graphics__/graphics/icons/data/astrometric.png",
                              { icon = "__space-exploration-graphics__/graphics/icons/number/2.png", scale = 0.5, icon_size = 20 }),
  energy_required = 10,
  icon_size = 64,
  category = "space-astrometrics",
  subgroup = "data-astronomic",
  enabled = false,
  always_show_made_in = true,
  hide_from_signal_gui = false,
  order = "a-04-b"
})
make_recipe({
  name = data_util.mod_prefix .. "astrometric-analysis-multispectral-3",
  ingredients = {
    { type = "item", name = data_util.mod_prefix .. "empty-data", amount = 13 },
    { type = "item", name = data_util.mod_prefix .. "visible-observation-data", amount = 1 },
    { type = "item", name = data_util.mod_prefix .. "infrared-observation-data", amount = 1 },
    { type = "item", name = data_util.mod_prefix .. "uv-observation-data", amount = 1 },
    { type = "item", name = data_util.mod_prefix .. "microwave-observation-data", amount = 1 },
    { type = "item", name = data_util.mod_prefix .. "xray-observation-data", amount = 1 },
    { type = "item", name = data_util.mod_prefix .. "radio-observation-data", amount = 1 },
    { type = "item", name = data_util.mod_prefix .. "gammaray-observation-data", amount = 1 },
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-cold", amount = 10},
  },
  results = {
    { type = "item", name = data_util.mod_prefix .. "astrometric-data", amount = 20 },
    { type = "fluid", name = data_util.mod_prefix .. "space-coolant-hot", amount = 10},
  },
  main_product = data_util.mod_prefix .. "astrometric-data",
  icons = data_util.sub_icons("__space-exploration-graphics__/graphics/icons/data/astrometric.png",
                              { icon = "__space-exploration-graphics__/graphics/icons/number/3.png", scale = 0.5, icon_size = 20 }),
  energy_required = 20,
  icon_size = 64,
  category = "space-astrometrics",
  subgroup = "data-astronomic",
  enabled = false,
  always_show_made_in = true,
  hide_from_signal_gui = false,
  order = "a-04-c"
})

local i = 0
for _, type in pairs(obs_types) do
  i = i + 1
  make_recipe({
    name = data_util.mod_prefix .. type[1] .. "-observation-data",
    ingredients = {
      { type = "item", name = data_util.mod_prefix .. "observation-frame-" .. type[1], amount = type[2] },
      { type = "item", name = data_util.mod_prefix .. "empty-data", amount = 1 },
    },
    results = {
      { type = "item", name = data_util.mod_prefix .. type[1] .. "-observation-data", amount_min = 1, amount_max = 1, probability = type[3] },
      { type = "item", name = data_util.mod_prefix .. "junk-data", amount_min = 1, amount_max = 1, probability = 0.99 - type[3] },
      { type = "item", name = data_util.mod_prefix .. "scrap",  amount_min = 1, amount_max = 1, probability = 0.01 * type[2] },
    },
    energy_required = math.floor(60 * type[3]) / 10,
    main_product = data_util.mod_prefix .. type[1] .. "-observation-data",
    icon = "__space-exploration-graphics__/graphics/icons/data/"..type[1].."-observation.png",
    icon_size = 64,
    category = "space-astrometrics",
    order = "od-a"..i,
    enabled = false,
    always_show_made_in = true,
    allow_as_intermediate = false,
  })
end
