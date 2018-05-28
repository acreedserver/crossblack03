upanel.darkrp.settings = upanel.darkrp.settings or {}

upanel.darkrp.applySettings = function()
	for k, v in pairs(upanel.darkrp.settings) do
		GAMEMODE.Config[k] = v
	end
end

if SERVER then
util.AddNetworkString("upanel_settings_network")
util.AddNetworkString("upanel_settings_set")

upanel.darkrp.saveSettings = function()
	file.Write("upanel/darkrp_settings.dat", util.TableToJSON(upanel.darkrp.settings, true))
end

upanel.darkrp.loadSavedSettings = function()
	if !upanel.isEnabled("darkrp_config") then return end

	upanel.darkrp.settings = util.JSONToTable(file.Read("upanel/darkrp_settings.dat", "DATA") or "[]")
	upanel.darkrp.applySettings()
end

hook.Add("PostGamemodeLoaded", "upanel_load_customs",upanel.darkrp.loadSavedSettings)

upanel.darkrp.networkSettings = function(ply)
	upanel.net.msg("upanel_settings_network")
	:table(upanel.darkrp.settings)
	:send(ply)
end

upanel.darkrp.changeOption = function(key, value)
	upanel.darkrp.settings[key] = value
	GAMEMODE.Config[key] = value

	upanel.darkrp.networkSettings(player.GetAll())
	upanel.darkrp.saveSettings()
end

upanel.net.receive("upanel_settings_set", function(msg)
	if !msg:isPermitted("edit_settings") then msg:fail("NOT_PERMITTED"); return end

	local t = msg:table()
	local k, v = t[1], t[2]

	upanel.darkrp.changeOption(k, v)
end)

upanel.clientSync(upanel.darkrp.networkSettings)

else

upanel.net.receive("upanel_settings_network", function(msg)
	upanel.darkrp.settings = msg:table()
	upanel.darkrp.applySettings()
end)

end

upanel.darkrp.settings_list = {
	{"voice3D", "Enable/disable 3DVoice is enabled.", true},
	{"AdminsCopWeapons", "Enable/disable admins spawning with cop weapons.", true},
	{"adminBypassJobCustomCheck", "Enable/disable whether an admin can force set a job with whenever customCheck returns false.", true},
	{"allowjobswitch", "Allow people getting their own custom jobs.", true},
	{"allowrpnames", "Allow players to Set their RP names using the /rpname command.", true},
	{"allowsprays", "Enable/disable the use of sprays on the server.", true},
	{"allowvehicleowning", "Enable/disable whether people can own vehicles.", true},
	{"allowvnocollide", "Enable/disable the ability to no-collide a vehicle (for security).", false},
	{"alltalk", "Enable for global chat, disable for local chat.", false},
	{"autovehiclelock", "Enable/disable automatic locking of a vehicle when a player exits it.", false},
	{"babygod", "People spawn godded (prevents spawn killing).", true},
	{"canforcedooropen", "Whether players can force an unownable door open with lockpick or battering ram or w/e.", true},
	{"chatsounds", "Sounds are played when some things are said in chat.", true},
	{"chiefjailpos", "Allow the Chief to set the jail positions.", true},
	{"cit_propertytax", "Enable/disable property tax that is exclusive only for citizens.", false},
	{"copscanunfreeze", "Enable/disable the ability of cops to unfreeze other people's props.", true},
	{"copscanunweld", "Enable/disable the ability of cops to unweld other people's props.", false},
	{"cpcanarrestcp", "Allow/disallow CPs to arrest other CPs.", true},
	{"currencyLeft", "The position of the currency symbol. true for left, false for right.", true},
	{"customjobs", "Enable/disable the /job command (personalized job names).", true},
	{"customspawns", "Enable/disable whether custom spawns should be used.", true},
	{"deathblack", "Whether or not a player sees black on death.", false},
	{"showdeaths", "Display kill information in the upper right corner of everyone's screen.", true},
	{"deadtalk", "Enable/disable whether people talk and use commands while dead.", true},
	{"deadvoice", "Enable/disable whether people talk through the microphone while dead.", true},
	{"deathpov", "Enable/disable whether people see their death in first person view.", false},
	{"decalcleaner", "Enable/disable clearing ever players decals.", false},
	{"disallowClientsideScripts", "Clientside scripts can be very useful for customizing the HUD or to aid in building. This option bans those scripts.", false},
	{"doorwarrants", "Enable/disable Warrant requirement to enter property.", true},
	{"dropmoneyondeath", "Enable/disable whether people drop money on death.", false},
	{"droppocketarrest", "Enable/disable whether people drop the stuff in their pockets when they get arrested.", false},
	{"droppocketdeath", "Enable/disable whether people drop the stuff in their pockets when they die.", true},
	{"dropweapondeath", "Enable/disable whether people drop their current weapon when they die.", false},
	{"dropspawnedweapons", "Whether players can drop the weapons they spawn with.", true},
	{"dynamicvoice", "Enable/disable whether only people in the same room as you can hear your mic.", true},
	{"earthquakes", "Enable/disable earthquakes.", false},
	{"enablebuypistol", "Turn /buy on of off.", true},
	{"enforceplayermodel", "Whether or not to force players to use their role-defined character models.", true},
	{"globalshow", "Whether or not to display player info above players' heads in-game.", false},
	{"ironshoot", "Enable/disable whether people need iron sights to shoot.", true},
	{"showjob", "Whether or not to display a player's job above their head in-game.", true},
	{"letters", "Enable/disable letter writing / typing.", true},
	{"license", "Enable/disable People need a license to be able to pick up guns.", false},
	{"lockdown", "Enable/disable initiating lockdowns for mayors.", true},
	{"lockpickfading", "Enable/disable the lockpicking of fading doors.", true},
	{"logging", "Enable/disable logging everything that happens.", true},
	{"lottery", "Enable/disable creating lotteries for mayors.", true},
	{"showname", "Whether or not to display a player's name above their head in-game.", true},
	{"showname", "Whether or not to display a player's health above their head in-game.", true},
	{"needwantedforarrest", "Enable/disable Cops can only arrest wanted people.", false},
	{"noguns", "Enabling this feature bans Guns and Gun Dealers.", false},
	{"norespawn", "Enable/disable that people don't have to respawn when they change job.", true},
	{"npcarrest", "Enable/disable arresting npc's.", true},
	{"ooc", "Whether or not OOC tags are enabled.", true},
	{"propertytax", "Enable/disable property tax.", false},
	{"proppaying", "Whether or not players should pay for spawning props.", false},
	{"propspawning", "Enable/disable props spawning. Applies to admins too.", true},
	{"removeclassitems", "Enable/disable shipments/microwaves/etc. removal when someone changes team.", true},
	{"removeondisconnect", "Enable/disable shipments/microwaves/etc. removal when someone disconnects.", true},
	{"respawninjail", "Enable/disable whether people can respawn in jail when they die.", true},
	{"restrictallteams", "Enable/disable Players can only be citizen until an admin allows them.", false},
	{"restrictbuypistol", "Enabling this feature makes /buy available only to Gun Dealers.", false},
	{"restrictdrop", "Enable/disable restricting the weapons players can drop. Setting this to true disallows weapons from shipments from being dropped.", false},
	{"revokeLicenseOnJobChange", "Whether licenses are revoked when a player changes jobs.", true},
	{"shouldResetLaws", "Enable/disable resetting the laws back to the default law set when the mayor changes.", false},
	{"strictsuicide", "Whether or not players should spawn where they suicided.", false},
	{"telefromjail", "Enable/disable teleporting from jail.", true},
	{"teletojail", "Enable/disable teleporting to jail.", true},
	{"unlockdoorsonstart", "Enable/Disable unlocking all doors on map start.", false},
	{"voiceradius", "Enable/disable local voice chat.", true},
	{"tax", "Whether players pay taxes on their wallets.", false},
	{"wantedsuicide", "Enable/disable suiciding while you are wanted by the police.", false},
	{"realisticfalldamage", "Enable/disable dynamic fall damage. Setting mp_falldamage to 1 will over-ride this.", true},
	{"printeroverheat", "Whether the default money printer can overheat on its own.", true},
	{"weaponCheckerHideDefault", "Hide default weapons when checking weapons.", true},
	{"weaponCheckerHideNoLicense", "Hide weapons that do not require a license.", false},
	{"adminnpcs", "Whether or not NPCs should be admin only. 0 = everyone, 1 = admin or higher, 2 = superadmin or higher, 3 = rcon only", 3},
	{"adminsents", "Whether or not SENTs should be admin only. 0 = everyone, 1 = admin or higher, 2 = superadmin or higher, 3 = rcon only", 1},
	{"adminvehicles", "Whether or not vehicles should be admin only. 0 = everyone, 1 = admin or higher, 2 = superadmin or higher, 3 = rcon only", 3},
	{"adminweapons", "Who can spawn weapons: 0: admins only, 1: supadmins only, 2: no one", 1},
	{"arrestspeed", "Sets the max arrest speed.", 120},
	{"babygodtime", "How long the babygod lasts.", 5},
	{"chatsoundsdelay", "How long to wait before letting a player emit a sound from their chat again.", 5},
	{"deathfee", "the amount of money someone drops when dead.", 30},
	{"decaltimer", "Sets the time to clear clientside decals (in seconds).", 120},
	{"demotetime", "Number of seconds before a player can rejoin a team after demotion from that team.", 120},
	{"doorcost", "Sets the cost of a door.", 30},
	{"entremovedelay", "How long to wait before removing a bought entity after disconnect.", 0},
	{"gunlabweapon", "The weapon that the gunlab spawns.", "weapon_p2282"},
	{"jailtimer", "Sets the jailtimer (in seconds).", 120},
	{"lockdowndelay", "The amount of time a mayor must wait before starting the next lockdown.", 120},
	{"maxadvertbillboards", "The maximum number of /advert billboards a player can place.", 3},
	{"maxdoors", "Sets the max amount of doors one can own.", 20},
	{"maxdrugs", "Sets max drugs.", 2},
	{"maxfoods", "Sets the max food cartons per Microwave owner.", 2},
	{"maxlawboards", "The maximum number of law boards the mayor can place.", 2},
	{"maxletters", "Sets max letters.", 10},
	{"maxlotterycost", "Maximum payment the mayor can set to join a lottery.", 250},
	{"maxvehicles", "Sets how many vehicles one can buy.", 5},
	{"microwavefoodcost", "Sets the sale price of Microwave Food.", 30},
	{"minlotterycost", "Minimum payment the mayor can set to join a lottery.", 30},
	{"moneyRemoveTime", "Money packets will get removed if they don't get picked up after a while. Set to 0 to disable.", 600},
	{"mprintamount", "Value of the money printed by the money printer.", 250},
	{"normalsalary", "Sets the starting salary for newly joined players.", 45},
	{"npckillpay", "Sets the money given for each NPC kill.", 10},
	{"paydelay", "Sets how long it takes before people get salary.", 160},
	{"pocketitems", "Sets the amount of objects the pocket can carry.", 10},
	{"pricecap", "The maximum price of items (using /price).", 500},
	{"pricemin", "The minimum price of items (using /price).", 50},
	{"propcost", "How much prop spawning should cost (prop paying must be enabled for this to have an effect).", 10},
	{"quakechance", "Chance of an earthquake happening.", 4000},
	{"respawntime", "Minimum amount of seconds a player has to wait before respawning.", 1},
	{"changejobtime", "Minimum amount of seconds a player has to wait before changing job.", 10},
	{"runspeed", "Sets the max running speed.", 240},
	{"runspeed", "Sets the max running speed for CP teams.", 255},
	{"searchtime", "Number of seconds for which a search warrant is valid.", 30},
	{"ShipmentSpawnTime", "Antispam time between spawning shipments.", 3},
	{"shipmenttime", "The number of seconds it takes for a shipment to spawn.", 10},
	{"startinghealth", "The health when you spawn.", 100},
	{"startingmoney", "Your wallet when you join for the first time.", 500},
	{"vehiclecost", "Sets the cost of a vehicle (To own it).", 40},
	{"wallettaxmax", "Maximum percentage of tax to be paid.", 5},
	{"wallettaxmin", "Minimum percentage of tax to be paid.", 1},
	{"wallettaxtime", "Time in seconds between taxing players. Requires server restart.", 600},
	{"wantedtime", "Number of seconds for which a player is wanted for.", 120},
	{"walkspeed", "Sets the max walking speed.", 160},
	{"falldamagedamper", "The damper on realistic fall damage. Default is 15. Decrease this for more damage.", 15},
	{"falldamageamount", "The base damage taken from falling for static fall damage. Default is 10.", 10},
	{"printeroverheatchance", "The likelyhood of a printer overheating. The higher this number, the less likely (minimum 3, default 22).", 22},
	{"printerreward", "Reward for destroying a money printer.", 950},

	{"MoneyClass", "The classname of money packets. Use this to create your own money entity!", "spawned_money"},
	{"moneyModel", "In case you do wish to keep the default money, but change the model, this option is the way to go:", "models/props/cs_assault/money.mdl"},
	{"lockdownsound", "You can set your own, custom sound to be played for all players whenever a lockdown is initiated.", "npc/overwatch/cityvoice/f_confirmcivilstatus_1_spkr.wav"},

	{"afkdemotetime", "The time of inactivity before being demoted.", 600},
	{"AFKDelay", "Prevent people from spamming AFK.", 300},

	{"minHitPrice", "The minimum price for a hit.", 200},
	{"maxHitPrice", "The maximum price for a hit.", 50000},
	{"minHitDistance", "The minimum distance between a hitman and his customer when they make the deal.", 150},
	{"hudText", "The text that tells the player he can press use on the hitman to request a hit.", "I am a hitman.\nPress E on me to request a hit!"},
	{"hitmanText", "The text above a hitman when he's got a hit.", "Hit\naccepted!"},
	{"hitTargetCooldown", "The cooldown time for a hit target (so they aren't spam killed).", 120},
	{"hitCustomerCooldown", "How long a customer has to wait to be able to buy another hit (from the moment the hit is accepted).", 240},
	{"hungerspeed", "Set the rate at which players will become hungry (2 is the default).", 2},
	{"starverate", "How much health that is taken away every second the player is starving  (3 is the default).", 3},
}