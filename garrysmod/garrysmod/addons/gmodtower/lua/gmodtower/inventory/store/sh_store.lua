include("sh_storeitem.lua")

module("Inventory.Store", package.seeall )

STORE = STORE or {}
STOREMeta = {
	__index = STORE
}

StoreList = StoreList or {}

function New( name, store )

	for id, item in pairs( store.Items ) do
		store.Items[ id ] = NewItem( item )
	end

	setmetatable( store, STOREMeta )

	store.Name = name
	
	StoreList[ name ] = store
	
end

function Get( name )
	if not StoreList[ name ] then
		clientError("Getting invalid store: " .. name .. "!\n")
	end

	return StoreList[ name ]
end
	
--[[[
	Check if the player is allowed to use the store
]]
function STORE:Allow( ply )

	local plyPos = ply:GetPos()
	
	if self.SellerClass then
		
		for _, ent in ipairs( ents.FindByClass( self.SellerClass ) ) do
			
			if ent:GetPos():Distance( plyPos ) < 512 then
				return true
			end
		
		end
		
	end

	return _G.DEBUG --Only allow to use the store any time if we are in debug mode
end

function STORE:GetItemById( id )
	
	local item = self.Items[ id ]
	
	if not item then
		clientError("Store does not sell item with given id.")
	end
	
	return item
	
end

function STORE:GetItems()
	return self.Items
end

function STORE:BuyRatio( Item )
	return 0.75
end
