--[[
Ralphlol's Utility Suite
Updated 5/16/2015
Version 1.02
]]

function Print(msg) print("<font color=\"#A51842\">Ralphlol's Utility Suite:  </font><font color=\"#FFFFFF\">"..msg) end

function OnLoad()
    local ToUpdate = {}
    ToUpdate.Version = 1.02
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
	if p.header == 200 then	
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
	self.sEnemies = GetEnemyHeroes()
	self.lastpos={}
	self.lasttime={}
	self.next_wardtime=0
	self.wM = self:Menu()
	for _,c in pairs(self.sEnemies) do
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
	for _,c in pairs(self.sEnemies) do		
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

--------------------------------------------------------------------------------------------
_G.ScriptCode = Base64Decode("fL/ZwsVndGpoaXozS/lxO3t9ZGFzZ3NmZGVyNDv1ZTFhmGRhc29zZuRr8nMyg+SxYXtk4fNyc2ZksHIzMuwkcWFYpGFz8TNm5gryMzJu5LHj/mRhc2/zZucKMjMybuSx5PkkoXNMc2dk7zIztgukMmF75OH3DPNnZG3yM7fxZDFhe+Th+PKzZ2Tv8va48GT16P3kJfvxcyvt7/L3vG7kMef55KZz7jOrZSvyeDItZPdieeWmc260rGar83gyreX3Y/5lbXPxtK3y7zN6wfClefH9JakE8bSv9u8zfMXwpXv1/SWrCPG0sfrvM37J8KV9+f0lrQzxtLP+7zOAzfBl//b95S8P8XQ1Ae/zAtDwZQEA/aWxEPE0tgXvs4TU8CWCBP0lrxfx9DgI73MG1/DlBAf9ZTUa8fQ6DO9zCNvw5QYL/aUwHvG0vBDvM4nf8KWID/0luCLxtL4U7zOL4/ClihP9JbAm8XRAF+/zDebwZQwW/eU8KfF0Qhvvsw/A8OUN9/1lMyzxdMMJ77MQ3vDljhX9Jb4R8bTEIO8zke/wpZAf/eWxLfF0xCPvcxPx8OURIf1lQjTx9Ecm73MV9fDlEyX9ZTI48fTEKu/zFvjwZRUo/eVFO/F0Sy3v8xj88GUXLP3lMj/xdMUx73Ma//DlGC/9ZUlC8fRONO8zG8HwZRr4/SU0RfE0xgrv8xzf8CWaFv1lyxLxtNAk7/Od+fAlmy/9pTMt8fTFOe+zngjwJZw4/WVNRPH0Ujzvcx4L8KWeO/0ls07xNEU/77OhDvAlnz79pdBR8TTVQ+/znhLw5SFB/aU0VPG0xkbv8yQU8GUjRP3lU1fxdFlJ7/MgGPDlJPX9JTZa8TRIB+9zp93wpSUT/eXVD/E0WiLvs5/38GWmLf2ltSzxtEc577MoDPDlpkL9JdZF8XTcTu8zHx7wpadO/SW1WvE0R1Hvs6og8CWoUP2l2WPxNN5V73OgJPDlJ1P9pbZm8bRIV++zrSbwJatW/aXcafE04VvvcyLD8OX5+v3lOBPxtMoM73Mv4fClrRj95V0u8TTiJu8zoPvwZXgx/WW3R/F0yTzvczAQ8CWnRv2l3lzx9GNP73MhIvDl+Ff95bds8bRJXu9zMS3wZShd/SXecPF0ZWHv8yEw8GV5YP1lOHIodKZk7zMWNSelcWF05qFz8XToZyYzczLw5ShkNGWic/G0ZGcms3QyZ+ZyYf1l43bxNFb27/P9zPDlCgL9pcccKDSnZO8ztOLwZakZ/eVfLyh0qGTvMzT18OWgK/1lqkTxdD447zOXCyelc2H9JeJS8fTeSu8zMRsn5XNh/SViX/F0VlXv8/wp8OUJWv2lxm4oNKhk7zM0MCflcmH9ZVp2KHSoZO+zMjUn5XNhdGakc/F06Gcmc3Yy8KUhZDSlpHPxdDBnJvN2MvBlCmQ0JaRz8TRLZyZzdzJnpnVh/WXjdij0qmTvsyw1JyV1Yf3lYHYodKtkZrR2MvBls2T9pVMGKLSrZO/z/zXwpQwD/SXIHSj0q2TvM7Tj8OUq/P0lYDAo9Klk7zM09vBloiz9ZSwr8TS/N+/zGQgnJXZh/SXiT/E030cmc3My8CUySTQlpHPxNOdO77MkIPDl/FX9pbtr8TTMXiZzeTLwJTJdNOWhc/F0YGcmM3QyZ6ZxYf1l43YotKhkZnR3MvBls2Q0JaNz8TRXZyazdzLwZf1kNOWmc/E0QGcmM3gy8KUYZDRlp3Notaxk73O1NSeld2H95Vt2KPSsZGY0czLwZbNkNCWnc2j1qmTvc7U1J6V2Yf0l4gPxNFn877OB0vAljQj9pUohKPSsZO8zNOjwZawcNGWic/E0ZyUmM3cy8CUyKf0l00LxdDM37zMOCfClGT40Jadz8TRnSO/zLhonpXJh/SViXih0q2TvM7Qh8KUkVv3lLmtv8+fx6zNzMidleGGYJmJz8XToZ+azejJLZTNheyRiduj0rWRKszUybiQyZPQlqHNM9GhkbTI0NedleWFYJWNzbzNnZ+azezLs5TJhNOWpcwS0ZmXm83sy7OUyYTQlqXOMdWlk73O1NefleWH55WJzKHSvZIq0NjLwZbNk9OWpc+30Z2Qms3wyi+Y0Yf1l43bo9K5k6/M0MiflemGYJmRz8XToZ+bzezLs5TJhWGVlc/E0Z+iEcrMyjWUxYXdmYXNn2WZobnIzMtmpn8bgzcbmZ3d1ZGVyepfaqZ/G4N2p2Nniy9dldj4yZmSjxtbFzd+r5cfbZXY4MmZkhcrWz2F3c3NmZMrCpZfKzZTV3NPPc2t9ZmRl1pyky8elyuLSYXd+c2ZkuuKXk9rJds/Y0crY2rfP1srVp5vV0jFleGRhc6vlx9tldkUyZmR109TbpNzZ1tLJs9erprLanWF3cGFzZ7fYxdy1nKTJ0JaTc2hvc2dzx8fZ26mXuMmUwt/Q1HNrf2ZkZeSYlcfQnbXc0cbmZ3dtZGVypZfJxZ3Nc2f7DAAM//2Esjc9ZmQx0NfNz+XM1sfQ0XI2zP/9yvoMdaF3enNmZNTWnKDYyZTC39DK4Nfl1drK1jM1mZdklKaXcLNrgmZkZeSYlcfQncrg1NPi3djKZGgMzMv//cp8s2htc2dz2dnV16Wky8eSzd9kZXlnc2bGzuZmZGZoOGFzZM3mz9zM2GV2OjJmZKPU283H52d3a2RlcpWT1MgxZXhkYXPJ69XWZXY7MmZkeqW13dXY2nNpZGVyMzJmZDFkc2Rhc2fzrKRocjMyZmQxUbJnYXNnc2akuLI2MmZkMWFzZKF2Z3NmZGUSoHJpZDFhc2Rhe6d2ZmRlcjPSx6Q0YXNkYXNng6ZnZXIzMmYElqF2ZGFzZ3NmeKV1MzJmZDEB3KRkc2dzZmRlinM1ZmQxYXPkvLNqc2ZkZXIzTqZnMWFzZGFzk7NpZGVyMzJmhHFkc2Rhc2dzraRocjMyZmQxg7NnYXNnc2bkuLI2MmZkMWFziKF2Z3NmZGUyoHJpZDFhc2Rhmad2ZmRlcjPyx6Q0YXNkYXNnm6ZnZXIzMmYklqF2ZGFzZ3NmjqV1MzJmZDGh3aRkc2dzZmQlznM1ZmQxYXNkj7Nqc2ZkZXIzZaZnMWFzZGFzl7NpZGVyMzLmrXFkc2Rhc2dzl6RocjMyZmTxtbNnYXNnc2Zkl7I2MmZkMWFT0aF2Z3NmZGVSlHJpZDFhc2Rhp6d2ZmRlcjMSy6Q0YXNkYXNnqKZnZXIzMmZEmqF2ZGFzZ3NmmqV1MzJmZDFhz6Rkc2dzZmRlqXM1ZmQxYXNkmbNqc2ZkZXIzeqZnMWFzZGFzoLNpZGVyMzJmuHFkc2Rhc2dzoKRocjMyZmQxz7NnYXNnc2ZkoLI2MmZkMWFzxqF2Z3NmZGVyb3JpZDFhc2Rh2ad2ZmRlcjMyo6Q0YXNkYXNn3aZnZXIzMmZkb6F2ZGFzZ3OmwKV1MzJmZDFhsqRkc2dzZmRlsnM1ZmQxYXPkqbNqc2ZkZXKzcqZnMWFzZGGzu7NpZGVyMzJmpXFkc2Rhc2eT1KRocjMyZmSxorNnYXNnc2aEx7I2MmZkMWFzpqF2Z3NmZGWSmXJpZDFhc2Thtad2ZmRlcjNS0KQ0YXNkYXNntqZnZXIzMmbkjaF2ZGFzZ3Pmp6V1MzJmZDFht6Rkc2dzZmRlu3M1ZmQxYXPkpbNqc2ZkZXKzhqZnMWFzZGFzrLNpZGVyMzKm0nFkc2Rhc2fzq6RocjMyZmRxw7NnYXNnc2Zkq7I2MmZkMWGzyqF2Z3NmZGUynXJpZDFhc2Qh0Kd2ZmRlcjOyraQ0YXNkYXPnvqZnZXIzMmYkhqF2ZGFzZ3PG0qV1MzJmZDHB1aRkc2dzZmRlvHM1ZmQxYXPEx7Nqc2ZkZXKzfKZnMWFzZGHT0bNpZGVyMzJmr3Fkc2Rhc2dzw6RocjMyZmQxrbNnYXNnc2bksbI2MmZkMWFzuaF2Z3NmZGVygHJpZDFhc2Th4ad2ZmRlcjOys6Q0YXNkYXPn1aZnZXIzMmZkf6F2ZGFzZ3PmyqV1MzJmZDHhwaRkc2dzZmTl3HM1ZmQxYXNksLNqc2ZkZXJzj6ZnMWFzZGHztrNpZGVyMzJmtHFkc2Rhc2eztqRocjMyZmRxtrNnYXNnc2bktbI2MmZkMWET0qF2Z3NmZGUyg3JpZDFhc2QB1ad2ZmRlcjMyt6Q0YXNkYXMH2aZnZXIzMmakgqF2ZGFzZ3MGzqV1MzJmZDHhxKRkc2dzZmTlz3M1ZmQxYXMksrNqc2ZkZXIzhKZnMWFzZGGzubNpZGVyMzLmuXFkc2Rhc2fzuKRocjMyZmTxz7NnYXNnc2Ykt7I2MmZkMWEzxqF2Z3NmZGVyhnJpZDFhc2Qh2ad2ZmRlcjPyvKQ0YXNkYXMn0aZnZXIzMmYkhKF2ZGFzZ3NGzqV1MzJmZDFB4aRkc2dzZmRF1HM1ZmQxYXNEx7Nqc2ZkZXIziKZnMWFzZGFzxbNpZGVyMzKmunFkc2Rhc2dz0aRocjMyZmSxt7NnYXNnc2Zk1LI2MmZkMWFzx6F2Z3NmZGVyinJpZDFhc2Rh2qd2ZmRlcjNyvaQ0YXNkYXPnyqZnZXIzMmakj6F2ZGFzZ3Mmu6V1MzJmZDFhy6Rkc2dzZmSlynM1ZmQxYXOEzLNqc2ZkZXKziqZnMWFzZGGT1rNpZGVyMzImvHFkc2Rhc2eTyaRocjMyZmQxurNnYXNnc2aEzLI2MmZkMWGzvaF2Z3NmZGXyjHJpZDFhc2Th0ad2ZmRlcjPyv6Q0YXNkYXNnzaZnZXIzMmaki6F2ZGFzZ3Omz6V1MzJmZDHhzaRkc2dzZmSl4XM1ZmQxYXMku7Nqc2ZkZXJzlaZnMWFzZGFzwrNpZGVyMzKmy3Fkc2Rhc2ezwaRocjMyZmTxwLNnYXNnc2YkwLI2MmZkMWHTz6F2Z3NmZGXSonJpZDFhc2TB1qd2ZmRlcjOSzaQ0YXNkYXNn0qZnZXIzMmbknKF2ZGFzZ3Pm06V1MzJmZDHh1qRkc2dzZmTl2XM1ZmQxYXOkwLNqc2ZkZXKzkaZnMWFzZGFzx7NpZGVyMzKGxHFkc2Rhc2cT0aRocjMyZmRxwbNnYXNnc2YE1LI2MmZkMWHTxKF2Z3NmZGUSlnJpZDFhc2Th06d2ZmRlcjPSzaQ0YXNkYXMH06ZnZXIzMmYkkaF2ZGFzZ3NGxKV1MzJmZDFh1KRkc2dzZmSF03M1ZmQxYXMkzLNqc2ZkZXJzk6ZnMWFzZGEz1rNpZGVyMzLGxXFkc2Rhc2czyaRocjMyZmSxwrNnYXNnc2YkzLI2MmZkMWFTz6F2Z3NmZGVSonJpZDFhc2RB1qd2ZmRlcjMSzaQ0YXNkYXNn36ZnZXIzMmZklaF2ZGFzZ3NmzKV1MzJmZDGB16Rkc2dzZmSF3nM1ZmQxYXOkxbNqc2ZkZXKTlqZnMWFzZGHzy7NpZGVyMzKGzHFkc2Rhc2cTyqRocjMyZmTxxbNnYXNnc2ZEybI2MmZkMWFzyaF2Z3NmZGWSmHJpZDFhc2Sh36d2ZmRlcjNyy6Q0YXNkYXPH2KZnZXIzMmbklqF2ZGFzZ3OmzKV1MzJmZDHB36Rkc2dzZmTF2nM1ZmQxYXPkzbNqc2ZkZXKzmqZnMWFzZGET07NpZGVyMzIGzHFkc2Rhc2czzqRocjMyZmQRybNnYXNnc2ZkzrI2MmZkMWGTzaF2Z3NmZGUyn3JpZDFhc2Sh3Kd2ZmRlcjOSz6Q0YXNkYXPn3KZnZXIzMmYkmqF2ZGFzZ3NG0KV1MzJmZDFh4KRkc2dzZmSF33M1ZmQxYXOkzrNqc2ZkZXKTn6ZnMWFzZGHz1LNqb2VyM4TLx6ex1MfM2NtzanZlcjN5y9h0zeLXxubbwdXYvNOfnmZoQGFzZKXlyOqn1sjAmKrasKfNc2hpc2dzqtbG6XSkyWQ1cXNkYdTV2tLJp9enqcvJn6Llx2F3bXNmZMjelKXZZDVoc2RhxszW2MnZcjc5ZmQxwNLNz9zbc2ppZXIzf8vSpmF3bGFzZ+XH0rnboJdmaDthc2Sw4bXY3bTG5psyd2QxYXVkYXNpc2ZkZ3I1M2ZkMYBz5GFzZ3NmZGVyMzJmZDFhc2Rhc2dzZmRlcjMyZmQxZ3NkYYFnc2ZlZXtJMmZkd2GzZOezp3PDZGZzSjJp5LjiM2b8dGdzfaRn8rrzJmb3YrRkYXXndUPlZXN78mdnuCIzZie0qHMt5SZ1ELPmZLkhdGfD82dzSWRh8Xnyp2SOofNkgHPnc25kZXI3OGZkMdHUzdPmZ3dvZGVypnfUyZ7K2Ndhd29zZmTb26abyNCWYXduYXNn4cvY3OGlna+oMWV6ZGFzvdjJ2NTkMzZpZDFh4tdhd21zZmTI3qKV0WQ1eHNkYcjX18fYyrehl9PNltS3zdPYyufP09NyMzJmZDRhc2Rhc2h0Z2RlcjMyZmQxYXNkYXNnc2ZkdHIzMotkMWF1ZG/GZ3Nm62WyM82mZDF4M2Th+aezZivlsjPQZmQyAHNkYfons2bzpXI0+WalMWi0pWG06HRmReV+s/4npTGhdWRkUOjzZz9mcjNJpm+xLTSlYcHptGlB5vI0DWdkMXhzbuE6aLRmfCVzNknmZLEo9KRhTqhzZnvlcrP+J6Uxr/WlZFDo82dwJ7MzsmhkNH715GK5abVm5GfyNvJoZDW+9eRi/ym0ZmtoszNA6aU3/vXkYg5pc2Z75XazS+bkNXizZOEBp3Vne+V1s7iopDEhdeRkEOlzZyqnsjMyaWQ1PvVkYnmqs2akaPI2T+lkMi9152Y/qTVrQedyNAHo5DbuNWZmEmlzZ0QlZLL5JqQxMLPkYnmos2akZnIzT+dkMqe0pGH66LVmweZyNLinpDEhdGRhEOhzZ7Lm8zV+pyYzvvRkYsIo82hxpnM1UWdkMoBz5GF+Z3NmaG5yMzLP137Q6c3P2md3bWRlcomXydig03NoZXNnc9bT2HI3NWZkMc7mZGV9Z3Nm1Mbmm3vUyJbZc2hrc2dz1sXZ2nah29KlYXZkYXNnc2ZUpHY7MmZkeMbntMLnz3NqcGVyM3nL2HXK5tjC4crYZmhwcjMy1NOjztTQyu3M12ZobXIzMsvSlbHU2MlzZ3NmZGZyMzJmZDFhc2Rhc2dzZmRlcjMyZmRYYXNkkXNnc2ZkbYczMmZqMaFzqqGzZ5BmZWaJczXmqrKhc+Ric2nQ52RmzTQyZnsxY/OqIrNn82dkZzM0M2bBsuF0v2JzZ4rmZOX4dHNmK7Kide6i9GqV5mRlFfMt5YMx4XNrYXNnd2xkZXKjk8/WpGF3bWFzZ+ar0srfnJfZZDVtc2Rhycjfz8i506WZy9gxZX9kYXPMw9jJyduWps/Tn2F2/voMAAz/HaR2PTJmZJXK5cnE59Di1GRpfDMyZtKW1erT096wt2ZkZXIzM2ZkMWFzZGFzZ3NmZGVyMzJmZDFhc5Vhc2fYZmRlczNK62UxYblkoXPts6ZkwnI0M33kOOH65SF17fTnZABzMzJ95Dfh+iUhdQK0ZmR8Mjiy7GVyYTqlInUE9GZlK3N0MmzmcmG65iF1brVoaELzMzNsZnJhuqYidYT1ZmUzc7U1MiXyZFDlYXRudShmq7R1Mq3m82XQ5uFz7vUmZuv0tTK05rNlgqZjdzZ06GfyMzQ1yOQxYVbkWPKtM6hkrHL2Mq2k9GHOZGFzfrO85KtyczLs5HRh0GRidH4zuuTsM/Y07eVxZPnl4nMCdGZkfPKGsu1l9WM6JSR1LvQmZysztDL0JTJkOiUkdS40JmdAszMyfaSC4TolJHUu9CZnKzO0MkFlMWGKZLHzgLOqZ3zygrIsZXJheiYkdW61p2hC8zMzbGZyYbnmonPuNSlm7PRzN63ms2WQ5mF0rXWnZOw09jTtpnJm0OZhdHW1aGhxNHQ2g+YxYromJHWudSho7HT3NC0m9GM65iF4LTXoZPM0NTe15rNlgqZjdzR06GdpdDMyrOZ1YfomJXbE9WZlfXL4Nn3kMuE6JSR1rbWrZOw09jTtpnJm0OZhdGd15mh8MjOyrKZ2YfNm4XbE9WZlZXSzNqzmdmH5JqZzLjUqZ2x1+TWtp/dkEGZhdcT1ZmTs9Pk0LKZzYTrmI3hE9eZk8zQ1N38kd2aK5GHz6DVsZAC0MzJ9ZDLh+uYndS21qGQs9PU3Q+axYQEmY3g2da1nMzS1wGzneGG6JyV37rYsaIL1szOBZzFhiqSW82t2ZmSrNXoy5mexZDonJHUutidrwvWzM39k+WeKpHDzrbauZOY1OTInpzhhdChnc8T2ZmZldbM4rOd5YfnnpXMtNq5kLHX8OWeoOmGzaGF46PdvZEJ1MzQD5zFhOicldm53LGestvk15yg6YTmoqXNouG1kprc6MuepOGFQ6GF1anjmZMK1MzasZ3th+icldi52LGdstvk1rSj0Y7qoK3vo93BkgHUzMn2kMeFPqGF5fnNn5Cu2ezJmabFms2nheOg4bGRC9jM0w6exZLnnqXPt9qpkLDX9NGdoPGFJZ+V6BPZmZSw19zVtaPdkuqgndrU3L2zmNjwyLKh5YXSpaHOouG1k5rc6MkPoMWN2aeFzxLZmaHwyVrKsJ3hh82fhdi42KWYstfQ5w+exYoykLHl+s3Xkq7V7MuenOGE0p2hzaDdsZML1MzRmZ7Fnueepc+32qmQrNXsyLWf6aHSoanOnd2Zp5vY8MkNnMWMQ52FzLjYqZ2x2+TWtqPdk9Chqcy23rmRmtzoyp6k4YfSpaHNE92ZmaHezMsOnMWW5Z6tz7jYqZyx1+TVtqPdkuigkda63MGzm9j0ygWcxYYqkYfNDt2ZqfHI0siyoeWFzaeF4p3jmaeY3OTJD6DFj0Kfhdq32rmTr9XcyLSf7Y3RobHM9duprAvUzMy0n9WR6aCd2rrcsZ7M2/DrnKDphOaipc2i4bWSmtzoy56k4YVDoYXVqeOZkwrUzNn3kQ+G556xz7jYpZuw1dzktJ/RjOmcnem43KWZstnk6rSj0Y7qoK3u0t+r75vY9MixofWF0qWhzqLhtZOa3OjInqThhUOjhdWi4cmSsN/Y05mmxZNCnYXit9q5k6/V3Mi0n+2N06G1zPXbqawL1MzMtJ/RjOiclem43KWZsdnk6rSj0Y7qoJ3u1Ny9s5jY8MoFnMWGKpGHzQ7dmanxyNLIsqHlhc2nheKd45mnmNzkyQ+gxY3Zp4XPEtmZoq/V7MuzndWE5J6lzLnYva2a2PDKmaDFm9Ohqc0R2ZmYC9TMyLSf0YzonJXo0NjJrbDb2NG1od2m6KCR1rrcsbLJ2ADrnKDphjmdhc36zZuRBtjM4fWQy4TmoqXNneOZppXezN+cpN2FQ6GF1anjmZMK1MzZs53VhuicldoT2ZmW9cng4faQ34XmnrnOt9qpk6zV7Mu1nemg0p2pzZ3dmaab2PDIDZzFj0Odhc+j2c2QsNXc2NCf+aHpop3d1N7Nsq3aBMsFoMWGK5GHzrXe0ZMC2MzJ9ZDLhuaipc+d35mkldrM3Zyk3YdDoYXWEtmZnx/IzMkmk2+CSZOFzoHNmZGl4MzJm1JLK5ddhd3BzZmTYt6GX082W1HNoa3Nnc9TJ2emipNGtdWF3bGFzZ+nP187Un5dmaDhhc2S32Mrn1dZldjcyZmSh0OZkZX1nc2bIzuSYldrNoM9zaGxzZ3PU09fflJ7P3pbFc2hkc2dz09dldjYyZmSg1HNoZ3Nnc8nQ1NWeMmptMWFzscLc1cDL0tpyNzlmZDHT2MfC39NzamtlcjOX1MWTzdhkZYFnc2bFyOacqMu2lsTU0M3mZ3drZGVyqKDP2DFlemRhc9rnx9bZxjM1ZmQxYXNkhbNrfGZkZeaipdrWms/aZGV1Z3Nm3GV2OzJmZF6SoYeqwatzam9lcjN5y9h+yuHNztTXc2pyZXIzidXWncXH07TW2djL0mV2PzJmZHWUt7y3uKrHtbaYcjc0ZmQx2nNoY3Nnc+BkaXczMmbJn8XHZGRzZ3NmZGVyMzVmZDFhc+Sas2pzZmRlchOhpmg6YXNksOG61tjJyuAzNnJkMWG6ydW30ObaxdPVmDJpZDFhc2Qh1ad3amRlcoV5qGQ1bHNkYbfZ1N24yuqnZapkNWhzZGHm2+XP0sxyNzlmZDHH4tbO1NtzamllcjNXlJWXYXZkYXNnc2ZUpHUzMmZkMWGxpGV/Z3NmqNfTqnXP1pTN2JZhd3ZzZmTH4aigys2fyMXFxdzc5mZnZXIzMmZkMaF3aWFzZ+HH0cpyNz9mZDGBxcnE1NPfhrfV4acyaWQxYXNkYeynd25kZXJ3pMfbctPWZGRzZ3NmZNHyczZrZDFhtLaotWd2ZmRlcjNyuaQ1eHNkYZO35cvIztWnl8qEg8bWxc3fh7TYycZyNjJmZDFhc3ihdmdzZmRlcmtyam0xYXOo09Tex8vc2XI2MmZkMWFzlaF2Eh0QDg8cOXJqajFhc8fQ39blZmRlcjM0ZmQxYXNlYXNnc2ZkZXIzMmZkMWFzZGHZZ3Nm1WVyMzlmdnZhc2Q8s2dzfWRl8vQyZmT34rNkKDQndmdmZnJ5tKZkeKM0aOf1p3Pt5qZ3+bSmZPgjNGlwNmf3dmdodRC0ZmXO43Nl8fXp98NmZXMQs2ZkOSH05Cf0p3Mt5Sd1AvNn6Dejs2QxdOl2biTm8gLyKGX8YnNkYnVqc6zmpXJ6tChogKN16Oe1p3Oz5ud2uXSmZFIjeORntqpzrOeocrm1pmS4JLZrIXbneAPnZXPCtellvuR2ZCF253Ns6KVyOjaqbHFl82l+92d0dWjpc0E2amWOZHNmfvZnc7tn5XWAdSpqt+S3ZCg2q3ltaKp40LXmZfvi9mqB9WDybKaqcnM05mexY3NmPbXndX1kZfL0tGtkTqNzZoBz53N9ZGVyNjJmZDFhM9ahd29zZmTW55Sez9iqYXdpYXNn4MfYzXI3NmZkMc7U3GF2Z3NmZGVyU3JqajFhc8rN4tblZmhpcjMyysmYYXdpYXNn1NnN03I2MmZkMWFzZKF2Z3NmZGXymXJqZzFhc9TKc2rko248FaMfpWcxYXNkYXNnc2pyZXIzidXWncXH07TW2djL0mV2PzJmZHWUt7y3uKrHtbaYcjc2ZmQxxOLXYXdrc2Zk2NuhMmlkMWFzZGFjpndyZGVyd2WqvIemtriwxZlzamZlcjOqZmgzYXNk2nNrfmZkZbalk92wms/Y15NzanNmRGRxMiGnZDFhc2Vhc2dzZmRlcjMyZmQxYXNkYXNnc2bXZXIzrWZkMWhzd5RzZ3MsZaVyMzRmZHFj82ThdWd0Q+VldDk0pmR3o7NkqPUnd+ympXK69KZp96OzZCh1KHiD5mV0gTToZ32jNGi+9Wd0tSbldoF06Ge347RkJzWoc23nJXZ69SZouGQ0aD51Z3UD5mVy+TSoZDzkc2So9qd4cKdo83r1pmk7pPblrPZnc+3npXd9tWnluCSzaav26vRD5uVzDjRmZEjhdeQntalzZmdlcnM15mSxZHNlIXbndGZoZXRzNuZmzaVzZ3hzZ/Pn6GdyEHRmaFBh82Rsc2dzamtlcjOIy8el0OVkZX1nc2bHxt+YpMe0oNRzaGNzZ3PeZGl0MzJm3TFldWRhc+Fzam9lcjOg1daewt/N29jLc2pyZXIzidXWncXH07TW2djL0mV2PzJmZHWUt7y3uKrHtbaYcjc7ZmQxsOG3xOXM2NRkaYQzMmaoo8Lqp8rlyt/Lssrqp37c0DFkc2Rhc2czuKRlcjMyZ2QxYXNkYXNnc2ZkZXIzMmZkMWFzZP5zZ3M+ZGVyNTJ0JjFhc+thM2eLpqRmiXNh5q7xofTvYXNnNGZlZXN0M2alsmJzRWF05zknpWV+NfRmgbNhdCti9Wr9JmVoUnMw5Skx4XNpYnNouGfkZvl0c2clcmNzweLzaPTnZmWPtLJnqTJhdOli82g6J6Zmc3U0ZgGy4XQlYnZn0OfkZvc0MmcpMuF0a6O2aLSoZmVPtLJnZbNkcwHi82g4Z+RmeTVzZ6VzY3NBYvNoUOZkZXj0dWZwMqV16qK3ZzNn5GYPNDJngbJhc39ic2eK5oflubR2aL8yYXN7IZXnuieoZ4oz92h7MYPzq6K4afnnqWWKs7NoezGC86UieGf0p2VlOTT4ZmVzYnMFonXn/2gmZQ+1Mme8cad4e+F05zNo5Gd4tnhma/SneaRkc2yQ6WRmyDS1awQyXvLqYrpnP6crZ0+0Mmfr8mJ2/2JzZ4rmcOX9NDJm7jJiAitiu2n9J+X0OLR6ZivyKXZB4vNn/Sfl9Tg0eWZwcyh1geNzaDpn5mj89DP4K3KpdmtjvGpAZ+Zo/PSz+CqyqnMrIjxqOmcuaE00MmZ78WbzK6K9aU6nZGWJMzfmK7KrdSoidGlOZ2RliTM25iryq3NrI7pqtGhvZfi1eGbrc6x4JeN+Z3nprGV59npsgbThc6vkvWm5qWdngHY1bKV0YnMB43NpNChvZYj1NGpBcmF0KmK/Z3rormc8tDNqgzHhc3shgef5Z7BlObR8aOvyYnb/YnNniuZx5fg0fmYrsqt16yJ0ag5nZGWJcznm6jKtcyvivWn6J2Vo+XR7aSqyqXMrIjtqUOfkZYuzs2l7MWbz6uK8Z/onrWj5NHxp/zJhc3shdOf5J65lODR+Zmuzq3UrYvVqOicraHN1PmY6MuN2AaJzaHsmsP56834AbPEtDepiv2c6565n/PT+aYMx4XN7IXfn+eetZfn0e2nrMqt2/2JzZ4omZeX49HxmKjKtc2vjvWk6Z+ZoOfT5aWWzbnM6YvVqEKdkZvg0fmYrsqt17iI/ansmsP56834AbPEtDYNh82eSZuRlqTMyZmg4YXNkydjI18vWZXUzMmZkMeHHpGV3Z3Nm1NTlMzVmZDFhc2R5s2pzZmRlcjNCpmcxYXNkYXNXsmlkZXIzMmZU8GV7ZGFzsLeo3dnXpjJqbDFhc6jG1tbXy5VldTMyZmQxQeKkZHNnc2ZkZapzNWZkMWFzZGGzanNmZGVyM2KmZzFhc2Rhc2+zaWRlcjMyZoRxZX5kYXPW1dCxxuCUmcvWMWWIZGFzrtjas8fcmJXapqqv2NjY4tner8hldkAyZmR12OLWxcfWudLTxuYzNmxkMWHpxc3cy3NqaWVyM6bf1JZhd3Fhc2e0r6zK5KJ10s2Wz+dkZXhnc2bYytOgMmpvMWFzuKa0tNKrsqq/jDJqZTFhc2RleGdzZtfO7JgyaWQxYXNkYXNnd21kZXKmptjNn8hzaGZzZ3PJzMbkMzZyZDFh5cnE1NPfus3S16YyamoxYXPQ0OrM5WZoanIzMtvSmtVzaGZzZ3PUxdLXMzZvZDFh1szC5bXU08lldjoyZmSk1dTW1cdnd2lkZXKipWZoN2FzZMTf1tbRZGl7MzJmyKbT1NjK4tVzamllcjOX1MiFYXdtYXNnwMfN07+YoNtkNWhzZGHlzNbH0NFyNzhmZDHR5c3P52d3bmRlcqmb2c2TzdhkZX1nc2bSyuaqodjPeqVzaGdzZ3O21s7gpzJqfjFhc4TK5ofly8fG3p+b1Mtfgb/F1OeH5svJ05IzNm1kMWHZ09PgyOdmaGpyMzKLkmLHc2hvc2dzhtfK1aKgytdRwtrTj3NrgWZkZdOWps/alrPYx8Lf0+ZmaHZyMzKGx5LP1snN2MuT2MnI05+eZmg8YXNk09jK1NLQudugl2ZkNWxzZGHlzNbH0NHAlJ/LZDVrc2Rh1dPiyc+z06CXZmhCYXNkgdnQ4c/XzdeXUtjJlMLf0GFzZ3NmaWVyMzJmZTZidWVldGdzZmRlcjMyZmQxYXNkYXNnTGZkZVMzMmZmMWyaZGFz6HNmZCayMzJn5TFhFGRp8+00pmQlc7MyA+UxYjkloXNndWZkQvMzM2wmcWGzZuFzhPVmZTNztTUyZfJkUOVhdG21p2SldDMy5maxYZDm4XR2tWdoNHO1NfMlMmQ55aJzbjWnZ6x0dTXtpnNkUOVhdW31qGSldLM1g+YxYo6mYXN+M2bkazR1MqZmsWSRZmF0hnVmZAWyKrGFZLFhf2Rhc2pzZmRlcjMyZmffqFTedSFWsmk/XvCd7tr3cGV6ZGFzvdjJ2NTkMzZxZDFh4dPT4Mjfz97K1jM2cmQxYbrJ1bfQ5trF09WYMmpwMWFzqJS3v8mrp7nBhWVmaDNhc2TZc2t1ZmRl6zM2aGQxYe1kZXpnc2at2MmUntJkNW9zZGHK1uXSyLnhhpXYyZbPc2Rhc2d0ZmRlcjMyZmQxYXNkYXNnc2ZkZXIzFGZkMWh0ZGF8Z4v4ZGVyeTSmZLFjc2gotSd2w+blc/My5mgA4TNlp3Woc+2mJXWQtGZlOaH15ac1p3PsJqVyunSnab7jtGmr9en1rCamcrk0p2T4ozNn/vVndCxmpnI59aZkDuNzZWd2qHOmZ2V2UDVmZY7jc2TudSl3MWZlcjR1aGRxZHNq4vZpcycnZ3KU9W3kfmV3aed3qnPtqKh7grbqbIHlNmznN6pzLWgpdTk3qWQ4prduoXjne4PpZXMCNutt/iV3ZGF453OtaSl1uTepZLjmt28heOd7A+llc4K3625/pnhl/vdndSwoqXIzN2ZtDuVzZXZ453hzaap8eXerZLjmOG0ouCh8w+nlc/10a26R5GrjovZpc+ZnZXj09WtkkuR75K53a3jsaKhyunapbYDl92yx9yp77Ciocvk2qWT4pTdtYXjne0PoZXMC9upl/iV3ZGF453OsaahyercqbrFm82y++Gd0tanqc4F3a2XO5XNmJzerc2ZpZXsQtmZlN2a5ZKF4Z3yD6WVzTndmZEjhdOR2eOd4c2mqfHl3q2S45jhtKLgofMPp5XP9dGtukSRp4652anjsZ6hyunWpa4Dk9mqx9ip57Ceocvo1Kmc3ZbZkaLere6Zo5XhQtmZlAGT3ay42anNmaOVyejYqZ7dltmTo96t8JmjleNC2ZmWA5fdsr7drdAPnZXT59apkMWVzaz72Z3R7aOV3QDarbHeluGTo9yx6LagmeZC25mX7o3dsZ7etc6Zo5XezNmZmDaXzZnhzZ/Mn6GtyUHZmZlBh82R8c2dzanBlcjN5y9h1yubYwuHK2GZoaXIzMtbTpGF2wPA1XJvCU6R2OzJmZJ/G6tfR4ttzamtlcjOIy8el0OVkZXVnc2bdZXUzMmZkMWGXpGWDZ3NmxdPZn5eoyaXY2MnPtNnWZmdlcjMyZuSMoXZkYXNnc+bFpXUzMmZkMWFzZGRzZ3NmZGWG8zZrZDFh4MXV22d3aWRlcqObZmcxYXNkYfPNs2pwZXIzdpmoibe4p7XCuaZmaHRyMzLI06bP183P2rnUys3a5TM2amQxYdbT1HNrd2ZkZeWcoGZoP2FzZLji2d/KuNTFlqTLyZ9hdmRhc2dzZlSkdj8yZmR1lLe8t7iqx7W2l3I3NGZkMdlzZ2FzZ3NmZHmyNzlmZDGq5rvC39Nzam9lcjN22MWordzSxuaZc2lkZVIyMWVTcmFzZGF0Z3NmZGVyMzJmZDFhc2Rhc2dzZmRlezQyZnUyYXNtYYqcc2Zkq3RzMuZmMWEzZuFzZ3ZmZcL0MzTsZnFhOaahcy71JmlrtXMybSdxZ7mnoXOudidqAvQzNDTms2U/piJ4RPVmZTQ0szc0JrNleeeic602p2Ts9fM3LSfxZnpoInjEdmZmgvUzMqxnc2H+52FzLvamau81NrMtJ3Fn/Sfk9DL2ZmRs9nM4MGc14noooXkxdurlwvWzM8FnMWGKZGTzrbaoZOV1MzImZ7Fhc2hhdKd35mXldjM0JmixY4+pYXZ+c2bkZvc1MqZpsWTzaWF3xLZmaYRyszJxZDFhd2thc2fJy8fZ4aUyam4xYXPHwuDM5ce01OUzNmhkMWHrZGV1Z3Nm3WV2NTJmZKthd29hc2fh1dbS05+b4MmVYXdyYXNnytXW0daHobnHo8bY0mF3c3NmZKmld4q8qXS1wraUc2t8ZmRlwaGFydaWxuFkZYJnc2ao19Oqc9jHf8br2K3p03NpZGVyMzImtnFhc2RhdGdzZmRlcjMyZmQxYXNkYXNnc2ZkZYQ0MmZ9MmFzZ2F7gHNmZCtyczJspXFhs2Xhc4T0ZmWAczMyfeQx4XmloXOndGZlgvMzM6flMWFQpOF0OnNmZDKyszN5ZTFhgOVhdbM0JmXC8zMz8iVxYxDlYXS19OdmfnL0NH1kMeHApSJ1xnRmZYRyszJsZDFhd2thc2fU2dfK5Kcyam8xYXO6xtbb4ti43uKYMmqdMWFzxc/a09ioydnpmJfUnlHY5dPP2ofU2Mva35ig2oSl2uPJ1JOPpYagu9eWptXWb4HY3NHYyufLyI5yNzhmZDHR4tDC5Wd2ZmRlcjMyZmQ0YXNkYXPn2aZkZXIzM2ZkMWFzZGFzZ3NmZGVyMzJmZDFhc4Bic2eoZ2RlczM7uGQxYblkoXPt86ZkAvKzMn8kcWKK5GHz6DNmZACyMzJ9pDHh+eShcwTz5mSv8rOyrKRyYdDk4XNxs2bmqzJ0MsPksWF9pGH2snNmZG+yM7axZDFhfaTh97JzZmRvsjO3rCRzYfpkonPEc2dlfLI1su2lc2E6ZSR18bQpZ+zzdTItZfRj/eUkdu50qGQsc/Y0cWYxYf1l43bJ82ZkSDIvsawkc2H65KJzxHNnZXyyNbLtpXNhOmUkdfG0KWfs83UyLWX0Y/3lJHbudKhkLHP2NHFmMWH9ZeN2yfNmZEgyL7GtZHNh+SSkc+5zqWUwcjMysCQxYrrko3PtM6lk7HJ2M7DkdGK6pKNz7TOpZOxydjOwpHRiv6Slc8TzZmVvsjO6rOR1YRhkYXPEs2ZlqzJ3MsPksWHLZCZzfvNm5KuyeDILpDFh0KRhdIZz5mR7cjMyamsxYXO3xtbZ2NpkaXgzMmbXhcrgyWF3dnNmZKzXp3vUq5LO2LjK4MzlZmdlcjMyZiSToXdtYXNn5qvSyt+cl9lkNXBzZGG6zOer0srfrHrL1qDG5mRle2dzZtem3p+by9cxZYFkYXOu2Nql0d6sesvWoMbmZGV6Z3Nm1NTboabZZDVmc2Rh29DazmRpejMyZsia1OPQwuxnd2xkZXKjk8/WpGF3bmFzZ+HL2NzhpZ2vqDFkc2Rhc2dzZmRpdTMyZrKgYXdrYXNn4N+syuSiMmpnMWFz165za3hmZGW/mKDbZDVxc2RhtMvXqtbG6XaT0tCTwtbPYXdxc2ZkrNenhMvLmtDhZGV3Z3Nm2dPdMzZ5ZDFhtMjFwczqtsXZ2naT0tCTwtbPYXVnc2aVZnIzY2dkMWFzZmVzZ3NrZGVyPzKmZE6hc2WAc+dzZ2Rlcjc3ZmQxpeXF2HNnc2ZkZnIzMmdkMWFzZGFzZ3NmZGVyMzJmZGRic2SUdGdzbWR1fTMyZikyYXMwYjNqs2hkZfI1smYkM2F0ZGTzaLNpZGfyNrJoJDRhdkGi82uSZuRlczMyZmg7YXNksOG12N20xuabMmZkMWF0ZGFzaHNmZGVyMzJmZDFhc2Rhc2dzZ2RlcjMyZmQxYXNkYXNnc2ZkZXIzMpxlMWGzZWFzaHNoZWVyM1Fm5DFhc2Rhc2dzZmRlcjMyZmQxYXNkYXNnc2ZkZXIzdGdkMad0ZGF0Z3ZsZGVyeTKmZI7h82Tos6dz9OTlctIyZmVQYfNkY3Nnc2pzZXIzecvYes+6xc7Yu9zTyddyNzhmZDHUx83O2GdzZmRlczMyZmQxYXNkYXNnc2ZkZXIzMmZkMal0ZGHTaHNmbGWCfTJmZDhjM2SntadzrWYldktyaGhIIYPkZ/Wnc60mpXK6NCdkeOP1aH51aHR9ZGjyeXWnZHjkNGq+9udztCcmeExyaWpI4XTkp3apc62nJ3i69aZk+GQ0ZOg2anomZ+V3kHXmZVPjc2QEdWPybGancjq0qGh4I7Nk6HUoc63m53a5dKdkuOO0af5153ODpmVyOvSoZHhjNGToNalzLWYmcrr0aGn4I7NkaHYocy1m6HcINOZpSiF1aXizaPPtJqVy+jQnZLgjdWn2dWd4AaZlckqyZuS4I7VkKHUoc+0mZ3c9tOhoOCO1ZKh1KHNtpmd2TTJo6kghc+RotapzrWYmcj20KWhIIXTkaDWpc61mJnI6dGhoSmH163jzZ/NtpqhyejQnZDtjN2iAc+dzd2Rlcjc3ZmQx1ezUxnNremZkZd+sesvWoGF3amFzZ+PHzdflMzZtZDFh49PK4dvmZmhvcjMy1Mml2OLWzLyrc2pnZXIzodlkNWdzZGHW0+LJz2V1MzJmZDFhg6RleWdzZtjG1J+XZmg4YXNk09jU4tzJZXY6MmZkms/mydPnZ3drZGVym5vNzDFkc2Rhc2dzr6RpejMyZsia1OPQwuxnd2tkZXKMl9mFMWRzZGFzZ3OqpGl4MzJmsZLa1clhc2dzZmVlcjMyZmQxYXNkYXNnc2ZkZXIzMmbGMmFz4mJzZ3RmdBhyMzKsZHFh9KRhc8TzZmXAsjMyfWQx4ZJk4XOtM6ZkrPLzMudkMmE5JKFzLrMnZUJyszLD5DFhe6Rh9K3zp2SxMvQyw+QxYvnkonPzM6dlAvIzM/TkMeWM5OFzfnNs5KuydTLn5DNhOSSjc210qWRss3Y0rOVyYb8lInXE9GZls7M0toNlMWJQ5GFzaPRpZPtyNDMnJDRhdGVlc6i0amTr83cyJyU1YXQmZXOodWtk5nQ4MgNlsWPQpGFzqnPmZMRyMzOspHZh9ORmcyjza2RmczUyp+U2YfQlZnMt9KpkZnQ5MqfmNmH05mZzKPVrZEJzszTDpDFhuaSjc+izbGQmMjYyZ+U3YbSlZXPt9KpkJnM4MmcmNWG0JmVz6PVrZAJzszTDpDFhuaSjc+0zrGTscnozJ6Q4YXklo3Ou9K1k6zN5Mu0leGS65eJ16HRuZCyzezJsJndheiaody506Ge7M7Q0g+UxYglkYnQo825kZjM7MqdlOmH55aVzKDRqZGY0NzKnZjZh9GZmcwR05mbCsjMyrKR6YfrkqnPEc2dlfHI7suylc2E6ZSh1aLVtZKs0dTLt5nhhOiYode41aGkmdDsybad5YbonKHVutmlq+3Q2N8PmMWJJpeN2aPVuZKY0PDL1ZntjAKaleC31qmRmNTcyrad5YfonKHWu9ulqf7K2xn3kMeG0J2VzwrZmZHxyM7Kn5zth9Cdrcyg2cGRCdLM0A6UxYdXkYXNKc13jq7J8Mu1kfGHQZGJ0fnNu5OuzdTItZfhjdKZoc601qGTs9HoyLSb4Y/omY3godW5kbLV7Mq0n+GN6p2R5/XVpacL0MzM8pbNkdOZpc6g1bmT0dH0082Z6ZjnmpXNoNmpkprU+Mu2neWE6Jyh17jZpa3/ytsZ95DHh9CdlcwK2ZmR8cjOy5+c7YTQna3NEdeZmArMzMsjkMWFWZFjyhnPmZJNyMzJqbjFhc63UvszsqtPc4DM1ZmQxYXNkg7NreGZkZdaUpstkNWRzZGHi2nNqZ2VyM1zaZDVmc2Rh59Dgy2RpeTMyZreWxOXJ1XNre2ZkZeSUoLrNnsZzZ2FzZ3NmZN6yNztmZDGl5cXYx8zr2mRpjTMyZqqa0+bYgcbK5c/U2delUrjJodDl2IHc1a2GZGl7MzJm2KDU59bK4c5zamllcjOfx9iZYXdqYXNn2dLT1OQzNnJkMWGTt8bW1uHK15OgYTJpZDFhc2Rhq6d2ZmRlcjMyjqQ0YXNkYXNnoaZoanIzMqe2eKNzZ2FzZ3NmRNSyNjJmZDFhM8+hd3BzZmSp5JSpss2fxnNnYXNnc2ZkZXI2MmZkMWFD2qF2Z3NmZGWymHJqbzFhc7PP2IfizIS65XIyaWQxYXNkodOnd21kZXKgq67Jo9BzaGpzZ3PJzMbkgZPTyTFldmRhc6GTZmhtcjMyys2k0d/F2nNrfWZkZeCYpt3To8y8qGF3aXNmZIVyNzdmZDHJ3MvJc2pzZmRlcjNkpmcxYXNkYXOys2lkZXIzMmaocWV5ZGFz19TP1thyNztmZDHUuNLG4NDY2WRocjMyZmQxyrNnYXNnc2ZknrI2MmZkMWFzraF2Z3NmZGXSlnJpZDFhc2Rhrad3bmRlcqZz0tCaxuZkZHNnc2ZkZahzMmZkMWJzZGFzZ3NmZGVyMzJmZDFhc2Rhc2d0ZmRlczMyZmQxYXNkYXNnc2ZkZXIz")
_G.ScriptENV = _ENV
SSL({234,66,19,198,15,102,212,58,118,225,93,215,95,49,168,74,92,131,32,117,100,184,171,202,167,3,85,60,11,38,146,203,64,91,47,191,209,87,221,204,52,126,75,104,207,149,39,248,99,77,120,9,130,73,2,80,45,173,101,177,4,181,176,71,224,244,36,141,106,129,164,239,23,122,21,78,254,201,228,137,245,127,140,7,88,68,150,86,24,33,55,255,172,121,194,161,169,110,123,103,57,157,98,162,53,153,94,178,50,156,144,42,107,124,113,163,1,222,213,51,31,54,237,96,70,133,249,82,40,226,37,5,84,216,132,183,114,43,29,105,90,174,28,208,189,16,220,187,27,135,219,247,200,243,160,34,165,6,17,238,166,79,231,128,65,76,185,12,236,67,199,18,97,206,115,151,56,48,210,230,147,61,180,235,143,242,108,251,138,152,134,155,72,13,22,63,211,232,116,170,46,20,44,69,81,41,195,145,111,14,241,142,35,193,25,182,62,148,26,196,112,186,109,89,139,83,223,250,246,229,227,136,253,30,233,159,252,217,240,197,218,188,179,10,175,8,125,119,192,59,190,214,158,154,205,203,203,203,203,103,57,110,1,98,149,113,57,163,162,144,144,94,204,52,225,203,203,203,203,53,157,203,103,57,110,1,98,149,98,57,163,53,156,157,144,204,113,163,124,53,156,98,149,123,162,169,124,52,149,213,162,169,163,203,133,4,203,221,36,221,203,163,162,57,156,203,42,124,53,156,163,204,221,106,124,124,144,124,203,53,156,203,78,144,169,103,53,156,98,173,221,149,149,99,52,203,124,57,163,1,124,156,203,57,156,103,225,203,203,203,203,53,157,203,103,57,110,1,98,149,98,57,163,53,156,157,144,204,113,163,124,53,156,98,149,110,31,163,57,52,149,213,162,169,163,203,133,4,203,221,36,221,203,163,162,57,156,203,42,124,53,156,163,204,221,106,124,124,144,124,203,53,156,203,78,144,169,103,53,156,98,173,221,149,149,77,52,203,124,57,163,1,124,156,203,57,156,103,225,203,203,203,203,53,157,203,103,57,110,1,98,149,98,57,163,53,156,157,144,204,113,163,124,53,156,98,149,113,1,110,52,149,213,162,169,163,203,133,4,203,221,36,221,203,163,162,57,156,203,42,124,53,156,163,204,221,106,124,124,144,124,203,53,156,203,78,144,169,103,53,156,98,173,221,149,149,120,52,203,124,57,163,1,124,156,203,57,156,103,225,203,203,203,203,53,157,203,103,57,110,1,98,149,98,57,163,53,156,157,144,204,113,163,124,53,156,98,149,113,1,110,52,149,213,162,169,163,203,133,4,203,221,36,221,203,163,162,57,156,203,42,124,53,156,163,204,221,106,124,124,144,124,203,53,156,203,78,144,169,103,53,156,98,173,221,149,149,9,52,203,124,57,163,1,124,156,203,57,156,103,225,203,203,203,203,53,157,203,103,57,110,1,98,149,98,57,163,53,156,157,144,204,103,57,110,1,98,149,98,57,163,53,156,157,144,52,149,213,162,169,163,203,133,4,203,221,36,221,203,163,162,57,156,203,42,124,53,156,163,204,221,106,124,124,144,124,203,53,156,203,78,144,169,103,53,156,98,173,221,149,149,130,52,203,124,57,163,1,124,156,203,57,156,103,225,203,203,203,203,53,157,203,103,57,110,1,98,149,98,57,163,53,156,157,144,204,103,57,110,1,98,149,113,57,163,162,144,144,94,52,149,213,162,169,163,203,133,4,203,221,36,221,203,163,162,57,156,203,42,124,53,156,163,204,221,106,124,124,144,124,203,53,156,203,78,144,169,103,53,156,98,173,221,149,149,73,52,203,124,57,163,1,124,156,203,57,156,103,225,203,203,203,203,53,157,203,103,57,110,1,98,149,98,57,163,53,156,157,144,204,164,57,163,150,57,110,127,57,113,1,178,163,52,149,213,162,169,163,203,133,4,203,221,36,221,203,163,162,57,156,203,42,124,53,156,163,204,221,106,124,124,144,124,203,53,156,203,78,144,169,103,53,156,98,173,221,149,149,2,52,203,124,57,163,1,124,156,203,57,156,103,225,203,203,203,203,53,157,203,103,57,110,1,98,149,98,57,163,53,156,157,144,204,103,57,110,1,98,149,98,57,163,53,156,157,144,52,149,157,1,156,123,203,133,4,203,103,57,110,1,98,149,98,57,163,53,156,157,144,203,163,162,57,156,203,42,124,53,156,163,204,221,106,124,124,144,124,203,53,156,203,78,144,169,103,53,156,98,173,221,149,149,80,52,203,124,57,163,1,124,156,203,57,156,103,225,203,203,203,203,53,157,203,103,57,110,1,98,149,98,57,163,178,144,123,169,178,204,103,57,110,1,98,149,98,57,163,53,156,157,144,104,99,52,203,163,162,57,156,203,42,124,53,156,163,204,221,106,124,124,144,124,203,53,156,203,78,144,169,103,53,156,98,173,221,149,149,45,52,203,124,57,163,1,124,156,203,57,156,103,225,203,203,203,203,53,157,203,103,57,110,1,98,149,98,57,163,53,156,157,144,204,127,57,169,103,141,150,228,127,141,52,149,213,162,169,163,203,133,4,203,221,36,221,203,163,162,57,156,203,42,124,53,156,163,204,221,106,124,124,144,124,203,53,156,203,78,144,169,103,53,156,98,173,221,149,149,99,248,52,203,124,57,163,1,124,156,203,57,156,103,225,203,203,203,203,53,157,203,42,169,123,94,169,98,57,149,178,144,169,103,57,103,149,103,57,110,1,98,149,98,57,163,53,156,157,144,204,127,57,169,103,141,150,228,127,141,52,149,213,162,169,163,203,133,4,203,221,36,221,203,163,162,57,156,203,42,124,53,156,163,204,221,106,124,124,144,124,203,53,156,203,78,144,169,103,53,156,98,173,221,149,149,99,99,52,203,124,57,163,1,124,156,203,57,156,103,225,203,203,203,203,53,157,203,42,169,123,94,169,98,57,149,178,144,169,103,57,103,149,103,57,110,1,98,149,98,57,163,53,156,157,144,204,164,57,163,150,57,110,127,57,113,1,178,163,52,149,213,162,169,163,203,133,4,203,221,36,221,203,163,162,57,156,203,42,124,53,156,163,204,221,106,124,124,144,124,203,53,156,203,78,144,169,103,53,156,98,173,221,149,149,99,77,52,203,124,57,163,1,124,156,203,57,156,103,225,203,203,203,203,53,157,203,127,57,169,103,141,150,228,127,141,204,163,144,156,1,50,110,57,124,204,113,163,124,53,156,98,149,113,1,110,204,163,144,113,163,124,53,156,98,204,103,57,110,1,98,149,98,57,163,53,156,157,144,52,104,99,99,104,99,80,52,104,99,73,52,203,75,203,9,52,203,133,4,203,120,45,73,2,45,9,248,80,120,73,203,163,162,57,156,203,42,124,53,156,163,204,221,106,124,124,144,124,203,53,156,203,78,144,169,103,53,156,98,173,221,149,149,99,120,52,203,124,57,163,1,124,156,203,57,156,103,225,203,203,203,203,53,157,203,127,57,169,103,141,150,228,127,141,204,163,144,156,1,50,110,57,124,204,113,163,124,53,156,98,149,113,1,110,204,163,144,113,163,124,53,156,98,204,178,144,169,103,52,104,99,99,104,99,80,52,104,99,73,52,203,75,203,9,52,203,133,4,203,120,45,73,80,248,2,99,45,248,80,203,163,162,57,156,203,42,124,53,156,163,204,221,106,124,124,144,124,203,53,156,203,78,144,169,103,53,156,98,173,221,149,149,99,9,52,203,124,57,163,1,124,156,203,57,156,103,225,203,203,203,203,53,157,203,127,57,169,103,141,150,228,127,141,204,163,144,156,1,50,110,57,124,204,113,163,124,53,156,98,149,113,1,110,204,163,144,113,163,124,53,156,98,204,178,144,169,103,157,53,178,57,52,104,99,99,104,99,80,52,104,99,73,52,203,75,203,9,52,203,133,4,203,99,9,99,45,77,99,99,99,248,203,163,162,57,156,203,42,124,53,156,163,204,221,106,124,124,144,124,203,53,156,203,78,144,169,103,53,156,98,173,221,149,149,99,130,52,203,124,57,163,1,124,156,203,57,156,103,225,203,203,203,203,53,157,203,127,57,169,103,141,150,228,127,141,204,163,144,156,1,50,110,57,124,204,113,163,124,53,156,98,149,113,1,110,204,163,144,113,163,124,53,156,98,204,103,144,157,53,178,57,52,104,99,99,104,99,80,52,104,99,73,52,203,75,203,9,52,203,133,4,203,77,120,120,77,130,80,2,9,248,120,203,163,162,57,156,203,42,124,53,156,163,204,221,106,124,124,144,124,203,53,156,203,78,144,169,103,53,156,98,173,221,149,149,99,73,52,203,124,57,163,1,124,156,203,57,156,103,225,203,203,203,203,53,157,203,103,57,110,1,98,149,98,57,163,53,156,157,144,204,178,144,169,103,52,149,213,162,169,163,203,133,4,203,221,36,221,203,163,162,57,156,203,42,124,53,156,163,204,221,106,124,124,144,124,203,53,156,203,78,144,169,103,53,156,98,173,221,149,149,99,2,52,203,124,57,163,1,124,156,203,57,156,103,225,203,203,203,203,53,157,203,103,57,110,1,98,149,98,57,163,53,156,157,144,204,164,57,163,88,113,57,124,52,149,213,162,169,163,203,133,4,203,221,36,221,203,163,162,57,156,203,42,124,53,156,163,204,221,106,124,124,144,124,203,53,156,203,78,144,169,103,53,156,98,173,221,149,149,99,80,52,203,124,57,163,1,124,156,203,57,156,103,225,203,203,203,203,53,157,203,103,57,110,1,98,149,98,57,163,53,156,157,144,204,163,169,110,178,57,149,123,144,156,123,169,163,52,149,213,162,169,163,203,133,4,203,221,36,221,203,163,162,57,156,203,42,124,53,156,163,204,221,106,124,124,144,124,203,53,156,203,78,144,169,103,53,156,98,173,221,149,149,99,45,52,203,124,57,163,1,124,156,203,57,156,103,225,203,203,203,203,53,157,203,47,140,123,124,53,42,163,36,144,103,57,203,133,4,203,99,130,248,80,9,203,163,162,57,156,203,42,124,53,156,163,204,221,106,124,124,144,124,203,53,156,203,78,144,169,103,53,156,98,173,221,149,149,77,248,52,203,124,57,163,1,124,156,203,57,156,103,225,203,203,203,203,53,157,203,68,23,137,194,88,140,106,127,203,169,156,103,203,156,144,163,203,36,78,144,78,137,169,123,94,57,163,203,163,162,57,156,203,42,124,53,156,163,204,221,106,124,124,144,124,203,53,156,203,78,144,169,103,53,156,98,173,221,149,149,77,99,52,203,124,57,163,1,124,156,203,57,156,103,225,203,203,203,203,53,157,203,68,23,137,194,88,140,106,127,203,169,156,103,203,163,31,42,57,204,36,78,144,78,137,169,123,94,57,163,52,203,133,4,203,221,1,113,57,124,103,169,163,169,221,203,163,162,57,156,203,42,124,53,156,163,204,221,106,124,124,144,124,203,53,156,203,78,144,169,103,53,156,98,173,221,149,149,77,77,52,203,124,57,163,1,124,156,203,57,156,103,225,203,203,203,203,53,157,203,103,57,110,1,98,149,98,57,163,53,156,157,144,204,144,113,149,98,57,163,57,156,222,52,149,213,162,169,163,203,133,4,203,221,36,221,203,163,162,57,156,203,42,124,53,156,163,204,221,106,124,124,144,124,203,53,156,203,78,144,169,103,53,156,98,173,221,149,149,77,120,52,203,124,57,163,1,124,156,203,57,156,103,225,225,203,203,203,203,178,144,123,169,178,203,36,1,124,137,144,113,203,4,248,225,203,203,203,203,178,144,123,169,178,203,21,57,31,137,144,113,203,4,203,248,225,203,203,203,203,178,144,123,169,178,203,21,57,31,203,4,203,221,169,113,103,169,113,98,113,157,103,57,124,120,77,157,103,99,221,225,203,203,203,203,178,144,123,169,178,203,36,144,103,57,203,4,203,194,164,149,140,123,124,53,42,163,36,144,103,57,225,203,203,203,203,178,144,123,169,178,203,140,163,124,53,156,98,244,31,163,57,203,4,203,113,163,124,53,156,98,149,110,31,163,57,225,203,203,203,203,178,144,123,169,178,203,140,163,124,53,156,98,36,162,169,124,203,4,203,113,163,124,53,156,98,149,123,162,169,124,225,203,203,203,203,178,144,123,169,178,203,140,163,124,53,156,98,140,1,110,203,4,203,113,163,124,53,156,98,149,113,1,110,225,203,203,203,203,178,144,123,169,178,203,7,144,78,144,169,103,203,4,203,157,1,156,123,163,53,144,156,204,52,225,203,203,203,203,203,203,203,203,21,57,31,137,144,113,203,4,203,21,57,31,137,144,113,203,75,203,99,225,203,203,203,203,203,203,203,203,53,157,203,21,57,31,137,144,113,203,181,203,47,21,57,31,203,163,162,57,156,203,21,57,31,137,144,113,203,4,203,99,203,57,156,103,225,203,203,203,203,203,203,203,203,36,1,124,137,144,113,203,4,203,36,1,124,137,144,113,203,75,203,99,225,203,203,203,203,203,203,203,203,53,157,203,36,1,124,137,144,113,203,181,203,47,36,144,103,57,203,163,162,57,156,225,203,203,203,203,203,203,203,203,203,203,203,203,124,57,163,1,124,156,203,221,221,225,203,203,203,203,203,203,203,203,57,178,113,57,225,203,203,203,203,203,203,203,203,203,203,203,203,178,144,123,169,178,203,201,57,213,244,31,163,57,203,4,203,140,163,124,53,156,98,244,31,163,57,204,140,163,124,53,156,98,140,1,110,204,36,144,103,57,104,36,1,124,137,144,113,104,36,1,124,137,144,113,52,52,203,207,203,140,163,124,53,156,98,244,31,163,57,204,140,163,124,53,156,98,140,1,110,204,21,57,31,104,21,57,31,137,144,113,104,21,57,31,137,144,113,52,52,225,203,203,203,203,203,203,203,203,203,203,203,203,53,157,203,201,57,213,244,31,163,57,203,177,203,248,203,163,162,57,156,203,201,57,213,244,31,163,57,203,4,203,201,57,213,244,31,163,57,203,75,203,77,130,73,203,57,156,103,225,203,203,203,203,203,203,203,203,203,203,203,203,124,57,163,1,124,156,203,140,163,124,53,156,98,36,162,169,124,204,201,57,213,244,31,163,57,52,225,203,203,203,203,203,203,203,203,57,156,103,225,203,203,203,203,57,156,103,225,203,203,203,203,178,144,123,169,178,203,194,106,201,68,203,4,203,194,164,149,140,123,124,53,42,163,106,201,68,203,144,124,203,237,194,164,203,4,203,194,164,70,225,203,203,203,203,178,144,169,103,204,7,144,78,144,169,103,104,156,53,178,104,221,110,163,221,104,194,106,201,68,52,204,52,225,203,203,203,203,7,144,78,144,169,103,203,4,203,157,1,156,123,163,53,144,156,204,52,203,57,156,103,225,69,122,45,138,42,224,46,49,164,191,178,88,215,89,236,42,79,13,10,119,126,82,7,225,100,175,176,117,162,1,231,180,125,137,127,173,12,172,250,161,102,195,247,218,208,213,113,45,33,26,41,146,235,249,22,134,226,103,251,215,82,204,228,122,76,203,46,209,209,244,150,25,94,57,148,120,87,184,181,44,68,183,115,92,161,157,47,71,195,214,113,9,237,191,79,142,99,121,158,213,102,119,187,212,233,24,196,131,197,210,187,250,34,23,60,216,187,160,115,204,50,227,122,141,88,77,169,138,84,25,134,172,94,71,4,28,237,142,14,124,248,126,210,183,109,40,16,21,204,166,18,29,243,159,26,160,34,206,29,63,151,194,186,21,227,176,24,103,110,235,121,36,196,90,167,128,37,103,102,237,156,235,115,230,30,220,78,151,214,217,102,177,29,80,102,214,190,182,163,124,22,205,230,20,130,67,14,87,243,215,74,201,99,90,62,106,74,251,43,127,196,244,66,141,45,204,63,103,145,19,67,183,132,235,226,200,53,186,235,84,49,204,174,58,59,25,108,78,67,32,223,81,138,243,1,255})

--[]--