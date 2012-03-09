local OrderVectors = OrderVectors
local util = util
local ValidEntity = ValidEntity
local Up = Vector(0,0,1)

module("Inventory.Trace")

local OnlyHitWorld = true

local function AngleWithinPrecisionError(ang, target)
	return (ang < target + 0.2 && ang > target - 0.2)
end

local function TraceHull( ent, filter )
	local mins, maxs = ent:WorldSpaceAABB()
	local Pos = ent:GetPos()
	local up = ent:GetUp()

	mins, maxs = (mins - Pos) * 0.95, (maxs - Pos) * 0.95
	OrderVectors(mins, maxs)

	if !filter then filter = ent end

	local trace = util.TraceHull( {
		mins = mins,
		maxs = maxs,
		start = Pos,
		endpos = Pos + up * 2,
		filter = filter
	} )

	return trace
end

local function CheckTraceHull( ent, filter )
	local Trace = TraceHull( ent, filter )
	
	if OnlyHitWorld == false then
		return Trace.Hit == false || Trace.Fraction	> 0.1
	else
		if ValidEntity( Trace.Entity ) && Trace.Entity:IsPlayer() then
			return false
		end
	
		return Trace.HitWorld == false || Trace.Fraction > 0.1
	end
end

function UpdatePosition( ent, Trace, rot, filter )

	local min = ent:OBBMins()
	local Normal = Trace.HitNormal
	
	if not Trace.Hit then
		Normal = Up
	end
	
	local BaseAngle = Normal:Angle()
	
	if AngleWithinPrecisionError(BaseAngle.p, 270) || AngleWithinPrecisionError(BaseAngle.p, 90) then
		BaseAngle.y = 0
	end

	BaseAngle:RotateAroundAxis( BaseAngle:Right(), -90 )
	BaseAngle:RotateAroundAxis( BaseAngle:Up(), rot )
	
	local NewPos = Trace.HitPos - Normal * min.z
	
	ent:SetAngles( BaseAngle )
	ent:SetPos( NewPos )
	
	return Trace.Hit and CheckTraceHull( ent, filter )

end

function AttemptUpdate( ent, ... )
	
	local OldPos = ent:GetPos()
	local OldAng = ent:GetAngles()
	local Success = UpdatePosition( ent, ... )
	
	if not Success then
		ent:SetPos( OldPos )
		ent:SetAngles( OldAng )
	end
	
	return Success

end