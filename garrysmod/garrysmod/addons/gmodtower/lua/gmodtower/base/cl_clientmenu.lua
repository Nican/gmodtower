

module("ClientMenu", package.seeall )


function Open( ply )

	local menu = DermaMenu()
	
	menu.Player = ply
	
	hook.Call("ClientMenu", _G.GAMEMODE, ply, menu )
	
	if table.Count( menu.Items ) == 0 then
		menu:Remove()
		return
	end
	
	menu:Open()
	
end