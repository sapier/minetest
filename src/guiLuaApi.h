/*
Minetest
Copyright (C) 2013 sapier

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation; either version 2.1 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/

#ifndef GUILUAAPI_H_
#define GUILUAAPI_H_

/******************************************************************************/
/* Includes                                                                   */
/******************************************************************************/
#include "serverlist.h"

/******************************************************************************/
/* Typedefs and macros                                                        */
/******************************************************************************/
typedef int (*lua_CFunction) (lua_State *L);

/******************************************************************************/
/* forward declarations                                                       */
/******************************************************************************/
class GUIEngine;


/******************************************************************************/
/* declarations                                                               */
/******************************************************************************/

/** Implementation of lua api support for mainmenu */
class guiLuaApi {

public:
	/**
	 * initialize given Lua stack
	 * @param L lua stack to initialize
	 * @param engine pointer to GUIEngine element to use as reference
	 */
	static void initialize(lua_State* L,GUIEngine* engine);

	/** default destructor */
	virtual ~guiLuaApi() {}

private:
	/**
	 * read a text variable from gamedata table within lua stack
	 * @param L stack to read variable from
	 * @param name name of variable to read
	 * @return string value of requested variable
	 */
	static std::string getTextData(lua_State *L, std::string name);

	/**
	 * read a integer variable from gamedata table within lua stack
	 * @param L stack to read variable from
	 * @param name name of variable to read
	 * @return integer value of requested variable
	 */
	static int getIntegerData(lua_State *L, std::string name,bool& valid);

	/**
	 * read a bool variable from gamedata table within lua stack
	 * @param L stack to read variable from
	 * @param name name of variable to read
	 * @return bool value of requested variable
	 */
	static int getBoolData(lua_State *L, std::string name,bool& valid);

	/**
	 * get the corresponding engine pointer from a lua stack
	 * @param L stack to read pointer from
	 * @return pointer to GUIEngine
	 */
	static GUIEngine* get_engine(lua_State *L);


	/**
	 * register a static member function as lua api call at current position of stack
	 * @param L stack to registe fct to
	 * @param name of function within lua
	 * @param fct C-Function to call on lua call of function
	 * @param top current top of stack
	 */
	static bool registerFunction(	lua_State* L,
									const char* name,
									lua_CFunction fct,
									int top
								);

	/**
	 * check if a path is within some of minetests folders
	 * @param path path to check
	 * @return true/false
	 */
	static bool isMinetestPath(std::string path);

	//api calls

	static int l_start(lua_State *L);

	static int l_close(lua_State *L);

	static int l_create_world(lua_State *L);

	static int l_delete_world(lua_State *L);

	static int l_get_worlds(lua_State *L);

	static int l_get_games(lua_State *L);

	static int l_get_favorites(lua_State *L);

	static int l_delete_favorite(lua_State *L);

	static int l_get_version(lua_State *L);

	//gui

	static int l_show_keys_menu(lua_State *L);

	static int l_show_file_open_dialog(lua_State *L);

	static int l_set_topleft_text(lua_State *L);

	static int l_set_clouds(lua_State *L);

	static int l_get_textlist_index(lua_State *L);

	static int l_set_background(lua_State *L);

	static int l_update_formspec(lua_State *L);

	//settings

	static int l_setting_set(lua_State *L);

	static int l_setting_get(lua_State *L);

	static int l_setting_getbool(lua_State *L);

	static int l_setting_setbool(lua_State *L);

	//filesystem

	static int l_get_scriptdir(lua_State *L);

	static int l_get_modpath(lua_State *L);

	static int l_get_gamepath(lua_State *L);

	static int l_get_dirlist(lua_State *L);

	static int l_create_dir(lua_State *L);

	static int l_delete_dir(lua_State *L);

	static int l_copy_dir(lua_State *L);

	static int l_extract_zip(lua_State *L);


};

#endif
