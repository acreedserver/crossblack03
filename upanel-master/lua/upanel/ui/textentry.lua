local PANEL = {}
local ui = upanel.ui

surface.CreateFont("upanel_textentry", {font = "Roboto", size = 16})

function PANEL:Init()
	self._borderColor = Color(180, 180, 180)
	self._borderColorFocused = Color(140, 140, 140)
	self._backgroundColor = Color(255, 255, 255)
	self._backgroundColorFocused = self._backgroundColor
	self._ghostText = ""
end

function PANEL:SetGhostText(text) self._ghostText = text end

function PANEL:Paint(w, h)
	local focus = self:HasFocus() and !self:GetDisabled()
	local text = self:GetValue()

	ui.DrawRect(0, 0, w, h, focus and self._backgroundColorFocused or self._backgroundColor)
	ui.DrawOutlinedRect(0, 0, w, h, focus and self._borderColorFocused or self._borderColor)

	if !text or text == "" and !focus then
		ui.DrawText(self._ghostText, ui.font.textentry, 5, h / 2, Color(130, 130, 130), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	self:DrawTextEntryText(Color(50, 50, 50), Color(150, 150, 150), Color(50, 50, 50))
end

vgui.Register("uPanelTextEntry", PANEL, "DTextEntry")