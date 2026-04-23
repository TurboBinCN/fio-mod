if settings.startup["priyutils-tinyenergyshield"].value then 
    for _, energyshield in pairs(data.raw["energy-shield-equipment"]) do
        energyshield.shape = {width = 1, height = 1, type = "full"}
	end
end
if settings.startup["priyutils-tinysolarpanel"].value then
  	for _, solarpanelequipment in pairs(data.raw["solar-panel-equipment"]) do
        solarpanelequipment.shape = {width = 1, height = 1, type = "full"}
	end
end
if settings.startup["priyutils-tinyreactor"].value then  
  	for _, reactorequipment in pairs(data.raw["generator-equipment"]) do
        reactorequipment.shape = {width = 1, height = 1, type = "full"}
	end
end
if settings.startup["priyutils-tinybattery"].value then  
  	for _, batteryequipment in pairs(data.raw["battery-equipment"]) do
        batteryequipment.shape = {width = 1, height = 1, type = "full"}
	end
end
if settings.startup["priyutils-tinyroboport"].value then  
  	for _, roboportequipment in pairs(data.raw["roboport-equipment"]) do
        roboportequipment.shape = {width = 1, height = 1, type = "full"}
	end
end
if settings.startup["priyutils-tinynightvision"].value then  
  	for _, nightvisionequipment in pairs(data.raw["night-vision-equipment"]) do
        nightvisionequipment.shape = {width = 1, height = 1, type = "full"}
	end
end
if settings.startup["priyutils-tinyexoskeleton"].value then  
  	for _, exoskeletonequipment in pairs(data.raw["movement-bonus-equipment"]) do
        exoskeletonequipment.shape = {width = 1, height = 1, type = "full"}
	end
end
if settings.startup["priyutils-tinyactivedefense"].value then  
  	for _, activedefenseequipment in pairs(data.raw["active-defense-equipment"]) do
	activedefenseequipment.shape = {width = 1, height = 1, type = "full"}
	end
end