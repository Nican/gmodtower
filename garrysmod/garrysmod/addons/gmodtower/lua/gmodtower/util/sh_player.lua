
module( "player", package.seeall )


function GetBySteamID( strSteamID )
	for k, v in ipairs( player.GetAll() ) do
		if ( v:SteamID() == strSteamID ) then return v end
	end
	
	return nil
end
