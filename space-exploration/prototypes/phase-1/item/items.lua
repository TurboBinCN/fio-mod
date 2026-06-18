local data_util = require("data_util")
data.raw.item["rocket-silo"].subgroup = "rocket-logistics"
data.raw.item["rocket-silo"].order = "a-a-a"

data.raw.item["rocket-control-unit"].subgroup = "rocket-part"
data.raw.item["low-density-structure"].subgroup = "advanced-assembling"
data.raw.item["low-density-structure"].order = "b"
data.raw.item["low-density-structure"].stack_size = 50
data.raw.item["rocket-fuel"].subgroup = "fuel"

-- item_group, sequence
--[[
data:extend({
  {
      action = {
        action_delivery = {
          target_effects = {
            damage = {
              amount = 50, -- 8,
              type = "physical"
            },
            type = "damage"
          },
          type = "instant"
        },
        type = "direct"
      },
      durability = 10000, -- 5000
      icon = "__space-exploration-graphics__/graphics/icons/omega-tool.png",
      icon_size = 64,
      name = data_util.mod_prefix .. "omega-tool",
      order = "a[mining]-b[steel-axe]",
      speed = 100, --4,
      stack_size = 5,
      subgroup = "tool",
      type = "mining-tool"
    },
})]]--

data:extend({
  {
    type = "item",
    name = data_util.mod_prefix .. "heat-shielding",
    icon = "__space-exploration-graphics__/graphics/icons/heat-shielding.png",
    icon_size = 64,
    order = "a[stone]-e[heat-shield]-a[heat-shield]",
    stack_size = 50,
    subgroup = "stone",
  },
  {
    icon = "__space-exploration-graphics__/graphics/icons/accumulator.png",
    icon_size = 64,
    name = data_util.mod_prefix .. "space-accumulator",
    order = data.raw.item.accumulator.order,
    place_result = data_util.mod_prefix .. "space-accumulator",
    stack_size = data.raw.item.accumulator.stack_size,
    subgroup = "solar",
    type = "item"
  },
  {
    icon = "__space-exploration-graphics__/graphics/icons/accumulator-2.png",
    icon_size = 64,
    name = data_util.mod_prefix .. "space-accumulator-2",
    order = data.raw.item.accumulator.order,
    place_result = data_util.mod_prefix .. "space-accumulator-2",
    stack_size = data.raw.item.accumulator.stack_size,
    subgroup = "solar",
    type = "item"
  },
  {
    icon = "__space-exploration-graphics__/graphics/icons/solar-panel.png",
    icon_size = 64,
    name = data_util.mod_prefix .. "space-solar-panel",
    order = "d[solar-panel]-a[solar-panel]-b",
    place_result = data_util.mod_prefix .. "space-solar-panel",
    stack_size = 20,
    subgroup = "solar",
    type = "item"
  },
  {
    icon = "__space-exploration-graphics__/graphics/icons/solar-panel-2.png",
    icon_size = 64,
    name = data_util.mod_prefix .. "space-solar-panel-2",
    order = "d[solar-panel]-a[solar-panel]-b2",
    place_result = data_util.mod_prefix .. "space-solar-panel-2",
    stack_size = 20,
    subgroup = "solar",
    type = "item"
  },
  {
    icon = "__space-exploration-graphics__/graphics/icons/solar-panel-3.png",
    icon_size = 64,
    name = data_util.mod_prefix .. "space-solar-panel-3",
    order = "d[solar-panel]-a[solar-panel]-b3",
    place_result = data_util.mod_prefix .. "space-solar-panel-3",
    stack_size = 20,
    subgroup = "solar",
    type = "item"
  },
})

local function make_item_sequence(item_group, items, set, icon_size, order_offset)
  for k, item in pairs(items) do
    -- name, stack_size, icon_size, picture count
    local item = type(item) == "string" and {item, 50} or item
    local order = (order_offset or "z") .."-".. string.format("%02d", k)
    local filename = item[1] .. ".png"
    local proto = {
      type = "item",
      name = data_util.mod_prefix .. item[1],
      icon = "__space-exploration-graphics__/graphics/icons/" .. (set == "catalogue" and "catalogue/" or "") .. filename,
      icon_size = set == "catalogue" and 64 or (item[3] or (icon_size or 64)),
      subgroup = item_group,
      order = order,
      stack_size = item[2]
    }
    if string.find(item[1], "catalogue", 1, true) then
      proto.pictures = {
        {
          layers = {
            {
              filename = "__space-exploration-graphics__/graphics/icons/" .. (set == "catalogue" and "catalogue/" or "") .. filename,
              scale = 0.5,
              size = 64
            },
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-catalogue-" .. (item[1]):sub(-1)..".png",
              scale = 0.5,
              size = 64,
              draw_as_light = true
            }
          }
        }
      }
    end
    if item[4] then
      local baseFileName = "__space-exploration-graphics__/graphics/icons/" .. (set == "catalogue" and "catalogue/" or "") .. item[1]
      proto.pictures = {
         { size = 64, filename = baseFileName .. ".png", scale = 0.5 },
         { size = 64, filename = baseFileName .. "-1" .. ".png", scale = 0.5 },
         { size = 64, filename = baseFileName .. "-2" .. ".png", scale = 0.5 },
         { size = 64, filename = baseFileName .. "-3" .. ".png", scale = 0.5 }
      }
    end
    data:extend({proto})
    --log(data_util.mod_prefix .. item[1])
  end
end

local function make_data_item_sequence(item_group, items, stack_size, icon_size, order_offset)
  local stack_size = stack_size or 100
  for _, item in pairs(items) do
    local item = type(item) == "string" and {item, 50} or item
    local order = (order_offset or "a-") .. string.format("%02d", _)
    data:extend({{
      type = "item",
      name = data_util.mod_prefix .. item[1] .. "-data",
      icon = "__space-exploration-graphics__/graphics/icons/data/" .. item[1] .. ".png",
      icon_size = icon_size or 64,
      subgroup = item_group,
      order = order,
      stack_size = item[2]
    }})
    --log(data_util.mod_prefix .. item[1] .. "-data")
  end
end

--[[
make_item_sequence("data-catalogue-astronomic", {
  "astronomic-catalogue-1", "astronomic-catalogue-2", "astronomic-catalogue-3", "astronomic-catalogue-4", "astronomic-insight"}, "catalogue")
make_item_sequence("data-catalogue-energy", {
  "energy-catalogue-1", "energy-catalogue-2", "energy-catalogue-3", "energy-catalogue-4", "energy-insight"}, "catalogue")
make_item_sequence("data-catalogue-biological", {
  "biological-catalogue-1", "biological-catalogue-2", "biological-catalogue-3", "biological-catalogue-4", "biological-insight"}, "catalogue")
make_item_sequence("data-catalogue-material", {
  "material-catalogue-1", "material-catalogue-2", "material-catalogue-3", "material-catalogue-4", "material-insight"}, "catalogue")
]]

make_data_item_sequence("data-significant", { "significant"})
make_data_item_sequence("data-generic", {"empty", "machine-learning", "junk", "broken"},
  nil, 64, "a[data-generic]-b[cards]"
)
data.raw.item[data_util.mod_prefix .. "broken-data"].icon_size = 64
-- data.raw.item[data_util.mod_prefix .. "empty-data"].order = "b"
-- data.raw.item[data_util.mod_prefix .. "machine-learning-data"].order = "c"
--[[
data:extend({
  {
    type = "item",
    name = data_util.mod_prefix .. "universal-catalogue",
    icon = "__space-exploration-graphics__/graphics/icons/catalogue/universal-catalogue.png",
    icon_size = 64,
    subgroup = "data-generic",
    order = "d",
    stack_size = 50
  }
})
]]

make_data_item_sequence("data-astronomic", {
  "infrared-observation",
  "visible-observation",
  "uv-observation",
  "astrometric",
  --"doppler-shift",

  "microwave-observation",
  "xray-observation",
  "gravitational-lensing",
  "gravity-wave",

  "radio-observation",
  "gammaray-observation",
  "darkmatter",
  "negative-pressure",

  "dark-energy",
  "micro-black-hole",
  --"timespace-anomaly",
  "zero-point-energy",
})

make_data_item_sequence("data-energy", {
  "conductivity",
  --"ion-spectrometry",
  "electromagnetic-field",
  "polarisation",
  "radiation",

  "quantum-phenomenon",
  "atomic",
  "subatomic",
  "forcefield",

  "superconductivity",
  "quark",
  "entanglement",
  "lepton",

  "boson",
  "fusion-test",
  --"singularity",
  "magnetic-monopole",
})

make_data_item_sequence("data-biological", {
  "bio-combustion",
  --"bio-spectral",
  "biomechanical",
  "biochemical",
  "genetic",

  "bio-combustion-resistance",
  "experimental-genetic",
  "biochemical-resistance",
  "biomechanical-resistance",

  "bioelectrics",
  "cryogenics",
  "decompression",
  "radiation-exposure",

  "comparative-genetic",
  "decompression-resistance",
  "neural-anomaly",
  "radiation-exposure-resistance",
})

make_data_item_sequence("data-material", {
  "cold-thermodynamics",
  "hot-thermodynamics",
  "tensile-strength",
  "compressive-strength",
  --"shear-strength",

  "rigidity",
  "pressure-containment",
  "corrosion-resistance",
  "impact-shielding",

  "friction",
  "ballistic-shielding",
  "radiation-shielding",
  "explosion-shielding",

  "electrical-shielding",
  "laser-shielding",
  "particle-beam-shielding",
  "experimental-alloys",
})

make_item_sequence("observation-frame", {
  {"observation-frame-blank", 200},
  {"observation-frame-radio", 200},
  {"observation-frame-microwave", 200},
  {"observation-frame-infrared", 200},
  {"observation-frame-visible", 200},
  {"observation-frame-uv", 200},
  {"observation-frame-xray", 200},
  {"observation-frame-gammaray", 200},
})

make_item_sequence("canister", {
  {"canister", 50},
  {"magnetic-canister", 50},
  {"empty-lifesupport-canister", 50},
  {"lifesupport-canister", 50},
  {"used-lifesupport-canister", 50},
})
make_item_sequence("canister-full", {
  {"plasma-canister", 50},
  {"ion-canister", 50},
  {"antimatter-canister", 50},
})
data.raw.item[data_util.mod_prefix .. "antimatter-canister"].fuel_value = "20000MJ"
data.raw.item[data_util.mod_prefix .. "antimatter-canister"].fuel_category = "antimatter"
data.raw.item[data_util.mod_prefix .. "antimatter-canister"].burnt_result = data_util.mod_prefix .. "magnetic-canister"

make_item_sequence("specimen", {
  {"nutrient-vat", 5},
  {"bioculture", 5},
  {"experimental-bioculture", 5},
}, nil, 64, "a[specimen]-a[culture]")

make_item_sequence("specimen", {
  {"specimen", 5},
  {"experimental-specimen", 5},
  {"significant-specimen", 5},
}, nil, 64, "a[specimen]-c[specimen]")

make_item_sequence("recycling", {
  {"scrap", 50, 64, 4},
  {"contaminated-scrap", 50, 64, 4},
}, nil, 64, "a[recycling]-a[scrap]-a[scrap]")

make_item_sequence("advanced-assembling", {
  "space-mirror",
  "gammaray-detector",
  {"material-testing-pack", 10},
  {"nanomaterial", 50, 64},
  {"naquium-cube", 8, 64},
  {"naquium-tessaract", 1, 64},
}, nil, 64)

make_item_sequence("electronic", {
  {"holmium-cable", 50, 64},
  {"superconductive-cable", 50, 64},
  {"holmium-solenoid", 50, 64},
  {"dynamic-emitter", 50, 64},
}, nil, 64, "b")

make_item_sequence("processor", {
  {"quantum-processor", 50, 64},
  {"naquium-processor", 1, 64},
}, nil, 64)

make_item_sequence("vitamelange", {
  {"vitalic-reagent", 50, 64},
  {"vitalic-epoxy", 50, 64},
  {"self-sealing-gel", 50, 64},
}, nil, 64, "a[vitamelange]-h[vita-product]-a[vita-product]")

make_item_sequence("specialist-assembling", {
  {"heavy-girder", 50, 64},
  {"heavy-bearing", 50, 64},
  {"heavy-composite", 50, 64},
  {"heavy-assembly", 50, 64},
  {"aeroframe-pole", 50, 64},
  {"aeroframe-scaffold", 50, 64},
  {"aeroframe-bulkhead", 50, 64},
  {"lattice-pressure-vessel", 50, 64},
  {"bioscrubber", 50, 64},
}, nil, 64)

data.raw.item[data_util.mod_prefix .. "scrap"].pictures = {
  {filename = "__space-exploration-graphics__/graphics/icons/scrap.png",scale = 0.5,size = 64},
  {filename = "__space-exploration-graphics__/graphics/icons/scrap-1.png",scale = 0.5,size = 64},
  {filename = "__space-exploration-graphics__/graphics/icons/scrap-2.png",scale = 0.5,size = 64},
  {filename = "__space-exploration-graphics__/graphics/icons/scrap-3.png",scale = 0.5,size = 64}
}
data.raw.item[data_util.mod_prefix .. "contaminated-scrap"].pictures = {
  {filename = "__space-exploration-graphics__/graphics/icons/contaminated-scrap.png",scale = 0.5,size = 64},
  {filename = "__space-exploration-graphics__/graphics/icons/contaminated-scrap-1.png",scale = 0.5,size = 64},
  {filename = "__space-exploration-graphics__/graphics/icons/contaminated-scrap-2.png",scale = 0.5,size = 64},
  {filename = "__space-exploration-graphics__/graphics/icons/contaminated-scrap-3.png",scale = 0.5,size = 64}
}

make_item_sequence("data-generic", {
  {"data-storage-substrate", 100},
  {"data-storage-substrate-cleaned", 100},
}, nil, 64, "a[data-generic]-a[substrate]")

data.raw.item[data_util.mod_prefix .. "material-testing-pack"].icon = "__space-exploration-graphics__/graphics/icons/crate.png"

data:extend({
    {
      type = "item",
      name = data_util.mod_prefix .. "satellite-telemetry",
      icon = "__space-exploration-graphics__/graphics/icons/satellite-telemetry.png",
      icon_size = 64,
      order = "a[data-generic]-f[telemetry]",
      subgroup = "data-generic",
      stack_size = 50,
    },

    {
      type = "item",
      name = data_util.mod_prefix .. "astronomic-catalogue-1",
      icon = "__space-exploration-graphics__/graphics/icons/catalogue/astronomic-catalogue-1.png",
      icon_size = 64,
      order = "a-a",
      subgroup = "data-catalogue-astronomic",
      stack_size = 50,
      pictures = {
        {
          layers = {
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/astronomic-catalogue-1.png",
              scale = 0.5,
              size = 64
            },
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-catalogue-1.png",
              scale = 0.5,
              size = 64,
              draw_as_light = true
            }
          }
        }
      }
    },
    {
      type = "item",
      name = data_util.mod_prefix .. "astronomic-catalogue-2",
      icon = "__space-exploration-graphics__/graphics/icons/catalogue/astronomic-catalogue-2.png",
      icon_size = 64,
      order = "a-b",
      subgroup = "data-catalogue-astronomic",
      stack_size = 50,
      pictures = {
        {
          layers = {
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/astronomic-catalogue-2.png",
              scale = 0.5,
              size = 64
            },
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-catalogue-2.png",
              scale = 0.5,
              size = 64,
              draw_as_light = true
            }
          }
        }
      }
    },
    {
      type = "item",
      name = data_util.mod_prefix .. "astronomic-catalogue-3",
      icon = "__space-exploration-graphics__/graphics/icons/catalogue/astronomic-catalogue-3.png",
      icon_size = 64,
      order = "a-c",
      subgroup = "data-catalogue-astronomic",
      stack_size = 50,
      pictures = {
        {
          layers = {
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/astronomic-catalogue-3.png",
              scale = 0.5,
              size = 64
            },
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-catalogue-3.png",
              scale = 0.5,
              size = 64,
              draw_as_light = true
            }
          }
        }
      }
    },
    {
      type = "item",
      name = data_util.mod_prefix .. "astronomic-catalogue-4",
      icon = "__space-exploration-graphics__/graphics/icons/catalogue/astronomic-catalogue-4.png",
      icon_size = 64,
      order = "a-d",
      subgroup = "data-catalogue-astronomic",
      stack_size = 50,
      pictures = {
        {
          layers = {
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/astronomic-catalogue-4.png",
              scale = 0.5,
              size = 64
            },
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-catalogue-4.png",
              scale = 0.5,
              size = 64,
              draw_as_light = true
            }
          }
        }
      }
    },
    {
      type = "item",
      name = data_util.mod_prefix .. "astronomic-insight",
      icon = "__space-exploration-graphics__/graphics/icons/catalogue/astronomic-insight.png",
      icon_size = 64,
      order = "a-e",
      subgroup = "data-catalogue-astronomic",
      stack_size = 50,
      pictures = {
        {
          layers = {
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/astronomic-insight.png",
              scale = 0.5,
              size = 64
            },
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-insight.png",
              scale = 0.5,
              size = 64,
              draw_as_light = true
            }
          }
        }
      }
    },

    {
      type = "item",
      name = data_util.mod_prefix .. "biological-catalogue-1",
      icon = "__space-exploration-graphics__/graphics/icons/catalogue/biological-catalogue-1.png",
      icon_size = 64,
      order = "a-a",
      subgroup = "data-catalogue-biological",
      stack_size = 50,
      pictures = {
        {
          layers = {
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/biological-catalogue-1.png",
              scale = 0.5,
              size = 64
            },
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-catalogue-1.png",
              scale = 0.5,
              size = 64,
              draw_as_light = true
            }
          }
        }
      }
    },
    {
      type = "item",
      name = data_util.mod_prefix .. "biological-catalogue-2",
      icon = "__space-exploration-graphics__/graphics/icons/catalogue/biological-catalogue-2.png",
      icon_size = 64,
      order = "a-b",
      subgroup = "data-catalogue-biological",
      stack_size = 50,
      pictures = {
        {
          layers = {
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/biological-catalogue-2.png",
              scale = 0.5,
              size = 64
            },
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-catalogue-2.png",
              scale = 0.5,
              size = 64,
              draw_as_light = true
            }
          }
        }
      }
    },
    {
      type = "item",
      name = data_util.mod_prefix .. "biological-catalogue-3",
      icon = "__space-exploration-graphics__/graphics/icons/catalogue/biological-catalogue-3.png",
      icon_size = 64,
      order = "a-c",
      subgroup = "data-catalogue-biological",
      stack_size = 50,
      pictures = {
        {
          layers = {
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/biological-catalogue-3.png",
              scale = 0.5,
              size = 64
            },
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-catalogue-3.png",
              scale = 0.5,
              size = 64,
              draw_as_light = true
            }
          }
        }
      }
    },
    {
      type = "item",
      name = data_util.mod_prefix .. "biological-catalogue-4",
      icon = "__space-exploration-graphics__/graphics/icons/catalogue/biological-catalogue-4.png",
      icon_size = 64,
      order = "a-d",
      subgroup = "data-catalogue-biological",
      stack_size = 50,
      pictures = {
        {
          layers = {
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/biological-catalogue-4.png",
              scale = 0.5,
              size = 64
            },
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-catalogue-4.png",
              scale = 0.5,
              size = 64,
              draw_as_light = true
            }
          }
        }
      }
    },
    {
      type = "item",
      name = data_util.mod_prefix .. "biological-insight",
      icon = "__space-exploration-graphics__/graphics/icons/catalogue/biological-insight.png",
      icon_size = 64,
      order = "a-e",
      subgroup = "data-catalogue-biological",
      stack_size = 50,
      pictures = {
        {
          layers = {
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/biological-insight.png",
              scale = 0.5,
              size = 64
            },
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-insight.png",
              scale = 0.5,
              size = 64,
              draw_as_light = true
            }
          }
        }
      }
    },


    {
      type = "item",
      name = data_util.mod_prefix .. "energy-catalogue-1",
      icon = "__space-exploration-graphics__/graphics/icons/catalogue/energy-catalogue-1.png",
      icon_size = 64,
      order = "a-a",
      subgroup = "data-catalogue-energy",
      stack_size = 50,
      pictures = {
        {
          layers = {
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/energy-catalogue-1.png",
              scale = 0.5,
              size = 64
            },
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-catalogue-1.png",
              scale = 0.5,
              size = 64,
              draw_as_light = true
            }
          }
        }
      }
    },
    {
      type = "item",
      name = data_util.mod_prefix .. "energy-catalogue-2",
      icon = "__space-exploration-graphics__/graphics/icons/catalogue/energy-catalogue-2.png",
      icon_size = 64,
      order = "a-b",
      subgroup = "data-catalogue-energy",
      stack_size = 50,
      pictures = {
        {
          layers = {
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/energy-catalogue-2.png",
              scale = 0.5,
              size = 64
            },
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-catalogue-2.png",
              scale = 0.5,
              size = 64,
              draw_as_light = true
            }
          }
        }
      }
    },
    {
      type = "item",
      name = data_util.mod_prefix .. "energy-catalogue-3",
      icon = "__space-exploration-graphics__/graphics/icons/catalogue/energy-catalogue-3.png",
      icon_size = 64,
      order = "a-c",
      subgroup = "data-catalogue-energy",
      stack_size = 50,
      pictures = {
        {
          layers = {
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/energy-catalogue-3.png",
              scale = 0.5,
              size = 64
            },
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-catalogue-3.png",
              scale = 0.5,
              size = 64,
              draw_as_light = true
            }
          }
        }
      }
    },
    {
      type = "item",
      name = data_util.mod_prefix .. "energy-catalogue-4",
      icon = "__space-exploration-graphics__/graphics/icons/catalogue/energy-catalogue-4.png",
      icon_size = 64,
      order = "a-d",
      subgroup = "data-catalogue-energy",
      stack_size = 50,
      pictures = {
        {
          layers = {
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/energy-catalogue-4.png",
              scale = 0.5,
              size = 64
            },
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-catalogue-4.png",
              scale = 0.5,
              size = 64,
              draw_as_light = true
            }
          }
        }
      }
    },
    {
      type = "item",
      name = data_util.mod_prefix .. "energy-insight",
      icon = "__space-exploration-graphics__/graphics/icons/catalogue/energy-insight.png",
      icon_size = 64,
      order = "a-e",
      subgroup = "data-catalogue-energy",
      stack_size = 50,
      pictures = {
        {
          layers = {
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/energy-insight.png",
              scale = 0.5,
              size = 64
            },
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-insight.png",
              scale = 0.5,
              size = 64,
              draw_as_light = true
            }
          }
        }
      }
    },


    {
      type = "item",
      name = data_util.mod_prefix .. "material-catalogue-1",
      icon = "__space-exploration-graphics__/graphics/icons/catalogue/material-catalogue-1.png",
      icon_size = 64,
      order = "a-a",
      subgroup = "data-catalogue-material",
      stack_size = 50,
      pictures = {
        {
          layers = {
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/material-catalogue-1.png",
              scale = 0.5,
              size = 64
            },
            {
              filename ="__space-exploration-graphics__/graphics/icons/catalogue/mask-catalogue-1.png",
              scale = 0.25,
              size = 64,
              draw_as_light = true
            }
          }
        }
      }
    },
    {
      type = "item",
      name = data_util.mod_prefix .. "material-catalogue-2",
      icon = "__space-exploration-graphics__/graphics/icons/catalogue/material-catalogue-2.png",
      icon_size = 64,
      order = "a-b",
      subgroup = "data-catalogue-material",
      stack_size = 50,
      pictures = {
        {
          layers = {
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/material-catalogue-2.png",
              scale = 0.5,
              size = 64
            },
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-catalogue-2.png",
              scale = 0.5,
              size = 64,
              draw_as_light = true
            }
          }
        }
      }
    },
    {
      type = "item",
      name = data_util.mod_prefix .. "material-catalogue-3",
      icon = "__space-exploration-graphics__/graphics/icons/catalogue/material-catalogue-3.png",
      icon_size = 64,
      order = "a-c",
      subgroup = "data-catalogue-material",
      stack_size = 50,
      pictures = {
        {
          layers = {
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/material-catalogue-3.png",
              scale = 0.5,
              size = 64
            },
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-catalogue-3.png",
              scale = 0.5,
              size = 64,
              draw_as_light = true
            }
          }
        }
      }
    },
    {
      type = "item",
      name = data_util.mod_prefix .. "material-catalogue-4",
      icon = "__space-exploration-graphics__/graphics/icons/catalogue/material-catalogue-4.png",
      icon_size = 64,
      order = "a-d",
      subgroup = "data-catalogue-material",
      stack_size = 50,
      pictures = {
        {
          layers = {
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/material-catalogue-4.png",
              scale = 0.5,
              size = 64
            },
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-catalogue-4.png",
              scale = 0.5,
              size = 64,
              draw_as_light = true
            }
          }
        }
      }
    },
    {
      type = "item",
      name = data_util.mod_prefix .. "material-insight",
      icon = "__space-exploration-graphics__/graphics/icons/catalogue/material-insight.png",
      icon_size = 64,
      order = "a-e",
      subgroup = "data-catalogue-material",
      stack_size = 50,
      pictures = {
        {
          layers = {
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/material-insight.png",
              scale = 0.5,
              size = 64
            },
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-insight.png",
              scale = 0.5,
              size = 64,
              draw_as_light = true
            }
          }
        }
      }
    },



    {
      type = "item",
      name = data_util.mod_prefix .. "deep-catalogue-1",
      icons = {
        {icon = "__space-exploration-graphics__/graphics/icons/catalogue/base-catalogue-1.png", icon_size = 64},
        {icon = "__space-exploration-graphics__/graphics/icons/catalogue/mask-catalogue-1.png", icon_size = 64},
      },
      icon_size = 64,
      order = "a-a",
      subgroup = "data-catalogue-deep",
      stack_size = 50,
      pictures = {
        {
          layers = {
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/base-catalogue-1.png",
              scale = 0.5,
              size = 64
            },
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-catalogue-1.png",
              scale = 0.5,
              size = 64,
              draw_as_glow = true
            }
          }
        }
      }
    },
    {
      type = "item",
      name = data_util.mod_prefix .. "deep-catalogue-2",
      icons = {
        {icon = "__space-exploration-graphics__/graphics/icons/catalogue/base-catalogue-2.png", icon_size = 64},
        {icon = "__space-exploration-graphics__/graphics/icons/catalogue/mask-catalogue-2.png", icon_size = 64},
      },
      icon_size = 64,
      order = "a-b",
      subgroup = "data-catalogue-deep",
      stack_size = 50,
      pictures = {
        {
          layers = {
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/base-catalogue-2.png",
              scale = 0.5,
              size = 64
            },
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-catalogue-2.png",
              scale = 0.5,
              size = 64,
              draw_as_glow = true
            }
          }
        }
      }
    },
    {
      type = "item",
      name = data_util.mod_prefix .. "deep-catalogue-3",
      icons = {
        {icon = "__space-exploration-graphics__/graphics/icons/catalogue/base-catalogue-3.png", icon_size = 64},
        {icon = "__space-exploration-graphics__/graphics/icons/catalogue/mask-catalogue-3.png", icon_size = 64},
      },
      icon_size = 64,
      order = "a-c",
      subgroup = "data-catalogue-deep",
      stack_size = 50,
      pictures = {
        {
          layers = {
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/base-catalogue-3.png",
              scale = 0.5,
              size = 64
            },
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-catalogue-3.png",
              scale = 0.5,
              size = 64,
              draw_as_glow = true
            }
          }
        }
      }
    },
    {
      type = "item",
      name = data_util.mod_prefix .. "deep-catalogue-4",
      icons = {
        {icon = "__space-exploration-graphics__/graphics/icons/catalogue/base-catalogue-4.png", icon_size = 64},
        {icon = "__space-exploration-graphics__/graphics/icons/catalogue/mask-catalogue-4.png", icon_size = 64},
      },
      icon_size = 64,
      order = "a-d",
      subgroup = "data-catalogue-deep",
      stack_size = 50,
      pictures = {
        {
          layers = {
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/base-catalogue-4.png",
              scale = 0.5,
              size = 64
            },
            {
              filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-catalogue-4.png",
              scale = 0.5,
              size = 64,
              draw_as_glow = true
            }
          }
        }
      }
    },
    {
      type = "item",
      name = data_util.mod_prefix .. "nano-engineering-data",
      icon = "__space-exploration-graphics__/graphics/icons/data/nano-engineering.png",
      icon_size = 64,
      order = "a-a",
      subgroup = "data-deep",
      stack_size = 50,
    },
    {
      type = "item",
      name = data_util.mod_prefix .. "naquium-structural-data",
      icon = "__space-exploration-graphics__/graphics/icons/data/naquium-structural.png",
      icon_size = 64,
      order = "a-b",
      subgroup = "data-deep",
      stack_size = 50,
    },
    {
      type = "item",
      name = data_util.mod_prefix .. "naquium-energy-data",
      icon = "__space-exploration-graphics__/graphics/icons/data/naquium-energy.png",
      icon_size = 64,
      order = "a-c",
      subgroup = "data-deep",
      stack_size = 50,
    },
    {
      type = "item",
      name = data_util.mod_prefix .. "annihilation-data",
      icon = "__space-exploration-graphics__/graphics/icons/data/annihilation.png",
      icon_size = 64,
      order = "b-a",
      subgroup = "data-deep",
      stack_size = 50,
    },
    {
      type = "item",
      name = data_util.mod_prefix .. "hyperlattice-data",
      icon = "__space-exploration-graphics__/graphics/icons/data/hyperlattice.png",
      icon_size = 64,
      order = "b-b",
      subgroup = "data-deep",
      stack_size = 50,
    },
    {
      type = "item",
      name = data_util.mod_prefix .. "timespace-anomaly-data",
      icon = "__space-exploration-graphics__/graphics/icons/data/timespace-anomaly.png",
      icon_size = 64,
      order = "b-c",
      subgroup = "data-deep",
      stack_size = 50,
    },
    {
      type = "item",
      name = data_util.mod_prefix .. "singularity-data",
      icon = "__space-exploration-graphics__/graphics/icons/data/singularity.png",
      icon_size = 64,
      order = "b-d",
      subgroup = "data-deep",
      stack_size = 50,
    },
    {
      type = "item",
      name = data_util.mod_prefix .. "star-probe-data",
      icon = "__space-exploration-graphics__/graphics/icons/data/star-probe.png",
      icon_size = 64,
      order = "z",
      subgroup = "data-energy",
      stack_size = 50,
    },
    {
      type = "item",
      name = data_util.mod_prefix .. "belt-probe-data",
      icon = "__space-exploration-graphics__/graphics/icons/data/belt-probe.png",
      icon_size = 64,
      order = "z",
      subgroup = "data-astronomic",
      stack_size = 50,
    },
    {
      type = "item",
      name = data_util.mod_prefix .. "void-probe-data",
      icon = "__space-exploration-graphics__/graphics/icons/data/void-probe.png",
      icon_size = 64,
      order = "a-e",
      subgroup = "data-deep",
      stack_size = 50,
    },
    {
      type = "item",
      name = data_util.mod_prefix .. "space-fold-data",
      icon = "__space-exploration-graphics__/graphics/icons/data/space-fold.png",
      icon_size = 64,
      order = "c-a",
      subgroup = "data-deep",
      stack_size = 50,
    },
    {
      type = "item",
      name = data_util.mod_prefix .. "space-warp-data",
      icon = "__space-exploration-graphics__/graphics/icons/data/space-warp.png",
      icon_size = 64,
      order = "c-b",
      subgroup = "data-deep",
      stack_size = 50,
    },
    {
      type = "item",
      name = data_util.mod_prefix .. "space-dilation-data",
      icon = "__space-exploration-graphics__/graphics/icons/data/space-dilation.png",
      icon_size = 64,
      order = "c-c",
      subgroup = "data-deep",
      stack_size = 50,
    },
    {
      type = "item",
      name = data_util.mod_prefix .. "space-injection-data",
      icon = "__space-exploration-graphics__/graphics/icons/data/space-injection.png",
      icon_size = 64,
      order = "c-d",
      subgroup = "data-deep",
      stack_size = 50,
    },
    {
      type = "item",
      name = data_util.mod_prefix .. "interstellar-data",
      icon = "__space-exploration-graphics__/graphics/icons/data/interstellar.png",
      icon_size = 64,
      order = "d-a",
      subgroup = "data-deep",
      stack_size = 50,
    },
    {
      type = "item",
      name = data_util.mod_prefix .. "teleportation-data",
      icon = "__space-exploration-graphics__/graphics/icons/data/teleportation.png",
      icon_size = 64,
      order = "d-b",
      subgroup = "data-deep",
      stack_size = 50,
    },
    {
      type = "item",
      name = data_util.mod_prefix .. "wormhole-data",
      icon = "__space-exploration-graphics__/graphics/icons/data/wormhole.png",
      icon_size = 64,
      order = "d-c",
      subgroup = "data-deep",
      stack_size = 50,
    },
    {
      type = "item",
      name = data_util.mod_prefix .. "rhga-data",
      icon = "__space-exploration-graphics__/graphics/icons/data/rhga.png",
      icon_size = 64,
      order = "d-d",
      subgroup = "data-deep",
      stack_size = 50,
    },

    {
      type = "item",
      name = data_util.mod_prefix .. "star-probe",
      icons = {
          { icon = "__space-exploration-graphics__/graphics/icons/satellite.png", icon_size = 64},
          { icon = "__space-exploration-graphics__/graphics/icons/satellite-mask.png", icon_size = 64, tint = {r=1,g=0,b=0.5}},
      },
      icon_size = 64,
      order = "z",
      subgroup = "data-energy",
      stack_size = 1,
      rocket_launch_products = {{type = "item", name = data_util.mod_prefix .. "star-probe-data", amount = 1000}},
      weight = 1 * tons,
      send_to_orbit_mode = "automated"
    },
    {
      type = "item",
      name = data_util.mod_prefix .. "belt-probe",
      icons = {
          { icon = "__space-exploration-graphics__/graphics/icons/satellite.png", icon_size = 64 },
          { icon = "__space-exploration-graphics__/graphics/icons/satellite-mask.png", icon_size = 64, tint = {r=0,g=0.5,b=1}},
      },
      icon_size = 64,
      order = "z",
      subgroup = "data-astronomic",
      stack_size = 1,
      rocket_launch_products = {{type = "item", name = data_util.mod_prefix .. "belt-probe-data", amount = 1000}},
      weight = 1 * tons,
      send_to_orbit_mode = "automated"
    },
    {
      type = "item",
      name = data_util.mod_prefix .. "void-probe",
      icons = {
          { icon = "__space-exploration-graphics__/graphics/icons/satellite.png", icon_size = 64 },
          { icon = "__space-exploration-graphics__/graphics/icons/satellite-mask.png", icon_size = 64, tint = {r=0.1,g=0,b=0.5}},
      },
      icon_size = 64,
      order = "a-d",
      subgroup = "data-deep",
      stack_size = 1,
      rocket_launch_products = {{type = "item", name = data_util.mod_prefix .. "void-probe-data", amount = 1000}},
      weight = 1 * tons,
      send_to_orbit_mode = "automated"
    },

})
