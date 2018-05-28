local PANEL = {}
local ui = upanel.ui

surface.CreateFont("upanel_btn", {font = "Roboto", size = 16})
surface.CreateFont("upanel_btn_bold", {font = "Roboto Bold", size = 16})

upanel.client.themes = {
	default = {Color(68, 68, 68), Color(250, 250, 250), Color(221, 221, 221)},
	primary = {Color(255, 255, 255), Color(60, 141, 188), Color(54, 127, 169)},
	success = {Color(255, 255, 255), Color(0, 166, 90), Color(0, 141, 76)},
	info = {Color(255, 255, 255), Color(0, 192, 239), Color(0, 172, 214)},
	danger = {Color(255, 255, 255), Color(221, 75, 57), Color(215, 57, 37)},
	warning = {Color(255, 255, 255), Color(243, 156, 18), Color(224, 142, 11)}
}

local themes = upanel.client.themes

function PANEL:Init()
	self._type = "default"
	self._shadow = true
	self:SetFont(ui.font.btn)
	self:themeChanged(t)

	self.SetDisabledInternal = self.SetDisabled

	self.SetDisabled = function(self, b)
		self:SetCursor(b and "no" or "hand")
		return self:SetDisabledInternal(b)
	end
end

function PANEL:themeChanged(t)
	local theme = themes[t] or themes.default
	self:SetTextColor(theme[1])
end

function PANEL:SetType(t)
	self._type = t
	self:themeChanged(t)
end

function PANEL:Paint(w, h)
	local theme = themes[self._type] or themes.default

	if self._shadow then ui.DrawShadow(1, 1, w - 2, h - 2) end

	ui.DrawRect(0, 0, w, h, theme[2])
	ui.DrawOutlinedRect(0, 0, w, h, theme[3])

	if self:GetDisabled() then
		if self._type == "default" then
			ui.DrawRect(0, 0, w, h, 0, 0, 0, 60)
		else
			ui.DrawRect(0, 0, w, h, 255, 255, 255, 25)
		end

		return
	end

	if self.Depressed then
		ui.DrawRect(0, 0, w, h, 0, 0, 0, 55)
	elseif self:IsHovered() then 
		ui.DrawRect(0, 0, w, h, 0, 0, 0, 25)
	end
end

vgui.Register("uPanelButton", PANEL, "DButton")