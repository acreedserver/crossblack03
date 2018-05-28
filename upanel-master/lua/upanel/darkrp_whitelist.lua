upanel.darkrp.whitelist = upanel.darkrp.whitelist or {list = {}}

if SERVER then
	util.AddNetworkString("upanel_whitelist_new")
	util.AddNetworkString("upanel_whitelist_remove")
	util.AddNetworkString("upanel_whitelist_player")
	util.AddNetworkString("upanel_whitelist_sync")

	upanel.darkrp.whitelist.save = function()
		file.Write("upanel/whitelist.dat", util.TableToJSON(upanel.darkrp.whitelist.list, true))
	end

	upanel.darkrp.whitelist.loadSaved = function()
		upanel.darkrp.whitelist.list = util.JSONToTable(file.Read("upanel/whitelist.dat", "DATA") or "[]")
	end
	upanel.darkrp.whitelist.loadSaved()

	upanel.darkrp.whitelist.addPlayer = function(cmd, steamid)
		table.insert(upanel.darkrp.whitelist.list[cmd], steamid)
		upanel.darkrp.whitelist.network(player.GetAll(), cmd)
		upanel.darkrp.whitelist.save()
	end

	upanel.darkrp.whitelist.removePlayer = function(cmd, steamid)
		table.RemoveByValue(upanel.darkrp.whitelist.list[cmd], steamid)
		upanel.darkrp.whitelist.network(player.GetAll(), cmd)
		upanel.darkrp.whitelist.save()
	end

	upanel.darkrp.whitelist.create = function(cmd)
		upanel.darkrp.whitelist.list[cmd] = {}
		upanel.darkrp.whitelist.network(player.GetAll(), cmd)
		upanel.darkrp.whitelist.save()
	end

	upanel.darkrp.whitelist.remove = function(cmd)
		upanel.darkrp.whitelist.list[cmd] = nil
		upanel.darkrp.whitelist.network(player.GetAll(), cmd)
		upanel.darkrp.whitelist.save()
	end

	upanel.darkrp.whitelist.network = function(ply, cmd)
		if !cmd then
			for k, v in pairs(upanel.darkrp.whitelist.list) do
				upanel.net.msg("upanel_whitelist_sync")
				:string(k)
				:table(v)
				:send(ply)
			end
		else
			upanel.net.msg("upanel_whitelist_sync")
			:string(cmd)
			:table(upanel.darkrp.whitelist.list[cmd] or {remove = true})
			:send(ply)
		end
	end

	upanel.net.receive("upanel_whitelist_new", function(msg, ply)
		if !msg:isPermitted("edit_whitelist") then msg:fail("NOT_PERMITTED"); return end

		local cmd = msg:string()
		if upanel.darkrp.whitelist.list[cmd] then msg:fail("THIS JOB IS ALREADY WHITELIST ONLY."); return end
		upanel.darkrp.whitelist.create(cmd)
	end)

	upanel.net.receive("upanel_whitelist_remove", function(msg, ply)
		if !msg:isPermitted("edit_whitelist") then msg:fail("NOT_PERMITTED"); return end

		local cmd = msg:string()
		if !upanel.darkrp.whitelist.list[cmd] then msg:fail("THIS JOB IS NOT WHITELIST ONLY."); return end
		upanel.darkrp.whitelist.remove(cmd)
	end)

	upanel.net.receive("upanel_whitelist_player", function(msg, ply)
		if !msg:isPermitted("edit_whitelist") then msg:fail("NOT_PERMITTED"); return end

		local cmd, steamid, action = msg:string(), msg:string(), msg:string()

		if !upanel.darkrp.whitelist.list[cmd] then msg:fail("THIS JOB IS NOT WHITELIST ONLY."); return end

		if action == "add" then
			if table.HasValue(upanel.darkrp.whitelist.list[cmd], steamid) then msg:fail("THIS PLAYER IS ALREADY WHITELISTED."); return end
			upanel.darkrp.whitelist.addPlayer(cmd, steamid)
		elseif action == "remove" then
			upanel.darkrp.whitelist.removePlayer(cmd, steamid)
		else
			msg:fail("UNKNOWN INSTRUCTIONS.")
		end
	end)

	upanel.clientSync(upanel.darkrp.whitelist.network)

	hook.Add("playerCanChangeTeam", "upanel_whitelist", function(ply, t, force)
		if upanel.isEnabled("whitelist") then
			local job = upanel.darkrp.getJobs()[t]

			if job and upanel.darkrp.whitelist.list[job.command] and !table.HasValue(upanel.darkrp.whitelist.list[job.command], ply:SteamID()) and !upanel.permissions.check(ply, "bypass_whitelist") then
				return false, "You're not whitelisted!"
			end
		end
	end)
else
	upanel.net.receive("upanel_whitelist_sync", function(msg, ply)
		local cmd, t = msg:string(), msg:table()
		if t.remove then t = nil end

		upanel.darkrp.whitelist.list[cmd] = t

		hook.Call("uPanelWhitelistUpdated", GAMEMODE, cmd, t)
	end)
end
