-- Kills
if SERVER then
	upanel.logs.addType("kills", true, "victim", "killer", "weapon")

	hook.Add("PlayerDeath", "upanel_logs", function(victim, weapon, killer)
		local killerObj = killer:IsPlayer() and upanel.logs.newUser(killer) or killer:GetClass()
		if weapon == killer then weapon = killer.GetActiveWeapon and killer:GetActiveWeapon() or attacker end
		local wep = (IsValid(weapon) and weapon.GetClass) and weapon:GetClass() or tostring(weapon)

		upanel.logs.add("kills", upanel.logs.newUser(victim), killerObj, wep)
	end)
else
	upanel.client.addLogType("kills", {
		formatLine = function(data)
			if data.killer == "worldspawn" then return {data.victim, " got killed by the world"} end
			if type(data.killer) == "table" and data.killer.steamid == data.victim.steamid then return {data.victim, " comitted suicide using ", data.weapon} end

			return {data.victim, " was killed by ", data.killer, " with ", data.weapon} 
		end,
		order = 1
	})
end

-- Damage
if SERVER then
	upanel.logs.addType("damage", false, "victim", "attacker", "weapon", "damage")


	hook.Add("EntityTakeDamage", "upanel_logs", function(victim, dmginfo)
		if !IsValid(victim) or !victim:IsPlayer() then return end
		victim.up_lastdamage = dmginfo:GetInflictor()
		local attacker = dmginfo:GetAttacker()
		local weapon = dmginfo:GetInflictor()
		if weapon == attacker then weapon = attacker.GetActiveWeapon and attacker:GetActiveWeapon() or attacker end
		if IsValid(attacker) and attacker:IsPlayer() then attacker = upanel.logs.newUser(attacker) else attacker = attacker.GetClass and attacker:GetClass() or tostring(attacker) end
		local wep = (IsValid(weapon) and weapon.GetClass) and weapon:GetClass() or tostring(weapon)

		upanel.logs.add("damage", upanel.logs.newUser(victim), attacker, wep, math.Round(dmginfo:GetDamage()))
	end)
else
	upanel.client.addLogType("damage", {
		formatLine = function(data) 
			if data.attacker == "worldspawn" then return {data.victim, " took " .. data.damage .. " damage from the world"} end
			if type(data.attacker) == "table" and data.attacker.steamid == data.victim.steamid then return {data.attacker, " took " .. data.damage .. " damage from themself using ", data.weapon}  end
			return {data.victim, " took " .. data.damage .. " damage from ", data.attacker, " with ", data.weapon}--{data.attacker, " did " .. data.damage .. " damage to ", data.victim, " using ", data.weapon} 
		end,
		order = 2
	})
end

-- Connects
if SERVER then
	upanel.logs.addType("connects/disconnects", false, "player", "text") -- "country", "city")

	hook.Add("PlayerInitialSpawn", "upanel_logs", function(ply)
		local user = upanel.logs.newUser(ply)
		http.Fetch("http://ip-api.com/json/" .. user.ip, function(json)
			local data = util.JSONToTable(json or "[]") or {}
			local text = "joined the server"

			if data.country and data.city then text = text .. " from" .. data.country .. ", " .. data.city end

			upanel.logs.add("connects/disconnects", user, text)
		end, function()
			upanel.logs.add("connects/disconnects", user, "joined the server")
		end)
	end)

	gameevent.Listen("player_disconnect")
	hook.Add("player_disconnect", "upanel_logs", function(data)
		local ply

		for k, v in pairs(player.GetAll()) do
			if v:UserID() == data.userid then
				ply = v
				break
			end
		end

		if !ply then return end

		upanel.logs.add("connects/disconnects", upanel.logs.newUser(ply), "left the server: " .. (data.reason and data.reason or "no reason specified"))
	end)
else
	upanel.client.addLogType("connects/disconnects", {
		formatLine = function(data)
			return {data.player, " " .. data.text}
		end,
		order = 3,
		name = "Connects/Disconnects"
	})
end

-- DarkRP

-- Team Changes
if SERVER then
	upanel.logs.addType("team_changes", false, "player", "old", "new")

	hook.Add("OnPlayerChangedTeam", "upanel_logs", function(ply, told, tnew)
		upanel.logs.add("team_changes", upanel.logs.newUser(ply), told, tnew)
	end)
else
	upanel.client.addLogType("team_changes", {
		formatLine = function(data)
			return {data.player, " changed their team from " .. team.GetName(data.old) .. " to " .. team.GetName(data.new)} 
		end,
		order = 4,
		name = "Team Changes"
	})
end

-- Arrests
if SERVER then
	upanel.logs.addType("arrests", true, "arrest", "cp", "criminal", "time")

	hook.Add("playerArrested", "upanel_logs", function(criminal, time, cp)
		upanel.logs.add("arrests", true, cp and upanel.logs.newUser(cp) or false, upanel.logs.newUser(criminal), time)
	end)

	hook.Add("playerUnArrested", "upanel_logs", function(criminal, cp)
		upanel.logs.add("arrests", false, cp and upanel.logs.newUser(cp) or false, upanel.logs.newUser(criminal))
	end)
else
	upanel.client.addLogType("arrests", {
		formatLine = function(data)
			if data.arrest then return {data.cp or "<someone>", " arrested ", data.criminal, " for " .. data.time .. " second(s)"} end
			if !data.cp then return {data.criminal, " got out of jail"} end
			return {data.cp, " unarrested ", data.criminal} 
		end,
		order = 5
	})
end

-- Lockpicks

if SERVER then
	upanel.logs.addType("lockpicks", false, "player", "vehicle", "success")

	hook.Add("lockpickStarted", "upanel_logs", function(ply, ent)
		upanel.logs.add("lockpicks", upanel.logs.newUser(ply), ent:IsVehicle())
	end)

	hook.Add("onLockpickCompleted", "upanel_logs", function(ply, success, ent)
		upanel.logs.add("lockpicks", upanel.logs.newUser(ply), ent:IsVehicle(), success)
	end)
else
	upanel.client.addLogType("lockpicks", {
		formatLine = function(data)
			local objName = data.vehicle and "vehicle" or "door"
			if data.success == nil then return {data.player, " started lockpicking a " .. objName} end
			return {data.player, data.success and (" successfully lockpicked a " .. objName) or (" failed to lockpick a " .. objName)} 
		end,
		order = 6
	})
end

-- Demotes

if SERVER then
	upanel.logs.addType("demotes", false, "target", "source", "reason")

	hook.Add("onPlayerDemoted", "upanel_logs", function(target, source, reason)
		upanel.logs.add("demotes", upanel.logs.newUser(target), source and upanel.logs.newUser(source) or nil, reason)
	end)

	hook.Add("playerAFKDemoted", "upanel_logs", function(target)
		upanel.logs.add("demotes", upanel.logs.newUser(target))
	end)
else
	upanel.client.addLogType("demotes", {
		formatLine = function(data)
			if !data.source then return {data.target, " was demoted for being AFK too long"} end

			return {data.target, " was demoted by ", data.source, ", reason: " .. (data.reason or "not specified")} 
		end,
		order = 7
	})
end

-- Purchases

if SERVER then
	upanel.logs.addType("purchases", false, "player", "item", "price")

	hook.Add("playerBoughtAmmo", "upanel_logs", function(ply, item, _, price)
		upanel.logs.add("purchases", upanel.logs.newUser(ply), item.name, price)
	end)

	hook.Add("playerBoughtCustomEntity", "upanel_logs", function(ply, item, _, price)
		upanel.logs.add("purchases", upanel.logs.newUser(ply), item.name, price)
	end)

	hook.Add("playerBoughtCustomVehicle", "upanel_logs", function(ply, item, _, price)
		upanel.logs.add("purchases", upanel.logs.newUser(ply), item.name, price)
	end)

	hook.Add("playerBoughtDoor", "upanel_logs", function(ply, _, price)
		upanel.logs.add("purchases", upanel.logs.newUser(ply), "door", price)
	end)

	hook.Add("playerBoughtVehicle", "upanel_logs", function(ply, _, price)
		upanel.logs.add("purchases", upanel.logs.newUser(ply), "vehicle", price)
	end)

	hook.Add("playerBoughtFood", "upanel_logs", function(ply, item, _, price)
		upanel.logs.add("purchases", upanel.logs.newUser(ply), item.name, price)
	end)

	hook.Add("playerBoughtPistol", "upanel_logs", function(ply, item, _, price)
		upanel.logs.add("purchases", upanel.logs.newUser(ply), item.name, price)
	end)

	hook.Add("playerBoughtShipment", "upanel_logs", function(ply, item, _, price)
		upanel.logs.add("purchases", upanel.logs.newUser(ply), item.name, price)
	end)
else
	upanel.client.addLogType("purchases", {
		formatLine = function(data)
			return {data.player, " bought a " .. data.item .. " for $" .. data.price} 
		end,
		order = 8
	})
end

-- Warrants/Wanted

if SERVER then
	upanel.logs.addType("warrants/wanted", false, "criminal", "cp", "warrant", "reason")

	hook.Add("playerWarranted", "upanel_logs", function(criminal, cp, reason)
		upanel.logs.add("warrants/wanted", upanel.logs.newUser(criminal), cp and upanel.logs.newUser(cp) or false, true, reason or "not specified")
	end)

	hook.Add("playerUnWarranted", "upanel_logs", function(criminal, cp)
		upanel.logs.add("warrants/wanted", upanel.logs.newUser(criminal), cp and upanel.logs.newUser(cp) or false, true, false)
	end)

	hook.Add("playerWanted", "upanel_logs", function(criminal, cp, reason)
		upanel.logs.add("warrants/wanted", upanel.logs.newUser(criminal), cp and upanel.logs.newUser(cp) or false, false, reason or "reason not specified")
	end)

	hook.Add("playerUnWanted", "upanel_logs", function(criminal, cp)
		upanel.logs.add("warrants/wanted", upanel.logs.newUser(criminal), cp and upanel.logs.newUser(cp) or false, false, false)
	end)
else
	upanel.client.addLogType("warrants/wanted", {
		formatLine = function(data)
			--PrintTable(data)
			if data.warrant then
				if !data.reason then
					if !data.cp then
						return {data.criminal, "'s warrant expired"}
					else
						return {data.cp, " revoked a warrant for ", data.criminal}
					end
				else
					return {data.cp or "<someone>", " ordered a warrant for ", data.criminal, ", reason: " .. data.reason}
				end
			else
				return {data.cp or "<someone>", " made ", data.criminal, !data.reason and " not wanted" or (" wanted for: " .. data.reason)}
			end
		end,
		order = 9,
		name = "Warrants/Wanted"
	})
end

--TODO: Hits
--TODO: Other police stuff maybe