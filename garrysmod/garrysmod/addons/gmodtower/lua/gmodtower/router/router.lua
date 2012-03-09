
module("Router", package.seeall )

function Receive( data )
	
	local name = data._name
	
	if not name then
		print("Wrong data")
		PrintTable( data )
		return
	end
	
	if not Handlers[ name ] then
		ErrorNoHalt("Router does not have handler: " .. tostring(data._name) .. "\n" )
		return
	end
	
	Handlers[ name ]:ReceiveRaw( data )

end