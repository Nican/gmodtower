require("mysqloo")

module("SQL", package.seeall )

Connected = false

if !mysqloo then
	error("mysqloo module not found")
	return
end

local databaseObject = mysqloo.connect("localhost", "root", "", "gmodtower", 3306 )


databaseObject.onConnected = function(database)
	Connected = true
	hook.Call("DatabaseConnect", GAMEMODE )
end


databaseObject.onConnectionFailed = function(db, err)
	ErrorNoHalt("Failed to connect to DB: " .. tostring( err ) )
end

databaseObject:connect()

function getDB()
	return databaseObject
end


_G.SQLLog = function( source, ... )

	if not Connected then
		return
	end
	
	local message = ""
	
	for _, v in pairs( {...} ) do		
		if type( v ) == "Player" then
			message = message .. "[p=".. tostring(v:SQLId()) .."]"
		else
			message = message .. tostring ( v ) 
		end
	end
	
	if string.len( message ) < 3 then
		return
	end
	
	if !source || !message || !GTowerServers then
		print("no message")
		debug.Trace()
		return
	end
	
	local insertStatment
	local db = getDB()

	if source == 'error' then
		local Hash = tonumber( util.CRC( select(1, ...) ) )
		
		if table.HasValue( ErrorLogMessages, Hash ) then
			return
		end
		table.insert( ErrorLogMessages, Hash )	
		ErrorNoHalt( message )
		
		insertStatment = "INSERT INTO  `gm_log_error`(`message`,`srvid`) VALUES " ..
			"('".. db:escape(message) .."'," .. tostring(GTowerServers:GetServerId()) ..")"
	
	else

		insertStatment = "INSERT INTO  `gm_log`(`type`,`message`,`srvid`) VALUES " ..
			"('".. db:escape(tostring(source)) .."','".. db:escape(message) .."',1)"
	
	end

	local query = db:query( insertStatment )
	query.onError = function( query, err )
		ErrorNoHalt("Failed to log query: " .. tostring( err ))
	end
	query:start()

	
end