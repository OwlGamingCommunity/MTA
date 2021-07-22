local myCommandsWindow = nil
local sourcePlayer = getLocalPlayer()

function commandsHelp()
	local loggedIn = getElementData(sourcePlayer, "loggedin")
	if (loggedIn == 1) then
		if (myCommandsWindow == nil) then
			guiSetInputEnabled(true)
			myCommandsWindow = guiCreateWindow (0.15, 0.15, 0.7, 0.7, "Index of all available player commands v4 (Updated on 13/5/2013)", true)
			guiWindowSetSizable(myCommandsWindow, false)
			local tabPanel = guiCreateTabPanel (0, 0.1, 1, 1, true, myCommandsWindow)
			local tlBackButton = guiCreateButton(0.8, 0.04, 0.2, 0.06, "Close", true, myCommandsWindow) -- close button

			local commands =
			{
				-- FIXME: Order each tab's contents (alphabetically)
				{
					name = "Chat",
					{ "'u'", "Press 'u' [Text]", "Quickly reply a PM.", "'u' Hello, my name is Jack. Who are you?" },
					{ "'t'", "Press 't' [IC Text]", "This is the local in character chat.", "'t' Hello, my name is Jack. Who are you?" },
					{ "'y' or /r", "/r [IC Text]", "This can be used by people who have a radio and are on the same frequency.", "/r What is your position? Over." },
					{ "/tuneradio", "/tuneradio [radio id] [frequency]", "Tunes a radio on a frequency, allowing you to speak with everyone using the same frequency. If no radio id is specified, the first radio is tuned.", "/tuneradio 100" },
					{ "/toggleradio", "/toggleradio [slot]", "Turns your radio on that slot (or if not specified, all radios you have) on/off.", "/toggleradio" },
					{ "'b' or /b", "/b [OOC Text]", "This is local out of character chat.", "/b Hey, what's going on around here?" },
					{ "/ooc", "/ooc [OOC Text]", "This is the global out of character chat.", "/ooc How is everyone?" },
					{ "/toggleooc", "/toggleooc", "Toggles global out of character chat.", "/toggleooc" },
					{ "/me", "/me [IC Action]", "Use this to simulate actions of your character.", "/me shakes the man's hand." },
					{ "/do", "/do [IC Event]", "This is used to simulate events and the surroundings. Similar to /me.", "/do The engine breaks down." },
					{ "/pm", "/pm [player] [OOC Text]", "Sends an out of character message to another player.", "/pm John_Doe Thanks for helping me." },
					{ "/togpm", "/togpm", "Toggles your PMs on or off. You can still recieve PMs from admins or friends. Only for Donators.", "/togpm" },
					{ "/s", "/s [IC Text]", "This is used to simulate your player shouting.", "/s Help! The man stole my wallet!" },
					{ "/f", "/f [OOC Text]", "This is out of character faction chat to organize roleplay. Can only be used by factions (LSPD, ...)", "/f How are my fellow faction members doing?" },
					{ "/m", "/m [IC Text]", "This allows you to speak to people in a wide radius with a megaphone.", "/m LSPD! Pull over your Vehicle!" },
					{ "/w", "/w [player] [IC Text]", "Use this to whisper to a player close to you. Only the two of you can see it.", "/w Jack_Konstantine He's looking right at me." },
					{ "/cw", "/cw [IC Text]", "Use this to whisper to all players in a vehicle with you. Only you and the other occupants can see it.", "/cw Keep an eye out. I'll be right back." },
					{ "/c", "/c [IC Text]", "Use this to talk quietly to all the players around you.", "/c He is walking right over here." },
					{ "/d or /department", "/d [IC Text]", "Department Radio for LSPD, SPD, LSES, Gov and Hex Towing.", "" },
					{ "/gov", "/gov [IC Text]", "In Character Government announcement and news.", "/gov Idlewood Gas is currently closed." },
					{ "/district", "/district [IC Text]", "Use this to talk to players in the same area of the map.", "/district Loud gunshots could be heard from around El Corona." },
					{ "/highlight", "/highlight [player] [r] [g] [b]", "Highlights all in character messages of your chosen people.", "/highlight Liza_Hawkins 0 255 255" },
				},
				{
					name = "Factions",
					{ "'F3'", "Press 'F3'", "Shows the faction menu.", "'F3'" },
					{ "/duty", "/duty", "Gives you items/weapons required for your job in an official faction.", "/duty" },
					{ "/issuebadge", "/issuebadge [player] [number/name]", "Issues a badge or ID to the player.", "/issuebadge Nathan_Daniels N.Daniels.64" },
					{ "Leaders", "/fpark", "Sets the faction vehicle's parking position where it respawns at.", "/fpark"},
					{ "Leaders", "/togglef", "Sets the Faction's OOC chat on/off.", "/togglef" },
					{ "PD", "/backup", "Puts a backup blip on your char showing other PD members where you are.", "/backup" },
					{ "PD", "/resetbackup [name]", "Removes the backup blip for the specified unit.", "/resetbackup Red" },
					{ "PD", "/fingerprint [player]", "Takes the fingerprint of the player.", "/fingerprint Richard_Banks" },
					{ "PD", "/ticket [player] [fine] [reason]", "Issues a ticket to the player.", "/ticket Richard_Banks 500 Speeding" },
					{ "PD", "/takelicense [player] [license] [hours=0]", "Takes the license from a player. They have to re-do the license later.", "/takelicense Daniela_Lane 1 20" },
					{ "PD", "/arrest [player] [fine] [minutes] [crimes]", "Arrests a player for a given amount of time.", "/arrest Daniela_Lane 500 15 Evading" },
					{ "PD", "/release [player]", "Releases a player from his arrest before the time is over.", "/release Daniela_Lane" },
					{ "PD", "/jailtime", "Shows how much time in jail you have left.", "/jailtime" },
					{ "PD", "/mdc", "Opens the Mobile Data Computer if you are in a vehicle.", "/mdc" },
					{ "PD", "/rbs", "Opens the roadblock system", "/rbs" },
					{ "PD", "/nearbyrb", "Shows the nearby roadblock's id.", "/nearbyrb" },
					{ "PD", "/delrb [id] or /delroadblock [id]", "Deletes the roadblock with that id.", "/delrb 3" },
					{ "PD", "/delallrbs or /delallroadblocks", "Deletes all roadblocks.", "/delallrbs" },
					{ "PD", "/deployspikes", "Deploys Spikes.", "/deployspikes" },
					{ "PD", "/throwspikes", "Throws Spikes.", "/throwspikes" },
					{ "PD", "/removespikes [id]", "Removes the spikes with that ID.", "/removespikes 3" },
					{ "PD", "/toll", "Opens nearby tollbooths if you are on duty.", "/toll" },
					{ "PD", "/tolllock [id]", "Locks one of the tollbooths", "/tolllock 10" },
					{ "ES", "/heal [player]", "Heals a player from all injuries and gives them full health.", "/heal Joe" },
					{ "ES", "/examine [player]", "Shows the player's injuries.", "/examine Harry" },
					{ "ES", "/firefighter", "Goes on FD Duty", "/firefighter" },
					{ "ES", "/assist", "Puts an assist beacon on your char showing other members where you are.", "/assist"},
					{ "ES", "/toll", "Opens nearby tollbooths if you are on duty.", "/toll" },
					{ "GOV", "/setbudget [faction] [amount]", "Gives a Government faction some cash into their faction bank.", "/setbudget 1 2000000" },
					{ "GOV", "/settax [percent]", "Sets the General Taxes, e.g. for buying items.", "/settax 12" },
					{ "GOV", "/setincometax [percent]", "Sets the income tax that is deducted from the wage each payday.", "/setincometax 10" },
					{ "GOV", "/setwelfare [amount]", "Sets the State Benefits unemployed people get (not in a company) per payday.", "/setwelfare 150" },
					{ "GOV", "/gettax", "Shows Tax, Income Tax and Welfare.", "/gettax" },
					{ "SAN", "/interview [player]", "Invites someone for an interview.", "/interview Hans_Vanderburg" },
					{ "SAN", "/endinterview [player]", "Ends an Interview.", "/endinterview Hans_Vanderburg" },
					{ "SAN", "/i [IC Text]", "Talks on the news if you're being interviewed.", "/i Yeah, it was pretty hard to come up with that idea." },
					{ "SAN", "/tognews", "Toggles News broadcast for you on or off.", "/tognews" },
					{ "SAN", "/news", "Sends a message to SAN. Your Phone number is included.", "/news I want to talk about Kraff." },
					{ "SAN", "/forecast", "Shows a weather forecast.", "/forecast" },
					{ "SAN", "/pollresults", "Shows the results of the elections.", "/pollresults" },
					{ "RT", "/towtruck", "Calls a towtruck to your current location.", "/towtruck" },
					{ "RT", "/resettowbackup", "Removes the blip created with /towtruck.", "/resettowbackup" },
					{ "RT", "/impoundbike", "Sets a Bike that is in the impound lot as impounded.", "/impoundbike" },
					{ "RT", "/unimpound [vehicle id]", "Sets a vehicle in the HEX Lot and unimpounded.", "/unimpound" },
					{ "LSIA", "/issuepilotcertificate [player]", "Issues a pilot certificate to the player.", "/issuepilotcertificate [player]" },
					{ "LSIA", "/atcvision", "Toggle HUD while in control tower.", "/atcvision" },
					{ "SFHR", "/makegeneric [id]", "Import new product, creating generic items for faction leaders.", "/makegeneric" },
				},
				{
					name = "Vehicles",
					{ "'J'", "Press 'J'", "Turns the engine on or off.", "'J'" },
					{ "'K'", "Press 'K'", "Locks or Unlocks the vehicle you're currently driving, or the nearest vehicle which you have a key of.", "'K'" },
					{ "'L'", "Press 'L'", "Switches the lights on or off.", "'L'" },
					{ "'P'", "Press 'P'", "Toggles the Emergency Light Beacon.", "'P'" },
					{ "'N'", "Press 'N'", "Toggles the Emergency Sirens.", "'N'" },
					{ "/switchseat ", "/switchseat ", "Switches the seat in vehicles from 0 to 3, 0 means driver seat", "/switchseat [0~3]" },
					{ "/detach", "/detach", "Detaches your vehicle's trailer (if any).", "/detach" },
					{ "/park", "/park", "Sets the vehicle's parking position where it respawns at.", "/park" },
					{ "/sell", "/sell [player]", "Sells the vehicle you're currently in to another player.", "/sell Nathan_Daniels" },
					{ "/handbrake", "/handbrake", "Applies or releases your handbrakes.", "/handbrake" },
					{ "/eject", "/eject [player]", "Throws a player out of your car.", "/eject Nathan_Daniels" },
					{ "/fill", "/fill [amount]", "Fills your vehicle with fuel if you're at a gas station either full or with the specified amount.", "/fill" },
					{ "/fillcan", "/fillcan [amount]", "Fills a fuel can at a gas station either full or with the specified amount.", "/fuelcan" },
					{ "/fastrope", "/fastrope", "Rappels down from a helicopter you sit on.", "/fastrope" },
					{ "/indicator_left", "/indicator_left", "Toggles your left indicators.", "/indicator_left" },
					{ "/indicator_right", "/indicator_right", "Toggles your right indicators.", "/indicator_left" },
					{ "/cc or /cruisecontrol", "/cc", "Enables or disables cruise control while the vehicle is moving.", "/cc" },
					{ "/togwindow", "/togwindow", "Toggles your vehicles windoes up/down.", "/togwindow" },
				},
				{
					name = "Properties",
					{ "/setbiznote [Message]", "Do this while being inside", "Sets business greeting/notification message." },
					{ "'F'", "Press 'F'", "Enters or Exits an Interior", "'F'" },
					{ "'K'", "Press 'K'", "Locks or unlocks the nearest interior you have the key for.", "'K'" },
					{ "/sell", "/sell [player]", "Sells the interior you're in to another player.", "/sell Hans_vanderburg" },
					{ "/sellproperty", "/sellproperty", "Sells the interior you're in back to the Government", "/sellproperty" },
					{ "/unrent", "/unrent", "Unrents a place you're renting.", "/unrent" },
					{ "/movesafe", "/movesafe", "Moves the safe in the interior you're in.", "/movesafe" },
					{ "/checksupplies", "/checksupplies", "Shows how many supplies you have in stock.", "/checksupplies" },
				},
				{
					name = "Items",
					{ "'I'", "Press 'I'", "Opens your inventory.", "'I'" },
					{ "'F5'", "Press 'F5'", "Shows the GPS.", "'F5'" },
					{ "/breathtest", "/breathtest [player]", "Checks a player's breath for alcohol.", "/breathtest [player]" },
					{ "/writenote", "/writenote [IC Text]", "Writes a note on a piece of a notebook.", "/writenote Call me if you want to hang out - #12345" },
					{ "/togglecradar", "/togglecradar", "Toggles the Police Radar.", "/togglecradar" },
					--{ "/call", "/call [number]", "Calls a person's phone.", "/call 12444" },
					{ "/pickup", "/pickup", "Picks up the phone when you're called.", "/pickup" },
					{ "/p", "/p [IC Text]", "Talks into the phone.", "/p Hey, how are you?" },
					{ "/loudspeaker", "/loudspeaker", "Toggles the phone's loudspeaker, letting other people around you hear the call.", "/loudspeaker" },
					{ "/hangup", "/hangup", "Hangs the phone up.", "/hangup" },
					{ "/togglephone", "/togglephone", "Toggles your phone on or off. Donators only.", "/togglephone" },
					{ "/sms", "/sms [number] [IC Text]", "Sends a text message to another phone.", "/sms 12444 I'm short on time right now, see you later." },
					{ "/sms[...]", "/sms[1-20] [number] [IC Text]", "Sends a text message to another phone from a phone not necessarily your first.", "/sms2 12444 I'm short on time right now, see you later." },
					{ "/split", "or hold 'shift' then left click on item", "Split an item into multiple items", "" },
					{ "/splits", "", "Lists all splittable item names and IDs", "" },

					--{ "/setphonebook", "/setphonebook [phone no] [new text]", "Changes the name other people see in /phonebook.", "/setphonebook 373739 Liza Hawkins" },
				},
				{
					name = "Jobs",
					{ "/startbus", "/startbus", "Starts the bus route at Unity Station.", "/startbus" },
					{ "/fish", "/fish", "Casts your line for fishing.", "/fish" },
					{ "/totalcatch", "/totalcatch", "Shows you how much lbs of fish you caught.", "/totalcatch" },
					{ "/sellfish", "/sellfish", "Sells your caught fish at the fish market.", "/sellfish" },
					{ "/copykey", "/copykey [type] [id]", "Copies a house, business or vehicle key.", "/copykey 1 50" },
					{ "/totalvalue", "/totalvalue", "Shows you the collection value of your taken photos.", "/totalvalue" },
					{ "/endjob or /quitjob", "/endjob or /quitjob", "Leaves your current job.", "/endjob" },
					{ "'Horn'", "Tap 'Horn' (short)", "Toggle your taxi lights.", "'Horn'" },
				},
				{
					name = "Misc",
					{ "/?", "/?", "Shows a basic help interface.", "/?" },
					{ "/cmds", "/cmds or /help or /helpcmds", "Shows all available player commands.", "/cmds" },
					{ "'M' or /togglecursor", "Press 'M' or type /togglecursor", "Toggles your cursor.", "'M' or /togglecursor" },
					{ "'O'", "Press 'O' or type /friends", "Toggles your friends list.", "'O' or /friends" },
					{ "'R' or /reload", "Press 'R'", "Reloads your active weapon.", "'R' or /reload" },
					{ "'F1'", "Press 'F1'", "Opens the window with the server rules and basic explanations.", "'F1'" },
					{ "'F2' or /report", "Press 'F2' or type /report", "Opens a window to report yourself or another player if you experience any problems.", "'F1' or /report" },
					{ "/endreport", "/endreport", "Closes your open report, use this if the issue has been solved.", "/endreport" },
					{ "'Tab'", "Keep 'Tab' pressed", "Shows the scoreboard with every player's ID, Name and Ping.", "'Tab'" },
					{ "/setwalk", "/setwalk [ID] or /setwalkingstyle [ID]", "Sets character walking style.", "/setwalk 128" },
					{ "/walklist", "/walklist", "Lists all available walking style IDs.", "/walklist" },
					{ "'N'", "Press 'N'", "Changes your Desert Eagle/Shotgun mode.", "'N'" },
					{ "'F6'", "Press 'F6'", "Shows the languages menu.", "'F6'" },
					{ "/togglespeedo", "/togglespeedo", "Enables or disables the speedometer.", "/togglespeedo" },
					{ "/togglelaser", "/togglelaser", "Toggles your weapon laser.", "/togglelaser" },
					{ "/clearchat", "/clearchat", "Clears your chatbox' content.", "/clearchat" },
					{ "/id", "/id [player]", "Shows the ID and name for a player with the given name/ID.", "/id Jessica_Keynes" },
					{ "/saveme", "/saveme", "Saves your current position and stats on the server, only do manually if you're bugged.", "/saveme" },
					{ "/settag", "/settag [1-8]", "Changes the tag you're spraying with a spraycan.", "/settag 2" },
					{ "/animlist", "/animlist", "Shows a list of animations.", "/animlist" },
					{ "/look", "/look [player]", "Shows age, race and a description of that character.", "/look Nathan_Daniels" },
					{ "/editlook", "/editlook", "Allows you to edit your character's look.", "/look Nathan_Daniels" },
					{ "/charity", "/charity [amount]", "Donates money to the hungry orphans.", "/charity 1337" },
					{ "/admins", "/admins", "Shows a list of all admins online and whetever they are on duty.", "/admins" },
					{ "/pay", "/pay [player] [amount]", "Gives the player some money from your wallet.", "/pay Ari_Viere 400" },
					{ "/stats", "/stats", "Shows your hours played, house ids, vehicle ids, languages etc.", "/stats" },
					{ "/timesaved", "/timesaved", "Shows how much time you have left until another payday will get you money.", "/timesaved" },
					{ "/gate", "/gate", "Opens various doors, some might require faction membership, a badge or a password", "/gate" },
					{ "/glue", "/glue", "Glues yourself or the vehicle you're driving to the nearest vehicle.", "/glue" },
					{ "/showfps", "/showfps", "Toggles the FPS counter.", "/showfps" },
					{ "/fp or cockpit", "/fp or /cockpit", "Toggles cockpit view.", "/cockpit" },
					{ "/showlicenses", "/showlicenses [player]", "Shows your driving and gun license to the player.", "/showlicenses Darren_Baker" },
					{ "/changeaccountpassword", "/changeaccountpassword [New Password] [Confirm Pass]", "changes your account password.", "" },
				}
			}
			--[[
				icreaterow = guiGridListAddRow ( chatcommandslist )
				guiGridListSetItemText ( chatcommandslist, icreaterow, chatcommand, "/i", false, false )
				guiGridListSetItemText ( chatcommandslist, icreaterow, chatcommanduse, "/i <IC text>", false, false )
				guiGridListSetItemText ( chatcommandslist, icreaterow, chatcommandexplanation, "This allows an interviewee to participate in the interview." , false, false )
				guiGridListSetItemText ( chatcommandslist, icreaterow, chatcommandexample, "/i At that time, I never thought my idea would be so successful.", false, false )
				]]

			for _, levelcmds in pairs( commands ) do
				local tab = guiCreateTab( levelcmds.name, tabPanel)
				local list = guiCreateGridList(0.02, 0.02, 0.96, 0.96, true, tab)
				guiGridListAddColumn (list, "Command", 0.15)
				guiGridListAddColumn (list, "Use", 0.2)
				guiGridListAddColumn (list, "Explanation", 0.5)
				guiGridListAddColumn (list, "Example", 0.7)
				for _, command in ipairs( levelcmds ) do
					local row = guiGridListAddRow ( list )
					guiGridListSetItemText ( list, row, 1, command[1], false, false)
					guiGridListSetItemText ( list, row, 2, command[2], false, false)
					guiGridListSetItemText ( list, row, 3, command[3], false, false)
					guiGridListSetItemText ( list, row, 4, command[4], false, false)
				end
			end

			local tabPatchNotes = guiCreateTab( "MTA Patch Notes & Information", tabPanel )
			local memoPatchNotes = guiCreateMemo (  0.02, 0.02, 0.96, 0.96, getElementData(getResourceRootElement(getResourceFromName("account-system")), "patchnotes:text") or "Error fetching patch notes...", true, tabPatchNotes )
			guiMemoSetReadOnly(memoPatchNotes, true)

			addEventHandler ("onClientGUIClick", tlBackButton, function(button, state)
				if (button == "left") then
					if (state == "up") then
						guiSetVisible(myCommandsWindow, false)
						showCursor (false)
						guiSetInputEnabled(false)
						myCommandsWindow = nil
					end
				end
			end, false)

			guiBringToFront (tlBackButton)
			guiSetVisible (myadminWindow, true)
		else
			local visible = guiGetVisible (myCommandsWindow)
			if (visible == false) then
				guiSetVisible( myCommandsWindow, true)
				showCursor (true)
			else
				showCursor(false)
			end
		end
	end
end
addCommandHandler("helpcmds", commandsHelp)
addCommandHandler("help", commandsHelp)
addCommandHandler("cmds", commandsHelp)
