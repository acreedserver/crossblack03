local PANEL = {}
local ui = upanel.ui

surface.CreateFont("upanel_content_title", {font = "Roboto Bold", size = 18})

function PANEL:Init()
	self._title = nil
end

function PANEL:SetTitle(str)
	self._title = str
end

function PANEL:Clear()
	for k, v in pairs(self:GetChildren()) do
		v:Remove()
	end
end

function PANEL:Hide(b)
	if !b then
		self._hide = {w = self:GetWide(), h = self:GetWide(), title = self._title}
		self:SetTall(30)
		self._title = (self._title or "") .. " (Hidden)"
	elseif self._hide then
		self:SetSize(self._hide.w, self._hide.h)
		self._title = self._hide.title
		self._hide = nil
	end
end

function PANEL:Paint(w, h)
	ui.DrawRect(0, 0, w, h, 255, 255, 255, 100)
	ui.DrawOutlinedRect(0, 0, w, h, 210, 214, 222)

	if !self._title then return end

	ui.DrawRect(0, 0, w, 30, 0, 0, 0, 15)
	ui.DrawText(self._title, ui.font.content_title, 8, 16, Color(60, 60, 60, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	ui.DrawRect(0, 30, w, 1, 210, 214, 222)

	if self._hide and h != 30 then
		self:SetTall(30)
	end
end

vgui.Register("uPanelContent", PANEL, "DPanel")