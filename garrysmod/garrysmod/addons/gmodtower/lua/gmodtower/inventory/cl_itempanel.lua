module("Inventory.Panels", package.seeall )

ITEMPANEL = ITEMPANEL or {}


function ITEMPANEL:Init()
	
	self.BaseClass.Init( self )
	
	self.StackLabel = vgui.Create("Label", self )
	self.StackLabel:SetFont( "TabLarge")
	
	self:SetMouseInputEnabled( false )

end

function ITEMPANEL:SetItem( item )
	
	self.Item = item
	
	if not item.Model then
		return
	end
	
	self:SetModel( self.Item.Model )
	
	if not ValidEntity( self.Entity ) then
		return
	end
	
	local look, camera = self.Item:GetRenderPos( self.Entity )
	
	self:SetLookAt( look )
	self:SetCamPos( camera )
	
end

function ITEMPANEL:Paint()
	
	self.BaseClass.Paint( self )
	
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawOutlinedRect( 0, 0, self:GetSize() )
	
end

function ITEMPANEL:GetItem()
	return self.Item
end

function ITEMPANEL:PerformLayout()
	
	local Item = self:GetItem()
	local stack = Item:GetStack()
	
	self.StackLabel:SetVisible( stack != 1 )
	self.StackLabel:SetText( stack ) //.. "/" .. Item.MaxStack )
	
	self.StackLabel:SizeToContents()
	self.StackLabel:AlignBottom( 2 )
	self.StackLabel:AlignRight( 2 )
	
end

vgui.Register("ItemHolder", ITEMPANEL, "DModelPanel" )
