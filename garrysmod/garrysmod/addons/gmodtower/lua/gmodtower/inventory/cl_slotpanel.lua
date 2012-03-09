
module("Inventory.Panels", package.seeall )

SLOTPANEL = SLOTPANEL or {}

SLOTPANEL.GhostRotation = 0

function SLOTPANEL:Init()
	
	DPanel.Init( self )
	self.ItemPanel = nil
	self.BagParent = self:GetParent()
	
	self:SetSize( Inventory.SlotSize, Inventory.SlotSize )
	
	self:SetMouseInputEnabled( true )
	
end

function SLOTPANEL:SetSlot( slot )
	self.Slot = slot
	self.Slot.VGUI = self
	self:SlotUpdate()
end

function SLOTPANEL:GetSlot()
	return self.Slot
end

function SLOTPANEL:GetItem()
	return self.Slot:Get()
end

function SLOTPANEL:SlotUpdate()
	
	local item = self:GetItem()
	local validChild = ValidPanel( self.ItemPanel )
	
	if not item then
		
		if validChild then
			self.ItemPanel:Remove()
			self.ItemPanel = nil
		end
		
	else
		
		if validChild then
			if self.ItemPanel:GetItem() != item then
				self.ItemPanel:Remove()
				self.ItemPanel = nil
			end
		end
		
		if not ValidPanel( self.ItemPanel ) then
			
			self.ItemPanel = vgui.Create( "ItemHolder", self)
			self.ItemPanel:SetItem( item )
			
		end
		
	end
	
	self:InvalidateLayout()
	
end

function SLOTPANEL:Think()
	
	if self:IsDragging() then
		self:MouseDragThink()
	end
	
end

function SLOTPANEL:PerformLayout()

	DPanel.PerformLayout( self )
	self:SetSize( Inventory.SlotSize, Inventory.SlotSize )
	
	if ValidPanel( self.ItemPanel ) then
		self.ItemPanel:SetSize( Inventory.SlotSize, Inventory.SlotSize )
	end
	
end

/** ===============
	MOUSE/DRAG 
    =============== */
	
function SLOTPANEL:OnMousePressed( mc )

	if not self:GetItem() then
		return
	end
	
	if mc == MOUSE_LEFT or mc == MOUSE_RIGHT then
		self:StartDragging()
	end
	
end

function SLOTPANEL:OnMouseReleased( mc )
	
	if not self:IsDragging() then
		return
	end
	
	self:EndDragging()
	
	if mc == MOUSE_RIGHT then
		
		local x, y = gui.MousePos( )
		
		if math.abs( self.PressMousePos[1] - x ) < 5 and math.abs( self.PressMousePos[2] - y ) < 5 then
			--TODO: Show right click menu
			
			return
		end
		
	end
	
	local DropPanel = hook.Call("InvDropSlotPanel", GAMEMODE, self )
	
	if DropPanel then
		--TODO: If using the right mouse, make sure to display quantity
		self:PerformSwap( DropPanel, 0 )
		return
	end
	
	self:SpawnEntity()
	
end	

function SLOTPANEL:SpawnEntity()
	
	local aim = LocalPlayer():GetCursorAimVector()
	local slot = self:GetSlot()
	
	RunConsoleCommand("inv_spawn", 
		slot:GetBag():GetId(), 
		slot:GetId(), 
		aim.x,
		aim.y,
		aim.z,
		self.GhostRotation
		)
		
end

function SLOTPANEL:PerformSwap( slotPanel, amount )
		
	local slot1 = self:GetSlot()
	local slot2 = slotPanel:GetSlot()
	
	if not slot1:CanManage() or not slot2:CanManage() then
		print("You can not manage one of the slots.")
		return --TODO: Show nice error message?
	end
	
	local item1 = slot1:Get()
	local item2 = slot2:Get()
	
	if not slot2:Allow( item1 ) or not slot1:Allow( item2 ) then
		print("One of the slots does not accept the item.")
		return --TODO: Show nice error message?
	end
	
	--Send the request to the server, and let the message back do the actual swapping
	RunConsoleCommand("inv_swap", slot1:GetBag():GetId(), slot1:GetId(), slot2:GetBag():GetId(), slot2:GetId(), amount or 0 )
	
end

function SLOTPANEL:StartDragging()

	if self:IsDragging() then
		return
	end
	
	self.PressMousePos = {gui.MousePos()}
	self.Dragging = true
	self:SetParent( nil )
	self:SetAlpha( 125 )
	self:SetZPos( 2 )
	
end

function SLOTPANEL:MouseDragThink()
	
	local MouseX, MouseY = gui.MousePos( )
	
	self:SetPos( MouseX - self:GetWide() / 2, MouseY - self:GetTall() / 2 )
	
	local DropPanel = hook.Call("InvDropSlotPanel", GAMEMODE, self )
	
	if not ValidPanel( DropPanel ) then
	
		local item = self:GetItem()
		
		if not item then
			self:DestroyGhost()
			return
		end
		
		if not ValidEntity( GhostEntity ) then
			self:CreateGhost( item )
		end
		
		self:GhostThink()
		
	else
		self:DestroyGhost()
	end
	
end	

function SLOTPANEL:EndDragging()
	
	self.Dragging = false
	self:SetParent( self.BagParent )
	self.BagParent:InvalidateLayout()
	self:SetZPos( 0 )
	self:SetAlpha( 255 )
	
	self:DestroyGhost()
	
end

function SLOTPANEL:IsDragging()
	return self.Dragging	
end

function SLOTPANEL:CanDrag()
	return not self:GetSlot():Empty()
end

/** ===============
	GHOST ENTITY DRAG
    =============== */
	
function SLOTPANEL:OnMouseWheeled( delta )
	self.GhostRotation = math.NormalizeAngle(self.GhostRotation + delta * 15)

	// try to snap to world axes
	for i=-180, 180, 90 do
		if (self.GhostRotation > i - 15 && self.GhostRotation < i + 15) then
			self.GhostRotation = i
			break
		end
	end

end
	
//Make it a local variable to avoid duplication
local GhostEntity
	
function SLOTPANEL:CreateGhost( Item )
	
	if !GhostEntity then
		GhostEntity = ents.Create( "prop_physics" )
	end
	
	GhostEntity:SetModel( Item.Model )	
	GhostEntity:SetSkin( Item.ModelSkinId )	
	GhostEntity:SetSolid( SOLID_VPHYSICS )
	GhostEntity:SetMoveType( MOVETYPE_NONE )
	GhostEntity:SetNotSolid( true );
	GhostEntity:SetRenderMode( RENDERMODE_TRANSALPHA )
	GhostEntity:SetColor( 255, 100, 100, 150 )
	
	GhostEntity.Item = Item
	
end	
	
function SLOTPANEL:DestroyGhost()

	if IsValid( GhostEntity ) then
		GhostEntity:Remove()
	end
	
	GhostEntity = nil

end

function SLOTPANEL:GetFilter()
	return {GhostEntity,LocalPlayer()}
end

function SLOTPANEL:GhostThink()
	
	if !ValidEntity( GhostEntity ) then
		return
	end
	
	local filter = self:GetFilter()
	local Trace = util.QuickTrace(
		LocalPlayer():EyePos(),
		LocalPlayer():GetCursorAimVector() * Inventory.MaxTraceDistance,
		filter
	)
	
	local status = Inventory.Trace.UpdatePosition( GhostEntity, Trace, self.GhostRotation, filter )
	
	if status then
		GhostEntity:SetColor( 100, 255, 100, 190 )
	else
		GhostEntity:SetColor( 255, 100, 100, 190 )
	end
	
end
	

vgui.Register("SlotHolder", SLOTPANEL, "DPanel" )


