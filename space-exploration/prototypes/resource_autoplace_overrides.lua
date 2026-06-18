local default_autoplace_set_name = "default"

local function get_patch_metaset_patch_set_index(patch_metaset, patch_set_name)
  if patch_metaset.patch_set_indexes[patch_set_name] == nil then
    patch_metaset.patch_set_indexes[patch_set_name] = patch_metaset.next_patch_set_index
    patch_metaset.next_patch_set_index = patch_metaset.next_patch_set_index + 1
    data.raw["noise-expression"][patch_metaset.count_expression_name].expression = patch_metaset.next_patch_set_index
  end
  return patch_metaset.patch_set_indexes[patch_set_name]
end

local function new_patch_metaset(params)
  data.raw["noise-expression"][params.count_expression_name] =
  {
    type = "noise-expression",
    name = params.count_expression_name,
    expression = 0
  }

  return
  {
    autoplace_set_name = params.autoplace_set_name or default_autoplace_set_name,
    count_expression_name = params.count_expression_name,
    next_patch_set_index = 0,
    patch_set_indexes = {},
    get_patch_set_index = get_patch_metaset_patch_set_index
  }
end

-- Indicate that a patch set exists and optionally that it also needs a separate starting patch set.
-- Call this to initialize patch sets' indexes in a more deterministic order
-- (see resources.lua for an example) before calling resource_autoplace_settings.
local function initialize_patch_set(patch_set_name, has_starting_area_placement, autoplace_set_name)
  autoplace_set_name = autoplace_set_name or default_autoplace_set_name
  local autoplace_set = get_autoplace_set(autoplace_set_name)
  autoplace_set.regular:get_patch_set_index(patch_set_name)
  if has_starting_area_placement then
    autoplace_set.starting:get_patch_set_index(patch_set_name)
  end
end

-- global
autoplace_sets = autoplace_sets or {}
function get_autoplace_set(autoplace_set_name)
  autoplace_set_name = autoplace_set_name or default_autoplace_set_name
  if not autoplace_sets[autoplace_set_name] then
    autoplace_sets[autoplace_set_name] = {
      regular = new_patch_metaset{ autoplace_set_name = autoplace_set_name, count_expression_name = autoplace_set_name .. "_regular_resource_patch_set_count" },
      starting = new_patch_metaset{ autoplace_set_name = autoplace_set_name, count_expression_name = autoplace_set_name .. "_starting_resource_patch_set_count" }
    }
  end
  return autoplace_sets[autoplace_set_name]
end


local base_distance = 5000 -- __core__ has this at 1300
local regular_patch_fade_in_distance = 320 -- __core__ has this at 300
local starting_resource_placement_radius = 140 -- __core__ has this at 120
local starting_patches_split = 1/4 -- __core__ has this at 1/2
local candidate_spot_count = 64 -- __core__ has this at 32
local suggested_minimum_candidate_point_spacing = 128 -- __core__ has this set at 32
local size_boost = 4 -- __core__ has no equivalent, so would be equal to 0
local maximum_spot_basement_radius = 64 -- __core__ has this set to 128
local starting_amount_val = 100000 -- __core__ has this set to 20000
--local starting_amount = 1000000 -- nicer for testing - just check that all spots have ~1.0M

-- Magic number to match 0.17.50 spot placement, when candidate_point_count was always 128
-- __core__ has a value of 45.254833995939045
local rs_suggested_minimum_candidate_point_spacing = 128

if not data.raw["noise-function"]["se_resource_autoplace_all_patches"] then
  data:extend({
    {
      type = "noise-function",
      name = "se_resource_autoplace_all_patches",
      parameters = {
        "base_density",
        "base_spots_per_km2",
        "candidate_spot_count",
        "frequency_multiplier",
        "has_starting_area_placement",
        "random_spot_size_minimum",
        "random_spot_size_maximum",
        "regular_blob_amplitude_multiplier",
        "regular_patch_set_count",
        "regular_patch_set_index",
        "regular_rq_factor",
        "seed1",
        "size_multiplier",
        "starting_blob_amplitude_multiplier",
        "starting_patch_set_count",
        "starting_patch_set_index",
        "starting_rq_factor",
        "random_probability"
      },
      expression = "if(has_starting_area_placement == 1, max(starting_patches, regular_patches), regular_patches)",
      local_expressions = {
        se_distance ="clamp("..base_distance.." + clamp(var('control:planet-size:richness'), 0, 1) * (distance - "..base_distance.."), 0, "..base_distance..")",
        basement_value = "-6 * max(regular_blob_amplitude_at(regular_blob_amplitude_maximum_distance),starting_blob_amplitude)",
        blobs0 =  "basis_noise{x = x, y = y, seed0 = map_seed, seed1 = seed1, input_scale = 1/8, output_scale = 1} + \z
                   basis_noise{x = x, y = y, seed0 = map_seed, seed1 = seed1, input_scale = 1/24, output_scale = 1}",
        double_density_distance = base_distance, -- Distance at which patches have twice as much stuff in them
        regular_patch_fade_in_distance = regular_patch_fade_in_distance,
        starting_resource_placement_radius = starting_resource_placement_radius,
        starting_patches_split = starting_patches_split,
        spots_per_km2_near_start = "base_spots_per_km2 * frequency_multiplier",

        -- Starting patches
        starting_patches = "spot_noise{\z
                                       x = x,\z
                                       y = y,\z
                                       density_expression = starting_amount / (pi * starting_resource_placement_radius * starting_resource_placement_radius) * starting_modulation,\z
                                       spot_quantity_expression = starting_area_spot_quantity,\z
                                       spot_radius_expression = "..(size_boost/2).." + starting_rq_factor * starting_area_spot_quantity ^ (1/3),\z
                                       spot_favorability_expression = 1,\z"..--[[ -- vanilla has the following expression instead
                                            clamp((elevation_lakes - 1) / 10, 0, 1) * starting_modulation * 2 - \z
                                            distance / starting_resource_placement_radius + random_penalty_at(0.5, 1),\z
                                          ,]]
                                      "seed0 = map_seed,\z
                                       seed1 = seed1 + 1,\z
                                       skip_span = starting_patch_set_count,\z
                                       skip_offset = starting_patch_set_index,\z
                                       region_size = starting_resource_placement_radius * 2,\z
                                       candidate_spot_count = candidate_spot_count,\z
                                       suggested_minimum_candidate_point_spacing = "..suggested_minimum_candidate_point_spacing..",\z
                                       hard_region_target_quantity = 1,\z".. -- Since there's [usually] only one spot, clamp its quantity to the target quantity
                                      "basement_value = basement_value,\z
                                       maximum_spot_basement_radius = "..maximum_spot_basement_radius.."\z
                                       "..--minimum_candidate_point_spacing = 32\z".. -- not sure if minimum_candidate_point_spacing is usable? No spot_noise calls in __core__ or __base__ seem to use it.
                                    "} + (0.4 * (blobs0 - 1/4) + 0.2 * start_vein * random_probability) * starting_blob_amplitude",
        start_vein = "1 - 10 * abs(multioctave_noise{\z
                                                     x = x,\z
                                                     y = y,\z
                                                     persistence = 0.5,\z
                                                     seed0 = map_seed,\z
                                                     seed1 = seed1,\z
                                                     input_scale = 1,\z
                                                     output_scale = 1,\z
                                                     octaves = 6\z
                        })",
        starting_amount = ""..starting_amount_val.." * base_density * starting_frequency_multiplier * size_multiplier",
        -- reduce the influence of the frequency slider over the amount of ore in the starting area.
        -- note that starting_spot_count is still set to frequency_multiplier below, so we still split the ore to a fairly high amount of patches.
        -- __core__ simply has (frequency_multiplier + 1)
        starting_frequency_multiplier = "((frequency_multiplier - 1) * 0.25) + 1",
        starting_area_spot_quantity = "starting_amount / starting_patches_split / frequency_multiplier",
        starting_blob_amplitude = "starting_blob_amplitude_multiplier / (pi/3 * starting_rq_factor ^ 2) * starting_area_spot_quantity ^ (1/3)",
        starting_modulation = "clamp((starting_resource_placement_radius - se_distance) * "..math.huge..", 0, 1)",

        -- Regular patches
        regular_patches = "spot_noise{\z
                                      x = x,\z
                                      y = y,\z
                                      density_expression = regular_density_at(se_distance),\z"..-- low-frequency noise evaluate for an entire region
                                     "spot_quantity_expression = regular_spot_quantity_expression,\z"..-- used to figure out where spots go
                                     "spot_radius_expression = "..size_boost.." + min(32, regular_rq_factor * regular_spot_quantity_expression ^ (1/3)),\z
                                      spot_favorability_expression = 1,\z
                                      seed0 = map_seed,\z
                                      seed1 = seed1,\z
                                      region_size = 1024,\z
                                      candidate_spot_count = candidate_spot_count,\z
                                      suggested_minimum_candidate_point_spacing = "..rs_suggested_minimum_candidate_point_spacing..",\z
                                      skip_span = regular_patch_set_count,\z
                                      skip_offset = regular_patch_set_index,\z
                                      hard_region_target_quantity = 0,\z"..-- it's fine for large spots to push region quantity past the target
                                     "basement_value = basement_value,\z
                                      maximum_spot_basement_radius = 128\z
                                    } + (1 * (blobs0 + basis_noise{\z
                                                                   x = x,\z
                                                                   y = y,\z
                                                                   seed0 = map_seed,\z
                                                                   seed1 = seed1,\z
                                                                   input_scale = 1/64,\z
                                                                   output_scale = 1.5\z
                                                                   } - 1/3) + 0.8 * vein * random_probability) * \z
                                        regular_blob_amplitude_at(se_distance)",
        regular_spot_quantity_expression = "random_penalty_between(random_spot_size_minimum, random_spot_size_maximum, 1) * \z
                                            regular_spot_quantity_base_at(se_distance)",
        vein = "1 - 10 * abs(multioctave_noise{\z
                                               x = x,\z
                                               y = y,\z
                                               persistence = 0.5,\z
                                               seed0 = map_seed,\z
                                               seed1 = seed1,\z
                                               input_scale = 1/4,\z
                                               output_scale = 1,\z
                                               octaves = 6\z
        })",
        regular_blob_amplitude_maximum_distance = "if(has_starting_area_placement == -1,\z
                                                    double_density_distance,\z
                                                    double_density_distance + regular_patch_fade_in_distance)",
      },
      local_functions = {
        size_effective_distance_at = {
          parameters = {"distance"},
          expression = "if(has_starting_area_placement == -1, distance, distance - regular_patch_fade_in_distance)",
        },
        regular_density_at = {
          parameters = {"distance"},
          expression = "base_density * frequency_multiplier * size_multiplier * \z
                        if(has_starting_area_placement == -1, 1, clamp((distance - starting_resource_placement_radius) / regular_patch_fade_in_distance, 0, 1)) * \z
                        (1 + clamp(size_effective_distance_at(distance) / double_density_distance, 0, 1))"
        },
        regular_spot_quantity_base_at = {
          parameters = {"distance"},
          expression = "regular_density_at(distance) * 1000000 / spots_per_km2_near_start",
        },
        regular_spot_height_typical_at = {
          parameters = {"distance"},
          expression = "((random_spot_size_minimum + random_spot_size_maximum) / 2 * regular_spot_quantity_base_at(distance)) ^ (1/3) / (pi/3 * regular_rq_factor ^ 2)",
        },
        regular_blob_amplitude_at = {
          parameters = {"distance"},
          expression = "regular_blob_amplitude_multiplier * min(regular_spot_height_typical_at(regular_blob_amplitude_maximum_distance),\z
                                                                regular_spot_height_typical_at(distance))",
        }
      },
    }
  })
end


--- Creates and returns an AutoplaceSpecification that will generate spot-based ore patches.
-- Required parameters:
-- - name - name for the type, used as the default autoplace control name and patch set name
--   (each of which can be overridden separately)
-- - base_density - amount of stuff, on average, to be placed per tile
-- Optional parameters:
-- - patch_set_name - name of the patch set; patches sets of the same name and seed1 will overlap; default: name
-- - autoplace_control_name - name of the corresponding autoplace control; default: name
-- - random_probability - probability of placement at any given tile within a patch; default: 1
-- - base_spots_per_km2 - number of patches per square kilometer near the starting area
-- - has_starting_area_placement - true|false|nil - yes, no, and there is no special starting area, respectively
-- - seed1 - random seed to use when generating patch positions; default: 100
-- More obscure parameters can be read about in the inline comments.
local function resource_autoplace_settings(params)

  local function setting_scale(value)
    --return value
    --return value * value
    return "("..value.." ^ 0.8)"
  end

  local name = params.name
  local order = params.order or "d"

  local patch_set_name = params.patch_set_name or name
  local autoplace_control_name = params.autoplace_control_name or name
  local autoplace_set_name = params.autoplace_set_name or default_autoplace_set_name
  local autoplace_set = get_autoplace_set(autoplace_set_name)
  local all_patches_name = autoplace_set_name .. "-" .. patch_set_name .. "-patches"


  data:extend({
    {
      type = "noise-expression",
      name = all_patches_name,
      expression = "se_resource_autoplace_all_patches{\z
        base_density = ".. params.base_density ..",\z
        base_spots_per_km2 = ".. (params.base_spots_per_km2 or 2.5) ..",\z
        candidate_spot_count = ".. (candidate_spot_count) ..",\z
        frequency_multiplier = ".. setting_scale("var('control:"..autoplace_control_name..":frequency')") ..",\z
        has_starting_area_placement = "..(   params.has_starting_area_placement == nil and -1
                                          or params.has_starting_area_placement and 1
                                          or 0)..",\z
        random_spot_size_minimum = ".. (params.random_spot_size_minimum or 0.25) ..",\z
        random_spot_size_maximum = ".. (params.random_spot_size_maximum or 2.00) ..",\z
        regular_blob_amplitude_multiplier = ".. ((params.regular_blob_amplitude_multiplier or 1) / 8) ..",\z
        regular_patch_set_count = ".. autoplace_set.regular.count_expression_name ..",\z
        regular_patch_set_index = ".. autoplace_set.regular:get_patch_set_index(patch_set_name) ..",\z
        regular_rq_factor = ".. ((params.regular_rq_factor_multiplier or 1) / 10) ..",\z
        seed1 = ".. (params.seed1 or 100) ..",\z
        size_multiplier = ".. setting_scale("var('control:"..autoplace_control_name..":size')") ..",\z
        starting_blob_amplitude_multiplier = ".. ((params.starting_blob_amplitude_multiplier or 1) / 8) ..",\z
        starting_patch_set_count = ".. autoplace_set.starting.count_expression_name ..",\z
        starting_patch_set_index = ".. (   params.has_starting_area_placement == true and autoplace_set.starting:get_patch_set_index(patch_set_name)
                                        or 0) .. ",\z
        starting_rq_factor = ".. ((params.starting_rq_factor_multiplier or 1) / 8) ..",\z".. -- We divide by 8, __core__ divides by 7
       --"random_probability = "..(params.random_probability or 1).."\z
       "random_probability = 1\z
      }"
    }
  })

  local local_expressions = data.raw["noise-function"]["se_resource_autoplace_all_patches"].local_expressions
  -- The following are more dangerous, since they'll throw total quantities off if you don't compensate for them:

  -- vanilla placement rules don't work well for most planets.
  -- they don't work at all well for asteroid fields.
  -- remove resource size and richness change over distance for space zones
  -- space zones are defined by ____?
  -- note: Set planet-size richness to 0 for all non-homeworld zones.

  --local distance = noise.var("distance")
  local distance = local_expressions.se_distance -- treat as permenant 5000

  -- local double_density_distance = 1300 -- distance at which patches have twice as much stuff in them
  local double_density_distance = base_distance -- distance at which patches have twice as much stuff in them

  -- Maximum distance at which blob amplitude should keep increasing along with spot height
  local spot_enlargement_maximum_distance = double_density_distance



  local richness_expression = "var('"..all_patches_name.."')"
  local probability_expression = "clamp(var('"..all_patches_name.."'), 0, 1)"

  if (params.random_probability or 1) < 1 then
    richness_expression = richness_expression.." / "..params.random_probability
    probability_expression = probability_expression.." * random_penalty{x = x, y = y, source = 1, amplitude = 1 / "..params.random_probability.."}"
  end
  -- additional_richness will be added to richness but does not affect probability of anything being placed at all.
  -- This is NOT automatically compensated for, because that would be difficult to calculate.
  -- The caller will need to compensate for any additional_richness by adjusting base_density.
  if (params.additional_richness or 0) > 0 then
    richness_expression = richness_expression.." + "..params.additional_richness
  end
  -- richness will be clamped to minimum_richness at the low end anywhere the stuff is otherwise placed
  -- Not automatically compensated for.
  if (params.minimum_richness or 0) > 0 then
    richness_expression = "max("..richness_expression..","..params.minimum_richness..")"
  end

  -- 'post' as in multiplied after everything else is calculated, including additional_richness
  -- and minimum_richness.
  local richness_post_multiplier = tostring(params.richness_post_multiplier or 1) .. " * " .. setting_scale("var('control:"..autoplace_control_name..":richness')")

  -- Get distance for purposes of calculating regular ore density, patch size, and richness
  ---@param dist string
  local function size_effective_distance_at(dist)
    if params.has_starting_area_placement == nil then
      return dist
    else
      -- If there's a starting area measure from the edge of the fade-in radius
      return dist.." - "..regular_patch_fade_in_distance
    end
  end
  -- sed = size-effective distance
  local function post_semd_richness_distance_multiplier_at(sed)
    local ddd = double_density_distance
    local semd = spot_enlargement_maximum_distance
    -- density = pre-richness-mutliplied density * richness_distance_multiplier.
    -- Since pre-richness-multiplied density plateaus at semd,
    -- richness needs to increase at that point, and by this much:
    return "("..ddd.." + "..sed..")/("..ddd.." + "..semd..")"
  end

  local richness_distance_multiplier = "max(1, "..post_semd_richness_distance_multiplier_at(size_effective_distance_at(distance))..")"

  richness_expression = richness_expression.." * "..richness_distance_multiplier.." * "..richness_post_multiplier

  local ret =
  {
    order = order,
    control = autoplace_control_name,
    probability_expression = probability_expression,
    richness_expression = richness_expression
  }

  return ret
end

return
{
  initialize_patch_set = initialize_patch_set,
  resource_autoplace_settings = resource_autoplace_settings
}
