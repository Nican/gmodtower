
module("SQLPlayer", package.seeall )

local MetaTable = {
	__index = getfenv()
}

UpdateTime = 30

local function GetChecksum( Data )
	if type( Data ) == "number" then
		return Data
	end
	return tonumber( util.CRC( Data ) )
end

function Init( ply )

	local o = {}
	
	setmetatable( o, MetaTable )

	o.Player = ply
	o.Connected = false
	o.SelectAttempts = 0
	o.NextUpdate = CurTime() + UpdateTime
	
	o.UpdateInProgress = false
	o.LastUpdates = {}
	
	return o
	
end

/*==============================================
	SELECT STATEMENTS
    ============================================ */

function GetSelectColumns( self )
	
	local SelectStrings = {}
	
	for _, v in pairs( SQL.GetColumns() ) do
		local Select = v:GetSelect()
		if Select then
			table.insert( SelectStrings, Select )
		end
	end
	
	return table.concat( SelectStrings, ",")
	
end

function GetSelectQuery( self )
	local Sqlid = self:SQLId()
	
	if Sqlid == nil then
		return
	end

	return "SELECT " .. self:GetSelectColumns() .. " FROM `gm_users` WHERE id=" .. Sqlid
end

function ExecuteSelect( self )
	
	if !self:Valid() then
		return
	end
	
	local selectStatment = self:GetSelectQuery()
	
	if selectStatment == nil then
		self:NewSelectAttemp( 3.0 )
		return
	end

	local query = getDB():query( selectStatment )

	query.onSuccess = function( query )
		self:SelectCallback( query:getData() )
	end
	query.onError = function( query, err )
		SQLLog('error', "Select error:" .. error )
		self:NewSelectAttemp()	
	end


end

function NewSelectAttemp( self, time )
	
	self.SelectAttempts = self.SelectAttempts + 1
	
	if self.SelectAttempts == 3 then
		self:DefaultValues()
		SQLLog('error', "3 attempts and was not able to recieve " , self.Player , " data ")
		return
	end
	
	timer.Create("SQLSelect" .. tostring(self.Player:EntIndex()), time or 2.0, 1, self.ExecuteSelect, self )

end

function SelectCallback( self, res )
	
	if !self:Valid() then
		return
	end
	
	local NewPlayer = #res == 0 
	
	//If no result were found
	if NewPlayer then
		self:InsertPlayer()
		self:DefaultValues()
	
	else
	
		local Result = res[1]
		
		for id, column in pairs( SQL.GetColumns() ) do
			local Response = column:GetSelectCallback()
			
			if Result[ Response ] then
				column:OnSelect( self.Player, Result[ Response ] )
			end

		end
		
		self.Connected = true
	
	end
	
	self.NextUpdate = CurTime() + UpdateTime
	self:CallConnected( NewPlayer )
	
	if !NewPlayer then
	
		for id, column in pairs( SQL.GetColumns() ) do
			
			if column:GetSelect() then
			
				local Data = column:GetUpdate( self.Player, ondisconnect )
				
				if Data then
					self.LastUpdates[ id ] = GetChecksum( Data )
				end
			end
			
		end
		
	end
	
end

function DefaultValues( self )
	
	for _, v in pairs( SQL.GetColumns() ) do
		v:DefaultValue( self.Player )
	end
	
end

function CallConnected( self, NewPlayer )
	self._DebugHasCalledConnected = true

	hook.Call( "SQLConnect", GAMEMODE, self.Player, NewPlayer )
end

/*==============================================
	INSERT STATEMENTS
    ================================================ */
	
function InsertPlayer( self )

	local db = SQL.getDB()
	local insertStatment = string.format( "INSERT INTO `gm_users`(id, steamid, name, ip) VALUES (%d, '%s', '%s', '%s')",
		self:SQLId(), self.Player:SteamID(), db:escape(self.Player:Name()), self:GetIP() )

	local query = db:query(insertStatment)

	insertStatment.onSuccess = function( query )
		self.Connected = true
	end

	insertStatment.onError = function( query, err)
		ErrorNoHalt("PLAYER INSERT ERROR: " .. err )
	end

	query:start()

	
end

function GetIP( self )
	return string.match( self.Player:IPAddress() , "(%d+%.%d+%.%d+%.%d+)" )
end

/*==============================================
	UPDATE STATEMNTS
    ================================================ */

function Update( self, ondisconnect, force )

	if !self:Valid() || self.Connected != true || self.UpdateInProgress == true then

		if ondisconnect then
			SQLLog('sqldebug', "Couldn't update player on disconnect calledconnected (" .. tostring(self._DebugHasCalledConnected) .. ") connected (" .. tostring(self.Connected) .. ") updateinprogress (" .. tostring(self.UpdateInProgress) .. ") " .. tostring(self.Player) )
		end

		return
	end
	
	local TimeLeft = self.NextUpdate - CurTime()
	
	//You have not updated in such a long tme, do not let this happen
	if ondisconnect != true then
		if TimeLeft < -120 then
			force = true
		elseif force != true && TimeLeft > 0  then
			return
		end
	end
	
	local ToUpdate = {}
	local UnimportantUpdate = true
	
	for id, column in pairs( SQL.GetColumns() ) do
		
		local Data = column:GetUpdate( self.Player, ondisconnect )
		
		if Data then
			local Checksum = GetChecksum( Data )
			
			if self.LastUpdates[ id ] != Checksum then
				table.insert( ToUpdate, Data )
				self.LastUpdates[ id ] = Checksum
				
				if column.UnimportantUpdate != true then
					UnimportantUpdate = false
				end	
			end	
		end
		
	end
	
	if table.Count( ToUpdate ) == 0 then //nothing to update

		if ondisconnect then
			//SQLLog('sqldebug', "Did not update player on disconnect " .. tostring(self.Player) )
		end

		return
	end
	
	if ondisconnect != true && force != true && UnimportantUpdate == true then
		self.NextUpdate = CurTime() + 10.0
		return
	end
	self.UpdateQuery = "UPDATE gm_users SET " .. table.concat( ToUpdate, "," ) .. " WHERE id=" .. self:SQLId()

	local query = SQL.GetDB():query( self.UpdateQuery )

	query.onSuccess = function( query )
		self:FinishUpdate()
	end

	query.onError = function( query, err )
		self:FinishUpdate()
		SQLLog('error', "Update player: ", err, "\n", self.UpdateQuery )
	end
	
	self.UpdateInProgress = true	
	hook.Call("ClientUpdated", GAMEMODE, self.Player, ondisconnect )
	
	if ondisconnect == true then
		//Well, all data should have been commited, and no longer should be updated
		self.Connected = false
		
		hook.Call("DisconnectPost", GAMEMODE, self.Player )
	end

	query:start()
	
end
	
function FinishUpdate( self )
	self.UpdateInProgress = false
	self.NextUpdate = CurTime() + UpdateTime
	self.UpdateQuery = nil

end
	
/*==============================================
	HELPER FUNCTIONS
    ================================================ */

function Valid( self )
	return IsValid( self.Player )
end

function SQLId( self )
	return self.Player:SQLId()
end
