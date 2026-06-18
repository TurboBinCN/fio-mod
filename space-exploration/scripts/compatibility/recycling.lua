-- goes over the prototypes to make sure the quality related things make sense,
-- mainly for recycling recipes but also houses checks for which recipes allow quality.

-- local function check_recipe(recipe)
--   if recipe.hidden then return end
--   if recipe.parameter then return end

--   assert(#recipe.products > 0)
--   local only_has_fluid_products = true

--   for _, product in ipairs(recipe.products) do
--     if product.type ~= "fluid" then
--       only_has_fluid_products = false
--     end
--   end

--   if only_has_fluid_products and (recipe.allowed_effects and recipe.allowed_effects["quality"]) then
--     log(string.format("recipe creating only fluids supports quality: %s > %s", recipe.name, prototypes.get_history(recipe.type, recipe.name).created))
--   end
-- end

-- for _, recipe in pairs(prototypes.get_recipe_filtered{{filter = "has-product-fluid"}}) do
--   check_recipe(recipe)
-- end
