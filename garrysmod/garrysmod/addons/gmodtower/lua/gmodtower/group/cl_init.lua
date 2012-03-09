include("shared.lua")
include("cl_gui.lua")
include("cl_noticeicon.lua")

local BarItem = Taskbar.New({
	Icon="gui/silkicons/group",
	Order=1,
	Panel = "group_main",
	TaskBarPanel = "GroupTaskBar",
})

module("Group", package.seeall )


usermessage.Hook("Group", function( um )
	
	local Id = um:ReadChar()
	
	if Id == 0 then
		
		local Group = New( um:ReadEntity() )
		local count = um:ReadChar()
		local players = {}
		
		for i=1, count do
			table.insert( players, um:ReadEntity() )
		end
		
		Group.Players = players
		
		LocalPlayer()._Group = Group
		
		hook.Call("GroupUpdate", _G.GAMEMODE, Group )
		
	elseif Id == 1 then
		
		LocalPlayer()._Group = nil
		
		hook.Call("GroupUpdate", _G.GAMEMODE, nil )
	
	elseif Id == 2 then
		
		GetInvite( um:ReadEntity() )
	
	end

end )

hook.Add("GroupUpdate", "UpdateUI", function( group )
	local Menu = BarItem:GetMenu()
	
	Menu:Update( group )
end )

function GetInvite( ply )

	if not ValidEntity( ply ) then
		return
	end
	
	local plyId = ply:EntIndex() 
	
	Topbar.New({
		Icon = "gui/silkicons/group",
		Player = ply,
		OnAccept = function() 
			RunConsoleCommand("group_accept", plyId )
		end,
		Timeout = 30,
		Message = "<color=red><font=TabLarge>" .. ply:GetName() .. "</font></color> has invited you to his group.",
	})
	
end

/**
	Returns the local group the localplayer is in
*/
function Get()
	return LocalPlayer()._Group
end

function InvitePlayer( ply )
	RunConsoleCommand("group_invite", ply:EntIndex() )
end

hook.Add("ClientMenu", "InviteToGroup", function( ply, menu )
	
	if ply == LocalPlayer() then
		return
	end
	
	local Group = Group.Get()
	
	if IsValid( Group ) and  Group:GetOwner() != LocalPlayer() then
		return
	end
	
	menu:AddOption("Invite to group", function()
		InvitePlayer( ply )
	end )

end )