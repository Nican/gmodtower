

module("Scoreboard", package.seeall )

PLAYERLIST = PLAYERLIST or {}
PLAYERLIST.NextUpdate = 0

function PLAYERLIST:Init()
	self.BaseClass.Init( self )
	
	self:SetWide( 500 )
	self:SetNoSizing( true )
end
	
	
function PLAYERLIST:HasPlayer( ply )
	
	for _, item in pairs( self.Items ) do
		if item:GetPlayer() == ply then
			return true
		end
	end
	
	return false	
end


function PLAYERLIST:CreatePlayer( ply )
	local pnl = vgui.Create("ScoreboardPlayer", self )
	pnl:SetPlayer( ply )
	
	self:AddItem( pnl )
	
	return pnl
end

function PLAYERLIST:Think()
	
	if CurTime() > self.NextUpdate then
		self:InvalidateLayout()		
		self.NextUpdate = CurTime() + 2.0
	end
	
end

function PLAYERLIST:PerformLayout()

	for _, ply in ipairs( player.GetAll() ) do
		if not self:HasPlayer( ply ) then
			self:CreatePlayer( ply )
		end
	end
	
	for id, item in pairs( self.Items ) do
		if not ValidPlayer( item:GetPlayer() ) then
			self:RemoveItem( item )
		else
			item:Update()
		end
	end
	
	self.BaseClass.PerformLayout( self )

	self:SizeToContents()
	
end


vgui.Register("ScorePlayers", PLAYERLIST, "DPanelList" )