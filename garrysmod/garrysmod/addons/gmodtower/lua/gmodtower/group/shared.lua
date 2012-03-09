include("sh_group.lua")

module("Group", package.seeall )

DEBUG = false

local MetaPlayer = FindMetaTable("Player")

/**
	Return player group if it exists
	Return nil if player is not in a group
*/
function MetaPlayer:GetGroup()

	return self.Group
	
end