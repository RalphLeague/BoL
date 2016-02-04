local updatedyes = true

_G.HumanVision = true
local hvversion = 0.6

local blockMove, blockCast
local lastMessage = 0
local okMove = false
local bCount = 0

local sEnemies = GetEnemyHeroes()
local missingEnemy = {}
for i, Enemy in pairs(sEnemies) do
	missingEnemy[Enemy.charName] = os.clock()
end

local function Print(message) print("<font color=\"#0000e5\"><b>Human Vision:</font> </b><font color=\"#FFFFFF\">" .. message) end

local hvMenu = scriptConfig("Human Vision", "hvLOL")

hvMenu:addParam("info23","", SCRIPT_PARAM_INFO, "")
hvMenu:addParam("fow", "Ignore new FoW enemies", SCRIPT_PARAM_ONOFF, true)
hvMenu:addParam("msg", "Show messages", SCRIPT_PARAM_ONOFF, false)
hvMenu:addParam("info22","Total Commands Blocked: 0", SCRIPT_PARAM_INFO, "")

hvMenu:addSubMenu(myHero.charName.." Spell Whitelist", myHero.charName)
	hvMenu[myHero.charName]:addParam("0", "Spell Q", SCRIPT_PARAM_ONOFF, false)
	hvMenu[myHero.charName]:addParam("1", "Spell W", SCRIPT_PARAM_ONOFF, false)
	hvMenu[myHero.charName]:addParam("2", "Spell E", SCRIPT_PARAM_ONOFF, false)
	hvMenu[myHero.charName]:addParam("3", "Spell R", SCRIPT_PARAM_ONOFF, false)

hvMenu:addSubMenu("Movement Limiter", "move")
	hvMenu.move:addParam("enable", "Use Movement Limiter", SCRIPT_PARAM_ONOFF, true)
	hvMenu.move:addParam("info222","", SCRIPT_PARAM_INFO, "")
	hvMenu.move:addParam("info23","Max Actions Per Second", SCRIPT_PARAM_INFO, "")
	hvMenu.move:addParam("lhit", "Last Hit", SCRIPT_PARAM_SLICE, 5, 1, 20, 0)
	hvMenu.move:addParam("lclear", "Lane Clear", SCRIPT_PARAM_SLICE, 5, 1, 20, 0)
	hvMenu.move:addParam("harass", "Harass", SCRIPT_PARAM_SLICE, 7, 1, 20, 0)
	hvMenu.move:addParam("combo", "Combo", SCRIPT_PARAM_SLICE, 12, 1, 20, 0)
	hvMenu.move:addParam("perm", "Persistant", SCRIPT_PARAM_SLICE, 8, 1, 20, 0)

	
local function IsOnScreen(spot)
	local check = WorldToScreen(D3DXVECTOR3(spot.x, spot.y, spot.z))
	local x, y = check.x, check.y
	if x > 0 and x < WINDOW_W and y > 0 and y < WINDOW_H then
		return true
	end
end


local function newEnemy()
	for i, Enemy in pairs(sEnemies) do
		if not Enemy.visible then
			missingEnemy[Enemy.charName] = os.clock()
		elseif Enemy.visible and missingEnemy[Enemy.charName] ~= 0 then
			if os.clock() - missingEnemy[Enemy.charName] > 1.5 then
				missingEnemy[Enemy.charName] = 0
			end
		end
	end
end

function OnTick()
	if hvMenu.fow then
		newEnemy()
	end
end

_G.ValidTarget = function(object, distance, enemyTeam)
	local enemyTeam = (enemyTeam ~= false)
	if object ~= nil and object.valid and object.name and (object.type == myHero.type or object.type:find("obj_AI")) and object.bTargetable and (object.team ~= player.team) == enemyTeam and object.visible and not object.dead and (enemyTeam == false or object.bInvulnerable == 0) and (distance == nil or GetDistanceSqr(object) <= distance * distance) and IsOnScreen(object) then
		if hvMenu.fow and object.type == myHero.type and object.team ~= myHero.team and missingEnemy[object.charName] ~= 0 then return end
		return true
	end
end

local lastCommand = 0
function OnIssueOrder(source, order, position, target)
	if hvMenu.move.enable and os.clock() - lastCommand < moveEvery() then
		blockMove = true
		bCount = bCount + 1
		hvMenu:modifyParam("info22", "text", "Total Commands Blocked: "..bCount)
		return
	elseif order == 2 then
		if not IsOnScreen(position) then
			if okMove then okMove = false return end
			blockMove = true
			bCount = bCount + 1
			hvMenu:modifyParam("info22", "text", "Total Commands Blocked: "..bCount)
			if hvMenu.msg and os.clock() - lastMessage > 1.5 then
				Print("Blocked move")
				lastMessage = os.clock()
			end
			return
		end
	elseif order == 3 then
		if not IsOnScreen(target) then
			if okMove then okMove = false return end
			blockMove = true
			bCount = bCount + 1
			hvMenu:modifyParam("info22", "text", "Total Commands Blocked: "..bCount)
			if hvMenu.msg and os.clock() - lastMessage > 1.5 then
				Print("Blocked move")
				lastMessage = os.clock()
			end
			return
		end
	end
	
	lastCommand = os.clock()
end

local globalUlt = {["Draven"] = true, ["Ezreal"] = true, ["Jinx"] = true, ["Ashe"] = true}
local didBlockF = false
local originalCastSpell = _G.CastSpell
local posX, posZ

_G.CastSpell = function(ID, param2, param3)
	if param3 and param2 then
		local endPos = Vector(param2, myHero.y, param3)
		if ID == 3 and globalUlt[myHero.charName] and IsOnScreen(myHero.pos) then
			local ultSpot = Vector(myHero.x, myHero.y, myHero.z) + (Vector(param2, myHero.y, param3) - Vector(myHero.x, myHero.y, myHero.z)):normalized() * (80 + (math.random()*420))
			param2, param3 = ultSpot.x, ultSpot.z
		elseif ID ~= 13 and not hvMenu[myHero.charName][tostring(ID)] then
			if endPos then
				if GetDistance(endPos) > 9900 and GetDistance(endPos) < 10000 then 
					--Print("Ok cast")
				elseif not IsOnScreen(endPos) then
					--local Spot = Vector(myHero.x, myHero.y, myHero.z) + (Vector(param2, myHero.y, param3) - Vector(myHero.x, myHero.y, myHero.z)):normalized() * (80 + (math.random()*420))
					--param2, param3 = Spot.x, Spot.z
					
					bCount = bCount + 1
					hvMenu:modifyParam("info22", "text", "Total Commands Altered: "..bCount)
					if hvMenu.msg and os.clock() - lastMessage > 1.5 then
						Print("Blocked cast")
						lastMessage = os.clock()
					end
					return
				end
			end
		end
	--[[elseif param2 then
		if ID ~= 13 and not hvMenu[myHero.charName][tostring(ID)] then
		if not IsOnScreen(param2) then
			
			
			bCount = bCount + 1
			hvMenu:modifyParam("info22", "text", "Total Commands Blocked: "..bCount)
			if hvMenu.msg and os.clock() - lastMessage > 1.5 then
				Print("Blocked cast")
				lastMessage = os.clock()
			end
			return
		end]]
	end
	if param3 and param2 then
		originalCastSpell(ID, param2, param3)
	elseif param2 then
		originalCastSpell(ID, param2)
	else
		originalCastSpell(ID)
	end
end

function OnWndMsg(msg, key)
	if msg == 516 and key == 2 then
        okMove = true
    end
end

function OnSendPacket(p)
	if blockMove and p.header == 137 then
		blockMove = false
		if okMove then okMove = false return end
		p:Block()
		
		bCount = bCount + 1
		hvMenu:modifyParam("info22", "text", "Total Commands Blocked: "..bCount)
		if hvMenu.msg and os.clock() - lastMessage > 1.5 then
			Print("Blocked move")
			lastMessage = os.clock()
		end
	end
	
	if p.header == 137 and okMove then
		okMove = false
	end
end

---SxUPDATER--
do
function OnLoad()
    local ToUpdate = {}
    ToUpdate.Version = hvversion
    ToUpdate.UseHttps = true
    ToUpdate.Host = "raw.githubusercontent.com"
    ToUpdate.VersionPath = "/RalphLeague/BoL/master/HumanVision.version"
    ToUpdate.ScriptPath =  "/RalphLeague/BoL/master/HumanVision.lua"
    ToUpdate.SavePath = SCRIPT_PATH.._ENV.FILE_NAME
    ToUpdate.CallbackUpdate = function(NewVersion,OldVersion) Print("Updated to v"..NewVersion) end
    ToUpdate.CallbackNoUpdate = function(OldVersion) Print(" Version "..ToUpdate.Version.." Loaded") end
    ToUpdate.CallbackNewVersion = function(NewVersion) Print("New Version found ("..NewVersion.."). Please wait until its downloaded") end
    ToUpdate.CallbackError = function(NewVersion) Print("Error while Downloading. Please try again.") end
	if updatedyes then
		HVScriptUpdate(ToUpdate.Version,ToUpdate.UseHttps, ToUpdate.Host, ToUpdate.VersionPath, ToUpdate.ScriptPath, ToUpdate.SavePath, ToUpdate.CallbackUpdate,ToUpdate.CallbackNoUpdate, ToUpdate.CallbackNewVersion,ToUpdate.CallbackError)
	end
	
	DelayAction(findOrbwalk, 15)
end

class "HVScriptUpdate"
function HVScriptUpdate:__init(LocalVersion,UseHttps, Host, VersionPath, ScriptPath, SavePath, CallbackUpdate, CallbackNoUpdate, CallbackNewVersion,CallbackError)
    self.LocalVersion = LocalVersion
    self.Host = Host
    self.VersionPath = '/BoL/TCPUpdater/GetScript'..(UseHttps and '5' or '6')..'.php?script='..self:Base64Encode(self.Host..VersionPath)..'&rand='..math.random(99999999)
    self.ScriptPath = '/BoL/TCPUpdater/GetScript'..(UseHttps and '5' or '6')..'.php?script='..self:Base64Encode(self.Host..ScriptPath)..'&rand='..math.random(99999999)
    self.SavePath = SavePath
    self.CallbackUpdate = CallbackUpdate
    self.CallbackNoUpdate = CallbackNoUpdate
    self.CallbackNewVersion = CallbackNewVersion
    self.CallbackError = CallbackError
    AddDrawCallback(function() self:OnDraw() end)
    self:CreateSocket(self.VersionPath)
    self.DownloadStatus = 'Connect to Server for VersionInfo'
    AddTickCallback(function() self:GetOnlineVersion() end)
end

function HVScriptUpdate:print(str)
    print('<font color="#FFFFFF">'..os.clock()..': '..str)
end

function HVScriptUpdate:OnDraw()
    if self.DownloadStatus ~= 'Downloading Script (100%)' and self.DownloadStatus ~= 'Downloading VersionInfo (100%)'then
        DrawText('Download Status: '..(self.DownloadStatus or 'Unknown'),50,10,50,ARGB(0xFF,0xFF,0xFF,0xFF))
    end
end

function HVScriptUpdate:CreateSocket(url)
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

function HVScriptUpdate:Base64Encode(data)
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

function HVScriptUpdate:GetOnlineVersion()
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
            if self.OnlineVersion and self.OnlineVersion > self.LocalVersion then
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

function HVScriptUpdate:DownloadUpdate()
    if self.GotHVScriptUpdate then return end
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
        self.GotHVScriptUpdate = true
    end
end
end

local function IsLaneclear()
	if sacUsed and _G.AutoCarry.Keys.LaneClear then
		return true
	elseif sxorbUsed and SxOrb.isLaneClear then
		return true
	elseif mmaUsed and _G.MMA_IsLaneClearing() then
		return true
	elseif norbUsed and _G.NebelwolfisOrbWalker.Config.k.LaneClear then
		return true
	elseif pewUsed and _Pewalk.GetActiveMode()["LaneClear"] then
		return true
	end
end
local function IsLastHit()
	if sacUsed and _G.AutoCarry.Keys.LastHit then
		return true
	elseif sxorbUsed and SxOrb.isLastHit then
		return true
	elseif mmaUsed and _G.MMA_IsLastHitting() then
		return true
	elseif norbUsed and _G.NebelwolfisOrbWalker.Config.k.LastHit then
		return true
	elseif pewUsed and _Pewalk.GetActiveMode()["Farm"] then
		return true
	end
end
local function IsCombo()
	if sacUsed and _G.AutoCarry.Keys.AutoCarry then
		return true
	elseif sxorbUsed and SxOrb.isFight then
		return true
	elseif mmaUsed and _G.MMA_IsOrbwalking() then
		--print("combo")
		return true
	elseif norbUsed and _G.NebelwolfisOrbWalker.Config.k.Combo then
		return true
	elseif pewUsed and _Pewalk.GetActiveMode()["Carry"] then
		return true
	end
end
local function IsHarass()
	if sacUsed and _G.AutoCarry.Keys.MixedMode then
		return true
	elseif sxorbUsed and SxOrb.isHarass then
		return true
	elseif mmaUsed and _G.MMA_IsDualCarrying() then
		return true
	elseif norbUsed and _G.NebelwolfisOrbWalker.Config.k.Harass then
		return true
	elseif pewUsed and _Pewalk.GetActiveMode()["Mixed"] then
		return true
	end
end

function moveEvery()
	if IsCombo() then
		return 1 / hvMenu.move.combo
	elseif IsLastHit() then
		return 1 / hvMenu.move.lhit
	elseif IsHarass() then
		return 1 / hvMenu.move.harass
	elseif IsLaneclear() then
		return 1 / hvMenu.move.lclear
	else
		return 1 / hvMenu.move.perm 
	end
end
function findOrbwalk()
	 if _G.Reborn_Loaded and not _G.Reborn_Initialised then
        DelayAction(CheckOrbwalk, 1)
    elseif _G.Reborn_Initialised then
        sacUsed = true
    elseif _G.MMA_IsLoaded then
		mmaUsed = true
	elseif _G.NebelwolfisOrbWalkerLoaded then
		norbUsed = true
	elseif _G.SxOrb then
		sxorbUsed = true
	elseif _Pewalk then
		pewUsed = true
	else
		Print("Orbwalker not found. Only movement limiter persistant will work.")
	end
end