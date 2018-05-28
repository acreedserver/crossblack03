upanel.darkrp = upanel.darkrp or {}
upanel.darkrp.customJobs = upanel.darkrp.customJobs or {}

upanel.darkrp.getJobs = function() return RPExtraTeams end
upanel.darkrp.getJob = function(t) return RPExtraTeams[t] end
upanel.darkrp.getJobByCommand = function(cmd)
	for _, job in pairs(RPExtraTeams) do
		if job.command == cmd then
			return job
		end
	end
end
upanel.darkrp.getModels = function()
	local t = {}

	for k, v in pairs(player_manager.AllValidModels()) do
		table.insert(t, v)
	end

	for k, v in pairs(upanel.customModels) do
		table.insert(t, v)
	end

	return t
end

upanel.darkrp.loadCustomJob = function(rt)
	--if _G[rt.enum] then if !upanel.darkrp.customJobs[rt.command] or upanel.darkrp.customJobs[rt.command].enum != rt.enum then upanel.printf("unable to create a job with given enum, something's already using this name (%s)", rt.enum); return end end

	upanel.darkrp.customJobs[rt.command] = rt

	local t = table.Copy(rt)

	t.admin = t.admin and 1 or 0

	for k, v in pairs(t.scripts or {}) do
		t[k] = CompileString("return (" .. v .. ")(...)", t.command .. " - " .. k) -- somehow this works 
	end

	t.scripts = nil
	t.enum = nil

	if rt.NeedToChangeFrom then
		local j = upanel.darkrp.getJobByCommand(rt.NeedToChangeFrom)

		t.NeedToChangeFrom = j and j.team or nil
	end

	if #t.model == 1 then
		t.model = t.model[1]
	end

	-- update existing job
	local j = upanel.darkrp.getJobByCommand(t.command)
	if j then
		_G[rt.enum] = j.team
		t.team = j.team
		RPExtraTeams[j.team] = t
		upanel.printf("job with given command (%s) already exists, updating it", rt.command)
		if SERVER then upanel.darkrp.networkCustomJob(player.GetAll(), rt.command) end
		return
	end

	_G[rt.enum] = DarkRP.createJob(t.name, t)

	if SERVER then
		upanel.darkrp.networkCustomJob(player.GetAll(), rt.command)
	elseif DarkRP.getF4MenuPanel then
		local p = DarkRP.getF4MenuPanel()
		if IsValid(p) then p:Remove() end
	end
end


if CLIENT then 
	upanel.net.receive("upanel_darkrp_network_job", function(msg)
		local j = msg:table()

		if table.Count(j) == 1 then
			upanel.darkrp.customJobs[j[1]] = nil
		else
			upanel.darkrp.loadCustomJob(j)
		end
		
		hook.Call("uPanelNewCustomJob", GAMEMODE, j)
	end)

	return 
end

file.CreateDir("upanel/jobs")

util.AddNetworkString("upanel_darkrp_newjob")
util.AddNetworkString("upanel_darkrp_deletejob")
util.AddNetworkString("upanel_darkrp_network_job")
util.AddNetworkString("upanel_darkrp_importjob")

upanel.darkrp.networkCustomJob = function(ply, job)
	if job then
		upanel.net.msg("upanel_darkrp_network_job")
		:table(upanel.darkrp.customJobs[job])
		:send(ply)
	else
		for _, v in pairs(upanel.darkrp.customJobs) do
			upanel.net.msg("upanel_darkrp_network_job")
			:table(v)
			:send(ply)
		end
	end
end

upanel.darkrp.saveCustomJob = function(t)
	file.Write("upanel/jobs/" .. util.CRC(t.command) .. ".dat", util.TableToJSON(t, true))
end

upanel.darkrp.loadSavedCustomJobs = function()
	if !upanel.isEnabled("custom_jobs") then return end

	for _, f in pairs(file.Find("upanel/jobs/*.dat", "DATA")) do
		local t = util.JSONToTable(file.Read("upanel/jobs/" .. f, "DATA"))
		upanel.darkrp.loadCustomJob(t)
	end
end

hook.Add("DarkRPFinishedLoading", "upanel_load_customs", upanel.darkrp.loadSavedCustomJobs)

upanel.net.receive("upanel_darkrp_newjob", function(msg, ply)
	if !msg:isPermitted("edit_customjobs") then msg:fail("NOT_PERMITTED"); return end


	local t = msg:table()
	local create = msg:bool()

	upanel.darkrp.saveCustomJob(t)
	if create then upanel.darkrp.loadCustomJob(t) end
end)

upanel.net.receive("upanel_darkrp_deletejob", function(msg, ply)
	if !msg:isPermitted("edit_customjobs") then msg:fail("NOT_PERMITTED"); return end
	
	local cmd = msg:string()
	local j = upanel.darkrp.getJobByCommand(cmd)
	local imported = upanel.darkrp.customJobs[cmd] and upanel.darkrp.customJobs[cmd].imported

	upanel.darkrp.customJobs[cmd] = nil
	file.Delete("upanel/jobs/" .. util.CRC(cmd) .. ".dat")

	upanel.net.msg("upanel_darkrp_network_job")
	:table({cmd})
	:broadcast()

	if j and j.team and !imported then
		DarkRP.removeJob(j.team)
	end
end)

local function lookupEnum(int)
	for k, v in pairs(_G) do
		if v == int and type(k) == "string" and k:match("^TEAM_.+") then
			return k
		end
	end

	return nil
end

upanel.net.receive("upanel_darkrp_importjob", function(msg, ply)
	if !msg:isPermitted("edit_customjobs") then msg:fail("NOT_PERMITTED"); return end

	local cmd = msg:string()
	local job = upanel.darkrp.getJobByCommand(cmd)

	if !job then msg:fail("INVALID JOB"); return end

	local enum = lookupEnum(job.team) or ("TEAM_" .. job.command:upper())
	local temp = {}

	for k, v in pairs(job) do
		if type(v) == "function" then continue end

		temp[k] = v
	end

	if type(temp.model) != "table" then
		temp.model = {temp.model}
	end

	temp.enum = enum
	temp.admin = job.admin > 0 and true or false
	temp.imported = true

	upanel.darkrp.saveCustomJob(temp)
	upanel.darkrp.loadCustomJob(temp)
end)

upanel.clientSync(upanel.darkrp.networkCustomJob)