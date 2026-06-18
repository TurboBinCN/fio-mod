local Blueprint = {}

-- Ruin.replace_in_blueprint({name="filename", blueprint="...", entities={["in_name"]="out-name"}, tiles={["in_name"]="out-name"}})
---@param data {name:string, blueprint: string, entities?:{name:string, new_name?:string, shift?:MapPosition}[], tiles?:{[string]:string}}
function Blueprint.replace_in_blueprint(data)
  local file_name = "space-exploration.replace_in_blueprint."..data.name..".lua"
  local blueprint_string = data.blueprint

  local inv = game.create_inventory(1)
  inv.insert{name="blueprint", count = 1}
  local blueprint = inv[1]
  blueprint.import_stack(blueprint_string)

  local entities = blueprint.get_blueprint_entities()
  for _, entity in pairs(entities or {}) do
    for _, change in pairs(data.entities or {}) do
      if entity.name == change.name then
        if change.new_name then
          entity.name = change.new_name
        end
        if change.shift then
          entity.position.x = entity.position.x + change.shift[1] or change.shift.x
          entity.position.y = entity.position.y + change.shift[2] or change.shift.y
        end
      end
    end
  end
  blueprint.set_blueprint_entities(entities)

  local tiles = blueprint.get_blueprint_tiles()
  for _, tile in pairs(tiles or {}) do
    for k, v in pairs(data.tiles or {}) do
      if tile.name == k then tile.name = v end
    end
  end
  blueprint.set_blueprint_tiles(tiles)

  local out_string = blueprint.export_stack()

  inv.destroy()

  helpers.write_file(file_name, out_string, false)
end

return Blueprint
