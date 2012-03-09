local CurTime = CurTime
local setmetatable = setmetatable
local Error = Error
local tostring = tostring
local pairs, ipairs = pairs, ipairs
local math = math
local _G = _G

module("Award")

local function AchivementComplete( self )
	hook.Call("Award", _G.GAMEMODE, self:GetPlayerAward():GetOwner(), self )
end

BASE_AWARD = BASE_AWARD or {
	Valid = true
}
BASE_AWARDMeta = BASE_AWARDMeta or {
	__index = BASE_AWARD
}

function BASE_AWARD:New( playerAward )
	
	local o = {
		PlayerAward = playerAward
	}
	
	setmetatable( o, self._Meta )
	
	return o
	
end

/**
	Loads the value from the database
*/
function BASE_AWARD:Load( value )
	
end

/**
	Return the to store in the database
*/
function BASE_AWARD:StoreData()
	return 0
end

/**
	Returns a value from 0.0 to 1.0 to how much the player is done
*/
function BASE_AWARD:GetProgress() 
	Error("Get function not implemented on " .. tostring(self.Id) )
end

/**
	To be implemented by subclass
*/
function BASE_AWARD:Get() 
	Error("Get function not implemented on " .. tostring(self.Id) )
end

/**
	Returns, from the parent award base, the maximun value 
*/
function AWARD_VALUE:GetMax()
	return self.MaxValue
end

/**
	Returns the award base object of this award
*/
function BASE_AWARD:GetPlayerAward() 
	return self.PlayerAward
end

/**
	To be implemented by subclass
*/
function BASE_AWARD:Add( value ) 
	Error("Add function not implemented on " .. tostring(self.Id) )
end

/**
	To be implemented by subclass
*/
function BASE_AWARD:Set( value ) 
	Error("Set function not implemented on " .. tostring(self.Id) )
end

/**
	Checks if the award is still valid and changable
*/
function BASE_AWARD:IsValid()
	return self.Valid
end

/**
	Invalidated the AWARD object
*/
function BASE_AWARD:Invalidate()
	self.Valid = false
end

/*	================================
		Award by value
		This award will be a value between 0 and MAX that will slowly progress up
		A.K.A. Achivement for running 100 kilometers in game
	================================ */

local AWARD_VALUE = AWARD_VALUE or {}
local AWARD_VALUEMeta = AWARD_VALUEMeta or {
	__index = BASE_AWARD
}
setmetatable( AWARD_VALUE, BASE_AWARDMeta )

/**
	Loads the value from the database
*/
function AWARD_VALUE:Load( value )
	self:Set( value or 0 )
end

/**
	Return the to store in the database
*/
function AWARD_VALUE:Store()
	return self:Get()
end

/**
	Returns a value from 0.0 to 1.0 to how much the player is done
*/
function AWARD_VALUE:GetProgress() 
	return self:Get() / self:GetMax()
end

/**
	Returns the actual value of the award
*/
function AWARD_VALUE:Get() 
	return self.Value
end

/**
	Adds the val to the award, and clamps it if it is above the limit
*/
function AWARD_VALUE:Add( value ) 
	self:Set( self:Get() + value )
end

/**
	Sets the value of the award, and clamps if neccesary
*/
function AWARD_VALUE:Set( value ) 

	value = math.Clamp( value, 0, self:GetMax() )

	if self.Value != value then
		self.Value = value
		
		if self:Get() >= self:GetMax() then
			AchivementComplete( self )
		end
	end
	
end
	
/*	================================
		Award by keys
		This award will be a set of bits that the user can partially complete
		A maximun of 32 bits are allowed
		A.K.A. Achivement for finding all paintings in the map
	================================ */

AWARD_KEY = AWARD_KEY or {}
AWARD_KEYMeta = AWARD_KEYMeta or {
	__index = BASE_AWARD
}
setmetatable( AWARD_KEY, BASE_AWARDMeta )

/**
	Loads the value from the database
*/
function AWARD_KEY:Load( value )
	local Max = self:GetMax()
	
	if Max > 32 then
		Error("Collecting AWARD_KEY " .. tostring(self.Id) .. " bigger than 32")
	end
	
	local Vals = {}
	
	for i=1, Max do
		Vals[ i ] = (value & (1 << i)) > 0
	end
	
	self.Value = Vals
end

/**
	Return the to store in the database
*/
function AWARD_KEY:Store()
	local Value = 0
	
	for k, v in ipairs( self.Value ) do
		if v == true then
			Value = Value + (1 << i)
		end
	end
	
	return Value
end

/**
	Returns whatever the bit is a valid bit
*/
function AWARD_KEY:InRange( bit )
	return bit >= 1 and bit <= self:GetMax()
end

/**
	Checks if the bit is in a valid range of the award
	If it is not, it throws an error
*/
function AWARD_KEY:CheckRange( bit )
	if not self:InRange( bit ) then
		Error("Selecting invalid bit("..tostring(bit)..") on " .. tostring(self))
	end
end

/**
	Returns a value from 0.0 to 1.0 to how much the player is done
*/
function AWARD_KEY:GetProgress() 
	local Count = 0
	
	for k, v in ipairs( self.Value ) do
		if v == true then
			Count = Count + 1
		end
	end

	return Count / #self.Value
end

/**
	Returns the actual value of the award
*/
function AWARD_KEY:Get( bit ) 
	self:CheckRange( bit )

	return self.Value[ bit ]
end

/**
	Sets the value of the bit
*/
function AWARD_KEY:Set( bit, value ) 
	
	self:CheckRange( bit )
	
	if value == nil then
		Error("Setting key by type without a value!")
	end
	
	if self.Value[ bit ] != value then
		self.Value[ bit ] = value
		
		if self:GetProgress()  >= 1.0 then
			AchivementComplete( self )
		end
	end
	
end

List = {
	VALUE = AWARD_VALUEMeta
	KEY = AWARD_KEYMeta
}