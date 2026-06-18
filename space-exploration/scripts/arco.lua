local Arco = {}

Arco.name_gravimetrics_lab = mod_prefix.."space-gravimetrics-laboratory"
Arco.name_arcosphere_collector = mod_prefix.."arcosphere-collector"
Arco.name_arcosphere = mod_prefix.."arcosphere"
Arco.collection_global = 0.8
Arco.collection_local = 0.2 -- there are 44 space zones so this needs to be low, 0.2 means 8.8x the number of spheres are available.

---@param force_name string
---@param zone_index uint
---@return integer
---@return integer
function Arco.collector_get_orbs(force_name, zone_index)
  local forcedata = storage.forces[force_name]

  -- global factor
  forcedata.arcosphere_collectors_launched = forcedata.arcosphere_collectors_launched or 0
  forcedata.arcospheres_collected = forcedata.arcospheres_collected or 0

  local launched_global = forcedata.arcosphere_collectors_launched
  local collected_next_global = math.ceil(Arco.collection_global * (math.log(launched_global+1+10)*50-math.log(10)*50))
  local collect_global = math.max(0, collected_next_global - forcedata.arcospheres_collected)

  -- local factor
  forcedata.zone_arcospheres = forcedata.zone_arcospheres or {}
  forcedata.zone_arcospheres[zone_index] = forcedata.zone_arcospheres[zone_index] or {}
  forcedata.zone_arcospheres[zone_index].arcosphere_collectors_launched = forcedata.zone_arcospheres[zone_index].arcosphere_collectors_launched or 0
  forcedata.zone_arcospheres[zone_index].arcospheres_collected = forcedata.zone_arcospheres[zone_index].arcospheres_collected  or 0

  local launched_local = forcedata.zone_arcospheres[zone_index].arcosphere_collectors_launched
  local collected_next_local = math.ceil(Arco.collection_local * (math.log(launched_local+1+10)*50-math.log(10)*50))
  local collect_local = math.max(0, collected_next_local - forcedata.zone_arcospheres[zone_index].arcospheres_collected)

  Log.debug("launched global "..launched_global.." local "..launched_local)
  Log.debug("collect global "..collect_global.." local "..collect_local)
  return collect_global, collect_local -- returns 2 values
end

---@param force_name string
---@param zone_index uint
function Arco.collector_increment(force_name, zone_index)
  local forcedata = storage.forces[force_name]

  forcedata.arcosphere_collectors_launched = (forcedata.arcosphere_collectors_launched or 0) + 1

  forcedata.zone_arcospheres = forcedata.zone_arcospheres or {}
  forcedata.zone_arcospheres[zone_index] = forcedata.zone_arcospheres[zone_index] or {}
  forcedata.zone_arcospheres[zone_index].arcosphere_collectors_launched = (forcedata.zone_arcospheres[zone_index].arcosphere_collectors_launched or 0) + 1
end

--[[
---@param event EventData.on_rocket_launched Event data
function Arco.on_rocket_launched(event)
  if event.rocket and event.rocket.valid then
    local zone = Zone.from_surface(event.rocket.surface)
    if event.rocket.attached_cargo_pod.get_item_count(Arco.name_arcosphere_collector) > 0 then
      if zone and zone.type == "asteroid-field" then
        ---@cast zone AsteroidFieldType
        local inv = event.rocket_silo.get_inventory(defines.inventory.rocket_silo_result)
        local empty = inv.count_empty_stacks(true)
        local forcedata = storage.forces[event.rocket.force.name]
        local inserted = 0
        local spheres_global, spheres_local = Arco.collector_get_orbs(event.rocket.force.name, zone.index) -- gets 2 values
        Log.debug("on_rocket_launched empty slots: " .. empty)
        if empty > 0 then
          if spheres_global + spheres_local > 0 then
            inserted = inserted + inv.insert({name=Arco.name_arcosphere, count= spheres_global + spheres_local})
          end
          if inserted > 0 then
            event.rocket.force.get_item_production_statistics(event.rocket.surface).on_flow(Arco.name_arcosphere, inserted)
          end
        end
        local inserted_global = math.min(spheres_global, inserted) -- remove from global pool first
        local inserted_local = inserted - inserted_global
        if inserted_global > 0 then
          forcedata.arcospheres_collected = (forcedata.arcospheres_collected or 0) + inserted_global
        end
        if inserted_local > 0 then
          forcedata.zone_arcospheres[zone.index].arcospheres_collected = (forcedata.zone_arcospheres[zone.index].arcospheres_collected or 0) + inserted_local
        end
        Arco.collector_increment(event.rocket.force.name, zone.index)
      end
    end
  end
end
Event.addListener(defines.events.on_rocket_launched, Arco.on_rocket_launched)
]]

---@param event EventData.on_cargo_pod_finished_ascending  Event data
function Arco.on_cargo_pod_finished_ascending (event)
  if event.cargo_pod and event.cargo_pod.valid and event.launched_by_rocket then
    local inv = event.cargo_pod.get_inventory(defines.inventory.chest)
    local zone = Zone.from_surface(event.cargo_pod.surface)
    local arcosphere_collectors = inv.get_item_quality_counts(Arco.name_arcosphere_collector)
    if next(arcosphere_collectors) and zone and zone.type == "asteroid-field" then
      ---@cast zone AsteroidFieldType
      local quality_name, item_count = next(arcosphere_collectors)
      event.cargo_pod.force.get_item_production_statistics(event.cargo_pod.surface).on_flow({name = Arco.name_arcosphere_collector, quality = quality_name}, -item_count)
      inv.clear()
      local forcedata = storage.forces[event.cargo_pod.force.name]
      local inserted = 0
      local spheres_global, spheres_local = Arco.collector_get_orbs(event.cargo_pod.force.name, zone.index) -- gets 2 values
      if spheres_global + spheres_local > 0 then
        inserted = inserted + inv.insert({name = Arco.name_arcosphere, count = spheres_global + spheres_local, quality = quality_name})
      end
      if inserted > 0 then
        event.cargo_pod.force.get_item_production_statistics(event.cargo_pod.surface).on_flow({name = Arco.name_arcosphere, quality = quality_name}, inserted)
      end
      local inserted_global = math.min(spheres_global, inserted) -- remove from global pool first
      local inserted_local = inserted - inserted_global
      if inserted_global > 0 then
        forcedata.arcospheres_collected = (forcedata.arcospheres_collected or 0) + inserted_global
      end
      if inserted_local > 0 then
        forcedata.zone_arcospheres[zone.index].arcospheres_collected = (forcedata.zone_arcospheres[zone.index].arcospheres_collected or 0) + inserted_local
      end
      Arco.collector_increment(event.cargo_pod.force.name, zone.index)
      local dest = event.cargo_pod.cargo_pod_destination
      dest.transform_launch_products = false
      event.cargo_pod.cargo_pod_destination = dest
    end
  end
end
Event.addListener(defines.events.on_cargo_pod_finished_ascending , Arco.on_cargo_pod_finished_ascending)


---@param event EventData.on_rocket_launch_ordered Event data
function Arco.on_rocket_launch_ordered(event)
  if event.rocket and event.rocket.valid then
    local zone = Zone.from_surface(event.rocket.surface)
    if event.rocket.attached_cargo_pod.get_item_count(Arco.name_arcosphere_collector) > 0 then
      if not (zone and zone.type == "asteroid-field") then
        ---@cast zone AsteroidFieldType
        -- launch location is invalid.
        local tick_task = new_tick_task("force-message") --[[@as ForceMessageTickTask]]
        tick_task.force_name = event.rocket.force.name
        tick_task.message = {"space-exploration.arcosphere_collector_invalid_launch"}
        tick_task.delay_until = event.tick + 750 --5s
        local probe_count = event.rocket.attached_cargo_pod.get_item_count(Arco.name_arcosphere_collector)
        event.rocket.attached_cargo_pod.remove_item({name=Arco.name_arcosphere_collector, count=probe_count})
      end
    end
  end
end
Event.addListener(defines.events.on_rocket_launch_ordered, Arco.on_rocket_launch_ordered)

---@param event EntityCreationEvent|{entity:LuaEntity} Event data
function Arco.on_entity_created(event)

  local entity
  if event.entity and event.entity.valid then entity = event.entity end
  if not entity then return end

  if entity.name == Arco.name_gravimetrics_lab then
    storage.gravimetrics_labs[entity.unit_number] = {
      unit_number = entity.unit_number,
      force_name = entity.force.name,
      entity = entity,
      products_finished = 0
    }
  end
end
Event.addOnEntityCreatedListeners(Arco.on_entity_created)

---@param surface LuaSurface
function Arco.reset_surface(surface)
  for _, entity in pairs(surface.find_entities_filtered{name = Arco.name_gravimetrics_lab}) do
    Arco.on_entity_created({entity = entity})
  end
end

---@param lab GravimetricsLabInfo
function Arco.swap_recipe(lab)
  local recipe, quality = lab.entity.get_recipe()
  local set_recipe
  if recipe then
    if string.find(recipe.name, "-alt", 1, true) then
      set_recipe = Util.replace(recipe.name, "-alt", "")
    else
      if prototypes.recipe[recipe.name.."-alt"] then
        set_recipe = recipe.name.."-alt"
      end
    end
  end
  if set_recipe then
    local crafting_progress = lab.entity.crafting_progress
    lab.entity.set_recipe(set_recipe, quality)
    -- setting the recipe will have returned the ingredients
    if crafting_progress > 0 then
      -- remove the ingredients again, as setting a positive crafting progress starts the crafting for free.
      local input = lab.entity.get_inventory(defines.inventory.crafter_input)
      local recipe = prototypes.recipe[set_recipe]
      for _, ingredient in pairs(recipe.ingredients) do
        if ingredient.type == "item" then
          input.remove({name = ingredient.name, count = ingredient.amount})
        else -- fluid
          -- NOTE: It may not look like fluid is returned when swapping the recipe, but it is, it just takes a tick to show up.
          local fluid = lab.entity.fluidbox[1]
          if fluid then
            fluid.amount = fluid.amount - ingredient.amount
            if fluid.amount > 0 then
              lab.entity.fluidbox[1] = fluid
            else
              lab.entity.fluidbox[1] = nil
            end
          end
        end
      end
      lab.entity.crafting_progress = crafting_progress
    end
  end
end

function Arco.on_nth_tick_60()
  for unit_number, lab in pairs(storage.gravimetrics_labs) do
    if lab.entity and lab.entity.valid then
      if lab.entity.products_finished ~= lab.products_finished then
        lab.products_finished = lab.entity.products_finished
        if math.random() < 0.314 then
          Arco.swap_recipe(lab)
        end
      end
    else
      storage.gravimetrics_labs[unit_number] = nil
    end
  end
end
Event.addListener("on_nth_tick_60", Arco.on_nth_tick_60) -- 1 second

function Arco.on_init()
  storage.gravimetrics_labs = {}
end
Event.addListener("on_init", Arco.on_init, true)

return Arco
