--I moved everything  to one file.
-- Drawing 3D2D things distance.
BR_DrawDistance = 256;

-- Robbers can steal only 16 cases from bank, regardless of money amount in vault.
BR_Bank_MaxCases = 16;
-- Shall cop get awarded?
BR_MoneyCase_RewardCop = true;
-- Reward for cop in % from case price if he returned money back by clicking 'E' on case.
BR_MoneyCase_ReturnReward = 0.1;
-- Bank vault name.
BR_BankName = "New Moscow";
-- Bank vault name color.
BR_BankNameColor = Color(96, 158, 219);
--Money income per citizen.
BR_MoneyIncome = 200;
--Money stored on start.
BR_MoneyStored = 25000;
--Max amount of money which can be stored.
BR_MaxMoneyStored = 1000000;
--Money income timer in seconds.
BR_IncomeTime = 10;
--Money expense timer in seconds.
BR_ExpenseTime = 120;
--Payment part from stored money in %.
BR_PaymentAmount = 0.025;
--Max payment part from stored money in %.
BR_MaxPaymentAmount = 0.1;
--Can mayor change payment amount?
BR_MayorPayment = true;
--Bank robbery music.
BR_RobberyMusic = "hl2_song20_submix0.mp3"
--Robber who starts robbery says 'Let's Go!'
BR_RobberyInitiator = true;
--Amount of cops required to rob the bank vault.
BR_CopsRequired = 0;
--Make wanted everyone who close to it.
BR_RobberyWanted = true;
--Combine styled report.
BR_RobberyReport = true;
--Choose money color.
BR_MoneyColor = Color(96, 158, 219, 200);
--Set up money name.
BR_MoneyName = "New Moscow Bank";
--Set up money name color.
BR_MoneyNameColor = Color(255, 255, 255, 200);
--Choose money case color.
BR_MoneyCaseColor = Color(96, 158, 219, 200);
--Players can't pocket money case. Don't set it to 'false'.
BR_MoneyCaseNoPocket = true;
--If true - money cases can be destroyed with damage
BR_MoneyCaseDamage = false;
--If true - money cases can be returned back to vault.
BR_MoneyCaseReturn = true;
--Set up money case name.
BR_MoneyCaseName = "New Moscow Bank";
--Set up money case name color.
BR_MoneyCaseNameColor = Color(96, 158, 219, 200);
--Should it be locked if stays near vault?
BR_MoneyCaseLock = true;
--Lock distance.
BR_MoneyCaseLockDistance = 2048;
--Open time while robbery on.
BR_OpenTime = 60;
--Cooldown time after robbery.
BR_CooldownTime = 3600; -- 1 hour btw
--Minimal money rob amount.
BR_MinMoneyAmount = 50;
--Maximum money rob amount.
BR_MaxMoneyAmount = 50;
--Minimal money case rob amount.
BR_MinMoneyCaseAmount = 500;
--Maximum money case rob amount.
BR_MaxMoneyCaseAmount = 500;
--Set up name for robbery boss.
BR_RobberyBoss = "Ivan";
--Set up phrases for robbery boss.
BR_RobberyPhrases = {
"Nice, nice!",
"Well done!",
"Keep robbing!",
"Good job!",
"Hurry up man, hurry up!",
"Keep it going, comeone!",
"Almost done guys!",
"We're almost finished!"
}

-- 'vault_spawn <name>' will spawn bank vault at your target position, vault fron text will be faced to you.
-- 'vault_remove <name>' removes bank vault.