

module("Topbar.Notice", package.seeall )


function Compare( self, other )
	
	if not self.DieTime then
		
		if not other.DieTime then
			return self.Created > other.Created
		end
		
		return true --I go first
	end
	
	if not other.DieTime then
		return false
	end
	
	return self.DieTime > other.DieTime

end

Registered = Registered or {}

NOTICE = NOTICE or {}
NOTICEMeta = NOTICEMeta or {
	__index = NOTICE
}

/**
	t = {
		Icon = Target material to use
		Message = Message to show when the player hovers over the object
		Timeout = (optional) Amount of time before the icon disapears
		Player = (optinal) Player avatar to show in the message
		OnAccept = (optional) If set a function, a button "ACCEPT" will be displayed, 
			and this function will be called when clicked
	}
*/
function Register( name, t )
	
	local t = t or {}
	
	setmetatable( t, NOTICEMeta )
	
	Registered[ name ] = t
	
	t.Name = name
	t._meta = {
		__index = t
	}
	
	return t
	
end

function New( t )
	if not ValidPanel( Topbar.Panel ) then
		error("No valid top-panel found.")
	end
	
	local Base = NOTICEMeta
	
	if t.Base then
		if not Registered[ t.Base ] then
			error("No valid top-panel of name " .. name .. " found.")
		end
		Base = Registered[ name ]._meta 
	end
	
	t.Created = CurTime()
	t.Valid = true
	
	setmetatable( t, Base )
	
	if t.Timeout then
		t:SetTimeout( t.Timeout )
	end
	
	Topbar.Panel:AddNotice( t )
	
	return t
end
Topbar.New = New

NOTICE.IconPanel = "NoticeIcon"

function NOTICE:NewIconPanel()
	local panel = vgui.Create(self.IconPanel)
	
	panel:SetNotice( self )
	
	return panel	
end

function NOTICE:GetIcon()
	if not ValidPanel( self.IconVgui ) then
		self.IconVgui = self:NewIconPanel()
	end
	return self.IconVgui
end

function NOTICE:NewBodyPanel()
	local panel = vgui.Create("NoticeMessage")
	
	panel:SetNotice( self )
	panel:SetVisible( false )
	
	return panel	
end

function NOTICE:GetBody()
	if not ValidPanel( self.BodyVgui ) then
		self.BodyVgui = self:NewBodyPanel()
	end
	return self.BodyVgui
end

function NOTICE:SetTimeout( timeout )
	self.DieTime = CurTime() + timeout
end

function NOTICE:Remove()
	
	self.Valid = false
	Topbar.Panel:RemoveNotice( self )
	
end

function NOTICE:Delete()
	SafeRemove( self.BodyVgui )
	SafeRemove( self.IconVgui )
end

function NOTICE:IsValid()
	return self.Valid
end


/**
	DEBUG
 */
 
concommand.Add("test_notice", function()
	
	if not _G.DEBUG then
		return
	end
	
	New( {
		Player = LocalPlayer(),
		Icon = "gui/silkicons/box",
		OnAccept = function() print("Clicked!") end,
		Timeout = 30,
		Message = "<color=red><font=TabLarge>" .. LocalPlayer():GetName() .. "</font></color> has asked to trade with you.",
	} )

end )
