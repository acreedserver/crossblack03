upanel.menu = upanel.menu or {clients = {}}

util.AddNetworkString("upanel_menu_state")
upanel.net.receive("upanel_menu_state", function(msg, ply)
	local isActive = msg:bool()

	if isActive then
		if table.HasValue(upanel.menu.clients, ply) then return end
		table.insert(upanel.menu.clients, ply)
	else
		table.RemoveByValue(upanel.menu.clients, ply)
	end
end)

upanel.menu.getClients = function() return upanel.menu.clients end

