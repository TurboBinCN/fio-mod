local data_util = require("data_util")

data.raw.tool["production-science-pack"].order = "f[production-science-pack]"
data.raw.tool["production-science-pack"].icons = {
  {icon = "__space-exploration-graphics__/graphics/icons/catalogue/deep-2.png", icon_size = 64},
  {icon = "__space-exploration-graphics__/graphics/icons/catalogue/mask-2.png", icon_size = 64, tint = data_util.production_science_tint},
}
data.raw.tool["production-science-pack"].pictures = {
  {
    layers = {
      {
        filename = "__space-exploration-graphics__/graphics/icons/catalogue/deep-2.png",
        scale = 0.5,
        size = 64
      },
      {
        filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-2.png", tint = data_util.production_science_tint,
        scale = 0.5,
        size = 64,
        draw_as_glow = true -- normally only the deep space sciences have glow instead of light, but that just looks purple for this one
      }
    }
  }
}

data.raw.tool["utility-science-pack"].order = "g[utility-science-pack]"
data.raw.tool["utility-science-pack"].icons = {
  {icon = "__space-exploration-graphics__/graphics/icons/catalogue/deep-2.png", icon_size = 64},
  {icon = "__space-exploration-graphics__/graphics/icons/catalogue/mask-2.png", icon_size = 64, tint = data_util.utility_science_tint},
}
data.raw.tool["utility-science-pack"].pictures = {
  {
    layers = {
      {
        filename = "__space-exploration-graphics__/graphics/icons/catalogue/deep-2.png",
        scale = 0.5,
        size = 64
      },
      {
        filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-2.png", tint = data_util.utility_science_tint,
        scale = 0.5,
        size = 64,
        draw_as_glow = true -- normally only the deep space sciences have glow instead of light, but that just looks purple for this one
      }
    }
  }
}

data.raw.tool["space-science-pack"].order = "e[space-science-pack]-b"
data.raw.tool["space-science-pack"].icons = {
  {icon = "__space-exploration-graphics__/graphics/icons/catalogue/deep-1.png", icon_size = 64},
  {icon = "__space-exploration-graphics__/graphics/icons/catalogue/mask-1.png", icon_size = 64},
}
data.raw.tool["space-science-pack"].stack_size = 200
data.raw.tool["space-science-pack"].pictures = {
  {
    layers = {
      {
        filename = "__space-exploration-graphics__/graphics/icons/catalogue/deep-1.png",
        scale = 0.5,
        size = 64
      },
      {
        filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-1.png",
        scale = 0.5,
        size = 64,
        draw_as_glow = true -- normally only the deep space sciences have glow instead of light, but that just looks purple for this one
      }
    }
  }
}

--taken from vanilla science pack sound definitions
local inventory_sound = {
  aggregation = {
    max_count = 1,
    remove = true
  },
  filename = "__base__/sound/item/science-inventory-move.ogg",
  volume = 0.6
}

data:extend({
  {
    type = "tool",
    name = data_util.mod_prefix .. "rocket-science-pack",
    subgroup = "science-pack",
    durability = 1,
    durability_description_key = "description.science-pack-remaining-amount-key",
    durability_description_value = "description.science-pack-remaining-amount-value",
    icon = "__space-exploration-graphics__/graphics/icons/beaker/orange.png",
    icon_size = 64,
    order = "e[space-science-pack]-a",
    stack_size = 200,
    pick_sound = inventory_sound,
    drop_sound = inventory_sound,
    inventory_move_sound = inventory_sound,
  },
  {
    type = "tool",
    name = data_util.mod_prefix .. "astronomic-science-pack-1",
    subgroup = "astronomic-science-pack",
    durability = 1,
    durability_description_key = "description.science-pack-remaining-amount-key",
    durability_description_value = "description.science-pack-remaining-amount-value",
    icon = "__space-exploration-graphics__/graphics/icons/catalogue/astronomic-1.png",
    icon_size = 64,
    order = "h[astronomic-science-pack-1]-a",
    stack_size = 200,
    pick_sound = inventory_sound,
    drop_sound = inventory_sound,
    inventory_move_sound = inventory_sound,
    pictures = {
      {
        layers = {
          {
            filename = "__space-exploration-graphics__/graphics/icons/catalogue/astronomic-1.png",
            scale = 0.5,
            size = 64
          },
          {
            filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-1.png",
            scale = 0.5,
            size = 64,
            draw_as_light = true
          }
        }
      }
    }
  },
  {
    type = "tool",
    name = data_util.mod_prefix .. "astronomic-science-pack-2",
    subgroup = "astronomic-science-pack",
    durability = 1,
    durability_description_key = "description.science-pack-remaining-amount-key",
    durability_description_value = "description.science-pack-remaining-amount-value",
    icon = "__space-exploration-graphics__/graphics/icons/catalogue/astronomic-2.png",
    icon_size = 64,
    order = "h[astronomic-science-pack-2]-b",
    stack_size = 200,
    pick_sound = inventory_sound,
    drop_sound = inventory_sound,
    inventory_move_sound = inventory_sound,
    pictures = {
      {
        layers = {
          {
            filename = "__space-exploration-graphics__/graphics/icons/catalogue/astronomic-2.png",
            scale = 0.5,
            size = 64
          },
          {
            filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-2.png",
            scale = 0.5,
            size = 64,
            draw_as_light = true
          }
        }
      }
    }
  },
  {
    type = "tool",
    name = data_util.mod_prefix .. "astronomic-science-pack-3",
    subgroup = "astronomic-science-pack",
    durability = 1,
    durability_description_key = "description.science-pack-remaining-amount-key",
    durability_description_value = "description.science-pack-remaining-amount-value",
    icon = "__space-exploration-graphics__/graphics/icons/catalogue/astronomic-3.png",
    icon_size = 64,
    order = "h[astronomic-science-pack-3]-c",
    stack_size = 200,
    pick_sound = inventory_sound,
    drop_sound = inventory_sound,
    inventory_move_sound = inventory_sound,
    pictures = {
      {
        layers = {
          {
            filename = "__space-exploration-graphics__/graphics/icons/catalogue/astronomic-3.png",
            scale = 0.5,
            size = 64
          },
          {
            filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-3.png",
            scale = 0.5,
            size = 64,
            draw_as_light = true
          }
        }
      }
    }
  },
  {
    type = "tool",
    name = data_util.mod_prefix .. "astronomic-science-pack-4",
    subgroup = "astronomic-science-pack",
    durability = 1,
    durability_description_key = "description.science-pack-remaining-amount-key",
    durability_description_value = "description.science-pack-remaining-amount-value",
    icon = "__space-exploration-graphics__/graphics/icons/catalogue/astronomic-4.png",
    icon_size = 64,
    order = "h[astronomic-science-pack-4]-d",
    stack_size = 200,
    pick_sound = inventory_sound,
    drop_sound = inventory_sound,
    inventory_move_sound = inventory_sound,
    pictures = {
      {
        layers = {
          {
            filename = "__space-exploration-graphics__/graphics/icons/catalogue/astronomic-4.png",
            scale = 0.5,
            size = 64
          },
          {
            filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-4.png",
            scale = 0.5,
            size = 64,
            draw_as_light = true
          }
        }
      }
    }
  },
  {
    type = "tool",
    name = data_util.mod_prefix .. "biological-science-pack-1",
    subgroup = "biological-science-pack",
    durability = 1,
    durability_description_key = "description.science-pack-remaining-amount-key",
    durability_description_value = "description.science-pack-remaining-amount-value",
    icon = "__space-exploration-graphics__/graphics/icons/catalogue/biological-1.png",
    icon_size = 64,
    order = "i[biological-science-pack-1]-a",
    stack_size = 200,
    pick_sound = inventory_sound,
    drop_sound = inventory_sound,
    inventory_move_sound = inventory_sound,
    pictures = {
      {
        layers = {
          {
            filename = "__space-exploration-graphics__/graphics/icons/catalogue/biological-1.png",
            scale = 0.5,
            size = 64
          },
          {
            filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-1.png",
            scale = 0.5,
            size = 64,
            draw_as_light = true
          }
        }
      }
    }
  },
  {
    type = "tool",
    name = data_util.mod_prefix .. "biological-science-pack-2",
    subgroup = "biological-science-pack",
    durability = 1,
    durability_description_key = "description.science-pack-remaining-amount-key",
    durability_description_value = "description.science-pack-remaining-amount-value",
    icon = "__space-exploration-graphics__/graphics/icons/catalogue/biological-2.png",
    icon_size = 64,
    order = "i[biological-science-pack-2]-b",
    stack_size = 200,
    pick_sound = inventory_sound,
    drop_sound = inventory_sound,
    inventory_move_sound = inventory_sound,
    pictures = {
      {
        layers = {
          {
            filename = "__space-exploration-graphics__/graphics/icons/catalogue/biological-2.png",
            scale = 0.5,
            size = 64
          },
          {
            filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-2.png",
            scale = 0.5,
            size = 64,
            draw_as_light = true
          }
        }
      }
    }
  },
  {
    type = "tool",
    name = data_util.mod_prefix .. "biological-science-pack-3",
    subgroup = "biological-science-pack",
    durability = 1,
    durability_description_key = "description.science-pack-remaining-amount-key",
    durability_description_value = "description.science-pack-remaining-amount-value",
    icon = "__space-exploration-graphics__/graphics/icons/catalogue/biological-3.png",
    icon_size = 64,
    order = "i[biological-science-pack-3]-c",
    stack_size = 200,
    pick_sound = inventory_sound,
    drop_sound = inventory_sound,
    inventory_move_sound = inventory_sound,
    pictures = {
      {
        layers = {
          {
            filename = "__space-exploration-graphics__/graphics/icons/catalogue/biological-3.png",
            scale = 0.5,
            size = 64
          },
          {
            filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-3.png",
            scale = 0.5,
            size = 64,
            draw_as_light = true
          }
        }
      }
    }
  },
  {
    type = "tool",
    name = data_util.mod_prefix .. "biological-science-pack-4",
    subgroup = "biological-science-pack",
    durability = 1,
    durability_description_key = "description.science-pack-remaining-amount-key",
    durability_description_value = "description.science-pack-remaining-amount-value",
    icon = "__space-exploration-graphics__/graphics/icons/catalogue/biological-4.png",
    icon_size = 64,
    order = "i[biological-science-pack-4]-d",
    stack_size = 200,
    pick_sound = inventory_sound,
    drop_sound = inventory_sound,
    inventory_move_sound = inventory_sound,
    pictures = {
      {
        layers = {
          {
            filename = "__space-exploration-graphics__/graphics/icons/catalogue/biological-4.png",
            scale = 0.5,
            size = 64
          },
          {
            filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-4.png",
            scale = 0.5,
            size = 64,
            draw_as_light = true
          }
        }
      }
    }
  },
  {
    type = "tool",
    name = data_util.mod_prefix .. "energy-science-pack-1",
    subgroup = "energy-science-pack",
    durability = 1,
    durability_description_key = "description.science-pack-remaining-amount-key",
    durability_description_value = "description.science-pack-remaining-amount-value",
    icon = "__space-exploration-graphics__/graphics/icons/catalogue/energy-1.png",
    icon_size = 64,
    order = "j[energy-science-pack-1]-a",
    stack_size = 200,
    pick_sound = inventory_sound,
    drop_sound = inventory_sound,
    inventory_move_sound = inventory_sound,
    pictures = {
      {
        layers = {
          {
            filename = "__space-exploration-graphics__/graphics/icons/catalogue/energy-1.png",
            scale = 0.5,
            size = 64
          },
          {
            filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-1.png",
            scale = 0.5,
            size = 64,
            draw_as_light = true
          }
        }
      }
    }
  },
  {
    type = "tool",
    name = data_util.mod_prefix .. "energy-science-pack-2",
    subgroup = "energy-science-pack",
    durability = 1,
    durability_description_key = "description.science-pack-remaining-amount-key",
    durability_description_value = "description.science-pack-remaining-amount-value",
    icon = "__space-exploration-graphics__/graphics/icons/catalogue/energy-2.png",
    icon_size = 64,
    order = "j[energy-science-pack-2]-b",
    stack_size = 200,
    pick_sound = inventory_sound,
    drop_sound = inventory_sound,
    inventory_move_sound = inventory_sound,
    pictures = {
      {
        layers = {
          {
            filename = "__space-exploration-graphics__/graphics/icons/catalogue/energy-2.png",
            scale = 0.5,
            size = 64
          },
          {
            filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-2.png",
            scale = 0.5,
            size = 64,
            draw_as_light = true
          }
        }
      }
    }
  },
  {
    type = "tool",
    name = data_util.mod_prefix .. "energy-science-pack-3",
    subgroup = "energy-science-pack",
    durability = 1,
    durability_description_key = "description.science-pack-remaining-amount-key",
    durability_description_value = "description.science-pack-remaining-amount-value",
    icon = "__space-exploration-graphics__/graphics/icons/catalogue/energy-3.png",
    icon_size = 64,
    order = "j[energy-science-pack-3]-c",
    stack_size = 200,
    pick_sound = inventory_sound,
    drop_sound = inventory_sound,
    inventory_move_sound = inventory_sound,
    pictures = {
      {
        layers = {
          {
            filename = "__space-exploration-graphics__/graphics/icons/catalogue/energy-3.png",
            scale = 0.5,
            size = 64
          },
          {
            filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-3.png",
            scale = 0.5,
            size = 64,
            draw_as_light = true
          }
        }
      }
    }
  },
  {
    type = "tool",
    name = data_util.mod_prefix .. "energy-science-pack-4",
    subgroup = "energy-science-pack",
    durability = 1,
    durability_description_key = "description.science-pack-remaining-amount-key",
    durability_description_value = "description.science-pack-remaining-amount-value",
    icon = "__space-exploration-graphics__/graphics/icons/catalogue/energy-4.png",
    icon_size = 64,
    order = "j[energy-science-pack-4]-d",
    stack_size = 200,
    pick_sound = inventory_sound,
    drop_sound = inventory_sound,
    inventory_move_sound = inventory_sound,
    pictures = {
      {
        layers = {
          {
            filename = "__space-exploration-graphics__/graphics/icons/catalogue/energy-4.png",
            scale = 0.5,
            size = 64
          },
          {
            filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-4.png",
            scale = 0.5,
            size = 64,
            draw_as_light = true
          }
        }
      }
    }
  },
  {
    type = "tool",
    name = data_util.mod_prefix .. "material-science-pack-1",
    subgroup = "material-science-pack",
    durability = 1,
    durability_description_key = "description.science-pack-remaining-amount-key",
    durability_description_value = "description.science-pack-remaining-amount-value",
    icon = "__space-exploration-graphics__/graphics/icons/catalogue/material-1.png",
    icon_size = 64,
    order = "k[material-science-pack-1]-a",
    stack_size = 200,
    pick_sound = inventory_sound,
    drop_sound = inventory_sound,
    inventory_move_sound = inventory_sound,
    pictures = {
      {
        layers = {
          {
            filename = "__space-exploration-graphics__/graphics/icons/catalogue/material-1.png",
            scale = 0.5,
            size = 64
          },
          {
            filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-1.png",
            scale = 0.5,
            size = 64,
            draw_as_light = true
          }
        }
      }
    }
  },
  {
    type = "tool",
    name = data_util.mod_prefix .. "material-science-pack-2",
    subgroup = "material-science-pack",
    durability = 1,
    durability_description_key = "description.science-pack-remaining-amount-key",
    durability_description_value = "description.science-pack-remaining-amount-value",
    icon = "__space-exploration-graphics__/graphics/icons/catalogue/material-2.png",
    icon_size = 64,
    order = "k[material-science-pack-2]-b",
    stack_size = 200,
    pick_sound = inventory_sound,
    drop_sound = inventory_sound,
    inventory_move_sound = inventory_sound,
    pictures = {
      {
        layers = {
          {
            filename = "__space-exploration-graphics__/graphics/icons/catalogue/material-2.png",
            scale = 0.5,
            size = 64
          },
          {
            filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-2.png",
            scale = 0.5,
            size = 64,
            draw_as_light = true
          }
        }
      }
    }
  },
  {
    type = "tool",
    name = data_util.mod_prefix .. "material-science-pack-3",
    subgroup = "material-science-pack",
    durability = 1,
    durability_description_key = "description.science-pack-remaining-amount-key",
    durability_description_value = "description.science-pack-remaining-amount-value",
    icon = "__space-exploration-graphics__/graphics/icons/catalogue/material-3.png",
    icon_size = 64,
    order = "k[material-science-pack-3]-c",
    stack_size = 200,
    pick_sound = inventory_sound,
    drop_sound = inventory_sound,
    inventory_move_sound = inventory_sound,
    pictures = {
      {
        layers = {
          {
            filename = "__space-exploration-graphics__/graphics/icons/catalogue/material-3.png",
            scale = 0.5,
            size = 64
          },
          {
            filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-3.png",
            scale = 0.5,
            size = 64,
            draw_as_light = true
          }
        }
      }
    }
  },
  {
    type = "tool",
    name = data_util.mod_prefix .. "material-science-pack-4",
    subgroup = "material-science-pack",
    durability = 1,
    durability_description_key = "description.science-pack-remaining-amount-key",
    durability_description_value = "description.science-pack-remaining-amount-value",
    icon = "__space-exploration-graphics__/graphics/icons/catalogue/material-4.png",
    icon_size = 64,
    order = "k[material-science-pack-4]-d",
    stack_size = 200,
    pick_sound = inventory_sound,
    drop_sound = inventory_sound,
    inventory_move_sound = inventory_sound,
    pictures = {
      {
        layers = {
          {
            filename = "__space-exploration-graphics__/graphics/icons/catalogue/material-4.png",
            scale = 0.5,
            size = 64
          },
          {
            filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-4.png",
            scale = 0.5,
            size = 64,
            draw_as_light = true
          }
        }
      }
    }
  },
  {
    type = "tool",
    name = data_util.mod_prefix .. "deep-space-science-pack-1",
    subgroup = "deep-science-pack",
    durability = 1,
    durability_description_key = "description.science-pack-remaining-amount-key",
    durability_description_value = "description.science-pack-remaining-amount-value",
    icon = "__space-exploration-graphics__/graphics/icons/catalogue/deep-1.png",
    icon_size = 64,
    order = "s[space-platform-science-pack-1]-a",
    stack_size = 200,
    pick_sound = inventory_sound,
    drop_sound = inventory_sound,
    inventory_move_sound = inventory_sound,
    pictures = {
      {
        layers = {
          {
            filename = "__space-exploration-graphics__/graphics/icons/catalogue/deep-1.png",
            scale = 0.5,
            size = 64
          },
          {
            filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-1.png",
            scale = 0.5,
            size = 64,
            tint = {r=50,g=0,b=150},
            draw_as_glow = true
          }
        }
      }
    }
  },
  {
    type = "tool",
    name = data_util.mod_prefix .. "deep-space-science-pack-2",
    subgroup = "deep-science-pack",
    durability = 1,
    durability_description_key = "description.science-pack-remaining-amount-key",
    durability_description_value = "description.science-pack-remaining-amount-value",
    icon = "__space-exploration-graphics__/graphics/icons/catalogue/deep-2.png",
    icon_size = 64,
    order = "s[space-platform-science-pack-2]-b",
    stack_size = 200,
    pick_sound = inventory_sound,
    drop_sound = inventory_sound,
    inventory_move_sound = inventory_sound,
    pictures = {
      {
        layers = {
          {
            filename = "__space-exploration-graphics__/graphics/icons/catalogue/deep-2.png",
            scale = 0.5,
            size = 64
          },
          {
            filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-2.png",
            scale = 0.5,
            size = 64,
            tint = {r=50,g=0,b=150},
            draw_as_glow = true
          }
        }
      }
    }
  },
  {
    type = "tool",
    name = data_util.mod_prefix .. "deep-space-science-pack-3",
    subgroup = "deep-science-pack",
    durability = 1,
    durability_description_key = "description.science-pack-remaining-amount-key",
    durability_description_value = "description.science-pack-remaining-amount-value",
    icon = "__space-exploration-graphics__/graphics/icons/catalogue/deep-3.png",
    icon_size = 64,
    order = "s[space-platform-science-pack-3]-c",
    stack_size = 200,
    pick_sound = inventory_sound,
    drop_sound = inventory_sound,
    inventory_move_sound = inventory_sound,
    pictures = {
      {
        layers = {
          {
            filename = "__space-exploration-graphics__/graphics/icons/catalogue/deep-3.png",
            scale = 0.5,
            size = 64
          },
          {
            filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-3.png",
            scale = 0.5,
            size = 64,
            tint = {r=50,g=0,b=150},
            draw_as_glow = true
          }
        }
      }
    }
  },
  {
    type = "tool",
    name = data_util.mod_prefix .. "deep-space-science-pack-4",
    subgroup = "deep-science-pack",
    durability = 1,
    durability_description_key = "description.science-pack-remaining-amount-key",
    durability_description_value = "description.science-pack-remaining-amount-value",
    icon = "__space-exploration-graphics__/graphics/icons/catalogue/deep-4.png",
    icon_size = 64,
    order = "s[space-platform-science-pack-4]-d",
    stack_size = 200,
    pick_sound = inventory_sound,
    drop_sound = inventory_sound,
    inventory_move_sound = inventory_sound,
    pictures = {
      {
        layers = {
          {
            filename = "__space-exploration-graphics__/graphics/icons/catalogue/deep-4.png",
            scale = 0.5,
            size = 64
          },
          {
            filename = "__space-exploration-graphics__/graphics/icons/catalogue/mask-4.png",
            scale = 0.5,
            size = 64,
            tint = {r=50,g=0,b=150},
            draw_as_glow = true
          }
        }
      }
    }
  },
})

--[[
local function tint_science_pack(name, tint)
  if data.raw.tool[name] then
    data.raw.tool[name].icon = nil
    data.raw.tool[name].icons = {
      {
        icon = "__space-exploration-graphics__/graphics/icons/science-pack-base.png"
      },
      {
        icon = "__space-exploration-graphics__/graphics/icons/science-pack-mask.png",
        tint = tint
      }
    }
  end
end
tint_science_pack("science-pack-1", {r = 0.9, g = 0.7, b = 0})
tint_science_pack("science-pack-2", {r = 0, g = 0.6, b = 0})
tint_science_pack("science-pack-3", {r = 0.2, g = 0.4, b = 0.8})
tint_science_pack("military-science-pack", {r = 0.7, g = 0, b = 0})
tint_science_pack("production-science-pack", {r = 0.9, g = 0.4, b = 0})
tint_science_pack("high-tech-science-pack",  {r = 0.7, g = 0, b = 0.7})
tint_science_pack("space-science-pack", {r = 0, g = 1, b = 1})
tint_science_pack(data_util.mod_prefix .. "science-pack-1", {r = 1, g = 1, b = 1})
data.raw.tool[data_util.mod_prefix .. "science-pack-2"].icons = nil
data.raw.tool[data_util.mod_prefix .. "science-pack-2"].icon = "__space-exploration-graphics__/graphics/icons/science-pack-dark.png"
"space-science-pack"
]]--
--[[

[red] = science pack 1
[green] = science pack 2
[military] (grey)
[blue] = science pack 3
[tech] (gold) High Tech
[production] (purple)
[rocket] (orange ) - was white space science 1
[space] (white) - new space platform
[deep-space] - advanced space science

yellow = 1
green = 2
cyan = 3
red = military
purple = production
turquoise = tech
orange = rocketry
white = space
black = deep space
]]--
