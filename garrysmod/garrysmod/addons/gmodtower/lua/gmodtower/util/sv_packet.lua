local umsg = umsg
local setmetatable = setmetatable
local string = string
local insert = table.insert
local ipairs = ipairs

module("Packet")

local PacketBase = {}
local Meta = {
	__index = PacketBase
}

function New()
	
	local t = {
		List = {},
	}
	
	setmetatable( t, Meta )
	
	return t
	
end

function PacketBase:Add( func, val, size )
	insert( self.List, { func, val, size } )
end

function PacketBase:Angle( val )
	self:Add( umsg.Angle, val, 12 )
end

function PacketBase:Bool( val )
	self:Add( umsg.Bool, val, 1 )
end

function PacketBase:Char( val )
	self:Add( umsg.Char, val, 1 )
end

function PacketBase:Entity( val )
	self:Add( umsg.Entity, val, 4 )
end

function PacketBase:Float( val )
	self:Add( umsg.Float, val, 4 )
end

function PacketBase:Long( val )
	self:Add( umsg.Long, val, 4 )
end

function PacketBase:Short( val )
	self:Add( umsg.Short, val, 2 )
end

function PacketBase:String( val )
	self:Add( umsg.String, val, string.len( val ) + 1 )
end

function PacketBase:Vector( val )
	self:Add( umsg.Vector, val, 12 )
end

function PacketBase:VectorNormal( val )
	self:Add( umsg.VectorNormal, val, 12 )
end

function PacketBase:Size()
	local Sum = 0
	
	for _, v in ipairs( self.List ) do
		Sum = Sum + v[3]
	end
	
	return Sum
end	

function PacketBase:Write()
	
	for _, v in ipairs( self.List ) do
		v[1]( v[2] )
	end
	
end

