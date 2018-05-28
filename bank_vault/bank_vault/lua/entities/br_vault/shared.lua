ENT.Base = "base_gmodentity";
ENT.Type = "anim";

ENT.PrintName		= "Bank Vault";
ENT.Category 		= "BR";
ENT.Author			= "EnnX49";

ENT.Contact    		= "";
ENT.Purpose 		= "";
ENT.Instructions 	= "" ;

ENT.Spawnable			= true;
ENT.AdminSpawnable		= true;

--Moved it here instead of 'init.lua' and 'cl_init.lua'.
--Since my script uses job info in both client and server files it should be stored here. Moving code below to 'br_config.lua' will not work.

--Robber teams, who can rob vault.
BR_RobberJobs = {"Mob Boss", "Gangster", "Ching Chong Leader"}
--Police teams, who get payment.
BR_PoliceJobs = {"Civil Protection", "SWAT"}
--Mayor teams, who can change payment amount for police.
BR_MayorJobs = {"Mayor"}