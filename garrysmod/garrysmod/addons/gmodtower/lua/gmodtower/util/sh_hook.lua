local pairs = pairs
local unpack = unpack
local hookTable = hook.GetTable()
local hook = hook
local print = print

module("hook2")

local function GetArguments( status, ... )
	local args = {...}
	if status && args[1] != nil then
		return args
	end
end

function hook.Remove( event_name, name )
	
	if hookTable[ event_name ] then
		hookTable[ event_name ][ name ] = nil
	end
	
end

function hook.Call( name, gm, ... )
	
	local HookTable = hookTable[ name ]
	local Args
	
	if HookTable then
		
		for k, v in pairs( HookTable ) do 
			
			// Call hook function
			Args = GetArguments( SafeCall( v, ... ) )
			
			// Allow hooks to override return values
			if Args then			
				return unpack( Args )
			end
			
		end
		
	end
	
	if gm && gm[ name ] then
		
		// This calls the actual gamemode function - after all the hooks have had chance to override
		Args = GetArguments( SafeCall( gm[ name ], gm, ... ) )
		
		if Args then
			return unpack( Args )
		end
		
	end
	
end
