local RecipeTints = {}

-- Chemical facility (vanilla)
-- - primary: liquid inside the plant
-- - secondary: secondary shade of the liquid inside the plant
-- - tertiary: outer part of the smoke coming out
-- - quaternary: inner part of the smoke coming out

-- Biochem facility:
-- - primary: big bubbly tube in the top left
-- - secondary: liquid in piston bottom right, second small tube on the left
-- - tertiary: liquid in piston bottom left
-- - quaternary: dome top right, third small tube on the left

RecipeTints.bio_sludge_tint = {
  primary = {r = 151.0/255.0, g = 255.0/255.0, b = 87.0/255.0, a = 1.0}, -- #47732bff
  secondary = {r = 151.0/255.0, g = 255.0/255.0, b = 87.0/255.0, a = 1.0}, -- #47732bff
  tertiary = {r = 155.0/255.0, g = 73.0/255.0, b = 255.0/255.0, a = 1.0}, --#994affff
  quaternary = {r = 155.0/255.0, g = 73.0/255.0, b = 255.0/255.0, a = 1.0}, --#994affff
}

RecipeTints.nutrient_tint = {
  primary = {r = 207.0/255.0, g = 83.0/255.0, b = 147.0/255.0, a = 1.0}, -- #cf5393
  secondary = {r = 244.0/255.0, g = 128.0/255.0, b = 255.0/255.0, a = 1.0}, -- #f480ffff
  tertiary = {r=1, g=0.4, b=0, a = 0.8},  -- Chemical gel
  quaternary = {r = 151.0/255.0, g = 255.0/255.0, b = 87.0/255.0, a = 1.0}, -- #47732bff
}

RecipeTints.nutrient_vat_tint = {
  primary = {r = 255.0/255.0, g = 70.0/255.0, b = 110.0/255.0, a = 1.0}, -- #ff466e
  secondary = {r = 244.0/255.0, g = 128.0/255.0, b = 255.0/255.0, a = 1.0}, -- #f480ffff
  tertiary = {r = 207.0/255.0, g = 83.0/255.0, b = 147.0/255.0, a = 1.0}, -- #cf5393
  quaternary = {r = 207.0/255.0, g = 83.0/255.0, b = 147.0/255.0, a = 1.0}, -- #cf5393
}

RecipeTints.oil_to_petrol_tint = {
  primary = {r = 155.0/255.0, g = 73.0/255.0, b = 255.0/255.0, a = 1.0}, --#994affff
  secondary = {r = 155.0/255.0, g = 73.0/255.0, b = 255.0/255.0, a = 1.0}, --#994affff
  tertiary = {r = 127.0/255.0, g = 75.0/255.0, b = 156.0/255.0, a = 1.0}, -- #7f4b9cff
  quaternary = {r = 127.0/255.0, g = 75.0/255.0, b = 156.0/255.0, a = 1.0}, -- #7f4b9cff
}

RecipeTints.oil_to_light_tint = {
  primary = {r = 155.0/255.0, g = 73.0/255.0, b = 255.0/255.0, a = 1.0}, --#994affff
  secondary = {r = 155.0/255.0, g = 73.0/255.0, b = 255.0/255.0, a = 1.0}, --#994affff
  tertiary = {r = 0.895, g = 0.773, b = 0.596, a = 1.000}, -- #e4c597ff
  quaternary = {r = 1.000, g = 0.734, b = 0.290, a = 1.000}, -- #ffbb49ff
}

RecipeTints.oil_to_heavy_tint = {
  primary = {r = 155.0/255.0, g = 73.0/255.0, b = 255.0/255.0, a = 1.0}, --#994affff
  secondary = {r = 155.0/255.0, g = 73.0/255.0, b = 255.0/255.0, a = 1.0}, --#994affff
  tertiary = {r = 0.854, g = 0.659, b = 0.576, a = 1.000}, -- #d9a892ff
  quaternary = {r = 1.000, g = 0.494, b = 0.271, a = 1.000}, -- #ff7e45ff
}

RecipeTints.coal_to_petrol_tint = {
  primary = {r = 1.000, g = 0.735, b = 0.643, a = 1.000}, -- #ffbba4ff
  secondary = {r = 0.749, g = 0.557, b = 0.490, a = 1.000}, -- #bf8e7dff
  tertiary = {r = 127.0/255.0, g = 75.0/255.0, b = 156.0/255.0, a = 1.0}, -- #7f4b9cff
  quaternary = {r = 127.0/255.0, g = 75.0/255.0, b = 156.0/255.0, a = 1.0}, -- #7f4b9cff
}

RecipeTints.chemical_gel_tint = {
  -- primary = {r=255/255, g=132/255, b=45/255, a = 1},  -- Chemical gel
  primary = {r=1, g=0.4, b=0, a = 0.8},  -- Chemical gel
  secondary = {r = 0.3, g = 0.1, b = 0.3, a = 1}, -- Petrol
  tertiary = {r = 0, g = 0.34, b = 0.6, a = 1}, -- Water
  quaternary = {r=1, g=0.4, b=0, a = 0.8},  -- Chemical gel
}

RecipeTints.water_tint = {
  primary = {r = 0, g = 0.34, b = 0.6, a = 1}, -- Water
  secondary = {r = 0.4, g = 0.5, b = 0.6, a = 1}, -- Water/Steam
  tertiary = {r = 1, g = 1, b = 1, a = 0.1}, -- Steam
  quaternary = {r = 0.5 , g = 0.5, b = 0.5, a = 0.1}, -- Steam (alt)
}

RecipeTints.vita_tint = {
  primary = {
    a = 1,
    r = 0.482,
    b = 0.338,
    g = 0.965338
  },
  quaternary = {
    a = 1,
    r = 0.763,
    b = 0.191,
    g = 0.939
  },
  secondary = {
    a = 1,
    r = 0.560,
    b = 0.222,
    g = 0.831
  },
  tertiary = {
    a = 1,
    r = 0.728,
    b = 0.443,
    g = 0.818,
  }
}

RecipeTints.vita_centri_tint = {
  primary = {r = 0.28, g = 0.4, b = 0, a = 1}
}

RecipeTints.beryllium_tint = {
  primary = { r = 0.338, g = 0.965, b = 0.482, a = 1.000 },
  quaternary = { r = 0.191, g = 0.939, b = 0.763, a = 1.000},
  secondary = { r = 0.222, g = 0.831, b = 0.56, a = 1.000},
  tertiary = { r = 0.443, g = 0.818, b = 0.728, a = 1.000}
}

RecipeTints.holmium_tint = {
  primary = {
    a = 1,
    g = 0.338,
    b = 0.482,
    r = 0.965
  },
  quaternary = {
    a = 1,
    g = 0.191,
    b = 0.763,
    r = 0.939
  },
  secondary = {
    a = 1,
    g = 0.222,
    b = 0.560,
    r = 0.831
  },
  tertiary = {
    a = 1,
    g = 0.443,
    b = 0.728,
    r = 0.818,
  }
}

RecipeTints.iridium_tint = {
  primary = {r = 1.000, g = 0.958, b = 0.000, a = 1.000}, -- #fff400ff
  secondary = {r = 1.000, g = 0.852, b = 0.172, a = 1.000}, -- #ffd92bff
  tertiary = {r = 0.876, g = 0.869, b = 0.597, a = 1.000}, -- #dfdd98ff
  quaternary = {r = 0.969, g = 1.000, b = 0.019, a = 1.000}, -- #f7ff04ff
}

RecipeTints.iridium_centri_tint = {
  primary = {r = 1, g = 1, b = 0.2, a = 1}
}

RecipeTints.naq_tint = {
  primary = {
    a = 1,
    g = 0.338,
    r = 0.482,
    b = 0.965
  },
  quaternary = {
    a = 1,
    g = 0.191,
    r = 0.763,
    b = 0.939
  },
  secondary = {
    a = 1,
    g = 0.222,
    r = 0.560,
    b = 0.831
  },
  tertiary = {
    a = 1,
    g = 0.443,
    r = 0.728,
    b = 0.818,
  }
}

RecipeTints.naq_centri_tint = {
  primary = {r = 0.3, g = 0.1, b = 1, a = 1}
}

RecipeTints.cryonite_tint = {
  primary = {
    a = 1,
    r = 0.338,
    g = 0.482,
    b = 0.965
  },
  quaternary = {
    a = 1,
    r = 0.191,
    g = 0.763,
    b = 0.939
  },
  secondary = {
    a = 1,
    r = 0.222,
    g = 0.560,
    b = 0.831
  },
  tertiary = {
    a = 1,
    r = 0.443,
    g = 0.728,
    b = 0.818,
  }
}

RecipeTints.vulcanite_tint = {
  primary = {
    a = 1,
    r = 0.965,
    g = 0.482,
    b = 0.338
  },
  quaternary = {
    a = 1,
    r = 0.939,
    g = 0.763,
    b = 0.191,
  },
  secondary = {
    a = 1,
    r = 0.560,
    g = 0.831,
    b = 0.222,
  },
  tertiary = {
    a = 1,
    r = 0.728,
    g = 0.818,
    b = 0.443,
  }
}


RecipeTints.pyroflux_tint = {
  primary = {r=0.725, g=0, b=0},
  secondary = {r=0.725, g=0.3, b=0.1},
  tertiary = {r=1, g=0, b=0, a=0.1},
  quaternary = {r=1, g=1, b=0, a=1},
}

RecipeTints.vulcanite_centri_tint = {
  primary = {r = 1, g = 0.1, b = 0, a = 1}
}

RecipeTints.methane_tint = {
  primary = {r = 1.000, g = 0.735, b = 0.643, a = 1.000}, -- #ffbba4ff
  secondary = {r = 0.749, g = 0.557, b = 0.490, a = 1.000}, -- #bf8e7dff
  tertiary = {r = 0.785, g = 0.660, b = 0.660, a = 1.000}, -- #c9a9a9ff
  quaternary = {r = 0.527, g = 0.460, b = 0.460, a = 1.000}, -- #877676ff
}

return RecipeTints
