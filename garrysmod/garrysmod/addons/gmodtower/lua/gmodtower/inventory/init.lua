AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_bagpanel.lua")
AddCSLuaFile("cl_slotpanel.lua")
AddCSLuaFile("cl_itempanel.lua")
AddCSLuaFile("cl_grabpanel.lua")

include("shared.lua")
include("network.lua")
include("command.lua")
include("db.lua")
include("store/init.lua")

module("Inventory", package.seeall )