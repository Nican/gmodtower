
module("Inventory.Store", package.seeall )

local PANEL = {}

function PANEL:LoadStore( Store )
	
	self:SetSpacing( 2 )
	self:SetPadding( 2 )
	self:Clear( true )
	
	self.Store = Store
	
	for id, StoreItem in ipairs( self.Store:GetItems() ) do
		
		local ItemPanel = vgui.Create("StoreItemPanel")
		ItemPanel:SetStorePanel( self )
		ItemPanel:SetStoreItem( StoreItem )
		ItemPanel:SetId( id )
		self:AddItem( ItemPanel )		
	
	end
	
	self:InvalidateLayout()
	
end

function PANEL:BuyItem( id )	
	RunConsoleCommand("store_buy", self.Store.Name, id )
end

vgui.Register("StorePanel", PANEL, "DPanelList")


local PANEL = {}

AccessorFunc( PANEL, "m_iId", 	"Id" )
AccessorFunc( PANEL, "m_pParentStore", 	"StorePanel" )

function PANEL:Init()
	self:SetHeight( 60 )
end

local function BuyItem( self )

	local PanelItem = self.PanelItem
	local StorePanel = PanelItem:GetStorePanel()
	local Id = PanelItem:GetId() 
	
	StorePanel:BuyItem( Id )
	
end

function PANEL:SetStoreItem( StoreItem )

	self.StoreItem = StoreItem
	self.Item = self.StoreItem:GetItem()
	
	self.ItemPanel = vgui.Create("ItemHolder", self)
	self.NameLabel = vgui.Create("Label", self )
	self.DescriptionLabel = vgui.Create("Label", self )
	self.BuyButton = vgui.Create("DButton", self )
	
	self.NameLabel:SetFont("Trebuchet24")
	self.DescriptionLabel:SetFont("Default")
	self.BuyButton:SetFont("Default")
	
	local Name = self.Item.Name
	local stack = self.Item:GetStack()
	
	if stack > 1 then
		Name = stack .. " " .. Name .. "s"
	end
	
	self.NameLabel:SetText( Name )
	self.DescriptionLabel:SetText( self.Item.Description )
	self.BuyButton:SetText( StoreItem.Price )	
	
	self.NameLabel:SizeToContents()
	self.DescriptionLabel:SizeToContents()
	
	self.ItemPanel:SetItem( self:GetItem() )
	
	local Message = "Are you sure you want to buy " .. stack .. " " .. Name .. "?"
	
	self.BuyButton.DoClick = function( self )
		Derma_Query( Message , "BUY ITEM", 
			"YES", function() BuyItem( self ) end,
			"NO" )
	end
	
	self.BuyButton.DoRightClick = BuyItem
	self.BuyButton.PanelItem = self
	
end

function PANEL:GetItem()
	return self.Item
end

function PANEL:PerformLayout()
	
	self.ItemPanel:SetSize( self:GetTall() - 4, self:GetTall() - 4 )
	self.ItemPanel:AlignLeft( 2 )
	self.ItemPanel:CenterVertical()
		
	self.NameLabel:MoveRightOf( self.ItemPanel, 4 )
	self.NameLabel:AlignTop( 4 )
	
	self.DescriptionLabel:MoveRightOf( self.ItemPanel, 8 ) //Align the X Pos
	self.DescriptionLabel:MoveBelow( self.NameLabel, 4 ) //Move the Y Pos below the name
	
	//Position it in the bottom right corner
	self.BuyButton:AlignBottom( 3 )
	self.BuyButton:AlignRight( 3 )
	self.BuyButton:SetSize( self:GetWide() * 0.15, 20 )
	
end


vgui.Register("StoreItemPanel", PANEL, "DPanel" )