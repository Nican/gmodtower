local CurTime = CurTime
local setmetatable = setmetatable
local Error = Error
local tostring = tostring
local pairs = pairs

module("Award")

local PLAYER_AWARD = {}
local PLAYER_AWARDMeta = {
	__index = PLAYER_AWARD
}

function NewPlayerAward( ply, data )
	
	local o = {
		Player = ply,
		Created = CurTime(),
		Awards = {},
		Valid = true
	}
	
	setmetatable( o, PLAYER_AWARD )
	
	if data then
		o:Load( data )
	end
	
	return o
	
end

function PLAYER_AWARD:Load( data )
	
	for id, award in pairs( AwardList ) do
		self.Awards[ id ] = award:New( self )		
	end	

	--TODO: Load player awards from blob
	//for id, value in ... do
	//	self.Awards[ id ]:Load( value )
	//end
	
end


function PLAYER_AWARD:StoreData()

	--TODO: Load player awards from blob
	//for id, award in pairs( AwardList ) do
	//	local Data = award:StoreData( value )
	//end
	
end

function PLAYER_AWARD:GetOwner()
	return self.Player
end

function PLAYER_AWARD:Get( id )
	local Award = self.Awards[ id ]
	
	if !Award then
		Error("Selecting award of invalid id: " .. tostring(id) )
	end
	
	return Award	
end

function PLAYER_AWARD:ValidAward( id )
	return self.Awards[ id ] != nil
end

function PLAYER_AWARD:IsValid()
	return self.Valid
end

function PLAYER_AWARD:Invalidate()
	self.Valid = false
end

