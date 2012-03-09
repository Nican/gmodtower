include("shared.lua")

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_gui.lua")
AddCSLuaFile("sh_group.lua")
AddCSLuaFile("cl_noticeicon.lua")

module("Group", package.seeall )

List = List or {}

/**
	Return indexed table of groups in the server
*/
function GetGroups()
	return List
end

/**
	Get group of the id
*/

function Get( id )
	return Group[ id ]
end

/**
	Get group by player
*/
function _R.Player:GetGroup()
	return self._Group
end

local function VerifyOwnerGroup( ply, target )

	if not target then
		clientError("Invalid target.")
	end
	
	local Group = ply:GetGroup()
	
	if not IsValid( Group ) then
		clientError("You are not in a group.")
	end
	
	if Group:GetOwner() != ply then
		clientError("You are not the owner of the group.")
	end
	
	local target = Entity( tonumber( target ) or 0 )
	
	if not ValidPlayer( target ) or target == ply then
		clientError("Can not invite invalid player.")
	end
	
	if not Group:HasPlayer( target ) then
		clientError("Target player is not in group.")
	end
	
	return Group, target
	
end

concommand.ClientAdd("group_remove", function( ply, cmd, args )
	
	local Group, target = VerifyOwnerGroup( ply, args[1] )
	
	Group:RemovePlayer( target )
	Group:SendNetwork()
	
end )


concommand.ClientAdd("group_owner", function( ply, cmd, args )
	
	local Group, target = VerifyOwnerGroup( ply, args[1] )
	
	Group:SetOwner( target )
	Group:SendNetwork()

end )

concommand.ClientAdd("group_leave", function( ply, cmd, args )
	
	local Group = ply:GetGroup()
	
	if not IsValid( Group ) then
		clientError("You are not in a group.")
	end

	Group:RemovePlayer( ply )
	Group:SendNetwork()
	
end )

concommand.ClientAdd("group_accept", function( ply, cmd, args )

	if #args < 1 then
		return
	end
	
	if IsValid( ply:GetGroup() ) then
		clientError("You are already in a group.")
	end
	
	local target = Entity( tonumber( args[1] ) or 0 )
	
	if not ValidPlayer( target ) or target == ply then
		clientError("Can not invite invalid player.")
	end
	
	local Group = target:GetGroup()
	
	if Group:GetOwner() != target then
		clientError("Can not accept the invite.")
	end
	
	Group:AcceptInvite( ply )

end )


concommand.ClientAdd("group_invite", function( ply, cmd, args )
	
	local Group = ply:GetGroup()
	
	if not Group or not Group.IsValid then
		Group = New( ply )
	end
	
	if Group:GetOwner() != ply then
		clientError("You are not the owner.")
	end
	
	local target = Entity( tonumber( args[1] ) or 0 )
	
	if not ValidPlayer( target ) or ply == target then
		clientError("Can not invite invalid player.")
	end
	
	if IsValid( target:GetGroup() ) then
		clientError("Player is already in a group.")
	end
	
	Group:CreateInvite( target )
	
	if _G.DEBUG and target:IsBot() then
		Group:AcceptInvite( target )
	end
	
end )