

module("Inventory.Store", package.seeall )

STOREITEM = STOREITEM or {}
STOREITEMMeta = {
	__index = STOREITEM
}


function NewItem( item )

	setmetatable( item, STOREITEMMeta )

	return item
end

function STOREITEM:GetItem()
	if not self.Item then
		self.Item = Inventory.NewItem( self.Name )
		self.Item:SetStack( self:GetStack() )
	end

	return self.Item
end

function STOREITEM:GetPrice()
	return self.Price
end

function STOREITEM:GetStack()
	return self.Stack or 1
end