
--Uh... Is this the best place for this?
hook.Add( "HUDShouldDraw", "HideBasics", function( name )
	
	if name == "CHudHealth" or name == "CHudBattery" or name == "CHudAmmo" or name == "CHudSecondaryAmmo" then
		return false
	end

end ) 