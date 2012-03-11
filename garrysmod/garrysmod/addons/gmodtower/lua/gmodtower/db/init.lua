include("column.lua")
include("player.lua")
include("basic.lua")

module("SQL", package.seeall )

DEBUG = true
ColumnInfo = {}
LateLoadPlayers = {}

local StartUserTableQuery = [[
CREATE TABLE IF NOT EXISTS `gm_users` (
  `id` int(11) unsigned NOT NULL DEFAULT '0',
  `steamid` varchar(20) DEFAULT NULL,
  `ip` varchar(15) DEFAULT NULL,
   PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;	]]


hook.Add("DatabaseConnect", "StartUserTable", function()

	local query = getDB():query(StartUserTableQuery)
	query.onSuccess = function( query )
		SelectColumns()
	end
	query.onError = function( query, err )
		error("Unable to load database: " .. tostring( err ) )
	end

	query:start()

end )

function SelectColumns()

	local query = getDB():query("DESCRIBE `gm_users`")
	query:SetOption(OPTION_NUMERIC_FIELDS, true )
	query.onSuccess = function( query )
		
		if status != 1 then
			ErrorNoHalt( "Could not get table description: " .. err )
			return
		end
		
		//ColumnInfo will hold the column informaton 
		for _, v in pairs( query:getData() ) do
			ColumnInfo[ v[1] ] = v[2]
		end
		
		StartColums()
		
		for _, ply in pairs( LateLoadPlayers ) do
			SafeCall( LoadPlayer, ply )
		end
			
		LateLoadPlayers = nil
		
	end )

	query.onError = function( query, err )
		error("Unable to load database: " .. tostring( err ) )
	end

	query:start()

end

function GetColumns()
	return Colums
end

function StartColums()

	if Colums then
		return
	end
	
	if DEBUG then
		print("Starting columns!")
	end
	
	Colums = {}
	AlterTableQuery = {}
	
	hook.Call("SQLStartColumns", GAMEMODE )
	
	if DEBUG then
		PrintTable( AlterTableQuery )
	end
	
	if #AlterTableQuery > 0 then
	
		local AlterList = table.concat( AlterTableQuery, "," )
		
		tmysql.query("ALTER TABLE `gm_users` " .. AlterList, function( res, status, err )
	
			if status != 1 then
				ErrorNoHalt( "Could not add new columns: " .. err )
				return
			end
			
		end )
	
	end
	
	//Just some garbage collecting to make sure it won't be added twice
	hook.GetTable().SQLStartColumns = nil
	AlterTableQuery = nil
	
end

local LogIp = "REPLACE INTO `gm_log_ip`(`user`,`ip`) VALUES (%s,INET_ATON('%s'))"
function LoadPlayer( ply )
	ply.SQL = SQLPlayer.Init( ply )
	ply.SQL:ExecuteSelect()
	
	ply.NextSQLUpdate = CurTime() + 5

	local query = getDB():query( string.format( LogIp, ply:SQLId(), ply.SQL:GetIP() ) )
	query.onError = function( query, err )
		print("Could not log player ip: " .. tostring(err) )
	end
	query:start()
	
end

RepairCallback = function( res, status, error )
	
	local EndString = ""
	
	if status != 1 then
		EndString = "Repair callback: " .. error
	else
		for _, v in pairs( res ) do
			EndString = EndString .. table.concat( v, "\t") .. "\n"
		end
	end

	SQLLog('error', "Repair table crashed: " .. EndString )

end

ErrorCheckCallback = function( origin, res, status, error )
	
	if status != 1 then
		SQLLog('error', 'Origin: ' .. tostring(origin) .. "\n MySQL Error: " .. error )
	end
	
end

hook.Add("PlayerAuthed", "GtowerSelectSQL", function(ply, steamid)
	
	if ply:IsBot() then
		return
	end
	
	if LateLoadPlayers then
		table.insert( LateLoadPlayers, ply )
	else
		LoadPlayer( ply )
	end
	
end )

hook.Add("PlayerDeath", "GtowerSQLPlayerDeath", function(ply)
	if !ply:IsBot() && ply.SQL then
		ply.SQL:Update( false )
	end
end)

hook.Add("PlayerThink", "GTowerSQLUpdate", function(ply)
	if !ply:IsBot() && ply.SQL && ply.NextSQLUpdate && CurTime() > ply.NextSQLUpdate then
		ply.NextSQLUpdate = CurTime() + 5
		ply.SQL:Update( false )
	end
end)

hook.Add("PlayerDisconnected", "GtowerSQLDisconnect", function(ply)
	
	if !ply:IsBot() && ply.SQL then
		ply.SQL:Update( true )
	end
end )


hook.Add( "MapChange", "GtowerSQLShutDown", function()

	Msg("Map change, mysql shut down.")

    for k, v in pairs( player.GetAll() ) do
		if !v:IsBot() && v.SQL then
			v.SQL:Update( true )
		end
    end 
	
	//Remove hooks to prevent any confusion
	hook.Remove("PlayerDisconnected", "GtowerSQLDisconnect")
	hook.Remove("PlayerDeath", "GtowerSQLPlayerDeath")
	hook.Remove("PlayerAuthed", "GtowerSelectSQL")
	hook.Remove("PlayerThink", "GTowerSQLUpdate")

end )

hook.Add("CanChangeLevel", "SavingPlayers", function()
	for _, ply in pairs( player.GetAll() ) do 
		if ply.SQL && ply.SQL.UpdateInProgress == true then
			return false
		end
	end
end )

concommand.Add("gmt_forceupdate", function( ply, cmd, args )
	
	if ply == NULL || ply:IsAdmin() then
		
		for _, v in ipairs( player.GetAll() ) do
			if !v:IsBot() && v.SQL then
				v.SQL:Update( false, true )
			end
	    end 
	
	end

end )

player.sqlGetAll = function()
	local all = {}
	
	for _, ply in pairs( player.GetAll() ) do
		if ply.SQL && ply.SQL.Connected then
			table.insert( all, ply )
		end		
	end
	
	return all
end