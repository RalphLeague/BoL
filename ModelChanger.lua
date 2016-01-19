_G.Model_Version = 1.32
timeran = os.clock()
function Print(message) print("<font color=\"#0000E5\"> Model Changer:</font> <font color=\"#FFFFFF\">" .. message) end

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
	"Sona",
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
	local ToUpdate = {}
    ToUpdate.Version = 1.32
    ToUpdate.UseHttps = true
    ToUpdate.Host = "raw.githubusercontent.com"
    ToUpdate.VersionPath = "/RalphLeague/BoL/master/ModelChanger.version"
    ToUpdate.ScriptPath =  "/RalphLeague/BoL/master/ModelChanger.lua"
    ToUpdate.SavePath = SCRIPT_PATH.._ENV.FILE_NAME
    ToUpdate.CallbackUpdate = function(NewVersion,OldVersion) Print("Updated to v"..NewVersion) end
    ToUpdate.CallbackNoUpdate = function(OldVersion) Print("No Updates Found") end
    ToUpdate.CallbackNewVersion = function(NewVersion) Print("New Version found ("..NewVersion.."). Please wait until its downloaded") end
    ToUpdate.CallbackError = function(NewVersion) Print("Error while Downloading. Please try again.") end
   
	MCScriptUpdater(ToUpdate.Version,ToUpdate.UseHttps, ToUpdate.Host, ToUpdate.VersionPath, ToUpdate.ScriptPath, ToUpdate.SavePath, ToUpdate.CallbackUpdate,ToUpdate.CallbackNoUpdate, ToUpdate.CallbackNewVersion,ToUpdate.CallbackError)
	Print(" Version "..ToUpdate.Version.." Loaded")
	
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
		Menu:addParam("use", "Use Spells", SCRIPT_PARAM_ONOFF, false)  
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
--00 05 00 00 40 1A C0 78 78 78 1A 53 C1 C1 C1 C1 52 61 6D 6D 75 73 50 42 00 4C 6F 63 61 74 69 6F 08 00 00 00 0F 00 00 00 00 80 3F 83 
function MakeModel(modelName)
	if SetSkin then
		local mP = CLoLPacket(0x9C);
		local mObject = modelName
		
		mP.vTable = 15650104;
		mP:EncodeF(myHero.networkID);
		mP:Encode4(0xA4A4A4A4);
		mP:Encode1(0x3A);
		mP:Encode1(0x3A);
		mP:Encode1(0x3A);
		mP:Encode1(0x3A);
		mP:Encode1(0x55);
		mP:Encode1(0xAC);
		mP:Encode1(0x58);
		
		for I = 1, string.len(mObject) do
			mP:Encode1(string.byte(string.sub(mObject, I, I)));
		end;

		for I = 1, (16 - string.len(mObject)) do
			mP:Encode1(0x00);
		end;

		mP:Encode1(0x07);
		mP:Encode1(0x00);
		mP:Encode1(0x00);
		mP:Encode1(0x00);
		mP:Encode1(0x0F);
		mP:Encode1(0x00);
		mP:Encode1(0x00);
		
		mP:Encode4(0x00000000);
		mP:Encode1(0x00);
		mP:Hide();
		RecvPacket(mP);
	end
end

class "MCScriptUpdater"
function MCScriptUpdater:__init(LocalVersion,UseHttps, Host, VersionPath, ScriptPath, SavePath, CallbackUpdate, CallbackNoUpdate, CallbackNewVersion,CallbackError)
    self.LocalVersion = LocalVersion
    self.Host = Host
    self.VersionPath = '/BoL/TCPUpdater/GetScript'..(UseHttps and '5' or '6')..'.php?script='..self:Base64Encode(self.Host..VersionPath)..'&rand='..math.random(99999999)
    self.ScriptPath = '/BoL/TCPUpdater/GetScript'..(UseHttps and '5' or '6')..'.php?script='..self:Base64Encode(self.Host..ScriptPath)..'&rand='..math.random(99999999)
    self.SavePath = SavePath
    self.CallbackUpdate = CallbackUpdate
    self.CallbackNoUpdate = CallbackNoUpdate
    self.CallbackNewVersion = CallbackNewVersion
    self.CallbackError = CallbackError
    --AddDrawCallback(function() self:OnDraw() end)
    self:CreateSocket(self.VersionPath)
    self.DownloadStatus = 'Connect to Server for VersionInfo'
    AddTickCallback(function() self:GetOnlineVersion() end)
end

function MCScriptUpdater:print(str)
    print('<font color="#FFFFFF">'..os.clock()..': '..str)
end

function MCScriptUpdater:OnDraw()
    if self.DownloadStatus ~= 'Downloading Script (100%)' and self.DownloadStatus ~= 'Downloading VersionInfo (100%)'then
        DrawText('Download Status: '..(self.DownloadStatus or 'Unknown'),50,10,50,ARGB(0xFF,0xFF,0xFF,0xFF))
    end
end

function MCScriptUpdater:CreateSocket(url)
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

function MCScriptUpdater:Base64Encode(data)
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

function MCScriptUpdater:GetOnlineVersion()
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

function MCScriptUpdater:DownloadUpdate()
    if self.GotMCScriptUpdater then return end
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
        self.GotMCScriptUpdater = true
    end
end