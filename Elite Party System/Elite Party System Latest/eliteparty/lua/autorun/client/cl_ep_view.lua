local function MessWithMember(ply, tar, name)
	if !IsValid(FuckWithMember) then 
		local FuckWithMember = vgui.Create( "DFrame" ) 
		FuckWithMember:SetSize( 300, 198 )
		FuckWithMember:Center()
		FuckWithMember:SetTitle( " " ) 
		FuckWithMember:SetVisible( true )
		FuckWithMember:SetDraggable( false ) 
		FuckWithMember:ShowCloseButton( false ) 				
		FuckWithMember:MakePopup() 
		FuckWithMember.Paint = function(self, w, h)
			draw.RoundedBoxEx( 0, 0, 0, w, 45, EliteParty.Color.HeaderLeft, true, true, false, false )
			draw.RoundedBoxEx( 0, 0, 45, w, h-45, EliteParty.Color.MainPage, false, false, true, true )	
		--	draw.SimpleText( EliteParty.Language.PlayerInvite, "ElitePartyMenuTitle", w/2, -1, EliteParty.Color.HeaderText, TEXT_ALIGN_CENTER )
			drawOutline( 0, 44, w, h-44, EliteParty.Color.HeaderLeft )
		end

		local CloseButton = vgui.Create( "DButton", FuckWithMember )
		CloseButton:SetSize( 45, 45 )
		CloseButton:SetPos( FuckWithMember:GetWide() - 45,0 )
		CloseButton:SetText( "X" )
		CloseButton:SetFont( "ElitePartyCloseButton" )
		CloseButton:SetTextColor( EliteParty.Color.CloseButton )
		CloseButton.Paint = function()
			
		end
		CloseButton.DoClick = function()
			if IsValid(FuckWithMember) then
				FuckWithMember:Remove()		
			end			
		end

		local MCategoryCreate = vgui.Create( "DPanel", FuckWithMember )
		MCategoryCreate:SetSize( FuckWithMember:GetWide()-20, FuckWithMember:GetTall()-65 )
		MCategoryCreate:SetPos( 10, 55)
		MCategoryCreate.Paint = function(self, w, h)
			drawOutline( 0, 29, w, h-29, EliteParty.Color.Header )
			--draw.RoundedBox( 1, 0, 30, w-2, h-31, EliteParty.Color.MainPage )
			draw.RoundedBox( 0, 0, 0, w, 30, EliteParty.Color.Header )
			draw.SimpleText( EliteParty.Language.AvailCommands, "ElitePartyPlayerName", 10, 2, EliteParty.Color.HeaderText, TEXT_ALIGN_LEFT )
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

		local tbl = {
			{cmdnam = EliteParty.Language.Kick, fun = function() net.Start("EliteParty_KickMember_ToServer") net.WriteEntity(tar) net.SendToServer() end},
			{cmdnam = EliteParty.Language.MakeFound, fun = function() net.Start("EliteParty_MakeFounder_ToServer") net.WriteEntity(tar) net.SendToServer() end}
		}
		for k, v in pairs(tbl) do
			local PlayerB = vgui.Create( "DPanel" )
			PlayerB:SetSize( PlayerList:GetWide(), 50 )
			PlayerB.Paint = function(self, w, h)
				draw.RoundedBox( 0, 0, 0, w, h, EliteParty.Color.MainPage )
				draw.SimpleText( v.cmdnam, "EliteParty_MiscTitlessub", 10, 12, EliteParty.Color.PlayerTextDark, TEXT_ALIGN_LEFT )
				--DrawSimpleCircle(w-(30+50), h/2, 5, team.GetColor(v:Team()))
				if k != table.Count(tbl) then
					PLDrawRect( 0, h-1, w, 1, EliteParty.Color.ListSeperator )
				end
			end
			local InviteButton = vgui.Create( "DButton", PlayerB )
			InviteButton:SetSize( (GetTextWidth("EliteParty_SubmitButton", EliteParty.Language.Choose)+20), 30 )
			InviteButton:SetPos( PlayerB:GetWide() - (InviteButton:GetWide()+10), 10 )
			InviteButton:SetText( "" )
			InviteButton.Paint = function(self, w, h)
				draw.RoundedBox( 6, 0, 0, w, h, EliteParty.Color.Primary )
				draw.SimpleText( EliteParty.Language.Choose, "EliteParty_SubmitButton", w/2, 0, EliteParty.Color.HeaderText, TEXT_ALIGN_CENTER )
			end
			InviteButton.DoClick = function()
				if ply:IsValid() and ply:IsPlayer() then
					EPRequestBoxMenuOpen(EliteParty.Language.CheckCmd.." "..v.cmdnam, tar:Nick().."?", EliteParty.Language.Yes, function() 
						v.fun()
						FuckWithMember:Remove()
						if IsValid(PartyVCMain) then
							PartyVCMain:AlphaTo(0,EliteParty.AnimSpeed,0, function()
								PartyVCMain:Remove()
								EliteParty.OpenSecondHalf = false
								if not EliteParty.OpenSecondHalf then
									net.Start("EliteParty_ViewParty_ToServer")
									--	net.WriteEntity(ply)
										net.WriteString(name)
									net.SendToServer()
								end
							end)
						end
					end, EliteParty.Language.No, function() return end)
				end		
			end
			PlayerList:Add(PlayerB)
		end
	end
end
net.Receive("EP_ViewMenu_ToClient", function()
	local ply = net.ReadEntity()
	local bool = net.ReadBool()
	local hasparty = net.ReadBool()
	local tbl = net.ReadTable()
	if EliteParty.Debug then
		EPTernary(bool, function() ElitePartyPrint(Color(10, 150, 255),  "You don't seem to be in a party let's make one!") end, function() ElitePartyPrint(Color(10, 150, 255), "Hmmm... You already are in a party. You don't need to make another!") end)
	end
	if IsValid(ELMain) then
		if not EliteParty.OpenSecondHalf then
			if bool then
				EliteParty.OpenSecondHalf = true
				PartyVCMain = vgui.Create( "DPanel", ELMain )
				PartyVCMain:SetAlpha(0)
				PartyVCMain:AlphaTo(255,EliteParty.AnimSpeed,0,function() return end)
				if EliteParty.EnableHalo == true then
					PartyVCMain:SetSize( 655, 660 )
				else
					PartyVCMain:SetSize( 655, 620 )
				end
				PartyVCMain:SetPos( 445, 0 )
				PartyVCMain.Paint = function(self, w, h)
					draw.RoundedBox( 0, 0, 60, w, h, EliteParty.Color.MainPage )
					draw.RoundedBox( 0, 0, 0, w, 60, EliteParty.Color.HeaderLeft )
					draw.SimpleText( EliteParty.Language.CreateNewTitle, "ElitePartyMenuTitle", w/2, 7, EliteParty.Color.HeaderText, TEXT_ALIGN_CENTER )
					draw.SimpleText( EliteParty.Language.HelpText, "ElitePartyHelpText2", w/2, 64, EliteParty.Color.HeaderLeft, TEXT_ALIGN_CENTER )
				end
				PartyVCMain.PartyType = EliteParty.Language.SetTypeText
				PartyVCMain.DamageToggle = false
				PartyVCMain.HaloToggle = false
				PartyVCMain.RingToggle = false

				local CreationScroll = vgui.Create( "DScrollPanel", PartyVCMain )
				CreationScroll:SetSize( PartyVCMain:GetWide()-20, PartyVCMain:GetTall()-95 )
				CreationScroll:SetPos( 10, 85 )
				CreationScroll.Paint = function(self, w, h)
					--draw.RoundedBox( 0, 0, 0, w, h, EliteParty.Color.MainPageBG )
					--draw.RoundedBox( 0, 0, 0, w, h, EliteParty.Color.MainPage )
				end
				CreationScroll.VBar.Paint = function(self, w, h)
				end
				CreationScroll.VBar.btnUp.Paint = function(self, w, h)
				end
				CreationScroll.VBar.btnDown.Paint = function(self, w, h)
				end
				CreationScroll.VBar.btnGrip.Paint = function(self, w, h)	
					draw.RoundedBox( 6, 3, 0, w-3, h, EliteParty.Color.HeaderLeft )
				end
				
				local CreationList = vgui.Create( "DIconLayout", CreationScroll )
				CreationList:SetSize( CreationScroll:GetWide() - 2, CreationScroll:GetTall() )
				CreationList:SetPos( 0, 0 )
				CreationList:SetSpaceX(0)
				CreationList:SetSpaceY(10)

				local GICategoryCreate = vgui.Create( "DPanel" )
				GICategoryCreate:SetSize( CreationList:GetWide(), 80 )
				GICategoryCreate.Paint = function(self, w, h)
					drawOutline( 0, 29, w, h-29, EliteParty.Color.Header )
					--draw.RoundedBox( 0, 0, 30, w, h, EliteParty.Color.MainPage )
					draw.RoundedBox( 0, 0, 0, w, 30, EliteParty.Color.Header )
					draw.SimpleText( EliteParty.Language.GeneralInformation, "ElitePartyPlayerName", 10, 2, EliteParty.Color.HeaderText, TEXT_ALIGN_LEFT )
					draw.SimpleText( EliteParty.Language.Name..":", "EliteParty_MiscTitlessub", 15, 40, EliteParty.Color.HeaderLeft, TEXT_ALIGN_LEFT )
					if EliteParty.EnablePartyTypes then
						draw.SimpleText( EliteParty.Language.Type..":", "EliteParty_MiscTitlessub", GICategoryCreate:GetWide()-(22+165), 40, EliteParty.Color.HeaderLeft, TEXT_ALIGN_RIGHT )
					end
				end

				local NameEntry = vgui.Create( "DTextEntry", GICategoryCreate )
				NameEntry:SetPos(GetTextWidth("EliteParty_MiscTitlessub", EliteParty.Language.Name..":") + 22, 40)
				NameEntry:SetSize(165, 25)
				NameEntry:SetFont("EliteParty_NameEntry")
				NameEntry:SetCursorColor(Color(0, 0, 0))
				NameEntry:SetTextColor(EliteParty.Color.HeaderLeft)

				if EliteParty.EnablePartyTypes then
					PartyType = vgui.Create( "DComboBox", GICategoryCreate )
					PartyType:SetPos( GICategoryCreate:GetWide()-(15+165), 40 )
					PartyType:SetSize( 165, 25 )
					PartyType:SetValue(EliteParty.Language.SetTypeText)
					for k, v in pairs(EliteParty.PartyTypes) do
						PartyType:AddChoice(v)
					end
					PartyType.OnSelect = function( panel, index, value )
						PartyVCMain.PartyType = value
					end
				end
				CreationList:Add(GICategoryCreate)
				local ToggleCategoryCreate = vgui.Create( "DPanel" )
				if EliteParty.EnableHalo == true then
					ToggleCategoryCreate:SetSize( CreationList:GetWide(), 120 )
				else
					ToggleCategoryCreate:SetSize( CreationList:GetWide(), 80 )
				end
				ToggleCategoryCreate.Paint = function(self, w, h)
					drawOutline( 0, 29, w, h-29, EliteParty.Color.Header )
					--draw.RoundedBox( 0, 0, 30, w, h, EliteParty.Color.MainPage )
					draw.RoundedBox( 0, 0, 0, w, 30, EliteParty.Color.Header )
					draw.SimpleText( EliteParty.Language.ToggleInformation, "ElitePartyPlayerName", 10, 2, EliteParty.Color.HeaderText, TEXT_ALIGN_LEFT )
					draw.SimpleText( EliteParty.Language.DamageToggle..":", "EliteParty_MiscTitlessub", 15, 40, EliteParty.Color.HeaderLeft, TEXT_ALIGN_LEFT )
					if EliteParty.EnableHalo == true then
						draw.SimpleText( EliteParty.Language.HaloToggle..":", "EliteParty_MiscTitlessub", w/2-(((GetTextWidth("EliteParty_MiscTitlessub", EliteParty.Language.RingToggle..":") + 14)+80)/2), 80, EliteParty.Color.HeaderLeft, TEXT_ALIGN_LEFT )
					end
					draw.SimpleText( EliteParty.Language.RingToggle..":", "EliteParty_MiscTitlessub", ToggleCategoryCreate:GetWide() - (22+80), 40, EliteParty.Color.HeaderLeft, TEXT_ALIGN_RIGHT)
				end
				local DamageToggle = vgui.Create( "DButton", ToggleCategoryCreate )
				DamageToggle:SetPos( GetTextWidth("EliteParty_MiscTitlessub", EliteParty.Language.DamageToggle..":") + 22, 40 )
				DamageToggle:SetSize( 80, 25 )
				DamageToggle:SetText( "" )
				DamageToggle.Paint = function(self, w, h)
					local x
					if PartyVCMain.DamageToggle then
						x = w/2
					else
						x = 1
					end
					draw.RoundedBox( 0, 0, 0, w/2, h, EliteParty.Color.Header )
					draw.RoundedBox( 0, w/2, 0, w/2, h, EliteParty.Color.Switch2 )
					draw.SimpleText( EliteParty.Language.On, "EliteParty_OnOff", 7, 2, EliteParty.Color.HeaderText, TEXT_ALIGN_LEFT )
					draw.SimpleText( EliteParty.Language.Off, "EliteParty_OnOff", w-4, 2, EliteParty.Color.OffText, TEXT_ALIGN_RIGHT )
					draw.RoundedBox( 0, x, 0, w/2, h, EliteParty.Color.MainPage )
					drawOutline( 0, 0, w, h, EliteParty.Color.HeaderLeft )
				end
				DamageToggle.DoClick = function(self)
					if PartyVCMain.DamageToggle == true then
						PartyVCMain.DamageToggle = false
					else
						PartyVCMain.DamageToggle = true
					end
				end
				local RingToggle = vgui.Create( "DButton", ToggleCategoryCreate )
				RingToggle:SetPos( ToggleCategoryCreate:GetWide() - (15+80), 40 )
				RingToggle:SetSize( 80, 25 )
				RingToggle:SetText( "" )
				RingToggle.toggle = false
				RingToggle.Paint = function(self, w, h)
					local x
					if PartyVCMain.RingToggle then
						x = w/2
					else
						x = 1
					end
					draw.RoundedBox( 0, 0, 0, w/2, h, EliteParty.Color.Header )
					draw.RoundedBox( 0, w/2, 0, w/2, h, EliteParty.Color.Switch2 )
					draw.SimpleText( EliteParty.Language.On, "EliteParty_OnOff", 7, 2, EliteParty.Color.HeaderText, TEXT_ALIGN_LEFT )
					draw.SimpleText( EliteParty.Language.Off, "EliteParty_OnOff", w-4, 2, EliteParty.Color.OffText, TEXT_ALIGN_RIGHT )
					draw.RoundedBox( 0, x, 0, w/2, h, EliteParty.Color.MainPage )
					drawOutline( 0, 0, w, h, EliteParty.Color.HeaderLeft )
				end
				RingToggle.DoClick = function(self)
					if PartyVCMain.RingToggle == true then
						PartyVCMain.RingToggle = false
					else
						PartyVCMain.RingToggle = true
					end
				end
				if EliteParty.EnableHalo == true then
					local HaloToggle = vgui.Create( "DButton", ToggleCategoryCreate )
					HaloToggle:SetPos( ToggleCategoryCreate:GetWide()/2+(((GetTextWidth("EliteParty_MiscTitlessub", EliteParty.Language.RingToggle..":"))-80)/2), 80 )
					HaloToggle:SetSize( 80, 25 )
					HaloToggle:SetText( "" )
					HaloToggle.toggle = false
					HaloToggle.Paint = function(self, w, h)
						local x
						if PartyVCMain.HaloToggle then
							x = w/2
						else
							x = 1
						end
						draw.RoundedBox( 0, 0, 0, w/2, h, EliteParty.Color.Header )
						draw.RoundedBox( 0, w/2, 0, w/2, h, EliteParty.Color.Switch2 )
						draw.SimpleText( EliteParty.Language.On, "EliteParty_OnOff", 7, 2, EliteParty.Color.HeaderText, TEXT_ALIGN_LEFT )
						draw.SimpleText( EliteParty.Language.Off, "EliteParty_OnOff", w-4, 2, EliteParty.Color.OffText, TEXT_ALIGN_RIGHT )
						draw.RoundedBox( 0, x, 0, w/2, h, EliteParty.Color.MainPage )
						drawOutline( 0, 0, w, h, EliteParty.Color.HeaderLeft )
					end
					HaloToggle.DoClick = function(self)
						if PartyVCMain.HaloToggle == true then
							PartyVCMain.HaloToggle = false
						else
							PartyVCMain.HaloToggle = true
						end
					end
				end
				CreationList:Add(ToggleCategoryCreate)
				local ColorCategoryCreate = vgui.Create( "DPanel" )
				ColorCategoryCreate:SetSize( CreationList:GetWide(), 295 )
				ColorCategoryCreate.Paint = function(self, w, h)
					drawOutline( 0, 29, w, h-29, EliteParty.Color.Header )
					--draw.RoundedBox( 0, 0, 30, w, h, EliteParty.Color.MainPage )
					draw.RoundedBox( 0, 0, 0, w, 30, EliteParty.Color.Header )
					draw.SimpleText( EliteParty.Language.ColorInformation, "ElitePartyPlayerName", 10, 2, EliteParty.Color.HeaderText, TEXT_ALIGN_LEFT )
					if EliteParty.EnableHalo == true then
						draw.SimpleText( EliteParty.Language.HaloColor..":", "EliteParty_MiscTitlessub", 315, 40, EliteParty.Color.HeaderLeft, TEXT_ALIGN_LEFT )
					end
					draw.SimpleText( EliteParty.Language.RingColor..":", "EliteParty_MiscTitlessub", 15, 40, EliteParty.Color.HeaderLeft, TEXT_ALIGN_LEFT )
				end
				local HoloColorCube
				if EliteParty.EnableHalo == true then
					HoloColorCube = vgui.Create( "DColorCube", ColorCategoryCreate )
					HoloColorCube:SetPos( 315, 70 )
					HoloColorCube:SetSize( 200, 200 )
					HoloColorCube:SetBaseRGB(Color(255, 0, 0, 255))
					HoloColorCube:SetRGB( Color(255, 255, 255, 255) )	
					local HoloColorPicker = vgui.Create( "DRGBPicker", ColorCategoryCreate )
					HoloColorPicker:SetPos( 520, 70 )
					HoloColorPicker:SetSize( 30, 200 )
					local HoloColorPalleteR = vgui.Create( "DNumberWang", ColorCategoryCreate )
					HoloColorPalleteR:SetPos( 555, 130 )
					HoloColorPalleteR:SetSize( 50, 20 )
					HoloColorPalleteR:SetMin( 0 )
					HoloColorPalleteR:SetMax( 255 )
					HoloColorPalleteR:SetValue(HoloColorCube:GetRGB().r)
					local HoloColorPalleteG = vgui.Create( "DNumberWang", ColorCategoryCreate )
					HoloColorPalleteG:SetPos( 555, 160 )
					HoloColorPalleteG:SetSize( 50, 20 )
					HoloColorPalleteG:SetMin( 0 )
					HoloColorPalleteG:SetMax( 255 )
					HoloColorPalleteG:SetValue(HoloColorCube:GetRGB().g)
					local HoloColorPalleteB = vgui.Create( "DNumberWang", ColorCategoryCreate )
					HoloColorPalleteB:SetPos( 555, 190 )
					HoloColorPalleteB:SetSize( 50, 20 )
					HoloColorPalleteB:SetMin( 0 )
					HoloColorPalleteB:SetMax( 255 )
					HoloColorPalleteB:SetValue(HoloColorCube:GetRGB().b)
					function HoloColorPalleteR:OnValueChanged(num)
						if tonumber(num) >= 0 and tonumber(num) <= 255 then
							local r = tonumber(num)
							local g = tonumber(HoloColorPalleteG:GetValue())
							local b = tonumber(HoloColorPalleteB:GetValue())
							HoloColorCube:SetColor(Color(r, g, b, 255))
							HoloColorPicker:SetRGB(Color(r, g, b, 255))
						end
					end
					function HoloColorPalleteG:OnValueChanged(num)
						if tonumber(num) >= 0 and tonumber(num) <= 255 then
							local r = tonumber(HoloColorPalleteR:GetValue())
							local g = tonumber(num)
							local b = tonumber(HoloColorPalleteB:GetValue())
							HoloColorCube:SetColor(Color(r, g, b, 255))
							HoloColorPicker:SetRGB(Color(r, g, b, 255))
						end
					end
					function HoloColorPalleteB:OnValueChanged(num)
						if tonumber(num) >= 0 and tonumber(num) <= 255 then
							local r = tonumber(HoloColorPalleteR:GetValue())
							local g = tonumber(HoloColorPalleteG:GetValue())
							local b = tonumber(num)
							HoloColorCube:SetColor(Color(r, g, b, 255))
							HoloColorPicker:SetRGB(Color(r, g, b, 255))
						end
					end
					function HoloColorPicker:OnChange( col )
						local h = ColorToHSV( col )
						local _, s, v = ColorToHSV( HoloColorCube:GetRGB() )
						col = HSVToColor( h, s, v )
						HoloColorCube:SetColor( col )
						local colortbl = HoloColorCube:GetRGB()
						HoloColorPalleteR:SetValue(colortbl.r)
						HoloColorPalleteG:SetValue(colortbl.g)
						HoloColorPalleteB:SetValue(colortbl.b)
					end
					function HoloColorCube:OnUserChanged(colortbl)
						HoloColorPalleteR:SetValue(colortbl.r)
						HoloColorPalleteG:SetValue(colortbl.g)
						HoloColorPalleteB:SetValue(colortbl.b)
						HoloColorPicker:SetRGB(Color(colortbl.r, colortbl.g, colortbl.b, 255))
					end
				end
				local RingColorCube = vgui.Create( "DColorCube", ColorCategoryCreate )
				RingColorCube:SetPos( 15, 70 )
				RingColorCube:SetSize( 200, 200 )
				RingColorCube:SetBaseRGB(Color(255, 0, 0, 255))
				RingColorCube:SetRGB( Color(255, 255, 255, 255) )	
				local RingColorPicker = vgui.Create( "DRGBPicker", ColorCategoryCreate )
				RingColorPicker:SetPos( 220, 70 )
				RingColorPicker:SetSize( 30, 200 )
				local RingColorPalleteR = vgui.Create( "DNumberWang", ColorCategoryCreate )
				RingColorPalleteR:SetPos( 255, 130 )
				RingColorPalleteR:SetSize( 50, 20 )
				RingColorPalleteR:SetMin( 0 )
				RingColorPalleteR:SetMax( 255 )
				RingColorPalleteR:SetValue(RingColorCube:GetRGB().r)
				local RingColorPalleteG = vgui.Create( "DNumberWang", ColorCategoryCreate )
				RingColorPalleteG:SetPos( 255, 160 )
				RingColorPalleteG:SetSize( 50, 20 )
				RingColorPalleteG:SetMin( 0 )
				RingColorPalleteG:SetMax( 255 )
				RingColorPalleteG:SetValue(RingColorCube:GetRGB().g)
				local RingColorPalleteB = vgui.Create( "DNumberWang", ColorCategoryCreate )
				RingColorPalleteB:SetPos( 255, 190 )
				RingColorPalleteB:SetSize( 50, 20 )
				RingColorPalleteB:SetMin( 0 )
				RingColorPalleteB:SetMax( 255 )
				RingColorPalleteB:SetValue(RingColorCube:GetRGB().b)
				function RingColorPalleteR:OnValueChanged(num)
					if tonumber(num) >= 0 and tonumber(num) <= 255 then
						local r = tonumber(num)
						local g = tonumber(RingColorPalleteG:GetValue())
						local b = tonumber(RingColorPalleteB:GetValue())
						RingColorCube:SetColor(Color(r, g, b, 255))
						RingColorPicker:SetRGB(Color(r, g, b, 255))
					end
				end
				function RingColorPalleteG:OnValueChanged(num)
					if tonumber(num) >= 0 and tonumber(num) <= 255 then
						local r = tonumber(RingColorPalleteR:GetValue())
						local g = tonumber(num)
						local b = tonumber(RingColorPalleteB:GetValue())
						RingColorCube:SetColor(Color(r, g, b, 255))
						RingColorPicker:SetRGB(Color(r, g, b, 255))
					end
				end
				function RingColorPalleteB:OnValueChanged(num)
					if tonumber(num) >= 0 and tonumber(num) <= 255 then
						local r = tonumber(RingColorPalleteR:GetValue())
						local g = tonumber(RingColorPalleteG:GetValue())
						local b = tonumber(num)
						RingColorCube:SetColor(Color(r, g, b, 255))
						RingColorPicker:SetRGB(Color(r, g, b, 255))
					end
				end
				function RingColorPicker:OnChange( col )
					local h = ColorToHSV( col )
					local _, s, v = ColorToHSV( RingColorCube:GetRGB() )
					col = HSVToColor( h, s, v )
					RingColorCube:SetColor( col )
					local colortbl = RingColorCube:GetRGB()
					RingColorPalleteR:SetValue(colortbl.r)
					RingColorPalleteG:SetValue(colortbl.g)
					RingColorPalleteB:SetValue(colortbl.b)
				end
				function RingColorCube:OnUserChanged(colortbl)
					RingColorPalleteR:SetValue(colortbl.r)
					RingColorPalleteG:SetValue(colortbl.g)
					RingColorPalleteB:SetValue(colortbl.b)
					RingColorPicker:SetRGB(Color(colortbl.r, colortbl.g, colortbl.b, 255))
				end
				CreationList:Add(ColorCategoryCreate)
				local SubmitPanelCreate = vgui.Create( "DPanel" )
				SubmitPanelCreate:SetSize( CreationList:GetWide(), 40 )
				SubmitPanelCreate.Paint = function(self, w, h)
					
				end
				local SubmitButton = vgui.Create( "DButton", SubmitPanelCreate )
				SubmitButton:SetSize( GetTextWidth("EliteParty_SubmitButton", EliteParty.Language.Create)+20, 40 )
				SubmitButton:SetPos( SubmitPanelCreate:GetWide() / 2 - SubmitButton:GetWide() / 2, 0 )
				SubmitButton:SetText( "" )
				SubmitButton.Paint = function(self, w, h)
					draw.RoundedBox( 6, 0, 0, w, h, EliteParty.Color.Primary )
					draw.SimpleText( EliteParty.Language.Create, "EliteParty_SubmitButton", w/2, 5, EliteParty.Color.HeaderText, TEXT_ALIGN_CENTER )
				end
				SubmitButton.DoClick = function()
					local Name = NameEntry:GetValue()
					local Damage = PartyVCMain.DamageToggle
					local Ring = PartyVCMain.RingToggle
					local HaloColor
					local Halo
					if EliteParty.EnableHalo == true then
						HaloColor = HoloColorCube:GetRGB()
						Halo = PartyVCMain.HaloToggle
					else
						HaloColor = Color(255, 255, 255, 255)
						Halo = false
					end
					local RingColor = RingColorCube:GetRGB()
					if not NameNotAlreadyExist(tbl, Name) then
						if Name != "" then
							if NotOnlySpace(Name) then
								if EliteParty.EnablePartyTypes then
									local Type = PartyVCMain.PartyType
									if Type != EliteParty.Language.SetTypeText then
										EPRequestBoxMenuOpen(EliteParty.Language.Passed, EliteParty.Language.PassedTwo.." '"..Name.."'?", EliteParty.Language.Yes, function()
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
											net.Start("EliteParty_CreateParty_ToServer")
												--net.WriteEntity(ply)
												net.WriteString(Name)
												net.WriteString(Type)
												net.WriteBool(Damage)
												net.WriteBool(Halo)
												net.WriteBool(Ring)
												net.WriteTable(HaloColor)
												net.WriteTable(RingColor)
											net.SendToServer()
											if IsValid(PartyVCMain) then
												PartyVCMain:AlphaTo(0,EliteParty.AnimSpeed,0,function() 
													EliteParty.OpenSecondHalf = false
													if IsValid(PartyVCMain) then
														PartyVCMain:Remove()
													end
													if IsValid(EPMainList) then
														EPMainList:Remove()
													end
													ELMain:Remove()
												end)
											end
										end, EliteParty.Language.No, function() return end)
									else
										EPRequestBoxMenuOpen(EliteParty.Language.NoType, "", EliteParty.Language.Ok, function() return end)
									end
								else
									local Type = ""
									EPRequestBoxMenuOpen(EliteParty.Language.Passed, EliteParty.Language.PassedTwo, EliteParty.Language.Yes, function()
										if EliteParty.Debug then
											ElitePartyPrint(Color(10, 150, 255), "\n\n-----------------------------------------------------")
											ElitePartyPrint(Color(10, 150, 255), "Founder = "..ply:Nick())
											ElitePartyPrint(Color(10, 150, 255), "Name = "..Name)
											ElitePartyPrint(Color(10, 150, 255), "Damage = "..Damage)
											ElitePartyPrint(Color(10, 150, 255), "Halo = "..Halo)
											ElitePartyPrint(Color(10, 150, 255), "Ring = "..Ring)
											ElitePartyPrint(Color(10, 150, 255), "Halo Color = "..table.ToString(HaloColor))
											ElitePartyPrint(Color(10, 150, 255), "Ring Color = "..table.ToString(RingColor))
											ElitePartyPrint(Color(10, 150, 255), "Name = "..Name)
											ElitePartyPrint(Color(10, 150, 255), "-----------------------------------------------------\n\n")
										end
										net.Start("EliteParty_CreateParty_ToServer")
											--net.WriteEntity(ply)
											net.WriteString(Name)
											net.WriteString(Type)
											net.WriteBool(Damage)
											net.WriteBool(Halo)
											net.WriteBool(Ring)
											net.WriteTable(HaloColor)
											net.WriteTable(RingColor)
										net.SendToServer()
										PartyVCMain:AlphaTo(0,EliteParty.AnimSpeed,0,function() 
											EliteParty.OpenSecondHalf = false
											if IsValid(PartyVCMain) then
												PartyVCMain:Remove()
											end
											if IsValid(EPMainList) then
												EPMainList:Remove()
											end
											ELMain:Remove()
										end)
									end, EliteParty.Language.No, function() return end)
								end
							else
								EPRequestBoxMenuOpen(EliteParty.Language.OnlySpaces, "", EliteParty.Language.Ok, function() return end)
							end
						else
							EPRequestBoxMenuOpen(EliteParty.Language.NoName, "", EliteParty.Language.Ok, function() return end)
						end
					else
						EPRequestBoxMenuOpen(EliteParty.Language.NameExist, "", EliteParty.Language.Ok, function() return end)
					end
				end
				CreationList:Add(SubmitPanelCreate)
			else
				local function IsMember(tbl, tar)
					for k, v in pairs(tbl["GeneralInformation"].members) do
						for num, mem in pairs(v) do
							if mem == tar then
								return true
							end
						end
					end
					return false
				end
				local function GetSizes(ply, tbl)
					if hasparty and tbl["GeneralInformation"].founder != ply then
						return 655, 615
					else
						return 655, 665
					end
				end
				EliteParty.OpenSecondHalf = true
				PartyVCMain = vgui.Create( "DPanel", ELMain )
				PartyVCMain:SetAlpha(0)
				PartyVCMain:AlphaTo(255,EliteParty.AnimSpeed,0,function() return end)
				PartyVCMain:SetSize( GetSizes(ply, tbl) )
				PartyVCMain:SetPos( 445, 0 )
				local function GetName()
					if string.len(tbl["GeneralInformation"].name) <= 20 then
						return tbl["GeneralInformation"].name
					else
						return string.sub(tbl["GeneralInformation"].name, 1, 17).."..."
					end
				end
				PartyVCMain.Paint = function(self, w, h)
					draw.RoundedBox( 0, 0, 60, w, h, EliteParty.Color.MainPage )
					draw.RoundedBox( 0, 0, 0, w, 60, EliteParty.Color.HeaderLeft )
					draw.SimpleText( EliteParty.Language.PartyViewHeader.." - "..GetName(), "ElitePartyMenuTitle", w/2, 7, EliteParty.Color.HeaderText, TEXT_ALIGN_CENTER )
				end
				PartyVCMain.PartyType = EliteParty.Language.SetTypeText
				PartyVCMain.DamageToggle = false
				PartyVCMain.HaloToggle = false
				PartyVCMain.RingToggle = false

				local CreationScroll = vgui.Create( "DScrollPanel", PartyVCMain )
				CreationScroll:SetSize( PartyVCMain:GetWide()-20, PartyVCMain:GetTall()-85 )
				CreationScroll:SetPos( 10, 75 )
				CreationScroll.Paint = function(self, w, h)
					--draw.RoundedBox( 0, 0, 0, w, h, EliteParty.Color.MainPageBG )
					--draw.RoundedBox( 0, 0, 0, w, h, EliteParty.Color.MainPage )
				end
				CreationScroll.VBar.Paint = function(self, w, h)
				end
				CreationScroll.VBar.btnUp.Paint = function(self, w, h)
				end
				CreationScroll.VBar.btnDown.Paint = function(self, w, h)
				end
				CreationScroll.VBar.btnGrip.Paint = function(self, w, h)	
					draw.RoundedBox( 6, 3, 0, w-3, h, EliteParty.Color.HeaderLeft )
				end
				
				local CreationList = vgui.Create( "DIconLayout", CreationScroll )
				CreationList:SetSize( CreationScroll:GetWide() - 2, CreationScroll:GetTall() )
				CreationList:SetPos( 0, 0 )
				CreationList:SetSpaceX(0)
				CreationList:SetSpaceY(10)

				local function GetFounder(v)
					if v:IsValid() and v:IsPlayer() then
						return tbl["GeneralInformation"].founder:Nick()
					else
						if EliteParty.Debug then
							ElitePartyPrint(Color(10, 150, 255), "The founder does not seem to be active on the server!")
						end
						return "Founder Not Found!"
					end
				end

				local GICategoryCreate = vgui.Create( "DPanel" )
				GICategoryCreate:SetSize( CreationList:GetWide(), 110 )
				GICategoryCreate.Paint = function(self, w, h)
					drawOutline( 0, 29, w, h-29, EliteParty.Color.Header )
					--draw.RoundedBox( 0, 0, 30, w, h, EliteParty.Color.MainPage )
					draw.RoundedBox( 0, 0, 0, w, 30, EliteParty.Color.Header )
					draw.SimpleText( EliteParty.Language.GeneralInformation, "ElitePartyPlayerName", 10, 2, EliteParty.Color.HeaderText, TEXT_ALIGN_LEFT )
					draw.SimpleText( EliteParty.Language.Name..": "..tbl["GeneralInformation"].name, "EliteParty_MiscTitlessub", 15, 40, EliteParty.Color.HeaderLeft, TEXT_ALIGN_LEFT )
					draw.SimpleText( EliteParty.Language.Founder..": "..GetFounder(tbl["GeneralInformation"].founder), "EliteParty_MiscTitlessub", 15, 70, EliteParty.Color.HeaderLeft, TEXT_ALIGN_LEFT )
					if EliteParty.EnablePartyTypes then
						draw.SimpleText( EliteParty.Language.Type..": "..tbl["GeneralInformation"].type, "EliteParty_MiscTitlessub", GICategoryCreate:GetWide()-(15+GetTextWidth("EliteParty_MiscTitlessub", EliteParty.Language.Type..": "..tbl["GeneralInformation"].type)), 40, EliteParty.Color.HeaderLeft, TEXT_ALIGN_LEFT )
						draw.SimpleText( EliteParty.Language.PlayerCount..": "..table.Count(tbl["GeneralInformation"].members).."/"..EliteParty.MaxMembers, "EliteParty_MiscTitlessub", GICategoryCreate:GetWide()-(15+GetTextWidth("EliteParty_MiscTitlessub", EliteParty.Language.Type..": "..tbl["GeneralInformation"].type)), 75, EliteParty.Color.HeaderLeft, TEXT_ALIGN_LEFT )
					else
						draw.SimpleText( EliteParty.Language.PlayerCount..": "..table.Count(tbl["GeneralInformation"].members).."/"..EliteParty.MaxMembers, "EliteParty_MiscTitlessub", GICategoryCreate:GetWide()-(15+GetTextWidth("EliteParty_MiscTitlessub", EliteParty.Language.Type..": "..tbl["GeneralInformation"].type)), 40, EliteParty.Color.HeaderLeft, TEXT_ALIGN_LEFT )
					end
				end
				CreationList:Add(GICategoryCreate)

				local MCategoryCreate = vgui.Create( "DPanel" )
				MCategoryCreate:SetSize( CreationList:GetWide(), 410 )
				MCategoryCreate.Paint = function(self, w, h)
					drawOutline( 0, 29, w, h-29, EliteParty.Color.Header )
					--draw.RoundedBox( 1, 0, 30, w-2, h-31, EliteParty.Color.MainPage )
					draw.RoundedBox( 0, 0, 0, w, 30, EliteParty.Color.Header )
					draw.SimpleText( EliteParty.Language.Members, "ElitePartyPlayerName", 10, 2, EliteParty.Color.HeaderText, TEXT_ALIGN_LEFT )
				end

				local MemberScroll = vgui.Create( "DScrollPanel", MCategoryCreate )
				MemberScroll:SetSize( MCategoryCreate:GetWide()-2, MCategoryCreate:GetTall()-32 )
				MemberScroll:SetPos( 1, 31 )
				MemberScroll.Paint = function(self, w, h)
					--draw.RoundedBox( 0, 0, 0, w, h, EliteParty.Color.MainPageBG )
					--draw.RoundedBox( 0, 0, 0, w, h, EliteParty.Color.MainPage )
				end
				MemberScroll.VBar.Paint = function(self, w, h)
				end
				MemberScroll.VBar.btnUp.Paint = function(self, w, h)
				end
				MemberScroll.VBar.btnDown.Paint = function(self, w, h)
				end
				MemberScroll.VBar.btnGrip.Paint = function(self, w, h)	
					draw.RoundedBox( 6, 3, 0, w-3, h, EliteParty.Color.HeaderLeft )
				end
				
				local MembersList = vgui.Create( "DIconLayout", MemberScroll )
				MembersList:SetSize( MemberScroll:GetWide() - 2, MemberScroll:GetTall() )
				MembersList:SetPos( 0, 0 )
				MembersList:SetSpaceX(0)
				MembersList:SetSpaceY(1)

				local function GetRank(v)
					if tbl["GeneralInformation"].founder == v then
						return "Founder"
					else
						return "Member"
					end
				end

				for num, val in pairs(tbl["GeneralInformation"].members) do
					for k, v in pairs(val) do
						if v:IsValid() and v:IsPlayer() then
							local Member = vgui.Create( "DButton" )
							Member:SetSize( MembersList:GetWide(), 40 )
							Member:SetText( "" )
							Member.Paint = function(self, w, h)
								draw.RoundedBox( 0, 0, 0, w, h, EliteParty.Color.MainPage )
								draw.SimpleText( v:Nick(), "EliteParty_MiscTitlessub", 80, 7, EliteParty.Color.PlayerTextDark, TEXT_ALIGN_LEFT )
								draw.SimpleText( GetRank(v), "EliteParty_MiscTitlessub", w/2, 7, EliteParty.Color.PlayerTextDark, TEXT_ALIGN_CENTER )
								draw.SimpleText( team.GetName(v:Team()), "EliteParty_MiscTitlessub", w-(45+50), 7, EliteParty.Color.PlayerTextDark, TEXT_ALIGN_RIGHT )
								DrawSimpleCircle(w-(30+50), h/2, 5, team.GetColor(v:Team()))
								/*if k != #tbl then
									PLDrawRect( 0, h-1, w, 1, EliteParty.Color.ListSeperator )
								end*/
								PLDrawRect( 0, h-1, w, 1, EliteParty.Color.ListSeperator )
							end
							Member:SetDisabled(true)
							if ply:CheckFounderFromTBL(tbl) then
								Member:SetDisabled(false)
							end
							Member.DoClick = function(self)
								if tbl["GeneralInformation"].founder == ply then
									if ply:IsValid() and ply:IsPlayer() and v:IsValid() and v:IsPlayer() and v != ply then
										MessWithMember(ply, v, tbl["GeneralInformation"].name)
									end
								end
							end

							local avatar = vgui.Create( "AvatarImage", Member ) 
							avatar:SetSize( 30, 30 )
							avatar:SetPlayer(v, 128)
							avatar:SetPos(10, 5)
							function avatar:PaintOver(w, h)
								StencilStart()
								DrawCircle(w/2, h/2, w/2, 1, Color(0,0,0,1))
								StencilReplace()
								surface.SetDrawColor(EliteParty.Color.MainPage)
								surface.DrawRect(0, 0, w, h)
								StencilEnd()
							end
							function avatar:Think() 
								avatar:SetPos(10, 5)
							end
							MembersList:Add(Member)
						else
							if EliteParty.Debug then
								ElitePartyPrint(Color(10, 150, 255), "The player does not seem to be active on the server!")
							end
						end
					end
				end
				CreationList:Add(MCategoryCreate)
				if tbl["GeneralInformation"].founder == ply then
					local EditPanelSettings = vgui.Create( "DPanel" )
					EditPanelSettings:SetSize( CreationList:GetWide(), 40 )
					EditPanelSettings.Paint = function(self, w, h)
						
					end
					local InviteButton = vgui.Create( "DButton", EditPanelSettings )
					InviteButton:SetSize( GetTextWidth("EliteParty_SubmitButton", EliteParty.Language.EditSettings)+40, 40 )
					InviteButton:SetPos( EditPanelSettings:GetWide() / 2 - (InviteButton:GetWide() + 7), 0 )
					InviteButton:SetText( "" )
					InviteButton.Paint = function(self, w, h)
						draw.RoundedBox( 6, 0, 0, w, h, EliteParty.Color.Header )
						draw.SimpleText( EliteParty.Language.Invite, "EliteParty_SubmitButton", w/2, 5, EliteParty.Color.HeaderText, TEXT_ALIGN_CENTER )
					end
					InviteButton.DoClick = function()
						net.Start("EliteParty_RequestInviteList_ToServer")
							--net.WriteEntity(ply)
							net.WriteTable(tbl)
						net.SendToServer()
					end
					local EditButton = vgui.Create( "DButton", EditPanelSettings )
					EditButton:SetSize( GetTextWidth("EliteParty_SubmitButton", EliteParty.Language.EditSettings)+40, 40 )
					EditButton:SetPos( EditPanelSettings:GetWide() / 2 + 7, 0 )
					EditButton:SetText( "" )
					EditButton.Paint = function(self, w, h)
						draw.RoundedBox( 6, 0, 0, w, h, EliteParty.Color.Primary )
						draw.SimpleText( EliteParty.Language.EditSettings, "EliteParty_SubmitButton", w/2, 5, EliteParty.Color.HeaderText, TEXT_ALIGN_CENTER )
					end
					EditButton.DoClick = function()
						if IsValid(PartyVCMain) then
							PartyVCMain:AlphaTo(0,EliteParty.AnimSpeed,0, function()
								if IsValid(PartyVCMain) then
									PartyVCMain:Remove()
								end
								OpenSettingsParty(tbl, ply, tbl["GeneralInformation"].name)
							end)
						end
					end
					CreationList:Add(EditPanelSettings)
				end
				if not IsMember(tbl, ply) then
					local EditPanelSettings = vgui.Create( "DPanel" )
					EditPanelSettings:SetSize( CreationList:GetWide(), 40 )
					EditPanelSettings.Paint = function(self, w, h)
						
					end
					local InviteButton = vgui.Create( "DButton", EditPanelSettings )
					InviteButton:SetSize( GetTextWidth("EliteParty_SubmitButton", EliteParty.Language.RequestJoin)+40, 40 )
					InviteButton:SetPos( EditPanelSettings:GetWide() / 2 - (InviteButton:GetWide()/2), 0 )
					InviteButton:SetText( "" )
					InviteButton.Paint = function(self, w, h)
						draw.RoundedBox( 6, 0, 0, w, h, EliteParty.Color.Header )
						draw.SimpleText( EliteParty.Language.RequestJoin, "EliteParty_SubmitButton", w/2, 5, EliteParty.Color.HeaderText, TEXT_ALIGN_CENTER )
					end
					InviteButton.DoClick = function()
						if ply:IsValid() and ply:IsPlayer() and tbl["GeneralInformation"].founder:IsValid() and tbl["GeneralInformation"].founder:IsPlayer() then
							net.Start("EliteParty_RequestJoin_ToServer")
							--	net.WriteEntity(ply)
								net.WriteEntity(tbl["GeneralInformation"].founder)
							net.SendToServer()
							EPRequestBoxMenuOpen(EliteParty.Language.RequestComp, EliteParty.Language.RequestComp2..".", EliteParty.Language.Ok, function() return end)
						end
					end
					CreationList:Add(EditPanelSettings)
				end
			end
		end
	end
end)
