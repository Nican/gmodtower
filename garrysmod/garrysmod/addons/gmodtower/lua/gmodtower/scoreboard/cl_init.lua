include("cl_playerlist.lua")
include("cl_playeritem.lua")
include("cl_scoreboard.lua")

--[[
	TODO: This really should not be in the addons, but what is the better place?
]]

module("Scoreboard", package.seeall )

if ValidPanel( ScoreboardPanel ) then
	ScoreboardPanel:Remove()
	ScoreboardPanel = nil
end

hook.Add("ScoreboardShow", "ShowNCScoreboard", function()

	if not ValidPanel( ScoreboardPanel ) then
		ScoreboardPanel = vgui.Create("ScoreboardMain")
	end
	
	gui.EnableScreenClicker( true )
	
	ScoreboardPanel:SetVisible( true )
	ScoreboardPanel:InvalidateLayout( true )
	
	return true
	
end )

hook.Add("ScoreboardHide", "HideNCScoreboard", function()

	gui.EnableScreenClicker( false )
	
	if ValidPanel( ScoreboardPanel ) then 
		ScoreboardPanel:SetVisible( false )
	end
	
	return true
	
end )

hook.Add("HUDDrawScoreBoard", "NoDrawScoreboard", function() 
	return true
end )