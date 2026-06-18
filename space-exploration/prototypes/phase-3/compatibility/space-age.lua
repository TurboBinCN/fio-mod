if mods["space-age"] then

  -- SESA rockets are apparently around 4 times more expensive than SA rockets according to:
  -- https://discord.com/channels/419526714721566720/1473279418142298164/1475269441691586561
  data.raw["rocket-silo"]["rocket-silo"].rocket_parts_required = 25
  data.raw["rocket-silo"]["sa-rocket-silo"].rocket_parts_required = 25

  if mods["Krastorio2"] then
    -- done after phase-3/technology.lua to skip the auto sort (so it matches postprocess adding the space-age packs to the end of normal labs)
    local k2_lab_inputs = data.raw["lab"]["kr-singularity-lab"].inputs
    table.insert(k2_lab_inputs, "metallurgic-science-pack")
    table.insert(k2_lab_inputs, "agricultural-science-pack")
    table.insert(k2_lab_inputs, "electromagnetic-science-pack")
    table.insert(k2_lab_inputs, "cryogenic-science-pack")
    table.insert(k2_lab_inputs, "promethium-science-pack")
  end

end
