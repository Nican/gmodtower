AddCSLuaFile("cl_init.lua")
AddCSLuaFile("sh_store.lua")
AddCSLuaFile("cl_panel.lua")
AddCSLuaFile("sh_list.lua")
AddCSLuaFile("sh_npc_store.lua")
AddCSLuaFile("sh_storeitem.lua")

include("sh_store.lua")
include("sh_list.lua")
include("sh_npc_store.lua")


module("Inventory.Store", package.seeall )

function Open( ply, Store )
	
	umsg.Start("store", ply )
		
		umsg.Char( 1 )
		umsg.String( Store.Name )
	
	umsg.End()

end

concommand.ClientAdd("store_buy", function( ply, cmd, args )

	if #args < 2 then
		return
	end
	
	--Player does not have an inventory yet to store stuff
	if not ply.Inventory then
		return
	end
	
	local StoreName = args[1]	
	local Store = Get( StoreName ) --Throws an error if the store does not exist
	
	--Check if the player is in range with the entity, and the store is open, etc...
	if not Store:Allow( ply ) then
		clientError("You are not allowed to use that store.")
	end
	
	local StoreItemId = tonumber( args[2] ) or 0
	local StoreItem = Store:GetItemById( StoreItemId )
	local Price = StoreItem:GetPrice()
	local Stack = StoreItem:GetStack()
	
	if not ply:Afford( Price ) then
		clientError("You do not have enough money.")
	end
	
	--Create the item that is going to be put in the player inventory
	local Item = Inventory.NewItem( StoreItem.Name )
	Item:SetStack( Stack )
	
	--Get the slot that the player chose or find one
	local slot = ply.Inventory:GetSlot( 1, tonumber( args[3] ) or 0 )
	
	if not slot or not slot:Empty() then
		clientError("Slot is not empty.")
	end
	
	if not slot:Allow( Item ) then
		clientError("Slot does not allow item.")
	end
	
	--Woot! We passed all the checks
	ply:AddMoney( -Price )
	slot:Set( Item )

end )