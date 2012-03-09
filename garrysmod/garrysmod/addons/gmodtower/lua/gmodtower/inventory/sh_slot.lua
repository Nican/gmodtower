local setmetatable = setmetatable
local tostring = tostring
local error = clientError
local hook = hook
local _G = _G
local ValidPanel = ValidPanel

module("Inventory" )


SlotBase = SlotBase or {}
SlotList = SlotList or {
	[0] = SlotBase
}

SlotBase._Meta = SlotBase._Meta or {
	__index = SlotBase
}


function RegisterSlot( typeId, tbl )
	
	setmetatable( tbl, SlotBase._Meta )
	
	if SlotList[ typeId ] then
		clientError("Trying to register two slots with id: " .. tostring(id) )
	end
	
	tbl._Meta = {
		__index = tbl
	}
	
	SlotList[ typeId ] = tbl
	
end

function NewSlot( typeId, id, bag )

	local Slot = SlotList[ typeId ]
	
	if not Slot then
		clientError("Slot of id " .. tostring(typeId) .. " does not exist.")
	end
	
	local t = {
		Id = id,
		Bag	= bag,
		Item = nil
	}
	
	setmetatable( t, Slot._Meta )
	
	t:Init()
	
	return t
	
end

function SlotBase:Init()

end

function SlotBase:GetId()
	return self.Id
end

/**
 * Set the specific non-nil item to this slot
 */
function SlotBase:Set( item )
	if not self:Empty() then
		clientError("Trying to set a new item on a non-empty slot!")
	end
	
	if not item then
		clientError("Trying to set a non-valid item!")
	end

	self.Item = item
	item.Slot = self
	
	self.Item:OnSlot()
	
	self:ItemSet()
	
	hook.Call("InventoryItemSet", _G.GAMEMODE, self )
end

/**
 * Removes the item from this slow
 */
function SlotBase:Remove()
	local oldItem = self.Item

	if oldItem then
		oldItem.Slot = nil
		oldItem:OnSlotRemove( self )
	end

	self.Item = nil
	
	if oldItem then
		self:ItemRemoved( oldItem )	
	end
	
	hook.Call("InventoryItemRemoved", _G.GAMEMODE, self )
end

/** 
 * Callback to when a item is added to this slot
 */
function SlotBase:ItemSet()
	self:GetBag():ItemSet( self )
	
	self:ItemChanged()
end

/**
 * Callback to when an item is removed from this slow
 */ 
function SlotBase:ItemRemoved( oldItem )
	self:GetBag():ItemRemoved( self, oldItem )
	
	self:ItemChanged()
end

/**
 * Return true when the user can change the items in this bag
 */
function SlotBase:CanManage()
	return true
end

/**
 * Does the slot allow the specific item in this slot
 */
function SlotBase:Allow( item )
	if not item then
		return true
	end

	return self:GetBag():Allow( item, self )
end

/**
 * Get the parent {Bag} object
 */
function SlotBase:GetBag()
	return self.Bag
end

/**
 * Get the player owner of the inventory
 */
function SlotBase:GetPlayer()
	return self:GetBag():GetPlayer()
end
SlotBase.GetOwner = SlotBase.GetPlayer

function SlotBase:GetInventory()
	return self:GetBag():GetInventory()
end

/**
 * Return the item in this bag
 */
function SlotBase:Get()
	return self.Item
end
SlotBase.GetItem = SlotBase.Get

/**
 * Checks if the there is no item in this slot
 */
function SlotBase:Empty()
	return self:Get() == nil
end

/**
 * Tells the network manage to resend the information about this slot to the client
 */
function SlotBase:ItemChanged()
	if SERVER then
		Network.insert( self )
	elseif ValidPanel( self.VGUI ) then
		self.VGUI:SlotUpdate()
	end
end

if _G.SERVER then
	/**
	 * To be used by the network manager to send this item over the network
	 */
	function SlotBase:GetNetworkPacket()
		local packet = _G.Packet.New()
		local Item = self:Get()
		
		packet:Char( self:GetBag():GetId() )
		packet:Char( self:GetId() )
		
		if Item then
			packet:Long( Item:GetId() )
			
			if Item.MaxStack != 1 then
				packet:Char( Item:GetStack() )
			end
			
			Item:WritePacket( packet )
		else
			packet:Long( 0 )
		end
		
		return packet
	end
	
else

	function SlotBase:ReadNetworkPacket( um )
	
		local ItemId = um:ReadLong()
		
		if ItemId == 0 then
			self:Remove()
		else
			if not self:Empty() then
				self:Remove()
			end
		
			local Item = NewItemById( ItemId )
			
			if Item.MaxStack != 1 then
				Item:SetStack( um:ReadChar() )
			end
			
			//TODO: Things to think: Read the network before or after set the slot?
			Item:ReadPacket( um )
			
			self:Set( Item )
			
		end
		
	end

end

function SlotBase:GetSaveData()
	
	if self:Empty() then
		return
	end
	local item = self:Get()

	return item:GetSaveData()
	
end

function SlotBase:LoadSaveData( data )
	
	local item = NewItemById( data.id )
	
	item:LoadSaveData( data )
	
	self:Set( item )

end