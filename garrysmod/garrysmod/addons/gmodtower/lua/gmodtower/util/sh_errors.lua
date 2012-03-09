
module("Errors", package.seeall )

local errorMeta = {
	__tostring = function( tbl )
		return tbl.message
	end
}

function clientError( message )
	
	local err = {
		_type = "client",
		message = message
	}
	
	setmetatable( err, errorMeta )
	
	error( err )

end
_G.clientError = clientError

function ClientCall( func, ply, ... )
	
	local b, err = pcall( func, ply, ... )
	
	if not b then
		if type( err ) == "table" then
			ply:ChatPrint( err.message ) --TODO: Better handling of the error message
		
		else
			ErrorNoHalt( err )
			
		end
	end	

end

