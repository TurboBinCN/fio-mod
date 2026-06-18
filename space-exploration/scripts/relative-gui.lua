local RelativeGUI = {}

RelativeGUI.relative_guis = {}

--- Registers a relative GUI to open for a particular entity.
--- The same relative GUI can be regsitered for multiple entities (see delivery cannons for example)
---@generic T
---@param name_root string the name of the GUI element that holds the relative gui in player.gui.relative
---@param name_entity string the name of the entity for which to open this relative gui
---@param gui_open fun(player:LuaPlayer, struct:T) the function that opens the relative gui
---@param entity_convert? fun(entity:LuaEntity):T? the function that converts the entity into a useable format for the gui_open function
function RelativeGUI.register_relative_gui(name_root, name_entity, gui_open, entity_convert)
  RelativeGUI.relative_guis[name_entity] = {
    name_root = name_root,
    gui_open = gui_open,
    entity_convert = entity_convert
  }
end

--- Safely closes a relative GUI
---@param player LuaPlayer player for which to close the gui
---@param name_root string the name of the GUI element that holds the relative gui to close
function RelativeGUI.gui_close(player, name_root)
  local gui = player.gui.relative[name_root]
  if gui then gui.destroy() end
end

--- Event handler that ensures that the relative entity GUI is properly destroyed/cleaned-up when
--- the gui for the entity to which it is attached is closed
---@param event EventData.on_gui_closed Event data
function RelativeGUI.on_gui_closed(event)
  local entity = event.entity
  if not (entity and entity.valid) then return end
  local player = game.get_player(event.player_index)
  ---@cast player -?
  if not player then return end
  local relative_gui = RelativeGUI.relative_guis[entity.name]
  if relative_gui then
    RelativeGUI.gui_close(player, relative_gui.name_root)
  end
end
Event.addListener(defines.events.on_gui_closed, RelativeGUI.on_gui_closed)

--- Event handler that ensures two things:
--- 1. that the relative GUI is opened when the entity's GUI is opened
--- 2. that the relative GUI is closed when a different entity's GUI is opened
---@param event EventData.on_gui_opened Event data
function RelativeGUI.on_gui_opened(event)
  local entity = event.entity
  if not (entity and entity.valid) then return end
  local player = game.get_player(event.player_index)
  ---@cast player -?
  if not player then return end
  local opened_gui = RelativeGUI.relative_guis[entity.name]
  for _, relative_gui in pairs(RelativeGUI.relative_guis) do
    if opened_gui and opened_gui.name_root == relative_gui.name_root then
      if opened_gui.entity_convert then
        opened_gui.gui_open(player, opened_gui.entity_convert(entity))
      else
        opened_gui.gui_open(player, entity)
      end
    else
      RelativeGUI.gui_close(player, relative_gui.name_root)
    end
  end
end
Event.addListener(defines.events.on_gui_opened, RelativeGUI.on_gui_opened)

return RelativeGUI
