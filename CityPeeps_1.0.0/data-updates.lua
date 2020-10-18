if (settings.startup["k2cp-use-workers"].value) then
	-- Insert farmers in k2cp-crops category
	for _, recipe in pairs(data.raw["recipe"]) do
		if (recipe.category == "k2cp-crops") then
			table.insert(recipe.ingredients,{"k2cp-farmer", 1})
		end
	end

	-- Insert workers and scientists
	for _, recipe in pairs(data.raw["recipe"]) do
		if not (string.find(recipe.name, "pack")) then
			if not (recipe.category == "crafting-with-fluid" or recipe.category == "smelting" or recipe.category == "k2cp-crops" or recipe.category == "k2cp-school") then
				--log("Recipe Name: "..recipe.name)
				if (recipe.category == "centrifuging" or recipe.category == "chemistry" or recipe.category == "rocket-building") then
					if (recipe.ingredients) then
						table.insert(recipe.ingredients,{"k2cp-scientist", 1})
					elseif (recipe.normal) then
						table.insert(recipe.normal.ingredients,{"k2cp-scientist", 1})
						if (recipe.expensive) then table.insert(recipe.expensive.ingredients,{"k2cp-scientist", 2}) end
					end
				else
					if (recipe.ingredients) then
						if not (recipe.name == "k2cp-village" or recipe.name == "k2cp-schoolhouse" or recipe.name == "k2cp-field" or
						        recipe.name == "k2cp-bread" or recipe.name == "k2cp-glass" or recipe.name == "k2cp-warehouse" ) then
							table.insert(recipe.ingredients,{"k2cp-worker", 1})
						end
					elseif (recipe.normal) then
						table.insert(recipe.normal.ingredients,{"k2cp-worker", 1})
						if (recipe.expensive) then table.insert(recipe.expensive.ingredients,{"k2cp-worker", 2}) end
					end	
				end
			end
		end
	end

	-- Insert scientists
	table.insert(data.raw["recipe"]["automation-science-pack"].ingredients		,{"k2cp-scientist", 1})
	table.insert(data.raw["recipe"]["logistic-science-pack"].ingredients  		,{"k2cp-scientist", 1})
	table.insert(data.raw["recipe"]["military-science-pack"].ingredients		,{"k2cp-scientist", 1})
	table.insert(data.raw["recipe"]["chemical-science-pack"].ingredients		,{"k2cp-scientist", 1})
	table.insert(data.raw["recipe"]["production-science-pack"].ingredients		,{"k2cp-scientist", 1})
	table.insert(data.raw["recipe"]["utility-science-pack"].ingredients			,{"k2cp-scientist", 1})

	-- Expand ingredient count in assemblers
	for _, entity in pairs(data.raw["assembling-machine"]) do
		entity.ingredient_count = 10
	end

	if (settings.startup["k2cp-research-scientists"].value) then
		for _, tech in pairs(data.raw["technology"]) do
			local i = tech.unit.ingredients
			if (i) then	table.insert(i,{"k2cp-scientist", 1}) end
		end
		-- Expand ingredient count in labs
		for _, entity in pairs(data.raw["lab"]) do
			local e = entity.inputs
			table.insert(e, "k2cp-scientist")
		end
	end	
else
	data.raw["recipe"]["k2cp-village"].enabled = false
	data.raw["recipe"]["k2cp-warehouse"].enabled = false
	data.raw["recipe"]["k2cp-schoolhouse"].enabled = false
	data.raw["recipe"]["k2cp-farmer"].enabled = false
	data.raw["recipe"]["k2cp-worker"].enabled = false
	data.raw["recipe"]["k2cp-scientist"].enabled = false
end