--[[
zone.controls = {
  water = {frequency, size}, -- size is 0 to 6
  moisture = {frequency, bias},-- bias is +/- 0.5
  aux = {frequency, bias}, -- bias is +/- 0.5
  hot = {frequency, size}, -- size is 0 to 6
  cold = {frequency, size}, -- size is 0 to 6
  -other_controls = {frequency, size, richness}, -- size is 0 to 6, for resources and stuff
}
zone.climate_tags = {}
]]--
-- climate presets



-- raw universe data
local UniverseRaw = {}

---@type UniverseType
UniverseRaw.universe = {
  stars = {
    {
      name = "Calidus", -- means hot, warm, brisk, prompt, impetuous, new
      children = {
        { name = "Nauvis", radius_multiplier = 0.5, children = {}} -- this is overwritten by map gen settings anyway
      }
    },
    {name="Astermore"},
    {name="Statarius"}, -- (Septem Statarius) Septem = seven.  Statarius = stationary, standing, steady, calm, even-minded, sedate
    {name="Nalara"},
    {name="Errioni"},
    {name="Kalmaia"},
    {name="Merlime"},
    {name="Halsian"},
    {name="Cordova"},
    {name="Alacrity"},
    {name="Auriel"},
    {name="Penthus"},
    {name="Angelus"},
    {name="Basilius"},
    {name="Auphorus"},
    {name="Pontus"},
    {name="Sargus"},
    {name="Rigelus"},
    {name="Tanius"},
    {name="Terebellus"},
    {name="Capellus"},
    {name="Hankorus"},
    {name="Brunnus"},
    {name="Vozanus"},
    {name="Teamagus"},
    {name="Wexovis"},
    {name="Electra"},
    {name="Sephi"},
    {name="Assimius"},
    {name="Argus"},
    {name="Calamity"},
  },
  anomaly = { -- only 1 of these, not in the 2d layer, equal disance in 3rd layer
    type = "anomaly",
    name = "Foenestra" -- window, loophole, Hole, breach, opening
  },
  space_zones = { -- other places in the same 2d layer as stars, mostly asteroid fields: 44
    ---@diagnostic disable:missing-fields
    { name = "Asteroidia" },
    { name = "Astral Snow", primary_resource="se-water-ice"},
    { name = "Breadcrumbs" },
    { name = "Broken Mirror"},
    { name = "Black Mirror", primary_resource="se-naquium-ore" },
    { name = "Bumperfield"},
    { name = "Caltrops" },
    { name = "Crystal Collective"},
    { name = "Creepy Hollow" },
    { name = "Cosmic Dustlands"},
    { name = "Dark Assemblage", primary_resource="se-naquium-ore"  },
    { name = "Darkflare", primary_resource="se-naquium-ore" },
    { name = "Deadspace", primary_resource="uranium-ore" },
    { name = "Dusty Voids"},
    { name = "Ephemeral Expanse", primary_resource="se-methane-ice"},
    { name = "Felleim"},
    { name = "Galactic Gravel"},
    { name = "Godash"},
    { name = "Grapeshot" },
    { name = "Galactic Graveyard" },
    { name = "Haunted Hollows" },
    { name = "Hailstorm", primary_resource="se-water-ice" },
    { name = "Interstellar Grotto" },
    { name = "Interstellar Barrens" },
    { name = "Ice Field", primary_resource="se-water-ice" },
    { name = "Kaleidoscope" },
    { name = "Melancholia", primary_resource="se-naquium-ore"  },
    { name = "Oblongglobulata", primary_resource="se-methane-ice" },
    { name = "Poltergeist" },
    { name = "Pebbles" },
    { name = "Rocky Ridge" },
    { name = "Razor Field", primary_resource="iron-ore" },
    { name = "Realm of Shadows", primary_resource="se-naquium-ore" },
    { name = "Sands of Time", primary_resource="se-naquium-ore"  },
    { name = "Shadeland" },
    { name = "Sea of Sorrows" },
    { name = "Shattered Skies"},
    { name = "Stardew", primary_resource="se-water-ice"  },
    { name = "Stardust", primary_resource="se-naquium-ore"},
    { name = "Stone Circles" },
    { name = "Solar Entrails", primary_resource="se-methane-ice" },
    { name = "Slumberland" },
    { name = "Starcorpse" },
    { name = "Sky Fragments" },
    { name = "Specter"},
    ---@diagnostic enable:missing-fields
  }
}
-- red
-- violet
-- purple
-- mauve
-- blue
-- turquoise
-- green
-- olive
-- yellow
-- orange
-- white
-- black
-- grey
-- snow

-- these planets are shuffled in as homeworlds
UniverseRaw.multiplayer_homeworlds = {
  { name="Ekida"}, --2
  { name="Dosam" }, --3
  { name="Nacar" }, --4
  { name="Panji" }, --5
  { name="Jitah" }, --6
  { name="Sathex" }, --7
  { name="Waxak" }, --8
  { name="Bolon" }, --9
  { name="Lahuna" }, --10
  { name="Matalac" }, --11
  { name="Eeldo" }, --12
}

UniverseRaw.haven_moons = {
  { name="Greyhaven", radius_multiplier = 0.3, primary_resource="crude-oil", tags={"enemy_none", "temperature_cool", "water_high", "trees_med", "moisture_high", "aux_very_low"} }, --1
  { name="Solsolace", radius_multiplier = 0.3, primary_resource="crude-oil", tags={"enemy_none", "temperature_cool", "water_high", "trees_med", "moisture_high", "aux_very_low"}  }, --2
  { name="Respitia", radius_multiplier = 0.3, primary_resource="crude-oil", tags={"enemy_none", "temperature_cool", "water_high", "trees_med", "moisture_high", "aux_very_low"}  }, --3
  { name="Dusku", radius_multiplier = 0.3, primary_resource="crude-oil", tags={"enemy_none", "temperature_cool", "water_high", "trees_med", "moisture_high", "aux_very_low"}  }, --4
  { name="Sanctunimo", radius_multiplier = 0.3, primary_resource="crude-oil", tags={"enemy_none", "temperature_cool", "water_high", "trees_med", "moisture_high", "aux_very_low"}  }, --5
  { name="Gradshiem", radius_multiplier = 0.3, primary_resource="crude-oil", tags={"enemy_none", "temperature_cool", "water_high", "trees_med", "moisture_high", "aux_very_low"}  }, --6
  { name="Ismet", radius_multiplier = 0.3, primary_resource="crude-oil", tags={"enemy_none", "temperature_cool", "water_high", "trees_med", "moisture_high", "aux_very_low"}  }, --7
  { name="Meditato", radius_multiplier = 0.3, primary_resource="crude-oil", tags={"enemy_none", "temperature_cool", "water_high", "trees_med", "moisture_high", "aux_very_low"}  }, --8
  { name="Remedy", radius_multiplier = 0.3, primary_resource="crude-oil", tags={"enemy_none", "temperature_cool", "water_high", "trees_med", "moisture_high", "aux_very_low"}  }, --9
  { name="Curaga", radius_multiplier = 0.3, primary_resource="crude-oil", tags={"enemy_none", "temperature_cool", "water_high", "trees_med", "moisture_high", "aux_very_low"}  }, --10
  { name="Medjed", radius_multiplier = 0.3, primary_resource="crude-oil", tags={"enemy_none", "temperature_cool", "water_high", "trees_med", "moisture_high", "aux_very_low"}  }, --11
  { name="Aesseilia", radius_multiplier = 0.3, primary_resource="crude-oil", tags={"enemy_none", "temperature_cool", "water_high", "trees_med", "moisture_high", "aux_very_low"}  }, --12
  { name="Seren", radius_multiplier = 0.3, primary_resource="crude-oil", tags={"enemy_none", "temperature_cool", "water_high", "trees_med", "moisture_high", "aux_very_low"}  }, --13
  { name="Serapis", radius_multiplier = 0.3, primary_resource="crude-oil", tags={"enemy_none", "temperature_cool", "water_high", "trees_med", "moisture_high", "aux_very_low"}  }, --14
  { name="Eshu", radius_multiplier = 0.3, primary_resource="crude-oil", tags={"enemy_none", "temperature_cool", "water_high", "trees_med", "moisture_high", "aux_very_low"}  }, --15
  { name="Molli", radius_multiplier = 0.3, primary_resource="crude-oil", tags={"enemy_none", "temperature_cool", "water_high", "trees_med", "moisture_high", "aux_very_low"}  }, --16
  { name="Veles", radius_multiplier = 0.3, primary_resource="crude-oil", tags={"enemy_none", "temperature_cool", "water_high", "trees_med", "moisture_high", "aux_very_low"}  }, --17
  { name="Erio", radius_multiplier = 0.3, primary_resource="crude-oil", tags={"enemy_none", "temperature_cool", "water_high", "trees_med", "moisture_high", "aux_very_low"}  }, --18
  { name="Arawn", radius_multiplier = 0.3, primary_resource="crude-oil", tags={"enemy_none", "temperature_cool", "water_high", "trees_med", "moisture_high", "aux_very_low"}  }, --19
  { name="Cichol", radius_multiplier = 0.3, primary_resource="crude-oil", tags={"enemy_none", "temperature_cool", "water_high", "trees_med", "moisture_high", "aux_very_low"}  }, --20
  { name="Donn", radius_multiplier = 0.3, primary_resource="crude-oil", tags={"enemy_none", "temperature_cool", "water_high", "trees_med", "moisture_high", "aux_very_low"}  }, --21
  { name="Mannanan", radius_multiplier = 0.3, primary_resource="crude-oil", tags={"enemy_none", "temperature_cool", "water_high", "trees_med", "moisture_high", "aux_very_low"}  }, --22
  { name="Morrigan", radius_multiplier = 0.3, primary_resource="crude-oil", tags={"enemy_none", "temperature_cool", "water_high", "trees_med", "moisture_high", "aux_very_low"}  }, --23
  { name="Ran", radius_multiplier = 0.3, primary_resource="crude-oil", tags={"enemy_none", "temperature_cool", "water_high", "trees_med", "moisture_high", "aux_very_low"}  }, --24
  { name="Culga", radius_multiplier = 0.3, primary_resource="crude-oil", tags={"enemy_none", "temperature_cool", "water_high", "trees_med", "moisture_high", "aux_very_low"}  }, --25
  { name="Mantus", radius_multiplier = 0.3, primary_resource="crude-oil", tags={"enemy_none", "temperature_cool", "water_high", "trees_med", "moisture_high", "aux_very_low"}  }, --26
  { name="Orcus", radius_multiplier = 0.3, primary_resource="crude-oil", tags={"enemy_none", "temperature_cool", "water_high", "trees_med", "moisture_high", "aux_very_low"}  }, --27
  { name="Vanth", radius_multiplier = 0.3, primary_resource="crude-oil", tags={"enemy_none", "temperature_cool", "water_high", "trees_med", "moisture_high", "aux_very_low"}  }, --28
  { name="Erebus", radius_multiplier = 0.3, primary_resource="crude-oil", tags={"enemy_none", "temperature_cool", "water_high", "trees_med", "moisture_high", "aux_very_low"}  }, --29
  { name="Mors", radius_multiplier = 0.3, primary_resource="crude-oil", tags={"enemy_none", "temperature_cool", "water_high", "trees_med", "moisture_high", "aux_very_low"}  }, --30
  { name="Mara", radius_multiplier = 0.3, primary_resource="crude-oil", tags={"enemy_none", "temperature_cool", "water_high", "trees_med", "moisture_high", "aux_very_low"}  }, --31
  { name="Degei", radius_multiplier = 0.3, primary_resource="crude-oil", tags={"enemy_none", "temperature_cool", "water_high", "trees_med", "moisture_high", "aux_very_low"}  }, --32
  { name="Pana", radius_multiplier = 0.3, primary_resource="crude-oil", tags={"enemy_none", "temperature_cool", "water_high", "trees_med", "moisture_high", "aux_very_low"}  }, --33
}
UniverseRaw.cryonite_moons = {
  { name="Shakok", radius_multiplier = 0.8, primary_resource="se-cryonite", tags={"enemy_none", "temperature_frozen", "water_low", "trees_none", "moisture_med", "aux_med"} }, --1
  { name="Vionette", radius_multiplier = 0.8, primary_resource="se-cryonite", tags={"enemy_none", "temperature_frozen", "water_low", "trees_none", "moisture_med", "aux_med"}  }, --2
  { name="Snowdrop", radius_multiplier = 0.8, primary_resource="se-cryonite", tags={"enemy_none", "temperature_frozen", "water_low", "trees_none", "moisture_med", "aux_med"}  }, --3
  { name="Glacier", radius_multiplier = 0.8, primary_resource="se-cryonite", tags={"enemy_none", "temperature_frozen", "water_low", "trees_none", "moisture_med", "aux_med"}  }, --4
  { name="Hagen", radius_multiplier = 0.8, primary_resource="se-cryonite", tags={"enemy_none", "temperature_frozen", "water_low", "trees_none", "moisture_med", "aux_med"}  }, --5
  { name="Hothier", radius_multiplier = 0.8, primary_resource="se-cryonite", tags={"enemy_none", "temperature_frozen", "water_low", "trees_none", "moisture_med", "aux_med"}  }, --6
  { name="Calippo", radius_multiplier = 0.8, primary_resource="se-cryonite", tags={"enemy_none", "temperature_frozen", "water_low", "trees_none", "moisture_med", "aux_med"}  }, --7
  { name="Pastille", radius_multiplier = 0.8, primary_resource="se-cryonite", tags={"enemy_none", "temperature_frozen", "water_low", "trees_none", "moisture_med", "aux_med"}  }, --8
  { name="Cornetto", radius_multiplier = 0.8, primary_resource="se-cryonite", tags={"enemy_none", "temperature_frozen", "water_low", "trees_none", "moisture_med", "aux_med"}  }, --9
  { name="Frost", radius_multiplier = 0.8, primary_resource="se-cryonite", tags={"enemy_none", "temperature_frozen", "water_low", "trees_none", "moisture_med", "aux_med"}  }, --10
  { name="Cryonia", radius_multiplier = 0.8, primary_resource="se-cryonite", tags={"enemy_none", "temperature_frozen", "water_low", "trees_none", "moisture_med", "aux_med"}  }, --11
  { name="Beira", radius_multiplier = 0.8, primary_resource="se-cryonite", tags={"enemy_none", "temperature_frozen", "water_low", "trees_none", "moisture_med", "aux_med"}  }, --12
  { name="Khione", radius_multiplier = 0.8, primary_resource="se-cryonite", tags={"enemy_none", "temperature_frozen", "water_low", "trees_none", "moisture_med", "aux_med"}  }, --13
  { name="Marzanna", radius_multiplier = 0.8, primary_resource="se-cryonite", tags={"enemy_none", "temperature_frozen", "water_low", "trees_none", "moisture_med", "aux_med"}  }, --14
  { name="Morozko", radius_multiplier = 0.8, primary_resource="se-cryonite", tags={"enemy_none", "temperature_frozen", "water_low", "trees_none", "moisture_med", "aux_med"}  }, --15
  { name="Boreas", radius_multiplier = 0.8, primary_resource="se-cryonite", tags={"enemy_none", "temperature_frozen", "water_low", "trees_none", "moisture_med", "aux_med"}  }, --16
}
UniverseRaw.vulcanite_planets = {
  { name="Aine", radius_multiplier = 0.2, primary_resource="se-vulcanite", tags={"enemy_none", "temperature_volcanic", "water_none", "moisture_none", "trees_none", "aux_very_low"}  }, --1
  { name="Theros", radius_multiplier = 0.2, primary_resource="se-vulcanite", tags={"enemy_none", "temperature_volcanic", "water_none", "moisture_none", "trees_none", "aux_very_low"} }, --2
  { name="Aestas", radius_multiplier = 0.2, primary_resource="se-vulcanite", tags={"enemy_none", "temperature_volcanic", "water_none", "moisture_none", "trees_none", "aux_very_low"} }, --3
  { name="Damia", radius_multiplier = 0.2, primary_resource="se-vulcanite", tags={"enemy_none", "temperature_volcanic", "water_none", "moisture_none", "trees_none", "aux_very_low"} }, --4
  { name="Ruamati", radius_multiplier = 0.2, primary_resource="se-vulcanite", tags={"enemy_none", "temperature_volcanic", "water_none", "moisture_none", "trees_none", "aux_very_low"} }, --5
  { name="Miochin", radius_multiplier = 0.2, primary_resource="se-vulcanite", tags={"enemy_none", "temperature_volcanic", "water_none", "moisture_none", "trees_none", "aux_very_low"} }, --6
  { name="Hephaestus", radius_multiplier = 0.2, primary_resource="se-vulcanite", tags={"enemy_none", "temperature_volcanic", "water_none", "moisture_none", "trees_none", "aux_very_low"} }, --7
  { name="Ogun", radius_multiplier = 0.2, primary_resource="se-vulcanite", tags={"enemy_none", "temperature_volcanic", "water_none", "moisture_none", "trees_none", "aux_very_low"} }, --8
  { name="Shennong", radius_multiplier = 0.2, primary_resource="se-vulcanite", tags={"enemy_none", "temperature_volcanic", "water_none", "moisture_none", "trees_none", "aux_very_low"} }, --9
  { name="Agni", radius_multiplier = 0.2, primary_resource="se-vulcanite", tags={"enemy_none", "temperature_volcanic", "water_none", "moisture_none", "trees_none", "aux_very_low"} }, --10
  { name="Agneya", radius_multiplier = 0.2, primary_resource="se-vulcanite", tags={"enemy_none", "temperature_volcanic", "water_none", "moisture_none", "trees_none", "aux_very_low"} }, --11
  { name="Fuji", radius_multiplier = 0.2, primary_resource="se-vulcanite", tags={"enemy_none", "temperature_volcanic", "water_none", "moisture_none", "trees_none", "aux_very_low"} }, --12
  { name="Odqan", radius_multiplier = 0.2, primary_resource="se-vulcanite", tags={"enemy_none", "temperature_volcanic", "water_none", "moisture_none", "trees_none", "aux_very_low"} }, --13
  { name="Turgmam", radius_multiplier = 0.2, primary_resource="se-vulcanite", tags={"enemy_none", "temperature_volcanic", "water_none", "moisture_none", "trees_none", "aux_very_low"} }, --14
  { name="Alaz", radius_multiplier = 0.2, primary_resource="se-vulcanite", tags={"enemy_none", "temperature_volcanic", "water_none", "moisture_none", "trees_none", "aux_very_low"} }, --15
  { name="Kamar", radius_multiplier = 0.2, primary_resource="se-vulcanite", tags={"enemy_none", "temperature_volcanic", "water_none", "moisture_none", "trees_none", "aux_very_low"} }, --16
  { name="Grannus", radius_multiplier = 0.2, primary_resource="se-vulcanite", tags={"enemy_none", "temperature_volcanic", "water_none", "moisture_none", "trees_none", "aux_very_low"} }, --17
  { name="Mariel", radius_multiplier = 0.2, primary_resource="se-vulcanite", tags={"enemy_none", "temperature_volcanic", "water_none", "moisture_none", "trees_none", "aux_very_low"} }, --18
}
UniverseRaw.iridium_moons = {
  { name="Kothar", radius_multiplier = 0.8, primary_resource="se-iridium-ore", tags={"enemy_low", "temperature_wild", "aux_low", "moisture_low", "trees_none", "water_low"} }, --1
  { name="Ptah", radius_multiplier = 0.8, primary_resource="se-iridium-ore", tags={"enemy_low", "temperature_wild", "aux_low", "moisture_low", "trees_none", "water_low"} }, --2
  { name="Goibniu", radius_multiplier = 0.8, primary_resource="se-iridium-ore", tags={"enemy_low", "temperature_wild", "aux_low", "moisture_low", "trees_none", "water_low"} }, --3
  { name="Anvil", radius_multiplier = 0.8, primary_resource="se-iridium-ore", tags={"enemy_low", "temperature_wild", "aux_low", "moisture_low", "trees_none", "water_low"} }, --4
  { name="Sethlans", radius_multiplier = 0.8, primary_resource="se-iridium-ore", tags={"enemy_low", "temperature_wild", "aux_low", "moisture_low", "trees_none", "water_low"} }, --5
  { name="Svarog", radius_multiplier = 0.8, primary_resource="se-iridium-ore", tags={"enemy_low", "temperature_wild", "aux_low", "moisture_low", "trees_none", "water_low"} }, --6
  { name="Gibil", radius_multiplier = 0.8, primary_resource="se-iridium-ore", tags={"enemy_low", "temperature_wild", "aux_low", "moisture_low", "trees_none", "water_low"} }, --7
  { name="Fornax", radius_multiplier = 0.8, primary_resource="se-iridium-ore", tags={"enemy_low", "temperature_wild", "aux_low", "moisture_low", "trees_none", "water_low"} }, --8
  { name="Forgehammer", radius_multiplier = 0.8, primary_resource="se-iridium-ore", tags={"enemy_low", "temperature_wild", "aux_low", "moisture_low", "trees_none", "water_low"} }, --9
  { name="Wayland", radius_multiplier = 0.8, primary_resource="se-iridium-ore", tags={"enemy_low", "temperature_wild", "aux_low", "moisture_low", "trees_none", "water_low"} }, --10
  { name="Ilmarinen", radius_multiplier = 0.8, primary_resource="se-iridium-ore", tags={"enemy_low", "temperature_wild", "aux_low", "moisture_low", "trees_none", "water_low"} }, --11
  { name="Lugh", radius_multiplier = 0.8, primary_resource="se-iridium-ore", tags={"enemy_low", "temperature_wild", "aux_low", "moisture_low", "trees_none", "water_low"} }, --12
  { name="Seker", radius_multiplier = 0.8, primary_resource="se-iridium-ore", tags={"enemy_low", "temperature_wild", "aux_low", "moisture_low", "trees_none", "water_low"} }, --13
  { name="Cyclops", radius_multiplier = 0.8, primary_resource="se-iridium-ore", tags={"enemy_low", "temperature_wild", "aux_low", "moisture_low", "trees_none", "water_low"} }, --14
  { name="Hadur", radius_multiplier = 0.8, primary_resource="se-iridium-ore", tags={"enemy_low", "temperature_wild", "aux_low", "moisture_low", "trees_none", "water_low"} }, --15
  { name="Ikenga", radius_multiplier = 0.8, primary_resource="se-iridium-ore", tags={"enemy_low", "temperature_wild", "aux_low", "moisture_low", "trees_none", "water_low"} }, --16
}
UniverseRaw.holmium_moons = {
  { name="Enlil", radius_multiplier = 0.8, primary_resource="se-holmium-ore", tags={"enemy_none", "temperature_bland", "aux_very_high", "moisture_high", "trees_med", "water_med"}}, --1
  { name="Amun", radius_multiplier = 0.8, primary_resource="se-holmium-ore", tags={"enemy_none", "temperature_bland", "aux_very_high", "moisture_high", "trees_med", "water_med"} }, --2
  { name="Henkhisesui", radius_multiplier = 0.8, primary_resource="se-holmium-ore", tags={"enemy_none", "temperature_bland", "aux_very_high", "moisture_high", "trees_med", "water_med"} }, --3
  { name="Shu", radius_multiplier = 0.8, primary_resource="se-holmium-ore", tags={"enemy_none", "temperature_bland", "aux_very_high", "moisture_high", "trees_med", "water_med"} }, --4
  { name="Ninlil", radius_multiplier = 0.8, primary_resource="se-holmium-ore", tags={"enemy_none", "temperature_bland", "aux_very_high", "moisture_high", "trees_med", "water_med"} }, --5
  { name="Holmera", radius_multiplier = 0.8, primary_resource="se-holmium-ore", tags={"enemy_none", "temperature_bland", "aux_very_high", "moisture_high", "trees_med", "water_med"} }, --6
  { name="Pazu", radius_multiplier = 0.8, primary_resource="se-holmium-ore", tags={"enemy_none", "temperature_bland", "aux_very_high", "moisture_high", "trees_med", "water_med"} }, --7
  { name="Tazer", radius_multiplier = 0.8, primary_resource="se-holmium-ore", tags={"enemy_none", "temperature_bland", "aux_very_high", "moisture_high", "trees_med", "water_med"} }, --8
  { name="Verbti", radius_multiplier = 0.8, primary_resource="se-holmium-ore", tags={"enemy_none", "temperature_bland", "aux_very_high", "moisture_high", "trees_med", "water_med"} }, --9
  { name="Shurdhi", radius_multiplier = 0.8, primary_resource="se-holmium-ore", tags={"enemy_none", "temperature_bland", "aux_very_high", "moisture_high", "trees_med", "water_med"} }, --10
  { name="Varpulis", radius_multiplier = 0.8, primary_resource="se-holmium-ore", tags={"enemy_none", "temperature_bland", "aux_very_high", "moisture_high", "trees_med", "water_med"} }, --11
  { name="Egoi", radius_multiplier = 0.8, primary_resource="se-holmium-ore", tags={"enemy_none", "temperature_bland", "aux_very_high", "moisture_high", "trees_med", "water_med"} }, --12
  { name="Borroum", radius_multiplier = 0.8, primary_resource="se-holmium-ore", tags={"enemy_none", "temperature_bland", "aux_very_high", "moisture_high", "trees_med", "water_med"} }, --13
  { name="Sidhe", radius_multiplier = 0.8, primary_resource="se-holmium-ore", tags={"enemy_none", "temperature_bland", "aux_very_high", "moisture_high", "trees_med", "water_med"} }, --14
  { name="Njord", radius_multiplier = 0.8, primary_resource="se-holmium-ore", tags={"enemy_none", "temperature_bland", "aux_very_high", "moisture_high", "trees_med", "water_med"} }, --15
  { name="Kari", radius_multiplier = 0.8, primary_resource="se-holmium-ore", tags={"enemy_none", "temperature_bland", "aux_very_high", "moisture_high", "trees_med", "water_med"} }, --16
}
UniverseRaw.vitamelange_moons = {
  { name="Freyr", radius_multiplier = 0.8, primary_resource="se-vitamelange", tags={"enemy_med", "temperature_bland", "aux_very_low", "moisture_high", "trees_high", "water_med"} }, --1
  { name="Bigrid", radius_multiplier = 0.8, primary_resource="se-vitamelange", tags={"enemy_med", "temperature_bland", "aux_very_low", "moisture_high", "trees_high", "water_med"} }, --2
  { name="Eostre", radius_multiplier = 0.8, primary_resource="se-vitamelange", tags={"enemy_med", "temperature_bland", "aux_very_low", "moisture_high", "trees_high", "water_med"} }, --3
  { name="Daisy", radius_multiplier = 0.8, primary_resource="se-vitamelange", tags={"enemy_med", "temperature_bland", "aux_very_low", "moisture_high", "trees_high", "water_med"} }, --4
  { name="Ver", radius_multiplier = 0.8, primary_resource="se-vitamelange", tags={"enemy_med", "temperature_bland", "aux_very_low", "moisture_high", "trees_high", "water_med"} }, --5
  { name="Jura", radius_multiplier = 0.8, primary_resource="se-vitamelange", tags={"enemy_med", "temperature_bland", "aux_very_low", "moisture_high", "trees_high", "water_med"} }, --6
  { name="Buttercup", radius_multiplier = 0.8, primary_resource="se-vitamelange", tags={"enemy_med", "temperature_bland", "aux_very_low", "moisture_high", "trees_high", "water_med"} }, --7
  { name="Eiar", radius_multiplier = 0.8, primary_resource="se-vitamelange", tags={"enemy_med", "temperature_bland", "aux_very_low", "moisture_high", "trees_high", "water_med"} }, --8
  { name="Morityema", radius_multiplier = 0.8, primary_resource="se-vitamelange", tags={"enemy_med", "temperature_bland", "aux_very_low", "moisture_high", "trees_high", "water_med"} }, --9
  { name="Gardinia", radius_multiplier = 0.8, primary_resource="se-vitamelange", tags={"enemy_med", "temperature_bland", "aux_very_low", "moisture_high", "trees_high", "water_med"} }, --10
  { name="Shire", radius_multiplier = 0.8, primary_resource="se-vitamelange", tags={"enemy_med", "temperature_bland", "aux_very_low", "moisture_high", "trees_high", "water_med"} }, --11
  { name="Mossgarden", radius_multiplier = 0.8, primary_resource="se-vitamelange", tags={"enemy_med", "temperature_bland", "aux_very_low", "moisture_high", "trees_high", "water_med"} }, --12
  { name="Fern", radius_multiplier = 0.8, primary_resource="se-vitamelange", tags={"enemy_med", "temperature_bland", "aux_very_low", "moisture_high", "trees_high", "water_med"} }, --13
  { name="Lilly", radius_multiplier = 0.8, primary_resource="se-vitamelange", tags={"enemy_med", "temperature_bland", "aux_very_low", "moisture_high", "trees_high", "water_med"} }, --14
  { name="Rose", radius_multiplier = 0.8, primary_resource="se-vitamelange", tags={"enemy_med", "temperature_bland", "aux_very_low", "moisture_high", "trees_high", "water_med"} }, --15
  { name="Tulip", radius_multiplier = 0.8, primary_resource="se-vitamelange", tags={"enemy_med", "temperature_bland", "aux_very_low", "moisture_high", "trees_high", "water_med"} }, --16
  { name="Everglade", radius_multiplier = 0.8, primary_resource="se-vitamelange", tags={"enemy_med", "temperature_bland", "aux_very_low", "moisture_high", "trees_high", "water_med"} }, --17
}

UniverseRaw.unassigned_planets = {
  {name="Arendel", radius_multiplier = 1, tags={"water_high", "aux_low", "trees_high", "moisture_high", "temperature_bland"}, primary_resource="uranium-ore"},
  {name="Orchid", tags={"water_low", "aux_high", "trees_high", "moisture_high", "temperature_balanced"}, primary_resource="copper-ore",
    biome_replacements={ -- blue, turquoise, white
      {replace={ "vegetation-purple", }, with="vegetation-violet"},
      {replace={"vegetation-mauve", "vegetation-blue", "vegetation-olive", "vegetation-yellow", "vegetation-orange",}, with="vegetation-red"},
      {replace={"all-dirt"}, with="dirt-white"},
      {replace={"all-sand"}, with="sand-white"},
      {replace={"all-volcanic"}, with="volcanic-purple"} }
    }, -- : Red Forestmin_aux = 0.7, min_water = 0.7, min_tempeature = 50, max_temperature = 100
  {name="Anathema", tags={"water_low", "aux_high", "trees_none", "moisture_med", "temperature_vhot"}, primary_resource="iron-ore",
    biome_replacements={  --: Blue Volcanic
      {replace={"all-vegetation"}, with="vegetation-blue"},
      {replace={"all-dirt"}, with="dirt-black"},
      {replace={"all-sand"}, with="sand-black"},
      {replace={"all-volcanic"}, with="volcanic-blue"} } },
  {name="Tigris", tags={"water_low", "aux_low", "trees_low", "moisture_low", "temperature_warm"}, primary_resource="stone",
    biome_replacements={   --  Endless Stone: Yellow deserts and plains
      {replace={"vegetation-red", "vegetation-violet", "vegetation-turquoise", }, with="vegetation-orange"},
      {replace={"vegetation-blue", "vegetation-mauve", "vegetation-purple", "vegetation-olive",  "vegetation-green",}, with="vegetation-yellow"},
      {replace={"dirt-purple", "dirt-violet", "dirt-red", "dirt-aubergine", "dirt-dustyrose", "dirt-black", "dirt-grey", "dirt-white"}, with="dirt-tan"},
      {replace={"sand-purple", "sand-violet", "sand-red", "sand-aubergine", "sand-dustyrose", "sand-black", "sand-grey", "sand-white"}, with="sand-tan"},
      {replace={"all-volcanic"}, with="volcanic-orange"} } },
  {name="Bellerophon"},
  {name="Theseus"},
  {name="Snek", radius_multiplier = 0.9, tags={"water_low", "aux_low", "trees_none", "moisture_none", "temperature_hot"}, patron = "Snek"}, -- either a super-earth or a gas dwarf? ^^
  {name="Maelstrom", primary_resource="iron-ore", tags={"water_med", "aux_med", "trees_med", "moisture_med", "temperature_balanced"},
    biome_replacements={ -- blue, turquoise, white
      {replace={"vegetation-green", "vegetation-olive", "vegetation-yellow", "vegetation-orange"}, with="vegetation-turquoise"},
      {replace={"vegetation-red", "vegetation-violet", "vegetation-purple", "vegetation-mauve"}, with="vegetation-blue"},
      {replace={"all-dirt"}, with="dirt-white"},
      {replace={"all-sand"}, with="sand-white"},
      {replace={"all-volcanic"}, with="volcanic-blue"} } },
  {name="Crystalys", tags={"water_med", "aux_high", "trees_med", "moisture_med", "temperature_vcold"}},
  {name="Nostos", tags={"water_low", "aux_low", "trees_none", "moisture_low", "temperature_balanced"}, primary_resource="uranium-ore",
    biome_replacements={ -- : Endless concrete and ruins. If you explore you find nuclear bombs. You might also find a unique artefact: power armour with a huge equipment grid. Always planet 55?
      {replace={"all-vegetation"}, with="vegetation-turquoise"},
      {replace={"sand-purple", "sand-violet", "sand-red", "sand-brown", "sand-tan", "sand-aubergine", "sand-dustyrose", "sand-cream", "sand-white"}, with="sand-black"},
      {replace={"dirt-purple", "dirt-violet", "dirt-red", "dirt-brown", "dirt-tan", "dirt-aubergine", "dirt-dustyrose", "dirt-cream", "dirt-white"}, with="dirt-black"},
      {replace={"sand-white"}, with="sand-grey"},
      {replace={"dirt-white"}, with="dirt-grey"},
      {replace={"all-volcanic"}, with="volcanic-green"} } },
  {name="Raegis", tags={"water_none", "aux_low", "trees_low", "moisture_med", "temperature_hot"}, primary_resource="copper-ore",
    biome_replacements={
      {replace={"dirt-purple", "dirt-violet", "dirt-aubergine", "dirt-dustyrose", "dirt-cream", "dirt-grey", "dirt-white"}, with="dirt-red"},
      {replace={"dirt-tan", "dirt-beige", "dirt-black", }, with="dirt-brown"},
      {replace={"sand-purple", "sand-violet", "sand-aubergine", "sand-dustyrose", "sand-cream", "sand-grey", "sand-white"}, with="sand-red"},
      {replace={"sand-tan", "sand-beige", }, with="sand-brown"},
      {replace={"all-frozen"}, with="sand-black"},
      {replace={"vegetation-green", "vegetation-olive", "vegetation-violet", "vegetation-purple", "vegetation-mauve", "vegetation-blue", "vegetation-turquoise"}, with="vegetation-red"},
      {replace={"vegetation-yellow"}, with="vegetation-orange"},
      {replace={"all-volcanic"}, with="volcanic-orange"} } }, -- Endless copper. Red deserts and forests.
  {name="Poseidon", radius_multiplier = 0.9, tags={"water_max", "moisture_max", "temperature_bland"}, primary_resource="crude-oil"},
  {name="Wilde", radius_multiplier = 0.9, tags={"water_max", "temperature_wild"}}, -- : Huge planet
  {name="Zegul", tags={"temperature_balanced", "water_med", "trees_high", "aux_med", "moisture_high", "enemy_max"}, primary_resource="coal",
    biome_replacements={ -- red, orange,
      {replace={"vegetation-green", "vegetation-olive", "vegetation-yellow", -- not orange
          "vegetation-violet", "vegetation-purple", "vegetation-mauve", "vegetation-blue", "vegetation-turquoise" }, with="vegetation-red"},
      {replace={"dirt-purple", "dirt-violet", "dirt-brown", "dirt-tan"}, with="dirt-red"},
      {replace={"dirt-aubergine", "dirt-beige", "dirt-cream", "dirt-black", "dirt-grey", "dirt-white"}, with="dirt-dustyrose"},
      {replace={"sand-purple", "sand-violet", "sand-brown", "sand-tan"}, with="sand-red"},
      {replace={"sand-aubergine", "sand-beige", "sand-cream", "sand-black", "sand-grey", "sand-white"}, with="sand-dustyrose"},
      {replace={"all-volcanic"}, with="volcanic-orange"} } }, -- is a biter death world with rich resources near the middle
  {name="Charon", tags={"temperature_volcanic", "water_low"}, primary_resource="copper-ore"}, -- a lava planet with rich copper deposit near the landing site.
  {name="Titan", radius_multiplier = 0.9}, -- : Big
}

UniverseRaw.unassigned_moons = {
  {name="Feluna", tags={"water_none", "moisture_none", "aux_low", "temperature_cool"}, primary_resource="iron-ore",
    biome_replacements={
      {replace={"all-vegetation", "all-dirt"}, with="sand-white"},
      {replace={"all-sand"}, with="sand-grey"},
      {replace={"all-volcanic", "water"}, with="sand-black"} }  }, -- has a rich iron depoit near the landing site but is otherwise like the moon.
  {name="Segel"},
  {name="Leto"},
  {name="Mixin"},
  {name="Albion"},
  {name="Husky", tags={"temperature_vcold"}},-- : Ice World
  {name="Butterfly", tags={"trees_max", "enemy_none"}},
  {name="Bluna", tags={"aux_high", "water_none", "moisture_none", "temperature_hot"}}, -- : Blue moon
  {name="Auberge", tags={"aux_high", "water_none", "moisture_none", "temperature_bland"}}, -- Aubergine Moon
  {name="Harbistaz", tags={"water_none", "moisture_none"}}, -- : moon
  {name="Minkey", tags={"water_high", "enemy_high"}},
  {name="Pengwing", tags={"water_high", "temperature_cold", "aux_low", "moisture_high"}},
  {name="Jackneevle", tags={"water_low", "moisture_low"}}, -- : Moon
  {name="Yetermoon", tags={"water_none", "moisture_none"}},
  {name="Alwego", patron = "Alwego", radius_multiplier = 0.2, tags={"temperature_bland", "enemy_none", "water_low", "moisture_high", "aux_very_low", "cliff_max", "trees_none"} },
}

UniverseRaw.unassigned_planets_or_moons = {
  {name="Untra", patron = "Untra", tags={"water_none", "moisture_none", "aux_very_high", "temperature_frozen", "trees_none", "cliff_none", "enemy_none"},
    primary_resource="iron-ore",
    radius_multiplier = 0.35,
    preset_resource_bias={["iron-ore"] = 1, ["se-cryonite"] = 0.95},
    biome_replacements={
      {replace={"all-dirt"}, with="dirt-grey"},
      {replace={"all-sand"}, with="sand-grey"},
    }
  },
  {name="Nell", patron = "Cpp", tags={"water_med", "moisture_med", "aux_very_high", "temperature_wild", "trees_high", "cliff_med", "enemy_max"},
    primary_resource="se-holmium-ore",
    radius_multiplier = 0.35,
    preset_resource_bias={["crude-oil"] = 0.95, ["copper-ore"] = 0.9, ["coal"] = 0.8, ["uranium-ore"] = 0},
    biome_replacements={
      {replace={"all-vegetation", "dirt-purple", "dirt-violet", "dirt-red", "dirt-brown", "dirt-tan", "dirt-dustyrose", "dirt-beige", "dirt-cream", "dirt-black", "dirt-grey", "dirt-white", "dirt-aubergine"}, with="vegetation-purple"},
      --{replace={"sand-purple", "sand-violet", "sand-red", "sand-brown"}, with="sand-dustyrose"}, --Next step converts "sand-dustyrose" to "sand-black"
      {replace={"sand-purple", "sand-violet", "sand-red", "sand-brown", "sand-tan", "sand-dustyrose", "sand-beige", "sand-cream", "sand-grey", "sand-aubergine"}, with="sand-black"}
    }
  },
  {name="Sylvateu", patron = "Penitencia", tags={"water_low", "moisture_max", "aux_high", "temperature_midrange", "trees_max", "cliff_none", "enemy_low"},
    primary_resource="se-iridium-ore"
  },
  {name="Aurelios", patron = "Joshua Tibbetts", tags={"water_med", "moisture_max", "aux_very_high", "temperature_vhot", "trees_low", "cliff_low", "enemy_med"},
    primary_resource="se-vulcanite",
  },
  {name="Hellmouth", patron = "Stuart Whelan", tags={"water_none", "moisture_none", "temperature_vhot", "trees_low", "cliff_med", "enemy_med"},
    primary_resource="se-vulcanite",
  },
  {name="Matyus", patron = "jmatya", tags={"water_max", "moisture_max", "aux_high", "temperature_wild", "trees_max", "cliff_none", "enemy_very_low"},
    primary_resource="se-vulcanite",
    preset_resource_bias={["se-vulcanite"] = 1, ["se-cryonite"] = 0.95},
  },
  {name="Orbadon", patron = "Orbadon", tags={"water_max", "moisture_med", "aux_med", "temperature_wild", "trees_high", "cliff_low", "enemy_very_low"}},
  {name="Feist", patron = "Warren Rosenau", tags={"aux_very_high", "temperature_extreme", "enemy_max"},
    primary_resource="se-vulcanite",
    preset_resource_bias={["se-vulcanite"] = 1, ["se-cryonite"] = 0.95},
  },
  {name="Irinchik", patron = "Eduard Tyantov", tags={"temperature_balanced", "enemy_none"}},
  {name="Orsa", patron = "ppeellllee", tags={"cliff_max", "enemy_high"},
    primary_resource="se-iridium-ore"
  },
  {name="Jibber", patron = "David Hillier", tags={"water_med", "moisture_high", "aux_very_low", "temperature_warm", "trees_high", "cliff_low", "enemy_very_low"},
    primary_resource="se-iridium-ore"
  },
  {name="Lameuffen", patron = "Hazmodan", tags={"water_med", "moisture_low", "aux_low", "temperature_vhot", "trees_none", "cliff_low", "enemy_none"},
    primary_resource="copper-ore",
  },
  {name="Sapphire", patron = "Stephanie Miller", tags={"water_max", "moisture_max", "aux_high", "temperature_hot", "trees_med", "cliff_low", "enemy_none"},
    primary_resource="se-beryllium-ore", preset_resource_bias={["se-beryllium-ore"] = 1, ["iron-ore"] = 0.95},
    biome_replacements={
      {replace={"vegetation-olive", "vegetation-yellow", "vegetation-orange", "vegetation-red"}, with="vegetation-turquoise"},
      {replace={"vegetation-red", "vegetation-violet", "vegetation-purple", }, with="vegetation-blue"},
      {replace={"all-dirt"}, with="dirt-cream"},
      {replace={"all-sand"}, with="sand-cream"},
      {replace={"all-volcanic"}, with="volcanic-blue"},
    }
  },
  {name="Yggdrasil", patron = "mishugashu", tags={"water_low", "moisture_high", "aux_very_low", "temperature_warm", "trees_max", "cliff_high", "enemy_very_low"},
    primary_resource="se-vitamelange", preset_resource_bias={["se-vitamelange"] = 1, ["copper-ore"] = 0.95},
  },
  {name="Cybros", patron = "FairEnough", tags={"water_low", "moisture_max", "aux_very_low", "temperature_balanced", "trees_med", "cliff_low", "enemy_none"},
    primary_resource="se-beryllium-ore",
  },
  {name="Tzelma", patron = "Scott McCoy", tags={"water_low", "moisture_max", "aux_very_high", "temperature_warm", "trees_med", "cliff_med", "enemy_very_low"},
    primary_resource="se-holmium-ore", preset_resource_bias={["se-holmium-ore"] = 1, ["crude-oil"] = 0.95, ["iron-ore"] = 0.9},
    biome_replacements={
      {replace={"all-vegetation"}, with="vegetation-purple"},
      {replace={"all-dirt"}, with="dirt-purple"},
      {replace={"all-sand"}, with="sand-purple"},
      {replace={"all-volcanic"}, with="volcanic-purple"},
    }
  },
  {name="Mina", patron = "PonSquared", tags={"water_high", "moisture_high", "aux_very_high", "temperature_balanced", "trees_med", "cliff_low", "enemy_low"},
    primary_resource="iron-ore", preset_resource_bias={["iron-ore"] = 1, ["crude-oil"] = 0.95, ["se-holmium-ore"] = 0.9},
    biome_replacements={
      {replace={"all-vegetation"}, with="vegetation-purple"},
      {replace={"all-dirt"}, with="dirt-purple"},
      {replace={"all-sand"}, with="sand-purple"},
      {replace={"all-volcanic"}, with="volcanic-purple"},
    }
  },
  {name="Greger", patron = "Anton Bergåker", tags={"water_low", "moisture_low", "aux_med", "temperature_hot", "trees_max", "cliff_low", "enemy_very_low"},
    primary_resource="iron-ore",
  },
  {name="Murasaki", patron = "CaitSith2", tags={"water_med", "moisture_med", "aux_med", "temperature_extreme", "trees_med", "cliff_none", "enemy_none"},
    primary_resource="crude-oil", preset_resource_bias={["crude-oil"] = 1, ["se-vulcanite"] = 0.95, ["se-cryonite"] = 0.9,},
    biome_replacements={
      {replace={"all-vegetation"}, with="vegetation-purple"},
      {replace={"all-dirt"}, with="dirt-tan"},
      {replace={"all-sand"}, with="sand-tan"},
      {replace={"volcanic-green", "volcanic-blue"}, with="volcanic-purple"},
    }
  },
  {name="Faustus", patron = "March McLaughlin", tags={"water_med", "moisture_med", "aux_high", "temperature_vcold", "trees_med", "cliff_low", "enemy_very_low"},
    primary_resource="se-cryonite",
  },
  {name="Tinfaya", patron = "Major Painpoint", tags={"water_low", "moisture_low", "aux_very_low", "temperature_hot", "trees_low", "cliff_high", "enemy_none"},
    primary_resource="stone", preset_resource_bias={["stone"] = 1, ["se-vulcanite"] = 0.95},
  },
  {name="Melkor", patron = "Charles Vaughn", tags={"water_low", "moisture_med", "aux_med", "temperature_hot", "trees_low", "cliff_low", "enemy_low"},
    primary_resource="se-iridium-ore",
    biome_replacements={
      {replace={"volcanic-orange"}, with="volcanic-blue"}
    }
  },
  {name="Thurion", patron = "Koelbloed", tags={"moisture_low", "moisture_low", "aux_high", "temperature_warm", "trees_low", "cliff_med", "enemy_med"},
    primary_resource="iron-ore",
  },
  {name="Jinxjazz", patron = "JinxAndJazz", tags={"water_med", "moisture_none", "aux_very_high", "temperature_frozen", "trees_low", "cliff_med", "enemy_very_low"},
    primary_resource="se-cryonite",
  },
  {name="Yuraq", patron = "frigidplanet", tags={"water_none", "moisture_none", "aux_high", "temperature_frozen", "trees_none", "cliff_high", "enemy_med"},
    primary_resource="se-cryonite",
  },
  {name="Braenora", patron = "DrAgniBraenor", tags={"water_med", "moisture_med", "aux_med", "temperature_vcold", "trees_none", "cliff_high", "enemy_low"},
    primary_resource="se-cryonite", -- Quiet, frozen planet, add ruins if possible.
  },
  {name="Lozekam", patron = "xandkat", tags={"water_low", "moisture_none", "aux_very_low", "temperature_frozen", "trees_none", "cliff_none", "enemy_none"},
    primary_resource="se-cryonite",
  },
  {name="Boerdig", patron = "letsgo2u", tags={"water_high", "moisture_low", "aux_med", "temperature_extreme", "trees_low", "cliff_max", "enemy_low"},
    primary_resource="se-vulcanite",
    preset_resource_bias={["se-vulcanite"] = 1, ["se-cryonite"] = 0.95},
  },
  {name="Goose", patron = "H. Goose", tags={"water_med", "moisture_med", "aux_high", "temperature_vcold", "cliff_max", "enemy_max"},
    primary_resource="se-iridium-ore",
    biome_replacements={
      {replace={"all-vegetation"}, with="vegetation-violet"},
      {replace={"all-dirt"}, with="dirt-cream"},
      {replace={"all-sand"}, with="sand-white"},
    }
  },
  {name="Corrine", patron = "Shadowclaimer", tags={"water_high", "moisture_high", "aux_very_low", "temperature_bland", "trees_max", "cliff_none", "enemy_med"},
    primary_resource="se-holmium-ore",
  },
  {name="Willownezz", patron = "Willownezz", tags={"water_low", "moisture_high", "aux_very_high", "temperature_extreme", "trees_high", "cliff_none", "enemy_very_low"},
    primary_resource="se-vulcanite", -- Can't call it Willow, reserved for vitamelange. Cold planet but with red/gray volcanic deserts with Vulcanite core Seams and Uranium
    preset_resource_bias={["se-vulcanite"] = 1, ["se-cryonite"] = 0.95, ["uranium-ore"] = 0.9,},
    biome_replacements={
      {replace={"vegetation-violet", "vegetation-purple", "vegetation-mauve", "vegetation-green", "vegetation-olive", "vegetation-orange", "vegetation-yellow"}, with="vegetation-red"},
      {replace={"vegetation-blue", "vegetation-turquoise"}, with="sand-grey"},
      {replace={"all-dirt"}, with="dirt-red"},
      {replace={"all-sand"}, with="sand-grey"},
      {replace={"all-volcanic"}, with="volcanic-orange"},
    }
  },
  {name="Antsoutwelt", patron = "Reroll Jenkins", tags={"water_max", "moisture_max", "aux_very_low", "temperature_temperate", "trees_med", "cliff_max", "enemy_max"},
    primary_resource="se-vitamelange", -- more meteors and alien buildings
    radius_multiplier = 0.97,
  },
  {name="Grishord", patron = "Grishord", tags={"water_med", "moisture_max", "aux_very_high", "temperature_midrange", "trees_max", "cliff_med", "enemy_low"},
    primary_resource="se-vitamelange", -- green green green
    biome_replacements={
      {replace={"dirt-black"}, with="vegetation-olive"},
      {replace={"sand-black"}, with="vegetation-green"},
      {replace={"all-volcanic"}, with="volcanic-green"},
    }
  },
  {name="Derry", patron = "Derry", tags={"water_max", "moisture_med", "aux_very_low", "temperature_warm", "trees_med", "cliff_low", "enemy_very_high"},
    primary_resource="crude-oil",
  },
  {name="Seehusen", patron = "Sashalicious", tags={"water_low", "moisture_low", "aux_very_high", "temperature_hot", "trees_low", "cliff_low", "enemy_none"},
    primary_resource="se-vulcanite",
    controls = {
      hot = {frequency=1.5, size=2.5},
      cold = {frequency=1.5, size=0.3},
      aux = {frequency=1.5, bias=0.35} -- half way between high and very high
    },
    biome_replacements={
      {replace={"sand-aubergine", "dirt-tan", "sand-brown"}, with="frozen-ice"},
      {replace={"dirt-aubergine", "sand-tan", "dirt-brown"}, with="frozen-snow"},
    }
  },
  {name="Etreum", patron = "Valeria", tags={"water_high", "moisture_high", "aux_high", "temperature_wild", "trees_med", "cliff_none", "enemy_very_low"},
    primary_resource="iron-ore",
    -- TODO: Add aquatic ruin.
  },
  {name="Sansara", patron = "Xsansara", tags={"water_low", "moisture_max", "aux_very_low", "temperature_midrange", "trees_max", "cliff_low", "enemy_none"},
  },
  {name="Lizava", patron = "OneWheelDude", tags={"water_med", "moisture_high", "aux_low", "temperature_bland", "trees_low", "cliff_low", "enemy_none"},
    primary_resource="se-beryllium-ore",
  },
  {name="Norfair", patron = "Syd", tags={"water_low", "moisture_none", "aux_very_high", "temperature_vhot", "trees_low", "cliff_max", "enemy_low"},
    primary_resource="se-holmium-ore",
    biome_replacements={
      {replace={"volcanic-orange"}, with="vegetation-purple"},
      {replace={"volcanic-green"}, with="vegetation-mauve"},
    }
  },
  {name="Robbebol", patron = "TheCuriousClown", tags={"water_med", "trees_high", "cliff_med"}
  },
  {name="Snezon", patron = "PrismaticKevin", tags={"water_med", "moisture_high", "aux_med", "temperature_cold", "trees_high", "cliff_none", "enemy_none"},
    controls = {hot = {frequency=2, size=0}, cold={frequency=2, size=1}},
    primary_resource="se-holmium-ore",
    biome_replacements={
      {replace={"sand-black", "sand-grey"}, with="sand-white"},
      {replace={"sand-cream", "sand-beige"}, with="sand-grey"},
      {replace={"sand-aubergine", "sand-violet", "sand-purple", "sand-red", "sand-brown", "sand-tan"}, with="sand-dustyrose"},
      {replace={"dirt-black"}, with="dirt-white"},
      {replace={"dirt-cream", "dirt-beige"}, with="dirt-grey"},
      {replace={"dirt-aubergine", "dirt-violet", "dirt-purple", "dirt-red", "dirt-brown", "dirt-tan"}, with="dirt-dustyrose"},
      {replace={"vegetation-blue"}, with="vegetation-turquoise"},
      {replace={"vegetation-olive", "vegetation-yellow", "vegetation-orange", "vegetation-red", "vegetation-violet", "vegetation-purple", "vegetation-mauve"}, with="vegetation-green"},
    }
  },
  {name="Cinza", patron = "Ash2ruin", tags={"water_low", "moisture_none", "aux_very_high", "temperature_volcanic", "trees_none", "cliff_med", "enemy_none"},
    primary_resource="se-vulcanite"
  },
  {name="Xorius", patron = "Xor", tags={"water_low", "moisture_max", "aux_med", "temperature_balanced", "trees_none", "cliff_none", "enemy_none"},
    primary_resource="se-holmium-ore",
    biome_replacements={
      {replace={"sand-violet", "sand-tan", "sand-dustyrose", "sand-beige", "sand-brown", "sand-cream", "sand-grey", "sand-white"}, with="sand-black"},
      {replace={"dirt-violet", "dirt-tan", "dirt-dustyrose", "dirt-beige", "dirt-brown", "dirt-cream", "dirt-grey", "dirt-white"}, with="dirt-black"},
      {replace={"vegetation-yellow", "vegetation-orange"}, with="vegetation-green"},
      {replace={"volcanic-orange"}, with="volcanic-green"},
    }
  },
  {name="Lacero", patron = "Lacero", tags={"water_low", "moisture_none", "aux_very_high", "temperature_vhot", "trees_none", "cliff_none", "enemy_none"},
    primary_resource="se-cryonite",
  },
  {name="Exallander", patron = "Boardoe", tags={"water_med", "moisture_low", "aux_med", "temperature_hot", "trees_low", "cliff_max", "enemy_very_low"},
    primary_resource="se-iridium-ore",
    biome_replacements={
      {replace={"all-vegetation"}, with="vegetation-yellow"},
    }
  },
  {name="Eris", patron = "NextToZero", tags={"temperature_hot", "water_max", "moisture_high", "aux_very_low", "trees_high", "cliff_high", "enemy_med"},
    primary_resource="crude-oil",
    biome_replacements={
      {replace={"vegetation-orange", "vegetation-yellow" }, with="vegetation-olive"},
      {replace={"all-dirt", "all-sand"}, with="sand-cream"},
      {replace={"all-volcanic"}, with="volcanic-orange"}
    }
  },
  {name="Cetria", patron = "Pelf", tags={"temperature_warm", "enemy_low", "water_low", "moisture_max", "aux_med", "trees_high", "cliff_low"},
    primary_resource="se-vitamelange",
  },
  {name="Kraine", patron = "Дмитро Кравченко", tags={"water_high", "moisture_med", "aux_very_high", "temperature_wild", "trees_none", "cliff_max", "enemy_high"},
    primary_resource="uranium-ore",
    biome_replacements={
      {replace={"vegetation-green", "vegetation-olive", "vegetation-orange", "vegetation-red" }, with="vegetation-yellow"},
      {replace={"vegetation-violet", "vegetation-purple", "vegetation-mauve", "vegetation-turquoise"}, with="vegetation-blue"},
      {replace={"dirt-violet", "dirt-dustyrose", "dirt-black"}, with="dirt-purple"},
      {replace={"dirt-brown", "dirt-red", "dirt-beige", "dirt-grey", "dirt-white"}, with="dirt-cream"},
      {replace={"sand-purple", "sand-violet", "sand-dustyrose", "sand-black"}, with="sand-cream"},
      {replace={"sand-brown", "sand-red", "sand-beige", "sand-grey", "sand-white"}, with="sand-aubergine"},
      {replace={"all-volcanic"}, with="volcanic-blue"}
    }
  },
  {name="Porcyka", patron = "Lost Hamster", tags={"temperature_temperate", "enemy_none", "water_low", "moisture_med", "aux_very_low", "trees_low"},
    primary_resource="se-iridium-ore",
  },
  {name="Cootiepuss", patron = "SMuffatti", tags={"water_high", "moisture_high", "aux_med", "temperature_warm", "enemy_very_high"},
    primary_resource="se-vitamelange",
    biome_replacements={
      {replace={"all-vegetation"}, with="vegetation-orange"},
      {replace={"all-sand"}, with="sand-tan"},
      {replace={"all-dirt"}, with="dirt-tan"},
      {replace={"all-volcanic"}, with="volcanic-orange"}
    }
  },
  {name="Zirbs", patron = "Zirbs"},
  {name="Raven", patron = "Ravish", tags={"water_none", "moisture_none", "aux_very_high", "temperature_wild", "trees_max", "cliff_max", "enemy_med"},
    primary_resource="crude-oil",
    biome_replacements={
      {replace={"all-vegetation"}, with="vegetation-blue"},
      {replace={"all-sand"}, with="sand-black"},
      {replace={"all-dirt"}, with="dirt-black"},
      {replace={"all-volcanic"}, with="volcanic-blue"}
    }
  },
  {name="Xynariz", patron = "Xynariz", tags={"water_low", "enemy_very_high", "moisture_low", "aux_high", "temperature_extreme", "trees_med", "cliff_low", "enemy_max"},
    primary_resource="kr-rare-metal-ore", -- ?
    radius_multiplier = 0.8, --big
    biome_replacements={ -- violet, purple, aubergine, mauve, turquoise.
      {replace={"vegetation-green"}, with="vegetation-turquoise"},
      {replace={"vegetation-olive"}, with="vegetation-blue"},
      {replace={"vegetation-yellow"}, with="vegetation-mauve"},
      {replace={"vegetation-orange"}, with="vegetation-purple"},
      {replace={"vegetation-red"}, with="vegetation-violet"},
      {replace={"vegetation-red"}, with="vegetation-violet"},
      {replace={"sand-red", "sand-brown", "sand-dustyrose"}, with="sand-violet"},
      {replace={"sand-beige", "sand-cream", "sand-white"}, with="sand-purple"},
      {replace={"sand-brown", "sand-tan", "sand-black", "sand-grey"}, with="sand-aubergine"},
      {replace={"dirt-red", "dirt-brown", "dirt-dustyrose"}, with="dirt-violet"},
      {replace={"dirt-beige", "dirt-cream", "dirt-white"}, with="dirt-purple"},
      {replace={"dirt-brown", "dirt-tan", "dirt-black", "dirt-grey"}, with="dirt-aubergine"},
      {replace={"volcanic-orange"}, with="volcanic-blue"}
    }
  },
  {name="Irilea", patron = "Iliurgul", tags={"temperature_balanced", "enemy_very_high", "water_low", "moisture_max", "aux_med", "trees_high", "cliff_med"},
    primary_resource="se-vitamelange",
  },
  {name="Arcanis", patron = "KMack413", tags={"temperature_warm", "enemy_low", "water_med", "moisture_max", "aux_low", "trees_med"},
    primary_resource="crude-oil",
  }, -- should have a ruin.
  {name="Lendiana", patron = "Polish Deathcare", tags={"temperature_temperate", "enemy_low", "water_high", "moisture_med", "aux_med", "trees_med"},
    primary_resource="uranium-ore",
  }, -- should have a ruin.
  {name="Coniferous", patron = "Coniferous", tags={"temperature_temperate", "enemy_low", "water_high", "moisture_high", "aux_low", "trees_high"},
    primary_resource="se-vitamelange",
  },
  {name="Mirage", patron = "Shylo132", tags={"temperature_wild", "enemy_low", "water_med", "moisture_med", "aux_very_high", "trees_med"},
    primary_resource="iron-ore",
    preset_resource_bias={["uranium-ore"] = 0.03, ["crude-oil"] = 0.02, ["coal"] = 0.01},
    biome_replacements={ -- yellow, purple, green,
      {replace={"all-vegetation", "dirt-purple", "dirt-violet", "dirt-red", "dirt-brown", "dirt-tan", "dirt-dustyrose", "dirt-beige", "dirt-cream", "dirt-black", "dirt-grey", "dirt-white", "dirt-aubergine"}, with="vegetation-blue"},
      {replace={"sand-purple", "sand-violet", "sand-red", "sand-brown"}, with="sand-black"},
      {replace={"sand-tan", "sand-dustyrose", "sand-beige", "sand-cream", "sand-grey", "sand-aubergine"}, with="sand-white"},
      {replace={"all-volcanic"}, with="volcanic-blue"}
    }
  },
  {name="Noveria", patron = "Luckay", tags={"temperature_frozen", "enemy_high", "water_high", "moisture_high", "aux_very_high", "trees_low"}, primary_resource="se-beryllium-ore", preset_resource_bias={["crude-oil"] = 0.99}},
  {name="Vorlon", patron = "SirVorlon", tags={"temperature_midrange", "enemy_none", "water_med", "moisture_med", "aux_med", "trees_low"}, primary_resource="se-iridium-ore",
    biome_replacements={ -- yellow, purple, green,
      {replace={"vegetation-blue", "dirt-cream" }, with="vegetation-yellow"},
      {replace={"vegetation-red" }, with="vegetation-olive"},
      {replace={"vegetation-orange", "all-frozen"}, with="vegetation-violet"},
      {replace={"vegetation-turquoise", }, with="vegetation-purple"},
      {replace={"dirt-violet", "dirt-brown", "dirt-red"}, with="dirt-purple"},
      {replace={"dirt-beige", "dirt-black", "dirt-grey", "dirt-white", "dirt-dustyrose"}, with="dirt-tan"},
      {replace={"sand-brown"}, with="sand-aubergine"},
      {replace={"sand-violet", "sand-black", "sand-red"}, with="sand-purple"},
      {replace={"sand-beige", "sand-grey", "sand-white", "sand-dustyrose"}, with="sand-tan"},
      {replace={"all-volcanic"}, with="volcanic-purple"} }
  },
  {name="Marquardt", patron = "Andree", tags={"temperature_frozen", "enemy_med", "water_med", "moisture_low", "aux_very_low", "trees_none"}, primary_resource="stone"},
  {name="Tarn", patron = "Tarn", tags={"temperature_cold", "enemy_low", "water_med", "moisture_low", "aux_high", "trees_low"}, primary_resource="se-cryonite"},
  {name="Ketobar", patron = "Valanna", tags={"temperature_temperate", "enemy_none", "water_none", "moisture_high", "aux_low", "trees_low"}, primary_resource="se-iridium-ore"},
  {name="Horaerratum", patron = "slipsec", tags={"temperature_extreme", "enemy_low", "water_low", "moisture_max", "aux_very_high", "trees_max"},
    primary_resource="se-vitamelange", preset_resource_bias={["se-cryonite"] = 0.99, ["se-vulcanite"] = 0.98}},
  {name="Katalos", patron = "PeterHan5", tags={"temperature_extreme", "enemy_max", "water_med", "moisture_max", "aux_low", "moisture_high", "cliff_low", "trees_med"},
    primary_resource="se-beryllium-ore", preset_resource_bias={["se-cryonite"] = 0.99, ["se-vulcanite"] = 0.98, ["iron-ore"] = 0.02, ["stone"] = 0.01},
    biome_replacements={ -- yellow, purple, green,
      {replace={"vegetation-violet", "vegetation-purple", "vegetation-mauve", "vegetation-blue"}, with="vegetation-green"},
      {replace={"dirt-violet", "dirt-purple", "dirt-aubergine"}, with="dirt-brown"},
      {replace={"sand-violet", "sand-purple", "sand-aubergine"}, with="sand-brown"},
      {replace={"volcanic-purple", "volcanic-blue"}, with="volcanic-orange"} }
  },
  {name="Drakkett", patron = "Drakkett", tags={"temperature_frozen", "enemy_low", "water_low", "aux_very_high", "trees_low"}, primary_resource="se-cryonite"},
  {name="Xiada", patron = "CrushedIce", tags={"temperature_cold", "enemy_med", "water_med", "moisture_high", "aux_med", "trees_high"}, primary_resource="se-vitamelange", preset_resource_bias={["crude-oil"] = 0.99},
    biome_replacements={
      {replace={"all-dirt"}, with="volcanic-blue"},
      {replace={"all-sand"}, with="sand-black"},
      {replace={"all-vegetation"}, with="vegetation-blue"},
      {replace={"all-volcanic"}, with="volcanic-blue"} } },
  {name="Sparky", patron = "Sparky", tags={"temperature_temperate", "enemy_very_low", "water_high", "moisture_max", "aux_very_low", "trees_high"}, primary_resource="se-holmium-ore", preset_resource_bias={["uranium-ore"] = 0.99}},
  --radiation/wind: very very high
  --secondary resource: uranium
  --weather: perpetual thunderstorm (or as close as possible)
  {name="Trelos", patron = "madman", tags={"temperature_frozen", "enemy_med", "water_med", "moisture_high", "aux_very_low", "trees_med"}, primary_resource="crude-oil"},
  {name="Sandro", patron = "Sandro", tags={"temperature_hot", "water_none", "moisture_none", "aux_high", "trees_none"}, primary_resource="iron-ore",
    biome_replacements={-- red black orange
      {replace={"all-dirt"}, with="dirt-red"},
      {replace={"all-sand"}, with="sand-red"},
      {replace={"all-frozen"}, with="sand-black"},
      {replace={"all-vegetation"}, with="vegetation-red"},
      {replace={"all-volcanic"}, with="volcanic-orange"} } },
  {name="Neenuvar", patron = "Neenuvar", tags={"temperature_cool", "water_high", "moisture_max", "aux_high", "trees_max"}},
  {name="Kamsta", patron = "Kamsta", tags={"temperature_cool", "water_med", "moisture_high", "aux_high", "trees_high"}, primary_resource="iron-ore",
    biome_replacements={
      {replace={"all-dirt"}, with="dirt-purple"},
      {replace={"all-sand"}, with="sand-purple"},
      {replace={"all-vegetation"}, with="vegetation-purple"},
      {replace={"all-volcanic"}, with="volcanic-purple"} } },
  {name="Jasbury"},
  {name="Atropos"},
  {name="Mormo"},
  {name="Viken"},
  {name="Katar"},
  {name="Liko"},
  {name="Plato"},
  {name="Talos"},
  {name="Capritos"},
  {name="Yaegner"},
  {name="Gigei"},
  {name="Kujaku"},
  {name="Aciszar"},
  {name="Toxinora", tags={"temperature_vhot", "aux_high", "water_high"}, primary_resource="crude-oil"},
  {name="Hestia"},
  {name="Avorion"},
  {name="Mercutio"},
  {name="Elolis"},
  {name="Horkos"},
  {name="Riven", tags={"enemy_none"}},
  {name="Techne"},
  {name="Bomore"},
  {name="Prabhava"},
  {name="Anemoi"},
  {name="Ismene"},
  {name="Owleye", tags={"enemy_none"}},
  {name="Theia"},
  {name="Isabella"},
  {name="Thanatos"},
  {name="Nechrophos"},
  {name="Morpheus"},
  {name="Eleusis"},
  {name="Nike"},
  {name="Pollus"},
  {name="Hadrian"},
  {name="Meleager"},
  {name="Sapperious"},
  {name="Arkazious"},
  {name="Hyratel"},
  {name="Atonoy"},
  {name="Dafdee"},
  {name="Bordoli"},
  {name="Dinotress"},
  {name="Helburn"},
  {name="Horae"},
  {name="Hybris"},
  {name="Fodius"},
  {name="Petra"},
  {name="Zafis"},
  {name="Kerel"},
  {name="Claustry"},
  {name="Anson"},
  {name="Reaver", tags={"enemy_max"}},
  {name="Arae"},
  {name="Magaera"},
  {name="Dagon", tags={"enemy_high"}},
  {name="Glasties"},
  {name="Phoebe"},
  {name="Vestrian"},
  {name="Rovecutio"},
  {name="Hexagee"},
  {name="Unilix"},
  {name="Eirene", tags={"enemy_none"}},
  {name="Rouk"},
  {name="Rupel"},
  {name="Dyton"},
  {name="Miranda"},
  {name="Aghanim"},
  {name="Octarine"},
  {name="Veden"},
  {name="Mireska"},
  {name="Tarrasque"},
  {name="Parth"},
  {name="Jenova"},
  {name="Lich", tags={"temperature_frozen"}},
  {name="Farangis", tags={"temperature_cool", "moisture_high", "aux_low", "trees_med"}},
  {name="Pelorum"},
  {name="Hera"},
  {name="Vyse"},
  {name="Argenta"},
  {name="Rooftrellen", tags={"temperature_warm", "moisture_high", "aux_low", "trees_med"}}, -- : Forest
  {name="Avez"},
  {name="Theoden"},
  {name="Nookryme"},
  {name="Lyralei"},
  {name="Agon"},
  {name="Eshone"},
  {name="Rolium"},
  {name="Exorrion"},
  {name="Sage"},
  {name="Persophone"},
  {name="Hemera"},
  {name="Shashi"},
  {name="Skadi", tags={"temperature_frozen", "enemy_high"}},-- : Ice World
  {name="Geryon"},
  {name="Juliette"},
  {name="Dolos"},
  {name="Druanga"},
  {name="Aquila", tags={"water_max", "temperature_warm", "aux_low", "moisture_max", "trees_max"}}, -- : Water world
  {name="Krobelus", tags={"temperature_extreme", "aux_high", "trees_low"}},
  {name="Neuranto"},
  {name="Trostaurus", tags={"temperature_extreme", "aux_high", "trees_low"}}, -- : Hot and cold
  {name="Lothar"},
  {name="Styx", tags={"water_high", "temperature_cool"}}, -- : Water
  {name="Sooten", tags={"water_low", "temperature_vhot", "trees_high", "aux_low", "moisture_med"}, primary_resource="iron-ore"},
  {name="Karura"},
  {name="Magi"},
  {name="Momus"},
  {name="Chronos"},
  {name="Ganymede", tags={"enemy_none"}},
  {name="Gerhaift"},
  {name="Heinlein"},
  {name="Chrodon"},
  {name="Ettenor", tags={"water_low", "moisture_high", "trees_max", "aux_low", "temperature_bland"}}, -- has a rich oil near the landing site. and is a forest planet
  {name="Numrah"},
  {name="Snagle"},
  {name="Noventede"},
  {name="Minos"},
  {name="Amebris"},
  {name="Lath"},
  {name="Haka"},
  {name="Adul"},
  {name="Lethe"},
  {name="Furion", tags={"temperature_hot"}}, -- : Hot
  {name="Alfonso"},
  {name="Bandoch"},
  {name="Daedelus"},
  {name="Acheron"},
  {name="Minoa"},
  {name="Angelos"},
  {name="Tartarus"},
  {name="Whittier"},
  {name="Ethoria"},
  {name="Acisrind"},
  {name="Rokenharr"},
  {name="Haze"},
  {name="Vekars"},
  {name="Kitsune", tags={"water_low", "moisture_high", "trees_max", "aux_high", "temperature_bland"}},
  {name="Pentto"},
  {name="Enigma"},
  {name="Tycho"},
  {name="Aporia"},
  {name="Orphne"},
  {name="Gearofen"},
  {name="Akasha"},
  {name="Sofurna"},
  {name="Hermes"},
  {name="Swoxter"},
  {name="Manta"},
  {name="Zion"},
  {name="Oneiros"},
  {name="Nexus"},
  {name="Jelt"},
  {name="Kratos", tags={"temperature_volcanic"}, primary_resource="iron-ore"},
  {name="Claymore"},
  {name="Avakis", tags={"temperature_warm", "water_none", "moisture_none", "trees_low", "enemy_med"}, primary_resource="coal"}, -- : Dune
  {name="Shara"},
  {name="Oeris"},
  {name="Tresdin"},
  {name="Hedone"},
  {name="Lilac"},
  {name="Tango", tags={"temperature_warm", "water_high", "moisture_high", "trees_high"}, primary_resource="crude-oil"},
  {name="Dolentea"},
  {name="Apate"},
  {name="Warrus"},
  {name="Esenudreus"},
  {name="Joenus"},
  {name="Narsus"},
  {name="Weylop"},
  {name="Warlock"},
  {name="Tieneo"},
  {name="Znok"},
  {name="Rinoto"},
  {name="Azure", tags={"temperature_hot", "aux_high"}, primary_resource="crude-oil"},
  {name="Zakhol"},
  {name="Ashura"},
  {name="Krubidium"},
  {name="Silverhorn"},
  {name="Alecto"},
  {name="Osis", tags={"water_high", "moisture_low", "temperature_warm"}}, -- Endless water (and fish): Land is very rare.
  {name="Morus"},
  {name="Selemaenae"},
  {name="Empha"},
  {name="Midas"},
  {name="Akerty"},
  {name="Lotuslana", tags={"aux_high", "water_max", "temperature_cool", "moisture_max", "trees_max"}}, -- : Water
  {name="Spiriso"},
  {name="Imbrium"},
  {name="Quillion"},
  {name="Alba"},
  {name="Zendia"},
  {name="Linken"},
  {name="Konan"},
  {name="Tolubai"},
  {name="Magmin"},
  {name="Sange", tags={"water_low", "temperature_hot", "aux_med", "trees_low", "moisture_none"}, primary_resource="copper-ore"},
  {name="Dionysus"},
  {name="Bishamonten"},
  {name="Bunkle"},
  {name="Memnon"},
  {name="Nomos"},
  {name="Kokytos"},
  {name="Crixalis"}, -- : Dune
  {name="Andragora"},
  {name="Ryuo"},
  {name="Rivos"}, -- : River planet
  {name="Constance"},
  {name="Stromhurst"},
  {name="Feaora"},
  {name="Paquin"},
  {name="Heechgata"},
  {name="Mercurial"},
  {name="Hyperion"},
  {name="Xandra"},
  {name="Delune"},
  {name="Adalind"},
  {name="Vioress"},
  {name="Crean"},
  {name="Alban"},
  {name="Lamia"},
  {name="Kaya"},
  {name="Heliolyte"},
  {name="Tanzan", tags={"aux_high", "temperature_cool", "trees_high", "moisture_high"}, primary_resource="crude-oil"}, --  Endless Oil: Purple forests. losts of water
  {name="Jakiro", tags={"temperature_extreme", "aux_low"}}, -- : Fire and Ice
  {name="Juno", tags={"aux_high"}},
  {name="Vobis"},
  {name="Corsol"},
  {name="Elezar"},
  {name="Lamplika", tags={"aux_high"}}, -- : Red
  {name="Taras"},
  {name="Atengam"},
  {name="Tentei"},
  {name="Shellabby"},
  {name="Ezra"},
  {name="Persephone", tags={"aux_high", "water_high", "moisture_high", "trees_med"}},
  {name="Chiron"},
  {name="Neevus"},
  {name="Rampart"},
  {name="Hades", tags={"moisture_low", "trees_low", "aux_low"}, primary_resource="coal"},
  {name="Santo"},
  {name="Abyssal"},
  {name="Deurus"},
  {name="Koskomino"},
  {name="Hypnos"},
  {name="Moirai"},
  {name="Selene", tags={"enemy_none"}},
  {name="Zed"},
  {name="Tisiphone"},
  {name="Thrasos"},
  {name="Beaumont"},
  {name="Indarl"},
  {name="Kerkon"},
  {name="Rhadaman"},
  {name="Verbena"},
  {name="Benthai"},
  {name="Boros"},
  {name="Aizen"},
  {name="Galvania"},
  {name="Prism"},
  {name="Berky"},
  {name="Tenou"},
  {name="Aeolus"},
  {name="Faerie", tags={"water_high", "temperature_cool", "moisture_high", "aux_high", "trees_max"}, primary_resource="crude-oil"}, -- : Forest
  {name="Ophion"},
  {name="Mobius"},
  {name="Peitho"},
  {name="Greenleaf", tags={"water_low", "temperature_cool", "moisture_high", "aux_low", "trees_max"}, primary_resource="coal"}, -- : Forest
  {name="Vesper", tags={"trees_med", "moisture_med", "temperature_hot"}, primary_resource="crude-oil"},
  {name="Rubik"},
  {name="Riza"},
  {name="Geive"},
  {name="Palto"},
  {name="Alke"},
  {name="Elysium"},
  {name="Eaglesong", tags={"water_med", "temperature_temperate", "moisture_high", "aux_low", "trees_high"}, primary_resource="coal"}, -- : Forest
  {name="Daryun"},
  {name="Achilles"},
  {name="Brion"},
  {name="Grilla"},
  {name="Ermintrude"},
  {name="Naden"},
  {name="Evadome"},
  {name="Amechania"},
  {name="Antaeus"},
  {name="Ender"},
  {name="Demeter", tags={"enemy_none"}},
  {name="Athina"},
  {name="Caerus"},
  {name="Witfalla"},
  {name="Starfury"},
  {name="Muir"},
  {name="Jeroen"},
  {name="Ourea"},
  {name="Jespur"},
  {name="Jetenury"},
  {name="Manelscot"},
  {name="Marmo", tags={"temperature_cold", "moisture_none", "water_none", "aux_med"},
    biome_replacements={-- Has red deserts and snow (mars) and a small deserted mining base.
      {replace={"all-dirt"}, with="dirt-dustyrose"},
      {replace={"all-sand"}, with="sand-dustyrose"},
      {replace={"all-vegetation"}, with="sand-dustyrose"},
      {replace={"all-volcanic"}, with="volcanic-orange"} } },
  {name="Emiir", tags={"water_med", "temperature_cold", "moisture_high", "aux_low", "trees_high"}, primary_resource="crude-oil"}, -- : Forest
  {name="Castor"},
  {name="Petussia"},
  {name="Androgun"},
  {name="Chimera"},
  {name="Semiele"},
  {name="Lyssa"},
  {name="Jetnova"},
  {name="Soma"},
  {name="Beylix"},
  {name="Rylai"},
  {name="Eulstave"},
  {name="Liono"},
  {name="Infernox"},
  {name="Paulara"},
  {name="Algea"},
  {name="Gapleon"},
  {name="Tetracat"},
  {name="Alastor"},
  {name="Bolina"},
  {name="Penium"},
  {name="Shiva", tags={"temperature_frozen"}, primary_resource="iron-ore"}, -- : Ice World
  {name="Arturius"},
  {name="Traxex", tags={"temperature_cold", "moisture_none", "water_low", "trees_none"}}, -- black
  {name="Itnora"},
  {name="Luxitania"},
  {name="Taishakuten"},
  {name="Bloodthorn", tags={"aux_high"}}, -- : Red
  {name="Amadeo"},
  {name="Plenai"},
  {name="Koma"},
  {name="Ishmere"},
  {name="Criopta"},
  {name="Thalassa"},
  {name="Thoon"},
  {name="Ozwulf"},
  {name="Thule"},
  {name="Vietera"},
  {name="Kunkri"},
  {name="Aion"},
  {name="Kael"},
  {name="Ixion"},
  {name="Metapilla"},
  {name="Mavarix"},
  {name="Voxnova"},
  {name="Karik"},
  {name="Sturata"},
  {name="Bernadette"},
  {name="Legogene"},
  {name="Ecludies"},
  {name="Abaddon"},
  {name="Miturion"},
  {name="Gorgyra"},
  {name="Cinrad"},
  {name="Orion"},
  {name="Kendapoa", tags={"enemy_none"}},
  {name="Spatha"},
  {name="Indigo", tags={"temperature_cold", "aux_high"}, primary_resource="iron-ore"}, -- : Endless iron, Blue forest, snow, grey desert
  {name="Corus"},
  {name="Harmonia"},
  {name="Arkoth", tags={"temperature_cold", "aux_low"}, primary_resource="coal"}, -- is a snow wasteland with rich coal near the landing site
  {name="Bromwinkle"},
  {name="Nikara"},
  {name="Ajax"},
  {name="Kaliphos"},
  {name="Mordiggian"},
  {name="Kuyou"},
  {name="Exavier"},
  {name="Zauber"},
  {name="Cerberus"},
  {name="Manearth"},
  {name="Umbra"},
  {name="Ranolin"},
  {name="Slithice", tags={"water_high", "temperature_vcold"}},-- : water and Ice World
  {name="Cadmus"},
  {name="Adikia"},
  {name="Perodome"},
  {name="Geras"},
  {name="Typhon"},
  {name="Termina"},
  {name="Oliran"},
  {name="Deadrim"},
  {name="Hyrean", tags={"water_max", "temperature_warm", "moisture_med"}}, -- is 100% ocean
  {name="Gorgon", tags={"water_low", "temperature_balanced", "trees_med"}, primary_resource="uranium-ore",
    biome_replacements={-- : Endless uranium, and black landscape yellow and green forest and plains
      {replace={"all-dirt"}, with="dirt-black"},
      {replace={"all-sand"}, with="sand-black"},
      {replace={"vegetation-mauve", "vegetation-blue", "vegetation-turquoise"}, with="vegetation-green"},
      {replace={"vegetation-violet", "vegetation-purple"}, with="vegetation-olive"},
      {replace={"vegetation-orange", "vegetation-red"}, with="vegetation-yellow"},
      {replace={"all-volcanic"}, with="volcanic-green"} } },
  {name="Chrothurn"},
  {name="Sladeshon"},
  {name="Nonagaz"},
  {name="Sihnon"},
  {name="Bombato"},
  {name="Mordred"},
  {name="Jiangyin"},
  {name="Akkolon"},
  {name="Alfrind"},
  {name="Sworn"},
  {name="Hexen"},
  {name="Falconsabre"},
  {name="Roma"},
  {name="Ganus"},
  {name="Aiakos"},
  {name="Ourus"},
  {name="Deadwood", tags={"water_med", "temperature_wild", "moisture_med", "aux_low", "trees_med"}, primary_resource="coal"},
  {name="Windlace", tags={"temperature_cold", "aux_med", "enemy_none"}},
  {name="Aberdon", tags={"water_high"}},-- : water
  {name="Kara"},
  {name="Koolimon"},
  {name="Rutadam"},
  {name="Pandion"},
  {name="Shinzo"},
  {name="Anax"},
  {name="Hecate"},
  {name="Rumba"},
  {name="Zomble", tags={"water_med", "temperature_hot", "moisture_med", "aux_med", "trees_low"},
    biome_replacements={-- orange and purple
        {replace={"dirt-red", "dirt-dustyrose", "dirt-beige"}, with="dirt-brown"},
        {replace={"dirt-violet", "dirt-cream", "dirt-grey", "dirt-white"}, with="dirt-aubergine"},
        {replace={"sand-red", "sand-dustyrose", "sand-beige"}, with="sand-brown"},
        {replace={"sand-violet", "sand-cream", "sand-grey", "sand-white"}, with="sand-aubergine"},
        {replace={"vegetation-yellow", "vegetation-red", "vegetation-olive", "vegetation-green" }, with="vegetation-orange"},
        {replace={"vegetation-violet", "vegetation-mauve", "vegetation-blue", "vegetation-turquoise" }, with="vegetation-purple"},
        {replace={"volcanic-green"}, with="volcanic-orange"},
        {replace={"volcanic-blue"}, with="volcanic-purple"} } },
  {name="Atos"},
  {name="Throix", tags={"temperature_volcanic"}}, -- : Green lava
  {name="Zelos", tags={"aux_high"}},
  {name="Razor", primary_resource="iron-ore"},
  {name="Mythulu"},
  {name="Katski"},
  {name="Morgana"},
  {name="Ester"},
  {name="Vares"},
  {name="Balanar"},
  {name="Impetus"},
  {name="Soteria"},
  {name="Arislan", tags={"temperature_temperate", "moisture_high", "aux_low"}},
  {name="Tintavis"},
  {name="Melione"},
  {name="Clotho"},
  {name="Aidos"},
  {name="Vexo"},
  {name="Sakimi"},
  {name="Stijio", tags={"temperature_wild", "aux_low"}},
  {name="Regina"},
  {name="Erinyes"},
  {name="Lynx"},
  {name="Wyvern"},
  {name="Nestor"},
  {name="Noctis", tags={"temperature_cool", "moisture_none"}}, -- : black
  {name="Osiris"},
  {name="Ariel"},
  {name="Erebos"},
  {name="Alessandro"},
  {name="Gelos"},
  {name="Yasha"},
  {name="Empusa"},
  {name="Esluna"},
  {name="Hermione"},
  {name="Orpheus"},
  {name="Limos"},
  {name="Karas"},
  {name="Nissaria"},
  {name="Harmonette"},
  {name="Piccard", tags={"aux_low", "trees_low"}},
  {name="Redril", tags={"aux_high"}}, -- red
  {name="Avernus", tags={"temperature_vcold", "aux_high"}},
  {name="Infamani"},
  {name="Perseus"},
  {name="Loliento"},
  {name="Elpis"},
  {name="Tyche"},
  {name="Whinstone"},
  {name="Budkai"},
  {name="Phanto"},
  {name="Toucan"},
  {name="Demios"},
}

UniverseRaw.prototypes_by_name = {}
for _, proto_zone_group in pairs({
  UniverseRaw.universe.stars,
  UniverseRaw.universe.space_zones,
  {UniverseRaw.universe.anomaly},
  UniverseRaw.unassigned_planets,
  UniverseRaw.unassigned_moons,
  UniverseRaw.unassigned_planets_or_moons,
  UniverseRaw.haven_moons,
  UniverseRaw.vulcanite_planets,
  UniverseRaw.cryonite_moons,
  UniverseRaw.iridium_moons,
  UniverseRaw.holmium_moons,
  UniverseRaw.vitamelange_moons,
}) do
  for _, proto_zone in pairs(proto_zone_group) do
    if UniverseRaw.prototypes_by_name[proto_zone.name] then
      error(proto_zone.name.." is defined twice")
    end
    UniverseRaw.prototypes_by_name[proto_zone.name] = proto_zone
  end
end

return UniverseRaw
