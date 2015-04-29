--[[Last user push:   4/29/2015  10:40 AM EST]]
--[[
	 ____  __.__  __              _____                .__    .__                 ____  __.      .__  .__          __          
	|    |/ _|__|/  |_  ____     /     \ _____    ____ |  |__ |__| ____   ____   |    |/ _|____  |  | |__| _______/  |______   
	|      < |  \   __\/ __ \   /  \ /  \\__  \ _/ ___\|  |  \|  |/    \_/ __ \  |      < \__  \ |  | |  |/  ___/\   __\__  \  
	|    |  \|  ||  | \  ___/  /    Y    \/ __ \\  \___|   Y  \  |   |  \  ___/  |    |  \ / __ \|  |_|  |\___ \  |  |  / __ \_
	|____|__ \__||__|  \___  > \____|__  (____  /\___  >___|  /__|___|  /\___  > |____|__ (____  /____/__/____  > |__| (____  /
		\/             \/          \/     \/     \/     \/        \/     \/          \/    \/             \/            \/ 
			
	by Ralphlol  
	
	Version 2.09 Updated 4/28/2015
	
	Default Settings Highly Recommended
	
	Changelog:
		0.99   Initial
		
		0.991 
			- Added option to draw E percent damage to enemy
			
		0.992
			- Added Wall Dash Helper
			
		0.993
			- Added KS Dragon and Baron with E (May be buggy)
			- E Execute should now check all enemies not just target
			- Fixed Q harass
			- Improved accuracy of E damage
			- Other small tweaks
		
		0.994
			- Added Save Oathsworn Ally with Ult from dangerous spells (credits to Tux/monogato)
			- Added reveal enemies in bush with W (credits to ilikemean)
			- Added use E on enemies leaving range
			- Added Q as an AA reset (insta double dash OP)
			- Fixed Q
			- Added dash every time you use Q
			- Added toggle option for combo and option to orbwalk during combo and harass toggles.
			- Improved auto level spells
			- Other tweaks
			
		0.995
			- Added save oathsworn ally with ult low life and in danger. 
			- Added E execute to all large jungle monsters
			- Added E execute for minions
			- Added special laneclear key (Only attacks minions that can't die from E)
		
		0.996
			- Added Q enemy through low life minions
			- Lots of fixes
			
		0.997
			- Added option to disable E percent draw
			- Moved Q through minions to combo and harass modes
			- Fixed a bug that may have been causing FPS drops
			- Fixed Q AA reset
			- Fixed a long standing bug where Q would miss if you were casting mid dash
			- Added extended range on Q if you will be dashing.
			- Added key for the execute minion check (Set to your laneclear key)
		
		0.998
			- Improved targeting
			- Added KS with Q
			- Added cast Q if target can die from Q + E damage
			- Added mana manager for E on minions
			- Improved Q accuracy greatly
			- Improved bush reveal with W a little
		
		0.9981
			- Added option to quickly disable all FPS intense features
			- Fixed bug where E would never cast for some people
		
		0.999
			- Added new wall dash spots at dragon and baron pits.
			- Improved special laneclear
			- Changed auto level spells to let you choose for first 3 levels
			- Reworked Ult Save to allow each individual spell to be enabled or not
		
		1.00
			- Tweaks
			- Reworked Auto Level
		
		1.01
			- Tweaks
			- New wall dash spots. If the jungle camp is up, it will attack them instead of casting Q. Some bug causes the jumps by baron and dragon to randomly fail about 10%.
		
		1.02
			- Improved Q accuracy
			- Tweaked E damage calculation
			- Added E execute for Vilemaw on Twisted Treeline.
			- Added new wall dash spots and fixed some old spots.
		
		1.03
			- Various Tweaks
			- New E Damage Drawing Options!
				- Choose between draw damage indicator on health bar either ascending or descending
				- Choose between draw damage calculation either Percentage or Raw Number
		
		1.04
			- Bug fixes
			- Reworked Q Logic.... Again
			- Added notch to E damage indicator for descending method
			
		1.1
			- E usage reworked to work on patch 4.21!!!
			- Added option to use QSS/Mercurial Scimitar in combo when hard CCed
			- Added use E if a minion can be executed and an enemy has at least one stack while laneclear key is pressed (Default key "V")
			- Added use of passive dash in combo on minion if enemy is out of range
			- Changed Save low life oathsworn ally with ult to factor in how tanky they are.
			- Improved Q logic to factor in if they are changing direction often. This should increase accuracy during laning a little.
			- Updated E damage calculation for patch 4.21 buff
			
		1.11
			- Improved special laneclear key
			- Added Zed R to QSS usage
			- Added ignite to QSS usage if you will die from it
			- Changed auto-update to stop crashes (maybe)
			- Other minor tweaks
		
		1.2
			- Will now only use QSS on cait trap if an enemy is within AA range
			- Will no longer use Q or E if enemy is using Tryn ult or has Kayle ult on them
			- Bug fixes
			
		1.3
			- Auto-level spells works again
			- Harass mode will now wait for an auto reset if you are killing a minion before using Q
			- Added toggle to always check for executes on minions
			- Fixed use of E on enemy with one or more spears and at least one minion can be executed
			- Fixed E on fleeing enemies or 
			- Added use E if you are about to leave range
			
		1.4
			- Improved Q accuracy.
			- Changed Q in harass mode to only shoot if very high chance to hit. For example: When they are CCed or about to auto attack a minion. This is very useful for laning. (Work in Progress)
			- Fixed Q through low life minions.
			- Fixed Skin Hack. Credits to Jorj
			- E damage calculations should be very accurate now.
			- Passive dash off minions in Combo mode will now prioritize minions behind you for further dash distance
			- Other tweaks
		
		1.5
			- New buff packets are working. Everything should be faster and more accurate.
			- Other various tweaks.
		
		1.6
			- Fixed bug with wall dashing
			- Fixed smart last hit with E to not do on minions you are already attacking
			- Fixed Dragon E calculation due to dragon taking 7% reduced damage per dragon killed
			- Fixed E bugs
			- Fixed Q harass
			- QSS/Merc Scimitar usage is now packet based resulting in faster response
			- Other tweaks
			
		1.62
			- Fixed some stuff with QSS usage
			- Fixed E calculation while exhausted
			- Added toggle to turn off execute minions that you can't last hit in time (You still need one of the options or keys on that checks minion execution)
			- Some other tweaks and fixes
			
		1.63
			- Added option to stop using E on enemy with one or more spears and at least one minion can be executed at your specificed level. At low levels this increases DPS at higher levels it lowers DPS
			- Made attempted fix for CN users
			
		1.64
			- Added option to set Soul-Marked enemies as highest priority target (Turn off/on from general settings)
			- Added Absolute option to turn off any minion farming (Turn off/on from main menu)
			- Other bugs and fixes
			
		1.66
			- Fixed Auto Level
			- Fixed other bugs
		
		1.67
			- Fixed various stuff

		1.681
			- Fixed buff packets
		
		1.69
			- Fixed E extended range
			- Fixed item casting
			- Re-enabled auto-level
			- Fixed packets
		
		1.7
			- Added advanced harass mode option. (If enemy has E stacks will attack minions to get E to go off) (Don't use this if you don't understand how Kalista works)
			- Added option for Blitcrank Ult Combo (Balista)
			- Improved E minions you can't last hit in time.
			- Fixed Baron E calculation when he debuffs you
			- Fixed W on enemies hiding in bushes and added use of ward/trinket/scrying orb.
			- Removed option to disable FPS intense features
			- Fixed some occurrences of double E bug
			- Other tweaks
			
		1.72
			- Fixed saving mana for E.
			- Improved accuracy for laning phase and harass mode.
			- Fixed more occurrences of the double rend bug.
			- Some other minor stuff.
		
		1.73
			- Added all wall jump spots from Cloudrop version. More than doubling the amount. Should include every possible spot on Summoners Rift.
			- Improved Q casting a little more.
			- Added Q to Shaco invisible jump spot.
			
		1.75
			- Removed auto-update
			- Removed Baron Targeting Debug
		
		1.76 
			- Added option to use Divine Prediction
			
		1.771
			- Fixed E bug
		
		1.772
			- Many tweaks
			- Advanced Mode Enabled
			
		1.78
			- Changed E Damage Drawing to be more visible
			- New E Damage Drawing - Show Attacks Remaining to Kill
			- Added new button to cast W bug. Ghost will get stuck and last indefinitely. Will cast to Dragon or Baron whichever is closer.
			- Other random changes.
			
		1.8
			- Made wall jumping a little faster
			- Added a subtle color change on the E number drawing if the enemy is out of cast range or extended cast range.
			- Added option to disable auto-buy starting items
			- Divine Prediction has been disabled until it works better
			
		1.9
			- Added option to manual adjust E damage calculation. Negative % will execute later, postive is sooner. (Only adjust if you have issues)
			- Added mastery option for Double-Edge Sword
			- Now properly calculates super minion buffed healths
			- Added option to draw W range on the minimap
			- Tweaked Q accuracy
			- Improved wall jumping when enemies are near
			- Improved special lane clear
			- Added key for R, hold down to cast faster than normal
			- Other minor tweaks and fixes
			
		2.0	       Starting with this update the script will be paid. Purchasing will include access to the future Cloudrop version.
			- Implemented custom target selector that factors in spears in enemy into the effective health. No longer will it target the enemy with 500hp and 0 spears over the enemy with 600hp and 50 spears. 
			- Added support for every shield factored into execute calculation
			- Added support for every damage amplifier/reducer factored into execute calculation (Example: Alistar R, Master Yi W)
			- E calculation will factor in Blitzcrank and Volibear passives.
			- Added option to cast E if you are about to die
			- Added option to choose which Jungle monsters you execute
			- Added option to disable jungle execute for first 2.1 minutes
			- New and improved E stack tracking
			- Added many new spells to save ally from. These include: Varus Ult, Sona ult, Graves ult, Lissandra ult, Leona E, Hecarim R, and many more!
			- Ult Save Health can be configured separately for each spell.
			- Added protect ally from Karthus ult
			- Made the manual E damage calculation adjustment easier to understand
			- Special Laneclear renamed to Advanced Laneclear
				- This is used on a different key than Orbwalker laneclear
				- Choose to clear with Q going through desired amount of minions
				- Will attack until minion is low enough then will switch to next minion.
				- Can choose to switch minion at E execute health or at Q health.
				- Will detect if you have Runaan's Hurricane and do special method for it.
			- Added option to disable permashows (requires restart)
			- Added option to disaable E execute enemies
			- Fixed Q mana bug
			- Fixed last hit with E under tower
			- Added option to adjust last hit with E. Higher will use more often.
			- New drawing options
			- Re-Added Auto-level.
			- Re-Added Divine Prediction
			- Added HPrediction
			- Entire script overhauled for optimization.
			- Other improvements and tweaks overall
			
		2.05
		
			-  Attempted fix for unregistered class error
]]

_G.ScriptENV = _ENV
SSL({176,20,188,244,153,154,121,136,212,78,245,196,118,6,34,124,213,248,135,56,25,183,47,75,160,81,171,250,164,134,55,206,230,45,252,251,131,174,123,240,238,157,15,7,2,181,129,59,70,144,32,31,36,156,116,120,247,234,68,54,8,41,50,99,139,194,126,113,106,219,83,84,216,21,150,89,95,170,105,193,162,175,37,142,28,11,13,65,40,80,182,85,185,241,69,236,235,49,202,172,221,18,100,130,155,208,22,90,44,26,74,57,53,107,233,71,92,94,226,209,110,246,145,218,128,79,178,249,159,148,58,191,72,27,42,215,127,14,64,132,12,189,203,137,237,96,103,184,173,3,39,254,38,60,151,168,205,119,61,76,141,166,73,163,5,86,220,197,167,207,211,222,87,17,88,66,177,16,214,225,232,147,24,122,255,190,210,242,195,117,104,19,23,111,133,146,200,198,186,112,1,48,158,97,114,149,201,187,165,62,108,115,125,143,140,152,227,239,192,109,46,180,101,102,29,229,30,204,33,9,91,67,179,63,253,231,98,228,161,217,138,243,224,10,169,223,52,35,77,4,82,93,43,199,51,206,206,206,206,172,221,49,92,100,181,233,221,71,130,74,74,22,240,238,78,206,206,206,206,155,18,206,172,221,49,92,100,181,100,221,71,155,26,18,74,240,233,71,107,155,26,100,181,202,130,235,107,238,181,226,130,235,71,206,79,8,206,123,126,123,206,71,130,221,26,206,57,107,155,26,71,240,123,106,107,107,74,107,206,155,26,206,89,74,235,172,155,26,100,234,123,181,181,70,238,206,107,221,71,92,107,26,206,221,26,172,78,206,206,206,206,155,18,206,172,221,49,92,100,181,100,221,71,155,26,18,74,240,233,71,107,155,26,100,181,49,110,71,221,238,181,226,130,235,71,206,79,8,206,123,126,123,206,71,130,221,26,206,57,107,155,26,71,240,123,106,107,107,74,107,206,155,26,206,89,74,235,172,155,26,100,234,123,181,181,144,238,206,107,221,71,92,107,26,206,221,26,172,78,206,206,206,206,155,18,206,172,221,49,92,100,181,100,221,71,155,26,18,74,240,233,71,107,155,26,100,181,233,92,49,238,181,226,130,235,71,206,79,8,206,123,126,123,206,71,130,221,26,206,57,107,155,26,71,240,123,106,107,107,74,107,206,155,26,206,89,74,235,172,155,26,100,234,123,181,181,32,238,206,107,221,71,92,107,26,206,221,26,172,78,206,206,206,206,155,18,206,172,221,49,92,100,181,100,221,71,155,26,18,74,240,233,71,107,155,26,100,181,233,92,49,238,181,226,130,235,71,206,79,8,206,123,126,123,206,71,130,221,26,206,57,107,155,26,71,240,123,106,107,107,74,107,206,155,26,206,89,74,235,172,155,26,100,234,123,181,181,31,238,206,107,221,71,92,107,26,206,221,26,172,78,206,206,206,206,155,18,206,172,221,49,92,100,181,100,221,71,155,26,18,74,240,172,221,49,92,100,181,100,221,71,155,26,18,74,238,181,226,130,235,71,206,79,8,206,123,126,123,206,71,130,221,26,206,57,107,155,26,71,240,123,106,107,107,74,107,206,155,26,206,89,74,235,172,155,26,100,234,123,181,181,36,238,206,107,221,71,92,107,26,206,221,26,172,78,206,206,206,206,155,18,206,172,221,49,92,100,181,100,221,71,155,26,18,74,240,172,221,49,92,100,181,233,221,71,130,74,74,22,238,181,226,130,235,71,206,79,8,206,123,126,123,206,71,130,221,26,206,57,107,155,26,71,240,123,106,107,107,74,107,206,155,26,206,89,74,235,172,155,26,100,234,123,181,181,156,238,206,107,221,71,92,107,26,206,221,26,172,78,206,206,206,206,155,18,206,172,221,49,92,100,181,100,221,71,155,26,18,74,240,83,221,71,13,221,49,175,221,233,92,90,71,238,181,226,130,235,71,206,79,8,206,123,126,123,206,71,130,221,26,206,57,107,155,26,71,240,123,106,107,107,74,107,206,155,26,206,89,74,235,172,155,26,100,234,123,181,181,116,238,206,107,221,71,92,107,26,206,221,26,172,78,206,206,206,206,155,18,206,172,221,49,92,100,181,100,221,71,155,26,18,74,240,172,221,49,92,100,181,100,221,71,155,26,18,74,238,181,18,92,26,202,206,79,8,206,172,221,49,92,100,181,100,221,71,155,26,18,74,206,71,130,221,26,206,57,107,155,26,71,240,123,106,107,107,74,107,206,155,26,206,89,74,235,172,155,26,100,234,123,181,181,120,238,206,107,221,71,92,107,26,206,221,26,172,78,206,206,206,206,155,18,206,172,221,49,92,100,181,100,221,71,90,74,202,235,90,240,172,221,49,92,100,181,100,221,71,155,26,18,74,7,70,238,206,71,130,221,26,206,57,107,155,26,71,240,123,106,107,107,74,107,206,155,26,206,89,74,235,172,155,26,100,234,123,181,181,247,238,206,107,221,71,92,107,26,206,221,26,172,78,206,206,206,206,155,18,206,172,221,49,92,100,181,100,221,71,155,26,18,74,240,175,221,235,172,113,13,105,175,113,238,181,226,130,235,71,206,79,8,206,123,126,123,206,71,130,221,26,206,57,107,155,26,71,240,123,106,107,107,74,107,206,155,26,206,89,74,235,172,155,26,100,234,123,181,181,70,59,238,206,107,221,71,92,107,26,206,221,26,172,78,206,206,206,206,155,18,206,57,235,202,22,235,100,221,181,90,74,235,172,221,172,181,172,221,49,92,100,181,100,221,71,155,26,18,74,240,175,221,235,172,113,13,105,175,113,238,181,226,130,235,71,206,79,8,206,123,126,123,206,71,130,221,26,206,57,107,155,26,71,240,123,106,107,107,74,107,206,155,26,206,89,74,235,172,155,26,100,234,123,181,181,70,70,238,206,107,221,71,92,107,26,206,221,26,172,78,206,206,206,206,155,18,206,57,235,202,22,235,100,221,181,90,74,235,172,221,172,181,172,221,49,92,100,181,100,221,71,155,26,18,74,240,83,221,71,13,221,49,175,221,233,92,90,71,238,181,226,130,235,71,206,79,8,206,123,126,123,206,71,130,221,26,206,57,107,155,26,71,240,123,106,107,107,74,107,206,155,26,206,89,74,235,172,155,26,100,234,123,181,181,70,144,238,206,107,221,71,92,107,26,206,221,26,172,78,206,206,206,206,155,18,206,175,221,235,172,113,13,105,175,113,240,71,74,26,92,44,49,221,107,240,233,71,107,155,26,100,181,233,92,49,240,71,74,233,71,107,155,26,100,240,172,221,49,92,100,181,100,221,71,155,26,18,74,238,7,70,70,7,70,120,238,7,70,156,238,206,15,206,31,238,206,79,8,206,32,247,156,116,247,31,59,120,32,156,206,71,130,221,26,206,57,107,155,26,71,240,123,106,107,107,74,107,206,155,26,206,89,74,235,172,155,26,100,234,123,181,181,70,32,238,206,107,221,71,92,107,26,206,221,26,172,78,206,206,206,206,155,18,206,175,221,235,172,113,13,105,175,113,240,71,74,26,92,44,49,221,107,240,233,71,107,155,26,100,181,233,92,49,240,71,74,233,71,107,155,26,100,240,90,74,235,172,238,7,70,70,7,70,120,238,7,70,156,238,206,15,206,31,238,206,79,8,206,32,247,156,120,59,116,70,247,59,120,206,71,130,221,26,206,57,107,155,26,71,240,123,106,107,107,74,107,206,155,26,206,89,74,235,172,155,26,100,234,123,181,181,70,31,238,206,107,221,71,92,107,26,206,221,26,172,78,206,206,206,206,155,18,206,175,221,235,172,113,13,105,175,113,240,71,74,26,92,44,49,221,107,240,233,71,107,155,26,100,181,233,92,49,240,71,74,233,71,107,155,26,100,240,90,74,235,172,18,155,90,221,238,7,70,70,7,70,120,238,7,70,156,238,206,15,206,31,238,206,79,8,206,70,31,70,247,144,70,70,70,59,206,71,130,221,26,206,57,107,155,26,71,240,123,106,107,107,74,107,206,155,26,206,89,74,235,172,155,26,100,234,123,181,181,70,36,238,206,107,221,71,92,107,26,206,221,26,172,78,206,206,206,206,155,18,206,175,221,235,172,113,13,105,175,113,240,71,74,26,92,44,49,221,107,240,233,71,107,155,26,100,181,233,92,49,240,71,74,233,71,107,155,26,100,240,172,74,18,155,90,221,238,7,70,70,7,70,120,238,7,70,156,238,206,15,206,31,238,206,79,8,206,144,32,32,144,36,120,116,31,59,32,206,71,130,221,26,206,57,107,155,26,71,240,123,106,107,107,74,107,206,155,26,206,89,74,235,172,155,26,100,234,123,181,181,70,156,238,206,107,221,71,92,107,26,206,221,26,172,78,206,206,206,206,155,18,206,172,221,49,92,100,181,100,221,71,155,26,18,74,240,90,74,235,172,238,181,226,130,235,71,206,79,8,206,123,126,123,206,71,130,221,26,206,57,107,155,26,71,240,123,106,107,107,74,107,206,155,26,206,89,74,235,172,155,26,100,234,123,181,181,70,116,238,206,107,221,71,92,107,26,206,221,26,172,78,206,206,206,206,155,18,206,172,221,49,92,100,181,100,221,71,155,26,18,74,240,83,221,71,28,233,221,107,238,181,226,130,235,71,206,79,8,206,123,126,123,206,71,130,221,26,206,57,107,155,26,71,240,123,106,107,107,74,107,206,155,26,206,89,74,235,172,155,26,100,234,123,181,181,70,120,238,206,107,221,71,92,107,26,206,221,26,172,78,206,206,206,206,155,18,206,172,221,49,92,100,181,100,221,71,155,26,18,74,240,71,235,49,90,221,181,202,74,26,202,235,71,238,181,226,130,235,71,206,79,8,206,123,126,123,206,71,130,221,26,206,57,107,155,26,71,240,123,106,107,107,74,107,206,155,26,206,89,74,235,172,155,26,100,234,123,181,181,70,247,238,206,107,221,71,92,107,26,206,221,26,172,78,206,206,206,206,155,18,206,252,37,202,107,155,57,71,126,74,172,221,206,79,8,206,70,36,70,36,116,116,206,71,130,221,26,206,57,107,155,26,71,240,123,106,107,107,74,107,206,155,26,206,89,74,235,172,155,26,100,234,123,181,181,144,59,238,206,107,221,71,92,107,26,206,221,26,172,78,206,206,206,206,155,18,206,11,216,193,69,28,37,106,175,206,235,26,172,206,26,74,71,206,126,89,74,89,193,235,202,22,221,71,206,71,130,221,26,206,57,107,155,26,71,240,123,106,107,107,74,107,206,155,26,206,89,74,235,172,155,26,100,234,123,181,181,144,70,238,206,107,221,71,92,107,26,206,221,26,172,78,206,206,206,206,155,18,206,11,216,193,69,28,37,106,175,206,235,26,172,206,71,110,57,221,240,126,89,74,89,193,235,202,22,221,71,238,206,79,8,206,123,92,233,221,107,172,235,71,235,123,206,71,130,221,26,206,57,107,155,26,71,240,123,106,107,107,74,107,206,155,26,206,89,74,235,172,155,26,100,234,123,181,181,144,144,238,206,107,221,71,92,107,26,206,221,26,172,78,206,206,206,206,155,18,206,172,221,49,92,100,181,100,221,71,155,26,18,74,240,74,233,181,100,221,71,221,26,94,238,181,226,130,235,71,206,79,8,206,123,126,123,206,71,130,221,26,206,57,107,155,26,71,240,123,106,107,107,74,107,206,155,26,206,89,74,235,172,155,26,100,234,123,181,181,144,32,238,206,107,221,71,92,107,26,206,221,26,172,78,78,206,206,206,206,90,74,202,235,90,206,126,92,107,193,74,233,206,8,59,78,206,206,206,206,90,74,202,235,90,206,150,221,110,193,74,233,206,8,206,59,78,206,206,206,206,90,74,202,235,90,206,150,221,110,206,8,206,123,235,233,172,221,221,226,100,18,172,123,78,206,206,206,206,90,74,202,235,90,206,126,74,172,221,206,8,206,69,83,181,37,202,107,155,57,71,126,74,172,221,78,206,206,206,206,90,74,202,235,90,206,37,71,107,155,26,100,194,110,71,221,206,8,206,233,71,107,155,26,100,181,49,110,71,221,78,206,206,206,206,90,74,202,235,90,206,37,71,107,155,26,100,126,130,235,107,206,8,206,233,71,107,155,26,100,181,202,130,235,107,78,206,206,206,206,90,74,202,235,90,206,37,71,107,155,26,100,37,92,49,206,8,206,233,71,107,155,26,100,181,233,92,49,78,206,206,206,206,90,74,202,235,90,206,142,74,89,74,235,172,206,8,206,18,92,26,202,71,155,74,26,240,238,78,206,206,206,206,206,206,206,206,150,221,110,193,74,233,206,8,206,150,221,110,193,74,233,206,15,206,70,78,206,206,206,206,206,206,206,206,155,18,206,150,221,110,193,74,233,206,41,206,252,150,221,110,206,71,130,221,26,206,150,221,110,193,74,233,206,8,206,70,206,221,26,172,78,206,206,206,206,206,206,206,206,126,92,107,193,74,233,206,8,206,126,92,107,193,74,233,206,15,206,70,78,206,206,206,206,206,206,206,206,155,18,206,126,92,107,193,74,233,206,41,206,252,126,74,172,221,206,71,130,221,26,78,206,206,206,206,206,206,206,206,206,206,206,206,107,221,71,92,107,26,206,123,123,78,206,206,206,206,206,206,206,206,221,90,233,221,78,206,206,206,206,206,206,206,206,206,206,206,206,90,74,202,235,90,206,170,221,226,194,110,71,221,206,8,206,37,71,107,155,26,100,194,110,71,221,240,37,71,107,155,26,100,37,92,49,240,126,74,172,221,7,126,92,107,193,74,233,7,126,92,107,193,74,233,238,238,206,2,206,37,71,107,155,26,100,194,110,71,221,240,37,71,107,155,26,100,37,92,49,240,150,221,110,7,150,221,110,193,74,233,7,150,221,110,193,74,233,238,238,78,206,206,206,206,206,206,206,206,206,206,206,206,155,18,206,170,221,226,194,110,71,221,206,54,206,59,206,71,130,221,26,206,170,221,226,194,110,71,221,206,8,206,170,221,226,194,110,71,221,206,15,206,144,36,156,206,221,26,172,78,206,206,206,206,206,206,206,206,206,206,206,206,107,221,71,92,107,26,206,37,71,107,155,26,100,126,130,235,107,240,170,221,226,194,110,71,221,238,78,206,206,206,206,206,206,206,206,221,26,172,78,206,206,206,206,221,26,172,78,206,206,206,206,90,74,202,235,90,206,69,106,170,11,206,8,206,69,83,181,37,202,107,155,57,71,106,170,11,206,74,107,206,145,69,83,206,8,206,69,83,128,78,206,206,206,206,90,74,235,172,240,142,74,89,74,235,172,7,26,155,90,7,123,49,71,123,7,69,106,170,11,238,240,238,78,206,206,206,206,142,74,89,74,235,172,206,8,206,18,92,26,202,71,155,74,26,240,238,206,221,26,172,78,206,239,97,94,144,227,21,5,134,181,164,164,152,128,35,134,132,10,176,92,164,42,217,7,217,145,213,196,134,237,130,82,43,63,19,157,54,125,61,1,228,133,226,112,19,153,240,18,46,56,236,175,86,45,136,73,104,122,74,9,138,112,3,24,139,164,33,125,91,219,171,171,175,30,23,168,228,182,155,65,137,18,183,58,171,25,149,233,73,215,72,232,227,133,209,155,115,54,73,91,110,230,254,20,170,237,209,9,227,37,68,178,3,97,24,150,38,46,253,201,119,237,1,16,148,53,73,219,103,137,222,85,15,243,246,131,195,206,5,107,59,115,171,79,59,132,192,241,113,89,3,136,129,144,109,28,216,163,191,50,105,94,19,20,49,107,198,89,179,241,72,216,125,133,232,56,234,164,144,25,121,169,129,112,16,252,132,44,193,90,203,135,96,70,145,249,74,155,121,76,10,201,212,242,109,20,135,53,76,141,21,80,97,18,176,245,9,147,130,253,18,242,62,59,190,72,123,233,223,66,249,178,105,254,126,86,159,131,81,241,231,205,94,228,53,145,242,91,24,140,31,114,108,125,1,255})
