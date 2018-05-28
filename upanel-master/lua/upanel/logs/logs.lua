upanel.logs = upanel.logs or {types = {}}

local more = {wasFrozen = "IsFrozen", wasInVehicle = "InVehicle", hadGodMode = "HasGodMode", wasTyping = "IsTyping", frags = "Frags", deaths = "Deaths"} --, position = "GetPos"}
upanel.logs.newUser = function(ply)
	local t = {
		username = ply:Nick(),
		steamid = ply:SteamID(),
		ip = ply:IPAddress(),
		team = ply:Team(),
		alive = ply:Alive(),
		position = ply:GetPos()
	}

	local function addMore(self)
		if !IsValid(ply) then return end

		self.more = {}

		for key, func in pairs(more) do
			self.more[key] = ply[func](ply)
		end

		self.more.weapons = {}
		for k, v in pairs(ply:GetWeapons()) do
			if !IsValid(v) or !v.GetClass then continue end
			table.insert(self.more.weapons, v:GetClass())
		end

		self.more.activeWeapon = "<none>"

		local wep = ply:GetActiveWeapon()
		if IsValid(wep) and wep.GetClass then self.more.activeWeapon = wep:GetClass() end
	end

	t.addMore = addMore

	return t
end

upanel.logs.isUserObject = function(obj)
	if type(obj) == "table" then
		return true
	end

	return false
end

upanel.logs.addType = function(id, extended, ...)
	if upanel.logs.types[id] then return end

	upanel.logs.types[id] = {
		requiresMore = extended,
		fields = {...},
		logs = {}
	}
end

upanel.logs.add = function(id, ...)
	if !upanel.isEnabled("logs") then return end

	local log = upanel.logs.types[id]
	local t = {content = {}, time = os.time()}
	for k, v in pairs({...}) do 
		--print(log.requiresMore, upanel.logs.isUserObject(v))
		if log.requiresMore and upanel.logs.isUserObject(v) then
			v:addMore()
		end
		if upanel.logs.isUserObject(v) then v.addMore = nil end
		t.content[log.fields[k]] = v 
	end
	--if log.requiresMore then for k, v in pairs(t.content) do if upanel.logs.isUserObject(v) then v:addMore() end end end
	table.insert(log.logs, 1, t)
end

util.AddNetworkString("upanel_logs_network")
util.AddNetworkString("upanel_logs_count")

upanel.net.receive("upanel_logs_count", function(msg, ply)
	if !msg:isPermitted("view_logs") then msg:fail("NOT_PERMITTED"); return end

	local type = msg:string()

	upanel.net.msg("upanel_logs_count")
	:string(type)
	:float(#upanel.logs.types[type].logs)
	:send(ply)
end)

upanel.logs.network = function(ply, type, start, amount)
	local logs = upanel.logs.types[type].logs

	local temp = {}
	for i = start, start + amount do
		table.insert(temp, logs[i])
	end

	upanel.net.msg("upanel_logs_network")
	:string(type)
	:float(start)
	:table(temp)
	:send(ply)
end

upanel.net.receive("upanel_logs_network", function(msg, ply)
	if !msg:isPermitted("view_logs") then msg:fail("NOT_PERMITTED"); return end

	local t, start = msg:string(), msg:float()
	upanel.logs.network(ply, t, start, 25)
end)