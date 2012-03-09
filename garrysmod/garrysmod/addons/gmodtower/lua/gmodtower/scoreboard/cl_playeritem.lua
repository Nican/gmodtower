
module("Scoreboard", package.seeall )

PLAYERITEM = PLAYERITEM or {}

function PLAYERITEM:Init()
	self.Avatar = vgui.Create("AvatarImage", self )
	self.Avatar:SetPos( 0, 0 )
	self.Avatar:SetSize( 32, 32 )
	
	self.Name = vgui.Create("DLabel", self )
	self.Name.x = 36
	self.Name:SetMouseInputEnabled( false )
	
	self:SetSize( 500, 32 )
	
end

function PLAYERITEM:SetPlayer( ply )
	self.Player = ply
	
	self.Avatar:SetPlayer( ply, 32 )

	
end

function PLAYERITEM:Update()
	
	self.Name:SetText( self.Player:GetName() )
	self.Name:SizeToContents()
	self.Name:CenterVertical()
	
end

function PLAYERITEM:OnMouseReleased()
	ClientMenu.Open( self.Player )
end


function PLAYERITEM:GetPlayer()
	return self.Player
end

vgui.Register("ScoreboardPlayer", PLAYERITEM )