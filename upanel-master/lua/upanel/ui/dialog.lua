upanel.dialog = {}

local dialogs = {}
local ui = upanel.ui

dialogs.text = function(f, callback, default, size)
	f.entry = vgui.Create("uPanelTextEntry", f)
	f.entry:SetPos(5, 30)
	f.entry:SetSize(f:GetWide() - 10, size or 30)
	f.entry:SetText(default or "")

	f.btn:SetPos(5, f.entry.y + 5 + f.entry:GetTall())
	f.btn.DoClick = function()
		callback(f.entry:GetValue() or "")
		f:Remove()
	end

	f:SetTall(f.btn.y + 5 + f.btn:GetTall())
end

dialogs.color = function(f, callback, default)
	f.mixer = vgui.Create("DColorMixer", f)
	f.mixer:SetPos(5, 30)
	f.mixer:SetColor(default or color_white)
	f.mixer:SetWide(f:GetWide() - 10)

	local show = vgui.Create("DPanel", f)
	show:SetPos(5, f.mixer:GetTall() + 35)
	show:SetSize(f.mixer:GetWide(), 10)
	show.Paint = function(self, w, h) 
		local clr = f.mixer:GetColor()
		local invClr = Color(255 - clr.r, 255 - clr.g, 255 - clr.b)

		ui.DrawRect(0, 0, w, h, clr) 
		ui.DrawOutlinedRect(0, 0, w, h, invClr)
	end

	f:SetTall(f.mixer:GetTall() + 85)

	f.btn:SetPos(5, f:GetTall() - 35)
	f.btn.DoClick = function()
		callback(f.mixer:GetColor() or color_white)
		f:Remove()
	end
end

dialogs.number = function(f, callback, default)
	f:SetTall(100)

	f.entry = vgui.Create("uPanelTextEntry", f)
	f.entry:SetPos(5, 30)
	f.entry:SetSize(f:GetWide() - 10, 30)
	f.entry:SetText(default or "")
	f.entry:SetNumeric(true)

	f.btn:SetPos(5, 65)
	f.btn.DoClick = function()
		local v = tonumber(f.entry:GetValue())
		if !v then return end
		callback(v)
		f:Remove()
	end
end

dialogs.select = function(f, callback, default_text)
	f:SetTall(100)

	f.select = vgui.Create("uPanelSelect", f)
	f.select:SetPos(5, 30)
	f.select:SetSize(f:GetWide() - 10, 30)

	if default_text then
		f.select._defaultText = default_text
		f.select:RethinkText()
	end

	f.btn:SetPos(5, 65)
	f.btn.DoClick = function()
		local v = f.select:GetSelectedOption()
		if !v then return end
		callback(v)
		f:Remove()
	end
end

dialogs.confirm = function(f, callback, continue_text, cancel_text)
	f.btn:SetType("success")
	f.btn:SetWide((f:GetWide() - 15) / 2)
	f.btn:SetText(continue_text or "Continue")
	f.btn.DoClick = function() callback(); f:Remove() end

	f.cancel = vgui.Create("uPanelButton", f)
	f.cancel:SetSize(f.btn:GetSize())
	f.cancel:SetPos(f.btn:GetWide() + 10, 30)
	f.cancel:SetText(cancel_text or "Cancel")
	f.cancel:SetType("danger")
	f.cancel.DoClick = function() f:Remove() end
end

dialogs.custom = function(f, callback) end

local function createWindow(non_modal)
	local f = vgui.Create("uPanelFrame")
	f:SetSize(500, 65)
	f:SetTitle("Dialog Window")
	if !non_modal then f:DoModal(true) end
	f:MakePopup()
	f:SetBackgroundBlur(true)
	f:SetDraggable(false)

	f.btn = vgui.Create("uPanelButton", f)
	f.btn:SetPos(5, 30)
	f.btn:SetSize(f:GetWide() - 10, 30)
	f.btn:SetText("Okay")
	f.btn:SetType("primary")

	return f
end

local nonmodal_types = {custom = true, select = true}
upanel.dialog.show = function(type, title, callback, ...)
	if IsValid(upanel.dialog.WINDOW) then upanel.dialog.WINDOW:Remove() end

	local f = createWindow(nonmodal_types[type] and true or false)
	f:SetTitle(title)

	dialogs[type](f, callback, ...)

	f:Center()

	upanel.dialog.WINDOW = f

	return f
end