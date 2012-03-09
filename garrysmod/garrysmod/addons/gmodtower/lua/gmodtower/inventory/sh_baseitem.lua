local setmetatable = setmetatable
local string = string
local math = math
local ValidEntity = ValidEntity
local error = clientError
local tostring = tostring
local ents = ents
local SERVER = SERVER
local _G = _G

module("Inventory" )

ItemBase = ItemBase or {}
ItemList = ItemList or {}
ItemListId = ItemListId or {}
ItemBase._Meta = ItemBase._Meta or {
	__index = ItemBase
}


ItemBase.Name = nil
ItemBase.Description = ""
ItemBase.Model = nil
ItemBase.ModelSkinId = nil //A skin for the given item?
ItemBase.EnablePhyiscs = false //Should the physics be enabled when the ent is created?
ItemBase.Tradable = true //Can the item be traded with other players?
ItemBase.EnableMotion = false

ItemBase.CanRemove = true //If it the ent can be removed trough inventory,  on the sub menu
ItemBase.CanUse = false //If it usable and can call :OnUse()

// This lets you always drop an inventory item, for things like fireworks!
ItemBase.AllowAnywhereDrop = false

ItemBase.MaxStack = 1 //Maximun amout of items that can be hold on one slot
ItemBase.StackSize = 1

function RegisterItem( name, tbl, base )
	
	tbl.UniqueName = name
	tbl._hash = string.hash( name )
	tbl._Meta = {
		__index = tbl
	}
	
	if tbl.Name == nil then
		error("Registering an item("..tostring(name)..") without a name")
	end
	
	if ItemList[ name ] then
		if not _G.DEBUG then
			ErrorNoHalt("An item with the same hash has already been registered("..name.."/".. ItemList[ name ].UniqueName ..")\n")
		end
		ItemList[ name ]._Meta.__index = tbl //Replace the old meta table, with the new meta table
	end
	
	if base then
		
		local baseItem = ItemList[ base ]
		
		if not baseItem then
			error("Setting item(".. tostring(name) .. ") with a base that does not exist: " .. tostring(base) )
		end
		
		setmetatable( tbl, baseItem._Meta )
		
	else
		setmetatable( tbl, ItemBase._Meta )
	end	
	
	if tbl.MaxStack > 100 then
		error("Item " .. tostring(name) .. " has too big of a stack.")
	end
	
	ItemList[ name ] = tbl
	ItemListId[ tbl._hash ] = tbl
	
end

local function RawNewItem( Item )
	
	if not Item then
		error("Trying to create a item that does not exist!")
	end
	
	if string.match( Item.UniqueName, "%_base" ) then
		error("Attempting to create a base item!")
	end
	
	local t = {}
	
	setmetatable( t, Item._Meta )
	
	t:Init()
	
	return t
	
end

function NewItemById( id )
	return RawNewItem( ItemListId[ id ] )
end

function NewItem( name )
	return RawNewItem( ItemList[ name ] )
end

/**
 * Called when the item is first created
 */
function ItemBase:Init()

end

/**
 * Returns a new item split from this current item
 */
function ItemBase:Split( amount )
	
	if amount < 1 or amount >= self:GetStack() then
		error("Can not split item of invalid size.")
	end
	
	local NewItem = NewItemById( self._hash )
	
	self:SetStack( self:GetStack() - amount )
	NewItem:SetStack( amount )
	
	NewItem:OnSplit( self )
	
	return NewItem
	
end


function ItemBase:OnSplit( original )
		
end

/**
 * Return the hash id of the item
 */
function ItemBase:GetId()
	return self._hash
end

/**
 * Can the item be placed in the given slot?
 */
function ItemBase:Allow( slot )
	return true
end

/**
 * Return the number of items remaining on this stack item
 */
function ItemBase:GetStack()
	return self.StackSize
end

/**
 * Set the stack size of this item
 */
function ItemBase:SetStack( amount )
	
	if amount <= 0 then
		error("Trying to set size of the stack <= 0")
	end
	
	if amount > self.MaxStack then
		error("Trying to set too many items on this stack!")
	end
	
	self.StackSize = amount
	
	local slot = self:GetSlot()
	
	if slot then
		slot:ItemChanged()
	end
	
end

/**
 * Return the slot that the item is located, nil if it on the ground
 */
function ItemBase:GetSlot()
	return self.Slot
end

/**
 * Hook to when the item is placed on a slot
 */
function ItemBase:OnSlot()

end

/**
 * Hook to when the item is removed from a slot
 */
function ItemBase:OnSlotRemove( slot )

end

/**
 * Returns the entity that is item is attached with
 */
function ItemBase:GetEntity()
	return self.__Entity
end

function ItemBase:SetEntity( ent )
	self.__Entity = ent
end

if SERVER then
	
	/**
	 * Return the {Entity} to be dropped on the floor 
	 */
	function ItemBase:GetDropEnt() //Called when items is dropped by player
		local ent
	
		if !self.Classname then
			ent = ents.Create("prop_physics")
			ent:SetModel(self.Model)
			
			if self.ModelSkinId then
				ent:SetSkin( self.ModelSkinId )
			end
		else
			ent = ents.Create( self.Classname )
		end
		
		if !ValidEntity( ent ) then
			error("Could not create entity")
		end
		
		local phys = ent:GetPhysicsObject()
		if phys and phys:IsValid() then
			phys:EnableMotion( self.EnableMotion )
		end
		
		ent:DrawShadow( false )
		ent:SetItem( self )
		
		return ent
	end 
	
	/**
	 * Call when the item has changed to be notified to the network
	 */
	function ItemBase:ItemChanged()
		self:GetSlot():ItemChanged()
	end
	
	/**
	 * Write to the {Packet} about any information to be sent to the client
	 */
	function ItemBase:WritePacket( packet )
		
	end
	
else

	/**
	 * Read Umsg about anything written on WritePacket
	 */
	function ItemBase:ReadPacket( um )
		
	end
	
	/**
	 * Get the center and camera position to be displayed on icon 
	 */
	function ItemBase:GetRenderPos( ent )
		local RenderMin, RenderMax = ent:GetRenderBounds()
				
		return (RenderMin+RenderMax) / 2 , RenderMax * 2
	end
end

function ItemBase:GetSaveData()
		
	local data = {
		id = self:GetId()
	}
	local stack = self:GetStack()
	
	if stack != 1 then
		data.stack = stack
	end
		
	return data
	
end

function ItemBase:LoadSaveData( data )
	
	if data.stack then
		self:SetStack( data.stack )
	end

end

