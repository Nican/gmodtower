
module("Inventory", package.seeall )
--[[
local Document = Db.NewDocument("inventory")

function Document:NewPlayer( ply )
	ply.Inventory = NewInventory( ply )
	ply.Inventory:LoadNew()
end

function Document:LoadPlayer( ply, data )
	ply.Inventory = NewInventory( ply )
	ply.Inventory:LoadSaveData( data )
end


function Document:GetData( ply )
	if ply.Inventory then
		return ply.Inventory:GetSaveData()
	end
end
]]

hook.Add("PlayerInitialSpawn", "createInventory", function( ply )
	timer.Simple( 5.0, function()
		ply.Inventory = NewInventory( ply )
		ply.Inventory:LoadNew()	
	end )
end)
