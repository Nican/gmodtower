

module("Group", package.seeall )

TASKBAR = TASKBAR or {}

function TASKBAR:PaintOver()
	
	local Group = Group.Get()
	
	if IsValid( Group ) and #Group.Players > 1 then
		
		surface.SetFont("Default")
		surface.SetTextPos( 0, 0 )
		surface.SetTextColor( 255, 255, 255, 255 )
		surface.DrawText( #Group.Players )
		
	end

end

vgui.Register("GroupTaskBar", TASKBAR, "TaskBarItem" )