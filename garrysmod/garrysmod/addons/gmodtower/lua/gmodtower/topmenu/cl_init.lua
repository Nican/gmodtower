include("cl_notice.lua")
include("cl_noticeicon.lua")
include("cl_message.lua")

module("Topbar", package.seeall )

BackgroundColor = Color(0,0,0,50)
Panel = Panel or nil
Size = 25

function Create()
	if ValidPanel( Panel ) then
		Panel:Remove()
		Panel = nil
	end
	Panel = vgui.Create("TopPanel")
end


TOPPANEL = TOPPANEL or {}

function TOPPANEL:Init()
	
	self.MoneyLabel = vgui.Create("Label", self )
	self.MessageHolder = vgui.Create("NoticeMessageHolder")
	self.Notices = {}
	
end

function TOPPANEL:Think()
	
	local ply = LocalPlayer()
	
	if ply.GetMoney then
		--TODO: Detect changes when the money changes
		self.MoneyLabel:SetText( ply:GetMoney() )
	end
	
end

function TOPPANEL:Paint()
	
	surface.SetDrawColor( 0, 0, 0, 40 )
	surface.DrawRect( 0,0, self:GetSize() )
	
end

function TOPPANEL:PerformLayout()
	
	self:SetPos( 0, 0 )
	self:SetSize( ScrW(), Size )
	
	self.MoneyLabel:SizeToContents()
	self.MoneyLabel:CenterVertical()
	self.MoneyLabel:AlignLeft( 5 )
	
	local XPos = self:GetWide()
	local Tall = self:GetTall()
	
	for _, notice in ipairs( self.Notices ) do
		
		local icon =  notice:GetIcon()
		
		XPos = XPos - icon:GetWide() - 2
		
		icon:CenterVertical()
		icon.x = XPos

	end
	
end

function TOPPANEL:AddNotice( notice )
	
	table.insert( self.Notices, notice )
	notice:GetIcon():SetParent( self )
	
	self:SetMessageOn( notice )
	
	self:InvalidateLayout()
	
end

function TOPPANEL:SetMessageOn( notice )
	self.MessageHolder:SetNotice( notice )
end


function TOPPANEL:RemoveNotice( notice )

	if self.MessageHolder.Notice == notice then
		self.MessageHolder:Hide()
	end
	
	table.RemoveValue( self.Notices, notice )
	self:InvalidateLayout()
	
	notice:Delete()

	table.sort( self.Notices, Topbar.Notice.Compare )
end

function TOPPANEL:Remove()
	self.MessageHolder:Remove()
	
	for _, v in pairs( self.Notices ) do
		v:Remove()
	end
	
	_R.Panel.Remove( self )
end

vgui.Register("TopPanel", TOPPANEL )








MESSAGEPANEL = MESSAGEPANEL or {}
MESSAGEPANEL.Border = 4
MESSAGEPANEL.ArrowSpace = 10

function MESSAGEPANEL:Init()
	self:SetVisible( false )
	
	self.ArrowX, self.ArrowY = 0, 0
	self.CurrentAlpha = 0
end

function MESSAGEPANEL:SetNotice( notice )

	if ValidPanel( self.NoticePanel ) then
		self.NoticePanel:SetVisible( false )
	end
	
	self:SetVisible( true )
	
	self.Notice = notice
	self.NoticePanel = self.Notice:GetBody()
	self.NoticePanel:SetParent( self )
	self.NoticePanel:SetVisible( true )
	
	self.NoticePanel:SetPos( self.Border, self.ArrowSpace + self.Border )
	
	local w = self.NoticePanel:GetWide() + self.Border * 2
	local h = self.ArrowSpace + self.Border * 2 + self.NoticePanel:GetTall()
	
	self:SetSize( w, h )
	
	self:UpdatePosition()
	self:Show()
	
end

function MESSAGEPANEL:Show()
	
	self:SetVisible( true )
	self.TargetAlpha = 255
	
end

function MESSAGEPANEL:Hide()
	self.TargetAlpha = 0
end

function MESSAGEPANEL:UpdatePosition()
	
	if not IsValid( self.Notice ) then
		self:SetVisible( false )
		return
	end
	
	local IconPanel = self.Notice:GetIcon()
	local posX, posY = IconPanel:LocalToScreen( IconPanel:GetWide() / 2, IconPanel:GetTall() )
	
	self.ArrowX, self.ArrowY = posX, posY
	
	posX = posX - self:GetWide() / 2
	
	if posX + self:GetWide() > ScrW() then
		posX = ScrW() - self:GetWide() - 1
	end
	
	self:SetPos( posX, posY )
	
end

function MESSAGEPANEL:Think()
	
	if not IsValid( self.Notice ) then
		self:SetVisible( false )
		return
	end

	local IconPanel = self.Notice:GetIcon()

	if self:IsMouseInWindow() or IconPanel.Hovered then
		self:Show()
	else
		self:Hide()
	end
	
	if self.TargetAlpha > 0 then
		self.CurrentAlpha = self.CurrentAlpha + FrameTime() * 255.0 * 2
	else
		self.CurrentAlpha = self.CurrentAlpha - FrameTime() * 255.0 * 2
	end
	
	self.CurrentAlpha = math.Clamp( self.CurrentAlpha, 0, 255 )
	
	if self.CurrentAlpha == 0.0 then
		self:SetVisible( false )
	end
	
	self:SetAlpha( self.CurrentAlpha )
	
end

function MESSAGEPANEL:Paint()
	local w, h = self:GetSize()
	local x, y = self:ScreenToLocal( self.ArrowX, self.ArrowY )
	
	draw.RoundedBox( 6, 0, self.ArrowSpace, w, h - self.ArrowSpace, BackgroundColor )

	surface.SetTexture( 0 ) --White blank texture
	surface.SetDrawColor( BackgroundColor.r, BackgroundColor.g, BackgroundColor.b, BackgroundColor.a )
	surface.DrawPoly( {
		{
			x = x - 6,
			y = self.ArrowSpace
		},
		{
			x = x + 6,
			y = self.ArrowSpace
		},
		{
			x = x,
			y = 0
		}
	} )
	
end


vgui.Register("NoticeMessageHolder", MESSAGEPANEL )


if LocalPlayer and IsValid( LocalPlayer() ) then
	Create()
end
hook.Add("Initialize", "CreateTopBar", Create )
