if SERVER then return nil end

local ui = {}

ui.font = {}
setmetatable(ui.font, {__index = function(self, key) return "upanel_" .. key end})

ui.CreateFont = function(name, size, t)
	t = t or {}

	t.font = "Roboto Slab"
	t.size = size

	local fontName = "upanel_" .. name

	surface.CreateFont(fontName, t)

	return fontName
end

local toReplace = {
    ["<"] = "&lt;",
    [">"] = "&gt;",
    ["&"] = "&amp;"
}

ui.SafeString = function(str)
    local newStr, _ = str:gsub("[<>&%c]", function(m)
        return toReplace[m] or ""
    end)
    
    return newStr 
end

ui.DrawText = draw.SimpleText
ui.SetDrawColor = surface.SetDrawColor

ui.DrawRect = function(x, y, w, h, ...)
	if (...) then
		surface.SetDrawColor(...)
	end
	surface.DrawRect(x, y, w, h)
end

ui.DrawTexturedRect = function(x, y, w, h, mat, ...)
   	if (...) then
        surface.SetDrawColor(...)
    else
        surface.SetDrawColor(255, 255, 255, 255)
    end
	surface.SetMaterial(mat)
	surface.DrawTexturedRect(x, y, w, h)
end

ui.DrawLine = function(startx, starty, endx, endy, ...)
    if (...) then
        surface.SetDrawColor(...)
    end
    surface.DrawLine(startx, starty, endx, endy)
end

ui.DrawOutlinedRect = function(x, y, w, h, ...)
    if (...) then
        surface.SetDrawColor(...)
    end
    surface.DrawOutlinedRect(x, y, w, h)
end

ui.GetTextSize = function(font, text)
	surface.SetFont(font)
	return surface.GetTextSize(text)
end

ui.CreateCirclePoly = function(x, y, radius, seg)
	local tbl = {}

	for i = 0, seg do
		local a = math.rad((i / seg) * -360)
		local aSin, aCos = math.sin(a), math.cos(a)

		tbl[i + 1] = {x = x + aSin * radius, y = y + aCos * radius, u = aSin / 2 + 0.5, v = aCos / 2 + 0.5}
	end

	return tbl
end

ui.DrawPreMadeCircle = surface.DrawPoly

ui.DrawCircle = function(x, y, radius, seg)
	surface.DrawPoly(mgui.CreateCirclePoly(x, y, radius, seg))
end

ui.LerpColor = function(fr, from, to)
    from.a = from.a or 255
    to.a = to.a or 255

    return Color(
        Lerp(fr, from.r, to.r),
        Lerp(fr, from.g, to.g),
        Lerp(fr, from.b, to.b),
        Lerp(fr, from.a, to.a))
end

ui.DrawTexturedRectRotated = function(x, y, w, h, material, rotation, ...)
    if (...) then
        surface.SetDrawColor(...)
    else
        surface.SetDrawColor(255, 255, 255, 255)
    end

    surface.SetMaterial(material)
    surface.DrawTexturedRectRotated(x, y, w, h, rotation)
end

local mError = Material("something.vtf")
ui.NullMaterial = mError
ui.DownloadMaterial = function(url, params, callback)
    local crc = util.CRC(url)
    if file.Exists("ugc/saved/" .. crc .. ".png", "DATA") then
        callback(Material("../data/ugc/saved/" .. crc .. ".png", params))
        return
    end
    http.Fetch(url, function(body)
        file.Write("ugc/saved/" .. crc .. ".png", body)
        callback(Material("../data/ugc/saved/" .. crc .. ".png", params))
    end,
    function(err)
        ugc.error("error downloading material (" .. url .. "): " .. (err or "unknown error"))
        callback(mError)
    end)
end

ui.CreateFont("upanel_frame", 16, {weight = 1000})

local PANEL = {}

function PANEL:Init()
    self.backgroundColor = Color(226, 231, 235)
    self.lblTitle:SetFont(ui.font.upanel_frame)
    self.lblTitle:SetColor(Color(220, 220, 220))
end

function PANEL:Paint(w, h)
    if self.m_bBackgroundBlur then
        Derma_DrawBackgroundBlur(self, self.m_fCreateTime)
    end

    upanel.ui.DrawShadow(0, 0, w, h)

    ui.DrawRect(0, 0, w, h, self.backgroundColor)
    ui.DrawRect(0, 0, w, 25, 28, 41, 46)
end

derma.DefineControl("uPanelFrame", "", PANEL, "DFrame")

local PANEL = {}

AccessorFunc( PANEL, "Padding",     "Padding" )
AccessorFunc( PANEL, "pnlCanvas",   "Canvas" )

--[[---------------------------------------------------------
   Name: Init
-----------------------------------------------------------]]
function PANEL:Init()

    self.pnlCanvas  = vgui.Create( "Panel", self )
    self.pnlCanvas.OnMousePressed = function( self, code ) self:GetParent():OnMousePressed( code ) end
    self.pnlCanvas:SetMouseInputEnabled( true )
    self.pnlCanvas.PerformLayout = function( pnl )
    
        self:PerformLayout()
        self:InvalidateParent()
    
    end
    
    -- Create the scroll bar
    self.VBar = vgui.Create( "uPanelVScrollBar", self )
    self.VBar:Dock( RIGHT )

    self:SetPadding( 0 )
    self:SetMouseInputEnabled( true )
    
    -- This turns off the engine drawing
    self:SetPaintBackgroundEnabled( false )
    self:SetPaintBorderEnabled( false )
    self:SetPaintBackground( false )

end

--[[---------------------------------------------------------
   Name: AddItem
-----------------------------------------------------------]]
function PANEL:AddItem( pnl )

    pnl:SetParent( self:GetCanvas() )
    
end

function PANEL:OnChildAdded( child )

    self:AddItem( child )

end

--[[---------------------------------------------------------
   Name: SizeToContents
-----------------------------------------------------------]]
function PANEL:SizeToContents()

    self:SetSize( self.pnlCanvas:GetSize() )
    
end

--[[---------------------------------------------------------
   Name: GetVBar
-----------------------------------------------------------]]
function PANEL:GetVBar()

    return self.VBar
    
end

--[[---------------------------------------------------------
   Name: GetCanvas
-----------------------------------------------------------]]
function PANEL:GetCanvas()

    return self.pnlCanvas

end

function PANEL:InnerWidth()

    return self:GetCanvas():GetWide()

end

--[[---------------------------------------------------------
   Name: Rebuild
-----------------------------------------------------------]]
function PANEL:Rebuild()

    self:GetCanvas():SizeToChildren( false, true )
        
    -- Although this behaviour isn't exactly implied, center vertically too
    if ( self.m_bNoSizing && self:GetCanvas():GetTall() < self:GetTall() ) then

        self:GetCanvas():SetPos( 0, (self:GetTall()-self:GetCanvas():GetTall()) * 0.5 )
    
    end
    
end

--[[---------------------------------------------------------
   Name: OnMouseWheeled
-----------------------------------------------------------]]
function PANEL:OnMouseWheeled( dlta )

    return self.VBar:OnMouseWheeled( dlta )
    
end

--[[---------------------------------------------------------
   Name: OnVScroll
-----------------------------------------------------------]]
function PANEL:OnVScroll( iOffset )

    self.pnlCanvas:SetPos( 0, iOffset )
    
end

--[[---------------------------------------------------------
   Name: ScrollToChild
-----------------------------------------------------------]]
function PANEL:ScrollToChild( panel )

    self:PerformLayout()
    
    local x, y = self.pnlCanvas:GetChildPosition( panel )
    local w, h = panel:GetSize()
    
    y = y + h * 0.5;
    y = y - self:GetTall() * 0.5;

    self.VBar:AnimateTo( y, 0.5, 0, 0.5 );
    
end


--[[---------------------------------------------------------
   Name: PerformLayout
-----------------------------------------------------------]]
function PANEL:PerformLayout()

    local Wide = self:GetWide()
    local YPos = 0
    
    self:Rebuild()
    
    self.VBar:SetUp( self:GetTall(), self.pnlCanvas:GetTall() )
    YPos = self.VBar:GetOffset()
        
    if ( self.VBar.Enabled ) then Wide = Wide - self.VBar:GetWide() end

    self.pnlCanvas:SetPos( 0, YPos )
    self.pnlCanvas:SetWide( Wide )
    
    self:Rebuild()


end

function PANEL:Clear()

    return self.pnlCanvas:Clear()

end

derma.DefineControl( "uPanelScrollPanel", "", PANEL, "DPanel" )

local PANEL = {}
--local mGrip = ui.NullMaterial
 
--ui.DownloadMaterial("http://i.imgur.com/06tvlxM.png", "vertexlitgeneric", function(m) mGrip = m end)
function PANEL:Init()
    local normal, hovered = Color(205, 205, 205), Color(166, 166, 166)
    self.btnGrip.Paint = function(self, w, h)
        ui.DrawRect(0, 0, w, h, self:IsHovered() and hovered or normal)
        --[[
        local center = h / 2
        for i = 1, 3 do
            ui.DrawRect(3, center + ((i == 2 and 2) or (i == 3 and - 2) or 0), w - 6, 1, 33, 33, 33, 150)
        end]]
    end

    self.btnUp:Remove()
    self.btnDown:Remove()
    self:SetShadow(true) 
end

function PANEL:Paint(w, h)
    if self.b_Shadow then ui.DrawShadow(0, 0, w, h) end
    ui.DrawRect(0, 0, w, h, 240, 240, 240)
end

function PANEL:SetShadow(b)
    self.b_Shadow = b
end

function PANEL:OnCursorMoved( x, y )

    if ( !self.Enabled ) then return end
    if ( !self.Dragging ) then return end

    local x = 0
    local y = gui.MouseY()
    local x, y = self:ScreenToLocal( x, y )
    
    -- Uck. 
    y = y - self.HoldPos
    
    local TrackSize = self:GetTall() - self.btnGrip:GetTall()
    
    y = y / TrackSize
    
    self:SetScroll( y * self.CanvasSize )   
    
end

function PANEL:PerformLayout()
    local Wide = self:GetWide()
    local Scroll = self:GetScroll() / self.CanvasSize
    local BarSize = math.max(self:BarScale() * self:GetTall(), 10)
    local Track = self:GetTall() - BarSize
    Track = Track + 1
    
    Scroll = Scroll * Track
    
    self.btnGrip:SetPos(0, Scroll)
    self.btnGrip:SetSize(Wide, BarSize)
end

vgui.Register("uPanelVScrollBar", PANEL, "DVScrollBar")

if upanel and upanel.ui then
    ui.DrawShadow = upanel.ui.DrawShadow
end

return ui 