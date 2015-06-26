--[[
Ralphlol's Utility Suite
Updated 6/25/2015
Version 1.06
]]

function Print(msg) print("<font color=\"#A51842\">Ralphlol's Utility Suite:  </font><font color=\"#FFFFFF\">"..msg) end

function OnLoad()
    local ToUpdate = {}
    ToUpdate.Version = 1.06
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
	if p.header == 11 then	
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

assert(load(Base64Decode("G0x1YVIAAQQEBAgAGZMNChoKAAAAAAAAAAAAAQIKAAAABgBAAEFAAAAdQAABBkBAAGUAAAAKQACBBkBAAGVAAAAKQICBHwCAAAQAAAAEBgAAAGNsYXNzAAQNAAAAU2NyaXB0U3RhdHVzAAQHAAAAX19pbml0AAQLAAAAU2VuZFVwZGF0ZQACAAAAAgAAAAgAAAACAAotAAAAhkBAAMaAQAAGwUAABwFBAkFBAQAdgQABRsFAAEcBwQKBgQEAXYEAAYbBQACHAUEDwcEBAJ2BAAHGwUAAxwHBAwECAgDdgQABBsJAAAcCQQRBQgIAHYIAARYBAgLdAAABnYAAAAqAAIAKQACFhgBDAMHAAgCdgAABCoCAhQqAw4aGAEQAx8BCAMfAwwHdAIAAnYAAAAqAgIeMQEQAAYEEAJ1AgAGGwEQA5QAAAJ1AAAEfAIAAFAAAAAQFAAAAaHdpZAAEDQAAAEJhc2U2NEVuY29kZQAECQAAAHRvc3RyaW5nAAQDAAAAb3MABAcAAABnZXRlbnYABBUAAABQUk9DRVNTT1JfSURFTlRJRklFUgAECQAAAFVTRVJOQU1FAAQNAAAAQ09NUFVURVJOQU1FAAQQAAAAUFJPQ0VTU09SX0xFVkVMAAQTAAAAUFJPQ0VTU09SX1JFVklTSU9OAAQEAAAAS2V5AAQHAAAAc29ja2V0AAQIAAAAcmVxdWlyZQAECgAAAGdhbWVTdGF0ZQAABAQAAAB0Y3AABAcAAABhc3NlcnQABAsAAABTZW5kVXBkYXRlAAMAAAAAAADwPwQUAAAAQWRkQnVnc3BsYXRDYWxsYmFjawABAAAACAAAAAgAAAAAAAMFAAAABQAAAAwAQACBQAAAHUCAAR8AgAACAAAABAsAAABTZW5kVXBkYXRlAAMAAAAAAAAAQAAAAAABAAAAAQAQAAAAQG9iZnVzY2F0ZWQubHVhAAUAAAAIAAAACAAAAAgAAAAIAAAACAAAAAAAAAABAAAABQAAAHNlbGYAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQAtAAAAAwAAAAMAAAAEAAAABAAAAAQAAAAEAAAABAAAAAQAAAAEAAAABAAAAAUAAAAFAAAABQAAAAUAAAAFAAAABQAAAAUAAAAFAAAABgAAAAYAAAAGAAAABgAAAAUAAAADAAAAAwAAAAYAAAAGAAAABgAAAAYAAAAGAAAABgAAAAYAAAAHAAAABwAAAAcAAAAHAAAABwAAAAcAAAAHAAAABwAAAAcAAAAIAAAACAAAAAgAAAAIAAAAAgAAAAUAAABzZWxmAAAAAAAtAAAAAgAAAGEAAAAAAC0AAAABAAAABQAAAF9FTlYACQAAAA4AAAACAA0XAAAAhwBAAIxAQAEBgQAAQcEAAJ1AAAKHAEAAjABBAQFBAQBHgUEAgcEBAMcBQgABwgEAQAKAAIHCAQDGQkIAx4LCBQHDAgAWAQMCnUCAAYcAQACMAEMBnUAAAR8AgAANAAAABAQAAAB0Y3AABAgAAABjb25uZWN0AAQRAAAAc2NyaXB0c3RhdHVzLm5ldAADAAAAAAAAVEAEBQAAAHNlbmQABAsAAABHRVQgL3N5bmMtAAQEAAAAS2V5AAQCAAAALQAEBQAAAGh3aWQABAcAAABteUhlcm8ABAkAAABjaGFyTmFtZQAEJgAAACBIVFRQLzEuMA0KSG9zdDogc2NyaXB0c3RhdHVzLm5ldA0KDQoABAYAAABjbG9zZQAAAAAAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQAXAAAACgAAAAoAAAAKAAAACgAAAAoAAAALAAAACwAAAAsAAAALAAAADAAAAAwAAAANAAAADQAAAA0AAAAOAAAADgAAAA4AAAAOAAAACwAAAA4AAAAOAAAADgAAAA4AAAACAAAABQAAAHNlbGYAAAAAABcAAAACAAAAYQAAAAAAFwAAAAEAAAAFAAAAX0VOVgABAAAAAQAQAAAAQG9iZnVzY2F0ZWQubHVhAAoAAAABAAAAAQAAAAEAAAACAAAACAAAAAIAAAAJAAAADgAAAAkAAAAOAAAAAAAAAAEAAAAFAAAAX0VOVgA="), nil, "bt", _ENV))() ScriptStatus("QDGFCLIIKGE") 
--------------------------------------------------------------------------------------------
_G.ScriptCode = Base64Decode("gbDcyYY2azl9bHJ0kshEg39vM2ZkZ2g0Nmo1enH5dXk1XHllZTszZeV/t3V5keroeT1qtrRzZ2RmsWRnaLr2qjVeqGp0A/U3+wrlMzNt5fm5wHl0anD5Ne3b9GhnbObm5+0odDZPNXpo9DR5udy5ZmU75uTrDbQ3aj35aO//eTU3geXluPGkaGi+ti27A2gu+wO1+wHvZfi87+U9wT35dPDu+XpqvfStaCrmq2QuaPo3cLa+aHG1vzd9+qplerQrZwQ4QXn+q68Hvyt9w/KorPbwJa/5vnezxwMpswcDdoEN7yZ9++6os8rAK4AQ8qvAEb/4xf7vdLP+8SmB0fR2xwT0NcfSwbq0A730tAQDeIUZ/iu4Gr+rh9byKLUJ8KW5DL73vNoDqb0aA/aKIO+mh9vvJs3gv7rJFPI6ihXAdb4T7ie8EfGpi+T09tAX9LXR5cE6vRa9p70Z8vWPHb+6wh7+Oo/sA6bA6fAlwh++d8btAynGLQN2lDPvJpDu76bX87860ifyupQowPXHJu6nxiTxKZT39HbaKvQ12vjBuscpvfTHKgN4mD/+K8tAv6ua/PIoyC/wpcwyvvfPAAOp0EAD9p1G76aaNO4ozwPAq51J8ivcSr944jfv9M838ameCvT24z30teQLwTrQPL100T0D+KFS/qvVU78row/yqNJC8CXVRb532RMDKdlTAzYnVu+mIwjvJukYv3rlTPK6JkXAtVc67ifXR/FpJhb0dmtB9PVqBsH610m951RG8vUoQb96Vzn++psdA+Y7GfDly0++tz4cA+nMXAO2CWHv5pMc7+ZJIL962lTyegtUwDXMUu5nOk/xaZYi9DZLVPR12SLBejVSvbRKSgO4Clv+60tVv+sJCPLoxUvw5ThJvrdJDwPpOUYDNhxd72aIRu5oSwzAawhJ8mtVXL84SkPvNEU68WkDBPR28Fb0NfAkwbrdVb303VYDeK5r/ivhbL+rsCjyKN5b8KXiXr735SwDqeZsA/azcu+msC3vJvYyv7ryZvI6s2fANWc07qdlKfHpM/P09ngdK3W5NcE65jD0p6Rn8vW3Lfb6qGr+OrbyOialM/Al6Bv1N6s1AynrPTp2eHnvJrT0Jua6N7869SMpOnZqwPXpGCVnqGTxKbX9K3a7aPQ1+vT4+qdlvfTmHDr4d3n+K+ko9mt5NGmpp2bwZelr9betNQPpaHc69np5Zmd3Zu5o6jf3q3l58utwfPa4vWVm9apk8Wm2OSs2vmj09XM4+LqqZTR1qWUDOLd8NSuseb/rLjcp6KlmZyasaL437Dg6abB0AzY1fCameTNmp783v3r2bSl6eWrANWRqJeesZGiqeTb0NvtrKzW/NcF6X2j0J6lnafZ5ar966m01ung3A2ZdNiclrWi+9+sBA+lnODo2fXnvJrTv7+Z06/Z6uWryOrY0wLVhKSXnqWTxKbXw9LZwGiv1vzXBOuYtvTRiJTq4enn+K+kxv2sx5CnoqGbwJeguvjdj8zpprXQD9rgv72YqFCUoqjTAKyt8KSu0eb+4Z2jv9Fth8ekgKyt2u2j0NW04+LqlZb20T2gD+Ch0/utQbPYrdzTy6Fpp8GVVZ763Xy4DaVZlOnZ4ee/mJzbvZmM1v/pnYfJ6HVnAdV4U7udTCfGpKdP0tmT99LVt4MH6Tgi9p1cC8rUd/b96XhP+eiLYA2ZazPBlUvm+N17cA2lTEwM2KhDvZhrCJua7N7/6Um0p+nVqwLU2au7nQmDx6QAqKza7aPT1Uzj4eqVlvbQvaAO4DXP+6zBr9ut3NPJoQmnwZbVnvjdGLQNpNmQ6Nnh572YNae5osjLAaw1v8ms8Z7+4VhHvtDMI8ekP0vS2RPz09VLfwfouB720PP8DuPwL/mtFIb9rA9TyaD/+8GUy+L43Q9sDaTMSAzYOD+9m+sFt5frEuzq0ail6fGpb9mln7mfoZ+ipezZPNntocjR6OLj6rGUYp2ZncPQ3bbY6r2pZ+jc3gSVmNudlr2gZ92w1gShrd/p2f3nr5jQzJubBN9K6dGvp+n1qvLVpZyUnrmSMajc29Db7a+v1wTW9+mZl9DSuZZ55OHn+a+p8tut+NO7oZWYnpbBoWbhtNQNp7Hf6tn956+Y0ZiXosTRbLDh58mv2fLa4wWXrtGdkTGk4NvT2euyJdPk1XnplZTc1ZWV5nTV9fWpoeaivpJnV0MnZZmh2aDQ2sZrtrdjZ5q5/3tfUmKZlaYQ3NXnmz8vaodZ6psneZGprZGdoiJ/NoHlsdnR5NZzJ18qXz8fb0aOkajmDaGp03Z6p3sjZnNXSZ2xLNmo1ztjO1e2afOfK0pyY2KniqZrc6NPX5zVuOzRoZ6jYx9tnbEY2ajW92svrvJ6p3NHKgZjd2cWtoXl4dmh5Na6old+qzdjJ0MyaNDp4NXloy9ftnq3et8qWx9DT2zQ6djV5aNzZ3Jaj5bnOoMvXZ2w7Nmo1683N1eWhN3z//szM/v6YdzmEdGpo6JnTpKbNysXS0mRqAs3PA84Seap4jDU3edTJnKHXytyYoeXd19jrpOCbmGhql5mZl5qbQ3ZuRHloaubemJjl0c6g1tbW3pmaajgTAQMNEs5SuWlxM2Zk2t2km9yn3svL4OU1O39lZTOVztmsaTV9e2poeaHdnp3O22RqbWRnaKap0p7f3Gp4fjU3ecfGoZdlaX43NXnW4tfrNW4+NGhnraqo3dvNpzZtNXloanR5NTd8ZWUzZmRH13Q5ajV5aGp0aXQ6eWVlM2ZE0qg3Nmo1eWhqdLk4N3llZTOT1KV8NzV5dGpogXVtNjRoZ2TG0aRqaDQ2ajV5eKp3eTU3eWVFoXNoZXk3NXl0fqh8NWo2NGhHzqZpZGdoNDZqTblranR5NTfZ06U2ZmRnaDQ2hnV8aGp0eTWX46VoM2ZkZ2g0Vqo4eWhqdHn1prloZTMzZWV5WXV8dGpoeTUqoXRrZ2RmZmRnjHQ5ajV5aGq06HU6eWVlMzNli7k6NXl0ami5oKo5NGhnZGZmjKdrNDZqNXko2LR8NTd5ZWUzkKRqaDQ2ajU50qp3eTU3eWVlX6ZnZ2g0Nmp156htdHk1N3llk3M2ZWV5NzW53qpreTVqNjRol6RpZmRnaDTW2XV8aGp0eTU3qqVoMzNlZXnXoLl3amh5NWo2ZqhqZGZmZGeIo3ZtNXloanR5aHd8ZWUzZmSH03Q5ajV5aGp0rXU6eWVlM2YE1ag3Nmo1eWhqqbk4N3llZTPTz6V8NzV5dGpor3VtNjRoZ2SG1KRqaDQ2ajV5n6p3eTU3eWWFnXNoZXk3NXl0oqh8NWo2NGjn06ZpZGdoNDZqbrlranR5NTf50KU2ZmRnaDQ2pHV8aGp0eTU36KVoM2ZkZ2g0cao4eWhqdHk1orloZTMzZWV5c3V8dGpoeTXqpHRrZ2RmZmRnpXQ5ajV5aGr043U6eWVlMzNlo7k6NXl0amh5o6o5NGhnZGZmo6drNDZqNXlo1LR8NTd5ZWUzpqRqaDQ2ajVZz6p3eTU3eWXlc6ZnZ2g0NmoV3KhtdHk1N3llpnM2ZWV5NzXZ26preTVqNjToqKRpZmRnaDSWzXV8aGp0eTU3u6VoMzNlZXkXm7l3amh5NWq2dqhqZGZmZGdIlnZtNXloanR5eHd8ZWUzZmTHznQ5ajV5aGr0vHU6eWVlM2bEyag3Nmo1eWhquLk4N3llZTPzzKV8NzV5dGrovXVtNjRoZ2QmyaRqaDQ2ajV5rap3eTU3eWWlmnNoZXk3NXn0r6h8NWo2NGinx6ZpZGdoNDZqe7lranR5NTc5y6U2ZmRnaDS2sHV8aGp0eTX326VoM2ZkZ2g0fao4eWhqdHl1nbloZTMzZWX5fnV8dGpoeTWqmHRrZ2RmZmRnsHQ5ajV5aGoU4HU6eWVlMzPlrbk6NXl0amgZmKo5NGhnZGZmradrNDZqNXmI0bR8NTd5ZWWzr6RqaDQ2ajWZy6p3eTU3eWVlfaZnZ2g0NmrV36htdHk1N3nlr3M2ZWV5NzUZ1qpreTVqNjRosqRpZmRnaDRW0HV8aGp0eTW3xKVoMzNlZXlXl7l3amh5NWo2gKhqZGZmZGfom3ZtNXloanT5gXd8ZWUzZmTny3Q5ajV5aGp0xnU6eWVlM2Zkzqg3Nmo1eWjqwbk4N3llZTMzyKV8NzV5dGpox3VtNjRoZ2TmzKRqaDQ2ajX5tqp3eTU3eWXllXNoZXk3NXl0uah8NWo2NGhnyqZpZGdoNDbqhLlranR5NTd5x6U2ZmRnaDQ2unV8aGp0eTX32KVoM2ZkZ2h0hqo4eWhqdHn1jrloZTMzZWX5h3V8dGpoeTUqlHRrZ2RmZmQnuHQ5ajV5aGo0z3U6eWVlMzNltrk6NXl0amg5kqo5NGhnZGamtadrNDZqNXkov7R8NTd5ZWWzt6RqaDQ2ajU5xKp3eTU3eWUlhKZnZ2g0Nmr1zahtdHk1N3llt3M2ZWV5NzX506preTVqNjSouaRpZmRnaDS2wXV8aGp0eTW3y6VoMzNlZXm3k7l3amh5NWr2hqhqZGZmZGfoinZtNXloanR5iHd8ZWUzZmTnxXQ5ajV5aGq0zHU6eWVlM2bkvKg3Nmo1eWjqx7k4N3llZTOzwaV8NzV5dGoozHVtNjRoZ2TmuqRqaDQ2ajV5vKp3eTU3eWWlknNoZXk3NXm0vqh8NWo2NGinu6ZpZGdoNDaqk7lranR5NTe5u6U2ZmRnaDQ2v3V8aGp0eTV31qVoM2ZkZ2h0i6o4eWhqdHl1k7loZTMzZWV5jXV8dGpoeTVqlXRrZ2RmZmRnv3Q5ajV5aGp013U6eWVlMzNlwrk6NXl0amh5kao5NGhnZGZmvKdrNDZqNXmowrR8NTd5ZWWzvqRqaDQ2ajU5wKp3eTU3eWVljKZnZ2g0Nmp10qhtdHk1N3nlvnM2ZWV5NzU5zapreTVqNjRowaRpZmRnaDR2xHV8aGp0eTW306VoMzNlZXn3j7l3amh5NWo2j6hqZGZmZGeoj3ZtNXloanT5kHd8ZWUzZmQnw3Q5ajV5aGp02XU6eWVlM2ZE1Kg3Nmo1eWiK1Lk4N3llZTMTzqV8NzV5dGqo2XVtNjRoZ2TG06RqaDQ2ajXZyKp3eTU3eWXFnHNoZXk3NXn0yqh8NWo2NGhH0KZpZGdoNDYKlblranR5NTdZzaU2ZmRnaDT2ynV8aGp0eTWX5aVoM2ZkZ2gUlqo4eWhqdHmVn7loZTMzZWV5mHV8dGpoeTUqo3RrZ2RmZmSHyXQ5ajV5aGo04nU6eWVlMzOlxrk6NXl0ami5oqo5NGhnZGbGxadrNDZqNXmo07R8NTd5ZWWzx6RqaDQ2ajU51Kp3eTU3eWUFlKZnZ2g0Nmr14ahtdHk1N3klxnM2ZWV5NzW54KpreTVqNjRIyKRpZmRnaDR20nV8aGp0eTXX5qVoMzNlZXnXnrl3amh5NWpWoahqZGZmZGeInXZtNXloanQZoXd8ZWUzZmQH0HQ5ajV5aGqU5XU6eWVlM2aEz6g3Nmo1eWjq4bk4N3llZTOzzqV8NzV5dGpo5nVtNjRoZ2Rmz6RqaDQ2ajX51Kp3eTU3eWXlm3NoZXk3NXl01qh8NWo2NGhnzKZpZGdoNDZqmblranR5NTdZyqU2ZmRnaDRWznV8aGp0eTV33aVoM2ZkZ2iUm6o4eWhqdHmVm7loZTMzZWX5m3V8dGpoeTVKmnRrZ2RmZmQHzHQ5ajV5aGo03XU6eWVlMzNlyrk6NXl0amg5mqo5NGhnZGaGyadrNDZqNXmoz7R8NTd5ZWWzy6RqaDQ2ajUZzap4hDU3ebfKlty0yMufm941fXpqdHl8nO2o0aKmytjthaTty8vU5TVuRTRoZ6jYx9uo2peEz63ttODgeTk/eWVld6XG3LqpmHl4emh5Ncukm9TMpsva28zNonfcmHlscHR5NZrlxtimZmhuaDQ2vZrc2s/oeTk+eWVlksXN1dGoNm46eWhqwd6jrHlpbTMzZdfapYni4c9ofT9qNjS3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dDo4Pnlm6Tkzwuh5OTV89HCuvH1qvPerZyrprmQuK/w9azmCaKp4eTq4vW5lEDZlZxa6NXk7bSx8PK77N6/rKWnn6HBo+jqyNXptcXS6Oj555mo6ZkHraDY5b7V5xa10fXv6wmXsNipnLqv5OXG5PmuxuDo3fn0vbbR3b2WUOjV5i6po+RGuNjp/Z2XmLGivaDQ76jq5bep5+ro9eULpMzXCqPk6e7y8au48eGr9tzJpZSpwZD1ruD0HuHlpMXc9OD69Kmh66ilqtrj/crb9cWo6fX03empsM6dpbmi1O3E1Vuxqdnw6t3nCqDM3fOWLt3u8v2rvvPZsvTesbiupJ2Yuq/k9cXk6anH4vj1+vSZnejcvbcZ7ORD1rnJ5+y6BNGlsa2anaW5otTtxNTptcXRWubd7Zmo/ZqusKTa2b7V8xa10fnt6wWXr9qlkLuv+OGt5hWhAd/081PxlZvp2JmdAOvmAe64pezyuezyvqyVoregscIK6Mz367HN0lDg3eXylM7NBqXk9THl16i59fWo2OehspGvmaejtOjZHuXlqbXn5NZS8ZWl5qaxn7vd5avv8sGo7PP0+emluM6ZoZ221enM1Vmtqdha4N3ksqPQ1LGg9PgL8QHFvvfZsPXitb6uqJ2au7Pk+t/lFcOv4gjVSfGVlSnNl5VV7NX+Lamn5+25+NGhs5GumaedttbtwNVbsanZ8Ord5wqgzamoqqzR9bfl8he10eo13vWt8c2zkbWuBNrD4vGjw98E1vjytbPQ2bmV5OzV+ta5xedJtNjbF6mRm56d0aPs5rjlH6zd7gHl8fXPpgDurKcY3kH10an/5Nep8+LVnv6pmZH5oNbawOcFo6nj5Ovd95Wo062pnxbg2bFK8aG3W+TU3XKUPsoVk52hsNmo1fXFqdHmCmOLTspih2mV9PjV5dNzN3JbWojRsbmRmZsnVyZaizzV9bmp0eaWY4tfYMzdzZXk3ltzo097eh8+ZldTT12ZqaWdoNKvYnu1obn55NTfnytmq1dbSsXg2bjx5aGrn7Zap7bllN25kZ2iqn92e29TPdHw1N3llZTNXpWmANzV5ys/L7aTcNjhsZ2Rm1tPaaDhAajV5zNPm3pir4tTTMzdwZXk3o+jm18nlnuSbmGhrZ2ZmZNTbNDpzNXlo3uPsqani08wzamZnaDSuajmBaGp0pmZlnK6zd2Zocmg0NrGa7bXT4uKimOllaUEzZWXQpqfl2L7XzJjcm5nWZ2hyZmRnrGd6wou+q77Dy2g3fWdlMzPeZX05NXl05Gh9Omo2NM3VyLpmaGpoNDbZqHlscHR5NZrl1MieZmdnaDQ2ajV5aG10eTU3eeWec2lkZ2g0NkqkuWxzdHk1hue4yKWYytN5O0F5dGqv3qmun6fcyNLJy2RqaDQ2ajU5yqp4fTU3ebesdTNpcHk3Nb3my9/NmuKqZ6xnaG1mZGfbqKjTo+Bobnt5NTff1Negx9hnbDk2ajWelpvaeTg3eWVlM2ZUpms0Nmo1eWiotH1BN3llqaWU3KjiqZjl2ZxofURqNjTK1tnUys3Vz4aXzp7u22p3eTU3eWVlM3Npank3NefV1815OXc2NGiHtsvJxdPUVInapO1obXR5NTd5Zd5zamxnaDR63JbwqdzXeTg3eWVlM9Lkp2w5Nmo1urqxtnk4N3llZTNzuKV9TjV5dIq465rOn5fczMiGuMnKyaCiinbrzct0fDU3eWVlM0elaHk3NXl0aqC5OXM2NGir1sfduMzgqDZtNXloanR5Znd8EA/dEA4RbnQ6cDV5aM3j5aSpeWVlM2ZmZ2g0Nmo2eWhqdHk1N3llZTMzZWV5NzXedGpo6TVqNjtoealmZmRCqDQ2gTV56Ct0eTX9+qVl+vQlaHo5Nnm67Kh5fKz3OO7ppGbt5qht+riqNUAqK3mI+Df9dWg2aUHpaDXT7DV6+Oz2/ZI5eWZCtGZkbyi1tjC2uWgx9Ts4Bjpm6Tl1pWVJOLd8fCrp+QQq+DUzaGRmZ2ZqaHq4qjXA6ix4yHc5/eunczOy5/s7u7u0aok7Ouo8d6tnqumpZO3rdDbx+LxvKnf5OtT8ZWbC6edo9bc5avV86Gp6/XU3gGmpO6Zo521Rumo2iGzudYc5O3rCaDM1guh5N4p89G21vPlwvLesZyspqmpubHk8B7j5aTT1/DtX+17kOXWqZbk5tXz0bGh7Eay2Nn9nZOYn5mxoUXhqN5ho6nSQNTd5aGUzZmRnKKZ2bj15aGrl7paj4tneM2ppZ2g0o8up4WhueHk1N+bG3TM2ZWV5NzV5lKpsfzVqNprU1tPYZmhraDQ2zprgaG55eTU32tjOoTNoZXk3NXl0aqh8NWo2NGjnyqZqZ2doNKbTNXzZp35Q2KdmpGgzZmRnaDQ2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ZGdoppvNluXUanh/NTd51dec1NhnbDw2ajXv0d3d26GceWlvM2Zk1c2ordmn5LGudH07N3lltaWc09l5O095dGqI4qiKqJnLyNDSz9LOllSCy6jtiN3Z3qNXeWlsMzNly+ipotroamx+NWo2WZaYymZqcmdoNFbdmtzX2NjsVZjg1JMzanJnaDSXzani3s/G3piY5dHYM2p1Z2g0Vs2W58vP4N6ZV+vKyJSf0WV9QjV5dNzN3JbWoojR1MlmZmhyaDQ23Jrcydbgx5ak3mVpPTNlZdujpNzfuMnmmmo6RWhnZIbMzdXRp57PmZnaz9faoaN5ZWUzZmlnaDQ2ajZ+aWx1fTY3eWVlM2ZkZ2g0Nmo1eWhqdFE1N3lFZTMzZ2WEXjV5dOtoeTUrdjRoaOVmZgVncLS8K3V5KGv0edK4eWYr9HNlZXs3NVb1aml/96o2dGrnZIPoZGg2NbhtAXopbVH6NTh/p6YzpmZnaLQ46jWW6up1iHc4fTRmtWnxKGk3/Ot2eW8stXx8Obto7HV1aEL6Nzd/9qxouTfqOVHqZ2WBqGRnf/Q26js7qmq0e7U6l2dlNFJnZXnXdXDziWj5NXY2NGhqZGZmZGdoNDZt48BJ5IgnJHZ8QF6x0CDb+3M6cTV5aMDZ3Kmm62VpPmZkZ9ajqNeW5dHk2d01O4VlZTN6ytm9oKjt1djL3jVuQjRoZ6iZqry9rXeKuYesaG52eTU38WVpNTNlZfI3OXt0amjzNW49NGhnrdm9xdPUNDp4NXloweProZvN1LiW2MnM1jQ2ajV5aWp0eTU3eWVlM2ZkZ2g0Nmo1eWhqdFo1N3lrZjMzbmWRyTV5dLBquTXqODRsLqYmacHp6DX2arV9N+o0ens5umXsdfNowvs3NoG07Om/96o2uiqnZO2opWz1tndvf/vq7Lo7djf/Z6YzLaYna9G4ajY/aqt0f/h3eULnM2dqaqk0dm01fYVtdHqSuXll8jX1aTB7NzV6t2xouThqPLXraWQnKWZnyfc96oJ9bG/6fXg3AKmoPILp6YGHuTx88Cy8NTE6+Gttaalma6ysPnZvtYGF73R6BDv+bjL3amRnbbQ2sTo9a/B5vDW+/qlw82vkbwW5NmuE/u10wr46OBbpZTX5Kal5Nzp5fUfseTZ/O7RtdGmrcKqsrTS97/qCL681gpK8+WYvdThvxfwutLr3bGj5OGo89StsZMfpbOe1ODpvu32ravu9eEDI6ek7tugqcLr6rTU/bK10QHn7gmVqs25B62g1BS65ejUueHk1PPllqzh2Zaz++z/5eepw1rpqN4Ot7GW0q2loBbg2bPs9rGp0fjVAVullNDlqq3l3Onl9h+15NoV7NGh+5GfmeWzoOUNveoOur7l5vLw+bix4J23E7bQ3NHd+cso3b7SEfGhquWmnZ+93eXGE/OtwxPz4Pf8oqDP6aCl8PTm8dHGsvT2qOrRuhOhmZzNq7DsDLTh5aG70eXw7PWjrN3Zl7P17Pjl46m4WuWo3g+zrbLSqaGgFtzZs+zysanR9NT5W6GU0e2jnbUE6rz2/rK90ALn8gCyp9G3B6+g1AKw5gW6uunl1O/lq5TczZ0G9tzeQdGroOrlwNlGsZ2aFZuRngzQ2ajmFaGp0wJqrvc7Yp5TTyN43OX10amjppN02N8T2JluOwFanOD5qNXnWz+vspabtZWk6ZmRnvpmZ3qTraG52eTU38mVoM2ZkZ2g0Wqo5iWhqdNqjnuXKp5in3MrepXbr12preTVqNjTowqRpZmRnaDS2y3V8aGp0eTU3eWVoMzNlZXk3STl4b2h5NdeXqNBnaGlmZGfYnTZtNXloanT5m3d9cWUzZqiarIyMr3jNt7yneTlGeWVlldXZ1cydpNGH2szT6ew1O31lZTOW1Nh5Ozl5dGrb4qNqOkJoZ2S91dbTzIilvZjrzc/ieTg3eWVlMzNVpH1DNXl0rpu9jcB7d7y2tphmaGloNDbiNXxoanR5NTeNpWk6ZmRnsaeNy6HlaG5/eTU3vdfGqrLN1c2naGo4eWhKc3g0JrplZTMzZmV5NzV5dGpoeTVqNjRoZ2RmZmRnaDw3ajWJaWp0gjVOrmVlM3lnpXm3N3l0Kmr5NWo5NGnE5mZo6mmoNPysdXkv7DR+O3q5ZWz2pmqtq3Q2sTg6bgf2eTcF++dp/6glbEW2NmsEO+hvQju3O3/opjN5KKZ5vrg5eTErOTpxOvVtxGdmaIHqaDR8bXd58+10efy6uWvv9jbmLDx3OwM37elEuGo2O+ynajBpaOhv+HZw/3zs69H8tTjUaGUzfWRq6Hp5rDX5a2p0OTi3eWVpM2eka+g1tm41eyhu9HtRfHlofDMz5Wb+OTW5eepr+TpqOpGrZ2mFZuRnczQ2ajmAaGp0z5qa7dTXMzdvZXk3mNrhz9rahdmpNGxpZGZm3GdsNjZqNfJobnZ5NTfzZWk+ZmRn1qOo15bl0eTZ3TU7h2VlM73T2dSYitmI3NrP2ec1O4VlZTN3mKnRjXq8yLm6rDVuPzRoZ7PUucfZzZmkajmIaGp0vaeY8KbXloHK3e2Dq+V0bWh5NWo29LqnZGZmZGhoNDZqNXloanR5NTd5ZWUzZmRnaDRHazV5gGt0eTg3gX5lM2YqZ6g0PKt1eahr9HlSuHlmgDQzZXz5N7V/tapouTZqN1HpZ2Wn52RnRXS2awh5aGpBubU4jGZlM0DmZXuD9jl1x+l5Nvb3dGoE5WZnsujpNk9q9nt/anT5gng6Z8Q0ZmWGaLQ2cDV5aG57eTU32tjYmNjYZ2w/Nmo1z83N6Oini/LVyjM3nmV5N5bn29bNu5rerZnN1Z6G3dbW1ptWy6fg3dfZ56lX7d7VmKaFjatXcc/Zzdzop6hWmeDXycnaycuRNDpwNXlo2uPllql5aGUzZmRnaDQ2bTV5aGp0+Zt3eWVlM2dkZ2g0Nmo1eWhqdHk1N3llZTMzZWWUODV5qGtoeTZqP4ZoZ2SsZqRn7rR2atL56GqNOXU4kOVls7QlZXnSdXl0gah5tfC2dGgE5OZmrufotHyqdnnF6vR5P3d556vzp2TE6LQ2dHV567V0eTVBuWXpfmZkZ3J0tu6AeWhqfrk1vL8lpzO6ZaZ5lDV6dYGoe7Xxd3ZoLmUpaO6oKze963d5L2s3e7+4PGjsNHVlLHr6N4R2amgDNuw5luhnZEkmYOau9HhqvPmpatF5NjiQpWez7aWpaPs3LTcDqS13ALZ5eSxm9mju6Cs3vWt3eS9rN3tAOXll7zS1aMf5NzVcNGbnwDWsNrooqmTtZqdoMzQ2an85aGu7+Xc3/yWoM7plqHqBtbx1sai7NfD2d2juZKlnrqerNYKqeXnF6nR6P3d57auzqmQMaDQ2x3V5abA0vTWU+eVli2YpZ3+0Nup7ua1qGbk1N9alZTRSZeV5TTV5dG5veTVqiZnL2cnaZmhtaDQ23Yni1c90fUQ3eWWsmKeu08CYot7I09Xep2o5NGhnZGYmxqdsPTZqNeyt2NnmnpzsZWlCZmRnr5mqr6Pe1eO83qem3thlN25kZ2ind9ah4s3ddH1DN3llrJinptHlsH3e5tnN7DVuPTRoZ9TVz9Lb2zQ6bzV5aNLd4J03fW1lMzPJzuynodrtamx/NWo2pMnQ1tlmaHFoNDbYmu3f2ebkfnt5aGUzZmRnaDQ2bjh5aGrC6DU7gGVlM9Pdr82mpWo5fGhqdOyCN31qZTMzssrnrDV9hGpoeXbOmnjayNupx9DTypWZ1TV9cmp0eXyc7bfKmpzU03k7OXl0at3noGo6R2hnZKfKyLXNq4bLqeGry+Dll5jc0GU1ZmRnmDU2amV6aGp0eTc7eWVlOGZkZ3Q0dmpSuWhrk3m1N3plZTM3amV5N3nr1eFoeTVqNjVoZ2RnZmRnaDQ2ajV5aGp0eTU3eWWXNDNll3o3NYB0enN5NWr7NWhnMGcmZ6dqNDbqN/loKnZ5Njd85WZzaWRp6De2bPV8aG1RurU7mGXlM2dkZ2g4QGo1ebfYwt6sh9rZzTMzZWV5ODV5dGtoeTVqNjRoZ2RmZmRnaDQ2ajZ5aGp0eTU3eWVlMzNlZXk3NXl0amiuNmo2c2lnZGdmZmhoNDaJNfloanR5NTd5ZWUzZmRnaDQ2ajV5aGp0eTU3eWVlM6dlZ2h5N2o1emhtenk1N79lpTOQ5eV5vnW5dPjo+TUJNjRphmTmZmZnaDQ6eTV5aLHZ7X6lwMbSmIfO0t6pNX16amh5qL6foc1nZGZmZGhoNDZqNXloanR5NTd5ZWUzZmRnaDR9azV5x2t0eT03ia9lM2ZraSg0fKx1ea9sNH1Nd3tpfPND5Wv7dzXANqpoADcrNnvq6WiDaGVofzQ56nu8qWq7/PY91ujlM4EoJn9QdXx6geh6tbA5dmiupyhs6yqoNP1t9nnvLXeA9Tr5asJ25mWJ6jQ2DTd153B2uzU++6dpeiikZ+8292p8++pu+rt2NwDnpjjQZ+V5VHd5dHEquzWxOPVo7iaoZitpKTS9LDd+Lyy0eTw6OmUsNbZqOnu3OpI0bG2QdWu2uyqnZC1oJWfv9jhvyntobw+7NTeQ5WWz7SapaPs4KzUAKmx5g7e5fWwndWaraSk0Paw3fYJqdv9M93nlbHV2Zax7+DWD9i1skPVrtjsqqWStaCVnb3Y4bk556vGL+TW3gKeoM3pnJnlBNz14iWj5NXs2NGhraWZmZNvhpJtqOYBoanTmrn/e19QzampnaDSmy57r22p4gDU3edXUnNTY2mg4QGo1edbP6PCkqeSuqTM3aGV5N6TsdG5ueTVqmaDXys9maWRnaDQ2akW5bHB0eTWr2sfRmDNpbHk3NevZ19fvmmo6O2hnZM/U18zaqDZuOnloatzinJ95aGUzZmRnaH12bj15aGrY4qin5cbeM2ppZ2g0j8+ommhtdHk1N3llqXM3a2V5N4La7czNeTVqNjRpZ2RmZmRnaDQ2ajV5aGp0eTU3eWVllDRlZfY4NXl1angsNWo2eminZOemZGfFtDZrkLloaot5NbeYZeUzrCSnaHu2KjX6aGt0P/V3eSyl9GdBZ+g0k+o1eXCqdPp7t7plsfP0ZcL5Nzb/9KtoBfWrN9HoZ2X05mTrgbS2akx5buq6uXc3+uVnM/klp3k9Nrx0cam8N7C3dWizJSdowehoNYSrNv2Fa3R6Erd5ZWa0aWT9aDU3K/V8aGt1fTV4umllueeoZyn1Omo2O2xqtXs6N/pnajPQZuV7lHV5dK1o+TXJNjRpraSrZuXnbTT36jp5aWt2eXa4fmXm9DhlK/p7NXp2cGi6t282tepsZCfoaWdFNbZskrloarq5dzf6pWszJyRqaDW3cDW6qW50/7Z7eSZmOGZlKWw0dyw5eenseXnSOPlnwnMzZau5eTX/NLBoADWxN/WobmRsJ6Znr7V9ars6rmr7Onw6wObmNbRmbXn+dsF0cCq/NXH4e2wuZehpuijpNlPrNXr+anV69reBZWb0bmSoaT028La9aCs1fTU4O2lldGhpZ+k2O2rSeuhs0bk1N7+lrjO65a55lDV6dYFogbXwd3ZoLmUtaGWpbzR8LHd57+y7efz5QGfs9TVqJns/NYC3smjA+DE4O6tqavxoZ2zFtjZrC7rqbXX7PTe6J24z9WaxasF4rjo/6q50evg7eayoe2brKi82fe24f4Kq9w1Mt3nlpvY3ZcC8NzWQdGrourh0NrUrcWQnKW5nRTa2bNK6aGrW+TU3XGVcsnmlrnm+NcR0x2h6NoE2POjtpahmK2gvNjesPHmuLLZ5vLnAZSz1LWbuKjY7KzeBaHG3wTV+PCxnOqlnbf42OW+S+2hrSrq3OnrnbTN0J215xjfDdvdqwjowuHhoaCdqZqWqczS9rX15Ly07e7z6fGx/s7b5fPk3tfo3bmgUeGo2S2hn5Ofpbmcp90BqEnvobBG6NTfb5WUzSWRe51M26jWnaGp0fT83eWWuprHJ4Kyjrdg1fGhqdHk1N5ulaTgzZWXdmKnedG5reTVqpadoa2dmZmSR3DQ6bzV5aN7d5po3fWxlMzO4ytypmu10bnB5NWqolda7zdPLZGpoNDZqNXnhqniCNTd5qdeU3bjM4Kg2blB5aGq64qeq7YW4ltjN19yZqIqH3tjZ5u1VoOefhTM3bmV5N6no597a4qPRNjhtZ2Rm08Xb0DQ6cDV5aNDg6KSpeWlxMzNlhcycmOjiztunY5g2N2hnZGZmZJ+oNzZqNXloapy5ODd5ZWUzZpKnbDk2ajW6urG2eTg3eWVlM0bTp2s0Nmo1eSjVtH0+N3llqaWU3LHipZp5d2poeTVqNjRoamRmZmRnOKp2bTV5aGp0uZp3fXBlMzO0095XpN+Uv9u4NW02NGhnZKbGpGtvNDZqovKwz+boNTuCZWUzyczI2oKX15p5bG10eTVxmWVpO2ZkZ8ydqdqh2uFqeIM1N3nTyqeq1NfkgHl5eGxoeTWKNjhtZ2Rmzs3O0DQ5ajV5aGp0q3U6eWVlMzNlsLk6NXl0amh5eao6OmhnZNbHzdnbNDpzNXlo3bnnmqTiytgzaWRnaDQ2ap65a2p0eTU3eZ6lNmZkZ2g0NrN1fGhqdHk1l9ylaDMzZWV5N2+5eHJoeTXdd6DU0MnZZmdnaDQ2ajWvqGp0eTU4eWVlMzNlZXk3NXl0amh5NWo2NGhnZWZmZGhoNDZqNXloanR5NTd5ZWUzZg==")
_G.ScriptENV = _ENV
SSL({160,226,205,85,178,133,229,10,241,208,81,30,172,56,36,5,20,98,114,126,61,141,104,59,170,130,45,137,11,176,100,194,113,239,165,192,181,237,196,107,76,87,7,124,4,215,123,136,161,77,249,174,44,116,235,143,32,82,15,225,207,242,234,201,193,228,217,1,230,84,214,23,2,177,254,125,17,202,135,22,90,153,200,48,195,101,62,40,18,187,6,120,63,167,24,73,29,232,218,179,134,129,212,115,245,51,109,119,132,148,250,227,8,252,138,38,152,80,27,121,112,175,110,14,171,244,35,75,47,131,25,117,162,197,154,185,146,127,203,213,33,92,204,26,99,223,145,184,91,89,209,93,34,142,150,236,140,139,66,155,53,128,67,210,158,164,9,49,144,159,105,55,39,233,96,108,83,186,13,240,78,70,253,64,41,151,211,231,222,220,43,246,42,169,12,94,95,16,189,182,58,206,191,57,106,221,156,255,65,71,157,219,46,102,188,52,54,111,50,21,74,88,97,86,37,183,238,199,173,69,103,251,243,180,163,198,68,31,72,79,166,190,216,149,122,3,19,28,118,60,224,168,247,147,248,194,194,194,194,179,134,232,152,212,215,138,134,38,115,250,250,109,107,76,208,194,194,194,194,245,129,194,179,134,232,152,212,215,212,134,38,245,148,129,250,107,138,38,252,245,148,212,215,218,115,29,252,76,215,27,115,29,38,194,244,207,194,196,217,196,194,38,115,134,148,194,227,252,245,148,38,107,196,230,252,252,250,252,194,245,148,194,125,250,29,179,245,148,212,82,196,215,215,161,76,194,252,134,38,152,252,148,194,134,148,179,208,194,194,194,194,245,129,194,179,134,232,152,212,215,212,134,38,245,148,129,250,107,138,38,252,245,148,212,215,232,112,38,134,76,215,27,115,29,38,194,244,207,194,196,217,196,194,38,115,134,148,194,227,252,245,148,38,107,196,230,252,252,250,252,194,245,148,194,125,250,29,179,245,148,212,82,196,215,215,77,76,194,252,134,38,152,252,148,194,134,148,179,208,194,194,194,194,245,129,194,179,134,232,152,212,215,212,134,38,245,148,129,250,107,138,38,252,245,148,212,215,138,152,232,76,215,27,115,29,38,194,244,207,194,196,217,196,194,38,115,134,148,194,227,252,245,148,38,107,196,230,252,252,250,252,194,245,148,194,125,250,29,179,245,148,212,82,196,215,215,249,76,194,252,134,38,152,252,148,194,134,148,179,208,194,194,194,194,245,129,194,179,134,232,152,212,215,212,134,38,245,148,129,250,107,138,38,252,245,148,212,215,138,152,232,76,215,27,115,29,38,194,244,207,194,196,217,196,194,38,115,134,148,194,227,252,245,148,38,107,196,230,252,252,250,252,194,245,148,194,125,250,29,179,245,148,212,82,196,215,215,174,76,194,252,134,38,152,252,148,194,134,148,179,208,194,194,194,194,245,129,194,179,134,232,152,212,215,212,134,38,245,148,129,250,107,179,134,232,152,212,215,212,134,38,245,148,129,250,76,215,27,115,29,38,194,244,207,194,196,217,196,194,38,115,134,148,194,227,252,245,148,38,107,196,230,252,252,250,252,194,245,148,194,125,250,29,179,245,148,212,82,196,215,215,44,76,194,252,134,38,152,252,148,194,134,148,179,208,194,194,194,194,245,129,194,179,134,232,152,212,215,212,134,38,245,148,129,250,107,179,134,232,152,212,215,138,134,38,115,250,250,109,76,215,27,115,29,38,194,244,207,194,196,217,196,194,38,115,134,148,194,227,252,245,148,38,107,196,230,252,252,250,252,194,245,148,194,125,250,29,179,245,148,212,82,196,215,215,116,76,194,252,134,38,152,252,148,194,134,148,179,208,194,194,194,194,245,129,194,179,134,232,152,212,215,212,134,38,245,148,129,250,107,214,134,38,62,134,232,153,134,138,152,119,38,76,215,27,115,29,38,194,244,207,194,196,217,196,194,38,115,134,148,194,227,252,245,148,38,107,196,230,252,252,250,252,194,245,148,194,125,250,29,179,245,148,212,82,196,215,215,235,76,194,252,134,38,152,252,148,194,134,148,179,208,194,194,194,194,245,129,194,179,134,232,152,212,215,212,134,38,245,148,129,250,107,179,134,232,152,212,215,212,134,38,245,148,129,250,76,215,129,152,148,218,194,244,207,194,179,134,232,152,212,215,212,134,38,245,148,129,250,194,38,115,134,148,194,227,252,245,148,38,107,196,230,252,252,250,252,194,245,148,194,125,250,29,179,245,148,212,82,196,215,215,143,76,194,252,134,38,152,252,148,194,134,148,179,208,194,194,194,194,245,129,194,179,134,232,152,212,215,212,134,38,119,250,218,29,119,107,179,134,232,152,212,215,212,134,38,245,148,129,250,124,161,76,194,38,115,134,148,194,227,252,245,148,38,107,196,230,252,252,250,252,194,245,148,194,125,250,29,179,245,148,212,82,196,215,215,32,76,194,252,134,38,152,252,148,194,134,148,179,208,194,194,194,194,245,129,194,179,134,232,152,212,215,212,134,38,245,148,129,250,107,153,134,29,179,1,62,135,153,1,76,215,27,115,29,38,194,244,207,194,196,217,196,194,38,115,134,148,194,227,252,245,148,38,107,196,230,252,252,250,252,194,245,148,194,125,250,29,179,245,148,212,82,196,215,215,161,136,76,194,252,134,38,152,252,148,194,134,148,179,208,194,194,194,194,245,129,194,227,29,218,109,29,212,134,215,119,250,29,179,134,179,215,179,134,232,152,212,215,212,134,38,245,148,129,250,107,153,134,29,179,1,62,135,153,1,76,215,27,115,29,38,194,244,207,194,196,217,196,194,38,115,134,148,194,227,252,245,148,38,107,196,230,252,252,250,252,194,245,148,194,125,250,29,179,245,148,212,82,196,215,215,161,161,76,194,252,134,38,152,252,148,194,134,148,179,208,194,194,194,194,245,129,194,227,29,218,109,29,212,134,215,119,250,29,179,134,179,215,179,134,232,152,212,215,212,134,38,245,148,129,250,107,214,134,38,62,134,232,153,134,138,152,119,38,76,215,27,115,29,38,194,244,207,194,196,217,196,194,38,115,134,148,194,227,252,245,148,38,107,196,230,252,252,250,252,194,245,148,194,125,250,29,179,245,148,212,82,196,215,215,161,77,76,194,252,134,38,152,252,148,194,134,148,179,208,194,194,194,194,245,129,194,153,134,29,179,1,62,135,153,1,107,38,250,148,152,132,232,134,252,107,138,38,252,245,148,212,215,138,152,232,107,38,250,138,38,252,245,148,212,107,179,134,232,152,212,215,212,134,38,245,148,129,250,76,124,161,161,124,161,143,76,124,161,116,76,194,7,194,174,76,194,244,207,194,249,32,116,235,32,174,136,143,249,116,194,38,115,134,148,194,227,252,245,148,38,107,196,230,252,252,250,252,194,245,148,194,125,250,29,179,245,148,212,82,196,215,215,161,249,76,194,252,134,38,152,252,148,194,134,148,179,208,194,194,194,194,245,129,194,153,134,29,179,1,62,135,153,1,107,38,250,148,152,132,232,134,252,107,138,38,252,245,148,212,215,138,152,232,107,38,250,138,38,252,245,148,212,107,119,250,29,179,76,124,161,161,124,161,143,76,124,161,116,76,194,7,194,174,76,194,244,207,194,249,32,116,143,136,235,161,32,136,143,194,38,115,134,148,194,227,252,245,148,38,107,196,230,252,252,250,252,194,245,148,194,125,250,29,179,245,148,212,82,196,215,215,161,174,76,194,252,134,38,152,252,148,194,134,148,179,208,194,194,194,194,245,129,194,153,134,29,179,1,62,135,153,1,107,38,250,148,152,132,232,134,252,107,138,38,252,245,148,212,215,138,152,232,107,38,250,138,38,252,245,148,212,107,119,250,29,179,129,245,119,134,76,124,161,161,124,161,143,76,124,161,116,76,194,7,194,174,76,194,244,207,194,161,174,161,32,77,161,161,161,136,194,38,115,134,148,194,227,252,245,148,38,107,196,230,252,252,250,252,194,245,148,194,125,250,29,179,245,148,212,82,196,215,215,161,44,76,194,252,134,38,152,252,148,194,134,148,179,208,194,194,194,194,245,129,194,153,134,29,179,1,62,135,153,1,107,38,250,148,152,132,232,134,252,107,138,38,252,245,148,212,215,138,152,232,107,38,250,138,38,252,245,148,212,107,179,250,129,245,119,134,76,124,161,161,124,161,143,76,124,161,116,76,194,7,194,174,76,194,244,207,194,77,249,249,77,44,143,235,174,136,249,194,38,115,134,148,194,227,252,245,148,38,107,196,230,252,252,250,252,194,245,148,194,125,250,29,179,245,148,212,82,196,215,215,161,116,76,194,252,134,38,152,252,148,194,134,148,179,208,194,194,194,194,245,129,194,179,134,232,152,212,215,212,134,38,245,148,129,250,107,119,250,29,179,76,215,27,115,29,38,194,244,207,194,196,217,196,194,38,115,134,148,194,227,252,245,148,38,107,196,230,252,252,250,252,194,245,148,194,125,250,29,179,245,148,212,82,196,215,215,161,235,76,194,252,134,38,152,252,148,194,134,148,179,208,194,194,194,194,245,129,194,179,134,232,152,212,215,212,134,38,245,148,129,250,107,214,134,38,195,138,134,252,76,215,27,115,29,38,194,244,207,194,196,217,196,194,38,115,134,148,194,227,252,245,148,38,107,196,230,252,252,250,252,194,245,148,194,125,250,29,179,245,148,212,82,196,215,215,161,143,76,194,252,134,38,152,252,148,194,134,148,179,208,194,194,194,194,245,129,194,179,134,232,152,212,215,212,134,38,245,148,129,250,107,38,29,232,119,134,215,218,250,148,218,29,38,76,215,27,115,29,38,194,244,207,194,196,217,196,194,38,115,134,148,194,227,252,245,148,38,107,196,230,252,252,250,252,194,245,148,194,125,250,29,179,245,148,212,82,196,215,215,161,32,76,194,252,134,38,152,252,148,194,134,148,179,208,194,194,194,194,245,129,194,165,200,218,252,245,227,38,217,250,179,134,194,244,207,194,161,174,32,249,44,194,38,115,134,148,194,227,252,245,148,38,107,196,230,252,252,250,252,194,245,148,194,125,250,29,179,245,148,212,82,196,215,215,77,136,76,194,252,134,38,152,252,148,194,134,148,179,208,194,194,194,194,245,129,194,101,2,22,24,195,200,230,153,194,29,148,179,194,148,250,38,194,217,125,250,125,22,29,218,109,134,38,194,38,115,134,148,194,227,252,245,148,38,107,196,230,252,252,250,252,194,245,148,194,125,250,29,179,245,148,212,82,196,215,215,77,161,76,194,252,134,38,152,252,148,194,134,148,179,208,194,194,194,194,245,129,194,101,2,22,24,195,200,230,153,194,29,148,179,194,38,112,227,134,107,217,125,250,125,22,29,218,109,134,38,76,194,244,207,194,196,152,138,134,252,179,29,38,29,196,194,38,115,134,148,194,227,252,245,148,38,107,196,230,252,252,250,252,194,245,148,194,125,250,29,179,245,148,212,82,196,215,215,77,77,76,194,252,134,38,152,252,148,194,134,148,179,208,194,194,194,194,245,129,194,179,134,232,152,212,215,212,134,38,245,148,129,250,107,250,138,215,212,134,38,134,148,80,76,215,27,115,29,38,194,244,207,194,196,217,196,194,38,115,134,148,194,227,252,245,148,38,107,196,230,252,252,250,252,194,245,148,194,125,250,29,179,245,148,212,82,196,215,215,77,249,76,194,252,134,38,152,252,148,194,134,148,179,208,208,194,194,194,194,119,250,218,29,119,194,217,152,252,22,250,138,194,207,136,208,194,194,194,194,119,250,218,29,119,194,254,134,112,22,250,138,194,207,194,136,208,194,194,194,194,119,250,218,29,119,194,254,134,112,194,207,194,196,129,179,212,115,174,116,51,44,112,115,51,38,112,44,235,112,134,134,249,129,179,212,115,174,116,51,44,112,115,51,38,112,44,235,112,134,134,249,249,134,134,112,235,44,112,38,51,115,112,44,51,116,174,115,212,179,129,129,179,212,115,174,116,51,44,112,115,51,38,112,44,235,112,134,134,249,249,134,134,112,235,44,112,38,51,115,112,44,51,116,174,115,212,179,129,129,179,212,115,174,116,51,44,112,115,51,38,112,44,235,112,134,134,249,196,208,194,194,194,194,119,250,218,29,119,194,217,250,179,134,194,207,194,24,214,215,200,218,252,245,227,38,217,250,179,134,208,194,194,194,194,119,250,218,29,119,194,200,38,252,245,148,212,228,112,38,134,194,207,194,138,38,252,245,148,212,215,232,112,38,134,208,194,194,194,194,119,250,218,29,119,194,200,38,252,245,148,212,217,115,29,252,194,207,194,138,38,252,245,148,212,215,218,115,29,252,208,194,194,194,194,119,250,218,29,119,194,200,38,252,245,148,212,200,152,232,194,207,194,138,38,252,245,148,212,215,138,152,232,208,194,194,194,194,119,250,218,29,119,194,48,250,125,250,29,179,194,207,194,129,152,148,218,38,245,250,148,107,76,208,194,194,194,194,194,194,194,194,254,134,112,22,250,138,194,207,194,254,134,112,22,250,138,194,7,194,161,208,194,194,194,194,194,194,194,194,245,129,194,254,134,112,22,250,138,194,242,194,165,254,134,112,194,38,115,134,148,194,254,134,112,22,250,138,194,207,194,161,194,134,148,179,208,194,194,194,194,194,194,194,194,217,152,252,22,250,138,194,207,194,217,152,252,22,250,138,194,7,194,161,208,194,194,194,194,194,194,194,194,245,129,194,217,152,252,22,250,138,194,242,194,165,217,250,179,134,194,38,115,134,148,208,194,194,194,194,194,194,194,194,194,194,194,194,252,134,38,152,252,148,194,196,196,208,194,194,194,194,194,194,194,194,134,119,138,134,208,194,194,194,194,194,194,194,194,194,194,194,194,119,250,218,29,119,194,202,134,27,228,112,38,134,194,207,194,200,38,252,245,148,212,228,112,38,134,107,200,38,252,245,148,212,200,152,232,107,217,250,179,134,124,217,152,252,22,250,138,124,217,152,252,22,250,138,76,76,194,4,194,200,38,252,245,148,212,228,112,38,134,107,200,38,252,245,148,212,200,152,232,107,254,134,112,124,254,134,112,22,250,138,124,254,134,112,22,250,138,76,76,208,194,194,194,194,194,194,194,194,194,194,194,194,245,129,194,202,134,27,228,112,38,134,194,225,194,136,194,38,115,134,148,194,202,134,27,228,112,38,134,194,207,194,202,134,27,228,112,38,134,194,7,194,77,44,116,194,134,148,179,208,194,194,194,194,194,194,194,194,194,194,194,194,252,134,38,152,252,148,194,200,38,252,245,148,212,217,115,29,252,107,202,134,27,228,112,38,134,76,208,194,194,194,194,194,194,194,194,134,148,179,208,194,194,194,194,134,148,179,208,194,194,194,194,119,250,218,29,119,194,24,230,202,101,194,207,194,24,214,215,200,218,252,245,227,38,230,202,101,194,250,252,194,110,24,214,194,207,194,24,214,171,208,194,194,194,194,119,250,29,179,107,48,250,125,250,29,179,124,148,245,119,124,196,232,38,196,124,24,230,202,101,76,107,76,208,194,194,194,194,48,250,125,250,29,179,194,207,194,129,152,148,218,38,245,250,148,107,76,194,134,148,179,208,241,4,4,24,214,215,214,134,38,195,138,134,252,77,194,207,194,148,245,119,208,99,82,153,76,122,133,75,239,242,208,99,64,71,219,218,208,81,105,21,109,96,28,143,99,74,115,208,200,242,30,246,93,223,139,178,5,51,232,18,155,143,254,92,40,145,61,113,22,126,43,33,151,125,66,218,4,56,42,110,239,11,38,32,30,13,30,145,197,78,121,153,52,74,196,117,93,63,215,173,136,47,115,228,116,110,14,242,140,163,208,152,18,102,144,21,43,220,29,18,94,110,175,242,7,218,225,34,143,104,63,134,91,175,21,1,148,237,103,10,119,186,131,230,9,118,200,228,184,188,238,253,235,24,79,24,198,130,184,168,215,77,34,131,61,54,110,251,55,89,212,3,251,9,173,81,245,95,140,81,114,69,11,97,204,173,68,153,4,84,215,47,45,123,111,124,155,21,186,225,89,153,72,162,187,153,65,98,239,141,210,190,172,121,76,129,228,71,193,226,102,52,1,153,225,86,100,167,237,191,71,48,47,237,84,146,26,45,138,3,82,202,189,36,191,233,121,209,49,200,61,72,244,60,241,255,173,234,233,231,187,219,84,42,232,23,160,183,129,46,34,78,144,81,52,1,255})
