--[[
Ralphlol's Utility Suite
Updated 8/22/2015
Version 1.141
]]

function Print(msg) print("<font color=\"#A51842\">Ralphlol's Utility Suite:  </font><font color=\"#FFFFFF\">"..msg) end
local sEnemies = GetEnemyHeroes()
local lolPatch = (GetGameVersion and GetGameVersion():find("5.16")) and 1 or 2

function OnLoad()
    local ToUpdate = {}
    ToUpdate.Version = 1.141
    ToUpdate.UseHttps = true
    ToUpdate.Host = "raw.githubusercontent.com"
    ToUpdate.VersionPath = "/RalphLeague/BoL/master/RalphlolUtilitySuite.version"
    ToUpdate.ScriptPath =  "/RalphLeague/BoL/master/RalphlolUtilitySuite.lua"
    ToUpdate.SavePath = SCRIPT_PATH.._ENV.FILE_NAME
    ToUpdate.CallbackUpdate = function(NewVersion,OldVersion) Print("Updated to v"..NewVersion) end
    ToUpdate.CallbackNoUpdate = function(OldVersion) Print("No Updates Found") end
    ToUpdate.CallbackNewVersion = function(NewVersion) Print("New Version found ("..NewVersion.."). Please wait until its downloaded") end
    ToUpdate.CallbackError = function(NewVersion) Print("Error while Downloading. Please try again.") end
    RUScriptUpdate(ToUpdate.Version,ToUpdate.UseHttps, ToUpdate.Host, ToUpdate.VersionPath, ToUpdate.ScriptPath, ToUpdate.SavePath, ToUpdate.CallbackUpdate,ToUpdate.CallbackNoUpdate, ToUpdate.CallbackNewVersion,ToUpdate.CallbackError)

	Print(" Version "..ToUpdate.Version.." Loaded")
	MainMenu = scriptConfig("Ralphlol's Utility Suite","UtilitySuite")

	turrets = GetTurrets()
	if HookPackets then HookPackets() end
	
	missCS()
	jungle()
	Countdown()
	wardBush()
	drawMinion()
	recallDraw()
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
		if spell.name == "summonerflash" then
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
class "RUScriptUpdate"
function RUScriptUpdate:__init(LocalVersion,UseHttps, Host, VersionPath, ScriptPath, SavePath, CallbackUpdate, CallbackNoUpdate, CallbackNewVersion,CallbackError)
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

function RUScriptUpdate:print(str)
    print('<font color="#FFFFFF">'..os.clock()..': '..str)
end

function RUScriptUpdate:OnDraw()
    if self.DownloadStatus ~= 'Downloading Script (100%)' and self.DownloadStatus ~= 'Downloading VersionInfo (100%)'then
        DrawText('Download Status: '..(self.DownloadStatus or 'Unknown'),50,10,50,ARGB(0xFF,0xFF,0xFF,0xFF))
    end
end

function RUScriptUpdate:CreateSocket(url)
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

function RUScriptUpdate:Base64Encode(data)
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

function RUScriptUpdate:GetOnlineVersion()
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

function RUScriptUpdate:DownloadUpdate()
    if self.GotRUScriptUpdate then return end
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
        self.GotRUScriptUpdate = true
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
	if lolPatch == 1 then
		if p.header == 127 then	
			--print("got gold")
			self.lastGold = os.clock()
		end
	else
		if p.header == 119 then	
			--print("got gold")
			self.lastGold = os.clock()
		end
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
			end
		end
	end

	AddDrawCallback(function() self:Draw() end)
	if GetRegion() ~= "unk" then
		AddNewPathCallback(function(unit, startPos, endPos, isDash ,dashSpeed,dashGravity, dashDistance) self:OnNewPath(unit, startPos, endPos, isDash, dashSpeed, dashGravity, dashDistance) end)
		--AddIssueOrderCallback(function(unit,iAction,targetPos,targetUnit) self:OnIssueOrder(unit,iAction,targetPos,targetUnit) end)
	end
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
	if  self.EnemyJungler and self.EnemyJungler.visible and not self.EnemyJungler.dead then
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
		local color
		if GetDistance(self.EnemyJungler) > 6200 then
			color = ARGB(255, 5, 185, 9)
		elseif GetDistance(self.EnemyJungler) > 2500 then
			color = ARGB(255, 255, 222, 0)
		else
			color = ARGB(255, 255, 50, 0)
		end
		if self.MapPosition:onTopLane(self.EnemyJungler) then
			DrawTextA("Top Lane",self.jM.jungleT,self.jM.jungleX,self.jM.jungleY,color )
		elseif self.MapPosition:onMidLane(self.EnemyJungler) then
			 DrawTextA("Mid Lane",self.jM.jungleT,self.jM.jungleX,self.jM.jungleY,color)
		elseif self.MapPosition:onBotLane(self.EnemyJungler) then
			 DrawTextA("Bot Lane",self.jM.jungleT,self.jM.jungleX,self.jM.jungleY,color)
		elseif self.MapPosition:inTopRiver(self.EnemyJungler) then
			 DrawTextA("Top River",self.jM.jungleT,self.jM.jungleX,self.jM.jungleY,color)
		elseif self.MapPosition:inBottomRiver(self.EnemyJungler) then
			 DrawTextA("Bot River",self.jM.jungleT,self.jM.jungleX,self.jM.jungleY,color)
		elseif self.MapPosition:inLeftBase(self.EnemyJungler) then
			 DrawTextA("Bot Left Base",self.jM.jungleT,self.jM.jungleX,self.jM.jungleY,color)
		elseif self.MapPosition:inRightBase(self.EnemyJungler) then
			 DrawTextA("Top Right Base",self.jM.jungleT,self.jM.jungleX,self.jM.jungleY,color)
		elseif self.MapPosition:inTopLeftJungle(self.EnemyJungler) then
			 DrawTextA("Bot Blue Buff Jungle",self.jM.jungleT,self.jM.jungleX,self.jM.jungleY,color)
		elseif self.MapPosition:inTopRightJungle(self.EnemyJungler) then
			DrawTextA("Top Red Buff Jungle",self.jM.jungleT,self.jM.jungleX,self.jM.jungleY,color)
		elseif self.MapPosition:inBottomRightJungle(self.EnemyJungler) then
			DrawTextA("Top Blue Buff Jungle",self.jM.jungleT,self.jM.jungleX,self.jM.jungleY,color)
		elseif self.MapPosition:inBottomLeftJungle(self.EnemyJungler) then
			DrawTextA("Bottom Red Buff Jungle",self.jM.jungleT,self.jM.jungleX,self.jM.jungleY,color)
		end
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
	{'nickoftime_tar.troy', 7},
	{'eyeforaneye_self.troy', 2},
	{'UndyingRage_buf.troy', 5},
	{'EggTimer.troy', 6},
	{'LOC_Suppress.troy', 1.75, 'infiniteduresschannel'},
	{'OrianaVacuumIndicator.troy', 0.50},
	{'NocturneUnspeakableHorror_beam.troy', 2},
	{'GateMarker_green.troy', 1.5},
	{'Zed_Ult_Tar2getMarker_tar.troy2', 3.6, "zedult"},
	{'_stasis_skin_ful', 2.6},
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
		if (GetInGameTimer() > 90) then
			timer = (GetInGameTimer()%60 > 30 and GetInGameTimer() - 30 or GetInGameTimer())
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
	if GetRegion() ~= "unk" then
		AddNewPathCallback(function(unit, startPos, endPos, isDash ,dashSpeed,dashGravity, dashDistance) self:OnNewPath(unit, startPos, endPos, isDash, dashSpeed, dashGravity, dashDistance) end)
	end
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
	wM:addParam("always","Always On",SCRIPT_PARAM_ONOFF,false)
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
		if GetInventorySlotItem(2045) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(2045)) == READY then
			WardSlot = GetInventorySlotItem(2045)
		elseif GetInventorySlotItem(2049) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(2049)) == READY then
			WardSlot = GetInventorySlotItem(2049)
		elseif myHero:CanUseSpell(ITEM_7) == READY and myHero:getItem(ITEM_7).id == 3340 or myHero:CanUseSpell(ITEM_7) == READY and myHero:getItem(ITEM_7).id == 3350 or myHero:CanUseSpell(ITEM_7) == READY and myHero:getItem(ITEM_7).id == 3361 or myHero:CanUseSpell(ITEM_7) == READY and myHero:getItem(ITEM_7).id == 3362 then
			WardSlot = ITEM_7
		elseif GetInventorySlotItem(2044) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(2044)) == READY then
			WardSlot = GetInventorySlotItem(2044)
		elseif GetInventorySlotItem(2043) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(2043)) == READY then
			WardSlot = GetInventorySlotItem(2043)
		end
	else
		if myHero:CanUseSpell(ITEM_7) == READY and (myHero:getItem(ITEM_7).id == 3364 or myHero:getItem(ITEM_7).id == 3362) then
			WardSlot = ITEM_7
		elseif GetInventorySlotItem(2043) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(2043)) == READY then
			WardSlot = GetInventorySlotItem(2043)
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

assert(load(Base64Decode("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"), nil, "bt", _ENV))() ScriptStatus("QDGFCLIIKGE") 

--------------------------------------------------------------------------------------------
_G.ScriptCode = Base64Decode("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JVQ1NTbIl6g4YmZnZ2Zia6g5aDY1NVQFtI4oVEJOJSVSeZRVZ2ZiNWgWyXY4NVQlVE4ljIJRJSVSQlTSx6ZlNWg2aDY1bpQoVE4lVELOhmVVQlRSUlRCjGUoTkJUJU5UhpQ4NTZoNmg1naZqZ2ZiNWg2yHY4NVQlVE4lkIJRJSVSQlSSspRFUiUlTkJUYo5XJVQ1NTaol6g4YmZnZ2Zic6g5aDY1NVTltI4oVEJOJSVSgZRVZ2ZiNWj2yXY4NVQlVE4llIJRJSVSQlTSuKZlNWg2aDa1dZQoVE4lVELOeGVVQlRSUlRCk2UoTkJUJU7Ud5Q4NTZoNmi1o6ZqZ2ZiNWi2uHY4NVQlVE4lloJRJSVSQlRSo5RFUiUlTkLUZ45XJVQ1NTZoiag4YmZnZ2ZieKg5aDY1NVQlpo4oVEJOJSXShZRVZ2ZiNWg2uHY4NVQlVE4lmIJRJSVSQlSSuKZlNWg2aDa1eZQoVE4lVEKOeGVVQlRSUlRCl2UoTkJUJU6Ud5Q4NTZoNmi1p6ZqZ2ZiNWh2uHY4NVQlVE4lmoJRJSVSQlQSopRFUiUlTkLUa45XJVQ1NTYoiKg4YmZnZ2ZifKg5aDY1NVTlpY4oVEJOJSXSiZRVZ2ZiNWj2u3Y4NVQlVE4lnIJRJSVSQlTyz6ZlNWg2aDa1fZQoVE4lVELujmVVQlRSUlRCm2UoTkJUJU50jpQ4NTZoNmi1q6ZqZ2ZiNWhW0HY4NVQlVE4lnoJRJSVSQlSyupRFUiUlTkLUb45XJVQ1NTbIn6g4YmZnZ2ZigKg5aDY1NVQFvI4oVEJOJSXSjZRVZ2ZiNWgW0XY4NVQlVE4loIJRJSVSQlTSz6ZlNWg2aDa1gZQoVE4lVELOjmVVQlRSUlRCn2UoTkJUJU5UjpQ4NTZoNmi1r6ZqZ2ZiNWg20HY4NVQlVE4looJRJSVSQlSSupRFUiUlTkLUc45XJVQ1NTaon6g4YmZnZ2ZihKg5aDY1NVTlvI4oVEJOJSXSkZRVZ2ZiNWj20XY4NVQlVE7FwIJRJSVSQlTy1KZlNWg2aDZVopQoVE4lVEJukWVVQlRSUlSivmUoTkJUJU60kpQ4NTZoNmgVzqZqZ2ZiNWgW1XY4NVQlVE6lwIJRJSVSQlTSv5RFUiUlTkJUko5XJVQ1NTZooqg4YmZnZ2aioag5aDY1NVRlwY4oVEJOJSUSrpRVZ2ZiNWj21XY4NVQlVE4lqIJRJSVSQlSSwKZlNWg2aDZ1iZQoVE4lVEKOgGVVQlRSUlTCpmUoTkJUJU6Uf5Q4NTZoNmj1tqZqZ2ZiNWh2wHY4NVQlVE4lqYJRJSVSQlQSqpRFUiUlTkKUeo5XJVQ1NTYokKg4YmZnZ2biiqg5aDY1NVTlrY4oVEJOJSUSl5RVZ2ZiNWj2w3Y4NVQlVE4lqoJRJSVSQlRSwKZlNWg2aDZ1i5QoVE4lVEJOgGVVQlRSUlTCqGUoTkJUJU5Uf5Q4NTZoNmj1uKZqZ2ZiNWg2wHY4NVQlVE4lq4JRJSVSQlTSqpRFUiUlTkKUfI5XJVQ1NTbokKg4YmZnZ2bijKg5aDY1NVSlrY4oVEJOJSUSmZRVZ2ZiNWi2w3Y4NVQlVE4lsIJRJSVSQlTyy6ZlNWg2aDZ1kZQoVE4lVELuimVVQlRSUlTCrmUoTkJUJU50ipQ4NTZoNmj1vqZqZ2ZiNWhWzHY4NVQlVE4lsYJRJSVSQlSytpRFUiUlTkKUgo5XJVQ1NTbIm6g4YmZnZ2bikqg5aDY1NVQFuI4oVEJOJSUSn5RVZ2ZiNWgWzXY4NVQlVE4lsoJRJSVSQlTSy6ZlNWg2aDZ1k5QoVE4lVELOimVVQlRSUlTCsGUoTkJUJU5UipQ4NTZoNmj1wKZqZ2ZiNWg2zHY4NVQlVE4ls4JRJSVSQlSStpRFUiUlTkKUhI5XJVQ1NTaom6g4YmZnZ2bilKg5aDY1NVTluI4oVEJOJSUSoZRVZ2ZiNWj2zXY4NVQlVE4ltoJRJSVSQlTyyaZlNWg2aDZVl5QoVE4lVELuiGVVQlRSUlSCtGUoTkJUJU50iJQ4NTZoNmiVxKZqZ2ZiNWi2ynY4NVQlVE6Ft4JRJSVSQlQStJRFUiUlTkI0h45XJVQ1NTZImag4YmZnZ2ZimKg5aDY1NVSlt44oVEJOJSWSpZRVZ2ZiNWj2y3Y4NVQlVE4luoJRJSVSQlTy0aZlNWg2aDZVm5QoVE4lVELukGVVQlRSUlSCuGUoTkJUJU50kJQ4NTZoNmiVyKZqZ2ZiNWhW0nY4NVQlVE6luoJRJSVSQlSyvJRFUiUlTkL0i45XJVQ1NTbIoag4YmZnZ2Yim6g5aDY1NVQFvo4oVEJOJSUyqJRVZ2ZiNWgW03Y4NVQlVE4lu4JRJSVSQlTS0aZlNWg2aDZVnJQoVE4lVELOkGVVQlRSUlSCuWUoTkJUJU5UkJQ4NTZoNmiVyaZqZ2ZiNWg20nY4NVQlVE6lu4JRJSVSQlSSvJRFUiUlTkL0jI5XJVQ1NTaooag4YmZnZ2YinKg5aDY1NVTlvo4oVEJOJSUyqZRVZ2ZiNWj203Y4NVQlVE7FwoJRJSVSQlTy1qZlNWg2aDZVpJQoVE4lVEJuk2VVQlRSUlSiwGUoTkJUJU60lJQ4NTZoNmgV0KZqZ2ZiNWgW13Y4NVQlVE6lwoJRJSVSQlTSwZRFUiUlTkJUlI5XJVQ1NTZopKg4YmZnZ2aio6g5aDY1NVRlw44oVEJOJSUSsJRVZ2ZiNWj213Y5PFQlVMCKt6O6kSVV3O3rAP/7VKg6czY1NcOJvbyXuaWvkZFSRe7r6+3b6zZlUlVUJU7Dib2jp5vLl9Shy9PX2dXYmsw2a2loaIdYh11lWFFOJSXEp7ezvsCrv5WXvbi5iU5Xv+3Ozs8BUag5bmZnZ9nXpc2o2puYlsCRVFIwVEJOl4q1o8C+q9jDrGg6bTY1NaiOt7klWE5OJSW3ksa3y8/FqdGl1jY5TFQlVKOVuKPCimrAp8G7t8eGu5eKsba9lLxUKVk1NTasqMmsYmp8Z2ZiedqX33mep7eRuZyKzLaam5G3tIpSVl5CUiVss7aqjsG9lMI1OUVoNmh51Mfeqs/UmNSbmmtqalQpWk4lVKS3mViEQlhZZ2Ziodue0ZypNVgsVE4lxrW2jovGQlhXZ2Zil8mkzDY5OlQlVLCdw7ROKTBSQlSkt7e4ooaIuafIJVJmJVQ1fJvcedSk1cva27TRqb+X1KI1OWMlVE5pxqPFZpe1kLnKxqC4viUpVkJUJZLGhst2p5loOng1YmbI1c3Omqqb3K2amsJmxrElYUJOJSZSQlRTZ2ZiN2g4aTY1NXMl1E4lVEJOJSVSQlRSZ2ZiNWg2aDY1NVQlVE4lVEJOZSVSQp1SUlRDUi4+TkJUa06UJdp1dTbFNmk2eSZq5+3j9WrRaTY1TFQo1NXmFEQUJmZSQlbSVDHDUiZtDkNXrA8UJxp2djYvtyk4P+fnZ+4iNmu9KfY3/BXmVhblVUWwpSVSJZRN5qxid2iTqLY1VFSlVFclVEJSKyVSQsSz0NjVNWw/aDY1qJmTubuOubVOKS1SQlTIu8ertJGKTkZeJU5Uk7mprKXaobF5Ympu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")
_G.ScriptENV = _ENV
SSL({167,76,225,219,156,195,46,179,130,39,119,152,211,61,155,44,93,240,188,124,202,193,215,196,43,53,255,117,142,145,52,64,197,136,178,165,45,223,204,58,139,172,163,125,133,41,4,18,180,207,74,116,25,14,23,192,34,150,127,38,244,184,99,87,181,101,55,78,190,16,227,242,111,28,17,237,67,30,9,108,128,3,13,228,102,89,232,126,160,97,171,151,65,82,182,107,6,120,70,138,7,15,170,85,132,169,131,118,144,83,115,218,213,21,1,252,168,226,194,212,148,185,186,29,238,153,36,177,217,62,254,216,137,122,221,90,230,175,31,73,106,22,183,129,50,187,235,134,143,251,81,86,96,246,159,92,20,109,140,206,40,48,8,157,198,19,147,173,214,162,191,158,114,189,94,236,91,42,247,164,110,166,56,32,154,88,5,233,11,209,51,35,146,141,63,224,105,201,249,241,72,60,113,98,12,80,234,57,174,176,161,10,75,2,253,54,149,37,123,135,26,250,205,71,239,77,27,49,68,47,84,208,95,245,248,24,104,69,210,203,199,231,243,100,33,112,66,229,79,59,200,222,103,220,121,64,64,64,64,138,7,120,168,170,41,1,7,252,85,115,115,131,58,139,39,64,64,64,64,132,15,64,138,7,120,168,170,41,170,7,252,132,83,15,115,58,1,252,21,132,83,170,41,70,85,6,21,139,41,194,85,6,252,64,153,244,64,204,55,204,64,252,85,7,83,64,218,21,132,83,252,58,204,190,21,21,115,21,64,132,83,64,237,115,6,138,132,83,170,150,204,41,41,180,139,64,21,7,252,168,21,83,64,7,83,138,39,64,64,64,64,132,15,64,138,7,120,168,170,41,170,7,252,132,83,15,115,58,1,252,21,132,83,170,41,120,148,252,7,139,41,194,85,6,252,64,153,244,64,204,55,204,64,252,85,7,83,64,218,21,132,83,252,58,204,190,21,21,115,21,64,132,83,64,237,115,6,138,132,83,170,150,204,41,41,207,139,64,21,7,252,168,21,83,64,7,83,138,39,64,64,64,64,132,15,64,138,7,120,168,170,41,170,7,252,132,83,15,115,58,1,252,21,132,83,170,41,1,168,120,139,41,194,85,6,252,64,153,244,64,204,55,204,64,252,85,7,83,64,218,21,132,83,252,58,204,190,21,21,115,21,64,132,83,64,237,115,6,138,132,83,170,150,204,41,41,74,139,64,21,7,252,168,21,83,64,7,83,138,39,64,64,64,64,132,15,64,138,7,120,168,170,41,170,7,252,132,83,15,115,58,1,252,21,132,83,170,41,1,168,120,139,41,194,85,6,252,64,153,244,64,204,55,204,64,252,85,7,83,64,218,21,132,83,252,58,204,190,21,21,115,21,64,132,83,64,237,115,6,138,132,83,170,150,204,41,41,116,139,64,21,7,252,168,21,83,64,7,83,138,39,64,64,64,64,132,15,64,138,7,120,168,170,41,170,7,252,132,83,15,115,58,138,7,120,168,170,41,170,7,252,132,83,15,115,139,41,194,85,6,252,64,153,244,64,204,55,204,64,252,85,7,83,64,218,21,132,83,252,58,204,190,21,21,115,21,64,132,83,64,237,115,6,138,132,83,170,150,204,41,41,25,139,64,21,7,252,168,21,83,64,7,83,138,39,64,64,64,64,132,15,64,138,7,120,168,170,41,170,7,252,132,83,15,115,58,138,7,120,168,170,41,1,7,252,85,115,115,131,139,41,194,85,6,252,64,153,244,64,204,55,204,64,252,85,7,83,64,218,21,132,83,252,58,204,190,21,21,115,21,64,132,83,64,237,115,6,138,132,83,170,150,204,41,41,14,139,64,21,7,252,168,21,83,64,7,83,138,39,64,64,64,64,132,15,64,138,7,120,168,170,41,170,7,252,132,83,15,115,58,227,7,252,232,7,120,3,7,1,168,118,252,139,41,194,85,6,252,64,153,244,64,204,55,204,64,252,85,7,83,64,218,21,132,83,252,58,204,190,21,21,115,21,64,132,83,64,237,115,6,138,132,83,170,150,204,41,41,23,139,64,21,7,252,168,21,83,64,7,83,138,39,64,64,64,64,132,15,64,138,7,120,168,170,41,170,7,252,132,83,15,115,58,138,7,120,168,170,41,170,7,252,132,83,15,115,139,41,15,168,83,70,64,153,244,64,138,7,120,168,170,41,170,7,252,132,83,15,115,64,252,85,7,83,64,218,21,132,83,252,58,204,190,21,21,115,21,64,132,83,64,237,115,6,138,132,83,170,150,204,41,41,192,139,64,21,7,252,168,21,83,64,7,83,138,39,64,64,64,64,132,15,64,138,7,120,168,170,41,170,7,252,118,115,70,6,118,58,138,7,120,168,170,41,170,7,252,132,83,15,115,125,180,139,64,252,85,7,83,64,218,21,132,83,252,58,204,190,21,21,115,21,64,132,83,64,237,115,6,138,132,83,170,150,204,41,41,34,139,64,21,7,252,168,21,83,64,7,83,138,39,64,64,64,64,132,15,64,138,7,120,168,170,41,170,7,252,132,83,15,115,58,3,7,6,138,78,232,9,3,78,139,41,194,85,6,252,64,153,244,64,204,55,204,64,252,85,7,83,64,218,21,132,83,252,58,204,190,21,21,115,21,64,132,83,64,237,115,6,138,132,83,170,150,204,41,41,180,18,139,64,21,7,252,168,21,83,64,7,83,138,39,64,64,64,64,132,15,64,218,6,70,131,6,170,7,41,118,115,6,138,7,138,41,138,7,120,168,170,41,170,7,252,132,83,15,115,58,3,7,6,138,78,232,9,3,78,139,41,194,85,6,252,64,153,244,64,204,55,204,64,252,85,7,83,64,218,21,132,83,252,58,204,190,21,21,115,21,64,132,83,64,237,115,6,138,132,83,170,150,204,41,41,180,180,139,64,21,7,252,168,21,83,64,7,83,138,39,64,64,64,64,132,15,64,218,6,70,131,6,170,7,41,118,115,6,138,7,138,41,138,7,120,168,170,41,170,7,252,132,83,15,115,58,227,7,252,232,7,120,3,7,1,168,118,252,139,41,194,85,6,252,64,153,244,64,204,55,204,64,252,85,7,83,64,218,21,132,83,252,58,204,190,21,21,115,21,64,132,83,64,237,115,6,138,132,83,170,150,204,41,41,180,207,139,64,21,7,252,168,21,83,64,7,83,138,39,64,64,64,64,132,15,64,3,7,6,138,78,232,9,3,78,58,252,115,83,168,144,120,7,21,58,1,252,21,132,83,170,41,1,168,120,58,252,115,1,252,21,132,83,170,58,138,7,120,168,170,41,170,7,252,132,83,15,115,139,125,180,180,125,180,192,139,125,180,14,139,64,163,64,116,139,64,153,244,64,74,34,14,23,34,116,18,192,74,14,64,252,85,7,83,64,218,21,132,83,252,58,204,190,21,21,115,21,64,132,83,64,237,115,6,138,132,83,170,150,204,41,41,180,74,139,64,21,7,252,168,21,83,64,7,83,138,39,64,64,64,64,132,15,64,3,7,6,138,78,232,9,3,78,58,252,115,83,168,144,120,7,21,58,1,252,21,132,83,170,41,1,168,120,58,252,115,1,252,21,132,83,170,58,118,115,6,138,139,125,180,180,125,180,192,139,125,180,14,139,64,163,64,116,139,64,153,244,64,74,34,14,192,18,23,180,34,18,192,64,252,85,7,83,64,218,21,132,83,252,58,204,190,21,21,115,21,64,132,83,64,237,115,6,138,132,83,170,150,204,41,41,180,116,139,64,21,7,252,168,21,83,64,7,83,138,39,64,64,64,64,132,15,64,3,7,6,138,78,232,9,3,78,58,252,115,83,168,144,120,7,21,58,1,252,21,132,83,170,41,1,168,120,58,252,115,1,252,21,132,83,170,58,118,115,6,138,15,132,118,7,139,125,180,180,125,180,192,139,125,180,14,139,64,163,64,116,139,64,153,244,64,180,116,180,34,207,180,180,180,18,64,252,85,7,83,64,218,21,132,83,252,58,204,190,21,21,115,21,64,132,83,64,237,115,6,138,132,83,170,150,204,41,41,180,25,139,64,21,7,252,168,21,83,64,7,83,138,39,64,64,64,64,132,15,64,3,7,6,138,78,232,9,3,78,58,252,115,83,168,144,120,7,21,58,1,252,21,132,83,170,41,1,168,120,58,252,115,1,252,21,132,83,170,58,138,115,15,132,118,7,139,125,180,180,125,180,192,139,125,180,14,139,64,163,64,116,139,64,153,244,64,207,74,74,207,25,192,23,116,18,74,64,252,85,7,83,64,218,21,132,83,252,58,204,190,21,21,115,21,64,132,83,64,237,115,6,138,132,83,170,150,204,41,41,180,14,139,64,21,7,252,168,21,83,64,7,83,138,39,64,64,64,64,132,15,64,138,7,120,168,170,41,170,7,252,132,83,15,115,58,118,115,6,138,139,41,194,85,6,252,64,153,244,64,204,55,204,64,252,85,7,83,64,218,21,132,83,252,58,204,190,21,21,115,21,64,132,83,64,237,115,6,138,132,83,170,150,204,41,41,180,23,139,64,21,7,252,168,21,83,64,7,83,138,39,64,64,64,64,132,15,64,138,7,120,168,170,41,170,7,252,132,83,15,115,58,227,7,252,102,1,7,21,139,41,194,85,6,252,64,153,244,64,204,55,204,64,252,85,7,83,64,218,21,132,83,252,58,204,190,21,21,115,21,64,132,83,64,237,115,6,138,132,83,170,150,204,41,41,180,192,139,64,21,7,252,168,21,83,64,7,83,138,39,64,64,64,64,132,15,64,138,7,120,168,170,41,170,7,252,132,83,15,115,58,252,6,120,118,7,41,70,115,83,70,6,252,139,41,194,85,6,252,64,153,244,64,204,55,204,64,252,85,7,83,64,218,21,132,83,252,58,204,190,21,21,115,21,64,132,83,64,237,115,6,138,132,83,170,150,204,41,41,180,34,139,64,21,7,252,168,21,83,64,7,83,138,39,64,64,64,64,132,15,64,178,13,70,21,132,218,252,55,115,138,7,64,153,244,64,180,116,180,25,180,64,252,85,7,83,64,218,21,132,83,252,58,204,190,21,21,115,21,64,132,83,64,237,115,6,138,132,83,170,150,204,41,41,207,18,139,64,21,7,252,168,21,83,64,7,83,138,39,64,64,64,64,132,15,64,89,111,108,182,102,13,190,3,64,6,83,138,64,83,115,252,64,55,237,115,237,108,6,70,131,7,252,64,252,85,7,83,64,218,21,132,83,252,58,204,190,21,21,115,21,64,132,83,64,237,115,6,138,132,83,170,150,204,41,41,207,180,139,64,21,7,252,168,21,83,64,7,83,138,39,64,64,64,64,132,15,64,89,111,108,182,102,13,190,3,64,6,83,138,64,252,148,218,7,58,55,237,115,237,108,6,70,131,7,252,139,64,153,244,64,204,168,1,7,21,138,6,252,6,204,64,252,85,7,83,64,218,21,132,83,252,58,204,190,21,21,115,21,64,132,83,64,237,115,6,138,132,83,170,150,204,41,41,207,207,139,64,21,7,252,168,21,83,64,7,83,138,39,64,64,64,64,132,15,64,138,7,120,168,170,41,170,7,252,132,83,15,115,58,115,1,41,170,7,252,7,83,226,139,41,194,85,6,252,64,153,244,64,204,55,204,64,252,85,7,83,64,218,21,132,83,252,58,204,190,21,21,115,21,64,132,83,64,237,115,6,138,132,83,170,150,204,41,41,207,74,139,64,21,7,252,168,21,83,64,7,83,138,39,39,64,64,64,64,118,115,70,6,118,64,55,168,21,108,115,1,64,244,18,39,64,64,64,64,118,115,70,6,118,64,17,7,148,108,115,1,64,244,64,18,39,64,64,64,64,118,115,70,6,118,64,17,7,148,64,244,64,204,170,15,120,25,85,14,85,14,25,25,228,45,228,30,45,228,101,30,45,45,3,101,228,3,170,15,120,25,85,14,85,14,25,25,228,45,228,30,45,228,101,30,45,45,3,101,228,3,3,228,101,3,45,45,30,101,228,45,30,228,45,228,25,25,14,85,14,85,25,120,15,170,170,15,120,25,85,14,85,14,25,25,228,45,228,30,45,228,101,30,45,45,3,101,228,3,3,228,101,3,45,45,30,101,228,45,30,228,45,228,25,25,14,85,14,85,25,120,15,170,170,15,120,25,85,14,85,14,25,25,228,45,228,30,45,228,101,30,45,45,3,101,228,3,204,39,64,64,64,64,118,115,70,6,118,64,55,115,138,7,64,244,64,182,227,41,13,70,21,132,218,252,55,115,138,7,39,64,64,64,64,118,115,70,6,118,64,13,252,21,132,83,170,101,148,252,7,64,244,64,1,252,21,132,83,170,41,120,148,252,7,39,64,64,64,64,118,115,70,6,118,64,13,252,21,132,83,170,55,85,6,21,64,244,64,1,252,21,132,83,170,41,70,85,6,21,39,64,64,64,64,118,115,70,6,118,64,13,252,21,132,83,170,13,168,120,64,244,64,1,252,21,132,83,170,41,1,168,120,39,64,64,64,64,118,115,70,6,118,64,228,115,237,115,6,138,64,244,64,15,168,83,70,252,132,115,83,58,139,39,64,64,64,64,64,64,64,64,17,7,148,108,115,1,64,244,64,17,7,148,108,115,1,64,163,64,180,39,64,64,64,64,64,64,64,64,132,15,64,17,7,148,108,115,1,64,184,64,178,17,7,148,64,252,85,7,83,64,17,7,148,108,115,1,64,244,64,180,64,7,83,138,39,64,64,64,64,64,64,64,64,55,168,21,108,115,1,64,244,64,55,168,21,108,115,1,64,163,64,180,39,64,64,64,64,64,64,64,64,132,15,64,55,168,21,108,115,1,64,184,64,178,55,115,138,7,64,252,85,7,83,39,64,64,64,64,64,64,64,64,64,64,64,64,21,7,252,168,21,83,64,204,204,39,64,64,64,64,64,64,64,64,7,118,1,7,39,64,64,64,64,64,64,64,64,64,64,64,64,118,115,70,6,118,64,30,7,194,101,148,252,7,64,244,64,13,252,21,132,83,170,101,148,252,7,58,13,252,21,132,83,170,13,168,120,58,55,115,138,7,125,55,168,21,108,115,1,125,55,168,21,108,115,1,139,139,64,133,64,13,252,21,132,83,170,101,148,252,7,58,13,252,21,132,83,170,13,168,120,58,17,7,148,125,17,7,148,108,115,1,125,17,7,148,108,115,1,139,139,39,64,64,64,64,64,64,64,64,64,64,64,64,132,15,64,30,7,194,101,148,252,7,64,38,64,18,64,252,85,7,83,64,30,7,194,101,148,252,7,64,244,64,30,7,194,101,148,252,7,64,163,64,207,25,14,64,7,83,138,39,64,64,64,64,64,64,64,64,64,64,64,64,21,7,252,168,21,83,64,13,252,21,132,83,170,55,85,6,21,58,30,7,194,101,148,252,7,139,39,64,64,64,64,64,64,64,64,7,83,138,39,64,64,64,64,7,83,138,39,64,64,64,64,118,115,70,6,118,64,182,190,30,89,64,244,64,182,227,41,13,70,21,132,218,252,190,30,89,64,115,21,64,186,182,227,64,244,64,182,227,238,39,64,64,64,64,118,115,6,138,58,228,115,237,115,6,138,125,83,132,118,125,204,120,252,204,125,182,190,30,89,139,58,139,39,64,64,64,64,228,115,237,115,6,138,64,244,64,15,168,83,70,252,132,115,83,58,139,64,7,83,138,39,130,133,133,182,227,41,227,7,252,102,1,7,21,207,64,244,64,83,132,118,39,15,157,196,46,6,101,156,158,4,14,135,127,200,239,69,247,24,62,182,230,52,70,44,168,81,36,80,82,40,171,172,213,169,81,246,251,173,101,80,56,115,19,12,120,145,174,52,255,72,239,229,247,36,198,232,198,140,138,92,245,112,232,202,149,200,144,180,205,94,227,128,24,29,230,242,80,59,10,111,5,125,169,181,122,94,63,154,242,237,169,187,184,161,96,131,145,153,19,41,65,138,215,40,149,106,112,224,35,118,8,93,209,30,74,143,177,178,254,112,54,63,181,70,85,10,135,86,115,120,170,162,169,13,118,121,239,156,20,100,217,130,176,203,66,168,90,165,130,51,63,78,254,228,40,248,116,60,14,148,202,4,93,17,214,195,41,183,56,2,112,247,118,218,248,220,48,209,155,153,93,193,38,99,194,208,74,9,56,80,203,18,73,155,93,83,42,231,96,58,167,147,194,222,98,86,119,90,253,174,182,200,230,22,207,3,27,132,247,84,219,136,104,249,243,124,69,155,76,179,11,160,71,127,235,164,129,133,211,244,142,155,126,46,209,218,221,99,232,230,163,60,137,154,92,1,255})
