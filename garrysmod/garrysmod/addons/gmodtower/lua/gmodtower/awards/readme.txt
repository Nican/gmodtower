AWARD:

Should be accesed as:
----
local Award = ply.Awards:Get( AWARD.LongRun )

if Award:Complete() then 
	return ...
end
----

The awardbase object base:
	Base object that must be registered with the achivement system to keep progreess
	AWARDBASE:GetId()

Award base object by value:
	This object is a progress value, for example, if you have to jump 10,000 times, it will just count up
	
	function AWARDBASE:GetMax() --Returns the maximun value the achivement can hold

Award base object by key:
	This object will keep bit-keys, for example, if the player has to keep 7 keys, they player may find the keys in any order
	
	function AWARDBASE:GetMax() --Returns the total number of bits it must store
	

=======================

The player award object:
Accesible by:
ply.Awards

function PLAYER_AWARD:Get( id ) --Returns a personal player data object that keeps the award data
function PLAYER_AWARD:IsValid() --Returns if the player and this achivement set is still valid
function PLAYER_AWARD:Invalidate() --Invalidated the player award object

=======================

The player specific award object

/**
	Returns a value from 0.0 to 1.0 to how much the player is done
*/
function AWARD:GetProgress() end

/**
	Returns the actual value of the award
*/
function AWARD:Get() end

/**
	On a prize by key, returns a boolean value showing if the achivement was complete
	throws an error if it the id is out of bounds from the PRIZE:GetMax()
*/
function AWARD:Get( id ) end

/**
	Returns the award base object of this award
*/
function AWARD:GetAward() end

/**
	On a prize by value, adds the val to the award, and clamps it if it is above the limit
	On a prize by key, throws an error
*/
function AWARD:Add( value ) end

/**
	On a prize by value, sets the value of the award, and clamps if neccesary
*/
function AWARD:Set( value ) end

/**
	On a prize by key, sets the bit (true/false) to the given id
	throws an error if it the id is out of bounds from the PRIZE:GetMax()
*/
function AWARD:Set( id, bit ) end

/**
	???
	Returns true
*/
function AWARD:IsValid() end

/**
	Invalidated the AWARD object
*/
function AWARD:Invalidate()


=================

To register an award:

hook.Add("RegisterAwards", "RegisterBasicAward", function()
	Award.Register({
		id = Award.IdList.LONG_RUN,
		name = "Long run",
		description = "Run 1000 kilometers.",
		type = Award.Type.KEY,
		max = 1000000
	} )
end )
