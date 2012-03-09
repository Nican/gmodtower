
local MetaPanel = FindMetaTable("Panel")


function MetaPanel:IsMouseInWindow()
    local x,y = self:CursorPos()
    return x >= 0 && y >= 0 && x <= self:GetWide() && y <= self:GetTall()
end
