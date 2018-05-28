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

surface.CreateFont("moneyFontBig", {
	font = "Arial",
	size = 50,
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

	local lockerPos = self:GetPos()+(self:GetUp()*-0.4)+(self:GetRight()*2.2)+(self:GetForward()*-0.3);
	local lockerColor = Color(255, 0, 0);
	
	if self:GetNWBool("vaultLock") then
		lockerColor = Color(255, 0, 0);
	else
		lockerColor = Color(0, 255, 0);
	end;
	
	ang:RotateAroundAxis(ang:Up(), 0);
	ang:RotateAroundAxis(ang:Forward(), 90);	
	if LocalPlayer():GetPos():Distance(self:GetPos()) < BR_DrawDistance then
		cam.Start3D2D(pos+ang:Up()*3.75, ang, 0.08)
			surface.SetDrawColor(Color(0, 0, 0, 200));
			surface.DrawRect(-156, 14, 312, 208);
			
			surface.SetDrawColor(BR_MoneyCaseColor);
			surface.DrawOutlinedRect(-156, 14, 312, 208);		

			surface.SetDrawColor(BR_MoneyCaseColor);
			surface.DrawOutlinedRect(-156, 14, 312, 30);			
		cam.End3D2D();
		cam.Start3D2D(pos+ang:Up()*3.75, ang, 0.065)		
			draw.SimpleTextOutlined(BR_MoneyCaseName, "moneyFont", 0, 34, BR_MoneyCaseNameColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));
		cam.End3D2D();
		cam.Start3D2D(pos+ang:Up()*3.75, ang, 0.1)		
			draw.SimpleTextOutlined(""..self:GetNWFloat("amount").."$", "moneyFontBig", 0, 88, BR_MoneyCaseColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));
		cam.End3D2D();
		
		ang:RotateAroundAxis(ang:Up(), 180);
		ang:RotateAroundAxis(ang:Forward(), 180);			
		cam.Start3D2D(pos+ang:Up()*3.75, ang, 0.08)
			surface.SetDrawColor(Color(0, 0, 0, 200));
			surface.DrawRect(-156, 14, 312, 208);
			
			surface.SetDrawColor(BR_MoneyCaseColor);
			surface.DrawOutlinedRect(-156, 14, 312, 208);		

			surface.SetDrawColor(BR_MoneyCaseColor);
			surface.DrawOutlinedRect(-156, 14, 312, 30);			
		cam.End3D2D();
		cam.Start3D2D(pos+ang:Up()*3.75, ang, 0.065)		
			draw.SimpleTextOutlined(BR_MoneyCaseName, "moneyFont", 0, 34, BR_MoneyCaseNameColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));
		cam.End3D2D();
		cam.Start3D2D(pos+ang:Up()*3.75, ang, 0.1)		
			draw.SimpleTextOutlined(""..self:GetNWFloat("amount").."$", "moneyFontBig", 0, 88, BR_MoneyCaseColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));
		cam.End3D2D();		
		render.SetMaterial(Material("sprites/glow04_noz"));
		render.DrawSprite(lockerPos, 4, 4, lockerColor);
		render.DrawSprite(lockerPos+self:GetForward()*10.2, 3, 3, lockerColor);		
		render.DrawSprite(lockerPos+self:GetForward()*-10.2, 4, 4, lockerColor);		
	end;
end;


