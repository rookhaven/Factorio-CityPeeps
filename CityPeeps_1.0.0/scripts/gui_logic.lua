------------------------------------------------------------------------
-- Gui class - manages gui for each player
------------------------------------------------------------------------
Gui = {}

function Gui:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end
	
function Gui:init_gui(event)
	local player=game.players[event.player_index]
	if not (player and player.valid) then return end

	self.state = {
		player_index		= event.player_index,
		player				= player,

		-- Cached frames/flows
		main_frame			= nil,
		dtl_frame			= nil,
		civ_frame			= nil,
		city_frame			= nil,
		credit_frame		= nil,
		upgrade_frame		= nil,
		upgrade_dtl_flow	= nil,
								 
		-- Cached labels
		day_label        	= nil,
		districts_label  	= nil,
		exports_label    	= nil,
		status_label     	= nil,
		renown_label     	= nil,
		score_label      	= nil,
		next_tier_label  	= nil,
		credits_label    	= nil,
		passenger_label  	= nil,
		credit_textbox   	= nil,
		interval_textbox 	= nil,
	}

	-- Master Button and Day Counter
	local k2cp_main_table=self.state.player.gui.top.add{type="table", name="k2cp_main_table", style="cp_title_table", column_count=3}
	      k2cp_main_table.add{type="sprite-button", name="k2cp_dtl_toggle", sprite="item/k2cp-resort", tooltip={"tooltip.k2cp-main-title"}}
	      k2cp_main_table.add{type="label", caption={"caption.k2cp-day"}, style="frame_title"}
	      k2cp_main_table.add{type="label", name="k2cp_day", caption="0", style="frame_title"}

	-- Detail Frame
	local k2cp_dtl_frame=self.state.player.gui.screen.add{type="frame", name="k2cp_dtl_frame", visible=false, direction="vertical", style="frame_with_even_paddings"}
		  k2cp_dtl_frame.force_auto_center()
	local k2cp_title_flow=k2cp_dtl_frame.add{type="flow", name="k2cp_title_flow", }
	local k2cp_title_label=k2cp_title_flow.add{type="label", caption={"caption.k2cp-title"}, style="frame_title"}
	      k2cp_title_label.drag_target=k2cp_dtl_frame
	local k2cp_widget=k2cp_title_flow.add{type="empty-widget", name="k2cp_widget", style="draggable_space_header"}
	      k2cp_widget.style.vertically_stretchable=true
		  k2cp_widget.style.horizontally_stretchable=true
		  k2cp_widget.drag_target=k2cp_dtl_frame
	      k2cp_title_flow.add{type="sprite-button", style="frame_action_button", sprite="utility/close_white", name="k2cp_dtl_close"}

	-- Civilization Frame
	local k2cp_civ_frame=k2cp_dtl_frame.add{type="frame", name="k2cp_civ_frame", direction="vertical", style="inside_deep_frame_for_tabs"}
 		  k2cp_civ_frame.style.width = 540
	local k2cp_civ_topflow=k2cp_civ_frame.add{type="flow", name="k2cp_civ_topflow", style="cp_horizontal_flow_style"}
	      k2cp_civ_topflow.add{type="sprite", sprite="globe_sprite"}
	local k2cp_civ_table=k2cp_civ_topflow.add{type="table", name="k2cp_civ_table", style="cp_table_style", column_count=4}
	      k2cp_civ_table.add{type="label",                    caption={"caption.k2cp-status"},     style="cp_label_right_style",  tooltip={"tooltip.k2cp-status-desc"}}
	      k2cp_civ_table.add{type="label", name="status",     caption="",                          style="cp_label_left_style",   tooltip={"tooltip.k2cp-status-desc"}}
	      k2cp_civ_table.add{type="label",                    caption={"caption.k2cp-renown"},     style="cp_label_right_style",  tooltip={"tooltip.k2cp-status-desc"}}
	      k2cp_civ_table.add{type="label", name="renown",     caption="",                          style="cp_label_left_style",   tooltip={"tooltip.k2cp-status-desc"}}
	      k2cp_civ_table.add{type="label",                    caption={"caption.k2cp-score"},      style="cp_label_right_style",  tooltip={"tooltip.k2cp-score-desc"}}
	      k2cp_civ_table.add{type="label", name="score",      caption="0",                         style="cp_label_left_style",   tooltip={"tooltip.k2cp-score-desc"}}
	      k2cp_civ_table.add{type="label",                    caption={"caption.k2cp-next-tier"},  style="cp_label_right_style",  tooltip={"tooltip.k2cp-next-tier-desc"}}
	      k2cp_civ_table.add{type="label", name="next_tier",  caption="",                          style="cp_label_left_style",   tooltip={"tooltip.k2cp-next-tier-desc"}}
	      k2cp_civ_table.add{type="label",                    caption={"caption.k2cp-exports"},    style="cp_label_right_style",  tooltip={"tooltip.k2cp-exports-desc"}}
	      k2cp_civ_table.add{type="label", name="exports",    caption="0",                         style="cp_label_left_style",   tooltip={"tooltip.k2cp-exports-desc"}}
	      k2cp_civ_table.add{type="label",                    caption={"caption.k2cp-households"}, style="cp_label_right_style",  tooltip={"tooltip.k2cp-total-housholds-desc"}}
	      k2cp_civ_table.add{type="label", name="households", caption="0",                         style="cp_label_left_style",   tooltip={"tooltip.k2cp-total-housholds-desc"}}
	      k2cp_civ_table.add{type="label",                    caption={"caption.k2cp-credits"},    style="cp_label_right_style",  tooltip={"tooltip.k2cp-credits-desc"}}
	      k2cp_civ_table.add{type="label", name="credits",    caption="0",                         style="cp_label_left_style",   tooltip={"tooltip.k2cp-credits-desc"}}
	      k2cp_civ_table.add{type="label",                    caption={"caption.k2cp-passengers"}, style="cp_label_right_style",  tooltip={"tooltip.k2cp-passengers-transported-desc"}}
	      k2cp_civ_table.add{type="label", name="passengers", caption="0",                         style="cp_label_left_style",   tooltip={"tooltip.k2cp-passengers-transported-desc"}}	
	local k2cp_civ_bottom_flow=k2cp_civ_frame.add{type="flow", name="k2cp_civ_bottom_flow", style="cp_horizontal_centered_flow_style"}
	  	  k2cp_civ_bottom_flow.style.horizontally_stretchable=true
		  k2cp_civ_bottom_flow.style.bottom_padding = 4
	local k2cp_credit_button=k2cp_civ_bottom_flow.add{type="button", name="k2cp_credit_button", caption={"caption.k2cp-credit-button"}, tooltip={"tooltip.k2cp-credit-button-desc"}}
	local k2cp_upgrade_button=k2cp_civ_bottom_flow.add{type="button", name="k2cp_upgrade_button", caption={"caption.k2cp-upgrade-button"}, tooltip={"tooltip.k2cp-upgrade-button-desc"}}
	local k2cp_city_topflow=k2cp_civ_frame.add{type="flow", name="k2cp_city_topflow", direction="vertical", style="cp_vertical_flow_style"}

	-- Credit Transfer Frame
	local k2cp_credit_frame=k2cp_dtl_frame.add{type="frame", name="k2cp_credit_frame", direction="vertical", visible=false, style="inside_deep_frame_for_tabs"}
 		  k2cp_credit_frame.style.width = 540
	local k2cp_credit_content_flow=k2cp_credit_frame.add{type="flow", name="k2cp_credit_content_flow", style="cp_horizontal_flow_style" }
		  k2cp_credit_content_flow.style.bottom_padding = 8
		  k2cp_credit_content_flow.add{type="label", caption={"caption.k2cp-credit-amount"}, style="cp_label_right_style"}
	local k2cp_credit_textbox=k2cp_credit_content_flow.add{type="text-box", name="k2cp_credit_textbox", text="", style="cp_text_box_style", tooltip={"tooltip.k2cp-deposit-tb-desc"}}
		  k2cp_credit_content_flow.add{type="button", name="k2cp_deposit_button", caption="+", style="frame_action_button", tooltip={"tooltip.k2cp-deposit-desc"}}
		  k2cp_credit_content_flow.add{type="button", name="k2cp_withdraw_button", caption="-", style="frame_action_button", tooltip={"tooltip.k2cp-withdraw-desc"} }
	local k2cp_spacer_1=k2cp_credit_content_flow.add{type="flow", name="k2cp_spacer_1", style="cp_horizontal_flow_style" }
		  k2cp_spacer_1.style.horizontally_stretchable=true
	local k2cp_credit_back_button=k2cp_credit_content_flow.add{type="button", name="k2cp_credit_back_button", caption={"caption.k2cp-back"}, style="confirm_button"}
		  k2cp_credit_back_button.style.horizontal_align = "right"
		  k2cp_credit_back_button.style.width = 70
		  
	-- Easter egg:  Update interval setter
	local k2cp_interval_flow=k2cp_credit_frame.add{type="flow", name="k2cp_interval_flow", style="cp_horizontal_flow_style" }
		  k2cp_interval_flow.style.bottom_padding = 8
		  k2cp_interval_flow.add{type="label", caption={"caption.k2cp-interval"}, style="cp_label_right_style", tooltip={"tooltip.k2cp-interval-desc"} }
	local k2cp_interval_textbox=k2cp_interval_flow.add{type="text-box", name="k2cp_interval_textbox", text=Civ.state.update_interval, style="cp_text_box_style", tooltip={"tooltip.k2cp-interval-desc"} }
		  k2cp_interval_flow.add{type="button", name="k2cp_interval_button", caption="*", style="frame_action_button", tooltip={"tooltip.k2cp-interval-desc"} } 

	-- Upgrade Frame
	local k2cp_upgrade_frame=k2cp_dtl_frame.add{type="frame", name="k2cp_upgrade_frame", direction="vertical", visible=false, style="inside_deep_frame_for_tabs"}
 		  k2cp_upgrade_frame.style.width = 540
		  k2cp_upgrade_frame.style.bottom_padding = 4
	local k2cp_upgrade_warn_flow=k2cp_upgrade_frame.add{type="flow", name="k2cp_upgrade_warn_flow", style="cp_horizontal_centered_flow_style" }
		  k2cp_upgrade_warn_flow.style.bottom_padding = 4
	local k2cp_upgrade_warn_label=k2cp_upgrade_warn_flow.add{type="label", caption={"caption.k2cp-upgrade-warn-label"}, style="cp_label_left_style" }
		  k2cp_upgrade_warn_label.style.single_line = false
	local k2cp_upgrade_filter_flow=k2cp_upgrade_frame.add{type="flow", name="k2cp_upgrade_filter_flow", style="cp_horizontal_flow_style" }
		  k2cp_upgrade_filter_flow.style.bottom_padding = 4
		  k2cp_upgrade_filter_flow.add{type="label", caption={"caption.k2cp-upgrade-filter-label"}, style="cp_label_right_style" }
			for _, u in ipairs(Civ.state.upgrades) do
				k2cp_upgrade_filter_flow.add{type="sprite-button", name="k2cp_us_"..u.name, sprite=u.sprite, tooltip={u.tooltip} }
			end
	local k2cp_spacer_1=k2cp_upgrade_filter_flow.add{type="flow", name="k2cp_spacer_1", style="cp_horizontal_flow_style" }
		  k2cp_spacer_1.style.horizontally_stretchable=true
	local k2cp_upgrade_back_button = k2cp_upgrade_filter_flow.add{type="button", name="k2cp_upgrade_back_button", caption={"caption.k2cp-back"}, style="confirm_button"}
		  k2cp_upgrade_back_button.style.horizontal_align = "right"
		  k2cp_upgrade_back_button.style.width = 70
		  
	-- Set GUI references
	self.state.day_label        	= k2cp_main_table.k2cp_day
	self.state.households_label 	= k2cp_civ_table.households
	self.state.exports_label    	= k2cp_civ_table.exports
	self.state.status_label     	= k2cp_civ_table.status
	self.state.renown_label     	= k2cp_civ_table.renown
	self.state.score_label      	= k2cp_civ_table.score
	self.state.next_tier_label  	= k2cp_civ_table.next_tier
	self.state.credits_label    	= k2cp_civ_table.credits
	self.state.passenger_label  	= k2cp_civ_table.passengers
	self.state.credit_textbox   	= k2cp_credit_textbox
	self.state.interval_textbox 	= k2cp_interval_textbox
								
	self.state.main_frame   		= k2cp_main_table
	self.state.dtl_frame 			= k2cp_dtl_frame
	self.state.civ_frame    		= k2cp_civ_frame
	self.state.city_frame   		= k2cp_city_topflow
	self.state.credit_frame 		= k2cp_credit_frame
	self.state.upgrade_frame		= k2cp_upgrade_frame
 end

function Gui:update_civ_gui()
	self.state.day_label.caption        	= Civ.state.days
	self.state.households_label.caption 	= Civ.state.districts * 100  -- Multiply districts by 100 to make cities look like they have alot of peeps.
	self.state.exports_label.caption    	= Civ.state.exports
	self.state.status_label.caption     	= Civ.state.status_title
	self.state.renown_label.caption     	= Civ.state.status_renown
	self.state.score_label.caption      	= Civ.state.score
	self.state.next_tier_label.caption  	= Civ.state.next_tier
	self.state.credits_label.caption    	= Civ.state.credits
	self.state.passenger_label.caption  	= Civ.state.passengers
	self.state.interval_textbox.text		= Civ.state.update_interval
end

-- Informational frame per city
function Gui:add_city_gui_dtl(index)
	local k2cp_dtl_flow=self.state.city_frame.add{type="flow", name="k2cp_dtl_flow_" .. index, direction="vertical", style="cp_vertical_flow_style"}
	local k2cp_line_flow=k2cp_dtl_flow.add{type="flow", name="k2cp_line_flow", style="cp_horizontal_flow_style" }
		  k2cp_line_flow.add{type="line", direction="horizontal", style="cp_line_style"}
	local k2cp_dtl_info=k2cp_dtl_flow.add{type="flow", name="k2cp_dtl_info", style="cp_horizontal_flow_style"}
  		  k2cp_dtl_info.style.horizontally_stretchable=true
	      k2cp_dtl_info.add{type="sprite", name="happiness_sprite", sprite="sleepy_sprite", tooltip={"tooltip.k2cp-happy-sprite-desc"}}
	local k2cp_city_table=k2cp_dtl_info.add{type="table", name="k2cp_city_table", style="cp_table_style", column_count=4}
		  k2cp_city_table.add{type="label",            			caption={"caption.k2cp-city"},       style="cp_label_narrow_right_style"}
		  k2cp_city_table.add{type="label", name="City",		caption=index,                       style="cp_label_narrow_left_style"}
		  k2cp_city_table.add{type="label",                		caption={"caption.k2cp-districts"},  style="cp_label_narrow_right_style", tooltip={"tooltip.k2cp-districts-desc"}}
		  k2cp_city_table.add{type="label", name="districts",	caption="0",                         style="cp_label_narrow_left_style", tooltip={"tooltip.k2cp-districts-desc"}}
	local k2cp_spacer_1=k2cp_dtl_info.add{type="flow", name="k2cp_spacer_1", style="cp_horizontal_flow_style" }
		  k2cp_spacer_1.style.horizontally_stretchable=true
	local k2cp_city_find_button=k2cp_dtl_info.add{type="sprite-button", name="k2cp_goto_city_" .. index, sprite="item/k2cp-city", tooltip={"tooltip.k2cp-find-city-desc"}}
		  k2cp_city_find_button.style.horizontal_align = "right"
	local k2cp_needs_flow=k2cp_dtl_flow.add{type="flow", name="k2cp_needs_flow", style="cp_horizontal_flow_style"}
  		  k2cp_needs_flow.style.horizontally_stretchable=true
		  k2cp_needs_flow.style.bottom_padding = 4
	local k2cp_needs_table=k2cp_needs_flow.add{type="table", name="k2cp_needs_table", style="cp_table_needs_style", column_count=Civ.state.needs_count + 1}
		  k2cp_needs_table.add{type="label", caption={"caption.k2cp-needs"}, style="cp_label_narrow_right_style", tooltip={"tooltip.k2cp-needs-desc"}}
		  for _, need in ipairs(Civ.state.city_needs) do
		  	local tt="item-name."..need
		  	k2cp_needs_table.add{type="sprite-button", name=need.."_sprite", sprite="item/"..need, tooltip={tt}}
		  end
end

-- Update the detail gui for each city
function Gui:update_city_dtl(city)
	local city_dtl_flow = self.state.city_frame["k2cp_dtl_flow_" .. city.state.index]
	if (city_dtl_flow) then
		if (tonumber(city_dtl_flow.k2cp_dtl_info.k2cp_city_table.districts.caption) < city.state.districts) then
			city_dtl_flow.k2cp_dtl_info["happiness_sprite"].sprite = "happy_sprite"
			city_dtl_flow.k2cp_dtl_info["happiness_sprite"].tooltip = {"tooltip.k2cp-pop-rise"}
		elseif (city.state.districts == 0) then
			city_dtl_flow.k2cp_dtl_info["happiness_sprite"].sprite = "sleepy_sprite"
			city_dtl_flow.k2cp_dtl_info["happiness_sprite"].tooltip = {"tooltip.k2cp-pop-neutral"}
		else
			city_dtl_flow.k2cp_dtl_info["happiness_sprite"].sprite = "sad_sprite"
			city_dtl_flow.k2cp_dtl_info["happiness_sprite"].tooltip = {"tooltip.k2cp-pop-fall"}
		end
		city_dtl_flow.k2cp_dtl_info.k2cp_city_table.districts.caption = city.state.districts

		local inventory = city.state.entity.get_inventory(1)
		for _, need in ipairs(Civ.state.city_needs) do
			local needs_sprite = need.."_sprite"
			city_dtl_flow.k2cp_needs_flow.k2cp_needs_table[needs_sprite].number = inventory.get_item_count(need)
		end
	end
end

-- Remove city detail gui if a city is removed
function Gui:remove_city_dtl(index)
	self.state.city_frame["k2cp_dtl_flow_" .. index].destroy()
end

-- Generate 'available entities to upgrade' buttons based on filter button selected
function Gui.add_upgrade_gui_dtl(self, name, sprite, tt)
	-- Refresh the dtl frame each time a filter is clicked
	local frame = self.state.upgrade_frame
	if (frame.k2cp_upgrade_dtl_flow) then frame.k2cp_upgrade_dtl_flow.destroy() end	
	local k2cp_upgrade_dtl_flow=frame.add{type="flow", name="k2cp_upgrade_dtl_flow", direction="vertical", style="cp_vertical_flow_style" }
		  k2cp_upgrade_dtl_flow.style.bottom_padding = 4
	local k2cp_udc_flow=k2cp_upgrade_dtl_flow.add{type="flow", name="k2cp_udc_flow", style="cp_horizontal_flow_style" }
		  k2cp_udc_flow.style.vertical_align = "top"
	local k2cp_udc_scroll=k2cp_udc_flow.add{type="scroll-pane", name="k2cp_udc_scroll", direction="vertical" }
		  k2cp_udc_scroll.style.maximal_height = 500
	local entity_count = 0
	for _, u in ipairs(Civ.state.upgrade_tracker) do
		if (u.object.state.internal_name == name) then
			k2cp_udc_scroll.add{type="sprite-button", name="k2cp_udc_"..name.."*"..u.object.state.index, sprite=sprite, number=u.object.state.index, tooltip=tt}
			entity_count = entity_count + 1
		end
	end			
	if (entity_count == 0) then	k2cp_udc_flow.add{type="label", caption={"caption.k2cp-none"}, style="cp_label_left_style"}	end
	self.state.upgrade_dtl_flow = k2cp_upgrade_dtl_flow
end

-- Generate entity's upgrade options
function Gui:add_upgrade_gui_options(frame, name, id)
	-- Refresh the options frame each time an entity is clicked
	if (frame.k2cp_udc_flow.k2cp_option_flow) then frame.k2cp_udc_flow.k2cp_option_flow.destroy() end	
	local k2cp_option_flow=frame.k2cp_udc_flow.add{type="flow", name="k2cp_option_flow", direction="vertical", style="cp_vertical_flow_style" }
		  k2cp_option_flow.style.vertical_align = "top"
	for _, u in ipairs(Civ.state.upgrade_tracker) do
		if (u.object.state.internal_name == name and u.object.state.index == id) then
			for _, o in ipairs(u.options) do
				local flow_name = "k2cp_opt_flow_"..o.track_id
				local bttn_name = "k2cp_opt_"..name.."*"..id.."#"..o.track_id
				local bttn_name=k2cp_option_flow.add{type="button", name=bttn_name}
					  bttn_name.style.horizontally_stretchable=true
					  bttn_name.style.minimal_height = 56
					  bttn_name.style.vertical_align = "center"
					  bttn_name.style.bottom_margin = 2
				local flow_name=bttn_name.add{type="flow", name=flow_name, style="cp_horizontal_flow_style" }
					  flow_name.add{type="label", caption=id}
				local flow_table=flow_name.add{type="table", style="cp_table_style", column_count=4 }
					  flow_table.style.left_margin = 12
					  flow_table.add{type="label", caption="Attribute:" 		, style="cp_label_narrow_right_style"}
					  flow_table.add{type="label", caption=o.option.attr		, style="cp_label_left_style"}
					  flow_table.add{type="label", caption="Add Value:"			, style="cp_label_narrow_right_style"}
					  flow_table.add{type="label", caption=o.option.add_value	, style="cp_label_left_style"}
					  flow_table.add{type="label", caption="Credits:"			, style="cp_label_narrow_right_style"}
					  flow_table.add{type="label", caption=o.option.cost		, style="cp_label_left_style"}
			end
		end
	end
end

function Gui:upgrade_msg(upgrade_state, cost)
	Gui.remove_upgrade_dtl(self)	

	local k2cp_upgrade_dtl_flow=self.state.upgrade_frame.add{type="flow", name="k2cp_upgrade_dtl_flow", direction="vertical", style="cp_vertical_flow_style" }
		  k2cp_upgrade_dtl_flow.style.bottom_padding = 4
	local k2cp_udc_flow=k2cp_upgrade_dtl_flow.add{type="flow", name="k2cp_udc_flow", style="cp_horizontal_centered_flow_style" }
		  k2cp_udc_flow.style.horizontally_stretchable = true
		  k2cp_udc_flow.add{type="label", name="k2cp_udc_msg_label", caption="test", style="cp_label_left_style" }
	self.state.upgrade_dtl_flow = k2cp_upgrade_dtl_flow
	local msg = self.state.upgrade_dtl_flow.k2cp_udc_flow.k2cp_udc_msg_label

	if (upgrade_state == "none") then
		msg.caption = {"message.k2cp-upg-none"}
	elseif (upgrade_state == "cost") then
		msg.caption = {"message.k2cp-transfer-insf", cost}
	elseif (upgrade_state == "success") then
		msg.caption = {"message.k2cp-upg-success", cost}
	end
end

function Gui.remove_upgrade_dtl(self)
	if (self.state.upgrade_dtl_flow) then 
		self.state.upgrade_dtl_flow.destroy()
	end	
end

function Gui.on_click(self, event)
	if (self.state.dtl_frame  == nil)   	then return end
	if (self.state.credit_frame  == nil)	then return end
	if (self.state.upgrade_frame == nil)	then return end

	if (event.element.name == "k2cp_dtl_toggle")            then Gui:toggle_visibility(self.state.dtl_frame) 		return end		-- Main button toggle
	if (event.element.name == "k2cp_dtl_close")         	then self.state.dtl_frame.visible = false	    		return end		-- dtl frame close button
	if (event.element.name == "k2cp_credit_button")        	then Gui:toggle_visibility(self.state.civ_frame)
																 Gui:toggle_visibility(self.state.credit_frame) 	return end		-- Credit transfer button
	if (event.element.name == "k2cp_credit_back_button")	then self.state.credit_frame.visible = false
																 Gui:toggle_visibility(self.state.civ_frame)		return end		-- Credit transfer close button
	if (event.element.name == "k2cp_upgrade_button")		then Gui:toggle_visibility(self.state.civ_frame)
																 Gui:toggle_visibility(self.state.upgrade_frame)	return end		-- Upgrade button
	if (event.element.name == "k2cp_deposit_button")       	then Gui.transfer_credits(self, "d")		       		return end		-- Credit deposit button
	if (event.element.name == "k2cp_withdraw_button")      	then Gui.transfer_credits(self, "w")					return end		-- Credit withdraw button

	-- Upgrade back button
	if (event.element.name == "k2cp_upgrade_back_button") then 
		self.state.upgrade_frame.visible = false
		Gui:toggle_visibility(self.state.civ_frame)
		if (self.state.upgrade_frame.k2cp_upgrade_dtl_flow) then 
			self.state.upgrade_frame.k2cp_upgrade_dtl_flow.destroy() 
		end	
		return
	end		
	
	-- Generate available upgradeable entity buttons
	if (string.sub(event.element.name, 1, 8) == "k2cp_us_") then
		Gui.add_upgrade_gui_dtl(self, string.sub(event.element.name, 9, -1), event.element.sprite, event.element.tooltip)
		return
	end

	-- Generate entity's upgrade option buttons
	if (string.sub(event.element.name, 1, 9) == "k2cp_udc_") then
		local position = string.find(event.element.name, "*")
		local name = string.sub(event.element.name, 10, position - 1)
		Gui:add_upgrade_gui_options(self.state.upgrade_dtl_flow, name, event.element.number)
		return
	end

	-- Execute the upgrade
	if (string.sub(event.element.name, 1, 9) == "k2cp_opt_") then
		local pos1 = string.find(event.element.name, "*")
		local pos2 = string.find(event.element.name, "#")
		local name = string.sub(event.element.name, 10, pos1 - 1)
		local id   = string.sub(event.element.name, pos1 + 1, pos2 - 1)
		local tid  = string.sub(event.element.name, pos2 + 1)
		Civ:upgrade_object(self.state.player, name, id, tid)
		return
	end

	-- Set the update interval
	if (event.element.name == "k2cp_interval_button") then
		local amount = self.state.interval_textbox.text
		if (amount~=string.match(self.state.interval_textbox.text, '%d+')) then
			player.print({"message.k2cp-interval-numeric"})
			return
		else
			amount = tonumber(amount)
			if (amount < 250) then amount = 250 end
			Civ:update_interval(amount)
		end
		return
	end

	-- Setup the find city button gps link
	if (string.sub(event.element.name, 1, 15) == "k2cp_goto_city_") then
		local id = tonumber(string.sub(event.element.name, 16, -1))
		for _, city in ipairs(Civ.state.cities) do
			if (city.state.entity.valid) then
				if (city.state.index == id) then
					self.state.player.print("City "..id..": "..Gui:gps_link(city.state.entity))
					break
				end
			end
		end
	end
end

function Gui.transfer_credits(self, action)
	local amount = self.state.credit_textbox.text
	if (amount~=string.match(self.state.credit_textbox.text, '%d+')) then
		self.state.player.print({"message.k2cp-transfer-numeric"})
		return
	end
	amount = tonumber(amount)
	Civ:transfer_credits(self.state.player, action, amount)
end

function Gui:toggle_visibility(frame)
	if (frame.visible) then	frame.visible = false else frame.visible = true	end
end

function Gui:gps_link(entity)
	return "[gps=" .. entity.position.x .. "," .. entity.position.y .. "," .. entity.surface.name .. "]"
end

