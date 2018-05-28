AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");

timer.Simple(1, 
function()
	if !file.IsDir("br", "DATA") then
		file.CreateDir("br", "DATA");
	end;
	
	if !file.IsDir("br/"..string.lower(game.GetMap()).."", "DATA") then
		file.CreateDir("br/"..string.lower(game.GetMap()).."", "DATA");
	end;

	for k, v in pairs(file.Find("br/"..string.lower(game.GetMap()).."/*.txt", "DATA")) do
		local vaultPosFile = file.Read("br/"..string.lower(game.GetMap()).."/"..v, "DATA");
	 
		local spawnNumber = string.Explode(" ", vaultPosFile);		
		
		local vault = ents.Create("br_vault");
		vault:SetPos(Vector(spawnNumber[1], spawnNumber[2], spawnNumber[3]));
		vault:SetAngles(Angle(tonumber(spawnNumber[4]), spawnNumber[5], spawnNumber[6]));
		vault:Spawn();
		vault:GetPhysicsObject():EnableMotion(false);
	end;
end
);

function PolicePayment(ply, args)
if BR_MayorPayment then
	if (table.HasValue(BR_MayorJobs, team.GetName(ply:Team()))) then
		if not tonumber(args) then
			ply:SendLua("local tab={Color(96,158,219),[["..BR_BankName.." Bank - ]],Color(255,255,255),[[Money amount should be number]]}chat.AddText(unpack(tab))");
		end;
		if (tonumber(args)) then
			local amount = tonumber(args);
			if ((amount<=BR_MaxPaymentAmount) and (amount>0.01)) then
				for k,v in pairs(ents.FindByClass("br_vault")) do
					v:SetNWFloat("policePayment", amount);
				end;
				for k, v in pairs(player.GetAll()) do				
					if (table.HasValue(BR_PoliceJobs, team.GetName(v:Team()))) then
						v:SendLua("local tab={Color(96,158,219),[["..BR_BankName.." Bank - ]],Color(255,255,255),[[Police payment has been changed to ]],Color(167, 212, 64),[["..(amount*100).."%]],Color(255,255,255),[[. Have a good day!]]}chat.AddText(unpack(tab))");
						v:EmitSound("npc/overwatch/radiovoice/on3.wav");
						timer.Simple(0.7, function() v:EmitSound("npc/overwatch/radiovoice/finalverdictadministered.wav"); end);
						timer.Simple(2.75, function() v:EmitSound("npc/overwatch/radiovoice/off2.wav"); end);	
					end;
				end;				
				ply:SendLua("local tab={Color(96,158,219),[["..BR_BankName.." Bank - ]],Color(255,255,255),[[You succesfully set police payment amount to ]],Color(167, 212, 64),[["..(amount*100).."%]],Color(255,255,255),[[.]]}chat.AddText(unpack(tab))");
			else
				ply:SendLua("local tab={Color(96,158,219),[["..BR_BankName.." Bank - ]],Color(255,255,255),[[Payment must be more than ]],Color(150, 20, 20),[[0.01]],Color(255,255,255),[[ and less than ]],Color(167,212,64),[["..BR_MaxPaymentAmount.."]],Color(255,255,255),[[.]]}chat.AddText(unpack(tab))");
			end;
		end;
	return "";
	else
	ply:SendLua("local tab={Color(96,158,219),[["..BR_BankName.." Bank - ]],Color(255,255,255),[[You should be a ]],Color(150,20,20),[[Mayor]],Color(255,255,255),[[ to use this command.]]}chat.AddText(unpack(tab))");
	end;
else
	ply:SendLua("local tab={Color(96,158,219),[["..BR_BankName.." Bank - ]],Color(255,255,255),[[This function is disabled by owner.]]}chat.AddText(unpack(tab))");
	return "";
end;
end
DarkRP.defineChatCommand("policepayment", PolicePayment, 0.3)

function spawnVaultPos(ply, cmd, args)
	if (ply:IsAdmin() or ply:IsSuperAdmin()) then
		local fileVaultName = args[1];
		
		if !fileVaultName then
			ply:SendLua("local tab = {Color(255,128,0,255), [[|Bank Robbery| ]], Color(255,255,255), [[Choose a name for your vault.]] } chat.AddText(unpack(tab))");
			return;
		end;
		
		if file.Exists( "br/"..string.lower(game.GetMap()).."/vault_".. fileVaultName ..".txt", "DATA") then 
			ply:SendLua("local tab = {Color(255,128,0,255), [[|Bank Robbery| ]], Color(255,255,255), [[This name is alredy in use, choose another one or type 'vault_remove "..fileVaultName.."' in console to remove this one.]] } chat.AddText(unpack(tab))");
			return;
		end;
		
		local vaultVector = string.Explode(" ", tostring(ply:GetEyeTrace().HitPos));
		local vaultAngles = string.Explode(" ", tostring(ply:GetAngles()+Angle(0, -180, 0)));

		--[[
		local vault = ents.Create("br_vault");
		vault:SetPos(ply:GetEyeTrace().HitPos);
		vault:SetAngles(ply:GetAngles()+Angle(0, -180, 0));
		vault:Spawn();
		vault:GetPhysicsObject():EnableMotion(false);
		]]--
		
		file.Write("br/"..string.lower(game.GetMap()).."/vault_".. fileVaultName ..".txt", ""..(vaultVector[1]).." "..(vaultVector[2]).." "..(vaultVector[3]).." "..(vaultAngles[1]).." "..(vaultAngles[2]).." "..(vaultAngles[3]).."", "DATA");
		ply:SendLua("local tab = {Color(255,128,0,255), [[|Bank Robbery| ]], Color(255,255,255), [[New pos for the vault has been set. Restart your server now!]] } chat.AddText(unpack(tab))");
	else
		ply:SendLua("local tab = {Color(255,128,0,255), [[|Bank Robbery| ]], Color(255,255,255), [[Only admins and superadmins can perform this action.]] } chat.AddText(unpack(tab))");
	end;
end;
concommand.Add("vault_spawn", spawnVaultPos);

function removeVaultPos(ply, cmd, args)
	if (ply:IsAdmin() or ply:IsSuperAdmin()) then
		local fileVaultName = args[1];
		
		if !fileVaultName then
			ply:SendLua("local tab = {Color(255,128,0,255), [[|Bank Robbery| ]], Color(255,255,255), [[Please enter a name of file!]] } chat.AddText(unpack(tab))");
			return;
		end;
		
		if file.Exists("br/"..string.lower(game.GetMap()).."/vault_"..fileVaultName..".txt", "DATA") then
			file.Delete("br/"..string.lower(game.GetMap()).."/vault_"..fileVaultName..".txt");
			ply:SendLua("local tab = {Color(255,128,0,255), [[|Bank Robbery| ]], Color(255,255,255), [[This vault has been removed. Restart your server!]] } chat.AddText(unpack(tab))");
			return;
		end;
		
	else
		ply:SendLua("local tab = {Color(255,128,0,255), [[|Bank Robbery| ]], Color(255,255,255), [[Only admins and superadmins can perform this action.]] } chat.AddText(unpack(tab))");			
	end;
end;
concommand.Add("vault_remove", removeVaultPos);

function ENT:Initialize()
	self:SetModel("models/props/cs_assault/MoneyPallet.mdl");
	self:PhysicsInit(SOLID_VPHYSICS);
	
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:SetSolid(SOLID_VPHYSICS);
	
	self:SetNWFloat("distance", BR_DrawDistance);
	self:SetNWFloat("moneyPerCitizen", BR_MoneyIncome);	
	self:SetNWFloat("moneyStored", BR_MoneyStored);
	
	self:SetNWFloat("timeIncome", BR_IncomeTime);
	self:SetNWFloat("timeIncomeMax", BR_IncomeTime);
	
	self:SetNWFloat("timeOpen", BR_OpenTime);
	self:SetNWFloat("coolDown", 0);
	
	self:SetNWFloat("policePayment", BR_PaymentAmount);
	
	self:SetNWFloat("policeExpense", 0);
	self:SetNWFloat("moneyPerCop", 0);
	self:SetNWFloat("policePaymentTime", BR_ExpenseTime);
	self:SetNWFloat("policePaymentTimeMax", BR_ExpenseTime);

	self:SetNWInt("vaultStatus", 0);
	
	self.moneyDiff1 = self:GetNWFloat("moneyStored");
	self.moneyDiff2 = self:GetNWFloat("moneyStored");
	self.casesAmount = BR_Bank_MaxCases;
	
	-- Get all players here.
	citCount = 0;	
	for k, v in pairs(player.GetAll()) do
		citCount = citCount + 1;
	end;
	
	-- Get police count here.
	copCount = 0;
	for k, v in pairs(player.GetAll()) do
		if (table.HasValue(BR_PoliceJobs, team.GetName(v:Team()))) then
			copCount = copCount + 1;
		end;
	end;	
	self:SetNWFloat("citizens", citCount);
	self:SetNWFloat("police", copCount);	
end;
 
function ENT:SpawnFunction(ply, trace)
	local ent = ents.Create("br_vault");
	ent:SetPos(trace.HitPos + trace.HitNormal * 16);
	ent:Spawn();
	ent:Activate();
     
	return ent;
end;

function ENT:Think()
	if (!self.nextSecond or CurTime() >= self.nextSecond) then	
		-- Count cops here.
		copCount = 0;	
		for k, v in pairs(player.GetAll()) do
			if (table.HasValue(BR_PoliceJobs, team.GetName(v:Team()))) then
				copCount = copCount + 1;
			end;
		end;	
		if (self:GetNWFloat("coolDown")>0) then
			self:SetNWFloat("coolDown", self:GetNWFloat("coolDown")-1);
		end;
		if ((copCount > 0) and (self:GetNWInt("vaultStatus") == 0)) then
			if (self:GetNWFloat("policePaymentTime")>0) then
				self:SetNWFloat("policePaymentTime", self:GetNWFloat("policePaymentTime")-1);
			elseif (self:GetNWFloat("policePaymentTime")==0) then		
				local policeExpense = math.Round(self:GetNWFloat("policePayment")*self:GetNWFloat("moneyStored"));		
				self:SetNWFloat("policeExpense", policeExpense);
				if (self:GetNWFloat("moneyStored")>=policeExpense) then			
					self:SetNWFloat("moneyStored", self:GetNWFloat("moneyStored")-policeExpense);
					--self:EmitSound("ambient/levels/labs/coinslot1.wav");
					local policeCount = 0;	
					for k, v in pairs(player.GetAll()) do
							if (table.HasValue(BR_PoliceJobs, team.GetName(v:Team()))) then
							policeCount = policeCount + 1;
						end;
					end;			
					local moneyEachPolice = math.Round(policeExpense/policeCount);
					for k, v in pairs(player.GetAll()) do
						if (table.HasValue(BR_PoliceJobs, team.GetName(v:Team()))) then
							v:SendLua("local tab={Color(96,158,219),[["..BR_BankName.." Bank - ]],Color(255,255,255),[[You got ]],Color(167, 212, 64),[["..moneyEachPolice.."$]],Color(255,255,255),[[ for guarding the bank vault.]]}chat.AddText(unpack(tab))");							
							v:addMoney(moneyEachPolice);
						end;
					end;
				end;
				self:SetNWFloat("policePaymentTime", self:GetNWFloat("policePaymentTimeMax"));
			end;
		end;

		if ((self:GetNWInt("vaultStatus") == 1) and (self:GetNWFloat("timeOpen")>0)) then
			self:SetNWFloat("timeOpen", (self:GetNWFloat("timeOpen")-1));
			if (self:GetNWFloat("timeOpen") == 0) then
				self:SetNWInt("vaultStatus", 0);			
				self:SetNWFloat("coolDown", BR_CooldownTime);
				self.casesAmount = BR_Bank_MaxCases;		
				self.moneyDiff2 = self:GetNWFloat("moneyStored");
				local moneyDifference = self.moneyDiff1 - self.moneyDiff2;
			--BroadcastLua("LocalPlayer():EmitSound('music/"..BR_RobberyMusic.."')");
						
				for k, v in pairs(player.GetAll()) do
					if (table.HasValue(BR_PoliceJobs, team.GetName(v:Team()))) then			
						v:SendLua("local tab={Color(96,158,219),[["..BR_BankName.." Bank - ]],Color(255,255,255),[[Vault lost ]],Color(255, 0, 0),[["..moneyDifference.."$]],Color(255,255,255),[[ during bank heist!]]}chat.AddText(unpack(tab))");
						if BR_RobberyReport then						
							v:EmitSound("npc/overwatch/radiovoice/on3.wav");
							timer.Simple(0.7, function() v:EmitSound("npc/overwatch/radiovoice/allunitsverdictcodeonsuspect.wav"); end);
							timer.Simple(2.75, function() v:EmitSound("npc/overwatch/radiovoice/off2.wav"); end);
						end;
					elseif (table.HasValue(BR_RobberJobs, team.GetName(v:Team()))) then
						v:SendLua("LocalPlayer():EmitSound('vo/coast/odessa/male01/nlo_cheer0"..math.random(1, 4)..".wav')");
						v:SendLua("local tab={Color(255,0,0),[["..BR_RobberyBoss..": ]],Color(255,255,255),[[Well played team, bank vault lost ]],Color(167, 212, 64),[["..moneyDifference.."$]],Color(255,255,255),[[.]]}chat.AddText(unpack(tab))");
					end;					
				end;
				self:SetNWFloat("timeOpen", BR_OpenTime);
			end;
		end;
		
		if ((self:GetNWFloat("timeIncome")>0) and (self:GetNWInt("vaultStatus") == 0)) then
			self:SetNWFloat("timeIncome", self:GetNWFloat("timeIncome")-1);
		elseif (self:GetNWFloat("timeIncome")==0) then
			self:SetNWFloat("moneyStored", math.Clamp(self:GetNWFloat("moneyStored")+(self:GetNWFloat("moneyPerCitizen")*self:GetNWFloat("citizens")), 0, BR_MaxMoneyStored));
			self:SetNWFloat("timeIncome", self:GetNWFloat("timeIncomeMax"));
			self:EmitSound("ambient/levels/labs/coinslot1.wav");
		end;
		
			-- Count civs here.
			citCount = 0;	
			for k, v in pairs(player.GetAll()) do
				citCount = citCount + 1;
			end;

			if (copCount > 0) then
				policeExpense = math.Round(self:GetNWFloat("policePayment")*self:GetNWFloat("moneyStored"));									
			else				
				policeExpense = 0;		
				self:SetNWFloat("moneyPerCop", 0);
			end;
			
			self:SetNWFloat("policeExpense", policeExpense);			
			self:SetNWFloat("moneyPerCop", math.Round(policeExpense/copCount));
			
			self:SetNWFloat("citizens", citCount);
			self:SetNWFloat("police", copCount);
	self.nextSecond = CurTime() + 1;
	end;
end;

function ENT:Use(activator, caller)
local curTime = CurTime();
	if (!self.nextUse or curTime >= self.nextUse) then
		if (table.HasValue(BR_RobberJobs, team.GetName(activator:Team()))) then
		if (self:GetNWFloat("police")>=BR_CopsRequired) then
			--activator:EmitSound("vo/npc/male01/letsgo0"..math.random(1, 2)..".wav", 100, 150);
			if ((self:GetNWInt("vaultStatus") == 0) and(self:GetNWFloat("coolDown")<=0)) then
				self:SetNWInt("vaultStatus", 1);
				if BR_RobberyInitiator then
					activator:EmitSound("vo/npc/male01/letsgo0"..math.random(1, 2)..".wav");
				end;				
				self.moneyDiff1 = self:GetNWFloat("moneyStored");		
					for k,v in pairs(ents.FindInSphere(self:GetPos(), 256)) do
						if ((v:GetClass() == "player") and table.HasValue(BR_RobberJobs, team.GetName(v:Team()))) then
							v:SendLua("LocalPlayer():EmitSound('music/"..BR_RobberyMusic.."')");
						end;
					end;			
				if BR_RobberyWanted then
					for k,v in pairs(ents.FindInSphere(self:GetPos(), 256)) do
						if ((v:GetClass() == "player") and table.HasValue(BR_RobberJobs, team.GetName(v:Team()))) then
							v:wanted(nil, "Bank Robbery");
						end;
					end;
				end;
				
				for k, v in pairs(player.GetAll()) do
					if (table.HasValue(BR_PoliceJobs, team.GetName(v:Team()))) then
						v:SendLua("local tab={Color(175,0,0),[["..BR_BankName.." Bank - ]],Color(255,0,0),[[Bank vault is being robbed, protect it immediately!]]}chat.AddText(unpack(tab))");
						--v:SendLua("sound.PlayURL('http://cs4-2v4.vk.me/p8/39a00ef685d978.mp3','mono',function(music) music:Play() end)");
						v:SendLua("LocalPlayer():EmitSound('music/"..BR_RobberyMusic.."')");
											
						if BR_RobberyReport then
							v:EmitSound("npc/overwatch/radiovoice/on3.wav");
							timer.Simple(0.7, function() v:EmitSound("npc/overwatch/radiovoice/allunitsreturntocode12.wav"); end);
							timer.Simple(2.65, function() v:EmitSound("npc/overwatch/radiovoice/off2.wav"); end);
						end;
					elseif (table.HasValue(BR_RobberJobs, team.GetName(v:Team()))) then	
						v:SendLua("local tab={Color(255,0,0),[["..BR_RobberyBoss..": ]],Color(255,255,255),[[Game's on, better hurry.]]}chat.AddText(unpack(tab))");
					end;	
				end;				

			elseif (self:GetNWInt("vaultStatus") == 1) and (activator:GetEyeTrace().Entity == self)then
				local dropType = math.random(1, 4);				
				if (self:GetNWFloat("moneyStored") >= BR_MaxMoneyCaseAmount) then
					if (self.casesAmount > 0) then
						local moneyAmountCase = math.random(BR_MinMoneyCaseAmount, BR_MaxMoneyCaseAmount);			
						self:SetNWFloat("moneyStored", self:GetNWFloat("moneyStored")-moneyAmountCase);
						local moneyCreate = ents.Create("br_money_case");
						moneyCreate:SetPos(activator:GetEyeTrace().HitPos+(activator:GetForward()*-16)+(activator:GetUp()*8));
						moneyCreate:SetAngles(activator:GetAngles()+Angle(0, 270, 0));
						moneyCreate:Spawn()
						moneyCreate:GetPhysicsObject():SetVelocity((moneyCreate:GetForward()*-16)+(moneyCreate:GetUp()*8));
						moneyCreate:SetNWFloat("amount", moneyAmountCase);
						moneyCreate:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");					
						activator:SendLua("local tab={Color(255,0,0),[["..BR_RobberyBoss..": ]],Color(255,255,255),[["..table.Random(BR_RobberyPhrases).." You stole ]],Color(167, 212, 64),[["..moneyCreate:GetNWFloat("amount").."$]],Color(255,255,255),[[.]]}chat.AddText(unpack(tab))");
						self.casesAmount = self.casesAmount - 1;
					elseif (self.casesAmount == 0) then
						if (self:GetNWFloat("moneyStored") >= BR_MaxMoneyAmount) then				
							local moneyAmount = math.random(BR_MinMoneyAmount, BR_MaxMoneyAmount);				
							self:SetNWFloat("moneyStored", self:GetNWFloat("moneyStored")-moneyAmount);					
							local moneyCreate = ents.Create("br_money");
							moneyCreate:SetPos(activator:GetEyeTrace().HitPos+(activator:GetForward()*-16)+(activator:GetUp()*16));
							moneyCreate:SetAngles(activator:GetAngles()+Angle(0, 270, 0));
							moneyCreate:Spawn()
							moneyCreate:GetPhysicsObject():SetVelocity((moneyCreate:GetForward()*-16)+(moneyCreate:GetUp()*8));
							moneyCreate:SetNWFloat("amount", moneyAmount);
							moneyCreate:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");
							activator:SendLua("local tab={Color(255,0,0),[["..BR_RobberyBoss..": ]],Color(255,255,255),[["..table.Random(BR_RobberyPhrases).." You stole ]],Color(167, 212, 64),[["..moneyCreate:GetNWFloat("amount").."$]],Color(255,255,255),[[.]]}chat.AddText(unpack(tab))");
						end;
					end;				
				elseif (self:GetNWFloat("moneyStored") >= BR_MaxMoneyAmount) then				
					local moneyAmount = math.random(BR_MinMoneyAmount, BR_MaxMoneyAmount);				
					self:SetNWFloat("moneyStored", self:GetNWFloat("moneyStored")-moneyAmount);					
					local moneyCreate = ents.Create("br_money");
					moneyCreate:SetPos(activator:GetEyeTrace().HitPos+(activator:GetForward()*-16)+(activator:GetUp()*16));
					moneyCreate:SetAngles(activator:GetAngles()+Angle(0, 270, 0));
					moneyCreate:Spawn()
					moneyCreate:GetPhysicsObject():SetVelocity((moneyCreate:GetForward()*-16)+(moneyCreate:GetUp()*8));
					moneyCreate:SetNWFloat("amount", moneyAmount);
					moneyCreate:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");
					activator:SendLua("local tab={Color(255,0,0),[["..BR_RobberyBoss..": ]],Color(255,255,255),[["..table.Random(BR_RobberyPhrases).." You stole ]],Color(167, 212, 64),[["..moneyCreate:GetNWFloat("amount").."$]],Color(255,255,255),[[.]]}chat.AddText(unpack(tab))");
				end;
			end;
		else
		activator:SendLua("local tab={Color(255,0,0),[["..BR_RobberyBoss..": ]],Color(255,255,255),[[You need at least "..BR_CopsRequired.." guards online to rob the bank.]]}chat.AddText(unpack(tab))");		
		end;
		end;
		self.nextUse = curTime + 1;		
	end;
end;

function ENT:PhysicsCollide(data, phys)
local curTime = CurTime(); 
	if ((data.DeltaTime > 0) and (data.HitEntity:GetClass() == "br_money_case") and (self:GetNWInt("vaultStatus")==0)) then
		if BR_MoneyCaseReturn then
			self:SetNWFloat("moneyStored", math.Clamp(self:GetNWFloat("moneyStored")+data.HitEntity:GetNWFloat("amount"), 0, BR_MaxMoneyStored));
			self:EmitSound("ambient/levels/labs/coinslot1.wav");
			for k, v in pairs(player.GetAll()) do
				if (table.HasValue(BR_PoliceJobs, team.GetName(v:Team()))) then	
					v:SendLua("local tab={Color(96,158,219),[["..BR_BankName.." Bank - ]],Color(167,212,64),[["..data.HitEntity:GetNWFloat("amount").."$]],Color(255,255,255),[[ were returned into the bank vault.]]}chat.AddText(unpack(tab))");
				end;
			end;			
			data.HitEntity:VisualEffect();
		end;
	end;
end;

function ENT:VisualEffect()
	local effectData = EffectData();	
	effectData:SetStart(self:GetPos());
	effectData:SetOrigin(self:GetPos());
	effectData:SetScale(8);	
	util.Effect("GlassImpact", effectData, true, true);
	self:Remove();
end;

