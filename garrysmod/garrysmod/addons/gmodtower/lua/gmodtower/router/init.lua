require("oosocks")

include("router.lua")
include("handler.lua")
include("basic.lua")

local CallbackTypes = {
	[SCKCALL_CONNECT] = "SCKCALL_CONNECT",
	[SCKCALL_LISTEN] = "SCKCALL_LISTEN",
	[SCKCALL_BIND] = "SCKCALL_BIND",
	[SCKCALL_ACCEPT] = "SCKCALL_ACCEPT",
	[SCKCALL_REC_LINE] = "SCKCALL_REC_LINE",
	[SCKCALL_REC_SIZE] = "SCKCALL_REC_SIZE",
	[SCKCALL_REC_DATAGRAM] = "SCKCALL_REC_DATAGRAM",
	[SCKCALL_SEND] = "SCKCALL_SEND",
}

module("Router", package.seeall )


if connection then
	Msg("Closing old connection.\n")
	connection:Close()
end

local function connectionCallback(socket, callType, callId, err, data, peer, peerPort)
	--[[
	print("\nReceive: ", CallbackTypes[callType] )
	print("Callid: ", callId )
	print("err: ", err )
	print("data: ", data )
	print("\n")
	]]
	
	if err != SCKERR_OK or (callType == SCKCALL_REC_LINE and data == "") then
		print("Got a non-ok calback: ", err, data )
		RetryConnect()
		return		
	end
	
	if callType == SCKCALL_CONNECT then
        print("Connected to router, YAY!");
		hook.Call("RouterConnect", _G.GAMEMODE )
		Connected = true
		socket:ReceiveLine();
    end
 
    if callType == SCKCALL_REC_LINE and data != "" then
       
		local b, Message = SafeCall( Json.Decode, data )
		
		if not b then
			timer.Simple( 0, Connect )
			return
		end
		
		SafeCall( Receive, Message )
	
		socket:ReceiveLine();

    end
 
end

function Connect()
	Connected = false
	if connection then
		connection:Close()
	end
	
	connection = OOSock(IPPROTO_TCP);
	connection:Connect("192.168.0.1", 8124);
	connection:SetCallback( connectionCallback )
	
end

function RetryConnect()
	local time = 5.0
	if DEBUG then
		time = 120
	end 
	timer.Create( "RouterConnect", time, 1, Connect )
end
 
timer.Simple( 0.1, Connect )