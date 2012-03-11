module("Room", package.seeall )

List = {}

function Register( rooment )

	if not IsValid( rooment ) then
		error("Attempt to register non-valid room: " .. tostring(rooment) )
	end

	local id = table.insert( List, rooment )

	--Hard coded for now, need to be fixed per-map later.
	local localMin = Vector(-10.0000, -300.0000, -33.1250)
	local localMax = Vector(314.0000, 705.0000, 246.8750)

	local min = room:LocalToWorld( localMin )
	local max = room:LocalToWorld( localMax )

	OrderVectors( min, max )

	rooment:SetetBounds( min, max )
	rooment:SetId( id )

end


function GetPlayerRoom( ply )

	for _, rooment in pairs( List ) do
		if rooment:GetOwner() == ply then
			return rooment
		end
	end

end