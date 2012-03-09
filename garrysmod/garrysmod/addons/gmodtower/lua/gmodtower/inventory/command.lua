local concommand = concommand
local tonumber = tonumber
local ipairs = ipairs
local ents = ents
local ValidEntity = ValidEntity
local clientError = clientError

module("Inventory" )

local function toNumberTable( args )
	
	for k, v in ipairs( args ) do
		
		args[ k ] = tonumber( v )
		
		if args[k] == nil then
			clientError("Invalid input. Hacking attempt detected.")
		end
		
	end
	
end

concommand.ClientAdd("inv_swap", function( ply, cmd, args )
	
	local inv = ply.Inventory
	
	if !inv then
		clientError("Player does not yet have an inventory.")
	end
	
	if #args != 5 then
		clientError("Invalid input. Hacking attempt detected.")
	end
	
	toNumberTable( args )
	
	local bag1 = 	args[1]
	local slot1 = 	args[2]
	local bag2 = 	args[3]
	local slot2 = 	args[4]
	local amount =	args[5]
	
	local slot1 = inv:GetSlot(bag1, slot1)
	local slot2 = inv:GetSlot(bag2, slot2)
	
	Util.Swap( slot1, slot2, amount )
	
end )

concommand.ClientAdd("inv_spawn", function( ply, cmd, args )
	
	local inv = ply.Inventory
	
	if !inv then
		clientError("Player does not yet have an inventory.")
	end
	
	if #args != 6 then
		clientError("Invalid input. Hacking attempt detected.")
	end
	
	toNumberTable( args )
	
	local bag =  	args[1]
	local slot = 	args[2]
	local aimX = 	args[3]
	local aimY = 	args[4]
	local aimZ = 	args[5]
	local rotation = args[6]
	
	local eyePos = ply:EyePos()
	local aim = Vector(aimX, aimY, aimZ)
	local slot = inv:GetSlot(bag, slot)

	aim:Normalize()
	
	Util.Drop( slot, eyePos, aim, rotation )
	
end )

concommand.ClientAdd("inv_grab", function( ply, cmd, args )
	
	local inv = ply.Inventory
	
	if !inv then
		clientError("Player does not yet have an inventory.")
	end
	
	if #args != 3 then
		clientError("Invalid input. Hacking attempt detected.")
	end
	
	toNumberTable( args )
	
	local bag =  	args[1]
	local slot = 	args[2]
	local entId = 	args[3]
	
	local slot = inv:GetSlot(bag, slot)
	local ent = ents.GetByIndex( entId )
	
	if not ValidEntity( ent ) then
		clientError("Grabbing an invalid entity.")
	end
	
	if ply:EyePos():Distance( ent:GetPos() ) > MaxTraceDistance then
		clientError("Entity is too far away.")
	end
	
	Util.Grab( slot, ent )
	
end )

concommand.ClientAdd("inv_move", function( ply, cmd, args )
	
	local inv = ply.Inventory
	
	if !inv then
		clientError("Player does not yet have an inventory.")
	end
	
	if #args != 5 then
		clientError("Invalid input. Hacking attempt detected.")
	end
	
	toNumberTable( args )
	
	local entId =  	args[1]
	local aimX = 	args[2]
	local aimY = 	args[3]
	local aimZ = 	args[4]
	local rotation = args[5]
	
	local ent = ents.GetByIndex( entId )
	
	if not ValidEntity( ent ) then
		clientError("Grabbing an invalid entity.")
	end
	
	local eyePos = ply:EyePos()
	local aim = Vector(aimX, aimY, aimZ)

	aim:Normalize()
	
	if eyePos:Distance( ent:GetPos() ) > MaxTraceDistance then
		clientError("Entity is too far away.")
	end
	
	Util.Move( ent, eyePos, aim, rot, {ply,ent} )
	
end )


