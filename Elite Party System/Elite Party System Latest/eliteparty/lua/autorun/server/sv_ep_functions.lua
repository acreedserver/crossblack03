local Meta = FindMetaTable("Player")
util.AddNetworkString("ep_set_globalvar")
function Meta:setEPVar(name, type, var, sendto)
	if self:IsValid() and self:IsPlayer() then
		if type != "remove" then
			self:SetPData(name, var)
			net.Start("ep_set_globalvar")
				net.WriteEntity(self)
				net.WriteString(name)
				net.WriteString(type)
				if type == "string" then
					net.WriteString(var)
				elseif type == "bool" then
					net.WriteBool(var)
				end
			if sendto == "self" then
				net.Send(self)
			elseif sendto == "all" then
				net.Broadcast()
			else
				net.Send(sendto)
			end
			if EliteParty.Debug then
				ElitePartyPrint(Color(10, 150, 255, 255), "Server Variable '"..name.."' set to "..tostring(var).."!")
			end
		else
			self:RemovePData( name )
			net.Start("ep_set_globalvar")
				net.WriteEntity(self)
				net.WriteString(name)
				net.WriteString(type)
			if sendto == "self" then
				net.Send(self)
			elseif sendto == "all" then
				net.Broadcast()
			else
				net.Send(sendto)
			end
			if EliteParty.Debug then
				ElitePartyPrint(Color(10, 150, 255, 255), "Server Variable '"..name.."' Removed!")
			end
		end
	end
end

function Meta:getEPVar(name, extra)
	local data = self:GetPData(name, extra)
	ElitePartyPrint(Color(10, 150, 255, 255), "Here is the data you requested: ".. tostring(data))
	return data
end

function Meta:CreateParty(Name, Type, Damage, Halo, Ring, HColor, RColor)
	if EliteParty.Parties then
		EliteParty.Parties[Name] = {
			GeneralInformation = {
				founder = self,
				name = Name, 
				type = Type,
				members = {
					{self}
				}
			},
			ToggleInformation = {
				dmg = Damage,
				halo = Halo,
				ring = Ring
			},
			ColorInformation = {
				hcolor = HColor,
				rcolor = RColor
			}
		}
		self:setEPVar("partyName", "string", Name, "all")
		if EliteParty.Debug then
			ElitePartyPrint(Color(10, 150, 255), "The party table existed and I added this new party. Here is the party table:")
			PrintTable(EliteParty.Parties)
			ElitePartyPrint(Color(10, 150, 255), "I finished printing the party table.\n\n")
		end
	else
		if EliteParty.Debug then
			ElitePartyPrint(Color(10, 150, 255), "The party table does not seem to exist!")
			ElitePartyPrint(Color(10, 150, 255), "I am creating one now. Then I will write it.\n\n")
		end
		EliteParty.Parties = {}
		self:CreateParty(Name, Type, Damage, Halo, Ring, HColor, RColor)
	end
end

function Meta:IsInParty()
	if EliteParty.Debug then
		ElitePartyPrint(Color(10, 150, 255), "-------------------------------\nBeginning check to see if "..self:Nick().." is in a party.")
	end
	if self:getEPVar("partyName") and EliteParty.Parties[self:getEPVar("partyName")] then
		return true
	else
		return false
	end
end

function GetPartyInfoByName(name)
	if EliteParty.Debug then
		ElitePartyPrint(Color(10, 150, 255), "Beginning the scavenge to find the party with the name '"..name.."'.")
	end
	if EliteParty.Debug then
		ElitePartyPrint(Color(10, 150, 255), "The party table existed. That is a good sign.")
	end
	if EliteParty.Parties[name] then
		return EliteParty.Parties[name]
	else
		return false
	end
end

function Meta:IsFounderofAny()
	if EliteParty.Debug then
		ElitePartyPrint(Color(10, 150, 255), "Beginning the check to see if '"..self:Nick().."' is apart of any party.")
	end
	if EliteParty.Debug then
		ElitePartyPrint(Color(10, 150, 255), "The party table existed. That is a good sign.")
	end
	if self:IsInParty() and EliteParty.Parties[self:getEPVar("partyName")] then
		if EliteParty.Parties[self:getEPVar("partyName")]["GeneralInformation"].founder == self then
			if EliteParty.Debug then
				ElitePartyPrint(Color(10, 150, 255), "The player is a founder of a party.")
				ElitePartyPrint(Color(10, 150, 255), "Finished the check to see if '"..self:Nick().."' is apart of any party.")
			end
			return true
		end
	end
	if EliteParty.Debug then
		ElitePartyPrint(Color(10, 150, 255), "The player is not a founder of a party.")
		ElitePartyPrint(Color(10, 150, 255), "Finished the check to see if '"..self:Nick().."' is apart of any party.")
	end
	return false
end

function Meta:GetPartyInfoByPlayer()
	if self:IsInParty() then
		if EliteParty.Parties[self:getEPVar("partyName")] then
			if EliteParty.Debug then
				ElitePartyPrint(Color(10, 150, 255), "Finished the scavenge to find the party with the player '"..self:Nick().."'.")
			end
			return EliteParty.Parties[self:getEPVar("partyName")]
		end
		if EliteParty.Debug then
			ElitePartyPrint(Color(10, 150, 255), "[ERROR] - THE PLAYER HAS A PARTY BUT WAS NOT FOUND. CONTACT THE ADDON CREATOR( BCBEST )!")
		end
		return false
	else
		if EliteParty.Debug then
			ElitePartyPrint(Color(10, 150, 255), "The party table does not seem to exist!")
		end
		return false
	end
end

function Meta:EditParty(Name, Type, Damage, Halo, Ring, HColor, RColor)
	if self:IsInParty() then
		if EliteParty.Debug then
			ElitePartyPrint(Color(10, 150, 255), "Beginning the edit of the party.")
		end
		if self:IsFounderofAny() then
			if EliteParty.Debug then
				ElitePartyPrint(Color(10, 150, 255), "The party table existed. That is a good sign.")
			end
			if EliteParty.Parties[self:getEPVar("partyName")] then
				EliteParty.Parties[self:getEPVar("partyName")] = {
					GeneralInformation = {
						founder = self,
						name = Name, 
						type = Type,
						members = EliteParty.Parties[self:getEPVar("partyName")]["GeneralInformation"].members
					},
					ToggleInformation = {
						dmg = Damage,
						halo = Halo,
						ring = Ring
					},
					ColorInformation = {
						hcolor = HColor,
						rcolor = RColor
					}
				}
				if EliteParty.Debug then
					ElitePartyPrint(Color(10, 150, 255), "Finished the edit of the party. Here is the party table:")
					PrintTable(EliteParty.Parties)
					ElitePartyPrint(Color(10, 150, 255), "I finished printing the party table.\n\n")
				end
				return true
			else
				if EliteParty.Debug then
					ElitePartyPrint(Color(10, 150, 255), "[ERROR] - THE PLAYER HAS A PARTY BUT WAS NOT FOUND. CONTACT THE ADDON CREATOR( BCBEST )!")
				end
				return false
			end
		else
			if EliteParty.Debug then
				ElitePartyPrint(Color(10, 150, 255), "The party table does not seem to exist!")
			end
			return false
		end
	else
		if EliteParty.Debug then
			ElitePartyPrint(Color(10, 150, 255), "This player is not a founder! He must have altered the files. HAX.")
		end
		return false
	end
end

function Meta:AddMemberToParty(tar)
	if self:IsInParty() then
		if EliteParty.Debug then
			ElitePartyPrint(Color(10, 150, 255), "Beginning the edit of the party.")
		end
		if self:IsFounderofAny() then
			if EliteParty.Debug then
				ElitePartyPrint(Color(10, 150, 255), "The party table existed. That is a good sign.")
			end
			if EliteParty.Parties[self:getEPVar("partyName")] then
				table.insert(EliteParty.Parties[self:getEPVar("partyName")]["GeneralInformation"].members, {tar})
				tar:setEPVar("partyName", "string", EliteParty.Parties[self:getEPVar("partyName")]["GeneralInformation"].name, "all")
				if EliteParty.Debug then
					ElitePartyPrint(Color(10, 150, 255), "Finished the edit of the party. Here is the party table:")
					PrintTable(EliteParty.Parties)
					ElitePartyPrint(Color(10, 150, 255), "I finished printing the party table.\n\n")
				end
				return true
			else
				if EliteParty.Debug then
					ElitePartyPrint(Color(10, 150, 255), "[ERROR] - THE PLAYER HAS A PARTY BUT WAS NOT FOUND. CONTACT THE ADDON CREATOR( BCBEST )!")
				end
				return false
			end
		else
			if EliteParty.Debug then
				ElitePartyPrint(Color(10, 150, 255), "The party table does not seem to exist!")
			end
			return false
		end
	else
		if EliteParty.Debug then
			ElitePartyPrint(Color(10, 150, 255), "This player is not a founder! He must have altered the files. HAX.")
		end
		return false
	end
end

function Meta:KickMemberFromParty(tar)
	if self:IsInParty() and tar:IsInParty() then
		if EliteParty.Debug then
			ElitePartyPrint(Color(10, 150, 255), "Beginning the removal of '"..tar:Nick().."'.")
		end
		if EliteParty.Debug then
			ElitePartyPrint(Color(10, 150, 255), "The party table existed. That is a good sign.")
		end
		if EliteParty.Parties[self:getEPVar("partyName")] then
			for number, member in pairs(EliteParty.Parties[self:getEPVar("partyName")]["GeneralInformation"].members) do
				for num, mem in pairs(member) do
					if mem == tar then
						if EliteParty.Debug then
							ElitePartyPrint(Color(10, 150, 255), "Found '"..tar:Nick().."' within his/her party. Now I am attempting to remove him/her.")
						end
						table.remove( EliteParty.Parties[self:getEPVar("partyName")]["GeneralInformation"].members, number )
						tar:setEPVar("partyName", "remove", "", "all")
						if EliteParty.Debug then
							ElitePartyPrint(Color(10, 150, 255), "I should have removed him/her.")
							PrintTable(EliteParty.Parties)
							ElitePartyPrint(Color(10, 150, 255), "Finished the removal of '"..tar:Nick().."'.")
						end
						return true
					end
				end
			end
		end
		if EliteParty.Debug then
			ElitePartyPrint(Color(10, 150, 255), "[ERROR] - THE PLAYER HAS A PARTY BUT WAS NOT FOUND. CONTACT THE ADDON CREATOR( BCBEST )!")
		end
		return false
	end
end

function Meta:MakeMemberFounder(tar)
	if self:IsInParty() and tar:IsInParty() then
		if EliteParty.Debug then
			ElitePartyPrint(Color(10, 150, 255), "Beginning the exchange of founder.")
		end
		if EliteParty.Debug then
			ElitePartyPrint(Color(10, 150, 255), "The party table existed. That is a good sign.")
		end
		if EliteParty.Parties[self:getEPVar("partyName")] then
			for number, member in pairs(EliteParty.Parties[self:getEPVar("partyName")]["GeneralInformation"].members) do
				for num, mem in pairs(member) do
					if mem == tar then
						if EliteParty.Debug then
							ElitePartyPrint(Color(10, 150, 255), "Found '"..tar:Nick().."' within his/her party. Now I am attempting to make him/her founder.")
						end
						EliteParty.Parties[self:getEPVar("partyName")]["GeneralInformation"].founder = EliteParty.Parties[self:getEPVar("partyName")]["GeneralInformation"].members[number][1]
						if EliteParty.Debug then
							ElitePartyPrint(Color(10, 150, 255), "I should have done the exchange him/her.")
							PrintTable(EliteParty.Parties)
							ElitePartyPrint(Color(10, 150, 255), "Finished the exchange of founder.")
						end
						return true
					end
				end
			end
		end
		if EliteParty.Debug then
			ElitePartyPrint(Color(10, 150, 255), "[ERROR] - THE PLAYER HAS A PARTY BUT WAS NOT FOUND. CONTACT THE ADDON CREATOR( BCBEST )!")
		end
		return false
	end
end

function Meta:LeaveParty()
	if self:IsInParty() then
		if not self:IsFounderofAny() then
			if EliteParty.Debug then
				ElitePartyPrint(Color(10, 150, 255), "Beginning the removal of '"..self:Nick().."'.")
			end
			if EliteParty.Debug then
				ElitePartyPrint(Color(10, 150, 255), "The party table existed. That is a good sign.")
			end
			if EliteParty.Parties[self:getEPVar("partyName")] then
				for number, member in pairs(EliteParty.Parties[self:getEPVar("partyName")]["GeneralInformation"].members) do
					for num, mem in pairs(member) do
						if mem == self then
							if EliteParty.Debug then
								ElitePartyPrint(Color(10, 150, 255), "Found '"..self:Nick().."' within his/her party. Now I am attempting to remove him/her.")
							end
							table.remove( EliteParty.Parties[self:getEPVar("partyName")]["GeneralInformation"].members, number )
							self:setEPVar("partyName", "remove", "", "all")
							if EliteParty.Debug then
								ElitePartyPrint(Color(10, 150, 255), "I should have removed him/her.")
								PrintTable(EliteParty.Parties)
								ElitePartyPrint(Color(10, 150, 255), "Finished the removal of '"..self:Nick().."'.")
							end
							return true
						end
					end
				end
			end
			if EliteParty.Debug then
				ElitePartyPrint(Color(10, 150, 255), "[ERROR] - THE PLAYER HAS A PARTY BUT WAS NOT FOUND. CONTACT THE ADDON CREATOR( BCBEST )!")
			end
			return false
		end
	end
end

function Meta:LeaveAsFounder()
	if self:IsInParty() then
		if self:IsFounderofAny() then
			if EliteParty.Debug then
				ElitePartyPrint(Color(10, 150, 255), "Beginning the removal of '"..self:Nick().."'.")
			end
			if EliteParty.Parties[self:getEPVar("partyName")] != false then
				if #EliteParty.Parties[self:getEPVar("partyName")]["GeneralInformation"].members > 1 then
					if EliteParty.Debug then
						ElitePartyPrint(Color(10, 150, 255), "The player is not the only active member. Removing the player and then randomly selecting a new lead.")
					end
					if EliteParty.Parties[self:getEPVar("partyName")] then
						for number, member in pairs(EliteParty.Parties[self:getEPVar("partyName")]["GeneralInformation"].members) do
							for num, mem in pairs(member) do
								if mem == self then
									if EliteParty.Debug then
										ElitePartyPrint(Color(10, 150, 255), "Found '"..self:Nick().."' within his/her party. Now I am attempting to remove him/her.")
									end
									table.remove( EliteParty.Parties[self:getEPVar("partyName")]["GeneralInformation"].members, number )
									EliteParty.Parties[self:getEPVar("partyName")]["GeneralInformation"].founder = EliteParty.Parties[self:getEPVar("partyName")]["GeneralInformation"].members[math.random(1, #EliteParty.Parties[self:getEPVar("partyName")]["GeneralInformation"].members)][1]
									self:setEPVar("partyName", "remove", "", "all")
									if EliteParty.Debug then
										ElitePartyPrint(Color(10, 150, 255), "I should have removed him/her.")
										PrintTable(EliteParty.Parties)
										ElitePartyPrint(Color(10, 150, 255), "Finished the removal of '"..self:Nick().."'.")
									end
									return true
								end
							end
						end
					end
					if EliteParty.Debug then
						ElitePartyPrint(Color(10, 150, 255), "[ERROR] - THE PLAYER HAS A PARTY BUT WAS NOT FOUND. CONTACT THE ADDON CREATOR( BCBEST )!")
					end
					return false
				else
					if EliteParty.Debug then
						ElitePartyPrint(Color(10, 150, 255), "The player is the only active member. Removing the whole party.")
					end
					if EliteParty.Parties[self:getEPVar("partyName")] then
						if EliteParty.Parties[self:getEPVar("partyName")]["GeneralInformation"].founder == self then
							EliteParty.Parties[self:getEPVar("partyName")] = nil
							self:setEPVar("partyName", "remove", "", "all")
							if EliteParty.Debug then
								ElitePartyPrint(Color(10, 150, 255), "I should have removed him/her.")
								PrintTable(EliteParty.Parties)
								ElitePartyPrint(Color(10, 150, 255), "Finished the removal of '"..self:Nick().."'.")
							end
							return true
						end
					end
					if EliteParty.Debug then
						ElitePartyPrint(Color(10, 150, 255), "[ERROR] - THE PLAYER'S PARTY WAS NOT FOUND! CONTACT THE ADDON CREATOR( BCBEST )!")
					end
					return false
				end
			else
				if EliteParty.Debug then
					ElitePartyPrint(Color(10, 150, 255), "I was unable to find the player's party info! Check to make sure that function is running correctly.")
				end
				return false
			end
		end
	end
end

function Meta:GetAllMembersInParty()
	local rtbl = {}
	local tbl = EliteParty.Parties[self:getEPVar("partyName")]
	for k, v in pairs(tbl["GeneralInformation"].members) do
		for num, mem in pairs(v) do
			rtbl[#rtbl+1] = mem
		end
	end
	return rtbl
end

function Meta:PopulatePartyHUD()
	local tbl = self:GetAllMembersInParty()
	for k, v in pairs(tbl) do
		net.Start("EliteParty_PopulateHUD_ToClient")
			net.WriteTable(tbl)
			net.WriteEntity(self:GetPartyInfoByPlayer()["GeneralInformation"].founder)
		net.Send(v)
	end
end

function Meta:PopulateOtherPartyHUD()
	local tbl = self:GetAllOtherMembersInParty()
	if #tbl >= 1 then
		for k, v in pairs(tbl) do
			net.Start("EliteParty_PopulateHUD_ToClient")
				net.WriteTable(tbl)
				net.WriteEntity(self:GetPartyInfoByPlayer()["GeneralInformation"].founder)
			net.Send(v)
		end
	end
	net.Start("EliteParty_RemovePopulateHUD_ToClient")
	net.Send(self)
end

function Meta:UpdateHaloData()
	local tbl = EliteParty.Parties[self:getEPVar("partyName")]
	local ctbl = tbl["ColorInformation"].hcolor
	local memtbl
	if tbl["ToggleInformation"].halo then
		memtbl = self:GetAllMembersInParty()
	else
		memtbl = {}
	end
	for k, v in pairs(self:GetAllMembersInParty()) do
		net.Start("EliteParty_UpdateMemberTableHalo_ToClient")
			net.WriteTable(memtbl)
			net.WriteTable(ctbl)
		net.Send(v)
	end
end
function Meta:UpdateRingData()
	local tbl = EliteParty.Parties[self:getEPVar("partyName")]
	local ctbl = tbl["ColorInformation"].rcolor
	local memtbl
	if tbl["ToggleInformation"].ring then
		memtbl = self:GetAllMembersInParty()
	else
		memtbl = {}
	end
	for k, v in pairs(self:GetAllMembersInParty()) do
		net.Start("EliteParty_UpdateMemberTableRing_ToClient")
			net.WriteTable(memtbl)
			net.WriteTable(ctbl)
		net.Send(v)
	end
end

function Meta:RemoveAllRingsAndHolos()
	local memtbl = {}
	local ctbl = Color(255, 255, 255, 255)
	net.Start("EliteParty_UpdateMemberTableRing_ToClient")
		net.WriteTable(memtbl)
		net.WriteTable(ctbl)
	net.Send(self)
	net.Start("EliteParty_UpdateMemberTableHalo_ToClient")
		net.WriteTable(memtbl)
		net.WriteTable(ctbl)
	net.Send(self)
end

function Meta:GetAllOtherMembersInParty()
	local rtbl = {}
	local tbl = EliteParty.Parties[self:getEPVar("partyName")]
	for k, v in pairs(tbl["GeneralInformation"].members) do
		for num, mem in pairs(v) do
			if mem != self then
				rtbl[#rtbl+1] = mem
			end
		end
	end
	return rtbl
end

function Meta:UpdateHaloDataFromOther()
	local tbl = EliteParty.Parties[self:getEPVar("partyName")]
	local ply = tbl["GeneralInformation"].members[math.random(1, #tbl["GeneralInformation"].members)][1]
	if ply != self then
		local tbl = self:GetPartyInfoByPlayer()
		local ctbl = tbl["ColorInformation"].hcolor
		local memtbl
		if tbl["ToggleInformation"].halo then
			memtbl = self:GetAllOtherMembersInParty()
		else
			memtbl = {}
		end
		for k, v in pairs(self:GetAllOtherMembersInParty()) do
			net.Start("EliteParty_UpdateMemberTableHalo_ToClient")
				net.WriteTable(memtbl)
				net.WriteTable(ctbl)
			net.Send(v)
		end
	else
		self:UpdateHaloDataFromOther()
	end
end
function Meta:UpdateRingDataFromOther()
	local tbl = EliteParty.Parties[self:getEPVar("partyName")]
	local ply = tbl["GeneralInformation"].members[math.random(1, #tbl["GeneralInformation"].members)][1]
	if ply != self then
		local tbl = self:GetPartyInfoByPlayer()
		local ctbl = tbl["ColorInformation"].rcolor
		local memtbl
		if tbl["ToggleInformation"].ring then
			memtbl = self:GetAllOtherMembersInParty()
		else
			memtbl = {}
		end
		for k, v in pairs(self:GetAllOtherMembersInParty()) do
			net.Start("EliteParty_UpdateMemberTableRing_ToClient")
				net.WriteTable(memtbl)
				net.WriteTable(ctbl)
			net.Send(v)
		end
	else
		self:UpdateHaloDataFromOther()
	end
end

function GetAllPlayersNotInParty()
	local rtbl = {}
	for k, v in pairs(player.GetAll()) do
		if not v:IsInParty() then
			table.insert(rtbl, v)
		end
	end
	return rtbl
end

function Meta:IsSameParty(tar)
	local tbl = EliteParty.Parties[self:getEPVar("partyName")]
	if tbl != false then
		for k, v in pairs(tbl["GeneralInformation"].members) do
			for num, mem in pairs(v) do
				if tar == mem then
					return true
				end
			end
		end
		return false
	else
		return false
	end
end