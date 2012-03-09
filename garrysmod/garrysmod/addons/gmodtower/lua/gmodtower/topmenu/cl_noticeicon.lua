module("Topbar.Notice", package.seeall )

NOTICEPANEL = NOTICEPANEL or {}

function NOTICEPANEL:Init()
	self.Image = vgui.Create("DImage", self )
	self.Image:SetMouseInputEnabled( false )
	
	self:SetSize( Topbar.Size, Topbar.Size )
	
	self:Ping()
end

function NOTICEPANEL:SetNotice( notice )
	
	self.Notice = notice
	self.Image:SetImage( notice.Icon )
	
	self.Scale = 1.0
	
end

function NOTICEPANEL:Think()
	
	if not self.Notice.DieTime then
		return
	end
	
	local TimeLeft = math.max( self.Notice.DieTime - CurTime(), 0 )
	
	if TimeLeft <= 0.01 then
		self.Notice:Remove()
	elseif TimeLeft < 1 then
		self.Scale = TimeLeft
		self:SetAlpha( TimeLeft * 255 )
		self:GetParent():InvalidateLayout()
	end
	
end

function NOTICEPANEL:OnCursorEntered()
	self:GetParent():SetMessageOn( self.Notice )
end

function NOTICEPANEL:Paint()
	local w, h = self:GetSize()
	
	draw.RoundedBox( 6, 0, 0, w, h, Topbar.BackgroundColor )
end

function NOTICEPANEL:PerformLayout()
	
	local size = Topbar.Size
	
	self:SetSize( size * self.Scale, size * self.Scale )
	self.Image:SetSize( self.Image.ActualWidth * self.Scale, self.Image.ActualHeight * self.Scale ) 
	self.Image:Center()
	
end

function NOTICEPANEL:Ping()
	local ping = vgui.Create("NoticePing")
	ping:SetTarget( self )
	
	return ping
end

vgui.Register("NoticeIcon", NOTICEPANEL )




NOTICEPING = NOTICEPING or {}
NOTICEPING.LifeSize = 1.0

function NOTICEPING:Init()
	
	self.EndLife = CurTime() + self.LifeSize
	
	self:SetMouseInputEnabled( false )
	
end

function NOTICEPING:SetTarget( target )
	self.Target = target
end

function NOTICEPING:LifeLeft()
	return math.max( self.EndLife - CurTime(), 0 ) / self.LifeSize
end

function NOTICEPING:Think()
	
	local Life = self:LifeLeft()

	if Life <= 0 or not ValidPanel( self.Target ) then
		self:Remove()
		return
	end
	
	Life = 1 - Life
	
	local x, y = self.Target:LocalToScreen( 0, 0 )
	local w,h = self.Target:GetSize()
	
	self:SetPos( x - Life * 100, y - Life * 100 )
	self:SetSize( Life * 200 + w, Life * 200 + h )	
	
end

function NOTICEPING:Paint()
	
	local w,h = self:GetSize()
	draw.RoundedBox( 16, 0, 0, w, h, Color(255, 255, 255, self:LifeLeft() * 255) )
	
end

vgui.Register("NoticePing", NOTICEPING )