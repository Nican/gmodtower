local setmetatable = setmetatable
local clientError = clientError
local table = table
local ValidEntity = ValidEntity
local _G = _G

module("Inventory")

Inventory = Inventory or {}

local MetaTbl = {
	__index = Inventory
}

function NewInventory( ply )
		
	if not ValidEntity( ply ) then
		clientError("Trying to start inventory with invalid owner!")
	end
		
	local t = {
		Player = ply,
		Bags = {}
	}
	
	setmetatable( t, MetaTbl )
	
	t:Init()
	
	return t
	
end

function Inventory:Init()
	local Main = NewBag( 0, 1, self )
	self.Bags[ 1 ] = Main
	Main:SetSize( 16 )
end

function Inventory:LoadNew()
	
	if _G.CLIENT then
		return
	end
	
	for i = 1, 10 do 
	
		local slot = self:GetSlot( 1, i )
		local item = NewItem("empty_bottle")
		item:SetStack( i )
		
		slot:Set( item )
		
	end
	
end


/**
  * Gets a slot of inventory from the given bag
  * If slotid is 0, then an item can given to find a slot in the bag that the item can fit in
  */

function Inventory:GetSlot( bagid, slotid, item ) //item is optional
	
	local bag = self:GetBag( bagid )
	
	if slotid == 0 then
		return bag:FindSlot( item )
	end
	
	return bag:GetSlot( slotid )
	
end

function Inventory:GetBag( id )
	if !self.Bags[ id ] then
		clientError("Could not find a bag of id: " .. tostring(id) )
	end
	
	return self.Bags[ id ]
end

function Inventory:GetPlayer()
	return self.Player
end	

function Inventory:IsValid()
	return self.Player:IsValid()
end

function Inventory:GetSaveData()
	
	local bags = {}
	
	for id, bag in pairs( self.Bags ) do
		bags[ id ] = bag:GetSaveData()
	end
	
	return bags
	
end

function Inventory:LoadSaveData( data )

	for sId, v in pairs( data ) do
		
		local id = tonumber(sId) //Bad json conversion, keys is transformed to strings
		
		if not id then
			clientError("Loading non-id on save data! ("..tostring(sId)..")")
		end
		
		local Bag = NewBag( v.type, id, self )
		self.Bags[ id ] = Bag
		
		Bag:LoadSaveData( v )
	
	end

end


