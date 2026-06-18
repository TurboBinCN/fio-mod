local Watermark = {}

Watermark.watermark_string_frame_name = "se_watermark_string_frame"
Watermark.watermark_string_label_name = "se_watermark_string_label"

Watermark.watermark_string = nil

function Watermark.get_watermark_string()
  if not Watermark.watermark_string then
    Watermark.watermark_string = Watermark.build_watermark_string()
  end
  return Watermark.watermark_string
end

function Watermark.build_watermark_string()
  local watermark_parts = {}

  if not script.active_mods[script.mod_name] then
    -- Probably loaded a sim save file
    return
  end

  -- Version
  table.insert(watermark_parts, "SE")
  table.insert(watermark_parts, script.active_mods[script.mod_name])

  -- Testing label (optional)
  if is_debug_mode then
    table.insert(watermark_parts, "DEVELOPMENT VERSION")
  elseif is_closed_testing then
    table.insert(watermark_parts, "CLOSED TESTING")
  end

  -- Science modifier (optional)
  if game.difficulty_settings.technology_price_multiplier > 1 then
    table.insert(watermark_parts, "x" .. game.difficulty_settings.technology_price_multiplier)
  elseif script.active_mods["progressive-tech-multiplier"] then
    table.insert(watermark_parts, "xProg")
  end

  -- Number of techs
  local technologies = prototypes.get_technology_filtered({
    {filter="enabled"},
    {mode="and", filter="hidden", invert=true}
  })
  table.insert(watermark_parts, "T" .. #technologies)

  -- Overhauls (optional)
  local overhauls = {}
  if script.active_mods["Krastorio2"] then
    watermark_parts[1] = "K2" .. watermark_parts[1]
  end
  if script.active_mods["space-age"] then
    watermark_parts[1] = watermark_parts[1] .. "SA"
  end
  if script.active_mods["bzvery"] then
    table.insert(overhauls, "BZ")
  end
  if next(overhauls) then
    table.insert(watermark_parts, "(+ " .. table.concat(overhauls, " ") .. ")")
  end

  return table.concat(watermark_parts, " ")
end

function Watermark.gui_create_update(player)
  if script.level.is_simulation then
    return
  end
  local frame = player.gui.screen[Watermark.watermark_string_frame_name]
  if not frame or not frame.valid then
    frame = player.gui.screen.add({
      type = "frame",
      name = Watermark.watermark_string_frame_name,
      style = Watermark.watermark_string_frame_name,
      direction = "horizontal",
      ignored_by_interaction = true,
    })
  elseif frame.style ~= Watermark.watermark_string_frame_name then
    -- There's been one case of someone losing the styles on the watermark
    -- I don't know why another mod would do that, but it's really bad if it happens since it covers the whole screen
    -- Better safe than sorry
    frame.style = Watermark.watermark_string_frame_name
  end
  local label = frame[Watermark.watermark_string_label_name]
  if not label or not label.valid then
    label = frame.add({
      type = "label",
      name = Watermark.watermark_string_label_name,
      style = Watermark.watermark_string_label_name,
    })
  elseif label.style ~= Watermark.watermark_string_label_name then
    label.style = Watermark.watermark_string_label_name
  end
  label.caption = Watermark.get_watermark_string()
  Watermark.gui_set_size(player)
end

function Watermark.gui_set_size(player)
  local frame = player.gui.screen[Watermark.watermark_string_frame_name]
  if not frame or not frame.valid then
    Watermark.gui_create_update(player) -- Will call back gui_set_width
    return
  end
  frame.style.height = player.display_resolution.height / player.display_scale
  frame.style.width = player.display_resolution.width / player.display_scale
end

function Watermark.on_player_created(event)
  Watermark.gui_create_update(game.get_player(event.player_index))
end
Event.addListener(defines.events.on_player_created, Watermark.on_player_created)

function Watermark.on_configuration_changed(event)
  for _, player in pairs(game.players) do
    Watermark.gui_create_update(player)
  end
end
Event.addListener("on_configuration_changed", Watermark.on_configuration_changed, true)

function Watermark.on_player_screen_changed(event)
  Watermark.gui_set_size(game.get_player(event.player_index))
end
Event.addListener(defines.events.on_player_display_resolution_changed, Watermark.on_player_screen_changed)
Event.addListener(defines.events.on_player_display_scale_changed, Watermark.on_player_screen_changed)


return Watermark
