

module("Router", package.seeall )

local WelcomeHandler = NewHandler("welcome")

function WelcomeHandler:Receive( data )
	PrintTable( data )
end

