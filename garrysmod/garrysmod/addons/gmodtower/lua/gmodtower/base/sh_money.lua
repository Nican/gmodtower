local Db = Db
local Player = FindMetaTable("Player")
local DTPlayer = DTPlayer
local tonumber = tonumber
local SERVER,CLIENT = SERVER,CLIENT
local _G = _G


module("Money" )


function Player:Afford( price )
	return self:GetMoney() >= price
end


if CLIENT then
function Player:GetMoney()
	return self:GetDTInt( DTPlayer.MONEY )
end
end --CLIENT


if SERVER then

--[[
local Document = Db.NewDocument("money")

function Document:NewPlayer( ply )
	ply:SetMoney( 0 )
end

function Document:LoadPlayer( ply, data )
	ply:SetMoney( tonumber( data ) )
end


function Document:GetData( ply )
	return ply:GetMoney()
end
]]
function Player:GetMoney()
	return self.__Money or 0
end

function Player:SetMoney( val )
	self.__Money = val
	self:SetDTInt( DTPlayer.MONEY, val )
end

function Player:AddMoney( val )
	self:SetMoney( self:GetMoney() + val )
end
	
_G.concommand.ClientAdd("test_money", function( ply, cmd, args )
	
	if _G.DEBUG then
		ply:SetMoney( tonumber(args[1]) or 0 )
	end
	
end )
	
end --SERVER