local data_util = require("data_util")

local style = data.raw["gui-style"]["default"]

local entity_settings_frame_width = 354
local ui_width = 300
local margin_right = 20
local space_for_button = 36
local blank_image = {
  filename = "__space-exploration-graphics__/graphics/blank.png",
  priority = "very-low",
  width = 1,
  height = 1,
  frame_count = 1,
  scale = 8,
}

data.raw["gui-style"]["default"]["se_titlebar_drag_handle"] = {
  type = "empty_widget_style",
  parent = "draggable_space",
  left_margin = 4,
  right_margin = 4,
  height = 24,
  horizontally_stretchable = "on"
}
data.raw["gui-style"]["default"]["se_stretchable_subheader_frame"] = {
  type = "frame_style",
  parent = "subheader_frame",
  horizontally_stretchable = "on",
  horizontally_squashable = "on",
}

data.raw["gui-style"]["default"]["space_platform_textfield"] = {
    width = ui_width - margin_right,
    type = "textbox_style",
}
data.raw["gui-style"]["default"]["space_platform_textfield_short"] = {
    width = ui_width - margin_right - space_for_button,
    type = "textbox_style",
}
data.raw["gui-style"]["default"]["space_platform_label"] = {
    width = ui_width - margin_right,
    parent= "label",
    type = "label_style",
    single_line = false,
}
data.raw["gui-style"]["default"]["space_platform_label_short"] = {
    width = ui_width - margin_right - space_for_button,
    parent= "label",
    type = "label_style",
    single_line = false,
}
data.raw["gui-style"]["default"]["space_platform_title"] = {
    width = ui_width - margin_right,
    parent= "label",
    type = "label_style",
    font = "default-large-semibold",
    single_line = false,
}
data.raw["gui-style"]["default"]["space_platform_title_short"] = {
    width = ui_width - margin_right - space_for_button,
    parent= "label",
    type = "label_style",
    font = "default-large-semibold",
    single_line = false,
}
data.raw["gui-style"]["default"]["space_platform_fieldset"] = {
    width = ui_width - margin_right,
    type = "frame_style",
    parent = "frame",
}
data.raw["gui-style"]["default"]["space_platform_container"] = {
    width = entity_settings_frame_width,
    type = "frame_style",
    parent = "frame",
}
data.raw["gui-style"]["default"]["space_platform_sprite_button"] = {
    type = "button_style",
    parent = "button",
    width = 32,
    height = 32,
    top_padding = 1,
    right_padding = 1,
    bottom_padding = 1,
    left_padding = 1,
}
data.raw["gui-style"]["default"]["space_platform_sprite_button_medium"] = {
    type = "button_style",
    parent = "space_platform_sprite_button",
    width = 28,
    height = 28,
}
data.raw["gui-style"]["default"]["space_platform_sprite_button_small"] = {
    type = "button_style",
    parent = "space_platform_sprite_button",
    width = 20,
    height = 20,
}
data.raw["gui-style"]["default"]["space_platform_button"] = {
    type = "button_style",
    parent = "button",
}

data.raw["gui-style"]["default"]["space_platform_subheader_frame"] = {
  type="frame_style",
  parent="frame",
  vertical_flow_style={type="vertical_flow_style", vertical_spacing=2},
  top_padding=6,--3,
  bottom_padding=4,--1,
  left_padding=12,--4,
  right_padding=12,--4,
  graphical_set=data.raw["gui-style"]["default"]["subheader_frame"].graphical_set
}

data.raw["gui-style"]["default"]["space_platform_line_divider"] = {
  type="line_style",
  top_margin=5
}

data.raw["gui-style"]["default"]["se_entity_settings_frame"] = {
  type="frame_style",
  parent="frame",
  vertical_flow_style={
    type="vertical_flow_style",
    width=entity_settings_frame_width - (12*2),
  }
}

data.raw["gui-style"]["default"]["se_entity_settings_inner_flow"] = {
  type="vertical_flow_style",
  padding=12
}

data.raw["gui-style"]["default"]["se_entity_settings_zones_dropdown"] = {
  type="dropdown_style",
  top_padding=4,
  bottom_padding=4,
  horizontally_stretchable="on"
}

data.raw["gui-style"]["default"]["se_entity_settings_target_coordinates_flow"] = {
  type="horizontal_flow_style",
  vertical_align="center"
}

data.raw["gui-style"]["default"]["se_entity_settings_set_target_button"] = {
  type="button_style",
  parent="frame_action_button",
  width=36,
  height=36,
  padding=4
}

data.raw["gui-style"]["default"]["se_space_capsule_info_label"] = {
  type="label_style",
  single_line=false
}

data.raw["gui-style"]["default"]["se_spaceship_integrity_status_label"] = {
  type="label_style",
  single_line=false,
  minimal_height = 20 -- One lines
}

data.raw["gui-style"]["default"]["se_spaceship_frame_action_button"] = {
  type="button_style",
  parent="frame_action_button",
  size = 28,
  padding = 0,
  top_margin = 1
}


data.raw["gui-style"]["default"]["se_space_capsule_green_launch_button"] = {
  type="button_style",
  parent="confirm_button",
  top_margin=10,
  horizontally_stretchable="on",
  horizontal_align="left"
}

data.raw["gui-style"]["default"]["se_space_capsule_yellow_launch_button"] = {
  type="button_style",
  parent="yellow_confirm_button",
  top_margin=10,
  horizontally_stretchable="on",
  horizontal_align="left"
}

data.raw["gui-style"]["default"]["se_space_capsule_red_launch_button"] = {
  type="button_style",
  parent="red_confirm_button",
  top_margin=10,
  horizontally_stretchable="on",
  horizontal_align="left"
}



-- Progressbars
data.raw["gui-style"]["default"]["se_launchpad_progressbar_generic"] = {
  type="progressbar_style",
  bar_width=28,
  horizontally_stretchable="on",
  font="default-bold",
  vertical_align="center",
  embed_text_in_bar=true,
  font_color={r=230/255, g=227/255, b=230/255},
  filled_font_color={r=0/255, g=0/255, b=0/255},
  bar_background=table.deepcopy(data.raw["gui-style"]["default"]["progressbar"].bar_background)
}
data.raw["gui-style"]["default"]["se_launchpad_progressbar_generic"].bar_background.base.opacity=0.3

data.raw["gui-style"]["default"]["se_launchpad_progressbar_capsule"] = {
  type="progressbar_style",
  parent="se_launchpad_progressbar_generic",
  color={r=41/255, g=181/255, b=8/255}
}
data.raw["gui-style"]["default"]["se_launchpad_progressbar_sections"] = {
  type="progressbar_style",
  parent="se_launchpad_progressbar_generic",
  color={r=227/255, g=205/255, b=1/255}
}
data.raw["gui-style"]["default"]["se_launchpad_progressbar_fuel"] = {
  type="progressbar_style",
  parent="se_launchpad_progressbar_generic",
  color={r=242/255, g=106/255, b=15/255}
}
data.raw["gui-style"]["default"]["se_launchpad_progressbar_cargo"] = {
  type="progressbar_style",
  parent="se_launchpad_progressbar_generic",
  color={r=18/255, g=154/255, b=234/255}
}

-- Old progressbars
data.raw["gui-style"]["default"]["space_platform_progressbar_generic"] = {
  type="progressbar_style",
  bar_width=28,
  horizontally_stretchable="on",
  font="default-bold",
  vertical_align="center",
  embed_text_in_bar=true,
  font_color={r=230/255, g=227/255, b=230/255},
  filled_font_color={r=0/255, g=0/255, b=0/255},
  bar_background=table.deepcopy(data.raw["gui-style"]["default"]["progressbar"].bar_background)
}

data.raw["gui-style"]["default"]["space_platform_progressbar_capsule"] = {
  type="progressbar_style",
  parent="space_platform_progressbar_generic",
  color={r=41/255, g=181/255, b=8/255}
}
data.raw["gui-style"]["default"]["space_platform_progressbar_sections"] = {
  type="progressbar_style",
  parent="space_platform_progressbar_generic",
  color={r=227/255, g=205/255, b=1/255}
}
data.raw["gui-style"]["default"]["space_platform_progressbar_fuel"] = {
  type="progressbar_style",
  parent="space_platform_progressbar_generic",
  color={r=242/255, g=106/255, b=15/255}
}
data.raw["gui-style"]["default"]["space_platform_progressbar_cargo"] = {
  type="progressbar_style",
  parent="space_platform_progressbar_generic",
  color={r=18/255, g=154/255, b=234/255}
}
data.raw["gui-style"]["default"]["space_platform_progressbar_integrity"] = {
  type="progressbar_style",
  parent="space_platform_progressbar_generic",
  color={r=233/255, g=0/255, b=0/255}
}
data.raw["gui-style"]["default"]["spaceship_progressbar_energy"] = {
  type="progressbar_style",
  parent="space_platform_progressbar_generic",
  color={r=233/255, g=120/255, b=0/255}
}
data.raw["gui-style"]["default"]["spaceship_progressbar_streamline"] = {
  type="progressbar_style",
  parent="space_platform_progressbar_generic",
  color={r=0/255, g=120/255, b=253/255}
}

data.raw["gui-style"]["default"]["space_platform_progressbar_red"] = {
    type = "progressbar_style",
    parent = "progressbar",
    color = {
      r = 233/255,
      g = 0/255,
      b = 0/255
    }
}
data.raw["gui-style"]["default"]["space_platform_progressbar_orange"] = {
    type = "progressbar_style",
    parent = "progressbar",
    color = {
      r = 255/255,
      g = 93/255,
      b = 0/255
    }
}
data.raw["gui-style"]["default"]["space_platform_progressbar_gold"] = {
    type = "progressbar_style",
    parent = "progressbar",
    color = {
      r = 233/255,
      g = 120/255,
      b = 0/255
    }
}
data.raw["gui-style"]["default"]["space_platform_progressbar_yellow"] = {
    type = "progressbar_style",
    parent = "progressbar",
    color = {
      r = 255/255,
      g = 255/255,
      b = 0/255
    }
}
data.raw["gui-style"]["default"]["space_platform_progressbar_green"] = {
    type = "progressbar_style",
    parent = "progressbar",
    color = {
      r = 0/255,
      g = 255/255,
      b = 0/255
    }
}
data.raw["gui-style"]["default"]["space_platform_progressbar_cyan"] = {
    type = "progressbar_style",
    parent = "progressbar",
    bar_width = 24,
    color = {
      r = 0/255,
      g = 120/255,
      b = 253/255
    }
}
data.raw["gui-style"]["default"]["space_platform_progressbar_blue"] = {
    type = "progressbar_style",
    parent = "progressbar",
    color = {
      r = 52/255,
      g = 107/255,
      b = 219/255
    }
}

data.raw["gui-style"]["default"]["spaceship_progressbar_integrity"] = {
  type="progressbar_style",
  parent="space_platform_progressbar_generic",
  color={r=233/255, g=0/255, b=0/255}
}

data.raw["gui-style"]["default"]["se_relative_vertical_spacer"] = {
  type="empty_widget_style",
  height=4,
}

data.raw["gui-style"]["default"]["se_relative_properties_spacer"] = {
  type="empty_widget_style",
  horizontally_stretchable="on"
}

data.raw["gui-style"]["default"]["se_relative_properties_label"] = {
  type="label_style",
  font_color={0.7, 0.7, 0.7}
}

data.raw["gui-style"]["default"]["se_label_over_bar"] = {
    parent= "label",
    type = "label_style",
    font = "default-bold",
    top_margin = -26,
    bottom_margin = 5,
    left_margin = 5,
    right_margin = 0,
    font_color = {0,0,0,1},
}
yellow_button_glow_color = {150, 150, 90, 128}
yellow_arrow_tileset = {arrows_tileset = {192, 232}, composition_tileset = {34, 17}}
data.raw["gui-style"]["default"]["yellow_confirm_button"] = {
  type = "button_style",
  parent = "dialog_button",
  horizontal_align = "right",
  left_click_sound = {{ filename = "__core__/sound/gui-red-confirm.ogg", volume = 0.7 }},
  default_graphical_set = arrow_forward(yellow_arrow_tileset, arrow_idle_index, "shadow", default_dirt_color),
  hovered_graphical_set = arrow_forward(yellow_arrow_tileset, arrow_disabled_index, "glow", yellow_button_glow_color), -- using disabled_index instead of the sensible index is required, because the sprites for the other indices don't exist for yellow
  clicked_graphical_set = arrow_forward(yellow_arrow_tileset, arrow_disabled_index),
  disabled_font_color = {0.5, 0.5, 0.5},
  disabled_graphical_set = arrow_forward(yellow_arrow_tileset, arrow_disabled_index, "glow", default_dirt_color)
}
data.raw["gui-style"]["default"]["view_zone_button"] = {
    type = "button_style",
    vertical_align = "center",
    scale = 1,
    scalable = false,
    width = 300,
    height = 32,
    horizontally_stretchable = "off",
    vertically_stretchable = "off",
    horizontally_squashable = "off",
    vertically_squashable = "off",
    top_padding = 0,
    bottom_padding = 0,
    left_padding = 0,
    right_padding = 0,
    top_margin = 0,
    bottom_margin = 0,
    left_margin = 0,
    right_margin = 0,
}
data.raw["gui-style"]["default"]["view_zone_button_flow"] = {
    type = "horizontal_flow_style",
    vertical_align = "center",
    scale = 1,
    scalable = false,
    width = 300,
    height = 32,
    horizontally_stretchable = "off",
    vertically_stretchable = "off",
    horizontally_squashable = "off",
    vertically_squashable = "off",
    top_padding = 0,
    bottom_padding = 0,
    left_padding = 0,
    right_padding = 0,
    top_margin = 0,
    bottom_margin = 0,
    left_margin = 0,
    right_margin = 0,
}
data.raw["gui-style"]["default"]["view_zone_button_label"] = {
    type = "label_style",
    scale = 1,
    scalable = false,
    width = 200,
    height = 32,
    horizontally_stretchable = "off",
    vertically_stretchable = "off",
    horizontally_squashable = "off",
    vertically_squashable = "off",
    top_padding = 0,
    bottom_padding = 0,
    left_padding = 0,
    right_padding = 0,
    top_margin = 0,
    bottom_margin = 0,
    left_margin = 0,
    right_margin = 0,
}
data.raw["gui-style"]["default"]["view_zone_button_sprite"] = {
  type = "button_style",
  parent = "map_generator_preview_button",
  icon_horizontal_align = "left",
  width = 300
}

-- Relative GUIs
data.raw["gui-style"]["default"]["se_relative_titlebar_flow"] = {
  type="horizontal_flow_style",
  horizontal_spacing=8
}
data.raw["gui-style"]["default"]["se_relative_titlebar_draggable_spacer"] = {
  type="empty_widget_style",
  parent="draggable_space_header",
  height=24,
  horizontally_stretchable="on"
}
data.raw["gui-style"]["default"]["se_relative_titlebar_nondraggable_spacer"] = {
  type="empty_widget_style",
  height=24,
  horizontally_stretchable="on"
}

--icon_horizontal_align = "left",

-- ZONELIST UI
data.raw["gui-style"]["default"]["zonelist_priority_textfield"] = {
  type = "textbox_style",
  default_background = {
    base = {
      center = {
        position = {43,8},
        size = 1
      },
      corner_size = 8,
      draw_type = "inner",
      position = {34, 0}
    },
    shadow = nil
  },
  active_background = {
    base = {
      center = {
        position = {60,26},
        size = 1
      },
      corner_size = 8,
      draw_type = "inner",
      position = {51, 17}
    },
  }
}
data.raw["gui-style"]["default"]["zonelist_priority_button"] = {
  default_graphical_set = {
    base = {
      corner_size = 8,
      position = {
        247,
        17
      }
    },
    --[[shadow = {
      corner_size = 8,
      draw_type = "outer",
      position = {
        395,
        86
      }
    }]]--
  },
  default_font_color = {220/255,220/255,220/255},
  hovered_font_color = {220/255,220/255,220/255},
  clicked_font_color = {220/255,220/255,220/255},
  type = "button_style"
}

data.raw["gui-style"]["default"]["zonelist_content_pane"] = {
  type = "scroll_pane_style",
  extra_padding_when_activated = 0,
  extra_margin_when_activated = 0,
  width = 300,
  minimal_height = 300,
  maximal_height = 600,
  graphical_set = {
    base = {},
    shadow = nil
  },
  vertical_scrollbar_style = {
    background_graphical_set = {
      blend_mode = "multiplicative-with-alpha",
      corner_size = 8,
      opacity = 0.7,
      position = {
        0,
        72
      }
    },
    type = "vertical_scrollbar_style"
  },
  vertically_stretchable = "on",
  horizontally_squashable = "on",
  padding = 12,
}

data.raw["gui-style"]["default"]["zonelist_progressbar"] = {
  type = "progressbar_style",
  parent = "progressbar",
  bar_width = 24,
  color = {
    r = 220/255,
    g = 200/255,
    b = 0/255
  }
}

data.raw["gui-style"]["default"]["zonelist_rows_pane"] = {
  type = "scroll_pane_style",
  graphical_set = {
    base = {},
    shadow = nil
  },
  vertical_scrollbar_style = {
    background_graphical_set = {
      blend_mode = "multiplicative-with-alpha",
      corner_size = 8,
      opacity = 0.7,
      position = {
        0,
        72
      }
    },
    type = "vertical_scrollbar_style"
  },
  vertically_stretchable = "on",
  horizontally_squashable = "on",
  padding = 0,
  extra_padding_when_activated = 0,
}


data.raw["gui-style"]["default"]["zonelist_row_button"] = {
  type = "button_style",
  horizontally_stretchable = "on",
  horizontally_squashable = "on",
  bottom_margin = -3,
  default_font_color = {250/255,250/255,250/255},
  hovered_font_color = { 0.0, 0.0, 0.0 },
  selected_clicked_font_color = { 0.97, 0.54, 0.15 },
  selected_font_color = { 0.97, 0.54, 0.15 },
  selected_hovered_font_color = { 0.97, 0.54, 0.15  },
  clicked_graphical_set = {
    corner_size = 8,
    position = { 51, 17 }
  },
  default_graphical_set = {
    corner_size = 8,
    position = { 208, 17 }
  },
  disabled_graphical_set = {
    corner_size = 8,
    position = { 17, 17 }
  },
  hovered_graphical_set = {
    base = {
      corner_size = 8,
      position = { 34, 17 }
    }
  }
}

data.raw["gui-style"]["default"]["zonelist_row_button_selected"] = {
  type = "button_style",
  parent = "zonelist_row_button",
  top_padding = 3,
  left_padding = 11,
  default_font_color = { 0.0, 0.0, 0.0 },
  hovered_font_color = { 0.0, 0.0, 0.0 },
  selected_clicked_font_color = { 0.0, 0.0, 0.0 },
  selected_font_color = { 0.0, 0.0, 0.0 },
  selected_hovered_font_color = { 0.0, 0.0, 0.0 },
  clicked_graphical_set = {
    border = 1,
    filename = "__core__/graphics/gui.png",
    position = { 75, 108 },
    scale = 1,
    size = 36
  },
  default_graphical_set = {
    border = 1,
    filename = "__core__/graphics/gui.png",
    position = {75,108},
    scale = 1,
    size = 36
  },
  hovered_graphical_set = {
    border = 1,
    filename = "__core__/graphics/gui.png",
    position = {75,108},
    scale = 1,
    size = 36
  },
}

data.raw["gui-style"]["default"]["se_frame_deep_slots_small"] = {
  type = "frame_style",
  parent = "slot_button_deep_frame",
  background_graphical_set = {
      position = {282, 17},
      corner_size = 8,
      overall_tiling_vertical_size = 32,
      overall_tiling_vertical_spacing = 8,
      overall_tiling_vertical_padding = 4,
      overall_tiling_horizontal_size = 32,
      overall_tiling_horizontal_spacing = 8,
      overall_tiling_horizontal_padding = 4
  }
}

data.raw["gui-style"]["default"]["se_sprite-button_inset"] = {
  type = "button_style",
  size = 40,
  padding = 0,
  default_graphical_set = data.raw["gui-style"]["default"].textbox.default_background,
  hovered_graphical_set = data.raw["gui-style"]["default"].rounded_button.clicked_graphical_set,
  clicked_graphical_set = data.raw["gui-style"]["default"].textbox.active_background,
  disabled_graphical_set = data.raw["gui-style"]["default"].rounded_button.disabled_graphical_set
}

data.raw["gui-style"]["default"]["se_sprite-button_inset_tiny"] = {
  type = "button_style",
  parent = "se_sprite-button_inset",
  size = 32
}

local graphic_set_down = {
  default_graphical_set = {
    base = {
      center = {
        position = {43,8},
        size = 1
      },
      corner_size = 8,
      draw_type = "inner",
      position = {34, 0}
    },
    shadow = {
      corner_size = 8,
      draw_type = "outer",
      position = {
        440,
        24
      }
    }
  },
}
local graphic_set_active_a = {
  default_font_color = { 0.0, 0.0, 0.0 },
  hovered_font_color = { 0.0, 0.0, 0.0 },
  selected_clicked_font_color = { 0.0, 0.0, 0.0 },
  selected_font_color = { 0.0, 0.0, 0.0 },
  selected_hovered_font_color = { 0.0, 0.0, 0.0 },
  default_graphical_set = {
    base = {
      corner_size = 8,
      position = {
        369,
        17
      }
    },
    shadow = {
      corner_size = 8,
      draw_type = "outer",
      position = {
        440,
        24
      }
    }
  },
}
data.raw["gui-style"]["default"]["se_button_discovery"] = {
  type = "button_style",
  parent = "se_generic_button",
  width = 165,
  height = 90,
  top_padding = 20,
  horizontal_align = "center",
  vertical_align = "center"
}
data.raw["gui-style"]["default"]["se_button_discovery_down"] = {
  type = "button_style",
  parent = "se_generic_button_down",
  width = 165,
  height = 90,
  top_padding = 20,
  horizontal_align = "center",
  vertical_align = "center"
}
data.raw["gui-style"]["default"]["se_button_discovery_active"] = {
  type = "button_style",
  parent = "se_generic_button_active",
  width = 165,
  height = 90,
  top_padding = 20,
  horizontal_align = "center",
  vertical_align = "center"
}

data.raw["gui-style"]["default"]["se_button_discovery_any"] = {
  type = "button_style",
  parent = "se_generic_button",
  width = 340,
  height = 70,
  padding = 10,
  horizontal_align = "center",
  vertical_align = "center",
  horizontally_stretchable = "on",
  font="heading-2",
}
data.raw["gui-style"]["default"]["se_button_discovery_any_down"] = {
  type = "button_style",
  parent = "se_generic_button_down",
  width = 340,
  height = 70,
  padding = 10,
  horizontal_align = "center",
  vertical_align = "center",
  horizontally_stretchable = "on",
  font="heading-2",
}
data.raw["gui-style"]["default"]["se_button_discovery_any_active"] = {
  type = "button_style",
  parent = "se_generic_button_active",
  width = 340,
  height = 70,
  padding = 10,
  horizontal_align = "center",
  vertical_align = "center",
  horizontally_stretchable = "on",
  font="heading-2",
}

local graphic_set_active_b = {
  default_graphical_set = {
    base = {
      center = {
        position = {43+17,8+17},
        size = 1
      },
      corner_size = 8,
      draw_type = "inner",
      position = {34+17, 0+17}
    },
    shadow = {
      corner_size = 8,
      draw_type = "outer",
      position = {
        440,
        24
      }
    }
  }
}

data_util.extend_style("frame_button", "se_generic_button", {
  padding = -4,
  default_font_color = { 1,1,1 },
})
data_util.extend_style("se_generic_button", "se_generic_button_down", graphic_set_down)
data_util.extend_style("se_generic_button", "se_generic_button_active", graphic_set_active_a)

local discovery_overrides = {
  width = 165,
  height = 90,
  top_padding = 20,
  horizontal_align = "center",
  vertical_align = "center"
}
data_util.extend_style("se_generic_button", "se_button_discovery", discovery_overrides)
data_util.extend_style("se_generic_button_down", "se_button_discovery_down", discovery_overrides)
data_util.extend_style("se_generic_button_active", "se_button_discovery_active", discovery_overrides)

local discovery_any_overrides = data_util.apply_styles(table.deepcopy(discovery_overrides), {
  width = 340,
  height = 70,
  padding = 10,
  horizontally_stretchable = "on",
  font="heading-2",
})
data_util.extend_style("se_generic_button", "se_button_discovery_any", discovery_any_overrides)
data_util.extend_style("se_generic_button_down", "se_button_discovery_any_down", discovery_any_overrides)
data_util.extend_style("se_generic_button_active", "se_button_discovery_any_active", discovery_any_overrides)

data_util.extend_style("frame_button", "se_generic_square_button", {
  size = 28,
  top_padding = -2,
  top_margin = -4,
  default_font_color = { 1,1,1 },
})
data_util.extend_style("se_generic_square_button", "se_generic_square_button_down", graphic_set_down)
data_util.extend_style("se_generic_square_button", "se_generic_square_button_active", graphic_set_active_b)

local zone_list_overrides = {
  height = 28,
  width = 32,
  right_margin = 0,
  left_margin = -4,
  top_margin = -2
}

data_util.extend_style("se_generic_square_button", "se_zone_list_filter", zone_list_overrides)
data_util.extend_style("se_generic_square_button_down", "se_zone_list_filter_down", zone_list_overrides)

local zonelist_priority_toggle_overrides = {
  height = 28,
  width = 32,
  top_margin = -2
}

data_util.extend_style("se_generic_square_button", "se_priority_toggle_button", zonelist_priority_toggle_overrides)
data_util.extend_style("se_generic_square_button_down", "se_priority_toggle_button_down", zonelist_priority_toggle_overrides)

data.raw["gui-style"]["default"]["se_zonelist_cell_heading_base"] = {
  type = "button_style",
  parent = "dark_button",
  horizontal_align = "center",
  margin = 0,
  width = 68
}

data.raw["gui-style"]["default"]["se_zonelist_cell_heading_name"] = {
  type = "button_style",
  parent = "se_zonelist_cell_heading_base",
  horizontal_align = "left",
  default_font_color = {1, 1, 1},
  width = 210
}

data.raw["gui-style"]["default"]["se_zonelist_cell_heading_flags"] = {
  type = "button_style",
  parent = "se_zonelist_cell_heading_base",
  width = 100
}

data.raw["gui-style"]["default"]["se_zonelist_cell_base"] = {
  type = "label_style",
  margin = 0,
  width = 68
}

data.raw["gui-style"]["default"]["se_zonelist_cell_heirarchy"] = {
  type = "label_style",
  parent = "se_zonelist_cell_base",
  horizontal_align = "left"
}

data.raw["gui-style"]["default"]["se_zonelist_cell_type"] = {
  type = "label_style",
  parent = "se_zonelist_cell_base",
  horizontal_align = "center",
  left_margin = -12
}

data.raw["gui-style"]["default"]["se_zonelist_cell_name"] = {
  type = "label_style",
  parent = "se_zonelist_cell_base",
  horizontal_align = "left",
  left_padding = 16,
  width = 210
}

data.raw["gui-style"]["default"]["se_zonelist_cell_numeric_value"] = {
  type = "label_style",
  parent = "se_zonelist_cell_base",
  horizontal_align = "right",
  right_padding = 16
}

data.raw["gui-style"]["default"]["se_zonelist_cell_resource"] = {
  type = "label_style",
  parent = "se_zonelist_cell_base",
  horizontal_align = "center"
}

data.raw["gui-style"]["default"]["se_zonelist_cell_flags"] = {
  type = "label_style",
  parent = "se_zonelist_cell_base",
  horizontal_align = "center",
  width = 100
}

data.raw["gui-style"]["default"]["se_zonelist_cell_priority"] = {
  type = "label_style",
  parent = "se_zonelist_cell_base",
  horizontal_align = "right",
  right_padding = 30
}

--Remote View GUI

data.raw["gui-style"]["default"]["se_remote_view_root_frame"] = {
  type = "frame_style",
  parent = "quick_bar_window_frame",
  horizontal_flow_style = {
    type = "horizontal_flow_style",
    horizontal_spacing = 0
  },
  padding = 0,
  height = 96
}

data.raw["gui-style"]["default"]["se_remote_view_left_frame"] = {
  type = "frame_style",
  parent = "inside_shallow_frame",
  width = 208,
  margin = 4,
  vertical_flow_style = {
    type = "vertical_flow_style",
    vertical_spacing = 0,
    padding = 0
  }
}

data.raw["gui-style"]["default"]["se_remote_view_name_frame"] = {
  type = "frame_style",
  parent = "quick_bar_inner_panel",
  vertically_stretchable = "stretch_and_expand",
  horizontally_stretchable = "stretch_and_expand",
  vertical_flow_style = {
    type = "vertical_flow_style",
    vertical_spacing = 0
  },
}

data.raw["gui-style"]["default"]["se_remote_view_content_flow"] = {
  type = "horizontal_flow_style",
  height = 40,
  horizontal_spacing = 6,
  vertical_align = "center",
  left_margin = 6,
  right_margin = 6
}

data.raw["gui-style"]["default"]["se_remote_view_name_button"] = {
  type = "button_style",
  size = 22,
  padding = 0,
  default_graphical_set = {}
}

data.raw["gui-style"]["default"]["se_remote_view_name_label"] = {
  type = "label_style",
  horizontally_squashable = "on",
  single_line = true,
  font = "heading-2"
}

data.raw["gui-style"]["default"]["se_remote_view_hierarchy_button"] = {
  type = "button_style",
  parent = "slot_button_in_shallow_frame",
  padding = 2,
  width = 30,
  height = 30
}

data.raw["gui-style"]["default"]["se_remote_view_hierarchy_button_active"] = {
  type = "button_style",
  parent = "se_remote_view_hierarchy_button",
  default_graphical_set = data.raw["gui-style"]["default"]["slot_button_in_shallow_frame"].clicked_graphical_set
}

data.raw["gui-style"]["default"]["se_remote_view_side_button_frame"] = {
  type = "frame_style",
  parent = "quick_bar_inner_panel",
  margin = 4,
  width = 40,
  vertical_flow_style = {
    type = "vertical_flow_style",
    vertical_spacing = 0
  },
}

data.raw["gui-style"]["default"]["se_remote_view_side_flow"] = {
  type = "horizontal_flow_style",
  horizontal_spacing = 0
}

data.raw["gui-style"]["default"]["se_remote_view_side_button"] = {
  type = "button_style",
  parent = "side_menu_button",
  default_font_color = {230, 227, 230},
  padding = 8
}

data.raw["gui-style"]["default"]["se_remote_view_breadcrumb_sprite"] = {
  type = "image_style",
  size = 8,
  left_margin = -5,
  right_margin = -5,
  stretch_image_to_widget_size = true
}

data.raw["gui-style"]["default"]["se_remote_view_pins_frame"] = {
  type = "frame_style",
  parent = "shortcut_bar_inner_panel",
  margin = 4,
  vertically_stretchable = "stretch_and_expand",
  vertical_flow_style = {
    type = "vertical_flow_style",
    vertical_spacing = 0
  }
}

data.raw["gui-style"]["default"]["se_remote_view_pins_table"] = {
  type = "table_style",
  parent = "filter_slot_table"
}

data.raw["gui-style"]["default"]["se_remote_view_pins_scroll_pane"] = {
  type = "scroll_pane_style",
  extra_padding_when_activated = 0
}

--Lifesupport GUIs

data.raw["gui-style"]["default"]["se_lifesupport_frame"] = {
  type = "frame_style",
  parent = "quick_bar_slot_window_frame",
  horizontal_flow_style = {
    type = "horizontal_flow_style",
    horizontal_spacing = 0
  },
  padding = 0,
  width = 150,
  height = 96
}

data.raw["gui-style"]["default"]["se_lifesupport_left_minimize_button"] = {
  type = "button_style",
  parent = "shortcut_bar_expand_button",
  top_margin = 4
}

data.raw["gui-style"]["default"]["se_lifesupport_draggable_space"] = {
  type = "empty_widget_style",
  parent = "draggable_space",
  width = 8,
  top_margin = 0,
  bottom_margin = 4,
  left_margin = 0,
  right_margin = 0,
  vertically_stretchable = "stretch_and_expand"
}

data.raw["gui-style"]["default"]["se_lifesupport_panel"] = {
  type = "frame_style",
  margin = 4,
  parent = "quick_bar_inner_panel",
  maximal_width = 126,
  vertically_stretchable = "stretch_and_expand",
  vertical_flow_style = {
    type = "vertical_flow_style",
    horizontal_align = "center",
    vertical_spacing = 4
  },
}

data.raw["gui-style"]["default"]["se_lifesupport_progressbar"] = {
  type = "progressbar_style",
  parent = "space_platform_progressbar_generic",
  bar_width = 28,
  color = {70/255, 171/255, 255/255},
  horizontal_align = "center",
  horizontally_stretchable = "stretch_and_expand",
}

data.raw["gui-style"]["default"]["se_lifesupport_text_flow"] = {
  type = "horizontal_flow_style",
  vertical_align = "center",
  right_margin = 4,
  left_margin = 4
}

data.raw["gui-style"]["default"]["se_lifesupport_sprite"] = {
  type = "image_style",
  width = 18,
  height = 18,
  stretch_image_to_widget_size = true
}

data.raw["gui-style"]["default"]["se_lifesupport_label_reserves"] = {
  type = "label_style",
  maximal_width = 78,
  single_line = true
}

data.raw["gui-style"]["default"]["se_lifesupport_sprite_info"] = {
  type = "image_style",
  parent = "se_lifesupport_sprite",
  width = 10,
  height = 10
}

-- Lifesupport Expanded GUI

data.raw["gui-style"]["default"]["se_lifesupport_expanded_frame"] = {
  type = "frame_style",
  parent = "quick_bar_slot_window_frame",
  vertical_flow_style = {
    type = "vertical_flow_style"
  },
  padding = 4,
  width = 320
}

data.raw["gui-style"]["default"]["se_lifesupport_expanded_title_icon"] = {
  type = "image_style",
  width = 20,
  height = 20,
  stretch_image_to_widget_size = true
}

data.raw["gui-style"]["default"]["se_lifesupport_expanded_subheader_frame"] = {
  type = "frame_style",
  parent = "frame",
  vertical_flow_style = { type = "vertical_flow_style", vertical_spacing = 2 },
  horizontally_stretchable = "stretch_and_expand",
  graphical_set = data.raw["gui-style"]["default"]["subheader_frame"].graphical_set
}

-- Zonelist 2
style.se_zonelist_root_frame = {
  type = "frame_style",
  height = 800,
  vertical_flow_style = {
    type = "vertical_flow_style",
    vertically_stretchable = "stretch_and_expand",
    horizontally_stretchable = "stretch_and_expand"
  }
}

style.se_zonelist_main_flow = {
  type = "horizontal_flow_style",
  horizontal_spacing = 12
}

style.se_zonelist_left_flow = {
  type = "vertical_flow_style",
  vertical_spacing = 8
}

style.se_zonelist_toolbar_flow = {
  type = "horizontal_flow_style",
  vertical_align = "center",
  horizontally_stretchable = "stretch_and_expand"
}

style.se_zonelist_toolbar_separator = {
  type = "empty_widget_style",
  width = 32,
}

style.se_zonelist_zone_type_filters_flow = {
  type = "horizontal_flow_style",
  horizontal_spacing = 0
}

style.se_zonelist_filter_button = {
  type = "button_style",
  parent = "frame_button",
  size = 32,
  padding = 2
}

style.se_zonelist_filter_button_down = {
  type = "button_style",
  parent = "se_zonelist_filter_button",
  default_graphical_set = graphic_set_down.default_graphical_set
}

style.se_zonelist_priority_threshold_flow = {
  type = "horizontal_flow_style",
  horizontal_spacing = 0,
}

style.se_zonelist_priority_textfield = {
  type = "textbox_style",
  width = 40,
  height = 34,
  top_margin = -2,
  horizontal_align = "center",
  padding = 0
}

style.se_zonelist_priority_small_button_flow = {
  type = "vertical_flow_style",
  vertical_spacing = 0
}

style.se_zonelist_priority_threshold_small_button = {
  type = "button_style",
  parent = "se_zonelist_filter_button",
  width = 20,
  height = 16,
  padding = 0,
  font = "default-tiny-bold",
  default_font_color = {230, 227, 230},
  horizontal_align = "center"
}

style.se_zonelist_search_flow = {
  type = "horizontal_flow_style",
  horizontal_spacing = 0
}

style.se_zonelist_search_textfield = {
  type = "textbox_style",
  parent = "se_zonelist_priority_textfield",
  horizontal_align = "left",
  width = 120,
  height = 32,
  top_margin = 0,
  left_padding = 2,
  right_padding = 2
}

style.se_zonelist_search_button = {
  type = "button_style",
  parent = "se_zonelist_filter_button"
}

style.se_zonelist_search_button_down = {
  type = "button_style",
  parent = "se_zonelist_filter_button",
  default_graphical_set = style["frame_button"].clicked_graphical_set
}

style.se_zonelist_left_frame = {
  type = "frame_style",
  parent = "inside_deep_frame",
  vertically_stretchable = "stretch_and_expand",
  horizontally_stretchable = "stretch_and_expand"
}

style.se_zonelist_header_frame = {
  type = "frame_style",
  parent = "subheader_frame",
  height = 32,
  horizontally_stretchable = "stretch_and_expand",
  horizontal_flow_style = {
    type = "horizontal_flow_style",
    left_padding = 8,
    right_padding = 12
  }
}

style.se_zonelist_sort_checkbox_inactive = {
  type = "checkbox_style",
  font = "default-bold",
  padding = 0,
  text_padding = 5,
  default_graphical_set = blank_image,
  hovered_graphical_set = blank_image,
  clicked_graphical_set = blank_image,
  disabled_graphical_set = blank_image,
  selected_graphical_set = blank_image,
  selected_hovered_graphical_set = blank_image,
  selected_clicked_graphical_set = blank_image,
  selected_disabled_graphical_set = blank_image,
  checkmark = blank_image,
  disabled_checkmark = blank_image
}
style.se_zonelist_sort_checkbox = {
  type = "checkbox_style",
  parent = "se_zonelist_sort_checkbox_inactive",
  default_graphical_set = {
    filename = "__core__/graphics/arrows/table-header-sort-arrow-down-white.png",
    size = { 16, 16 },
    scale = 0.5,
  },
  hovered_graphical_set = {
    filename = "__core__/graphics/arrows/table-header-sort-arrow-down-hover.png",
    size = { 16, 16 },
    scale = 0.5,
  },
  clicked_graphical_set = {
    filename = "__core__/graphics/arrows/table-header-sort-arrow-down-white.png",
    size = { 16, 16 },
    scale = 0.5,
  },
  disabled_graphical_set = {
    filename = "__core__/graphics/arrows/table-header-sort-arrow-down-white.png",
    size = { 16, 16 },
    scale = 0.5,
  },
  selected_graphical_set = {
    filename = "__core__/graphics/arrows/table-header-sort-arrow-up-white.png",
    size = { 16, 16 },
    scale = 0.5,
  },
  selected_hovered_graphical_set = {
    filename = "__core__/graphics/arrows/table-header-sort-arrow-up-hover.png",
    size = { 16, 16 },
    scale = 0.5,
  },
  selected_clicked_graphical_set = {
    filename = "__core__/graphics/arrows/table-header-sort-arrow-up-white.png",
    size = { 16, 16 },
    scale = 0.5,
  },
  selected_disabled_graphical_set = {
    filename = "__core__/graphics/arrows/table-header-sort-arrow-up-white.png",
    size = { 16, 16 },
    scale = 0.5,
  }
}

style.se_zonelist_scroll_pane = {
  type = "scroll_pane_style",
  parent = "list_box_scroll_pane",
  horizontally_stretchable = "stretch_and_expand",
  vertically_stretchable = "stretch_and_expand",
  dont_force_clipping_rect_for_contents = true,
  padding = 0,
  graphical_set = {
    shadow = default_inner_shadow,
  },
  vertical_flow_style = {
    type = "vertical_flow_style",
    vertical_spacing = 4,
  },
}

style.se_zonelist_row_button = {
  type = "button_style",
  horizontally_stretchable = "on",
  bottom_margin = -3,
  default_font_color = {250/255,250/255,250/255},
  hovered_font_color = { 0.0, 0.0, 0.0 },
  selected_clicked_font_color = { 0.97, 0.54, 0.15 },
  selected_font_color = { 0.97, 0.54, 0.15 },
  selected_hovered_font_color = { 0.97, 0.54, 0.15  },
  clicked_graphical_set = {
    corner_size = 8,
    position = { 352, 17 }
    -- position = { 51, 17 }
  },
  default_graphical_set = {
    corner_size = 8,
    position = { 208, 17 }
  },
  hovered_graphical_set = {
    base = {
      corner_size = 8,
      position = { 34, 17 }
    }
  }
}

style.se_zonelist_row_button_selected = {
  type = "button_style",
  parent = "se_zonelist_row_button",
  default_graphical_set = {
    corner_size = 8,
    position = { 54, 17 }
  },
  hovered_graphical_set = {
    corner_size = 8,
    position = { 54, 17 }
  }
}

style.se_zonelist_header_cell_flow = {
  type = "horizontal_flow_style",
  width = 68,
  horizontal_align = "center"
}

style.se_zonelist_row_cell_base = {
  type = "label_style",
  margin = 0,
  width = 68,
  horizontal_align = "left"
}

style.se_zonelist_row_cell_heirarchy = {
  type = "label_style",
  parent = "se_zonelist_row_cell_base",
}

style.se_zonelist_row_cell_type = {
  type = "label_style",
  parent = "se_zonelist_row_cell_base",
  horizontal_align = "center",
  width = 54
}

style.se_zonelist_row_cell_name = {
  type = "label_style",
  parent = "se_zonelist_row_cell_base",
  width = 210,
  left_padding = 16
}

style.se_zonelist_row_cell_numeric = {
  type = "label_style",
  parent = "se_zonelist_row_cell_base",
  horizontal_align = "right",
  right_padding = 16
}

style.se_zonelist_row_cell_resource = {
  type = "label_style",
  parent = "se_zonelist_row_cell_base",
  horizontal_align = "center"
}

style.se_zonelist_row_cell_flags = {
  type = "label_style",
  parent = "se_zonelist_row_cell_base",
  width = 100,
  horizontal_align = "center"
}

style.se_zonelist_instruction_frame = {
  type = "frame_style",
  parent = "dark_frame",
  horizontally_stretchable = "on",
  horizontal_flow_style = {
    type = "horizontal_flow_style",
  }
}

style.se_zonelist_instruction_label = {
  type = "label_style",
  single_line = false
}


style.se_zonelist_right_flow = {
  type = "vertical_flow_style",
  vertically_stretchable = "stretch_and_expand",
  vertical_spacing = 8
}
style.se_zonelist_zone_data_main_frame = {
  type = "frame_style",
  parent = "inside_shallow_frame",
  vertically_stretchable = "stretch_and_expand",
  vertical_flow_style = {
    type = "vertical_flow_style",
    vertical_spacing = 0,
  },
  width = 300,
}
style.se_zonelist_zone_data_subheader_frame = {
  type = "frame_style",
  parent = "subheader_frame",
  height = 40,
  horizontally_stretchable = "stretch_and_expand",
  horizontal_flow_style = {
    type = "horizontal_flow_style",
    vertical_align = "center",
    top_padding = 2,
    left_padding = 6,
    bottom_padding = 2
  }
}
style.se_zonelist_zone_data_header_label = {
  type = "label_style",
  font = "default-bold",
  maximal_width = 190
}
style.se_zonelist_zone_data_priority_sprite = {
  type = "image_style",
  size = 24,
  stretch_image_to_widget_size = true
}

style.se_zonelist_zone_data_content_scroll_pane = {
  type = "scroll_pane_style",
  parent = "scroll_pane_under_subheader",
  vertically_stretchable = "on",
  horizontally_stretchable = "on",
  vertical_flow_style = {
    type = "vertical_flow_style",
    vertical_spacing = 16,
    padding = 12
  }
}

style.se_zonelist_zone_data_content_sub_flow = {
  type = "vertical_flow_style",
  top_margin = -8,
  horizontally_stretchable = "on"
}

style.se_zonelist_zone_data_label = {
  type = "label_style",
  font_color = {0.8, 0.8, 0.8},
  maximal_width = 180,
}

style.se_zonelist_zone_data_value = {
  type = "label_style",
  maximal_width = 180
}
style.se_zonelist_zone_data_value_link = {
  type = "label_style",
  parent = "se_zonelist_zone_data_value",
  font = "default-semibold"
}
style.se_zonelist_zone_data_value_multiline = {
  type = "label_style",
  single_line = false
}

style.se_zonelist_flag_icon = {
  type = "image_style",
  size = 20,
  stretch_image_to_widget_size = true
}

style.se_zonelist_zone_data_header_checkbox = {
  type = "checkbox_style",
  parent = "se_zonelist_sort_checkbox_inactive",
  default_graphical_set = {
    filename = "__core__/graphics/icons/mip/collapse.png",
    position = {6, 6},
    size = { 20, 20 },
  },
  hovered_graphical_set = {
    filename = "__core__/graphics/icons/mip/collapse.png",
    position = {6, 6},
    size = { 20, 20 },
  },
  clicked_graphical_set = {
    filename = "__core__/graphics/icons/mip/collapse.png",
    position = {6, 6},
    size = { 20, 20 },
  },
  disabled_graphical_set = {
    filename = "__core__/graphics/icons/mip/collapse.png",
    position = {6, 6},
    size = { 20, 20 },
  },
  selected_graphical_set = {
    filename = "__core__/graphics/icons/mip/expand.png",
    position = {6, 6},
    size = { 20, 20 },
  },
  selected_hovered_graphical_set = {
    filename = "__core__/graphics/icons/mip/expand.png",
    position = {6, 6},
    size = { 20, 20 },
  },
  selected_clicked_graphical_set = {
    filename = "__core__/graphics/icons/mip/expand.png",
    position = {6, 6},
    size = { 20, 20 },
  },
  selected_disabled_graphical_set = {
    filename = "__core__/graphics/icons/mip/expand.png",
    position = {6, 6},
    size = { 20, 20 },
  },
}

style.se_zonelist_zone_data_resource_icon = {
  type = "image_style",
  size = 24,
  stretch_image_to_widget_size = true
}
style.se_zonelist_zone_data_resource_bar = {
  type = "progressbar_style",
  parent = "se_progressbar_generic",
  horizontally_stretchable = "on",
  font = "default-bold"
}

style.se_zonelist_zone_data_pins_frame = {
  type = "frame_style",
  parent = "slot_button_deep_frame",
  minimal_width = 248
}

style.se_zonelist_preview_frame = {
  type = "frame_style",
  parent = "inside_deep_frame",
  width = 300,
  horizontal_align = "center",
  vertical_align = "center",
  vertical_flow_style = {
    type = "vertical_flow_style",
    horizontal_align = "center",
    vertical_align = "center"
  }
}
style.se_zonelist_preview_minimap = {
  type = "minimap_style",
  size = 300
}
style.se_zonelist_preview_camera = {
  type = "camera_style",
  size = 300
}
style.se_zonelist_preview_label = {
  type = "label_style",
  single_line = false,
  font_color = {0.5, 0.5, 0.5},
  horizontal_align = "center",
  top_padding = 12,
  left_padding = 12,
  right_padding = 12,
  bottom_padding = 16
}

style.se_zonelist_tool_button = {
  type = "button_style",
  parent = "tool_button",
  size = 32
}
style.se_zonelist_tool_button_red = {
  type = "button_style",
  parent = "tool_button_red",
  size = 32
}
style.se_zonelist_tool_button_blue = {
  type = "button_style",
  parent = "tool_button_blue",
  size = 32
}
style.se_zonelist_view_button = {
  type = "button_style",
  parent = "confirm_button",
  maximal_width = 156,
  horizontally_stretchable = "on"
}

style.se_watermark_string_frame = {
  type = "frame_style",
  parent = "invisible_frame",
  horizontal_flow_style = {
    type = "horizontal_flow_style",
    horizontal_align = "right",
    vertical_align = "bottom",
    horizontally_stretchable = "on",
    vertically_stretchable = "on",
  },
}
style.se_watermark_string_label = {
  type = "label_style",
  font = "default-tiny-bold",
  font_color = {r=1, g=1, b=1, a=0.5},
  right_margin = 2,
  bottom_margin = -3,
}

-- SHARED

style.se_slot_button_active = {
  type = "button_style",
  parent = "slot_button",
  default_graphical_set = style.slot_button.clicked_graphical_set
}

style.se_progressbar_generic = {
  type = "progressbar_style",
  bar_width = 28,
  horizontally_stretchable = "on",
  font = "default-bold",
  vertical_align = "center",
  embed_text_in_bar = true,
  font_color = {r=230/255, g=227/255, b=230/255},
  filled_font_color = {r=0/255, g=0/255, b=0/255},
  bar_background = table.deepcopy(style["progressbar"].bar_background)
}

style.se_horizontal_flow_centered = {
  type = "horizontal_flow_style",
  vertical_align = "center"
}

style.se_frame_action_button_active = {
  type = "button_style",
  parent = "frame_action_button",
  default_graphical_set = style["frame_button"].clicked_graphical_set
}

style.se_titlebar_icon = {
  type = "image_style",
  width = 20,
  height = 20,
  stretch_image_to_widget_size = true
}

style.se_titlebar_frame_button = {
  type = "button_style",
  parent = "frame_button",
  height = 24,
  left_padding = 4,
  right_padding = 4,
  font = "default-small",
  default_font_color = {1, 1, 1}
}

style.se_textfield_maximum_stretchable = {
  type = "textbox_style",
  horizontally_stretchable = "on",
  horizontally_squashable = "on",
  maximal_width = 0,
}

style.se_icon_selector_button = {
  type = "button_style",
  parent = "button",
  width = 28,
  height = 28,
  padding = 0,
  top_margin = 1,
}

style.se_spaceship_schedule_condition_progress_bar = {
  type = "progressbar_style",
  bar_width = 36,
  color = {1, 1, 1}, -- color baked in
  font_color = {1, 1, 1},
  filled_font_color = {},
  width = 450 - 112,
  height = 36,
  top_margin = 0,
  bottom_margin = -8,
  left_margin = -4,
  right_margin = -(450 - 112) - 4,
  bar_background = {},
  embed_text_in_bar = true,
  side_text_padding = 120,
  bar = { -- train_schedule_fullfilled_condition_frame graphics
      base = {position = {412, 86}, corner_size = 8},
      shadow = { -- default_shadow
          position = {200, 128},
          corner_size = 8,
          tint = {0, 0, 0, 0.35},
          scale = 0.5,
          draw_type = "outer"
      }
  }
}

style.se_spaceship_schedule_condition_progress_bar_partial = {
  parent = "se_spaceship_schedule_condition_progress_bar",
  type = "progressbar_style",
  bar = {
    base = {position = {561, 836+8}, corner_size = 8},
    shadow = { -- default_shadow
        position = {200, 128},
        corner_size = 8,
        tint = {0, 0, 0, 0.35},
        scale = 0.5,
        draw_type = "outer"
    }
  }
}

style.se_spaceship_scheduler_records_scroll_pane =
{
  type = "scroll_pane_style",
  parent = "scroll_pane_with_dark_background_under_subheader",
  background_graphical_set =
  {
    position = {282, 17},
    corner_size = 8,
    custom_horizontal_tiling_sizes = {28, 44, 288},
    overall_tiling_horizontal_spacing = 8,
    overall_tiling_horizontal_padding = 4,
    overall_tiling_vertical_spacing = 12,
    overall_tiling_vertical_size = 28,
    overall_tiling_vertical_padding = 4
  }
}

style.se_spaceship_scheduler_comparator_dropdown =
{
  type = "dropdown_style",
  minimal_width = 0,
  left_padding = 4,
  right_padding = 0,
  -- semi-hack redefining the graphical set to put shadow in to glow layer to be on top of the neighbour inset
  button_style =
  {
    type = "button_style",
    parent = "dropdown_button",
    default_graphical_set =
    {
      base = {position = {0, 17}, corner_size = 8},
      glow = default_glow(default_dirt_color, 0.5)
    },
    hovered_graphical_set =
    {
      base = {position = {34, 17}, corner_size = 8},
      glow = default_glow({225, 177, 106, 255}, 0.5)
    },
    clicked_graphical_set =
    {
      base = {position = {51, 17}, corner_size = 8},
      glow = default_glow(default_dirt_color, 0.5)
    },
    disabled_graphical_set =
    {
      base = {position = {17, 17}, corner_size = 8},
      glow = default_glow(default_dirt_color, 0.5)
    },
    selected_graphical_set =
    {
      base = {position = {225, 17}, corner_size = 8},
      glow = default_glow(default_dirt_color, 0.5)
    },
    selected_hovered_graphical_set =
    {
      base = {position = {369, 17}, corner_size = 8},
      glow = default_glow(default_dirt_color, 0.5)
    },
    selected_clicked_graphical_set =
    {
      base = {position = {352, 17}, corner_size = 8},
      glow = default_glow(default_dirt_color, 0.5)
    }
  },
  list_box_style =
  {
    type = "list_box_style",
    maximal_height = 400,
    item_style =
    {
      type = "button_style",
      parent = "list_box_item",
      left_padding = 4,
      right_padding = 4
    },
    scroll_pane_style =
    {
      type = "scroll_pane_style",
      padding = 0,
      extra_padding_when_activated = 0,
      graphical_set = {shadow = default_glow(default_shadow_color, 0.5)}
    }
  }
}

style.se_spacehip_scheduler_comparison_type_frame =
{
  type = "frame_style",
  padding = 0,
  top_margin = -20,
  bottom_margin = 20
}

style.se_train_schedule_delete_button_red =
{
  type = "button_style",
  parent = "red_button",
  padding = 0,
  width = 16,
  invert_colors_of_picture_when_hovered_or_toggled = true,
  left_click_sound = "__core__/sound/gui-tool-button.ogg"
}
