local meta = FindMetaTable( "Player" )

module( "player", package.seeall )


function GetBySteamID( strSteamID )
	for k, v in ipairs( player.GetAll() ) do
		if ( v:SteamID() == strSteamID ) then return v end
	end
	
	return nil
end

function meta:SQLId()
	if !self._GTSqlID then
		
		if !self.SteamID then
			debug.traceback()
			Error("Trying to get player steamid before player is created!")
		end
		
		local SteamId = self:SteamID()
		local Findings = {}
		
		for w in string.gmatch( SteamId , "%d+") do
			table.insert( Findings, w )
		end
		
		if #Findings == 3 then
			self._GTSqlID = (tonumber(Findings[3]) * 2) + tonumber(Findings[2])
		else
			if SteamId != "STEAM_ID_PENDING" && SteamId != "UNKNOWN" then
				SQLLog( 'error', "sql id could not be found (".. tostring(SteamId) ..")\n" )
			end
			return 
		end
		
	end

	return self._GTSqlID
end
