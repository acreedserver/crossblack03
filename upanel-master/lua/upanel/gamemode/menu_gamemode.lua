local TAB = {}
TAB.Name = "DarkRP"
TAB.Icon = Material("upanel/game.png", "smooth")
TAB.Order = 2
TAB.canView = function(ply)
	return upanel.permissions.check(ply, "view_darkrp")
end

local content
local ui = upanel.ui
TAB.buildMenu = function(content_pnl, frame, spnl)
	local selectedJob, selectedPlayer, blockPlayers

	if !IsValid(content) then
		content = vgui.Create("uPanelScrollPanel", content_pnl)
		content:SetSize(content_pnl:GetSize())
		content._bar = nil
		content._GetWide = content.GetWide
		content.GetWide = function(self, t)
			if !t then return self:_GetWide() end

			local w = self:_GetWide()
			
			if self._bar then w = w - self._bar end

			return w
		end
	end

	local function rebuild(w)
		content:Clear()
		content._bar = w
		TAB.buildMenu(content_pnl, frame, spnl)
	end

	local whitelist = vgui.Create("uPanelContent", content)
	whitelist:SetPos(5, 5)
	whitelist:SetSize(content:GetWide(true) - 10, 400)
	whitelist:SetTitle("Whitelist")

	local blockSize = (whitelist:GetWide() - 20) / 3
	local wl_job = vgui.Create("uPanelSelect", whitelist)
	wl_job:SetPos(5, 35)
	wl_job:SetSize(blockSize - 85, 30)
	wl_job._defaultText = "Select a job..."
	wl_job.fill = function(self)
		self._options = {}
		self._selected = {}
		self:RethinkText()

		if IsValid(self._List) then self._List:Remove() end

		for _, job in pairs(upanel.darkrp.getJobs()) do
			if upanel.darkrp.whitelist.list[job.command] then continue end
			self:AddChoice(job.name, job.command, job.command)
		end
	end
	wl_job:fill()

	local wl_jobadd = vgui.Create("uPanelButton", whitelist)
	wl_jobadd:SetPos(wl_job.x + wl_job:GetWide() + 5, 35)
	wl_jobadd:SetSize(80, 30)
	wl_jobadd:SetType("primary")
	wl_jobadd:SetText("Add")
	wl_jobadd.DoClick = function()
		local opt = wl_job:GetSelectedOption()
		if !opt then return end
		upanel.net.msg("upanel_whitelist_new"):string(opt.data):send()
	end

	local blockJobs = vgui.Create("uPanelContent", whitelist)
	blockJobs:SetPos(5, 70)
	blockJobs:SetSize(blockSize, whitelist:GetTall() - blockJobs.y - 5)

	blockJobs.scroll = vgui.Create("uPanelScrollPanel", blockJobs)
	blockJobs.scroll:SetPos(1, 1)
	blockJobs.scroll:SetSize(blockJobs:GetWide() - 2, blockJobs:GetTall() - 2)
	blockJobs.Clear = function(self) self.scroll:Clear() end

	blockJobs.fill = function(self)
		self.scroll:Clear()

		local ypos = 0
		local i = 0
		for cmd, _ in pairs(upanel.darkrp.whitelist.list) do
			i = i + 1

			local odd = i % 2 == 1
			local j = upanel.darkrp.getJobByCommand(cmd)
			local jobName = j and j.name or cmd
			local line = vgui.Create("DButton", self.scroll)
			line:SetText("")
			line:SetPos(0, ypos)
			line:SetSize(self.scroll:GetWide(), 31)
			line.Paint = function(self, w, h)
				local selected = selectedJob == cmd
				if !selected then
					ui.DrawRect(0, 0, w, h, 0, 0, 0, odd and 40 or 10)		
				else
					ui.DrawRect(0, 0, w, h, Color(60, 141, 188))
				end
				ui.DrawText(jobName, ui.font.btn, 8, h / 2 - 1, !selected and Color(30, 30, 30) or color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				ui.DrawRect(0, h - 1, w, 1, 210, 214, 222)
			end
			line.DoClick = function()
				selectedJob = selectedJob != cmd and cmd or nil

				if !selectedJob then
					blockPlayers:Clear()
				else
					blockPlayers:fill(selectedJob)
				end

				whitelist:rethinkDisabled()
			end

			ypos = ypos + line:GetTall()
		end
	end
	blockJobs:fill()

	blockPlayers = vgui.Create("uPanelContent", whitelist)
	blockPlayers:SetPos(blockSize + 10, 35)
	blockPlayers:SetSize(blockSize, whitelist:GetTall() - 40)

	blockPlayers.scroll = vgui.Create("uPanelScrollPanel", blockPlayers)
	blockPlayers.scroll:SetPos(1, 1)
	blockPlayers.scroll:SetSize(blockPlayers:GetWide() - 2, blockPlayers:GetTall() - 2)
	blockPlayers.Clear = function(self) self.scroll:Clear() end

	blockPlayers.fill = function(self, cmd)
		self:Clear()

		local ypos = 0
		local i = 0
		local plys = upanel.darkrp.whitelist.list[cmd] or {}

		for _, steamid in ipairs(plys) do
			i = i + 1

			local odd = i % 2 == 1
			local line = vgui.Create("DButton", self.scroll)
			line:SetText("")
			line:SetPos(0, ypos)
			line:SetSize(self.scroll:GetWide(), 31)
			line.Paint = function(self, w, h)
				local selected = selectedPlayer == steamid
				if !selected then
					ui.DrawRect(0, 0, w, h, 0, 0, 0, odd and 40 or 10)		
				else
					ui.DrawRect(0, 0, w, h, Color(60, 141, 188))
				end
				ui.DrawText(steamid, ui.font.btn, 8, h / 2 - 1, !selected and Color(30, 30, 30) or color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				ui.DrawRect(0, h - 1, w, 1, 210, 214, 222)
			end
			line.DoClick = function()
				selectedPlayer = selectedPlayer != steamid and steamid or nil
				whitelist:rethinkDisabled()
			end

			ypos = ypos + line:GetTall()
		end
	end

	local wl_addplayer_entry = vgui.Create("uPanelTextEntry", whitelist)
	wl_addplayer_entry:SetPos(blockSize * 2 + 15, 35)
	wl_addplayer_entry:SetSize(blockSize, 30)
	wl_addplayer_entry:SetGhostText("Enter a SteamID...")

	local wl_addplayer = vgui.Create("uPanelButton", whitelist)
	wl_addplayer:SetPos(blockSize * 2 + 15, 70)
	wl_addplayer:SetSize(blockSize, 30)
	wl_addplayer:SetType("primary")
	wl_addplayer:SetText("Add to the Whitelist")
	wl_addplayer.DoClick = function()
		if !upanel.isValidSteamID(wl_addplayer_entry:GetValue()) then return end

		upanel.net.msg("upanel_whitelist_player"):string(selectedJob):string(wl_addplayer_entry:GetValue()):string("add"):send()
	end

	local wl_removeplayer = vgui.Create("uPanelButton", whitelist)
	wl_removeplayer:SetPos(blockSize * 2 + 15, 105)
	wl_removeplayer:SetSize(blockSize, 30)
	wl_removeplayer:SetType("danger")
	wl_removeplayer:SetText("Remove from the Whitelist")
	wl_removeplayer.DoClick = function()
		upanel.net.msg("upanel_whitelist_player"):string(selectedJob):string(selectedPlayer):string("remove"):send()
		selectedPlayer = nil
		whitelist:rethinkDisabled()
	end

	local wl_removejob = vgui.Create("uPanelButton", whitelist)
	wl_removejob:SetSize(blockSize, 30)
	wl_removejob:SetPos(blockSize * 2 + 15, whitelist:GetTall() - 35)
	wl_removejob:SetType("danger")
	wl_removejob:SetText("Disable Whitelist")
	wl_removejob.DoClick = function()
		upanel.dialog.show("confirm", "Disable " .. selectedJob .. " whitelist", function() upanel.net.msg("upanel_whitelist_remove"):string(selectedJob):send() end, "Disable")
	end

	whitelist.rethinkDisabled = function(self)
		if !selectedJob then
			blockPlayers:SetAlpha(220)

			wl_addplayer_entry:SetAlpha(210)
			wl_addplayer_entry:SetDisabled(true)
			wl_addplayer_entry:SetCursor("no")

			wl_addplayer:SetAlpha(230)
			wl_addplayer:SetDisabled(true)

			wl_removejob:SetAlpha(230)
			wl_removejob:SetDisabled(true)

			selectedPlayer = nil
		else
			blockPlayers:SetAlpha(255)

			wl_addplayer_entry:SetAlpha(255)
			wl_addplayer_entry:SetDisabled(false)
			wl_addplayer_entry:SetCursor("beam")

			wl_addplayer:SetAlpha(255)
			wl_addplayer:SetDisabled(false)

			wl_removejob:SetAlpha(255)
			wl_removejob:SetDisabled(false)
		end

		wl_removeplayer:SetVisible(selectedPlayer != nil and selectedJob != nil)
	end
	whitelist:rethinkDisabled()

	hook.Add("uPanelWhitelistUpdated", "update_ui", function(cmd, t)
		if IsValid(whitelist) then
			wl_job:fill()
			blockJobs:fill()

			if cmd and selectedJob == cmd then
				selectedPlayer = nil
				blockPlayers:fill(cmd)
				whitelist:rethinkDisabled()
			end
		end
	end)

	local jobs = vgui.Create("uPanelContent", content)
	jobs:SetPos(5, whitelist.y + whitelist:GetTall() + 5)
	jobs:SetSize(content:GetWide(true) - 10, 150)
	jobs:SetTitle("Custom Jobs")

	local jobEditor = vgui.Create("uPanelButton", jobs)
	jobEditor:SetPos(5, 35)
	jobEditor:SetSize(jobs:GetWide() - 10, 30)
	jobEditor:SetText("Open Job Editor")
	jobEditor:SetType("primary")
	jobEditor.DoClick = function() upanel.client.jobEditorWindow() end

	local importHardcoded = vgui.Create("uPanelButton", jobs)
	importHardcoded:SetPos(5, 70)
	importHardcoded:SetSize(jobs:GetWide() - 10, 30)
	importHardcoded:SetText("Import Hardcoded Job")
	importHardcoded:SetType("warning")
	importHardcoded.DoClick = function() 
		local f = upanel.dialog.show("select", "Custom hooks will not be saved! (like customCheck)", function(option)
			upanel.net.msg("upanel_darkrp_importjob")
			:string(option.data)
			:send()
		end, "Select a job...")

		for k, v in pairs(upanel.darkrp.getJobs()) do
			if upanel.darkrp.customJobs[v.command] then continue end
			f.select:AddOption(v.name, v.command, v.command)
		end
	end

	local settings = vgui.Create("uPanelContent", content)
	settings:SetPos(5, jobs.y + jobs:GetTall() + 5)
	settings:SetSize(content:GetWide(true) - 10, 500)
	settings:SetTitle("DarkRP Settings")
	settings.load = function(self)
		self:Clear()

		local ypos = 31
		for k, v in ipairs(upanel.darkrp.settings_list) do
			local odd = k % 2 == 1
			local line = vgui.Create("DPanel", self)
			line:SetSize(self:GetWide() - 2, 31)
			line:SetPos(1, ypos)
			line._markup = markup.Parse(("<color=30,30,30><font=upanel_btn_bold>%s: </font><font=upanel_btn>%s</font></color>"):format(v[1], v[2]), line:GetWide() - 315)
			line.Paint = function(self, w, h)
				ui.DrawRect(0, 0, w, h, 0, 0, 0, odd and 40 or 10)

				self._markup:Draw(8, h / 2 - 1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

				ui.DrawRect(0, h - 1, w, 1, 210, 214, 222)
			end

			local valueType = type(v[3])
			local value = GAMEMODE.Config[v[1]] or v[3]

			if upanel.darkrp.settings[v[1]] != nil then
				value = upanel.darkrp.settings[v[1]]
			end

			local function save(value)
				upanel.net.msg("upanel_settings_set")
				:table({v[1], value})
				:send()
			end

			if valueType == "boolean" then
				local tgl = vgui.Create("DButton", line)
				tgl:SetText("")
				tgl:SetSize(65, 20)
				tgl:SetPos(line:GetWide() - 70, 5)
				tgl._value = value
				tgl.Paint = function(self, w, h)
					local clr = upanel.client.themes[self._value and "success" or "danger"][self:IsHovered() and 3 or 2]
					draw.RoundedBox(4, 0, 0, w, h, clr)
					ui.DrawText(self._value, ui.font.toggle_bold_small, w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
				tgl.DoClick = function()
					tgl._value = !tgl._value

					save(tgl._value)
				end
			elseif valueType == "number" then
				local entry
				local savebtn = vgui.Create("uPanelButton", line)
				savebtn:SetSize(65, 24)
				savebtn:SetPos(line:GetWide() - 70, 3)
				savebtn:SetType("success")
				savebtn:SetText("Save")
				savebtn.DoClick = function()
					local val = tonumber(entry:GetValue())
					if !val then return end
					save(val)
				end

				entry = vgui.Create("uPanelTextEntry", line)
				entry:SetSize(100, 24)
				entry:SetPos(savebtn.x - entry:GetWide() - 5, 3)
				entry:SetNumeric(true)
				entry:SetValue(value)
			elseif valueType == "string" then
				local entry
				local savebtn = vgui.Create("uPanelButton", line)
				savebtn:SetSize(65, 24)
				savebtn:SetPos(line:GetWide() - 70, 3)
				savebtn:SetType("success")
				savebtn:SetText("Save")
				savebtn.DoClick = function()
					save(entry:GetValue() or "")
				end

				entry = vgui.Create("uPanelTextEntry", line)
				entry:SetSize(135, 24)
				entry:SetPos(savebtn.x - entry:GetWide() - 5, 3)
				entry:SetValue(value)
				entry:SetMultiline(value:find("\n"))
			end

			ypos = ypos + line:GetTall()
		end

		self:SetTall(ypos)
	end

	settings:load()

	local s = vgui.Create("DPanel", content); s:SetPos(0, settings.y + 5); s:SetSize(0, 0);

	jobs.load = function(self)
		for k, v in pairs(self:GetChildren()) do
			if v == jobEditor or v == importHardcoded then continue end
			v:Remove()
		end

		local ypos = 105

		local i = 0
		for k, v in pairs(upanel.darkrp.customJobs) do
			i = i + 1

			local odd = i % 2 == 1
			local line = vgui.Create("DPanel", self)
			line:SetPos(1, ypos)
			line:SetSize(self:GetWide() - 2, 36)
			line.Paint = function(self, w, h)
				ui.DrawRect(0, 0, h, h, v.color.r, v.color.g, v.color.b, 150)
				ui.DrawRect(h, 0, w - h, h, 0, 0, 0, odd and 40 or 10)

				local tw, _ = ui.DrawText("[" .. v.enum .. "]", ui.font.text_bold, h + 8, h / 2 - 1, Color(30, 30, 30, 245), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				ui.DrawText(v.name, ui.font.text, h + 12 + tw, h / 2 - 1, Color(30, 30, 30, 245), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				ui.DrawRect(0, h - 1, w, 1, 210, 214, 222)
			end

			local mdl = vgui.Create("ModelImage", line)
			mdl:SetSize(35, 35)
			mdl:SetModel(type(v.model) == "string" and v.model or v.model[1])

			local delete = vgui.Create("uPanelButton", line)
			delete:SetSize(90, 25)
			delete:SetPos(line:GetWide() - 95, 5)
			delete:SetText("Delete")
			delete:SetType("danger")
			delete.DoClick = function(self)
				upanel.dialog.show("confirm", "Delete " .. v.command .. " job", function() upanel.net.msg("upanel_darkrp_deletejob"):string(v.command):send() end, "Delete")
			end

			local edit = vgui.Create("uPanelButton", line)
			edit:SetSize(90, 25)
			edit:SetPos(delete.x - 95, 5)
			edit:SetText("Edit")
			edit:SetType("primary")
			edit.DoClick = function()
				upanel.client.jobEditorWindow(v)
			end

			ypos = ypos + line:GetTall() - 1
		end

		self:SetTall(ypos + 1)
		settings:SetPos(5, jobs.y + jobs:GetTall() + 5)
		s.y = settings.y + settings:GetTall() + 5
	end

	jobs:load()

	hook.Add("uPanelNewCustomJob", "update_menu", function(j)
		jobs:load()
	end)

	if !upanel.isEnabled("whitelist") then whitelist:Hide() end
	if !upanel.isEnabled("custom_jobs") then jobs:Hide() end
	if !upanel.isEnabled("darkrp_config") then settings:Hide() end

	jobs.y = whitelist.y + whitelist:GetTall() + 5
	settings.y = jobs.y + jobs:GetTall() + 5

	if !content._bar then
		timer.Simple(0, function()
			if IsValid(content) and content.VBar and content.VBar.Enabled then
				rebuild(content.VBar:GetWide())
			end
		end)
	end
end 
upanel.addTab("gamemode", TAB) 