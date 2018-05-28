net.Receive("EliteParty_RequestInviteList_ToClient", function()
	local ply = net.ReadEntity()
	local tbl = net.ReadTable()
	local tbltwo = net.ReadTable()
	if !IsValid(EPInvite) then 
		local EPInvite = vgui.Create( "DFrame" ) 
		EPInvite:SetSize( 600, 450 )
		EPInvite:Center()
		EPInvite:SetTitle( " " ) 
		EPInvite:SetVisible( true )
		EPInvite:SetDraggable( false ) 
		EPInvite:ShowCloseButton( false ) 				
		EPInvite:MakePopup() 
		EPInvite.Paint = function(self, w, h)
			draw.RoundedBoxEx( 0, 0, 0, w, 45, EliteParty.Color.HeaderLeft, true, true, false, false )
			draw.RoundedBoxEx( 0, 0, 45, w, h-45, EliteParty.Color.MainPage, false, false, true, true )	
			draw.SimpleText( EliteParty.Language.PlayerInvite, "ElitePartyMenuTitle", w/2, -1, EliteParty.Color.HeaderText, TEXT_ALIGN_CENTER )
			drawOutline( 0, 44, w, h-44, EliteParty.Color.HeaderLeft )
		end

		local CloseButton = vgui.Create( "DButton", EPInvite )
		CloseButton:SetSize( 45, 45 )
		CloseButton:SetPos( EPInvite:GetWide() - 45,0 )
		CloseButton:SetText( "X" )
		CloseButton:SetFont( "ElitePartyCloseButton" )
		CloseButton:SetTextColor( EliteParty.Color.CloseButton )
		CloseButton.Paint = function()
			
		end
		CloseButton.DoClick = function()
			if IsValid(EPInvite) then
				EPInvite:Remove()		
			end	
			if IsValid(PartyVCMain) then
				PartyVCMain:AlphaTo(0,EliteParty.AnimSpeed,0, function()
					PartyVCMain:Remove()
					EliteParty.OpenSecondHalf = false
					if not EliteParty.OpenSecondHalf then
						net.Start("EliteParty_ViewParty_ToServer")
							--net.WriteEntity(ply)
							net.WriteString(tbltwo["GeneralInformation"].name)
						net.SendToServer()
					end
				end)
			end		
		end

		local MCategoryCreate = vgui.Create( "DPanel", EPInvite )
		MCategoryCreate:SetSize( EPInvite:GetWide()-20, EPInvite:GetTall()-65 )
		MCategoryCreate:SetPos( 10, 55)
		MCategoryCreate.Paint = function(self, w, h)
			drawOutline( 0, 29, w, h-29, EliteParty.Color.Header )
			--draw.RoundedBox( 1, 0, 30, w-2, h-31, EliteParty.Color.MainPage )
			draw.RoundedBox( 0, 0, 0, w, 30, EliteParty.Color.Header )
			draw.SimpleText( EliteParty.Language.PlayersAvail, "ElitePartyPlayerName", 10, 2, EliteParty.Color.HeaderText, TEXT_ALIGN_LEFT )
		end
		
		local PlayerScroll = vgui.Create( "DScrollPanel", MCategoryCreate )
		PlayerScroll:SetSize( MCategoryCreate:GetWide()-2, MCategoryCreate:GetTall()-1 )
		PlayerScroll:SetPos( 1, 30 )
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
		PlayerList:SetSpaceY(1)

		for k, v in pairs(tbl) do
			if v:IsValid() and v:IsPlayer() then
				local PlayerB = vgui.Create( "DPanel" )
				PlayerB:SetSize( PlayerList:GetWide(), 50 )
				PlayerB.Paint = function(self, w, h)
					draw.RoundedBox( 0, 0, 0, w, h, EliteParty.Color.MainPage )
					draw.SimpleText( v:Nick(), "EliteParty_MiscTitlessub", 65, 12, EliteParty.Color.PlayerTextDark, TEXT_ALIGN_LEFT )
					draw.SimpleText( team.GetName(v:Team()), "EliteParty_MiscTitlessub", w/2, 12, EliteParty.Color.PlayerTextDark, TEXT_ALIGN_LEFT )
					--DrawSimpleCircle(w-(30+50), h/2, 5, team.GetColor(v:Team()))
					--if k != #tbl then
						PLDrawRect( 0, h-1, w, 1, EliteParty.Color.ListSeperator )
					--end
				end
				local avatar = vgui.Create( "AvatarImage", PlayerB ) 
				avatar:SetSize( 40, 40 )
				avatar:SetPlayer(v, 128)
				avatar:SetPos(5, 5)
				function avatar:PaintOver(w, h)
					StencilStart()
					DrawCircle(w/2, h/2, w/2, 1, Color(0,0,0,1))
					StencilReplace()
					surface.SetDrawColor(EliteParty.Color.MainPage)
					surface.DrawRect(0, 0, w, h)
					StencilEnd()
				end
				function avatar:Think() 
					avatar:SetPos(5, 5)
				end

				local InviteButton = vgui.Create( "DButton", PlayerB )
				InviteButton:SetSize( (GetTextWidth("EliteParty_SubmitButton", EliteParty.Language.Invite)+20), 30 )
				InviteButton:SetPos( PlayerB:GetWide() - (InviteButton:GetWide()+10), 10 )
				InviteButton:SetText( "" )
				InviteButton.Paint = function(self, w, h)
					draw.RoundedBox( 6, 0, 0, w, h, EliteParty.Color.Primary )
					draw.SimpleText( EliteParty.Language.Invite, "EliteParty_SubmitButton", w/2, 0, EliteParty.Color.HeaderText, TEXT_ALIGN_CENTER )
				end
				InviteButton.DoClick = function()
					if ply:IsValid() and ply:IsPlayer() then
						net.Start("EliteParty_InvitePlayer_ToServer")
							--net.WriteEntity(ply)
							net.WriteEntity(v)
						net.SendToServer()
						EPRequestBoxMenuOpen(EliteParty.Language.InviteComp, EliteParty.Language.InviteComp2..".", EliteParty.Language.Ok, function() return end)
					end		
				end
				PlayerList:Add(PlayerB)
			end
		end
		if table.Count(tbl) < 1 then
			local PlayerB = vgui.Create( "DPanel" )
			PlayerB:SetSize( PlayerList:GetWide(), 50 )
			PlayerB.Paint = function(self, w, h)
				draw.RoundedBox( 0, 0, 0, w, h, EliteParty.Color.MainPage )
				draw.SimpleText( EliteParty.Language.NoAvPlay..".", "EliteParty_MiscTitlessub", w/2, 12, EliteParty.Color.PlayerTextDark, TEXT_ALIGN_CENTER )
				--if k != #tbl then
					PLDrawRect( 0, h-1, w, 1, EliteParty.Color.ListSeperator )
				--end
			end
			PlayerList:Add(PlayerB)
		end
	end
end)

net.Receive("EliteParty_InvitePlayer_ToClient", function()
	local ply = net.ReadEntity()
	local tar = net.ReadEntity()
	local name = net.ReadString()
	local InviteNotification = vgui.Create( "DNotify" )
	if (GetTextWidth("EliteParty_InviteNotiText", ply:Nick().." "..EliteParty.Language.SomeoneInvite..".")+20) > 315 then
		InviteNotification:SetSize(GetTextWidth("EliteParty_InviteNotiText", ply:Nick().." "..EliteParty.Language.SomeoneInvite..".")+20, 120)
	else
		InviteNotification:SetSize(315, 120)
	end
	InviteNotification:SetPos(ScrW()-(InviteNotification:GetWide()+5), ScrH())
	InviteNotification:MoveTo( ScrW()-(InviteNotification:GetWide()+5), ScrH()-(InviteNotification:GetTall()+5), EliteParty.AnimSpeed, 0, -1, function() return end )
	InviteNotification:SetLife(EliteParty.InviteTimer)
	local bg = vgui.Create( "DPanel", InviteNotification )
	bg:Dock( FILL )
	local function GetLocalTime()
		if timer.Exists("TimerBeforeInviteClose") then
			return math.Round(timer.TimeLeft("TimerBeforeInviteClose"))
		else
			return "0"
		end
	end
	bg.Paint = function(self, w, h)
		draw.RoundedBoxEx( 0, 0, 0, w, 30, EliteParty.Color.HeaderLeft, true, true, false, false )
		draw.RoundedBoxEx( 0, 0, 30, w, h-30, EliteParty.Color.MainPage, false, false, true, true )	
		draw.SimpleText( EliteParty.Language.PlayerInvite, "ElitePartyPlayerName", w/2, 2, EliteParty.Color.HeaderText, TEXT_ALIGN_CENTER )
		drawOutline( 0, 29, w, h-29, EliteParty.Color.HeaderLeft )
		draw.SimpleText( ply:Nick().." "..EliteParty.Language.SomeoneInvite..".", "EliteParty_InviteNotiText", w/2, 35, EliteParty.Color.HeaderLeft, TEXT_ALIGN_CENTER )
		draw.SimpleText( EliteParty.Language.LikeAccept.."?", "EliteParty_InviteNotiText", w/2, 55, EliteParty.Color.HeaderLeft, TEXT_ALIGN_CENTER )
		draw.SimpleText( GetLocalTime(), "EliteParty_InviteNotiButton", w/2, h-28, EliteParty.Color.HeaderLeft, TEXT_ALIGN_CENTER )
	end
	timer.Create("TimerBeforeInviteClose", EliteParty.InviteTimer, 1, function()
		timer.Remove("TimerBeforeInviteClose")
	end)
	timer.Simple(EliteParty.InviteTimer, function()
		if IsValid(InviteNotification) then
			InviteNotification:MoveTo( ScrW()-(InviteNotification:GetWide()+5), ScrH(), EliteParty.AnimSpeed, 0, -1, function()
				InviteNotification:Remove()
			end)
		end
	end)
	local JoinButton = vgui.Create( "DButton", InviteNotification )
	JoinButton:SetSize( 50, 25 )
	JoinButton:SetPos( InviteNotification:GetWide()/2 - (JoinButton:GetWide()+25), InviteNotification:GetTall()-(JoinButton:GetTall()+5) )
	JoinButton:SetText( "" )
	JoinButton.Paint = function(self, w, h)
		draw.RoundedBox( 6, 0, 0, w, h, EliteParty.Color.Primary )
		draw.SimpleText( EliteParty.Language.Yes, "EliteParty_InviteNotiButton", w/2, 2, EliteParty.Color.HeaderText, TEXT_ALIGN_CENTER )
	end
	JoinButton.DoClick = function()
		if tar:IsValid() and tar:IsPlayer() and ply:IsPlayer() and ply:IsValid() then
			net.Start("EliteParty_PartyInvitedAccepted_ToServer")
				net.WriteEntity(ply)
				--net.WriteEntity(tar)
			net.SendToServer()
			if IsValid(InviteNotification) then
				InviteNotification:MoveTo( ScrW()-(InviteNotification:GetWide()+5), ScrH(), EliteParty.AnimSpeed, 0, -1, function()
					InviteNotification:Remove()
				end)
			end
		end	
	end
	local DeclineButton = vgui.Create( "DButton", InviteNotification )
	DeclineButton:SetSize( 50, 25 )
	DeclineButton:SetPos( InviteNotification:GetWide()/2 +25, InviteNotification:GetTall()-(DeclineButton:GetTall()+5) )
	DeclineButton:SetText( "" )
	DeclineButton.Paint = function(self, w, h)
		draw.RoundedBox( 6, 0, 0, w, h, EliteParty.Color.Primary )
		draw.SimpleText( EliteParty.Language.No, "EliteParty_InviteNotiButton", w/2, 2, EliteParty.Color.HeaderText, TEXT_ALIGN_CENTER )
	end
	DeclineButton.DoClick = function()
		if IsValid(InviteNotification) then
			InviteNotification:MoveTo( ScrW()-(InviteNotification:GetWide()+5), ScrH(), EliteParty.AnimSpeed, 0, -1, function()
				InviteNotification:Remove()
			end)
		end		
	end
end)

net.Receive("EliteParty_RequestJoin_ToClient", function()
	local ply = net.ReadEntity()
	local tar = net.ReadEntity()
	local InviteNotification = vgui.Create( "DNotify" )
	if (GetTextWidth("EliteParty_InviteNotiText", ply:Nick().." "..EliteParty.Language.SomeoneInvite..".")+20) > 315 then
		InviteNotification:SetSize(GetTextWidth("EliteParty_InviteNotiText", ply:Nick().." "..EliteParty.Language.SomeoneInvite..".")+20, 120)
	else
		InviteNotification:SetSize(315, 120)
	end
	InviteNotification:SetPos(ScrW()-(InviteNotification:GetWide()+5), ScrH())
	InviteNotification:MoveTo( ScrW()-(InviteNotification:GetWide()+5), ScrH()-(InviteNotification:GetTall()+5), EliteParty.AnimSpeed, 0, -1, function() return end )
	InviteNotification:SetLife(EliteParty.InviteTimer)
	local bg = vgui.Create( "DPanel", InviteNotification )
	bg:Dock( FILL )
	local function GetLocalTime()
		if timer.Exists("TimerBeforeInviteClose") then
			return math.Round(timer.TimeLeft("TimerBeforeInviteClose"))
		else
			return "0"
		end
	end
	bg.Paint = function(self, w, h)
		draw.RoundedBoxEx( 0, 0, 0, w, 30, EliteParty.Color.HeaderLeft, true, true, false, false )
		draw.RoundedBoxEx( 0, 0, 30, w, h-30, EliteParty.Color.MainPage, false, false, true, true )	
		draw.SimpleText( EliteParty.Language.PlayerInvite, "ElitePartyPlayerName", w/2, 2, EliteParty.Color.HeaderText, TEXT_ALIGN_CENTER )
		drawOutline( 0, 29, w, h-29, EliteParty.Color.HeaderLeft )
		draw.SimpleText( ply:Nick().." "..EliteParty.Language.Requested..".", "EliteParty_InviteNotiText", w/2, 35, EliteParty.Color.HeaderLeft, TEXT_ALIGN_CENTER )
		draw.SimpleText( EliteParty.Language.RequestAccept.."?", "EliteParty_InviteNotiText", w/2, 55, EliteParty.Color.HeaderLeft, TEXT_ALIGN_CENTER )
		draw.SimpleText( GetLocalTime(), "EliteParty_InviteNotiButton", w/2, h-28, EliteParty.Color.HeaderLeft, TEXT_ALIGN_CENTER )
	end
	timer.Create("TimerBeforeInviteClose", EliteParty.InviteTimer, 1, function()
		timer.Remove("TimerBeforeInviteClose")
	end)
	timer.Simple(EliteParty.InviteTimer, function()
		if IsValid(InviteNotification) then
			InviteNotification:MoveTo( ScrW()-(InviteNotification:GetWide()+5), ScrH(), EliteParty.AnimSpeed, 0, -1, function()
				InviteNotification:Remove()
			end)
		end
	end)
	local JoinButton = vgui.Create( "DButton", InviteNotification )
	JoinButton:SetSize( 50, 25 )
	JoinButton:SetPos( InviteNotification:GetWide()/2 - (JoinButton:GetWide()+25), InviteNotification:GetTall()-(JoinButton:GetTall()+5) )
	JoinButton:SetText( "" )
	JoinButton.Paint = function(self, w, h)
		draw.RoundedBox( 6, 0, 0, w, h, EliteParty.Color.Primary )
		draw.SimpleText( EliteParty.Language.Yes, "EliteParty_InviteNotiButton", w/2, 2, EliteParty.Color.HeaderText, TEXT_ALIGN_CENTER )
	end
	JoinButton.DoClick = function()
		if tar:IsValid() and tar:IsPlayer() and ply:IsPlayer() and ply:IsValid() then
			net.Start("EliteParty_PartyRequestAccepted_ToServer")
				net.WriteEntity(ply)
				--net.WriteEntity(tar)
			net.SendToServer()
			if IsValid(InviteNotification) then
				InviteNotification:MoveTo( ScrW()-(InviteNotification:GetWide()+5), ScrH(), EliteParty.AnimSpeed, 0, -1, function()
					InviteNotification:Remove()
				end)
			end
		end	
	end
	local DeclineButton = vgui.Create( "DButton", InviteNotification )
	DeclineButton:SetSize( 50, 25 )
	DeclineButton:SetPos( InviteNotification:GetWide()/2 +25, InviteNotification:GetTall()-(DeclineButton:GetTall()+5) )
	DeclineButton:SetText( "" )
	DeclineButton.Paint = function(self, w, h)
		draw.RoundedBox( 6, 0, 0, w, h, EliteParty.Color.Primary )
		draw.SimpleText( EliteParty.Language.No, "EliteParty_InviteNotiButton", w/2, 2, EliteParty.Color.HeaderText, TEXT_ALIGN_CENTER )
	end
	DeclineButton.DoClick = function()
		if IsValid(InviteNotification) then
			InviteNotification:MoveTo( ScrW()-(InviteNotification:GetWide()+5), ScrH(), EliteParty.AnimSpeed, 0, -1, function()
				InviteNotification:Remove()
			end)
		end		
	end
end)