
module( "Hex", package.seeall )

local HexObj = {}

// writing is limited to 32bits
// this is due to string.format's %x specifier!!
// making this higher will lead to undefined behavior!
MaxBits = 32
MaxBytes = MaxBits / 8
MaxSize = ( 2 ^ MaxBits ) - 1


// creates a new hex object for serializing data
function Create( strHex )

	local obj = {}
	
	if ( !strHex ) then
		strHex = ""
	end
	
	setmetatable( obj, { __index = HexObj } )
	
	obj:SetData( strHex )
	obj.Position = 0
	
	return obj
	
end



// read a number of bytes from the current position
function HexObj:Read( iBytes )

	if ( iBytes > MaxBytes ) then
		MsgN( "Hex: Reading more than 4 bytes!! Clamping!" )
		MsgN( debug.traceback() )
		iBytes = math.Clamp( iBytes, 0, MaxBytes )
	end

	local subStart = 1 + self.Position
	local subEnd = subStart + ( iBytes * 2 ) - 1
	
	local subStr = "0x" .. string.sub( self.Data, subStart, subEnd )
	self:SeekRelative( iBytes )
	
	return tonumber( subStr, 16 )
	
end

// write a value of iBytes size to the current position
function HexObj:Write( iData, iBytes )

	if ( iData > MaxSize ) then
		MsgN( "Hex: Writing more than 32 bits!! Clamping!" )
		MsgN( debug.traceback() )
		iData = math.Clamp( iData, 0, MaxSize )
	end
	
	if ( iBytes > MaxBytes ) then
		MsgN( "Hex: Writing more than 4 bytes!! Clamping!" )
		MsgN( debug.traceback() )
		iBytes = math.Clamp( iBytes, 0, MaxBytes )
	end
	
	local hexStr = string.format( "%X", iData )
	local length = string.len( hexStr ) 
	
	// left pad the hexStr with 0's
	local numPad = length % 2
	hexStr = string.rep( "0", numPad ) .. hexStr
	length = length + numPad
	
	// pad more
	local numBytes = length / 2
	if ( iBytes > numBytes ) then
		hexStr = string.rep( "0", ( iBytes - numBytes ) * 2 ) .. hexStr
	end
	
	// truncate left bytes
	if ( iBytes < numBytes ) then
		local diff = ( numBytes - iBytes ) * 2
		hexStr = string.sub( hexStr, 1 + diff, length )
	end
	
	self:SetData( self.Data .. hexStr )
	
	//self.Data = self.Data .. hexStr
	//self.Length = string.len( self.Data )
	self:SeekRelative( iBytes )
	
end

// sets the string data for the hex object
// this also ensures correct padding
function HexObj:SetData( strData )

	local len = string.len( strData )
	
	// ensure our data is divisible by 2
	local numPad = len % 2
	strData = string.rep( "0", numPad ) .. strData
	
	self.Data = strData
	self.Length = string.len( strData )
	
end

function HexObj:GetData()
	return self.Data
end

// seeks to a specific byte position
function HexObj:Seek( iPosition )
	self.Position = iPosition * 2
end
// returns the current position in the stream
function HexObj:GetPosition()
	return self.Position / 2
end

// seeks to a specific byte position, relative to the current position
function HexObj:SeekRelative( iBytes )
	self.Position = self.Position + ( iBytes * 2 )
end

// checks if the hex object is overflowed past the length
function HexObj:IsOverflowed()
	return self.Position > self.Length
end

// returns the size of the data in bytes
function HexObj:GetSize()
	return self.Length / 2
end
