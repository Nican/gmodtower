local math = math
local error = clientError
local util = util
local Inventory = require("Inventory")
local ValidEntity = ValidEntity
local _G = _G

module("Inventory.Util")

function Swap( slot1, slot2, amount )
	
	if slot1 == slot2 then
		error("Can not swap with the same slot.")
	end
	
	if not slot1:CanManage() or not slot2:CanManage() then
		error("Player can not manage this slot.")
	end
	
	if math.floor( amount ) != amount then
		error("Hacking attempt. Got non-integer amount.")
	end
	
	local item1 = slot1:Get()
	local item2 = slot2:Get()
	
	if not slot2:Allow( item1 ) or not slot1:Allow( item2 ) then
		error("Items can not be swaped")
	end
	
	if item1 and item2 and item1.UniqueName == item2.UniqueName then
		if amount <= 0 or amount > item1.MaxStack then
			amount = item1:GetStack()
		end
	
		//Swapping the same items, if we can add the quantities
		local SpaceLeft = item2.MaxStack - item2:GetStack()
		local ToTransfer = math.min( SpaceLeft, amount  )
		
		if ToTransfer > 0 then
			if item1:GetStack() == ToTransfer then
				slot1:Remove()	
			else
				item1:SetStack( item1:GetStack() - ToTransfer ) 
			end
			
			item2:SetStack( item2:GetStack() + ToTransfer )
		end	
		
		return
	end
	
	//YAY! All requirements have passed
	slot1:Remove()
	slot2:Remove()
	
	if item1 then
		slot2:Set( item1 )		
	end
	
	if item2 then
		slot1:Set( item2 )
	end

end

function Drop( slot, start, direction, rotation )
	
	if slot:Empty() then
		error("Slot is empty.")
	end
	
	if not slot:CanManage() then
		error("Player can not manage the item.")
	end
	
	local ply = slot:GetOwner()	
	local Trace = util.QuickTrace( 
		start,
		direction * Inventory.MaxTraceDistance,
		ply
	)
	
	if not Trace.Hit then
		error("Trace does not hit anything.")
	end
	
	local Item = slot:Get()
	
	--TODO: Check if the player is allowed to drop
	
	local ent = Item:GetDropEnt()
	
	if !ValidEntity( ent ) then
		error("Unable to create entity.")
	end
	
	local status = Inventory.Trace.UpdatePosition( ent, Trace, rotation, ply )
	
	if not status then
		ent:Remove()
		error("Could not place entity at given position")
	end
	
	ent:Spawn()
	
	local NewCount = Item:GetStack() - 1
	
	if NewCount == 0 then
		ent:SetItem( Item )
		slot:Remove()
		return
	end
	
	local NewItem = Item:Split( 1 )
	ent:SetItem( NewItem )

end

function Grab( slot, ent )
	
	local Item = ent:GetItem()
	
	if not Item then
		error("Entity is not an inventory item")
	end
	
	if not slot:CanManage() then
		error("User can not manage the slot.")
	end

	if not slot:Allow( Item ) then
		error("Slot can not store the given item.")
	end
	
	if not slot:Empty() then
		local curItem = slot:Get()
		
		if curItem.UniqueName != Item.UniqueName then
			error("Slot already has an item.")
		end
		
		if curItem:GetStack() >= curItem.MaxStack then
			error("Slot is already full.")
		end
		
		curItem:SetStack( curItem:GetStack() + 1 )
		ent:SetItem( nil )
		ent:Remove()
		return
	end
	
	ent:SetItem( nil )
	ent:Remove()
	
	slot:Set( Item )

end

function Move( ent, start, direction, rotation, filter )
	
	local item = ent:GetItem()
	
	if not item then
		return
	end
	
	local Trace = util.QuickTrace( 
		start,
		direction * Inventory.MaxTraceDistance,
		filter
	)
	
	if not Trace.Hit then
		error("Trace does not hit anything.")
	end
	
	Inventory.Trace.AttemptUpdate( ent, Trace, rotation, ply )

end