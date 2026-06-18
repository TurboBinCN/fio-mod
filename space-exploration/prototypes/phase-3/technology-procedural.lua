local data_util = require("data_util")

local deep_space_1_words = {"antimatter", "darkmatter", "singularity"}
local teleport_tech_words = {"teleport", "dimension", "stargate", "portal"}

-- Procedural tech
debug_log("Procedural tech")

local function update_tech_unit_counts(complexity, multiplier)
  if not (complexity and complexity.unit) then return end
  if complexity.unit.count then
    complexity.unit.original_count = complexity.unit.original_count or complexity.unit.count
    complexity.unit.count = math.ceil(complexity.unit.original_count * multiplier)
  end
  if complexity.unit.count_formula then
    complexity.unit.original_count_formula = complexity.unit.original_count_formula or complexity.unit.count_formula
    complexity.unit.count_formula = multiplier.."*("..complexity.unit.original_count_formula..")"
  end
end

local function update_tech_for_complexity(tech, complexity, space_flavour, this_level)
  local add_fn = data_util.tech_add_ingredients_with_prerequisites
  local multiplier = 1
  if complexity >= 4 then -- would be at complexity 3 except for military
    add_fn(tech.name, {"chemical-science-pack" })
  end
  if complexity >= 5 then
    add_fn(tech.name, {"space-science-pack" })
  end
  if complexity == 6 then
    add_fn(tech.name, { space_flavour.."-1" })
    multiplier = 0.6
  elseif complexity == 7 then
    add_fn(tech.name, { space_flavour.."-2" })
    multiplier = 0.5
  elseif complexity == 8 then
    add_fn(tech.name, { space_flavour.."-3" })
    multiplier = 0.4
  elseif complexity >= 9 then
    add_fn(tech.name, { space_flavour.."-4" })
    multiplier = 0.3
  end
  if complexity >= 10 then
    add_fn(tech.name, { data_util.mod_prefix .. "deep-space-science-pack-1" })
    multiplier = 0.2
  end
  if complexity >= 11 then
    add_fn(tech.name, { data_util.mod_prefix .. "deep-space-science-pack-2" })
    multiplier = 0.15
  end
  if complexity >= 12 then
    add_fn(tech.name, { data_util.mod_prefix .. "deep-space-science-pack-3" })
    multiplier = 0.12
  end
  if complexity >= 13 then
    add_fn(tech.name, { data_util.mod_prefix .. "deep-space-science-pack-4" })
    multiplier = 0.1
  end

  update_tech_unit_counts(tech, multiplier)

end

-- We used to have a typo in the variable name, this is legacy support for mods that used the typo'd name.
-- If you want your tech to be ignored, please add its name to `se_procedural_tech_exclusions`
se_prodecural_tech_exclusions = se_prodecural_tech_exclusions or {}
data_util.concatenate_tables(se_procedural_tech_exclusions, se_prodecural_tech_exclusions)

local techs_static = {}
for _, tech in pairs(data.raw.technology) do
  table.insert(techs_static, tech.name)
end

for _, tech_name in pairs(techs_static) do
  local tech = data.raw.technology[tech_name]
  if tech and string.sub(tech.name, 1, 3) ~= "se-" then
    --debug_log("consider tech: " .. tech.name)
    local exclude = false
    for _, exclusion in pairs(se_procedural_tech_exclusions) do
      if string.find(tech.name, exclusion, 1, true) then
        exclude = true
        break
      end
    end
    if not exclude then
      local lowercase_tech_name = string.lower(tech.name)
      -- Find technolgies from other mods that should be locked behind deep science packs
      -- If a tech explicitly has SE science packs, then ignore it, they know what they're doing.
      for _, word in pairs(deep_space_1_words) do
        if string.find(lowercase_tech_name, word, 1, true) then
          data_util.tech_add_ingredients(tech.name, { data_util.mod_prefix .. "deep-space-science-pack-1"})
          break
        end
      end
      for _, word in pairs(teleport_tech_words) do
        if string.find(lowercase_tech_name, word, 1, true) then
          data_util.tech_add_prerequisites(tech.name, { data_util.mod_prefix .. "teleportation" })
          data_util.tech_add_ingredients(tech.name, {
            data_util.mod_prefix .. "rocket-science-pack",
            "space-science-pack",
            "utility-science-pack",
            "production-science-pack",
            data_util.mod_prefix .. "astronomic-science-pack-4",
            data_util.mod_prefix .. "energy-science-pack-4",
            data_util.mod_prefix .. "material-science-pack-4",
            data_util.mod_prefix .. "deep-space-science-pack-4",
          })
          break
        end
      end

      -- if it already needs space science then starting complexity is 1 (space)
      -- otherwise if it requires utility/production then it is -1
      -- otherwise if it requires chemical it is -2,
      -- otherwise if it requires logistic it is -3
      -- otherwise if it requires automation it is -4
      local this_level = data_util.string_to_simple_int(tech.name, true)
      local max_level = tech.max_level
      if this_level or max_level then
        this_level = this_level or 1
        max_level = max_level or this_level
        --debug_log("tech (" .. tech.name..") level: " .. this_level)
        --debug_log("tech (" .. tech.name..") max level: " .. max_level)
        local min_complexity = 4 -- pre-space
        if data_util.tech_has_ingredient (tech.name, "deep-space-science-pack-4") then
          exclude = true -- already done
        elseif data_util.tech_has_ingredient (tech.name, data_util.mod_prefix .. "astronomic-science-pack-4")
          or data_util.tech_has_ingredient (tech.name, data_util.mod_prefix .. "biological-science-pack-4")
          or data_util.tech_has_ingredient (tech.name, data_util.mod_prefix .. "energy-science-pack-4")
          or data_util.tech_has_ingredient (tech.name, data_util.mod_prefix .. "material-science-pack-4") then
            min_complexity = 9
        elseif data_util.tech_has_ingredient (tech.name, data_util.mod_prefix .. "astronomic-science-pack-3")
          or data_util.tech_has_ingredient (tech.name, data_util.mod_prefix .. "biological-science-pack-3")
          or data_util.tech_has_ingredient (tech.name, data_util.mod_prefix .. "energy-science-pack-3")
          or data_util.tech_has_ingredient (tech.name, data_util.mod_prefix .. "material-science-pack-3") then
            min_complexity = 8
        elseif data_util.tech_has_ingredient (tech.name, data_util.mod_prefix .. "astronomic-science-pack-2")
          or data_util.tech_has_ingredient (tech.name, data_util.mod_prefix .. "biological-science-pack-2")
          or data_util.tech_has_ingredient (tech.name, data_util.mod_prefix .. "energy-science-pack-2")
          or data_util.tech_has_ingredient (tech.name, data_util.mod_prefix .. "material-science-pack-2") then
            min_complexity = 7
        elseif data_util.tech_has_ingredient (tech.name, data_util.mod_prefix .. "astronomic-science-pack-1")
          or data_util.tech_has_ingredient (tech.name, data_util.mod_prefix .. "biological-science-pack-1")
          or data_util.tech_has_ingredient (tech.name, data_util.mod_prefix .. "energy-science-pack-1")
          or data_util.tech_has_ingredient (tech.name, data_util.mod_prefix .. "material-science-pack-1") then
            min_complexity = 6
        elseif data_util.tech_has_ingredient (tech.name, "utility-science-pack")
          or data_util.tech_has_ingredient (tech.name, "production-science-pack") then
            min_complexity = 5
        elseif data_util.tech_has_ingredient (tech.name, "space-science-pack") then
            min_complexity = 4
        elseif data_util.tech_has_ingredient (tech.name, "chemical-science-pack") then
            min_complexity = 3
        elseif data_util.tech_has_ingredient (tech.name, "logistic-science-pack") then
            min_complexity = 2
        elseif data_util.tech_has_ingredient (tech.name, "automation-science-pack") then
            min_complexity = 1
        end
        if not exclude then
          local complexity = math.max(this_level, min_complexity)
          local complexity_adjust = complexity - this_level
          --debug_log("tech (" .. tech.name..") complexity_adjust: " .. complexity_adjust)
          local max_complexity = 10
          local level_of_max_complexity = max_complexity - complexity_adjust
          --debug_log("tech (" .. tech.name..") level_of_max_complexity: " .. level_of_max_complexity)
          local max_level_to_make = level_of_max_complexity
          if max_level ~= "infinite" then
            max_level_to_make = math.min(max_level_to_make, max_level)
          end
          --debug_log("tech (" .. tech.name..") max_level_to_make: " .. max_level_to_make)
          local space_flavour = data_util.mod_prefix .. "material-science-pack"
          if string.find(lowercase_tech_name, "laser", 1, true)
          or string.find(lowercase_tech_name, "energy", 1, true)
          or string.find(lowercase_tech_name, "robots-speed", 1, true) then
            space_flavour = data_util.mod_prefix .. "energy-science-pack"
          end
          if string.find(lowercase_tech_name, "productivity", 1, true) then
            space_flavour = data_util.mod_prefix .. "biological-science-pack"
          end
          --debug_log("tech (" .. tech.name..") space_flavour: " .. space_flavour)
          -- Update packs for this
          update_tech_for_complexity(tech, complexity, space_flavour, this_level)
          -- make new levels as required
          if max_level_to_make > this_level then
            local raw_name = data_util.remove_number_suffix(tech.name)
            --debug_log("tech (" .. tech.name..") raw_name: " .. raw_name)
            for i = this_level+1, max_level_to_make do
              --debug_log("tech (" .. tech.name..") try to make tech for level: " .. i.."("..raw_name.."-"..i..")")
              local new_tech = data_util.tech_split_at_level(raw_name, i)
              if new_tech then
                update_tech_for_complexity(new_tech, i+complexity_adjust, space_flavour, i)
                --debug_log("new tech level created: " .. new_tech.name.."")
              else
                --debug_log("tech (" .. tech.name..") create tech failed")
              end
            end
          else
            --debug_log("tech (" .. tech.name..") no new levels needed")
          end

        end
      end
    end
  end
end

-- Dynamically assign utility/production packs on top of the space science packs to keep them relevant into late game space science
-- This leaves vanilla techs or other modded techs that use utility/production still using them, while adding them into thematically
-- appropriate locations for SE.
for _, tech in pairs(data.raw.technology) do
  if not string.find(tech.name, "science-pack", 1, true) then
    if data_util.tech_has_ingredient (tech.name, data_util.mod_prefix .. "astronomic-science-pack-1")
      or data_util.tech_has_ingredient (tech.name, data_util.mod_prefix .. "astronomic-science-pack-2")
      or data_util.tech_has_ingredient (tech.name, data_util.mod_prefix .. "astronomic-science-pack-3")
      or data_util.tech_has_ingredient (tech.name, data_util.mod_prefix .. "astronomic-science-pack-4")
      or data_util.tech_has_ingredient (tech.name, data_util.mod_prefix .. "energy-science-pack-1")
      or data_util.tech_has_ingredient (tech.name, data_util.mod_prefix .. "energy-science-pack-2")
      or data_util.tech_has_ingredient (tech.name, data_util.mod_prefix .. "energy-science-pack-3")
      or data_util.tech_has_ingredient (tech.name, data_util.mod_prefix .. "energy-science-pack-4") then
        data_util.tech_add_ingredients(tech.name, { "utility-science-pack" })
    end
    if data_util.tech_has_ingredient (tech.name, data_util.mod_prefix .. "biological-science-pack-1")
      or data_util.tech_has_ingredient (tech.name, data_util.mod_prefix .. "biological-science-pack-2")
      or data_util.tech_has_ingredient (tech.name, data_util.mod_prefix .. "biological-science-pack-3")
      or data_util.tech_has_ingredient (tech.name, data_util.mod_prefix .. "biological-science-pack-4")
      or data_util.tech_has_ingredient (tech.name, data_util.mod_prefix .. "material-science-pack-1")
      or data_util.tech_has_ingredient (tech.name, data_util.mod_prefix .. "material-science-pack-2")
      or data_util.tech_has_ingredient (tech.name, data_util.mod_prefix .. "material-science-pack-3")
      or data_util.tech_has_ingredient (tech.name, data_util.mod_prefix .. "material-science-pack-4") then
        data_util.tech_add_ingredients(tech.name, { "production-science-pack" })
    end

    if data_util.tech_has_ingredient (tech.name, "utility-science-pack")
      or data_util.tech_has_ingredient (tech.name, "production-science-pack") then
        data_util.tech_add_ingredients(tech.name, { "space-science-pack" }, true)
    end

    if data_util.tech_has_ingredient (tech.name, "space-science-pack") then
      data_util.tech_add_ingredients(tech.name, { data_util.mod_prefix .. "rocket-science-pack" }, true)
    end
  end
end
