AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");

function ENT:Initialize()
	self:SetModel("models/props/cs_assault/Money.mdl");
	self:PhysicsInit(SOLID_VPHYSICS);
	
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:SetSolid(SOLID_VPHYSICS);
	
	self:SetNWFloat("distance", BR_DrawDistance);
	self:SetNWFloat("amount", 0);
	self:GetPhysicsObject():SetMass(105);
end;
 
function ENT:SpawnFunction(ply, trace)
	local ent = ents.Create("br_money");
	ent:SetPos(trace.HitPos + trace.HitNormal * 16);
	ent:Spawn();
	ent:Activate();
     
	return ent;
end;

function ENT:Use(activator, caller)
local curTime = CurTime();
	if (!self.nextUse or curTime >= self.nextUse) then
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


function ENT:OnTakeDamage(dmginfo)
	self:VisualEffect();
end;

function ENT:VisualEffect()
	local effectData = EffectData();	
	effectData:SetStart(self:GetPos());
	effectData:SetOrigin(self:GetPos());
	effectData:SetScale(8);	
	util.Effect("GlassImpact", effectData, true, true);
	self:Remove();
end;

