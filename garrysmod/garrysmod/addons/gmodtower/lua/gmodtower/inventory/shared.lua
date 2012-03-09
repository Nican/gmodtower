local shared = {"sh_inventory.lua","sh_bag.lua","sh_slot.lua","sh_baseitem.lua","sh_items.lua", "sh_trace.lua", "sh_util.lua","sh_entity.lua"}

for _, v in ipairs( shared ) do
	include( v )
	
	if SERVER then
		AddCSLuaFile( v )
	end
end


module("Inventory" )

MaxTraceDistance = 1024