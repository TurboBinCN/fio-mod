-- Note: Default entity force will be 'capture', if a player character get near and there are no enemies the player will capture the entity.
local satellite = {
  center = {x = 0, y = 0},
  landing_offset = {1,5}, -- only used in the satelliet blueprint, not normal ruins
  force_name = "friendly",
  insert_list = {
    {x=4,  y=2, items={{name = "se-space-science-lab", min = 1, max = 1},
                       {name = "automation-science-pack", min = 1000, max = 1000},
                       {name = "logistic-science-pack", min = 1000, max = 1000},
                       {name = "chemical-science-pack", min = 1000, max = 1000},
                       {name = mod_prefix.."rocket-science-pack", min = 500, max = 500},
                      }},
    {x=4,  y=4, items={{name = "se-space-manufactory", min = 1, max = 1},
                       {name = "iron-plate", min = 1000, max = 1000},
                       {name = "copper-plate", min = 1000, max = 1000},
                       {name = mod_prefix.."beryllium-plate", min = 1000, max = 1000},
                       {name = mod_prefix.."vulcanite-block", min = 100, max = 100},
                      }},
    {x=4,  y=6, items={{name = mod_prefix.."space-platform-plating", min = 200, max = 200},
                       {name = mod_prefix.."space-platform-scaffold", min = 200, max = 200},
                       {name = mod_prefix.."deep-space-transport-belt-yellow", min = 200, max = 200},
                       {name = mod_prefix.."deep-space-splitter-yellow", min = 10, max = 10},
                       {name = mod_prefix.."deep-space-underground-belt-yellow", min = 20, max = 20},
                       {name = mod_prefix.."space-rail", min = 100, max = 100},
                      }},
    {x=-3, y=2, items={{name = "solar-panel", min = 10, max = 10},
                       {name = mod_prefix.."pylon", min = 1, max = 1},
                       {name = mod_prefix.."pylon-substation", min = 1, max = 1},
                       {name = mod_prefix.."pylon-construction", min = 1, max = 1},
                       {name = mod_prefix.."space-capsule"},
                       {name = "cargo-landing-pad"},
                       {name = mod_prefix.."delivery-cannon-chest"},
                      }},
    {x=-3, y=4, items={
                        {name = "water-barrel", min = 200, max = 200},
                        {name = "lubricant-barrel", min = 10, max = 10},
                        {name = "heavy-oil-barrel", min = 100, max = 100},
                      }},
    {x=-3, y=6, items={ -- weapons added here
                       {name = "raw-fish", min = 10, max = 10},
                       {name = mod_prefix.."medpack-4"},
                      }},
                 },
  ---@param surface LuaSurface
  ---@param ruin_position MapPosition.0
  ---@param ruin RuinInfo
  prebuild = function(surface, ruin_position, ruin) -- surface, position, self (DO NOT MODFY SELF)
    -- function that runs before tiles and entities are added
  end,
  ---@param surface LuaSurface
  ---@param ruin_position MapPosition.0
  ---@param ruin RuinInfo
  ---@param built_entities Collection<LuaEntity>
  postbuild = function(surface, ruin_position, ruin, built_entities)
    local ruin_position_center_offset = Util.vectors_delta(ruin.center, ruin_position)
    local pos = Util.vectors_add(ruin_position_center_offset, {x=-3+0.5, y=6+0.5})
    local weapons_chest = surface.find_entity("steel-chest", pos)

    if weapons_chest then
      local r = math.random(1,2)
      if r == 1 then
        weapons_chest.insert({name=mod_prefix.."tesla-gun", count=1})
        weapons_chest.insert({name=mod_prefix.."tesla-ammo", count=200})
        weapons_chest.insert({name=mod_prefix.."cryogun", count=1})
        weapons_chest.insert({name=mod_prefix.."cryogun-ammo", count=200})
      elseif r == 2 then
        weapons_chest.insert({name=mod_prefix.."cryogun", count=1})
        weapons_chest.insert({name=mod_prefix.."cryogun-ammo", count=200})
        weapons_chest.insert({name=mod_prefix.."biogun", count=1})
        weapons_chest.insert({name=mod_prefix.."bloater-ammo", count=200})
      end
    end
    --surface.create_entity({name="iron-chest",position={x=ruin_position.x - ruin.center.x, y=ruin_position.y - ruin.center.y}})
    -- surface, position, self (maybe modified)
    -- function that runs after tiles and entities are added
    -- maybe required to set conditions
    --[[local accumulator = surface.find_entity("accumulator",
      {
        x = 10.5 + ruin_position.x - ruin.center.x,
        y = 8.5 + ruin_position.y - ruin.center.y
      }
    )
    local control = accumulator.get_or_create_control_behavior() -- https://lua-api.factorio.com/latest/LuaControlBehavior.html#LuaAccumulatorControlBehavior
    control.output_signal = {type = "virtual", name = "signal-B"}
    game.print("test end")
    ]]
  end,
  blueprint_strings = {
    { -- tiles
      xadj = 1, yadj = 2,
      string = "0eNqt2stu2lAUheF3OWMinYsvwKtUGVBiIktgUEyqRoh3bwgMOiml/jrKTXuDf7ZPlvdap/B9+94d3vrhGJan0K/3wxiW305h7F+H1fbyu+PHoQvL0B+7XZiFYbW7/DR2T+Nhte6eDtvVcbN/23190w+v4TwL/fDS/QzLdH6ehWO/7a4dD/uxP/b74dLz869PaTELH59fm/NDXf/coJ7cYH5t0GqDRhvwJVSTG7TKoFUGrTJolUGjDBpl0CiDRhnUyqBWBrUyqJVBpQwqZVApg0oZFGVQlEFRBkUZZGWQlUFWBlkZJGWQlEFSBkkZRGUQlUFUBhEZLBCBijzVeAu8fpWIqhBVIKo+VHmo6lDFoWpDVXYq7B5RVeN6tdnsty/3GtSTG6imUUlzq09Wj+VlarmqIRVD5QF6dz/+8nd8D9SXyfVZb4CsN8CtQZ76EWQc4Gt9tHJ8dbz4YuXTFZzqL5VfD/z3uTt7twYF30DG+mT10crx1fHikT3O7tTRwycPfO6IOPfRxj7a1Ecb+kgzH2nkI018pIGPNO+Rxj2hSkgoEvCcxWPWTlk7ZO2MtSPWTlhc0uGKLqMwz6bLs8lyfKzBp5pit0uhgS80shUeVBUeVOjSoEeDRhsuY5r/8uanHje4ScNFGu7RcI2GW1RcouIOFVeouEHHBTruz3F9rg6KGijqn6h9oi6ammjqoamFpk6qGqnqo6qNqm66munqpauVrokKDVRonkLjFJqq0VCNZmo0UqPJKg1Waa5KY1WartNwnWbrNFqnAcl/y0c+z64p1eVvodZZ+NG9jV8d8zxV7SK3ad5WdZPO51+3bUmJ"
    },
    { -- entities
      xadj = 1, yadj = 1,
      string = "0eNqV1N1qwyAUB/B3OddaYr6bVyljmPSwCVZFzVgIvvtMerFCGzdvFMXz4y9+rDDKGY0VysOwgpi0cjBcVnDiQ3G5zfnFIAwgPN6AgOK3beSQOsOn2GrJLTVcoYRAQKgrfsPAwhsBVF54gXdvHyzvar6NaOOCtETAaBeLtdoSRJCylsAS+yYE8qSV2VqZ0KpcrU9gdSaWsppMK7nLNhdLHUD3iJlFakW3m+TtPG0EtfwaZatHbbT1z3iRsPtf2yNKOn2ie0HQ6tTcleL00jn/z/mLYUVmHnbgsLw8R0yZGac6cKq8ODsTH/n+LQwPvwiBL7RuLyh7VnfnsmN9VzctC+EH8v50bA=="
  }}
}

return satellite
