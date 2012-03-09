local hook = hook
local gui = gui
local _G = _G

module("Menu")

local MenuOpen = false
local MouseX, MouseY

function Open()
	
	if IsOpen() then
		return
	end
	
	if not CanOpen() then
		return
	end
	
	gui.EnableScreenClicker( true )
	
	if MouseX and MouseY then
		gui.SetMousePos( MouseX, MouseY )
	end
	
	MenuOpen = true
	hook.Call("OpenMenu", _G.GAMEMODE )
	
end

function Close()
	
	if not IsOpen() then
		return
	end
	
	if not CanClose() then
		return
	end
	
	MenuOpen = false
	hook.Call("CloseMenu", _G.GAMEMODE )
	
	MouseX, MouseY = gui.MousePos( )
	
	gui.EnableScreenClicker( false )
	
end

function CanClose()
	return hook.Call("CanCloseMenu", _G.GAMEMODE ) != false
end

function CanOpen()
	return hook.Call("CanOpenMenu", _G.GAMEMODE ) != false
end

function IsOpen()
	return MenuOpen
end

--[[
_G.concommand.Add("-menu", Close ) 
_G.concommand.Add("+menu", Open )
]]

_G.concommand.Add("-menu_context", Close )
_G.concommand.Add("+menu_context", Open )