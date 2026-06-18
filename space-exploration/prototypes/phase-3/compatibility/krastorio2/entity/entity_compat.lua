local path = "prototypes/phase-3/compatibility/krastorio2/entity/"

--require(path .. "logistics")
if data.raw["logistic-robot"]["logistic-robot"] then
    data.raw["logistic-robot"]["logistic-robot"].speed = 0.05
    data.raw["logistic-robot"]["logistic-robot"].max_energy = "1.5MJ"
    data.raw["logistic-robot"]["logistic-robot"].max_health = 100
    data.raw["logistic-robot"]["logistic-robot"].max_payload_size = 1
end

if data.raw["construction-robot"]["construction-robot"] then
    data.raw["construction-robot"]["construction-robot"].speed = 0.06
    data.raw["construction-robot"]["construction-robot"].max_energy = "1.5MJ"
    data.raw["construction-robot"]["construction-robot"].max_health = 100
    data.raw["construction-robot"]["construction-robot"].max_payload_size = 1
end

--require(path .. "power")

-- Account for Heat Capacity Change of water for the Steam Engine and Boiler
data.raw["generator"]["steam-engine"].fluid_usage_per_tick = (((1/6)*3) + ((1/6)/3))/2



--require(path .. "resources")
local function restrict_mining(tech_name, ore_name, effect_desc)
    local restriction_data = data.raw["mod-data"]["kr-resource-restrictions"]
    restriction_data.data[tech_name] = {ore_name}
    table.insert(
        data.raw.technology[tech_name].effects,
        {type = "nothing", effect_description = effect_desc}
    )
end

restrict_mining("se-processing-vulcanite", "se-vulcanite", {"technology-effect-description.se-kr-vulcanite-mining"})
restrict_mining("se-processing-cryonite", "se-cryonite", {"technology-effect-description.se-kr-cryonite-mining"})
restrict_mining("se-processing-beryllium", "se-beryllium-ore", {"technology-effect-description.se-kr-beryllium-mining"})
restrict_mining("se-processing-holmium", "se-holmium-ore", {"technology-effect-description.se-kr-holmium-mining"})
restrict_mining("se-processing-iridium", "se-iridium-ore", {"technology-effect-description.se-kr-iridium-mining"})
restrict_mining("se-processing-vitamelange", "se-vitamelange", {"technology-effect-description.se-kr-vitamelange-mining"})
restrict_mining("se-processing-naquium", "se-naquium-ore", {"technology-effect-description.se-kr-naquium-mining"})
