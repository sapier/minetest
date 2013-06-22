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

#ifndef S_THREAD_ASYNC_H_
#define S_THREAD_ASYNC_H_

class ScriptApi;
class JobStore;
class ModApiBase;

#include <vector>
#include "util/thread.h"

class AsyncThread : public SimpleThread {
public:
	AsyncThread();
	void* Thread();

	inline void setScriptapi(ScriptApi* val) {
		m_scriptapi = val;
	}
	inline void setJobStore(JobStore* val) {
		m_jobstore = val;
	}
	inline void setModList(std::vector<ModApiBase*>* val) {
		m_modlist = *val;
	}

private:
	ScriptApi* m_scriptapi;
	JobStore*  m_jobstore;
	std::vector<ModApiBase*> m_modlist;
};
#endif /* S_THREAD_ASYNC_H_ */
