local this = {}
local ui = upanel.ui

this.info = {
	{title = "Server's Uptime", get = function()
		local ct = CurTime()
		local t = string.FormattedTime(ct)
		local str = ""
		local order = {"h", "m", "s"}

		for k, v in ipairs(order) do
			k = v
			v = t[k]

			str = str .. v .. k .. " "
		end

		str = str .. "(" .. math.floor(ct) .. ")"

		return str
	end},
	{title = "Hostname", get = function() return upanel.getHostname() end},
	{title = "Gamemode", get = function() return engine.ActiveGamemode() end},
	{title = "Tickrate", get = function() return math.floor(1 / engine.TickInterval()) .. " t/s" end},
	{title = "Map", get = game.GetMap()}
}

this.build = function(content)
	local hasPermissions = upanel.permissions.check(LocalPlayer(), "edit_server")

	local btnw = (content:GetWide() - 20) / 3
	local changelevel = vgui.Create("uPanelButton", content)
	changelevel:SetSize(btnw, 30)
	changelevel:SetPos(5, 35)
	changelevel:SetText("Change Map")
	changelevel:SetType("success")

	changelevel.DoClick = function()
		upanel.dialog.show("text", "Change Map", function(s)
			upanel.net.msg("upanel_server_action"):string("changelevel"):string(s):send()
		end, game.GetMap()).btn:SetText("Change")
	end

	local listenServer = !GetGlobalBool("up_dedi")

	local restart = vgui.Create("uPanelButton", content)
	restart:SetPos(changelevel.x + btnw + 5, 35)
	restart:SetSize(btnw, 30)
	restart:SetText("Restart")
	restart:SetType("warning")
	restart.DoClick = function()
		upanel.dialog.show("number", "Delay before restart in seconds", function(num)
			upanel.net.msg("upanel_server_action"):string("restart"):float(num):send()
		end, 3).btn:SetText("Restart")
	end

	local stop = vgui.Create("uPanelButton", content)
	stop:SetPos(restart.x + btnw + 5, 35)
	stop:SetSize(btnw, 30)
	stop:SetText("Stop")
	stop:SetType("danger")
	stop.DoClick = function()
		upanel.dialog.show("confirm", "Are you sure that you want to stop the server?", function()
			upanel.net.msg("upanel_server_action"):string("stop"):send()
		end, "Stop", "Back"):ShowCloseButton(false)
	end
	upanel.tooltip.set(stop):text("Basically, this button <color=221,75,57>crashes</color> the server.\nUse it at your own risk." .. (listenServer and "\n\n<color=221,75,57>Disabled for listen servers.</color>" or "")):position("bottom"):delay(0.1)
	
	if listenServer then 
		restart:SetDisabled(true)
		stop:SetDisabled(true)
		upanel.tooltip.set(restart):text("<color=221,75,57>Disabled for listen servers.</color>"):position("bottom"):delay(0.1)
	end

	if !hasPermissions then
		changelevel:SetDisabled(true)
		restart:SetDisabled(true)
		stop:SetDisabled(true)
	end

	local info = vgui.Create("DPanel", content)
	info:SetPos(5, 70)
	info:SetSize(content:GetWide() - 10, content:GetTall() - 75)
	info.Paint = function(self, w, h)
		ui.DrawRect(0, 0, w, h, 253, 253, 253)
		ui.DrawOutlinedRect(0, 0, w, h, 210, 214, 222)
	end

	local ypos = 1
	local maxPos = 0
	for k, v in ipairs(this.info) do
		local line = vgui.Create("DPanel", info)
		line:SetSize(info:GetWide() - 2, 29)
		line:SetPos(1, ypos)

		local getFunc = type(v.get) == "function"
		line.Paint = function(self, w, h)
			if self:IsHovered() or self.phovered then ui.DrawRect(0, 0, w, h, 0, 0, 0, 20) end

			local tw, th = ui.DrawText(v.title, ui.font.btn_bold, 8, h / 2 - 1, Color(45, 45, 45), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

			local lpos = 16 + tw
			if lpos > maxPos then maxPos = lpos end

			ui.DrawRect(maxPos, 0, 1, h, 210, 214, 222)
			ui.DrawText(getFunc and v.get() or v.get, ui.font.btn, maxPos + 8, h / 2 - 1, Color(60, 60, 60), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			ui.DrawRect(0, h - 1, w, 1, 210, 214, 222)
		end

		if v.title == "Hostname" then
			local change = vgui.Create("uPanelButton", line)
			change:SetSize(100, 28)
			change:SetPos(line:GetWide() - 100, 0)
			change:SetType("primary")
			change:SetText("Change")
			change._shadow = false
			change.Think = function(self) self.x = line:GetWide() - 100; line.phovered = self:IsHovered() end
			change.DoClick = function()
				upanel.dialog.show("text", "Hostname", function(s) upanel.net.msg("upanel_server_action"):string("hostname"):string(s):send() end, v.get()).btn:SetText("Change")
			end
			change:SetDisabled(!hasPermissions)
			if hasPermissions then
				line.OnMousePressed = function(self, m) 
					if m == MOUSE_RIGHT then 
						local m = DermaMenu()
						m:AddOption("Hostname"):SetDisabled(true)
						m:AddSpacer()
						m:AddOption("Edit...", function() change:DoClick() end):SetIcon("icon16/pencil.png")
						m:AddOption("Make Persistent", function() upanel.client.addTask({id = "persistent_hostname", isTimer = true, shouldRepeat = false, time = 0, actionType = "cmd", action = ("hostname " .. upanel.getHostname())}) end):SetIcon("icon16/link.png")
						m:AddOption("Restore Default", function() upanel.net.msg("upanel_server_action"):string("hostname"):string(GetConVarString("hostname")):send() end):SetIcon("icon16/arrow_refresh.png")
						m:Open()
					end
				end
			end
		end

		ypos = ypos + line:GetTall()
	end
	info:SetTall(ypos)
	content:SetTall(info.y + ypos + 5)
end

return this