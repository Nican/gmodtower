AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("sh_room.lua")
AddCSLuaFile("sh_entity.lua")

include("shared.lua")
include("sh_room.lua")
include("sh_entity.lua")
include("entity.lua")

module("Room", package.seeall )



function Load( ply )

	local rooment = GetUnusedRoom()

	if not rooment then
		error("Could not find an available room")
	end

	room:SetLoaded( true )
	room:ClearRoom()

	local db = SQL.getDB()
	local map = db:escape( string.lower( game.GetMap() ) )
	local query = db:query( string.format( "SELECT `data` FROM  `gm_room` WHERE `map`='%s' AND `userid`=%d LIMIT 1", map, ply:SQLId() ) )
	

	query:SetOption( OPTION_NUMERIC_FIELDS, true )
	query:SetOption( OPTION_NAMED_FIELDS, false )

	query.onSuccess = function()

		local data = query:getData()

		if #data > 0 then 
			rooment:LoadData( data[1][1] ) --Get the first column, of the first row
		end

	end

	query.onFailure = function( query, err )
		room:SetLoaded( false )
		--TODO: Show error to the client that there is an internal error
		print("Database errror when loading the room: " .. tostring( err ) )
	end

	query:start()

end


function GetUnusedRoom()

	for _, ent in pairs( List ) do

		if not ent:IsLoaded() then
			return ent
		end

	end

end