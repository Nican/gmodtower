local setmetatable = setmetatable
local tostring = tostring
local clientError = clientError

module("Inventory" )

BagBase = BagBase or {}
BagList = BagList or {
	[0] = BagBase
}

BagBase.Meta = BagBase.Meta or {
	__index = BagBase
}

function RegisterBag( typeId, tbl )
	
	setmetatable( tbl, BagBase.Meta )
	
	if BagList[ typeId ] then
		clientError("Trying to register two bags with typeId: " .. tostring(typeId) )
	end
	
	tbl.Meta = {
		__index = tbl
	}
	
	BagList[ typeId ] = tbl
	
end

function NewBag( typeId, id, inventory )

	local Bag = BagList[ typeId ]
	
	if not Bag then
		clientError("Bag of typeId " .. tostring(typeId) .. " does not exist.")
	end
	
	local t = {
		Inventory = inventory,
		BagType = typeId,
		Slots = {},
		Id = id,
	}
	
	setmetatable( t, Bag.Meta )
	
	t:Init()
	
	return t
	
end

function BagBase:Init()
	
end	

function BagBase:GetId()
	return self.Id
end

function BagBase:SetSize( size )

	if size == #self.Slots then
		return
	end
	
	local i
	
	if size > #self.Slots then
		
		for i = #self.Slots + 1, size, 1 do
			self:CreateSlot( i )
		end
	
	else 
		
		for i = size + 1, #self.Slots, 1 do
			if not self:GetSlot( i ):IsEmpty() then
				error("Attempting to remove slot that is not empty")
			end
		end
	
		for i = size + 1, #self.Slots, 1 do
			self:RemoveSlot( i )		
		end
	
	end
	
	self:SizeChanged()
	
end

function BagBase:SizeChanged()
	if CLIENT && self.VGUI then
		self.VGUI:BagUpdate()
	end
end

function BagBase:CanManage()
	return true
end

function BagBase:FindUnusedSlot( item )
	
	for _, slot in ipairs( item ) do
		
		if slot:Empty() and slot:CanManage() and slot:Allow( item ) then
			return slot
		end
	
	end
	
end

function BagBase:ItemSet( slot )
	
end

function BagBase:ItemRemoved( slot, oldItem )
	
end

function BagBase:Allow( item, slot )
	if not item then 
		return true
	end

	return item:Allow( slot )
end

function BagBase:CreateSlot( id )
	self.Slots[ id ] = NewSlot( 0, id, self )
end

function BagBase:Destroy()
	//DO NOTHING
end	

function BagBase:RemoveSlot( id )
	self.Slots[ id ]:Destroy()
	self.Slots[ id ] = nil
end

function BagBase:GetSlot( id )
	return self.Slots[ id ]
end

function BagBase:FindSlot( item )
	
	for _, slot in ipairs( self.Slots ) do
		if slot:Empty() and slot:Allow( item ) then
			return slot
		end
	end
	
end

function BagBase:GetInventory()
	return self.Inventory
end	

function BagBase:GetPlayer()
	return self:GetInventory():GetPlayer()
end	

function BagBase:IsValid()
	return self:GetInventory():IsValid()
end	

function BagBase:GetSaveData()
	
	local bag = {
		size = #self.Slots,
		type = self.BagType,
		slots = {}
	}
	
	for id, slot in ipairs( self.Slots ) do
		
		if not slot:Empty() then
			bag.slots[ id ] = slot:GetSaveData()
		end
		
	end
	
	return bag	
	
end

function BagBase:LoadSaveData( data ) 
	
	if data.size then
		self:SetSize( data.size )
	end
	
	for id, slot in ipairs( self.Slots ) do
		
		if data.slots[ id ] then
			slot:LoadSaveData( data.slots[ id ] )
		elseif not slot:Empty() then
			slot:Remove()
		end
		
	end

end