include("sh_store.lua")
include("cl_panel.lua")
include("sh_list.lua")
include("sh_npc_store.lua")

module("Inventory.Store", package.seeall )

function Open( Store )

	if not Store then
		clientError("Trying to load a nil store.")
	end
	
	local frame = vgui.Create("DFrame")
	frame:SetSize( 640, 480 )
	
	local storePanel = vgui.Create("StorePanel", frame )
	storePanel:StretchToParent( 4, 27, 4, 4 )
	storePanel:LoadStore( Store )

	frame:Center()
	
end

usermessage.Hook("store", function( um )
	
	local id = um:ReadChar()
	
	if id == 1 then
		
		local StoreName = um:ReadString()
		local Store = Get( StoreName )
		
		if Store then
			Open( Store )
		else
			error("Can not find store of name: " .. StoreName )
		end
	
	end

end )

concommand.Add("store_test", function( ply, cmd, args )
	
	if _G.DEBUG then
		Open( Get( args[1] or "First" ) )
	end
	
end )