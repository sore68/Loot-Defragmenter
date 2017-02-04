check_level = 0
action_state = {false, 0}

------------------------------------------ event script
script.on_init(function() init() end)

script.on_event(defines.events.on_tick, function(event)
	if event.tick%60 == 0 then
		-- writeDebug("tick = " .. event.tick)
		if global.Roboport_Table ~= nil then
			for i = #global.Roboport_Table, 1, -1 do
				if not global.Roboport_Table[i][1].valid then
					table.remove(global.Roboport_Table, i)
				end
				if #global.Roboport_Table == 0 then
					global.Roboport_Table = nil
				end
			end
			-- if type(global.Roboport_Table) == "table" then writeDebug(#global.Roboport_Table) else writeDebug("nil table") end
		end
	end
	if event.tick%20 == 0 then
		if action_state[1] then
			action_state[2] = event.tick
			if global.Roboport_Table ~= nil then
				-- writeDebug("Roboport_Table not nil")
				local numb = 4
				local top = #global.Roboport_Table - (numb * check_level)
				local bottom = #global.Roboport_Table - numb - (numb * check_level)
				local caption_text
				-- writeDebug(top .. " / " .. bottom .. " / " .. check_level)
				check_level = check_level + 1
				for i = top, bottom, -1 do
					if i <= 0 then
						check_level = 0
						action_state[1] = false
						action_state[2] = event.tick
						caption_text = 0
						break
					end
					if global.Roboport_Table[i] then scan_item(global.Roboport_Table[i]) end
					caption_text = i
				end
				local number = ((#global.Roboport_Table - caption_text) / #global.Roboport_Table * 100)
				for _, player in pairs(game.players) do
					if player.gui.left.collect_title then
						player.gui.left.collect_title.collect_table.collect_table_2.caption = string.format("   %d %s ", number, "%")
					elseif player.gui.top.collect_view_frame then
						-- player.gui.top.collect_view_frame.collect_top_label.caption = string.format("   %d %s ", number, "%")
						local action_top_table = player.gui.top.collect_view_frame.collect_top_table
						for i = 1, 10 do
							-- local a = 5 * (i * 2 - 1)
							local a = 10 * i - 1
							if number >= a then
								if action_top_table["ast_" .. i].sprite ~= "color_G" then action_top_table["ast_" .. i].sprite = "color_G" end
							else
								if number >= a - 10 then
									if action_top_table["ast_" .. i].sprite ~= "color_Y" then action_top_table["ast_" .. i].sprite = "color_Y" end
								else
									if action_top_table["ast_" .. i].sprite ~= "color_R" then action_top_table["ast_" .. i].sprite = "color_R" end
								end
							end
						end
					end
				end
			end
		else
			for _, player in pairs(game.players) do
				if player.gui.left.collect_title then player.gui.left.collect_title.destroy() end
				if player.gui.top.collect_view_frame then player.gui.top.collect_view_frame.destroy() end
			end
			
			if game.players[1].force.technologies["automated-construction"].researched then
				-- writeDebug("researched")
				if math.abs(action_state[2] - event.tick) > (60 * 60 * 5) then
					-- action_state[1] = true
					progress_button(game.players[1])
					progress_button(game.players[1])
					-- writeDebug("progress" .. game.players[1].name)
				end
			end
		end
	end
end)

script.on_event({defines.events.on_built_entity,}, function(event) On_Built(event) end)
script.on_event({defines.events.on_robot_built_entity,}, function(event) On_Built(event) end)

script.on_event("item_collect", function(event)
	progress_button(game.players[event.player_index])
end)


------------------------------------------ function
function init()
	for _,surface in pairs(game.surfaces) do
		local roboports = surface.find_entities_filtered{type = "roboport"}
		for _, roboport in pairs(roboports) do
			add_roboport(roboport)
		end
	end
end

function On_Built(event)
	if event.created_entity.type == "roboport" then
		add_roboport(event.created_entity)
	end
end

function scan_item(entity)
	if entity[1].valid then
		local force = entity[1].force
		local items
		if entity[3] then
			if entity[3] == 1 then
				items = entity[1].surface.find_entities_filtered{
					area = {{entity[1].position.x - entity[2], entity[1].position.y - entity[2]}, {entity[1].position.x, entity[1].position.y}},
					name = "item-on-ground"}
			elseif entity[3] == 2 then
				items = entity[1].surface.find_entities_filtered{
					area = {{entity[1].position.x - entity[2], entity[1].position.y}, {entity[1].position.x, entity[1].position.y + entity[2]}},
					name = "item-on-ground"}
			elseif entity[3] == 3 then
				items = entity[1].surface.find_entities_filtered{
					area = {{entity[1].position.x, entity[1].position.y - entity[2]}, {entity[1].position.x + entity[2], entity[1].position.y}},
					name = "item-on-ground"}
			elseif entity[3] == 4 then
				items = entity[1].surface.find_entities_filtered{
					area = {{entity[1].position.x, entity[1].position.y}, {entity[1].position.x + entity[2], entity[1].position.y + entity[2]}},
					name = "item-on-ground"}
			end
		else
			items = entity[1].surface.find_entities_filtered{area = {{entity[1].position.x - entity[2], entity[1].position.y - entity[2]}, {entity[1].position.x + entity[2], entity[1].position.y + entity[2]}}, name = "item-on-ground"}
		end
		for _, item in ipairs(items) do
			if not item.to_be_deconstructed(force) then 
				item.order_deconstruction(force)
				-- writeDebug("scan items")
			end
		end
	end
end

function add_roboport(entity)
	if global.Roboport_Table == nil then
		global.Roboport_Table = {}
	end
	local radius = entity.logistic_cell.construction_radius
	if radius >= 25 then
		if radius > 100 then
			table.insert(global.Roboport_Table, {entity, radius, 1})
			table.insert(global.Roboport_Table, {entity, radius, 2})
			table.insert(global.Roboport_Table, {entity, radius, 3})
			table.insert(global.Roboport_Table, {entity, radius, 4})
		else
			table.insert(global.Roboport_Table, {entity, radius})
		end
	end
end


------------------------------------------ gui
function progress_button(player)
	local action_frame_main = player.gui.left.collect_title
	local action_frame_false = player.gui.left.collect_title_false
	local action_top = player.gui.top.collect_view_frame
	
	if action_frame_main or action_frame_false then
		if action_frame_main then action_frame_main.destroy() end
		if action_frame_false then action_frame_false.destroy() end
		if action_state[1] then
			player.gui.top.add{type = "frame", name = "collect_view_frame", direction = "vertical"}
			player.gui.top.collect_view_frame.add{type = "label", name = "asl_", caption = "Defragment.."}
			local action_top = player.gui.top.collect_view_frame.add{type = "table", name = "collect_top_table", colspan = 10}
			action_top.style.horizontal_spacing = 1
			for i = 1, 10 do
				action_top.add{type = "sprite-button", name = "ast_" .. i, sprite = "color_R", style = "LD_gauge"}
			end
		end
	else
		if action_top then action_top.destroy() end
		if player.force.technologies["automated-construction"].researched then
			if global.Roboport_Table then
				action_frame_main = player.gui.left.add{type = "frame", name = "collect_title", direction = "vertical"}
				local action_main_table = action_frame_main.add{type = "table", name = "collect_table", colspan = 2}
				action_main_table.add{type = "label", name = "collect_table_1", caption = "Scanning area near Roboport."}
				if action_state[1] then
					action_main_table.add{type = "label", name = "collect_table_2", caption = "   -- % "}
				else
					action_main_table.add{type = "label", name = "collect_table_2", caption = "   0 % "}
					action_state[1] = true
				end
			else
				action_frame_false = player.gui.left.add{type = "frame", name = "collect_title_false"}
				local false_port_table = action_frame_false.add{type = "table", name = "af1_table", colspan = 2}
				false_port_table.add{type = "label", name = "fpt_label", caption = "Need to Roboport : "}
				false_port_table.add{type = "sprite", name = "fpt_sprite", sprite = "entity/roboport", tooltip = game.entity_prototypes["roboport"].localised_name}
			end
		else
			action_frame_false = player.gui.left.add{type = "frame", name = "collect_title_false"}
			local false_tech_table = action_frame_false.add{type = "table", name = "af2_table", colspan = 2}
			false_tech_table.add{type = "label", name = "ftt_label_1", caption = "Need to Technology : "}
			false_tech_table.add{type = "sprite", name = "ftt_sprite", sprite = "technology/automated-construction", tooltip = player.force.technologies["automated-construction"].localised_name}
		end
		
	end
end


------------------------------------------ bundle
function writeDebug(message)
	for i, player in pairs(game.players) do
		player.print(tostring(message))
	end
end