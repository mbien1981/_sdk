if not rawget(_G, "_sdk") then
	rawset(_G, "_sdk", {})

	--* t, dt
	function _sdk:current_time()
		return TimerManager:main():time()
	end

	function _sdk:current_delta()
		return TimerManager:main():delta_time()
	end

	function _sdk:current_game_time()
		return TimerManager:game():time()
	end

	function _sdk:current_game_delta()
		return TimerManager:game():delta_time()
	end

	-- * table utils
	function _sdk:load_table_from_file(filename)
		local file = io.open(filename, "r")
		if not file then
			return {}
		end

		local info = loadstring(file:read("*all"))()
		file:close()

		return info
	end

	function _sdk:save_table_to_file(tbl, filename)
		local file = io.open(filename, "w+")
		if not file then
			return
		end

		file:write("return {")
		local function do_recursion_raw(file, data)
			local is_first = false
			for i, v in pairs(data) do
				if type(v) == "table" then
					file:write((is_first and "," or "") .. (type(i) == "number" and "" or ('["' .. i .. '"]=')) .. "{")
					is_first = true
					do_recursion_raw(file, v)
				else
					file:write(
						(is_first and "," or "")
							.. (type(i) == "number" and "" or (i .. "="))
							.. (
								type(v) == "string" and ('"' .. tostring(v):gsub("[\n\r]", "") .. '"')
								or tostring(v):gsub("[\n\r]", "")
							)
					)
					is_first = true
				end
			end

			file:write("}")
		end

		do_recursion_raw(file, tbl)

		file:close()
	end

	-- * panel utils
	function _sdk:ease_in_out_sine(time, start, final, delta)
		return -final / 2 * (math.cos(math.pi * time / delta) - 1) + start
	end

	function _sdk:debug_panel_fill(panel, color)
		panel:rect({
			color = color,
			visible = true,
			alpha = 0.5,
			layer = 10000,
		})
	end

	function _sdk:debug_panel_outline(panel, color, layer)
		panel:rect({
			valign = "grow",
			halign = "grow",
			h = 1,
			color = color,
			visible = true,
			alpha = 0.5,
			layer = layer or 1000,
		})
		panel:rect({
			valign = "grow",
			halign = "grow",
			y = panel:h() - 1,
			h = 1,
			color = color,
			visible = true,
			alpha = 0.5,
			layer = layer or 1000,
		})
		panel:rect({
			valign = "grow",
			halign = "grow",
			w = 1,
			color = color,
			visible = true,
			alpha = 0.5,
			layer = layer or 1000,
		})
		panel:rect({
			valign = "grow",
			halign = "grow",
			x = panel:w() - 1,
			w = 1,
			color = color,
			visible = true,
			alpha = 0.5,
			layer = layer or 1000,
		})
	end

	function _sdk:update_text_rect(text)
		local _, _, w, h = text:text_rect()
		text:set_w(w)
		text:set_h(h)

		return w, h
	end

	function _sdk:animate_ui(total_t, callback)
		local t = 0
		local const_frames = 0
		local count_frames = const_frames + 1
		while t < total_t do
			coroutine.yield()
			t = t + TimerManager:main():delta_time()
			if count_frames >= const_frames then
				callback(t / total_t, t)
				count_frames = 0
			end
			count_frames = count_frames + 1
		end

		callback(1, total_t)
	end

	function _sdk:animate_inf_ui(callback, framerate)
		framerate = tonumber(framerate)
		local const_frames = (framerate and (1 / framerate)) or 0
		local count_frames = const_frames + 1
		while true do
			coroutine.yield()
			if count_frames >= const_frames then
				callback()
				count_frames = 0
			end
			count_frames = count_frames + 1
		end

		callback()
	end

	--* color utils
	function _sdk:rgb255(...)
		local items = { ... }
		local num = #items
		if num == 4 then
			return Color(items[1] / 255, items[2] / 255, items[3] / 255, items[4] / 255)
		end

		if num == 3 then
			return Color(items[1] / 255, items[2] / 255, items[3] / 255)
		end

		return Color.white
	end

	function _sdk:blend_colors(current, target, blend)
		local result = {
			r = (current.r * blend) + (target.r * (1 - blend)),
			g = (current.g * blend) + (target.g * (1 - blend)),
			b = (current.b * blend) + (target.b * (1 - blend)),
		}

		return Color(result.r, result.g, result.b)
	end

	--* string stuff
	function _sdk:read_color_tags(text_panel_obj)
		local string_data = {}

		local splitString = function(s, i)
			i = (i or 0) + 1
			local j = s:sub(i, i)
			if j == "" then
				return
			end
			j = s:find(j == "[" and "]" or ".%f[[%z]", i) or #s
			table.insert(string_data, { i, j, s:sub(i, j) })
			return j
		end

		for k, v in splitString, text_panel_obj:text() do
			-- nothing
		end

		local start_count = 0
		local commands = {}
		local command_count = 0
		local real_text = ""
		for i, v in pairs(string_data) do
			if string.lower(v[3]):find("color=") then
				command_count = command_count + 1
				local temp = {}
				for word in string.gmatch(v[3]:match("%(([^%)]+)"), "([^,]+)") do
					table.insert(temp, tonumber(word))
				end
				table.insert(commands, { start = start_count, ending = 0, color = temp })
			elseif string.lower(v[3]):find("/color") then
				commands[command_count].ending = start_count
			else
				start_count = start_count + utf8.len(v[3])
				real_text = real_text .. v[3]
			end
		end

		text_panel_obj:set_text(real_text)

		for _, v in pairs(commands) do
			text_panel_obj:set_range_color(v.start, v.ending, Color(unpack(v.color)))
		end

		-- in case we need it back.
		return text_panel_obj
	end

	--* gamestate utils
	function _sdk:in_game()
		if not rawget(_G, "game_state_machine") then
			return false
		end

		return string.find(game_state_machine:current_state_name(), "game")
	end

	function _sdk:is_playing()
		if not self:in_game() or not rawget(_G, "BaseNetworkHandler") then
			return false
		end

		return BaseNetworkHandler._gamestate_filter.any_ingame_playing[game_state_machine:last_queued_state_name()]
	end

	--* player stuff
	function _sdk:player()
		local player = managers.player and managers.player:player_unit()
		return alive(player) and player
	end

	function _sdk:player_movement_state()
		local unit = self:player()
		if unit then
			return unit:movement():current_state()
		end
	end

	function _sdk:player_state_name()
		return managers.player and managers.player:current_state()
	end
end
