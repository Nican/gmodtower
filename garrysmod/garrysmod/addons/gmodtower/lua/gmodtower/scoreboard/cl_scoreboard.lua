module("Scoreboard", package.seeall )

print("StartInclude")

SCOREBOARD = SCOREBOARD or {}


function SCOREBOARD:Init()

	self.BaseClass.Init( self )
	
	self.PlayerList = vgui.Create("ScorePlayers", self )
	self.PlayerList:SetPos( 4, 4 )
	
end


function SCOREBOARD:PerformLayout()
	
	self.BaseClass.PerformLayout( self )
	
	self.PlayerList:InvalidateLayout( true )
	
	local w,h = self.PlayerList:GetSize()
	
	self:SetSize( w + 8, h + 8 )
	self:Center()	

end

vgui.Register("ScoreboardMain", SCOREBOARD, "DPanel" )