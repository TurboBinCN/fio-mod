local hotkeys =
{
  {
    type = "custom-input",
    name = "follow-drone",
    localised_name = {"controls.follow-drone"},
    linked_game_control = "toggle-driving",
    key_sequence = "return",
    enabled_while_in_cutscene = true
  },
  {
    type = "custom-input",
    name = "toggle-road-network-gui",
    localised_name = {"controls.toggle-road-network-gui"},
    key_sequence = "CONTROL + T",
    enabled_while_in_cutscene = true
  },
  {
    type = "custom-input",
    name = "toggle-transport-network-overlay",
    localised_name = {"controls.toggle-transport-network-overlay"},
    key_sequence = "CONTROL + SHIFT + T",
    enabled_while_in_cutscene = true
  },
}

data:extend(hotkeys)