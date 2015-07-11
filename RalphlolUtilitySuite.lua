--[[
Ralphlol's Utility Suite
Updated 7/11/2015
Version 1.09
]]

function Print(msg) print("<font color=\"#A51842\">Ralphlol's Utility Suite:  </font><font color=\"#FFFFFF\">"..msg) end

function OnLoad()
    local ToUpdate = {}
    ToUpdate.Version = 1.09
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
		elseif unit.charName == "Vayne" and spell.name:lower():find(unit:GetSpellData(0).name:lower()) then
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

	if spell.target then
		if spell.name:lower():find("_turret_") then
			if spell.target == myHero and unit.team ~= myHero.team then
				towerTarget = os.clock()
				print(spell.windUpTime)
			end
		end
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
	if p.header == 210 then	
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

class 'jungle'
function jungle:__init()
	require "MapPosition"
	require "VPrediction"
	
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
		AddIssueOrderCallback(function(unit,iAction,targetPos,targetUnit) self:OnIssueOrder(unit,iAction,targetPos,targetUnit) end)
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
			DrawText("GANK ALERT",self.jM.jungleT+5,self.jM.jungleX,self.jM.jungleY,ARGB(255, 255, 0, 0))
			if GetTickCount() >= self.lasttime then
				DrawText("____________",self.jM.jungleT,self.jM.jungleX,self.jM.jungleY + 20,color)
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
			DrawText("Top Lane",self.jM.jungleT,self.jM.jungleX,self.jM.jungleY,color )
		elseif self.MapPosition:onMidLane(self.EnemyJungler) then
			 DrawText("Mid Lane",self.jM.jungleT,self.jM.jungleX,self.jM.jungleY,color)
		elseif self.MapPosition:onBotLane(self.EnemyJungler) then
			 DrawText("Bot Lane",self.jM.jungleT,self.jM.jungleX,self.jM.jungleY,color)
		elseif self.MapPosition:inTopRiver(self.EnemyJungler) then
			 DrawText("Top River",self.jM.jungleT,self.jM.jungleX,self.jM.jungleY,color)
		elseif self.MapPosition:inBottomRiver(self.EnemyJungler) then
			 DrawText("Bot River",self.jM.jungleT,self.jM.jungleX,self.jM.jungleY,color)
		elseif self.MapPosition:inLeftBase(self.EnemyJungler) then
			 DrawText("Bot Left Base",self.jM.jungleT,self.jM.jungleX,self.jM.jungleY,color)
		elseif self.MapPosition:inRightBase(self.EnemyJungler) then
			 DrawText("Top Right Base",self.jM.jungleT,self.jM.jungleX,self.jM.jungleY,color)
		elseif self.MapPosition:inTopLeftJungle(self.EnemyJungler) then
			 DrawText("Bot Blue Buff Jungle",self.jM.jungleT,self.jM.jungleX,self.jM.jungleY,color)
		elseif self.MapPosition:inTopRightJungle(self.EnemyJungler) then
			DrawText("Top Red Buff Jungle",self.jM.jungleT,self.jM.jungleX,self.jM.jungleY,color)
		elseif self.MapPosition:inBottomRightJungle(self.EnemyJungler) then
			DrawText("Top Blue Buff Jungle",self.jM.jungleT,self.jM.jungleX,self.jM.jungleY,color)
		elseif self.MapPosition:inBottomLeftJungle(self.EnemyJungler) then
			DrawText("Bottom Red Buff Jungle",self.jM.jungleT,self.jM.jungleX,self.jM.jungleY,color)
		end
		if GetTickCount() >= self.lasttime then
			DrawText("__________",self.jM.jungleT,self.jM.jungleX,self.jM.jungleY + 20,color)
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
	{'Zed_Ult_Tar2getMarker_tar.troy2', 3.4, "zedult"},
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
			self:Check(unit, false, spell.endPos)
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
_G.ScriptCode = Base64Decode("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ioaX1KGfoL7LyL6tqyNUjHOsp5usd5QoVzUzNaWXmJOhoZuioqWkqZqsJFcCEgENEtl0kSdTSEhZzMOjm6fam4aGtL0jVU4lNTKXm6doZTVMK1RoedTn4am/xSNLT0hZWcCmnp7OqiMpTVEjUaqGo5Y1Njg1MzWqnMPaeWx8eUBZmmeJwby+zE42NjVoNiMlSFEmUUglJUhRU5FLJSM2aDU2I41cWUhIRyPxwYB8dGh5aFQkSHU2NTMyNTI1XXI4MjM1MzVILJRreWh0eUA5tGNKSEhZWU4zRnVrNiMlSFGjtIgoJUhRI1FIOWM5aDU2M06ZtohLRyNRWUB5jKh8aFQkSDXToXM1NTI1NTI1TnM4MzVIJFRom6h3eUBZUSNHaIhcWU4zNjWonmMoSFEjUUjlhXI4MjM1MzVISJRreWh0eUA5s2NKSEhZWU4zXHVrNiMlSFFjt4goNTI1MjNVmHVLJFRoeWh0o4BcUSNHSEiZvI42NjVoNiMldJEmUUglJUhRUZFLJSM2aDX2iI5cWUhIRyNRroB8dGh5aFQkeXU2NTMyNTJ1iXI4MjM1MzVIVpRreWh0eUBZhGNKSEhZWU5zl3VrNiMlSFEjhYgoJUhRI1FIYGM5aDU2M05ZjohLRyNRWUB53ah8aFQkSDUza3M1NTI1NTKVnHM4MzVIJFRosKh3eUBZUSNHnohcWU4zNjVobmMoSFEjUUgliXI4MjM1MzVIXZRreWh0eUDZkmNKSEhZWU4zcHVrNiMlSFHjpIgoNTI1MjMVonVLJFRoeWh0tYBcUSNHSEj5u442NjVoNiMlhZEmUUglJUjRg5FLJSM2aDU2cY5cWUhIRyNxvYB8dGh5aFQkh3U2NTMyNTK1lnI4MjM1MzVIZJRreWh0eUCZq2NKSEhZWU6zdnVrNiMlSFEjmYgoJUhRI1FIZmM5aDU2M05ZvohLRyNRWUBZ4ah8aFQkSDUzd3M1NTI1NTIVmXM4MzVIJFTou6h3eUBZUSPHt4hcWU4zNjVoeWMoSFEjUUhli3I4MjM1MzXIZ5RreWh0eUDZpGNKSEhZWU4zenVrNiMlSFGjnYgoNTI1MjO1d3VLJFRoeWi00IBcUSNHSEhZno42NjVoNiOljZEmUUglJUhRkJFLJSM2aDU2eY5cWUhIRyMxv4B8dGh5aFSkjnU2NTMyNTL1mnI4MjM1MzVIa5RreWh0eUDZtmNKSEhZWU6zfXVrNiMlSFHjtIgoJUhRI1FIlGM5aDU2M07ZoYhLRyNRWUB54Kh8aFQkSDUzfnM1NTI1NTK1inM4MzVIJFTowqh3eUBZUSNHrIhcWU4zNjVogGMoSFEjUUgFnXI4MjM1MzXIbpRreWh0eUDZu2NKSEhZWU4zgXVrNiMlSFHDuIgoNTI1MjO1fnVLJFRoeWh0xYBcUSNHSEgZsI42NjVoNiOFtJEmUUglJUhRcJFLJSM2aDW2gI5cWUhIRyPxw4B8dGh5aFQklnU2NTMyNTL1nnI4MjM1MzXIcpRreWh0eUCZrGNKSEhZWU4zhXVrNiMlSFFDsYgoJUhRI1HIdGM5aDU2M04ZsYhLRyNRWUB5xKh8aFQkSDUznXM1NTI1NTJ1gnM4MzVIJFRI4qh3eUBZUSPHmIhcWU4zNjVoh2MoSFEjUUglnHI4MjM1MzWIdZRreWh0eUDZomNKSEhZWU5ToXVrNiMlSFHjoogoNTI1MjO1lXVLJFRoeWh0y4BcUSNHSEiZwI42NjVoNiNlmpEmUUglJUhRhJFLJSM2aDW2hY5cWUhIRyMRwYB8dGh5aFTkmnU2NTMyNTI1iHI4MjM1MzWId5RreWh0eUBZu2NKSEhZWU6zlXVrNiMlSFGjpYgoJUhRI1EIeWM5aDU2M05ZuIhLRyNRWUB50Kh8aFQkSDVzinM1NTI1NTK1h3M4MzVIJFSI36h3eUBZUSMHrIhcWU4zNjWIoGMoSFEjUUili3I4MjM1MzUIepRreWh0eUC5uWNKSEhZWU4zjXVrNiMlSFEjs4goNTI1MjO1inVLJFRoeWj04YBcUSNHSEhZvI42NjVoNiMloJEmUUglJUgRkpFLJSM2aDV2i45cWUhIRyPxxoB8dGh5aFTErHU2NTMyNTI1jnI4MjM1MzVojZRreWh0eUCZqmNKSEhZWU7TlnVrNiMlSFGjqogoJUhRI1FolGM5aDU2M04ZsohLRyNRWUB50ah8aFQkSDUzj3M1NTI1NTL1lHM4MzVIJFQI2qh3eUBZUSPHoohcWU4zNjXonWMoSFEjUUjlj3I4MjM1MzWIk5RreWh0eUBZrGNKSEhZWU6zkXVrNiMlSFHjrIgoNTI1MjPVmHVLJFRoeWi01YBcUSNHSEiZvY42NjVoNiOlpJEmUUglJUixiZFLJSM2aDX2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eG55aFSUqZ6lqDM2QzI1NZOYppyrmIeth7XU5dt0fUVZUSO8trHNWVI9NjVopIiZv8CVvJFpNTY8MjM1pqmplsi8eWx8eUBZx4y6sarFvk42NjVoNiMlbJEmUUglNTI1MjM4JJ0rrAlgXaZ4fEBZUZC6SExgWU4zjJrLqpKXSFUnUUgllbfEI1VSJSM2zJ6omLHNwre2RydcWUB54tfr1bWQsa+YmTM2PjI1NaakpaennKOvJFhqeWh08UBdWSNHSHWKh3F8hHloOi4lSFFqtrxyjra6kLK4JSdEaDU2ir3Lxayctna0y6Xe4mh9dFQkSHlmeYuIenWJhIRoMjc3MzVInVRse2h0ebpZVShHSEi+x7KHNjlrNiMlt8QjVU4lNTKYnqKYnjVLJFRoeWj0soBcUSNHSEg5yI43PzVoNnKTm7SVtq2TNTZBMjM1epq8aL3b7cni3KVZVTJHSEi7yMOhmp7WnXWGrLqYxEgpKUhRI6OPZyM6czU2M5LLur+crJvFjIR5eG95aFSXvKeco5oyOTk1NTKboaWilKlIKFloeWiZp3G/USZHSEhZWU4jdThoNiMlSFFhkUw0JUhRZ8OpnGaf2piimICOjn1ISiNRWUB5dGi5bFkkSDWhlqCXNTZCNTI1UoWalpa0kHS76dfoeUNZUSNHSEiymVI7NjVoepWGv5KVtEgoNTI1MjOhs3VMKVRoeanGwIJZVCNHSEhZmaFzOkxoNiNFmMOItbGIqZeZUoWalpa0kHSp683VeUNZUSNHSEhtmVEzNjVoNiNdiFUsUUglabqymqWtnZc2azU2M05ZWXmISs77A+ojHm65bFokSDWWpJ+hpzI1NTI1NTM1MzVIJVRpe2h0eUBZUSNHSEhZWU4zNjXfNiMlzVEjUU8lN5NRI1EjZSM2fzU2sw9ZWUgOyGNRIAE5d2l7aVRqynUzfHXzObi3dTK8tHQ6+beIJBsqOm2DPEDdYSZKSyXbWU/QuDVpxqWnzK4lUUkCtjI1OvO2s/vJZFQv+ip3SAFa1SmJiEgpWtA2PvXptvLlClLuUkglNjQ4Mnm3czWPphZsyKp2/cabkSOUyspd35BzNlaqPaMri5Qjl8tlJY/U5lfIKKM7xbg2NJ2c3EmViiZR2UP5dC78qFTrC/g6NTeyOg+4NTME9bY2AfhLJXHreWq6fIRZ0SZHTqXcWU+5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rcOSlLSOirbFI1VNJSM23JqXoE5dZEhIR3eWmo3Yuba+ta0kSzUzNTMyNXN1OTM1MjM1NzpIJFTb4uLZeUNZUSNHSEhZWVI6NjVoqZeXsb+KUUwqJUhRhrmplyM6dDU2M8C+vKm0s3e6xqXsdGx/aFQktKSqmqUyOTc1NTKqoJypMzlNJFRo58nh3kBdWiNHSKvBusCBl6LNNicsSFEjxLyGp6aJMjc4MzVIk8dofW50eUC8vZKqs0hdYk4zNpndqISZscCRUUwqNTI1l6GZhzVMLVRoebXV4q6mtpG8SExgWU4zqJrLl4+RSFUpUUgllbq6kcVIKSs2aDWsnMHCu7StRydbWUB54s3t38OWs353NTc4NTI1haSeoKc1N09IJFSI4tuU66W8so+zsbbAh25/l6jcVpaKrb9DUUwsJUhRicC6koSqaDk7M05ZfnZ5rSNVZ0B5dIjszbeTtpmmVZSZpGA1OUA1MjOWlqmxmrm63svV5azMUSdYSEhZebGUpJjNooiJaMOItKmRoTI5PTM1M6eth7XU5bzd5qVZUSdSSEhZy7OWl6HUhISSrVEnW0glNZShoZaggZa1iVRsimh0eWC/upGwu7C+vW6lm5jJoo8lSFEjUU0lJUhRI1JOJiY3bTY2M05ZWUhIRyNRWUB5dGh5aEEkSDUoNTMyNzJAXDI1MrQ1MzUJZFRoeul0eeFZWaPNCYhZGU+zNtLpNiTrCZEjUUolJSXSI1JO52M2qDe2M2vbWUkWSKVUJUE6d0X6aFUqinYzdTUyNbI3tTJStLM2QndJKCNp+2sBOkFcF6SISE8bmlF6OHdrvWVnSy6kUUort3Q1cjW1NlLKJFWDu2h0kABZ0SkJikiZW842VDdoN0InSFHDkT+kVDK1Mj81MzVLJFRoeWh0eUBc/2oowlwHSI02ES7moN+Z25AnWEglJZ62hsW3lyM6czU2M7zIy7Wps4zLvqR5eHR5aFRrral3nqamlqCYmjI5PjM1M3l7aKy+vqvIyJKMUSdJSEhZ0U43ODVoNpwlTFMjUUifJUxYI1FIbpaNyaGiM1JnWUhInpLDxaTN47vc2rmJtjUzNTMyNjI1NTI1MjM1MzVIJFRoeWh0eUBZURlHSEhxWk4zQDWByCMlSNclkUjlNzI5OXb1NtLKpFUoeWh5SMAZUqlJiUggmw4207doNyulytKpE4gl+/R1Mvp39DoVphVtAyr2+8YbkiMNSolZYJHzORLqNiQrS5IjlwtlJWXUI1KOKGQ26Dg2N6tcWUnlySNRJkK7eXN8aFRlizcztTayO/O4NzI29jU11PhPpOGs/W06fYNZGGcKUdcdXVfDunhx/OdoSFgoFUtrKotRapYML6M7aD6TuE5aaI1NUTBWXkC5eeh571noS/s4eDP5uvZANTg1OxC6MzbX6VlzB+15eh3dUSVNDYxZmVOzP1LtNiR6TVEpnk3qP7h6dzP8uHpSK5qpgwX5+UFj1KhR6MtQ2M+2ODUoOaMrSRUoUemoPbLCdrc6+TmLJBusPHEDPURi4aeKUQ4dnE45O3hoPWhpUpEoUVFCqkhSMlbNJjA7bTV2OM5Z302LR6rWnUs5eWiCBdkkScS4ujTAujc2ErY1NDn6dzWIKdRxlu10eoZelyPHTchittMzN5CtNiM8yFKjpk0lK5VW6FvOamg2L7p7PVWfmlLlzKNSY8P+fgg8XtOxi7g4+zZ1Nfl4+DnE9TY8w7iLKxorvGh7fQRclyeKSI+dHVazOjVvk6clSWBnVVAyOTY1cje1M7xM6Fcufat0QMQdWiNMSE823U40xflsP7GpTFIA1EgnO/Z5MnM5szxlqFRpzmx0f41dFivNjI1ZINJ4PjytdyvCzNEkW8upLY6VaVHIKSM8KDk2NWqe2UpfRyPRWsV/dMW9aFZDSLUzUDMyNTZBNTI1eZipd567mLXW3M10fURZUSO3t7tZXKrC+CqQkhJkTFkjUUiTir/Ek8C8JSc9aDU2ibO8zbe6RydTWUB57Wh8aFQkSDUzWXM2RTI1NZOjmZ+adZq8m7nN56nm3EBcUSNHSEjZtI42NjVoNiOlqZEmUUglNTI1MjM4MzVIJFRojSh4fkBZUZCovLBZXVEzNjXYnyMoSFEjUUilm3I5PjM1M3l7aKy+vqvIyJKMUSdWSEhZu72opJnRpIp3qbWMxrslKUxRI1GrlJY2bDk2M07MwrZISzFRWUDQ49rlzKiTm5ilmpigNTU1NTI1MjMlcjlUJFRovZu40ZaelHeWmnpZXVAzNjXgNiYlSFEjUUg5ZUxYI1FIbpaNyaGiM1JkWUhIi5Wy0Izi4s3smlQnSDUTNDIxJHM1NTI1MzM1MzVIJFRoeWh0eUBZUSNHSEhZWWg0NjWKNyMlUlE8h0glNbg3cjP1NTVIJFfoeah3eUH20yNJDkqZWVR2djVvuWMrjpRjUY/o9Ti7dXM1ujiJKzHqeWqCPEJeXWaITmXcWU9C+TVuRCYoTZemkkir6IlR6tSIKyr6qDt9N49f9ktISYDUWUD/d6p5M9ckSDy39Tn8ODa2PPb1OP04t7ZTqFRowOw0f0qdVaSODAhfY5K3t9LrtiTAS1EjaIgopc6UZVEIKCM2aDm2M45dWUnIS6NSGUR5dmh+6FaAjTU2TDMytXO6NzK1N7M48zpIKFRu+WwRvMBecCPHSFNZWU43PTVoNnmKq8WSw0gpPzI1MpaWoJq6haTX7Gh4e0BZUZtHTEpZWU6sNjlqNiMlwlEnXEglNaCkpKCWn57CibhofXZ0eUCwwJWzrJzIrLGlm5rWNicxSFEjlXtpfZ6WZqWXd1Y2bD42M06ox5uruYi2x0B9g2h5aJiWqax0p5aAmqqpgaihMjY1MzVIJBS6uWh0eUBaUSNHSEhZWU4zNjVoNiMlSFEjUUglSElRI3tJJSM5aD1PM05ZH0iIRymSmUC5deh5hdUkSVA0NTNJtTK1O3N1MnM2MzZlpVRpuul0eR2Z0SQaSEhZJo6zN0hpNiMyyVElnQnlNo+2MjTB9HVKwdVoerb1+kJyUeRJX0hZ2Zt09zfHNyMmZ1GjUU4lNTI5OTM1M5a7l7na7Wh4hEBZUXmsq7zIy6KspppoOlwlSFGEv6+Rioq2l8itipFwiKyoorzAeam6rpi+vq7tlNzy2LmXaF1lVW+ImpWppKRzUpito5qrmLnMomh4f0BZUZO2tKnLWVEzNjVoNiMlSFQjUUglJci3Y1FIJSM3aDU2M05ZWUhIRyNRWUB5dGh5aFQkSTUzNTQyNTI1NTI1MjM1MzVIJFRoeQ==")
_G.ScriptENV = _ENV
SSL({164,92,137,64,129,85,237,14,109,121,90,225,226,176,37,207,231,96,94,233,73,162,187,197,212,100,50,251,86,146,95,243,209,104,5,188,160,123,16,35,155,125,239,88,210,119,159,49,51,174,147,240,215,62,12,178,143,18,79,13,38,83,199,144,55,135,145,184,139,213,63,87,54,232,163,47,10,22,65,181,26,20,130,230,241,34,36,56,29,46,117,203,91,234,156,198,101,4,166,157,248,126,40,1,217,17,169,114,250,72,99,118,11,80,122,255,127,133,171,27,221,214,132,223,9,170,6,154,3,140,200,193,32,238,172,186,28,252,148,211,180,205,98,115,128,190,229,42,66,110,167,30,113,61,149,236,192,70,31,78,194,228,206,189,249,48,202,77,39,124,254,103,97,89,25,19,179,2,44,242,15,227,158,216,151,253,191,24,33,57,222,175,219,59,108,220,183,235,201,106,168,245,218,224,69,152,111,244,161,112,138,53,134,142,204,71,84,43,196,74,23,8,45,67,195,81,52,68,141,185,93,21,82,107,41,60,7,58,246,150,165,208,120,76,247,153,182,177,173,75,105,131,102,136,116,243,243,243,243,157,248,4,127,40,119,122,248,255,1,99,99,169,35,155,121,243,243,243,243,217,126,243,157,248,4,127,40,119,40,248,255,217,72,126,99,35,122,255,80,217,72,40,119,166,1,101,80,155,119,171,1,101,255,243,170,38,243,16,145,16,243,255,1,248,72,243,118,80,217,72,255,35,16,139,80,80,99,80,243,217,72,243,47,99,101,157,217,72,40,18,16,119,119,51,155,243,80,248,255,127,80,72,243,248,72,157,121,243,243,243,243,217,126,243,157,248,4,127,40,119,40,248,255,217,72,126,99,35,122,255,80,217,72,40,119,4,221,255,248,155,119,171,1,101,255,243,170,38,243,16,145,16,243,255,1,248,72,243,118,80,217,72,255,35,16,139,80,80,99,80,243,217,72,243,47,99,101,157,217,72,40,18,16,119,119,174,155,243,80,248,255,127,80,72,243,248,72,157,121,243,243,243,243,217,126,243,157,248,4,127,40,119,40,248,255,217,72,126,99,35,122,255,80,217,72,40,119,122,127,4,155,119,171,1,101,255,243,170,38,243,16,145,16,243,255,1,248,72,243,118,80,217,72,255,35,16,139,80,80,99,80,243,217,72,243,47,99,101,157,217,72,40,18,16,119,119,147,155,243,80,248,255,127,80,72,243,248,72,157,121,243,243,243,243,217,126,243,157,248,4,127,40,119,40,248,255,217,72,126,99,35,122,255,80,217,72,40,119,122,127,4,155,119,171,1,101,255,243,170,38,243,16,145,16,243,255,1,248,72,243,118,80,217,72,255,35,16,139,80,80,99,80,243,217,72,243,47,99,101,157,217,72,40,18,16,119,119,240,155,243,80,248,255,127,80,72,243,248,72,157,121,243,243,243,243,217,126,243,157,248,4,127,40,119,40,248,255,217,72,126,99,35,157,248,4,127,40,119,40,248,255,217,72,126,99,155,119,171,1,101,255,243,170,38,243,16,145,16,243,255,1,248,72,243,118,80,217,72,255,35,16,139,80,80,99,80,243,217,72,243,47,99,101,157,217,72,40,18,16,119,119,215,155,243,80,248,255,127,80,72,243,248,72,157,121,243,243,243,243,217,126,243,157,248,4,127,40,119,40,248,255,217,72,126,99,35,157,248,4,127,40,119,122,248,255,1,99,99,169,155,119,171,1,101,255,243,170,38,243,16,145,16,243,255,1,248,72,243,118,80,217,72,255,35,16,139,80,80,99,80,243,217,72,243,47,99,101,157,217,72,40,18,16,119,119,62,155,243,80,248,255,127,80,72,243,248,72,157,121,243,243,243,243,217,126,243,157,248,4,127,40,119,40,248,255,217,72,126,99,35,63,248,255,36,248,4,20,248,122,127,114,255,155,119,171,1,101,255,243,170,38,243,16,145,16,243,255,1,248,72,243,118,80,217,72,255,35,16,139,80,80,99,80,243,217,72,243,47,99,101,157,217,72,40,18,16,119,119,12,155,243,80,248,255,127,80,72,243,248,72,157,121,243,243,243,243,217,126,243,157,248,4,127,40,119,40,248,255,217,72,126,99,35,157,248,4,127,40,119,40,248,255,217,72,126,99,155,119,126,127,72,166,243,170,38,243,157,248,4,127,40,119,40,248,255,217,72,126,99,243,255,1,248,72,243,118,80,217,72,255,35,16,139,80,80,99,80,243,217,72,243,47,99,101,157,217,72,40,18,16,119,119,178,155,243,80,248,255,127,80,72,243,248,72,157,121,243,243,243,243,217,126,243,157,248,4,127,40,119,40,248,255,114,99,166,101,114,35,157,248,4,127,40,119,40,248,255,217,72,126,99,88,51,155,243,255,1,248,72,243,118,80,217,72,255,35,16,139,80,80,99,80,243,217,72,243,47,99,101,157,217,72,40,18,16,119,119,143,155,243,80,248,255,127,80,72,243,248,72,157,121,243,243,243,243,217,126,243,157,248,4,127,40,119,40,248,255,217,72,126,99,35,20,248,101,157,184,36,65,20,184,155,119,171,1,101,255,243,170,38,243,16,145,16,243,255,1,248,72,243,118,80,217,72,255,35,16,139,80,80,99,80,243,217,72,243,47,99,101,157,217,72,40,18,16,119,119,51,49,155,243,80,248,255,127,80,72,243,248,72,157,121,243,243,243,243,217,126,243,118,101,166,169,101,40,248,119,114,99,101,157,248,157,119,157,248,4,127,40,119,40,248,255,217,72,126,99,35,20,248,101,157,184,36,65,20,184,155,119,171,1,101,255,243,170,38,243,16,145,16,243,255,1,248,72,243,118,80,217,72,255,35,16,139,80,80,99,80,243,217,72,243,47,99,101,157,217,72,40,18,16,119,119,51,51,155,243,80,248,255,127,80,72,243,248,72,157,121,243,243,243,243,217,126,243,118,101,166,169,101,40,248,119,114,99,101,157,248,157,119,157,248,4,127,40,119,40,248,255,217,72,126,99,35,63,248,255,36,248,4,20,248,122,127,114,255,155,119,171,1,101,255,243,170,38,243,16,145,16,243,255,1,248,72,243,118,80,217,72,255,35,16,139,80,80,99,80,243,217,72,243,47,99,101,157,217,72,40,18,16,119,119,51,174,155,243,80,248,255,127,80,72,243,248,72,157,121,243,243,243,243,217,126,243,20,248,101,157,184,36,65,20,184,35,255,99,72,127,250,4,248,80,35,122,255,80,217,72,40,119,122,127,4,35,255,99,122,255,80,217,72,40,35,157,248,4,127,40,119,40,248,255,217,72,126,99,155,88,51,51,88,51,178,155,88,51,62,155,243,239,243,240,155,243,170,38,243,147,143,62,12,143,240,49,178,147,62,243,255,1,248,72,243,118,80,217,72,255,35,16,139,80,80,99,80,243,217,72,243,47,99,101,157,217,72,40,18,16,119,119,51,147,155,243,80,248,255,127,80,72,243,248,72,157,121,243,243,243,243,217,126,243,20,248,101,157,184,36,65,20,184,35,255,99,72,127,250,4,248,80,35,122,255,80,217,72,40,119,122,127,4,35,255,99,122,255,80,217,72,40,35,114,99,101,157,155,88,51,51,88,51,178,155,88,51,62,155,243,239,243,240,155,243,170,38,243,147,143,62,178,49,12,51,143,49,178,243,255,1,248,72,243,118,80,217,72,255,35,16,139,80,80,99,80,243,217,72,243,47,99,101,157,217,72,40,18,16,119,119,51,240,155,243,80,248,255,127,80,72,243,248,72,157,121,243,243,243,243,217,126,243,20,248,101,157,184,36,65,20,184,35,255,99,72,127,250,4,248,80,35,122,255,80,217,72,40,119,122,127,4,35,255,99,122,255,80,217,72,40,35,114,99,101,157,126,217,114,248,155,88,51,51,88,51,178,155,88,51,62,155,243,239,243,240,155,243,170,38,243,51,240,51,143,174,51,51,51,49,243,255,1,248,72,243,118,80,217,72,255,35,16,139,80,80,99,80,243,217,72,243,47,99,101,157,217,72,40,18,16,119,119,51,215,155,243,80,248,255,127,80,72,243,248,72,157,121,243,243,243,243,217,126,243,20,248,101,157,184,36,65,20,184,35,255,99,72,127,250,4,248,80,35,122,255,80,217,72,40,119,122,127,4,35,255,99,122,255,80,217,72,40,35,157,99,126,217,114,248,155,88,51,51,88,51,178,155,88,51,62,155,243,239,243,240,155,243,170,38,243,174,147,147,174,215,178,12,240,49,147,243,255,1,248,72,243,118,80,217,72,255,35,16,139,80,80,99,80,243,217,72,243,47,99,101,157,217,72,40,18,16,119,119,51,62,155,243,80,248,255,127,80,72,243,248,72,157,121,243,243,243,243,217,126,243,157,248,4,127,40,119,40,248,255,217,72,126,99,35,114,99,101,157,155,119,171,1,101,255,243,170,38,243,16,145,16,243,255,1,248,72,243,118,80,217,72,255,35,16,139,80,80,99,80,243,217,72,243,47,99,101,157,217,72,40,18,16,119,119,51,12,155,243,80,248,255,127,80,72,243,248,72,157,121,243,243,243,243,217,126,243,157,248,4,127,40,119,40,248,255,217,72,126,99,35,63,248,255,241,122,248,80,155,119,171,1,101,255,243,170,38,243,16,145,16,243,255,1,248,72,243,118,80,217,72,255,35,16,139,80,80,99,80,243,217,72,243,47,99,101,157,217,72,40,18,16,119,119,51,178,155,243,80,248,255,127,80,72,243,248,72,157,121,243,243,243,243,217,126,243,157,248,4,127,40,119,40,248,255,217,72,126,99,35,255,101,4,114,248,119,166,99,72,166,101,255,155,119,171,1,101,255,243,170,38,243,16,145,16,243,255,1,248,72,243,118,80,217,72,255,35,16,139,80,80,99,80,243,217,72,243,47,99,101,157,217,72,40,18,16,119,119,51,143,155,243,80,248,255,127,80,72,243,248,72,157,121,243,243,243,243,217,126,243,5,130,166,80,217,118,255,145,99,157,248,243,170,38,243,51,174,147,12,62,243,255,1,248,72,243,118,80,217,72,255,35,16,139,80,80,99,80,243,217,72,243,47,99,101,157,217,72,40,18,16,119,119,174,49,155,243,80,248,255,127,80,72,243,248,72,157,121,243,243,243,243,217,126,243,34,54,181,156,241,130,139,20,243,101,72,157,243,72,99,255,243,145,47,99,47,181,101,166,169,248,255,243,255,1,248,72,243,118,80,217,72,255,35,16,139,80,80,99,80,243,217,72,243,47,99,101,157,217,72,40,18,16,119,119,174,51,155,243,80,248,255,127,80,72,243,248,72,157,121,243,243,243,243,217,126,243,34,54,181,156,241,130,139,20,243,101,72,157,243,255,221,118,248,35,145,47,99,47,181,101,166,169,248,255,155,243,170,38,243,16,127,122,248,80,157,101,255,101,16,243,255,1,248,72,243,118,80,217,72,255,35,16,139,80,80,99,80,243,217,72,243,47,99,101,157,217,72,40,18,16,119,119,174,174,155,243,80,248,255,127,80,72,243,248,72,157,121,243,243,243,243,217,126,243,157,248,4,127,40,119,40,248,255,217,72,126,99,35,99,122,119,40,248,255,248,72,133,155,119,171,1,101,255,243,170,38,243,16,145,16,243,255,1,248,72,243,118,80,217,72,255,35,16,139,80,80,99,80,243,217,72,243,47,99,101,157,217,72,40,18,16,119,119,174,147,155,243,80,248,255,127,80,72,243,248,72,157,121,121,243,243,243,243,114,99,166,101,114,243,145,127,80,181,99,122,243,38,49,121,243,243,243,243,114,99,166,101,114,243,163,248,221,181,99,122,243,38,243,49,121,243,243,243,243,114,99,166,101,114,243,163,248,221,243,38,243,16,215,174,215,174,147,215,147,215,87,188,230,1,221,1,255,221,144,29,26,5,63,87,87,29,29,22,147,62,215,1,62,5,160,87,26,5,26,87,160,215,174,215,174,147,215,147,215,87,188,230,1,221,1,255,221,144,29,26,5,63,87,87,29,29,22,147,62,215,1,62,5,160,87,26,5,26,87,160,160,87,26,5,26,87,160,5,62,1,215,62,147,22,29,29,87,87,63,5,26,29,144,221,255,1,221,1,230,188,87,215,147,215,147,174,215,174,215,215,174,215,174,147,215,147,215,87,188,230,1,221,1,255,221,144,29,26,5,63,87,87,29,29,22,147,62,215,1,62,5,160,87,26,5,26,87,160,160,87,26,5,26,87,160,5,62,1,215,62,147,22,29,29,87,87,63,5,26,29,144,221,255,1,221,1,230,188,87,215,147,215,147,174,215,174,215,215,174,215,174,147,215,147,215,87,188,230,1,221,1,255,221,144,29,26,5,63,87,87,29,29,22,147,62,215,1,62,5,160,87,26,5,26,87,160,16,121,243,243,243,243,114,99,166,101,114,243,145,99,157,248,243,38,243,156,63,119,130,166,80,217,118,255,145,99,157,248,121,243,243,243,243,114,99,166,101,114,243,130,255,80,217,72,40,135,221,255,248,243,38,243,122,255,80,217,72,40,119,4,221,255,248,121,243,243,243,243,114,99,166,101,114,243,130,255,80,217,72,40,145,1,101,80,243,38,243,122,255,80,217,72,40,119,166,1,101,80,121,243,243,243,243,114,99,166,101,114,243,130,255,80,217,72,40,130,127,4,243,38,243,122,255,80,217,72,40,119,122,127,4,121,243,243,243,243,114,99,166,101,114,243,230,99,47,99,101,157,243,38,243,126,127,72,166,255,217,99,72,35,155,121,243,243,243,243,243,243,243,243,163,248,221,181,99,122,243,38,243,163,248,221,181,99,122,243,239,243,51,121,243,243,243,243,243,243,243,243,217,126,243,163,248,221,181,99,122,243,83,243,5,163,248,221,243,255,1,248,72,243,163,248,221,181,99,122,243,38,243,51,243,248,72,157,121,243,243,243,243,243,243,243,243,145,127,80,181,99,122,243,38,243,145,127,80,181,99,122,243,239,243,51,121,243,243,243,243,243,243,243,243,217,126,243,145,127,80,181,99,122,243,83,243,5,145,99,157,248,243,255,1,248,72,121,243,243,243,243,243,243,243,243,243,243,243,243,80,248,255,127,80,72,243,16,16,121,243,243,243,243,243,243,243,243,248,114,122,248,121,243,243,243,243,243,243,243,243,243,243,243,243,114,99,166,101,114,243,22,248,171,135,221,255,248,243,38,243,130,255,80,217,72,40,135,221,255,248,35,130,255,80,217,72,40,130,127,4,35,145,99,157,248,88,145,127,80,181,99,122,88,145,127,80,181,99,122,155,155,243,210,243,130,255,80,217,72,40,135,221,255,248,35,130,255,80,217,72,40,130,127,4,35,163,248,221,88,163,248,221,181,99,122,88,163,248,221,181,99,122,155,155,121,243,243,243,243,243,243,243,243,243,243,243,243,217,126,243,22,248,171,135,221,255,248,243,13,243,49,243,255,1,248,72,243,22,248,171,135,221,255,248,243,38,243,22,248,171,135,221,255,248,243,239,243,174,215,62,243,248,72,157,121,243,243,243,243,243,243,243,243,243,243,243,243,80,248,255,127,80,72,243,130,255,80,217,72,40,145,1,101,80,35,22,248,171,135,221,255,248,155,121,243,243,243,243,243,243,243,243,248,72,157,121,243,243,243,243,248,72,157,121,243,243,243,243,114,99,166,101,114,243,156,139,22,34,243,38,243,156,63,119,130,166,80,217,118,255,139,22,34,243,99,80,243,132,156,63,243,38,243,156,63,9,121,243,243,243,243,114,99,101,157,35,230,99,47,99,101,157,88,72,217,114,88,16,4,255,16,88,156,139,22,34,155,35,155,121,243,243,243,243,230,99,47,99,101,157,243,38,243,126,127,72,166,255,217,99,72,35,155,243,248,72,157,121,109,210,210,156,63,119,63,248,255,241,122,248,80,174,243,38,243,72,217,114,121,194,149,154,164,155,204,197,143,106,127,219,11,106,41,141,134,248,12,128,166,107,42,217,243,205,99,205,75,70,86,157,95,193,2,252,141,239,170,214,189,86,128,81,197,55,33,65,157,69,161,168,236,7,95,48,93,179,141,251,214,108,60,94,216,217,81,171,112,107,170,217,174,57,161,181,185,122,232,221,105,125,238,211,14,140,187,175,172,131,175,198,97,10,95,138,38,252,232,229,2,178,113,84,128,238,99,114,123,224,78,233,154,37,176,140,124,226,25,221,198,226,211,109,26,173,244,189,105,80,126,69,54,159,94,30,58,110,117,31,130,251,214,13,180,232,208,39,242,210,211,109,201,172,194,223,119,137,105,214,81,15,162,244,118,229,67,201,19,81,130,214,59,160,43,12,55,113,154,2,43,55,235,223,155,199,93,74,73,60,64,62,5,55,27,188,89,26,1,228,77,38,71,16,8,169,133,107,180,248,21,207,122,175,114,253,196,134,55,212,194,48,71,225,18,106,91,173,224,34,150,253,20,213,225,171,118,197,237,152,125,87,251,149,137,65,101,26,71,180,103,188,253,11,22,1,255})
