module("Topbar.Notice", package.seeall )

MESSAGEPANEL = MESSAGEPANEL or {}
MESSAGEPANEL.MaxWidth = 280
MESSAGEPANEL.Padding = 4

function MESSAGEPANEL:Init()

end

function MESSAGEPANEL:SetNotice( notice )
	
	self.Notice = notice
	self.MarkupX, self.MarkupY = 0, 0
	
	if ValidPlayer( self.Notice.Player ) then
		self.Avatar = vgui.Create("AvatarImage", self )
		self.Avatar:SetPos( 0, 0 )
		self.Avatar:SetSize( 32, 32 )
		self.Avatar:SetPlayer( self.Notice.Player, 32 )
		
		self.MarkupX = 32 + self.Padding
	end
	
	local Accept = self.Notice.OnAccept
	
	if type( Accept ) == "function" then
		self.Accept = vgui.Create("DButton", self )
		self.Accept:SetText("ACCEPT")
		self.Accept:SetTall( 18 )
		self.Accept.DoClick = function()
			Accept()
			notice:Remove()
		end
	end	
	
	self.Markup = markup.Parse( self.Notice.Message, self.MaxWidth - self.MarkupX )
	
	local Tall = self.Markup:GetHeight()
	
	if ValidPanel( self.Avatar ) then
		Tall = math.max( Tall, self.Avatar:GetTall() )
	end
	
	if ValidPanel( self.Accept ) then
		Tall = Tall + self.Accept:GetTall() + self.Padding
	end
	
	self:SetTall( Tall )
	self:SetWide( self.MarkupX + self.Markup:GetWidth() )
	
	if ValidPanel( self.Accept ) then
		self.Accept:SetPos( 0, self:GetTall() - self.Accept:GetTall() )
		self.Accept:SetWide( self:GetWide() )
	end
	
end

function MESSAGEPANEL:Paint()
	self.Markup:Draw( self.MarkupX, self.MarkupY )
end

vgui.Register("NoticeMessage", MESSAGEPANEL )