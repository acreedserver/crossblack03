local this = {}
local ui = upanel.ui
local icons = {
	default = Material("icon16/group.png"),
	all = Material("icon16/group_key.png"),
	sys = Material("icon16/group_gear.png"),

	[true] = Material("icon16/accept.png"),
	[false] = Material("icon16/delete.png")
}

this.list = {}

upanel.client.editPermissionsWindow = function(gname)
	local f = upanel.dialog.show("custom", "Group Permissions: " .. gname, function() end)
	local perms = upanel.permissions.groups[gname] or {}

	local p = vgui.Create("DPanel", f)
	p:SetPos(5, 30)
	p:SetSize(f:GetWide() - 10, #upanel.permissions.list * 25)
	p.Paint = function(self, w, h)
		ui.DrawRect(0, 0, w, h, 250, 250, 250)
		ui.DrawOutlinedRect(0, 0, w, h, 190, 190, 190)
	end

	local collect = {}
	for k, v in ipairs(upanel.permissions.list) do
		local line = vgui.Create("DButton", p)
		line:SetPos(0, (k - 1) * 25)
		line:SetSize(p:GetWide(), 25)
		line:SetText("")
		line._state = perms[v] == true
		line._perm = v
		line.Paint = function(self, w, h)
			if self:IsHovered() then ui.DrawRect(0, 0, w, h, 0, 0, 0, 20) end
			ui.DrawRect(0, h - 1, w, 1, 190, 190, 190)
			ui.DrawText(v, ui.font.btn_bold, 6, h / 2 - 1, Color(30, 30, 30), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			ui.DrawTexturedRect(w - 24, 4, 16, 16, icons[self._state])
		end
		line.DoClick = function()
			line._state = !line._state
		end
		table.insert(collect, line)
	end

	f:SetTall(p:GetTall() + 70)
	f:Center()

	f.btn.y = f:GetTall() - 35
	f.btn:SetText("Save")
	f.btn:SetType("success")
	f.btn.DoClick = function()
		local t = {}
		for k, v in pairs(collect) do
			if v._state then
				t[v._perm] = true
			end
		end
		upanel.net.msg("upanel_permissions_edit"):string(gname):table(t):send()
		f:Remove()
	end
end

this.build = function(content)
	local ypos = 35
	local hasPermission = upanel.permissions.check(LocalPlayer(), "edit_permissions")

	local groupName = vgui.Create("uPanelTextEntry", content)
	groupName:SetPos(5, ypos)
	groupName:SetSize(300, 30)
	groupName:SetGhostText("Enter a group name...")
	groupName:SetDisabled(!hasPermission)
	--groupName:AllowInput(hasPermission)

	local addBtn = vgui.Create("uPanelButton", content)
	addBtn:SetPos(groupName:GetWide() + 10, ypos)
	addBtn:SetSize(65, 30)
	addBtn:SetType("primary")
	addBtn:SetText("Add")
	addBtn.DoClick = function(self)
		local gname = groupName:GetValue()
		if !gname or gname == "" then return end

		upanel.net.msg("upanel_permissions_edit"):string(gname):table({}):send()
	end
	addBtn:SetDisabled(!hasPermission)

	ypos = 70

	local i = 0
	for group, perms in SortedPairs(upanel.permissions.groups) do
		i = i + 1

		local micon = icons.default
		if table.Count(perms) == #upanel.permissions.list then micon = icons.all
		elseif perms.edit_server and perms.edit_tasks then micon = icons.sys end

		local delete, edit
		local odd = i % 2 == 1
		local line = vgui.Create("DPanel", content)
		line:SetSize(content:GetWide() - 2, 31)
		line:SetPos(1, ypos)
		line.Paint = function(self, w, h)
			ui.DrawRect(0, 0, w, h, 0, 0, 0, odd and 40 or 10)
			ui.DrawRect(0, h - 1, w, 1, 210, 214, 222)

			ui.DrawTexturedRect(7, 7, 16, 16, micon)
			ui.DrawText(group, ui.font.btn_bold, 30, h / 2 - 1, Color(0, 31, 63), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end

		delete = vgui.Create("uPanelButton", line)
		delete:SetSize(90, 24)
		delete:SetPos(line:GetWide() - 93, 3)
		delete:SetText("Delete")
		delete:SetType("danger")
		delete.DoClick = function(self)
			upanel.dialog.show("confirm", "Delete " .. group .. " group", function() upanel.net.msg("upanel_permissions_delete"):string(group):send() end, "Delete")
		end
		delete:SetDisabled(!hasPermission)

		edit = vgui.Create("uPanelButton", line)
		edit:SetSize(90, 24)
		edit:SetPos(delete.x - 93, 3)
		edit:SetText("Edit")
		edit:SetType("primary")
		edit.DoClick = function()
			upanel.client.editPermissionsWindow(group)
		end
		edit:SetDisabled(!hasPermission)

		delete.x = line:GetWide() - 93
		edit.x = delete.x - 93

		ypos = ypos + line:GetTall()
	end

	content:SetTall(ypos - 1)

	hook.Add("uPanelPermissionsChanged", "update_menu", function()
		if IsValid(content) then
			content:Clear()
			this.build(content)
		end
	end)
end

return this