local hook = hook
local timer = timer
local table = table
local umsg = umsg
local  ipairs = ipairs
local ValidEntity = ValidEntity
local tostring = tostring

module("Inventory.Network", package.seeall )

function playerProcess( ply, inv )
	
	if !ValidEntity( ply ) then
		return
	end
	
	local ToSend = {}
	local TotalSize = 0
	
	while #inv._NetworkQueue > 0 do
	
		local carrier = table.remove( inv._NetworkQueue )
		local packet = carrier:GetNetworkPacket()
		
		if TotalSize + packet:Size() > 220 then
			table.insert( inv._NetworkQueue, carrier )
			break
		end
		
		table.insert( ToSend, packet )
	
	end
	
	if #ToSend == 0 then
		return
	end
	
	umsg.Start("Inv", ply )
		
		umsg.Char( 0 )
		umsg.Char( #ToSend )
		
		for _, packet in ipairs( ToSend ) do
			packet:Write()
		end
		
	umsg.End()
	
	if #inv._NetworkQueue > 0 then
		timer.Simple( 0.2, playerProcess, ply, inv )
	end
	
end 

function insert( carrier )
	local ply = carrier:GetPlayer()
	local inv = carrier:GetInventory()
	
	--SHIT: TODO: Fix the timer to a normal named timer. This will create a timer for ever item changed!
	timer.Simple( 0.0, playerProcess, ply, inv )
	
	if !inv._NetworkQueue then
		inv._NetworkQueue = {}
	end
	
	if not table.HasValue( inv._NetworkQueue, carrier ) then
		table.insert( inv._NetworkQueue, carrier )
	end
	
end