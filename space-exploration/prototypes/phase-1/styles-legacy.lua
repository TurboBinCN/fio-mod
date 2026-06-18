--- This contains the styles that went missing from 1.1 to 2.0.
--- Ideally all of this needs to be consolidated. And if we keep it
--- like this we might have to prefix it with `se_*`

local style = data.raw["gui-style"]["default"]

default_shadow_color = {0, 0, 0, 0.35}
hard_shadow_color = {0, 0, 0, 1}

function default_glow(tint_value, scale_value)
  return
  {
    position = {200, 128},
    corner_size = 8,
    tint = tint_value,
    scale = scale_value,
    draw_type = "outer"
  }
end

function default_inner_glow(tint_value, scale_value)
  return
  {
    position = {183, 128},
    corner_size = 8,
    tint = tint_value,
    scale = scale_value,
    draw_type = "inner"
  }
end

default_shadow = default_glow(default_shadow_color, 0.5)
default_inner_shadow = default_inner_glow(hard_shadow_color, 0.5)

-------------------------------------------

style.dark_frame =
{
  type = "frame_style",
  graphical_set =
  {
    base = {position = {68, 0}, corner_size = 8},
    shadow = default_shadow
  }
}

style.a_inner_frame =
{
  type = "frame_style",
  graphical_set =
  {
    base = {position = {17, 0}, corner_size = 8, draw_type = "outer"},
    shadow = default_inner_shadow
  }
}

style.b_inner_frame =
{
  type = "frame_style",
  graphical_set =
  {
    base =
    {
      position = {17, 0},
      corner_size = 8,
      center = {position = {76, 8}, size = {1, 1}},
      draw_type = "outer"
    },
    shadow = default_inner_shadow
  }
}

style.window_content_frame =
{
  type = "frame_style",
  padding = 4,
  graphical_set =
  {
    base =
    {
      position = {17, 0},
      corner_size = 8,
      center = {position = {76, 8}, size = {1, 1}},
      draw_type = "outer"
    },
    shadow = default_inner_shadow
  }
}

style.window_content_frame_packed =
{
  type = "frame_style",
  parent = "window_content_frame",
  padding = 0,
  horizontal_flow_style =
  {
    type = "horizontal_flow_style",
    horizontal_spacing = 0
  },
  vertical_flow_style =
  {
    type = "vertical_flow_style",
    vertical_spacing = 0
  }
}

style.quick_bar_window_frame =
{
  type = "frame_style",
  padding = 4,
  use_header_filler = false,
  header_flow_style =
  {
    type = "horizontal_flow_style",
    bottom_padding = 8
  },
  horizontal_flow_style =
  {
    type = "horizontal_flow_style",
    --space between page buttons and icon slots
    horizontal_spacing = 8
  }
}

style.scroll_pane_with_dark_background_under_subheader =
{
  type = "scroll_pane_style",
  extra_padding_when_activated = 0,
  padding = 4,
  graphical_set =
  {
    base =
    {
      position = {17, 0},
      corner_size = 8,
      center = {position = {42, 8}, size = 1},
      top = {},
      left_top = {},
      right_top = {},
      draw_type = "outer"
    },
    shadow = default_inner_shadow
  }
}
