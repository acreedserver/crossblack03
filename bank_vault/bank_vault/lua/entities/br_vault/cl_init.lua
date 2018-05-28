include("shared.lua");

surface.CreateFont("bankFontCity", {
	font = "Arial",
	size = 60,
	weight = 800,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
});

surface.CreateFont("bankFontName", {
	font = "Arial",
	size = 50,
	weight = 800,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
});

surface.CreateFont("bankFont", {
	font = "Arial",
	size = 30,
	weight = 800,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
});

function ENT:Initialize()	

end;

function ENT:Draw()
	self:DrawModel();
	
	local pos = self:GetPos()
	local ang = self:GetAngles()

	local vaultColor = Color(60, 220, 108, 255);
	
	if (self:GetNWFloat("moneyStored")>0) then
		vaultColor = Color(60, 220, 108, 255);
	else
		vaultColor = Color(155, 0, 0, 255);
	end;
	
	ang:RotateAroundAxis(ang:Up(), 90);
	ang:RotateAroundAxis(ang:Forward(), 90);	
	if LocalPlayer():GetPos():Distance(self:GetPos()) < BR_DrawDistance then
		cam.Start3D2D(pos+ang:Up()*30.35, ang, 0.15)
			draw.SimpleTextOutlined(BR_BankName, "bankFontCity", -5, -395, BR_BankNameColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));
			draw.SimpleTextOutlined("Bank Vault", "bankFontName", -5, -352.5, vaultColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));
		cam.End3D2D();

		cam.Start3D2D(pos+ang:Up()*30.35, ang, 0.15)
			draw.SimpleTextOutlined("Citizens Total: ", "bankFont", -185, -310, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));
			draw.SimpleTextOutlined(""..self:GetNWFloat("citizens").." ("..self:GetNWFloat("moneyPerCitizen").."$/1)", "bankFont", -10, -310, Color(167, 212, 64, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));		
		
			draw.SimpleTextOutlined("Money Income: ", "bankFont", -185, -280, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));
			draw.SimpleTextOutlined("+"..(self:GetNWFloat("moneyPerCitizen")*self:GetNWFloat("citizens")).."$ ("..self:GetNWFloat("timeIncome").."s)", "bankFont", 0, -280, Color(167, 212, 64, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));
						
			draw.SimpleTextOutlined("Money Stored: ", "bankFont", -185, -250, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));
			draw.SimpleTextOutlined(self:GetNWFloat("moneyStored").."$", "bankFont", -8.5, -250, Color(167, 212, 64, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));	
			
			draw.SimpleTextOutlined("Police Total: ", "bankFont", -185, -190, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));
			if (self:GetNWFloat("police")>0) then
				draw.SimpleTextOutlined(""..self:GetNWFloat("police").." ("..self:GetNWFloat("moneyPerCop").."$/1)", "bankFont", -32, -190, Color(203, 121, 137, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));								
			else
				draw.SimpleTextOutlined("0 (0$/1)", "bankFont", -32, -190, Color(203, 121, 137, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));			
			end;
				
			draw.SimpleTextOutlined("Police Expense: ", "bankFont", -185, -160, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));
			draw.SimpleTextOutlined("-"..self:GetNWFloat("policeExpense").."$ ("..self:GetNWFloat("policePaymentTime").."s)", "bankFont", 10, -160, Color(203, 121, 137, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));			
			
			draw.SimpleTextOutlined("Police Payment: ", "bankFont", -185, -130, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));
			draw.SimpleTextOutlined(math.Round((self:GetNWFloat("policePayment")*100), 2).."%", "bankFont", 10, -130, Color(203, 121, 137, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));
			
			if table.HasValue(BR_RobberJobs, team.GetName(LocalPlayer():Team())) then
				if ((self:GetNWInt("vaultStatus") == 0) and (self:GetNWFloat("coolDown")==0)) then
					draw.SimpleTextOutlined("Start Robbery", "bankFont", -20, -100, Color(255, 25, 25, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));
					draw.SimpleTextOutlined("Cops will be alerted quickly!", "bankFont", -20, -70, Color(255, 25, 25, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));	
				elseif ((self:GetNWInt("vaultStatus") == 0) and (self:GetNWFloat("coolDown")>0)) then
					draw.SimpleTextOutlined("Wait "..math.Round(self:GetNWFloat("coolDown")/60).."min", "bankFont", -20, -100, Color(255, 25, 25, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));
					draw.SimpleTextOutlined("Wait and plan your robbery!", "bankFont", -20, -70, Color(255, 25, 25, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));						
				elseif ((self:GetNWInt("vaultStatus") == 1) and (self:GetNWFloat("coolDown")==0)) then
					draw.SimpleTextOutlined("Being Robbed ("..self:GetNWFloat("timeOpen").."s)", "bankFont", -20, -100, Color(255, 25, 25, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));
					draw.SimpleTextOutlined("Steal as much as you can!", "bankFont", -20, -70, Color(255, 25, 25, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));	
				end;
			end;
			
			if table.HasValue(BR_PoliceJobs, team.GetName(LocalPlayer():Team())) then
				if ((self:GetNWInt("vaultStatus") == 0) and (self:GetNWFloat("coolDown")==0)) then
					draw.SimpleTextOutlined("Can be robbed", "bankFont", -20, -100, BR_BankNameColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));
					draw.SimpleTextOutlined("Protect it from robbers!", "bankFont", -20, -70, BR_BankNameColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));	
				elseif ((self:GetNWInt("vaultStatus") == 0) and (self:GetNWFloat("coolDown")>0)) then
					draw.SimpleTextOutlined("Can be robbed in "..math.Round(self:GetNWFloat("coolDown")/60).."min", "bankFont", -20, -100, BR_BankNameColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));
					draw.SimpleTextOutlined("You can relax a little.", "bankFont", -20, -70, BR_BankNameColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));						
				elseif ((self:GetNWInt("vaultStatus") == 1) and (self:GetNWFloat("coolDown")==0)) then
					draw.SimpleTextOutlined("Being Robbed ("..self:GetNWFloat("timeOpen").."s)", "bankFont", -20, -100, Color(255, 25, 25, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));
					draw.SimpleTextOutlined("Protect it immediately!", "bankFont", -20, -70, Color(255, 25, 25, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));	
				end;
			end;
			
			--draw.SimpleTextOutlined("Bank Vault", "bankFont1", -5, -172.5, vaultColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));			
		cam.End3D2D();		
	end;
end;

-- maxAmount = 60
-- amount = x

