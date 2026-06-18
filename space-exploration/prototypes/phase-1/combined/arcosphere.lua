local data_util = require("data_util")

--[[
α alpha
β  beta
γ  gamma
δ  delta
ε  epsilon
ζ  zeta
η  eta
θ  theta
λ  la(m)bda
ξ  xi
φ  phi
ψ  psi
ω  omega


δ  delta
ε  epsilon
ζ  zeta
θ  theta
λ  lambda
ξ  xi
φ  phi
ω  omega

Ζ Zeta
Θ theta
Ω omega
Φ phi
Σ sigma
Λ Lambda

translation
rotation
reflection
dilation
transformation
inversion
substitution
superposition

Apex
Omega

Ruby
Saphire
Emerald
Topaz
Amber
Citrine
Amethyst
Quartz


γ  gamma
ζ  zeta
ξ  xi
φ  phi
ψ  psi
ω  omega
θ  theta
λ  lambda

]]

local arcosphere_variants = {
  { number = 1, letter = "a", sign = "l", character = "λ", name = "lambda", color = {r = 0.0, g = 251.0/255.0, b = 1.0, a = 1.0}},
  { number = 2, letter = "b", sign = "x", character = "ξ", name = "xi", color = {r = 0.0, g = 222.0/255.0, b = 26.0/255.0, a = 1.0}},
  { number = 3, letter = "c", sign = "z", character = "ζ", name = "zeta", color = {r = 251.0/255.0, g = 1.0, b = 0.0, a = 1.0}},
  { number = 4, letter = "d", sign = "t", character = "θ", name = "theta", color = {r = 1.0, g = 126.0/255.0, b = 61.0/255.0, a = 1.0}},
  { number = 5, letter = "e", sign = "e", character = "ε", name = "epsilon", color = {r = 1.0, g = 61.0/255.0, b = 81.0/255.0, a = 1.0}},
  { number = 6, letter = "f", sign = "f", character = "φ", name = "phi", color = {r = 229.0/255.0, g = 61.0/255.0, b = 1.0, a = 1.0}},
  { number = 7, letter = "g", sign = "g", character = "γ", name = "gamma", color = {r = 135.0/255.0, g = 61.0/255.0, b = 1.0, a = 1.0}},
  { number = 8, letter = "h", sign = "o", character = "ω", name = "omega", color = {r = 61.0/255.0, g = 68.0/255.0, b = 1.0, a = 1.0}},
}

local arcosphere_fracture_a = {r = 0.055, g = 0.0641, b = 0.805, a = 1.000}
local arcosphere_fracture_b = {r = 0.055, g = 0.805, b = 0.217, a = 1.000}

data:extend({
  {
    type = "technology",
    name = data_util.mod_prefix .. "arcosphere",
    effects = {
      { type = "unlock-recipe", recipe = data_util.mod_prefix .. "arcosphere-collector", },
    },
    icon = "__space-exploration-graphics__/graphics/technology/arcosphere.png",
    icon_size = 128,
    order = "e-g",
    prerequisites = {
      "laser-turret",
      data_util.mod_prefix .. "deep-space-science-pack-2",
    },
    unit = {
     count = 200,
     time = 60,
     ingredients = {
       { data_util.mod_prefix .. "deep-space-science-pack-2", 1 },
     }
    },
  },
  {
    type = "technology",
    name = data_util.mod_prefix .. "arcosphere-folding",
    effects = {
      { type = "unlock-recipe", recipe = data_util.mod_prefix .. "arcosphere-fracture", },
      { type = "unlock-recipe", recipe = data_util.mod_prefix .. "arcosphere-fracture-alt", },
      { type = "unlock-recipe", recipe = data_util.mod_prefix .. "arcosphere-fold-in", },
      { type = "unlock-recipe", recipe = data_util.mod_prefix .. "arcosphere-fold-out", },
      { type = "unlock-recipe", recipe = data_util.mod_prefix .. "arcosphere-fold-a", },
      { type = "unlock-recipe", recipe = data_util.mod_prefix .. "arcosphere-fold-b", },
      { type = "unlock-recipe", recipe = data_util.mod_prefix .. "arcosphere-fold-c", },
      { type = "unlock-recipe", recipe = data_util.mod_prefix .. "arcosphere-fold-d", },
      { type = "unlock-recipe", recipe = data_util.mod_prefix .. "arcosphere-fold-e", },
      { type = "unlock-recipe", recipe = data_util.mod_prefix .. "arcosphere-fold-f", },
      { type = "unlock-recipe", recipe = data_util.mod_prefix .. "arcosphere-fold-g", },
      { type = "unlock-recipe", recipe = data_util.mod_prefix .. "arcosphere-fold-h", },
    },
    icon = "__space-exploration-graphics__/graphics/technology/arcosphere.png",
    icon_size = 128,
    order = "e-g",
    prerequisites = {
      data_util.mod_prefix .. "arcosphere",
    },
    unit = {
     count = 400,
     time = 60,
     ingredients = {
       { data_util.mod_prefix .. "deep-space-science-pack-2", 1 },
     }
    },
  },
  {
    type = "item",
    name = data_util.mod_prefix .. "arcosphere-collector",
    icons = {
        { icon = "__space-exploration-graphics__/graphics/icons/satellite.png", icon_size = 64 },
        { icon = "__space-exploration-graphics__/graphics/icons/satellite-mask.png", icon_size = 64, tint = {r=0.9,g=8,b=0.9}},
    },
    icon_size = 64,
    order = "a[arcosphere]-a[collecter]",
    subgroup = "arcosphere",
    stack_size = 1,
    rocket_launch_products = {{type = "item", name = data_util.mod_prefix .. "arcosphere", amount = 0}},
    weight = 1 * tons,
    send_to_orbit_mode = "automated"
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "arcosphere-collector",
    main_product = data_util.mod_prefix .. "arcosphere-collector",
    category = "space-manufacturing",
    subgroup = "arcosphere",
    enabled = false,
    energy_required = 60,
    ingredients = {
      {type = "item", name = "laser-turret", amount = 2},
      {type = "item", name = data_util.mod_prefix .. "dynamic-emitter", amount = 2},
      {type = "item", name = data_util.mod_prefix .. "quantum-processor", amount = 5},
      {type = "item", name = data_util.mod_prefix .. "naquium-cube", amount = 10},
      {type = "item", name = data_util.mod_prefix .. "antimatter-canister", amount = 10},
      {type = "item", name = data_util.mod_prefix .. "aeroframe-bulkhead", amount = 30},
    },
    results = {
      {type = "item", name = data_util.mod_prefix .. "arcosphere-collector", amount = 1},
      {type = "item", name = data_util.mod_prefix .. "magnetic-canister", amount = 10},
    },
    requester_paste_multiplier = 1,
    icon_size = 64,
    order = "a[arcosphere]-a[collecter]"
  },
  {
    type = "item",
    name = data_util.mod_prefix .. "arcosphere",
    icon = "__space-exploration-graphics__/graphics/icons/dss/ns-0.png",
    icon_size = 64,
    order = "a[arcosphere]-b[arcosphere]",
    subgroup = "arcosphere",
    stack_size = 1,
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "arcosphere-fracture",
    category = "arcosphere",
    subgroup = "arcosphere",
    enabled = false,
    energy_required = 60,
    ingredients = {
      {type = "item", name = data_util.mod_prefix .. "arcosphere", amount = 4},
    },
    results = {
      {type = "item", name = data_util.mod_prefix .. "arcosphere-a", amount = 1},
      {type = "item", name = data_util.mod_prefix .. "arcosphere-b", amount = 0},
      {type = "item", name = data_util.mod_prefix .. "arcosphere-c", amount = 1},
      {type = "item", name = data_util.mod_prefix .. "arcosphere-d", amount = 0},
      {type = "item", name = data_util.mod_prefix .. "arcosphere-e", amount = 1},
      {type = "item", name = data_util.mod_prefix .. "arcosphere-f", amount = 0},
      {type = "item", name = data_util.mod_prefix .. "arcosphere-g", amount = 1},
      {type = "item", name = data_util.mod_prefix .. "arcosphere-h", amount = 0},
    },
    requester_paste_multiplier = 1,
    icon = "__space-exploration-graphics__/graphics/icons/dss/ns-0.png",
    icon_size = 64,
    always_show_made_in = true,
    localised_description = {"space-exploration.arcosphere-random"},
    crafting_machine_tint =
    {
      primary = arcosphere_fracture_a,
      secondary = arcosphere_fracture_b,
    },
    order = "a[arcosphere]-c[polerize]-a"
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "arcosphere-fracture-alt",
    category = "arcosphere",
    subgroup = "arcosphere",
    enabled = false,
    energy_required = 60,
    ingredients = {
      {type = "item", name = data_util.mod_prefix .. "arcosphere", amount = 4},
    },
    results = {
      {type = "item", name = data_util.mod_prefix .. "arcosphere-a", amount = 0},
      {type = "item", name = data_util.mod_prefix .. "arcosphere-b", amount = 1},
      {type = "item", name = data_util.mod_prefix .. "arcosphere-c", amount = 0},
      {type = "item", name = data_util.mod_prefix .. "arcosphere-d", amount = 1},
      {type = "item", name = data_util.mod_prefix .. "arcosphere-e", amount = 0},
      {type = "item", name = data_util.mod_prefix .. "arcosphere-f", amount = 1},
      {type = "item", name = data_util.mod_prefix .. "arcosphere-g", amount = 0},
      {type = "item", name = data_util.mod_prefix .. "arcosphere-h", amount = 1},
    },
    requester_paste_multiplier = 1,
    icon = "__space-exploration-graphics__/graphics/icons/dss/ns-0.png",
    icon_size = 64,
    always_show_made_in = true,
    localised_name = {"recipe-name."..data_util.mod_prefix .. "arcosphere-fracture"},
    localised_description = {"space-exploration.arcosphere-random"},
    crafting_machine_tint =
    {
      primary = arcosphere_fracture_b,
      secondary = arcosphere_fracture_a,
    },
    order = "a[arcosphere]-c[polerize]-b"
  }
})

for _, arcosphere_variant in pairs(arcosphere_variants) do
  data:extend({{
      type = "item",
      name = data_util.mod_prefix .. "arcosphere-"..arcosphere_variant.letter,
      icon_gfx = "__space-exploration-graphics__/graphics/icons/dss/ns-"..arcosphere_variant.letter..".png", -- used for recipe
      icon_letter = "__space-exploration-graphics__/graphics/icons/dss/"..arcosphere_variant.name..".png", -- used for recipe
      icon_size = 64,
      icons = { -- overrides icon
        { icon = "__space-exploration-graphics__/graphics/icons/dss/ns-"..arcosphere_variant.letter..".png", icon_size = 64 },
        { icon = "__space-exploration-graphics__/graphics/icons/dss/"..arcosphere_variant.name..".png", icon_size = 64 },
      },
      pictures = {
        {
          filename = "__space-exploration-graphics__/graphics/icons/dss/ns-"..arcosphere_variant.letter..".png",
          scale = 0.5,
          size = 64
        },
      },
      order = "a[arcosphere]-d[polerized]-"..arcosphere_variant.letter,
      subgroup = "arcosphere",
      stack_size = 1,
  }})
end

local function make_recipe(name, from_high, from_low, to_high, to_low)

  local a = data.raw.item[data_util.mod_prefix .. "arcosphere-"..arcosphere_variants[from_high].letter]
  local b = data.raw.item[data_util.mod_prefix .. "arcosphere-"..arcosphere_variants[from_low].letter]
  local c = data.raw.item[data_util.mod_prefix .. "arcosphere-"..arcosphere_variants[to_high].letter]
  local d = data.raw.item[data_util.mod_prefix .. "arcosphere-"..arcosphere_variants[to_low].letter]
  data:extend({
    {
      type = "recipe",
      name = data_util.mod_prefix..name,
      category = "arcosphere",
      subgroup = "arcosphere-folding",
      order = "a[folding]-a["..name.."]",
      results = {
        {type = "item", name = data_util.mod_prefix .. "arcosphere-"..arcosphere_variants[to_high].letter, amount = 1},
        {type = "item", name = data_util.mod_prefix .. "arcosphere-"..arcosphere_variants[to_low].letter, amount = 1},
      },
      enabled = false,
      energy_required = 10,
      ingredients = {
        {type = "item", name = data_util.mod_prefix .. "arcosphere-"..arcosphere_variants[from_high].letter, amount = 1},
        {type = "item", name = data_util.mod_prefix .. "arcosphere-"..arcosphere_variants[from_low].letter, amount = 1},
      },
      crafting_machine_tint =
      {
        primary = arcosphere_variants[from_high].color,
        secondary = arcosphere_variants[from_low].color,
      },
      requester_paste_multiplier = 1,
      always_show_products = false,
      allow_decomposition = false,
      always_show_made_in = true,
      icons = {
        { icon = "__space-exploration-graphics__/graphics/blank.png", scale = 1, shift = {0, 0}, icon_size = 64 }, -- to lock scale
        { icon = a.icon_gfx, scale = 0.33, shift = {-4, -16}, icon_size = 64 },
        { icon = b.icon_gfx, scale = 0.33, shift = {16, -16}, icon_size = 64 },
        { icon = c.icon_gfx, scale = 0.33, shift = {-16, 16}, icon_size = 64 },
        { icon = d.icon_gfx, scale = 0.33, shift = {4, 16}, icon_size = 64 },
        { icon = a.icon_letter, scale = 0.33, shift = {-4, -16}, icon_size = 64 },
        { icon = b.icon_letter, scale = 0.33, shift = {16, -16}, icon_size = 64 },
        { icon = c.icon_letter, scale = 0.33, shift = {-16, 16}, icon_size = 64 },
        { icon = d.icon_letter, scale = 0.33, shift = {4, 16}, icon_size = 64 },
        { icon = "__space-exploration-graphics__/graphics/icons/transition-arrow.png", scale = 1, shift = {0, 0}, icon_size = 64 }, -- to overlay
      },
      localised_name = {"recipe-name.se-arcosphere-folding",
        arcosphere_variants[from_high].character,
        arcosphere_variants[from_low].character,
        arcosphere_variants[to_high].character,
        arcosphere_variants[to_low].character}
    }
  })
end
make_recipe("arcosphere-fold-a", 8, 1, 2, 4)
make_recipe("arcosphere-fold-b", 7, 2, 3, 1)
make_recipe("arcosphere-fold-c", 2, 3, 4, 6)
make_recipe("arcosphere-fold-d", 1, 4, 5, 3)
make_recipe("arcosphere-fold-e", 4, 5, 6, 8)
make_recipe("arcosphere-fold-f", 3, 6, 7, 5)
make_recipe("arcosphere-fold-g", 6, 7, 8, 2)
make_recipe("arcosphere-fold-h", 5, 8, 1, 7)

data:extend({
  {
    type = "recipe",
    name = data_util.mod_prefix .. "arcosphere-fold-in",
    category = "arcosphere",
    subgroup = "arcosphere",
    order = "a[arcosphere]-c[polerize]-c",
    results = {
      {type = "item", name = data_util.mod_prefix .. "arcosphere-a", amount = 1},
      {type = "item", name = data_util.mod_prefix .. "arcosphere-b", amount = 1},
      {type = "item", name = data_util.mod_prefix .. "arcosphere-e", amount = 1},
      {type = "item", name = data_util.mod_prefix .. "arcosphere-f", amount = 1},
    },
    enabled = false,
    energy_required = 100,
    ingredients = {
      {type = "item", name = data_util.mod_prefix .. "arcosphere-c", amount = 1},
      {type = "item", name = data_util.mod_prefix .. "arcosphere-d", amount = 1},
      {type = "item", name = data_util.mod_prefix .. "arcosphere-g", amount = 1},
      {type = "item", name = data_util.mod_prefix .. "arcosphere-h", amount = 1},
    },
    requester_paste_multiplier = 1,
    always_show_products = false,
    allow_decomposition = false,
    always_show_made_in = true,
    icon = "__space-exploration-graphics__/graphics/icons/dss/ns-0.png",
    icon_size = 64
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "arcosphere-fold-out",
    category = "arcosphere",
    subgroup = "arcosphere",
    order = "a[arcosphere]-c[polerize]-d",
    results = {
      {type = "item", name = data_util.mod_prefix .. "arcosphere-c", amount = 1},
      {type = "item", name = data_util.mod_prefix .. "arcosphere-d", amount = 1},
      {type = "item", name = data_util.mod_prefix .. "arcosphere-g", amount = 1},
      {type = "item", name = data_util.mod_prefix .. "arcosphere-h", amount = 1},
    },
    enabled = false,
    energy_required = 100,
    ingredients = {
      {type = "item", name = data_util.mod_prefix .. "arcosphere-a", amount = 1},
      {type = "item", name = data_util.mod_prefix .. "arcosphere-b", amount = 1},
      {type = "item", name = data_util.mod_prefix .. "arcosphere-e", amount = 1},
      {type = "item", name = data_util.mod_prefix .. "arcosphere-f", amount = 1},
    },
    requester_paste_multiplier = 1,
    always_show_products = false,
    allow_decomposition = false,
    always_show_made_in = true,
    icon = "__space-exploration-graphics__/graphics/icons/dss/ns-0.png",
    icon_size = 64
  }
})
