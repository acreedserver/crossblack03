include("shared.lua");

surface.CreateFont("moneyFont", {
	font = "Arial",
	size = 30,
	weight = 600,
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
	
	ang:RotateAroundAxis(ang:Up(), 0);
	ang:RotateAroundAxis(ang:Forward(), 0);	
	if LocalPlayer():GetPos():Distance(self:GetPos()) < BR_DrawDistance then
	
		cam.Start3D2D(pos+ang:Up()*0.85, ang, 0.07)
			surface.SetDrawColor(Color(0, 0, 0, 225));
			surface.DrawRect(-57, -26, 113, 52);		
		
			surface.SetDrawColor(BR_MoneyColor);
			surface.DrawRect(-57, -26, 21, 52);
			
			surface.SetDrawColor(BR_MoneyColor);
			surface.DrawRect(36, -26, 21, 52);					
		cam.End3D2D();
		cam.Start3D2D(pos+ang:Up()*0.85, ang, 0.030)		
			draw.SimpleTextOutlined(BR_MoneyName, "moneyFont", 0, -44, BR_MoneyNameColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));
		cam.End3D2D();
		cam.Start3D2D(pos+ang:Up()*0.85, ang, 0.04)		
			draw.SimpleTextOutlined(""..self:GetNWFloat("amount").."$", "moneyFont", 0, 4, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));
		cam.End3D2D();
		
		ang:RotateAroundAxis(ang:Up(), 180);
		ang:RotateAroundAxis(ang:Forward(), 180);			
		cam.Start3D2D(pos+ang:Up()*-0.01, ang, 0.07)
			surface.SetDrawColor(Color(0, 0, 0, 225));
			surface.DrawRect(-57, -26, 113, 52);				
		
			surface.SetDrawColor(BR_MoneyColor);
			surface.DrawRect(-57, -26, 21, 52);
			
			surface.SetDrawColor(BR_MoneyColor);
			surface.DrawRect(36, -26, 21, 52);					
		cam.End3D2D();
		cam.Start3D2D(pos+ang:Up()*-0.01, ang, 0.030)		
			draw.SimpleTextOutlined(BR_MoneyName, "moneyFont", 0, -44, BR_MoneyNameColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));
		cam.End3D2D();		
		cam.Start3D2D(pos+ang:Up()*-0.01, ang, 0.04)		
			draw.SimpleTextOutlined(""..self:GetNWFloat("amount").."$", "moneyFont", 0, 4, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));
		cam.End3D2D();				
	end;
end;

-- maxAmount = 60
-- amount = x

