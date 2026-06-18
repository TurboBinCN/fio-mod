local data_util = require("data_util")

local qualities = {}
for quality_name, quality in pairs(data.raw.quality) do
  if (not quality.hidden) or quality_name == "normal" then
    qualities[quality_name] = quality
  end
end

for _, generator_name in ipairs({
  data_util.mod_prefix .. "fluid-burner-generator",
  "kr-gas-power-station",
}) do
  local generator = data.raw.generator[generator_name]
  if generator then

    for _, fluid in pairs(data.raw.fluid) do
      if (not fluid.hidden) and fluid.fuel_value then
        local quality_values = {}

        for quality_name, quality in pairs(qualities) do
          local multiplier = quality.default_multiplier or (1 + 0.3 * quality.level)
          local fluid_usage_per_tick = generator.fluid_usage_per_tick * multiplier

          local per_tick_uncapped = util.parse_energy(generator.max_power_output) * multiplier / util.parse_energy(fluid.fuel_value)
          local per_tick = math.min(fluid_usage_per_tick, per_tick_uncapped)
          local per_second = per_tick * 60
          local rounded = math.floor(per_second * 10) / 10
          local no_decimal_or_one = tostring(tonumber(string.format("%.1f", rounded)))

          quality_values[quality_name] = {"", string.format("[fluid=%s]", fluid.name), " ", no_decimal_or_one, {"per-second-suffix"}}
        end

        data_util.add_custom_tooltip_field(generator, {
          name = {"description.fluid-consumption"},
          value = quality_values["normal"],
          quality_values = quality_values,
          order = 99,
        })
      end
    end

  end
end
