
module("Group", package.seeall )

GROUPGUI = GROUPGUI or {}

function GROUPGUI:Init()
	
	self.BaseClass.Init( self )
	
	self:SetSize( 200, 250 )	
	
	self:UpdateNoGroup()
	
end


function GROUPGUI:Update( group )
	
	self.Group = group
	
	if self.Group then
		self:UpdateGroup()
	else
		self:UpdateNoGroup()
	end
	
end

function GROUPGUI:UpdateNoGroup()
	
	SafeRemove( self.GroupPanel )
	
	if not ValidPanel( self.Text ) then
		self.Text = vgui.Create("DLabel", self )
	end
	
	self.Text:SetText("You are not\n in a group.")
	self.Text:SetFont("Trebuchet24")
	self.Text:SizeToContents()
	self.Text:Center()
	
end	

function GROUPGUI:UpdateGroup()
	
	SafeRemove( self.Text )
	
	if not ValidPanel( self.GroupPanel ) then
		self.GroupPanel = vgui.Create("group_body", self )
	end
	
	self.GroupPanel:StretchToParent( 0, 0, 0, 0 )
	self.GroupPanel:Update( self.Group )
	self.GroupPanel:InvalidateLayout()

end


vgui.Register("group_main", GROUPGUI, "DPanel" )



GROUPBODY = GROUPBODY or {}

function GROUPBODY:Init()
	
	self.List = vgui.Create("DPanelList", self )
	self.LeaveButton = vgui.Create("DButton", self )
	
	self.LeaveButton:SetText( "LEAVE" )
	self.LeaveButton.DoClick = function()
		Derma_Query("Are you sure you want to leave the group", "LEAVE",
			"YES", function() RunConsoleCommand("group_leave" ) end,
			"NO" )
	end
	
	
end

function GROUPBODY:PerformLayout()
	
	self.List:StretchToParent( 2, 23, 2, 2 )
	
	self.LeaveButton:SetSize( self:GetWide() * 0.3, 18 )
	self.LeaveButton:AlignRight( 2 )
	self.LeaveButton:AlignTop( 2 )

end

function GROUPBODY:HasPlayer( ply )
	for _, v in pairs( self.List.Items ) do
		if v.Player == ply then
			return true
		end
	end
	return false
end

function GROUPBODY:AddPlayer( ply )
	
	local panel = vgui.Create("group_item", self )
	panel:SetPlayer( ply )
	
	self:UpdateControl( panel )
	
	self.List:AddItem( panel )
	
	return panel
	
end

function GROUPBODY:UpdateControl( panel )
	panel:UpdateControl( self.Group:GetOwner() == LocalPlayer() )
	panel:IsOwner( self.Group:GetOwner() == panel.Player )
end

function GROUPBODY:Update( group )

	self.Group = group
	
	for _, ply in pairs( group:GetPlayers() ) do
		if not self:HasPlayer( ply ) then
			self:AddPlayer( ply )
		end	
	end
	
	for _, panel in pairs( self.List.Items ) do
		if not group:HasPlayer( panel.Player ) then
			self.List:RemoveItem( panel )
		else
			self:UpdateControl( panel )
		end
	end

end

vgui.Register("group_body", GROUPBODY )




GROUPITEM = GROUPITEM or {}

function GROUPITEM:Init()
	self.Avatar = vgui.Create("AvatarImage", self )
	self.Avatar:SetPos( 0, 0)
	self.Avatar:SetSize( 32, 32 )
	
	self.Name = vgui.Create("DLabel", self )
	
	self:SetTall( 32 )
end

function GROUPITEM:SetPlayer( ply )
	self.Player = ply
	
	self.Avatar:SetPlayer( ply, 32 )
end

function GROUPITEM:IsOwner( owner )
	
	if not owner then
		SafeRemove( self.OwnerStar )
		return
	end
	
	if not ValidPanel( self.OwnerStar ) then
		self.OwnerStar = vgui.Create("DImage", self )
		self.OwnerStar:SetImage("gui/silkicons/star")
		self.OwnerStar:SizeToContents()
	end
	
end

function GROUPITEM:UpdateControl( control )
	self.CanControl = control
	
	if self.Player == LocalPlayer() then
		return
	end
	
	if not control then
		SafeRemove( self.OwnerButton )
		SafeRemove( self.RemoveButton )
		return
	end
	
	local PlyId = self.Player:EntIndex()
	local Name = self.Player:GetName()
	
	if not ValidPanel( self.OwnerButton ) then
		self.OwnerButton  = vgui.Create("DImageButton", self )
		self.OwnerButton:SetImage("gui/silkicons/star")
		self.OwnerButton:SetToolTip("SET OWNER")
		self.OwnerButton.DoClick = function()
			Derma_Query("Are you sure you want to set " .. Name .. " as the owner?", "SET OWNER",
				"YES", function() RunConsoleCommand("group_owner", PlyId ) end,
				"NO" )			
		end	
	end
	
	if not ValidPanel( self.RemoveButton ) then
		self.RemoveButton = vgui.Create("DImageButton", self )
		self.RemoveButton:SetImage("gui/silkicons/bomb")
		self.RemoveButton:SetToolTip("REMOVE")
		self.RemoveButton.DoClick = function()
			Derma_Query("Are you sure you want to REMOVE " .. Name .. "?", "REMOVE PLAYER",
				"YES", function() RunConsoleCommand("group_remove", PlyId ) end,
				"NO" )
		end	
	end
	
	self:InvalidateLayout()
	
end

function GROUPITEM:PerformLayout()
	
	if not ValidEntity( self.Player ) then
		return
	end	
	
	self.Name:SetText( self.Player:GetName() )
	
	local Left = self.Avatar
	
	if ValidPanel( self.OwnerStar ) then
		self.OwnerStar:MoveRightOf( self.Avatar, 4 )
		self.OwnerStar:CenterVertical()
		
		Left = self.OwnerStar
	end
	
	self.Name:MoveRightOf( Left, 4 )
	self.Name:CenterVertical()
	
	if ValidPanel( self.OwnerButton ) and ValidPanel( self.RemoveButton ) then	
		self.OwnerButton:SizeToContents()
		self.RemoveButton:SizeToContents()
		
		self.OwnerButton:CenterVertical()
		self.RemoveButton:CenterVertical()
		
		self.RemoveButton:AlignRight( 4 )
		self.OwnerButton:MoveLeftOf( self.RemoveButton, 4 )
	end	
	
end

vgui.Register("group_item", GROUPITEM )