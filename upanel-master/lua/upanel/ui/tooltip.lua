local forceHide = false
local ui = upanel.ui

upanel.tooltip = {}
upanel.tooltip.setVisible = function(b) forceHide = b end

local themes = {
	light = {
		background = Color(255, 255, 255),
		outline = Color(185, 185, 185),
		text = Color(65, 65, 65, 100),
		shadow = true
	},
	dark = {
		background = Color(60, 60, 60),
		outline = Color(80, 80, 80),
		text = Color(225, 225, 225),
		shadow = true
	}
}

local function detour(def, new)
	return function(...)
		new(...)

		if def then
			return def(...)
		end
	end
end

upanel.tooltip.set = function(pnl)
	local tip = vgui.Create("DPanel")
	tip:SetAlpha(pnl:IsHovered() and 255 or 0)

	tip._text = "undefined"
	tip._theme = "light"
	tip._time = 0.2
	tip._size = 16
	tip._position = "top"
	tip._offset = 5
	tip._condition = function() return true end
	tip._markup = nil
	tip._delay = 0.5
	tip._holding = 0

	tip:SetDrawOnTop(true)
	tip:SetZPos(-32768)

	tip.onHide = function() end
	tip.onShow = function() end

	pnl.OnCursorEntered = detour(pnl.OnCursorEntered, function()
		if IsValid(tip) then
			if tip._Think then
				tip.Think = tip._Think
				tip._Think = nil
			end
		end
	end)

	pnl.OnRemove = detour(pnl.OnRemove, function()
		if IsValid(tip) then
			tip:Remove()
		end
	end)

	tip.parentMouseEntered = function(tip)
		if !tip:_condition() then return end

		tip:show() --tip:SetAlpha(255)
	end

	tip.parentMouseExited = function(tip)
		tip:hide() --tip:SetAlpha(0)
	end

	tip.show = function(tip)
		tip:AlphaTo(255, tip._time, 0, function() tip:onShow() end)
		tip._shouldhide = false
	end

	tip.hide = function(tip)
		tip:AlphaTo(0, tip._time * 0.75, 0, function() tip:onHide() end)
		tip._shouldhide = true
	end

	tip.die = function(tip, time)
		timer.Simple(time, function()
			if IsValid(tip) then
				tip.onHide = function(self) self:Remove() end
				tip:hide()
			end
		end)

		return tip
	end

	tip.rebuildMarkup = function(tip)
		local theme = themes[tip._theme] or themes.light
		local text = "<font=" .. ui.font["tooltip_" .. tip._size] .. "><color=" .. theme.text.r .. ", " .. theme.text.g .. ", " .. theme.text.b .. ", " .. (theme.text.a or 255) .. ">" .. tip._text .. "</font></color>"
		tip._markup = markup.Parse(text)
	end

	tip.Paint = function(self, w, h)
		local theme = themes[self._theme] or themes.light

		if theme.shadow then
			for i = 1, 2 do upanel.ui.DrawShadow(0, 0, w, h) end
		end

		draw.RoundedBox(4, 0, 0, w, h, theme.outline)
		draw.RoundedBox(4, 1, 1, w - 2, h - 2, theme.background)

		local mup = self._markup
		if !mup then return end

		self:SetSize(mup:GetWidth() + 16, mup:GetHeight() + 10)
		mup:Draw(8, 5, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 255)
	end

	local parentHovered = false
	local shouldHide = 0
	tip._Think = function(self)
		if !IsValid(pnl) then self:Remove(); return end

		if pnl:IsHovered() then
			self._holding = self._holding + FrameTime()
			if !parentHovered and self._holding >= self._delay then
				self:parentMouseEntered()
				parentHovered = true
				self._holding = 0
			end
		elseif parentHovered then
			self:parentMouseExited()
			parentHovered = false
			self._holding = 0
		end

		if self._shouldhide then
			if self:GetAlpha() >= 255 then
				shouldHide = shouldHide + 1
			end

			if shouldHide > 3 then
				self:hide()
			end
		else
			shouldHide = 0
		end

		local px, py = pnl:GetPos()
		local pp = pnl:GetParent()
		local tpos = self._position

		local w, h = self:GetSize()
		local pw, ph = pnl:GetSize()

		if IsValid(pp) then px, py = pp:LocalToScreen(px, py) end

		local tx, ty

		if tpos == "top" then
			tx = px + pw / 2 - w / 2
			ty = py - self._offset - h
		elseif tpos == "bottom" then
			tx = px + pw / 2 - w / 2
			ty = py + self._offset + ph
		elseif tpos == "left" then
			tx = px - w - self._offset
			ty = py + ph / 2 - h / 2
		elseif tpos == "right" then
			tx = px + pw + self._offset
			ty = py + ph / 2 - h / 2
		end

		tx, ty = math.Clamp(tx, 5, ScrW() - w - 5), math.Clamp(ty, 5, ScrH() - h - 5)

		self:SetPos(tx, ty)
	end

	tip.theme = function(self, theme) self._theme = theme; self:rebuildMarkup(); return self end -- dark, light
	tip.position = function(self, pos) self._position = pos; return self end -- left, right, top, bottom
	tip.time = function(self, time) self._time = time; return self end
	tip.text = function(self, text) self._text = text; self:rebuildMarkup(); return self end
	tip.size = function(self, size) surface.CreateFont("upanel_tooltip_" .. size, {size = size, font = "Roboto"}); self._size = size; self:rebuildMarkup(); return self end
	tip.offset = function(self, offset) self._offset = offset; return self end
	tip.condition = function(self, func) self._condition = func; return self end
	tip.delay = function(self, delay) self._delay = delay; return self end

	tip:size(16)
	tip:text("undefined")

	return tip
end