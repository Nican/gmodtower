if SERVER then
	AddCSLuaFile("gmt.lua")
end

module("GMT", package.seeall )

_G.DEBUG = true

local function IncludeDir( utilDir ) 
	local utilFiles = file.FindInLua( utilDir .. "*.lua")

	for _, name in ipairs( utilFiles ) do

		local prefix = string.sub( name, 0, 2 )
		local fullPath = utilDir .. name
		
		if prefix == "sv" then
			
			if SERVER then
				include( fullPath )
			end
			
		elseif prefix == "cl" then
			
			if SERVER then
				AddCSLuaFile( fullPath )
			else
				include( fullPath )
			end
			
		elseif prefix == "sh" then
			
			if SERVER then
				AddCSLuaFile( fullPath )
			end
			
			include( fullPath )
		else
			ErrorNoHalt("Unkown prefix on lua file: " .. name )
		end
		
	end
end

function Load()

	IncludeDir( "gmodtower/util/" ) 

	if SERVER then
		include("gmodtower/sql.lua")
		include("gmodtower/db/init.lua")
		include("gmodtower/inventory/init.lua")
		include("gmodtower/group/init.lua")
		include("gmodtower/topmenu/init.lua")
		include("gmodtower/scoreboard/init.lua")
		include("gmodtower/room/init.lua")
	else
		include("gmodtower/inventory/cl_init.lua")
		include("gmodtower/group/cl_init.lua")
		include("gmodtower/topmenu/cl_init.lua")
		include("gmodtower/scoreboard/cl_init.lua")
		include("gmodtower/room/cl_init.lua")
	end

	IncludeDir( "gmodtower/base/" ) 

end

if SERVER then
	concommand.Add("gmt_reload", Load )
else
	concommand.Add("gmt_reload_cl", Load )
end

Load()