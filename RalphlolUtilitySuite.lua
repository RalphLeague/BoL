--[[
Ralphlol's Utility Suite
Updated 5/7/2015
Version 1.01
]]


function Print(msg) print("<font color=\"#A51842\">Ralphlol's Utility Suite:  </font><font color=\"#FFFFFF\">"..msg) end

function OnLoad()
    local ToUpdate = {}
    ToUpdate.Version = 1.01
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
	AddRecvPacketCallback(function(p) self:RecvPacket(p) end)
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
	if p.header == 121 then	
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
	AddRecvPacketCallback(function(p) self:RecvPacket(p) end)
end

_G.ScriptCode = Base64Decode("grDox7MyMmVraHtmesU+a4Fuc2ZhMjFhZ2RzZ2rBMmFniXNmYToxYedq86ZhT7HhZ2xz5uE9MWFnr3NmYbjxoWdJs2ZhvPFh6QnzZmE6seHp73NmYTqxYeoJM2ZhOrHh6uozpmEXMWJn7jNm5ddxYmds8+bl17FiZ2zzZua9MWFnbPPm5r1xYmfu8ynnvDEl7u7zKum8MSbw7vMq6zqxYe3q86thufGmaCrzq2H5MSdoavSrYTlyp2mq9KthebInae90cmG8cqj17jSt8LxyqffuNK7yvHKq+e40r/S8cqv77jSw9rxyrP3uNLH4vHKt/+40svq8cq4B7jSz/LxyrwPuNLT+vHKwBe40tQC8crEH7jS2ArxysgnuNLcEvHKzC+40uAa8crQN7jS5CLxytQ/uNLoKvHK2Ee40uwy8crcT7jS8DrwyOP7utD3wvLI4Au40PfS8crkX7vQ+D7wyOhjutL8SvLI6Du50PgC88joS7nRABLyyOxvuND4WvHK8He40wRi8cr0f7jTAGrwyPiDu9EMbvDI/Iu70QR288r8k7rTFH7zywCbutMAhvLJBJ+50RyK8skIp7nRBJLxywyvuNMgmvHLELe70rSi8MkUu7vRJKbzyxTDu9K4rvLJGMe60Siy8cscz7nStLrwySDTudEkvvPLINu50rjG8skk37jRJMrxyyjnu9LE0vDJLOu70TDW88ss87vSyN7yyTD3utE04vHLNP+50sTq8Mk5A7nRMO7zyzkLudLI9vLJPQ+40TD68MlAA7vQv8rxyUATudEv2vLLQG+70MBC88lAe7jRLE7wyURDudC8CvHJRFO70Sga8stEp7nSwHLzyUSzutEsfvHLSSe70s0S8MlNK7nRORbzy00zu9LRHvLJUTe40Tki8ctVP7nSzSrwyVlDu9E1LvPLWUu50tE28sldT7rROTrwyWDPu9EInvHJYNu70Vyq8sthH7rTDP7zy2EjutNhAvDJZP+50QjO8cllC7nRXNryyWU/uNEJDvPJZUu40V0a8ctpZ7nTGVLwyW1ru9FpVvPLbXO40xle8slxd7rRbWLxy3V/u9MVavDJeYO50Wlu88t5i7rTGXbyyX2PuNFpevDJg/e60RO+8cmAB7nRZ87yy4BrudMUPvPLgHO40WRHzMqFn7jTnB7zyPgUltKZhvPLiEe70WAPzsqFn7jTnILyyPx8lNKZhvPJiKu602R3zMqJn7jRnUbzywlUltKdhvPJiWO503FDzMqFnZfWnYbwy42ru9Mhf87KhZ2U1p2G8MuNq7jTcYPMyo2fuNOdZvHJCWSW0qGG88uJi7vRbVvMyo2dl9ahhvDLjaiV0p2G8MkNqJfSoYTPzo2fudOhk87KiZ+60XGS8sto17vS1KfMypGfuNGcyvLLKMu60YEG8sjFFJbSpYbzy4kjutFBAvDLaQe50tTXzsqRn7jRnPrwyyj7uNN9LvDKxSyU0qWG88mJU7jTPSPOypGfu9GJk8zKkZ+70OWTz8qRnZXWqYbwy42oltKlhvLJNaiW0qmG8cl5qJfSqYbyyNWolNKphMzOmZ+506GTzcqZn7rRTZPOypmfudGJk8zKlZ+50OWTz8qZnZfWrYbwy42oldKthvDJNaiV0rGG88l1qJbSsYbwyNWol9KxhM/OmZ+506GTz8qdn7jRSZLwyXP/u9Dfx87KlZ+405/28Mkz77jRhFLyysxYltKthvPLiHe400RO8slsP7nQ3AfNypWfuNOcNvLJLC+604SK8MrMhJTSqYbzy4ivutFEevDJfV+70O0/zcqdn7jTnUrwyT1YltKZhvPJfau70PF/z8qFnZTWsYbwy42ruNFRgvLLeYe50u1XzMqdn7jRnXryyzl4ltKhhvHJfaiW0p2G8MjdqJTSoYTOzp2fudOhk8/KiZ+60VGQ6seL06jSmYfMyqGeJNWdhvDLjauW0rWEXMmNnbDNnZLOyqGdJtGhhOvFiauU0rWEXsmNnbDNnZLMyqWdJNGhhOvFiauW0rmG4smJnJfSuYc9yYWjl9K5huLJiZyU0rmFXM2Rn7nToZLOyqWfq9Gdh8zKqZ4m1aWG8MuNq5fSuYbiyYmcltK9hV7NkZ+506GSzsqln6vRnYfOyqmeJNWlhvDLjauX0rmG4smJnSXRqYbzyYuuDc+ZhWTJhZ2h1ZmEyl2FrbXNmYaV2z8zR3MvUMjVwZ2Rzrcamds/M0eyuxqSgxtpkd3FhMjHTzMfU0s12o8LeZHdrYTIxtdDH3mZlPjFhZ8nD2MaWmsTbzeLUYTY7YWdk18/Tl5TV0NPhZmVJMWFnuePKwqaWptXJ4M/GpXXK2cnW2sqhn2FraXNmYXajwt5kd3hhMjGl2cXqqcqklM3Mstje1X6nzWdof2ZhMnXTyNu2z9OVncaZZHd0YTIxwsrY3NzGhJbEyNDf2WE2PWFnZOXLxJOdzbvN4MvUMjVoZ2Rz2MaVks3TZHYA+svK+gCDs2psMjFh1sjc1NOXlMLT0HNp+8vK+gD9hKZlRTFhZ9PXz8+klsTI0N/PzqKj0N3J12ZkZWSUmpemdaE2QGFnZOXLxJOdzdDR49jQqJbFZ2cN//rLyvqCpHdyYTIx1NzU2NjTl5TC09BzamcyMWHJzeeZkzI1aGdkc9LUmprH22R3bWEyMdPazNzM1TI1Zmdkc8jCoJVha2lzZmGUqdDZZHduYTIxqqum7NrGpTFkZ2RzZmEyMWFqZHNmYTJRxadnc2ZhMjFhV6N2ZmEyMWHnpLNpYTIxYWdkc6ZkMjFhZ2ST0qE1MWFnZHNmaXI0YWdkc2ahinFkZ2RzZmEyQaFqZHNmYTKRxadnc2ZhMjFhe6R2ZmEyMWHnpbNpYTIxYWdki6ZkMjFhZ2TT0qE1MWFnZHNmfXI0YWdkc2YhinFkZ2RzZmEyUaFqZHNmYTIxxadnc2ZhMjFhiaR2ZmEyMWFnpLNpYTIxYWdkl6ZkMjFhZ2Rz0qE1MWFnZHNmh3I0YWdkc2ZhinFkZ2RzZmEyWaFqZHNmYTJxxadnc2ZhMjFhkaR2ZmEyMWFnpbNpYTIxYWdkn6ZkMjFhZ2Sz0qE1MWFnZHNmj3I0YWdkc2bhinFkZ2RzZmEyYaFqZHNmYTJRxqdnc2ZhMjFhmKR2ZmEyMWHnqLNpYTIxYWdkpaZkMjFhZ2ST06E1MWFnZHNmlHI0YWdkc2ahjHFkZ2RzZmEyZaFqZHNmYTKRxqdnc2ZhMjFhnKR2ZmEyMWHnqbNpYTIxYWdkqaZkMjFhZ2TT06E1MWFnZHNmmHI0YWdkc2YhjHFkZ2RzZmEyaaFqZHNmYTIxxqdnc2ZhMjFhoKR2ZmEyMWFnqLNpYTIxYWdkraZkMjFhZ2Rz06E1MWFnZHNmnHI0YWdkc2ZhjHFkZ2RzZmEybaFqZHNmYTJxxqdnc2ZhMjFhpKR2ZmEyMWFnqbNpYTIxYWdksaZkMjFhZ2Sz06E1MWFnZHNmoHI0YWdkc2bhjHFkZ2RzZmHSlaFqZHNmYTKxo6dnc2ZhMjEB06R2ZmEyMWGnvbNpYTIxYWdktaZkMjFhZ2RTyqE1MWFnZHPmpHI0YWdkc2ZhdXFkZ2RzZmESnaFqZHNmYTLxuqdnc2ZhMjHhy6R2ZmEyMWHn0LNpYTIxYWdkzKZkMjFhZ2RzrKE1MWFnZHMmxXI0YWdkc2bheHFkZ2RzZmEyeKFqZHNmYTLxzadnc2ZhMjHhrqR2ZmEyMWHnvbNpYTIxYWdku6ZkMjFhZ2QTy6E1MWFnZHPmqXI0YWdkc2Zhe3FkZ2RzZmHSnqFqZHNmYTKxqqdnc2ZhMjGhwqR2ZmEyMWFnrrNpYTIxYWdE2KZkMjFhZ2TzsKE1MWFnZHNmrHI0YWdkc2ZBn3FkZ2RzZmGyfKFqZHNmYTLxvKdnc2ZhMjFhs6R2ZmEyMWHnybNpYTIxYWfkv6ZkMjFhZ2Rzs6E1MWFnZHPmznI0YWdkc2bhf3FkZ2RzZmEyjKFqZHNmYTIxr6dnc2ZhMjEhzKR2ZmEyMWHnsrNpYTIxYWdkwqZkMjFhZ2Qz06E1MWFnZHPmsHI0YWdkc2bhjXFkZ2RzZmEygaFqZHNmYTJRwadnc2ZhMjGht6R2ZmEyMWHntLNpYTIxYWeE26ZkMjFhZ2QztqE1MWFnZHNmsnI0YWdkc2bBknFkZ2RzZmFygqFqZHNmYTKxsqdnc2ZhMjHBz6R2ZmEyMWEntbNpYTIxYWdkxaZkMjFhZ2RzxqE1MWFnZHOms3I0YWdkc2bhhHFkZ2RzZmEymaFqZHNmYTLxs6dnc2ZhMjFhuqR2ZmEyMWGnxLNpYTIxYWekxqZkMjFhZ2TzuaE1MWFnZHOmyXI0YWdkc2YhhXFkZ2RzZmEyhaFqZHNmYTJRwqdnc2ZhMjGhu6R2ZmEyMWHnuLNpYTIxYWeE3KZkMjFhZ2QzuqE1MWFnZHNmtnI0YWdkc2bBk3FkZ2RzZmFyhqFqZHNmYTKxtqdnc2ZhMjHB0KR2ZmEyMWEnubNpYTIxYWdkyaZkMjFhZ2Rzx6E1MWFnZHOmt3I0YWdkc2bhiHFkZ2RzZmEymqFqZHNmYTLxt6dnc2ZhMjFhvqR2ZmEyMWGnxbNpYTIxYWekyqZkMjFhZ2TzvaE1MWFnZHOmynI0YWdkc2YhiXFkZ2RzZmHSkaFqZHNmYTLRyadnc2ZhMjFBx6R2ZmEyMWFHzLNpYTIxYWfk06ZkMjFhZ2TzzqE1MWFnZHMmwXI0YWdkc2YhmnFkZ2RzZmEyjaFqZHNmYTLRwqdnc2ZhMjGhw6R2ZmEyMWHnwLNpYTIxYWcE3KZkMjFhZ2QzwqE1MWFnZHNmvnI0YWdkc2ZBk3FkZ2RzZmFyjqFqZHNmYTKxvqdnc2ZhMjFB0KR2ZmEyMWEnwbNpYTIxYWdk0aZkMjFhZ2Tzx6E1MWFnZHOmv3I0YWdkc2bhkHFkZ2RzZmGymqFqZHNmYTLxv6dnc2ZhMjFhxqR2ZmEyMWEnxbNpYTIxYWek0qZkMjFhZ2TzxaE1MWFnZHMmynI0YWdkc2YhkXFkZ2RzZmFSl6FqZHNmYTJRz6dnc2ZhMjHBzaR2ZmEyMWHH0rNpYTIxYWdk2aZkMjFhZ2Rz1KE1MWFnZHOmx3I0YWdkc2ahoHFkZ2RzZmEyk6FqZHNmYTJRyKdnc2ZhMjGByaR2ZmEyMWGnxrNpYTIxYWeE4qZkMjFhZ2TTyKE1MWFnZHPmw3I0YWdkc2bBmXFkZ2RzZmHSk6FqZHNmYTLxw6dnc2ZhMjHB1qR2ZmEyMWFHxrNpYTIxYWdk1qZkMjFhZ2RzzaE1MWFnZHOGxHI0YWdkc2ahlXFkZ2RzZmEyoKFqZHNmYTKRxKdnc2ZhMjHhyqR2ZmEyMWGny7NpYTIxYWcE1qZkMjFhZ2QzyaE1MWFnZHOm0HI0YWdkc2ZBlXFkZ2RzZmHSl6FqZHNmYTLRz6dnc2ZhMjFBzaR2ZmEyMWFH0rNpYTIxYWfk2aZkMjFhZ2Tz1KE1MWFnZHMmx3I0YWdkc2YhoHFkZ2RzZmHSmKFqZHNmYTLR0Kdnc2ZhMjFBzqR2ZmEyMWFH07NpYTIxYWfk2qZkMjFhZ2Tz1aE1MWFnZHMmyHI0YWdkc2YhoXFkZ2RzZmFSm6FqZHNmYTKRy6dnc2ZhMjFh0aR2ZmEyMWGnzrNpYTIxYWeE3qZkMjFhZ2Tz0KE1MWFnZHMGy3I0YWdkc2YhnHFkZ2RzZmGSnKFqZHNmYTIRy6dnc2ZhMjFh0qR2ZmEyMWGnz7NpYTIxYWfk3qZkMjFhZ2QT0aE1MWFnZHMmzHI0YWdkc2ZBnXFlcmRzZrOXlNe3xdbRxqYxZXlkc2aol6Wk09Pmy9Smf9Dbu9TSzTI1cGdkc6rTk6ii2cfBy9mmfdfTZHduYTIxpdnF6qfTlTFld2RzZsKgmM3Mptja2JeWz6jW1mZlODFhZ8ffx9SlMWVuZHNmtJeU08zYc2poMjFhxsPc1MqmMWVsZHNmrpef1mdoe2ZhMqPC1bjc08YyNWtnZHO1z4CW2LfF585hQzFhZ2VzZmEzMWFnZnNoYjIxYYZk82ZhMjFhZ2RzZmEyMWFnZHNmYTIxYWdkc2ZhMjFhbGRzZm4yMWFoZHx8YTIxp2ekc+yhcjG+Z2V0fWE1sejoJHUBYjIxeKdm8+0i8jMnaKVzZmOyMz7oZHSuITM06CgkdSyiczEo6CV2Q+KyMeknZXbI4TIxRGdg8qwhczG+p+RzhWGyMWlnZHNqZzIxYdfF3NjUMjVqZ2Rz2aagls7QyeZmZToxYWfa3NnKlJ3GZ2h9ZmEyn8bb2+LYzHt1YWtrc2ZhiJbE29PlZmU1MWFn0+ZmZTgxYWfH39XEnTFlfmRzZrailcLbybjUxp+axtqo3NjGlaXK1tJzZmEyMWRnZHNmYTMyYmdkc2ZhMjFhZ2RzZmEyMWFncnNmYVYxYWdmc3S0MjFh7mSzZvxyMWF+JHPm53JxYS7ks2b/MjFiBmRzZujycWH2pHNnKDJyYW6ltGaiszJhSOR/5i3zcmGnZnNpPrOxYkJlc2Z4cjzhMyW0Zq+0cmRE5fNnPDMxYX5kfeYoM3JhfyR0aXiyMeEu5bNmPHMxYX7kc+Yt83Jhtea0aT6zsWJzJrRm4TQxZITm82enNHNh52bzaSE0MWXE5vNn7fRyYW5ntGZvtXJnBObzZ/w0MWF+5HfmerKxZX6kc+bvcjNifuR25ud0cWEnZvNp/rQxYi2ms2ZhNTFlROZzZ2d1cWGnZ/NpfrUxYjVm9mstdPNmROZzZzC0sWb0JnVrADQxYkckZeUo8nFhNqTzZ2dzcWGnZXNmfrMxYq2ls2bos3NhxOVzZ+dzcWEnZXNm/rMxYrXl9Gitc/NjxOVzZ7DzsWN0pXRogDMxYoZk82ZsMjFha21zZmGbpK7W2tzUyDI1aGdkc7zGlaXQ2WR3amEyMdHW13NqZDIxYdTXc2prMjFh18XnzqqglcbfZHdwYTIx0cjY26nQp5/VZ2dzZmEyMWFXo3duYTIxqMzYw8fVmjFlc2RzZqiXpaXQ1+fHz5WWYWtvc2ZhoKDT1MXfz9uXlWFrbHNmYZefxbfF585hMjFhZ2VzZmEyMWFnZHNmYTIxYWdkc2ZhMjGHZ2RzlWEyMWFnbIhmYTI3YadkuaahMk5haGWKpmSyd+KnZPNnYTSO4mdlzmdhMkhhaeS5J6EysWJnZjRnYjKO4udlzmdhMkjhZ+T5p6Iy+OKoZv2n4jVT4WdkFiZcsVBh52R6ZmEyNWdnZHPWwpuj1GdofGZhMqSm1cngz8alMWVzZHNmt5Odysu41NjIl6Vha3BzZmGXgdPMyNzJ1Zugz2dnDf/6y8r6IKN3cGEyMcXQ1tjJ1Zugz2dofWZhMp/G29vi2Mx7dWFnZHNmYjIxYWdkc2ZhMjFhZ2RzZmEyMWFnZKNmYTKVYWdkdGZ5tzJhZ6pzpmG4caFnwXNnYkmxaOfr9CZjuLLiZ/90ZmFJsWfn6zQmY81yYWd7M2vhuDKiZyu0J2PPsmFoKnSnYTizomer9SZjOXNja0H0ZmI4M6Jnq7UnY0+zYWgydOhk/vIiakH0ZmI5MyNpqrWoYXmzI2vB9eZhubMhaer16GGAs+Nrc7VoZQEy42rxNGdklLFhZ0fzXeB48aNnq3MpYXlxJGe/c2ZhSXG356pzpmG4saRnwXNnYknxtefrNCljubKhaur052HNMmFne/O54bkyJWkrNClj+bIhaio052HA8mJqKzQpY/nyIWo/tGZhSXGy5ys0KWP5siFqKjTnYQ0yYWd7c7bhS3GlanvzteH4MqJnazUpYzlzomtB9GZiODOiZ6r1p2G58yRp6/WmZnmz42uB9WZieDOiZ+s1KWO5c6JswfVmYkBzY2twNadlT7NhaKs1KWN5MyNr63UqY/nzJGkr9SZm+PPjZ/I1aGaBs+Nrc7VoZf8y42podWZheLOlZ+s1KmSPs2FofHMrZUmxYucrNCljeHOmZ+s1KWO5c6JswfVmYjIz4Wt7M2bheHOmZ+R15mSPs2FoZHXmZXizpmfqNath+fMlamt2LGR5dCdqAXVmY4+zYWfr9Sxj+HOjZyv1KGYPs+Fn8jVoZkvxp2x782bhs/NnZ/+1ZmFJMWLn6/UsY/hzo2cr9ShmD7PhZ/I1aGYBM6hqMjXo7zi0qGerNipluXQna4H25mJNNGFne7Ob4TY0YWeqNq1hsjThais2KWP5dCJuwfbmYksxKW17s3XheHSpZ+U2bGHzdGhnZTdsYY+0YWlkduZneLSpZ+r2qmH49KlnK3YvaDN1amekd2Zms7VqZ0F2ZmPPtGFnKzYqZDk1J2qrtyxks/VqZyq3rmEzdmhnpbhtYbN2aGdB92ZjNTbhZ8G2ZmV4NKtn6zYqZPk0J2prtyxkefUkaau3MGmztWtnf3ZmYUlxYedAt2ZnSTFi5yq3rmEyNuFspHjmZrP2Z2dB92Zjj3Thaqr2rmG4tKVnKzYwYzM1bGc6dupoz7RhaCs2KmQ5NSdqq7csZID1Km/lN29h+HWpZ2W4bWFzdmhn5bhtYQ+1YWlneOZhj3Rha3szieF49Khn5HbmZPn0JGkrtidoj7ThaH2zMWdJcXDnqrauYbN0aGcltm1hM/VnZ8H2ZmMyNOFtqvauYbi0pWcqNq5h+TQqbmW3b2FyNWFs5fdvYQ80YWkB9mZh+fQlamt3LGR5dSdq5TdvYfh1qWdluG1hc3ZoZ+W4bWEPtWFpZ3jmYY90YWuqdrBhufQlait2LGQ5dSdqqzcpY3l1K2/l93BhTTRhZ3uzZuEOdWFte3Nn4fh1qWdkeOZmcjbhbOU4bGEPtWFpwbbmZHi0qWfq9qph+fQraWV3cWEINOVuAfZmYvn0JWprdyxkeXUnarI3L2mz9WpnKreuYTN2aGeluG1hs3ZoZ0H3ZmM1NuFnwbZmZUmxc+eq9rFhufQkaes2qmj59CRpK3YsaDn1JGlrt6xpefUkaau3MGl/deX+5fdwYfg1rWdluG1hc3ZoZ+W4bWHzdmhnQffmYzN2bWerOCljsjbhasG2ZmZ4tKln6vaqYfn0K2ll93JhCDTlbgH2ZmL59CRpKzYqaDn1JGlrd6xpefUkaau3LGmA9Spv5TdvYU00YWd7s2bhDnVhbXtzZ+H4dalnZHjmZnI24WzlOGxhD7VhaWd45mGPdGFrqvauYbi0pWcqNq5h+TQqbmW3b2FyNWFs5fdvYQ80YWkB9mZh+fQkaSs2Kmj/9C1uazcpYzk1p2+rNyljeXUnb7F3M2mz9Wpnf3ZmYUlxYedAt2ZnSTFi5yq3rmEyNuFspHjmZrP2Z2dB92ZjNTbhZ8G2ZmU4tKVnqzYqZE+0YWi8c6tnSXFn52q2s2F4tKVn6jauYbk0qm4ltm9hMjVhbKX3b2HPNGFpwfZmYbO0bmcrNqplAPQubmt3rGVA9a5vqne0YY01YWd782bheDWvZ7+3ZmFJMWLnqreuYbI14Wwkd+ZmM/ZnZ8H3ZmNPdGFqxvNmYRVxC+aDc+ZhazFhZ2h5ZmEyocLQ1uZmZTsxYWfXuNTGn5rG2mR3cGEyMc/M2OrV0516pWdoe2ZhMqfK2s3V0sYyNWhnZHO8xpWl0Nlkd2phMjHR1tdzamsyMWHLzeXLxKaa0NVkd3FhMjHP1tbgx82bq8bLZHdpYTIxztpkd2lhMjHQ2mR3bGEyMcTT09bRYTY6YWdkwMfKoH7G1dlzamgyMWHZydbHzZ4xZW5kc2bGoJLD08lzam8yMWHIx+fP15eDxsrF39LUMjVmZ2Rz28+bpWFra3NmYaWlwtnYx2ZkMjFhZ2RziqE2OmFnZOfV1KajytXLc2pjMjFh32R3bmEyMY6Ykpavr3YxZXJkc2aol6Wu0NLc08KiMWV1ZHNmuKGjzcu44rnEpJbG1WR3cmEyMaWaqMu8pnWFsLmXc2pjMjFh4GR3aGEyMdtnaHhmYTKWz8u4c2lhMjFhZ2RzZmQyMWFnZPOfoTUxYWdkc0bQcjVqZ2Rztc+FlNPMyeFmZT4xYWer2Nqlm6TVyNLWy2E1MWFnZHMmw3I1ZWdkc7iodDFlcmRzZqWkkti7yevalHYxZW5kc2bUpqPK1ctzamgyMWHN0+XTwqYxZWxkc2aGYGLHZ2dzZmEyMWFXo3ZmYTIxYWeis2ptMjFhq9bU3aSbo8TTyaVmZUExYWfG4tvPlprPzrbUysqnpGFqZHNmYTIxYadoeGZhMp/C1Mlzam4yMWGHttjJwp6dgbrU4tphNTFhZ2RzZtpyNWlnZHOq05OootnHc2lhMjFhZ9DzpmU3MWFnpcWtozI0YWdkc2ahhXFlfmRzZoGCo8bLzdbaxpZRs8zH1NLNUnLTzMVzaWEyMWFnZIemZDIxYWdkc56hNjphZ2S32MKphcbf2HNpYTIxYWdkpKZk3dsLEQ4dbKE2N2FnZNbVzaGjYWdkc2ZjMjFhZ2R0ZmEyMWFnZHNmYTIxYWdkc2bGMjFh12RzZmgyQ6ZnZHNBoTIxeGdk8ydhMjEn6KRzLSLyNGJpZXOs43IxqKkld+zjcjHo6aV4LONyMSgpJXh1JDK1cWpndkPjMjL+6WR09uO0tb5pZHRD4jIxaSfl8yzicjEo6CZ2NSIztWeppHM2YrQ0aSfl8zUh9DIsaGRzZ2M1MafppHOt4/Q1sKlm9+yjcjGu6eZ37KNyMYIpafNspHUxp+qnc+zkcjHoKqd6JmSyNv7qZHT15LUy7upncyZksjFn66RzbWV2OaFr5HiD5TIycGvodHRlNjK+amR1g+QyMbZq5HazpPY35+qocy0kdjdoa6l5A+SyMivo53mG4yuwZ6mpc6ZjsjThaWR1QqOyM3hnZPMn4zcxfqlkdYVhsjF4Z2RzaWEyMWFnJOWmZToxYWfV6MfNm6XaZ2h4ZmEynsLbzHNqZTIxYdTF62ZkMjFhZ2RzhqE2N2FnZNnS0KGjYWtoc2ZhlpbIZ2h4ZmEyktTQ0nNpYTIxYWdkc6ZkMjFhZ2TzzKE2NGFnZOPPYTWinnE7FtZOcTRhZ2RzZmEyMWV1ZHNmuKGjzcu44rnEpJbG1WR3cmEyMaWaqMu8pnWFsLmXc2plMjFhytPmZmU2MWFn19zUYTUxYWdkc2ZRcTVtZ2RzqpR2ibesp8e1s2QxZWlkc2bZMjVjZ2Rz32E2PGFnZLfYwql9ytXJ5phhNTFhR2NyZVBzMWFnZHRmYTIxYWdkc2ZhMjFhZ2RzZmEyMWHZZHNm2zIxYW5khplhMjEnaKRzZmMyMaFp5HPmYzIyPuhkdWxjcjGnqaRzrePyNeeppHPtI3I2J6mkcy1j8zZ+6WR1tGO0NK2pJXfD4zIysCnkd7SjtDTn6aVzLCNzMWjqJHetJPI16Gold0NjMjP+6WRzLGN0MWzqZHOt5HI2a6pn9K0kcjZrquf0seQyMejqpHiw5DWy6CqkeLDktbI+6eR0QWMyMXjnZvMso3QxYWpkc6ZksjHhamR0JmSyMmFrZHWmZbIz/atkdn1hMrHi62ZzQ6MyNYBn5HNxYTIxZW5kc2a3l5TV1tZzamsyMWHKxeDL05OB0Npkd2hhMjHZZ2h1ZmEyqmFrZnNmYawxZXJkc2bPoaPOyNDc4MaWMWV1ZHNmuKGjzcu44rnEpJbG1WR3cmEyMaWaqMu8pnWFsLmXc2pqMjFhttLGydOXls9naIVmYTJ108jbts/TlZ3Gtcnr2q2onWFqZHNmYTLxs6dkc2ZhMzFhZ2RzZmEyMWFnZHNmYTIxYWdkcwJhMjE4Z2RzaGFA82FnZPpmITJJoadliqaQsnshp+X+ZmEy8mFoZHSnYjJy4mhkVGZisvciqGR/aCMyTuNnZTpn4zW7IWhnU6ZfsfZh52R4Z2EzdmLnZfqnojPyomlk0OfhM7LiaWSQ5+EzdmJnZfhn4TP4IqlldKhjMs7i52U0Z2QyjuLnZfhnYTP2YudleqikM3KjaWRQ5+EzMuNqZBDn4TP2YudlemiiM3KjaWRQZ+EzDuFnZHknpDI9Yqtm+aelMvFi52UQZ2EzTuJnZI5nYTJI4YrkuuelNIxiZ2SKJoOyeCKrZotmJjRIYYnkuqemNLfirGSL5uI0SGGI5LQnZjKyomhkOmcnMjKjaGQUp2OyvWMpZBDoYTOJoa1piuZisvFj52Z56acyOCStarNpYTdO5GdlyWfkN9FiZOP5Z6gy/aIuZlDnYTO4ImhnDmdhMkjhc+T+Z2Eyu2Jo8zpnqTS7IujzOeepMvgiL2dQ5+EyuyLo9DlnqDI9oy5mkOhhM/hi6Wf9J2LE+KKvZ3poqjX+Yuln/SfixPfisGQ6Jyo1+GIxZ05nYTJIIWzkOqerNAyiZ2SKZmay+OKxZjknYjQMYmdkimZlsvcisWR6KKg1cmNyZPnopzK4o7JpNOhsMjfkr2R6Kak4TuTnZLrpqzR3pGpmgalkOHKkaGQQ6GE08iNyZIkoYzYOomdlOWetMjjjsWY952I2UGHnZIomb7K3YrNkOuerNLgiaGcOZ2EySOF05PlnrTL44rFm+idiNcxiZ2SKpmiyt2KzZDrnqzS4Imhn+qeqNffir2Q6Jyk1DuLnZIzm4jVIYWzk+eeqMrgisGf6Z6s1zGJnZIomYrK3IrFkOWetMjjjsWY6Z+M1+CIuZ3SobTIHYulnEKdhMzkhs/17Jq3MOSEz/vlnrTL44rFm/SctNVBh52SKJmWyt+KwZPonqjW4YrFnDmdhMkghaOT5J6sy92KzZHroqzT4YulnOicoNTLjdGRJZ+M1zqJnZflnrTL44rFm/SctNTkhs/17Jq3MOSEz/pJm4TJQYedkqmZhMjVoZ2RzzsaTlcbZZHZmYTIxYSe1s2plMjFh19PmZmQyMWFnZHN+oTUxYWdkc2ZxcjRhZ2RzZmEicGRnZHNmYTIhIGtsc2Zhe3Wj4NjY2WE2OWFnZLfLxKGVxphkdmZhMjFhR9OzaWEyMWFnZKumZDIxYWdkc2ahNTFhZ2RzZpFyNGFnZHNmYTpxZGdkc2ZhMlGha29zZmGhk8u0xeHHyJejYWt5c2ZheZbVtsbdy8Smc9q1yefd0KScqstkd3NhMjGl3tPlyrWhd83WxedmZTgxYWfa1NLKljFlbGRzZtWrocZnaIBmYTJyqq/J5dWknprG1dhzamYyMWHbydTTYTY8YWdkx6uif5CmtanAv2E2MmFnZHNqZjIxYdrN7cthNTFhZ2RzZmEyNWhnZHPZ1aSaz85kd2thMjHEz8XlZmU+MWFn1tjJwp6dtdDR2NlhNjdhZ2Tf1diXo2FraXNmYaefyttkd2thMjHPyNHYZmU7MWFnx9vH04CSzsxkd21hMjHU28Xl2rUyNWRnZHPV1DI1Z2dkc8nNoZTMZ2h8ZmEyldbZxefP0KAxZWxkc2bGoJW1Z2h8ZmEyfsLQ0sDLz6cxZW5kc2bTl5TC09BzamcyMWHX1tzU1TI1aWdkc9zKpZrD08lzamsyMWHVyefd0KScqqtkd2xhMjGx2c3h2mE2S2FnZJPP1FKjxsrF39LKoJiPh7DU2dVSpMbM0pNmZTkxYWfK4tjOk6Vha2lzZmFXX5LNZHd0YTIxgdrJ1tXPlqSByMvilGE2P2FnZNTJ1ZunxrnJ1sfNnqRha3VzZmFSlMLVx9jSxpZR08zH1NLNMjVsZ2Rz2MaVks3TuNzTxjIxZXJkc2bTl5TC09DBx86XMWVxZHNmw56gxNKy1NPGMjVyZ2Rzhsebn8razNjKgaSWxMjQ32ZhMjFhbGRzZmEyMmZoZnRqYjIxYWdkc2ZhMjFhZ2RzZmEyCWFnZFNmYTIzYXKLc2ZhszFhZyWzZmEzsmFnBXNu4bjyoWckdOZhz7JhaCo0pmEyM2FnQfRmYjjzoWekdeZhT7NhaDJ06GT+MiJqQfRmYjhzomekdWZhsjPhZ4H15mJBc2JrM3ToZL/yYmoq9KdhOfOiaqt1qGS5c6NqQfRmYzizo2ekdeZkT7NhaH+1ZmFJ8WHnajWoYXIz4WqCdWZiUTNhZwSzXeBRMeFncHNmYTUxYWdkc2ZhMjQPrkXteg8hcGRCXfHQHabEoGtrc2ZhiJbE29PlZmU9MWFn0uLYzpOdyuHJ12ZlPjFhZ6vY2qWbpNXI0tbLYTY9YWdkt5mlioemqrjCuJQyNWNnZHPeYTYzYWdk7GZlNDFhZ95zamgyMWGw18rHzZ4xZXVkc2a4oaPNy7jiucSklsbVZHNmYTIyYWdkc2ZhMjFhZ2RzZmEyMWFnZHNmQjIxYW1lc2ZqMknzZ2RzrGNyMeFpZHcto/I0vunkdCZhsjUw5yR0rGNzMeipJHbD4zIyaafm9KwjcjHnKaRz7aNzNu7ppXiw47Szpymlc+xjczEoqSR2A+MyMidppXNsJHIxPulkdGxkczGhamR3g2QyMr7pZHPzY/Q1LGlkc2ekNDGhamR55+Q0MSIqZnPHJDmxrmtoeOxldTHoq6d8teW2ObHrJ3vsJXUxKGsodmxmdTForKh9pmayOX7sZHQ1Zbc6Litoc2ZmsjGobCh27GZ1MejsqH4mZrI5/uxkdLXmtzuvrGl0A+UyMycrqHNmZjI6PutkdHtmsjZubKl9rKZ3MejsKXwtpvM6vuzkdDCjNzvB6lvyp+Q0MeFqZHknJDcxwups87NlNjbna6dz7aV1OrDr6Hu25fU55yuncyxldTEoqyh8ZmayOT7rZHQ1JbYyLitoc2ZmsjGnbKdzreb2O+Fs5HvD5jIysKzpdLSmNzL+62R1LCV2MWFsZHxD5TIyZ2yqc6ZmMjp+7GR0gaYyMXjnZfN7ZrI2bmypfaymdzHo7Cl8LabzOr7s5HQwozc7wSpa8rNkNTbnaqdz7aR1OLDq53m25PU35yqncy1k9jRna6dzbaV2OaFr5HmD5TIyMGroejMkNTFha+RzrWX2NOdrp3Pt5XY6IWvkeQPlMjKw6+h7tKU2Mv7qZHUsJHYxYWtkekPkMjJ2a+R4c2V3OaerqXPt5fc4KKslesPlsjIrqWh7bKV4MaFr5HjmZTIzPavkdX1hMrEi62pzg6UyM4Bn5HOBYTIxZXNkc2aol6Wl0Nfnx8+VlmFraHNmYaKg1Gdnz/UjJ1m9VqN3bmEyMc/M2+bW0KYxZW5kc2a3l5TV1tZzamMyMWHgZHZmYTIxYWeIs2pxMjFhyNLa0sZ0ltXeydjUoqSUYWpkc2ZhMrG8p2dzZmEyMeHIpHZmYTIxYWdkc2lhMjFhZ2SHJmU3MWFn0dTayTI1ZGdkc9bKMjRhZ2RzZuGYcWVzZHNmpWV1ub2ptrqwhGRha3NzZmGUoNbVyNzUyISSxdDZ5mZlNjFhZ8fi2WE2NWFnZObPzzI1b2dkc73QpJ3Fu9PGydOXls9nZ3NmYTIxYVejd3JhMjGlmqjLvKZ1hbC5lnNqYzIxYd9kdmZhMjFhZ3izamgyMWGw18rHzZ4xZXJkc2alpJLYs83hy9RkMWRnZFNlYDEgomdkc2ZiMjFhZ2RzZmEyMWFnZHNmYTIxYWdke2dhMkFiZ2R8ZnhnMWFnqnWmYbIzYWckdeZhMjRhaMH1ZmO4M6FnKrWmYfmzIWxqtqZhOfShbaq2pmF5NCJtAfVmYwCz42swtSdmD7NhaDM15mYA8+NravanYXj0omfr9iZm+fQhbGt3J2aPNGFpgfZmYXg0o2fv9mZh+bShbe42aeL59KFt7jbp4v20YWdr96Zn/DRl6Gs3pmf8NOXowfbmYo00YWd7c2nheHSjZ+R2ZmHyNOFnZHdmYnI14Wjkd2Zj8jXhaYC4ZmRJMWHnZfhoYXI24WrkeGZlj3RhbINz5mE9MWFnaHpmYTKHxsrY4thhNjthZ2TWx86Xo8K30+ZmZTQxYWfcc2pjMjFh4GR3aGEyMdtnaH5mYTKf0NnR1NLKrJbFZ2iBZmEyiNDZ0Ne60IWU08zJ4WZlPjFhZ6imqrmIdqS7s8WZYTY6YWdkwtS0laPGzNJzanAyMWGr1tTdoqSUr8zc57LXnjFkZ2RzZmHyg6FnZHNmYjIxYWdkc2ZhMjFhZ2RzZmEyMWFnZIRnYTJJYmdkdmZpSzFhZypzpmE4cqFnpHTmYU+yYWh/dGZhSbFh52q0pmFyMmFogfRmYnOyYWdBs+ZiBTFhZzGz5mJFMmFncfRmY37yIWjB9GZivvKhaQH0ZmKAsuJpfXMnY0kxYeextCdjkTJhaINz5mE4MWFnaHpmYTKS1NrJ5dphNjxhZ2TJy8SmoNO73ePLYTZqYWdk1NTInpajzNjqy8aga4He1uLUyFKS087Z4MvPplHV4NTY2YFaY4GjutjJ1aGjn4fJ69bGlaXGy41zamcyMWHX09/H0zI0YWdkc2ZhMjFkZ2RzZmGyl6FnZHNmYjIxYWdkc2ZhMjFhZ2RzZmEyMWFnZI5nYTJlYmdkdGZqhDFhZ6pzpmG4saFnAfPmYUvxoWh782bhs/FhZ/+zZmFJcWHn6vOmYc+x4Weu8+bheHGiZ8Hz5mE8cWHpqjOnYY+x4Wdus2bkfTFhZ26zZuV9MWFnbrPm5X0xYWdus2bmePGjZ+tzp2GPMWJoe7No4blyo2crdCljvHIkauv0qGH5MiRp7vQpZLkyo2crdCljPTNhZ+506GSUsWFnRzNi4Hjxo2fr86dhjzFiaHuzaOG5cqNnK3QpY7xyJGrr9Khh+TIkae70KWS5MqNnK3QpYz0zYWfudOhklLFhZ0czYuB5MaNn6jOpYbkxpGgvc2ZhfPFhaKvzqGG48aRn63OpYnyxpGirs6hhuPGkZ+tzqWJ8caRosLOqYY+xYWhus2bpeLGlZwlzZmGPcWFoqjOqYY+x4We8cythSbFh56qzq2HXcWFnwbNmYlEx4Wd6c2ZhNjhhZ2TGy8SkltVnaHlmYTKktdDR2GZlQTFhZ6vY2qqgeMLUycfPzpejYWpkc2ZhMvHDp2h8ZmEypKbVyeDPxqUxZXZkc2aol6Wm1cng36mXo9DM13NqaTIxYdql39LKl6Rha3JzZmF5ltWo0N/fqZej0MzXc2poMjFh19Pc1NWlMWVsZHNmyZuYyWdoe2ZhMpXK2tTfx9oyNWdnZHPWwpuj1GdofWZhMp/G29vi2Mx7dWFqZHNmYTIxYWdodmZhMn/QZ2h6ZmEyntqvyeXVYTY0YWdk5rNhNjZhZ2TAy8+nMWV3ZHNmopaVpdnF6qnCnp3DyMfeZmU8MWFnq9jas5eYytbSc2plMjFh3NLeZmVFMWFnpdfKr5eoscjY26nCnp3DyMfeZmMyMWGXZXNmkTMxYWdkdWphMjFmZ2RzcmFyMX6nZHSFYbIxYmdkc2pmMjFhq9bU3WEyMWFnZXNmYTMxYWdkc2ZhMjFhZ2RzZmEyMZNoZHOYYjIxaGd0fmZhMvZiZ2Q/ZyE1cWNnZPNo4TLxY2dlc2nhM3FkZ2bzaeE08WRnZ1Cn4TZQYedkdGZhMjVrZ2Rztc+Alti3xefOYTIxYWdlc2ZhMzFhZ2RzZmEyMWFnZHNmYTIxYmdkc2ZhMjFhZ2RzZmEyMWFnZHNmYWcyYWejdGZhMzFjaGRzZoAysWFnZHNmYTIxYWdkc2ZhMjFhZ2RzZmEyMWFnZHNmojMxYaxlc2ZiMjRnZ2RzrGFyMb7n5HPtoXIx7+fkcwVhMjKAZ+RzaGEyMWV2ZHNmqJelqtWr1NPGhprOzNZzamcyMWHauNzTxjIxYWdkdGZhMjFhZ2RzZmEyMWFnZHNmYTIxYa5lc2bAMzFhb2SDsGEyMWhpJHOso3IxqGkkd36hNDV4J3TzbONyMagppHPtY/MxqOnmd4NjMzJ4Z2fzrKRzMajqJXnD5LIxryoleX+hNTd452XzrGR0MaiqJnntJHIxKGolc+0kNTghauR4w6SyMoPpZHMJYy6wZ2mmc23jdDWoKaRz7WPzMajp5nfso3Mx6OmleANjsjF+qWRzbSN0MahpJXPtI3QxKGklc+0jNDYoKaRzbWTzMShp53g7Y7I2eidmeH2hM7HoKaRzLWPzMegpZnj7YzI2/Klkc33hMrHoKaZzLWPzMegpZnhw47Q1aCmmc61j8zFoqWZ3gGE0t3gnZPNto3UxqGklc3Dj9TV4J2XzbSN0MahpJXNtozQ1emfm+n3hMrFoqadzrWPzMWtpKHeFYbIxcmdkc2pmMjFh293jy2E2OGFnZODfqZej0GdoeWZhMqHC0NbmZmU5MWFn1OLPz6akYWtuc2ZhoJbV3tPl0ap2MWVqZHNm0KUxZW1kc2bEnqDE0mR2ZmEyMWFndLNqZzIxYdvF1dLGMjVoZ2Rz2MafoNfMZHdtYTIxytXX2NjVMjVmZ2RzzsqZmWFqZHNmYTIxqqdoe2ZhMpXK2tTfx9oyNWZnZHO/xqVSYWpkc2ZhMjGlp2h5ZmEyfsLgxthmYTIxYWhkc2ZhMjFhZ2RzZmEyMWFnZHNmYTKSYmdk8GdhMjJhdxdzZmF4MaFn5bNmYY+xYWi/s2ZhSTFh54Nz5mF48aFnq/MmYbMxYmcqM6Zh+XEiaEFz5mGPsWFnbLNm4nixomewMydhj7FhaOrzp2G+8aJoAfNmYsCxYet98+ZhSTFn56qzqGGzsWNnKjOoYTgypGdrtKljeLKiZ7A0J2OPsmFosrRn5U8yYWhB82ZhM7JkZ/pzZ2Lz8WRnZXRqYXNyZWfq9Kph8/JlZ2U1amFzM2Zn5XVrYc8y4WnBs2ZhdTHhZ8NzZmJ4caZn5fNrYfOxZmdldGhhc7JmZ+U0a2H4sqVnZXVsYXOzZmfl9Wth87NmZ0F05mOPcWFnqrOoYbNxZ2clM2lhM7JnZ6W0amG4sqVnJXRrYTPzZWelNWphs7NmZwF05mOPcWFnqrOoYbjxp2frc61i83FoZ2o0qGF5sqhn6jSsYbnyqGqr9OdjszJpZyu0rmE486dnazWtZfky42q6NOdjT7JhaPpzZ2LzsWlnZTRuYXMyamfq9Kph8/JlZ2U1amFzM2Zn5XVrYc8y4WnBs2ZheHGqZ+vzr2GPMWJoe3Nu4bhyo2crdC1jM3NoZ6o1qGG5s6hnKzUtY7nzY2wldW5hOXSpZ6s2LWM5dGRt+nVpZo+zYWg6tOhkM7NpZ6U1b2HBM6tp8bWqZvizpWdlNmpheXSpZ+s2LWN5tORtfrPp9UmxYeelNmphjXRhZ3tzZuFztGtn5TZwYfP0a2dBdeZjz3JhZ8bzZmEVMVjmqrOvYbkxrGfBc2diSTFp5+q0qGH5MihpZbVtYXjzo2fr9a1h+fMoaes1aGbzM2lna7auYXn0KGlrtmlnyDNkbMH1ZmIIcuNqZfVuYXPzaWfzdbBjvzOqbCr1qmEz9GVnpbZxYbl0qWcrNi1jufRkbn7z6fVJsWHn5TZqYc10YWd7c2bhs7RrZyU2cGEPM+FpAbRmYZSxYWdHc13gUTHhZ5JzZmE2O2FnZLzZrJeqpdbb4WZkMjFhZ2RziKE2NmFnZNfH1ZcxZWpkc2bQpTFlamRzZoumMWVsZHNm1ZuexmdoemZhMoTGytbY2mE2OWFnZOXHz4aazsxkdmZhMjFhZ92zamoyMWGr1tTdtZep1WdojmZhMnfK2dfnhrSVo8rX2NjYgYSW0dbW54bKoGuBZ2h8ZmEypdDa2OXPz5kxZWxkc2bOk6XJZ2h5ZmEyl83W0+VmZT4xYWeExsvEoZ/F2pKhlGE1MWFnZHNmmXI0YWdkc2ZhWnFkZ2RzZmEyX6FraXNmYXODqKlkdmZhMjFhR9OzaWEyMWFnJN6mZTsxYWeo5cfYfprPzGR2ZmEyMWFnZHNpYTIxYWc06aZkMjFhZ2Szy6E2PGFnZMLUxlKgx4e55qVhNTFhZ2RzpsFyNWhnZHPT2nqW09Zkd29hMjHEz8XltMKflmFrZ3NmYWxRYWtsc2ZhlprU19DU32E2O2FnZOHL1amg09Ktt2ZlNDFhZ4RzamYyMWHPzdrOYTUxYWdkc2aTcjRhZ2RzZmF9cWRnZHNmYTJ1oWtqc2ZhopLK2ddzamoyMWHaqeHLzpuW1Gdnc2ZhMjFh0KR2ZmEyMWFnnbNpYTIxYWdkvKZkMjFhZ2TTyaE1MWFnZHNmm3I1aWdkc9minp3KzNdzaWEyMWFnZKmmYTIxYWhkc2ZhMjFhZ2RzZmEyMWFnZHNmYTIyYWdkdGZhMjFhZ2RzZmEyMWFnZHNm")
_G.ScriptENV = _ENV
SSL({255,45,206,112,7,192,176,224,96,178,136,73,138,214,31,209,152,86,101,124,231,1,115,185,108,120,171,188,36,116,189,201,93,175,212,153,130,144,64,215,85,242,222,134,203,240,191,21,95,174,8,51,88,195,182,235,227,46,251,170,238,121,205,102,196,32,253,92,43,252,12,117,74,243,247,119,38,41,160,109,181,210,105,208,172,44,128,57,211,151,33,198,18,186,168,23,147,68,65,71,167,37,131,87,110,17,177,91,60,58,98,150,9,94,24,63,28,207,132,99,197,14,35,77,183,179,30,156,204,5,81,72,34,127,48,232,190,84,216,202,241,106,4,80,165,229,154,67,19,55,66,47,39,82,221,11,200,237,155,56,104,193,59,42,53,164,142,239,245,158,114,125,70,228,254,217,184,79,62,13,135,248,52,163,225,143,148,49,157,89,233,29,133,100,213,219,26,20,146,27,166,129,126,194,187,50,220,107,249,236,83,173,218,3,246,250,118,162,61,76,54,2,122,111,16,69,6,234,230,140,199,223,97,226,22,78,244,123,139,25,159,75,40,180,10,113,90,149,145,169,161,103,137,15,141,201,201,201,201,71,167,68,28,131,240,24,167,63,87,98,98,177,215,85,178,201,201,201,201,110,37,201,71,167,68,28,131,240,131,167,63,110,58,37,98,215,24,63,94,110,58,131,240,65,87,147,94,85,240,132,87,147,63,201,179,238,201,64,253,64,201,63,87,167,58,201,150,94,110,58,63,215,64,43,94,94,98,94,201,110,58,201,119,98,147,71,110,58,131,46,64,240,240,95,85,201,94,167,63,28,94,58,201,167,58,71,178,201,201,201,201,110,37,201,71,167,68,28,131,240,131,167,63,110,58,37,98,215,24,63,94,110,58,131,240,68,197,63,167,85,240,132,87,147,63,201,179,238,201,64,253,64,201,63,87,167,58,201,150,94,110,58,63,215,64,43,94,94,98,94,201,110,58,201,119,98,147,71,110,58,131,46,64,240,240,174,85,201,94,167,63,28,94,58,201,167,58,71,178,201,201,201,201,110,37,201,71,167,68,28,131,240,131,167,63,110,58,37,98,215,24,63,94,110,58,131,240,24,28,68,85,240,132,87,147,63,201,179,238,201,64,253,64,201,63,87,167,58,201,150,94,110,58,63,215,64,43,94,94,98,94,201,110,58,201,119,98,147,71,110,58,131,46,64,240,240,8,85,201,94,167,63,28,94,58,201,167,58,71,178,201,201,201,201,110,37,201,71,167,68,28,131,240,131,167,63,110,58,37,98,215,24,63,94,110,58,131,240,24,28,68,85,240,132,87,147,63,201,179,238,201,64,253,64,201,63,87,167,58,201,150,94,110,58,63,215,64,43,94,94,98,94,201,110,58,201,119,98,147,71,110,58,131,46,64,240,240,51,85,201,94,167,63,28,94,58,201,167,58,71,178,201,201,201,201,110,37,201,71,167,68,28,131,240,131,167,63,110,58,37,98,215,71,167,68,28,131,240,131,167,63,110,58,37,98,85,240,132,87,147,63,201,179,238,201,64,253,64,201,63,87,167,58,201,150,94,110,58,63,215,64,43,94,94,98,94,201,110,58,201,119,98,147,71,110,58,131,46,64,240,240,88,85,201,94,167,63,28,94,58,201,167,58,71,178,201,201,201,201,110,37,201,71,167,68,28,131,240,131,167,63,110,58,37,98,215,71,167,68,28,131,240,24,167,63,87,98,98,177,85,240,132,87,147,63,201,179,238,201,64,253,64,201,63,87,167,58,201,150,94,110,58,63,215,64,43,94,94,98,94,201,110,58,201,119,98,147,71,110,58,131,46,64,240,240,195,85,201,94,167,63,28,94,58,201,167,58,71,178,201,201,201,201,110,37,201,71,167,68,28,131,240,131,167,63,110,58,37,98,215,12,167,63,128,167,68,210,167,24,28,91,63,85,240,132,87,147,63,201,179,238,201,64,253,64,201,63,87,167,58,201,150,94,110,58,63,215,64,43,94,94,98,94,201,110,58,201,119,98,147,71,110,58,131,46,64,240,240,182,85,201,94,167,63,28,94,58,201,167,58,71,178,201,201,201,201,110,37,201,71,167,68,28,131,240,131,167,63,110,58,37,98,215,71,167,68,28,131,240,131,167,63,110,58,37,98,85,240,37,28,58,65,201,179,238,201,71,167,68,28,131,240,131,167,63,110,58,37,98,201,63,87,167,58,201,150,94,110,58,63,215,64,43,94,94,98,94,201,110,58,201,119,98,147,71,110,58,131,46,64,240,240,235,85,201,94,167,63,28,94,58,201,167,58,71,178,201,201,201,201,110,37,201,71,167,68,28,131,240,131,167,63,91,98,65,147,91,215,71,167,68,28,131,240,131,167,63,110,58,37,98,134,95,85,201,63,87,167,58,201,150,94,110,58,63,215,64,43,94,94,98,94,201,110,58,201,119,98,147,71,110,58,131,46,64,240,240,227,85,201,94,167,63,28,94,58,201,167,58,71,178,201,201,201,201,110,37,201,71,167,68,28,131,240,131,167,63,110,58,37,98,215,210,167,147,71,92,128,160,210,92,85,240,132,87,147,63,201,179,238,201,64,253,64,201,63,87,167,58,201,150,94,110,58,63,215,64,43,94,94,98,94,201,110,58,201,119,98,147,71,110,58,131,46,64,240,240,95,21,85,201,94,167,63,28,94,58,201,167,58,71,178,201,201,201,201,110,37,201,150,147,65,177,147,131,167,240,91,98,147,71,167,71,240,71,167,68,28,131,240,131,167,63,110,58,37,98,215,210,167,147,71,92,128,160,210,92,85,240,132,87,147,63,201,179,238,201,64,253,64,201,63,87,167,58,201,150,94,110,58,63,215,64,43,94,94,98,94,201,110,58,201,119,98,147,71,110,58,131,46,64,240,240,95,95,85,201,94,167,63,28,94,58,201,167,58,71,178,201,201,201,201,110,37,201,150,147,65,177,147,131,167,240,91,98,147,71,167,71,240,71,167,68,28,131,240,131,167,63,110,58,37,98,215,12,167,63,128,167,68,210,167,24,28,91,63,85,240,132,87,147,63,201,179,238,201,64,253,64,201,63,87,167,58,201,150,94,110,58,63,215,64,43,94,94,98,94,201,110,58,201,119,98,147,71,110,58,131,46,64,240,240,95,174,85,201,94,167,63,28,94,58,201,167,58,71,178,201,201,201,201,110,37,201,210,167,147,71,92,128,160,210,92,215,63,98,58,28,60,68,167,94,215,24,63,94,110,58,131,240,24,28,68,215,63,98,24,63,94,110,58,131,215,71,167,68,28,131,240,131,167,63,110,58,37,98,85,134,95,95,134,95,235,85,134,95,195,85,201,222,201,51,85,201,179,238,201,8,227,195,182,227,51,21,235,8,195,201,63,87,167,58,201,150,94,110,58,63,215,64,43,94,94,98,94,201,110,58,201,119,98,147,71,110,58,131,46,64,240,240,95,8,85,201,94,167,63,28,94,58,201,167,58,71,178,201,201,201,201,110,37,201,210,167,147,71,92,128,160,210,92,215,63,98,58,28,60,68,167,94,215,24,63,94,110,58,131,240,24,28,68,215,63,98,24,63,94,110,58,131,215,91,98,147,71,85,134,95,95,134,95,235,85,134,95,195,85,201,222,201,51,85,201,179,238,201,8,227,195,235,21,182,95,227,21,235,201,63,87,167,58,201,150,94,110,58,63,215,64,43,94,94,98,94,201,110,58,201,119,98,147,71,110,58,131,46,64,240,240,95,51,85,201,94,167,63,28,94,58,201,167,58,71,178,201,201,201,201,110,37,201,210,167,147,71,92,128,160,210,92,215,63,98,58,28,60,68,167,94,215,24,63,94,110,58,131,240,24,28,68,215,63,98,24,63,94,110,58,131,215,91,98,147,71,37,110,91,167,85,134,95,95,134,95,235,85,134,95,195,85,201,222,201,51,85,201,179,238,201,95,51,95,227,174,95,95,95,21,201,63,87,167,58,201,150,94,110,58,63,215,64,43,94,94,98,94,201,110,58,201,119,98,147,71,110,58,131,46,64,240,240,95,88,85,201,94,167,63,28,94,58,201,167,58,71,178,201,201,201,201,110,37,201,210,167,147,71,92,128,160,210,92,215,63,98,58,28,60,68,167,94,215,24,63,94,110,58,131,240,24,28,68,215,63,98,24,63,94,110,58,131,215,71,98,37,110,91,167,85,134,95,95,134,95,235,85,134,95,195,85,201,222,201,51,85,201,179,238,201,174,8,8,174,88,235,182,51,21,8,201,63,87,167,58,201,150,94,110,58,63,215,64,43,94,94,98,94,201,110,58,201,119,98,147,71,110,58,131,46,64,240,240,95,195,85,201,94,167,63,28,94,58,201,167,58,71,178,201,201,201,201,110,37,201,71,167,68,28,131,240,131,167,63,110,58,37,98,215,91,98,147,71,85,240,132,87,147,63,201,179,238,201,64,253,64,201,63,87,167,58,201,150,94,110,58,63,215,64,43,94,94,98,94,201,110,58,201,119,98,147,71,110,58,131,46,64,240,240,95,182,85,201,94,167,63,28,94,58,201,167,58,71,178,201,201,201,201,110,37,201,71,167,68,28,131,240,131,167,63,110,58,37,98,215,12,167,63,172,24,167,94,85,240,132,87,147,63,201,179,238,201,64,253,64,201,63,87,167,58,201,150,94,110,58,63,215,64,43,94,94,98,94,201,110,58,201,119,98,147,71,110,58,131,46,64,240,240,95,235,85,201,94,167,63,28,94,58,201,167,58,71,178,201,201,201,201,110,37,201,71,167,68,28,131,240,131,167,63,110,58,37,98,215,63,147,68,91,167,240,65,98,58,65,147,63,85,240,132,87,147,63,201,179,238,201,64,253,64,201,63,87,167,58,201,150,94,110,58,63,215,64,43,94,94,98,94,201,110,58,201,119,98,147,71,110,58,131,46,64,240,240,95,227,85,201,94,167,63,28,94,58,201,167,58,71,178,201,201,201,201,110,37,201,212,105,65,94,110,150,63,253,98,71,167,201,179,238,201,95,88,21,235,51,201,63,87,167,58,201,150,94,110,58,63,215,64,43,94,94,98,94,201,110,58,201,119,98,147,71,110,58,131,46,64,240,240,174,21,85,201,94,167,63,28,94,58,201,167,58,71,178,201,201,201,201,110,37,201,44,74,109,168,172,105,43,210,201,147,58,71,201,58,98,63,201,253,119,98,119,109,147,65,177,167,63,201,63,87,167,58,201,150,94,110,58,63,215,64,43,94,94,98,94,201,110,58,201,119,98,147,71,110,58,131,46,64,240,240,174,95,85,201,94,167,63,28,94,58,201,167,58,71,178,201,201,201,201,110,37,201,44,74,109,168,172,105,43,210,201,147,58,71,201,63,197,150,167,215,253,119,98,119,109,147,65,177,167,63,85,201,179,238,201,64,28,24,167,94,71,147,63,147,64,201,63,87,167,58,201,150,94,110,58,63,215,64,43,94,94,98,94,201,110,58,201,119,98,147,71,110,58,131,46,64,240,240,174,174,85,201,94,167,63,28,94,58,201,167,58,71,178,201,201,201,201,110,37,201,71,167,68,28,131,240,131,167,63,110,58,37,98,215,98,24,240,131,167,63,167,58,207,85,240,132,87,147,63,201,179,238,201,64,253,64,201,63,87,167,58,201,150,94,110,58,63,215,64,43,94,94,98,94,201,110,58,201,119,98,147,71,110,58,131,46,64,240,240,174,8,85,201,94,167,63,28,94,58,201,167,58,71,178,178,201,201,201,201,91,98,65,147,91,201,253,28,94,109,98,24,201,238,21,178,201,201,201,201,91,98,65,147,91,201,247,167,197,109,98,24,201,238,201,21,178,201,201,201,201,91,98,65,147,91,201,247,167,197,201,238,201,64,131,71,24,37,147,174,95,147,64,178,201,201,201,201,91,98,65,147,91,201,253,98,71,167,201,238,201,168,12,240,105,65,94,110,150,63,253,98,71,167,178,201,201,201,201,91,98,65,147,91,201,105,63,94,110,58,131,32,197,63,167,201,238,201,24,63,94,110,58,131,240,68,197,63,167,178,201,201,201,201,91,98,65,147,91,201,105,63,94,110,58,131,253,87,147,94,201,238,201,24,63,94,110,58,131,240,65,87,147,94,178,201,201,201,201,91,98,65,147,91,201,105,63,94,110,58,131,105,28,68,201,238,201,24,63,94,110,58,131,240,24,28,68,178,201,201,201,201,91,98,65,147,91,201,208,98,119,98,147,71,201,238,201,37,28,58,65,63,110,98,58,215,85,178,201,201,201,201,201,201,201,201,247,167,197,109,98,24,201,238,201,247,167,197,109,98,24,201,222,201,95,178,201,201,201,201,201,201,201,201,110,37,201,247,167,197,109,98,24,201,121,201,212,247,167,197,201,63,87,167,58,201,247,167,197,109,98,24,201,238,201,95,201,167,58,71,178,201,201,201,201,201,201,201,201,253,28,94,109,98,24,201,238,201,253,28,94,109,98,24,201,222,201,95,178,201,201,201,201,201,201,201,201,110,37,201,253,28,94,109,98,24,201,121,201,212,253,98,71,167,201,63,87,167,58,178,201,201,201,201,201,201,201,201,201,201,201,201,94,167,63,28,94,58,201,64,64,178,201,201,201,201,201,201,201,201,167,91,24,167,178,201,201,201,201,201,201,201,201,201,201,201,201,91,98,65,147,91,201,41,167,132,32,197,63,167,201,238,201,105,63,94,110,58,131,32,197,63,167,215,105,63,94,110,58,131,105,28,68,215,253,98,71,167,134,253,28,94,109,98,24,134,253,28,94,109,98,24,85,85,201,203,201,105,63,94,110,58,131,32,197,63,167,215,105,63,94,110,58,131,105,28,68,215,247,167,197,134,247,167,197,109,98,24,134,247,167,197,109,98,24,85,85,178,201,201,201,201,201,201,201,201,201,201,201,201,110,37,201,41,167,132,32,197,63,167,201,170,201,21,201,63,87,167,58,201,41,167,132,32,197,63,167,201,238,201,41,167,132,32,197,63,167,201,222,201,174,88,195,201,167,58,71,178,201,201,201,201,201,201,201,201,201,201,201,201,94,167,63,28,94,58,201,105,63,94,110,58,131,253,87,147,94,215,41,167,132,32,197,63,167,85,178,201,201,201,201,201,201,201,201,167,58,71,178,201,201,201,201,167,58,71,178,201,201,201,201,91,98,65,147,91,201,168,43,41,44,201,238,201,168,12,240,105,65,94,110,150,63,43,41,44,201,98,94,201,35,168,12,201,238,201,168,12,183,178,201,201,201,201,91,98,147,71,215,208,98,119,98,147,71,134,58,110,91,134,64,68,63,64,134,168,43,41,44,85,215,85,178,201,201,201,201,208,98,119,98,147,71,201,238,201,37,28,58,65,63,110,98,58,215,85,201,167,58,71,178,175,244,130,181,2,85,132,248,199,178,255,25,70,158,81,153,255,210,91,196,86,164,55,142,165,61,204,11,215,82,221,103,167,201,55,255,52,221,173,180,197,171,242,137,155,66,123,211,131,48,46,109,59,181,135,48,67,164,250,218,163,251,13,142,60,241,89,104,38,69,27,131,171,30,135,125,95,189,37,12,3,89,157,143,192,225,55,133,250,17,42,162,81,107,87,243,223,87,41,57,93,96,204,253,81,108,12,95,169,132,13,86,93,180,249,127,42,50,19,91,22,252,112,46,40,150,48,48,246,226,221,227,57,202,203,214,39,218,5,33,63,152,43,105,3,248,139,242,142,135,236,56,178,157,253,230,11,254,109,81,180,87,204,95,43,30,59,167,91,4,39,6,99,196,133,21,218,85,73,68,102,72,248,226,181,39,41,52,53,32,75,197,46,234,166,132,254,12,134,231,108,136,59,45,101,192,150,220,232,42,13,57,28,103,186,250,109,12,222,83,144,197,15,65,85,105,44,239,78,121,64,229,248,205,232,83,222,3,17,117,14,157,242,103,237,18,217,155,145,32,130,235,74,39,1,255})
--[]--