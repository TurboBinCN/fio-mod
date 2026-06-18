-- add all fluids which we can barrel
for name, fluid in pairs(data.raw["fluid"]) do
  if not (fluid.auto_barrel == false) then
    se_delivery_cannon_recipes[name] = {name=name.."-barrel"}
  end
end
