
hook.Add("SQLStartColumns", "StartBasicColumns", function()
	
	SQLColumn.Init( {
		["column"] = "money",
		["update"] = function( ply ) 
			return math.Clamp( ply:Money(), 0, 2147483647 )
		end,
		["defaultvalue"] = function( ply )
			ply:SetMoney( 0 )
		end,
		["onupdate"] = function( ply, val ) 
			ply:SetMoney( tonumber( val ) or 0 )
		end,
		["type"] = "INT UNSIGNED",
	} )
	
	SQLColumn.Init( {
		["column"] = "name",
		["fullupdate"] = function( ply ) 
			return "`name`='" .. SQL.getDB():escape(ply:Name()) .. "'"
		end,
	} )
	
	SQLColumn.Init( {
		["column"] = "ip",
		["fullupdate"] = function( ply ) 
			if ply.SQL then
				return "`ip`='" .. tostring(ply.SQL:GetIP()) .. "'"
			end
		end,
	} )
	
	SQLColumn.Init( {
		["column"] = "LastOnline",
		["update"] = function( ply, ondisconnect ) 
			if ondisconnect == true then
				return os.time()
			end
		end,
	} )
	
	SQLColumn.Init( {
		["column"] = "time",
		["defaultvalue"] = function( ply )
			ply.Time = 0
		end,
		["onupdate"] = function( ply, val )
			ply.Time = tonumber( val ) or 0
		end,
		["fullupdate"] = function( ply, onend )
			if onend == true then 
				return "`time`=`time`+" .. ply:TimeConnected()
			end
		end
	} )

end )