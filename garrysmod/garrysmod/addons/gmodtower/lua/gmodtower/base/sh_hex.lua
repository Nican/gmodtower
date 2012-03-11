function Hex( Input )	
	return HexTable.Init( Input )
end

/*concommand.Add("gmt_testhex", function( ply, cmd, args )
	
	if ply != NULL then return end
	
	local Data = Hex()
	local Jumpstep = 132
	
	for i=0, 256*Jumpstep, Jumpstep do
		Data:SafeWrite( i )
	end
	
	local Count = 0
	
	while Data:CanRead( 1 ) do
		local Int = Data:SafeRead()
		if Int != Count then
			Msg("FAILED!\n")
			return
		end
		
		Count = Count + Jumpstep		
	end	
	
	Msg("SUCESS!\n")
end )*/


do

local string = string
local type = type
local stringformat = string.format
local stringlen = string.len
local math = math
local debug = debug
local Msg, getfenv, tonumber, setmetatable, ErrorNoHalt = Msg, getfenv, tonumber, setmetatable, ErrorNoHalt
local Vector, Angle = Vector, Angle

module("HexTable")

local modenv = getfenv()
local hextbl = {"0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"}

/*
So I don't go insane, here's how the width on these functions work:
remember 8 bits = 1 byte
They use twice the expected width, because it's a string in base 16
byte (8 bits) (1 byte) ( 2 chars base 16 ) = 2
int (16 bits) (2 bytes) ( 4 chars base 16 ) = 4
long (32 bits) (4 bytes) ( 8 chars base 16 ) = 8
64-bit int (64 bits) (8 bytes) ( 16 chars base 16) = 16
string = n*2 + 2 for the 00 byte term
*/

function Init( Input )
	local o = setmetatable({
		Data = Input or "",
		Pointer = 1		
	}, {__index = modenv})

	return o
end

function ConvertToHex(input, amount)
	local hex = stringformat("%X", input )
	local diff = amount - stringlen(hex)
	
	if diff < 0 then
		Error("Trying to convert hex to a smaller size!")
	end
	
	return string.rep( "0", diff ) .. hex
end

function CanRead( self, size )
	return self.Pointer + (size or 1) <= self:DataLenght() + 1
end

function DataLenght( self )
	return stringlen( self.Data )
end

function Read( self, count )
	
	local Value = tonumber( string.sub( self.Data, self.Pointer, self.Pointer + count - 1 ), 16 )
	self.Pointer = self.Pointer + count
	
	return Value
	
end

function Write( self, value, lenght )
	if type( value ) == "boolean" then
		if value == true then
			value = 1
		else
			value = 0
		end		
	end
	
	if lenght > 11 then
		ErrorNoHalt("ATTETION: Number on HexTable is too large, clamping it!")
		ErrorNoHalt( debug.traceback(), "\n\n")
	end
	
	self.Data = self.Data .. ConvertToHex( value, lenght * 2 )
end

/* ========================
	Strings!
	Read until a null terminator is found
  ========================== */
  
function WriteString( self, str )
	
	local Lenght = stringlen( str )
	
	for i=1, Lenght do
		self:Write( string.byte( str, i ), 1 )
	end
	
	self:Write( 0, 1 )
	
end

function ReadString( self )
	local String = ""
	local DataLenght = self:DataLenght()
	
	while self:CanRead( 1 ) do
		local Value = self:Read( 1 )
		
		if Value == 0 then
			break
		end
	
		String = String .. string.char( Value )
	end
	
	return String
end

/* ========================
	VECTOR / ANGLES
  ========================== */
  
function WriteVector( self, vec )
	
	self:Write( 2147483648 + math.Round( vec.x * 100 ), 4 )
	self:Write( 2147483648 + math.Round( vec.y * 100 ), 4 )
	self:Write( 2147483648 + math.Round( vec.z * 100 ), 4 )

end

function ReadVector( self )
	
	local PosX = (self:Read( 4 ) - 2147483648) / 100
	local PosY = (self:Read( 4 ) - 2147483648) / 100 
	local PosZ = (self:Read( 4 ) - 2147483648) / 100 
	
	return Vector( PosX, PosY, PosZ )

end

function WriteAngles( self, Ang )
	
	self:Write( 18000 + math.Round( Ang.p * 100 ), 4 )
	self:Write( 18000 + math.Round( Ang.y * 100 ), 4 )
	self:Write( 18000 + math.Round( Ang.r * 100 ), 4 )
	
end

function ReadAngles( self )
	
	local AngP = (self:Read( 4 ) - 18000) / 100
	local AngY = (self:Read( 4 ) - 18000) / 100
	local AngR = (self:Read( 4 ) - 18000) / 100
	
	return Angle( AngP, AngY, AngR )
	
end


/* ========================
	GET HEX to be put into the database
  ========================== */

function Get( self )
	local Lenght = self:DataLenght()
	if Lenght == 0 then
		return "0x0"
	end
	
	//A extra 0 has to be added if the the lenght is odd
	//because otherwise SQL will add a extra 0 to the front and mess everything up.
	if math.fmod( Lenght, 2 ) == 1 then
		return "0x" .. self.Data .. "0"
	end
	
	return "0x" .. self.Data
end

end //End of the module
