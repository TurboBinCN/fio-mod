local AbandonedRuins = {}
function AbandonedRuins.exclude_surfaces()
  if remote.interfaces["AbandonedRuins"] and remote.interfaces["AbandonedRuins"]["exclude_surface"] then
    remote.call("AbandonedRuins", "exclude_surface", "Vault")
    remote.call("AbandonedRuins", "exclude_surface", "spaceship")
    remote.call("AbandonedRuins", "exclude_surface", "Asteroid")
    remote.call("AbandonedRuins", "exclude_surface", "Orbit")
    remote.call("AbandonedRuins", "exclude_surface", "Foenestra") -- Note orbits, asteroid fields, etc should already be handled.
    for _, space_zone in pairs(UniverseRaw.universe.space_zones) do
      remote.call("AbandonedRuins", "exclude_surface", space_zone.name)
    end
  end
end
return AbandonedRuins
