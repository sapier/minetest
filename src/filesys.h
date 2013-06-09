/*
Minetest
Copyright (C) 2013 celeron55, Perttu Ahola <celeron55@gmail.com>

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

#ifndef FILESYS_HEADER
#define FILESYS_HEADER

#include <string>
#include <vector>
#include "exceptions.h"

#ifdef _WIN32 // WINDOWS
#define DIR_DELIM "\\"
#define DIR_DELIM_C '\\'
#else // POSIX
#define DIR_DELIM "/"
#define DIR_DELIM_C '/'
#endif

namespace fs
{

struct DirListNode
{
	std::string name;
	bool dir;
};
std::vector<DirListNode> GetDirListing(std::string path);

// Returns true if already exists
bool CreateDir(std::string path);

bool PathExists(std::string path);

bool IsDir(std::string path);

// Only pass full paths to this one. True on success.
// NOTE: The WIN32 version returns always true.
bool RecursiveDelete(std::string path);

bool DeleteSingleFileOrEmptyDirectory(std::string path);

/* Multiplatform */

// The path itself not included
void GetRecursiveSubPaths(std::string path, std::vector<std::string> &dst);

// Tries to delete all, returns false if any failed
bool DeletePaths(const std::vector<std::string> &paths);

// Only pass full paths to this one. True on success.
bool RecursiveDeleteContent(std::string path);

// Create all directories on the given path that don't already exist.
bool CreateAllDirs(std::string path);

// Copy directory and all subdirectorys
bool CopyDir(std::string source,std::string target);

//get absolute path from a given relative one
std::string AbsolutePath(std::string path);

}//fs

#endif

