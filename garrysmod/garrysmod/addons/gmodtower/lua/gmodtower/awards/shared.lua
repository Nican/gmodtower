local PlayerMeta = FindMetaTable("Player")
local Error = Error
local _G = _G

module("Award")

/**
	String table containign all the ids of all achivements
*/
IdList = {
	

}

/**
	List of registered award items
*/
AwardList = {}


function PlayerMeta:GetAwards()
	return self._Award
end

function Register( data )

	if !data.id or !self.name or !self.description or !self.type then
		Error("Loading achivement without an id/name/description/type!")
	end
	
	local o = {
		Id = data.id,
		Name = data.name,
		Description = data.description,
		MaxValue = data.max 
	}
	
	setmetatable( o, data.type )
	
	o._Meta = {
		__index = o
	}
	
	AwardList[ o.Id ] = o
	
	return o

end


hook.Add("Initialize", "LoadAwards", function()
	hook.Call("RegisterAwards", _G.GAMEMODE )
end )