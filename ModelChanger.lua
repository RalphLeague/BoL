_G.Model_Version = 1.3
_G.Model_Autoupdate = true
timeran = os.clock()
local script_downloadName = "Model Changer"
local script_downloadHost = "raw.github.com"
local script_downloadPath = "/RalphLeague/BoL/master/ModelChanger.lua" .. "?rand=" .. math.random(1, 10000)
local script_downloadUrl = "https://" .. script_downloadHost .. script_downloadPath
local script_filePath = SCRIPT_PATH .. GetCurrentEnv().FILE_NAME

function script_Messager(message) print("<font color=\"#0000E5\">" .. script_downloadName .. ":</font> <font color=\"#FFFFFF\">" .. message) end

if _G.Model_Autoupdate then
	local script_webResult = GetWebResult(script_downloadHost, script_downloadPath)
	if script_webResult then
		local script_serverVersion = string.match(script_webResult, "%s*_G.Model_Version%s+=%s+%d+%.%d+")

		if script_serverVersion then
			script_serverVersion = tonumber(string.match(script_serverVersion or "", "%d+%.?%d*"))

			if not script_serverVersion then
				script_Messager("Please contact the developer of the script \"" .. script_downloadName .. "\", since the auto updater returned an invalid version.")
				return
			end

			if _G.Model_Version < script_serverVersion then
				script_Messager("New version available: " .. script_serverVersion)
				script_Messager("Updating, please don't press F9")
				DelayAction(function () DownloadFile(script_downloadUrl, script_filePath, function() script_Messager("Successfully updated the script, please reload and check the changelog!") end) end, 2)
			else
				script_Messager("You've got the latest version: " .. script_serverVersion)
			end
		else
			script_Messager("Something went wrong, update the script manually!")
		end
	else
		script_Messager("Error downloading server version!")
	end
end

ModelNames = {
	"      OFF",
	"Cupcake",
	"New Dragon",
	"Poro", 
	"Urf", 
	"Yonkey", 
	"Azir", 
	"Vision Ward", 
	"New Red", 
	"New Blue", 
	"Gromp", 
	"Sona", 
	"New Baron", 
	"Porowl", 
	"Ironback",
	--"Shop",
	--"Monacle Guy",
	"Shark",
	"Vilemaw",
	"Pumpkin Guy",
	"Kitty",
	"Baby Dragon",
	"Snowman",
	--"Crystal Platform",
	--"Some Dude 1", 
	--"Some Dude 2",
	"Mega Poro",
	--"Turret",
	"Duckie",
	"Dragon"
	
 }
Models = {
	"OFF",
	"LuluCupcake",
	"SRU_Dragon",
	"HA_AP_Poro",
	"Urf",
	"Yonkey",
	"Azir",
	"VisionWard",
	"SRU_Red",
	"SRU_Blue",
	"SRU_Gromp",
	"SonaDJGenre01",
	"SRU_Baron",
	"Sru_Porowl",
	"BW_Ironback",
	--"sru_storekeepersouth",
	--"sru_storekeepernorth",
	"FizzShark",
	"TT_Spiderboss",
	"TT_Shopkeeper",
	"LuluKitty",
	"LuluDragon",
	"LuluSnowman",
	--"crystal_platform",
	--"Summoner_Rider_Order",
	--"Summoner_Rider_Chaos",
	"KingPoro",
	--"OrderTurretDragon",
	"Sru_Duckie",
	"redDragon",
}
function OnLoad()
	Menu()
	ModelChosen = 0
	Menu.skins = false
	Menu.flames = false
	Menu.model = 1
	check = 1
end

function skinsfun()
	if check == 1 then
		if timeran ~= nil then
			if timeran < os.clock() - 5 then
				if Menu.model ~= 1 then
					MakeModel(ModelChosen)	
					Menu.model = 1
				end
				
				if Menu.skins then
					MakeModel(myHero.charName)
					Menu.skins = false
				end
				if Menu.flames then
					MakeModel("TT_Brazier")
					Menu.flames = false
					DelayAction(function()
						MakeModel(myHero.charName)
					end, 1)
				end
			end
		end
	end
end

function Menu()
	Menu = scriptConfig("Model Changer", "ModelChanger")
		Menu:addParam("skins", "Change Me Back", SCRIPT_PARAM_ONOFF, false)
		Menu:addParam("flames", "Give My Hero Flames", SCRIPT_PARAM_ONOFF, false)
		Menu:addParam("model", "Change Model", SCRIPT_PARAM_LIST, 1, ModelNames)
		
		Menu:addParam("info4","", SCRIPT_PARAM_INFO, "")
		Menu:addParam("use", "Use Spells", SCRIPT_PARAM_ONOFF, true)  
		Menu:addParam("CastQ", "Cast Q", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('Q')) 
		Menu:addParam("CastW", "Cast W", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('W')) 
		Menu:addParam("CastE", "Cast E", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('E')) 
		Menu:addParam("CastR", "Cast R", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('R')) 
end

function OnTick()
	if check == 1 then
		if Menu.model ~= 0 then
			if Menu.model ~= 1 then
				ModelChosen = Models[Menu.model]
			end
		end
	end
	
	skinsfun()
	if Menu.use then
		if Menu.CastQ then
			CastSpell(0)
		end
		if Menu.CastW then
			CastSpell(1)
		end
		if Menu.CastE then
			CastSpell(2)
		end
		if Menu.CastR then
			CastSpell(3)
		end
	end
end
function MakeModel(modelName)
   local p = CLoLPacket(0x0055)
	p.vTable = 15718744
    p:EncodeF(player.networkID)
	p:Encode1(0xE3)
	p:Encode1(0xE3)
	p:Encode1(0xE3)
	p:Encode1(0xE3)
	p:Encode1(0x6A)
	local count = 0
	for c in modelName:gmatch'.' do
	  p:Encode1(string.byte(c))
	  count = count + 1
	end
	for i = 1, 16 - count do
		p:Encode1(0x00)
	end
	--p:Encode1(0x47)
	--p:Encode1(0x6E)
	--p:Encode1(0x61)
	--p:Encode1(0x72)
	
	p:Encode1(0x07)
	p:Encode1(0x00)
	p:Encode1(0x00)
	p:Encode1(0x00)
	p:Encode1(0x0F)
	p:Encode1(0x00)
	p:Encode1(0x00)
	p:Encode1(0x00)
	p:Hide()
--	local file = io.open(SCRIPT_PATH .. "skinchanger.txt", "a")
--	file:write(DumpPacketData(p))
--	file:close()
    RecvPacket(p)
end