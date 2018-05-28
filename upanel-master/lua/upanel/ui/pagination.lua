local ui = upanel.ui
upanel.createPagination = function(numPages)
	local pnl = vgui.Create("DPanel")
	local fits = numPages <= 6
	local xpos = 47

	pnl.SetPage = function(self, page)
		self.page = page 
		self:pageChanged(page)
		if IsValid(self.entry) then self.entry:SetText(page) end
	end
	pnl.pageChanged = function() end

	local prevbtn = vgui.Create("DButton", pnl)
	prevbtn:SetPos(1, 1)
	prevbtn:SetSize(45, 33)
	prevbtn:SetText("«")
	prevbtn.DoClick = function() pnl:SetPage(pnl.page - 1) end
	prevbtn.Paint = function(self, w, h)
		local clr = Color(230, 230, 230)
		if self:GetDisabled() then
			clr = Color(200, 200, 200)
		elseif self:IsHovered() then
			clr = Color(210, 210, 210)
		end
		self:SetCursor(self:GetDisabled() and "no" or "hand")

		draw.RoundedBoxEx(4, 0, 0, w, h, clr, true, false, true, false)
	end

	for i = 1, numPages do
		if i > 4 and i <= numPages - 3 then continue end

		if i == 4 and numPages > 6 then
			local pbtn = vgui.Create("DTextEntry", pnl)
			pbtn:SetSize(35, 33)
			pbtn:SetValue(i)
			pbtn:SetPos(xpos, 1)
			pbtn:SetNumeric(true)
			pbtn:SetEnterAllowed(true)
			pbtn.OnValueChange = function(self, v) pnl:SetPage(math.Clamp(tonumber(v), 1, numPages)) end
			pbtn.Paint = function(self, w, h)
				ui.DrawRect(0, 0, w, h, 255, 255, 220)
				self:DrawTextEntryText(Color(25, 25, 25), Color(150, 150, 150), Color(25, 25, 25))
			end
			pnl.entry = pbtn
			xpos = xpos + pbtn:GetWide() + 1
		else
			local pbtn = vgui.Create("DButton", pnl)
			pbtn:SetSize(35, 33)
			pbtn:SetText("")
			pbtn:SetPos(xpos, 1)
			pbtn.DoClick = function() pnl:SetPage(i) end
			pbtn.pageNum = i
			pbtn.Paint = function(self, w, h) 
				local clr = Color(240, 240, 240)
				if self.pageNum == pnl.page then clr = Color(51, 122, 183) elseif self:IsHovered() then clr = Color(220, 220, 220) end
				ui.DrawRect(0, 0, w, h, clr)
				ui.DrawText(self.pageNum, "DermaDefaultBold", w / 2, h / 2, self.pageNum == pnl.page and Color(220, 220, 220) or Color(90, 90, 90), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

			xpos = xpos + pbtn:GetWide() + 1
		end
	end

	local nextbtn = vgui.Create("DButton", pnl)
	nextbtn:SetPos(xpos, 1)
	nextbtn:SetSize(45, 33)
	nextbtn:SetText("»")
	nextbtn.DoClick = function() pnl:SetPage(pnl.page + 1) end
	nextbtn.Paint = function(self, w, h)
		local clr = Color(230, 230, 230)
		if self:GetDisabled() then
			clr = Color(200, 200, 200)
		elseif self:IsHovered() then
			clr = Color(210, 210, 210)
		end
		self:SetCursor(self:GetDisabled() and "no" or "hand")

		draw.RoundedBoxEx(4, 0, 0, w, h, clr, false, true, false, true)
	end

	pnl.Think = function(self)
		nextbtn:SetDisabled(self.page >= numPages)
		prevbtn:SetDisabled(self.page <= 1)
	end

	xpos = xpos + nextbtn:GetWide() + 1

	pnl.Paint = function(self, w, h)
		draw.RoundedBox(4, 0, 0, w, h, Color(180, 180, 180))
	end

	pnl:SetWide(xpos)
	pnl:SetPage(1)

	return pnl
end