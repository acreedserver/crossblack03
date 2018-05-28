function StencilStart()
	render.ClearStencil()
	render.SetStencilEnable( true )
	render.SetStencilWriteMask( 1 )
	render.SetStencilTestMask( 1 )
	render.SetStencilFailOperation( STENCILOPERATION_KEEP )
	render.SetStencilZFailOperation( STENCILOPERATION_KEEP )
	render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_ALWAYS ) 	
	render.SetStencilReferenceValue( 1 )
	render.SetColorModulation( 1, 1, 1 )
end

function StencilReplace()
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
	render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
	render.SetStencilReferenceValue(0)
end

function StencilEnd()
	render.SetStencilEnable( false )
end

function PLDrawRect( Startx, StartY, Width, Length, Color )
	surface.SetDrawColor(Color)
	surface.DrawRect( Startx, StartY, Width, Length )
end

function drawOutline( Start, Start2, End, End2, color )
	surface.SetDrawColor(color)
	surface.DrawOutlinedRect( Start, Start2, End, End2 )
end

function DrawSimpleCircle(posx, posy, radius, color)
	local poly = { }
	local v = 40
	for i = 0, v do
		poly[i+1] = {x = math.sin(-math.rad(i/v*360)) * radius + posx, y = math.cos(-math.rad(i/v*360)) * radius + posy}
	end
	draw.NoTexture()
	surface.SetDrawColor(color)
	surface.DrawPoly(poly)
end

function DrawCircle(posx, posy, radius, progress, color)
	local poly = { }
	local v = 220
	poly[1] = {x = posx, y = posy}
	for i = 0, v*progress+0.5 do
		poly[i+2] = {x = math.sin(-math.rad(i/v*360)) * radius + posx, y = math.cos(-math.rad(i/v*360)) * radius + posy}
	end
	draw.NoTexture()
	surface.SetDrawColor(color)
	surface.DrawPoly(poly)
end

function GetTextWidth(font, txt)
	surface.SetFont(font)
	local w, h = surface.GetTextSize(txt)
	return w
end

EliteParty.OpenSecondHalf = false

net.Receive("EliteParty_NoPOpenMenu", function()
	if !IsValid(PLMainPlayerList) and not IsValid(ELMain) then 
		local ply = net.ReadEntity()
		local bool = net.ReadBool()
		local tbl = net.ReadTable()
		local righth
		local function GetRightH()
			local height = ((table.Count(tbl) * 80) + 100 + 60)
			if height <= 700 then
				righth = height
			else
				righth = 700
			end
		end
		GetRightH()
		ELMain = vgui.Create( "DFrame" ) 
		ELMain:SetSize( 1100, 700 )
		ELMain:Center()
		ELMain:SetTitle( " " ) 
		ELMain:SetVisible( true )
		ELMain:SetDraggable( false ) 
		ELMain:ShowCloseButton( false ) 				
		ELMain:MakePopup() 
		ELMain.Paint = function(self, w, h)
			
		end

		local EPMainList = vgui.Create( "DPanel", ELMain )
		EPMainList:SetSize( 430, righth )
		EPMainList:Center()
		EPMainList:SetAlpha(0)
		EPMainList:AlphaTo(255,EliteParty.AnimSpeed,0,function() return end)
		EPMainList.Paint = function(self, w, h)
			draw.RoundedBox( 0, 86, 0, w-40, 60, EliteParty.Color.Header )
			draw.RoundedBox( 0, 0, 0, 86, 60, EliteParty.Color.HeaderLeft )
			draw.RoundedBox( 0, 20, 16, 48, 4, EliteParty.Color.HeaderBars )
			draw.RoundedBox( 0, 20, ((16) + (4)) + (8), 48-15, 4, EliteParty.Color.HeaderBars )
			draw.RoundedBox( 0, 20, ((60) - (16)) - (4), 48, 4, EliteParty.Color.HeaderBars )
			--draw.RoundedBox( 0, 0, 60, w, h-(60)-40, EliteParty.Color.MainPageBG )
			--draw.RoundedBox( 0, 0, 60, w, (((#player.GetAll()*80)))-40, EliteParty.Color.MainPage )
			draw.RoundedBox( 0, 0, h-40, w-(w/2), 40, EliteParty.Color.InstructionPanel )
			draw.SimpleText( EliteParty.Language.PartyTitle, "ElitePartyMenuTitle", w/2, 7, EliteParty.Color.HeaderText, TEXT_ALIGN_CENTER )
			draw.SimpleText( EliteParty.Language.SelectParty, "ElitePartyHelpText", (w/2)/2, h-33, EliteParty.Color.HeaderText, TEXT_ALIGN_CENTER )
		end
		
		local CloseButton = vgui.Create( "DButton", EPMainList )
		CloseButton:SetSize( 60, 60 )
		CloseButton:SetPos( EPMainList:GetWide() - 60,0 )
		CloseButton:SetText( "X" )
		CloseButton:SetFont( "ElitePartyCloseButton" )
		CloseButton:SetTextColor( EliteParty.Color.CloseButton )
		CloseButton.Paint = function()
			
		end
		CloseButton.DoClick = function()
			EliteParty.OpenSecondHalf = false
			if IsValid(PartyVCMain) then
				PartyVCMain:Remove()
			end
			if IsValid(EPMainList) then
				EPMainList:Remove()
			end
			ELMain:Remove()					
		end

		local ButtonScrollPanel = vgui.Create( "DScrollPanel", EPMainList )
		ButtonScrollPanel:SetSize( EPMainList:GetWide(), EPMainList:GetTall()-100 )
		ButtonScrollPanel:SetPos( 0, 60 )
		ButtonScrollPanel.Paint = function(self, w, h)
			--draw.RoundedBox( 0, 0, 0, w, h, EliteParty.Color.MainPageBG )
			draw.RoundedBox( 0, 0, 0, w, h, EliteParty.Color.MainPage )
		end
		ButtonScrollPanel.VBar.Paint = function(self, w, h)
		end
		ButtonScrollPanel.VBar.btnUp.Paint = function(self, w, h)
		end
		ButtonScrollPanel.VBar.btnDown.Paint = function(self, w, h)
		end
		ButtonScrollPanel.VBar.btnGrip.Paint = function(self, w, h)	
			draw.RoundedBox( 6, 3, 0, w-3, h, EliteParty.Color.HeaderLeft )
		end
		
		local ButtonList = vgui.Create( "DListLayout", ButtonScrollPanel )
		ButtonList:SetSize( ButtonScrollPanel:GetWide() - 2, ButtonScrollPanel:GetTall() )
		ButtonList:SetPos( 0, 0 )

		if table.Count(tbl) > 0 then
			for k, v in pairs(tbl) do
				local Playerselectionbutton = vgui.Create( "DButton" )
				Playerselectionbutton:SetSize( ButtonList:GetWide(), 80 )
				Playerselectionbutton:SetPos( 0, 0 )
				Playerselectionbutton:SetText( "" )
				Playerselectionbutton.Paint = function(self, w, h)
					draw.RoundedBox( 0, 0, 0, w, h, EliteParty.Color.MainPage )
					draw.SimpleText( v["GeneralInformation"].name, "ElitePartyPlayerName", 85, 12, EliteParty.Color.PlayerTextDark, TEXT_ALIGN_LEFT )
					if EliteParty.EnablePartyTypes then
						draw.SimpleText( v["GeneralInformation"].type, "ElitePartyPlayerName", 85, 38, EliteParty.Color.PlayerTextLight, TEXT_ALIGN_LEFT )
					end
					draw.SimpleText( #v["GeneralInformation"].members.."/"..EliteParty.MaxMembers, "ElitePartyPlayerName", w-10, 38, EliteParty.Color.PlayerTextLight, TEXT_ALIGN_RIGHT )
					--if k != #tbl then
						PLDrawRect( 0, h-1, w, 1, EliteParty.Color.ListSeperator )
					--end
				end
				Playerselectionbutton.DoClick = function()
					local ex, wy = EPMainList:GetPos()
					if ex == 0 and wy == 0 then
						if EliteParty.OpenSecondHalf then
							PartyVCMain:Remove()
							EliteParty.OpenSecondHalf = false
							timer.Simple(0.25, function()
								if not EliteParty.OpenSecondHalf then
										net.Start("EliteParty_ViewParty_ToServer")
											--net.WriteEntity(ply)
											net.WriteString(v["GeneralInformation"].name)
										net.SendToServer()
								end
							end)
						end
					else
						EPMainList:MoveTo( 0, 0, EliteParty.AnimSpeed, 0, -1, function() 
							if not EliteParty.OpenSecondHalf then
								if ply:IsPlayer() and ply:IsValid() then
									net.Start("EliteParty_ViewParty_ToServer")
									--	net.WriteEntity(ply)
										net.WriteString(v["GeneralInformation"].name)
									net.SendToServer()
								end
							end
						end )
					end
				end
				local avatar = vgui.Create( "AvatarImage", Playerselectionbutton ) 
				avatar:SetSize( 60, 60 )
				avatar:SetPlayer(v["GeneralInformation"].founder, 128)
				avatar:SetPos(10, 10)
				function avatar:PaintOver(w, h)
					StencilStart()
					DrawCircle(w/2, h/2, w/2, 1, Color(0,0,0,1))
					StencilReplace()
					surface.SetDrawColor(EliteParty.Color.MainPage)
					surface.DrawRect(0, 0, w, h)
					StencilEnd()
				end
				function avatar:Think() 
					avatar:SetPos(10, 10)
				end
				ButtonList:Add(Playerselectionbutton)
			end
		end

		if bool then
			local AddParty = vgui.Create( "DPanel" )
			AddParty:SetSize( ButtonList:GetWide(), 60 )
			AddParty:Center()
			AddParty.Paint = function(self, w, h)
				draw.RoundedBox( 0, 0, 0, w, h, EliteParty.Color.MainPage )
			end
			local Playerselectionbutton = vgui.Create( "DButton", AddParty )
			Playerselectionbutton:SetSize( AddParty:GetWide()-60, AddParty:GetTall()-20 )
			Playerselectionbutton:SetPos( 30, 10 )
			Playerselectionbutton:SetText( "" )
			Playerselectionbutton.Paint = function(self, w, h)
				draw.RoundedBox( 10, 0, 0, w, h, EliteParty.Color.Header )
				draw.SimpleText( EliteParty.Language.CreateNew, "ElitePartyPlayerName", w/2, 5, EliteParty.Color.HeaderText, TEXT_ALIGN_CENTER )
			end
			Playerselectionbutton.DoClick = function()
				local ex, wy = EPMainList:GetPos()
				if ex == 0 and wy == 0 then
					if EliteParty.OpenSecondHalf then
						PartyVCMain:Remove()
						EliteParty.OpenSecondHalf = false
						timer.Simple(0.25, function()
							if not EliteParty.OpenSecondHalf then
									net.Start("EP_CreateParty_ToServer")
									--	net.WriteEntity(ply)
									net.SendToServer()
							end
						end)
					end
				else
					EPMainList:MoveTo( 0, 0, EliteParty.AnimSpeed, 0, -1, function() 
						if not EliteParty.OpenSecondHalf then
							if ply:IsPlayer() and ply:IsValid() then
								net.Start("EP_CreateParty_ToServer")
								--	net.WriteEntity(ply)
								net.SendToServer()
							end
						end
					end )
				end
			end
			ButtonList:Add(AddParty)
		else
			local AddParty = vgui.Create( "DPanel" )
			AddParty:SetSize( ButtonList:GetWide(), 60 )
			AddParty:Center()
			AddParty.Paint = function(self, w, h)
				draw.RoundedBox( 0, 0, 0, w, h, EliteParty.Color.MainPage )
			end
			local Playerselectionbutton = vgui.Create( "DButton", AddParty )
			Playerselectionbutton:SetSize( AddParty:GetWide()-60, AddParty:GetTall()-20 )
			Playerselectionbutton:SetPos( 30, 10 )
			Playerselectionbutton:SetText( "" )
			Playerselectionbutton.Paint = function(self, w, h)
				draw.RoundedBox( 10, 0, 0, w, h, EliteParty.Color.Header )
				draw.SimpleText( EliteParty.Language.LeaveParty, "ElitePartyPlayerName", w/2, 5, EliteParty.Color.HeaderText, TEXT_ALIGN_CENTER )
			end
			Playerselectionbutton.DoClick = function()
				EPRequestBoxMenuOpen(EliteParty.Language.CheckLeave, EliteParty.Language.CheckLeave2.."?", EliteParty.Language.Yes, function()
					if ply:IsPlayer() and ply:IsValid() then
						net.Start("EliteParty_LeaveParty_ToServer")
							--net.WriteEntity(ply)
						net.SendToServer()
						EliteParty.OpenSecondHalf = false
						if IsValid(PartyVCMain) then
							PartyVCMain:Remove()
						end
						if IsValid(EPMainList) then
							EPMainList:Remove()
						end
						ELMain:Remove()	
					end
				end, EliteParty.Language.No, function() return end)
			end
			ButtonList:Add(AddParty)
		end
	end
end)

local HaloMemberTBL = {}
local RingMemberTBL = {}
local HaloColor = Color(255, 255, 255, 255)
local RingColor = Color(255, 255, 255, 255)
net.Receive("EliteParty_UpdateMemberTableHalo_ToClient", function()
	HaloMemberTBL = net.ReadTable()
	HaloColor = net.ReadTable()
	if EliteParty.Debug then
		PrintTable(HaloMemberTBL)
		PrintTable(HaloColor)
	end
end)
net.Receive("EliteParty_UpdateMemberTableRing_ToClient", function()
	RingMemberTBL = net.ReadTable()
	RingColor = net.ReadTable()
	if EliteParty.Debug then
		PrintTable(RingMemberTBL)
		PrintTable(RingColor)
	end
end)
hook.Add("PreDrawHalos", "DrawHolosParty", function()
	for k, v in pairs(HaloMemberTBL) do
		if v:IsValid() and v:IsPlayer() then
			if EliteParty.MaxDistance != 0 then
				if LocalPlayer():GetPos():Distance(v:GetPos()) <= EliteParty.MaxDistance then
					halo.Add( {v}, HaloColor , 2, 2, 2, true, true )
				end
			else
				halo.Add( {v}, HaloColor , 2, 2, 2, true, true )
			end
		end
	end
end)
hook.Add("PostDrawTranslucentRenderables", "DrawPartyRing", function()
	for k, v in pairs(RingMemberTBL) do
		if v != LocalPlayer() and v:IsValid() and v:IsPlayer() then
			cam.Start3D2D( v:GetPos() + Vector(0,0,5),Angle(0,CurTime()*120,0), 0.25 )
				surface.SetMaterial(Material("particle/Particle_Ring_Wave_Additive"))
				surface.SetDrawColor(RingColor) 
				surface.DrawTexturedRect( -100,-100,100*2, 100*2 )
			cam.End3D2D()
		end
	end
end)

net.Receive("EliteParty_NewMember_ToClient", function()
	local ply = net.ReadEntity()
	local tar = net.ReadEntity()
	chat.AddText( EliteParty.Color.ChatPrefix, "["..EliteParty.Language.EParty.."] ", Color( 255, 255, 255 ), tar:Nick().." "..EliteParty.Language.JoinedParty.."." )
end)
net.Receive("EliteParty_KickedMember_ToClient", function()
	local ply = net.ReadEntity()
	local tar = net.ReadEntity()
	if net.ReadBool() then
		chat.AddText( EliteParty.Color.ChatPrefix, "["..EliteParty.Language.EParty.."] ", Color( 255, 255, 255 ), ply:Nick().." "..EliteParty.Language.KickedMemberPly.."." )
	else
		chat.AddText( EliteParty.Color.ChatPrefix, "["..EliteParty.Language.EParty.."] ", Color( 255, 255, 255 ), tar:Nick().." "..EliteParty.Language.KickedMember.."." )
	end
end)
net.Receive("EliteParty_MakeFounder_ToClient", function()
	local ply = net.ReadEntity()
	local tar = net.ReadEntity()
	chat.AddText( EliteParty.Color.ChatPrefix, "["..EliteParty.Language.EParty.."] ", Color( 255, 255, 255 ), tar:Nick().." "..EliteParty.Language.MadeFounder.."." )
end)
net.Receive("EliteParty_PartyRequestAccepted_ToClient", function()
	local ply = net.ReadEntity()
	local tar = net.ReadEntity()
	chat.AddText( EliteParty.Color.ChatPrefix, "["..EliteParty.Language.EParty.."] ", Color( 255, 255, 255 ), ply:Nick().." "..EliteParty.Language.JoinedParty.."." )
end)
net.Receive("EliteParty_SendPartyChat_ToClient", function()
	local ply = net.ReadEntity()
	local txt = net.ReadString()
	chat.AddText( EliteParty.Color.ChatPrefix, "["..EliteParty.Language.EParty.."] ", team.GetColor(ply:Team()), ply:Nick(), Color(255, 255, 255), ": "..txt )
end)

surface.CreateFont( "EliteParty_SmallWindowButtonText", {
	font = "Roboto",
	size = 18,
	weight = 500
} )

surface.CreateFont( "EliteParty_InviteNotiText", {
	font = "Roboto",
	size = 20,
	weight = 500
} )

surface.CreateFont( "EliteParty_SmallWindowText", {
	font = "Roboto",
	size = 17,
	weight = 500
} )

surface.CreateFont( "EliteParty_OnOff", {
	font = "Source Sans Pro",
	size = 20,
	weight = 625
} )

surface.CreateFont( "EliteParty_NameEntry", {
	font = "Source Sans Pro",
	size = 20,
	weight = 500
} )

surface.CreateFont( "EliteParty_InviteNotiButton", {
	font = "Source Sans Pro",
	size = 20,
	weight = 580
} )

surface.CreateFont( "EliteParty_SubmitButton", {
	font = "Source Sans Pro",
	size = 29,
	weight = 625
} )

surface.CreateFont( "EliteParty_MiscTitlessub", {
	font = "Source Sans Pro",
	size = 23,
	weight = 550
} )

surface.CreateFont( "ElitePartyHelpText", {
	font = "Nevis",
	size = 25,
	weight = 400,
	bold = true
} )
surface.CreateFont( "ElitePartyHelpText2", {
	font = "Nevis",
	size = 18,
	weight = 400,
	bold = true
} )

surface.CreateFont( "ElitePartyPlayerName", {
	font = "Trebuchet24",
	size = 25,
	weight = 400,
	bold = true
} )

surface.CreateFont( "ElitePartyCloseButton", {
	font = "Aliquam",
	size = 35,
	weight = 520,
} )

surface.CreateFont( "ElitePartyMenuTitle", {
	font = "Bebas Neue",
	size = 53,
	weight = 500,
} )