function OpenSettingsParty(tbl, ply)
	if IsValid(ELMain) then
		if not IsValid(PartyVCMain) then
			PartyVCMain = vgui.Create( "DPanel", ELMain )
			PartyVCMain:SetAlpha(0)
			PartyVCMain:AlphaTo(255,EliteParty.AnimSpeed,0,function() return end)
			PartyVCMain:SetSize( 655, 665 )
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
				draw.SimpleText( EliteParty.Language.EditingPartyTitle.." - "..GetName(), "ElitePartyMenuTitle", w/2, 7, EliteParty.Color.HeaderText, TEXT_ALIGN_CENTER )
				--draw.SimpleText( EliteParty.Language.HelpText, "ElitePartyHelpText2", w/2, 64, EliteParty.Color.HeaderLeft, TEXT_ALIGN_CENTER )
			end
			PartyVCMain.PartyType = tbl["GeneralInformation"].type
			PartyVCMain.DamageToggle = tbl["ToggleInformation"].dmg
			PartyVCMain.HaloToggle = tbl["ToggleInformation"].halo
			PartyVCMain.RingToggle = tbl["ToggleInformation"].ring

			local CreationScroll = vgui.Create( "DScrollPanel", PartyVCMain )
			CreationScroll:SetSize( PartyVCMain:GetWide()-20, PartyVCMain:GetTall()-100 )
			CreationScroll:SetPos( 10, 90 )
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
			NameEntry:SetText(tbl["GeneralInformation"].name)
			NameEntry:SetCursorColor(Color(0, 0, 0))
			NameEntry:SetTextColor(EliteParty.Color.HeaderLeft)
			NameEntry:AllowInput(false)
			NameEntry:SetDisabled(true)
			NameEntry:SetEditable(false)

			if EliteParty.EnablePartyTypes then
				PartyType = vgui.Create( "DComboBox", GICategoryCreate )
				PartyType:SetPos( GICategoryCreate:GetWide()-(15+165), 40 )
				PartyType:SetSize( 165, 25 )
				PartyType:SetValue(tbl["GeneralInformation"].type)
				for k, v in pairs(EliteParty.PartyTypes) do
					PartyType:AddChoice(v)
				end
				PartyType.OnSelect = function( panel, index, value )
					PartyVCMain.PartyType = value
				end
			end
			CreationList:Add(GICategoryCreate)
			local ToggleCategoryCreate = vgui.Create( "DPanel" )
			ToggleCategoryCreate:SetSize( CreationList:GetWide(), 120 )
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
				HoloColorCube:SetRGB( Color(tbl["ColorInformation"].hcolor["r"], tbl["ColorInformation"].hcolor["g"], tbl["ColorInformation"].hcolor["b"]) )	
				local HoloColorPicker = vgui.Create( "DRGBPicker", ColorCategoryCreate )
				HoloColorPicker:SetPos( 520, 70 )
				HoloColorPicker:SetSize( 30, 200 )
				HoloColorPicker:SetRGB( Color(tbl["ColorInformation"].hcolor["r"], tbl["ColorInformation"].hcolor["g"], tbl["ColorInformation"].hcolor["b"]) )
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
			RingColorCube:SetRGB( Color(tbl["ColorInformation"].rcolor["r"], tbl["ColorInformation"].rcolor["g"], tbl["ColorInformation"].rcolor["b"]) )	
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
			local BackButton = vgui.Create( "DButton", SubmitPanelCreate )
			BackButton:SetSize( GetTextWidth("EliteParty_SubmitButton", EliteParty.Language.SubmitChanges)+20, 40 )
			BackButton:SetPos( SubmitPanelCreate:GetWide() / 2 - (BackButton:GetWide()+7), 0 )
			BackButton:SetText( "" )
			BackButton.Paint = function(self, w, h)
				draw.RoundedBox( 6, 0, 0, w, h, EliteParty.Color.Header )
				draw.SimpleText( EliteParty.Language.Back, "EliteParty_SubmitButton", w/2, 5, EliteParty.Color.HeaderText, TEXT_ALIGN_CENTER )
			end
			BackButton.DoClick = function()
				if IsValid(PartyVCMain) then
					PartyVCMain:AlphaTo(0,EliteParty.AnimSpeed,0, function()
						PartyVCMain:Remove()
						EliteParty.OpenSecondHalf = false
						if not EliteParty.OpenSecondHalf then
							net.Start("EliteParty_ViewParty_ToServer")
								--net.WriteEntity(ply)
								net.WriteString(tbl["GeneralInformation"].name)
							net.SendToServer()
						end
					end)
				end
			end
			local SubmitButton = vgui.Create( "DButton", SubmitPanelCreate )
			SubmitButton:SetSize( GetTextWidth("EliteParty_SubmitButton", EliteParty.Language.SubmitChanges)+20, 40 )
			SubmitButton:SetPos( SubmitPanelCreate:GetWide() / 2 + 7, 0 )
			SubmitButton:SetText( "" )
			SubmitButton.Paint = function(self, w, h)
				draw.RoundedBox( 6, 0, 0, w, h, EliteParty.Color.Primary )
				draw.SimpleText( EliteParty.Language.SubmitChanges, "EliteParty_SubmitButton", w/2, 5, EliteParty.Color.HeaderText, TEXT_ALIGN_CENTER )
			end
			SubmitButton.DoClick = function()
				local Name = NameEntry:GetValue()
				local Damage = PartyVCMain.DamageToggle
				local Halo
				local Ring = PartyVCMain.RingToggle
				local HaloColor
				local RingColor = RingColorCube:GetRGB()
				if EliteParty.EnableHalo == true then
					HaloColor = HoloColorCube:GetRGB()
					Halo = PartyVCMain.HaloToggle
				else
					HaloColor = Color(255, 255, 255, 255)
					Halo = false
				end
				if not NameNotAlreadyExist(tbl, Name) then
					if Name != "" then
						if NotOnlySpace(Name) then
							if EliteParty.EnablePartyTypes then
								local Type = PartyVCMain.PartyType
								if Type != EliteParty.Language.SetTypeText then
									EPRequestBoxMenuOpen(EliteParty.Language.EditCheck, EliteParty.Language.EditCheck2.."?", EliteParty.Language.Yes, function()
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
										net.Start("EliteParty_EditParty_ToServer")
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
								else
									EPRequestBoxMenuOpen(EliteParty.Language.NoType, "", EliteParty.Language.Ok, function() return end)
								end
							else
								local Type = ""
								EPRequestBoxMenuOpen(EliteParty.Language.EditCheck, EliteParty.Language.EditCheck2.."?", EliteParty.Language.Yes, function()
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
									net.Start("EliteParty_EditParty_ToServer")
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
		end
	end
end
