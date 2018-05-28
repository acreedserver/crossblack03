EliteParty = {}
EliteParty.Color = {}
EliteParty.Language = {}
EliteParty.Parties = {}

------------------------Config Starts Here------------------------

//Main Config\\
EliteParty.ChatCommand = "!party" --The command to open the party menu.
EliteParty.PartyChatCommand = "/p" --The prefix for the party chat.
EliteParty.Debug = false --Keep false unless you want both server and client console spamming.
EliteParty.AnimSpeed = 0.5 --How fast the animations are moving.
EliteParty.InviteTimer = 10 --How long the invitation and request will stay on the screen.
EliteParty.EnablePartyTypes = true --Having this true will force a player to select a type for their party.
EliteParty.PartyTypes = { --The types a player can choose from.
	"Thiefs",
	"Raiders",
	"Cops",
	"Dirty Cops"
}
EliteParty.MaxMembers = 10 --The maximum amount of people in one party.
EliteParty.MaxDistance = 400 --How close you have to be to see the holo. If you want it to be unlimited distance, set this as 0

EliteParty.EnableHalo = true -- This will enable the halo. 
EliteParty.HUDSize = 0.5 --This is how much the hud wioll take up of someones screen. .5 is 50% of their screen.

//Color Config\\
EliteParty.Color.Header = Color(88,177,206,255)
EliteParty.Color.HeaderLeft = Color(79, 106, 125)
EliteParty.Color.HeaderBars = Color(235,235,235,255)
EliteParty.Color.HeaderText = Color(235,235,235,255)
EliteParty.Color.MainPage = Color(235,235,235,255)
EliteParty.Color.MainPageBG = Color(255,255,255,255)
EliteParty.Color.CloseButton = Color(235,235,235,255)
EliteParty.Color.Switch2 = Color(79,106,125,255)
EliteParty.Color.InstructionPanel = Color(236,32,41,255)
EliteParty.Color.Primary = Color(237,150,50,255)
EliteParty.Color.PlayerTextDark = Color(143,143,142,255)
EliteParty.Color.PlayerTextLight = Color(197,194,193,255)
EliteParty.Color.ListSeperator = Color(145,144,143,255)
EliteParty.Color.OffText = Color(234,234,234,255)
EliteParty.Color.ChatPrefix = Color(237,150,50,255)

//Language Config\\
EliteParty.Language.SelectParty = "Select a Party!"
EliteParty.Language.PartyTitle = "Party Menu"
EliteParty.Language.CreateNew = "Create a New Party"
EliteParty.Language.CreateNewTitle = "Party Creation"
EliteParty.Language.GeneralInformation = "General Information"
EliteParty.Language.ToggleInformation = "Toggleable Information"
EliteParty.Language.ColorInformation = "Color Information"
EliteParty.Language.Name = "Party Name"
EliteParty.Language.Type = "Party Type"
EliteParty.Language.DamageToggle = "Damage Toggle"
EliteParty.Language.HaloToggle = "Halo Toggle"
EliteParty.Language.RingToggle = "Ring Toggle"
EliteParty.Language.HaloColor = "Halo Color"
EliteParty.Language.RingColor = "Ring Color"
EliteParty.Language.HelpText = "These settings will be able to be changed at a future time. This is just the initial setup."
EliteParty.Language.SetTypeText = "Select a Type"
EliteParty.Language.On = "ON" -- Changing this may mess up the switches
EliteParty.Language.Off = "OFF" -- Changing this may mess up the switches
EliteParty.Language.Create = "Create Party"
EliteParty.Language.NoName = "You need to type a name!"
EliteParty.Language.OnlySpaces = "Your name cannot only consist of spaces!"
EliteParty.Language.NoType = "You must select a valid type!"
EliteParty.Language.NameExist = "That name already exists!"
EliteParty.Language.Passed = "Are you sure you want to create a party"
EliteParty.Language.PassedTwo = "with the name "
EliteParty.Language.Ok = "OK"
EliteParty.Language.No = "NO"
EliteParty.Language.Yes = "YES"
EliteParty.Language.LeaveParty = "Leave Party"
EliteParty.Language.PartyViewHeader = "Viewing Party"
EliteParty.Language.PlayerCount = "Members"
EliteParty.Language.Founder = "Founder"
EliteParty.Language.Members = "Members"
EliteParty.Language.EditSettings = "Edit Settings"
EliteParty.Language.Invite = "Invite"
EliteParty.Language.CheckLeave = "Are you sure you want to leave"
EliteParty.Language.CheckLeave2 = "this party"
EliteParty.Language.EditingPartyTitle = "Editing Party"
EliteParty.Language.SubmitChanges = "Submit Changes"
EliteParty.Language.Back = "Go Back"
EliteParty.Language.EditCheck = "Are you sure you want to edit"
EliteParty.Language.EditCheck2 = "this party"
EliteParty.Language.PlayersAvail = "Available Players"
EliteParty.Language.PlayerInvite = "Player Invite"
EliteParty.Language.InviteComp = "You have successfully invited this player"
EliteParty.Language.InviteComp2 = "to your party"
EliteParty.Language.RequestComp = "You have successfully requested to join"
EliteParty.Language.RequestComp2 = "this party"
EliteParty.Language.SomeoneInvite = "has invited you to join their party"
EliteParty.Language.LikeAccept = "Would you like to join their party"
EliteParty.Language.NoAvPlay = "There are no available players to invite"
EliteParty.Language.EParty = "Elite Party"
EliteParty.Language.ChooseCommand = "Select a Command"
EliteParty.Language.MakeFound = "Make Founder"
EliteParty.Language.Kick = "Kick"
EliteParty.Language.Choose = "Choose"
EliteParty.Language.CheckCmd = "Are you sure you want to"
EliteParty.Language.JoinedParty = "has joined your party"
EliteParty.Language.KickedMember = "has been kicked from your party"
EliteParty.Language.KickedMemberPly = "has kicked you out of the party"
EliteParty.Language.MadeFounder = "has been made founder"
EliteParty.Language.RequestJoin = "Request to Join"
EliteParty.Language.Requested = "has requested to join your party"
EliteParty.Language.RequestAccept = "Would you like to accept his request"
EliteParty.Language.AvailCommands = "Available Commands"
