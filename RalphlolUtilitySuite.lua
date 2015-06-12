--[[
Ralphlol's Utility Suite
Updated 6/11/2015
Version 1.05
]]

function Print(msg) print("<font color=\"#A51842\">Ralphlol's Utility Suite:  </font><font color=\"#FFFFFF\">"..msg) end

function OnLoad()
    local ToUpdate = {}
    ToUpdate.Version = 1.05
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
	if p.header == 221 then	
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
_G.ScriptCode = Base64Decode("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xeqp3NbJpZdlOTd4OWVlxdba3NrLi5eWmp/WrGVpcHNmc9bLnJOfpYfTpsrYZHdtc2Rmq5eWmp/WOWj//Qz/DP2FeTY+OTNqqMnO0uXL1sXSpTI208wD0v7+dbNqhmRmOaGXoqHcnsjG0N/P4NTYqKiYnTNtbJiYl6aZgqRqSDIzOaXPnMbR0NzT49bVr5eXOTYE0v7+/QyBs2hyOTIzrKjantfXydbH39BmPTgzOTPMotmYlnNqemRmOZ6moZzQrWVpa3Nmc9bZoZuZrTNuPmVlZNXH4chmPTczOTPMsdTXZHduc2RmgnZ1sqfPrGVoZHNmc2RmOTI2OTNqOWXFzLNpc2RmOTIzKXJtOWVlZHNG26RpOTIzOTNqOaVoZHNmc2TGpHI2OTNqOWVlbLNpc2RmOTITpHNtOWVlZHNmg6RpOTIzOTPKo6VoZHNmc2RmTXI2OTNqOWVFzrNpc2RmOTIzUXNtOWVlZHPG4KRpOTIzOTNqVaVoZHNmc2RGpnI2OTNqOWVlhLNpc2RmOTKTpXNtOWVlZHNmlaRpOTIzOTNKpaVoZHNmc2RmXXI2OTNqOWXF07Npc2RmOTIzX3NtOWVlZHNG4qRpOTIzOTNqYaVoZHNmc2TGp3I2OTNqOWVljrNpc2RmOTITp3NtOWVlZHNmn6RpOTIzOTPKmqVoZHNmc2RmZ3I2OTNqOWVFxbNpc2RmOTIzaXNtOWVlZHPG06RpOTIzOTNqaqVoZHNmc2RGmXI2OTNqOWVllrNpc2RmOTKTnHNtOWVlZHNmpqRpOTIzOTNKnKVoZHNmc2RmbXI2OTNqOWXFxrNpc2RmOTIzbnNtOWVlZHNG1aRpOTIzOTNqb6VoZHNmc2TGnnI2OTNqOWVlm7Npc2RmOTITnnNtOWVlZHNmq6RpOTIzOTPKnaVoZHNmc2RmcnI2OTNqOWVFyLNpc2RmOTIzc3NtOWVlZHPG2qRpOTIzOTNqdKVoZHNmc2RGoHI2OTNqOWVloLNpc2RmOTKTn3NtOWVlZHNmsKRpOTIzOTNKn6VoZHNmc2Rmd3I2OTNqOWUltrNpc2RmOTIzeHNtOWVlZHMmxqRpOTIzOTNqeaVoZHNmc2QmiXI2OTNqOWXlpLNpc2RmOTLzinNtOWVlZHNmtKRpOTIzOTMqj6VoZHNmc2TmenI2OTNqOWUlu7Npc2RmOTIze3NtOWVlZHMmx6RpOTIzOTPqe6VoZHNmc2QmjnI2OTNqOWVlp7Npc2RmOTLzk3NtOWVlZHPmtqRpOTIzOTMqlKVoZHNmc2RmfXI2OTNqOWUlvLNpc2RmOTKzfXNtOWVlZHMmzKRpOTIzOTNqfqVoZHNmc2Qml3I2OTNqOWXlqbNpc2RmOTLzmHNtOWVlZHNmuaRpOTIzOTMqlaVoZHNmc2Tmf3I2OTNqOWUlwbNpc2RmOTIzgHNtOWVlZHPmuqRpOTIzOTNqgaVoZHNmc2TmgXI2OTNqOWVlrbNpc2RmOTKzgnNtOWVlZHNmvaRpOTIzOTPqg6VoZHNmc2RmhHI2OTNqOWXlr7Npc2RmOTIzhXNtOWVlZHPmv6RpOTIzOTNqhqVoZHNmc2TmhnI2OTNqOWXls7Npc2RmOTIzh3NtOWVlZHPmwaRpOTIzOTNqiKVoZHNmc2RmonI2OTNqOWXlzbNpc2RmOTIziXNtOWVlZHNm26RpOTIzOTOqiaVoZHNmc2TmoXI2OTNqOWXltLNpc2RmOTIzpHNtOWVlZHPm3qRpOTIzOTNqiqVoZHNmc2Rmo3I2OTNqOWWltbNpc2RmOTKzo3NtOWVlZHPmxKRpOTIzOTNqpqVoZHNmc2TmpnI2OTNqOWVltrNpc2RmOTIzpXNtOWVlZHOmxaRpOTIzOTPqpaVoZHNmc2Tmi3I2OTNqOWVl07Npc2RmOTKzqHNtOWVlZHNmxqRpOTIzOTNqp6VoZHNmc2SmjHI2OTNqOWXl0rNpc2RmOTKzjHNtOWVlZHNm1KRpOTIzOTPqmqVoZHNmc2RmjXI2OTNqOWVlxLNpc2RmOTJzjXNtOWVlZHPm06RpOTIzOTPqjaVoZHNmc2RmnHI2OTNqOWXlx7Npc2RmOTIzjnNtOWVlZHNm1aRpOTIzOTOqjqVoZHNmc2Tmm3I2OTNqOWXlubNpc2RmOTIznnNtOWVlZHPm2KRpOTIzOTNqj6VoZHNmc2RmnXI2OTNqOWWlurNpc2RmOTKznXNtOWVlZHPmyaRpOTIzOTNqoKVoZHNmc2TmoHI2OTNqOWVlu7Npc2RmOTIzn3NtOWVlZHOmyqRpOTIzOTPqn6VoZHNmc2TmkHI2OTNqOWVlvLNpc2RmOTJzkXNtOWVlZHPmy6RpOTIzOTNqkqVoZHNmc2SmknI2OTNqOWXlvbNpc2RmOTIzk3NtOWVlZHNmzqRpOTIzOTOqk6VoZHNmc2Tmk3I2OTNqOWVlwrNpc2RmOTIzmHNtOWVlZHNmz6RpOTIzOTOqlKVoZHNmc2RmlnI2OTNqOWXlv7Npc2RmOTJzlXNtOWVlZHPmz6RpOTIzOTOqlqVoZHNmc2TmlnI2OTNqOWWlwrNpc2RmOTKzl3NtOWVlZHOm0qRpOTIzOTPqmKVoZHNmc2SGonI2OTNqOWUFzbNpc2RmOTJToXNtOWVlZHOG06RpOTIzOTMKoaVoZHNmc2SmmXI2OTNqOWWFz7Npc2RmOTLTpHNtOWVlZHOG3aRpOTIzOTMKmaVoZHNmc2QGo3I2OTNqOWUlxLNpc2RmOTJTpnNtOWVlZHMG4KRpOTIzOTOKpaVoZHNmc2SGmnI2OTNqOWUF0LNpc2RmOTJzmnNtOWVlZHOG4qRpOTIzOTMKqKVoZHNmc2SGp3I2OTNqOWUFxbNpc2RmOTLTp3NtOWVlZHMm1KRpOTIzOTOKm6VoZHNmc2Smm3I2OTNqOWWFx7Npc2RmOTLTnHNtOWVlZHMG1aRpOTIzOTMqm6VoZHNmc2SGnnI2OTNqOWUFybNpc2RmOTJTnXNtOWVlZHMG16RpOTIzOTOqnKVoZHNmc2SGoHI2OTNqOWUFy7Npc2RmOTJTn3NtOWVlZHMG2aRpOTIzOTMqnKVoZHNmc2SmnXI2OTNqOWUlyLNpc2RmOTJznnNtOWVlZHMm2KRpOTIzOTOqn6VoZHNmc2Qmn3I2OTNqOWWly7Npc2RmOTLzoHNtOWVlZHOm3KRpOTIzOTMqoqVoZHNmc2SmoXI2OTNqOWUlzLNpc2RmOTJzpHNtOWVlZHMm3qRpOTIzOTOqo6VoZHNmc2Qmo3I2OTNqOWWl0bNpc2RmOTLzpnNtOWVlZHOm36RpOTIzOTMqpaVoZHNmc2SmqHI2OTNqOWXFzbNpc2RmOTLzqHNtOWVlZHOm4aRpOTIzOTMqp6VoZHNmc2RGonI3RDNqObfKx+m21MfRnqYzPUVqOWWsyeep39PZnqWnh6LekMbR0HNqgmRmOXalmqqrq8izyevav9rSOTY7OTNqfdfG27TY1mRqSTIzOZTYoNHKptja6snLp3OlnDNuP2VlZNbS1NfZOTY6OTNqjMrI1tjac2htOTIzmJLTp87ZZHdrc2RmhpehrjNuQWVlZOXH4bjPppczPT1qOWW0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ZDRpemRnvTgzlrZqO2Vo5Hmstqxmv/V2OfntgWUsJzttdGhvOXI3OTjrfW5lQXZmdQHpOTL6PPdtQKkqZ7rqOGfnvTsz/zeyOWZqa3OneGtmujc6ORDuOWdoafNm0KdmPXj2gjPxPCloK7Yrdmvq/jV6ffRsgGkvbPSqfWSBPDIzUHNquUGpZHl9c2Xm/zZ7OTNvuWqlafNr9OlsOQ+3OTXHfOVoqrauc+opfDL6vP1sOilvZElp92sDvDI0ADYuPGypKXat9ylph7b8QbTuQmUraLtmdGltOXM4QDPrPmxlQfdmdWdruTKQfDNuUOV35LmpvmTtfPM1wDauQCyoJXUttiltQHb0Ozrufm2sqDRoumgwQX93PcrrfW9lKjexc2VrQDJ0PjpqumpsZDRremRDvbI1Ojh2OayqJXXmeORplnUzPnmtgWXrJ7ZmOucwOzN3RTNAPOlsAfZmdCup+jT6PPdxQKkmZnqquGytffM1gLcvQbPpLXvn921mVDUzOUqqOeVBqHNsimRnufg3gTNqPuVqpHjmeOXrPzIQvTNsPGrlZNCpc2isfHozv/atOSvorHMtNixtOjY8OXNuOWrmqHxmUGdmO8+2OTMxfCZnK3YqejHpBTk6ffRsQKmqbLqqNGatvfc7hvc2QebpbXOBdmRmUHIzuQ+uOWt8ZHTmOWiuOTI4uTiqPuVq5fhsc0HqOTQ2PrNqlqhlaHkptmStPPY2VrZqOr2lqHl9s2rmPzWAOXktfGXr57tm+ieuQPM2QjNqPWVqpbdvcwFpOTSQvDNquqhyZDppt2g0vP86QHevPXPpsXusN7FmlDYzOUrqOeWrKMBmzqhmOUkzOrOwPa1l5HfmeCRquTc0vjlqlullZpCpc2fIuTIzHHMUuIRl5HOec2RmPTszOTO3ms7TsdjU6GRqQDIzOaXPnMbR0HNqemRmOZehmpXWnmVpanNmc9THoqSmOTd4OWVlxdba3NrLi5eWmp/WrGVpaXNmc9nUoqYzPT1qOWXTyefd4tbRgnYzPTpqOWXY2NTY57hmPTozOTPgotjOxt/Lc2dmOTIzOTOOeWlsZHNmycnJraGlOTduOWVl1OLZc2hwOTIznZzcnsjZzeLUc2hxOTIzp6LcpsbRze3L12RqPDIzOaDdOWluZHNm59PZraScp5pqPWdlZHPec2huOTIzZmSYXK6zqHNqfmRmOXmYrYDTp87SxeNmd3JmOTKKqKXWnbnUt9bY2MnUOTY/OTNqfZipvMmrtri1i2UzPTVqOWXeZHdoc2RmszI3PjNqOcrTyMdmd2dmOTKirDNuP2VlZNbS4sfROTUzOTNqOWVlZHZmc2RmObJseTZqOWVlZFPVs2hvOTIziKG9nNfKyeFmd3BmOTJ6nqeuotjZxeHJ2GRpOTIzOTMqm6VpaHNmc7atezI3RDNqOanXxeq62NzabHYzPTpqOWXY2OXP4ctmPTkzOTPQqNfSxedmd2lmOTJYZ2TQOWhlZHNmc2RWeDUzOTNqOWWjpHdyc2RmfaSUsHbTq8jRyaVmd3NmOTKVqKjYnc7Ty8XH183brDI2OTNqOWVlZLNqeGRmOaCUpphqPXJlZHOGxcnJmp6fWYbaqNllZ3Nmc2RmOatzPTtqOWWp1tTdtNbJOTUzOTNqOdHlpHdrc2RmeoR6ezNtOWVlZHOmxqRqUDIzOVO6q8rJzdba2MiGi5eWmp/WWabXydRmdmRmOTIzOUeqPGVlZHNmc5ymPTszOTOuq8bcuNje52RpOTIzOTNqaqVoDx0QHQ4QP3I3PzNqOcjU0OLYc2RmOTI1OTNqOWVmZHNmc2RmOTIzOTNqOWVlZHPMc2RmqjIzOTpqS6plZHNBs2RmUDIzufRqOWUr5bNmOiUmPDM1OjOwu6Vlq7Und+roeTK6u3Rv/+elZDooNGl1/DK3STZtPELnZHQD9WRnybS1vZBsOWZC5XNmeyTnufi0eTMxuidoMzRn92qoeTIDOrVtQSXm5EImNWUxOjIzOjVtOavnpHOt9SZqiHQ1vbmseWWy5vVq+aamOVP1PrNwfKhlqvapc+rpeTK6/HZx+WjlaRDpc2X1vLU0xrZtOSVo5HNs96RmQDZ3QXNuuWqC6HNngmjqOkA3PTTHPGVngfZmc7lpuTWAfPdwv+ipZDopt2ptPXc51rbqOi/m53mG9V3lP3R4OXNsuWjlZnNoT6bmO0kzObMru2plgbVmdYNmuTJKOTNqPGVlZHNmM9amPTozOTPbrsbRzeffc2hrOTIzppTeoWVpaHNmc9HHsTI2OTNqOWVlhLNqeWRmOZifqKLcOWlpZHNm18nNOTY4OTNqmtjO0nNpc2RmOTIzOXNtOWVlZHPm2aRqPDIzOaPTOWjWoX09FtRTeDUzOTNqOWVlZHd0c2RmkKGlpZe+qLjI1tjL4WRqRTIzOXedfb27qba6wraZOTY3OTNqnNTYZHdqc2RmrJuhOTZqOWVlZHNWsmhyOTIzfWaukbuqp8e1xZZmPTQzOTPiOWlnZHNm7GRqRDIzOXfcmtyxzeHL5pZmPDIzGTJpOFSmZHNmc2VmOTIzOTNqOWVlZHNmc2RmOTIzOTPdOWVl33Nmc2tmTGUzOTMwOqVlZHVmc6RouTKzOzNrFuZlZnlos2Sse3IzgLUqPeunpHPtNaRr/3RzOfps+mqC5nNowWboPH51+jfHu2VmszXmd7KouzW5u3Rq/yemZHrpM2it/PI3wDYrPUJnZHUD9WRm/zR1OT7tOWWs57Nrfadpunn2eTh0fOjmr/Zmc+vpeTd9vDbrwCilab3p9uVDu7I0FDVqOXzlZvMstaZmOTUzOXNtuWXlZ3NnM2fmOjI3OTWqPeVnALdmdntmObK0vTVqFqdlaJJm82RxOTIzPTpqOWW7ydba4tZmPTwzOTPNmtLK1tS24tdmPTQzOTPiOWlnZHNm7GRqOzIzOa1qPXBlZHPU4tbTmp6cs5jOOWlzZHNmytPYpZaHqIbNq8rK0nNqf2RmOXZmfYvAfqi5s8WZc2hvOTIziKG9nNfKyeFmd3ZmOTJ3q5ThfM7Xx9/LwcnerX6ppTNtOWVlZHMmxaRmOTIzOjNqOWVlZHNmc2RmOTIzOTNqOWVlZBBmc2Q+OTIzOzN4/GVlZPpmM2R+eXI0ULOZua8lpPTxc2Rm+jI0OTSrOmWm5XRmVGRnufj0ejN2OydlgfVmdCtnuzW9+TRtGaVj4zhm82RrOjI0fjTqOuympXQntGZmlrOzOrTrO2WC5fNnuGVmOrc0uTQx+qdmZbVocwHnuTP0OjZqlublZfhnc2UrOrI0QHWtOqanZnND9ORnOrQ2OdDruWYqZfNnemanOnN1OzNHOuVmQfNmc2onfDI/Ondsv6apZDNn82UDOjI0VrRqOYBmZHN9M4fmgLN3O45rOWV8ZJbmuiWqO0oz/jWBeYflq7SrdernfjJLubRsUKWG5L0muOWnOjgzunRrOSymKnNntWVm2nM1ub9s+2UC5nNny+SsPkmzOrMqO+Vnajasc2tpgDhzPDNvVuhlZcln9mkGOi+yv3SxOTHmK3VD9GRnwPM0PM5rOWV85H/m/mVmObw0usIxeq1n7jRnAyongTL6OvxtFublZP0ndPUsenkzRbUxO4LnZHQtdOZpw/O0y/rrgWhsprxpQGXoPLz0OsYw+q5lK3QwdiunAzUOOjNqUCVq5DrnvWZBejIzUDNvuSwmrnUsNGVoFDMzOUpqPeUrZb5memauPHN1RDPw+6tl6/WxeCUoRDI5/HtqQGiuapDp82St/Hw1f3ZtO3OoZ3mntmVm1rQzO/RsRWV7JnVqUKVmOvh0hTNx+69nLvRnd4NmuTJK+UHqv6axZDonvWbt+jM21DRqOXzlcfPstLBmAPN9O7orOmgAZXNmiqRtubh0hTMx+q9n6zRnduvngjX5+ntqAGYuZ1Dn82R/ubM2UDNvuesmrXPtdK5pwHN9PM5rOWV8JHTm+WWxOfh0hTNx+69nK3ToditnATU0uz9qD2bnZxCnc2VuOf/MQTM3021lsQ7stLBmAPN9O71rBmiEZPNmiiRqubj0gjPxOq9o67Swdv9nOTJK+TTqv2awZDmnv2Rt+3w1ADTsPCxmLHZnNXFmDzO1PNCrOWbrpb9mOiWwO7w0BjZyOTL+bHMzDWxmhs1SObNqWGXlZKtmc2RqQDIzOZvPmsnK1nNpc2RmOTKjq3NuPWVlZOPV5mRpOTIzOTNqUaVoZHNmc2RmSXI2OTNqOWVlVLJpc2RmOTIzKfJuQWVlZLyqtd3anqUzPTtqOWWpydbV18mXOTUzOTNqOUXUpHZmc2RmOTJreTZqOWVlZHNms2dmOTIzOTOaeWhlZHNmc2RueTUzOTNqOWWFpHdxc2RmqJSdhpTYmszK1nNqiGRmOXmYrYLMo8rI2LXfwcnasKGlpHzOOWlyZHNmt9vVq5aHqHnWqMbZZHdsc2Rmr5OfopdqPWplZHPa7NTLOTZAOTNqeq6tyeXVttDPnqCnOTdvOWVl2NjH4GRqRDIzOYeverLEqcGrwL1mPDIzOTNqObOlaHRmc2RmPTczOTPdot/KZHZmc2RmOTIzOTdxOWVl1+fY3NLNOTY4OTNqnM3G1nNqf2RmOaSYnJTWpbnO0djZc2hsOTIzpaLhntdlaHhmc2Tbp5unOTdvOWVl0tTT2GRqQjIzOZbSmtezxeDLc2htOTIzrKfLq9m5ZHdpc2RmqKUzPTlqOWXI0OLJ3mRqQjIzOZffq8bZzeLUc2hrOTIznqHOjWVpbXNmc7HHoqCAnqHfOWlsZHNm5cnJmp6fOTdwOWVl1OXP4dhmPTozOTPgotjOxt/Lc2hwOTIzp5jesNTXz7yqc2hsOTIziaXTp9llaI1mc2SGoqVTq5jNmtHRzeHNoYSymqWnWabPntOFZHdtc2Rmn6GlppTeOWlqZHNmmJKXnzI3RzNqOYXYydbV4cjZWZOaqGFqPXNlZHPH1tjPr5eFnpbLpdHYZHd3c2RmWZWUp5bPpcrJhOXL1sXSpTI3RDNqOdfKx9TS37jPppczOTd1OWVl1tjJ1NDSh5OgnjNuQ2VlZNXS4sfRh5OgnjNuSmVlZJPM3NLPrJqYnVPcnsjG0N9mc2RmOTczOTNqOWZqZXVnd2VmOTIzOTNqOWVlZHNmc2RmOQszOTNLOWVlZnNxmmRmObMzOTMreWVlZfRmcwVmQbK5+nNq+WblZBDnc2Us+nIzOTVqOULmZHRsNaRmeTSzOVDsOWYzZfVpP2UnPA+0OTRwe6ZlpHVmc+RouTJQu7NrSKdmaEJn9Wfz+jM2/7SrOWwnpXatdaZpwHR1PBDrOWdr5rVms2bmPE+1OTSFe2VlezNm82ooezJzO7NtV2dlZZJoc2QGeSmyWDPqOXFlZHNpc2RmOTIzOTNt56xG3ocUYqNpFCuxo+/ezKRpa3Nmc7rLnKaiqzNuRGVlZOHV5dHHpZutnpdqPXFlZHOt2NiqoqWnmqHNnmVpcHNmc6iZfYqJfna+iLeYZHdoc2RmsTI3OzNqOd5laHVmc2TgOTY6OTNqgti8xd/Sc2h0OTIzkKLcpcm508bJ5cnLpzIzOTNqOmVlZHNmc2RmOTIzOTNqOWVlZHNmc0ZmOTI6OjNqQmV99nNmc6poeTKzOzNuAKclZ9Do82UmObI3CLMqOqtnpXPttSRplrQzOjuqu+arJrNm+SamObl1ejj3u6ZqrvXo9aooejK5O3RqAKclZxDoc2UsO3MzP/aqOULnZHRsdqVmeTUzPVBtOWbC5nNmAGYoPf01OTNrfGdlpHZmeeXpOzL0/DVqmihs5MBqd2nsPXUzwHetQrTp6Hu29yduv/Z2Ofpu/WhrabZmeqmqQ3I4uTuHvmVmM3frfDEqPTIzPrNqgGopZ/lrtmTtvnY++TjqQQLqZHS1+Olwh3c4OtDuOWcrKLdmc2lmQg+3OTR/PuVqcXirfaqrfjK6vvhzAKombdDr82Uwezc9mbZhuKboZnPmdmRs+vU4OZTtQeWyaHdr+WipObl3fDy5velttPcpe+oqfDL5PXZqAKkpbXNr82xDvTI0CPfuOjIpaHNmeORmfzd2OXrv/W/lafNu0OlmOoF4vjS4fmpmAfdmdSoqfTIzPjNzFullZXlruWSmPjI8VrhqOoCqZHN982XmTjezPkBvfm+rqbhm+ukrQvl4+jzHvuVmLrVrfcQpL7GAPDZvv2ioZPqptmu1vLU5ibYtP+sop3MtdihpPzZ2OTqufW2laPNskOhmOgE2vTo3/GhlZHfmc6tq/TW5PXZqwOmpbTNq82oDvTI0iLfuQbOpaHQD9mRo//V3OTNuOWxC53NniGjmPj83fjuwfapl6/creiuq+jmQvbNrA6dpbHmquWSmPbI4uTdqO0Gp5HV9c2Tm+rY5OVCuOWeEZPNmjmRmOTY/OTNqgMrZqNzZ58XUnJczPTdqOWXV0+ZmdsD1+ydblSKpPW1lZHPU2NvZqaGnOTdxOWVlutjJ59PYOTY1OTNqsmVoZHNmc2RmXXI3STNqOcbTy9/LtcnasJeYp3TcnGVoZHNmc2TmlHI2OTNqOWXlxbNpc2RmOTIzOTNtOWVlZHNmhyRqPjIzOaDLrc1laHZmc2TWojI2OTNqOWXlyrNqf2RmOXZmfYvAfqi5s8WZc2h1OTIzm6Lfp8nO0tq41MjPrqUzPTdqOWXI0+Zmd2hmOTKmoqFqPXNlZHO94tbSnYaijJbcnsrTZHZmc2RmOTIjeDd2OWVlqKaqy7qrfIaCi2VqPWdlZHPec2dmOTIzOTN+eWlsZHNmvNe9mp6fOTd1OWVlqOXH6rDPp5emazNtOWVFY3JlYqVmOTIzOjNqOWVlZHNmc2RmOTIzOTNqOWVlZHxnc2R3OjIzQjOBbmVlZLlos2TmOzIz+TXqOWVoZHTD9WRovzRzOfmseWUs5jNreaemOTn2eTmwfKVlq3YneQHoOTQBu7VuBacmaVDoc2U1+7I4B/XsPWvopXOsNqVmwLXzPvot+WpsaDRr0GdmO0+2OTOwPKdl7/ZmcyvpeTi9/DbrACilav0p9uUxvDIzQLeqPy9oaPRtN6RsAzW3upDtuWbAZ3NmimRpuXh2ezPqPGVlJHbmc2RqOTNzPbNruWllZjNq82aCfjI2UDNquWbqZnOmeORpuTczPZCtOWqEZPNmfmRmOTY6OTNqj8rI2OLYc2hwOTIznJTXntfGtOLZc2hoOTIzsTNuO2VlZOxmd2ZmOTKtOTd1OWVl0uLY4MXSoqyYnTNuR2VlZMrV5dDKjaGGnKXPntNlaH9mc2SqbHaLj3itjbS3l3NqfGRmOYGhjJbcnsrTZHd1c2RmfaSUsHTcnLPK3Oey6dBmPDIzOTNq+belZHNmc2VmOTIzOTNqOWVlZHNmc2RmOTIzOTN8OmVlfXRmc2dmQUszOTMwOaVlarSmc6RnuTJQujNrVGZlZIrmc+RsenIzeTRqOoLmZHSn9GRmFnKzOgZqOWUypPNnhmVmOT+0OTW2+iVmwfRmdPAneTTQujNrh+bmZoxmNGZ9OTKzhnQrO8RmZHSFc+RmPzIzOTdxOWVlxebZ2NbaOTY+OTNqj8rI2OLYx93WnjI3cjNqOcbTy9/LtcnasJeYp22KsNfU0tqG1NbNrp+Yp6eKrd7VyeaGm5aGdYiYnKfZq6OFyevW2MfanpZcOTdwOWVl1OLS1NZmPDIzOTNqOWVlZ3Nmc2RmuZhzOTNqOWZlZHNmc2RmOTIzOTNqOWVlZHNmc2SCOjIzbjRqOWZlbcVmc2SsOXIzv7OqOQLl5HN/M6RnULIzubQqOWUApHNmiqRmubizeTMHueVlrvPm86qmejKQubNqQ6Vl5rkmtGTDubIzQ3NqvLBlZHNws2TqhDIzOT2quemwZHNmfaRmvnjzezPxOaZlwXNndHumO7K6enVqAGYoZv2nNmftunQzADQtO+/mJ3btdKZmADP2Oz5sOWXvZfVp1eRmORXzNbKw+adl6/Onc8FmOjNKeTXqwKanZDpnNmbwevU2wLSsOSxmJ3Xw9CdpwDN1Ofpr/GdwZnNm/WXoPJSzOTNN+WHkq3Ooc+omfDK6OXZrBGVlZL0mc2WtuXQzv/OtOexlp3Sw86dngHJ1ObkqfGXsZLZnvaSpOn5zfTPHuWVmbrNm+6rmfTLYOTNqlqVlZbkmt2TDubIzkTMvOXzlZPOss6lm3nIzOZCqOWaEZPNmiWRmOTY6OTNqjMrI1tjac2hsOTIzrIfTpsplaIJmc2StnqZ8p3rLpsq5zeDL5WRpOTIzOTMqm6VpbXNmc9erp5egopjdOWl0ZHNmusnafqCYpqyyntfUyeZmd2xmOTKmep/WosrYZHd0c2RmgJenep/Wsq3K1uLL5mRqQDIzOaPZotPZ13NqeGRmOZqcoJtqPW1lZHPK3NfWpZOsOTdwOWVl1NTP5ddmPTwzOTPYntnc0+XRvKhmPDIzOTNqOWVlaHZmc2S0qDI3QDNqOdLerNjY4mRqPDIzOaa3OWlqZHNmwMnUrjI3STNqOabJyLfY1Nupmp6fm5TNpGVpbnNmc6vLrYSYoJzZp2VpaHNmc9nUpDI3TDNqOabJyMHL6rTHrZp2mp/Wm8bIz3Noc2RmajMzOWRrOWVlZHVqc2RmPjIzOT9qeWWCpHNnkmTmOTMzOTNuPmVlZLfY1NtmOTIzOTRqOWVmZHNmc2RmOTIzOTNqOWVlZHOZdGRmbDMzOTpqSXBlZHMrdGRmBTPzPHNsOWXlZvNmM2ZmOjI2uTSqPGVn5HbmdSRpOTUQerNuWGXlZHRmc2RqQzIzOYLYh8rctNTa22RmOTIzOjNqOWZlZHNmc2RmOTIzOTNqOWVlZHRmc2RmOTIzOTNqOWVlZHNmc2RmOTJpOjNqeWZlZHRmdWVmOTJSObNqOWVlZHNmc2RmOTIzOTNqOWVlZHNmc2RmOTIzOXVrOWWrZXNmdGRpPzIzOXlqeWXC5PNm+qSmOcCzuTMJOWVmg3Pmc2ZmOTI3SDNqOazK2LzUusXTnoacppjcOWlrZHNm5rjPppczOTNqOWZlZHNmc2RmOTIzOTNqOWVlZHNmc2SuOjIzmTRqOW1ldL1mc2RtO/Izf3WqOaxnJHd+s2ZqUPJDuTnseWWsJrNm+mYnOXm1uzeHO2Zme3Np86qpejJ6vPRwlujlZMEpNGp/eTU5ULNruatopnOttiZswPVzOfpt+mXsJ3ZtM2fmPo92uTSMu2VlB3Vi8mpoezI6u3VugCelZPpoNGStu7Q3v3WrOeznpXgDdeRmVnQzOTose2WsZjRm+iaoOfk1+jPx+2dqKzWmc2tp+jL6O7ZvDmflaYwmdWl9eTOzwPWqOSxnJXPtNWZrzjQzPs6sOWV85HPm+iaoOfk1+jPx+2dqbvXod2soezJ6O/RqQKdnaI1mdep9+TKzQHWtOaxnJXNw9SdqUPI0uTose2WsZjRmeqZoPUszu7qBuWXla7Wpc6to+jI9O/duWGXlZIRmc2RqPjIzOafjqcplaHpmc2TTsnqYq6JqPWtlZHPW1M3YrDI3QDNqOdXUzeHa5mRqQzIzOaHPrdzU1t6vt2RqPDIzOaLdOWlrZHNm1tDVnJ0zPDNqOWVlZIOmd2pmOTKnmpXWnmVpa3Nmc9bLpqGpnjNuQGVlZNzU5snYrTI3PjNqOc3Oy9tmdmRmOTIzOXyqPW1lZHPK3NfWpZOsOTdvOWVlvdjZlGRpOTIzOTNqfaVpanNmc7HHspSYOTNqOWVmZHNmc2RmOTIzOTNqOWVlZHNmc2RmmzMzObFrOWVmZIMZc2RmfzJzObSqOWXC5HNnzqRmOUkzObOJOeVlqjOmc6vm+TK0OTRq/yWlZDqmNGVDObIzlrNqOW2lZPSs86VmhfL0OZDqOWbr5LRm/ySnOs+zOTT4uWXpffPmc3tmP7J5eXVquuVnZDkmtWRsOnUzQHStO6vmpXOyNCVolrMzOoGrOumCZXNnUORmOTO0PDMAOWZmJTNpc2VnPTJ0ejdqv+apZDQnd2Rn+zYzejVvOeZnaXMDdORolnIzOXZquWXEZHNnuaSrObOzPjMruWplZXRoc6XnPjK0+jhq/+apZHRoeWSnuzczurVvOSbnaXNDdORolnIzOXmqe2XmpHlmNCRpOTO0PzOremll6vSqcyVnPjI0+zdqeidpZPToeGQDOrI1lnNqOaulpnPsM6pmwDJ6OvSqQGVrJbVmuuWtObj0fzPx+qxoq/TndeVnQTL6entqPyerZHooumgtOrQ2j/TrO4LmZHT8c2Vn+rI7OTQrQWWmZXxm+eWqOfP0PTNr+2llpXVrc+VoPjLQOrNslqVlZLmmvGTtuXszljNrOnxlbPPstKZmADP6OzSsQGWrJrVm+uatOfn1ADXx+2dqJXVuc2upgTJ6/PpsQKhoaglodmnDuzI0D3TsPGbnbHOnNW1myDR9O8CsfWor5rdmdCdqOXl2gTPx/Cxnq/bpeX6mvMZKuTPqeihpZM6pc2R9OTKzerZ0OeYobnMnNm5mFjSzO9CrOWXH5HNmVmRduHhzgjPxObBlwXNndHtmQbK5enVqAGYsZnSoemSs+3QzwLWxOSwnK3XtNWZr+jQ7OTqtgWWsJzpoeqdpP8g1PDjHu2VmOrTodmXoQTJ0+ztqyGevZgBovGksu3YzOvZuOaaob3PttqxmAPX6O7otPGx/5Pb6iuRmubP2PTMFfGVle3Nm8+XpQzL0/D1qFmflZhCnc2TIuTIzHDNhuIRl5HOUc2RmPTwzOTOzrLDK3bfV6tJmPDIzOTNqOYelaHhmc2TKmqaYOTdtOWVl0+Zmd2dmOTJdrTNuPmVlZOfP4MlmPTkzOTO9nsjXyedmd2xmOTKlmqG+otLKZHZmc2RmOTKseTdzOWVlqOXH6rjLsaYzPU5qOWWrzeXZ54S5nKScqafPq4W3yePV5diGoqBtWTNuQmVlZOfV5tjYoqCaOTdvOWVl0dTa22RqPzIzOZnWqNTXZHdyc2RmWYWYnKLYndiTkqFmdmRmOTIzOWuqPGVlZHNmc4ymPDIzOTNqOZOlaHhmc2Sni3l1OTZqOWVlZFPVs2dmOTIzOfPVeWluZHNmt9bHsH6cp5hqPGVlZHNmc2RmPDIzOTNqCdulZ3Nmc2RmeZdzPT5qOWW00tiG4sqGjqVyOTZqOWVlZLPGs2htOTIzpqyyntfUZHdvc2RmnJqUq4HLpsplaHZmc2SgWTI3QTNqOcnO1+PS1N1mPTwzOTPYntnc0+XRvKhmPTQzOTOKOWlqZHNm283NoTI2OTNqOWVllrNpc2RmOTIzhHNtOWVlZHNmt6RqPzIzOaPLotfYZHdvc2RmrHehnqDTnthlZ3Nmc2RmOZtzPDNqOWVlZKymdmRmOTIzOXyqPGVlZHNm08emPDIzOTNqOZ+laHtmc2TZep6fopjdOWhlZHNmc2SceTIzOTNrOWVlZHNmc2RmOTIzOTNqOWVlZHNmdGRmOTMzOTNqOWVlZHNmc2RmOTIzOQ==")
_G.ScriptENV = _ENV
SSL({102,228,218,164,160,120,115,122,35,211,190,205,121,24,123,84,222,98,176,104,92,202,235,41,153,93,76,130,57,27,159,231,155,39,77,86,33,234,183,166,239,60,32,162,8,197,242,116,191,106,68,46,44,15,79,85,241,1,168,119,31,66,83,7,14,90,12,208,207,64,114,97,73,216,178,219,108,87,105,226,138,253,195,37,29,238,118,229,182,206,113,194,59,188,175,140,112,230,170,38,88,203,34,144,13,54,245,204,133,22,65,82,152,192,50,4,254,232,128,42,124,52,198,11,56,5,129,6,103,167,186,212,220,151,21,10,17,233,147,51,96,69,141,193,149,223,214,157,142,62,134,58,18,100,255,139,246,117,199,67,23,248,3,25,177,20,143,95,184,173,200,9,224,154,145,71,43,81,55,89,225,125,180,127,53,196,48,26,187,63,250,217,210,209,40,161,181,2,227,47,49,126,30,237,61,146,80,163,131,36,72,236,247,132,252,74,189,169,75,213,150,174,158,94,179,172,156,171,215,107,165,110,45,136,109,99,91,221,148,243,101,185,251,28,78,111,201,70,244,249,240,135,137,16,19,231,231,231,231,38,88,230,254,34,197,50,88,4,144,65,65,245,166,239,211,231,231,231,231,13,203,231,38,88,230,254,34,197,34,88,4,13,22,203,65,166,50,4,192,13,22,34,197,170,144,112,192,239,197,128,144,112,4,231,5,31,231,183,12,183,231,4,144,88,22,231,82,192,13,22,4,166,183,207,192,192,65,192,231,13,22,231,219,65,112,38,13,22,34,1,183,197,197,191,239,231,192,88,4,254,192,22,231,88,22,38,211,231,231,231,231,13,203,231,38,88,230,254,34,197,34,88,4,13,22,203,65,166,50,4,192,13,22,34,197,230,124,4,88,239,197,128,144,112,4,231,5,31,231,183,12,183,231,4,144,88,22,231,82,192,13,22,4,166,183,207,192,192,65,192,231,13,22,231,219,65,112,38,13,22,34,1,183,197,197,106,239,231,192,88,4,254,192,22,231,88,22,38,211,231,231,231,231,13,203,231,38,88,230,254,34,197,34,88,4,13,22,203,65,166,50,4,192,13,22,34,197,50,254,230,239,197,128,144,112,4,231,5,31,231,183,12,183,231,4,144,88,22,231,82,192,13,22,4,166,183,207,192,192,65,192,231,13,22,231,219,65,112,38,13,22,34,1,183,197,197,68,239,231,192,88,4,254,192,22,231,88,22,38,211,231,231,231,231,13,203,231,38,88,230,254,34,197,34,88,4,13,22,203,65,166,50,4,192,13,22,34,197,50,254,230,239,197,128,144,112,4,231,5,31,231,183,12,183,231,4,144,88,22,231,82,192,13,22,4,166,183,207,192,192,65,192,231,13,22,231,219,65,112,38,13,22,34,1,183,197,197,46,239,231,192,88,4,254,192,22,231,88,22,38,211,231,231,231,231,13,203,231,38,88,230,254,34,197,34,88,4,13,22,203,65,166,38,88,230,254,34,197,34,88,4,13,22,203,65,239,197,128,144,112,4,231,5,31,231,183,12,183,231,4,144,88,22,231,82,192,13,22,4,166,183,207,192,192,65,192,231,13,22,231,219,65,112,38,13,22,34,1,183,197,197,44,239,231,192,88,4,254,192,22,231,88,22,38,211,231,231,231,231,13,203,231,38,88,230,254,34,197,34,88,4,13,22,203,65,166,38,88,230,254,34,197,50,88,4,144,65,65,245,239,197,128,144,112,4,231,5,31,231,183,12,183,231,4,144,88,22,231,82,192,13,22,4,166,183,207,192,192,65,192,231,13,22,231,219,65,112,38,13,22,34,1,183,197,197,15,239,231,192,88,4,254,192,22,231,88,22,38,211,231,231,231,231,13,203,231,38,88,230,254,34,197,34,88,4,13,22,203,65,166,114,88,4,118,88,230,253,88,50,254,204,4,239,197,128,144,112,4,231,5,31,231,183,12,183,231,4,144,88,22,231,82,192,13,22,4,166,183,207,192,192,65,192,231,13,22,231,219,65,112,38,13,22,34,1,183,197,197,79,239,231,192,88,4,254,192,22,231,88,22,38,211,231,231,231,231,13,203,231,38,88,230,254,34,197,34,88,4,13,22,203,65,166,38,88,230,254,34,197,34,88,4,13,22,203,65,239,197,203,254,22,170,231,5,31,231,38,88,230,254,34,197,34,88,4,13,22,203,65,231,4,144,88,22,231,82,192,13,22,4,166,183,207,192,192,65,192,231,13,22,231,219,65,112,38,13,22,34,1,183,197,197,85,239,231,192,88,4,254,192,22,231,88,22,38,211,231,231,231,231,13,203,231,38,88,230,254,34,197,34,88,4,204,65,170,112,204,166,38,88,230,254,34,197,34,88,4,13,22,203,65,162,191,239,231,4,144,88,22,231,82,192,13,22,4,166,183,207,192,192,65,192,231,13,22,231,219,65,112,38,13,22,34,1,183,197,197,241,239,231,192,88,4,254,192,22,231,88,22,38,211,231,231,231,231,13,203,231,38,88,230,254,34,197,34,88,4,13,22,203,65,166,253,88,112,38,208,118,105,253,208,239,197,128,144,112,4,231,5,31,231,183,12,183,231,4,144,88,22,231,82,192,13,22,4,166,183,207,192,192,65,192,231,13,22,231,219,65,112,38,13,22,34,1,183,197,197,191,116,239,231,192,88,4,254,192,22,231,88,22,38,211,231,231,231,231,13,203,231,82,112,170,245,112,34,88,197,204,65,112,38,88,38,197,38,88,230,254,34,197,34,88,4,13,22,203,65,166,253,88,112,38,208,118,105,253,208,239,197,128,144,112,4,231,5,31,231,183,12,183,231,4,144,88,22,231,82,192,13,22,4,166,183,207,192,192,65,192,231,13,22,231,219,65,112,38,13,22,34,1,183,197,197,191,191,239,231,192,88,4,254,192,22,231,88,22,38,211,231,231,231,231,13,203,231,82,112,170,245,112,34,88,197,204,65,112,38,88,38,197,38,88,230,254,34,197,34,88,4,13,22,203,65,166,114,88,4,118,88,230,253,88,50,254,204,4,239,197,128,144,112,4,231,5,31,231,183,12,183,231,4,144,88,22,231,82,192,13,22,4,166,183,207,192,192,65,192,231,13,22,231,219,65,112,38,13,22,34,1,183,197,197,191,106,239,231,192,88,4,254,192,22,231,88,22,38,211,231,231,231,231,13,203,231,253,88,112,38,208,118,105,253,208,166,4,65,22,254,133,230,88,192,166,50,4,192,13,22,34,197,50,254,230,166,4,65,50,4,192,13,22,34,166,38,88,230,254,34,197,34,88,4,13,22,203,65,239,162,191,191,162,191,85,239,162,191,15,239,231,32,231,46,239,231,5,31,231,68,241,15,79,241,46,116,85,68,15,231,4,144,88,22,231,82,192,13,22,4,166,183,207,192,192,65,192,231,13,22,231,219,65,112,38,13,22,34,1,183,197,197,191,68,239,231,192,88,4,254,192,22,231,88,22,38,211,231,231,231,231,13,203,231,253,88,112,38,208,118,105,253,208,166,4,65,22,254,133,230,88,192,166,50,4,192,13,22,34,197,50,254,230,166,4,65,50,4,192,13,22,34,166,204,65,112,38,239,162,191,191,162,191,85,239,162,191,15,239,231,32,231,46,239,231,5,31,231,68,241,15,85,116,79,191,241,116,85,231,4,144,88,22,231,82,192,13,22,4,166,183,207,192,192,65,192,231,13,22,231,219,65,112,38,13,22,34,1,183,197,197,191,46,239,231,192,88,4,254,192,22,231,88,22,38,211,231,231,231,231,13,203,231,253,88,112,38,208,118,105,253,208,166,4,65,22,254,133,230,88,192,166,50,4,192,13,22,34,197,50,254,230,166,4,65,50,4,192,13,22,34,166,204,65,112,38,203,13,204,88,239,162,191,191,162,191,85,239,162,191,15,239,231,32,231,46,239,231,5,31,231,191,46,191,241,106,191,191,191,116,231,4,144,88,22,231,82,192,13,22,4,166,183,207,192,192,65,192,231,13,22,231,219,65,112,38,13,22,34,1,183,197,197,191,44,239,231,192,88,4,254,192,22,231,88,22,38,211,231,231,231,231,13,203,231,253,88,112,38,208,118,105,253,208,166,4,65,22,254,133,230,88,192,166,50,4,192,13,22,34,197,50,254,230,166,4,65,50,4,192,13,22,34,166,38,65,203,13,204,88,239,162,191,191,162,191,85,239,162,191,15,239,231,32,231,46,239,231,5,31,231,106,68,68,106,44,85,79,46,116,68,231,4,144,88,22,231,82,192,13,22,4,166,183,207,192,192,65,192,231,13,22,231,219,65,112,38,13,22,34,1,183,197,197,191,15,239,231,192,88,4,254,192,22,231,88,22,38,211,231,231,231,231,13,203,231,38,88,230,254,34,197,34,88,4,13,22,203,65,166,204,65,112,38,239,197,128,144,112,4,231,5,31,231,183,12,183,231,4,144,88,22,231,82,192,13,22,4,166,183,207,192,192,65,192,231,13,22,231,219,65,112,38,13,22,34,1,183,197,197,191,79,239,231,192,88,4,254,192,22,231,88,22,38,211,231,231,231,231,13,203,231,38,88,230,254,34,197,34,88,4,13,22,203,65,166,114,88,4,29,50,88,192,239,197,128,144,112,4,231,5,31,231,183,12,183,231,4,144,88,22,231,82,192,13,22,4,166,183,207,192,192,65,192,231,13,22,231,219,65,112,38,13,22,34,1,183,197,197,191,85,239,231,192,88,4,254,192,22,231,88,22,38,211,231,231,231,231,13,203,231,38,88,230,254,34,197,34,88,4,13,22,203,65,166,4,112,230,204,88,197,170,65,22,170,112,4,239,197,128,144,112,4,231,5,31,231,183,12,183,231,4,144,88,22,231,82,192,13,22,4,166,183,207,192,192,65,192,231,13,22,231,219,65,112,38,13,22,34,1,183,197,197,191,241,239,231,192,88,4,254,192,22,231,88,22,38,211,231,231,231,231,13,203,231,77,195,170,192,13,82,4,12,65,38,88,231,5,31,231,191,46,241,68,44,231,4,144,88,22,231,82,192,13,22,4,166,183,207,192,192,65,192,231,13,22,231,219,65,112,38,13,22,34,1,183,197,197,106,116,239,231,192,88,4,254,192,22,231,88,22,38,211,231,231,231,231,13,203,231,238,73,226,175,29,195,207,253,231,112,22,38,231,22,65,4,231,12,219,65,219,226,112,170,245,88,4,231,4,144,88,22,231,82,192,13,22,4,166,183,207,192,192,65,192,231,13,22,231,219,65,112,38,13,22,34,1,183,197,197,106,191,239,231,192,88,4,254,192,22,231,88,22,38,211,231,231,231,231,13,203,231,238,73,226,175,29,195,207,253,231,112,22,38,231,4,124,82,88,166,12,219,65,219,226,112,170,245,88,4,239,231,5,31,231,183,254,50,88,192,38,112,4,112,183,231,4,144,88,22,231,82,192,13,22,4,166,183,207,192,192,65,192,231,13,22,231,219,65,112,38,13,22,34,1,183,197,197,106,106,239,231,192,88,4,254,192,22,231,88,22,38,211,231,231,231,231,13,203,231,38,88,230,254,34,197,34,88,4,13,22,203,65,166,65,50,197,34,88,4,88,22,232,239,197,128,144,112,4,231,5,31,231,183,12,183,231,4,144,88,22,231,82,192,13,22,4,166,183,207,192,192,65,192,231,13,22,231,219,65,112,38,13,22,34,1,183,197,197,106,68,239,231,192,88,4,254,192,22,231,88,22,38,211,211,231,231,231,231,204,65,170,112,204,231,12,254,192,226,65,50,231,31,116,211,231,231,231,231,204,65,170,112,204,231,178,88,124,226,65,50,231,31,231,116,211,231,231,231,231,204,65,170,112,204,231,178,88,124,231,31,231,183,38,50,203,50,38,203,241,106,68,241,68,54,241,88,88,183,211,231,231,231,231,204,65,170,112,204,231,12,65,38,88,231,31,231,175,114,197,195,170,192,13,82,4,12,65,38,88,211,231,231,231,231,204,65,170,112,204,231,195,4,192,13,22,34,90,124,4,88,231,31,231,50,4,192,13,22,34,197,230,124,4,88,211,231,231,231,231,204,65,170,112,204,231,195,4,192,13,22,34,12,144,112,192,231,31,231,50,4,192,13,22,34,197,170,144,112,192,211,231,231,231,231,204,65,170,112,204,231,195,4,192,13,22,34,195,254,230,231,31,231,50,4,192,13,22,34,197,50,254,230,211,231,231,231,231,204,65,170,112,204,231,37,65,219,65,112,38,231,31,231,203,254,22,170,4,13,65,22,166,239,211,231,231,231,231,231,231,231,231,178,88,124,226,65,50,231,31,231,178,88,124,226,65,50,231,32,231,191,211,231,231,231,231,231,231,231,231,13,203,231,178,88,124,226,65,50,231,66,231,77,178,88,124,231,4,144,88,22,231,178,88,124,226,65,50,231,31,231,191,231,88,22,38,211,231,231,231,231,231,231,231,231,12,254,192,226,65,50,231,31,231,12,254,192,226,65,50,231,32,231,191,211,231,231,231,231,231,231,231,231,13,203,231,12,254,192,226,65,50,231,66,231,77,12,65,38,88,231,4,144,88,22,211,231,231,231,231,231,231,231,231,231,231,231,231,192,88,4,254,192,22,231,183,183,211,231,231,231,231,231,231,231,231,88,204,50,88,211,231,231,231,231,231,231,231,231,231,231,231,231,204,65,170,112,204,231,87,88,128,90,124,4,88,231,31,231,195,4,192,13,22,34,90,124,4,88,166,195,4,192,13,22,34,195,254,230,166,12,65,38,88,162,12,254,192,226,65,50,162,12,254,192,226,65,50,239,239,231,8,231,195,4,192,13,22,34,90,124,4,88,166,195,4,192,13,22,34,195,254,230,166,178,88,124,162,178,88,124,226,65,50,162,178,88,124,226,65,50,239,239,211,231,231,231,231,231,231,231,231,231,231,231,231,13,203,231,87,88,128,90,124,4,88,231,119,231,116,231,4,144,88,22,231,87,88,128,90,124,4,88,231,31,231,87,88,128,90,124,4,88,231,32,231,106,44,15,231,88,22,38,211,231,231,231,231,231,231,231,231,231,231,231,231,192,88,4,254,192,22,231,195,4,192,13,22,34,12,144,112,192,166,87,88,128,90,124,4,88,239,211,231,231,231,231,231,231,231,231,88,22,38,211,231,231,231,231,88,22,38,211,231,231,231,231,204,65,170,112,204,231,175,207,87,238,231,31,231,175,114,197,195,170,192,13,82,4,207,87,238,231,65,192,231,198,175,114,231,31,231,175,114,56,211,231,231,231,231,204,65,112,38,166,37,65,219,65,112,38,162,22,13,204,162,183,230,4,183,162,175,207,87,238,239,166,239,211,231,231,231,231,37,65,219,65,112,38,231,31,231,203,254,22,170,4,13,65,22,166,239,231,88,22,38,211,35,8,8,175,114,197,114,88,4,29,50,88,192,106,231,31,231,22,13,204,211,196,223,65,176,184,134,178,135,221,15,33,32,72,69,87,61,206,61,120,76,117,87,139,191,208,178,199,75,206,9,92,98,60,203,89,238,32,203,179,200,201,77,48,171,51,102,164,253,164,59,93,32,92,191,58,199,146,10,188,83,121,2,114,199,244,200,146,127,215,174,234,166,184,184,233,13,107,105,157,45,161,122,135,107,231,138,228,69,55,73,9,28,199,135,230,175,101,100,248,137,44,139,222,17,170,150,107,12,210,49,199,153,227,40,138,84,108,72,110,178,216,65,147,119,253,183,42,91,92,203,113,202,125,104,128,81,251,178,125,40,50,156,14,32,4,102,134,46,130,220,149,251,97,234,241,55,144,14,146,180,144,121,123,3,115,120,226,249,115,176,40,229,204,47,215,130,8,19,22,244,104,35,165,75,124,119,2,156,95,238,60,52,223,119,117,248,136,8,18,93,101,25,96,74,21,168,71,167,213,96,167,140,31,13,222,39,24,213,13,204,189,60,121,175,229,223,133,195,118,171,22,251,133,2,165,43,128,45,233,87,222,134,16,245,53,176,228,93,114,177,67,44,84,45,1,255})
