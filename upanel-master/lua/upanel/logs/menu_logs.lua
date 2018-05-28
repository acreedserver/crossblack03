local TAB = {}
TAB.Name = "Logs"
TAB.Icon = Material("upanel/logs.png", "smooth")
TAB.Order = 3
TAB.LogTypes = {}
TAB.perPage = 25
TAB.canView = function(ply)
	return upanel.permissions.check(ply, "view_logs") and upanel.isEnabled("logs")
end

upanel.client.addLogType = function(id, tbl) TAB.LogTypes[id] = tbl end

surface.CreateFont("upanel_loading", {font = "Roboto Bold", size = 34})
local ui = upanel.ui
TAB.buildMenu = function(content, frame, spnl)
	local pagination

	local logType = vgui.Create("uPanelSelect", content)
	logType:SetSize(250, 30)
	logType:SetPos(5, 5)
	logType:SetMultiple(false)
	logType._defaultText = "Select a type..."
	logType._text = logType._defaultText

	for k, v in SortedPairsByMemberValue(TAB.LogTypes, "order") do
		logType:AddOption(v.name or k:gsub("^%l", string.upper), k, k)
	end

	--local searchbox = vgui.Create("uPanelTextEntry", content)
	--searchbox:SetSize(300, 30)
	--searchbox:SetPos(260, 5)
	--searchbox:SetGhostText("Search...")

	local loadingLogs = true
	local plogs = vgui.Create("DPanel", content)
	plogs:SetPos(5, 40)
	plogs:SetSize(content:GetWide() - 10, content:GetTall() - 85)
	plogs.Paint = function(self, w, h)
		ui.DrawRect(0, 0, w, h, 250, 250, 250)
		ui.DrawOutlinedRect(0, 0, w, h, 210, 214, 222)

		if loadingLogs then ui.DrawText("Loading...", ui.font.loading, w / 2, 15, Color(50, 50, 50, 200), TEXT_ALIGN_CENTER) end
	end

	local line_ypos = 1
	local line_count = 0
	plogs.Clear = function(self) for k, v in pairs(self:GetChildren()) do v:Remove() end; line_ypos = 1; line_count = 0 end
	plogs.addLine = function(self, time, data)
		line_count = line_count + 1

		local drawBottomLine = line_count != TAB.perPage
		local height = (self:GetTall() - 2) / TAB.perPage
		local dateEnd = 68
		local xpos = dateEnd + 10
		local line = vgui.Create("DPanel", self)
		line:SetSize(self:GetWide() - 2, height)
		line:SetPos(1, line_ypos)
		line.Paint = function(self, w, h) 
			if drawBottomLine then ui.DrawRect(0, h - 1, w, 1, 210, 214, 222) end

			ui.DrawText(self.os_date, ui.font.btn_bold, dateEnd / 2, h / 2, Color(30, 30, 30, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			ui.DrawRect(dateEnd, 0, 1, h, 210, 214, 222)
		end
		line.os_date = os.date("%H:%M:%S", time)
		line._text = ""
		line.OnMousePressed = function(self, m)
			if m == MOUSE_RIGHT then
				local m = DermaMenu()

				m:AddOption("Copy Time", function() SetClipboardText(self.os_date) end):SetIcon("icon16/time.png")
				m:AddOption("Copy Line", function() SetClipboardText(self.os_date .. " - " .. self._text) end):SetIcon("icon16/page_copy.png")

				m:Open()
			end
		end
		for k, v in ipairs(data) do
			if type(v) == "table" then
				local tw, th = ui.GetTextSize(ui.font.btn, v.username)
				local plyEnt = player.GetBySteamID(v.steamid)

				local lbl = vgui.Create("DButton", line)
				lbl:SetPos(xpos, 0)
				lbl:SetSize(tw, th)
				lbl:CenterVertical()
				lbl:SetText("")
				lbl.Paint = function(self, w, h)
					ui.DrawText(v.username, ui.font.btn, w / 2, h / 2 - 1, Color(60, 141, 188), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

					if self.Hovered then
						DisableClipping(true)
						ui.DrawRect(0, th, tw - 1, 1, 60, 141, 188)
						DisableClipping(false)
					end
				end
				line._text = line._text .. v.username
				lbl.DoClick = function(self) self._tooltip:text(self._tooltip._text == self._smallDesc and self._bigDesc or self._smallDesc) end
				lbl.getInformation = function() 
					local str = upanel.formatString(upanel.buildString(
						"Time: " .. line.os_date .. "\n",
						"Username: {username}\n",
						"SteamID: {steamid}\n",
						"IP: {ip}\n",
						"Team: " .. team.GetName(v.team) .. " [{team}]\n",
						"Alive: {alive}\n"
					), v)

					if v.more then
						str = str .. "\nExtra:\n\n"

						local weps = ""
						if table.Count(v.more.weapons) == 0 then
							weps = "<none>"
						else
							for k, v in pairs(v.more.weapons) do
								weps = weps .. v .. " "
							end
						end

						for k, v in pairs(v.more) do
							if k == "weapons" then str = str .. "Weapons: " .. weps .. "\n"; continue end
							str = str .. k .. ": " .. tostring(v) .. "\n"
						end
					end

					return str
				end
				lbl.DoRightClick = function(self)
					local m = DermaMenu()

					m:AddOption(v.username)--:SetIcon("icon16/user.png")
					m:AddSpacer()

					local options = {
						{"Go to the saved position", function() RunConsoleCommand("upanel_goto", tostring(v.position)) end, "icon16/arrow_right.png"},
						{"Print information to the console", function() print(lbl.getInformation()) end, "icon16/application_xp_terminal.png"},
						false,
						{"Copy username", function() SetClipboardText(v.username) end, "icon16/page_copy.png"},
						{"Copy SteamID", function() SetClipboardText(v.steamid) end, "icon16/page_copy.png"},
						{"Copy IP address", function() SetClipboardText(v.ip) end, "icon16/page_copy.png"},
						{"Copy everything", function() SetClipboardText(lbl.getInformation()) end, "icon16/page_copy.png"}
					}

					for k, v in pairs(options) do
						if !v then m:AddSpacer(); continue end
						m:AddOption(v[1], v[2]):SetIcon(v[3])
					end

					m:Open()
				end

				lbl._smallDesc = v.steamid .. "\n<color=221,75,57>Click to view additional information.</color>"

				local toDisplay = {
					"<color=" .. (plyEnt and "104,131,48" or "62,115,136") .. ">" .. ui.SafeString(v.username) .. (plyEnt and "</color> (Online)\n" or "</color> (Offline)\n"),
					"{steamid}\n", 
					"{ip}\n\n",
					"<color=0,0,0>Team</color>: " .. ui.SafeString(team.GetName(v.team)) .. " [{team}]\n",
					"<color=0,0,0>Alive</color>: " .. (v.alive and "<color=0,150,0>true</color>" or "<color=255,0,0>false</color>")
				}

				--PrintTable(v)

				if v.more then
					table.insert(toDisplay, "\n\n")
					--v.more.weapons = table.Count(v.more.weapons)
					for k, v in pairs(v.more) do
						if k == "weapons" then continue end
						local value = ui.SafeString(tostring(v))
						if value == "true" then value = "<color=0,150,0>true</color>"
						elseif value == "false" then value = "<color=255,0,0>false</color>" end
						table.insert(toDisplay, "<color=0,0,0>" .. ui.SafeString(k) .. ": </color>" .. value .. "\n")
					end
				end
				
				lbl._bigDesc = upanel.formatString(upanel.buildString(unpack(toDisplay)), v)

				lbl._tooltip = upanel.tooltip.set(lbl):text(lbl._smallDesc):offset(5):delay(0.8):position("right")
				lbl._tooltip.onHide = function(self) self:text(lbl._smallDesc) end

				xpos = xpos + lbl:GetWide()
			else
				v = tostring(v)

				local lbl = vgui.Create("DLabel", line)
				lbl:SetPos(xpos, 0)
				lbl:SetText(v)
				lbl:SetFont(ui.font.btn)
				lbl:SizeToContents()
				lbl:CenterVertical()
				lbl.y = lbl.y - 1
				lbl:SetColor(Color(80, 80, 80))
				line._text = line._text .. v

				xpos = xpos + lbl:GetWide()
			end
		end

		line_ypos = line_ypos + height
	end

	local requestedStart
	local function loadPage(type, start)
		requestedStart = start

		plogs:Clear()
		loadingLogs = true

		upanel.net.msg("upanel_logs_network"):string(type):float(start):send()
	end

	local function createPagination(num)
		if IsValid(pagination) then pagination:Remove() end

		pagination = upanel.createPagination(math.max(math.ceil(num / TAB.perPage), 1))
		pagination:SetTall(35)
		pagination:SetPos(content:GetWide() - 5 - pagination:GetWide(), content:GetTall() - 40)
		pagination:SetParent(content)
		pagination.pageChanged = function(self, p)
			local start = (p - 1) * 25 + 1
			loadPage(logType:GetOption(logType:GetSelected()).id, start)
		end
		pagination:SetPage(1)
	end
	local function requestPaginationUpdate() 
		if IsValid(pagination) then pagination:Remove() end 
		upanel.net.msg("upanel_logs_count"):string(logType:GetOption(logType:GetSelected()).id):send() 
	end

	upanel.net.receive("upanel_logs_network", function(msg)
		local type, start, logs = msg:string(), msg:float(), msg:table()
		if !IsValid(plogs) or logType:GetOption(logType:GetSelected()).id != type or start != requestedStart then return end

		plogs:Clear()
		loadingLogs = false

		for k, v in SortedPairsByMemberValue(logs, "time", true) do
			plogs:addLine(v.time, TAB.LogTypes[type].formatLine(v.content))
		end

		--upanel.printf("upanel_logs_network\ntype: %s\nstart: %i\namount: %i", type, start, #logs)
	end)

	upanel.net.receive("upanel_logs_count", function(msg)
		local type, amount = msg:string(), msg:float()
		if logType:GetOption(logType:GetSelected()).id != type then return end
		createPagination(amount)

		--upanel.printf("upanel_logs_count\ntype: %s\namount: %s", type, amount)
	end)

	logType.OnSelected = function(self, num, bool)
		if !bool then self:Select(num, true); return end

		requestPaginationUpdate()

		local opt = self:GetOption(num)

	end

	logType:Select(1, true)
	logType:RethinkText()
end 

upanel.addTab("logs", TAB) 