local Essential = {}

mod_prefix = util.mod_prefix
mod_prefix_snake_case = util.mod_prefix_snake_case

 -- Vanilla and some mods use a dummy item-with-inventory with 1 slot.
 -- Hardcode them to not be included in items_banned_from_transport
local allowed_items = {
  "item-with-inventory", -- Vanilla dummy item
  "blank-gui-item", -- Memory Storage
}
allowed_items = core_util.list_to_map(allowed_items)

function Essential.detect_breaking_prototypes()
  if prototypes.item["rocket-fuel"].stack_size > 10 then
    error("A mod has changed the rocket fuel stack size above 10. Please check and adjust your mod list.")
  end
  if prototypes.item["rocket-fuel"].stack_size > math.ceil(1000000000 / prototypes.item["rocket-fuel"].fuel_value) then
    error("A mod has changed the rocket fuel energy per stack beyond accepted values. Please check and adjust your mod list.")
  end
  if prototypes.entity[mod_prefix .. "rocket-launch-pad"].get_inventory_size(defines.inventory.chest) ~= Launchpad.rocket_capacity then
    error("A mod has changed the cargo rocket launch pad's inventory size. This will prevent cargo rockets from working correctly. Please check and adjust your mod list.")
  end
  if prototypes.entity[mod_prefix .. "rocket-launch-pad-tank"].fluid_capacity ~= Shared.cargo_rocket_launch_pad_tank_nonbuffer + Shared.cargo_rocket_launch_pad_tank_buffer then
    error("A mod has changed the cargo rocket launch pad's fuel tank size. This will prevent cargo rockets from working correctly. Please check and adjust your mod list.")
  end

  local oversized_stacks = {}

  local benchmark_stacks = {
    ["iron-ore"] = 50,
    ["iron-plate"] = 100,
    ["copper-ore"] = 50,
    ["copper-plate"] = 100,
    ["stone"] = 50,
    ["stone-brick"] = 100,
    ["low-density-structure"] = 50,
    [mod_prefix .. "beryllium-ore"] = 100,
    [mod_prefix .. "beryllium-plate"] = 200,
    [mod_prefix .. "holmium-ore"] = 50,
    [mod_prefix .. "holmium-plate"] = 100,
    [mod_prefix .. "iridium-ore"] = 20,
    [mod_prefix .. "iridium-plate"] = 40,
  }
  for name, stack_size in pairs(benchmark_stacks) do
    if not prototypes.item[name] then
      error("Mod conflict: " ..name.. " was removed by another mod.")
    elseif prototypes.item[name].stack_size > stack_size then
      table.insert(oversized_stacks, name)
    end
  end

  storage.items_banned_from_transport = {}

  local stack_size_limit = 200
  local above_stack_size_count = 0
  for _, prototype in pairs(prototypes.item) do
    if prototype.type == "item-with-inventory" and prototype.inventory_size > 0 and not allowed_items[prototype.name] then
      storage.items_banned_from_transport[prototype.name] = true;
    end
    if prototype.stack_size > stack_size_limit and (not prototype.hidden) and prototype.name ~= "coin" then
      local recipe_prototype = prototypes.recipe[prototype.name]
      if not recipe_prototype or #recipe_prototype.ingredients ~= 0 then
        above_stack_size_count = above_stack_size_count + 1
        table.insert(oversized_stacks, prototype.name)
      end
    end
  end

  Log.debug_log("items_banned_from_transport: " .. serpent.line(storage.items_banned_from_transport))


  local oversized_stacks_count = table_size(oversized_stacks)
  if oversized_stacks_count > 0 then

    local full_message = {"", {"space-exploration.stack_size_danger_1", oversized_stacks_count}}

    if settings.startup["kr-stack-size"] and settings.startup["kr-stack-size"].value ~= "No changes" then
      -- This is no obsolete as the setting it references has been removed
      ---@TODO: Remove this and remove the locale string
      table.insert(full_message, {"space-exploration.stack_size_danger_2_krastorio2"})
    else
      table.insert(full_message, {"space-exploration.stack_size_danger_2_generic"})
    end

    if oversized_stacks_count > 30 then
      table.insert(full_message, {"space-exploration.stack_size_danger_list_too_many"})
    else
      table.insert(full_message, {"space-exploration.stack_size_danger_list"})
      if oversized_stacks_count >= 5 then
        table.insert(full_message, "[font=default-small-bold]")
      end

      local first = true
      local oversized_list_message = {""}
      local sub_message
      for i, name in pairs(oversized_stacks) do
      -- Localised string limit is 20 parameters, add a new sub_message every 20 items
        if (i - 1) % 20 == 0 then
          sub_message = {""}
          table.insert(oversized_list_message, sub_message)
        end

        local localised_name = prototypes.item[name].localised_name
        local stack_size = prototypes.item[name].stack_size
        local recommended_size = benchmark_stacks[name] or 200
        if first then
          table.insert(sub_message, {"", localised_name, ": ", stack_size, " ", {"space-exploration.stack_size_recommended", recommended_size}})
        else
          table.insert(sub_message, {"", ",  ", localised_name, ": ", stack_size, " ", {"space-exploration.stack_size_recommended", recommended_size}})
        end
        first = false
      end
      table.insert(full_message, oversized_list_message)

      if oversized_stacks_count >= 5 then
        table.insert(full_message, "[/font]")
      end
    end

    local tick_task = new_tick_task("game-message") --[[@as GameMessageTickTask]]
    tick_task.delay_until = game.tick + 15
    tick_task.message = full_message
  end
end

function Essential.enable_critical_techs()

  for _, force in pairs(game.forces) do
    if not SystemForces.is_system_force(force.name) then
      force.technologies["se-medpack"].enabled = true
      force.technologies["se-medpack-2"].enabled = true
      force.technologies["se-medpack-3"].enabled = true
      force.technologies["se-medpack-4"].enabled = true
      force.technologies["se-energy-beam-defence"].enabled = true
      force.technologies["se-adaptive-armour-1"].enabled = true
      force.technologies["se-adaptive-armour-2"].enabled = true
      force.technologies["se-adaptive-armour-3"].enabled = true
      force.technologies["se-adaptive-armour-4"].enabled = true
      force.technologies["se-adaptive-armour-5"].enabled = true
      force.technologies["se-addon-power-pole"].enabled = true
      force.technologies["se-aeroframe-bulkhead"].enabled = true
      force.technologies["se-aeroframe-pole"].enabled = true
      force.technologies["se-aeroframe-scaffold"].enabled = true
      force.technologies["se-antimatter-engine"].enabled = true
      force.technologies["se-antimatter-production"].enabled = true
      force.technologies["se-antimatter-reactor"].enabled = true
      force.technologies["se-arcosphere"].enabled = true
      force.technologies["se-arcosphere-folding"].enabled = true
      force.technologies["se-astronomic-science-pack-1"].enabled = true
      force.technologies["se-astronomic-science-pack-2"].enabled = true
      force.technologies["se-astronomic-science-pack-3"].enabled = true
      force.technologies["se-astronomic-science-pack-4"].enabled = true
      force.technologies["se-big-heat-exchanger"].enabled = true
      force.technologies["se-big-turbine"].enabled = true
      force.technologies["se-bio-upgrade-agility-1"].enabled = true
      force.technologies["se-bio-upgrade-agility-2"].enabled = true
      force.technologies["se-bio-upgrade-agility-3"].enabled = true
      force.technologies["se-bio-upgrade-agility-4"].enabled = true
      force.technologies["se-bio-upgrade-agility-5"].enabled = true
      force.technologies["se-bio-upgrade-constitution-1"].enabled = true
      force.technologies["se-bio-upgrade-constitution-2"].enabled = true
      force.technologies["se-bio-upgrade-constitution-3"].enabled = true
      force.technologies["se-bio-upgrade-constitution-4"].enabled = true
      force.technologies["se-bio-upgrade-constitution-5"].enabled = true
      force.technologies["se-bio-upgrade-dexterity-1"].enabled = true
      force.technologies["se-bio-upgrade-dexterity-2"].enabled = true
      force.technologies["se-bio-upgrade-dexterity-3"].enabled = true
      force.technologies["se-bio-upgrade-dexterity-4"].enabled = true
      force.technologies["se-bio-upgrade-dexterity-5"].enabled = true
      force.technologies["se-bio-upgrade-intelligence-1"].enabled = true
      force.technologies["se-bio-upgrade-intelligence-2"].enabled = true
      force.technologies["se-bio-upgrade-intelligence-3"].enabled = true
      force.technologies["se-bio-upgrade-intelligence-4"].enabled = true
      force.technologies["se-bio-upgrade-intelligence-5"].enabled = true
      force.technologies["se-bio-upgrade-strength-1"].enabled = true
      force.technologies["se-bio-upgrade-strength-2"].enabled = true
      force.technologies["se-bio-upgrade-strength-3"].enabled = true
      force.technologies["se-bio-upgrade-strength-4"].enabled = true
      force.technologies["se-bio-upgrade-strength-5"].enabled = true
      force.technologies["se-biogun"].enabled = true
      force.technologies["se-biological-science-pack-1"].enabled = true
      force.technologies["se-biological-science-pack-2"].enabled = true
      force.technologies["se-biological-science-pack-3"].enabled = true
      force.technologies["se-biological-science-pack-4"].enabled = true
      force.technologies["se-bioscrubber"].enabled = true
      force.technologies["se-capsule-behemoth-biter"].enabled = true
      force.technologies["se-capsule-behemoth-spitter"].enabled = true
      force.technologies["se-capsule-big-biter"].enabled = true
      force.technologies["se-capsule-big-spitter"].enabled = true
      force.technologies["se-capsule-medium-biter"].enabled = true
      force.technologies["se-capsule-medium-spitter"].enabled = true
      force.technologies["se-capsule-small-biter"].enabled = true
      force.technologies["se-capsule-small-spitter"].enabled = true
      force.technologies["se-condenser-turbine"].enabled = true
      force.technologies["se-core-miner"].enabled = true
      force.technologies["se-deep-catalogue-1"].enabled = true
      force.technologies["se-deep-catalogue-2"].enabled = true
      force.technologies["se-deep-catalogue-3"].enabled = true
      force.technologies["se-deep-catalogue-4"].enabled = true
      force.technologies["se-deep-space-science-pack-1"].enabled = true
      force.technologies["se-deep-space-science-pack-2"].enabled = true
      force.technologies["se-deep-space-science-pack-3"].enabled = true
      force.technologies["se-deep-space-science-pack-4"].enabled = true
      force.technologies["se-deep-space-transport-belt"].enabled = true
      force.technologies["se-delivery-cannon"].enabled = true
      force.technologies["se-delivery-cannon-weapon"].enabled = true
      --force.technologies["se-dimensional-anchor"].enabled = true
      force.technologies["se-dynamic-emitter"].enabled = true
      force.technologies["se-electric-boiler"].enabled = true
      force.technologies["se-energy-beaming"].enabled = true
      force.technologies["se-energy-science-pack-1"].enabled = true
      force.technologies["se-energy-science-pack-2"].enabled = true
      force.technologies["se-energy-science-pack-3"].enabled = true
      force.technologies["se-energy-science-pack-4"].enabled = true
      force.technologies["se-fluid-burner-generator"].enabled = true
      --force.technologies["se-fuel-refining"].enabled = true
      force.technologies["se-heat-shielding"].enabled = true
      force.technologies["se-heavy-assembly"].enabled = true
      force.technologies["se-heavy-bearing"].enabled = true
      force.technologies["se-heavy-composite"].enabled = true
      force.technologies["se-heavy-girder"].enabled = true
      force.technologies["se-holmium-cable"].enabled = true
      force.technologies["se-holmium-solenoid"].enabled = true
      force.technologies["se-lattice-pressure-vessel"].enabled = true
      force.technologies["se-lifesupport-equipment-1"].enabled = true
      force.technologies["se-lifesupport-equipment-2"].enabled = true
      force.technologies["se-lifesupport-equipment-3"].enabled = true
      force.technologies["se-lifesupport-equipment-4"].enabled = true
      force.technologies["se-lifesupport-facility"].enabled = true
      force.technologies["se-linked-container"].enabled = true
      --force.technologies["se-long-range-star-mapping"].enabled = true
      force.technologies["se-material-science-pack-1"].enabled = true
      force.technologies["se-material-science-pack-2"].enabled = true
      force.technologies["se-material-science-pack-3"].enabled = true
      force.technologies["se-material-science-pack-4"].enabled = true
      force.technologies["se-nanomaterial"].enabled = true
      force.technologies["se-naquium-cube"].enabled = true
      force.technologies["se-naquium-processor"].enabled = true
      force.technologies["se-naquium-tessaract"].enabled = true
      force.technologies["se-nexus"].enabled = true
      force.technologies["se-processing-beryllium"].enabled = true
      force.technologies["se-processing-cryonite"].enabled = true
      force.technologies["se-processing-holmium"].enabled = true
      force.technologies["se-processing-iridium"].enabled = true
      force.technologies["se-processing-naquium"].enabled = true
      force.technologies["se-processing-vitamelange"].enabled = true
      force.technologies["se-processing-vulcanite"].enabled = true
      force.technologies["se-pulveriser"].enabled = true
      force.technologies["se-pylon"].enabled = true
      force.technologies["se-pylon-construction"].enabled = true
      force.technologies["se-pylon-construction-radar"].enabled = true
      force.technologies["se-pylon-substation"].enabled = true
      force.technologies["se-quantum-processor"].enabled = true
      force.technologies["se-recycling-facility"].enabled = true
      force.technologies["se-rocket-cargo-safety-1"].enabled = true
      force.technologies["se-rocket-cargo-safety-2"].enabled = true
      force.technologies["se-rocket-cargo-safety-3"].enabled = true
      --force.technologies["se-rocket-fuel-from-water"].enabled = true
      --force.technologies["se-rocket-landing-pad"].enabled = true
      force.technologies["se-rocket-launch-pad"].enabled = true
      force.technologies["se-rocket-reusability-1"].enabled = true
      force.technologies["se-rocket-reusability-2"].enabled = true
      force.technologies["se-rocket-reusability-3"].enabled = true
      force.technologies["se-rocket-survivability-1"].enabled = true
      force.technologies["se-rocket-survivability-2"].enabled = true
      force.technologies["se-rocket-survivability-3"].enabled = true
      force.technologies["se-self-sealing-gel"].enabled = true
      force.technologies["shield-projector"].enabled = true
      force.technologies["se-space-assembling"].enabled = true
      force.technologies["se-space-astrometrics-laboratory"].enabled = true
      force.technologies["se-space-biochemical-laboratory"].enabled = true
      force.technologies["se-space-catalogue-astronomic-1"].enabled = true
      force.technologies["se-space-catalogue-astronomic-2"].enabled = true
      force.technologies["se-space-catalogue-astronomic-3"].enabled = true
      force.technologies["se-space-catalogue-astronomic-4"].enabled = true
      force.technologies["se-space-catalogue-biological-1"].enabled = true
      force.technologies["se-space-catalogue-biological-2"].enabled = true
      force.technologies["se-space-catalogue-biological-3"].enabled = true
      force.technologies["se-space-catalogue-biological-4"].enabled = true
      force.technologies["se-space-catalogue-energy-1"].enabled = true
      force.technologies["se-space-catalogue-energy-2"].enabled = true
      force.technologies["se-space-catalogue-energy-3"].enabled = true
      force.technologies["se-space-catalogue-energy-4"].enabled = true
      force.technologies["se-space-catalogue-material-1"].enabled = true
      force.technologies["se-space-catalogue-material-2"].enabled = true
      force.technologies["se-space-catalogue-material-3"].enabled = true
      force.technologies["se-space-catalogue-material-4"].enabled = true
      force.technologies["se-space-data-card"].enabled = true
      force.technologies["se-space-decontamination-facility"].enabled = true
      force.technologies["se-space-electromagnetics-laboratory"].enabled = true
      force.technologies["se-space-genetics-laboratory"].enabled = true
      force.technologies["se-space-gravimetrics-laboratory"].enabled = true
      force.technologies["se-space-growth-facility"].enabled = true
      force.technologies["se-space-hypercooling-1"].enabled = true
      force.technologies["se-space-hypercooling-2"].enabled = true
      force.technologies["se-space-hypercooling-3"].enabled = true
      force.technologies["se-space-laser-laboratory"].enabled = true
      force.technologies["se-space-manufactory"].enabled = true
      force.technologies["se-space-material-fabricator"].enabled = true
      force.technologies["se-space-matter-fusion"].enabled = true
      force.technologies["se-space-mechanical-laboratory"].enabled = true
      force.technologies["se-space-particle-accelerator"].enabled = true
      force.technologies["se-space-particle-collider"].enabled = true
      force.technologies["se-space-plasma-generator"].enabled = true
      force.technologies["se-space-platform-plating"].enabled = true
      force.technologies["se-space-platform-scaffold"].enabled = true
      force.technologies["se-space-probe"].enabled = true
      force.technologies["se-space-radiating-efficiency"].enabled = true
      force.technologies["se-space-radiating-speed"].enabled = true
      force.technologies["se-space-radiation-laboratory"].enabled = true
      force.technologies["se-space-radiator-1"].enabled = true
      force.technologies["se-space-radiator-2"].enabled = true
      force.technologies["se-space-rail"].enabled = true
      force.technologies["se-space-science-lab"].enabled = true
      force.technologies["se-space-simulation-ab"].enabled = true
      force.technologies["se-space-simulation-abm"].enabled = true
      force.technologies["se-space-simulation-am"].enabled = true
      force.technologies["se-space-simulation-as"].enabled = true
      force.technologies["se-space-simulation-asb"].enabled = true
      force.technologies["se-space-simulation-asbm"].enabled = true
      force.technologies["se-space-simulation-asm"].enabled = true
      force.technologies["se-space-simulation-bm"].enabled = true
      force.technologies["se-space-simulation-sb"].enabled = true
      force.technologies["se-space-simulation-sbm"].enabled = true
      force.technologies["se-space-simulation-sm"].enabled = true
      force.technologies["se-space-solar-panel"].enabled = true
      force.technologies["se-space-solar-panel-2"].enabled = true
      force.technologies["se-space-solar-panel-3"].enabled = true
      force.technologies["se-space-supercomputer-1"].enabled = true
      force.technologies["se-space-supercomputer-2"].enabled = true
      force.technologies["se-space-supercomputer-3"].enabled = true
      force.technologies["se-space-supercomputer-4"].enabled = true
      force.technologies["se-space-telescope"].enabled = true
      force.technologies["se-space-telescope-gammaray"].enabled = true
      force.technologies["se-space-telescope-microwave"].enabled = true
      force.technologies["se-space-telescope-radio"].enabled = true
      force.technologies["se-space-telescope-xray"].enabled = true
      force.technologies["se-space-thermodynamics-laboratory"].enabled = true
      force.technologies["se-spaceship-clamps"].enabled = true
      force.technologies["se-supercharger"].enabled = true
      force.technologies["se-teleportation"].enabled = true
      force.technologies["se-vitalic-acid"].enabled = true
      force.technologies["se-vitalic-epoxy"].enabled = true
      force.technologies["se-vitalic-reagent"].enabled = true
      force.technologies["se-wide-beacon"].enabled = true
      force.technologies["se-wide-beacon-2"].enabled = true
      force.technologies["se-zone-discovery-deep"].enabled = true
      force.technologies["se-zone-discovery-random"].enabled = true
      force.technologies["se-zone-discovery-targeted"].enabled = true
      force.technologies["se-cryogun"].enabled = true
      force.technologies["se-factory-spaceship-1"].enabled = true
      force.technologies["se-factory-spaceship-2"].enabled = true
      force.technologies["se-factory-spaceship-3"].enabled = true
      force.technologies["se-factory-spaceship-4"].enabled = true
      force.technologies["se-factory-spaceship-5"].enabled = true
      force.technologies["se-meteor-defence"].enabled = true
      force.technologies["se-meteor-point-defence"].enabled = true
      force.technologies["se-plague"].enabled = true
      force.technologies["se-railgun"].enabled = true
      force.technologies["se-rtg-equipment"].enabled = true
      force.technologies["fission-reactor-equipment"].enabled = true
      force.technologies["se-fusion-reactor-equipment"].enabled = true
      force.technologies["se-antimatter-reactor-equipment"].enabled = true
      force.technologies["se-space-accumulator"].enabled = true
      force.technologies["se-space-accumulator-2"].enabled = true
      force.technologies["se-spaceship"].enabled = true
      force.technologies["se-spaceship-integrity-1"].enabled = true
      force.technologies["se-spaceship-integrity-2"].enabled = true
      force.technologies["se-spaceship-integrity-3"].enabled = true
      force.technologies["se-spaceship-integrity-4"].enabled = true
      force.technologies["se-spaceship-integrity-5"].enabled = true
      force.technologies["se-spaceship-integrity-6"].enabled = true
      force.technologies["se-spaceship-integrity-7"].enabled = true
      force.technologies["se-superconductive-cable"].enabled = true
      force.technologies["se-tesla-gun"].enabled = true
      force.technologies["se-thruster-suit"].enabled = true
      force.technologies["se-thruster-suit-2"].enabled = true
      force.technologies["se-thruster-suit-3"].enabled = true
      force.technologies["se-thruster-suit-4"].enabled = true
      force.technologies["se-rocket-science-pack"].enabled = true
      if not script.active_mods["Krastorio2"] then
        force.technologies["se-spaceship-victory"].enabled = true
      end
    end
  end
end
return Essential
