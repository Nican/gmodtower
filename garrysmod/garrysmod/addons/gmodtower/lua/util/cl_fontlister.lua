-- By Python1320 | Do whatever you want..
-- Goes to garrysmod/lua/includes/extensions/CreateFont.lua
-- http://www.facepunch.com/threads/1089200-What-are-you-working-on-V5-Nothing-to-see-here-folks?p=30661801&viewfull=1#post30661801

local temp=string.Explode("\n",
[[DebugFixed
DebugFixedSmall
DefaultFixedOutline
MenuItem
Default
TabLarge
DefaultBold
DefaultUnderline
DefaultSmall
DefaultSmallDropShadow
DefaultVerySmall
DefaultLarge
UiBold
MenuLarge
ConsoleText
Marlett
Trebuchet18
Trebuchet19
Trebuchet20
Trebuchet22
Trebuchet24
HUDNumber
HUDNumber1
HUDNumber2
HUDNumber3
HUDNumber4
HUDNumber5
HudHintTextLarge
HudHintTextSmall
CenterPrintText
HudSelectionText
DefaultFixed
DefaultFixedDropShadow
CloseCaption_Normal
CloseCaption_Bold
CloseCaption_BoldItalic
TitleFont
TitleFont2
ChatFont
TargetID
TargetIDSmall
HL2MPTypeDeath
BudgetLabel]])
	
local fontvalues={
	"font_name",
	"size", 
	"weight", 
	"antialiasing", 
	"additive", 
	"new_font_name", 
	"drop_shadow", 
	"outlined", 
	"blur",
	"ext1",
	"ext2",
	"ext3",
	"ext4",
}	
local fontvalues_print={
	"Base",
	"Size", 
	"Boldness", 
	"Aliased", 
	"Additive", 
	"Font name", 
	"Shadow", 
	"Outlined", 
	"Blurred",
	"ext1",
	"ext2",
	"ext3",
	"ext4",
}
local function fontvalues_toprint(name) 
	for k,v in pairs(fontvalues) do
		if v==name then
			return fontvalues_print[k]
		end
	end 
	return name
end

surface.fonts=surface.fonts or {}
function surface.GetFonts()	return surface.fonts end

-- add default fonts
for _,new_font_name in pairs(temp) do
	surface.fonts[new_font_name]=surface.fonts[new_font_name] or {new_font_name=new_font_name}
end

local oldCreateFont=surface.CreateFont
surface.CreateFont=function( ... ) 
	
   local data={}
   
   for id,value in pairs{...} do
      data[ fontvalues[id] ] = value
   end
   
   local name = data.new_font_name
   if name then
      surface.fonts[name]=data
   end
   
   return oldCreateFont( ... )
end



concommand.Add('gm_showfonts',function()

   local fonts={}
   for k,v in pairs( surface.GetFonts() ) do
      table.insert( fonts, {
         name=k,
         values=v
      })
   end
   table.SortByMember(fonts,"name",function(a,b) return a>b end)
    
   local a=vgui.Create'DFrame'
      a:SetSizable(true)
      a:SetSize(ScrW()*0.3,ScrH()*0.6)
      a:DockPadding(3,21+3,3,3)
      a:SetDraggable(true)
      --a:DeleteOnRemove(true)
      a:MakePopup()
      a:SetTitle("Font Lister")

   local b=vgui.Create('DPanelList',a)
      b:EnableVerticalScrollbar(true)
      b:Dock(FILL)
      b:SetAutoSize(false)
      b:SetPadding(0)
      b:SetSpacing(3)
   
   local c=vgui.Create('DTextEntry',a)
      c:Dock(BOTTOM)
      c:SetMultiline(true)
      c:SetTall(a:GetTall()*0.2)
      c:SetText"testing the text\ngo go go"
      c:SetAllowNonAsciiCharacters(true)
         
   for _,v in pairs( fonts ) do

      local font      = v.name
      local values   = v.values
      
      surface.SetFont(font)
      local w,h=surface.GetTextSize"."
      local w2,h2=surface.GetTextSize"W"
      
      local monospace=w==w2
      local tall=h
      local wide=w
   
      local cat = vgui.Create("DCollapsibleCategory",b)
      cat:SetExpanded(tall<40)
      cat:SetPadding(3)
      
      do -- WOHA
         
         txt =    font.. ' | ' ..tall ..' tall'..
               (monospace and ", monospace, "..wide..' wide' or "")
         
         local bad={
            ["size"]=true,
            ["new_font_name"]=true,
         }
         
         for valuename,value in pairs(values) do
            
            if not bad[valuename] then
               txt=txt..' | '
               local printable = tostring( fontvalues_toprint( valuename ) )
               if value==true then
                  txt=txt..printable
               elseif value==false then
               else
                  txt=txt..printable..': '..tostring(value)
               end
            end
            
         end
         
      end
      cat:SetLabel(txt)
   
      --label:SetColor(Color(255,100,100,255))
      b:AddItem(cat)
      local label = vgui.Create("DLabel",cat)
      label:SetFont(font)
      function label:OnMouseReleased(but)
        c:SetFont(font)
      end
      label:SetText(   "Lorem ipsum dolor sit amet, consectetur adipiscing elit.".."\n"..
                  "Unicode: öäåá,®©,«,²³¹,??,¦¦¦¦,????")
      label:SetWrap(true)
      cat:SetContents(label)
      label:SizeToContents()
      --   label:InvalidateLayout()
      --   label:TellParentAboutSizeChanges()
      timer.Simple(0,label.SizeToContents,label)  -- wtf hax
   end
   
end)