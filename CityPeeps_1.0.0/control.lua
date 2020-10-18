GAMEDAY = 25000

config = require("config")
require("scripts.civ_logic")
require("scripts.gui_logic")
require("scripts.village_logic")
require("scripts.city_logic")
require("scripts.academy_logic")
require("scripts.hub_logic")
require("scripts.resort_logic")

function on_mod_init(event)
    Civ:init()
end

function on_mod_load(event)
	Civ:load()
end

function on_configuration_changed()
end

function on_player_created(event)
	Civ:assist_player(event)
end

function on_player_joined_game(event)
	Civ:player_joined(event)
end

function on_tick(event)
	Civ:tick(event)
end

function on_gui_click(event)
	Civ:on_gui_click(event)
end

function on_built_entity(event)
	Civ:entity_built(event)
end

function on_mined_entity(event)
	Civ:entity_mined(event)
end

script.on_init(on_mod_init)
script.on_load(on_mod_load)
script.on_configuration_changed(on_configuration_changed)
script.on_event(defines.events.on_player_created, on_player_created)
script.on_event(defines.events.on_player_joined_game, on_player_joined_game)
script.on_event(defines.events.on_tick, on_tick)
script.on_event(defines.events.on_gui_click, on_gui_click)
script.on_event(defines.events.on_built_entity, on_built_entity)
script.on_event(defines.events.on_robot_built_entity, on_built_entity)
script.on_event(defines.events.on_player_mined_entity, on_mined_entity)
script.on_event(defines.events.on_robot_mined_entity, on_mined_entity)