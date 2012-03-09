

local PANEL = {}
local BagPanelList = {}


function PANEL:Init()

	self.BaseClass.Init( self )
	
	table.insert( BagPanelList, self )
	
	self:SetSpacing( 2 )
	self:SetPadding( 2 )
	self:EnableHorizontal( true )
	self:SetDrawBackground( false )
	//self:SetAutoSize( true )
	
end

function PANEL:SetBag( bag )

	self.Bag = bag
	self.Bag.VGUI = bag
	
	self:BagUpdate()
	
end

function PANEL:BagUpdate()
	
	--TODO: Do not clear all the slots
	--Only remove the slots that needs to be removed and add the ones that needs to be added
	self:Clear()
	
	for k, slot in ipairs( self.Bag.Slots ) do
		
		local SlotPanel = vgui.Create("SlotHolder", self )
		SlotPanel:SetSlot( slot )
		
		self.Items[ k ] = SlotPanel
	
	end
	
end

function PANEL:GetMouseOverSlot( ignoreSlot )
	
	for k, slot in ipairs( self.Items ) do
		
		if slot != ignoreSlot and slot:IsMouseInWindow() then
			return slot
		end		
	
	end

end

vgui.Register("BagHolder", PANEL, "DPanelList" )



hook.Add("InvDropSlotPanel", "CheckSlotPanels", function( slot )
	
	for k, bagPanel in pairs( BagPanelList ) do
	
		if !ValidPanel( bagPanel ) then
			
			BagPanelList[ k ] = nil
		
		elseif bagPanel:IsVisible() && bagPanel:IsMouseInWindow() then
			
			local slotPanel = bagPanel:GetMouseOverSlot( slot )
				
			if slotPanel then
				return slotPanel
			end
			
		end
	
	end
	
end )