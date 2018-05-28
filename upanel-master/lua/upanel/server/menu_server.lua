local TAB = {}
TAB.Name = "Server Management"
TAB.Icon = Material("upanel/server.png", "smooth")
TAB.Order = 1
TAB.Parts = {
	{name = "General", script = "general.lua"},
	{name = "Task Manager", script = "tasks.lua"},
	{name = "Permission Manager", script = "permissions.lua"}
}
TAB.canView = function(ply)
	return upanel.permissions.check(ply, "view_server")
end

for k, v in ipairs(TAB.Parts) do
	v.instance = include("upanel/server/parts/" .. v.script) or {}
end

local ui = upanel.ui
TAB.buildMenu = function(content, frame, spnl)
	local scroll = vgui.Create("uPanelScrollPanel", content)
	scroll:SetSize(content:GetSize())

	local prevPnl
	for k, v in ipairs(TAB.Parts) do
		local c = vgui.Create("uPanelContent", scroll)
		c:SetPos(5, 5)
		c:SetSize(scroll:GetWide() - 10, 100)
		c:SetTitle(v.name)
		c.prev = prevPnl

		c.Think = function(self)
			if IsValid(self.prev) then self.y = self.prev.y + self.prev:GetTall() + 5 end
			--self:SetWide(scroll:GetWide() - 10)

			if self.cThink then self:cThink() end
		end
		v.instance.build(c)

		if v.name == "Task Manager" and !upanel.isEnabled("task_manager") then
			c:Hide()
			c.cThink = nil
		end

		prevPnl = c
	end
end

local hostname = GetConVarString("hostname")
upanel.getHostname = function() return hostname end
upanel.net.receive("upanel_server_hostname_changed", function(msg) hostname = msg:string(); upanel.print("received hostname update") end)

upanel.addTab("server", TAB) 