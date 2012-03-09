module("RADIO", package.seeall )

if not bass then
	useBass = useBass or require("bass")
end
	
function RADIO:Init()
	local o = {}
	
	setmetatable(o, self)
	self.__index = self
	
	o.Songs = {}
	o.Owner = nil
	o.Position = Vector(0, 0, 0)
	
	return o
end

function RADIO:AddSong(song)
	if song && type(song) == "string" then
		table.insert(self.Songs, song)
	end
end

function RADIO:GetPlaylist()
	return self.Songs
end

function RADIO:Play()

end

function RADIO:Stop()

end

function RADIO:Next()
	local playlist = self:GetPlaylist()
	local nextSong = playlist[2]
	
	if playlist[1] then
		table.remove(playlist, 1)
	end
	
	if nextSong then
		self:Play()
	end
	
end

function RADIO:fft2048()

end

function RADIO:GetPos()
	return self.Position
end

function RADIO:SetPos(pos)
	if !pos || type(pos) != "Vector" then
		ErrorNoHalt("Setting a radio's position with a non-vector.")
		return
	end
	self.Position = pos
end

function RADIO:GetOwner()
	return self.Owner
end

function RADIO:SetOwner(owner)
	self.Owner = owner
end

function RADIO:Think()
	local owner = self:GetOwner()
	
	if ValidEntity(owner) then
		if owner.GetPos then
			self:SetPos(owner:GetPos())
		end
	else
		
	end
end

function RADIO:InLimit()

end