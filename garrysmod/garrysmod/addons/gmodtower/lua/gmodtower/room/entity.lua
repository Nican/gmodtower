

module("Room", package.seeall )


function ROOMENT:GetSaveEntities()

	local worldMin, worldMax = self:GetBounds()
	local roomEntities = ents.FindInBox( worldMin, worldMax )
	local returnEntities = {}

	for _, ent in pairs( roomEntities ) do

		if ent == self or ent:IsPlayer() then
			continue
		end

		if ent:GetItem() then
			table.insert( returnEntities, ent )
		end

	end

	return returnEntities

end


function ROOMENT:ClearRoom()

	local worldMin, worldMax = self:GetBounds()
	local roomEntities = ents.FindInBox( worldMin, worldMax )

	for _, ent in pairs( roomEntities ) do

		if ent == self then
			continue
		end

		if ent:IsPlayer() then
			ent:Kill()
			continue
		end

		local Item = ent:GetItem()

		if Item then
			SafeRemoveEntityDelayed( ent, 0.0 )
		end

	end

end


function ROOMENT:GetSaveData()

	if not self:IsLoaded() then
		error("Trying to get room save data while it was not loaded!")
	end

	local json = {}
	local entities = self:GetSaveEntities()

	for _, ent in pairs( entities ) do

		local item = ent:GetItem()
		local pos = self:WorldToLocal( ent:GetPos() )
		local ang = self:WorldToLocalAngles( ent:GetAngles() )

		table.insert( json, {
			px = pos.x,
			py = pos.y,
			pz = pos.z,
			ap = ang.p,
			ay = ang.y,
			ar = ang.r,
			item = item:GetSaveData()
		})

	end

	return json

end

function ROOMENT:LoadData( json )

	if self:IsLoaded() then
		error("Loading room that is already loaded!")
	end

	for _, document in pairs( json ) do

		local item = Inventory.NewItemById( document.item.id )
		item:LoadSaveData( data )

		local ent = item:GetDropEnt()
		ent:SetPos( Vector( document.px, document.py, document.pz ) )
		ent:SetAngle( Angle( document.ap, document.ay, document.ar ) )
		ent:Spawn()

	end

end

function ROOMENT:ThinkLoadEntities()
	--TODO: Slowly load entities
end