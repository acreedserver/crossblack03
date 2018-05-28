util.AddNetworkString("upanel_server_action")
util.AddNetworkString("upanel_server_hostname_changed")

upanel.net.receive("upanel_server_action", function(msg, ply)
	if !msg:isPermitted("edit_server") then msg:fail("NOT_PERMITTED"); return end

	local action = msg:string()
	if action == "stop" then
		game.ConsoleCommand("say Stopping the server via uPanel. Initiated by " .. ply:Name() .. ".\n")
		timer.Simple(0.5, function()
			for k, v in pairs(player.GetAll()) do
				v:Kick("uPanel: Server shutting down.")
			end
		end)
		timer.Simple(1, function() Entity(0):Remove() end)
	elseif action == "restart" then
		local delay = math.max(msg:float(), 0)
		if delay == 0 then
			game.ConsoleCommand("say Restarting the server via uPanel. Initiated by " .. ply:Name() .. ".\n")
		else
			game.ConsoleCommand("say uPanel: The server will restart in " .. delay .. " second(s). Initiated by " .. ply:Name() .. ".\n")
		end

		timer.Simple(delay, function()
			game.ConsoleCommand("changelevel " .. game.GetMap() .. "\n")
		end)
	elseif action == "changelevel" then
		game.ConsoleCommand("changelevel " .. msg:string() .. "\n")
	elseif action == "hostname" then
		game.ConsoleCommand("hostname " .. msg:string() .. "\n")
	end
end)

util.AddNetworkString("upanel_network_tasks")
util.AddNetworkString("upanel_add_tasks")
util.AddNetworkString("upanel_remove_tasks")

upanel.task = upanel.task or {list = {}}
upanel.task.add = function(id, data) data.id = id; table.insert(upanel.task.list, data); upanel.task.network(upanel.menu.getClients()) end

upanel.task.network = function(ply)
	local temp = table.Copy(upanel.task.list)

	for _, task in pairs(temp) do
		for k, v in pairs(task) do
			if type(v) == "function" then
				task[k] = nil
			end
		end
	end

	upanel.net.msg("upanel_network_tasks")
	:table(temp)
	:send(ply)
end

upanel.net.receive("upanel_network_tasks", function(msg, ply)
	if !msg:isPermitted("view_server") then msg:fail("NOT_PERMITTED"); return end

	upanel.task.network(ply)
end)

upanel.task.load = function(rt, msg)
	local t = {}

	for k, v in pairs(upanel.task.list) do
		if v.id == rt.id then
			table.remove(upanel.task.list, k)
			break
		end
	end

	if rt.isTimer then
		t.isTimer = true
		t.shouldRepeat = rt.shouldRepeat
		t.time = rt.time
	else
		t.match = {}
		t.time = rt.time
		t.days = {}

		for _, day in pairs(rt.days) do
			t.days[day] = true
		end
	end

	t.actionType = rt.actionType

	if rt.actionType == "cmd" then
		t.trigger = function() game.ConsoleCommand(rt.action .. "\n") end
	elseif rt.actionType == "code" then
		t.trigger = function() 
			local fn = CompileString(rt.action, rt.id .. "_autorun", false)
			if type(fn) == "string" then
				t.error = string.format("Failed to complete the task (%s), error during the code compiling: %s", rt.id, fn)
				upanel.print(t.error)
			else
				local suc, err = pcall(fn)
				if !suc then 
					t.error = string.format("Failed to complete the task (%s), error during the code execution: %s", rt.id, err)
					upanel.print(t.error) 
				end
			end
		end
	end

	upanel.task.add(rt.id, t)
end

upanel.task.remove = function(id)
	local saved = util.JSONToTable(file.Read("upanel/tasks.dat", "DATA") or "[]")

	for k, v in pairs(saved) do
		if v.id == id then
			table.remove(saved, k)
		end
	end

	for k, v in pairs(upanel.task.list) do
		if v.id == id then
			table.remove(upanel.task.list, k)
		end
	end

	file.Write("upanel/tasks.dat", util.TableToJSON(saved, true))
	
	upanel.task.network(upanel.menu.getClients())
end

upanel.task.save = function(rt)
	local saved = util.JSONToTable(file.Read("upanel/tasks.dat", "DATA") or "[]")

	table.insert(saved, rt)

	file.Write("upanel/tasks.dat", util.TableToJSON(saved, true))
end

upanel.task.loadAll = function()
	upanel.task.list = {}
	local saved = util.JSONToTable(file.Read("upanel/tasks.dat", "DATA") or "[]")
	for k, v in ipairs(saved) do
		upanel.task.load(v)
	end
end
upanel.task.loadAll()

upanel.net.receive("upanel_add_tasks", function(msg, ply)
	if !msg:isPermitted("edit_tasks") then msg:fail("NOT_PERMITTED"); return end

	local rt = msg:table()
	
	upanel.task.load(rt, msg)
	upanel.task.save(rt)
end)

upanel.net.receive("upanel_remove_tasks", function(msg, ply)
	if !msg:isPermitted("edit_tasks") then msg:fail("NOT_PERMITTED"); return end

	upanel.task.remove(msg:string())
end)


upanel.task.tick = function()
	if !upanel.isEnabled("task_manager") then return end

	local ostime = os.time()
	local weekday = tonumber(os.date("%w", ostime)) -- Hours:Minutes:Seconds DayOfTheWeek ([0, 6] -- sunday is 0)
	local daytime = os.date("%H:%M:%S", ostime)
	local ct = CurTime()

	for id, task in pairs(upanel.task.list) do
		if task.error then continue end

		if task.isTimer then
			if task.isTriggered or (task.await and task.await > ct) then continue end

			if task.time <= ct then
				task.trigger()
				task.isTriggered = true

				if task.shouldRepeat then
					task.initialTime = task.initialTime or task.time
					task.time = task.time + task.initialTime
					task.await = ct + task.initialTime * 0.8
					task.isTriggered = false
				end
			end
		else
			--print(weekday, daytime, task.time, task.days[weekday])
			if task.days[weekday] then
				if task.time .. ":00" == daytime and (!task.lastTrigger or task.lastTrigger + 5 < ct) then
					task.lastTrigger = ct
					task.trigger()
				end
			end
		end
	end
end
hook.Add("Tick", "upanel_tasks", upanel.task.tick)

concommand.Add("upanel_print_tasks", function(ply)
	if ply != NULL then return end
	local s = ""
	for _, task in ipairs(upanel.task.list) do
		s = s .. (task.isTimer and "Timer" or "Fixed") .. " [" .. task.id .. "]"

		if task.isTimer then
			s = s .. (task.shouldRepeat and " [On Repeat] " or " ") .. (task.initialTime or task.time) .. ": " .. (task.isTriggered and "is triggered" or "is yet to be triggered")
		else
			for k, v in pairs(task.match) do
				s = s .. " " .. k .. ";"
			end
		end

		s = s .. "\n"
	end
	print(s)
end)

-- i don't like this :<
-- callbacks don't work with non-lua created convars
local cvHostname = GetConVar("hostname")
local oldValue = cvHostname:GetString()
timer.Create("upanel_check_hostname", 1, 0, function()
	local newValue = cvHostname:GetString()

	if oldValue != newValue then
		upanel.net.msg("upanel_server_hostname_changed"):string(newValue):broadcast()
	end

	oldValue = newValue
end) 

hook.Add("PlayerInitialSpawn", "upanel_hostname_update", function(ply) upanel.net.msg("upanel_server_hostname_changed"):string(oldValue):send(ply) end)

concommand.Add("upanel_goto", function(ply, _, _, args)
	if ply == NULL or !ply:IsAdmin() then return end 

	args = args:Replace("\"", "")
	
	local vec = Vector(args)
	ply:SetPos(vec)
end)