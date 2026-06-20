data:extend(
  {
    {
      type = "shortcut",
      name = "transport-drones-gui",
      associated_control_input = "toggle-road-network-gui",
      localised_name = {"shortcut.transport-drones-gui"},
      order = "a[transport-drones]",
      action = "lua",
      technology_to_unlock = shared.transport_system_technology,
      style = "blue",
      icon = util.path("data/entities/transport_drone/transport-drone-icon.png"),
      icon_size = 113,
      small_icon = util.path("data/entities/transport_drone/transport-drone-icon.png"),
      small_icon_size = 113
    }
  }
)