local PANEL = {}
local ui = upanel.ui

surface.CreateFont("upanel_toggle_bold", {font = "Roboto Bold", size = 18})
surface.CreateFont("upanel_toggle_bold_small", {font = "Roboto Bold", size = 14})

function PANEL:Init()
	self.btn = vgui.Create("DButton", self)
	self.btn:SetPos(0, 0)
	self.btn:SetText("")
	self.btn.Paint = function(btn, w, h) self:PaintButton(btn, w, h) end
	self.btn.DoClick = function() self:Toggle() end

	self._value = false

	self:SetTall(20)
end

function PANEL:Toggle() self:SetValue(!self._value) end
function PANEL:SetValue(b) self._value = b; self:OnValueChanged(b) end
function PANEL:GetValue(b) return self._value end
function PANEL:GetText() return IsValid(self.lbl) and self.lbl:GetText() or nil end
function PANEL:OnValueChanged(b) end

function PANEL:PerformLayout(w, h)
	self.btn:SetSize(h, h)

	if !IsValid(self.lbl) then 
		if w != h then self:SetWide(h) end 
	else
		self.lbl:SetTall(h)
		self.lbl.x = h + 5
	end
end

function PANEL:PaintButton(btn, w, h)
	ui.DrawRect(0, 0, w, h, 255, 255, 255)
	ui.DrawOutlinedRect(0, 0, w, h, 20, 20, 20, 200)

	if self._value then
		ui.DrawRect(3, 3, h - 6, h - 6, 92, 184, 92, 230)
	else
		ui.DrawRect(3, 3, h - 6, h - 6, 195, 195, 195, 180)
	end
end

function PANEL:Paint() end

function PANEL:SetText(t) 
	if !self.lbl then
		self.lbl = vgui.Create("DLabel", self)
		self.lbl:SetFont(ui.font.btn)
		self.lbl:SetTextColor(Color(30, 30, 30))
	end

	self.lbl:SetText(t)
	self.lbl:SizeToContents()
	self:SetWide(self:GetTall() + 5 + self.lbl:GetWide())
end

vgui.Register("uPanelCheckBox", PANEL, "DPanel")

local PANEL = {}

function PANEL:PaintButton(btn, w, h)
	local clr = upanel.client.themes[self._value and "danger" or "primary"][btn:IsHovered() and 3 or 2]
	local text = self._value and "-" or "+"

	draw.RoundedBox(4, 0, 0, w, h, clr)
	ui.DrawText(text, h >= 20 and ui.font.toggle_bold or ui.font.toggle_bold_small, w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

vgui.Register("uPanelToggle", PANEL, "uPanelCheckBox")