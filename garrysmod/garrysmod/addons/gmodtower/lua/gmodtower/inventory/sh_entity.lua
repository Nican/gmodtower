local EntMeta = FindMetaTable("Entity")


if SERVER then

	function EntMeta:SetItem( item )
		if self.__Item then
			self.__Item:SetEntity( nil )
		end	
	
		self.__Item = item
		
		if item then
			self:SetDTInt( 3, item._hash )
			item:SetEntity( self )
		else
			self:SetDTInt( 3, 0 )
		end
		
	end
	
	function EntMeta:GetItem()
		return self.__Item
	end
	

else

	function EntMeta:GetItem()
	
		if self.__Item then
			return self.__Item
		end
		
		local ItemId = self:GetDTInt( 3 )
		
		if ItemId > 0 then
			
			self.__Item = Inventory.NewItemById( ItemId )
			self.__Item:SetEntity( self )
			return self.__Item
			
		end		
	
	end

end
