local scriptpath = engine.get_scriptdir()

dofile(scriptpath .. DIR_DELIM .. "modmgr.lua")
dofile(scriptpath .. DIR_DELIM .. "gamemgr.lua")

local menu = {}
local tabbuilder = {}
local menubar = {}

--------------------------------------------------------------------------------
function render_favourite(spec)
	local text = ""
	
	if spec.name ~= nil then
		text = text .. spec.name:trim()
		
		if spec.description ~= nil then
			--TODO make sure there's no invalid chat in spec.description
			text = text .. " (" .. fs_escape_string(spec.description) .. ")"
		end
	else
		if spec.address ~= nil then
			text = text .. spec.address:trim()
		end
	end
	
	local details = ""
	if spec.password == true then
		details = " *"
	else
		details = "  "
	end
	
	if spec.creative then
		details = details .. "C"
	else
		details = details .. " "
	end
	
	if spec.damage then
		details = details .. "D"
	else
		details = details .. " "
	end
	
	if spec.pvp then
		details = details .. "P"
	else
		details = details .. " "
	end
	
	text = text .. ":" .. spec.port:trim()
	
	return text
end

--------------------------------------------------------------------------------
os.tempfolder = function()
	local filetocheck = os.tmpname()
	os.remove(filetocheck)
	
	local randname = "MTTempModFolder_" .. math.random(0,10000)
	
	local backstring = filetocheck:reverse()
	return filetocheck:sub(0,filetocheck:len()-backstring:find(DIR_DELIM)+1) ..randname

end

--------------------------------------------------------------------------------
function cleanup_path(temppath)
	
	local parts = temppath:split("-")
	temppath = ""	
	for i=1,#parts,1 do
		if temppath ~= "" then
			temppath = temppath .. "_"
		end
		temppath = temppath .. parts[i]
	end
	
	parts = temppath:split(".")
	temppath = ""	
	for i=1,#parts,1 do
		if temppath ~= "" then
			temppath = temppath .. "_"
		end
		temppath = temppath .. parts[i]
	end
	
	parts = temppath:split("'")
	temppath = ""	
	for i=1,#parts,1 do
		if temppath ~= "" then
			temppath = temppath .. ""
		end
		temppath = temppath .. parts[i]
	end
	
	parts = temppath:split(" ")
	temppath = ""	
	for i=1,#parts,1 do
		if temppath ~= "" then
			temppath = temppath
		end
		temppath = temppath .. parts[i]
	end
	
	return temppath
end

--------------------------------------------------------------------------------
function menu.update_gametype()
	if (menu.game_last_check == nil or
		menu.game_last_check ~= menu.last_game) and
		tabbuilder.current_tab == "singleplayer" then
		
		local gamedetails = menu.lastgame()
		engine.set_topleft_text(gamedetails.name)
		
		--background
		local path_background_texture = gamedetails.path .. DIR_DELIM .."menu" .. 
												 DIR_DELIM .. "background.png"
		if engine.set_background("background",path_background_texture) then
			engine.set_clouds(false)
		else
			engine.set_clouds(true)
		end
		
		--overlay
		local path_overlay_texture = gamedetails.path .. DIR_DELIM .."menu" .. 
												 DIR_DELIM .. "overlay.png"
		engine.set_background("overlay",path_overlay_texture)
		
		--header
		local path_overlay_texture = gamedetails.path .. DIR_DELIM .."menu" .. 
												 DIR_DELIM .. "header.png"
		engine.set_background("header",path_overlay_texture)
		
		--footer
		local path_overlay_texture = gamedetails.path .. DIR_DELIM .."menu" .. 
												 DIR_DELIM .. "footer.png"
		engine.set_background("footer",path_overlay_texture)
		
		menu.game_last_check = menu.last_game
	else
		menu.game_last_check = menu.last_game
		menu.reset_gametype()
	end
end

--------------------------------------------------------------------------------
function menu.reset_gametype()
	menu.game_last_check = nil
	engine.set_clouds(true)
	engine.set_background("background","")
	engine.set_background("overlay",menu.basetexturedir .. "menu_overlay.png")
	engine.set_background("header",menu.basetexturedir .. "menu_header.png")
	engine.set_background("footer",menu.basetexturedir .. "menu_footer.png")
	engine.set_topleft_text("")
end

--------------------------------------------------------------------------------
function get_last_folder(text,count)
	local parts = text:split(DIR_DELIM)
	
	if count == nil then
		return parts[#parts]
	end
	
	local retval = ""
	for i=1,count,1 do
		retval = retval .. parts[#parts - (count-i)] .. DIR_DELIM
	end
	
	return retval
end

--------------------------------------------------------------------------------
function init_globals()
	--init gamedata
	gamedata.worldindex = 0
end

--------------------------------------------------------------------------------
function identify_filetype(name)

	if name:sub(-3):lower() == "zip" then
		return {
				name = name,
				type = "zip"
				}
	end
	
	if name:sub(-6):lower() == "tar.gz" or
		name:sub(-3):lower() == "tgz"then
		return {
				name = name,
				type = "tgz"
				}
	end
	
	if name:sub(-6):lower() == "tar.bz2" then
		return {
				name = name,
				type = "tbz"
				}
	end
	
	if name:sub(-2):lower() == "7z" then
		return {
				name = name,
				type = "7z"
				}
	end

	return {
		name = name,
		type = "ukn"
	}
end

--------------------------------------------------------------------------------
function update_menu()

	local formspec = "size[12,5.2]"
	
	-- handle errors
	if gamedata.errormessage ~= nil then
		formspec = formspec ..
			"field[1,2;10,2;;ERROR: " ..
			gamedata.errormessage .. 
			";]"..
			"button[4.5,4.2;3,0.5;btn_error_confirm;Ok]"
	else
		formspec = formspec .. tabbuilder.gettab()
	end

	engine.update_formspec(formspec)
end

--------------------------------------------------------------------------------
function menu.filtered_game_list()
	local retval = ""

	local current_game = menu.lastgame()
	
	for i=1,#menu.worldlist,1 do
		if menu.worldlist[i].gameid == current_game.id then
			if retval ~= "" then
				retval = retval ..","
			end
			
			retval = retval .. menu.worldlist[i].name .. 
						" [[" .. menu.worldlist[i].gameid .. "]]"
		end
	end
	
	return retval
end

--------------------------------------------------------------------------------
function menu.filtered_game_list_raw()
	local retval =  {}

	local current_game = menu.lastgame()
	
	for i=1,#menu.worldlist,1 do
		if menu.worldlist[i].gameid == current_game.id then
			table.insert(retval,menu.worldlist[i])
		end
	end
	
	return retval
end

--------------------------------------------------------------------------------
function menu.filtered_index_to_plain(filtered_index)

	local current_game = menu.lastgame()
	
	local temp_idx = 0
	
	for i=1,#menu.worldlist,1 do
		if menu.worldlist[i].gameid == current_game.id then
			temp_idx = temp_idx +1
		end
		
		if temp_idx == filtered_index then
			return i
		end
	end
	return -1
end

--------------------------------------------------------------------------------
function menu.init()
	--init menu data
	gamemgr.update_gamelist()

	menu.worldlist = engine.get_worlds()
	
	menu.last_world	= tonumber(engine.setting_get("main_menu_last_world_idx"))
	menu.last_game	= tonumber(engine.setting_get("main_menu_last_game_idx"))
	
	if type(menu.last_world) ~= "number" then
		menu.last_world = 1
	end
	
	if type(menu.last_game) ~= "number" then
		menu.last_game = 1
	end

	if engine.setting_getbool("public_serverlist") then
		menu.favorites = engine.get_favorites("online")
	else
		menu.favorites = engine.get_favorites("local")
	end
	
	
	menu.basetexturedir = engine.get_gamepath() .. DIR_DELIM .. ".." ..
						DIR_DELIM .. "textures" .. DIR_DELIM .. "base" .. 
						DIR_DELIM .. "pack" .. DIR_DELIM
end

--------------------------------------------------------------------------------
function menu.lastgame()
	if menu.last_game > 0 and menu.last_game <= #gamemgr.games then
		return gamemgr.games[menu.last_game]
	end
	
	if #gamemgr.games >= 1 then
		menu.last_game = 1
		return gamemgr.games[menu.last_game]
	end
	
	--error case!!
	return nil
end

--------------------------------------------------------------------------------
function menu.lastworld()
	if menu.last_world ~= nil and 
		menu.last_world > 0 and 
		menu.last_world <= #menu.worldlist then
		return menu.worldlist[menu.last_world]
	end
	
	if #menu.worldlist >= 1 then
		menu.last_world = 1
		return menu.worldlist[menu.last_world]
	end
	
	--error case!!
	return nil
end

--------------------------------------------------------------------------------
function menu.update_last_game(world_idx)
	if gamedata.selected_world <= #menu.worldlist then
		local world = menu.worldlist[gamedata.selected_world]
		
		for i=1,#gamemgr.games,1 do		
			if gamemgr.games[i].id == world.gameid then
				menu.last_game = i
				engine.setting_set("main_menu_last_game_idx",menu.last_game)
				break
			end
		end
	end
end

--------------------------------------------------------------------------------
function menubar.handle_buttons(fields)
	for i=1,#menubar.buttons,1 do
		if fields[menubar.buttons[i].btn_name] ~= nil then
			menu.last_game = menubar.buttons[i].index
			engine.setting_set("main_menu_last_game_idx",menu.last_game)
			menu.update_gametype()
		end
	end
end

--------------------------------------------------------------------------------
function menubar.refresh()
	menubar.formspec = "box[-2,7.625;15.75,1.75;BLK]"
	menubar.buttons = {}

	local button_base = -1.8
	
	local maxbuttons = #gamemgr.games
	
	if maxbuttons > 12 then
		maxbuttons = 12
	end
	
	for i=1,maxbuttons,1 do

		local btn_name = "menubar_btn_" .. gamemgr.games[i].id
		local buttonpos = button_base + (i-1) * 1.3
		if gamemgr.games[i].menuicon_path ~= nil and
			gamemgr.games[i].menuicon_path ~= "" then

			menubar.formspec = menubar.formspec ..
				"image_button[" .. buttonpos ..  ",7.9;1.3,1.3;"  ..
				gamemgr.games[i].menuicon_path .. ";" .. btn_name .. ";;true;false]"
		else
		
			local part1 = gamemgr.games[i].id:sub(1,5)
			local part2 = gamemgr.games[i].id:sub(6,10)
			local part3 = gamemgr.games[i].id:sub(11)
			
			local text = part1 .. "\n" .. part2
			if part3 ~= nil and
				part3 ~= "" then
				text = text .. "\n" .. part3
			end
			menubar.formspec = menubar.formspec ..
				"image_button[" .. buttonpos ..  ",7.9;1.3,1.3;;" ..btn_name ..
				";" .. text .. ";true;true]"
		end
		
		local toadd = {
			btn_name = btn_name,
			index = i,
		}
		
		table.insert(menubar.buttons,toadd)
	end
end

--------------------------------------------------------------------------------
function tabbuilder.dialog_create_world()
	local retval = 
		"label[2,1;World name]"..
		"field[4.5,1.4;6,0.5;te_world_name;;]" ..
		"label[2,2;Game]"..
		"button[5,4.5;2.6,0.5;world_create_confirm;Create]" ..
		"button[7.5,4.5;2.8,0.5;world_create_cancel;Cancel]" ..
		"textlist[4.2,1.9;5.8,2.3;games;" ..
		gamemgr.gamelist() ..
		";" .. menu.last_game .. "]"

	return retval
end

--------------------------------------------------------------------------------
function tabbuilder.dialog_delete_world()
	return	"label[2,2;Delete World \"" .. menu.lastworld().name .. "\"?]"..
			"button[3.5,4.2;2.6,0.5;world_delete_confirm;Yes]" ..
			"button[6,4.2;2.8,0.5;world_delete_cancel;No]"
end

--------------------------------------------------------------------------------
function tabbuilder.gettab()
	local retval = ""
	
	if tabbuilder.show_buttons then
		retval = retval .. tabbuilder.tab_header()
	end

	if tabbuilder.current_tab == "singleplayer" then
		retval = retval .. tabbuilder.tab_singleplayer()
	end
	
	if tabbuilder.current_tab == "multiplayer" then
		retval = retval .. tabbuilder.tab_multiplayer()
	end

	if tabbuilder.current_tab == "server" then
		retval = retval .. tabbuilder.tab_server()
	end
	
	if tabbuilder.current_tab == "settings" then
		retval = retval .. tabbuilder.tab_settings()
	end
	
	if tabbuilder.current_tab == "credits" then
		retval = retval .. tabbuilder.tab_credits()
	end
	
	if tabbuilder.current_tab == "dialog_create_world" then
		retval = retval .. tabbuilder.dialog_create_world()
	end
	
	if tabbuilder.current_tab == "dialog_delete_world" then
		retval = retval .. tabbuilder.dialog_delete_world()
	end
	
	retval = retval .. modmgr.gettab(tabbuilder.current_tab)
	retval = retval .. gamemgr.gettab(tabbuilder.current_tab)

	return retval
end

--------------------------------------------------------------------------------
function tabbuilder.handle_create_world_buttons(fields)
	
	if fields["world_create_confirm"] then
		
		local worldname = fields["te_world_name"]
		local gameindex = engine.get_textlist_index("games")
		
		if gameindex > 0 and
			worldname ~= "" then
			local message = engine.create_world(worldname,gameindex)
			
			menu.last_game = gameindex
			engine.setting_set("main_menu_last_game_idx",gameindex)
			
			if message ~= nil then
				gamedata.errormessage = message
			else
				menu.worldlist = engine.get_worlds()
				
				local worldlist = menu.worldlist
				
				if tabbuilder.current_tab == "singleplayer" then
					worldlist = menu.filtered_game_list_raw()
				end
				
				local index = 0
				
				for i=1,#worldlist,1 do
					if worldlist[i].name == worldname then
						index = i
						print("found new world index: " .. index)
						break
					end
				end
				
				if tabbuilder.current_tab == "singleplayer" then
					engine.setting_set("main_menu_singleplayer_world_idx",index)
				else
					menu.last_world = index
				end
			end
		else
			gamedata.errormessage = "No worldname given or no game selected"
		end
	end
	
	if fields["games"] then
		tabbuilder.skipformupdate = true
		return
	end
	
	tabbuilder.is_dialog = false
	tabbuilder.show_buttons = true
	tabbuilder.current_tab = engine.setting_get("main_menu_tab")
end

--------------------------------------------------------------------------------
function tabbuilder.handle_delete_world_buttons(fields)
	
	if fields["world_delete_confirm"] then
		if menu.last_world > 0 and 
			menu.last_world < #menu.worldlist then
			engine.delete_world(menu.last_world)
			menu.worldlist = engine.get_worlds()
			menu.last_world = 1
		end
	end
	
	tabbuilder.is_dialog = false
	tabbuilder.show_buttons = true
	tabbuilder.current_tab = engine.setting_get("main_menu_tab")
end

--------------------------------------------------------------------------------
function tabbuilder.handle_multiplayer_buttons(fields)
	if fields["favourites"] ~= nil then
		local event = explode_textlist_event(fields["favourites"])
		if event.typ == "DCL" then
			gamedata.address = menu.favorites[event.index].name
			if gamedata.address == nil then
				gamedata.address = menu.favorites[event.index].address
			end
			gamedata.port = menu.favorites[event.index].port
			gamedata.playername		= fields["te_name"]
			gamedata.password		= fields["te_pwd"]
			gamedata.selected_world = 0
			
			if gamedata.address ~= nil and
				gamedata.port ~= nil then
				
				engine.start()
			end
		end
		
		if event.typ == "CHG" then
			local address = menu.favorites[event.index].name
			if address == nil then
				address = menu.favorites[event.index].address
			end
			local port = menu.favorites[event.index].port
			
			if address ~= nil and
				port ~= nil then
				engine.setting_set("address",address)
				engine.setting_set("port",port)
			end
		end
		return
	end
	
	if fields["cb_public_serverlist"] ~= nil then
		engine.setting_setbool("public_serverlist",
			tabbuilder.tobool(fields["cb_public_serverlist"]))
			
		if engine.setting_getbool("public_serverlist") then
			menu.favorites = engine.get_favorites("online")
		else
			menu.favorites = engine.get_favorites("local")
		end
	end

	if fields["btn_delete_favorite"] ~= nil then
		local current_favourite = engine.get_textlist_index("favourites")
		engine.delete_favorite(current_favourite)
		menu.favorites = engine.get_favorites()
		
		engine.setting_set("address","")
		engine.setting_get("port","")
		
		return
	end

	if fields["btn_mp_connect"] ~= nil then
		gamedata.playername		= fields["te_name"]
		gamedata.password		= fields["te_pwd"]
		gamedata.address		= fields["te_address"]
		gamedata.port			= fields["te_port"]
		gamedata.selected_world = 0

		engine.start()
		return
	end
end

--------------------------------------------------------------------------------
function tabbuilder.handle_server_buttons(fields)

	local world_doubleclick = false

	if fields["worlds"] ~= nil then
		local event = explode_textlist_event(fields["worlds"])
		
		if event.typ == "DBL" then
			world_doubleclick = true
		end
	end
	
	if fields["cb_creative_mode"] then
		engine.setting_setbool("creative_mode",tabbuilder.tobool(fields["cb_creative_mode"]))
	end
	
	if fields["cb_enable_damage"] then
		engine.setting_setbool("enable_damage",tabbuilder.tobool(fields["cb_enable_damage"]))
	end

	if fields["start_server"] ~= nil or
		world_doubleclick then
		local selected = engine.get_textlist_index("srv_worlds")
		if selected > 0 then
			gamedata.playername		= fields["te_playername"]
			gamedata.password		= fields["te_pwd"]
			gamedata.address		= ""
			gamedata.port			= fields["te_serverport"]
			gamedata.selected_world	= selected
			
			engine.setting_set("main_menu_tab",tabbuilder.current_tab)
			engine.setting_set("main_menu_last_world_idx",gamedata.selected_world)
			
			menu.update_last_game(gamedata.selected_world)
			engine.start()
		end
	end
	
	if fields["world_create"] ~= nil then
		tabbuilder.current_tab = "dialog_create_world"
		tabbuilder.is_dialog = true
		tabbuilder.show_buttons = false
	end
	
	if fields["world_delete"] ~= nil then
		local selected = engine.get_textlist_index("srv_worlds")
		if selected > 0 then
			menu.last_world = engine.get_textlist_index("worlds")
			if menu.lastworld() ~= nil and
				menu.lastworld().name ~= nil and
				menu.lastworld().name ~= "" then
				tabbuilder.current_tab = "dialog_delete_world"
				tabbuilder.is_dialog = true
				tabbuilder.show_buttons = false
			else
				menu.last_world = 0
			end
		end
	end
	
	if fields["world_configure"] ~= nil then
		selected = engine.get_textlist_index("srv_worlds")
		if selected > 0 then
			modmgr.world_config_selected_world = selected
			if modmgr.init_worldconfig() then
				tabbuilder.current_tab = "dialog_configure_world"
				tabbuilder.is_dialog = true
				tabbuilder.show_buttons = false
			end
		end
	end
end

--------------------------------------------------------------------------------
function tabbuilder.tobool(text)
	if text == "true" then
		return true
	else
		return false
	end
end

--------------------------------------------------------------------------------
function tabbuilder.handle_settings_buttons(fields)
	if fields["cb_fancy_trees"] then
		engine.setting_setbool("new_style_leaves",tabbuilder.tobool(fields["cb_fancy_trees"]))
	end
		
	if fields["cb_smooth_lighting"] then
		engine.setting_setbool("smooth_lighting",tabbuilder.tobool(fields["cb_smooth_lighting"]))
	end
	if fields["cb_3d_clouds"] then
		engine.setting_setbool("enable_3d_clouds",tabbuilder.tobool(fields["cb_3d_clouds"]))
	end
	if fields["cb_opaque_water"] then
		engine.setting_setbool("opaque_water",tabbuilder.tobool(fields["cb_opaque_water"]))
	end
			
	if fields["cb_mipmapping"] then
		engine.setting_setbool("mip_map",tabbuilder.tobool(fields["cb_mipmapping"]))
	end
	if fields["cb_anisotrophic"] then
		engine.setting_setbool("anisotropic_filter",tabbuilder.tobool(fields["cb_anisotrophic"]))
	end
	if fields["cb_bilinear"] then
		engine.setting_setbool("bilinear_filter",tabbuilder.tobool(fields["cb_bilinear"]))
	end
	if fields["cb_trilinear"] then
		engine.setting_setbool("trilinear_filter",tabbuilder.tobool(fields["cb_trilinear"]))
	end
			
	if fields["cb_shaders"] then
		engine.setting_setbool("enable_shaders",tabbuilder.tobool(fields["cb_shaders"]))
	end
	if fields["cb_pre_ivis"] then
		engine.setting_setbool("preload_item_visuals",tabbuilder.tobool(fields["cb_pre_ivis"]))
	end
	if fields["cb_particles"] then
		engine.setting_setbool("enable_particles",tabbuilder.tobool(fields["cb_particles"]))
	end
	if fields["cb_finite_liquid"] then
		engine.setting_setbool("liquid_finite",tabbuilder.tobool(fields["cb_finite_liquid"]))
	end

	if fields["btn_change_keys"] ~= nil then
		engine.show_keys_menu()
	end
end

--------------------------------------------------------------------------------
function tabbuilder.handle_singleplayer_buttons(fields)

	local world_doubleclick = false

	if fields["worlds"] ~= nil then
		local event = explode_textlist_event(fields["worlds"])
		
		if event.typ == "DBL" then
			world_doubleclick = true
		end
	end
	
	if fields["cb_creative_mode"] then
		engine.setting_setbool("creative_mode",tabbuilder.tobool(fields["cb_creative_mode"]))
	end
	
	if fields["cb_enable_damage"] then
		engine.setting_setbool("enable_damage",tabbuilder.tobool(fields["cb_enable_damage"]))
	end

	if fields["play"] ~= nil or
		world_doubleclick then
		local selected = engine.get_textlist_index("sp_worlds")
		if selected > 0 then
			gamedata.selected_world	= menu.filtered_index_to_plain(selected)
			gamedata.singleplayer	= true
			
			engine.setting_set("main_menu_tab",tabbuilder.current_tab)
			engine.setting_set("main_menu_singleplayer_world_idx",selected)
			
			menu.update_last_game(gamedata.selected_world)
			
			engine.start()
		end
	end
	
	if fields["world_create"] ~= nil then
		tabbuilder.current_tab = "dialog_create_world"
		tabbuilder.is_dialog = true
		tabbuilder.show_buttons = false
	end
	
	if fields["world_delete"] ~= nil then
		local selected = engine.get_textlist_index("sp_worlds")
		if selected > 0 then
			menu.last_world = menu.filtered_index_to_plain(selected)
			if menu.lastworld() ~= nil and
				menu.lastworld().name ~= nil and
				menu.lastworld().name ~= "" then
				tabbuilder.current_tab = "dialog_delete_world"
				tabbuilder.is_dialog = true
				tabbuilder.show_buttons = false
			else
				menu.last_world = 0
			end
		end
	end
	
	if fields["world_configure"] ~= nil then
		selected = engine.get_textlist_index("sp_worlds")
		if selected > 0 then
			modmgr.world_config_selected_world = menu.filtered_index_to_plain(selected)
			if modmgr.init_worldconfig() then
				tabbuilder.current_tab = "dialog_configure_world"
				tabbuilder.is_dialog = true
				tabbuilder.show_buttons = false
			end
		end
	end
end

--------------------------------------------------------------------------------
function tabbuilder.tab_header()

	if tabbuilder.last_tab_index == nil then
		tabbuilder.last_tab_index = 1
	end
	
	local toadd = ""
	
	for i=1,#tabbuilder.current_buttons,1 do
		
		if toadd ~= "" then
			toadd = toadd .. ","
		end
		
		toadd = toadd .. tabbuilder.current_buttons[i].caption
	end
	return "tabheader[-0.3,-0.99;main_tab;" .. toadd ..";" .. tabbuilder.last_tab_index .. ";true;false]"
end

--------------------------------------------------------------------------------
function tabbuilder.handle_tab_buttons(fields)

	if fields["main_tab"] then
		local index = tonumber(fields["main_tab"])
		tabbuilder.last_tab_index = index
		tabbuilder.current_tab = tabbuilder.current_buttons[index].name
		
		engine.setting_set("main_menu_tab",tabbuilder.current_tab)
	end
	
	--handle tab changes
	if tabbuilder.current_tab ~= tabbuilder.old_tab then
		if tabbuilder.current_tab ~= "singleplayer" then
			menu.reset_gametype()
		end
	end
	
	if tabbuilder.current_tab == "singleplayer" then
		menu.update_gametype()
	end
	
	tabbuilder.old_tab = tabbuilder.current_tab
end

--------------------------------------------------------------------------------
function tabbuilder.init()
	tabbuilder.current_tab = engine.setting_get("main_menu_tab")
	
	if tabbuilder.current_tab == nil or
		tabbuilder.current_tab == "" then
		tabbuilder.current_tab = "singleplayer"
		engine.setting_set("main_menu_tab",tabbuilder.current_tab)
	end
	
	
	--initialize tab buttons
	tabbuilder.last_tab = nil
	tabbuilder.show_buttons = true
	
	tabbuilder.current_buttons = {}
	table.insert(tabbuilder.current_buttons,{name="singleplayer", caption="Singleplayer"})
	table.insert(tabbuilder.current_buttons,{name="multiplayer", caption="Client"})
	table.insert(tabbuilder.current_buttons,{name="server", caption="Server"})
	table.insert(tabbuilder.current_buttons,{name="settings", caption="Settings"})
	
	if engine.setting_getbool("main_menu_game_mgr") then
		table.insert(tabbuilder.current_buttons,{name="game_mgr", caption="Games"})
	end
	
	if engine.setting_getbool("main_menu_mod_mgr") then
		table.insert(tabbuilder.current_buttons,{name="mod_mgr", caption="Mods"})
	end
	table.insert(tabbuilder.current_buttons,{name="credits", caption="Credits"})
	
	
	for i=1,#tabbuilder.current_buttons,1 do
		if tabbuilder.current_buttons[i].name == tabbuilder.current_tab then
			tabbuilder.last_tab_index = i
		end
	end
	
	menu.update_gametype()
end

--------------------------------------------------------------------------------
function tabbuilder.tab_multiplayer()
	local retval =
		"vertlabel[0,-0.25;CLIENT]" ..
		"label[1,-0.25;Favorites:]"..
		"label[1,4.25;Address/Port]"..
		"label[9,0;Name/Password]" ..
		"field[1.25,5.25;5.5,0.5;te_address;;" ..engine.setting_get("address") .."]" ..
		"field[6.75,5.25;2.25,0.5;te_port;;" ..engine.setting_get("port") .."]" ..
		"button[6.45,3.95;2.25,0.5;btn_delete_favorite;Delete]" ..
		"button[9,4.95;2.5,0.5;btn_mp_connect;Connect]" ..
		"field[9.25,1;2.5,0.5;te_name;;" ..engine.setting_get("name") .."]" ..
		"pwdfield[9.25,1.75;2.5,0.5;te_pwd;]" ..
		"checkbox[1,3.6;cb_public_serverlist;Public Serverlist;" ..
		dump(engine.setting_getbool("public_serverlist")) .. "]" ..
		"textlist[1,0.35;7.5,3.35;favourites;"

	if #menu.favorites > 0 then
		retval = retval .. render_favourite(menu.favorites[1])
		
		for i=2,#menu.favorites,1 do
			retval = retval .. "," .. render_favourite(menu.favorites[i])
		end
	end

	retval = retval .. ";1]"

	return retval
end

--------------------------------------------------------------------------------
function tabbuilder.tab_server()
	local retval = 
		"button[4,4.15;2.6,0.5;world_delete;Delete]" ..
		"button[6.5,4.15;2.8,0.5;world_create;New]" ..
		"button[9.2,4.15;2.55,0.5;world_configure;Configure]" ..
		"button[8.5,4.9;3.25,0.5;start_server;Start Game]" ..
		"label[4,-0.25;Select World:]"..
		"vertlabel[0,-0.25;START SERVER]" ..
		"checkbox[0.5,0.25;cb_creative_mode;Creative Mode;" ..
		dump(engine.setting_getbool("creative_mode")) .. "]"..
		"checkbox[0.5,0.7;cb_enable_damage;Enable Damage;" ..
		dump(engine.setting_getbool("enable_damage")) .. "]"..
		"field[0.8,2.2;3,0.5;te_playername;Name;" ..
		engine.setting_get("name") .. "]" ..
		"pwdfield[0.8,3.2;3,0.5;te_passwd;Password]" ..
		"field[0.8,5.2;3,0.5;te_serverport;Server Port;30000]" ..
		"textlist[4,0.25;7.5,3.7;srv_worlds;"
	
	if #menu.worldlist > 0 then
		retval = retval .. menu.worldlist[1].name .. 
						" [[" .. menu.worldlist[1].gameid .. "]]"
				
		for i=2,#menu.worldlist,1 do
			retval = retval .. "," .. menu.worldlist[i].name .. 
						" [[" .. menu.worldlist[i].gameid .. "]]"
		end
	end
				
	retval = retval .. ";" .. menu.last_world .. "]"
		
	return retval
end

--------------------------------------------------------------------------------
function tabbuilder.tab_settings()
	return	"vertlabel[0,0;SETTINGS]" ..
			"checkbox[1,0.75;cb_fancy_trees;Fancy trees;" 		.. dump(engine.setting_getbool("new_style_leaves"))	.. "]"..
			"checkbox[1,1.25;cb_smooth_lighting;Smooth Lighting;".. dump(engine.setting_getbool("smooth_lighting"))	.. "]"..
			"checkbox[1,1.75;cb_3d_clouds;3D Clouds;" 			.. dump(engine.setting_getbool("enable_3d_clouds"))	.. "]"..
			"checkbox[1,2.25;cb_opaque_water;Opaque Water;" 		.. dump(engine.setting_getbool("opaque_water"))		.. "]"..
			
			"checkbox[4,0.75;cb_mipmapping;Mip-Mapping;" 		.. dump(engine.setting_getbool("mip_map"))			.. "]"..
			"checkbox[4,1.25;cb_anisotrophic;Anisotropic Filtering;".. dump(engine.setting_getbool("anisotropic_filter"))	.. "]"..
			"checkbox[4,1.75;cb_bilinear;Bi-Linear Filtering;"	.. dump(engine.setting_getbool("bilinear_filter"))	.. "]"..
			"checkbox[4,2.25;cb_trilinear;Tri-Linear Filtering;"	.. dump(engine.setting_getbool("trilinear_filter"))	.. "]"..
			
			"checkbox[7.5,0.75;cb_shaders;Shaders;"				.. dump(engine.setting_getbool("enable_shaders"))		.. "]"..
			"checkbox[7.5,1.25;cb_pre_ivis;Preload item visuals;".. dump(engine.setting_getbool("preload_item_visuals"))	.. "]"..
			"checkbox[7.5,1.75;cb_particles;Enable Particles;"	.. dump(engine.setting_getbool("enable_particles"))	.. "]"..
			"checkbox[7.5,2.25;cb_finite_liquid;Finite Liquid;"	.. dump(engine.setting_getbool("liquid_finite"))		.. "]"..
			
			"button[1,3.75;2.25,0.5;btn_change_keys;Change keys]"
end

--------------------------------------------------------------------------------
function tabbuilder.tab_singleplayer()
	local index = engine.setting_get("main_menu_singleplayer_world_idx")
	
	if index == nil then
		index = 0
	end

	return	"button[4,4.15;2.6,0.5;world_delete;Delete]" ..
			"button[6.5,4.15;2.8,0.5;world_create;New]" ..
			"button[9.2,4.15;2.55,0.5;world_configure;Configure]" ..
			"button[8.5,4.95;3.25,0.5;play;Play]" ..
			"label[4,-0.25;Select World:]"..
			"vertlabel[0,-0.25;SINGLE PLAYER]" ..
			"checkbox[0.5,0.25;cb_creative_mode;Creative Mode;" ..
			dump(engine.setting_getbool("creative_mode")) .. "]"..
			"checkbox[0.5,0.7;cb_enable_damage;Enable Damage;" ..
			dump(engine.setting_getbool("enable_damage")) .. "]"..
			"textlist[4,0.25;7.5,3.7;sp_worlds;" ..
			menu.filtered_game_list() ..
			";" .. index .. "]" ..
			menubar.formspec
end

--------------------------------------------------------------------------------
function tabbuilder.tab_credits()
	return	"vertlabel[0,-0.5;CREDITS]" ..
			"label[0.5,3;Minetest " .. engine.get_version() .. "]" ..
			"label[0.5,3.3;http://minetest.net]" .. 
			"image[0.5,1;" .. menu.basetexturedir .. "logo.png]" ..
			"textlist[3.5,-0.25;8.5,5.8;list_credits;" ..
			"#YLWCore Developers," ..
			"Perttu Ahola (celeron55) <celeron55@gmail.com>,"..
			"Ryan Kwolek (kwolekr) <kwolekr@minetest.net>,"..
			"PilzAdam <pilzadam@minetest.net>," ..
			"IIya Zhuravlev (thexyz) <xyz@minetest.net>,"..
			"Lisa Milne (darkrose) <lisa@ltmnet.com>,"..
			"Maciej Kasatkin (RealBadAngel) <mk@realbadangel.pl>,"..
			"proller <proler@gmail.com>,"..
			"sfan5 <sfan5@live.de>,"..
			"kahrl <kahrl@gmx.net>,"..
			","..
			"#YLWActive Contributors," ..
			"sapier,"..
			"Vanessa Ezekowitz (VanessaE) <vanessaezekowitz@gmail.com>,"..
			"Jurgen Doser (doserj) <jurgen.doser@gmail.com>,"..
			"Jeija <jeija@mesecons.net>,"..
			"MirceaKitsune <mirceakitsune@gmail.com>,"..
			"ShadowNinja"..
			"dannydark <the_skeleton_of_a_child@yahoo.co.uk>"..
			"0gb.us <0gb.us@0gb.us>,"..
			"," ..
			"#YLWPrevious Contributors," ..
			"Guiseppe Bilotta (Oblomov) <guiseppe.bilotta@gmail.com>,"..
			"Jonathan Neuschafer <j.neuschaefer@gmx.net>,"..
			"Nils Dagsson Moskopp (erlehmann) <nils@dieweltistgarnichtso.net>,"..
			"Constantin Wenger (SpeedProg) <constantin.wenger@googlemail.com>,"..
			"matttpt <matttpt@gmail.com>,"..
			"JacobF <queatz@gmail.com>,"..
			";0;true]"
end

--------------------------------------------------------------------------------
function tabbuilder.checkretval(retval)

	if retval ~= nil then
		if retval.current_tab ~= nil then
			tabbuilder.current_tab = retval.current_tab
		end
		
		if retval.is_dialog ~= nil then
			tabbuilder.is_dialog = retval.is_dialog
		end
		
		if retval.show_buttons ~= nil then
			tabbuilder.show_buttons = retval.show_buttons
		end
		
		if retval.skipformupdate ~= nil then
			tabbuilder.skipformupdate = retval.skipformupdate
		end
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- initialize callbacks
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
engine.button_handler = function(fields)
	print("Buttonhandler: tab: " .. tabbuilder.current_tab .. " fields: " .. dump(fields))
	
	if fields["btn_error_confirm"] then
		gamedata.errormessage = nil
	end
	
	local retval = modmgr.handle_buttons(tabbuilder.current_tab,fields)
	tabbuilder.checkretval(retval)
	
	retval = gamemgr.handle_buttons(tabbuilder.current_tab,fields)
	tabbuilder.checkretval(retval) 
	
	if tabbuilder.current_tab == "dialog_create_world" then
		tabbuilder.handle_create_world_buttons(fields)
	end
	
	if tabbuilder.current_tab == "dialog_delete_world" then
		tabbuilder.handle_delete_world_buttons(fields)
	end
	
	if tabbuilder.current_tab == "singleplayer" then
		tabbuilder.handle_singleplayer_buttons(fields)
	end
	
	if tabbuilder.current_tab == "multiplayer" then
		tabbuilder.handle_multiplayer_buttons(fields)
	end
	
	if tabbuilder.current_tab == "settings" then
		tabbuilder.handle_settings_buttons(fields)
	end
	
	if tabbuilder.current_tab == "server" then
		tabbuilder.handle_server_buttons(fields)
	end
	
	--tab buttons
	tabbuilder.handle_tab_buttons(fields)
	
	--menubar buttons
	menubar.handle_buttons(fields)
	
	if not tabbuilder.skipformupdate then
		--update menu
		print("updating menu:" .. tabbuilder.current_tab)
		update_menu()
	else
		tabbuilder.skipformupdate = false
	end
end

--------------------------------------------------------------------------------
engine.event_handler = function(event)
	if event == "MenuQuit" then
		if tabbuilder.is_dialog then
			tabbuilder.is_dialog = false
			tabbuilder.show_buttons = true
			tabbuilder.current_tab = engine.setting_get("main_menu_tab")
			update_menu()
		else
			engine.close()
		end
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- menu startup
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
init_globals()
menu.init()
tabbuilder.init()
menubar.refresh()
update_menu()
