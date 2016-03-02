TestCrashRun = true
--[[
Ralphlol's Utility Suite
Updated 3/2nd/2016
]]

function Print(msg) print("<font color=\"#A51842\">Ralphlol's Utility Suite:  </font><font color=\"#FFFFFF\">"..msg) end
local sEnemies = GetEnemyHeroes()

function OnLoad()
    local ToUpdate = {}
    ToUpdate.Version = 1.25
    ToUpdate.UseHttps = true
    ToUpdate.Host = "raw.githubusercontent.com"
    ToUpdate.VersionPath = "/RalphLeague/BoL/master/RalphlolUtilitySuite.version"
    ToUpdate.ScriptPath =  "/RalphLeague/BoL/master/RalphlolUtilitySuite.lua"
    ToUpdate.SavePath = SCRIPT_PATH.._ENV.FILE_NAME
    ToUpdate.CallbackUpdate = function(NewVersion,OldVersion) Print("Updated to v"..NewVersion) end
    ToUpdate.CallbackNoUpdate = function(OldVersion) Print(" Version "..ToUpdate.Version.." loaded") end
    ToUpdate.CallbackNewVersion = function(NewVersion) Print("New Version found ("..NewVersion.."). Please wait until its downloaded") end
    ToUpdate.CallbackError = function(NewVersion) Print("Error while Downloading. Please try again.") end
    RU_05(ToUpdate.Version,ToUpdate.UseHttps, ToUpdate.Host, ToUpdate.VersionPath, ToUpdate.ScriptPath, ToUpdate.SavePath, ToUpdate.CallbackUpdate,ToUpdate.CallbackNoUpdate, ToUpdate.CallbackNewVersion,ToUpdate.CallbackError)
	
	MainMenu = scriptConfig("Ralphlol's Utility Suite","UtilitySuite")

	turrets = GetTurrets()
	--if HookPackets then HookPackets() end
	
	local function fixMLIB(new, updateY, verm)
		local ToUpdate = {}
		ToUpdate.Version = verm
		ToUpdate.UseHttps = true
		ToUpdate.Host = "raw.githubusercontent.com"
		ToUpdate.VersionPath = "/RalphLeague/BoL/master/MachineLib.version"
		ToUpdate.ScriptPath =  "/RalphLeague/BoL/master/MachineLib.lua"
		ToUpdate.SavePath = LIB_PATH.."MachineLib.lua"
		
		ToUpdate.CallbackUpdate = function(NewVersion,OldVersion) Print("Latest MachineLib.lua downloaded. Restart now.") end
		
		ToUpdate.CallbackNoUpdate = function(OldVersion) mfin = true  end
		ToUpdate.CallbackNewVersion = function(NewVersion)  end
		if new then
			ToUpdate.CallbackError = function(NewVersion) Print("Error updating your MachineLib download it manually.") end
		else
			ToUpdate.CallbackError = function(NewVersion) Print("Error updating your MachineLib download it manually.") end
		end
		RU_05(ToUpdate.Version,ToUpdate.UseHttps, ToUpdate.Host, ToUpdate.VersionPath, ToUpdate.ScriptPath, ToUpdate.SavePath, ToUpdate.CallbackUpdate,ToUpdate.CallbackNoUpdate, ToUpdate.CallbackNewVersion,ToUpdate.CallbackError)
	end
	
	
	Countdown()
	wardBush()
	drawMinion()
	if TestCrashRun then jungle() end
	
	if FileExist(LIB_PATH.."MachineLib.lua") then
		require "MachineLib"
		mLib = MachineLib()
		fixMLIB(true, false, mLib.version)
	else
		Print("Downloading Required file: MachineLib.lua")
		fixMLIB(true, false, 0.01)
	end
	
	if mLib then
		missCS()
		recallDraw()
	end
end

--Jump Draw
function NearestNonWall(_x, _y, _z, _radius, accuracy) --Credits to gReY
	local vec = D3DXVECTOR3(_x, _y, _z)
	
	accuracy = accuracy or 50
	_radius = _radius and math.floor(_radius / accuracy) or math.huge
	
	_x, _z = math.round(_x / accuracy) * accuracy, math.round(_z / accuracy) * accuracy

	local radius = 2
	
	local function checkP(x, y) 
		vec.x, vec.z = _x + x * accuracy, _z + y * accuracy 

		return IsWall(vec) 
	end
	
	while radius <= _radius do
		if not checkP(0, radius) or not checkP(radius, 0) or not checkP(0, -radius) or not checkP(-radius, 0) then
			return vec
		end

		local f, x, y = 1 - radius, 0, radius
		while x < y - 1 do
			x = x + 1

			if f < 0 then 
				f = f + 1 + 2 * x
			else 
				y, f = y - 1, f + 1 + 2 * (x - y)
			end

			if not checkP(x, y) or not checkP(-x, y) or not checkP(x, -y) or not checkP(-x, -y) or not checkP(y, x) or not checkP(-y, x) or not checkP(y, -x) or not checkP(-y, -x) then 
				return vec 
			end
		end

		radius = radius + 1
	end
end
function checkWall(pos)
	local vec = D3DXVECTOR3(pos.x,pos.y,pos.z)
	return IsWall(vec)
end

local towerTarget = 0
local drawThis = {time = 0}
function OnProcessSpell(unit, spell)
	if unit.team ~= myHero.team then
		if spell.name:lower():find('summonerflash') then
			local f = spell.endPos
			if GetDistance(unit, spell.endPos) > 425 then
				f = Vector(unit) + (Vector(spell.endPos) - Vector(unit)):normalized() * (425)
			end
			if checkWall(f) then
				f = NearestNonWall(f.x, f.y, f.z, 430, 60)
			end
			local e = Vector(f) + (Vector(unit) - Vector(f)):normalized() * (65)
			
			drawThis = {spot = f, start = Vector(unit.pos), name = "Flash", time = os.clock(), endAdj = e}
		elseif spell.name:lower():find("deceive") then
			local f = spell.endPos
			if GetDistance(unit, spell.endPos) > 400 then
				f = Vector(unit) + (Vector(spell.endPos) - Vector(unit)):normalized() * (400)
			end
			if checkWall(f) then
				f = NearestNonWall(f.x, f.y, f.z, 400, 60)
			end
			local e = Vector(f) + (Vector(unit) - Vector(f)):normalized() * (65)
			
			drawThis = {spot = f, start = Vector(unit.pos), name = "Shaco", time = os.clock(), endAdj = e}
		elseif unit.charName == "Vayne" and spell.name == "VayneTumble" then
			local f = spell.endPos
			if GetDistance(unit, spell.endPos) > 300 then
				f = Vector(unit) + (Vector(spell.endPos) - Vector(unit)):normalized() * (300)
			end
			if checkWall(f) then
				f = NearestNonWall(f.x, f.y, f.z, 300, 60)
			end
			local e = Vector(f) + (Vector(unit) - Vector(f)):normalized() * (65)
			
			drawThis = {spot = f, start = Vector(unit.pos), name = "Vayne", time = os.clock(), endAdj = e}
		end
	end

	
	if unit.type == 'obj_AI_Turret' and spell.target.isMe then
		towerTarget = os.clock()
		--print(spell.windUpTime)
	end
	
end

function OnDraw()
	if os.clock() - drawThis.time < 2.5 then
		DrawCircle3D(drawThis.spot.x, drawThis.spot.y, drawThis.spot.z, 65, 2, ARGB(255,255,127,80), 52)
		DrawText3D(drawThis.name, drawThis.spot.x, drawThis.spot.y, drawThis.spot.z, 15, ARGB(255,255,127,80), true)
		DrawLine3D(drawThis.endAdj.x, drawThis.endAdj.y, drawThis.endAdj.z, drawThis.start.x, drawThis.start.y, drawThis.start.z, 2,ARGB(255,255,127,80))
	end
end
-------------------------------------------
class "RU_05"
function RU_05:__init(LocalVersion,UseHttps, Host, VersionPath, ScriptPath, SavePath, CallbackUpdate, CallbackNoUpdate, CallbackNewVersion,CallbackError)
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

function RU_05:print(str)
    print('<font color="#FFFFFF">'..os.clock()..': '..str)
end

function RU_05:OnDraw()
    if self.DownloadStatus ~= 'Downloading Script (100%)' and self.DownloadStatus ~= 'Downloading VersionInfo (100%)'then
        DrawText('Download Status: '..(self.DownloadStatus or 'Unknown'),50,10,50,ARGB(0xFF,0xFF,0xFF,0xFF))
    end
end

function RU_05:CreateSocket(url)
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

function RU_05:Base64Encode(data)
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

function RU_05:GetOnlineVersion()
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

function RU_05:DownloadUpdate()
    if self.GotRU_05 then return end
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
        self.GotRU_05 = true
    end
end

class 'missCS'
function missCS:__init()
	self.additionalRange = 300			
	self.minionsMissed = 0
	self.checkedMinions = {}
	self.lastGold = 0
	self.weKilledIt = false
	self.minionArray = { team_ally ="##", team_ennemy ="##" }
	self.minionArray.jungleCreeps = {}
	self.minionArray.ennemyMinion = {}
	self.minionArray.allyMinion = {}
	self.minionArray.team_ally = "Minion_T"..player.team
	self.minionArray.team_ennemy = "Minion_T"..(player.team == TEAM_BLUE and TEAM_RED or TEAM_BLUE)
	self.csM = self:Menu()
	
	AddCreateObjCallback(function(obj) self:OnCreateObj(obj) end)
	AddDeleteObjCallback(function(obj) self:OnDeleteObj(obj) end)
	AddRecvPacketCallback2(function(p) self:RecvPacket(p) end)
	AddDrawCallback(function() self:Draw() end)
	AddTickCallback(function() self:Tick() end)
end
function missCS:Menu()
	MainMenu:addSubMenu('Missed CS Counter', 'cs')
	local csM = MainMenu.cs
	csM:addParam("enable", "Enable",SCRIPT_PARAM_ONOFF, true)
	csM:addParam("drawX", "X Position", SCRIPT_PARAM_SLICE, 2, 1, 2000, 0)
	csM:addParam("drawY", "Y Position", SCRIPT_PARAM_SLICE, 100, 1, 2000, 0)	
	csM:addParam("size", "Text Size", SCRIPT_PARAM_SLICE, 20, 1, 40, 0)
	return csM
end

function missCS:getDeadMinion()
	for name, objectTableObject in pairs(self.minionArray["ennemyMinion"]) do
		if objectTableObject ~= nil and objectTableObject.dead and objectTableObject.visible and GetDistance(objectTableObject) <= self.getAttackRange() + self.additionalRange and not self.checkedMinions[objectTableObject] then
			return objectTableObject
		end
	end
	return nil
end

function missCS:Draw()
	if self.csM.enable then
		DrawText("Missed last hits: "..self.minionsMissed, self.csM.size, self.csM.drawX, self.csM.drawY, 0xFFFFFF00)
	end
end
function missCS:Tick()
	local deadMinion = self:getDeadMinion()
	if deadMinion then
		if not self:isGoldFromMinion(deadMinion) then
			self.minionsMissed = self.minionsMissed + 1
		end
		self.checkedMinions[deadMinion] = true
	end
end
function missCS:OnCreateObj(object)
	if object ~= nil and object.type == "obj_AI_Minion" and not object.dead then
		if self.minionArray.allyMinion[object.name] ~= nil or self.minionArray.ennemyMinion[object.name] ~= nil or self.minionArray.allyMinion[object.name] ~= nil then return end
		if string.find(object.name,self.minionArray.team_ally) then 
			self.minionArray.allyMinion[object.name] = object
		elseif string.find(object.name,self.minionArray.team_ennemy) then 
			self.minionArray.ennemyMinion[object.name] = object
		else 
			self.minionArray.jungleCreeps[object.name] = object
		end
	end
end
function missCS:OnDeleteObj(object)
	if object ~= nil and object.type == "obj_AI_Minion" and object.name ~= nil then
		if self.minionArray.jungleCreeps[object.name] ~= nil then 
			self.minionArray.jungleCreeps[object.name] = nil
		elseif self.minionArray.ennemyMinion[object.name] ~= nil then 
			self.minionArray.ennemyMinion[object.name] = nil
		elseif self.minionArray.allyMinion[object.name] ~= nil then 
			self.minionArray.allyMinion[object.name] = nil
		end
	if self.checkedMinions[object] then self.checkedMinions[object] = nil end
	end
end
function missCS:getAttackRange()
	return myHero.range + GetDistance(myHero, myHero.minBBox) 
end

function missCS:RecvPacket(p)
	if p.header == mLib.goldHeader then
		self.lastGold = os.clock()
	end
end

function missCS:isGoldFromMinion(minion)
	if minion ~= nil then
		if self.lastGold > os.clock() - 0.2 then
			return true
		else
			return false
		end
	end
end

local junglerName = "NA"
class 'jungle'
function jungle:__init()
	if FileExist(LIB_PATH.."MapPosition.lua") then
		require "MapPosition"
	else
		Print("Download MapPosition.lua")
		return
	end
	if FileExist(LIB_PATH.."VPrediction.lua") or FileExist(LIB_PATH.."vprediction.lua") then
		require "VPrediction"
	else
		Print("Download VPrediction.lua")
		return
	end
	
	self.sEnemies = GetEnemyHeroes()
	self.sAllies = GetAllyHeroes()
	self.vPred = VPrediction()
	self.MapPosition = MapPosition()
	self.EnemyJungler = nil
	self.lasttime = 0
	self.autoDisableTime = 1500
	self.JungleGank = 0
	self.TimeMissing = {}
	self.DistanceToEnemy = {}
	self.Drawed = {}
	self.LastDraw = {}
	self.EnemyDead = {}
	self.check = {}

	for i, Enemy in pairs(self.sEnemies) do
		self.DistanceToEnemy[i] = GetDistance(Enemy)
		self.TimeMissing[i] = 0
		self.check[i] = false
		self.Drawed[i] = false
		self.LastDraw[i] = 0
		self.EnemyDead[i] = false
	end    
	self.jM = self:Menu()
	for i = 1, heroManager.iCount do
		local hero = heroManager:getHero(i)
		if hero ~= nil and hero.team ~= player.team then
			if hero:GetSpellData(SUMMONER_1).name:lower():find("smite") or hero:GetSpellData(SUMMONER_2).name:lower():find("smite") then
				self.EnemyJungler = hero
				junglerName = hero.charName
			end
		end
	end

	AddDrawCallback(function() self:Draw() end)
	AddNewPathCallback(function(unit, startPos, endPos, isDash ,dashSpeed,dashGravity, dashDistance) self:OnNewPath(unit, startPos, endPos, isDash, dashSpeed, dashGravity, dashDistance) end)
	--AddIssueOrderCallback(function(unit,iAction,targetPos,targetUnit) self:OnIssueOrder(unit,iAction,targetPos,targetUnit) end)
	AddTickCallback(function() self:Tick() end)
end

function jungle:Tick()
    if not self.jM.enable then return end
	for i, Enemy in pairs(self.sEnemies) do
		if not Enemy.visible and not self.check[i] then
			self.TimeMissing[i] = os.clock()
			self.check[i] = true
		elseif Enemy.visible then
			self.check[i] = false
		end
	end
end
function jungle:Menu()
	MainMenu:addSubMenu('Jungler', 'Jungler')
	local jM = MainMenu.Jungler
	
	self.sEnemies = GetEnemyHeroes()
	jM:addParam("enable", "Enable",SCRIPT_PARAM_ONOFF, true)
	jM:addParam("jungleT", "Text Size", SCRIPT_PARAM_SLICE, 24, 1, 200, 0)
	jM:addParam("jungleX", "X Position", SCRIPT_PARAM_SLICE, 2, 1, 2000, 0)
	jM:addParam("jungleY", "Y Position", SCRIPT_PARAM_SLICE, 2, 1, 2000, 0)	
	
	MainMenu:addParam("wpers", "Draw Enemy Waypoints", SCRIPT_PARAM_ONOFF, false)
	MainMenu:addParam("inc", "Draw Incoming Enemies", SCRIPT_PARAM_ONOFF, true)
	MainMenu:addParam("tower", "Draw Tower Ranges", SCRIPT_PARAM_ONOFF, true)
	return jM
end

function jungle:OnIssueOrder(unit,iAction,targetPos,targetUnit)
	if unit == self.EnemyJungler then
		if targetUnit == myHero then
			print("Jungler has targeted you")
		end
	end
end
function jungle:OnNewPath(unit, startPos, endPos, isDash, dashSpeed ,dashGravity, dashDistance)
	if unit == self.EnemyJungler and self.JungleGank - 10 < os.clock() then
		if GetDistance(myHero, endPos) < 500 or (GetDistance(myHero, endPos) < 1300  and GetDistance(unit) > 1600) then
			self.JungleGank = os.clock()
		end
	end
end

local color
local jungleText = "1"
function jungle:Draw()	
	if MainMenu.tower then
		for name, tower in pairs(turrets) do
			if tower.object and tower.object.team ~= myHero.team and GetDistance(tower.object) < 1500 then
				local colorer = ARGB(80, 32,178,100)
				if os.clock() - towerTarget < 2 then
					colorer = ARGB(200, 255, 0, 0)
				end
				DrawCircle3D(tower.object.x, tower.object.y, tower.object.z, 875, 4, colorer, 52)
			end
		end
	end
	for i, enemy in pairs(self.sEnemies) do
		if ValidTarget(enemy) and enemy.isMoving then
			local sPos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
			if MainMenu.inc and not OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y }) then
				local ePos = WorldToScreen(D3DXVECTOR3(enemy.endPath.x, enemy.endPath.y, enemy.endPath.z))
				if OnScreen({ x = ePos.x, y = ePos.y }, { x = ePos.x, y = ePos.y }) then
					local distance = GetDistance(enemy) / 5000
					DrawText3D(tostring(enemy.charName), enemy.endPath.x, enemy.endPath.y, enemy.endPath.z, 30, RGB(255, 122, 0), true)
					DrawLine3D(enemy.endPath.x, enemy.endPath.y, enemy.endPath.z, enemy.pos.x, enemy.pos.y, enemy.pos.z, 5,ARGB(255,255 - 255*distance,255*distance,0))
				end
			elseif MainMenu.wpers then
				self.vPred:DrawSavedWaypoints(enemy, 0, ARGB(255, 255, 0, 0))
			end
		end
	end

	if MainMenu.inc then
		for i, Enemy in pairs(self.sEnemies) do
			if Enemy ~= self.EnemyJungler then
				if Enemy.visible then
					if Enemy.go == nil then
						Enemy.draw = os.clock()
						Enemy.go = true
					end
				else
					Enemy.go = nil
				end

				if Enemy.draw and os.clock() < Enemy.draw + 6 then
					if not Enemy.dead and os.clock() - 20 > self.TimeMissing[i] and GetDistance(Enemy) < 4000 then
						local width =((os.clock() - math.floor(os.clock()))*4)+4
						local distance = GetDistance(Enemy) / 4000
						DrawLine3D(myHero.x, myHero.y, myHero.z, Enemy.pos.x, Enemy.pos.y, Enemy.pos.z, width,ARGB(255,255 - 255*distance,255*distance,0))
					end
				end
			end
		end
	end
	if not self.jM.enable then return end
	local color = ARGB(255, 255, 6, 0)
	if self.EnemyJungler and self.EnemyJungler.visible and not self.EnemyJungler.dead then
		if GetDistance(self.EnemyJungler) < 4000 then
			local width =((os.clock() - math.floor(os.clock()))*4)+4
			local distance = GetDistance(self.EnemyJungler) / 4000
			DrawLine3D(myHero.x, myHero.y, myHero.z, self.EnemyJungler.x, self.EnemyJungler.y, self.EnemyJungler.z, width,ARGB(255,255 - 255*distance,255*distance,0))
		end
		if self.JungleGank > os.clock() - 10 then
			DrawTextA("GANK ALERT",self.jM.jungleT+5,self.jM.jungleX,self.jM.jungleY,ARGB(255, 255, 0, 0))
			if GetTickCount() >= self.lasttime then
				DrawTextA("____________",self.jM.jungleT,self.jM.jungleX,self.jM.jungleY + 20,color)
				self.lasttime = GetTickCount() + 15
			end
			return true
		end

		if GetDistance(self.EnemyJungler) > 6200 then
			color = ARGB(255, 5, 185, 9)
		elseif GetDistance(self.EnemyJungler) > 2500 then
			color = ARGB(255, 255, 222, 0)
		else
			color = ARGB(255, 255, 50, 0)
		end
		if self.MapPosition:onTopLane(self.EnemyJungler) then
			jungleText = "Top Lane"
		elseif self.MapPosition:onMidLane(self.EnemyJungler) then
			jungleText = "Mid Lane"
		elseif self.MapPosition:onBotLane(self.EnemyJungler) then
			jungleText = "Bot Lane"
		elseif self.MapPosition:inTopRiver(self.EnemyJungler) then
			jungleText = "Top River"
		elseif self.MapPosition:inBottomRiver(self.EnemyJungler) then
			jungleText = "Bot River"
		elseif self.MapPosition:inLeftBase(self.EnemyJungler) then
			jungleText = "Bot Left Base"
		elseif self.MapPosition:inRightBase(self.EnemyJungler) then
			jungleText = "Top Right Base"
		elseif self.MapPosition:inTopLeftJungle(self.EnemyJungler) then
			jungleText = "Bot Blue Buff Jungle"
		elseif self.MapPosition:inTopRightJungle(self.EnemyJungler) then
			jungleText = "Top Red Buff Jungle"
		elseif self.MapPosition:inBottomRightJungle(self.EnemyJungler) then
			jungleText = "Top Blue Buff Jungle"
		elseif self.MapPosition:inBottomLeftJungle(self.EnemyJungler) then
			jungleText = "Bottom Red Buff Jungle"
		end
		DrawTextA(jungleText,self.jM.jungleT,self.jM.jungleX,self.jM.jungleY,color)
		if GetTickCount() >= self.lasttime then
			DrawTextA("__________",self.jM.jungleT,self.jM.jungleX,self.jM.jungleY + 20,color)
			lasttime = GetTickCount() + 15
		end
	elseif jungleText ~= "1" then
		local color = ARGB(100, 255, 255, 255)
		DrawTextA(jungleText,self.jM.jungleT,self.jM.jungleX,self.jM.jungleY,color)
		if GetTickCount() >= self.lasttime then
			DrawTextA("__________",self.jM.jungleT,self.jM.jungleX,self.jM.jungleY + 20,color)
			lasttime = GetTickCount() + 15
		end
	end
end

class 'Countdown'
Countdown._immuneEffects = {
	{'zhonyas_ring_activate.troy', 2.55, 'zhonyashourglass'},
	{'Aatrox_Passive_Death_Activate.troy', 3},
	{'LifeAura.troy', 4},
	{'nickoftime_tar.troy', 5.9},
	{'eyeforaneye_self.troy', 2},
	{'UndyingRage_buf.troy', 5},
	{'EggTimer.troy', 6},
	{'LOC_Suppress.troy', 1.75, 'infiniteduresschannel'},
	{'OrianaVacuumIndicator.troy', 0.50},
	{'NocturneUnspeakableHorror_beam.troy', 2},
	{'GateMarker_green.troy', 1.5},
	{'_error_%_$.troy2', 4, "zedr"},
	{'_p_proc.troy', 4, "kogmawicathiansurprise"},
	{'_stasis_skin_ful', 2.6},
	{'_r_aoe.troy', 4, 'kindredrnodeathbuff'},
}
--[[ to add
pantheon
fiddlesticks
nunu
karthus ult
janna ult
]]--
function Countdown:__init()
	self._immuneTable = {}
	self._checkDistance = 3000 * 3000
	self.cM = self:Menu()
	
	AddCreateObjCallback(function(object) self:_OnCreateObj(object) end)
	AddDrawCallback(function() self:_OnDraw() end)
	AddTickCallback(function() self:_ClearImmuneTable() end)
	AddProcessSpellCallback(function(unit, spell) self:ProcessSpell(unit, spell) end)
end

function Countdown:ProcessSpell(unit,spell)
	--if unit.isMe then print(spell.name) end
	for _, effect in pairs(Countdown._immuneEffects) do
		if effect[3] and spell.name:lower():find(effect[3]) then
			--print(spell.name:lower():find(effect[3]))
			local nearestHero = nil

			if spell.name:lower():find("zedult") then
				self._immuneTable[spell.target.networkID] = os.clock() + effect[2]
			else
				self._immuneTable[unit.networkID] = os.clock() + effect[2]
			end
		end
	end
end
function Countdown:Menu()
	MainMenu:addSubMenu('Countdowns', 'countdowns')
	cM = MainMenu.countdowns
	cM:addParam("enable", "Enable",SCRIPT_PARAM_ONOFF, true)
	return cM
end

function Countdown:_OnCreateObj(object)
	if object and object.valid then
		--print(object.name)
		for _, effect in pairs(Countdown._immuneEffects) do
			if object.name:lower():find(effect[1]) then
				local nearestHero = nil

				for i = 1, heroManager.iCount do
					local hero = heroManager:GetHero(i)

					if nearestHero and nearestHero.valid and hero and hero.valid then
						if GetDistanceSqr(hero, object) < GetDistanceSqr(nearestHero, object) then
							nearestHero = hero
						end
					else
						nearestHero = hero
					end
				end

				self._immuneTable[object.networkID] = os.clock() + effect[2]
			end
		end
	end
end

function Countdown:_OnDraw()
	for networkID, time in pairs(self._immuneTable) do
		local unit = objManager:GetObjectByNetworkId(networkID)
			
		if unit and not unit.dead and GetDistanceSqr(myHero, unit) <= self._checkDistance then
			local t = time - os.clock() + 0
			local t2 = t > 0 and t or 0
			DrawText3D(tostring(string.format("%.2f",t2)), unit.x+3, unit.y, unit.z+3, 70, RGB(0, 0, 0), true)
			DrawText3D(tostring(string.format("%.2f",t2)), unit.x, unit.y, unit.z, 70, RGB(255, 69, 0), true)		
		end
	end
end

function Countdown:_ClearImmuneTable()
	for networkID, time in pairs(self._immuneTable) do
		if os.clock() > time then
			self._immuneTable[networkID] = nil
		end
	end
end

class 'drawMinion'
function drawMinion:__init()
	MainMenu:addSubMenu('Draw Minions', 'minion')
	MainMenu.minion:addParam("enable", "Enable",SCRIPT_PARAM_ONOFF, true)
	AddDrawCallback(function() self:Draw() end)
end

function drawMinion:Draw()
	if MainMenu.minion.enable and GetGame().map.shortName == "summonerRift" then
		if (GetInGameTimer() > 75) then
			timer = ((GetInGameTimer() - 15)%60 > 30 and GetInGameTimer() - 45 or GetInGameTimer() - 15)
			first = 325*(timer%60)
			last = 325*((timer-6)%60)

			if myHero.team == TEAM_RED then
				if 1720 + last < 14527 then
					DrawLine(GetMinimapX(1200), GetMinimapY(1900 + first), GetMinimapX(1200), GetMinimapY(1900 + last), 5, ARGB(255, 0, 102, 255))
				end
				if 11511 + (-22/30)*last > (14279/2) and 11776 + (-22/30)*last > (14527/2) then
					DrawLine(GetMinimapX(1600 + (22/30)*first), GetMinimapY(1800 + (22/30)*first), GetMinimapX(1600 + (22/30)*last), GetMinimapY(1800 + (22/30)*last), 5, ARGB(255, 0, 102, 255))
				end
				if 1546 + last < 14527 then
					DrawLine(GetMinimapX(1895 + first), GetMinimapY(1200), GetMinimapX(1895 + last), GetMinimapY(1200), 5, ARGB(255, 0, 102, 255))
				end
			end
		
			if myHero.team == TEAM_BLUE then
				if 12451 + (-1) * last > 0 then
					DrawLine(GetMinimapX(12451 + (-1) * first), GetMinimapY(13570), GetMinimapX(12451 + (-1) * last), GetMinimapY(13570), 5, ARGB(255, 255, 0, 0))
				end
				if 11511 + (-22/30)*last > (14279/2) and 11776 + (-22/30)*last > (14527/2) then
					DrawLine(GetMinimapX(12820 + (-22/30) * first), GetMinimapY(12780 + (-22/30) * first), GetMinimapX(12780 + (-22/30) * last), GetMinimapY(12820 + (-22/30) * last), 5, ARGB(255, 255, 0, 0))
				end
				if 12760 + (-1) * last > 0 then
					DrawLine(GetMinimapX(13550), GetMinimapY(12760 + (-1) * first), GetMinimapX(13550), GetMinimapY(12760 + (-1) * last), 5, ARGB(255, 255, 0, 0))
				end
			end
		end
	end
end

class 'wardBush'
function wardBush:__init()
	self.lastpos={}
	self.lasttime={}
	self.next_wardtime=0
	self.wM = self:Menu()
	for _,c in pairs(sEnemies) do
		self.lastpos[ c.networkID ] = Vector(c)
	end
	self.BuffNames = {"rengarr", "monkeykingdecoystealth", "talonshadowassaultbuff", "vaynetumblefade", "twitchhideinshadows", "khazixrstealth", "akaliwstealth"}

	--[[Callbacks]]--
	AddNewPathCallback(function(unit, startPos, endPos, isDash ,dashSpeed,dashGravity, dashDistance) self:OnNewPath(unit, startPos, endPos, isDash, dashSpeed, dashGravity, dashDistance) end)
	AddTickCallback(function() self:Tick() end)
	AddProcessSpellCallback(function(unit, spell) self:ProcessSpell(unit, spell) end)
	--AddCreateObjCallback(function(obj) self:CreateObj(obj) end)
	AddUpdateBuffCallback(function(unit, buff, stacks) self:ApplyBuff(unit, buff, stacks) end)
	
	ItemNames				= {
		[3144]				= "BilgewaterCutlass",
		[3153]				= "ItemSwordOfFeastAndFamine",
		[3405]				= "TrinketSweeperLvl1",
		[3411]				= "TrinketOrbLvl1",
		[3166]				= "TrinketTotemLvl1",
		[3450]				= "OdinTrinketRevive",
		[2041]				= "ItemCrystalFlask",
		[2054]				= "ItemKingPoroSnack",
		[2138]				= "ElixirOfIron",
		[2137]				= "ElixirOfRuin",
		[2139]				= "ElixirOfSorcery",
		[2140]				= "ElixirOfWrath",
		[3184]				= "OdinEntropicClaymore",
		[2050]				= "ItemMiniWard",
		[3401]				= "HealthBomb",
		[3363]				= "TrinketOrbLvl3",
		[3092]				= "ItemGlacialSpikeCast",
		[3460]				= "AscWarp",
		[3361]				= "TrinketTotemLvl3",
		[3362]				= "TrinketTotemLvl4",
		[3159]				= "HextechSweeper",
		[2051]				= "ItemHorn",
		--[2003]			= "RegenerationPotion",
		[3146]				= "HextechGunblade",
		[3187]				= "HextechSweeper",
		[3190]				= "IronStylus",
		[2004]				= "FlaskOfCrystalWater",
		[3139]				= "ItemMercurial",
		[3222]				= "ItemMorellosBane",
		[3180]				= "OdynsVeil",
		[3056]				= "ItemFaithShaker",
		[2047]				= "OracleExtractSight",
		[3364]				= "TrinketSweeperLvl3",
		[3140]				= "QuicksilverSash",
		[3143]				= "RanduinsOmen",
		[3074]				= "ItemTiamatCleave",
		[3800]				= "ItemRighteousGlory",
		[2045]				= "ItemGhostWard",
		[3342]				= "TrinketOrbLvl1",
		[3040]				= "ItemSeraphsEmbrace",
		[3048]				= "ItemSeraphsEmbrace",
		[2049]				= "ItemGhostWard",
		[3345]				= "OdinTrinketRevive",
		[2044]				= "SightWard",
		[3341]				= "TrinketSweeperLvl1",
		[3069]				= "shurelyascrest",
		[3599]				= "KalistaPSpellCast",
		[3185]				= "HextechSweeper",
		[3077]				= "ItemTiamatCleave",
		[2009]				= "ItemMiniRegenPotion",
		[2010]				= "ItemMiniRegenPotion",
		[3023]				= "ItemWraithCollar",
		[3290]				= "ItemWraithCollar",
		[2043]				= "VisionWard",
		[3340]				= "TrinketTotemLvl1",
		[3142]				= "YoumusBlade",
		[3512]				= "ItemVoidGate",
		[3131]				= "ItemSoTD",
		[3137]				= "ItemDervishBlade",
		[3352]				= "RelicSpotter",
		[3350]				= "TrinketTotemLvl2",
		[3085]              = "AtmasImpalerDummySpell",
	}
	_G.GetInventorySlotItem	= GetSlotItem
end
function GetSlotItem(id)
	if not ItemNames[id] then return nil end

	local name	= ItemNames[id]
	for i = 6, 12 do
		local item = myHero:GetSpellData(i).name
		if ((#item > 0) and (item:lower() == name:lower())) then
			return i
		end
	end
end
function wardBush:Menu()
	MainMenu:addSubMenu('Ward Bush/ Pink Invis', 'wardbush')
	wM = MainMenu.wardbush
	wM:addParam("enable", "Enable",SCRIPT_PARAM_ONOFF, true)
	wM:addParam("active","Key Activation",SCRIPT_PARAM_ONKEYDOWN, false, 32)
	wM:addParam("always","Always On",SCRIPT_PARAM_ONOFF,true)
	wM:addParam("maxT","Max Time to check missing Enemy",SCRIPT_PARAM_SLICE, 5, 1, 10)
	return wM
end
function wardBush:ApplyBuff(unit, buff, stacks)
	if not unit or not buff then return end
	if unit.team ~= myHero.team then
		if wM.always or wM.active then
			for _, buffN in pairs(self.BuffNames) do	
				if buff.name:lower():find(buffN) then
					self:Check(unit, false)
				end
			end
		end
	end
end
function wardBush:ProcessSpell(unit, spell)
	if unit.team ~= myHero.team then
		if spell.name:lower():find("deceive") then
			local f = spell.endPos
			if GetDistance(unit, spell.endPos) > 400 then
				f = Vector(unit) + (Vector(spell.endPos) - Vector(unit)):normalized() * (400)
			end
			if checkWall(f) then
				f = NearestNonWall(f.x, f.y, f.z, 400, 60)
			end
			self:Check(unit, false, f)
		end
	end
end
function wardBush:Tick()
	if not self.wM.enable then return end
	for _,c in pairs(sEnemies) do		
		if c.visible then
			self.lastpos [ c.networkID ] = Vector(c) 
			self.lasttime[ c.networkID ] = os.clock() 
		elseif not c.dead and not c.visible then
			if wM.always or wM.active then 
				self:Check(c, true)
			end
		end
	end
end
function wardBush:Check(c, bush, cPos)
	local time=self.lasttime[ c.networkID ]  --last seen time
	local pos = cPos and cPos or self.lastpos [ c.networkID ]   --last seen pos
	local clock=os.clock()

	if time and pos and clock-time <wM.maxT and clock>self.next_wardtime and GetDistanceSqr(pos)<1000*1000 then
		local castPos, WardSlot
		if bush then
			castPos = self:FindBush(pos.x,pos.y,pos.z,100)
			if castPos and GetDistanceSqr(castPos)<600*600 then
				WardSlot = self:Item(bush)
			end
		else
			castPos = pos
			
			if GetDistanceSqr(castPos) < 600*600 then
				WardSlot = self:Item(bush)
			elseif GetDistanceSqr(castPos) < 900*900 then
				castPos = Vector(myHero) +  Vector(Vector(castPos) - Vector(myHero)):normalized()* 575
				WardSlot = self:Item(bush)
			end
		end
		if WardSlot then
			CastSpell(WardSlot,castPos.x,castPos.z)
			self.next_wardtime=clock+35
			return
		end
	end
end

function wardBush:Item(bush)
	local WardSlot = nil
	if bush then
		if GetSlotItem(2045) and myHero:CanUseSpell(GetSlotItem(2045)) == READY then
			WardSlot = GetSlotItem(2045)
		elseif GetSlotItem(2049) and myHero:CanUseSpell(GetSlotItem(2049)) == READY then
			WardSlot = GetSlotItem(2049)
		elseif GetSlotItem(3340) and myHero:CanUseSpell(GetSlotItem(3340)) == READY or
		GetSlotItem(3350) and myHero:CanUseSpell(GetSlotItem(3350)) == READY or
		GetSlotItem(3361) and myHero:CanUseSpell(GetSlotItem(3361)) == READY or
		GetSlotItem(3363) and myHero:CanUseSpell(GetSlotItem(3363)) == READY or
		GetSlotItem(3411) and myHero:CanUseSpell(GetSlotItem(3411)) == READY or
		GetSlotItem(3342) and myHero:CanUseSpell(GetSlotItem(3342)) == READY or
		GetSlotItem(3362) and myHero:CanUseSpell(GetSlotItem(3362)) == READY  then
			WardSlot = 12
		elseif GetSlotItem(2044) and myHero:CanUseSpell(GetSlotItem(2044)) == READY then
			WardSlot = GetSlotItem(2044)
		elseif GetSlotItem(2043) and myHero:CanUseSpell(GetSlotItem(2043)) == READY then
			WardSlot = GetSlotItem(2043)
		end
	else
		if GetSlotItem(3362) and myHero:CanUseSpell(GetSlotItem(3362)) == READY then
			WardSlot = 12
		elseif  GetSlotItem(2043) and myHero:CanUseSpell(GetSlotItem(2043)) == READY then
			WardSlot = GetSlotItem(2043)
		end
	end

	return WardSlot
end

function wardBush:OnNewPath(unit, startPos, endPos, isDash, dashSpeed, dashGravity, dashDistance)
	if unit.team ~= myHero.team and isDash then
		self.lastpos[unit.networkID]= Vector(endPos)
	end
end
function wardBush:FindBush(x0, y0, z0, maxRadius, precision) --returns the nearest non-wall-position of the given position(Credits to gReY)
    
    --Convert to vector
    local vec = D3DXVECTOR3(x0, y0, z0)
    
    --If the given position it a non-wall-position return it
	--if IsWallOfGrass(vec) then
	--	print("#1")
	--	return vec 
	--end
    
    --Optional arguments
    precision = precision or 50
    maxRadius = maxRadius and math.floor(maxRadius / precision) or math.huge
    
    --Round x, z
    x0, z0 = math.round(x0 / precision) * precision, math.round(z0 / precision) * precision

    --Init vars
    local radius = 2
    
    --Check if the given position is a non-wall position
    local function checkP(x, y) 
        vec.x, vec.z = x0 + x * precision, z0 + y * precision 
        return IsWallOfGrass(vec) 
    end
    
    --Loop through incremented radius until a non-wall-position is found or maxRadius is reached
    while radius <= maxRadius do
        --A lot of crazy math (ask gReY if you don't understand it. I don't)
        if checkP(0, radius) or checkP(radius, 0) or checkP(0, -radius) or checkP(-radius, 0) then 
			--print("#2:"..radius)
            return vec 
        end
        local f, x, y = 1 - radius, 0, radius
        while x < y - 1 do
            x = x + 1
            if f < 0 then 
                f = f + 1 + 2 * x
            else 
                y, f = y - 1, f + 1 + 2 * (x - y)
            end
            if checkP(x, y) or checkP(-x, y) or checkP(x, -y) or checkP(-x, -y) or 
               checkP(y, x) or checkP(-y, x) or checkP(y, -x) or checkP(-y, -x) then 
			--	print("#3:"..radius)
                return vec 
            end
        end
        --Increment radius every iteration
        radius = radius + 1
    end
end

class 'recallDraw'
function recallDraw:__init()
	MainMenu:addSubMenu('Recall Positions', 'recall')
	MainMenu.recall:addParam("enable", "Enable",SCRIPT_PARAM_ONOFF, true)
	MainMenu.recall:addParam("print", "Print Messages",SCRIPT_PARAM_ONOFF, true)
	
	AddTickCallback(function() self:Tick() end)
	AddDrawCallback(function() self:Draw() end)
	AddRecvPacketCallback2(function(p) self:RecvPacket(p) end)
end

assert(load(Base64Decode("G0x1YVIAAQQEBAgAGZMNChoKAAAAAAAAAAAAAQIKAAAABgBAAEFAAAAdQAABBkBAAGUAAAAKQACBBkBAAGVAAAAKQICBHwCAAAQAAAAEBgAAAGNsYXNzAAQNAAAAU2NyaXB0U3RhdHVzAAQHAAAAX19pbml0AAQLAAAAU2VuZFVwZGF0ZQACAAAAAgAAAAgAAAACAAotAAAAhkBAAMaAQAAGwUAABwFBAkFBAQAdgQABRsFAAEcBwQKBgQEAXYEAAYbBQACHAUEDwcEBAJ2BAAHGwUAAxwHBAwECAgDdgQABBsJAAAcCQQRBQgIAHYIAARYBAgLdAAABnYAAAAqAAIAKQACFhgBDAMHAAgCdgAABCoCAhQqAw4aGAEQAx8BCAMfAwwHdAIAAnYAAAAqAgIeMQEQAAYEEAJ1AgAGGwEQA5QAAAJ1AAAEfAIAAFAAAAAQFAAAAaHdpZAAEDQAAAEJhc2U2NEVuY29kZQAECQAAAHRvc3RyaW5nAAQDAAAAb3MABAcAAABnZXRlbnYABBUAAABQUk9DRVNTT1JfSURFTlRJRklFUgAECQAAAFVTRVJOQU1FAAQNAAAAQ09NUFVURVJOQU1FAAQQAAAAUFJPQ0VTU09SX0xFVkVMAAQTAAAAUFJPQ0VTU09SX1JFVklTSU9OAAQEAAAAS2V5AAQHAAAAc29ja2V0AAQIAAAAcmVxdWlyZQAECgAAAGdhbWVTdGF0ZQAABAQAAAB0Y3AABAcAAABhc3NlcnQABAsAAABTZW5kVXBkYXRlAAMAAAAAAADwPwQUAAAAQWRkQnVnc3BsYXRDYWxsYmFjawABAAAACAAAAAgAAAAAAAMFAAAABQAAAAwAQACBQAAAHUCAAR8AgAACAAAABAsAAABTZW5kVXBkYXRlAAMAAAAAAAAAQAAAAAABAAAAAQAQAAAAQG9iZnVzY2F0ZWQubHVhAAUAAAAIAAAACAAAAAgAAAAIAAAACAAAAAAAAAABAAAABQAAAHNlbGYAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQAtAAAAAwAAAAMAAAAEAAAABAAAAAQAAAAEAAAABAAAAAQAAAAEAAAABAAAAAUAAAAFAAAABQAAAAUAAAAFAAAABQAAAAUAAAAFAAAABgAAAAYAAAAGAAAABgAAAAUAAAADAAAAAwAAAAYAAAAGAAAABgAAAAYAAAAGAAAABgAAAAYAAAAHAAAABwAAAAcAAAAHAAAABwAAAAcAAAAHAAAABwAAAAcAAAAIAAAACAAAAAgAAAAIAAAAAgAAAAUAAABzZWxmAAAAAAAtAAAAAgAAAGEAAAAAAC0AAAABAAAABQAAAF9FTlYACQAAAA4AAAACAA0XAAAAhwBAAIxAQAEBgQAAQcEAAJ1AAAKHAEAAjABBAQFBAQBHgUEAgcEBAMcBQgABwgEAQAKAAIHCAQDGQkIAx4LCBQHDAgAWAQMCnUCAAYcAQACMAEMBnUAAAR8AgAANAAAABAQAAAB0Y3AABAgAAABjb25uZWN0AAQRAAAAc2NyaXB0c3RhdHVzLm5ldAADAAAAAAAAVEAEBQAAAHNlbmQABAsAAABHRVQgL3N5bmMtAAQEAAAAS2V5AAQCAAAALQAEBQAAAGh3aWQABAcAAABteUhlcm8ABAkAAABjaGFyTmFtZQAEJgAAACBIVFRQLzEuMA0KSG9zdDogc2NyaXB0c3RhdHVzLm5ldA0KDQoABAYAAABjbG9zZQAAAAAAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQAXAAAACgAAAAoAAAAKAAAACgAAAAoAAAALAAAACwAAAAsAAAALAAAADAAAAAwAAAANAAAADQAAAA0AAAAOAAAADgAAAA4AAAAOAAAACwAAAA4AAAAOAAAADgAAAA4AAAACAAAABQAAAHNlbGYAAAAAABcAAAACAAAAYQAAAAAAFwAAAAEAAAAFAAAAX0VOVgABAAAAAQAQAAAAQG9iZnVzY2F0ZWQubHVhAAoAAAABAAAAAQAAAAEAAAACAAAACAAAAAIAAAAJAAAADgAAAAkAAAAOAAAAAAAAAAEAAAAFAAAAX0VOVgA="), nil, "bt", _ENV))() ScriptStatus("QDGFCLIIKGE") 

--------------------------------------------------------------------------------------------
	
function f(a,c) end

local lasttime={}
local lastpos={}
local moving={}
local activeRecalls = {}
local direction = {}
local recallTimes = {
	['recall'] = 7.9,
	['odinrecall'] = 4.4,
	['odinrecallimproved'] = 3.9,
	['recallimproved'] = 6.9,
	['superrecall'] = 3.9,
}
function recallDraw:Tick()
	for _,c in pairs(sEnemies) do		
		if c.visible then
			lastpos [ c.networkID ] = Vector(c) 
			lasttime[ c.networkID ] = os.clock() 
			moving[ c.networkID ] = c.isMoving
		end
	end
	UpdateEnemiesDirection()
end
function ePrediction(unit, delay)
	if not unit.isMoving then return Vector(unit.pos) end
	local pathPot = unit.ms*(delay)
	for i = unit.pathIndex, unit.pathCount do	
		if unit:GetPath(i) and unit:GetPath(i-1) then
			local pStart = i == unit.pathIndex and unit.pos or unit:GetPath(i-1)
			local pEnd = unit:GetPath(i) 
			local iPathDist = GetDistance(pStart, pEnd) 
			if unit:GetPath(unit.pathIndex  - 1) then
				if pathPot > iPathDist then
					pathPot = pathPot-iPathDist
				else 
					local v = Vector(pStart) + (Vector(pEnd)-Vector(pStart)):normalized()*pathPot
					--DrawCircle3D(v.x, v.y, v.z, 20, 2, ARGB(255, 255, 111, 0))
					return v
				end
			end
		end
	end
	local pathPot = unit.ms*delay
	local v = Vector(unit) + (Vector(unit.endPath)-Vector(unit)):normalized()*pathPot
	return v
end

function UpdateEnemiesDirection()
	for i, enemy in pairs(sEnemies) do
		if ValidTarget(enemy) then
			local dir = ePrediction(enemy, 0.1)
			if dir then 
				direction[enemy.networkID] = dir
			end
		end
	end	
end
function recallDraw:Draw()
	--DrawArc(recall.unit.x, recall.unit.y, recall.unit.z, 525.5+recall.unit.boundingRadius, 2, ARGB(255, 255,255,255), 77, recall.unit, m)
	--DrawArc(myHero.x, myHero.y, myHero.z, 555, 2, ARGB(255, 255,255,255), 77, myHero, mousePos, true)
	--[[for i, enemy in pairs(sEnemies) do
		if lasttime[enemy.networkID] and not enemy.visible then
			local endSpot = Vector(enemy.pos) + (Vector(direction[enemy.networkID])-Vector(enemy.pos)):normalized()*(enemy.ms*(os.clock() - lasttime[enemy.networkID]))
		--	DrawArc(enemy.x, enemy.y, enemy.z, 525.5+enemy.boundingRadius, 2, ARGB(255, 255,255,255), 77, enemy, endSpot)
		end
	end]]
    
	if MainMenu.recall.enable then
		for i, recall in pairs(activeRecalls) do
			if lasttime[recall.unit.networkID] then 
				local rActual = recall.startT - lasttime[recall.unit.networkID]
				if not recall.unit.visible and lasttime[recall.unit.networkID] and rActual < 10 then
					
					local rtt = rActual > 0 and rActual or 0.00001
					local recallWidth = recall.unit.ms*rtt
					local m = Vector(recall.unit.pos) + (Vector(direction[recall.unit.networkID])-Vector(recall.unit.pos)):normalized()*recallWidth
					
					local map
					if tostring(m.x) == '-1.#IND' then
						m = recall.unit
						map = GetMinimap(recall.unit.pos)
					else
						map = GetMinimap(m)
					end
					local check = WorldToScreen(D3DXVECTOR3(m.x, m.y, m.z))
					local rTime = recall.endT - os.clock() < 0 and 0 or recall.endT - os.clock()
					local color2 = 255 - rActual * 25.5
					if OnScreen(check.x, check.z) then
						local color
						local distR = GetDistance(m,recall.unit.pos)
						if not moving[recall.unit.networkID] then
							recallWidth = recallWidth - recall.unit.boundingRadius
							recallWidth = recallWidth >= recall.unit.boundingRadius and recallWidth or recall.unit.boundingRadius
							color = RGB(0, 255, 255)
							DrawText3D(tostring(string.format("%.1f", rTime, 1)), m.x, m.y, m.z, 30, RGB(0, 255, 255), true)
							DrawCircle2555(m.x, m.y, m.z, recallWidth, 2, color and color or RGB(color2, color2, 0))
							DrawText3D(tostring(recall.name.." Recall Spot"), m.x, m.y, m.z-30, 30, RGB(255, 255, 255), true)
						elseif rActual <= 0.00001 then
							color = RGB(0, 255, 0)
							DrawText3D(tostring(string.format("%.1f", rTime, 1)), m.x, m.y, m.z, 30, RGB(0, 255, 255), true)
							DrawCircle2555(m.x, m.y, m.z, recall.unit.boundingRadius, 2, color and color or RGB(color2, color2, 0))
							DrawText3D(tostring(recall.name.." Recall Spot"), m.x, m.y, m.z-30, 30, RGB(255, 255, 255), true)
						elseif recallWidth < 100 then
							recallWidth = recallWidth - recall.unit.boundingRadius
							recallWidth = recallWidth >= recall.unit.boundingRadius and recallWidth or recall.unit.boundingRadius
							color = RGB(255, 255, 0)
							DrawText3D(tostring(string.format("%.1f", rTime, 1)), m.x, m.y, m.z, 30, RGB(0, 255, 255), true)
							DrawCircle2555(m.x, m.y, m.z, recallWidth, 2, color and color or RGB(color2, color2, 0))
							DrawText3D(tostring(recall.name.." Recall Spot"), m.x, m.y, m.z-30, 30, RGB(255, 255, 255), true)
						else
						
							DrawArc(recall.unit.x, recall.unit.y, recall.unit.z, 525.5+recall.unit.boundingRadius, 2, ARGB(255, 255,255,255), 77, recall.unit, m)
							DrawText3D(tostring(recall.name.." Predicted Recall Area"), recall.unit.x, recall.unit.y, recall.unit.z -30, 30, color and color or RGB(color2, color2, 0), true)
							DrawText3D(tostring(string.format("%.1f", rTime, 1)), recall.unit.x+5, recall.unit.y, recall.unit.z+24, 30, color and color or RGB(color2, color2, 0), true)
						end
						
						
					end
					if tostring(m.x) ~= '-1.#IND' then	
						DrawText(tostring(string.format("%.1f", rTime, 1)), 17, map.x - (17/6), map.y - (17/6), color and color or RGB(color2, color2, 0))
					end
				end
			end
		end
	end
end
function DrawCircleNextLvler6(x, y, z, radius, width, color, chordlength)
    radius = radius or 300
    quality = math.max(8,math.floor(180/math.deg((math.asin((chordlength/(2*radius)))))))
    quality = 2 * math.pi / quality
    radius = radius*.92
    local points = {}
    for theta = 0, 2 * math.pi + quality, quality do
		local b = D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta))
        local c = WorldToScreen(b)
		if not IsWall(b) then
			points[#points + 1] = D3DXVECTOR2(c.x, c.y)
		end
    end
    DrawLines2(points, width, color or 4294967295)
end
function GetVision(spot)
	local closest = nil

	for i = 1, objManager.maxObjects do
        local object = objManager:GetObject(i)

		if object and object.valid and object.team == myHero.team then
			if GetDistance(object, spot) < 1200 then
				return true
			end
		end
	end
end
function DrawCircle2555(x, y, z, radius, width, color, chordlength)
    local vPos1 = Vector(x, y, z)
    local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
    local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
    local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
    if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y }) then
        DrawCircleNextLvler6(x, y, z, radius, width, color, chordlength or 75)
    end
end

local lshift, rshift, band, bxor = bit32.lshift, bit32.rshift, bit32.band, bit32.bxor

function recallDraw:RecvPacket(p)
	if mLib and p.header == mLib.recallHeader  then --recall
		p.pos = mLib.recallPos1
		--local spellid1 = p:Decode1()
		--print("spell "..spellid1)
		local bytes = {}
		for i=4, 1, -1 do
			bytes[i] = mLib.IDBytes[p:Decode1()]
		end
		local netID = bxor(lshift(band(bytes[1],0xFF),24),lshift(band(bytes[2],0xFF),16),lshift(band(bytes[3],0xFF),8),band(bytes[4],0xFF))
		local o = objManager:GetObjectByNetworkId(DwordToFloat(netID))

		if o and o.valid and o.type == 'AIHeroClient' and o.team == TEAM_ENEMY then
			p.pos = mLib.recallPos2
			local str = ''
			for i=1, p.size do
				local char = p:Decode1()
				if char == 0 then break end
				str=str..string.char(char)
			end
			if recallTimes[str:lower()] then
				local r = {}
				r.unit = o
				r.name = o.charName
				r.startT = os.clock()
				r.duration = recallTimes[str:lower()]
				r.endT = r.startT + r.duration
				if MainMenu.recall.print then
					if not o.visible and lasttime[o.networkID]  then 
						
						Print(r.name.." is recalling. Last seen "..string.format("%.1f", os.clock() -lasttime[o.networkID], 1).." seconds ago." )
						--print("someone recalling1")
					
						--print(r.name.." is recalling.")
						--print("Someone is recalling2")
					end
				end
				activeRecalls[o.networkID] = r
				return
			elseif activeRecalls[o.networkID] then
				if activeRecalls[o.networkID] and activeRecalls[o.networkID].endT > os.clock() then
					if MainMenu.recall.print then
						Print(activeRecalls[o.networkID].name.." canceled recall")
					end
					recallTime = nil
					recallName = nil
					blockName = nil
					activeRecalls[o.networkID] = nil
					return
				else
					if junglerName == activeRecalls[o.networkID].name then
						jungleText = "Recalled"
					end
					if MainMenu.recall.print then
						Print(activeRecalls[o.networkID].name.." finished recall")
					end
					activeRecalls[o.networkID] = nil
					recallTime = nil
					recallName = nil
					blockName = nil
					return
				end
			end
		end
	end
end
function GetClosestNotWall(unit, b)
	for i = 0, 0.99, 0.019 do
		local spot = Vector(b) + (Vector(unit) - Vector(b)):normalized() * (GetDistance(unit,b)*i)
		local b = D3DXVECTOR3(spot.x, spot.y, spot.z)
		if not IsWall(b) then
			return WorldToScreen(b)
		end
	end
end
function DrawArcNextLvl(x, y, z, radius, width, color, chordlength, unit, endPos, small)
    radius = GetDistance(endPos, unit.pos)
	radius = radius*.98
	newspot = Vector(unit.pos)
	newspot.y = newspot.y + 10
	--local angle = Vector(unit.pos):angleBetween(Vector(CastPosition), Vector(myHero.pos))
	local df = angleBetweenArc(Vector(unit.pos), Vector(newspot), Vector(endPos))
	local startAngle = df +110
    local points = {}
	local arcWidth = 140
	
	for theta = arcWidth, 0, -5 do
		local a = (startAngle+theta)*math.pi/180
		local b = D3DXVECTOR3(x + unit.boundingRadius * math.cos(a), y, z - unit.boundingRadius * math.sin(a))
		local c = WorldToScreen(b)
		--if not IsWall(b) then
			points[#points + 1] = D3DXVECTOR2(c.x, c.y)
		--end
	end
	for theta = 0, arcWidth, 5 do
		local a = (startAngle+theta)*math.pi/180
		local b = D3DXVECTOR3(x + radius * math.cos(a), y, z - radius * math.sin(a))
		local c = WorldToScreen(b)
		if not IsWall(b) then
			points[#points + 1] = D3DXVECTOR2(c.x, c.y)
	
		end
	end
	local a = (startAngle+arcWidth)*math.pi/180
	local b = D3DXVECTOR3(x + unit.boundingRadius * math.cos(a), y, z - unit.boundingRadius * math.sin(a))
	local c = WorldToScreen(b)

	points[#points + 1] = D3DXVECTOR2(c.x, c.y)
	DrawLines2(points, width, color or 4294967295)
end

function DrawArc(x, y, z, radius, width, color, chordlength, unit, endPos, small)
    local vPos1 = Vector(x, y, z)
    local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
    local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
    local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
    if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y }) then
        DrawArcNextLvl(x, y, z, radius, width, color, chordlength or 75, unit, endPos, small)
    end
end
function angleBetweenArc(v0, v1, v2)
    assert(VectorType(v1) and VectorType(v2), "angleBetween: wrong argument types (2 <Vector> expected)")
    local p1, p2 = (-v0 + v1), (-v0 + v2)
    local theta = p1:polar() - p2:polar()
	if theta < 0 then theta = theta + 180 end
   -- if theta > 180 then theta = 180 - theta end
    return theta
end
