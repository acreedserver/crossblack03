net.Receive("ep_set_globalvar", function()
	if EliteParty.Debug then
		ElitePartyPrint(Color(10, 150, 255, 255), "Server variable information made it to client.")
	end
	local ply = net.ReadEntity()
	local name = net.ReadString()
	local type = net.ReadString()
	if type != "remove" then
		local var
		if type == "string" then
			var = net.ReadString(var)
		elseif type == "bool" then
			var = net.ReadBool(var)
		end
		ply:SetPData(name, var)
		if EliteParty.Debug then
			ElitePartyPrint(Color(10, 150, 255, 255), "Client Variable '"..name.."' set to "..tostring(var).."!")
			print(ply)
			print(name)
			print(type)
			print(var)
		end
	else
		if ply:IsValid() or ply:IsPlayer() then
			ply:RemovePData(name)
			if EliteParty.Debug then
				ElitePartyPrint(Color(10, 150, 255, 255), "Client Variable '"..name.."' Removed!")
			end
		end
	end
end)

local meta = FindMetaTable("Player")
function meta:getEPVar(name, extra)
	local data = self:GetPData(name, extra)
	ElitePartyPrint(Color(10, 150, 255, 255), "Here is the data you requested: ", tostring(data))
	return data
end