function NotOnlySpace(name)
	local tbl = string.ToTable(name)
	for k, v in pairs(tbl) do
		if v != " " then
			return true
		end
	end
	return false
end

function EPTernary(T, fun, F, ...)
	if T == true then
		fun()
	else
		F()
	end
end

local Meta = FindMetaTable("Player")

function Meta:CheckFounderFromTBL(tbl)
	if EliteParty.Debug then
		ElitePartyPrint(Color(10, 150, 255), "Beginning the check to see if '"..self:Nick().."' is a founder of this party.")
	end
	if self:IsValid() and self:IsPlayer() then
		if tbl["GeneralInformation"].founder == self then
			if EliteParty.Debug then
				ElitePartyPrint(Color(10, 150, 255), "The player seems to be the founder of this party!")
				ElitePartyPrint(Color(10, 150, 255), "Finishing the check to see if '"..self:Nick().."' is a founder of this party.")
			end
			return true
		end
		if EliteParty.Debug then
			ElitePartyPrint(Color(10, 150, 255), "The player is not the founder of this party!")
			ElitePartyPrint(Color(10, 150, 255), "Finishing the check to see if '"..self:Nick().."' is a founder of this party.")
		end
		return false
	else
		if EliteParty.Debug then
			ElitePartyPrint(Color(10, 150, 255), "The player is non existent!")
			ElitePartyPrint(Color(10, 150, 255), "Finishing the check to see if '"..self:Nick().."' is a founder of this party.")
		end
		return false
	end
end

function NameNotAlreadyExist(tbl, name)
	if EliteParty.Debug then
		ElitePartyPrint(Color(10, 150, 255), "Beginning the check to see if '"..name.."' already exists.")
	end
	if #tbl >= 1 then
		for k, v in pairs(tbl) do
			if string.lower(v["GeneralInformation"].name) == string.lower(name) then
				if EliteParty.Debug then
					ElitePartyPrint(Color(10, 150, 255), "OOPS. The name already exists...")
					ElitePartyPrint(Color(10, 150, 255), "Finishing the check to see if '"..name.."' already exists.")
				end
				return true
			end
		end
		if EliteParty.Debug then
			ElitePartyPrint(Color(10, 150, 255), "The name was found to be non existent!")
			ElitePartyPrint(Color(10, 150, 255), "Finishing the check to see if '"..name.."' already exists.")
		end
		return false
	else
		if EliteParty.Debug then
			ElitePartyPrint(Color(10, 150, 255), "The table did not have any parties in it!")
			ElitePartyPrint(Color(10, 150, 255), "Finishing the check to see if '"..name.."' already exists.")
		end
		return false
	end
end

function ElitePartyPrint(color, msg)
	if EliteParty.Debug == true then
		MsgC(color, "\n\n[Elite Party] - "..msg.."\n")
	end
end

local function drawOutline( Start, Start2, End, End2, color )
	surface.SetDrawColor(color)
	surface.DrawOutlinedRect( Start, Start2, End, End2 )
end

function EPRequestBoxMenuOpen(text, text2, button1, button1fun, button2, button2fun)
	if !IsValid(RequestInput) then 
		local RequestInput = vgui.Create( "DFrame" ) 
		RequestInput:SetSize( 400, 125 )
		RequestInput:Center()
		RequestInput:SetTitle( " " ) 
		RequestInput:SetVisible( true )
		RequestInput:SetDraggable( false ) 
		RequestInput:ShowCloseButton( false ) 				
		RequestInput:MakePopup() 
		RequestInput.Paint = function(self, w, h)
			draw.RoundedBoxEx( 0, 0, 0, w, 30, EliteParty.Color.Header, true, true, false, false )
			draw.RoundedBoxEx( 0, 0, 30, w, h-30, EliteParty.Color.MainPage, false, false, true, true )	
			draw.SimpleText( text, "EliteParty_SmallWindowText", RequestInput:GetWide()/2, 35, EliteParty.Color.HeaderLeft, TEXT_ALIGN_CENTER )
			draw.SimpleText( text2, "EliteParty_SmallWindowText", RequestInput:GetWide()/2, 55, EliteParty.Color.HeaderLeft, TEXT_ALIGN_CENTER )
			drawOutline( 0, 29, w, h-29, EliteParty.Color.Header )
		end
		
		local Button1 = vgui.Create( "DButton", RequestInput )
		Button1:SetSize( 76, 30 )
		if button2 then
			Button1:SetPos( RequestInput:GetWide()/2-84,RequestInput:GetTall()-40 )
		else
			Button1:SetPos( RequestInput:GetWide()/2-38,RequestInput:GetTall()-40 )
		end
		Button1:SetText( "" )
		Button1.Paint = function(self, w, h)
			draw.RoundedBox( 0, 0, 0, w, h, EliteParty.Color.Primary )
			draw.SimpleText( button1, "EliteParty_SmallWindowButtonText", Button1:GetWide()/2, 7, EliteParty.Color.HeaderText, TEXT_ALIGN_CENTER )
		end
		Button1.DoClick = function()
			RequestInput:Remove()	
			button1fun()		
		end
		if button2 then
			local Button2 = vgui.Create( "DButton", RequestInput )
			Button2:SetSize( 76, 30 )
			Button2:SetPos( RequestInput:GetWide()/2+8,RequestInput:GetTall()-40 )
			Button2:SetText( "" )
			Button2.Paint = function(self, w, h)
				draw.RoundedBox( 0, 0, 0, w, h, EliteParty.Color.Primary )
				draw.SimpleText( button2, "EliteParty_SmallWindowButtonText", Button2:GetWide()/2, 7, EliteParty.Color.HeaderText, TEXT_ALIGN_CENTER )
			end
			Button2.DoClick = function()
				RequestInput:Remove()	
				button2fun()				
			end
		end
	end
end