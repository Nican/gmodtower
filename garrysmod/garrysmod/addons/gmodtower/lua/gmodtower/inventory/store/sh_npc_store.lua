module("Inventory.Store", package.seeall )

NPC = NPC or {}

NPC.Type 				= "ai"
NPC.Base 				= "base_anim"
NPC.PrintName		= "Store NPC"
NPC.Author		= "Nican"
NPC.Contact		= ""
NPC.Purpose		= ""
NPC.Instructions	= ""
NPC.Spawnable		= false
NPC.AdminSpawnable	= true

if SERVER then

function NPC:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	
	local ent = ents.Create( "npc_store" )
	ent:SetPos( tr.HitPos + Vector(0,0,1) )	
	ent:KeyValue("Store", "First")
	ent:SetModel(Model( "models/Humans/Group01/Female_01.mdl"))
	ent:DropToFloor()
	ent:Spawn()
	ent:Activate()
	
	return ent
end

function NPC:ErrorRemove()
	print("Store entity ", self, " does not have a valid store.")
	timer.Simple( 1.0, SafeRemoveEntity, self )
end

function NPC:Initialize()
	self:SetHullType( HULL_HUMAN );
	self:SetHullSizeNormal();

	self:SetSolid( SOLID_BBOX )
	self:SetMoveType( MOVETYPE_STEP )
	self:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )

	self:CapabilitiesAdd( CAP_USE | CAP_OPEN_DOORS | CAP_FRIENDLY_DMG_IMMUNE | CAP_SQUAD | CAP_TURN_HEAD )
	
	self:SetHealth( 100 )
	
	if not self.Store then
		self:ErrorRemove()
	end
end

function NPC:KeyValue( key, value )
	if key == "Store" then
		local valid, Store = SafeCall( Get, value )
		
		if not valid then
			self:ErrorRemove()
			return
		end
		
		self.Store = Store		
	end	
end

function NPC:AcceptInput( name, activator, ply )
	if not self.Store then
		ply:ChatPrint("NPC does not have a valid store.")
		return
	end

    if name == "Use" && ply:IsPlayer() && ply:KeyDownLast(IN_USE) == false then
		Open( ply, self.Store )
    end
end
end --SERVER

scripted_ents.Register( NPC , "npc_store", true )