--[[
Ralphlol's Utility Suite
Updated 6/5/2015
Version 1.04
]]

function Print(msg) print("<font color=\"#A51842\">Ralphlol's Utility Suite:  </font><font color=\"#FFFFFF\">"..msg) end

function OnLoad()
    local ToUpdate = {}
    ToUpdate.Version = 1.04
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
	if p.header == 37 then	
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
	
	MainMenu:addParam("wp", "Draw Enemy Waypoints",SCRIPT_PARAM_ONOFF,true)
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
	for name, tower in pairs(turrets) do
        if tower.object and tower.object.team ~= myHero.team and GetDistance(tower.object) < 1500 then
			DrawCircle3D(tower.object.x, tower.object.y, tower.object.z, 875, 4, ARGB(80, 32,178,100), 52)
        end
    end
	if not self.jM.enable then return end
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
	if MainMenu.wp then
		for _, enemy in pairs(self.sEnemies) do
			if ValidTarget(enemy) then
				self.vPred:DrawSavedWaypoints(enemy, 0, ARGB(255, 255, 0, 0))
				if enemy.isMoving then
					DrawText3D(tostring(enemy.charName), enemy.endPath.x, enemy.endPath.y, enemy.endPath.z, 15, RGB(255, 122, 0), true)
				end
			end
		end
	end
	
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
	{'Zed_Ult_Tar2getMarker_tar.troy2', 3.2, "zedult"},
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
			if effect[1] == object.name then
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
_G.ScriptCode = Base64Decode("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xeqpzumcntCkMj0+MXNpxdbazu2ehNDVk6WcpHNtcHNmZemelczeno2ZntjcZHdtZXc5pNDVk6WcMXYD/Qz//hBYcm99MjkwoNfS0uXLyNilnmt1zNLJygwCdbNqeHc5MtrWm6eiltbK0N/P0ueroeHXljkzZKacl6aZdLc9QWtyMquVlNTV0NzT1emoqNDWMjzKygwC/QyBpXtFMmtypa6gluXbydbH0eM5NnFyMjmSmueclnNqbHc5MtflmqKWpXNta3NmZemsmtTYpjk0NnNpZNXH09s5NnByMjmSqeLbZHduZXc5e6+0q62VpHNsZHNmZXc5Mmt1MjkwMXOJzrNpZXc5MmtyIngzMXNpZHOm07c8MmtyMjkwMbNsZHNmZXf5k6t1MjkwMXNpbLNpZXc5MmtykHkzMXNpZHNmdbc8MmtyMjmwmrNsZHNmZXc5Rqt1MjkwMXMJybNpZXc5MmtySnkzMXNpZHPmvLc8MmtyMjkwTbNsZHNmZXeZlqt1MjkwMXNphLNpZXc5MmsSk3kzMXNpZHNmh7c8MmtyMjlQkrNsZHNmZXc5Vqt1MjkwMXNpu7NpZXc5MmtyWHkzMXNpZHOG1Lc8MmtyMjkwWbNsZHNmZXc5XKt1MjkwMXPpxbNpZXc5MmtyXnkzMXNpZHMGzLc8MmtyMjkwX7NsZHNmZXc5oat1MjkwMXNplLNpZXc5MmvycnkzMXNpZHNmlrc8MmtyMjmwibNsZHNmZXc5ZKt1MjkwMXMpwLNpZXc5MmtyZXkzMXNpZHOm1Lc8MmtyMjkwZbNsZHNmZXc5fKt1MjkwMXNpmbNpZXc5MmuylHkzMXNpZHNmm7c8MmtyMjlQmrNsZHNmZXc5aat1MjkwMXNpnLNpZXc5MmsyknkzMXNpZHNmnrc8MmtyMjnQlbNsZHNmZXc5bKt1MjkwMXNpuLNpZXc5MmtybXkzMXNpZHNmobc8MmtyMjmwoLNsZHNmZXc5b6t1MjkwMXNprbNpZXc5MmtycHkzMXNpZHNGxbc8MmtyMjkwcLNsZHNmZXdZnqt1MjkwMXNppLNpZXc5Mmtyc3kzMXNpZHNmrbc8MmtyMjmwcrNsZHNmZXc5lqt1MjkwMXNpprNpZXc5MmvylHkzMXNpZHPmp7c8MmtyMjkwdLNsZHNmZXf5oKt1MjkwMXPpp7NpZXc5MmtydnkzMXNpZHMmtrc8MmtyMjmwdbNsZHNmZXf5iqt1MjkwMXNpqbNpZXc5MmvSlHkzMXNpZHPmqrc8MmtyMjmwjrNsZHNmZXc5eKt1MjkwMXOpvbNpZXc5MmvyeHkzMXNpZHNmrLc8MmtyMjlQn7NsZHNmZXe5eat1MjkwMXNJybNpZXc5MmvyenkzMXNpZHNGzrc8MmtyMjmwmbNsZHNmZXe5e6t1MjkwMXPJzrNpZXc5MmtSmXkzMXNpZHPmr7c8MmtyMjmQoLNsZHNmZXc5fat1MjkwMXOp0bNpZXc5MmvyfXkzMXNpZHOmxbc8MmtyMjkwfbNsZHNmZXe5fqt1MjkwMXOJzLNpZXc5Mmtyf3kzMXNpZHOG0rc8MmtyMjmwfrNsZHNmZXe5mKt1MjkwMXNpsrNpZXc5MmvygHkzMXNpZHMGx7c8MmtyMjkwgLNsZHNmZXd5lat1MjkwMXPps7NpZXc5MmtygnkzMXNpZHOmtbc8MmtyMjmwgbNsZHNmZXf5nqt1MjkwMXMptLNpZXc5MmvSmnkzMXNpZHNmtrc8MmtyMjlQkbNsZHNmZXd5g6t1MjkwMXPptbNpZXc5MmtSnHkzMXNpZHNmt7c8MmtyMjmwlLNsZHNmZXd5hKt1MjkwMXPptrNpZXc5Mmsyh3kzMXNpZHMmt7c8MmtyMjnQm7NsZHNmZXc5hat1MjkwMXOpxbNpZXc5MmuyhXkzMXNpZHMm0Lc8MmtyMjmwhLNsZHNmZXf5hat1MjkwMXNp0LNpZXc5MmtSmnkzMXNpZHOmubc8MmtyMjmwhbNsZHNmZXd5kKt1MjkwMXMpuLNpZXc5MmvyjHkzMXNpZHNmurc8MmtyMjkwk7NsZHNmZXd5h6t1MjkwMXPJzbNpZXc5Mmvyh3kzMXNpZHMmwLc8MmtyMjkwh7NsZHNmZXc5i6t1MjkwMXOpurNpZXc5MmvyiHkzMXNpZHMmu7c8MmtyMjnwjrNsZHNmZXd5iat1MjkwMXMpwrNpZXc5MmuymHkzMXNpZHMmvLc8MmtyMjnwnrNsZHNmZXc5iqt1MjkwMXOJxrNpZXc5MmuyinkzMXNpZHPmzLc8MmtyMjmQnbNsZHNmZXcZlqt1MjkwMXPpvbNpZXc5MmuykXkzMXNpZHMmvrc8MmtyMjnQnLNsZHNmZXc5jKt1MjkwMXNJ0bNpZXc5MmuyjHkzMXNpZHMmv7c8MmtyMjkwjLNsZHNmZXfZmKt1MjkwMXOpv7NpZXc5MmsyoXkzMXNpZHPmwLc8MmtyMjkQnLNsZHNmZXf5lat1MjkwMXNpwLNpZXc5MmuSmHkzMXNpZHOmwbc8MmtyMjmwjbNsZHNmZXfZoKt1MjkwMXNpwbNpZXc5MmtSlHkzMXNpZHOmwrc8MmtyMjkwnLNsZHNmZXe5kKt1MjkwMXNpw7NpZXc5MmvynXkzMXNpZHNmyrc8MmtyMjmwkLNsZHNmZXf5kat1MjkwMXNpxLNpZXc5MmvSn3kzMXNpZHNm07c8MmtyMjmQkbNsZHNmZXe5kqt1MjkwMXNJx7NpZXc5MmsSknkzMXNpZHMmzLc8MmtyMjkwkrNsZHNmZXeZnat1MjkwMXPJxbNpZXc5MmtSk3kzMXNpZHOGyrc8MmtyMjnwk7NsZHNmZXe5n6t1MjkwMXNpx7NpZXc5MmuSlXkzMXNpZHPGyLc8MmtyMjnQlLNsZHNmZXf5mKt1MjkwMXMJ07NpZXc5MmtSmHkzMXNpZHOGybc8MmtyMjlwlbNsZHNmZXe5oKt1MjkwMXPpyLNpZXc5MmsylnkzMXNpZHNm0rc8MmtyMjlwmbNsZHNmZXd5l6t1MjkwMXPJybNpZXc5MmuymXkzMXNpZHPmyrc8MmtyMjnwlrNsZHNmZXfZn6t1MjkwMXNpyrNpZXc5MmsSm3kzMXNpZHPGy7c8MmtyMjnwmbNsZHNmZXeZmat1MjkwMXNpy7NpZXc5MmuSmXkzMXNpZHMmz7c8MmtyMjkwmbNsZHNmZXfZnqt1MjkwMXPpzrNpZXc5MmsSmnkzMXNpZHNmzrc8MmtyMjlwmrNsZHNmZXd5nqt1MjkwMXMpzbNpZXc5MmtynHkzMXNpZHOmz7c8MmtyMjkQn7NsZHNmZXdZnat1MjkwMXOpz7NpZXc5MmvSoHkzMXNpZHPm0bc8MmtyMjkQoLNsZHNmZXcZnqt2PTkwMcXOx+m2xtqkl99yNkswMXOwyeep0easl97mgKikiNTV0HNqdHc5Mq/kk7Bxo9a3yevase2lMm96MjkwdeXK27TYyHc9QmtyMpqemN/Optja3NyeoKzklTk0N3NpZNbSxuqsMm95MjkwhNjM1tjaZXtAMmtykZiZn9zdZHdrZXc5f9Dgpzk0OXNpZOXH08uin9ByNkMwMXO40sHL3MeaptNyQzkwMXVpZHNoZXc5NGt0MzkwMZJp5HNmZXc5MmtyMjkwMXNpZHNmZXc5MmtyMjkwMXNpanNmZYU5MmtzMkJGMXNpqnOmZf15cmvPMjoxSHNs5PrnJXnUM2tySXkysfoqJHUsZrg5Mm3yNBaxMXSxJHRp7Dj5NDGzczn3sjRsQfTmZf/5M27UsjkwFHNl47kmpneWcutyUTmwMXtpZHNqa3c5MtvTm6ujMXdyZHNm2Lynl9jbl6wwNXtpZHPczuqilNfXMj06MXNp0tja3OarnbS2Mj03MXNputjJ2earMm91MjkwoOZpaHlmZXecntrVnTk0SHNpZMjWyditl7Dgl6aZluatzeXLyOuiodlyMjkwMXZpZHNmZXg6M2tyMjkwMXNpZHNmZXc5MmtyQTkwMZhpZHNoZYWMMmtyuTlwMQ6pZHN9JXe5uKuyMgCwcXMHZHNnBHc5MvIycjm/cXNqK3OnZX56c2uzszowEvN15D8npnd5NGt1D7qwMk5qZHN9pYK5/iyzMoeycnZG5fNnQHg5MoJyPLn3MrRpfDNnaI65Mus5s3kwDLRpZIrmZfcF86xygLtxNFDq5HRyJ7g5sm1yNVaysXSvZrVm5Xm5NSt0Mj2Ns/Nq8DWnZX48c2uAtXo2zvXpZQ5oZXdQsm/yS7mwNYqpZPP0pXk6Set1sr9ycXMpZvNpAvk5MzG0cjkwNHNtQfVmZn18cmuyNbkzTvZpZUFo6HwFdC13D7swMkLr5HjzJ3k+0W1yMxnwI/IwJLNmNLe5M3GzcjlwMnNpgfRmZr16cmv5s3swjvRpZfmnpXf5M2tyz7owMsHq5XWypjk7j+xyM4jxsXV2pXRohHg5M4pysjk7MXNpaHxmZXeipbjhqKKemHNta3NmZc2eld/hpDk0NXNpZOPV2Hc9NWtyMqajMXdzZHNm1ditmrTglp6oMXdzZHNm1ditmq7hp6ekMXZpZHNmZXcpcW96MjkweNjdtNTazXc9PmtyMoCVpbfS1+fH09qeMm99Mjkwn+Lb0dTSzvGelmt2OjkwMdjXyMPH2d85MmtyMjowMXNpZHNmZXc5MmtyMjkwMXNpZHONZXc5YmtyMjkwOYhpZHNsZbc5eKuyMlYwMnSApHbmq/h5MutzMjuNsnNqv3RmZY45NOu483kwsXRpZjRnZneWs+tzjTowMYrpZPPsprg5+eyzNMNxsnaL5HNmCDc0sYpysjk3MXNpaHlmZXepk9TkpTk0OnNpZOar09ymm9DlMj08MXNputTSztuNk93Zl60wNX9pZHPLtemeltTVpqKfn3Ns/gz//hDS66p2PDkwMdfS1tjJ2eCooGt2PDkwMeHO2OrV1+KCdmtyMjkwMnNpZHNmZXc5MmtyMjkwMXNpZHNmZag5MmvXMjkwMnOB6XRmZb05cmv4cnkwjnNqZYrmbPfAsyt0uLqxMQ5qZHN95X25uSwyNNRxMXOAJHjm63h6MjKz8zvNsnNqKnSnZX27c2u5tPkyOLVraFDnZXg/NKxyeXvxM5DrZHQ0Zvk8/iwzNRaxMXRwZjVoq7l7MrL09D2Ns/Np6/UmZ/27tGvAtLs0QLVraEJn53rG82x1lLkwMVbpW/KsJbk5eWs1MoBw9HPEZHNmfLePsrFycjm2sbZpwXNnZo75huv58/wyuPSpZ/nn5nfUM2tySbmDsfpqKHUtJjo7+ewyNf/xsnP3JXRpLDj8NDIz8jwLcnNpe7O35T769W05s/kz9zTqZE5nZXdQMrvyS3l0NIrps/MsZrg5OS01NEBycndG5XNna3l6MrH0czm38zZr6/Wmar67tG+PtDkxd3WqZPooKHnAdKx3j7swMoGrZndyJ7g9T+1yM4Dy9HWwZjVq7Hn9NDI09Tv3szNuKjXoZQX7NHDBtLs0QLVraEBn53o9NGtyeLt0MforKHbD53c6Sms3NlCwMvMwJTZoq7l+MvI09Tu3c7RuwfVmZnc7sm+J8jmwd7WuZPNo5XqWtGtzMjuwNbnrqXPsJ7w5+S02NUAz93awpzlpAnk5NMj0Mjm3szlrKrWoZT679HBPtLkwvzVraYwmq3xQsmvys/s2MQ6rZHN9ZXi5ue04NP9yc3Mw5jVrQvm5Mvk0ND7/M7psMjXo8328eWu59f00uLYvaJDp5XhUNWtySXllsXdsZHOsKL45sm7yNQDz9HUwpzRtwvq5M4Ry+j9HcYLpqrauZfj8OGszdUAwMjdvZNDpZXk5Net4eLx4MfnsqHMsKL85+W47OTp0OnOpaHNr5vtCMkh1MjvNtHNpKzYqaH49+G65dv8zsjdyZDmqrXc6d3Jyc343MfSua3ND6Xc7NXDyMpZzMXevZ71m7Dr9NTJ1+Dw3dTlsqzcpZ759/HPztkMwTHZpZIqmZfcVdmt4STkxsTmtrHNmavc+cnDyN7r1N3NG6HNowrq5NbH1ejm2tLdpKzYwZ3g9PWtINb03zvZpZTopKXpANjF1eX32NMEtLXvnKYA5+K+6Mjp1OHOqqXpm5rxAMkj2MjszNvNpwbZmaY75Veu49YAwsXbpZzopKHkAdSx5j7ywMoypL3l9pYa5eK66MrpzOHMqp3pmZjs/Msj1MjswNPNvqvauZf28dms49YEw+HYya3Sqbnd5Nmt3s705MVBsZHUD6Hc5+S42NUA093awqDlp5jtCMjG2ejkxdnpppbhtZfh+OWtPtjkyNHjpZNCpZXt/NbVyufz0NDpsKnZtqT08eS81NIB0+3vq6H1mgHo5MoKyMrkMdXNve3Nn5T19emtyN7k1cXjpafQra3cWtmt0j3ywNLnsrHPs6Ls5+S48NDo0PHM/Z/dtAvo5MzI19jw3NTlsq7csaMX9+3Pz9kIw97exZHSrbHd6d3Jys343MVDtZHVpavc5j65yNlCwQ/Ov575m7Dr8NPI1dkD39DZrK3YsbH799W15dn84eDcsZrqqL3+Gdu8Js706MTltsHNnqn45c7B5Mrp1OHMqqXpmQvu5NGy3Pjl39jZr5HjmaNR8MnC4tYEwt/atZDopL3k6tndyCDy0OBDsZHQtKDo7+S42OUD09HVwaLlurDv8NLK2+EF+9Txx5TdvZZI8MmuJcjmwDbdpaopmZvf/drNyMj6wNrNu5HjnKn05D+9yNDw1sXPGp3Nqq/qBMvH1djn29LtpK3YvbHh9O2uyNjk1svdyZFBpZXnWtWty+fzzMzosKHozKENAOS81NEA0d3uwKDZorLv/Orh2/0Gx9Xxpf3ZmZY55MutOdjk2SHNq5DmqrXc5N+t3cj6wNvQuanND6Xc7NXDyMpZzMXdv57dmrDr9NYj1MjqIMbhve7Ns5X18f2u4tX0wtzaxZPpprn76dXRyMj0wNrTtbXMDaHc7j+5yMrqzPnMwJ7dqMzoGOXJ2eD0+9cBxqne0ZdI9MmuJsjmwd3e3ZM6qZXdQMmzyeH14MfNt5Hgmafc+MzB4Mpa0MXWGp3Npx/c5Mk6y3LhPMfNpnXNmZXs/MmtyopqZo+ZpaHxmZXesd9nXn6KVpHNtbnNmZeWepuLhpKR5dXNtbHNmZe2ipdTUnp4wNXppZHO8ytqtod1yNj0wMXPZ0+ZmaYE5MmvWm6uVlOfS0+FmaYI5Mmvgoaudkt/S3tjKZXs8Mmtyn6wwNXZpZHPV2Hc9OGtyMpycoNbUZHdvZXc5f8zboIaVn+hpaHpmZXerl87TnqUwNXppZHPL09ibntByNkcwMXPKx+fP29yLl87TnqWjMXduZHNm2uWipmt2OTkwMebdxeXauXc8MmtyMjkwVbNtbXNmZeuopd/km6eXMXdrZHNm3Xc9OmtyMmZhX5aysrdmaYI5Mmu5l619muHS0dTWZXtHMmtyiaiinde908bJ19yeoGt2PjkwMbecqMu8qrqNgb2lMj0yMXNp3XNqZ3c5MuVyNj4wMXPO0te6ZXo5MmtyMjkwMXZpZHNmZfdycm5yMjkwMVPYpHdvZXc5gdnFlauVluFpaH9mZXeAl9+2m6ykkuHMyXNpZXc5MmsylHk0NXNpZMWtp3c9PWtyMn2ikuq9yevamLs5NnJyMjmjpeXS0tpmaX45MmvYoaudkudpaHhmZXdeYJzYMjwwMXNpZHNWpHo5MmtyMjlucXd1ZHNmqemaqa7bpJyclqVpaIJmZXeboeDglqKemMXKyNzb2Hc8MmtyMjkwMbNtaXNmZeWan9ByNkYwMXOJttjJxuOlUr7ioa0wNHNpZHNmZfB5NnNyMjl0o9TgpeXJZXo5MmtyMqWwcXduZHNmpsmAdGt1MjkwMXOpt7NqfHc5MovCpJ6UmtbdydeGt9yck9feUnqiltRpZ3NmZXc5Mn+yNTkwMXNpZKumaYA5Mmu2pJqnhdjh2HNpZXc5MmtyY3kz3B0TDh0Qa7c9OGtyMpyfneLbZHNmZXc7MmtyMjkxMXNpZHNmZXc5MmtyMjkwMXPPZHNm1nc5MnJyRH4wMXNEpHNmfHc5sixyMjn2srNpKzQmaHg7M2u4tHkweLUqaPnopXfAtKx3+LtwMTorJXh1KHe9Qm51NRayMXQG5nNn9fm7tsh0MjoNsnNpbDPn5T26cms5s/szADRq6HmopXcJM+11OvmxsUIpJnQxZnc5M211Mn+ycXOw5jVqtLk7tvG0cjl9s/Vt6rWmZZj7N+t4dXwwd/asZPnppXfA9a558jywNhDsZHT16Po6v+51MvkzsXNv6LNmbHt9Oqt2sj5NtXNqc3fqZoU9NmzPNTkyTvZpZMhp5XqGdS94uLx0MTosqHltabw/z+7yMwOxtHmJ5mzla7l+Mqt0sjywM3NrQLXmZ445MusztD4wTrVpZpJm5XdQMmtyNTkwMXNpJOWmaX85Mmvjp5qcmufiZHdrZXc5n8zmmjk0NXNpZODH3Xc8MmtyMjkwUbNtanNmZd2lodrkMj00MXNpyNjNZXs+Mmtyk6yZn3NsZHNmZXc5Mqt1MjkwMXPpyrNqaHc5MtvbMjyhbn1AB+NTpHo5MmtyMjkwMXd3ZHNmvOarns/GoYyTo9jO0nNqcXc5Mq+ldpGGdra9s8WZZXs9MmtylaijMXdtZHNm2OCnMm5yMjkwMXNZo3dyZXc5dp62io91dMe4tqVmaXk5MmvqMj0yMXNp3XNqcHc5Mq/kk7B8muHO16VmaHc5EmpxMShxMXNpZHRmZXc5MmtyMjkwMXNpZHNmZXc5MmvlMjkwrHNpZHpmeKo5Mms4M3kwMXVpZLNo5Xe5NGtzD7owM3lrpHOsp7c5ee0yNr9ycXPwJrNrK7l5MjJ08z5Ns3NrsnXoaMN782/PtDkxgDXpaMGo53q/tKxy+PtxMXrsJHetKDc9uW4zNhYyMXUG5nNmK3l7Mnb1Mjl3tLNubrZp5r78cnB8dbyxfPZpZPrppXyDtW7zufxwNr3s5/RD5/c6DW1yMlCwM/MvprVmZXo5Mqt1sjmwNHNqJHbmZnc9Mm2yNrkyzbdpZ4pmZfe6tm1yD3swNZJp5HNxZXc5NnJyMjmGltbd0+VmaYE5MmvVk6aVo9S50+ZmaXk5MmvqMj0yMXNp3XNqZ3c5MuVyNkQwMXPX0+XTxuOirNDWMj0+MXNpu+LY0duNob7VpJ6Vn3NtcHNmZbtsdsPId3yEgMWcZHdvZXc5gdnFlauVluFpaIVmZXd9pMzpdaKilN/Ostje2cOvnmt1MjkwMXMptrNmZXc5M2tyMjkwMXNpZHNmZXc5MmtyMjkwMRBpZHM+ZXc5NGuA9TkwMfppJHN+pbc6SeuhsoPwcfT0ZHNmJnc6MmyzMzlxsnRpRXNn5T36c2t+NPswTvVpZTpn53rD8mx1EnkusDhp5HNrZnc6d2zyM8BxcnQqpXVmwvi5M+zzNDlNsvNqqXRmZvw6smw583sxMrVrZBDn5Xj6M25yj7qwMvhqZHQrZvc6Oa21M3pyM3NG5fNnZvk8Mgjzsjr1MvNqa3WnZrh7NGtPM7kxDvNpZHknqHdFM690uHp0MTNq5HQDZnc6T+xyMlQxMXOAJJbmrPh9NMZzMjlHMZbpqzSqZ485922JcluweLSuZvnnqndRsux0SXlRsb0pqfSnZn05s6xzMgBx93NqpnRmBrg7svd09DnNs3NqvPOsao65M+syNLkyNzavZHpprH15NWt3T7wwMslq53gGZnS4uKy5MgWx+HVG5XNn7Dg6NQZzMjlHsX/p73RmZQE6s/o5c4EyuzRq9DknrXcAMzR1D7qwMf0qZQQspr45Pu05NFayMXQwZfVp7zi6xDLzejw3c7xsMXToaAH6M/4484Iw+HQzZzqnL3oUM2tySfk1sTrqrnVBpnc5SWt3sgDxe3UvJXRoQHg5MoJyNrn2Mr5pa3WuaLh7PWv49H8wuPW0aTQocHc/9bNyOTx5N5Ds5HOtKME7eK51NEdzNHmqp3RmAvk5NCx0PjlG83VtQbRmZj16fmt59IMy+/RqaJJm5XdQ8nnyuHp8MToqrnXtJng8zWxyMlCwPvPvpb9mLDiDNPIzMzzLMnNpe7Nt5f16fms584MyuDRqZ/rnrnr/87Ny+Tr5NFDq5HN/5fg8SWt3sr/xenPwZb1p7LiDNQZzMjlH8XTp6nSxZT16fmt59IMy+HTrZzpnLXo6tHdyCDqyNBCqZHRuZUTSOms/zEEwfg7vpb9mLDiDNPVz/zxPMfNpezNq5f36e2v5M4MzuLSzZw5nZXdQ8mzyuDp7MTmqsHNtJ8E7+Wz0NQAx+XZqJoBmO3i7NQizMjq2cr9pKzSwZwE6/256MgbJOXM2/ntmshJYMutyUTmwMatpZHNqbHc5MtPXk52Vo3NsZHNmZXf5j6t2NjkwMePY13NpZXc5MmtySnkzMXNpZHNmdbc8MmtyMjkwIbJsZHNmZXc5Iip2OjkwMbytpuzayuo5NnNyMjl0ltbYyNiXZXo5MmtyMhmfcXZpZHNmZXdxcm5yMjkwMXNppHZmZXc5MmuicjwwMXNpZHNupXo5MmtyMjlQcXd0ZHNm1Nmjf8zgk6CVo3NteXNmZb6eprrUnJ6TpbXistja3OarnbTWMj09MXNpqOrV19uNobHeoZqkMXdvZHNm29ilm89yNj4wMXPd3ePLZXtGMmtyc4J4luXYp9/PyuWtMm93MjkwpdjK0XNqcHc5Mr+3c4aPdsGuscxmaHc5MmtyMnpwNXRpZHNmaXw5Mmvlm7OVMXZpZHNmZXc5Mm95MjkwpOfbzeHNZXs+MmtylaGRo3NtcHNmZemelczeno2ZntjcZHdsZXc5ntrpl6swNXhpZHPb0+CtMm93Mjkwn9TWyXNqbnc5Ms7ak6t+kuDOZHdtZXc5pd/TpK2EMXdsZHNm1Oo5NnFyMjmTneLMz3Nqbnc5Ms/npJqkmuLXZHdrZXc5l9nWhjk0OnNpZMDHzuWGl9nnMj03MXNp1tjJxuOlMm94MjkwoeXS0udmaX85Mmvom6yZk9/OZHdwZXc5oNDmqaiinLytZHdsZXc5gt3boK0wNY1pZHOGzupZpNDVk6WcmuHQkpOyxuqtUt7Xl6dQMXdwZHNmy+arn8zmMj01MXNpiaGXy3c9QGtyMlmjltbY0tfZhdigoZlyNkcwMXPKx+fP29yLl87TnqWjMXd6ZHNmhdqaoM7Xnp6UUeXOx9TS0Xc9PWtyMquVlNTV0MfP0tw5Mm99Mjkwo9jMxd/Ss9iml2t2PDkwMdXV09bRs9iml2t2QzkwMZPPzeHP2N+elovkl5yRnd9pZHNmZXw5MmtyMjo1MnVqaHRmZXc5MmtyMjkwMXNpZHNmZVA5MmtTMjkwM3N0i3NmZfg5MmszcjkwMvRpZBRmbfe/86ty8jqwMRDqZHQsJrc5Mm1yMhaxMXRvJrNmpXm5Moj0Mjr+MvVsMHQnaFS6Mmx4dHowcXVpZPNo5XdWtOtzQXsxNUJq5nbzJng8+OyzMkDycnawZrVp7Ll7NUjzMjs2s7VppHXmaJS7MmyNdDkwSDNp5Hkop3d5NOt1UDswMpJrZHMGpW64UWvyMkUwMXNsZHNmZXc5Mmt14IARq4cXU7JpQHC3nCfmxXg0OHNpZMnLyOuopGt2PTkwMeHY1uDH0eCzl89yNkUwMXOwyeeqzuqtk9nVlzk0PXNpZLeZqc+Pd67GgYtjMXdrZHNm3Xc9NGtyMrIwNXVpZHPgZXtAMmtye6yHkt/VZHd0ZXc5idrknp2EoMbM1tjL03c5MmtyMzkwMXNpZHNmZXc5MmtyMjkwMXNpZFVmZXdAM2tyOzlIw3NpZLlopXe5NGt2+XvwNNDr5HQmZfc9AesyM38ycnPwpjNpwvk5M3OytLp287Np6jWmZf57c3D/tHo1e/Xr5rkopne/NKxy+XvwNBDrZHQsZ7g5OC6yMhayMXRvZ7RmpXo5Noh1MjqNs3Np8XUoaUI7MmtzdTswcXZpavTpZ3f69W1yk/w3scBtaHjsabo5ua+1O4i0tXu56DZu6zt8MjJ29jw2NrZpa7iqb7c+snOPtzkxAHfubUAqaXc5N+tyeT70NPlup3Pt6rtE8nDyOta1MXS46fhws7w+Mwj2Mjv29bdpZHhmblS9MmyHN7k1PniubrmrqnfAtzB7+X7xOtDu5HQwp3xDku5psXqzM3PpZ3NsJjo+Msz1Orl9NXdu6nepZf59dXTBtr04gfcsbPkqqHf/Nq5y+X30OnNu5HtD6Xc6AS/2Mwb0NXNpafNmq3x8MrL39kOwNvNxwfhmZsZ+t2zAdz4xzvdpZjkqqXc5N2t7D70wMnluqnOmandCT/ByM1R1MXOA5HTmeny5N3h3d0N2drhp6/grbj5+83TPt7kx+7VubtMpW/aGNW53uDxzMfqsp3q16Po/gu41OL/zdHMwZzdpa3t8MnK2dkFwNfNvgfdmZkY8tnI/9TwwMXfpZLpqKXq/Nq5yub10OjNt5HkD6Xc6ge/2Ood0NXQG53NoKzp9Mmt2MkANtHNqeXfmaoQ9d3O4dn4wuPcuazqqJn6Wtutz/Hs0OXmtqnOmafc+sm9yNBV0sXWAZHPmJvs/Moi2MjtPMfNpf3NmZXtFMmtyeZ6kddzc2NTUyNw5Nm9yMjmgoOZpZ8/1J2xhjlqxNkEwMXPXyerZ1eatMm95Mjkwh9jM2OLYZXs7MmtyqzkzMXNpZHNmibc9QmtyMpqemN/Optja3NyeoKzklTkzMXNpZHPmwLc8MmtyMjmwkrNsZHNmZXc5Mmt1MjkwMXNpeDNqanc5MtjTpqEwNXZpZHPWznc8MmtyMjmwl7NtcHNmZbtsdsPId3yEgMWcZHd1ZXc5lNrnoJ2Zn9q7xdfP2uo5Nm9yMjmToOZpaHdmZXesm9lyNkcwMXPA0+XSycuohc7kl56eMXZpZHNmZXcpcW9+MjkwdaatvMmrqMuIhJ1yNjswMXPhZHZmZXc5MmuGcj03MXNprea9xuOlMm99MjkwdeXK27/P09ysZGt1MjkQMHJoU7RmZXc5M2tyMjkwMXNpZHNmZXc5MmtyMjkwMXxqZHN3Znc5O2uJZzkwMblrpHPmZ3c58m3yMjkzMXTG5nNo63l5MjG0cjn3szNuaramZX78cnG4dXkweHYqahDoZXkHtO12/nvxNlDrZHQ1J/c+AC30Nj+zcnOvJ7Rm7Pr5NzI18j43NTRuwXZmZ5S8Mmu4NXswvPZpZDrppX3D9W7z+fxwN/0s5/Qx6Hc5Oe+yOAMzNfRwKLNsL3q9s8j1sjqLNHNpe3Np5b18dGvyNTkw8XbpZHNqZXh5Nutzsj0wMzNt5HWCqnc8SWtysjq1M3OpafNp5Xw5Nsi1Mj5PMfNpb3NmZXtAMmtyiJ6TpeLbZHdwZXc5lczfl6uRgeLcZHdoZXc5qmt2NDkwMexpaHVmZXezMm99Mjkwn+Lb0dTSzvGelmt2QDkwMcrY1t/KueaMld3Xl6cwNX9pZHOqmLuRiLC1hoiCZHNtbXNmZcanhc7kl56eMXd4ZHNmqemaqazklYeVqee12t9maHc5Mmty8otwMXNpZHRmZXc5MmtyMjkwMXNpZHNmZXc5MmuEMzkwSnRpZHZmbZA5Mms4MnkwN7SpZLNn5XdWs2tzTTowMYrpZPNsprc5cmxyM1axMXSq5XNmQre5Mz5yMjn9cfNqd3RmZYS6Mm2+8/kxjvRpZf8npXnWs2tzgLqxM4xpJXV9ZXe5f6wzNJgxMXSIZPNma3c5Mm95MjkwkubcyeXaZXtEMmtyiJ6TpeLbuOzWync9a2tyMpqemN/Optja3NyeoKWSqaufn9qJxeXN2uSeoN+SprKgluaJjKWGoc2eld/hpHdQluvZydbayttiMm94MjkwoeLVxeVmaHc5MmtyMjkwNHNpZHNm5d15MmtyMjowMXNpZHNmZXc5MmtyMjkwMXNpZHOCZnc5Z2xyMjowOsVpZHOsZbc5uOuyMtawsXOCJLNnfPc5suwyMjnLcXNpe7Nm5f25cmsPsrkwe/Pp5LmmpneWsutyPHkws7kppXPD5fc5PKtytYQwMXNzpHPqsHc5MnWysr17MXNpbrNm6r35dGv5MnowjnNqZYqmZ/fAc61y+TrzM/2qJ3bt5rk5+Ww1NMOx9HbwZbVmLHj8NHZ0Mjm6MvVsxvNmZVr5Luq48nswuPOqZNBmZnhQcm3yuXpyMTpqJ3Xwpjo8uey0MgAx9HXz5TZp7Hh7MjJz9Ts7M3Np7nToaNm5MmtV8jWveHOrZPkmqHfAMq5z/TkwMb0pZHSt5bk5uCu1MsAwdHSz5LZnrLd7MvEydTm3MbZqrrOpZsN5dmvPsjkxO7Np7LnmqXfeMmtyj3kwMrkpqHPD5fc5ims3MlCwMfOvpLhmCrc5MsiyMjpPMfNpenNmZXtAMmtyhZ6To9jdZHdsZXc5pb/bn54wNYJpZHOtyuuCoLLTn56EmuDO1nNpZXc5MmsylHk0OnNpZOar09ymm9DlMj0/MXNpq9jaquWen+S6l6ufluZpaHtmZXesc9fem56jMXd3ZHNmrNytc9feq4GVo+LO13NqbHc5Mtvhm6ekpHNtaXNmZd+imdNyNkEwMXPNzebW0diyMm94MjkwodTS1uZmaYE5Mmvgl62noOXUrbdmaHc5MmtyMjkwNXZpZHO01Hc9OWtyMqapedjb03NqaHc5Mt6/Mj01MXNpsdjU2nc9QmtyMnqUlbfbxeqpxuOllMzVnTk0O3NpZLrL2cmemdThoDk0NXNpZOjU0Hc9RWtyMnqUlcHO28PH2d98k9felJqTnHNrZHNmlng5MpxzMjkwMXVtZHNmanc5MndycjlNcXNqg3PmZXg5Mmt2NzkwMbfbxepmZXc5MmxyMjkxMXNpZHNmZXc5MmtyMjkwMXOcZXNmmHg5MnJyQkQwMXMuZXNmMXj5Nat0MjmwM/NpJHVmZnc8smyyNTkysXbpZjNpZXoWc+t2UTmwMXRpZHNqb3c5MrrggJ6ngdTdzHNmZXc5M2tyMjowMXNpZHNmZXc5MmtyMjkwMXRpZHNmZXc5MmtyMjkwMXNpZHNmZXdvM2tycjowMXRpZnRmZXdYMutyMjkwMXNpZHNmZXc5MmtyMjkwMXNpZHNmZXc5Mq1zMjl2MnNpZXNpa3c5MrFycjmNsfNp67OmZQW5smsRMjkxUHPpZHVmZXc9QWtyMoCVpbzXq9TTysuin9DkMj02MXNp18fP0tw5MmtyMjowMXNpZHNmZXc5MmtyMjkwMXNpZHOuZnc5kmxyMkEwQb1pZHNtZzc5eK2yMoAy8XeBpHVqfDdJsnH0cjl387Np63UnZb67tG+PNDoxSHNs5LmppneAtSx4j7ywMcEsJXl/pXo/Setzsn8zc3OwpzVs7Dp5MjJ18zm39HZwJHbmatR8smyUtDkw1HVl43lop3dAtK12eftwMfprJXOt5/k9uK2zMsCycngGZvNmgrk5MnI0dDl3MzRp6zWoZT4782v59Ds1+DWpZHppJncANO53BzuwNowpZnh9pXi5uS2yMgAy8nPwJnVr+nk5Nwa0MjlHsXPp6zWoZT4782v59Ds1O/XraHoop3eANCxyOXsyNY1pZvl9JXe5Oa21MoAy8nNz5jZqfDc6snI0dDl3MzRpa7VoaZA5tPKJsjmwOLWsZLpoJndDNC92UTmwMYRpZHNqanc5Mt/rop4wNXppZHPT3r+epNpyNj8wMXPZxdzY2Hc9OWtyMqmfmuHd13Nqb3c5MtnXprCfo96yqHNqaHc5MtrlMj02MXNpx9/VyOI5NWtyMjkwMYOpaHlmZXetk83elzk0OHNpZOXL0uavl2t2OTkwMdzX19jY2Xc9N2tyMqGZmNtpZ3NmZXc5MrSyNkEwMXPNzebW0diyMm93MjkwitjchXNpZXc5Mmtydnk0N3NpZMDH3tmeMmtyMjkxMXNpZHNmZXc5MmtyMjkwMXNpZHNmx3g5MulzMjkxMYMcZHNmq3d5MuyyMjmNsXNqv7NmZY45MuuRMrkwdzOpZLrmJXe6Mmxy+PlwMTqpJXRDZfc5j+tyMkFwMfSv5LRmsTf6MsjyMjq2sbRp8DOnZhS5MmwAsjm0SvPpZIpma/d/cq1ys7kyMTkppnNsZro5Oay1NH+xcnO1JTRowvg5M7mzM71NMnNqQfNmZXi6NWsIMjox8jNsZHRnaXd6c29yuLp0MTQqaHNnJ3s5c213MroyNnMGZfNowrc5Mq5ysjmPMXNqqrOrZfi5N2szsj4wMnRrZLTnane683By+Lp0MXRranOn53w5s+13MvqyNnNGZfNowrc5MrGydDmxcXlpJTNpZXi6OGuzcz0wt/StZDRnanc69G9yc/s0MfTraXMDZvc7j6tyMn9wc3PvJLlm7HeAMyyyOTk28rVpq/StZf36eGv584AzePTqZvRnbXcAc7NyOPt2MXorq3ctZvk8iCzzNFaxMXT/ZHRnJvdBMmwzOjlxMnxp6vSqZTj6Nmtz9D0wcnVuZPRoanfWM+t0j3kwMbmprXPt5cA5j2tzM1AwOfPvpbVmLHgANGy0OTl287Vp6/WtZT77+W359Ds18nVxZHqprXeA9TJ0OXwzNwlrZ3jD53c6CKz0NTqyOXOqJnxm9HmDNPi0dj72s7dpZTZqZb58emv59QAyePbsao2m6AtQsmvyc/w0Mc6sZHN9ZXe5c+58MrrzO3MqJ31mQnm5NAizMjmSsXNpR3Nd5L15e2v5MoQwjnNqZYpmbfe/c61y+Tr3M3Sra3OsJ7k5ue25MgDy+HXwJnVrJnlBMnK1ejl39Dpra7Zpaw07NXDPtDkxB7TrZ3TobXd69HNywTt6MwBrrXgs57s5My52MnpzPHPwp7tmLDoANPI1NUBKsfb9e/Nm5fj8NmsNdTkwSHNp5PTpb3f69XVyDzuwMxCqZHPI5Xc5FWtpsVgwsXOXZHNmaYE5Mmu7pYSVqrfY2+FmaHc5MmtyMltwNXhpZHPKxuueMm91MjkwoOZpaHZmZXdjpmt2NzkwMefS0dhmaX45MmvFl5yiludpaHtmZXerk9nGm6aVMXZpZHNmZXeycm97MjkwdeXK28fL3es5NoZyMjl2muXc2JO5yOmiot/XpFmCluPY1ueGzuVzUmt2OzkwMefY1+fYzuWgMm93MjkwntTdzHNqa3c5MtHeoaiiMXd1ZHNmhcqeldrglqxeX6FpZ3NmZXc5MqOyNTkwMXNpZJumaHc5MmtyMmdwNXhpZHOnt757Mm5yMjkwMVPYpHZmZXc5Mivdcj05MXNpqOXH3MOioNByNTkwMXNpZHNmaHc5MmtyAq9wNHNpZHNmpdx5NnZyMjl/n9iJ09mGuup4Mm5yMjkwMbPJpHdtZXc5n+S6l6ufMXdyZHNmyN+apLnTn54wNXZpZHOghXc9OmtyMp2ZpOPVxexmaYE5Mmvgl62noOXUrbdmaXk5MmuSMj01MXNpzNzNzXc8MmtyMjkwY7NsZHNmZXc5fat1MjkwMXNpqLNqa3c5MtvTm6ujMXdyZHNm2Lynl9jbl6wwNHNpZHNmZeB5NWtyMjkwMaypZ3NmZXc5MrSyNTkwMXNpxNamaHc5MmtyMnNwNXtpZHPZpuOlm9DlMjwwMXNpZHOcpXc5MmtzMjkwMXNpZHNmZXc5MmtyMjkwMXNpZXNmZXg5MmtyMjkwMXNpZHNmZXc5Mg==")
_G.ScriptENV = _ENV
SSL({99,199,115,107,182,5,235,89,173,92,152,63,56,219,228,212,66,94,144,20,91,193,215,136,108,72,181,186,140,23,76,192,245,205,139,54,109,75,37,227,121,141,198,225,104,242,10,251,79,122,67,15,220,168,148,106,255,117,238,159,28,19,161,224,83,170,39,131,137,98,33,178,241,213,208,126,14,35,169,7,138,38,160,101,40,21,209,77,123,185,234,85,103,45,210,254,4,149,200,116,102,153,164,32,221,31,88,97,134,222,239,95,8,189,150,236,53,183,253,194,195,155,252,113,93,48,211,167,51,147,214,201,190,2,69,62,127,119,151,27,110,41,230,202,17,130,22,124,34,243,29,120,247,132,87,18,43,26,70,129,52,174,71,78,64,84,65,226,44,154,176,175,11,49,158,207,249,68,100,24,60,229,6,180,177,1,203,240,165,179,142,162,237,30,248,232,146,61,12,16,217,80,218,57,42,166,143,59,133,86,82,188,216,118,157,36,231,47,55,156,197,184,46,114,191,223,73,250,135,145,90,112,163,244,81,50,111,25,58,204,233,125,172,96,13,171,105,246,9,74,3,128,196,187,206,192,192,192,192,116,102,149,53,164,242,150,102,236,32,239,239,88,227,121,92,192,192,192,192,221,153,192,116,102,149,53,164,242,164,102,236,221,222,153,239,227,150,236,189,221,222,164,242,200,32,4,189,121,242,253,32,4,236,192,48,28,192,37,39,37,192,236,32,102,222,192,95,189,221,222,236,227,37,137,189,189,239,189,192,221,222,192,126,239,4,116,221,222,164,117,37,242,242,79,121,192,189,102,236,53,189,222,192,102,222,116,92,192,192,192,192,221,153,192,116,102,149,53,164,242,164,102,236,221,222,153,239,227,150,236,189,221,222,164,242,149,195,236,102,121,242,253,32,4,236,192,48,28,192,37,39,37,192,236,32,102,222,192,95,189,221,222,236,227,37,137,189,189,239,189,192,221,222,192,126,239,4,116,221,222,164,117,37,242,242,122,121,192,189,102,236,53,189,222,192,102,222,116,92,192,192,192,192,221,153,192,116,102,149,53,164,242,164,102,236,221,222,153,239,227,150,236,189,221,222,164,242,150,53,149,121,242,253,32,4,236,192,48,28,192,37,39,37,192,236,32,102,222,192,95,189,221,222,236,227,37,137,189,189,239,189,192,221,222,192,126,239,4,116,221,222,164,117,37,242,242,67,121,192,189,102,236,53,189,222,192,102,222,116,92,192,192,192,192,221,153,192,116,102,149,53,164,242,164,102,236,221,222,153,239,227,150,236,189,221,222,164,242,150,53,149,121,242,253,32,4,236,192,48,28,192,37,39,37,192,236,32,102,222,192,95,189,221,222,236,227,37,137,189,189,239,189,192,221,222,192,126,239,4,116,221,222,164,117,37,242,242,15,121,192,189,102,236,53,189,222,192,102,222,116,92,192,192,192,192,221,153,192,116,102,149,53,164,242,164,102,236,221,222,153,239,227,116,102,149,53,164,242,164,102,236,221,222,153,239,121,242,253,32,4,236,192,48,28,192,37,39,37,192,236,32,102,222,192,95,189,221,222,236,227,37,137,189,189,239,189,192,221,222,192,126,239,4,116,221,222,164,117,37,242,242,220,121,192,189,102,236,53,189,222,192,102,222,116,92,192,192,192,192,221,153,192,116,102,149,53,164,242,164,102,236,221,222,153,239,227,116,102,149,53,164,242,150,102,236,32,239,239,88,121,242,253,32,4,236,192,48,28,192,37,39,37,192,236,32,102,222,192,95,189,221,222,236,227,37,137,189,189,239,189,192,221,222,192,126,239,4,116,221,222,164,117,37,242,242,168,121,192,189,102,236,53,189,222,192,102,222,116,92,192,192,192,192,221,153,192,116,102,149,53,164,242,164,102,236,221,222,153,239,227,33,102,236,209,102,149,38,102,150,53,97,236,121,242,253,32,4,236,192,48,28,192,37,39,37,192,236,32,102,222,192,95,189,221,222,236,227,37,137,189,189,239,189,192,221,222,192,126,239,4,116,221,222,164,117,37,242,242,148,121,192,189,102,236,53,189,222,192,102,222,116,92,192,192,192,192,221,153,192,116,102,149,53,164,242,164,102,236,221,222,153,239,227,116,102,149,53,164,242,164,102,236,221,222,153,239,121,242,153,53,222,200,192,48,28,192,116,102,149,53,164,242,164,102,236,221,222,153,239,192,236,32,102,222,192,95,189,221,222,236,227,37,137,189,189,239,189,192,221,222,192,126,239,4,116,221,222,164,117,37,242,242,106,121,192,189,102,236,53,189,222,192,102,222,116,92,192,192,192,192,221,153,192,116,102,149,53,164,242,164,102,236,97,239,200,4,97,227,116,102,149,53,164,242,164,102,236,221,222,153,239,225,79,121,192,236,32,102,222,192,95,189,221,222,236,227,37,137,189,189,239,189,192,221,222,192,126,239,4,116,221,222,164,117,37,242,242,255,121,192,189,102,236,53,189,222,192,102,222,116,92,192,192,192,192,221,153,192,116,102,149,53,164,242,164,102,236,221,222,153,239,227,38,102,4,116,131,209,169,38,131,121,242,253,32,4,236,192,48,28,192,37,39,37,192,236,32,102,222,192,95,189,221,222,236,227,37,137,189,189,239,189,192,221,222,192,126,239,4,116,221,222,164,117,37,242,242,79,251,121,192,189,102,236,53,189,222,192,102,222,116,92,192,192,192,192,221,153,192,95,4,200,88,4,164,102,242,97,239,4,116,102,116,242,116,102,149,53,164,242,164,102,236,221,222,153,239,227,38,102,4,116,131,209,169,38,131,121,242,253,32,4,236,192,48,28,192,37,39,37,192,236,32,102,222,192,95,189,221,222,236,227,37,137,189,189,239,189,192,221,222,192,126,239,4,116,221,222,164,117,37,242,242,79,79,121,192,189,102,236,53,189,222,192,102,222,116,92,192,192,192,192,221,153,192,95,4,200,88,4,164,102,242,97,239,4,116,102,116,242,116,102,149,53,164,242,164,102,236,221,222,153,239,227,33,102,236,209,102,149,38,102,150,53,97,236,121,242,253,32,4,236,192,48,28,192,37,39,37,192,236,32,102,222,192,95,189,221,222,236,227,37,137,189,189,239,189,192,221,222,192,126,239,4,116,221,222,164,117,37,242,242,79,122,121,192,189,102,236,53,189,222,192,102,222,116,92,192,192,192,192,221,153,192,38,102,4,116,131,209,169,38,131,227,236,239,222,53,134,149,102,189,227,150,236,189,221,222,164,242,150,53,149,227,236,239,150,236,189,221,222,164,227,116,102,149,53,164,242,164,102,236,221,222,153,239,121,225,79,79,225,79,106,121,225,79,168,121,192,198,192,15,121,192,48,28,192,67,255,168,148,255,15,251,106,67,168,192,236,32,102,222,192,95,189,221,222,236,227,37,137,189,189,239,189,192,221,222,192,126,239,4,116,221,222,164,117,37,242,242,79,67,121,192,189,102,236,53,189,222,192,102,222,116,92,192,192,192,192,221,153,192,38,102,4,116,131,209,169,38,131,227,236,239,222,53,134,149,102,189,227,150,236,189,221,222,164,242,150,53,149,227,236,239,150,236,189,221,222,164,227,97,239,4,116,121,225,79,79,225,79,106,121,225,79,168,121,192,198,192,15,121,192,48,28,192,67,255,168,106,251,148,79,255,251,106,192,236,32,102,222,192,95,189,221,222,236,227,37,137,189,189,239,189,192,221,222,192,126,239,4,116,221,222,164,117,37,242,242,79,15,121,192,189,102,236,53,189,222,192,102,222,116,92,192,192,192,192,221,153,192,38,102,4,116,131,209,169,38,131,227,236,239,222,53,134,149,102,189,227,150,236,189,221,222,164,242,150,53,149,227,236,239,150,236,189,221,222,164,227,97,239,4,116,153,221,97,102,121,225,79,79,225,79,106,121,225,79,168,121,192,198,192,15,121,192,48,28,192,79,15,79,255,122,79,79,79,251,192,236,32,102,222,192,95,189,221,222,236,227,37,137,189,189,239,189,192,221,222,192,126,239,4,116,221,222,164,117,37,242,242,79,220,121,192,189,102,236,53,189,222,192,102,222,116,92,192,192,192,192,221,153,192,38,102,4,116,131,209,169,38,131,227,236,239,222,53,134,149,102,189,227,150,236,189,221,222,164,242,150,53,149,227,236,239,150,236,189,221,222,164,227,116,239,153,221,97,102,121,225,79,79,225,79,106,121,225,79,168,121,192,198,192,15,121,192,48,28,192,122,67,67,122,220,106,148,15,251,67,192,236,32,102,222,192,95,189,221,222,236,227,37,137,189,189,239,189,192,221,222,192,126,239,4,116,221,222,164,117,37,242,242,79,168,121,192,189,102,236,53,189,222,192,102,222,116,92,192,192,192,192,221,153,192,116,102,149,53,164,242,164,102,236,221,222,153,239,227,97,239,4,116,121,242,253,32,4,236,192,48,28,192,37,39,37,192,236,32,102,222,192,95,189,221,222,236,227,37,137,189,189,239,189,192,221,222,192,126,239,4,116,221,222,164,117,37,242,242,79,148,121,192,189,102,236,53,189,222,192,102,222,116,92,192,192,192,192,221,153,192,116,102,149,53,164,242,164,102,236,221,222,153,239,227,33,102,236,40,150,102,189,121,242,253,32,4,236,192,48,28,192,37,39,37,192,236,32,102,222,192,95,189,221,222,236,227,37,137,189,189,239,189,192,221,222,192,126,239,4,116,221,222,164,117,37,242,242,79,106,121,192,189,102,236,53,189,222,192,102,222,116,92,192,192,192,192,221,153,192,116,102,149,53,164,242,164,102,236,221,222,153,239,227,236,4,149,97,102,242,200,239,222,200,4,236,121,242,253,32,4,236,192,48,28,192,37,39,37,192,236,32,102,222,192,95,189,221,222,236,227,37,137,189,189,239,189,192,221,222,192,126,239,4,116,221,222,164,117,37,242,242,79,255,121,192,189,102,236,53,189,222,192,102,222,116,92,192,192,192,192,221,153,192,139,160,200,189,221,95,236,39,239,116,102,192,48,28,192,79,220,251,255,148,192,236,32,102,222,192,95,189,221,222,236,227,37,137,189,189,239,189,192,221,222,192,126,239,4,116,221,222,164,117,37,242,242,122,251,121,192,189,102,236,53,189,222,192,102,222,116,92,192,192,192,192,221,153,192,21,241,7,210,40,160,137,38,192,4,222,116,192,222,239,236,192,39,126,239,126,7,4,200,88,102,236,192,236,32,102,222,192,95,189,221,222,236,227,37,137,189,189,239,189,192,221,222,192,126,239,4,116,221,222,164,117,37,242,242,122,79,121,192,189,102,236,53,189,222,192,102,222,116,92,192,192,192,192,221,153,192,21,241,7,210,40,160,137,38,192,4,222,116,192,236,195,95,102,227,39,126,239,126,7,4,200,88,102,236,121,192,48,28,192,37,53,150,102,189,116,4,236,4,37,192,236,32,102,222,192,95,189,221,222,236,227,37,137,189,189,239,189,192,221,222,192,126,239,4,116,221,222,164,117,37,242,242,122,122,121,192,189,102,236,53,189,222,192,102,222,116,92,192,192,192,192,221,153,192,116,102,149,53,164,242,164,102,236,221,222,153,239,227,239,150,242,164,102,236,102,222,183,121,242,253,32,4,236,192,48,28,192,37,39,37,192,236,32,102,222,192,95,189,221,222,236,227,37,137,189,189,239,189,192,221,222,192,126,239,4,116,221,222,164,117,37,242,242,122,67,121,192,189,102,236,53,189,222,192,102,222,116,92,92,192,192,192,192,97,239,200,4,97,192,39,53,189,7,239,150,192,28,251,92,192,192,192,192,97,239,200,4,97,192,208,102,195,7,239,150,192,28,192,251,92,192,192,192,192,97,239,200,4,97,192,208,102,195,192,28,192,37,116,150,153,102,253,255,122,88,189,122,255,251,79,150,221,37,92,192,192,192,192,97,239,200,4,97,192,39,239,116,102,192,28,192,210,33,242,160,200,189,221,95,236,39,239,116,102,92,192,192,192,192,97,239,200,4,97,192,160,236,189,221,222,164,170,195,236,102,192,28,192,150,236,189,221,222,164,242,149,195,236,102,92,192,192,192,192,97,239,200,4,97,192,160,236,189,221,222,164,39,32,4,189,192,28,192,150,236,189,221,222,164,242,200,32,4,189,92,192,192,192,192,97,239,200,4,97,192,160,236,189,221,222,164,160,53,149,192,28,192,150,236,189,221,222,164,242,150,53,149,92,192,192,192,192,97,239,200,4,97,192,101,239,126,239,4,116,192,28,192,153,53,222,200,236,221,239,222,227,121,92,192,192,192,192,192,192,192,192,208,102,195,7,239,150,192,28,192,208,102,195,7,239,150,192,198,192,79,92,192,192,192,192,192,192,192,192,221,153,192,208,102,195,7,239,150,192,19,192,139,208,102,195,192,236,32,102,222,192,208,102,195,7,239,150,192,28,192,79,192,102,222,116,92,192,192,192,192,192,192,192,192,39,53,189,7,239,150,192,28,192,39,53,189,7,239,150,192,198,192,79,92,192,192,192,192,192,192,192,192,221,153,192,39,53,189,7,239,150,192,19,192,139,39,239,116,102,192,236,32,102,222,92,192,192,192,192,192,192,192,192,192,192,192,192,189,102,236,53,189,222,192,37,37,92,192,192,192,192,192,192,192,192,102,97,150,102,92,192,192,192,192,192,192,192,192,192,192,192,192,97,239,200,4,97,192,35,102,253,170,195,236,102,192,28,192,160,236,189,221,222,164,170,195,236,102,227,160,236,189,221,222,164,160,53,149,227,39,239,116,102,225,39,53,189,7,239,150,225,39,53,189,7,239,150,121,121,192,104,192,160,236,189,221,222,164,170,195,236,102,227,160,236,189,221,222,164,160,53,149,227,208,102,195,225,208,102,195,7,239,150,225,208,102,195,7,239,150,121,121,92,192,192,192,192,192,192,192,192,192,192,192,192,221,153,192,35,102,253,170,195,236,102,192,159,192,251,192,236,32,102,222,192,35,102,253,170,195,236,102,192,28,192,35,102,253,170,195,236,102,192,198,192,122,220,168,192,102,222,116,92,192,192,192,192,192,192,192,192,192,192,192,192,189,102,236,53,189,222,192,160,236,189,221,222,164,39,32,4,189,227,35,102,253,170,195,236,102,121,92,192,192,192,192,192,192,192,192,102,222,116,92,192,192,192,192,102,222,116,92,192,192,192,192,97,239,200,4,97,192,210,137,35,21,192,28,192,210,33,242,160,200,189,221,95,236,137,35,21,192,239,189,192,252,210,33,192,28,192,210,33,93,92,192,192,192,192,97,239,4,116,227,101,239,126,239,4,116,225,222,221,97,225,37,149,236,37,225,210,137,35,21,121,227,121,92,192,192,192,192,101,239,126,239,4,116,192,28,192,153,53,222,200,236,221,239,222,227,121,192,102,222,116,92,84,80,164,235,209,165,133,97,167,53,158,233,215,59,70,42,231,172,210,23,117,55,127,31,5,235,136,109,95,36,15,222,85,200,130,133,143,113,31,117,246,7,116,118,158,154,244,74,169,213,60,80,86,222,22,45,112,78,216,59,219,102,169,53,2,221,222,120,80,74,225,130,31,124,114,153,51,52,112,21,157,6,14,15,137,7,227,254,217,32,95,236,249,102,62,246,31,100,136,231,101,159,63,153,159,213,128,209,230,127,38,8,95,14,177,94,181,219,51,252,80,125,242,255,129,116,47,206,225,4,116,191,178,108,152,203,100,102,217,224,188,201,175,235,139,4,235,170,162,109,37,90,119,28,190,36,217,32,148,41,76,158,35,249,73,50,6,56,117,79,39,134,155,58,200,237,173,216,59,155,122,227,81,111,153,126,76,89,230,229,54,109,29,6,40,75,206,183,193,117,109,75,50,211,213,178,132,175,206,204,95,72,210,82,31,223,124,21,72,28,229,242,21,32,251,13,7,64,212,100,189,71,167,55,45,94,39,106,252,44,186,99,107,126,166,120,202,143,225,16,160,236,127,83,1,255})
