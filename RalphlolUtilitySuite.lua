--[[
Ralphlol's Utility Suite
Updated 7/26/2015
Version 1.11
]]

function Print(msg) print("<font color=\"#A51842\">Ralphlol's Utility Suite:  </font><font color=\"#FFFFFF\">"..msg) end

function OnLoad()
    local ToUpdate = {}
    ToUpdate.Version = 1.11
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
	if p.header == 52 then	
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

--[[function jungle:OnIssueOrder(unit,iAction,targetPos,targetUnit)
	if unit == self.EnemyJungler then
		if targetUnit == myHero then
			print("Jungler has targeted you")
		end
	end
end]]
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
_G.ScriptCode = Base64Decode("gbDclcs2aTlsXVIlf/d0PpNAaDVoWUolJUpZaT8GN3k0bWSmZqWnNHlTqDVpX4plJa9ZaDVydnm1bSSmZqpndXm8qHZoGsomZgHnNHr6aDVoWgsmZqloNHmTaLVqdsolJWeZ6DVuNrs0qKRoZoGnNHpbqDVoYUolqlBZqzWFtvk0b2Tm629nNHmBaDVo5EolZiqndHlb6TVoI0qm7EknNHk+KDXvJEolJVIZ6LxNNno0byRm7iqndHlbqTZoI0qmrS/ZaTVw9nm9TCRnZmwntAIbaDdoYQol8C9nNHk+KLXyJIomZi5n+gQA6Pv0I0rsshTZL8MyNkDDbyRm8SpnfHn9qP1pX0ttJVHasDeuN8E0riUuaOpofHm9aX5rJEsxZi4ofQwAqX/8Iwtv+y6ofw8AKYD/I4txvRQatM4yd8bOMSWzAS6oghUAKYMFI4t0wxQat9Qyd8nUMSW2By6ohRsAKYYLI4t3Ci4ohh4AqYgOIwt4DS6oiCEAKYkRI4t6zxQaveAyd8/gMSW8Ey6oiycAKYwXI4t91RQawOYyd9LmMSW/GS6oji0AKY8dI4uAHC4ojzAAqZEgIwuBHy6okTMAKZIjI4uD4RQaxvIyd9jyMSXFJS6olDkAKZUpI4uG5xQayfgyd9v4MSXIKy6olz8AKZgvI4uJLi4omEIAqZoyIwuKMS6omkUAKZs1I4uM8xQazwQyd+EEMSXONy6onUsAKZ47I4uP+RQa0goyd+QKMSXRPS6ooFEAKaFBI4uSQC4ooVQAqaNEIwuTQy6oo1cAKaRHI4uVBRQa2BYyd+oWMSXXSS6opl0AKadNI4uYCxQa2xwyd+0cMeVa+S4oKA0AaSr9I4sa/C7oKRAAKSoAI0sb/y6oKhMA6SsDIwsbwRRaX9Iyd3DSMeVdBS4oKxkAaS0JI4sdxxTaYNgy93HYMWVfCy6oLR8A6S4PIwseDi5oLiIAqS8SI8sfES4oLiUAaTAVI4sg0xTaY+Qy93TkMWViFy6oMCsA6TEbIwsh2RRaZeoyd3bqMeVjHS4oMTEAaTMhI4sjIC7oMjQAKTMkI0skIy6oMzcA6TQnIwsk5UtbqDUyN/v1aKamZi5otjs36nVoI0un6EsbqDUyN/v4aGanZi5otj43qnZoI0unLGXpdXkAabcvWgxmZi5otkE3andoI0un7kubqjUyN/v+aOaoZi5otkQ3KndoI0un8UtbqzUyN/sBaKapZi5otkc36nhoI0unNWUpd3kAabc4WkxpZi5otko3qnloI0un90vbrDUyN/sHaCaqZi5otk03anpoI0un+kubrTUyN/sKaOarZi5otlA3KnpoI0unPmVpenkAabdBWoxrZi5otlM36ntoI0unAEsbrjUyN/sQaGatZi5otlY3qnxoI0unCkvbrzUyN/sSaCatZi5otlg3an1oI0unRmWpfHkAabdJWsxtZi5otls3Kn1oI0unCEtbsTUyN/sYaKavZi5oNmQA6f5OI0vvDBTaMh0yN8QdMeUxTy5ogGMA6QFSI0tyVS7oAWQAaYNUI8vzUi5og2YA6QRVI0t1ExTaOCMyN0ojMeW3Vi5oBmkA6YdZI0v4FhTauycyN00mMeW6WS5oCWwA6YpcI0v7Wi7oim4AaQxdI8t8XC5oDG8A6Y1fI0v+HBTawS0yN1MsMeXAXy5oD3IA6ZBiI0sBHxTaxDAyN1YvMeXDYi5oEnUA6ZNlI0sEYy7ok3cAaRVmI8uFZS5oFXg3anVoI8uGKUubqDUyN9s4aOamZi7oln03KnVoI0uIKUtbqTUyt9w4aKanZi5omH036nZoI8uJamUpdXkAaZpsWkxnZi7omX03qndoI0uLKUvbqjUyt984aCaoZi5om303anhoI8uMKUubqzUyN+E4aOapZi7onH03KnhoI0uOamVpeHkA6Z5sWoxpZi5onn036nloI8uPKUsbrDUyN+Q4aGarZi7on303qnpoI0uRKUvbrTUyt+U4aCarZi5ooX03antoI8uSamWpenkAaaNsWsxrZi7oon03KntoI0uUKUtbrzUyt+g4aKatZi5opH036nxoI8uVKUsbrzUyN+o4aGauZi7opX03qn1oI0uXamXpfHkA6adsWgxtZi5op303an5oI8uYKUubsTUyN+04byTn+CqodHk36n5ovownJRSaajkp98I0jOZoZmxntnz3aX9ofgwnZmxntnz3qX9ofkwoZmxntnz36X9ofowoJVJZ6jiHNvk0kmVmZmhtNHk2y6HJzL0lKVVZaDXam9yV09Cq2MXeNH09aDVouKmO1M3bNH09aDVour2Yy9bbNH07aDVoxbmGiUpddTVoNruV2smcmqjMl+iazTVsklIlJZGJ4GbBjMJ1qLW3q6aom7p9woK2nLKUsaWodbp3qXapmotmp6W4fcR3qXapm7FnZouernapd7qYuKWnqKbSdrp3r4qpmotmcJuaq3eqobt1qKu8p6WodcSHsXiqocFop6Wohbp3qXatm7Fmp6WuguyPwIPimot2c4uaqXa9aMetyLyolrmahuGasIvimot2bYuaqXbAZ7KkydHSlqWohcV3qXaprnx7276tivCQr3uYs5tmqaWodbp3z3apmouMZouaqXipd+ioqKWnp8zSdrp3tZapqotmbMGuqXaqrb92qM+sqKW4dd2duXaqq71rp6Wsl7utuYCqwJtqp7zAebp3wZeqqotobYuurXnfmb52qK6YqKWofMCtvXap0cFtZ4vQrXipnb2YzrWnqKbafrp3qZirqpt3qLXOfbp+wX6pmpx+qKXOgN13qXaqx6NmZoua2Xapf7p/uKWprMzOdr13tX2pmrFoibGaqXerpbx1z7XXp9ublcB3rYap0YJnqaW0mrqt333MmpNmp9LAdbp3qaapwJOKcpueuXapj755qK6Xp8uoe8CtrYapjptmZoujmXapd76aqK2np6qodbp3qYaumotmp8WvmOmQqXatnZtmp6WsfuGZmoqap497mqOLoaDCh7p5qrWnp6Wvhu+Zm4fhuqFak4uauXmpd7p1yZezp6aol7p3qXfWs6J30sbVjbp4qoqpmotnt7nSbb2IvoO8rXtvi52uunu8ost+uc/SrLnOdb55uXapmpB7eZyvsoS5i6p6qKW3tKWodbqHmG62rpB7u7a9fsiHvWaumot2t6WodbqLrn+4qnp7eZ+JoYjAZvF6vc+8s6Wohc13qXaprpBvdZuJvom9ZrKHv5WwrLrSoM2JvW63mot2q6WodbqJmoudmot2rqWodbqZmm7Sunx7VYuauX6pd7p1ytG83si+oPKQuXatnLFmZougzJ3Kjc+Iy6uslr64dbp4qYapmotnlr2adbp4qZipmotnzseaguWZ1oapm4uYZouaqonCja6fvbyo0b2/huV3qYKpmotmZouarKy4rcqJqKWnp7W+huSH1ovWvH1n2b2/hr2Pv63bsrdr0MXedbt3qXapnItmZouaz3apd7p1qKWzrKWodbp4uXapmoucZpuaq3e5d7p1r7mpp6W5bLqdqXarmotmp6aop7p3qXe8s6Fa0bq/duSPwIfUmotyZouaqXapd7p1uKWnp6Wodbt3qXapmptmdouaqXa5fbKdwdK84L2ZeqmQv4bdu5J7zqWoibp3qXaxmotmp6eodbp3qZypmotmbouaqXard7p1qKWnp6Wodbt3qXapm5tmZouhtqHKfdJ1qLWnp6Wodbp7qXapmo9n3L3UjqqZmoPQvZF70bDUrKqPuXbcmotmZovQqXapd8Z1qKWnq6Wodbp4qXapmot2ZouaqXqpd7p1qaWnp6Wohbp3qXatmotmp6aodbp3qYqpmotmrKWodbp4uXapmot6ZouaqXupd7p1qbWnp6Woibp3qXaumotmZozAqXapd9J1qKWnraWodbp4z3apmot6p6Wodb13qXapmsFmp6Wojbp3qXavmotmZozAqXapd9J1qKWnraWodbp4z3apmot+ZouaqX2pd7p1qdunp6Wol7p3qXawmotmp6bedbp3qZipmotmrqWodbp433apmouIZouaqX6pd7p1qqWnp6Wom7p3qXaxmotmZovAqXapd851qKWo4L6+rOZ3qXapmotm2qWodbp3z3apmpFqp6Wodbp3q2WpmotmZ4uaqXaqh7p1qKqfrLjTjbp5uXapmotZZouaqXipd6mMqKWnp8zedrp3sa2pqotqqMu4dbqHy3qpmpRWp6Wof8F3rXapw4tnZ4uqrneph7t8zrmrp8vKebt3tZiqqrFmZ8HArXa5d8R1qK2uqaW4eMCH036p0X5xqaa4fL13z3a/mptyqdK8d7p3wZipqotocouetXfWi7p1qLaep8uodcd3qXapm4t2ZouaqmXBabp1qaXNp6WoduOYmmrds6FzlqWohct3qXapvHxz38W/dqmZm4fQvZJ7n5bGnaHMd7p4qKWnp6WodbqMrXatm5tmZouhtqHKo8p1qaXZp6WodsGIvobPpX1zm8bUge13qYatmotmp7eZiq53qYarmotmZpaqqXqqh7p1qKvOmcW+hbp4qZipmotnma+u0KHLo7F1qaXRp6WoduOXr3vhrbdr2r64db6Az3apmo1nr7qthsqC4nrdpotVcJ2goa/Meuibypa038W/dqmZm4fQvZJ7n5bGnaHMd6l/q7XVp6aojbp3qXfSu5Fe4L64dbp3qXapmptmp6Wodbp7qXapmo9nm6PGwmbLaMecy6u80bDUrKqPuXbAmotmZo3AqXapd+h1qKWnsaWodbp5z3apmouUp6WodcV3qXapnMFmp6Wop7p3qXa0motmZo6aqXapd/B1qKWntKWodbp6uXapmotVZouaqYSpd7p1q8unp6WoaLp3qXa3motmp6fedbp3qWmpmotmtaWodbp6z3apmotZZouaqXipd7p1qbWnp6WvguWYr46pmotmZouby3apd7p3qKWnp724dbp3qXapn8Fmp6Woebp3qXaumotmp7yXisiMz3aqmotmZouqqYapd7p1uKufz77VivOPmnuYs6F2mqyhvp2pd+h1qKWnqKWodbp3uXapmotqp6Wodbx3qXapnItmp6Wofbp3qXaymotmZo7AqXapd+R1qKWntaWodbp3qXapmotqZouaqXupd7p1v5S8tbrOdbY2bDhoWUqH2mRrQXk2aIjLy7OV2rfble2r2zVsZUolJZudr3urgsJ9squrZmhpNHk2zjVsYkolJb2e1prVn96nZ2h1ZmRne96qraPNxsNty9bWmew2bDpoWUp5z8fSNH1CaDVovpqXiq7Cy6nRpec0a25mZmTLneuby6nRyLglKWFZaDW9pt2V28mr1MnUnd6prJ7avq2Zz9PVNH07aDVonbyG3WRrSXk2aHnausFojry81Jq2m/Gos9rSy9adNH1AaDVooK+Ze7PM0aTWNn1DZ2RmqtbIq7yf2pjUvnxam5lnOIc2aDXJvL6O3Mm5mdyX1KHbWU4xJUpZ2prLl+Wgu83Ty9dnOIA2aDXavq2GkbZZa88BzxLNAIOmam9nNHmlzJ7Wy6+Ix9DTNHzQAc4B8uM2pmh6NHk215nRx7yKiKvF1J7Vpuuj3cnKZmeaZ6xpm2h3mU40JUpZ2prLl+Wg0NHW2NPdmd02a88B8uO+/3+nOIU2aDXbzrqK2NbMl9qi1DVsX0olJazC3GiaNn07Z2Rm0tfPnd+qaDlvWUoll73B0ZvcNn05Z2RmyMXVmHk6bTVoWayd1dZnOIE2aDWxnYye2snaNHw2aDVoWUolJU1ZaDVoNvmJp2dmZmRnNHkmpzhoWUolJQquqDhoNnk0Z2RmpmdnNHk2aDW+mU0lZmRnNHk+qDhoWUolZqS9dHw2aDVoWUo1ZU1ZaDVoNvmKp2dmZmRnNHlKqDhoWUolJQqvqDhoNnk0Z2R+pmdnNHk2aDW/mU0lZmRnNHlSqDhoWUolZqS+dHw2aDVoWUpFZU1ZaDVoNvmLp2dmZmRnNHlYqDhoWUolJQqwqDhoNnk0Z2SKpmdnNHk2aDXAmU0lZmRnNHlcqDhoWUolZqS/dHw2aDVoWUpNZU1ZaDVoNvmMp2dmZmRnNHlgqDhoWUolJQqxqDhoNnk0Z2SSpmdnNHk2aDXBmU0lZmRnNHlkqDhoWUolZqTAdHw2aDVoWUpVZU1ZaDVoNvmNp2dmZmRnNHlnqDhoWUolJQqyqDhoNnk0Z2SYpmdnNHk2aDXCmU0lZmRnNHlpqDhoWUolZqTBdHw2aDVoWUpZZU1ZaDVoNvmOp2dmZmRnNHlrqDhoWUolJQqzqDhoNnk0Z2ScpmdnNHk2aDXDmU0lZmRnNHltqDhoWUolZqTCdHw2aDVoWUpdZU1ZaDVoNvmPp2dmZmRnNHlvqDhoWUolJQq0qDhoNnk0Z2SgpmdnNHk2aDXEmU0lZmRnNHlxqDhoWUolZqTDdHw2aDVoWUphZU1ZaDVoNvmQp2dmZmRnNHlzqDhoWUolJQq1qDhoNnk0Z2SkpmdnNHk2aDXFmU0lZmRnNHl1qDhoWUolZqTEdHw2aDVoWUplZU1ZaDVoNvmRp2dmZmRnNPl2qDhoWUolJQq2qDhoNnk0Z2SnpmdnNHk2aDXGmU0lZmRnNPl3qDhoWUolZqTFdHw2aDVoWUpnZU1ZaDVoNvmSp2dmZmRnNPl4qDhoWUolJQq3qDhoNnk0Z2SppmdnNHk2aDXHmU0lZmRnNPl5qDhoWUolZqTGdHw2aDVoWUppZU1ZaDVoNvmTp2dmZmRnNPl6qDhoWUolJQq4qDhoNnk0Z2SrpmdnNHk2aDXImU0lZmRnNPl7qDhoWUolZoTHdHw2aDVoWUprZU1ZaDVoNrmUp2dmZmRnNPl8qDhoWUolJaq5qDhoNnk0Z2StpmdnNHk2aLXImU0lZmRnNPl9qDhoWUolZgTHdHw2aDVoWUptZU1ZaDVoNjmUp2dmZmRnNPl+qDhoWUolJSq5qDhoNnk0Z2SvpmdnNHk2aDXJmU0lZmRnNPl/qDhoWUolZoTIdHw2aDVoWUpvZU1ZaDVoNrmVp2dmZmRnNPmAqDhoWUolJaq6qDhoNnk0Z2SxpmdnNHk2aLXJmU0lZmRnNPmBqDhoWUolZgTIdHw2aDVoWUpxZU1ZaDVoNjmVp2dmZmRnNPmCqDhoWUolJSq6qDhoNnk0Z2SzpmdnNHk2aDXKmU0lZmRnNPmDqDhoWUolZoTJdHw2aDVoWUpzZU1ZaDVoNrmWp2dmZmRnNPmEqDhoWUolJaq7qDhoNnk0Z2S1pmdnNHk2aLXKmU0lZmRnNPmFqDhoWUolZgTJdHw2aDVoWUp1ZU1ZaDVoNjmWp2dmZmRnNLmGqDhoWUolJSq7qDhoNnk0Z+S2pmdnNHk2aDXLmU0lZmRnNDmGqDhoWUolZoTKdHw2aDVoWUp2ZU1ZaDVoNrmXp2dmZmRnNLmHqDhoWUolJaq8qDhoNnk0Z+S3pmdnNHk2aLXLmU0lZmRnNDmHqDhoWUolZgTKdHw2aDVoWUp3ZU1ZaDVoNjmXp2dmZmRnNLmIqDhoWUolJSq8qDhoNnk0Z+S4pmdnNHk2aDXMmU0lZmRnNDmIqDhoWUolZqTLdHw2aDVoWUp4ZU1ZaDVoNtmYp2dmZmRnNLmJqDhoWUolJcq9qDhoNnk0Z+S5pmdnNHk2aNXMmU0lZmRnNDmJqDhoWUolZiTLdHw2aDVoWUp5ZU1ZaDVoNlmYp2dmZmRnNLmKqDhoWUolJUq+qDhoNnk0Z+S6pmdnNHk2aFXMmU0lZmRnNDmKqDhoWUolZqTMdHw2aDVoWUp6ZU1ZaDVoNtmZp2dmZmRnNLmLqDhoWUolJcq+qDhoNnk0ZwTLpmdnNHk2aPXNmU0lZmRnNFmbqDhoWUolZmTNdHw2aDVoWWqKZU1ZaDVoNrmap2dmZmRnNNmcqDhoWUolJcq/qDhoNnk0ZwTMpmdnNHk2aPXOmU0lZmRnNFmcqDhoWUolZmTOdHw2aDVoWWqLZU1ZaDVoNpmbp2dmZmRnNLmdqDhoWUolJarAqDhoNnk0Z+TNpmdnNHk2aNXPmU0lZmRnNDmdqDhoWUolZkTOdHw2aDVoWUqNZU1ZaDVoNpmcp2dmZmRnNLmeqDhoWUolJarBqDhoNnk0Z+TOpmdnNHk2aNXQmU0lZmRnNDmeqDhoWUolZkTPdHw2aDVoWUqOZU1ZaDVoNpmdp2dmZmRnNLmfqDhoWUolJarCqDhoNnk0Z+TPpmdnNHk2aNXRmU0lZmRnNDmfqDhoWUolZkTQdHw2aDVoWUqPZU1ZaDVoNpmep2dmZmRnNLmgqDhoWUolJarDqDhoNnk0Z+TQpmdnNHk2aNXSmU0lZmRnNDmgqDhoWUolZkTRdHw2aDVoWUqQZU1ZaDVoNpmfp2dmZmRnNLmhqDhoWUolJarEqDhoNnk0Z+TRpmdnNHk2aNXTmU0lZmRnNDmhqDhoWUolZkTSdHw2aDVoWUqRZU1ZaDVoNpmgp2dmZmRnNLmiqDhoWUolJarFqDhoNnk0Z+TSpmdnNHk2aNXUmU0lZmRnNDmiqDhoWUolZkTTdHw2aDVoWUqSZU1ZaDVoNpmhp2dmZmRnNLmjqDhoWUolJarGqDhoNnk0Z+TTpmdnNHk2aNXVmU0lZmRnNDmjqDhoWUolZkTUdHw2aDVoWUqTZU1ZaDVoNpmip2dmZmRnNLmkqDhoWUolJarHqDhoNnk0Z+TUpmdnNHk2aNXWmU0lZmRnNDmkqDhoWUolZkTVdHw2aDVoWUqUZU1ZaDVoNpmjp2dmZmRnNLmlqDhoWUolJarIqDhoNnk0Z+TVpmdnNHk2aNXXmU0lZmRnNDmlqDhoWUolZkTWdH1BaDVoq6+Im5q6y6DNqnk4eWRmZqvMqLyi16jNzL5zlL6wyaHUNn1DZ2RmqtbIq7qoy4PN0b5x3NBnOIE2aDWsy6ucp9bKNH1GaDVouriMka+bzanfm96iqNbJZnJnNHk5aDVoZEolJUtZb1RoNnl6Z6RmsqQnNDq2aDVpGkolw6RnNr82qDWvGQolsmQoNDp2aTVp2kslawuaaLhptnmRp2RprGSnNMD2KDW0WQsl5kpbaDapOHl6KKVm6WXnNNZ2aDiu2YwlC2RnNNZ2aDauGYwlC6RnNNZ2aDauWY0lyspZaJKoNnpTZ+Rmc2RnNH0/aDVopquOk5e+1qpoOoQ0Z2THysi6qduDzaPdWU42ZmRnht6ZyaHUeZqU2c3bneik2zVsYEolJby+y5bUonk4cGRmZsXLmMmX2pbVWU4sJUpZzaPJmOWZZ2htZmRneeeXyqHNWU44ZmRnh7yIsYW8uJpmuKW0k8iEt3uuWU4rJUpZ2KfRpO00a3NmZmS3puKk3FW1vr2YhrG+2zVsRnk0Z6XKyrjQl+R5yaHUu6uI0WRrRHk2aHbMvY6Xx9uqleWiypbLxEopPEpZaHbMmsuZytq2x8fSme15yaHUu6uIkHxZazVoNoE0Z2RuZmRnNHk4bDVoWU8lZmRzNLk2hXVoWmkl5mRoNHk2bDpoWUp5jq3EaDVoNnk1Z2RmZ2RnNHk2aDVoWUolJUpZaDVoP3k0Z21mZmRnNHs6aDVoXkolZnBndHlTqDVpeEqlZmVnNHk6bTVoWY6XhsFZaDVoNno0Z2RnZmRnNHk2aDVoWUolJUpZaDVyNnk0cWRmZmVnOH42aDWtWUolsmQnNDk2aDXFmcomhWTnNHo2aDVsZEolJZy+y6u4l9yfzNhmZmRnNHo2aDVpWUolJUpZaDVoNnk0Z2RmZmRoNHk2aDVoWUolZmRnNHk2aDVoWUold2RnNIo2aDVqWUwmJUpZhzXoNnk0Z2RmZmRnNHk2aDVoWUolJUpZaDVoNnk0Z2R8ZmRnU3k2aDZoYmMlZmStNLk27nWoWaclZ2V+9Hy277YoW+UmJUpwaDjovTr0aSpnp2RnNvk4RbZoWpLlJk3gKfVq/Lp1ZyvnJ2dEtfk28PVpXNHmJmYu9To4MPVpXKylZmRKdHS1rjWqWadlpUp4aLVoP3k0Z2hsZmRnpNqf2qhoXVMlJUrMraPNo+KZ2mRqbmRnNO+f257Kxa8lam5nNHmkzanfyLyQr6hnOIA2aDW+vq2ZlLxZbDhoNnmj2mRqbGRnNNyi15jTWU4uJUpZ0ai1pe+d1ctmantnNHmL2JnJza9q1MnUnd6prJ7avq2Zz9PVNHk2aDVsWUolJUpaaTZoN3s0Z2RmZmRnNHk2aDVoWUolRUpZaGtoNnk2Z3K5ZmRnu3l2aNCoWUo8JmTnurl2aPzomUrDZmRo03k2aLwomUq0ZUpaLzWpNoB1qGSn52VnFflC6AEpmkplJ0pcRbboN1Q1Z2R9pm/nADp3aIPqmk0C5+RoD3o2aExoY8rsZ6VnTDk3a0zoWcrspopZQ3ZoNpC0Z+QyJ6Vngvt3axLp2Usx54tZ6DdoOZa252WsaKZntHu2a/VqWU6C6ORowDt3aDxrmkoz6aVt0fu2adBqWUo8pU7ZgbXoOpB0Z+T0pmZoS/k56LuqmUrlJ8pcBbdoNz92p2RmaWRrEfs2aTurmUplaeRqUfw2aQNq3E/xqCZsEfs2aQTq2U+y50xeBzdoN1n0WeMtJqRnA7m2aTupmUplJkpZhbZoN791p2Tt56Znkfo2abupmUrlZ2Rn0fo2aYPp2kxxpyZpkfo2aYQp2UwyZktbhzZoN5g052RxZmRnOII2aDXRzJeUm7PHzzVsPXk0Z7rLydjWpnk6bDVoWbqU2WRrN3k2aKLbWU4vZmRnpNqq0H7Wva+dJU5jaDVoptqoz6fV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565pD7o2aExoXsrsJ65p+jo3ahBpWUo8JU7ZLjazNoA2r2enqG9nujt8aLzqpE/m51VZbviwNoA3sGqD6eRnezyAanurXEwzqWdtdbw3aNLqWUzmaHBnSjs4bBKpWUvrZpZZb/eyOEO1aGiFZuRnSzlE6LuppUrs5pRb7/ZpORQ1Z2R95nHnurqCaPwpo0ysJ2Vqz3o2aEyoYMqrp7Bn+zqAarwpWk2sppNcLvawNkA1MGdD5+RnTfm3a0xoXsqr5pNZ7zayOQB1sWcBZ2RnSzk36LtppErrp7BnOzuAavxp203sZyxqNftCaAtp203CZkpacDU1z4E0NP5uZrECurqCaPwpo0yvJhdchzXoNpD0a+TsJ61nu3qAa7ypo03AZ2RnSzk36LtppErrp7BnOzuAavxp203sJhJcafd1Nk816WcDp2RourqCaPwpo0yvJhdccDU1z4E0NP5uZrECU3m2aFRo2UpdZmRnOIA2aDXQvquJy9ZnN3k2aDVoOaxlKU5ZaDXYpew0amRmZmRn9Mx2azVoWUolJVqZazVoNnk0Z1SlaWRnNHk2aCUnXVIlZmSweLuv3JrbWU4tZmRneN6Z15nNikooJUpZaDVIpbk3Z2RmZmRnbLk5aDVoWUolJYpcaDVoNnk0l6RpZmRnNHk2cHVrWUolZmRnVLk6czVoWbmH0LHIotqdzadoXV8lJUqgzam3mOOZytio37LMqPCl2qCxvUopMkpZaHnfpeuYu9Os0tPIqHk6bjVoWcCG0s3LNH07aDVozcOVy2RrQXk2aHaxoa+XlI3F0ZrWqnk4bGRmZtjMleY2bEBoWUp5aoumx3q2e8aNZ2dmZmRnNHl0qDlpWUolZmhsNHk2257ivkooZmRnNHk2aDVsYEolJb3N2p7WnXk4bGRmZsfPles2bEFoWUqXiq261KG8n+aZ2mRqbGRnNOWl35raWU4qZmRnqeef3DVsXkolZtLIod42bD5oWUqIjavLtpbVm3k4bmRmZtfbleuqvDVsXEolJbnMaDluNnk0ytDVyc9nOII2aDXMzryG2s3Wonk6bTVoWa+TyrhnOII2aDW1urOTcq/H3TVsPXk0Z9bLycXToHk6bjVoWbqXjrjNaDlwNnk03c3Zz8bTmXk6cjVoWbiK2tvWpuR/rDVsX0olZrTZneeqaDmCWUolRbPMiKfNmdqg083UzZKHgNqp3FXbvq+TRUpdbzVoNt+j2dHH2mRrOXk2aFqWirAlanJnNHlW25rLyLiJ2YTIm+hkaDl2WUolhq3N0avNiN6XyNDS2WRrRXk2aFXLuriIira+zFXam9yV09Bmam9nNHmozZjJxbZ5z9HMNHk6czVoWbyKycXToMeX1ZpoXVQlJUq71KTLoceV1MlmanVnNHlWzp7Wwr2Niq552prLl+WgZ2RmZmRsNHk2aDVpX0soZ2loNHk2aDVoWUolZmRnNHk2aDVxWkolNktZaDdoQaA0Z2TnZmRn9bk2aDbpWUrGJVLZ7vaoNjk152QD52Ro+jp2aDVqWUoC52RoOjt2aHVq2UpC6GRoAnq4awFpGk0CpkpabnepNrk2Z2TmaORnUfu2aUSqWk70Jsxc9fZpOT+1qGRtKKVqe3t4a7yqm00C52RpOvt4aHVq2U1C6GRoT7s2aEwoWcor54xZqDfoOZc2Z2WFaGRn1Lkt51Ro2UoxJUpZazVoNnk0Z2RmaRKuFfNKFiSnXCUe5M4jqAx1bDxoWUp7y8fbo+s2bEBoWUqTlLzGyaHRsN6YZ2hyZmRne96qrJ7bzauTiK9ZbEFoNnl4mqi+vKmqiMiImzVsW0olZtxnOHs2aDXhWU4nZmRnrnk6bzVoWZOYfKvF1DVsRHk0Z7vV2NDLiOiJy6fNvrglJUpZaDZoNnk0Z2RmZmRnNHk2aDVoWUolZmR5NXk2nDZoWVQlf/ZnNHm8anVoGUwlKVGcKDgFuPk1J2RmazPn9Hq8anZoIIzlKOfbaDZwtvu17SamZiopdHn9qvZtJszma+4ptvu8KnZoH0xmZmuq9HwT6jVpX01mJZAcqDWFuXk1rWenZuRqNH2TazVp9swlJRdbqjpzOXk0qKdoZuRqtH/36zdoWg4nZgUqO/nDrLltH05oZiur94LFLDlx6c5oLhAdqzVvOz03rWmpZqus+IO2bTVxts8lJlmebT91O340p2nmZuts+Hz8bXhoIM/pcWRtNIIT7TVp6A8qcfLsOXoT7DVqXw9pJYpe6D6Fu3k1vGlmbLFs+YO8rXpoIM9qL1GfqT8Fu/k1cefrcATqK/i36zdoGU2lbGUrOXnX6z3o5o6payprd3n9rPhx6A4pLtrdqz4u+rw0bWmpZmuseIN2bTVxds8lJlle7TZ1O340p2nmZupsd3m97XlzGU8lbwHsNHrF7bpp588qZ0HrNHs8LXlomU+lLmfeaDauO78052nmb8HsNHqRrTVocMompZ9eaDu1Oz4+7amrZivseYM9rnZy9s+lZ27quYPWKyvn5o2oaypqd3n9q/hv6A0oLNrcqzwu+bw0bmgqaaprd3l9rPlw2U4lLKfdaDZ3en08dGhqZqRrtHm9bPlrH05oZivr+II2bTVvNs4lZ/MrOILE7DlpNs0lJ1AdrDWoOvk7hOhmZ7lrNH+DbPpw345qJRHdrT1ve7o8BOjmZ27quIF8rHto2U4lbCRrNHtSrbVqcEol5mXsOnmTrDVqeEqlJWVZaDVsQnk0Z6vL2qjQp+2X1pjNWU4pJUpZ2KTbNnyQ9iZbjsBWc30+aDVox6+c2dTWqHk6bzVoWaCKydjWpnk6ajVoWcMlKEpZaDVoNp10a3RmZmTIouCizXfNzcGKiria2phoOXk0Z2Rm5r+nN3k2aDVo2atlaWRnNHk2aDVoXEolZmRnNI32bDpoWUqShr7BaDlrNnk0181maWRnNHk26JuoXVYlJUqdm3nAjL53u7O4mWRrQ3k2aJfXzriJz9LOhtqa0arbWU4pZmRnl+ipaDlsWUolmLPHaDl2Nnk0vtPY0si7o8yZ2prNx0ooJUpZaDVoJrg4c2RmZqiaeNGMrXi8qJxXZmhpNHk24DVrWUolZmRnSLk6bzVoWZOYfKvF1DVsQXk0Z6jYx9uzneeb22doXEolBUlYZySpNnk0Z2VmZmRnNHk2aDVoWUolZmRnNHk2aDWeWkolpGVnNIM2gWtoWUqrJ4pZKDdoNnk352SmaWRo0fs2avtqmUoraIpZb7ioPL93p2StKSRturx2aLxrmlEC6GRpQjw4bUGrmlBC6WRoQzw2bkNrXE9rqItZ7vipNkC3p2ptKqRte313btJrWUyCqEpZ7jiqNkS3Z2Rt6iRt/nw66TwsGVDvaejoP/02aHzsGVAvqmjoez32bj+s3cvCqMpaAzhoNpB0auTsqaZn9Hw2aDVs2UplKUpa6DnoNzk4Z2Zma+RpkL42a0xoWcpm62ZntH62a/VtWU4lbORr0by2bVRo2UowJUpZbDxoNnmKzMfa1dZnOIM2aDXLureKl6up16hoOns0Z2TeZmhpNHk24TVsW0olZt5nOIQ2aDXWyLySx9DQrt6aaDl2WUolfLnL1Jm8pcyX2cnL1GRrQHk2aHmbnaJ7ao2tt4ebNn09Z2RmtdK6l+ubzaNoXVklZmSrptqtqafLp6+d2rDdoHk5aDVoWUrld4pZaDVoN3k0Z2RmZmRnNHk2aDVoWUolJUpZaHRpNnl6aGRmaWRvTXk2aPtomUorp6RndHq2aFLpWUtAZ2RnS/k26DupmUplJkpahbZoN7q1Z2RDpuRoB3k2aAKo2Us4JkpZdbZoOMX1J2XD52RowDp2atLpWUtz5+VpTXn3akxoWcpypyVpk3o2aVRo2UorJUpZbDxoNnmV2tfL2NhnOIQ2aDW+vq2ZlLyt4aXNNn1tZ2Rmx9LOoN54zanfvq+ToITepuikz1XJy7Ga08nVqJmq4aXNzGpNV2qVvprLquimpYTL3tTMl+2bzF5oXVAlJUrJ16HJqHk3Z2RmZmRnNHk5aDVoWUqlzKRnNHk2aTVoWUolZmRnNHk2aDVoWUolJUpZaDZoNnk1Z2RmZmRnNHk2aDVoWUolJUo=")
_G.ScriptENV = _ENV
SSL({159,138,55,205,68,127,135,225,58,132,18,153,105,195,209,77,33,38,191,53,59,228,63,82,221,62,12,210,52,166,28,246,236,249,245,6,2,19,142,173,217,197,40,254,46,192,10,218,243,176,234,14,97,203,95,175,223,233,157,90,229,47,49,102,51,98,106,22,144,110,65,8,101,17,196,199,60,45,104,81,237,134,172,255,43,11,213,117,30,69,168,146,120,54,50,215,122,70,37,187,72,170,227,231,76,204,23,32,118,189,107,73,113,250,96,240,26,188,169,186,57,220,25,177,133,67,219,21,64,148,235,85,1,253,44,239,140,71,190,80,183,121,194,48,224,103,20,238,251,109,248,171,160,149,212,27,4,87,150,214,147,143,35,24,75,161,139,31,198,89,29,34,99,114,230,202,206,247,128,88,131,91,126,61,136,200,242,244,156,222,232,145,162,151,94,7,184,42,93,207,15,116,124,174,201,112,78,111,241,167,179,119,252,100,211,108,163,185,41,16,181,180,123,130,141,84,86,5,152,56,9,154,39,92,115,182,193,36,164,3,155,66,216,125,226,208,79,129,74,178,13,83,158,137,165,246,246,246,246,187,72,70,26,227,192,96,72,240,231,107,107,23,173,217,132,246,246,246,246,76,170,246,187,72,70,26,227,192,227,72,240,76,189,170,107,173,96,240,250,76,189,227,192,37,231,122,250,217,192,169,231,122,240,246,67,229,246,142,106,142,246,240,231,72,189,246,73,250,76,189,240,173,142,144,250,250,107,250,246,76,189,246,199,107,122,187,76,189,227,233,142,192,192,243,217,246,250,72,240,26,250,189,246,72,189,187,132,246,246,246,246,76,170,246,187,72,70,26,227,192,227,72,240,76,189,170,107,173,96,240,250,76,189,227,192,70,57,240,72,217,192,169,231,122,240,246,67,229,246,142,106,142,246,240,231,72,189,246,73,250,76,189,240,173,142,144,250,250,107,250,246,76,189,246,199,107,122,187,76,189,227,233,142,192,192,176,217,246,250,72,240,26,250,189,246,72,189,187,132,246,246,246,246,76,170,246,187,72,70,26,227,192,227,72,240,76,189,170,107,173,96,240,250,76,189,227,192,96,26,70,217,192,169,231,122,240,246,67,229,246,142,106,142,246,240,231,72,189,246,73,250,76,189,240,173,142,144,250,250,107,250,246,76,189,246,199,107,122,187,76,189,227,233,142,192,192,234,217,246,250,72,240,26,250,189,246,72,189,187,132,246,246,246,246,76,170,246,187,72,70,26,227,192,227,72,240,76,189,170,107,173,96,240,250,76,189,227,192,96,26,70,217,192,169,231,122,240,246,67,229,246,142,106,142,246,240,231,72,189,246,73,250,76,189,240,173,142,144,250,250,107,250,246,76,189,246,199,107,122,187,76,189,227,233,142,192,192,14,217,246,250,72,240,26,250,189,246,72,189,187,132,246,246,246,246,76,170,246,187,72,70,26,227,192,227,72,240,76,189,170,107,173,187,72,70,26,227,192,227,72,240,76,189,170,107,217,192,169,231,122,240,246,67,229,246,142,106,142,246,240,231,72,189,246,73,250,76,189,240,173,142,144,250,250,107,250,246,76,189,246,199,107,122,187,76,189,227,233,142,192,192,97,217,246,250,72,240,26,250,189,246,72,189,187,132,246,246,246,246,76,170,246,187,72,70,26,227,192,227,72,240,76,189,170,107,173,187,72,70,26,227,192,96,72,240,231,107,107,23,217,192,169,231,122,240,246,67,229,246,142,106,142,246,240,231,72,189,246,73,250,76,189,240,173,142,144,250,250,107,250,246,76,189,246,199,107,122,187,76,189,227,233,142,192,192,203,217,246,250,72,240,26,250,189,246,72,189,187,132,246,246,246,246,76,170,246,187,72,70,26,227,192,227,72,240,76,189,170,107,173,65,72,240,213,72,70,134,72,96,26,32,240,217,192,169,231,122,240,246,67,229,246,142,106,142,246,240,231,72,189,246,73,250,76,189,240,173,142,144,250,250,107,250,246,76,189,246,199,107,122,187,76,189,227,233,142,192,192,95,217,246,250,72,240,26,250,189,246,72,189,187,132,246,246,246,246,76,170,246,187,72,70,26,227,192,227,72,240,76,189,170,107,173,187,72,70,26,227,192,227,72,240,76,189,170,107,217,192,170,26,189,37,246,67,229,246,187,72,70,26,227,192,227,72,240,76,189,170,107,246,240,231,72,189,246,73,250,76,189,240,173,142,144,250,250,107,250,246,76,189,246,199,107,122,187,76,189,227,233,142,192,192,175,217,246,250,72,240,26,250,189,246,72,189,187,132,246,246,246,246,76,170,246,187,72,70,26,227,192,227,72,240,32,107,37,122,32,173,187,72,70,26,227,192,227,72,240,76,189,170,107,254,243,217,246,240,231,72,189,246,73,250,76,189,240,173,142,144,250,250,107,250,246,76,189,246,199,107,122,187,76,189,227,233,142,192,192,223,217,246,250,72,240,26,250,189,246,72,189,187,132,246,246,246,246,76,170,246,187,72,70,26,227,192,227,72,240,76,189,170,107,173,134,72,122,187,22,213,104,134,22,217,192,169,231,122,240,246,67,229,246,142,106,142,246,240,231,72,189,246,73,250,76,189,240,173,142,144,250,250,107,250,246,76,189,246,199,107,122,187,76,189,227,233,142,192,192,243,218,217,246,250,72,240,26,250,189,246,72,189,187,132,246,246,246,246,76,170,246,73,122,37,23,122,227,72,192,32,107,122,187,72,187,192,187,72,70,26,227,192,227,72,240,76,189,170,107,173,134,72,122,187,22,213,104,134,22,217,192,169,231,122,240,246,67,229,246,142,106,142,246,240,231,72,189,246,73,250,76,189,240,173,142,144,250,250,107,250,246,76,189,246,199,107,122,187,76,189,227,233,142,192,192,243,243,217,246,250,72,240,26,250,189,246,72,189,187,132,246,246,246,246,76,170,246,73,122,37,23,122,227,72,192,32,107,122,187,72,187,192,187,72,70,26,227,192,227,72,240,76,189,170,107,173,65,72,240,213,72,70,134,72,96,26,32,240,217,192,169,231,122,240,246,67,229,246,142,106,142,246,240,231,72,189,246,73,250,76,189,240,173,142,144,250,250,107,250,246,76,189,246,199,107,122,187,76,189,227,233,142,192,192,243,176,217,246,250,72,240,26,250,189,246,72,189,187,132,246,246,246,246,76,170,246,134,72,122,187,22,213,104,134,22,173,240,107,189,26,118,70,72,250,173,96,240,250,76,189,227,192,96,26,70,173,240,107,96,240,250,76,189,227,173,187,72,70,26,227,192,227,72,240,76,189,170,107,217,254,243,243,254,243,175,217,254,243,203,217,246,40,246,14,217,246,67,229,246,234,223,203,95,223,14,218,175,234,203,246,240,231,72,189,246,73,250,76,189,240,173,142,144,250,250,107,250,246,76,189,246,199,107,122,187,76,189,227,233,142,192,192,243,234,217,246,250,72,240,26,250,189,246,72,189,187,132,246,246,246,246,76,170,246,134,72,122,187,22,213,104,134,22,173,240,107,189,26,118,70,72,250,173,96,240,250,76,189,227,192,96,26,70,173,240,107,96,240,250,76,189,227,173,32,107,122,187,217,254,243,243,254,243,175,217,254,243,203,217,246,40,246,14,217,246,67,229,246,234,223,203,175,218,95,243,223,218,175,246,240,231,72,189,246,73,250,76,189,240,173,142,144,250,250,107,250,246,76,189,246,199,107,122,187,76,189,227,233,142,192,192,243,14,217,246,250,72,240,26,250,189,246,72,189,187,132,246,246,246,246,76,170,246,134,72,122,187,22,213,104,134,22,173,240,107,189,26,118,70,72,250,173,96,240,250,76,189,227,192,96,26,70,173,240,107,96,240,250,76,189,227,173,32,107,122,187,170,76,32,72,217,254,243,243,254,243,175,217,254,243,203,217,246,40,246,14,217,246,67,229,246,243,14,243,223,176,243,243,243,218,246,240,231,72,189,246,73,250,76,189,240,173,142,144,250,250,107,250,246,76,189,246,199,107,122,187,76,189,227,233,142,192,192,243,97,217,246,250,72,240,26,250,189,246,72,189,187,132,246,246,246,246,76,170,246,134,72,122,187,22,213,104,134,22,173,240,107,189,26,118,70,72,250,173,96,240,250,76,189,227,192,96,26,70,173,240,107,96,240,250,76,189,227,173,187,107,170,76,32,72,217,254,243,243,254,243,175,217,254,243,203,217,246,40,246,14,217,246,67,229,246,176,234,234,176,97,175,95,14,218,234,246,240,231,72,189,246,73,250,76,189,240,173,142,144,250,250,107,250,246,76,189,246,199,107,122,187,76,189,227,233,142,192,192,243,203,217,246,250,72,240,26,250,189,246,72,189,187,132,246,246,246,246,76,170,246,187,72,70,26,227,192,227,72,240,76,189,170,107,173,32,107,122,187,217,192,169,231,122,240,246,67,229,246,142,106,142,246,240,231,72,189,246,73,250,76,189,240,173,142,144,250,250,107,250,246,76,189,246,199,107,122,187,76,189,227,233,142,192,192,243,95,217,246,250,72,240,26,250,189,246,72,189,187,132,246,246,246,246,76,170,246,187,72,70,26,227,192,227,72,240,76,189,170,107,173,65,72,240,43,96,72,250,217,192,169,231,122,240,246,67,229,246,142,106,142,246,240,231,72,189,246,73,250,76,189,240,173,142,144,250,250,107,250,246,76,189,246,199,107,122,187,76,189,227,233,142,192,192,243,175,217,246,250,72,240,26,250,189,246,72,189,187,132,246,246,246,246,76,170,246,187,72,70,26,227,192,227,72,240,76,189,170,107,173,240,122,70,32,72,192,37,107,189,37,122,240,217,192,169,231,122,240,246,67,229,246,142,106,142,246,240,231,72,189,246,73,250,76,189,240,173,142,144,250,250,107,250,246,76,189,246,199,107,122,187,76,189,227,233,142,192,192,243,223,217,246,250,72,240,26,250,189,246,72,189,187,132,246,246,246,246,76,170,246,245,172,37,250,76,73,240,106,107,187,72,246,67,229,246,243,97,203,95,14,246,240,231,72,189,246,73,250,76,189,240,173,142,144,250,250,107,250,246,76,189,246,199,107,122,187,76,189,227,233,142,192,192,176,218,217,246,250,72,240,26,250,189,246,72,189,187,132,246,246,246,246,76,170,246,11,101,81,50,43,172,144,134,246,122,189,187,246,189,107,240,246,106,199,107,199,81,122,37,23,72,240,246,240,231,72,189,246,73,250,76,189,240,173,142,144,250,250,107,250,246,76,189,246,199,107,122,187,76,189,227,233,142,192,192,176,243,217,246,250,72,240,26,250,189,246,72,189,187,132,246,246,246,246,76,170,246,11,101,81,50,43,172,144,134,246,122,189,187,246,240,57,73,72,173,106,199,107,199,81,122,37,23,72,240,217,246,67,229,246,142,26,96,72,250,187,122,240,122,142,246,240,231,72,189,246,73,250,76,189,240,173,142,144,250,250,107,250,246,76,189,246,199,107,122,187,76,189,227,233,142,192,192,176,176,217,246,250,72,240,26,250,189,246,72,189,187,132,246,246,246,246,76,170,246,187,72,70,26,227,192,227,72,240,76,189,170,107,173,107,96,192,227,72,240,72,189,188,217,192,169,231,122,240,246,67,229,246,142,106,142,246,240,231,72,189,246,73,250,76,189,240,173,142,144,250,250,107,250,246,76,189,246,199,107,122,187,76,189,227,233,142,192,192,176,234,217,246,250,72,240,26,250,189,246,72,189,187,132,132,246,246,246,246,32,107,37,122,32,246,106,26,250,81,107,96,246,229,218,132,246,246,246,246,32,107,37,122,32,246,196,72,57,81,107,96,246,229,246,218,132,246,246,246,246,32,107,37,122,32,246,196,72,57,246,229,246,142,170,187,227,14,57,203,231,97,231,30,17,2,170,187,227,14,57,203,231,97,231,30,17,2,2,17,30,231,97,231,203,57,14,227,187,170,170,187,227,14,57,203,231,97,231,30,17,2,2,17,30,231,97,231,203,57,14,227,187,170,170,187,227,14,57,203,231,97,231,30,17,2,142,132,246,246,246,246,32,107,37,122,32,246,106,107,187,72,246,229,246,50,65,192,172,37,250,76,73,240,106,107,187,72,132,246,246,246,246,32,107,37,122,32,246,172,240,250,76,189,227,98,57,240,72,246,229,246,96,240,250,76,189,227,192,70,57,240,72,132,246,246,246,246,32,107,37,122,32,246,172,240,250,76,189,227,106,231,122,250,246,229,246,96,240,250,76,189,227,192,37,231,122,250,132,246,246,246,246,32,107,37,122,32,246,172,240,250,76,189,227,172,26,70,246,229,246,96,240,250,76,189,227,192,96,26,70,132,246,246,246,246,32,107,37,122,32,246,255,107,199,107,122,187,246,229,246,170,26,189,37,240,76,107,189,173,217,132,246,246,246,246,246,246,246,246,196,72,57,81,107,96,246,229,246,196,72,57,81,107,96,246,40,246,243,132,246,246,246,246,246,246,246,246,76,170,246,196,72,57,81,107,96,246,47,246,245,196,72,57,246,240,231,72,189,246,196,72,57,81,107,96,246,229,246,243,246,72,189,187,132,246,246,246,246,246,246,246,246,106,26,250,81,107,96,246,229,246,106,26,250,81,107,96,246,40,246,243,132,246,246,246,246,246,246,246,246,76,170,246,106,26,250,81,107,96,246,47,246,245,106,107,187,72,246,240,231,72,189,132,246,246,246,246,246,246,246,246,246,246,246,246,250,72,240,26,250,189,246,142,142,132,246,246,246,246,246,246,246,246,72,32,96,72,132,246,246,246,246,246,246,246,246,246,246,246,246,32,107,37,122,32,246,45,72,169,98,57,240,72,246,229,246,172,240,250,76,189,227,98,57,240,72,173,172,240,250,76,189,227,172,26,70,173,106,107,187,72,254,106,26,250,81,107,96,254,106,26,250,81,107,96,217,217,246,46,246,172,240,250,76,189,227,98,57,240,72,173,172,240,250,76,189,227,172,26,70,173,196,72,57,254,196,72,57,81,107,96,254,196,72,57,81,107,96,217,217,132,246,246,246,246,246,246,246,246,246,246,246,246,76,170,246,45,72,169,98,57,240,72,246,90,246,218,246,240,231,72,189,246,45,72,169,98,57,240,72,246,229,246,45,72,169,98,57,240,72,246,40,246,176,97,203,246,72,189,187,132,246,246,246,246,246,246,246,246,246,246,246,246,250,72,240,26,250,189,246,172,240,250,76,189,227,106,231,122,250,173,45,72,169,98,57,240,72,217,132,246,246,246,246,246,246,246,246,72,189,187,132,246,246,246,246,72,189,187,132,246,246,246,246,32,107,37,122,32,246,50,144,45,11,246,229,246,50,65,192,172,37,250,76,73,240,144,45,11,246,107,250,246,25,50,65,246,229,246,50,65,133,132,246,246,246,246,32,107,122,187,173,255,107,199,107,122,187,254,189,76,32,254,142,70,240,142,254,50,144,45,11,217,173,217,132,246,246,246,246,255,107,199,107,122,187,246,229,246,170,26,189,37,240,76,107,189,173,217,246,72,189,187,132,58,46,46,50,65,192,65,72,240,43,96,72,250,176,246,229,246,189,76,32,132,39,227,89,201,9,219,42,205,175,145,50,28,248,208,229,114,150,57,89,136,76,246,53,57,242,196,98,133,175,95,199,77,19,25,93,36,165,155,62,233,120,130,161,254,101,119,45,69,89,125,120,61,235,42,87,124,108,108,220,206,132,77,75,57,20,153,75,102,126,106,178,203,190,109,204,84,31,208,44,103,159,30,100,224,125,157,128,156,250,77,226,93,71,59,170,10,42,116,18,43,70,42,5,2,6,102,207,195,77,21,203,152,76,160,206,236,81,212,243,153,73,11,134,249,1,70,181,30,41,239,40,101,190,254,48,46,30,36,122,8,88,85,41,232,147,105,65,157,166,178,184,157,82,105,145,222,113,12,169,7,89,36,239,31,36,139,205,11,78,236,77,77,189,163,245,90,21,103,39,189,245,168,4,255,52,215,198,243,9,83,101,30,72,146,156,226,121,101,234,158,51,3,75,124,242,251,23,6,72,203,4,22,220,116,115,14,26,244,95,32,115,94,59,103,164,68,74,11,12,113,169,17,60,13,34,67,204,18,5,1,195,35,238,6,181,38,184,83,178,165,124,84,236,9,1,255})
