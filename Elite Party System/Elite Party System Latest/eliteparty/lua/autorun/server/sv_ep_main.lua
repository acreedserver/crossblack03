//Download Fonts\\
resource.AddFile( "resource/fonts/Aliquam.ttf" )
resource.AddFile( "resource/fonts/Bebas Neue.ttf" )
resource.AddFile( "resource/fonts/nevis.ttf" )
resource.AddFile( "resource/fonts/SourceSansPro-Regular.ttf" )

local buildNum = "1.0.1"
MsgC( "[PARTY] Elite Party System "..buildNum.." by BC BEST on ScriptFodder. \n" )
util.AddNetworkString("EliteParty_NoPOpenMenu")
util.AddNetworkString("EP_CreateParty_ToServer")
util.AddNetworkString("EP_ViewMenu_ToClient")
util.AddNetworkString("EliteParty_CreateParty_ToServer")
util.AddNetworkString("EliteParty_ViewParty_ToServer")
util.AddNetworkString("EliteParty_LeaveParty_ToServer")
util.AddNetworkString("EliteParty_EditParty_ToServer")
util.AddNetworkString("EliteParty_RequestInviteList_ToServer")
util.AddNetworkString("EliteParty_RequestInviteList_ToClient")
util.AddNetworkString("EliteParty_InvitePlayer_ToServer")
util.AddNetworkString("EliteParty_InvitePlayer_ToClient")
util.AddNetworkString("EliteParty_PartyInvitedAccepted_ToServer")
util.AddNetworkString("EliteParty_PartyInvitedAccepted_ToClient")
util.AddNetworkString("EliteParty_NewMember_ToClient")
util.AddNetworkString("EliteParty_KickMember_ToServer")
util.AddNetworkString("EliteParty_KickedMember_ToClient")
util.AddNetworkString("EliteParty_MakeFounder_ToServer")
util.AddNetworkString("EliteParty_MakeFounder_ToClient")
util.AddNetworkString("EliteParty_RequestJoin_ToServer")
util.AddNetworkString("EliteParty_RequestJoin_ToClient")
util.AddNetworkString("EliteParty_PartyRequestAccepted_ToServer")
util.AddNetworkString("EliteParty_PartyRequestAccepted_ToClient")
util.AddNetworkString("EliteParty_UpdateMemberTableHalo_ToClient")
util.AddNetworkString("EliteParty_UpdateMemberTableRing_ToClient")
util.AddNetworkString("EliteParty_PopulateHUD_ToClient")
util.AddNetworkString("EliteParty_RemovePopulateHUD_ToClient")
util.AddNetworkString("EliteParty_SendPartyChat_ToClient")
MsgC( "You have recieved all required data. Enjoy the script!\n" )

hook.Add( "PlayerSay", "OpenPartyNoParty", function( ply, text, to )
	if EliteParty.ChatCommand then
		if string.lower(text) == string.lower(EliteParty.ChatCommand) then
			net.Start("EliteParty_NoPOpenMenu")
				net.WriteEntity(ply)
				EPTernary(ply:IsInParty(), function() net.WriteBool(false) end, function() net.WriteBool(true) end)
				net.WriteTable(EliteParty.Parties)
			net.Send(ply)
		end
	end
end)

hook.Add( "PlayerSay", "PartyChating", function(ply,text)
	if string.sub(text, 1, (string.len(EliteParty.PartyChatCommand)+1)) == (EliteParty.PartyChatCommand.." ") then
		local Text = string.sub(text, (string.len(EliteParty.PartyChatCommand)+2))
		for k, v in pairs(ply:GetAllMembersInParty()) do
			net.Start("EliteParty_SendPartyChat_ToClient")
				net.WriteEntity(ply)
				net.WriteString(Text)
			net.Send(v)
		end
		return ""
	end
end)

net.Receive("EP_CreateParty_ToServer", function(len, ply)
	--local ply = net.ReadEntity()
	net.Start("EP_ViewMenu_ToClient")
		net.WriteEntity(ply)
		net.WriteBool(true)
		net.WriteBool(ply:IsInParty())
		net.WriteTable(EliteParty.Parties)
	net.Send(ply)
end)

net.Receive("EliteParty_ViewParty_ToServer", function(len, ply)
	--local ply = net.ReadEntity()
	local name = net.ReadString()
	net.Start("EP_ViewMenu_ToClient")
		net.WriteEntity(ply)
		net.WriteBool(false)
		net.WriteBool(ply:IsInParty())
		if GetPartyInfoByName(name) != false then
			net.WriteTable(GetPartyInfoByName(name))
		end
	net.Send(ply)
end)

net.Receive("EliteParty_CreateParty_ToServer", function(len, ply)
	--local ply = net.ReadEntity()
	local Name = net.ReadString()
	local Type = net.ReadString()
	local Damage = net.ReadBool()
	local Halo = net.ReadBool()
	local Ring = net.ReadBool()
	local HaloColor = net.ReadTable()
	local RingColor = net.ReadTable()
	if EliteParty.Debug then
		ElitePartyPrint(Color(10, 150, 255), "-----------------------------------------------------")
		ElitePartyPrint(Color(10, 150, 255), "Founder = "..ply:Nick())
		ElitePartyPrint(Color(10, 150, 255), "Name = "..Name)
		ElitePartyPrint(Color(10, 150, 255), "Damage = "..tostring(Damage))
		ElitePartyPrint(Color(10, 150, 255), "Halo = "..tostring(Halo))
		ElitePartyPrint(Color(10, 150, 255), "Ring = "..tostring(Ring))
		ElitePartyPrint(Color(10, 150, 255), "Halo Color = "..table.ToString(HaloColor))
		ElitePartyPrint(Color(10, 150, 255), "Ring Color = "..table.ToString(RingColor))
		ElitePartyPrint(Color(10, 150, 255), "Name = "..Name)
		ElitePartyPrint(Color(10, 150, 255), "-----------------------------------------------------\n\n")
	end
	ply:CreateParty(Name, Type, Damage, Halo, Ring, HaloColor, RingColor)
	timer.Simple(1, function()
		ply:UpdateHaloData()
		ply:UpdateRingData()
		ply:PopulatePartyHUD()
	end)
end)

net.Receive("EliteParty_EditParty_ToServer", function(len, ply)
	--local ply = net.ReadEntity()
	local Name = net.ReadString()
	local Type = net.ReadString()
	local Damage = net.ReadBool()
	local Halo = net.ReadBool()
	local Ring = net.ReadBool()
	local HaloColor = net.ReadTable()
	local RingColor = net.ReadTable()
	if EliteParty.Debug then
		ElitePartyPrint(Color(10, 150, 255), "-----------------------------------------------------")
		ElitePartyPrint(Color(10, 150, 255), "Founder = "..ply:Nick())
		ElitePartyPrint(Color(10, 150, 255), "Name = "..Name)
		ElitePartyPrint(Color(10, 150, 255), "Damage = "..tostring(Damage))
		ElitePartyPrint(Color(10, 150, 255), "Halo = "..tostring(Halo))
		ElitePartyPrint(Color(10, 150, 255), "Ring = "..tostring(Ring))
		ElitePartyPrint(Color(10, 150, 255), "Halo Color = "..table.ToString(HaloColor))
		ElitePartyPrint(Color(10, 150, 255), "Ring Color = "..table.ToString(RingColor))
		ElitePartyPrint(Color(10, 150, 255), "Name = "..Name)
		ElitePartyPrint(Color(10, 150, 255), "-----------------------------------------------------\n\n")
	end
	ply:EditParty(Name, Type, Damage, Halo, Ring, HaloColor, RingColor)
	ply:UpdateHaloData()
	ply:UpdateRingData()
	ply:PopulatePartyHUD()
end)

net.Receive("EliteParty_LeaveParty_ToServer", function(len, ply)
	--local ply = net.ReadEntity()
	if ply:IsPlayer() and ply:IsValid() then
		if ply:IsInParty() then
			if ply:IsFounderofAny() then
				if #ply:GetAllMembersInParty() <= 1 then
					ply:RemoveAllRingsAndHolos()
					ply:PopulateOtherPartyHUD()
					ply:LeaveAsFounder()
				else
					ply:UpdateHaloDataFromOther()
					ply:UpdateRingDataFromOther()
					ply:RemoveAllRingsAndHolos()
					ply:PopulateOtherPartyHUD()
					ply:LeaveAsFounder()
				end
			else
				ply:UpdateHaloDataFromOther()
				ply:UpdateRingDataFromOther()
				ply:RemoveAllRingsAndHolos()
				ply:PopulateOtherPartyHUD()
				ply:LeaveParty()
			end
		end
	end
end)

net.Receive("EliteParty_RequestInviteList_ToServer", function(len, ply)
	--local ply = net.ReadEntity()
	local players = GetAllPlayersNotInParty()
	local tbl = net.ReadTable()
	net.Start("EliteParty_RequestInviteList_ToClient")
		net.WriteEntity(ply)
		net.WriteTable(players)
		net.WriteTable(tbl)
	net.Send(ply)
end)

net.Receive("EliteParty_InvitePlayer_ToServer", function(len, ply)
	--local ply = net.ReadEntity()
	local tar = net.ReadEntity()
	if ply:IsValid() and ply:IsPlayer() and tar:IsValid() and tar:IsPlayer() then
		if ply:IsInParty() then
			if ply:IsFounderofAny() then
				if not tar:IsInParty() then
					net.Start("EliteParty_InvitePlayer_ToClient")
						net.WriteEntity(ply)
						net.WriteEntity(tar)
						net.WriteString(ply:GetPartyInfoByPlayer()["GeneralInformation"].name)
					net.Send(tar)
				end
			end
		end
	end
end)

net.Receive("EliteParty_PartyInvitedAccepted_ToServer", function(len, tar)
	local ply = net.ReadEntity()
	if ply:IsValid() and ply:IsPlayer() and tar:IsValid() and tar:IsPlayer() then
		if ply:IsInParty() then
			if ply:IsFounderofAny() then
				if tar:IsInParty() != true then
					print("Here")
					ply:AddMemberToParty(tar)
					ply:UpdateHaloData()
					ply:UpdateRingData()
					ply:PopulatePartyHUD()
					for k, v in pairs(ply:GetPartyInfoByPlayer()["GeneralInformation"].members) do
						for num, mem in pairs(v) do
							net.Start("EliteParty_NewMember_ToClient")
								net.WriteEntity(ply)
								net.WriteEntity(tar)
							net.Send(mem)
						end
					end
				end
			end
		end
	end
end)

net.Receive("EliteParty_RequestJoin_ToServer", function(len, ply)
	--local ply = net.ReadEntity()
	local tar = net.ReadEntity()
	if ply:IsValid() and ply:IsPlayer() and tar:IsValid() and tar:IsPlayer() then
		if tar:IsInParty() then
			if tar:IsFounderofAny() then
				if not ply:IsInParty() then
					net.Start("EliteParty_RequestJoin_ToClient")
						net.WriteEntity(ply)
						net.WriteEntity(tar)
					net.Send(tar)
				end
			end
		end
	end
end)

net.Receive("EliteParty_PartyRequestAccepted_ToServer", function(len, tar)
	local ply = net.ReadEntity()
	--local tar = net.ReadEntity()
	if ply:IsValid() and ply:IsPlayer() and tar:IsValid() and tar:IsPlayer() then
		if tar:IsInParty() then
			if tar:IsFounderofAny() then
				if not ply:IsInParty() then
					tar:AddMemberToParty(ply)
					ply:UpdateHaloData()
					ply:UpdateRingData()
					ply:PopulatePartyHUD()
					for k, v in pairs(tar:GetPartyInfoByPlayer()["GeneralInformation"].members) do
						for num, mem in pairs(v) do
							net.Start("EliteParty_PartyRequestAccepted_ToClient")
								net.WriteEntity(ply)
								net.WriteEntity(tar)
							net.Send(mem)
						end
					end
				end
			end
		end
	end
end)

net.Receive("EliteParty_KickMember_ToServer", function(len, ply)
	--local ply = net.ReadEntity()
	local tar = net.ReadEntity()
	if ply:IsValid() and ply:IsPlayer() and tar:IsValid() and tar:IsPlayer() then
		if ply:IsInParty() and tar:IsInParty() then
			if ply:IsFounderofAny() then
				tar:RemoveAllRingsAndHolos()
				tar:PopulateOtherPartyHUD()
				ply:KickMemberFromParty(tar)
				ply:UpdateHaloData()
				ply:UpdateRingData()
				for k, v in pairs(ply:GetPartyInfoByPlayer()["GeneralInformation"].members) do
					for num, mem in pairs(v) do
						net.Start("EliteParty_KickedMember_ToClient")
							net.WriteEntity(ply)
							net.WriteEntity(tar)
							net.WriteBool(false)
						net.Send(mem)
					end
				end
				net.Start("EliteParty_KickedMember_ToClient")
					net.WriteEntity(ply)
					net.WriteEntity(tar)
					net.WriteBool(true)
				net.Send(tar)
			end
		end
	end
end)

net.Receive("EliteParty_MakeFounder_ToServer", function(len, ply)
	--local ply = net.ReadEntity()
	local tar = net.ReadEntity()
	if ply:IsValid() and ply:IsPlayer() and tar:IsValid() and tar:IsPlayer() then
		if ply:IsInParty() and tar:IsInParty() then
			if ply:IsFounderofAny() then
				ply:MakeMemberFounder(tar)
				ply:UpdateHaloData()
				tar:UpdateHaloData()
				ply:UpdateRingData()
				tar:UpdateRingData()
				for k, v in pairs(ply:GetPartyInfoByPlayer()["GeneralInformation"].members) do
					for num, mem in pairs(v) do
						net.Start("EliteParty_MakeFounder_ToClient")
							net.WriteEntity(ply)
							net.WriteEntity(tar)
						net.Send(mem)
					end
				end
			end
		end
	end
end)

hook.Add("PlayerDisconnected", "LeaveParty", function(ply)
	if ply:IsInParty() then
		if ply:IsFounderofAny() then
			if #ply:GetAllMembersInParty() <= 1 then
				ply:RemoveAllRingsAndHolos()
				ply:PopulateOtherPartyHUD()
				ply:LeaveAsFounder()
			else
				ply:UpdateHaloDataFromOther()
				ply:UpdateRingDataFromOther()
				ply:RemoveAllRingsAndHolos()
				ply:PopulateOtherPartyHUD()
				ply:LeaveAsFounder()
			end
		else
			ply:UpdateHaloDataFromOther()
			ply:UpdateRingDataFromOther()
			ply:PopulateOtherPartyHUD()
			ply:LeaveParty()
		end
	end
end)

hook.Add("PlayerShouldTakeDamage", "PartyNoDamage", function(ply, att)
	local tbl = ply:GetPartyInfoByPlayer()
	if ply:IsPlayer() and ply:IsValid() and att:IsValid() then
		if att:IsPlayer() then
			if ply:IsInParty() and att:IsInParty() then
				if ply:IsSameParty(att) then
					if tbl["ToggleInformation"].dmg then
						if EliteParty.Debug then
							ElitePartyPrint(Color(10, 150, 255), "They are in the same party and the should not take damage.")
						end
						return false
					else
						if EliteParty.Debug then
							ElitePartyPrint(Color(10, 150, 255), "They are in the same party, but they take damage.")
						end
						return true
					end
				else 
					if EliteParty.Debug then
						ElitePartyPrint(Color(10, 150, 255), "They are not in the same party.")
					end
					return true
				end
			else
				if EliteParty.Debug then
					ElitePartyPrint(Color(10, 150, 255), "One or both of them are not in a party.")
				end
				return true
			end
		elseif att:GetOwner():IsPlayer() then
			if ply:IsInParty() and att:GetOwner():IsInParty() then
				if ply:IsSameParty(att:GetOwner()) then
					if tbl["ToggleInformation"].dmg then

					if EliteParty.Debug then
							ElitePartyPrint(Color(10, 150, 255), "They are in the same party and the should not take damage.")
						end
						return false
					else
						if EliteParty.Debug then
							ElitePartyPrint(Color(10, 150, 255), "They are in the same party, but they take damage.")
						end
						return true
					end
				else 
					if EliteParty.Debug then
						ElitePartyPrint(Color(10, 150, 255), "They are not in the same party.")
					end
					return true
				end
			else
				if EliteParty.Debug then
					ElitePartyPrint(Color(10, 150, 255), "One or both of them are not in a party.")
				end
				return true
			end
		end
	end
end)