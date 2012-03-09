module("Taskbar", package.seeall )


TASK = TASK or {}
TASKMeta = TASKMeta or {
	__index = TASK
}

if List then
	for _, task in ipairs( List ) do 
		task:Remove()
	end
end
	
List = {}
Size = 42
Padding = 2

/**
	Creates a new taskbar item and automatically adds it to the screen
*/
function New( data )

	setmetatable( data, TASKMeta )
	
	table.insert( List, data )
	
	data.Order = data.Order or 1000
	data.IsOpen = false
	
	if ValidEntity( LocalPlayer() ) then --Can we create panels yet?
		data:CreateVgui()
	end
	
	Reorder()

	return data 

end

function Reorder()
	
	List = table.ClearKeys( List )
	
	table.sort( List, function(a,b) 
		return a.Order < b.Order
	end )
	
	for id, task in pairs( List ) do
		task.Id = id
	end
	
end

hook.Add("Initialize", "CreateTaskbar", function()
	for _, task in pairs( List ) do
		task:CreateVgui()
	end
end )


/**
	Return material to be painted on the task bar item icon
 */
function TASK:GetIcon()
	return self.Icon
end

/**
	When the item has to be closed
 */
function TASK:Close()
	
	if ValidPanel( self.Menu ) then
		self.Menu:SetVisible( false )
	end
	
	self.IsOpen = false
	
end

/**
	When the item has to open the menu
 */
function TASK:Open()

	if self.IsOpen then
		self:Close()
		return
	end
	
	for _, task in pairs( List ) do
		if task != self then
			task:Close()
		end
	end

	local menu = self:GetMenu()
	
	menu:SetVisible( true )
	menu:InvalidateLayout( true )
	
	menu.y = self.Vgui.y - menu:GetTall() - 1
	menu.x = self.Vgui.x + self.Vgui:GetWide() * 0.5 - menu:GetWide() * 0.5
	
	if menu.x + menu:GetWide() > ScrW() then --Do not let it go outside of the screen
		menu.x = ScrW() - menu:GetWide() - 1
	end
	
	self.IsOpen = true

end

/**
	Created menu that is going to be open when the element is open
 */
function TASK:CreateMenu()
	local panel = vgui.Create( self.Panel )
	
	panel:SetVisible( false )
	
	return panel	
end

function TASK:GetMenu()
	if not ValidPanel( self.Menu ) then
		self.Menu = self:CreateMenu()
	end
	
	return self.Menu	
end

/**
	Created the vgui element that is always going to be rendered on the screen
 */
TASK.TaskBarPanel = "TaskBarItem"
function TASK:CreateVgui()
	if ValidPanel( self.Vgui ) then
		return
	end

	self.Vgui = vgui.Create( self.TaskBarPanel )
	self.Vgui:SetTask( self )
end

/**
	Creates the image icon to be displayed.
	Maybe you want to display a TGA?
*/
function TASK:CreateImage()
	local image = vgui.Create("DImage")
	image:SetImage( self:GetIcon() )
	
	return image
end

function TASK:Remove()
	SafeRemove( self.Vgui )
	SafeRemove( self.Menu )
	List[ self.Id ] = nil
	Reorder()
end



TASKPANEL = TASKPANEL or {}

function TASKPANEL:Init()
	DPanel.Init( self )
	
	self:SetSize( Size, Size )
	self:SetMouseInputEnabled( true )
end

function TASKPANEL:SetTask( task )
	self.Task = task
	self.Image = self.Task:CreateImage()
	self.Image:SetParent( self )
	self.Image:SetMouseInputEnabled( false )
end

function TASKPANEL:PerformLayout()
	self:SetPos(
		ScrW() - self.Task.Id * (self:GetWide() + Padding) + Padding,
		ScrH() - self:GetTall()	
	)

	DPanel.PerformLayout( self )
	
	if ValidPanel( self.Image ) then
		self.Image:SizeToContents()
		self.Image:Center()
	end
end

function TASKPANEL:OnMouseReleased()
	self.Task:Open()
end

vgui.Register("TaskBarItem", TASKPANEL, "DPanel" )