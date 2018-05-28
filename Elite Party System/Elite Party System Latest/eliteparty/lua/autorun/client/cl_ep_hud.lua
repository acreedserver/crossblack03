local playerlist = {}
local PHUDMain
local function DoOnscreenShit(tbl, fd)
	if EliteParty.Debug then
		ElitePartyPrint(Color(10, 150, 255), "You have called the DoOnscreenShit function.")
	end
	if not IsValid(PHUDMain) then
		PHUDMain = vgui.Create( "DPanel" )
		if ((table.Count(tbl)*75) + ((table.Count(tbl) - 1)*10)) >= (ScrH() * EliteParty.HUDSize) then
			PHUDMain:SetSize( 190, ScrH() * EliteParty.HUDSize )
		else
			PHUDMain:SetSize( 190, ((table.Count(tbl)*75) + ((table.Count(tbl) - 1)*10)) )
		end
		PHUDMain:SetPos( 5, 5 )
		PHUDMain:SetAlpha(0)
		PHUDMain:AlphaTo(255,EliteParty.AnimSpeed,0,function() return end)
		PHUDMain.Paint = function(self, w, h)
			--draw.RoundedBox( 0, 86, 0, w-40, 60, EliteParty.Color.Header )
			--draw.RoundedBox( 0, 0, 0, 86, 60, EliteParty.Color.HeaderLeft )
		end
		
		local PlayerScroll = vgui.Create( "DScrollPanel", PHUDMain )
		PlayerScroll:SetSize( PHUDMain:GetWide(), PHUDMain:GetTall() )
		PlayerScroll:SetPos( 0, 0 )
		PlayerScroll.Paint = function(self, w, h)
			--draw.RoundedBox( 0, 0, 0, w, h, EliteParty.Color.MainPageBG )
			--draw.RoundedBox( 0, 0, 0, w, h, EliteParty.Color.MainPage )
		end
		PlayerScroll.VBar.Paint = function(self, w, h)
		end
		PlayerScroll.VBar.btnUp.Paint = function(self, w, h)
		end
		PlayerScroll.VBar.btnDown.Paint = function(self, w, h)
		end
		PlayerScroll.VBar.btnGrip.Paint = function(self, w, h)	
			draw.RoundedBox( 6, 3, 0, w-3, h, EliteParty.Color.HeaderLeft )
		end
		
		local PlayerList = vgui.Create( "DIconLayout", PlayerScroll )
		PlayerList:SetSize( PlayerScroll:GetWide() - 2, PlayerScroll:GetTall() )
		PlayerList:SetPos( 0, 0 )
		PlayerList:SetSpaceX(0)
		PlayerList:SetSpaceY(10)

		local function GetRank(v)
			if v == fd then
				return "Founder"
			else
				return "Member"
			end
		end

		for k, v in pairs(tbl) do
			if v:IsValid() and v:IsPlayer() then
				local PInfo = vgui.Create( "DPanel" )
				PInfo:SetSize( 170, 75 )
				PInfo:SetPos( 5, 5 )
				PInfo.Paint = function(self, w, h)
					if v:IsValid() and v:IsPlayer() then
						draw.RoundedBox( 0, 0, 0, w, h, EliteParty.Color.MainPage )
						draw.RoundedBox( 0, 0, 0, w, 30, EliteParty.Color.HeaderLeft )
						drawOutline( 0, 29, w, h-29, EliteParty.Color.HeaderLeft )
						draw.SimpleText( v:Nick(), "ElitePartyPlayerName", 10, 2, EliteParty.Color.HeaderText, TEXT_ALIGN_LEFT )
						draw.SimpleText( GetRank(v), "EliteParty_SmallWindowText", 10, 35, EliteParty.Color.HeaderLeft, TEXT_ALIGN_LEFT )
						draw.SimpleText( team.GetName(v:Team()), "EliteParty_SmallWindowText", w-10, 35, team.GetColor(v:Team()), TEXT_ALIGN_RIGHT )
						draw.RoundedBox( 0, 10, h-20, 150, 15, Color(70, 70, 70, 255) )
						draw.RoundedBox( 0, 10, h-20, math.Clamp(v:Health()*1.5, 0, 150), 15, Color(255, 0, 0, 255) )
						draw.SimpleText( v:Health().."%", "EliteParty_SmallWindowText", w/2, h-20, EliteParty.Color.Header, TEXT_ALIGN_CENTER )
					end
				end
				PlayerList:Add(PInfo)
			end
		end
	else
		PHUDMain:Remove()
		DoOnscreenShit(tbl)
	end
end

local function Repopulate()
	if EliteParty.Debug then
		ElitePartyPrint(Color(10, 150, 255), "You have called the repopulate function.")
	end
	local tbl = net.ReadTable()
	local fd = net.ReadEntity()
	if IsValid(PHUDMain) then
		PHUDMain:Remove()
	end
	DoOnscreenShit(tbl, fd)
end
net.Receive("EliteParty_PopulateHUD_ToClient", Repopulate)
net.Receive("EliteParty_RemovePopulateHUD_ToClient", function() if IsValid(PHUDMain) then PHUDMain:Remove() end end)