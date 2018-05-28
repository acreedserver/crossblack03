local frame
local ui = upanel.ui

ui.CreateFont("menubtn", 16)
ui.CreateFont("header", 32)

surface.CreateFont("upanel_text", {font = "Roboto", size = 18})
surface.CreateFont("upanel_text_bold", {font = "Roboto Bold", size = 18})

local logo = Material("upanel/logo64px.png", "smooth")
upanel.openMenu = function()
	local w, h = ScrW(), ScrH()

	frame = vgui.Create("DFrame")
	frame:SetSize(w, h)
	frame:SetTitle("")
	frame:MakePopup()
	frame:SetDraggable(false)
	frame:ShowCloseButton(false)

	frame.sw = function(self, fraction, min, max)
		local s = self:GetWide()

		return math.Clamp(s * fraction, min or 0, max or s)
	end 

	frame.sh = function(self, fraction, min, max)
		local h = self:GetTall()

		return math.Clamp(s * fraction, min or 0, max or s)
	end

	frame.getCurrentTab = function(self) return self.currentTab end

	frame.Paint = function(self, w, h)
		ui.DrawRect(0, 0, w, h, 236, 240, 245)
	end

	local spnl = vgui.Create("DPanel", frame)
	spnl:SetPos(0, 0)
	spnl.Paint = function(self, w, h)
		ui.DrawRect(0, 0, w, h, 34, 45, 50)
		ui.DrawRect(w - 1, 0, 1, h, 100, 100, 100)
		--ui.DrawRect(0, 41, w - 1, 1, 190, 190, 190, 150)

		for k, v in pairs(self:GetChildren()) do
			v:SetWide(w)
		end
	end
	spnl.small = cookie.GetString("upanel_leftbar_small") == "1"
	spnl.maxWidth = 40 --225
	spnl:SetSize(spnl.small and 40 or spnl.maxWidth, h)
	spnl.Toggle = function(self, force) if self.small then self:SizeTo(self.maxWidth, h, 0.5) else self:SizeTo(41, h, 0.5) end self.small = !self.small cookie.Set("upanel_leftbar_small", self.small and "1" or "0") end

	local changeSize = vgui.Create("DButton", spnl)
	changeSize:SetPos(0, 0)
	changeSize:SetSize(spnl:GetWide(), 40)
	changeSize:SetText("")
	changeSize.Paint = function(self, w, h)
		if self.Hovered then ui.DrawRect(0, 0, w, h, 0, 0, 0, 15) end

		local fr = (w - 55) / 55 

		ui.DrawText("uP", ui.font.header, 20, 20, Color(255, 255, 255, 255 * (0.8 - fr)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		ui.DrawText("uPanel", ui.font.header, w / 2, h / 2, Color(255, 255, 255, 255 * fr), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	--changeSize.DoClick = function() if frame._customPage then return end spnl:Toggle() end

	local content = vgui.Create("DPanel", frame)
	content:SetTall(frame:GetTall())
	content.Paint = function() end
	content.SizeChanged = function() end
	content.lastsw = spnl:GetWide()
	content:SetWide(w - spnl:GetWide())
	content.x = spnl:GetWide()
	--[[content.Think = function(self)
		local sw = spnl:GetWide()
		self.x = sw

		local wp = w - sw
		self:SetWide(wp)

		if wp != self.lastsw then
			self:SizeChanged(lastsw, wp)
		end

		self.lastsw = wp
	end]]
	content.Clear = function(self)
		for k, v in pairs(self:GetChildren()) do
			v:Remove()
		end
	end

	frame.changeTab = function(self, id)
		local t = upanel._tabs[id]
		self.currentTab = id
		content.SizeChanged = function() end
		content:Clear()
		t.buildMenu(content, frame, spnl)
		self._customPage = false
	end

	frame.newPage = function(self)
		self._customPage = true

		content.SizeChanged = function() end
		content:Clear()

		return content
	end

	local i = 1
	local firstToView = true
	for k, v in SortedPairsByMemberValue(upanel._tabs, "Order") do
		local canView = true
		if v.canView then canView = v.canView(LocalPlayer()) end
		local b = vgui.Create("DButton", spnl)
		b:SetPos(0, 50 + 35 * (i - 1))
		b:SetTall(35)
		b:SetText("")
		b.Paint = function(self, w, h)
			local selected = frame:getCurrentTab() == k
			local hov = self.Hovered or self.Depressed or selected

			if hov then ui.DrawRect(0, 0, w, h, 0, 0, 0, spnl.small and 80 or 60) end
			local fr = w / spnl.maxWidth

			local iconSize = 24
			local iconX, iconY = (40 - iconSize) / 2 - 1, (h - iconSize) / 2
			local clr

			if !canView then clr = Color(221, 75, 57)
			elseif v.getIconColor then clr = v.getIconColor(self, hov, selected)
			else clr = Color(255, 255, 255, hov and 210 or 100) end

			ui.DrawTexturedRect(iconX, iconY, iconSize, iconSize, v.Icon, clr)
			ui.DrawText(v.Name, ui.font.menubtn, 40, h / 2 - 1, Color(255, 255, 255, hov and 210 * fr or 100 * fr), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

			if selected then
				local p = spnl.small and 2 or 3
				ui.DrawRect(w - p, 0, p, h, 60, 141, 188)
			end
		end
		b.DoClick = function()
			frame:changeTab(k)
		end
		b:SetDisabled(!canView)

		if canView then upanel.tooltip.set(b):text(v.Name):position("right"):condition(function() return spnl.small end) end

		if firstToView and canView then b:DoClick(); firstToView = false end

		i = i + 1
	end

	local close = vgui.Create("DButton", spnl)
	close:SetPos(0, 60 + 35 * (i - 1))
	close:SetTall(35)
	close:SetText("")
	close.Paint = function(self, w, h)
		local hov = self.Hovered or self.Depressed

		if hov then ui.DrawRect(0, 0, w, h, 0, 0, 0, spnl.small and 80 or 60) end

		ui.DrawText("Close", ui.font.menubtn, w / 2, h / 2, Color(255, 255, 255, hov and 210 or 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	close.DoClick = function() frame:Remove() end

	frame.OnRemove = function() upanel.net.msg("upanel_menu_state"):bool(false):send() end
	upanel.net.msg("upanel_menu_state"):bool(true):send()

	frame._spnl = spnl
	frame._changeSize = changeSize
end

upanel.getMenu = function() return frame end
upanel.closeMenu = function() if !IsValid(frame) then return end frame:Close() end

concommand.Add("upanel", function() 
	if table.Count(upanel.permissions.get(LocalPlayer())) == 0 then upanel.print("You're not allowed to view this menu.") return end 
	upanel.openMenu() 
end)