include("shared.lua")
include("cl_bagpanel.lua")
include("cl_slotpanel.lua")
include("cl_itempanel.lua")
include("cl_grabpanel.lua")
include("store/cl_init.lua")

local vgui = vgui
local hook = hook
local usermessage = usermessage
local concommand = concommand
local LocalPlayer = LocalPlayer
local print = print
local BarItem = Taskbar.New({
	Icon="gui/silkicons/box", 
	Order=0,
	Panel = "inv_main"
})
 
module("Inventory" )

SlotSize = 42

function Get()
	
	if not Active then
		Active = NewInventory( LocalPlayer() )
	end
	
	return Active
end

concommand.DebugAdd("inv_test", function( ply, cmd, args )
	
	local frame = vgui.Create("DFrame")
	local bag = vgui.Create("BagHolder", frame )
	
	bag:SetBag( Get():GetBag( 1 ) )
	bag:SetPos( 5, 26 )
	bag:PerformLayout( true )
	
	frame:SetVisible( true )	
	frame:SetDraggable( true )
	
	frame:SetSize( bag:GetWide() + 5, bag:GetTall() + 30 )

end )

local function ReadNetworkPacket( um )
	
	local BagId = um:ReadChar()
	local SlotId = um:ReadChar()
	
	local Slot = Get():GetSlot( BagId, SlotId )
	
	Slot:ReadNetworkPacket( um )
	
end

usermessage.Hook("Inv", function( um )

	local Id = um:ReadChar()
	
	if Id == 0 then
		
		local Count = um:ReadChar()
		
		for i=1, Count do
			SafeCall( ReadNetworkPacket, um )
		end
	
	end

end )

MAINPANEL = MAINPANEL or {}

MAINPANEL.Padding = 3

function MAINPANEL:Init()

	self.BaseClass.Init( self )
	
	self.Bag = vgui.Create("BagHolder", self )
	self.Bag:SetBag( Get():GetBag( 1 ) )
	self.Bag:SetPos( self.Padding, self.Padding )

end

function MAINPANEL:PerformLayout()

	self.BaseClass.PerformLayout( self )
	
	local Wide = self.Padding + self.Padding + 8 * ( SlotSize + self.Bag:GetSpacing() ) + self.Bag:GetPadding()
	
	self:SetWide( Wide )
	
	self.Bag:SetWide( Wide - self.Padding * 2 )
	self.Bag:InvalidateLayout( true )
	self.Bag:SizeToContents()
	
	self:SetTall( self.Bag:GetTall() + self.Padding * 2 )

end

vgui.Register("inv_main", MAINPANEL, "DPanel")