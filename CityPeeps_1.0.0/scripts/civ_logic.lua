-----------------------------------------------------------------------------------------
-- Civ Class - container for all high level mod variables pertaining to the civilization
-----------------------------------------------------------------------------------------
Civ = {}

function Civ:init()
	self.state = {
		     update_interval = math.floor(GAMEDAY
		  * settings.startup["k2cp-update-interval"].value)             	, -- Time between city updates
		       max_districts = settings.startup["k2cp-max-districts"].value	, -- Max housing districts per city
		                vcpc = settings.startup["k2cp-cpc"].value			, -- Village citizens per cycle
		passenger_multiplier = config.passenger_multiplier                	, -- Passenger multipler
		   passenger_divisor = config.passenger_divisor	  				  	, -- Districs divided by this = passengers per cycle
		  student_multiplier = config.student_multiplier                  	, -- Passenger multipler
		     student_divisor = config.student_divisor	  					, -- Districs divided by this = students per cycle
		             revenue = config.starting_revenue	  					, -- Revenue per passenger delivered
		               tiers = config.tiers                               	, -- Status tiers and resultant status description
		            upgrades = config.upgrades							  	, -- Upgrades table
		       village_needs = config.village_needs                     	, -- Items needed to increase village growth rate
		          city_needs = config.city_needs                           	, -- Items needed to increase city household count
		    city_needs_count = 1								          	, -- Count of needed city items for the GUI
		        status_title = "-"                                        	, -- Status title from tiers array - based on score
		       status_renown = "-"                                        	, -- Status renown from tiers array - based on score
		               score = 0                                          	, -- Civilzation score - determines title and renown
		             tier_id = 0									      	, -- Current tier ID
		           next_tier = 0									      	, -- Next tier score for advancement
		                days = 0                                          	, -- Number of days that have passed in this game
		           districts = 0                                          	, -- Total districts in civ
		             exports = 0                                          	, -- Number of trade goods exported to the galaxy
		          passengers = 0									      	, -- Passengers transported to resorts for your civ
		             credits = 0						     		      	, -- Credit balance
		       academy_count = 0                                          	, -- Count of academies - tracks academies array
		           academies = {}                                         	, -- Array of instantiated city objects
		          city_count = 0                                          	, -- Count of cities - tracks cities array
		              cities = {}                                         	, -- Array of instantiated city objects
		       village_count = 0                                          	, -- Count of villages - tracks villages array
		            villages = {}                                         	, -- Array of instantiated village objects
		          city_count = 0                                          	, -- Count of cities - tracks cities array
		             resorts = {}                                         	, -- Array of instantiated resort objects
		        resort_count = 0                                          	, -- Count of resorts - tracks resorts array
		                hubs = {}                                         	, -- Array of instantiated tradehub objects
			 upgrade_tracker = {}											, -- Tracks which upgrades have been applied to which entities
			    upgrade_flag = false										, -- Flag that keeps the upgrade replace from executing on_mined logic
				        guis = {}											, -- Manage each player's GUI
	}

	-- Add in any "needs" crates selected in mod settings
	if (settings.startup["k2cp-require-crate-house"].value   ) then table.insert(self.state.city_needs,"k2cp-crate-house")    self.state.city_needs_count = self.state.city_needs_count + 1 end
	if (settings.startup["k2cp-require-crate-energy"].value  ) then table.insert(self.state.city_needs,"k2cp-crate-energy")   self.state.city_needs_count = self.state.city_needs_count + 1 end
	if (settings.startup["k2cp-require-crate-school"].value  ) then table.insert(self.state.city_needs,"k2cp-crate-school")   self.state.city_needs_count = self.state.city_needs_count + 1 end
	if (settings.startup["k2cp-require-crate-military"].value) then table.insert(self.state.city_needs,"k2cp-crate-military") self.state.city_needs_count = self.state.city_needs_count + 1 end
	if (settings.startup["k2cp-require-crate-medical"].value ) then table.insert(self.state.city_needs,"k2cp-crate-medical")  self.state.city_needs_count = self.state.city_needs_count + 1 end
	if (settings.startup["k2cp-require-crate-pleasure"].value) then table.insert(self.state.city_needs,"k2cp-crate-pleasure") self.state.city_needs_count = self.state.city_needs_count + 1 end
	
	global.civ_state = self.state
end

function Civ:load()
	if global.civ_state ~= nil then
		self.state = global.civ_state
		for _, academy in pairs(self.state.academies) do
			setmetatable(academy, {__index = Academy})
		end
		for _, village in pairs(self.state.villages) do
			setmetatable(village, {__index = Village})
		end
		for _, city in pairs(self.state.cities) do
			setmetatable(city, {__index = City})
		end
		for _, hub in pairs(self.state.hubs) do
			setmetatable(hub, {__index = Hub})
		end
		for _, resort in pairs(self.state.resorts) do
			setmetatable(resort, {__index = Resort})
		end
		for _, gui in pairs(self.state.guis) do
			setmetatable(gui, {__index = Gui})
		end
		if global.actions then
			script.on_event(defines.events.on_tick, on_tick)
		end
	end
end

function Civ:player_joined(event)
	local player = game.players[event.player_index]
	if not (player and player.valid) then return end
	-- If citypeeps gui doesn't exist, add it
	if not (player.gui.top and player.gui.top.k2cp_main_table) then 
		local new_gui = Gui:new()
		new_gui:init_gui(event)
		table.insert(self.state.guis, new_gui)
	end
	-- Sync it up
	for _, gui in ipairs(self.state.guis) do
		if (gui.state.player_index == event.player_index) then
			gui:update_civ_gui()
			gui.state.city_frame.clear()
			for _, city in ipairs(self.state.cities) do
				gui:add_city_gui_dtl(city.state.index)
				gui:update_city_dtl(city)
			end
			gui:remove_upgrade_dtl(self)
		end
	end
end

function Civ:assist_player(event)
	if (settings.startup["k2cp-assist-mode"].value) then
		local player = game.players[event.player_index]
		if not (player and player.valid) then return end
		--/unlock-shortcut-bar

		-- Used primarily for play testing
		local box = game.surfaces[1].create_entity{name="steel-chest", position={x = 1, y = 0}, force=player.force}
		box.insert({name="iron-plate", count=400})
		box.insert({name="copper-plate", count=200})
		box.insert({name="wood", count=400})
		box.insert({name="stone", count=400})
		box.insert({name="steel-plate", count=200})
		box.insert({name="k2cp-leather", count=400})
		box.insert({name="k2cp-city", count=10})
		box.insert({name="k2cp-academy", count=20})
		box.insert({name="k2cp-tradehub", count=1})
		box.insert({name="k2cp-datacenter", count=1})
		box.insert({name="k2cp-resort", count=2})
		box.insert({name="k2cp-student", count=4})
		box.insert({name="k2cp-passenger", count=4})
		box.insert({name="k2cp-officer-1", count=2})
		box.insert({name="k2cp-crate-meals", count=4000})
		box.insert({name="k2cp-datacron", count=20000})
		box.insert({name="k2cp-coin", count=4000})
		box.insert({name="locomotive", count=2})
		box.insert({name="k2cp-passenger-wagon", count=1})
		box.insert({name="k2cp-student-wagon", count=1})
		box.insert({name="rail", count=100})
		box.insert({name="train-stop", count=2})
		self.state.credits = 10000
		
		box.insert({name="k2cp-field", count=2})
		box.insert({name="k2cp-village", count=2})
		box.insert({name="k2cp-warehouse", count=2})
		box.insert({name="k2cp-schoolhouse", count=6})
		box.insert({name="k2cp-citizen", count=200})
		box.insert({name="k2cp-farmer", count=200})

		player.print("CityPeeps Assist On")
	end
end

function Civ:tick(event)
	if event.tick % GAMEDAY == 0 then
		self.state.days = self.state.days + 1
	end

	if event.tick % 250 == 0 then
		-- Process villages
		for index, village in ipairs(self.state.villages) do
			if (village.state.entity.valid) then
				village:update(self.state.village_needs)
			else
				table.remove(self.state.villages, index)
			end
		end
	end

	if event.tick % self.state.update_interval == 0 then

		-- Process cities and calculate household growth
		local districts = 0
		for index, city in ipairs(self.state.cities) do
			if (city.state.entity.valid) then
				city:update(self.state.city_needs)
				districts = districts + city.state.districts
				for _, gui in ipairs(self.state.guis) do
					gui:update_city_dtl(city)
				end
			else
				-- If the city entity is invalid (probably destroyed) remove the detail gui and array element.
				for _, gui in ipairs(self.state.guis) do
					gui:remove_city_dtl(city.state.index)
				end
				table.remove(self.state.cities, index)
			end
		end
		self.state.districts = districts

		-- Process academies
		for index, academy in ipairs(self.state.academies) do
			if (academy.state.entity.valid) then
				-- no updates for academies - only tracked for upgrade purposes
			else
				table.remove(self.state.academies, index)
			end
		end

		-- Process resorts
		if (self.state.student_multiplier > 0) then
			for index, resort in ipairs(self.state.resorts) do
				if (resort.state.entity.valid) then
					resort:update()
					self.state.passengers = self.state.passengers + resort.state.passengers
					self.state.credits = self.state.credits + resort.state.credits
				else
					table.remove(self.state.resorts, index)
				end
			end
		end

		-- Process tradehubs and calculate exports
		for index, hub in ipairs(self.state.hubs) do
			if (hub.state.entity.valid) then
				hub:update()
				self.state.exports = self.state.exports + hub.state.exports
			else
				table.remove(self.state.hubs, index)
			end
		end

		-- Calculate overall score and resultant title/renown
		self.state.score = math.floor(self.state.exports / 10) + self.state.districts + self.state.passengers
		for _, tier in ipairs(self.state.tiers) do
			if (self.state.score >= tier.score) then
				if (self.state.tier_id < tier.id) then
					local message = tier.msg
					for _, player in pairs(game.players) do
						if (tier.reward_type == "i") then player.get_main_inventory().insert(tier.reward) end
						if (tier.reward_type == "r") then player.force.recipes[tier.reward].enabled = true end
						player.print(message)
					end
					-- In case they skip over any of these tiers in one update cycle - force recipes enabled
					if (game.players[1].force.recipes["k2cp-datacron"].enabled    == false and tier.score >= config.tiers[4].score) then game.players[1].force.recipes["k2cp-datacron"].enabled    = true end
					if (game.players[1].force.recipes["k2cp-promotion-1"].enabled == false and tier.score >= config.tiers[3].score) then game.players[1].force.recipes["k2cp-promotion-1"].enabled = true end
					if (game.players[1].force.recipes["k2cp-promotion-2"].enabled == false and tier.score >= config.tiers[2].score) then game.players[1].force.recipes["k2cp-promotion-2"].enabled = true end
				end
				self.state.tier_id = tier.id
				self.state.status_title = tier.title
				self.state.status_renown = tier.renown
				break
			end
		end

		-- Display next "promotion" score
		for _, next_tier in ipairs(self.state.tiers) do
			if (next_tier.id - 1 == self.state.tier_id) then
				self.state.next_tier = next_tier.score
				break
			end
		end

		-- Update the main gui
		for _, gui in ipairs(self.state.guis) do
			gui:update_civ_gui()
		end
	end
end

function Civ:entity_built(event)
	-- performance bypass - only execute for k2cp entities
	if string.sub(event.created_entity.name,1,4) ~= "k2cp" then return end  

	-- Force a reselection of the available upgrade options
	for _, gui in ipairs(self.state.guis) do
		gui:remove_upgrade_dtl()
	end

    local entity = event.created_entity
	if entity.name == "k2cp-village" then
		self.state.village_count = self.state.village_count + 1
		local new_village = Village:new()
		new_village:init(self.state.village_count, self.state.vcpc, entity)
		table.insert(self.state.villages, new_village)
	elseif entity.name == "k2cp-city" then
		-- Check if another city is too close, else place the city
		local distance = settings.startup["k2cp-city-distance"].value
		if (Civ:tile_limit(entity,distance) > 1) then
			local item = entity.name
			local player = game.players[event.player_index]
			local inventory = player.get_main_inventory()
			inventory.insert({name = item, count = 1})
			inventory.sort_and_merge()
			entity.destroy()
			player.print({"message.k2cp-city-limit", distance})
		else
			self.state.city_count = self.state.city_count + 1
			local new_city = City:new()
			new_city:init(self.state.city_count
						, "k2cp-city"
			            , entity
						, self.state.max_districts
						, self.state.passenger_divisor
						, self.state.passenger_multiplier
						, self.state.student_divisor
						, self.state.student_multiplier)
			table.insert(self.state.cities, new_city)
			for _, gui in ipairs(self.state.guis) do
				gui:add_city_gui_dtl(self.state.city_count)
			end
			Civ:upgrade_tracking("add", new_city)
		end
	elseif entity.name == "k2cp-resort" then
		local distance = settings.startup["k2cp-resort-distance"].value
		if (Civ:tile_limit(entity,distance) > 0) then
			local item = entity.name
			local player = game.players[event.player_index]
			local inventory = player.get_main_inventory()
			inventory.insert({name = item, count = 1})
			inventory.sort_and_merge()
			entity.destroy()
			player.print({"message.k2cp-resort-limit", distance})
		else
			self.state.resort_count = self.state.resort_count + 1
			local new_resort = Resort:new()
			new_resort:init(self.state.resort_count, "k2cp-resort", entity, self.state.revenue)
			table.insert(self.state.resorts, new_resort)
			Civ:upgrade_tracking("add", new_resort)
		end
	elseif entity.name == "k2cp-tradehub" then
		local new_hub = Hub:new()
		new_hub:init(entity)
		table.insert(self.state.hubs, new_hub)
	elseif entity.name == "k2cp-academy" then
		self.state.academy_count = self.state.academy_count + 1
		local new_a = Academy:new()
		new_a:init(self.state.academy_count, "k2cp-academy", entity)
		table.insert(self.state.academies,  new_a)
		Civ:upgrade_tracking("add", new_a)
	elseif (string.sub(entity.name,1,20) == "k2cp-passenger-wagon") then
		local inventory = entity.get_inventory(defines.inventory.cargo_wagon)
		if (inventory) then
			for i=1, inventory.count_empty_stacks(true), 1 do
				inventory.set_filter(i,"k2cp-passenger")
			end
		end
	elseif (string.sub(entity.name,1,18) == "k2cp-student-wagon") then
		local inventory = entity.get_inventory(defines.inventory.cargo_wagon)
		if (inventory) then
			for i=1, inventory.count_empty_stacks(true), 1 do
				inventory.set_filter(i,"k2cp-student")
			end
		end
	end
end

-- Remove entities from their respective arrays when mined.
function Civ:entity_mined(event)
	-- Performance bypass - only execute for k2cp entities
	if string.sub(event.entity.name,1,4) ~= "k2cp" then return end  

	-- Force a reselection of the available upgrade options
	for _, gui in ipairs(self.state.guis) do
		gui:remove_upgrade_dtl()
	end
	
	-- Bypass the array removal if the entity is mined do to the upgrade 'replace' process
	if self.state.upgrade_flag then self.state.upgrade_flag = false return end  

	-- If an entity is mined by the player or robots, remove it from the array and refresh the gui
	-- If you change the city minable variable to true, then add city check here
	local entity = event.entity
	if (string.sub(entity.name,1,9) == "k2cp-village") then
		for index, village in ipairs(self.state.villages) do
			if (village.state.entity.unit_number == entity.unit_number) then
				table.remove(self.state.villages, index)
				return
			end
		end
	elseif (string.sub(entity.name,1,9) == "k2cp-city") then
		for index, city in ipairs(self.state.cities) do
			if (city.state.entity.unit_number == entity.unit_number) then
				Civ:upgrade_tracking("remove", city)
				table.remove(self.state.cities, index)
				for _, gui in ipairs(self.state.guis) do
					gui:remove_city_dtl(city.state.index)
				end
				if (#self.state.cities == 0) then self.state.city_count = 0 end
				return
			end
		end
	elseif (string.sub(entity.name,1,11) == "k2cp-resort") then
		for index, resort in ipairs(self.state.resorts) do
			if (resort.state.entity.unit_number == entity.unit_number) then
				Civ:upgrade_tracking("remove", resort)
				table.remove(self.state.resorts, index)
				return
			end
		end
	elseif (string.sub(entity.name,1,13) == "k2cp-tradehub") then
		for index, hub in ipairs(self.state.hubs) do
			if (hub.state.entity.unit_number == entity.unit_number) then
				table.remove(self.state.hubs, index)
				return
			end
		end
	elseif (string.sub(entity.name,1,12) == "k2cp-academy") then
		for index, academy in ipairs(self.state.academies) do
			if (academy.state.entity.unit_number == entity.unit_number) then
				Civ:upgrade_tracking("remove", academy)
				table.remove(self.state.academies, index)
				return
			end
		end
	end	
end

function Civ:tile_limit(entity, r)
	return entity.surface.count_entities_filtered({name={"k2cp-city"}, position=entity.position, radius=r})
end

function Civ:transfer_credits(player, action, amount)
	local inventory = player.get_main_inventory()
	if (action == "d") then
		local coin_count = inventory.get_item_count("k2cp-coin")
		if (coin_count >= amount) then
			inventory.remove{name="k2cp-coin", count=amount}
			self.state.credits = self.state.credits + amount
			player.print({"message.k2cp-transfer-success", amount})
			for _, gui in ipairs(self.state.guis) do gui:update_civ_gui() end
		else
			player.print({"message.k2cp-transfer-insf", amount})
		end
	end
	if (action == "w") then
		if (self.state.credits >= amount) then
			inventory.insert({name = "k2cp-coin", count = amount})
			self.state.credits = self.state.credits - amount
			player.print({"message.k2cp-transfer-success", amount})
			for _, gui in ipairs(self.state.guis) do gui:update_civ_gui() end
		else
			player.print({"message.k2cp-transfer-insf", amount})
		end
	end
end

function Civ:update_interval(amount)
	Civ.state.update_interval = amount
	for _, gui in ipairs(self.state.guis) do gui:update_civ_gui() end
end

-- Maintain master list of available upgrades
function Civ:upgrade_tracking(action, obj, track_id)
	-- If no counter exists in the tracker, add it once
	if (self.state.upgrade_tracker.count == nil) then self.state.upgrade_tracker.count = 1 end

	-- Called from on_entity_built, add the upgrade options for each entity added
	if (action == "add") then
		for _, upgrade in ipairs(self.state.upgrades) do
			if (upgrade.name == obj.state.internal_name) then
				local u = {}
				u.object = obj
				u.options = {}
				for index, opt in ipairs(upgrade.options) do
					local option = {
						track_id = self.state.upgrade_tracker.count,
						option = opt,
					}
					table.insert(u.options, option)
					self.state.upgrade_tracker.count = self.state.upgrade_tracker.count + 1
				end
				table.insert(self.state.upgrade_tracker, u)
			end
		end
	end

	-- Action "remove" is sent from the entity_mined and should remove entity level
	if (action == "remove") then
		local temp = {}
		for _, upgrade in ipairs(self.state.upgrade_tracker) do
			if not (upgrade.object.state.internal_name == obj.state.internal_name and upgrade.object.state.index == obj.state.index) then
				table.insert(temp, upgrade)
			end
		end
		self.state.upgrade_tracker = temp
	end
	
	-- Action "remove_opt" is sent after an upgrade is applied an should remove only that option from the entity
	if (action == "remove_opt") then
		local temp = {}
		for _, upgrade in ipairs(self.state.upgrade_tracker) do
			if (upgrade.object.state.internal_name == obj.state.internal_name and upgrade.object.state.index == obj.state.index) then
				local opt_count = 0
				local new_upgrade = upgrade
				local new_options = {}
				for _, option in ipairs(upgrade.options) do
					if not (option.track_id == track_id) then
						opt_count = opt_count + 1
						table.insert(new_options, option)
					end
				end
				if (opt_count > 0) then
					new_upgrade.options = new_options
					table.insert(temp, new_upgrade)
				end
			else
				table.insert(temp, upgrade)
			end
		end
		self.state.upgrade_tracker = temp
	end
end

function Civ:upgrade_object(player, name, i, t)
	local old_object	= ""
	local new_object	= ""
	local option		= ""
	local index			= tonumber(i)
	local track_id		= tonumber(t)

	for _, u in ipairs(self.state.upgrade_tracker) do
		if (u.object.state.internal_name == name and u.object.state.index == index) then
			old_object = u.object
			for _, o in ipairs(u.options) do
				if (o.track_id == track_id) then
					option = o.option
					new_object = o.option.object
					break
				end
			end
			break
		end
	end

	-- Process the option selected
	local upgrade_state = "none"
	if (option) then
		if (option.cost > self.state.credits) then 
			upgrade_state = "cost"
		else
			if (option.type == "a") then
				if (old_object) then
					old_object.state[option.attr] = old_object.state[option.attr] + option.add_value
					self.state.credits = self.state.credits - option.cost
					for _, gui in ipairs(self.state.guis) do
						gui:update_civ_gui()
					end
					Civ:upgrade_tracking("remove_opt", old_object, track_id)
					upgrade_state = "success"
				end
			elseif option.type == "e" then
				if (old_object.state.entity.valid) then
					self.state.upgrade_flag = true
					local new_entity = old_object.state.entity.surface.create_entity
						{ name=new_object
						, target=old_object.state.entity
						, position=old_object.state.entity.position
						, direction=old_object.state.entity.direction
						, force=old_object.state.entity.force
						, fast_replace=true
						, player=player
						, raise_built=false
						, create_build_effect_smoke=false
						, spawn_decorations=false
						}
					self.state.upgrade_flag = false
					old_object.state.entity = new_entity
					local inventory = player.get_main_inventory()
					inventory.remove({name = name, count = 1})
					self.state.credits = self.state.credits - option.cost
					for _, gui in ipairs(self.state.guis) do
						gui:update_civ_gui()
					end
					Civ:upgrade_tracking("remove_opt", old_object, track_id)
					upgrade_state = "success"
				end
			end
		end
	end

	-- Create the message label
	for _, gui in ipairs(self.state.guis) do
		gui:upgrade_msg(upgrade_state, option.cost)
	end
end

function Civ:on_gui_click(event)
	if (string.sub(event.element.name, 1, 4) ~= "k2cp") then return end

	for _, gui in ipairs(self.state.guis) do
		if (gui.state.player_index == event.player_index) then
			gui.on_click(gui, event)
		end
	end
end

function Civ:debug(s)
	--log(serpent.block(table))
	for _, player in pairs(game.players) do
		if (config.debug) then player.print(s)	end
	end
end
