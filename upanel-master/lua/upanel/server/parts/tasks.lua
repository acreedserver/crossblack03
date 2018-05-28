local this = {}
local ui = upanel.ui

upanel.client.addTask = function(t)
	upanel.net.msg("upanel_add_tasks"):table(t):send()
end

upanel.client.newTaskWindow = function(tasktype)
	local stype = tasktype:GetSelectedOption()
	if !stype then return end
	stype = stype.data

	local f = upanel.dialog.show("custom", "Task Manager", function() end)
	local height = 100

	local taskName = vgui.Create("uPanelTextEntry", f)
	taskName:SetPos(5, 30)
	taskName:SetSize(f:GetWide() - 10, 30)
	taskName:SetGhostText("Unique task name")

	if stype == "timer" then
		f.time = vgui.Create("uPanelTextEntry", f)
		f.time:SetPos(5, 65)
		f.time:SetSize(f:GetWide() - 10, 30)
		f.time:SetGhostText("Delay in seconds")
		f.time:SetNumeric(true)

		f.checkbox = vgui.Create("uPanelCheckBox", f)
		f.checkbox:SetPos(5, 100)
		f.checkbox:SetText("Repeat")
		f.checkbox:SetValue(false)
		--f.checkbox:SetTextColor(Color(30, 30, 30))

		height = 140 + f.checkbox:GetTall()
	else
		f.days = vgui.Create("uPanelSelect", f)
		f.days:SetPos(5, 65)
		f.days:SetSize(f:GetWide() - 10, 30)
		f.days:SetMultiple(true)
		f.days._defaultText = "Select days..."
		f.days:RethinkText()


		f.time = vgui.Create("uPanelTextEntry", f)
		f.time:SetPos(5, 100)
		f.time:SetSize(f:GetWide() - 10, 30)
		f.time:SetGhostText("Time in hh:mm format")

		local days = {"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"}
		for k, v in pairs(days) do f.days:AddOption(v, k % 7, k % 7) end

		height = 170
	end

	local actiontype = vgui.Create("uPanelSelect", f)
	actiontype:SetPos(5, height - 35)
	actiontype:SetSize(f:GetWide() - 10, 30)
	actiontype._defaultText = "Select action type..."
	actiontype:RethinkText()
	actiontype:AddOption("Console Command", "cmd", "cmd")
	actiontype:AddOption("Lua Script", "code", "code")
	actiontype.OnSelected = function(self, num, bool)
		if !bool then self:Select(num, true); return end
	end
	actiontype:Select(1, true)
	actiontype:RethinkText()

	height = height + actiontype:GetTall() + 5

	f.btn:SetPos(5, height - 35)
	f.btn:SetText("Create")
	f.btn.DoClick = function()
		local stype = tasktype:GetSelectedOption().data
		local t

		local taskNameValue = taskName:GetValue()
		if !taskNameValue or taskNameValue == "" then return end
		local timeValue = f.time:GetValue()

		if stype == "timer" then
			timeValue = tonumber(timeValue)

			if !timeValue then return end

			t = {
				id = taskNameValue,
				isTimer = true,
				shouldRepeat = f.checkbox:GetValue(),
				time = timeValue
			}
		elseif stype == "date" then
			local selectedDays = f.days:GetSelected()
			if table.Count(selectedDays) == 0 then return end
			if !timeValue:match("%d%d:%d%d") then return end

			local days = {}
			for k, v in pairs(selectedDays) do
				local d = f.days:GetOption(v)
				table.insert(days, d.data)
			end

			t = {
				id = taskNameValue,
				isTimer = false,
				days = days,
				time = timeValue
			}
		end

		t.actionType = actiontype:GetSelectedOption().data
		
		upanel.dialog.show("text", t.actionType == "cmd" and "Console Command" or "Lua Script", function(s)
			t.action = s
			upanel.client.addTask(t)
		end)
	end

	f:SetTall(height)
	f:Center()
end

local function drawLabel(text, x, y, background_color, text_color)
	local tw, _ = ui.GetTextSize(ui.font.btn, text)
	local lbl_w = tw + 8

	draw.RoundedBox(4, x, y, lbl_w, 20, background_color)
	ui.DrawText(text, ui.font.btn, x + 4, y + 2, color_white)

	return lbl_w
end

local mWarning = Material("icon16/error.png")
this.build = function(content)
	local hasPermission = upanel.permissions.check(LocalPlayer(), "edit_tasks")

	local tasktype = vgui.Create("uPanelSelect", content)
	tasktype:SetPos(5, 35)
	tasktype:SetSize(300, 30)
	tasktype:AddOption("Timer", "timer")
	tasktype:AddOption("Date", "date")
	tasktype._defaultText = "Select a task type..."
	tasktype:RethinkText()

	local addtask = vgui.Create("uPanelButton", content)
	addtask:SetPos(tasktype:GetWide() + 10, 35)
	addtask:SetSize(65, 30)
	addtask:SetType("primary")
	addtask:SetText("Add")
	addtask.DoClick = function(self)
		upanel.client.newTaskWindow(tasktype)
	end

	if !hasPermission then
		tasktype:SetDisabled(true)
		tasktype:SetAlpha(230)

		addtask:SetDisabled(true)
	end

	local ypos = 70
	content.toClear = {}
	content.fill = function(content, tbl)
		ypos = 70
		
		for k, v in pairs(content.toClear) do
			if IsValid(v) then v:Remove() end
		end
		content.toClear = {}

		for task_num, task in pairs(tbl) do
			local odd = task_num % 2 == 1
			local delete, edit
			local line = vgui.Create("DPanel", content)
			line:SetPos(1, ypos)
			line:SetSize(content:GetWide() - 2, 31)

			local days_text = {"Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"}
			line.Paint = function(self, w, h)
				h = 30

				ui.DrawRect(0, 0, w, h, 0, 0, 0, odd and 40 or 10)

				--local typeText = task.isTimer and "Timer" or "Date"
				--local tw, th = ui.GetTextSize(ui.font.btn, typeText)
				--local dist = (h - th - 4) / 2
				--draw.RoundedBox(4, dist, dist, tw + 8, th + 4, Color(0, 167, 208, 240))
				--ui.DrawText(typeText,  ui.font.btn, dist + 4, dist + 2, Color(255, 255, 255, 255))

				local lbl_pos = 5

				lbl_pos = lbl_pos + drawLabel(task.isTimer and "Timer" or "Date", lbl_pos, 5, Color(0, 167, 208, 240), color_white) + 5

				if task.isTimer then
					local lbl_w = drawLabel((task.initialTime or task.time) .. "s", lbl_pos, 5, (task.shouldRepeat and task.error) and Color(221, 75, 57, 240) or Color(0, 167, 208, 240), color_white)
					lbl_pos = lbl_pos + lbl_w + 5

					if task.shouldRepeat then
						lbl_pos = lbl_pos + drawLabel("Repeat", lbl_pos, 5, Color(0, 166, 90, 240), color_white) + 5
					end
				else
					local str = ""
					local numDays = table.Count(task.days)

					if numDays == 7 then
						str = "Everyday"
					elseif numDays == 2 and task.days[0] and task.days[6] then
						str = "Weekend"
					elseif numDays == 5 and !task.days[0] and !task.days[6] then
						str = "Weekdays"
					else
						for d, _ in pairs(task.days) do
							str = str .. days_text[d == 0 and 7 or d] .. " "
						end
					end

					lbl_pos = lbl_pos + drawLabel(task.time, lbl_pos, 5, Color(0, 167, 208, 240), color_white) + 5
					lbl_pos = lbl_pos + drawLabel(str, lbl_pos, 5, Color(96, 92, 168, 240), color_white) + 5
				end

				lbl_pos = lbl_pos + drawLabel(task.actionType == "cmd" and "CMD" or "Script", lbl_pos, 5, Color(243, 156, 18, 240), color_white) + 5

				ui.DrawRect(lbl_pos, 0, 1, h, 0, 0, 0, 45)

				local tw, th = ui.DrawText(task.id, ui.font.btn, lbl_pos + 5, h / 2, Color(0, 31, 63), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

				if task.error then
					local sf = math.abs(math.cos(CurTime() * 1))
					ui.DrawTexturedRect(lbl_pos + tw + 5 * 2, (h - 14) / 2, 14, 14, mWarning, 255, 255, 255, 255 * sf)
				end
				--edit.x = delete.x - 93
				ui.DrawRect(0, h, w, 1, 210, 214, 222)
			end

			if task.error then
				upanel.tooltip.set(line):text("Server has failed to execute this task.\n\n<color=221,75,57>" .. ui.SafeString(task.error) .. "</color>")
			end

			delete = vgui.Create("uPanelButton", line)
			delete:SetSize(90, 24)
			delete:SetPos(line:GetWide() - 93, 3)
			delete:SetText("Delete")
			delete:SetType("danger")
			delete.DoClick = function(self)
				upanel.dialog.show("confirm", "Delete " .. task.id .. " task", function() upanel.net.msg("upanel_remove_tasks"):string(task.id):send() end, "Delete")
			end
			delete:SetDisabled(!hasPermission)
			delete.x = line:GetWide() - 93

			--edit = vgui.Create("uPanelButton", line)
			--edit:SetSize(90, 24)
			--edit:SetPos(delete.x - 93, 3)
			--edit:SetText("Edit")
			--edit:SetType("primary")

			table.insert(content.toClear, line)
			ypos = ypos + line:GetTall()
		end
	end

	upanel.net.receive("upanel_network_tasks", function(msg) if IsValid(content) and content.fill then content:fill(msg:table()) end end)
	upanel.net.msg("upanel_network_tasks"):send()

	content.cThink = function(self)
		self:SetTall(ypos)
	end
end

return this