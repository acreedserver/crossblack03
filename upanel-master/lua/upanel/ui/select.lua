local PANEL = {}
local ui = upanel.ui
local menus = {}

surface.CreateFont("upanel_select_text", {font = "Roboto", size = 16})

function PANEL:Init()
	self:SetText("")
	self.SetInternalText = self.SetText
	self.SetText = function() end

	self._options = {}
	self._selected = {}
	self._defaultText = "Select..."
	self._text = self._defaultText
	self._allowMultiple = false
	self._searchbox = false
	self._height = 230
	self._upanelselect = true
	self._direction = "down"
end

function PANEL:GetValue() local selected = self:GetSelectedOption(); return selected and selected.data or nil end
function PANEL:SetValue(str) self._text = str end
function PANEL:GetSelectedOption() return self._options[self:GetSelected()] end
function PANEL:GetOption(num) return self._options[num] end
function PANEL:Select(num, bool) if !self._allowMultiple and bool then self._selected = {} end self._selected[num] = bool; self:OnSelected(num, bool) end
function PANEL:SelectByID(value, bool) for k, v in pairs(self._options) do if v.id == value then self:Select(k, bool) end end end
function PANEL:AddOption(text, data, id) return table.insert(self._options, {text = text, data = data, id = id}) end
PANEL.AddChoice = PANEL.AddOption
function PANEL:DoClick() if IsValid(self._List) then self._List:Remove() else self:CreateList() end end
function PANEL:SetListHeight(h) self._height = h end
function PANEL:OnRemove() if IsValid(self._List) then self._List:Remove() end end
function PANEL:SetMultiple(b) self._allowMultiple = b end
function PANEL:SetSearch(b) self._searchbox = b end
function PANEL:OnSelected(num) end
function PANEL:GetSelected() 
	local t = {}

	for k, v in pairs(self._selected) do
		if !v then continue end
		table.insert(t, k)
	end

	return self._allowMultiple and t or t[1]
end
function PANEL:RethinkText()
	local selected = self:GetSelected()

	if self._allowMultiple then
		if #selected == 0 then self._text = self._defaultText ; return end
		self._text = "Selected " .. #selected .. " option(s)..."
	else
		if !selected || !self._options[selected] then self._text = self._defaultText; return end
		self._text = self._options[selected].text
	end
end

function PANEL:SetShouldUpdate(b)
	self._shouldUpdate = b
end

function PANEL:CreateList()
	if IsValid(self._List) then return end
	if #self._options == 0 then return end

	local pnt = self:GetParent()
	local px, py = pnt:LocalToScreen(self:GetPos())
	local pw, ph = self:GetSize()
	local sw, sh = pw, self._height
	local starty = 0
	local spnl = self

	local pnl = vgui.Create("DPanel") -- TODO: change to EditablePanel, should fix focus problems with DTextEntry
	pnl:SetPos(px, self._direction == "down" and py + ph or py - sh)
	pnl:SetSize(sw, sh)
	pnl:MakePopup()
	pnl:SetDrawOnTop(true)
	pnl:SetKeyboardInputEnabled(true)
	pnl.Close = pnl.Remove
	pnl._upanelselect = true
	pnl.Paint = function(self, w, h)
		ui.DrawShadow(0, 0, w, h)
		ui.DrawRect(0, 0, w, h, 255, 255, 255)
		ui.DrawOutlinedRect(0, -1, w, h + 1, 210, 214, 222)

		if spnl._shouldUpdate then
			px, py = pnt:LocalToScreen(spnl:GetPos())
			self:SetPos(px, spnl._direction == "down" and py + ph or py - sh)
		end
	end

	if self._searchbox then
		local height = ph + 4
		local entry = vgui.Create("DTextEntry", pnl)
		entry:SetPos(4, 4)
		entry:SetSize(sw - 8, height - 8)
		entry.Paint = function(self, w, h)
			ui.DrawOutlinedRect(0, 0, w, h, 60, 141, 188)
			self:DrawTextEntryText(Color(30, 30, 30), Color(180, 180, 180), Color(40, 40, 40))
		end
		entry._upanelselect = true
		starty = height
	end

	local scroll = vgui.Create("uPanelScrollPanel", pnl)
	scroll:SetPos(1, starty)
	scroll:SetSize(sw - 2, sh - starty - 1)
	scroll._upanelselect = true
	scroll.VBar._upanelselect = true
	scroll.VBar:SetShadow(false)

	local ypos = 0

	for k, v in pairs(self._options) do
		local btn = vgui.Create("DButton", scroll)
		btn:SetPos(0, ypos)
		btn:SetSize(sw, ph)
		btn:SetText("")
		btn._upanelselect = true

		local hovered, selected = Color(60, 141, 188), Color(221, 221, 221)
		btn.Paint = function(self, w, h)
			local bselected, clr = spnl._selected[k], nil
			if bselected then clr = selected elseif self:IsHovered() then clr = hovered end
			if clr then ui.DrawRect(0, 0, w, h, clr) end
			ui.DrawText(v.text, ui.font.select_text, 8, h / 2, (self:IsHovered() and !bselected) and color_white or Color(60, 60, 60), _, TEXT_ALIGN_CENTER)
		end
		btn.DoClick = function()
			self:Select(k, !self._selected[k] and true or false)
			self:RethinkText()
			if !self._allowMultiple then pnl:Remove() end
		end

		ypos = ypos + ph
	end

	if ypos < sh then
		pnl:SetTall(ypos + 1)
	end

	self._List = pnl
	table.insert(menus, pnl)
end

function PANEL:Paint(w, h)
	ui.DrawRect(0, 0, w, h, 255, 255, 255)
	ui.DrawOutlinedRect(0, 0, w, h, 210, 214, 222)

	ui.DrawText(self._text, ui.font.select_text, 8, h / 2, Color(33, 33, 33), _, TEXT_ALIGN_CENTER)
	ui.DrawText(IsValid(self._List) and "▴" or "▾", ui.font.select_text, w - 12, h / 2 + 1, Color(150, 150, 150), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
end

vgui.Register("uPanelSelect", PANEL, "DButton")


hook.Add("VGUIMousePressed", "upanel_select", function(panel)
	if IsValid(panel) and !panel._upanelselect then
		local parent = panel:GetParent()
		if parent and parent._upanelselect then return end
		for k, v in ipairs(menus) do
			if IsValid(v) then
				v:Close()
			end
		end
		menus = {}
	end
end)