data:extend{
  -- Startup
  {
      type = "int-setting",
      name = "se-space-pipe-capacity",
      setting_type = "startup",
      default_value = 100,
      minimum_value = 50,
      maximum_value = 200,
      order = "e"
  },
  {
      type = "int-setting",
      name = "se-deep-space-belt-speed-2",
      setting_type = "startup",
      default_value = 90,
      minimum_value = 60,
      maximum_value = 512,
      order = "f"
  },
  --[[{
      type = "bool-setting",
      name = "se-electric-boiler",
      setting_type = "startup",
      default_value = true
  },
  {
      type = "bool-setting",
      name = "se-deep-space-belt-black",
      setting_type = "startup",
      default_value = false
  },]]
  {
      type = "bool-setting",
      name = "se-deep-space-belt-white",
      setting_type = "startup",
      default_value = true,
      order = "g"
  },
  {
      type = "bool-setting",
      name = "se-deep-space-belt-red",
      setting_type = "startup",
      default_value = true,
      order = "g"
  },
  {
      type = "bool-setting",
      name = "se-deep-space-belt-magenta",
      setting_type = "startup",
      default_value = true,
      order = "g"
  },
  {
      type = "bool-setting",
      name = "se-deep-space-belt-blue",
      setting_type = "startup",
      default_value = true,
      order = "g"
  },
  {
      type = "bool-setting",
      name = "se-deep-space-belt-cyan",
      setting_type = "startup",
      default_value = true,
      order = "g"
  },
  {
      type = "bool-setting",
      name = "se-deep-space-belt-green",
      setting_type = "startup",
      default_value = true,
      order = "g"
  },
  {
      type = "bool-setting",
      name = "se-deep-space-belt-yellow",
      setting_type = "startup",
      default_value = true,
      order = "g"
  },
  {
      type = "bool-setting",
      name = "se-pylon-charge-points",
      setting_type = "startup",
      default_value = false,
      order = "e-b"
  },
  {
      type = "bool-setting",
      name = "se-spawn-small-resources",
      setting_type = "startup",
      default_value = true,
      order = "h"
  },
  {
      type = "int-setting",
      name = "se-supercharger-individual-charge-rate",
      setting_type = "startup",
      default_value = 90,
      minimum_value = 90,
      maximum_value = 1000,
      order = "e-c"
  },
  {
    type = "bool-setting",
    name = "se-add-icon-labels",
    setting_type = "startup",
    order = "i",
    default_value = false
  },
  {
    type = "int-setting",
      name = "se-delivery-cannon-artillery-timeout",
      setting_type = "startup",
      default_value = 120,
      minimum_value = 60,
      maximum_value = 600,
      order = "j"
  },
  {
      type = "bool-setting",
      name = "se-use-underground-collision-masks",
      setting_type = "startup",
      -- getting this one in early, once a world gets saved with this it'll remember the default value at that time.
      -- so if at some point we do want this behavior then any preexisting world would not be automatically bricked.
      default_value = false,
      order = "k"
  },
  {
      type = "bool-setting",
      name = "se-use-new-space-rail-graphics",
      setting_type = "startup",
      -- elevated rails currently are still on the "apply_grey_tint" pictures, having two styles of space rails looks bad,
      -- with this setting people can opt back in to "apply_grey_tint" for the normal space rails until both have new art.
      default_value = true,
      order = "l"
  },
  {
      type = "bool-setting",
      name = "se-quality-mod-support",
      setting_type = "startup",
      default_value = false,
      order = "m",
      hidden = mods["quality"] == nil,
  },
  {
      type = "bool-setting",
      name = "se-space-age-mod-support",
      setting_type = "startup",
      default_value = false,
      order = "n",
      hidden = mods["space-age"] == nil,
  },

  -- Runtime global
  {
      type = "int-setting",
      name = "se-meteor-interval",
      setting_type = "runtime-global",
      default_value = 30,
      minimum_value = 1,
      maximum_value = 2880,
      order = "a-a"
  },
  {
      type = "int-setting",
      name = "se-plague-max-runtime-2",
      setting_type = "runtime-global",
      default_value = 30,
      minimum_value = 5,
      maximum_value = 1000,
      order = "b"
  },
  {
      type = "int-setting",
      name = "se-cmes-max-frequency",
      setting_type = "runtime-global",
      minimum_value = 0,
      maximum_value = 200,
      default_value = 36,
      order = "a-c"
  },
  {
      type = "int-setting",
      name = "se-scan-search-budget",
      setting_type = "runtime-global",
      default_value = 1000,
      minimum_value = 1,
      maximum_value = 10000,
      order = "s-a"
  },
  {
      type = "int-setting",
      name = "se-scan-chart-budget",
      setting_type = "runtime-global",
      default_value = 10,
      minimum_value = 1,
      maximum_value = 60,
      order = "s-b"
  },
  {
      type = "int-setting",
      name = "se-scan-alert-interval",
      setting_type = "runtime-global",
      default_value = 300,
      minimum_value = 0,
      maximum_value = 1000,
      order = "s-c"
  },
  {
      type = "int-setting",
      name = "se-scan-max-range",
      setting_type = "runtime-global",
      default_value = 10000,
      minimum_value = 0,
      maximum_value = 1000000, -- engine limit is 1048448
      order = "s-d"
  },
  {
    type = "bool-setting",
    name = "se-core-seam-map-tags",
    setting_type = "runtime-global",
    default_value = true,
    order = "s-e"
  },

  -- Per user
  {
      type = "string-setting",
      name = "se-print-meteor-info",
      setting_type = "runtime-per-user",
      allowed_values = {
        "always",
        "current-zone-only",
        "breakthrough-only",
        "breakthrough-and-current-zone-only",
        "never",
      },
      default_value = "current-zone-only",
      order = "a-b"
  },
  {
      type = "bool-setting",
      name = "se-print-satellite-discovered-nothing",
      setting_type = "runtime-per-user",
      default_value = true,
      order = "c-a"
  },
  {
      type = "bool-setting",
      name = "se-never-show-train-gui",
      setting_type = "runtime-per-user",
      default_value = false,
      order = "c-b",
  },
  {
      type = "string-setting",
      name = "se-lifesupport-hud-visibility",
      setting_type = "runtime-per-user",
      allowed_values = {
        "option-1", -- Always
        "option-2", -- When equipped or in need
        "option-3", -- When in need
        "option-4"  -- Never
      },
      default_value = "option-2",
      order = "c-c"
  },
  {
      type = "bool-setting",
      name = "se-show-zone-preview",
      setting_type = "runtime-per-user",
      default_value = true,
      order = "d"
  },
  {
      type = "bool-setting",
      name = "se-show-overhead-button-satellite-mode",
      setting_type = "runtime-per-user",
      default_value = true,
      order = "d-b"
  },
  {
      type = "bool-setting",
      name = "se-show-overhead-button-interstellar-map",
      setting_type = "runtime-per-user",
      default_value = true,
      order = "d-c"
  },
  {
      type = "bool-setting",
      name = "se-show-overhead-button-universe-explorer",
      setting_type = "runtime-per-user",
      default_value = true,
      order = "d-d"
  },
  {
      type = "bool-setting",
      name = "se-show-pin-help-tooltip",
      setting_type = "runtime-per-user",
      default_value = true,
      order = "e-a"
  },
  {
      type = "bool-setting",
      name = "se-dropdowns-hide-low-priority-zones",
      setting_type = "runtime-per-user",
      default_value = false,
      order = "e-b"
  },
  {
      type = "int-setting",
      name = "se-dropdowns-priority-threshold",
      setting_type = "runtime-per-user",
      default_value = 0,
      minimum_value = -999,
      maximum_value = 999,
      order = "e-c"
  },
}

local function disable_setting(type, name, value)
  local setting = data.raw[type .. "-setting"][name]
  if not setting then return end

  setting.hidden = true
  if type == "bool" then
    setting.forced_value = value
  else
    setting.default_value = value
    setting.allowed_values = {value}
  end
end

-- Overrides
disable_setting("bool", "aai-wide-drill", true)
for _, setting in pairs(data.raw["string-setting"]) do
  if string.find(setting.name, "alien-biomes-include-", 1, true) and setting.name ~= "alien-biomes-include-rivers" then
    disable_setting("string", setting.name, "Enabled")
  end
end
disable_setting("string", "alien-biomes-disable-vegetation", "Disabled")
