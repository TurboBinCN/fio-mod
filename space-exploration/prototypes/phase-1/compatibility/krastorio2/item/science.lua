-- Remove rocket launch product from Optimization Tech Card
data.raw.tool["kr-optimization-tech-card"].rocket_launch_product = nil

---- Matter Science Pack
-- Data Cards Items
data.raw.item["kr-matter-research-data"].subgroup = "data-matter"
data.raw.item["kr-matter-research-data"].icon = "__space-exploration-graphics__/graphics/compatability/icons/matter-analysis.png"
data.raw.item["kr-matter-research-data"].stack_size = 50
local matter_synthesis_data = {
  type = "item",
  name = "se-kr-matter-synthesis-data",
  icon = "__space-exploration-graphics__/graphics/compatability/icons/matter-synthesis.png",
  icon_size = 64,
  order = "a-b",
  subgroup = "data-matter",
  stack_size = 50,
}
data:extend({matter_synthesis_data})
local matter_liberation_data = {
  type = "item",
  name = "se-kr-matter-liberation-data",
  icon = "__space-exploration-graphics__/graphics/compatability/icons/matter-liberation.png",
  icon_size = 64,
  order = "a-b",
  subgroup = "data-matter",
  stack_size = 50,
}
data:extend({matter_liberation_data})
local matter_containment_data = {
  type = "item",
  name = "se-kr-matter-containment-data",
  icon = "__space-exploration-graphics__/graphics/compatability/icons/matter-containment.png",
  icon_size = 64,
  order = "a-b",
  subgroup = "data-matter",
  stack_size = 50,
}
data:extend({matter_containment_data})

local matter_manipulation_data = {
  type = "item",
  name = "se-kr-matter-manipulation-data",
  icon = "__space-exploration-graphics__/graphics/compatability/icons/matter-manipulation.png",
  icon_size = 64,
  order = "b-c",
  subgroup = "data-matter",
  stack_size = 50,
}
data:extend({matter_manipulation_data})
local matter_recombinaion_data = {
  type = "item",
  name = "se-kr-matter-recombination-data",
  icon = "__space-exploration-graphics__/graphics/compatability/icons/matter-recombination.png",
  icon_size = 64,
  order = "b-c",
  subgroup = "data-matter",
  stack_size = 50,
}
data:extend({matter_recombinaion_data})
local matter_stabilization_data = {
  type = "item",
  name = "se-kr-matter-stabilization-data",
  icon = "__space-exploration-graphics__/graphics/compatability/icons/matter-stabilization.png",
  icon_size = 64,
  order = "b-c",
  subgroup = "data-matter",
  stack_size = 50,
}
data:extend({matter_stabilization_data})
local matter_utilization_data = {
  type = "item",
  name = "se-kr-matter-utilization-data",
  icon = "__space-exploration-graphics__/graphics/compatability/icons/matter-utilization.png",
  icon_size = 64,
  order = "b-c",
  subgroup = "data-matter",
  stack_size = 50,
}
data:extend({matter_utilization_data})

-- Matter Science Pack Tint
local matter_pack_tint = {r = 255, g = 51, b = 151}

-- Catalogue items
local matter_catalogue = {
  type = "item",
  name = "se-kr-matter-catalogue-1",
  icons = {
    {icon = "__space-exploration-graphics__/graphics/icons/catalogue/base-catalogue-1.png", icon_size = 64},
    {icon = "__space-exploration-graphics__/graphics/icons/catalogue/mask-catalogue-1.png", icon_size = 64, tint = matter_pack_tint},
  },
  order = "a-b",
  subgroup = "data-catalogue-matter",
  stack_size = 50,
  pictures = {
    {
      layers = {
        {
          filename = "__space-exploration-graphics__/graphics/icons/catalogue/base-catalogue-1.png",
          scale = 0.25,
          size = 64,
        },
        {
          filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-catalogue-1.png",
          scale = 0.25,
          size = 64,
          draw_as_glow = true,
          tint = matter_pack_tint
        }
      }
    }
  }
}
data:extend({matter_catalogue})

local matter_catalogue_2 = {
  type = "item",
  name = "se-kr-matter-catalogue-2",
  icons = {
    {icon = "__space-exploration-graphics__/graphics/icons/catalogue/base-catalogue-2.png", icon_size = 64},
    {icon = "__space-exploration-graphics__/graphics/icons/catalogue/mask-catalogue-2.png", icon_size = 64, tint = matter_pack_tint},
  },
  order = "a-b",
  subgroup = "data-catalogue-matter",
  stack_size = 50,
  pictures = {
    {
      layers = {
        {
          filename = "__space-exploration-graphics__/graphics/icons/catalogue/base-catalogue-2.png",
          scale = 0.25,
          size = 64,
        },
        {
          filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-catalogue-2.png",
          scale = 0.25,
          size = 64,
          draw_as_glow = true,
          tint = matter_pack_tint
        }
      }
    }
  }
}
data:extend({matter_catalogue_2})
-- Science Pack Items
local matter_science_pack_1 = data.raw.tool["kr-matter-tech-card"]
matter_science_pack_1.subgroup = "matter-science-pack"
matter_science_pack_1.order = "m[matter-science-pack-1]-a"
matter_science_pack_1.icon = nil
matter_science_pack_1.icon_size = nil
matter_science_pack_1.icons = {
  {icon = "__space-exploration-graphics__/graphics/icons/catalogue/deep-2.png", icon_size = 64},
  {icon = "__space-exploration-graphics__/graphics/icons/catalogue/mask-2.png", icon_size = 64, tint = matter_pack_tint}
}
matter_science_pack_1.pictures = {
  {
    layers = {
      {
        filename = "__space-exploration-graphics__/graphics/icons/catalogue/deep-2.png",
        scale = 0.25,
        size = 64
      },
      {
        filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-2.png",
        scale = 0.25,
        size = 64,
        draw_as_glow = true,
        tint = matter_pack_tint
      }
    }
  }
}

local matter_science_pack_2 = table.deepcopy(data.raw.tool["kr-matter-tech-card"])
matter_science_pack_2.name = "se-kr-matter-science-pack-2"
matter_science_pack_2.order = "m[matter-science-pack-2]-b"
matter_science_pack_2.icons = {
  {icon = "__space-exploration-graphics__/graphics/icons/catalogue/deep-3.png", icon_size = 64},
  {icon = "__space-exploration-graphics__/graphics/icons/catalogue/mask-3.png", icon_size = 64, tint = matter_pack_tint}
}
matter_science_pack_2.pictures = {
  {
    layers = {
      {
        filename = "__space-exploration-graphics__/graphics/icons/catalogue/deep-3.png",
        scale = 0.25,
        size = 64
      },
      {
        filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-3.png",
        scale = 0.25,
        size = 64,
        draw_as_glow = true,
        tint = matter_pack_tint
      }
    }
  }
}
data:extend({matter_science_pack_2})

local advanced_pack_tint = {r = 133, g = 33, b = 209}
local adv_pack = data.raw.tool["kr-advanced-tech-card"]
local sing_pack = data.raw.tool["kr-singularity-tech-card"]

adv_pack.subgroup = "advanced-science-pack"
adv_pack.order = "l[advanced-science-pack-1]-a"
adv_pack.icon = nil
adv_pack.icon_size = nil
adv_pack.icons = {
  {icon = "__space-exploration-graphics__/graphics/icons/catalogue/deep-2.png", icon_size = 64},
  {icon = "__space-exploration-graphics__/graphics/icons/catalogue/mask-2.png", icon_size = 64, tint = advanced_pack_tint}
}
adv_pack.pictures = {
  {
    layers = {
      {
        filename = "__space-exploration-graphics__/graphics/icons/catalogue/deep-2.png",
        scale = 0.25,
        size = 64
      },
      {
        filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-2.png",
        scale = 0.25,
        size = 64,
        draw_as_glow = true,
        tint = advanced_pack_tint
      }
    }
  }
}

sing_pack.subgroup = "advanced-science-pack"
sing_pack.order = "l[advanced-science-pack-2]-a"
sing_pack.icon = nil
sing_pack.icon_size = nil
sing_pack.icons = {
  {icon = "__space-exploration-graphics__/graphics/icons/catalogue/deep-3.png", icon_size = 64},
  {icon = "__space-exploration-graphics__/graphics/icons/catalogue/mask-3.png", icon_size = 64, tint = advanced_pack_tint}
}
sing_pack.pictures = {
  {
    layers = {
      {
        filename = "__space-exploration-graphics__/graphics/icons/catalogue/deep-3.png",
        scale = 0.25,
        size = 64
      },
      {
        filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-3.png",
        scale = 0.25,
        size = 64,
        draw_as_glow = true,
        tint = advanced_pack_tint
      }
    }
  }
}

-- Catalogue items
local adv_catalogue = {
  type = "item",
  name = "se-kr-advanced-catalogue-1",
  icons = {
    {icon = "__space-exploration-graphics__/graphics/icons/catalogue/base-catalogue-1.png", icon_size = 64},
    {icon = "__space-exploration-graphics__/graphics/icons/catalogue/mask-catalogue-1.png", icon_size = 64, tint = advanced_pack_tint},
  },
  order = "a-b",
  subgroup = "data-catalogue-advanced",
  stack_size = 50,
  pictures = {
    {
      layers = {
        {
          filename = "__space-exploration-graphics__/graphics/icons/catalogue/base-catalogue-1.png",
          scale = 0.25,
          size = 64,
        },
        {
          filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-catalogue-1.png",
          scale = 0.25,
          size = 64,
          draw_as_glow = true,
          tint = advanced_pack_tint
        }
      }
    }
  }
}
data:extend({adv_catalogue})

local adv_catalogue_2 = {
  type = "item",
  name = "se-kr-advanced-catalogue-2",
  icons = {
    {icon = "__space-exploration-graphics__/graphics/icons/catalogue/base-catalogue-2.png", icon_size = 64},
    {icon = "__space-exploration-graphics__/graphics/icons/catalogue/mask-catalogue-2.png", icon_size = 64, tint = advanced_pack_tint},
  },
  order = "a-b",
  subgroup = "data-catalogue-advanced",
  stack_size = 50,
  pictures = {
    {
      layers = {
        {
          filename = "__space-exploration-graphics__/graphics/icons/catalogue/base-catalogue-2.png",
          scale = 0.25,
          size = 64,
        },
        {
          filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-catalogue-2.png",
          scale = 0.25,
          size = 64,
          draw_as_glow = true,
          tint = advanced_pack_tint
        }
      }
    }
  }
}
data:extend({adv_catalogue_2})

local combi_catalogue = {
  type = "item",
  name = "se-kr-combined-catalogue",
  icons = {
    {icon = "__space-exploration-graphics__/graphics/icons/catalogue/universal-catalogue.png", icon_size = 64}
  },
  order = "a-b",
  subgroup = "data-catalogue-advanced",
  stack_size = 50,
  pictures = {
    {
      layers = {
        {
          filename = "__space-exploration-graphics__/graphics/icons/catalogue/universal-catalogue.png",
          scale = 0.25,
          size = 64,
        }
      }
    }
  }
}
data:extend({combi_catalogue})

local power_density_data = {
  type = "item",
  name = "se-kr-power-density-data",
  icon = "__space-exploration-graphics__/graphics/compatability/icons/power-density.png",
  icon_size = 64,
  order = "a-a",
  subgroup = "data-advanced",
  stack_size = 50,
}
local quantum_computation_data = {
  type = "item",
  name = "se-kr-quantum-computation-data",
  icon = "__space-exploration-graphics__/graphics/compatability/icons/quantum-computation.png",
  icon_size = 64,
  order = "a-b",
  subgroup = "data-advanced",
  stack_size = 50,
}
local remote_sensing_data = {
  type = "item",
  name = "se-kr-remote-sensing-data",
  icon = "__space-exploration-graphics__/graphics/compatability/icons/remote-sensing.png",
  icon_size = 64,
  order = "a-d",
  subgroup = "data-advanced",
  stack_size = 50,
}
local remote_probe = table.deepcopy(data.raw.item["se-star-probe"])
remote_probe.name = "se-kr-remote-probe"
remote_probe.order = "a-c"
remote_probe.icons = {
  { icon = "__space-exploration-graphics__/graphics/icons/satellite.png", icon_size = 64},
  { icon = "__space-exploration-graphics__/graphics/icons/satellite-mask.png", icon_size = 64, tint = advanced_pack_tint},
}
remote_probe.subgroup = "data-advanced"
remote_probe.rocket_launch_products = {{type = "item", name = "se-kr-remote-sensing-data", amount = 1000}}

local macroscale_entanglement_data = {
  type = "item",
  name = "se-kr-macroscale-entanglement-data",
  icon = "__space-exploration-graphics__/graphics/compatability/icons/macroscale-entanglement.png",
  icon_size = 64,
  order = "b-a-a",
  subgroup = "data-advanced",
  stack_size = 50,
}
local timespace_manipulation_data = {
  type = "item",
  name = "se-kr-timespace-manipulation-data",
  icon = "__space-exploration-graphics__/graphics/compatability/icons/timespace-manipulation.png",
  icon_size = 64,
  order = "b-b-a",
  subgroup = "data-advanced",
  stack_size = 50,
}
local singularity_application_data = {
  type = "item",
  name = "se-kr-singularity-application-data",
  icon = "__space-exploration-graphics__/graphics/compatability/icons/singularity-application.png",
  icon_size = 64,
  order = "b-c-a",
  subgroup = "data-advanced",
  stack_size = 50,
}
data:extend({power_density_data,quantum_computation_data,remote_sensing_data,remote_probe,macroscale_entanglement_data,timespace_manipulation_data,singularity_application_data})
