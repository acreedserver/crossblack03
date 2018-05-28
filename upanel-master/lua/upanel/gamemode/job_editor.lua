local ui = upanel.ui
local mlightning = Material("icon16/lightning.png")

local optionalFields = {
	{
		id = "category",
		panel = "uPanelSelect",
		callback = function(pnl) 
			for _, cat in pairs(DarkRP.getCategories().jobs) do
				pnl:AddOption(cat.name, cat.name, cat.name)
			end
			--pnl.GetValue = pnl.GetSelected
			pnl._defaultText = "Category"
			pnl:RethinkText()
		end,
		SetShouldUpdate = true
	},
	{
		id = "sortOrder",
		SetGhostText = "Sort Order (number)",
		panel = "uPanelTextEntry",
		SetNumeric = true
	},
	{
		id = "NeedToChangeFrom",
		panel = "uPanelSelect",
		callback = function(pnl) 
			for _, job in pairs(upanel.darkrp.getJobs()) do
				pnl:AddOption(job.name, job.command, job.command)
			end
			--pnl.GetValue = pnl.GetSelected
			pnl._defaultText = "NeedToChangeFrom"
			pnl:RethinkText()
		end,
		SetShouldUpdate = true
	},
	{
		id = "candemote",
		SetText = "Can Demote",
		SetValue = true,
		panel = "uPanelCheckBox"
	},
	{
		id = "cp",
		SetText = "Is Police Officer",
		panel = "uPanelCheckBox"
	},
	{
		id = "mayor",
		SetText = "Is Mayor",
		panel = "uPanelCheckBox"
	},
	{
		id = "chief",
		SetText = "Is Chief",
		panel = "uPanelCheckBox"
	},
	{
		id = "medic",
		SetText = "Is Medic",
		panel = "uPanelCheckBox"
	},
	{
		id = "cook",
		SetText = "Is Cook",
		panel = "uPanelCheckBox"
	},
	{
		id = "hobo",
		SetText = "Is Hobo",
		panel = "uPanelCheckBox"
	},
	{
		id = "modelScale",
		SetGhostText = "Model Scale (number)",
		panel = "uPanelTextEntry",
		SetNumeric = true
	},
	{
		id = "maxpocket",
		SetGhostText = "Max Pocket (number)",
		panel = "uPanelTextEntry",
		SetNumeric = true
	},
	{
		id = "playerClass",
		SetGhostText = "Player Class (string)",
		panel = "uPanelTextEntry"
	},
	{
		id = "CustomCheckFailMsg",
		SetGhostText = "CustomCheckFailMsg (string)",
		panel = "uPanelTextEntry"
	},
	{
		id = "canStartVoteReason",
		SetGhostText = "canStartVoteReason (string)",
		panel = "uPanelTextEntry"
	}
}

upanel.client.jobEditorWindow = function(t)
	local f = upanel.getMenu(); if !IsValid(f) then return end
	local page = f:newPage()

	--[[if !f._spnl.small then
		f._spnl:SetWide(40)
		f._spnl.small = true
		page:SetWide(f:GetWide() - 40)
	end]]

	local content = vgui.Create("uPanelScrollPanel", page)
	content:SetSize(page:GetSize())
	content._gets = {}
	content.setGet = function(self, pnl, id)
		self._gets[id] = pnl
	end

	local enum = vgui.Create("uPanelTextEntry", content)
	enum:SetPos(5, 5)
	enum:SetSize(160, 25)
	enum:SetText("TEAM_")
	enum:SetGhostText("Unique ID")

	local cmd = vgui.Create("uPanelTextEntry", content)
	cmd:SetPos(170, 5)
	cmd:SetSize(160, 25)
	cmd:SetGhostText("Command")

	local jobName = vgui.Create("uPanelTextEntry", content)
	jobName:SetPos(5, 35)
	jobName:SetSize(160, 25)
	jobName:SetGhostText("Job Name")

	local jobColor = vgui.Create("DButton", content)
	jobColor:SetPos(170, 35)
	jobColor:SetSize(160, 25)
	jobColor:SetText("")
	jobColor._clr = color_white
	jobColor.SetValue = function(self, v) self._clr = v end
	jobColor.Paint = function(self, w, h) 
		local invClr = upanel.getBasedTextColor(self._clr)

		ui.DrawRect(0, 0, w, h, self._clr)
		ui.DrawOutlinedRect(0, 0, w, h, invClr)
		ui.DrawText(self._clr.r .. ", " .. self._clr.g .. ", " .. self._clr.b, "DermaDefault", w / 2, h / 2, invClr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	jobColor.GetValue = function(self) return self._clr end
	jobColor.DoClick = function() upanel.dialog.show("color", "Job Color", function(clr) if !IsValid(jobColor) then return end jobColor._clr = clr end, jobColor._clr) end

	local max = vgui.Create("uPanelTextEntry", content)
	max:SetPos(5, 65)
	max:SetSize(160, 25)
	max:SetGhostText("Max")
	max:SetNumeric(true)

	local salary = vgui.Create("uPanelTextEntry", content)
	salary:SetPos(170, 65)
	salary:SetSize(160, 25)
	salary:SetGhostText("Salary")
	salary:SetNumeric(true)

	local vote = vgui.Create("uPanelCheckBox", content)
	vote:SetPos(335, 5)
	vote:SetText("Vote")
	vote:SetValue(false)

	local license = vgui.Create("uPanelCheckBox", content)
	license:SetPos(335, 35)
	license:SetText("Has License")
	license:SetValue(false)

	local admin = vgui.Create("uPanelCheckBox", content)
	admin:SetPos(335, 65)
	admin:SetText("Admin Only")
	admin:SetValue(false)

	local descContent = vgui.Create("uPanelContent", content)
	descContent:SetPos(5, 95)
	descContent:SetSize(435, 310)
	descContent:SetTitle("Job Description")

	local desc = vgui.Create("uPanelTextEntry", descContent)
	desc:SetPos(1, 31)
	desc:SetSize(descContent:GetWide() - 2, descContent:GetTall() - 32)
	desc:SetMultiline(true)
	desc._borderColor = Color(0, 0, 0, 0)
	desc._borderColorFocused = desc._borderColor

	local wepsContent = vgui.Create("uPanelContent", content)
	wepsContent:SetPos(445, 5)
	wepsContent:SetSize(240, 400)
	wepsContent:SetTitle("Weapons")
	wepsContent.weps = {}
	wepsContent.GetValue = function(self) return self.weps end

	wepsContent.scroll = vgui.Create("uPanelScrollPanel", wepsContent)
	wepsContent.scroll:SetPos(1, 31)
	wepsContent.scroll:SetSize(wepsContent:GetWide() - 2, wepsContent:GetTall() - 32)

	local optional = vgui.Create("uPanelContent", content)
	optional:SetPos(wepsContent.x + 5 + wepsContent:GetWide(), 5)
	optional:SetSize(content:GetWide() - optional.x - 5, 400)
	optional:SetTitle("Optional")

	optional.scroll = vgui.Create("uPanelScrollPanel", optional)
	optional.scroll:SetPos(1, 31)
	optional.scroll:SetSize(optional:GetWide() - 2, optional:GetTall() - 32)

	local ypos = 5
	for _, field in ipairs(optionalFields) do
		local p = vgui.Create(field.panel, optional.scroll)
		p:SetPos(5, ypos)

		if field.panel != "uPanelCheckBox" then
			p:SetSize(200, 30)
		else	
			p:SetWide(200)
		end

		for k, v in pairs(field) do
			if p[k] then
				p[k](p, v)
			end
		end

		if field.callback then field.callback(p) end
		content:setGet(p, field.id)

		ypos = ypos + 5 + p:GetTall()
	end
	local s = vgui.Create("DPanel", optional.scroll); s:SetPos(0, ypos); s:SetSize(0, 0)

	local wepsToUpdate = {}
	wepsContent.SetValue = function(self, v) 
		for k, v in pairs(v) do
			if wepsToUpdate[v] then
				wepsToUpdate[v]:SetValue(true)
			end
		end

		self.weps = v 
	end

	local i = 0
	for _, wep in pairs(weapons.GetList()) do
		i = i + 1

		local odd = i % 2 == 1
		local tgl
		local p = wepsContent.scroll:Add("DPanel")
		p:SetSize(wepsContent.scroll:GetWide(), 24)
		p:SetPos(0, (i - 1) * 24)
		p.Paint = function(self, w, h)
			ui.DrawRect(0, 0, w, h, 0, 0, 0, odd and 40 or 10)
			ui.DrawText(wep.ClassName, ui.font[tgl._value and "btn_bold" or "btn"], 5, h / 2, Color(30, 30, 30), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end

		tgl = vgui.Create("uPanelToggle", p)
		tgl:SetSize(16, 16)
		tgl:SetPos(p:GetWide() - 38, 4)
		tgl.OnValueChanged = function(_, b)
			table[b and "insert" or "RemoveByValue"](wepsContent.weps, wep.ClassName)
		end

		wepsToUpdate[wep.ClassName] = tgl
	end

	local models = vgui.Create("uPanelContent", content)
	models:SetPos(5, 410)
	models:SetSize(content:GetWide() - 10, 300)
	models:SetTitle("Models")
	models.mdls = {}
	models.GetValue = function(self) return self.mdls end

	local modelsToUpdate = {}
	models.SetValue = function(self, v) 
		for _, mdl in pairs(v) do
			if modelsToUpdate[mdl] then
				modelsToUpdate[mdl]._selected = true
			end
		end
		self.mdls = v 
	end

	models.fill = function()
		local perRow = 16
		local iconSize = (models:GetWide() - (perRow + 1) * 5) / perRow
		local diff = (iconSize - math.floor(iconSize)) * perRow
		local xpos, ypos = 5 + diff / 2, 35

		surface.CreateFont("upanel_mdl_icon", {font = "Roboto Bold", size = iconSize})

		local i = 0
		for k, v in pairs(upanel.darkrp.getModels()) do
			i = i + 1

			local p = vgui.Create("DPanel", models)
			p:SetPos(xpos, ypos)
			p:SetSize(iconSize, iconSize)
			p:SetModel(v)
			p:SetTooltip(v)
			p.PaintManual = p.Paint
			p.Paint = function(self, w, h)
				ui.DrawRect(0, 0, w, h, 0, 0, 0, 25)

				if self._selected then
					ui.DrawRect(0, 0, w, h, 0, 255, 0, 80)
				end
			end
			p._selected = table.HasValue(models.mdls, v)

			modelsToUpdate[v] = p

			local img = vgui.Create("ModelImage", p)
			img:Dock(FILL)
			img:SetModel(v)
			img.PaintOver = function(self, w, h)
				ui.DrawOutlinedRect(0, 0, w, h, p._selected and Color(0, 170, 25, 200) or Color(180, 180, 180, 255))

				if self.Hovered then
					ui.DrawRect(0, 0, w, h, upanel.client.themes[p._selected and "danger" or "primary"][2])
					ui.DrawText(p._selected and "-" or "+", ui.font.mdl_icon, w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				elseif p._selected then
					ui.DrawText("✓", ui.font.mdl_icon, w / 2, h / 2, Color(0, 200, 0, 190), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
			end
			img.OnMousePressed = function(_, m)
				if m == MOUSE_LEFT then 
					p._selected = !p._selected 
				end

				table[p._selected and "insert" or "RemoveByValue"](models.mdls, v)--:sub(8))
			end
			img:SetCursor("hand")

			if i % perRow == 0 then
				xpos, ypos = 5 + diff / 2,  ypos + p:GetTall() + 5
			else
				xpos = xpos + p:GetWide() + 5
			end
		end

		models:SetTall(ypos + iconSize + 5)
		models._filled = true
	end

	local create
	local hooks_list = {
		{"customCheck", "ply"},
		{"CustomCheckFailMsg", "ply, jobTable"},
		{"CanPlayerSuicide", "ply"},
		{"PlayerCanPickupWeapon", "ply, weapon"},
		{"PlayerDeath", "ply, weapon, killer"},
		{"PlayerLoadout", "ply"},
		{"PlayerSelectSpawn", "ply, spawn"},
		{"PlayerSetModel", "ply"},
		{"PlayerSpawn", "ply"},
		{"PlayerSpawnProp", "ply, model"},
		{"RequiresVote", "ply, job"},
		{"ShowSpare1", "ply"},
		{"ShowSpare2", "ply"},
		{"OnPlayerChangedTeam", "ply, oldTeam, newTeam"},
		{"canStartVote", "ply"},
		{"canStartVoteReason", "ply, jobTable"}
	}	
	local hooks = {}
	local advanced = vgui.Create("uPanelContent", content)
	advanced:SetPos(5, 715)
	advanced:SetSize(content:GetWide() - 10, 300)
	advanced:SetTitle("Advanced")
	advanced._toclear = {}

	local select_hooks = vgui.Create("uPanelSelect", advanced)
	select_hooks:SetPos(5, 35)
	select_hooks:SetSize(300, 30)
	select_hooks:SetShouldUpdate(true)
	select_hooks._defaultText = "Select an event..."
	select_hooks._direction = "up"

	for k, v in ipairs(hooks_list) do select_hooks:AddChoice(v[1], v[1], k) end

	local add_hook = vgui.Create("uPanelButton", advanced)
	add_hook:SetPos(select_hooks:GetWide() + 10, 35)
	add_hook:SetSize(65, 30)
	add_hook:SetType("primary")
	add_hook:SetText("Add")
	add_hook.DoClick = function(self)
		local selected = select_hooks:GetSelectedOption()
		if !selected then return end

		upanel.dialog.show("text", "Event: " .. selected.data, function(s) if !IsValid(advanced) then return end hooks[selected.data] = {code = s, sort = CurTime()}; advanced:load() end, "function(" .. hooks_list[selected.id][2] .. ")\n\nend", 300).entry:SetMultiline(true)
	end
	advanced.Clear = function(self) for k, v in pairs(self._toclear) do v:Remove() end; self._toclear = {} end

	local s
	advanced.load = function(self)
		local ypos = 70

		self._error = nil
		self:Clear()

		local i = 0
		for k, v in SortedPairsByMemberValue(hooks, "sort") do
			i = i + 1

			local odd = i % 2 == 1
			local delete, edit
			local line = vgui.Create("DPanel", self)
			line:SetPos(1, ypos)
			line:SetSize(self:GetWide() - 2, 31)
			line.Paint = function(self, w, h)
				ui.DrawRect(0, 0, w, h, 0, 0, 0, odd and 40 or 10)
				ui.DrawRect(0, h, w, 1, 210, 214, 222)

				ui.DrawTexturedRect(7, 7, 16, 16, mlightning)

				local tw, _ = ui.DrawText(k, ui.font.btn_bold, 30, h / 2 - 1, Color(30, 30, 30), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				if advanced._error and advanced._error[1] == k then
					ui.DrawText("ERROR: " .. advanced._error[2], ui.font.btn_bold, 30 + tw + 5, h / 2 - 1, Color(221, 75, 57), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				end

				self:SetWide(advanced:GetWide() - 2)

				delete.x = w - 93
				edit.x = delete.x - 93
			end
			table.insert(self._toclear, line)

			delete = vgui.Create("uPanelButton", line)
			delete:SetSize(90, 24)
			delete:SetPos(line:GetWide() - 93, 3)
			delete:SetText("Delete")
			delete:SetType("danger")
			delete.DoClick = function(self)
				hooks[k] = nil
				advanced:load()
			end

			edit = vgui.Create("uPanelButton", line)
			edit:SetSize(90, 24)
			edit:SetPos(delete.x - 93, 3)
			edit:SetText("Edit")
			edit:SetType("primary")
			edit.DoClick = function()
				upanel.dialog.show("text", "Event: " .. k, function(s) if !IsValid(advanced) then return end hooks[k] = {code = s, sort = (hooks[k].sort or CurTime())}; advanced:load() end, v.code, 300).entry:SetMultiline(true)
			end

			ypos = ypos + line:GetTall()
		end

		self:SetTall(ypos - 1)

		if create then 
			create.y = advanced.y + advanced:GetTall() + 5
			s.y = create.y + create:GetTall() + 5 
		end

	end
	advanced:load()
	advanced.GetValue = function(self)
		local t = {}
		for k, v in pairs(hooks) do
			t[k] = v.code
		end
		return t
	end
	advanced.SetValue = function(self, v)
		local i = 1
		for k, v in pairs(v) do
			hooks[k] = {code = v, sort = CurTime() + i}
			i = i + 1
		end
		self:load()
	end

	create = vgui.Create("uPanelButton", content)
	create:SetPos(5, advanced.y + 5 + advanced:GetTall())
	create:SetSize(content:GetWide() - 10, 30)
	create:SetType("success")
	create:SetText(t and "Update" or "Create")
	create.DoClick = function()
		local b = content:checkTable()
		if !b then return end
		
		local t = content:getTable()
		local jobCmd = t.command

		--PrintTable(t.model)

		upanel.net.msg("upanel_darkrp_newjob")
		:table(t)
		:bool(true)
		:send()

		hook.Add("uPanelNewCustomJob", "close_panel", function(j)
			if jobCmd == j.command and IsValid(create) then
				upanel.getMenu():changeTab("gamemode")
			end
		end)

	end

	local function checkBar(pass)
		if pass > 2 then return end

		timer.Simple(0.1, function()
			if !IsValid(content) then return end

			if content.VBar.Enabled then
				local vw = content.VBar:GetWide()
				models:SetWide(content:GetWide() - 10 - vw)
				if !models._filled then models:fill() end

				advanced.y = models.y + models:GetTall() + 5
				advanced:SetWide(content:GetWide() - 10 - vw)

				optional:SetWide(content:GetWide() - optional.x - 5 - vw)
				optional.scroll:SetWide(optional:GetWide() - 2)

				create:SetWide(content:GetWide() - create.x - 5 - vw)
				create.y = advanced.y + advanced:GetTall() + 5
				s.y = create.y + create:GetTall() + 5
			else
				models:fill()
				advanced.y = models.y + models:GetTall() + 5
				create.y = advanced.y + advanced:GetTall() + 5
				s.y = create.y + create:GetTall() + 5
			end

			checkBar(pass + 1)
		end)
	end
	checkBar(1)

	s = vgui.Create("DPanel", content); s:SetPos(0, advanced.y + advanced:GetTall() + 5); s:SetSize(0, 0)

	content.missingValues = {}
	content.getTable = function(self)
		local temp = {}
		for id, pnl in pairs(self._gets) do
			local val = pnl:GetValue()

			if val == "" and id != "description" then continue end

			temp[id] = pnl:GetValue()

			if pnl.GetNumeric and pnl:GetNumeric() then
				temp[id] = tonumber(temp[id]) or 0
			end
		end
		for k, v in pairs(self.missingValues) do
			temp[k] = v
		end
		return temp
	end

	content.warn = function(self, pnl)
		if pnl.__w then return end

		pnl.__w = true

		local oldPO = pnl.PaintOver
		pnl.PaintOver = function(self, w, h)
			if oldPO then oldPO(self, w, h) end
			ui.DrawOutlinedRect(0, 0, w, h, 255, 0, 0, 200)
		end

		timer.Simple(6, function()
			if IsValid(pnl) then
				pnl.PaintOver = oldPO
				pnl.__w = false
			end
		end)
	end

	content.checkTable = function(self)
		local t = self:getTable()
		local function checkEmpty(id) local pnl = self._gets[id] if pnl and pnl:GetValue() == "" then self:warn(pnl); return true end end
		local b = true

		local function sb(...) 
			for k, v in pairs({...}) do
				if v == true then
					b = false
					break
				end
			end
		end

		sb(
			checkEmpty("name"),
			checkEmpty("enum"),
			checkEmpty("command"),
			checkEmpty("max"),
			checkEmpty("salary")
		)

		if table.Count(t.model) == 0 then self:warn(self._gets.model); sb(true) end

		for k, v in pairs(t.scripts) do
			local func = CompileString("local s = " .. v, k .. "_test", false)
			if type(func) == "string" then
				advanced._error = {k, func}
				upanel.printf("error compiling the function (%s): %s", k, func)
				return false
			end
		end

		return b
	end

	content:setGet(enum, "enum")
	content:setGet(jobName, "name")
	content:setGet(max, "max")
	content:setGet(salary, "salary")
	content:setGet(cmd, "command")
	content:setGet(jobColor, "color")
	content:setGet(desc, "description")
	content:setGet(wepsContent, "weapons")
	content:setGet(vote, "vote")
	content:setGet(license, "hasLicense")
	content:setGet(admin, "admin")
	content:setGet(models, "model")
	content:setGet(advanced, "scripts")

	if t then
		for k, v in pairs(t) do
			local p = content._gets[k]

			if !IsValid(p) then
				upanel.printf("editor field does not exist (%s)", k)
				content.missingValues[k] = v
				continue
			end

			if k == "NeedToChangeFrom" or k == "category" then
				p:SelectByID(v, true)
				p:RethinkText()
				continue
			end

			p:SetValue(v)
		end
	end
end
