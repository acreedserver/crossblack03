AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");

function ENT:Initialize()
	self:SetModel("models/props_c17/SuitCase_Passenger_Physics.mdl");
	self:PhysicsInit(SOLID_VPHYSICS);
	
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:SetSolid(SOLID_VPHYSICS);
	
	self:SetNWFloat("distance", BR_DrawDistance);
	self:SetNWFloat("amount", 2000);
	self:SetNWFloat("vaultDistance", BR_MoneyCaseLockDistance);
	if BR_MoneyCaseLock then
		self:SetNWBool("vaultLock", true);
	else
		self:SetNWBool("vaultLock", false);
	end;
	if BR_MoneyCaseNoPocket then
		self:GetPhysicsObject():SetMass(105);
	end;
end;
 
function ENT:SpawnFunction(ply, trace)
	local ent = ents.Create("br_money_case");
	ent:SetPos(trace.HitPos + trace.HitNormal * 16);
	ent:Spawn();
	ent:Activate();
     
	return ent;
end;

function ENT:Use(activator, caller)
local curTime = CurTime();
	if (!self.nextUse or curTime >= self.nextUse) then
		if (table.HasValue(BR_PoliceJobs, team.GetName(activator:Team()))) then	
			for k, v in pairs(ents.FindByClass("br_vault")) do
				if IsValid(v) then				
					if (BR_MoneyCase_RewardCop) then
						self.rewardPrice = math.Round(BR_MoneyCase_ReturnReward*self:GetNWFloat("amount"));
						self.cashbackVault = math.Round(self:GetNWFloat("amount")-self.rewardPrice);
						v:SetNWFloat("moneyStored", math.Clamp(v:GetNWFloat("moneyStored")+self.cashbackVault, 0, BR_MaxMoneyStored));
					else
						v:SetNWFloat("moneyStored", math.Clamp(v:GetNWFloat("moneyStored")+self:GetNWFloat("amount"), 0, BR_MaxMoneyStored));
					end;
					self:EmitSound("ambient/levels/labs/coinslot1.wav");	
					for k, v in pairs(player.GetAll()) do
						if (table.HasValue(BR_PoliceJobs, team.GetName(v:Team()))) then
							v:SendLua("local tab={Color(96,158,219),[["..BR_BankName.." Bank - ]],Color(167,212,64),[["..self.cashbackVault.."$]],Color(255,255,255),[[ were returned into the bank vault.]]}chat.AddText(unpack(tab))");
						end;						
					end;
					if (BR_MoneyCase_RewardCop) then
						if (GAMEMODE.Version == "2.4.3") then
							activator:AddMoney(self.rewardPrice);
						else
							activator:addMoney(self.rewardPrice);
						end;
						activator:SendLua("local tab={Color(96,158,219),[["..BR_BankName.." Bank - ]],Color(255,255,255),[[You got ]],Color(167,212,64),[["..self.rewardPrice.."$]],Color(255,255,255),[[ for returning money to bank vault.]]}chat.AddText(unpack(tab))");	
					end;
				end;			
			end;
			self:VisualEffect();
		else
			if (!self:GetNWBool("vaultLock")) then
				if (GAMEMODE.Version == "2.4.3") then
					activator:AddMoney(self:GetNWFloat("amount"));
				else
					activator:addMoney(self:GetNWFloat("amount"));
				end;
				self:EmitSound("ambient/levels/labs/coinslot1.wav");
				self:VisualEffect();
				self.nextUse = curTime + 0.5;	
			end;
		end;
	end;
end;

function ENT:Think()
	if BR_MoneyCaseLock then
		for k, v in pairs (ents.FindByClass("br_vault")) do
			local vPos = v:GetPos();
			local vDistance = vPos:Distance(self:GetPos());
			if v:GetPos():Distance(self:GetPos())<BR_MoneyCaseLockDistance then
				self:SetNWBool("vaultLock", true);
			elseif v:GetPos():Distance(self:GetPos())>BR_MoneyCaseLockDistance then
				self:SetNWBool("vaultLock", false);	
			end;
		end;
	end;
end;

function ENT:OnTakeDamage(dmginfo)
	if BR_MoneyCaseDamage then
		self:VisualEffect();
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

