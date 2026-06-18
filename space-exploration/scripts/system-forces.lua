local SystemForces = {}

SystemForces.system_forces = core_util.list_to_map{
  "enemy",
  "neutral",
  "capture",
  "conquest",
  "ignore",
  "friendly",
  "kr-internal-turrets"  -- Krastorio 2 tesla coils and planetary teleporters
}
SystemForces.protected_system_forces = {"capture", "conquest", "friendly"}
SystemForces.protected_system_forces_map = core_util.list_to_map(SystemForces.protected_system_forces)

---@param force_name string
---@return boolean
function SystemForces.is_system_force(force_name)
  return SystemForces.system_forces[force_name]
    or string.starts(force_name, "EE_") -- Editor Extensions
    or string.starts(force_name, "bpsb-") -- Blueprint Sandboxes
end


function SystemForces.setup_system_forces()
  if not game.forces["conquest"] then
    game.create_force("conquest") -- will shoot at the player, does not show icons, cannot be deconstructed. Has capture mechanic but active entities must be destroyed.
  end
  local conquest = game.forces["conquest"]
  conquest.ai_controllable = true
  SystemForces.setup_conquest_tech(conquest)

  if not game.forces["ignore"] then
    game.create_force("ignore") -- won't shoot at the player, does not show icons, cannot be deconstructed.
  end
  local ignore = game.forces["ignore"]
  for _, force in pairs(game.forces) do
    ignore.set_cease_fire(force, true)
    force.set_cease_fire(ignore, true)
  end

  if not game.forces["capture"] then
    game.create_force("capture") -- won't shoot at the player, does not show icons, cannot be deconstructed. Has capture mechanic.
  end
  local capture = game.forces["capture"]
  for _, force in pairs(game.forces) do
    capture.set_cease_fire(force, true)
    force.set_cease_fire(capture, true)
  end

  if not game.forces["friendly"] then
    game.create_force("friendly") -- acts like a player entity, displays power icons, can be deconstructured by player
  end
  local friendly = game.forces["friendly"]
  for _, force in pairs(game.forces) do
    friendly.set_friend(force, true)
    force.set_friend(friendly, true)
  end

  local enemy = game.forces["enemy"]
  enemy.set_friend(conquest, true)
  conquest.set_friend(enemy, true)

  capture.set_friend(conquest, true)
  conquest.set_friend(capture, true)
  capture.set_friend(ignore, true)
  ignore.set_friend(capture, true)
  capture.set_friend(enemy, true)
  enemy.set_friend(capture, true)

  ignore.set_friend(conquest, true)
  conquest.set_friend(ignore, true)
  ignore.set_friend(enemy, true)
  enemy.set_friend(ignore, true)
end

function SystemForces.setup_conquest_tech(conquest_force)
  util.safe_research_tech(conquest_force, "artillery")
  util.safe_research_tech(conquest_force, "tank")
  util.safe_research_tech(conquest_force, "radar")
  util.safe_research_tech(conquest_force, "electronics")
  util.safe_research_tech(conquest_force, "sulfur-processing")
  util.safe_research_tech(conquest_force, "explosives")
  util.safe_research_tech(conquest_force, "electricity")
  util.safe_research_tech(conquest_force, "fuel-processing")
  util.safe_research_tech(conquest_force, "repair-pack")

  -- Using force modifiers is more resistant to mod changes compared to researching tech levels
  conquest_force.worker_robots_speed_modifier = 5.65 -- Equivalent to tech level 10
  conquest_force.worker_robots_storage_bonus = 3
  conquest_force.artillery_range_modifier = 1.8 -- Equivalent to tech level 6
  conquest_force.set_gun_speed_modifier("artillery-shell", 6) -- Equivalent to tech level 6
  conquest_force.set_gun_speed_modifier("laser", 2.2) -- Equivalent to tech level 7
  conquest_force.set_ammo_damage_modifier("laser", 5.1) -- Equivalent to tech level 10
end

---@param player LuaPlayer
function SystemForces.player_capture_selected(player)
  local playerdata = get_make_playerdata(player)
  if playerdata.capture_text and playerdata.capture_text.valid then
    playerdata.capture_text.destroy()
  end
  local entity = player.selected
  if entity and (entity.force.name == "capture" or entity.force.name == "conquest") and entity.type ~= "wall" then
    local range = 1
    local box = entity.bounding_box
    local pos = player.position
    if player.character and pos.x > box.left_top.x - range
      and pos.x < box.right_bottom.x + range
      and pos.y > box.left_top.y - range
      and pos.y < box.right_bottom.y + range then
        local blocker = entity.surface.find_nearest_enemy{position=entity.position, max_distance=32, force=player.force}
        if blocker then
          player.create_local_flying_text{
            position = entity.position,
            text = {"space-exploration.capture-blocked"},
          }
        else
          entity.force = player.force
          local zone = Zone.from_surface(entity.surface)
          if zone then
            local inventory = entity.get_inventory(defines.inventory.chest)
            if inventory then
              for _, item_name in pairs(Ruin.track_loot_items) do
                local count = inventory.get_item_count(item_name)
                if count > 0 then
                  zone.looted_items = zone.looted_items or {}
                  zone.looted_items[item_name] = (zone.looted_items[item_name] or 0) + count
                end
              end
            end
          end
          if entity.name == "se-spaceship-console" then

            -- Destroy the spaceship and recreate it in the player's
            -- force to correctly setup the schedulre.
            local position = entity.position
            local surface = entity.surface
            local old_name = Spaceship.from_entity(entity).name
            entity.destroy{raise_destroy=true}
            local new_console = surface.create_entity{
              name = "se-spaceship-console",
              position = position,
              force = player.force,
              raise_built = true,
            }
            Spaceship.rename(Spaceship.from_entity(new_console), old_name)

            -- capture the rest of the ship in a very brutal way
            for _, subentity in pairs(surface.find_entities_filtered{force = "capture"}) do
              subentity.force = player.force
              if subentity.name == mod_prefix.."space-pipe-to-ground" then -- top up what got lost during force changes
                subentity.insert_fluid({name = mod_prefix.."ion-stream", amount = 100})
              end
            end
          end
        end
    else
      if not Util.table_contains(
      {"turret", "ammo-turret", "electric-turret", "fluid-turret", "artillery-turret",
        "combat-robot", "logistic-robot", "construction-robot",
        "wall", "gate"}, entity.type) then
          playerdata.capture_text = rendering.draw_text{
            text = {"space-exploration.touch-to-capture"},
            surface = entity.surface,
            target = {entity = entity, offset = {0, -0.5}},
            players={player},
            color={r=0.8,g=0.8,b=0.8,a=0.8},
            alignment="center",
            scale = (1 + box.right_bottom.x-box.left_top.x)/3,
        }
      end
    end
  end
end

---@param event EventData.on_force_reset|EventData.on_technology_effects_reset
function SystemForces.on_force_reset(event)
  if SystemForces.system_forces[event.force.name] then
    SystemForces.setup_system_forces()
  end
end
Event.addListener(defines.events.on_force_reset, SystemForces.on_force_reset)
Event.addListener(defines.events.on_technology_effects_reset, SystemForces.on_force_reset)

return SystemForces
