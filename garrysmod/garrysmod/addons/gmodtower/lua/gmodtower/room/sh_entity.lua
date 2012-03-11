module("Room", package.seeall )

ROOMENT = ROOMENT or {}

ROOMENT.Type 				= "anim"
ROOMENT.Base 				= "base_entity"
ROOMENT.PrintName		= "Room Networking"
ROOMENT.Author		= "Nican"
ROOMENT.Contact		= ""
ROOMENT.Purpose		= ""
ROOMENT.Instructions	= ""
ROOMENT.Spawnable		= false
ROOMENT.AdminSpawnable	= false

function ROOMENT:Initialize()
	
end

function ROOMENT:GetId()
	return self:GetDTInt( 0 )
end

function ROOMENT:SetId( id )
	self:SetDTInt( 0, id )
end

function ROOMENT:IsLoaded()
	return self:GetDTBool( 0 )
end

function ROOMENT:SetLoaded( loaded )
	self:SetDTBool( 0, loaded )
end


function ROOMENT:GetBounds()
	return self:GetDTVector( 0 ), self:GetDTVector( 1 )
end

function ROOMENT:SetetBounds( min, max )
	self:SetDTVector( 0, min )
	self:SetDTVector( 1, max )
end

function ROOMENT:Think()

	if SERVER then
		self:ThinkLoadEntities()
	end

end

function ROOMENT:Draw()
end

function ROOMENT:UpdateTransmitState() 
	return TRANSMIT_ALWAYS 
end

scripted_ents.Register( ROOMENT , "gmt_roomloc", true )