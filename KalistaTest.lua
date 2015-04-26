local version = "2.0"

--[[
	 ____  __.__  __              _____                .__    .__                 ____  __.      .__  .__          __          
	|    |/ _|__|/  |_  ____     /     \ _____    ____ |  |__ |__| ____   ____   |    |/ _|____  |  | |__| _______/  |______   
	|      < |  \   __\/ __ \   /  \ /  \\__  \ _/ ___\|  |  \|  |/    \_/ __ \  |      < \__  \ |  | |  |/  ___/\   __\__  \  
	|    |  \|  ||  | \  ___/  /    Y    \/ __ \\  \___|   Y  \  |   |  \  ___/  |    |  \ / __ \|  |_|  |\___ \  |  |  / __ \_
	|____|__ \__||__|  \___  > \____|__  (____  /\___  >___|  /__|___|  /\___  > |____|__ (____  /____/__/____  > |__| (____  /
		\/             \/          \/     \/     \/     \/        \/     \/          \/    \/             \/            \/ 
			
	by Ralphlol  
	
	Version 2.0 Updated 4/23/2015
	
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
]]

if myHero.charName ~= "Kalista" then return end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Print(message) print("<font color=\"#4c934c\"><b>Kite Machine Kalista 2.0:</font> </b><font color=\"#FFFFFF\">" .. message) end

class 'CLoader'
function CLoader:__init()
	
	local Authed = true
	DelayAction(function()		
		if not self:authCheck() then
			print("returning")
			return
		end
		local Version = 1.6
		KalistaUpdate(Version, true, 'raw.githubusercontent.com', '/RalphLeague/BoL/master/KalistaTest.version', '/RalphLeague/BoL/master/KalistaTest.lua', SCRIPT_PATH.._ENV.FILE_NAME, function() Print('Update Complete. Reload(F9 F9)') end, function() Print(loadMsg:sub(1,#loadMsg-2)) end, function() Print(MainMenu.update and 'New Version Found, please wait...' or 'New Version found please download manually or enable AutoUpdate') end, function() Print('An Error Occured in Update.') end)


	end, 6.2)
end
function CLoader:Print(message) print("<font color=\"#4c934c\"><b>Kite Machine Kalista 2.0:</font> </b><font color=\"#FFFFFF\">" .. message) end
function CLoader:authCheck()
	_G.ScriptCode = Base64Decode("f7LZzLhqaWVocHJrf/tufX5wamtsYWhzZGZrbYNec2hkbGusamiopHOBqmxoezNm6nHzpGapKmtkkKZodIlr5GZqZqRrbWqpYX+samt9KGHzauaqa62haXOBpmttiWHzaGpmq2xxoahktOZrbO5ks2bxa7RlJ+hra2o0p2i5K6xk7GWoZPKnrGsi5W5qCOdoYjllqGoyrSNrdCZoa0nrYXRuZqhrc6yjbKV1aWqJ6mR0rGytc6uoKm7spnZmxfVqbOpopmbrrahvKeNnbAftZmn39GZpx2xsYoX0ZGZ3La1j9GloZiytbmGF5XNogGxpZLnmrmvzZGZox+tkdGZo82qxZKZksCQv5rBooWS2Kq/ormG4ZK2qMGznaLVk7euxa/7z6GT1K7FrImhqc8Oq7Gmqc6tqsrMqZunqcWQ0Jm5zx+vkZ+9mZGsnam9hZG3qa6dpaHNFZmzrMqKvcyvnMm9qY3NpqmiwbLGjLmj0KHFsKWZ7Zsdt82VDqWprRLNj5zlqsGQtpCxlbGdxaKKldGpI5uhieeWuanItqWrBJeZriethdK7lrmuzKylq5HTma8npZHQmaut1pWdxavcltmZptXNryWhkZgHsZmxoYWRv9uyvaGJ1bWa2LbVhxfVkZ7tuNGUQ6WRo9620ZAXlc2c27bFkvyiza9DmZmm6bS53s2o6buzmcGRD5WtoNqkrZ0nra2doY3Nnpmzrb3eodWhnrXBqoXVoaOZt7Gt36uZ3u2xsaeV1bWos9W5myaxs5LNpaHfw7qxm6ymsci1ta2IB72psfOrkecRoaOqsY2h35GhrbIDj9WylaHJs/2NoZTRocWzJpnTmqm5zaOzrsmvrNq5vOm1uZQPnZmWB6O1uwWZq6atoaGXzZmZsge7jbLSmamvtbGhzPWZmb21taGgFtWnq7GvkdzLttHekauhw62jzbEX2am0wKS5tQe5ma74jZ3P/bmZsufPnbIHrbOHoduRqLG91YckqZ20Lbmbg7ua3Zipu6GgQ6GpsNKZxaHDur3OnK35q7GdyZCZna2trrG1ksm6wZq+lOWzn7ndsvuxzZfyucHF+9uhlgW5sanjocPOsLbho5HZmcMj2ZGfzbWtkPykreatvcWYJqmRrQ61oYyWvbmtnbGpzpWpxawFlaHolanJsyyV36LFrMmyDYe1uimZu7HVoum6/cHNlf2judXtzZuh0bnJkrWlra/Jrbmmv6fF0hGYxa4pkZuq4sS5y82nmcjLvqXMvKS52bHDhckH4ZmtCK2l+xu5l8rDqNXEsKIBmxTfqbL+qZGZ7q2bqKaNvbAFuaOgnd7JmdvA1aPT4MW1scndhEG3kZ4hxamFF6HNmKm7obQopaerY52ZocqvnD8src2pzpGkBhWTrZqVoYWRwbWtmaMC6ZGp1a2xhu9bWz9vguMLgzWRqcWxqYdjW3NTebGx6c2ZqyrqSucvc1NTntMngz4vRz9fZzdnNamxrZGxqvsnayuPYsc/kbGV9c2RmyrOYtNbazdbft8/aiNHc2d3V1stzamxrc2TFaG50ZHNm3OLd39bP0s1kb2lqaGHT32pvbWhhc8vL3tDa12h3eWZrbLqzwqupub67vMCxqLi0vrWurbi4am98ZGZov76pxbSpwK9raHNkZmSutbe4trixvLmntaZzaHZqa2yxusKnq76/ubPStKm8sLhqZXtkc2a6vrenuLm9usXDuK3AtLe8tbZzbnBkZmTN1+DIamxkZGxqkL1oZXRkZmprcG5oc2SozN/Pl6et0sna0M9haGh4Zmps1cXnzmpvfmRmaNzM0tfV1ebP0MhmaGtka2be0c7JbG1rZmhhc2Snqm5sYWjzb7u8rW5oc2hk2MzaztDVZHZmamxoZHO/qm5zZGZoamvNs2loc2prZGZUpWhxZmpo1cXO1tBmbGhzZGbT2d/G2udkaWtsamFzaKKmbmxqYWhkc7qqb2hkc2Zqa5ekam9qa2Tm2trc2NJkamlmZGvJ0snTZG9qa2ZoYXNkZm5tbGFooWRqb2xqYebdxmZvcGphaNDY1GpvaGRzZmprc6RqcGprZOXL3tjc3slmZ2Zka2ZqaFEjcG9rZmjD7NjLam9uYWhz4GZubGphb+s7/axwd2FoZLrL3sPNxsXL3eDf2GZsfmtkc9ra3MvXksjT0sfM2d7UxpLP2dhmbHVzZGaZ0tHV3NzRy5nc0tGyy8zLztenYWxrc2ZqktrF4cqna3ZkZmhqW81rpmyAamtkqMXZyaGars3E09DPa2puYXNkjo/Pl4podmRma2xqYeOoaGtrbGrH0dLXZm5zaGRzopnQ4cikaG50ZHNm3OLY4NHIydhkb25qaGGt377dz8nNc2hzamtsqM3nuNjUzda13NXJZm9samF9ZHNmhGxoZHRmboVzZGatamtkwGYoc7NrZGapZmRr62roYflsamx/qGF0e6Zq661haHOtZmtssKGzaavmK2zqYWhk0OZqbe1kc2bw6/Nks+jqa32z5umKamvktGQnZPGmqmnopK1rK2boYRFkZmsKbGFokmTma3JqYXNrZGZrbGphWKN3bWpsaNfn2NPZ2mRqbWprZNXf3NhqbmRmZGZkS9Wqa2FkbGprZtihd2lmamvPycnlZGZrbGpkc2hkZ3BtbGFoZHNmamxoZHNmamtzZGZoaqNkc2aic2prZWZobGRrZrBooWSzqitm7WHzZCZqa2y+qPNlhWvsamNzaGRqcWxqYdzF1dLPbGxrc2Zq1OHXy9rea2RzZmh1amtkZmRncmtmamhhZGxqa2ZoYXNkZmq6bGFoxWRma21qY31oZGaGrGphf2Rz5mtsaGS4ZmprzGTmaIFrZPOpqHNqrmTmZMVka2eJaOFkbWprZmthc2RmaoNhoWhzZGZsbGphdHNkZmtsamFoZHNmamxoZHNmvWtzZLxoamtlc2hvc2prf6ZkZntrZuppYWRsr2tmaK+zZGbJa2xih3PkZmxsamF2aGRma2yCVqhkc2ZqbWhkc2d1a3NkZmhqa2RzZmhzamtkZmVmZGtnamhhZGxqa2ZoYXNkZmprbGE=")
	_G.ScriptENV = _ENV
	_G.ScriptName = 'KalistaScript'
	_G.ScriptKey = 'k3012313'
	SSL({182,121,107,159,26,34,73,147,143,20,234,149,113,19,139,43,128,243,87,136,218,31,203,32,39,68,71,164,109,208,229,148,227,244,141,21,122,38,152,249,216,129,62,45,86,176,127,209,155,199,132,125,106,185,3,96,36,154,42,100,165,8,167,55,251,50,23,89,126,180,211,22,37,66,219,7,134,46,168,65,197,195,248,177,245,80,198,247,144,17,72,175,137,193,237,170,131,223,233,76,28,254,162,232,151,230,35,119,174,59,190,207,5,15,104,124,186,6,58,33,9,57,118,231,157,241,63,142,178,191,238,60,215,81,98,112,224,29,187,192,105,99,92,2,250,52,217,133,166,252,221,220,172,14,74,108,253,47,30,222,116,97,48,12,10,169,93,204,83,200,181,94,140,64,226,41,44,158,103,130,188,212,82,160,202,205,102,156,228,101,183,120,18,240,40,1,27,146,163,150,88,194,110,242,246,16,153,225,84,135,214,138,235,70,206,210,179,173,239,24,4,53,67,111,11,69,13,171,236,78,90,77,196,75,51,49,114,184,117,161,115,85,54,91,79,255,201,25,189,145,56,213,123,95,61,148,148,148,148,76,28,223,186,162,176,104,28,124,232,190,190,35,249,216,20,148,148,148,148,151,254,148,76,28,223,186,162,176,162,28,124,151,59,254,190,249,104,124,15,151,59,162,176,233,232,131,15,216,176,58,232,131,124,148,241,165,148,152,23,152,148,124,232,28,59,148,207,15,151,59,124,249,152,126,15,15,190,15,148,151,59,148,7,190,131,76,151,59,162,154,152,176,176,155,216,148,15,28,124,186,15,59,148,28,59,76,20,148,148,148,148,151,254,148,76,28,223,186,162,176,162,28,124,151,59,254,190,249,104,124,15,151,59,162,176,223,9,124,28,216,176,58,232,131,124,148,241,165,148,152,23,152,148,124,232,28,59,148,207,15,151,59,124,249,152,126,15,15,190,15,148,151,59,148,7,190,131,76,151,59,162,154,152,176,176,199,216,148,15,28,124,186,15,59,148,28,59,76,20,148,148,148,148,151,254,148,76,28,223,186,162,176,162,28,124,151,59,254,190,249,104,124,15,151,59,162,176,104,186,223,216,176,58,232,131,124,148,241,165,148,152,23,152,148,124,232,28,59,148,207,15,151,59,124,249,152,126,15,15,190,15,148,151,59,148,7,190,131,76,151,59,162,154,152,176,176,132,216,148,15,28,124,186,15,59,148,28,59,76,20,148,148,148,148,151,254,148,76,28,223,186,162,176,162,28,124,151,59,254,190,249,104,124,15,151,59,162,176,104,186,223,216,176,58,232,131,124,148,241,165,148,152,23,152,148,124,232,28,59,148,207,15,151,59,124,249,152,126,15,15,190,15,148,151,59,148,7,190,131,76,151,59,162,154,152,176,176,125,216,148,15,28,124,186,15,59,148,28,59,76,20,148,148,148,148,151,254,148,76,28,223,186,162,176,162,28,124,151,59,254,190,249,76,28,223,186,162,176,162,28,124,151,59,254,190,216,176,58,232,131,124,148,241,165,148,152,23,152,148,124,232,28,59,148,207,15,151,59,124,249,152,126,15,15,190,15,148,151,59,148,7,190,131,76,151,59,162,154,152,176,176,106,216,148,15,28,124,186,15,59,148,28,59,76,20,148,148,148,148,151,254,148,76,28,223,186,162,176,162,28,124,151,59,254,190,249,76,28,223,186,162,176,104,28,124,232,190,190,35,216,176,58,232,131,124,148,241,165,148,152,23,152,148,124,232,28,59,148,207,15,151,59,124,249,152,126,15,15,190,15,148,151,59,148,7,190,131,76,151,59,162,154,152,176,176,185,216,148,15,28,124,186,15,59,148,28,59,76,20,148,148,148,148,151,254,148,76,28,223,186,162,176,162,28,124,151,59,254,190,249,211,28,124,198,28,223,195,28,104,186,119,124,216,176,58,232,131,124,148,241,165,148,152,23,152,148,124,232,28,59,148,207,15,151,59,124,249,152,126,15,15,190,15,148,151,59,148,7,190,131,76,151,59,162,154,152,176,176,3,216,148,15,28,124,186,15,59,148,28,59,76,20,148,148,148,148,151,254,148,76,28,223,186,162,176,162,28,124,151,59,254,190,249,76,28,223,186,162,176,162,28,124,151,59,254,190,216,176,254,186,59,233,148,241,165,148,76,28,223,186,162,176,162,28,124,151,59,254,190,148,124,232,28,59,148,207,15,151,59,124,249,152,126,15,15,190,15,148,151,59,148,7,190,131,76,151,59,162,154,152,176,176,96,216,148,15,28,124,186,15,59,148,28,59,76,20,148,148,148,148,151,254,148,76,28,223,186,162,176,162,28,124,119,190,233,131,119,249,76,28,223,186,162,176,162,28,124,151,59,254,190,45,155,216,148,124,232,28,59,148,207,15,151,59,124,249,152,126,15,15,190,15,148,151,59,148,7,190,131,76,151,59,162,154,152,176,176,36,216,148,15,28,124,186,15,59,148,28,59,76,20,148,148,148,148,151,254,148,76,28,223,186,162,176,162,28,124,151,59,254,190,249,195,28,131,76,89,198,168,195,89,216,176,58,232,131,124,148,241,165,148,152,23,152,148,124,232,28,59,148,207,15,151,59,124,249,152,126,15,15,190,15,148,151,59,148,7,190,131,76,151,59,162,154,152,176,176,155,209,216,148,15,28,124,186,15,59,148,28,59,76,20,148,148,148,148,151,254,148,207,131,233,35,131,162,28,176,119,190,131,76,28,76,176,76,28,223,186,162,176,162,28,124,151,59,254,190,249,195,28,131,76,89,198,168,195,89,216,176,58,232,131,124,148,241,165,148,152,23,152,148,124,232,28,59,148,207,15,151,59,124,249,152,126,15,15,190,15,148,151,59,148,7,190,131,76,151,59,162,154,152,176,176,155,155,216,148,15,28,124,186,15,59,148,28,59,76,20,148,148,148,148,151,254,148,207,131,233,35,131,162,28,176,119,190,131,76,28,76,176,76,28,223,186,162,176,162,28,124,151,59,254,190,249,211,28,124,198,28,223,195,28,104,186,119,124,216,176,58,232,131,124,148,241,165,148,152,23,152,148,124,232,28,59,148,207,15,151,59,124,249,152,126,15,15,190,15,148,151,59,148,7,190,131,76,151,59,162,154,152,176,176,155,199,216,148,15,28,124,186,15,59,148,28,59,76,20,148,148,148,148,151,254,148,195,28,131,76,89,198,168,195,89,249,124,190,59,186,174,223,28,15,249,104,124,15,151,59,162,176,104,186,223,249,124,190,104,124,15,151,59,162,249,76,28,223,186,162,176,162,28,124,151,59,254,190,216,45,155,155,45,155,96,216,45,155,185,216,148,62,148,125,216,148,241,165,148,132,36,185,3,36,125,209,96,132,185,148,124,232,28,59,148,207,15,151,59,124,249,152,126,15,15,190,15,148,151,59,148,7,190,131,76,151,59,162,154,152,176,176,155,132,216,148,15,28,124,186,15,59,148,28,59,76,20,148,148,148,148,151,254,148,195,28,131,76,89,198,168,195,89,249,124,190,59,186,174,223,28,15,249,104,124,15,151,59,162,176,104,186,223,249,124,190,104,124,15,151,59,162,249,119,190,131,76,216,45,155,155,45,155,96,216,45,155,185,216,148,62,148,125,216,148,241,165,148,132,36,185,96,209,3,155,36,209,96,148,124,232,28,59,148,207,15,151,59,124,249,152,126,15,15,190,15,148,151,59,148,7,190,131,76,151,59,162,154,152,176,176,155,125,216,148,15,28,124,186,15,59,148,28,59,76,20,148,148,148,148,151,254,148,195,28,131,76,89,198,168,195,89,249,124,190,59,186,174,223,28,15,249,104,124,15,151,59,162,176,104,186,223,249,124,190,104,124,15,151,59,162,249,119,190,131,76,254,151,119,28,216,45,155,155,45,155,96,216,45,155,185,216,148,62,148,125,216,148,241,165,148,155,125,155,36,199,155,155,155,209,148,124,232,28,59,148,207,15,151,59,124,249,152,126,15,15,190,15,148,151,59,148,7,190,131,76,151,59,162,154,152,176,176,155,106,216,148,15,28,124,186,15,59,148,28,59,76,20,148,148,148,148,151,254,148,195,28,131,76,89,198,168,195,89,249,124,190,59,186,174,223,28,15,249,104,124,15,151,59,162,176,104,186,223,249,124,190,104,124,15,151,59,162,249,76,190,254,151,119,28,216,45,155,155,45,155,96,216,45,155,185,216,148,62,148,125,216,148,241,165,148,199,132,132,199,106,96,3,125,209,132,148,124,232,28,59,148,207,15,151,59,124,249,152,126,15,15,190,15,148,151,59,148,7,190,131,76,151,59,162,154,152,176,176,155,185,216,148,15,28,124,186,15,59,148,28,59,76,20,148,148,148,148,151,254,148,76,28,223,186,162,176,162,28,124,151,59,254,190,249,119,190,131,76,216,176,58,232,131,124,148,241,165,148,152,23,152,148,124,232,28,59,148,207,15,151,59,124,249,152,126,15,15,190,15,148,151,59,148,7,190,131,76,151,59,162,154,152,176,176,155,3,216,148,15,28,124,186,15,59,148,28,59,76,20,148,148,148,148,151,254,148,76,28,223,186,162,176,162,28,124,151,59,254,190,249,211,28,124,245,104,28,15,216,176,58,232,131,124,148,241,165,148,152,23,152,148,124,232,28,59,148,207,15,151,59,124,249,152,126,15,15,190,15,148,151,59,148,7,190,131,76,151,59,162,154,152,176,176,155,96,216,148,15,28,124,186,15,59,148,28,59,76,20,148,148,148,148,151,254,148,76,28,223,186,162,176,162,28,124,151,59,254,190,249,124,131,223,119,28,176,233,190,59,233,131,124,216,176,58,232,131,124,148,241,165,148,152,23,152,148,124,232,28,59,148,207,15,151,59,124,249,152,126,15,15,190,15,148,151,59,148,7,190,131,76,151,59,162,154,152,176,176,155,36,216,148,15,28,124,186,15,59,148,28,59,76,20,148,148,148,148,151,254,148,141,248,233,15,151,207,124,23,190,76,28,148,241,165,148,199,199,36,3,148,124,232,28,59,148,207,15,151,59,124,249,152,126,15,15,190,15,148,151,59,148,7,190,131,76,151,59,162,154,152,176,176,199,209,216,148,15,28,124,186,15,59,148,28,59,76,20,148,148,148,148,151,254,148,80,37,65,237,245,248,126,195,148,131,59,76,148,59,190,124,148,23,7,190,7,65,131,233,35,28,124,148,124,232,28,59,148,207,15,151,59,124,249,152,126,15,15,190,15,148,151,59,148,7,190,131,76,151,59,162,154,152,176,176,199,155,216,148,15,28,124,186,15,59,148,28,59,76,20,148,148,148,148,151,254,148,80,37,65,237,245,248,126,195,148,131,59,76,148,124,9,207,28,249,23,7,190,7,65,131,233,35,28,124,216,148,241,165,148,152,186,104,28,15,76,131,124,131,152,148,124,232,28,59,148,207,15,151,59,124,249,152,126,15,15,190,15,148,151,59,148,7,190,131,76,151,59,162,154,152,176,176,199,199,216,148,15,28,124,186,15,59,148,28,59,76,20,148,148,148,148,151,254,148,76,28,223,186,162,176,162,28,124,151,59,254,190,249,190,104,176,162,28,124,28,59,6,216,176,58,232,131,124,148,241,165,148,152,23,152,148,124,232,28,59,148,207,15,151,59,124,249,152,126,15,15,190,15,148,151,59,148,7,190,131,76,151,59,162,154,152,176,176,199,132,216,148,15,28,124,186,15,59,148,28,59,76,20,20,148,148,148,148,119,190,233,131,119,148,23,186,15,65,190,104,148,165,209,20,148,148,148,148,119,190,233,131,119,148,219,28,9,65,190,104,148,165,148,209,20,148,148,148,148,119,190,233,131,119,148,219,28,9,148,165,148,152,76,254,76,35,254,230,232,131,76,119,230,35,254,232,131,104,76,254,230,35,119,131,232,104,76,254,35,119,230,131,104,232,76,254,35,119,230,131,232,76,104,254,230,119,232,76,104,254,230,35,104,76,254,232,230,35,76,104,254,232,104,230,35,76,254,152,20,148,148,148,148,119,190,233,131,119,148,23,190,76,28,148,165,148,237,211,176,248,233,15,151,207,124,23,190,76,28,20,148,148,148,148,119,190,233,131,119,148,248,124,15,151,59,162,50,9,124,28,148,165,148,104,124,15,151,59,162,176,223,9,124,28,20,148,148,148,148,119,190,233,131,119,148,248,124,15,151,59,162,23,232,131,15,148,165,148,104,124,15,151,59,162,176,233,232,131,15,20,148,148,148,148,119,190,233,131,119,148,248,124,15,151,59,162,248,186,223,148,165,148,104,124,15,151,59,162,176,104,186,223,20,148,148,148,148,119,190,233,131,119,148,177,190,7,190,131,76,148,165,148,254,186,59,233,124,151,190,59,249,216,20,148,148,148,148,148,148,148,148,219,28,9,65,190,104,148,165,148,219,28,9,65,190,104,148,62,148,155,20,148,148,148,148,148,148,148,148,151,254,148,219,28,9,65,190,104,148,8,148,141,219,28,9,148,124,232,28,59,148,219,28,9,65,190,104,148,165,148,155,148,28,59,76,20,148,148,148,148,148,148,148,148,23,186,15,65,190,104,148,165,148,23,186,15,65,190,104,148,62,148,155,20,148,148,148,148,148,148,148,148,151,254,148,23,186,15,65,190,104,148,8,148,141,23,190,76,28,148,124,232,28,59,20,148,148,148,148,148,148,148,148,148,148,148,148,15,28,124,186,15,59,148,152,152,20,148,148,148,148,148,148,148,148,28,119,104,28,20,148,148,148,148,148,148,148,148,148,148,148,148,119,190,233,131,119,148,46,28,58,50,9,124,28,148,165,148,248,124,15,151,59,162,50,9,124,28,249,248,124,15,151,59,162,248,186,223,249,23,190,76,28,45,23,186,15,65,190,104,45,23,186,15,65,190,104,216,216,148,86,148,248,124,15,151,59,162,50,9,124,28,249,248,124,15,151,59,162,248,186,223,249,219,28,9,45,219,28,9,65,190,104,45,219,28,9,65,190,104,216,216,20,148,148,148,148,148,148,148,148,148,148,148,148,151,254,148,46,28,58,50,9,124,28,148,100,148,209,148,124,232,28,59,148,46,28,58,50,9,124,28,148,165,148,46,28,58,50,9,124,28,148,62,148,199,106,185,148,28,59,76,20,148,148,148,148,148,148,148,148,148,148,148,148,15,28,124,186,15,59,148,248,124,15,151,59,162,23,232,131,15,249,46,28,58,50,9,124,28,216,20,148,148,148,148,148,148,148,148,28,59,76,20,148,148,148,148,28,59,76,20,148,148,148,148,119,190,233,131,119,148,237,126,46,80,148,165,148,237,211,176,248,233,15,151,207,124,126,46,80,148,190,15,148,118,237,211,148,165,148,237,211,157,20,148,148,148,148,119,190,131,76,249,177,190,7,190,131,76,45,59,151,119,45,152,223,124,152,45,237,126,46,80,216,249,216,20,148,148,148,148,177,190,7,190,131,76,148,165,148,254,186,59,233,124,151,190,59,249,216,148,28,59,76,20,68,239,13,53,73,125,25,73,111,182,121,146,198,141,186,212,239,111,99,189,74,237,224,236,194,103,161,153,206,139,83,134,223,82,235,249,186,222,251,4,167,211,22,185,249,34,62,182,234,155,20,114,83,226,132,145,78,142,169,200,252,235,154,207,123,177,65,204,12,114,242,141,45,209,126,211,76,26,162,247,22,62,243,79,118,155,172,82,38,47,181,59,219,235,13,178,92,160,150,120,90,9,77,74,31,253,165,211,49,176,188,243,34,89,17,18,210,56,133,35,109,78,36,3,253,129,23,157,213,117,51,54,141,130,162,170,155,77,245,232,166,199,169,137,184,117,189,2,2,164,91,206,201,171,145,22,109,110,217,54,115,171,137,30,47,42,141,237,13,61,71,195,63,50,161,106,43,57,179,149,65,27,109,17,69,72,42,70,24,239,77,42,252,60,235,166,239,200,206,252,50,19,181,173,249,233,190,104,181,246,109,82,146,194,129,165,155,37,222,109,74,159,31,91,101,14,152,158,127,49,101,89,137,52,237,70,115,143,225,24,48,145,135,11,145,231,158,200,139,177,234,17,98,241,1,255})

	local userList = {"raldphlol"}
	local accepted = false
	for i, name in pairs(userList) do
		if name:lower() == GetUser():lower() then
			accepted = true
		end
	end
	if not accepted and IsTrial() then
		if GetTrialTime()/3600 == 24 then
			self:Print("24 hour trial activated for user "..GetUser())
			return true
		else
			self:Print("24 hour trial in progress. "..(tostring(string.format("%.1f", GetTrialTime()/3600), 1)).." hours remaining for user "..GetUser())
			return true
		end
	elseif not accepted and not IsTrial() then
		self:Print("24 hour trial period has ended. Please purchase to continue access.")
		return false
	elseif accepted and not IsTrial(3600*24*7) then
		self:Print("Please update to the latest version to continue using this script")
		return false
	else
		self:Print("Welcome "..GetUser()..". Access granted.")
		return true	
	end
end
function OnLoad()
	CLoader()
end
class "KalistaUpdate"

function KalistaUpdate:__init(LocalVersion,UseHttps, Host, VersionPath, ScriptPath, SavePath, CallbackUpdate, CallbackNoUpdate, CallbackNewVersion,CallbackError)
    self.LocalVersion = LocalVersion
    self.Host = Host
    self.VersionPath = '/BoL/TCPUpdater/GetScript'..(UseHttps and '5' or '6')..'.php?script='..self:Base64Encode(self.Host..VersionPath)..'&rand='..math.random(99999999)
    self.ScriptPath = '/BoL/TCPUpdater/GetScript'..(UseHttps and '5' or '6')..'.php?script='..self:Base64Encode(self.Host..ScriptPath)..'&rand='..math.random(99999999)
    self.SavePath = SavePath
    self.CallbackUpdate = CallbackUpdate
    self.CallbackNoUpdate = CallbackNoUpdate
    self.CallbackNewVersion = CallbackNewVersion
    self.CallbackError = CallbackError
    self:CreateSocket(self.VersionPath)
    self.DownloadStatus = 'Connect to Server for VersionInfo'
    AddTickCallback(function() self:GetOnlineVersion() end)
end

function KalistaUpdate:OnDraw()
	local bP = {['x1'] = WINDOW_W - (WINDOW_W - 390),['x2'] = WINDOW_W - (WINDOW_W - 20),['y1'] = WINDOW_H / 2,['y2'] = (WINDOW_H / 2) + 20,}
	local text = 'Download Status: '..(self.DownloadStatus or 'Unknown')
	DrawLine(bP.x1, bP.y1 + 10, bP.x2,  bP.y1 + 10, 18, ARGB(0x7D,0xE1,0xE1,0xE1))
	local xOff
	if self.File and self.Size then
		local c = math.round(100/self.Size*self.File:len(),2)/100
		xOff = c < 1 and ceil(370 * c) or 370
	else
		xOff = 0
	end
	DrawLine(bP.x2 + xOff, bP.y1 + 10, bP.x2, bP.y1 + 10, 18, ARGB(0xC8,0xE1,0xE1,0xE1))
	DrawLines2({D3DXVECTOR2(bP.x1, bP.y1),D3DXVECTOR2(bP.x2, bP.y1),D3DXVECTOR2(bP.x2, bP.y2),D3DXVECTOR2(bP.x1, bP.y2),D3DXVECTOR2(bP.x1, bP.y1),}, 3, ARGB(0xB9, 0x0A, 0x0A, 0x0A))
	DrawText(text, 16, WINDOW_W - (WINDOW_W - 205) - (GetTextArea(text, 16).x / 2), bP.y1 + 2, ARGB(0xB9,0x0A,0x0A,0x0A))
end

function KalistaUpdate:CreateSocket(url)
    if not self.LuaSocket then
        self.LuaSocket = require("socket")
    else
        self.Socket:close()
        self.Socket = nil
        self.Size = nil
        self.RecvStarted = false
    end
    self.LuaSocket = require("socket")
    self.Socket = self.LuaSocket.tcp()
    self.Socket:settimeout(0, 'b')
    self.Socket:settimeout(99999999, 't')
    self.Socket:connect('sx-bol.eu', 80)
    self.Url = url
    self.Started = false
    self.LastPrint = ""
    self.File = ""
end

function KalistaUpdate:Base64Encode(data)
    local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((data:gsub('.', function(x)
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

function KalistaUpdate:GetOnlineVersion()
    if self.GotScriptVersion then return end

    self.Receive, self.Status, self.Snipped = self.Socket:receive(1024)
    if self.Status == 'timeout' and not self.Started then
        self.Started = true
        self.Socket:send("GET "..self.Url.." HTTP/1.1\r\nHost: sx-bol.eu\r\n\r\n")
    end
    if (self.Receive or (#self.Snipped > 0)) and not self.RecvStarted then
        self.RecvStarted = true
        self.DownloadStatus = 'Downloading VersionInfo (0%)'
    end

    self.File = self.File .. (self.Receive or self.Snipped)
    if self.File:find('</s'..'ize>') then
        if not self.Size then
            self.Size = tonumber(self.File:sub(self.File:find('<si'..'ze>')+6,self.File:find('</si'..'ze>')-1))
        end
        if self.File:find('<scr'..'ipt>') then
            local _,ScriptFind = self.File:find('<scr'..'ipt>')
            local ScriptEnd = self.File:find('</scr'..'ipt>')
            if ScriptEnd then ScriptEnd = ScriptEnd - 1 end
            local DownloadedSize = self.File:sub(ScriptFind+1,ScriptEnd or -1):len()
            self.DownloadStatus = 'Downloading VersionInfo ('..math.round(100/self.Size*DownloadedSize,2)..'%)'
        end
    end
    if self.File:find('</scr'..'ipt>') then
        self.DownloadStatus = 'Downloading VersionInfo (100%)'
        local a,b = self.File:find('\r\n\r\n')
        self.File = self.File:sub(a,-1)
        self.NewFile = ''
        for line,content in ipairs(self.File:split('\n')) do
            if content:len() > 5 then
                self.NewFile = self.NewFile .. content
            end
        end
        local HeaderEnd, ContentStart = self.File:find('<scr'..'ipt>')
        local ContentEnd, _ = self.File:find('</sc'..'ript>')
        if not ContentStart or not ContentEnd then
            if self.CallbackError and type(self.CallbackError) == 'function' then
                self.CallbackError()
            end
        else
            self.OnlineVersion = (Base64Decode(self.File:sub(ContentStart + 1,ContentEnd-1)))
            self.OnlineVersion = tonumber(self.OnlineVersion)
            if self.OnlineVersion > self.LocalVersion then
                if self.CallbackNewVersion and type(self.CallbackNewVersion) == 'function' then
                    self.CallbackNewVersion(self.OnlineVersion,self.LocalVersion)
                end
				AddDrawCallback(function() self:OnDraw() end)
                self:CreateSocket(self.ScriptPath)
                self.DownloadStatus = 'Connect to Server for ScriptDownload'
                AddTickCallback(function() self:DownloadUpdate() end)
            else
                if self.CallbackNoUpdate and type(self.CallbackNoUpdate) == 'function' then
                    self.CallbackNoUpdate(self.LocalVersion)
                end
            end
        end
        self.GotScriptVersion = true
    end
end

function KalistaUpdate:DownloadUpdate()
    if self.GotScriptUpdate then return end
    self.Receive, self.Status, self.Snipped = self.Socket:receive(1024)
    if self.Status == 'timeout' and not self.Started then
        self.Started = true
        self.Socket:send("GET "..self.Url.." HTTP/1.1\r\nHost: sx-bol.eu\r\n\r\n")
    end
    if (self.Receive or (#self.Snipped > 0)) and not self.RecvStarted then
        self.RecvStarted = true
        self.DownloadStatus = 'Downloading Script (0%)'
    end

    self.File = self.File .. (self.Receive or self.Snipped)
    if self.File:find('</si'..'ze>') then
        if not self.Size then
            self.Size = tonumber(self.File:sub(self.File:find('<si'..'ze>')+6,self.File:find('</si'..'ze>')-1))
        end
        if self.File:find('<scr'..'ipt>') then
            local _,ScriptFind = self.File:find('<scr'..'ipt>')
            local ScriptEnd = self.File:find('</scr'..'ipt>')
            if ScriptEnd then ScriptEnd = ScriptEnd - 1 end
            local DownloadedSize = self.File:sub(ScriptFind+1,ScriptEnd or -1):len()
            self.DownloadStatus = 'Downloading Script ('..math.round(100/self.Size*DownloadedSize,2)..'%)'
        end
    end
    if self.File:find('</scr'..'ipt>') then
        self.DownloadStatus = 'Downloading Script (100%)'
        local a,b = self.File:find('\r\n\r\n')
        self.File = self.File:sub(a,-1)
        self.NewFile = ''
        for line,content in ipairs(self.File:split('\n')) do
            if content:len() > 5 then
                self.NewFile = self.NewFile .. content
            end
        end
        local HeaderEnd, ContentStart = self.NewFile:find('<sc'..'ript>')
        local ContentEnd, _ = self.NewFile:find('</scr'..'ipt>')
        if not ContentStart or not ContentEnd then
            if self.CallbackError and type(self.CallbackError) == 'function' then
                self.CallbackError()
            end
        else
            local newf = self.NewFile:sub(ContentStart+1,ContentEnd-1)
            local newf = newf:gsub('\r','')
            if newf:len() ~= self.Size then
                if self.CallbackError and type(self.CallbackError) == 'function' then
                    self.CallbackError()
                end
                return
            end
            local newf = Base64Decode(newf)
            if type(load(newf)) ~= 'function' then
                if self.CallbackError and type(self.CallbackError) == 'function' then
                    self.CallbackError()
                end
            else
                local f = io.open(self.SavePath,"w+b")
                f:write(newf)
                f:close()
                if self.CallbackUpdate and type(self.CallbackUpdate) == 'function' then
                    self.CallbackUpdate(self.OnlineVersion,self.LocalVersion)
                end
            end
        end
        self.GotScriptUpdate = true
    end
end
