module("Inventory.Panels", package.seeall )

local PANEL = {}

function PANEL:SetEntity( ent )
	self.Entity = ent
end

function PANEL:GetItem()
	return self.Entity:GetItem()
end

function PANEL:GetSlot()
	clientError("Getting slot from invalid slot." .. debug.traceback() )
end

function PANEL:PerformSwap( target )
	
	local slot = target:GetSlot()
	
	if not slot:CanManage() then
		return
	end
	
	if not slot:Allow( self:GetItem() ) then
		return
	end
	
	RunConsoleCommand("inv_grab", slot:GetBag():GetId(), slot:GetId(), self.Entity:EntIndex() )
	
end

function PANEL:SpawnEntity()
	
	local aim = LocalPlayer():GetCursorAimVector()
	
	RunConsoleCommand("inv_move", 
		self.Entity:EntIndex(),
		aim.x,
		aim.y,
		aim.z,
		self.GhostRotation
		)
		
end

function PANEL:Think()
	if !ValidEntity( self.Entity ) then
		self:EndDragging()
		return
	end

	self.BaseClass.Think( self )
	
end

function PANEL:GetFilter()
	return {GhostEntity,LocalPlayer(),self.Entity}
end

function PANEL:EndDragging()
	self.BaseClass.EndDragging( self )
	self:Remove()
end

vgui.Register("InvSlotGrab", PANEL, "SlotHolder")



hook.Add("GUIMousePressed", "GtowerMousePressed", function( mc )

	local trace = LocalPlayer():GetEyeTrace()

	if !ValidEntity(trace.Entity) then return end
	
	if ValidPanel( ActiveGrab ) then
		if ActiveGrab.Entity == trace.Entity then
			return
		end
		ActiveGrab:Remove()
	end

	local Item = trace.Entity:GetItem()
	
	if Item then
		
		ActiveGrab = vgui.Create("InvSlotGrab")
		ActiveGrab:SetEntity( trace.Entity )
		ActiveGrab:SlotUpdate()
		ActiveGrab:StartDragging()
		
	end
	
	
end )
 