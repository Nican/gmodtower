
module("Group", package.seeall )

GROUP = GROUP or {}
GROUPMeta = GROUPMeta or {
	__index = GROUP
}
MaxInviteTime = 60.0

/**
	Initialize new group with the given owner
*/
function New( owner )
	
	local Group = {
		Players = { owner },
		Invites = {},
		Owner = owner,
		Created = CurTime(),
		Valid = true
	}
	
	owner._Group = Group
	
	setmetatable( Group, GROUPMeta )
	
	if DEBUG then
		print("New group with owner: ", owner )
	end
	
	Group:SendNetwork()
	
	return Group
	
end

/**
	Gets all the players in the groups and sticks them in a recipient filter
	For clientside hooks.
*/
function GROUP:GetRP()
	
	local rp = RecipientFilter()
	
	for _, ply in pairs( self.Players ) do
		rp:AddPlayer( ply )
	end
	
	return rp
	
end

/**
	Sending Networked Vars via umsg.
	Seperates the entity index for Owner and Players.
*/
function GROUP:SendNetwork()
	if CLIENT then
		return
	end

	timer.Create( tostring(self), 0.1, 1, self._SendNetwork, self )
	
	if DEBUG then
		print("Sending network of group")
	end
end

function GROUP:_SendNetwork()

	if not self:IsValid() then
		return
	end
	
	umsg.Start("Group", self:GetRP() )
		
		umsg.Char( 0 )
		umsg.Entity( self.Owner )
		umsg.Char( #self.Players )
		
		for _, ply in ipairs( self.Players ) do
			umsg.Entity( ply )
		end
		
	
	umsg.End()
	
end

/**
	Get the player owner of the group
*/
function GROUP:GetOwner()	
	return self.Owner
end

function GROUP:SetOwner( ply )	
	self.Owner = ply
end

/**
	Get a copy of the indexed table of players in the group
*/
function GROUP:GetPlayers()	
	return table.Copy( self.Players )
end

/**
	Add player to the group
	Throws an error if the player is already in a group, unless this is the group
*/
function GROUP:AddPlayer( ply )

	if IsValid( ply._Group ) and ply._Group != self then
		Error("Player is already in a group!")
	end
	
	if DEBUG then
		print("Adding ", ply ," to group.")
	end

	ply._Group = self
	
	table.insert(self.Players, ply)
	
	hook.Call("GroupAdd", GAMEMODE, self, ply )
	
	self:SendNetwork()
	
end

/**
	Returns true if the player is in the group
*/
function GROUP:HasPlayer( ply )
	return table.HasValue( self.Players, ply )
end

/**
	Removes player group the group
	Throws error if such player is not in the group
*/
function GROUP:RemovePlayer( ply )

	for k, gply in ipairs( self.Players ) do // Need to find out how to get one player
		
		if ply == gply then
		
			umsg.Start("Group", ply )
				umsg.Char( 1 )
			umsg.End()
			
			table.remove( self.Players, k )
			ply._Group = nil
			
			if #self.Players == 1 then --Remove the last player and delete this group
				self:Invalidate()
			
			elseif #self.Players > 1 and ply == self:GetOwner() then
				ply:SetOwner( self.Players[1] )
			end
			
			return
			
		end
		
	end
	
	Error("Player not found in the group")
	
end

/**
	Checks if the group is still valid
	-Has valid players in them
	-Has more than 1 player in it
*/ 
function GROUP:IsValid()
	return self.Valid == true and #self.Players > 1
end

/**
	Invalidated the group
	Removes all players
*/
function GROUP:Invalidate()

	self.Valid = false

	for _, ply in pairs(self.Players) do
		self:RemovePlayer( ply )
	end
	
	if DEBUG then
		print("Invalidating group.")
	end
end



function GROUP:CreateInvite( ply )
	
	self.Invites[ ply ] = CurTime()
	
	umsg.Start("Group", ply )
		umsg.Char( 2 )
		umsg.Entity( self:GetOwner() )
	umsg.End()
	
	if DEBUG then
		print("Creating invitation for: ", ply, self:GetOwner() )
	end
	
end


function GROUP:AcceptInvite( ply )

	if not self.Invites[ ply ] or CurTime() - self.Invites[ ply ] > MaxInviteTime then
		clientError("You do not have a valid invite.")
	end
	
	if DEBUG then
		print("Accepting invitation for: ", ply )
	end
	
	self.Invites[ ply ] = nil
	
	self:AddPlayer( ply )

end
