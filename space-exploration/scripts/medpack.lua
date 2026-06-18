Medpack = {}

-- constants
Medpack.trigger_base_name = mod_prefix.."heal-trigger-"
Medpack.search_radius = 8

---@param event EventData.on_trigger_created_entity Event data
function Medpack.on_trigger_created_entity(event)
  if not event.entity and event.entity.valid then return end
  if string.starts(event.entity.name, Medpack.trigger_base_name) then
    local suffix = util.replace(event.entity.name, Medpack.trigger_base_name, "")
    -- number is at the end.
    local heal = util.string_to_number(suffix)
    if heal and heal > 0 then
      local instigator = event.source
      if not instigator then return end

      local surface = event.entity.surface
      local position = event.entity.position
      local forces = ceasefire_forces(instigator.force)
      local friends = surface.find_entities_filtered{
        position = position,
        radius = Medpack.search_radius,
        force = forces,
        type = {"character", "unit"}
      }
      local heal_target = nil
      local best_distance = math.huge
      for _, friend in pairs(friends) do
        -- TODO: when entity.prototype.trigger_target_mask is readable then use the biological mask.
        if friend.prototype.flags["breaths-air"] then
          local distance  = util.vectors_delta_length(position, friend.position)
          if distance < best_distance then
            best_distance = distance
            heal_target = friend
          end
        end
      end
      if heal_target then
        heal_target.health = heal_target.health + heal
      end
    end
  end
end
Event.addListener(defines.events.on_trigger_created_entity, Medpack.on_trigger_created_entity)

return Medpack
