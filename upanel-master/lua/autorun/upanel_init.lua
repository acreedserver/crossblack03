upanel = upanel or {}

--TODO: documentation

-- Resolution Support:
-- 	4:3		1024x768
-- 	16:9	1176x664 (the lowest)
-- 	16:10	1280x768
-- 	Every width >= 1024

upanel._tabs = {}
upanel._toNetworkOnConnect = {}
upanel.Folder = "upanel"
upanel.Version = "1.0.2"

file.CreateDir("upanel")

upanel.print = function(...)
	MsgC(Color(33, 150, 243), "uPanel: ", color_white, ...)
	Msg("\n")
end

upanel.printf = function(text, ...)
	upanel.print(text:format(...))
end

upanel.formatString = function(text, tbl)
	for k, v in pairs(tbl) do
		text = text:Replace("{" .. k .. "}", tostring(v))
	end

	return text
end

upanel.colorToString = function(clr)
	clr.a = clr.a or 255
	return upanel.formatString("Color({r}, {g}, {b}, {a})", clr)
end

upanel.tableToString = function(t)
	local str = "{"

	local i = 1
	local len = table.Count(t)
	local function sString(s) return ("'" .. s:Replace("'", "\\'") .. "'") end

	for k, v in pairs(t) do
		str = str .. "[" .. (isstring(k) and sString(k) or tostring(k)) .. "] = " .. (isstring(v) and sString(v) or tostring(v)) .. (i != len and ", " or "")
		i = i + 1
	end

	str = str .. "}"

	return str
end

-- Source: http://stackoverflow.com/questions/394287876561198064977919/how-to-decide-font-color-in-white-or-black-depending-on-background-color
upanel.getBasedTextColor = function(clr, black, white)
	clr = Color(clr.r, clr.g, clr.b)

	for k, v in pairs(clr) do
		if k == "a" then continue end
		v = v / 255
		clr[k] = v <= 0.03928 and (v / 12.92) or (((v + 0.055) / 1.055) ^ 2.4)
	end

	local L = 0.2126 * clr.r + 0.7152 * clr.g + 0.0722 * clr.b

	return L > 0.179 and (black or Color(0, 0, 0)) or (white or Color(255, 255, 255))
end

upanel.clientSync = function(fn) table.insert(upanel._toNetworkOnConnect, fn) end

upanel.buildString = function(...)
	local str = ""
	for k, v in ipairs({...}) do
		str = str .. v
	end
	return str
end

upanel.translateRealm = function(n)
	if n == "cl" then return "CLIENT"
	elseif n == "sv" then return "SERVER" end
	return "SHARED"
end

upanel.pointer = {}

upanel.pointer.set = function(point, value)
	local points = string.Explode(".", point)
	local num = #points
	local t = _G

	for k, v in ipairs(points) do
		if num == k then
			t[v] = value
			return true
		end

		t = t[v]
	end

	return false
end

upanel.pointer.get = function(point, value)
	local points = string.Explode(".", point)
	local num = #points
	local t = _G

	for k, v in ipairs(points) do
		t = t[v]

		if num == k then
			return t
		end
	end
end

upanel.isValidSteamID = function(str)
	return str:match("STEAM_%d:%d:%d+") == str
end

upanel.include = function(path, realm)
	path = upanel.Folder .. "/" .. path

	local incCL, incSV = false, false
	if realm == "cl" then incCL = true elseif realm == "sv" then incSV = true else incCL, incSV = true, true end

	if SERVER then upanel.printf("[%s] Adding %s...", upanel.translateRealm(realm), path) end

	if CLIENT then
		if incCL then
			return include(path)
		end
	else
		if incCL then
			AddCSLuaFile(path)
		end

		if incSV then
			return include(path)
		end
	end 
end

upanel.addTab = function(id, t) upanel._tabs[id] = t end

upanel.include("config.lua", "sh")
upanel.include("unet.lua", "sh")

upanel.ui = upanel.ui or upanel.include("ui/ui.lua")
if CLIENT then
	upanel.client = upanel.client or {}

	hook.Add("Initialize", "upanel_ui_shadow", function()
		local drawShadow = derma.GetDefaultSkin().tex.Shadow

		upanel.ui.DrawShadow = function(x, y, w, h)
			DisableClipping(true)
			drawShadow(-4, -4, w + 10, h + 10)
			DisableClipping(false)
		end  
	end)
end

if SERVER then
	SetGlobalBool("up_dedi", game.IsDedicated())

	hook.Add("PlayerInitialSpawn", "upanel_clientsync", function(ply)
		for k, v in pairs(upanel._toNetworkOnConnect) do
			v(ply)
		end
	end)

	hook.Add("PlayerSay", "upanel_menu", function(ply, str)
		if str:match("^[!/]upanel$") then
			ply:ConCommand("upanel")
			return ""
		end
	end)
end

upanel.include("darkrp.lua", "sh")
upanel.include("darkrp_settings.lua", "sh")
upanel.include("darkrp_whitelist.lua", "sh")

upanel.include("ui/menu.lua", "cl")
upanel.include("ui/tooltip.lua", "cl")
upanel.include("ui/pagination.lua", "cl")
upanel.include("ui/select.lua", "cl")
upanel.include("ui/textentry.lua", "cl")
upanel.include("ui/button.lua", "cl")
upanel.include("ui/content.lua", "cl")
upanel.include("ui/dialog.lua", "cl")
upanel.include("ui/checkbox.lua", "cl")

upanel.include("sv_menu.lua", "sv")

upanel.include("server/sv_handle.lua", "sv")
upanel.include("server/h_permissions.lua", "sh")

if SERVER then
	AddCSLuaFile("upanel/server/parts/general.lua")
	AddCSLuaFile("upanel/server/parts/tasks.lua")
	AddCSLuaFile("upanel/server/parts/permissions.lua")
end
upanel.include("server/menu_server.lua", "cl")

upanel.include("gamemode/menu_gamemode.lua", "cl")
upanel.include("gamemode/job_editor.lua", "cl")

upanel.include("logs/logs.lua", "sv")
upanel.include("logs/menu_logs.lua", "cl") 
upanel.include("logs/default_logs.lua", "sh") 
--upanel.include("fireac/init.lua", "sh")

if SERVER then
	resource.AddSingleFile("resource/fonts/RobotoSlab-Bold.ttf")
	resource.AddSingleFile("resource/fonts/RobotoSlab-Regular.ttf")

	resource.AddSingleFile("materials/upanel/game.png")
	resource.AddSingleFile("materials/upanel/logs.png")
	resource.AddSingleFile("materials/upanel/profile.png")
	resource.AddSingleFile("materials/upanel/server.png")
end

upanel.reload = function() if CLIENT and IsValid(upanel.getMenu()) then upanel.getMenu():Remove() end AddCSLuaFile("autorun/upanel_init.lua"); include("autorun/upanel_init.lua") end
concommand.Add("upanel_reload", function()
	if SERVER then
		for k, v in pairs(player.GetAll()) do
			v:ConCommand("upanel_reload")
		end
	end

	upanel.reload()
end)

--[[
if CLIENT then
	local content = file.Read("ugh.txt.txt", "DATA")
	local lines = string.Explode("\n", content)
	local s = ""
	for i = 1, 260, 2 do
		local descLine = lines[i]
		local valLine = lines[i + 1]

		local t = string.Explode(" - ", descLine:match("- (.+)"))
		local key, desc = t[1], t[2]
		local value = valLine:match(".+= (.+)")

		s = s .. "{\"" .. key:Replace("\r", "") .. "\", \"" .. desc:Replace("\r", "") .. "\", " .. value:Replace("\r", "") .. "},\n"
	end

	file.Write("ugh_.txt", s)
end]]