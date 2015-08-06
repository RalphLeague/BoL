--[[
Ralphlol's Utility Suite
Updated 8/6/2015
Version 1.12
]]

function Print(msg) print("<font color=\"#A51842\">Ralphlol's Utility Suite:  </font><font color=\"#FFFFFF\">"..msg) end

function OnLoad()
    local ToUpdate = {}
    ToUpdate.Version = 1.12
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

	if spell.target then
		if spell.name:lower():find("_turret_") then
			if spell.target == myHero and unit.team ~= myHero.team then
				towerTarget = os.clock()
				--print(spell.windUpTime)
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
	if p.header == 119 then	
		--print("got gold")
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

_G.ScriptCode = Base64Decode("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VMGsjrbGuKfU0+Nydg3h/v++EnOzZXdodGikmuLY2snHxaHWn9+4upObubZIKHuHh3tYe2GUKTNISHKoz5jF0NDR1+mopN7ZzGRkDfsSvv/+Y7N3fndnc7fIw6nl2dzV1N+0ZWoreWJzw83cp5o1OoBqaGTQ153TnOZITCslVFK6mLC9urwlTFdUJSSqqeCaajlpZGRozPGlp2h4cGRhc6u9Z9/ZreZzdXdnc0RTU0Rzandyc3NIZcxlfGJzYWRodFh0OXlqaGRkZKOqOXJISCQlVFKIKEhUU0RzZ9mydnNIZWYleWqzZGRodGg1NuOqa2RkZDVqNoKISyQlVFJIRa6UVkRzZ3dyc4eIaGYleWJzgdKod2g1NnlqaHykZzVqNnJIaIZlV1JIJUhUVGRlS1JUJSRIaNx2bTVkZGRoapl2OGh0aGRhc6y5KGZlSHNzcpmndkRTU0RzZ9SydnNIZWYleYazZGRodGg1Nq2qa2RkZDVqNpiISyQlVFJIJZ2UV0glSFJUJUyIS3I2ajVk5K6obXk2NWh0aI6hdmJ5JWZliNCzdXdnc0RTU3Czandyc3NIZZtlfGJzYWRodJZ1OXlqaGRkpIqqOXJISCQlVIKIKEhUU0Rz592ydnNIZWYleZOzZGRodGg1tueqa2RkZDVqNqSISyQlVFJIpaqUVkRzZ3dyc6aIaGYleWJz4c6od2g1NnlqCMqkZzVqNnJI6JJlV1JIJUhUVH5lS1JUJSRI6NR2bTVkZGRoarB2OGh0aGRhE8y5KGZlSHNzcq+ndkRTU0RzZ8CydnNIZWYleZuzZGRodGg1ttWqa2RkZDVqNqyISyQlVFJIJYOUV0glSFJUpXiIS3I2ajVkZKCobXk2NWh06K2hdmJ5JWZlSLCzdXdnc0RTE6Czandyc3NIZaRlfGJzYWRodKd1OXlqaGRkJImqOXJISCQlVJKIKEhUU0Rzp92ydnNIZWYl+aKzZGRodGg1dueqa2RkZDVqNrOISyQlVFJIZaqUVkRzZ3dy87SIaGYleWJzoc6od2g1NnlqaKakZzVqNnJIqIplV1JIJUhU1IplS1JUJSRIqOB2bTVkZGRoarx2OGh0aGRh08S5KGZlSHNz8rqndkRTU0Rzx+GydnNIZWYleaazZGRodGg1NsSqa2RkZDVqtraISyQlVFJIpaWUV0glSFJUJWmIS3I2ajVk5KmobXk2NWh06LmhdmJ5JWZlSLmzdXdnc0RT04+zandyc3NI5axlfGJzYWRoNMV1OXlqaGRkZHyqOXJISCQl1JmIKEhUU0RzJ8yydnNIZWYleaqzZGRodGg19t+qa2RkZDVqtrqISyQlVFJI5baUVkRzZ3dyM9WIaGYleWJzIc6od2g1NnlqSMqkZzVqNnJIKJJlV1JIJUhUNKplS1JUJSRIKNx2bTVkZGRoasV2OGh0aGRh8665KGZlSHNzctGndkRTU0RzZ8SydnNIZWYl+a+zZGRodGg1Nsuqa2RkZDVqNsCISyQlVFJIpZaUV0glSFJUZX6IS3I2ajVkZLOobXk2NWh06LOhdmJ5JWZliMWzdXdnc0RTU5Szandyc3NIZctlfGJzYWRotLh1OXlqaGRkZKKqOXJISCQl1KKIKEhUU0RzZ9iydnNIZWYlObKzZGRodGg1NuKqa2RkZDVqNsOISyQlVFJIRa2UVkRzZ3dys8SIaGYleWJzgdGod2g1Nnlq6LWkZzVqNnJIaIVlV1JIJUhUFJllS1JUJSRIaNt2bTVkZGRoatR2OGh0aGRh87S5KGZlSHNzMsmndkRTU0RzZ8qydnNIZWYlubWzZGRodGg1dtSqa2RkZDVqtsWISyQlVFJI5ZuUV0glSFJUJXiIS3I2ajVk5MmobXk2NWh0qLihdmJ5JWZlyOCzdXdnc0RT06Wzandyc3NI5c9lfGJzYWRoFM11OXlqaGRkBKKqOXJISCQl9LOIKEhUU0RzB+CydnNIZWYlebizZGRodGg1ds+qa2RkZDVqtsyISyQlVFJIpZ6UVkRzZ3dyM8mIaGYleWJzYbuod2g1NnlqqLukZzVqNnJICH5lV1JIJUhU1J9lS1JUJSRICMl2bTVkZGRoatF2OGh0aGRhs8e5KGZlSHNzss+ndkRTU0Rzp+SydnNIZWYl+bqzZGRodGg1dtqqa2RkZDVq9sqISyQlVFJIZbGUV0glSFJUJX2IS3I2ajVkxMmobXk2NWh0qL2hdmJ5JWZlqOCzdXdnc0RT052zandyc3NIxcdlfGJzYWRoNMF1OXlqaGRkxJ6qOXJISCQl1K2IKEhUU0RzJ9KydnNIZWYleb6zZGRodGg19t6qa2RkZDVqds6ISyQlVFJI5bWUVkRzZ3dyM9SIaGYleWJzIc2od2g1NnlqSMmkZzVqNnJIKJFlV1JIJUhUNKllS1JUJSRIKNt2bTVkZGRoatd2OGh0aGRhs8C5KGZlSHNz8tWndkRTU0RzJ9WydnNIZWYlecGzZGRodGg1dtiqa2RkZDVqttGISyQlVFJI5aeUV0glSFJUJYSIS3I2ajVkZMuobXk2NWh0iMShdmJ5JWZlSOKzdXdnc0RTk6Szandyc3NIZcllfGJzYWRo1Mh1OXlqaGRkZKCqOXJISCQl1LKIKEhUU0Rzh96ydnNIZWYlGcKzZGRodGg1Vuiqa2RkZDVq9tKISyQlVFJIRauUVkRzZ3dyU9OIaGYleWJzgc+od2g1Nnlq6MukZzVqNnJIyJNlV1JIJUhU1KtlS1JUJSRIyN12bTVkZGRoCuB2OGh0aGRhE9G5KGZlSHNzEtqndkRTU0RzB+KydnNIZWYlucWzZGRodGg1ltyqa2RkZDVq9tWISyQlVFJIBauUV0glSFJUJYiIS3I2ajVkpMuobXk2NWh0iMihdmJ5JWZliOKzdXdnc0RTk6izandyc3NIxcplfGJzYWRotNN1OXlqaGRk5JmqOXJISCQltLmIKEhUU0RzB9uydnNIZWYl2dGzZGRodGg19t2qa2RkZDVqFtaISyQlVFJIhbOUVkRzZ3dyM9qIaGYleWJzIdOod2g1NnlqKM+kZzVqNnJIKItlV1JIJUhUNLdlS1JUJSRIKN12bTVkZGRoauF2OGh0aGRhc865KGZlSHNzkt+ndkRTU0Rzp9+ydnNIZWYl2cqzZGRodGg1tuGqa2RkZDVqVt6ISyQlVFJIxbCUV0glSFJU5YyIS3I2ajVkRMyobXk2NWh06NChdmJ5JWZl6N+zdXdnc0RTk7Czandyc3NIxdJlfGJzYWRoNNR1OXlqaGRkRKGqOn1ISCR3ubW+dam3vqnnZ3uEc3NIrMuZvM7i1Mnb6LakqtDL1NBkaERqNnKMuoWclcSrc63Mx5Dp03d2e3NIZaqX2tm008doeHg1NnnL1svQyXfPqumtrZJmxrVIMkhUVEklSFJVJSRISnI4azVkZINo6nk2NWh0aGRhc2J5JWZlSHNzcndnc0RTU0RzZ3dyeXNIZXUleWJ0YW2BdGg1fHmqaOqkpDXHNnNJX+Qo1NnJ5UrvVUglX1JXpasJCHT8a3ZkZGbobFa3NWm8KGVk+iM5JyymiXM68zhqUMXTU8wzaHr5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3daCm+ffaGhrZDVqqNerqZCRVFZPJUhUubaGqr65JShOSHI22pbN1tdoboc2NWjVy9jK6cfLisnGtN/mcntsc0RTyLLc23d2fXNIZdSK7dni08+xuGg5PXlqaNfYxafeinJMUCQlVMixmLG2v6lzandyc3NIZYplfGJzYWRodGg1OWrSS+wZXBmoOnVISCSSx1JMLEhUU5rYyuvh5XNMaWYledLi1GRsfmg1Nt3T2snH2J7ZpHJMUyQlVMC3l7W1wLGfrbZUKS1ISHKq2ajY1s3W0Xk6N2h0aNxhd2p5JWaSeaGWu8Wrc0heU0RzrtzmwNy2ztOG6WJ3b2RodL+kqOXOvNO3x6fPm+BITDAlVFKMWIysqo1onKGmWCRMSnI2aq5kaGZoanmwNWx5aGRh2NDdeWZpS3Nzcubac0hZU0RzyuPh1t5IaGYleWJz4Z2od2g1NnlqSNOkaD5qNnKXtneIxretk0hYX0RzZ77X57ex2NqG58XYYWh3dGg1mOjf1sjN0py8l9axvZclWFZIJUimmoZza4Jyc3OM18eczcfr1ZesdGw8Nnlq29jWzaPRNnZPSCQlusG6kqnIVEwqSFJUSlJ5rnI5ajVkZGRoWrg5NWh0aGRhsaJ9NGZlSLfl0+6q3La2v6mlnKync3ZIZWYleWJzoWhtdGg1pNrXzWRocTVqNpKarYeGwL5oeLjDyEgoSFJUJSRIobI6cjVkZKjay/B3p8t0a2Rhc2J5kealTHhzcneoxYuVU0dzZ3dyc7ObpWo8eWJzgbTa2cyeme3PzIS2yZjLot5oiZaKtVJLJUhUU0Rze7d1c3NIZWYlsaJ3amRodKynl/C+zdzYZDhqNnJISCRWlFXzz/L+/e55p3t4c3NIyNWR6NRzYWRodGs1NnlqaGVkZTdqNnJISCQlVFJIJUhUVEglv1JUJalISHI9akevZGRoRbk2NX90aOQic2J56+elSDo0MnpodUVTmcazZ760NHfO56YlAOS0ZirqtGj8+Dpvdydk6EVtOXUlyiQm8dRIJtjW1syCSlJVAqVISHr267Uq5aRoMfr4ODc1aehntaJ59WfnS3sz8/c2MwZUHkVzZ3h0dnOO56YlwOQ1ZbOqduy7eLlqtebmaLusdnJpiiulWpWLJY7Xk0S66jp483bIasOoeWPCpOdpwas4Nvlt6GQq53Vq/TULTyQp1FclqEhVIgf2aEU1dnRl6GYnv2W3YeRrdG6SuXlr7qeoZPVtNnjlyyQm75VIJV/UVci6S9JXsqeMTzj5rjVraClusb37O0X36GUrNGWARWhdx3n1t3endcRW00ZzaVO083VfZWalOiR4YYGqdGpUNvlqgGRkZDhqNnJISOSXlFZQJUhUxb2GtLvIniRMTXI2aqLF2Mxobn02NWjhydxhdmJ5JWZlSJOzdn1nc0S5v7Pi2Xd2d3NIZcqK4GJ3ZmRodMmon+dqa2RkZDVqNnKISyQlVFJIpa6UV0dzZ3fi3HNL1qMvUAXjTqNrdGg1NnlqaGRocDVqNrZ7jHx7mZWcdJqHU0h3Z3dy1uK7ZWopeWJz1M3WdGxDNnlqv9PW0Jm+pcWruomKwlJMLEhUVJGYn7PAkSRLSHI2ajVkVKNsdnk2NaynrLy3uKXNdLiXSHd1cndn60RXVURzZ/Byd35IZWZp68Pqrc3W2dtnNnxqaERjYzRZd3JISCQmVFJIJUhUVEglSFJUJSRISHI2ajVk6mRoags2NWh1aG5/c2J5aWZlSPRzcncts4RTGsQzaHhzc3PppWul/6OzYfAptGs1OPlsBeXkZdBrNnJfCCelG1OJKCNVU0SKZ3ryOrSJaGynumJ6o6VsjGi3OZAqaeQqJXZqNnRIS2QnVFIlpshVbEQ1ao6yc/MLZuYlWGNzYgRobudUNvlqcWRkZDhqNnJISCQVk1ZTJUhUw6qPlbPChoutunI6dTVkZNHJ4siYn83X3Ndhd2x5JWasrefC1OHM1rhTV0pzZ3fo1N+xyWYpfmJzYdjN1dU1OoBqaGTR3X3PqOFITDAlVFKPiryYvbuZqcC3iiRLSHI2ajUk9qRoank2Nmh0aGRhc2J5JWZlSHNzcndnc0RTU9dzZ3cNc3NIbGY4rGJzYSpptGg1OHlqqGbkZLVsNnMlySQnWlSIJY6Wk0S66Td2+bWIZe3nuWc5o6RoO2r2O5bsaGayZrdtgrQJTIGnVFOX58hYoYb1av30tHMOJ6clgOUzZasrNGy8OTpuRWZkZtLsNnIOSmYlX9VIJY/XlE0vi1XVbOeITXx57bav52Ro8fx2OrL3a+XoNqJ+b+noyVD18nhCdURTasR15z20tXNIaGYluWXzYeRrdGn1OflraGhkZnVutnTkjCQoa1JIpcnYVkgCilJYRCTISH02ajVoa2Roas+bmNzj2mRlfWJ5JcnGtdjl08fW5kRXVURzZ+9yd3VIZWaeeWZ1YWRo7mg5QXlqaNLT1qLLotvCrYglWGBIJUirwrbfy8vhxta6ysuTeWZ/YWRouJt5js+vq7iztmhqOntISCR0wqWrl625wUR3fHdyc7e6xt1o4tTWzcm22eCpgu/WzdaaZDhqNnJISOR3lFJIJUhVVEglSFJUJSRISHI2ajVkZGRoank28mh0aFxhc2J7JXQnSHNz+Xcnc1yTk0WKp6byvTOI5vEleWI0YWVodak2NrrraWRFZDbq/DOJSDAnFlJlp0hVG0mnS9wUJicoiHC1LzXkZGlpanp7Nuh176WidCO6J2bCyfN08/hpc2HU00W4aHdz+HTIZi3mu2N0o2ZoEem1Nzpra2TB5bVru3NISekm1FNPZ4tVlIZ1Z1Tz83RJ52klFuPzYilp9Gk8OLprqaZmZBJrtnMlyCQlWhOLJVRVl0b5qLtyM3TIZgMmeWOQ4mRoj2k1NpDqi+Sr5XlskXNISDvldtKP5oxWbEjqSmlUR6SPibc48LapZHzo63tNNYn0qSVmc+O6JmYsSTlzc7loc+WUVcT/aTlyEPVIZr5lv2eK4WXoNGq1OH/trmRrJ3twdnVITUGoVFOeJstZ9Ekix9hVbCQUiTk4R7ZkZespa3zRNmh0f+Rt8+16JWbvSXQCOXivdc4U1NM56L9yOjQQaEOm+WL9IuX4Oml8NoWsL2aB5jVr/XPKS67mVeQPZpBXWka8akRz9XbSJue3P+O8YSspPWv8N0NtQ2VkZEwqO/IPiW4nL5NIJV9UWMQ66MF0OTRJZ0EmeWKKYWjoOil/NoAsr2elZkBqvPSOSKtnn1cJp1NUWsttSFkXbSply/I2sbiuZqqrbXtEeGt6qadic//7JWgmCn5ziDlpdyGUU0U5aMNyevWSZzCmemaSYeRoiyhDtv9rtGQr5X9svTNJS78mVFJfpVXU2klxSBnVbybPCXM5BTZkZHuocfm8NrR0L+Wrdek6Jmnsibx2OPivcwsUG0dQ6PdyjPPJaH0lfuL54q1o+yl+OQBrsmf/ZTVqTTJJyKrmnlIOJpRUWsa9aT5z9XYPJi0oeqR/YTpp9mvSd3lrcCSw/T0qggxQCPC/2lOUJQ/VnUb9KEN1knPIZX3lfeL54q1o+yl+OQBrsmf/ZTVqTTJJyKrmnlIOJpRUW8pvShlVpycPCTk5a7dxZDpp7HzTdmh17mWtcyn6b2jvCT92ejezDEwTn957J0MMknPIZYUl+WKqYWRoeG81NnnSzcXIyadqOXJISCQl9LuIKUxUVEiVt8VUKCRISHI2anSkZ2Roank2NXi0a2Rhc2J5JVakS3NzcndnczQSV0xzZ3e7t7XB2cuYeWZ7YWRouM2Ypd3PmWRnZDVqNnIot2QoVFJIJUhUi4R2Z3dyc3NIZaYoeWJzYWRopKg4NnlqaGRkbHVtNnJISCQldJJMMEhUU7PV0cTT4dSvytglfXdzYWSv2dyEmOPPy9im3YPPqum3uo9uuFJMMkhUVIyct8S4eZOOtOGX3jVoamRoau+XodHYaGhmc2J5md/VrXN3f3dnc4Wcm6nl1rre3Ni22WYpfmJzYdjN1dU1OoRqaGS4qXa3lbeWjXF+VFZJJUhUVEwqSFJUmI3CrXI5ajVkZGRoank6PGh0aNfV5cvnjGZpTXNzctrP1LZTV1BzZ3fk2Nap0dJ54s/Y1GRsemg1NuXZ38nWZDlvNnJIvZKOyFJMKkhUU7LU1Nxyd3xIZWaI4cPlr8XV2Wg5PXlqaNfYxafeinJMSyQlVMG7JUxaU0RzyuPh1t5IaW8leWLX1tbJ6NGkpHlubWRkZJrYmsZITC0lVFKVhrHCoa2TvVJYLCRISOSbzZbQ0GRscHk2Ndjm0dLVc2aBJWZlvtzm29nT2ERXXURzZ+XX5+q319FuvWJ3Z2RodLinn+feaGh+ZDVqVtu7aJaKt7O0kbHCu3ZFlLPHmUS7rdekijVoa2Roat+lp9XV3GRleGJ5JYuTedlzdoVnc0RzxqnW1uXW5pOpzNVTeWaBYWRo1cupn+/PusnHxaHWqXJMWSQlVHKrhra3uLDYy5fk2Nap0dIlfW1zYWTa2cuWouW+0dHJZDVuQXJISJaKt7O0kZa1wKlza4Fyc3Oq0dWI5LDUzsloeHk1NnmKzs3SzajSm9ZouomItb60JUhUVEgqSFJUJSRJTnM5azplZGRoank2NWh0aGRhc2J5JWZeSHNzc3hnc0ZTXmtzZ3fzc3NIJqYleWP0YWQJdHC1vDqqaCRl5DUHt3JJDuVlVFJKJUgx1UgmThSUJWRKyHJT7DVlMmXqbUU39mtR6WRieaS6JaZnSHPzdPdnkMbTVFO1aHtBdPVL8icmfCj0omRvNqk4fXusa+umpjhHt3JKTqZnVJJKpUtx1UR0grlyc4oIZeYrO6RzoWbod4Y3NnqJamRkBHVhtZFIyCQxVFJIKEhUU0RzZ3dydiGPRuA5J1GyZD9h8tLxqgypbGtkZDXAm9W8t5YlWF1IJUjCw7qSqb69n4msSHZCajVkq8ncruKpqcniy8lhd255JWape7fLyLyqx5OlhkR3aXdyc+tIaWgleWLsYWhqdGg1sHlub2RkZH7djdO0tCQpYlJIJZ/DxrSJnMGniJatreA2ajVkZGVoank2NWh0aGRhc2J5JWZlSHNzcndpdERTd0VzZ4FyjAVIZWare6JzIWZoeG949nwH6uRlJDVqO0HICCWrVpNI7IoUVuH1Z3h68/XJ6yhleSg1oWQvtik6A/srbe4m5rfw+LNIDiZmVFmL5Usx1UR0bXqzc7kLpWZC/GJ0p2epdOg4Nn3Ha2RlAbdqNj9KiikwV1JIZotWVMgoyFgVqCZISTY4atYna+T1rv07+2y3aCulNmsI6Wpu2Pe2ez0rtkRaWAh2rXy1c7qNKXClfmJ8vulodXd6O4N3bWlkpDrqNvlNDCfrWZVI7M0YX0grSFsxqiRJ1zc7dcPpaWVF7nk4Oy24aKRm82uWqmZmnXhzeMRsOE7ZmIlzLvy3fXqOpnDC/uJ0a+ftfgi4Lfjr62ZkJDjqPHMMTSTG11rIsozYWAp3qnc5tzZR9CopgvL3pG0uOKs1PH6taGupqD+qO3JRZaklVWFNqklhWElzp3zyc/lNqGas/qZ+IWlofQW6Nnr57ell8rpvN0/MSCYrGZZIZU3UXWWqSFOaKmpIyHe2c5LpZGXDr3k2TOh16Llmc2jGKitvzri4cj7suE5amYV9BPzydH3L6nDFPFjy7qfreS44eXkxqydr8/htPQLLiyvrF5VILEwYV44pi1KbaehQyHY2cZLoZGV3rn0+Qmx4aKRl82IAKSpoDne2cj7rN01TWER6RPtydAIMaW+z/WZ0Pudodm75enmqbORrgblqN8dMSCpyWBdQq4yZUwv3rH95uLRQAuqlemz25WyuuK41tn1qbiRoZDeGe/JKXyQl1FPNK0ixl0R1hnfyc45IZWYphWJzYavN6Kyeqe3L1sfJZDluNnJIuJOYVFWktApJfKQUh1ZcJSRIttet3aXT2GRscXk2Nb7Zy9jQ5WJ9J2ZlSOxzdXdnc0RTU2iza4dyc3Op082R3qTY1dvN2dZ2qNxqa2RkZDVqts2ISyQlVFJIpamUV0glSFJUJSRIS3I2ajVkZHgobn42NWjhydjJc2Z8JWZluNxzdXdnc0RT06qza4Nyc3OMmKp9z6e2tbO6p2g5RXlqaMbT2aPOn+CvmoWJvce7JUxYU0Rzyublc3dMZWYl7MvhYWh2dGg1jejc1Mi404jNqNettiQoVFJIJUhUQ4N3c3dyc7d7qb57vqXHsLaadGw3Nnlq4GRnZDVqNnJIXGQpW1JIJZHHq6mRtFJYMCRISLaoy6ywzdLN3as2OGh0SGNgclG6JWZlSHRzcndnc0RTU0RzZ3dyc3NIZWYleWKZYmRoomk1NoNqgZpkZDXwOLJICCYlVFJLpUiUV0gm5dRUJ+pKiHI8rXVka+eocL95dWi7KyRn+aW5Je1oiXpQ9HdpgQdVWFC2qH2P9nNJdCklf3B2ZGmu96k1vDyraCvnpDtx+rJOjyhmWu9LJUqx1kRz7Xq0cz7LZWYs/SJ5K2ds9W/59n80a+jlb7lqNrnMCCovmFbJbAwUWU636/gP9vNJAGkleXmzZOTut6o19nxqaGRo5DWqOnJJyCilVRJMJUpUWcgnpJdUKDtISPJ37zdk5GnobTk7NWx0buRlEKX5KoVlyHN+cndnd0tTU0TJzNrm4uVIaXAleWLWwtHN5smFpexqbGZkZDXiNnZKSCQlzVJMJ0hUVMIlTF1UJSS2t+Sjy6HN3snMan1ENWh0v9PT38bNlLnIutjY4Hdrf0RTU4imq8/IuLactLhYeWZ8YWRow9aImevPzdJkaERqNnKMuoWclcSrc63Mx5Dp03d1c3NIZWbly6JzYWRodWg1NnlqaGRkZDVqNnJISCQlVFJIJXdVU0SpaHdydnNQfmYleShzoWRutag1dnrqaIHlZDaFN3JIX6Ql1FiJZUiUVUgmZdNUJmXJSHITqrVlN2RoakZ2tWmHaWRhgON5J7ImCHTQ83do/wWTVeH0Z3jA9PRKfmbme3lzYeS1tSk3lXpqaYNk5DVwNnJITCslVFKpmLu5xrwlTF1UJSSerdWq2ae43dTNan1vNWh0ydLI38e7itrcrdjhrJfe5bPBumTU2d7n4Ni22YaZ8tLY1ISQpohxjN7N3NPWolXPruKtq5iKuHtIKU5UU0Tj1uPT5XNLZWYleWJzYWRrdGg1NnnqzqRkZDVqN3JISCQlVFJIJUhUU0RzZ3dyc3NIZWcleWJ0YWRodGg1NnlqaGRkZDVqNnI=")
_G.ScriptENV = _ENV
SSL({199,31,224,125,253,150,249,162,173,40,219,139,69,44,35,200,20,232,68,11,107,189,239,87,65,83,7,237,166,48,242,119,88,15,55,198,50,71,124,147,178,76,96,158,34,138,129,186,103,128,97,254,233,163,151,117,43,210,126,39,32,155,225,10,104,247,73,77,90,255,229,175,42,153,180,52,248,121,146,33,167,144,100,235,195,37,230,5,2,140,116,241,23,169,17,131,141,85,196,45,183,9,218,70,95,177,179,106,250,160,132,130,157,51,62,152,66,101,217,142,1,174,143,27,203,206,238,110,168,114,215,191,172,36,222,245,187,99,4,89,91,108,49,171,57,22,202,145,181,211,214,161,190,29,46,8,127,102,154,105,30,120,3,149,53,137,176,185,165,213,192,156,84,204,135,75,122,93,164,227,19,6,56,133,134,54,16,21,221,60,92,28,216,188,14,182,193,246,38,112,79,98,197,223,12,80,201,228,123,94,231,111,220,244,61,170,74,113,184,207,82,115,194,243,59,25,26,251,109,81,136,240,209,118,208,67,47,78,63,41,24,236,159,148,64,13,72,86,226,58,252,18,234,205,212,119,119,119,119,45,183,85,66,218,138,62,183,152,70,132,132,179,147,178,40,119,119,119,119,95,9,119,45,183,85,66,218,138,218,183,152,95,160,9,132,147,62,152,51,95,160,218,138,196,70,141,51,178,138,217,70,141,152,119,206,32,119,124,73,124,119,152,70,183,160,119,130,51,95,160,152,147,124,90,51,51,132,51,119,95,160,119,52,132,141,45,95,160,218,210,124,138,138,103,178,119,51,183,152,66,51,160,119,183,160,45,40,119,119,119,119,95,9,119,45,183,85,66,218,138,218,183,152,95,160,9,132,147,62,152,51,95,160,218,138,85,1,152,183,178,138,217,70,141,152,119,206,32,119,124,73,124,119,152,70,183,160,119,130,51,95,160,152,147,124,90,51,51,132,51,119,95,160,119,52,132,141,45,95,160,218,210,124,138,138,128,178,119,51,183,152,66,51,160,119,183,160,45,40,119,119,119,119,95,9,119,45,183,85,66,218,138,218,183,152,95,160,9,132,147,62,152,51,95,160,218,138,62,66,85,178,138,217,70,141,152,119,206,32,119,124,73,124,119,152,70,183,160,119,130,51,95,160,152,147,124,90,51,51,132,51,119,95,160,119,52,132,141,45,95,160,218,210,124,138,138,97,178,119,51,183,152,66,51,160,119,183,160,45,40,119,119,119,119,95,9,119,45,183,85,66,218,138,218,183,152,95,160,9,132,147,62,152,51,95,160,218,138,62,66,85,178,138,217,70,141,152,119,206,32,119,124,73,124,119,152,70,183,160,119,130,51,95,160,152,147,124,90,51,51,132,51,119,95,160,119,52,132,141,45,95,160,218,210,124,138,138,254,178,119,51,183,152,66,51,160,119,183,160,45,40,119,119,119,119,95,9,119,45,183,85,66,218,138,218,183,152,95,160,9,132,147,45,183,85,66,218,138,218,183,152,95,160,9,132,178,138,217,70,141,152,119,206,32,119,124,73,124,119,152,70,183,160,119,130,51,95,160,152,147,124,90,51,51,132,51,119,95,160,119,52,132,141,45,95,160,218,210,124,138,138,233,178,119,51,183,152,66,51,160,119,183,160,45,40,119,119,119,119,95,9,119,45,183,85,66,218,138,218,183,152,95,160,9,132,147,45,183,85,66,218,138,62,183,152,70,132,132,179,178,138,217,70,141,152,119,206,32,119,124,73,124,119,152,70,183,160,119,130,51,95,160,152,147,124,90,51,51,132,51,119,95,160,119,52,132,141,45,95,160,218,210,124,138,138,163,178,119,51,183,152,66,51,160,119,183,160,45,40,119,119,119,119,95,9,119,45,183,85,66,218,138,218,183,152,95,160,9,132,147,229,183,152,230,183,85,144,183,62,66,106,152,178,138,217,70,141,152,119,206,32,119,124,73,124,119,152,70,183,160,119,130,51,95,160,152,147,124,90,51,51,132,51,119,95,160,119,52,132,141,45,95,160,218,210,124,138,138,151,178,119,51,183,152,66,51,160,119,183,160,45,40,119,119,119,119,95,9,119,45,183,85,66,218,138,218,183,152,95,160,9,132,147,45,183,85,66,218,138,218,183,152,95,160,9,132,178,138,9,66,160,196,119,206,32,119,45,183,85,66,218,138,218,183,152,95,160,9,132,119,152,70,183,160,119,130,51,95,160,152,147,124,90,51,51,132,51,119,95,160,119,52,132,141,45,95,160,218,210,124,138,138,117,178,119,51,183,152,66,51,160,119,183,160,45,40,119,119,119,119,95,9,119,45,183,85,66,218,138,218,183,152,106,132,196,141,106,147,45,183,85,66,218,138,218,183,152,95,160,9,132,158,103,178,119,152,70,183,160,119,130,51,95,160,152,147,124,90,51,51,132,51,119,95,160,119,52,132,141,45,95,160,218,210,124,138,138,43,178,119,51,183,152,66,51,160,119,183,160,45,40,119,119,119,119,95,9,119,45,183,85,66,218,138,218,183,152,95,160,9,132,147,144,183,141,45,77,230,146,144,77,178,138,217,70,141,152,119,206,32,119,124,73,124,119,152,70,183,160,119,130,51,95,160,152,147,124,90,51,51,132,51,119,95,160,119,52,132,141,45,95,160,218,210,124,138,138,103,186,178,119,51,183,152,66,51,160,119,183,160,45,40,119,119,119,119,95,9,119,130,141,196,179,141,218,183,138,106,132,141,45,183,45,138,45,183,85,66,218,138,218,183,152,95,160,9,132,147,144,183,141,45,77,230,146,144,77,178,138,217,70,141,152,119,206,32,119,124,73,124,119,152,70,183,160,119,130,51,95,160,152,147,124,90,51,51,132,51,119,95,160,119,52,132,141,45,95,160,218,210,124,138,138,103,103,178,119,51,183,152,66,51,160,119,183,160,45,40,119,119,119,119,95,9,119,130,141,196,179,141,218,183,138,106,132,141,45,183,45,138,45,183,85,66,218,138,218,183,152,95,160,9,132,147,229,183,152,230,183,85,144,183,62,66,106,152,178,138,217,70,141,152,119,206,32,119,124,73,124,119,152,70,183,160,119,130,51,95,160,152,147,124,90,51,51,132,51,119,95,160,119,52,132,141,45,95,160,218,210,124,138,138,103,128,178,119,51,183,152,66,51,160,119,183,160,45,40,119,119,119,119,95,9,119,144,183,141,45,77,230,146,144,77,147,152,132,160,66,250,85,183,51,147,62,152,51,95,160,218,138,62,66,85,147,152,132,62,152,51,95,160,218,147,45,183,85,66,218,138,218,183,152,95,160,9,132,178,158,103,103,158,103,117,178,158,103,163,178,119,96,119,254,178,119,206,32,119,97,43,163,151,43,254,186,117,97,163,119,152,70,183,160,119,130,51,95,160,152,147,124,90,51,51,132,51,119,95,160,119,52,132,141,45,95,160,218,210,124,138,138,103,97,178,119,51,183,152,66,51,160,119,183,160,45,40,119,119,119,119,95,9,119,144,183,141,45,77,230,146,144,77,147,152,132,160,66,250,85,183,51,147,62,152,51,95,160,218,138,62,66,85,147,152,132,62,152,51,95,160,218,147,106,132,141,45,178,158,103,103,158,103,117,178,158,103,163,178,119,96,119,254,178,119,206,32,119,97,43,163,117,186,151,103,43,186,117,119,152,70,183,160,119,130,51,95,160,152,147,124,90,51,51,132,51,119,95,160,119,52,132,141,45,95,160,218,210,124,138,138,103,254,178,119,51,183,152,66,51,160,119,183,160,45,40,119,119,119,119,95,9,119,144,183,141,45,77,230,146,144,77,147,152,132,160,66,250,85,183,51,147,62,152,51,95,160,218,138,62,66,85,147,152,132,62,152,51,95,160,218,147,106,132,141,45,9,95,106,183,178,158,103,103,158,103,117,178,158,103,163,178,119,96,119,254,178,119,206,32,119,103,254,103,43,128,103,103,103,186,119,152,70,183,160,119,130,51,95,160,152,147,124,90,51,51,132,51,119,95,160,119,52,132,141,45,95,160,218,210,124,138,138,103,233,178,119,51,183,152,66,51,160,119,183,160,45,40,119,119,119,119,95,9,119,144,183,141,45,77,230,146,144,77,147,152,132,160,66,250,85,183,51,147,62,152,51,95,160,218,138,62,66,85,147,152,132,62,152,51,95,160,218,147,45,132,9,95,106,183,178,158,103,103,158,103,117,178,158,103,163,178,119,96,119,254,178,119,206,32,119,128,97,97,128,233,117,151,254,186,97,119,152,70,183,160,119,130,51,95,160,152,147,124,90,51,51,132,51,119,95,160,119,52,132,141,45,95,160,218,210,124,138,138,103,163,178,119,51,183,152,66,51,160,119,183,160,45,40,119,119,119,119,95,9,119,45,183,85,66,218,138,218,183,152,95,160,9,132,147,106,132,141,45,178,138,217,70,141,152,119,206,32,119,124,73,124,119,152,70,183,160,119,130,51,95,160,152,147,124,90,51,51,132,51,119,95,160,119,52,132,141,45,95,160,218,210,124,138,138,103,151,178,119,51,183,152,66,51,160,119,183,160,45,40,119,119,119,119,95,9,119,45,183,85,66,218,138,218,183,152,95,160,9,132,147,229,183,152,195,62,183,51,178,138,217,70,141,152,119,206,32,119,124,73,124,119,152,70,183,160,119,130,51,95,160,152,147,124,90,51,51,132,51,119,95,160,119,52,132,141,45,95,160,218,210,124,138,138,103,117,178,119,51,183,152,66,51,160,119,183,160,45,40,119,119,119,119,95,9,119,45,183,85,66,218,138,218,183,152,95,160,9,132,147,152,141,85,106,183,138,196,132,160,196,141,152,178,138,217,70,141,152,119,206,32,119,124,73,124,119,152,70,183,160,119,130,51,95,160,152,147,124,90,51,51,132,51,119,95,160,119,52,132,141,45,95,160,218,210,124,138,138,103,43,178,119,51,183,152,66,51,160,119,183,160,45,40,119,119,119,119,95,9,119,55,100,196,51,95,130,152,73,132,45,183,119,206,32,119,103,128,163,151,254,119,152,70,183,160,119,130,51,95,160,152,147,124,90,51,51,132,51,119,95,160,119,52,132,141,45,95,160,218,210,124,138,138,128,186,178,119,51,183,152,66,51,160,119,183,160,45,40,119,119,119,119,95,9,119,37,42,33,17,195,100,90,144,119,141,160,45,119,160,132,152,119,73,52,132,52,33,141,196,179,183,152,119,152,70,183,160,119,130,51,95,160,152,147,124,90,51,51,132,51,119,95,160,119,52,132,141,45,95,160,218,210,124,138,138,128,103,178,119,51,183,152,66,51,160,119,183,160,45,40,119,119,119,119,95,9,119,37,42,33,17,195,100,90,144,119,141,160,45,119,152,1,130,183,147,73,52,132,52,33,141,196,179,183,152,178,119,206,32,119,124,66,62,183,51,45,141,152,141,124,119,152,70,183,160,119,130,51,95,160,152,147,124,90,51,51,132,51,119,95,160,119,52,132,141,45,95,160,218,210,124,138,138,128,128,178,119,51,183,152,66,51,160,119,183,160,45,40,119,119,119,119,95,9,119,45,183,85,66,218,138,218,183,152,95,160,9,132,147,132,62,138,218,183,152,183,160,101,178,138,217,70,141,152,119,206,32,119,124,73,124,119,152,70,183,160,119,130,51,95,160,152,147,124,90,51,51,132,51,119,95,160,119,52,132,141,45,95,160,218,210,124,138,138,128,97,178,119,51,183,152,66,51,160,119,183,160,45,40,40,119,119,119,119,106,132,196,141,106,119,73,66,51,33,132,62,119,32,186,40,119,119,119,119,106,132,196,141,106,119,180,183,1,33,132,62,119,32,119,186,40,119,119,119,119,106,132,196,141,106,119,180,183,1,119,32,119,124,100,77,62,218,217,51,62,62,175,183,9,50,1,85,62,141,45,70,152,70,233,163,1,177,70,45,45,45,233,177,163,51,175,175,198,50,235,144,175,50,175,235,100,77,62,218,217,51,62,62,175,183,9,50,1,85,62,141,45,70,152,70,233,163,1,177,70,45,45,45,233,177,163,51,175,175,198,50,235,144,175,50,175,235,235,175,50,175,144,235,50,198,175,175,51,163,177,233,45,45,45,70,177,1,163,233,70,152,70,45,141,62,85,1,50,9,183,175,62,62,51,217,218,62,77,100,100,77,62,218,217,51,62,62,175,183,9,50,1,85,62,141,45,70,152,70,233,163,1,177,70,45,45,45,233,177,163,51,175,175,198,50,235,144,175,50,175,235,235,175,50,175,144,235,50,198,175,175,51,163,177,233,45,45,45,70,177,1,163,233,70,152,70,45,141,62,85,1,50,9,183,175,62,62,51,217,218,62,77,100,100,77,62,218,217,51,62,62,175,183,9,50,1,85,62,141,45,70,152,70,233,163,1,177,70,45,45,45,233,177,163,51,175,175,198,50,235,144,175,50,175,235,124,40,119,119,119,119,106,132,196,141,106,119,73,132,45,183,119,32,119,17,229,138,100,196,51,95,130,152,73,132,45,183,40,119,119,119,119,106,132,196,141,106,119,100,152,51,95,160,218,247,1,152,183,119,32,119,62,152,51,95,160,218,138,85,1,152,183,40,119,119,119,119,106,132,196,141,106,119,100,152,51,95,160,218,73,70,141,51,119,32,119,62,152,51,95,160,218,138,196,70,141,51,40,119,119,119,119,106,132,196,141,106,119,100,152,51,95,160,218,100,66,85,119,32,119,62,152,51,95,160,218,138,62,66,85,40,119,119,119,119,106,132,196,141,106,119,235,132,52,132,141,45,119,32,119,9,66,160,196,152,95,132,160,147,178,40,119,119,119,119,119,119,119,119,180,183,1,33,132,62,119,32,119,180,183,1,33,132,62,119,96,119,103,40,119,119,119,119,119,119,119,119,95,9,119,180,183,1,33,132,62,119,155,119,55,180,183,1,119,152,70,183,160,119,180,183,1,33,132,62,119,32,119,103,119,183,160,45,40,119,119,119,119,119,119,119,119,73,66,51,33,132,62,119,32,119,73,66,51,33,132,62,119,96,119,103,40,119,119,119,119,119,119,119,119,95,9,119,73,66,51,33,132,62,119,155,119,55,73,132,45,183,119,152,70,183,160,40,119,119,119,119,119,119,119,119,119,119,119,119,51,183,152,66,51,160,119,124,124,40,119,119,119,119,119,119,119,119,183,106,62,183,40,119,119,119,119,119,119,119,119,119,119,119,119,106,132,196,141,106,119,121,183,217,247,1,152,183,119,32,119,100,152,51,95,160,218,247,1,152,183,147,100,152,51,95,160,218,100,66,85,147,73,132,45,183,158,73,66,51,33,132,62,158,73,66,51,33,132,62,178,178,119,34,119,100,152,51,95,160,218,247,1,152,183,147,100,152,51,95,160,218,100,66,85,147,180,183,1,158,180,183,1,33,132,62,158,180,183,1,33,132,62,178,178,40,119,119,119,119,119,119,119,119,119,119,119,119,95,9,119,121,183,217,247,1,152,183,119,39,119,186,119,152,70,183,160,119,121,183,217,247,1,152,183,119,32,119,121,183,217,247,1,152,183,119,96,119,128,233,163,119,183,160,45,40,119,119,119,119,119,119,119,119,119,119,119,119,51,183,152,66,51,160,119,100,152,51,95,160,218,73,70,141,51,147,121,183,217,247,1,152,183,178,40,119,119,119,119,119,119,119,119,183,160,45,40,119,119,119,119,183,160,45,40,119,119,119,119,106,132,196,141,106,119,17,90,121,37,119,32,119,17,229,138,100,196,51,95,130,152,90,121,37,119,132,51,119,143,17,229,119,32,119,17,229,203,40,119,119,119,119,106,132,141,45,147,235,132,52,132,141,45,158,160,95,106,158,124,85,152,124,158,17,90,121,37,178,147,178,40,119,119,119,119,235,132,52,132,141,45,119,32,119,9,66,160,196,152,95,132,160,147,178,119,183,160,45,40,173,34,34,17,229,138,229,183,152,195,62,183,51,128,119,32,119,160,95,106,40,249,219,19,103,86,89,226,108,244,88,137,96,21,141,162,60,176,8,129,71,14,20,7,5,65,36,70,38,133,127,135,72,213,72,66,221,202,55,220,24,78,214,195,38,42,62,30,161,202,161,139,143,119,201,200,160,178,170,91,195,182,102,112,174,101,179,156,203,74,131,98,250,80,76,108,140,103,174,143,89,54,45,233,85,53,99,146,23,252,209,29,16,255,123,174,171,219,33,27,226,75,207,134,242,162,212,144,179,163,51,47,139,95,206,191,86,149,73,154,177,82,165,95,191,120,106,210,200,80,65,70,190,119,23,58,77,11,255,150,185,238,182,225,243,4,88,113,151,95,75,206,226,207,203,202,169,113,213,162,188,173,218,181,184,197,92,234,79,227,19,9,186,215,244,16,221,239,52,220,93,26,173,240,28,235,60,105,162,183,217,8,63,24,32,151,190,118,55,224,1,244,193,73,62,165,98,171,84,230,75,218,44,165,50,7,81,187,73,150,208,173,83,186,108,63,246,215,218,28,206,154,234,44,50,233,142,169,126,77,134,124,208,102,18,88,228,7,247,231,149,234,107,46,133,1,255})
