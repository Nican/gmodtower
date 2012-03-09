

module("Router", package.seeall )

Handler = Handler or {}
Handler._Meta = Handler._Meta or {
	__index = Handler
}
Handlers = {}
LastId = 0


function NewHandler( name )
	
	local o = {
		name = name,
		callbacks = {},
		hooks = {}
	}
	
	setmetatable( o, Handler._Meta )
	
	Handlers[ name ] = o
	
	return o

end

function Handler:ReceiveRaw( data )

	local id = data._cid
	
	if not id then
		self:Receive( data )
		return
	end
	
	local callback = self.callbacks[ id ]
	
	if not callback then
		PrintTable( data )
		error("Received a message without a valid callback id")
		return
	end
	
	callback( data._error, data )
	
	self.callbacks[ id ] = nil

end


function Handler:Receive( data )
	
	local hook = data._hook
	
	if not hook then
		PrintTable( data )
		error("Could not find hook")
	end
	
	if not self.hooks[ hook ] then
		print("Message does not have the hook ", hook )
		return
	end
	
	SafeCall( self.hooks[ hook ], self, data )
	
end

function Handler:AddHook( name, func )
	
	self.hooks[ name ] = func

end

function Handler:Send( data, callback )
	
	if callback then
		data._id = LastId
		LastId = LastId + 1
		
		self.callbacks[ data._id ] = callback
	end
	
	data._name = self.name
	
	local json = Json.Encode( data )
	
	connection:SendLine( json )
	
end


function Handler:SendHook( hookname, data, callback )

	data._hook = hookname
	
	self:Send( data, callback )

end

