
-- Rocket science pack
-- Since K2 doesn't have an icon for this specifically, we will use one of the existing but unused K2 icons instead.
local rocket_science_pack = data.raw.tool["se-rocket-science-pack"]
rocket_science_pack.localised_name = {"item-name.se-kr-rocket-tech-card"}
rocket_science_pack.icons = nil
rocket_science_pack.icon = "__Krastorio2Assets__/icons/cards/utility-tech-card.png"
rocket_science_pack.icon_size = 64

---- Production Science Pack
-- Change graphics back to SEs
local production_pack = data.raw.tool["production-science-pack"]
production_pack.localised_name = {"item-name.production-science-pack"}
production_pack.icon = nil
production_pack.icon_size = nil
production_pack.icons = {
  {icon = "__space-exploration-graphics__/graphics/icons/catalogue/deep-2.png", icon_size = 64},
  {icon = "__space-exploration-graphics__/graphics/icons/catalogue/mask-2.png", icon_size = 64, tint = {r=1, g=0, b=0}}
}
production_pack.pictures = nil

---- Utility Science Pack
-- Change graphics back to SEs
local utility_pack = data.raw.tool["utility-science-pack"]
utility_pack.localised_name = {"item-name.utility-science-pack"}
utility_pack.icon = nil
utility_pack.icon_size = nil
utility_pack.icons = {
  {icon = "__space-exploration-graphics__/graphics/icons/catalogue/deep-2.png", icon_size = 64},
  {icon = "__space-exploration-graphics__/graphics/icons/catalogue/mask-2.png", icon_size = 64, tint = {r=0, g=1, b=0.8}}
}
utility_pack.pictures = nil

local optimization_pack_tint = {r = 255, g = 128, b = 0}
local opti_pack = data.raw.tool["kr-optimization-tech-card"]
opti_pack.icons = {
  {icon = "__space-exploration-graphics__/graphics/icons/catalogue/deep-2.png", icon_size = 64},
  {icon = "__space-exploration-graphics__/graphics/icons/catalogue/mask-2.png", icon_size = 64, tint = optimization_pack_tint}
}
opti_pack.pictures = nil
