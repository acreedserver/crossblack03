upanel.permissions = upanel.permissions or {groups = {}}

upanel.permissions.list = {"view_server", "edit_server", "edit_tasks", "edit_permissions", "view_logs", "view_darkrp", "edit_customjobs", "edit_whitelist", "bypass_whitelist", "edit_settings"}
upanel.permissions.all = {}
for k, v in pairs(upanel.permissions.list) do upanel.permissions.all[v] = true end 

upanel.permissions.checkGroup = function(group, p)
	return upanel.permissions.getGroup(group)[p] == true
end

upanel.permissions.check = function(ply, p)
	return upanel.permissions.checkGroup(ply:GetUserGroup(), p)
end

upanel.permissions.addToList = function(p)
	table.insert(upanel.permissions.list, p)
	upanel.permissions.all[p] = true
end

upanel.permissions.getGroup = function(group) 
	if group == "superadmin" then return upanel.permissions.all end
	return upanel.permissions.groups[group] or {} 
end
upanel.permissions.get = function(ply) return upanel.permissions.getGroup(ply:GetUserGroup()) end

if CLIENT then 
	upanel.net.receive("upanel_permissions_network", function(msg)
		upanel.permissions.groups = msg:table()
		hook.Call("uPanelPermissionsChanged")
		upanel.print("received permissions update")
	end)

	return 
end
util.AddNetworkString("upanel_permissions_network")
util.AddNetworkString("upanel_permissions_edit")
util.AddNetworkString("upanel_permissions_delete")

upanel.permissions.network = function(ply)
	upanel.net.msg("upanel_permissions_network")
	:table(upanel.permissions.groups)
	:send(ply)
end
upanel.clientSync(upanel.permissions.network)

upanel.permissions.editGroup = function(group, tbl)
	upanel.permissions.groups[group] = tbl
	upanel.permissions.network(player.GetAll())

	file.Write("upanel/permissions.dat", util.TableToJSON(upanel.permissions.groups, true))
end

if !file.Exists("upanel/permissions.dat", "DATA") then
	file.Write("upanel/permissions.dat", util.TableToJSON({
		admin = {view_logs = true}
	}, true))
end

upanel.permissions.loadSaved = function()
	upanel.permissions.groups = util.JSONToTable(file.Read("upanel/permissions.dat") or "[]") or {}
end
upanel.permissions.loadSaved()

upanel.net.receive("upanel_permissions_delete", function(msg, ply)
	if !msg:isPermitted("edit_permissions") then msg:fail("NOT_PERMITTED"); return end

	local gname = msg:string()
	if gname:lower() == "superadmin" then msg:fail("THIS GROUP NAME IS RESERVED. IT HAS ALL PERMISSIONS."); return end

	upanel.permissions.editGroup(gname, nil)
end)

upanel.net.receive("upanel_permissions_edit", function(msg, ply)
	if !msg:isPermitted("edit_permissions") then msg:fail("NOT_PERMITTED"); return end

	local gname = msg:string()
	if gname:lower() == "superadmin" then msg:fail("THIS GROUP NAME IS RESERVED. IT HAS ALL PERMISSIONS."); return end

	upanel.permissions.editGroup(gname, msg:table())
end)