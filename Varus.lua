if myHero.charName ~= "Varus" then return end

function Print(message) print("<font color=\"#0000e5\"><b>Ralphlol's Varus:</font> </b><font color=\"#FFFFFF\">".. message.."</font>") end
require "VPrediction"
vPred = VPrediction()

function Menu()
VarusMenu = scriptConfig("Ralphlol Varus", "VarusLOL")
	VarusMenu:addSubMenu("Combo Settings", "combo")
		VarusMenu.combo:addParam("qMana", "Use Q combo if  mana is above", SCRIPT_PARAM_SLICE, 5, 0, 100, 0) 
		VarusMenu.combo:addParam("eMana", "Use E combo if  mana is above", SCRIPT_PARAM_SLICE, 30, 0, 100, 0) 
		VarusMenu.combo:addParam("E", "Use E in Combo", SCRIPT_PARAM_ONOFF, true)
		VarusMenu.combo:addParam("R", "Use R in Combo", SCRIPT_PARAM_ONOFF, true)
		VarusMenu.combo:addParam("Rcount", "R min enemies to hit", SCRIPT_PARAM_SLICE, 3, 1, 5, 0)
 
	VarusMenu:addSubMenu("Harass Settings", "harass") 
		VarusMenu.harass:addParam("qMana", "Use Q harass if  mana is above", SCRIPT_PARAM_SLICE, 20, 0, 100, 0) 
		VarusMenu.harass:addParam("eMana", "Use E harass if  mana is above", SCRIPT_PARAM_SLICE, 75, 0, 100, 0) 
		VarusMenu.harass:addParam("E", "Use E in Harass", SCRIPT_PARAM_ONOFF, false)

	VarusMenu:addSubMenu("Wave Clear Settings", "farm")
	 	VarusMenu.farm:addParam("qMana", "Use Q if  mana is above", SCRIPT_PARAM_SLICE, 30, 0, 100, 0) 
		VarusMenu.farm:addParam("eMana", "Use E if  mana is above", SCRIPT_PARAM_SLICE, 70, 0, 100, 0) 
		VarusMenu.farm:addParam("Q", "Use Q in Wave Clear", SCRIPT_PARAM_ONOFF, true)
		VarusMenu.farm:addParam("E", "Use E in Wave Clear", SCRIPT_PARAM_ONOFF, true)
		
	VarusMenu:addSubMenu("General Settings", "sett")
		VarusMenu.sett:addParam("ksq", "KS with Q", SCRIPT_PARAM_ONOFF, true)
		VarusMenu.sett:addParam("kse", "KS with E", SCRIPT_PARAM_ONOFF, true)
		VarusMenu.sett:addParam("ksr", "KS with R", SCRIPT_PARAM_ONOFF, false)
		VarusMenu.sett:addParam("sel", "Focus Selected Target", SCRIPT_PARAM_ONOFF, false) 
		VarusMenu.sett:addParam("autoBuy", "Auto-Buy Starting Items", SCRIPT_PARAM_ONOFF, true) 
		VarusMenu.sett:addParam("Target", "Target Mode:", SCRIPT_PARAM_LIST, 3, { "Less Cast", "Near Mouse", "Less Cast Priority" })
		VarusMenu.sett:addParam("pred", "Prediction Method:", SCRIPT_PARAM_LIST, 1, { "VPrediction", "Divine Prediction", "HPrediction"})
		
		VarusMenu.sett:addSubMenu("Draw Settings", "drawing") 
			VarusMenu.sett.drawing:addParam("mDraw", "Disable All Range Draws", SCRIPT_PARAM_ONOFF, false) 
			VarusMenu.sett.drawing:addParam("Target", "Draw Circle on Target", SCRIPT_PARAM_ONOFF, true)  
			VarusMenu.sett.drawing:addParam("aaDraw", "Draw AA Range", SCRIPT_PARAM_ONOFF, true)
			VarusMenu.sett.drawing:addParam("hitDraw", "Draw My Hitbox", SCRIPT_PARAM_ONOFF, true)
			VarusMenu.sett.drawing:addParam("qDraw", "Draw (Q) Range", SCRIPT_PARAM_ONOFF, true) 
			VarusMenu.sett.drawing:addParam("eDraw", "Draw (E) Range", SCRIPT_PARAM_ONOFF, false) 
			VarusMenu.sett.drawing:addParam("rDraw", "Draw (R) Range", SCRIPT_PARAM_ONOFF, false) 
			
	VarusMenu:addSubMenu("Orbwalking Settings", "Orbwalking") 	
		
	VarusMenu:addSubMenu("Keybindings", "keys") 
		VarusMenu.keys:addParam("comboKey", "Full Combo Key (SBTW)", SCRIPT_PARAM_ONKEYDOWN, false, 32) 
		VarusMenu.keys:addParam("lastKey", "Last Hit Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("X")) 
		VarusMenu.keys:addParam("harassKey", "Harass Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("C")) 
		VarusMenu.keys:addParam("laneKey", "Wave Clear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("V")) 
		VarusMenu.keys:addParam("forceUltKey", "Force Ult", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("T")) 
	
	--VarusMenu:addParam("info22","", SCRIPT_PARAM_INFO, "")	
	--VarusMenu:addParam("instruct", "Click For Instructions", SCRIPT_PARAM_ONOFF, false)

	TSAA = TargetSelector(TARGET_LESS_CAST_PRIORITY, 800, DAMAGE_PHYSICAL)
		
	TargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, 2000, DAMAGE_PHYSICAL)
	TSAA.name = "AA"
	TargetSelector.name = "Varus"
	
	enemyMinions = minionManager(MINION_ENEMY, 1500, myHero)
	jungleMinions = minionManager(MINION_JUNGLE, 900, myHero)
end

function hPredOn()
	if FileExist(LIB_PATH.."HPrediction.lua") then
		require 'HPrediction'
		HPred = HPrediction()
		
		if _G.HPrediction_Version then
			hpEnabled = true
			HP_Q = HPSkillshot({delay = 0.25,range = 1625,speed = 1900,type = "DelayLine",width = 70})
			HP_E = HPSkillshot({delay = 1,range = 925,speed = 1500,type = "DelayCircle",width = 235})
			HP_R = HPSkillshot({delay = 0.25,range = 1075,speed = 1950,type = "DelayLine",width = 100})
		else
			Print("Update HPrediction to use it.")
		end
	else
		Print("HPrediction not installed, cannot use it")
	end
end
function dPredOn()
	if FileExist(LIB_PATH.."DivinePred.luac") and FileExist(LIB_PATH.."DivinePred.lua") then
		require "DivinePred"
		DP = DivinePred()
		if DP.VERSION < 1.1 then
			DelayAction(function()		
				Print("Redownload Divine Prediction to use it. Need minimum version 1.1")
			end, 1.2)
		else
			dpEnabled = true
		end
		--DivinePred.debugMode = true
	else
		Print("Divine Prediction not installed, cannot use it")
	end
end

--
function CheckOrbwalk()
	 if _G.Reborn_Loaded and not _G.Reborn_Initialised then
        DelayAction(CheckOrbwalk, 1)
    elseif _G.Reborn_Initialised then
        sacused = true
		VarusMenu.Orbwalking:addParam("info11","SAC Detected", SCRIPT_PARAM_INFO, "")
    elseif _G.MMA_Loaded then
		VarusMenu.Orbwalking:addParam("info11","MMA Detected", SCRIPT_PARAM_INFO, "")
		mmaused = true
	else
		require "SxOrbWalk"
		SxOrb:LoadToMenu(VarusMenu.Orbwalking, false) 
		sxorbused = true
		SxOrb:RegisterAfterAttackCallback(MyAfterAttack)
		DelayAction(function()		
			if SxOrb.Version < 2.44 then
				Print("Your SxOrbWalk library is outdated, please get the latest version!")
			end
		end, 5)
	end
end
DelayAction(CheckOrbwalk, 4)

local sEnemies = GetEnemyHeroes()
local sAllies = GetAllyHeroes()
local lasttime={}
local lastTime = 0
local lastpos={}
local switch = nil 
local myAnimTime = 0
local BaseWindUpTime = 3
local LastAA = 0
local wTargets = {}

function OnLoad()
	local ToUpdate = {}
	ToUpdate.Version = 0.7
	DelayAction(function()
		ToUpdate.UseHttps = true
		ToUpdate.Host = "raw.githubusercontent.com"
		ToUpdate.VersionPath = "/RalphLeague/BoL/master/Varus.version"
		ToUpdate.ScriptPath =  "/RalphLeague/BoL/master/Varus.lua"
		ToUpdate.SavePath = SCRIPT_PATH.._ENV.FILE_NAME
		ToUpdate.CallbackUpdate = function(NewVersion,OldVersion) Print("Updated to v"..NewVersion) end
		ToUpdate.CallbackNoUpdate = function(OldVersion) Print("No Updates Found.") end
		ToUpdate.CallbackNewVersion = function(NewVersion) Print("New Version found ("..NewVersion.."). Please wait until its downloaded") end
		ToUpdate.CallbackError = function(NewVersion) Print("Error while Downloading. Please try again.") end
		SxScriptUpdate(ToUpdate.Version,ToUpdate.UseHttps, ToUpdate.Host, ToUpdate.VersionPath, ToUpdate.ScriptPath, ToUpdate.SavePath, ToUpdate.CallbackUpdate,ToUpdate.CallbackNoUpdate, ToUpdate.CallbackNewVersion,ToUpdate.CallbackError)
	end, 0.5)
	Print("Version "..ToUpdate.Version.." loaded.")
	--dPredOn()
	hPredOn()
	
	Variables()
	Menu()
	if VarusMenu.sett.autoBuy then
		--BuyStuff()
	end

	Debug = true
end

function Variables()
	SpellQ = {speed = 1900, range = 1625, delay = 0.25, width = 70, ready = false, last = 0, dmg = function() return (-40 + (GetSpellData(0).level*55) + (myHero.totalDamage*1.6))*1.05 end, dmgMin = function() return (-27 + (GetSpellData(0).level*37) + (myHero.totalDamage*1.54))*1.05 end}
	SpellW = {speed = 3300, range = 1500, delay = 0.601, width = 60, ready = false, last = 0, dmg = function() return (-40 + (GetSpellData(1).level*50) + (myHero.totalDamage*1.4))*1.08 end}
	SpellE = {speed = 1500, delay = 1, range = 925, width = 235, ready = false, last = 0, dmg = function() return (30 + (GetSpellData(2).level*35) + (myHero.totalDamage*0.6))*1.05 end}
	SpellR = {speed = 1950, delay = 0.25, range = 1075, width = 100, ready = false, last = 0, kill = 0, dmg = function() return (50 + (GetSpellData(3).level*10) + (myHero.ap))*1.05 end}
	
end

function OnTick()
	LastHitKey			= VarusMenu.keys.lastKey
	LaneclearKey        = VarusMenu.keys.laneKey
	ComboKey			= VarusMenu.keys.comboKey
	HarassKey			= VarusMenu.keys.harassKey
	Debug               = VarusMenu.sett.debug
	
	TickChecks() 
	local shouldnot = KS()
	
	if LaneclearKey then
		Farm(enemyMinions)
		Farm(jungleMinions)
	elseif ValidTarget(Target) then
		if VarusMenu.keys.forceUltKey then
			CastR(Target)
			moveToCursor()
		end
		local wStat = checkW(Target)
		if wStat > 0 and not shouldnot then 
			if HarassKey then
				Harass(Target, wStat)
			elseif ComboKey then
				Combo(Target, wStat)
			end
		end
	end
end
function KS()
	for i, currentEnemy in ipairs(sEnemies) do
		if ValidTarget(currentEnemy, SpellQ.range) then
			if VarusMenu.sett.ksq and SpellQ.ready and currentEnemy.health <= myHero:CalcDamage(currentEnemy, SpellQ.dmg()) - 5 then
				if not qStart then
					CastQ(currentEnemy)
				else
					Q2(currentEnemy, true)
					return true
				end
			elseif VarusMenu.sett.kse and SpellE.ready and currentEnemy.health <= myHero:CalcDamage(currentEnemy, SpellE.dmg()) -5 then
				CastE(currentEnemy)
			elseif VarusMenu.sett.ksr and SpellR.ready and currentEnemy.health <= myHero:CalcMagicDamage(currentEnemy, SpellR.dmg()) - 5 then
				CastR(currentEnemy)
			end
		end
	end
end

function checkW(unit)
	if not qStart and GetDistance(unit) < AARange + unit.boundingRadius + 15 then
		if myHero:GetSpellData(1).level > 0 then
			local currTime = GetGameTimer()
			for i, w in ipairs(wTargets) do
				if currTime > w.EndT  then
					table.remove(wTargets, i)
				elseif w.Name == unit.charName then
					return 2
				end
			end
			return 0
		else
			return 2
		end
	end
	return 1
end

function TickChecks()
	AARange = myHero.range + myHero.boundingRadius
	myMana = (myHero.mana/myHero.maxMana)*100
	SpellQ.ready = (myHero:CanUseSpell(0) == 0)
	SpellW.ready = (myHero:CanUseSpell(1) == 0)
	SpellE.ready = (myHero:CanUseSpell(2) == 0)
	SpellR.ready = (myHero:CanUseSpell(3) == 0)
	Target = GetCustomTarget()
	TargetSelectorMode()
end
function moveToCursor()
	local MouseMove = Vector(myHero) + (Vector(mousePos) - Vector(myHero)):normalized() * 500
	myHero:MoveTo(MouseMove.x, MouseMove.z)	
end
function Combo(target, ws)
	if SpellR.ready and VarusMenu.combo.R then
		CastRMec(target)
	end
	if ws == 1 then
		if (SpellQ.ready and myMana > VarusMenu.combo.qMana) or qStart then
			CastQ(target)
		elseif SpellE.ready and VarusMenu.combo.E and myMana > VarusMenu.combo.eMana then
			CastE(target)
		end
	else
		if SpellE.ready and VarusMenu.combo.E and myMana > VarusMenu.combo.eMana then
			CastE(target)
		elseif (SpellQ.ready and myMana > VarusMenu.combo.qMana) or qStart then
			CastQ(target)
		end
	end
end
function Harass(target)
	if (SpellQ.ready and myMana > VarusMenu.harass.qMana) or qStart then
		CastQ(target)
	elseif SpellE.ready and VarusMenu.harass.E and myMana > VarusMenu.harass.eMana then
		CastE(target)
	end	
end
function CastR(unit)
	if GetDistance(unit) > SpellR.range + 100 then return end
	
	local CastPosition, Hitchance = PredictionSuite(unit, SpellR.delay, SpellR.width, SpellR.range, SpellR.speed, myHero, false, HP_R)
	if CastPosition and Hitchance >= 2 then 
		if GetDistanceSqr(myHero.pos, CastPosition) < (SpellR.range - 5)*(SpellR.range - 5) then
			CastSpell(3, CastPosition.x, CastPosition.z)
			return true
		end	
	end
end

function CastQFast(unit)
	if not qStart then
		CastSpell(0, unit.x, unit.z)
		qStart = os.clock()
		return
	else
		local vec = D3DXVECTOR3(unit.x, unit.y, unit.z)
		CastSpell2(0, vec)
		qStart = nil
		SpellQ.last = os.clock()
		return
	end
end

function CastRMec(unit)
	if GetDistance(unit) > SpellR.range + 100 then return end
	
	local CastPosition, Hitchance = PredictionSuite(unit, SpellR.delay, SpellR.width, SpellR.range, SpellR.speed, myHero, false, HP_R)
	if CastPosition and Hitchance >= 2 then 
		if GetDistanceSqr(myHero.pos, CastPosition) < (SpellR.range - 5)*(SpellR.range - 5) then
			if CountEnemiesNearUnit(unit, 550) >= VarusMenu.combo.Rcount then
				CastSpell(3, CastPosition.x, CastPosition.z)
				return true
			end
		end	
	end
end

function CountEnemiesNearUnit(unit, range)
	local count = 0
	for i, currentEnemy in ipairs(sEnemies) do
		if ValidTarget(currentEnemy) then
			local pos = vPred:GetPredictedPos(currentEnemy, SpellR.delay)
			if GetDistanceSqr(pos, unit) <= range * range then count = count + 1 end
		end
	end
	return count
end
function Farm(farmTable)
	farmTable:update()
	if VarusMenu.farm.Q and (SpellQ.ready and myMana > VarusMenu.farm.qMana) or qStart then
		local BestPos, Count = GetBestLineFarmPosition(SpellQ.range, SpellQ.width, farmTable.objects)
		if BestPos and Count > 1 and GetDistance(BestPos) < SpellQ.range then
			--CastQ(BestPos)
			if not qStart then
				CastSpell(0, BestPos.x, BestPos.z)
				qStart = os.clock()
				return
			else
				local qTime = os.clock() - qStart > 1.42 and 1.42 or os.clock() - qStart
				if qTime == 1.42 then
					local vec = D3DXVECTOR3(BestPos.x, BestPos.y, BestPos.z)
					CastSpell2(0, vec)
					qStart = nil
					SpellQ.last = os.clock()
					return
				end
			end
		end
	end
	if SpellE.ready and VarusMenu.farm.E and myMana > VarusMenu.farm.eMana then
		local BestPos, Count = GetBestCircularFarmPosition(SpellE.range, SpellE.width/2, farmTable.objects)
		if BestPos and Count > 1 and GetDistance(BestPos) < SpellE.range then
			CastSpell(2, BestPos.x, BestPos.z)
			return
		end
	end
end	
function CountObjectsNearPos(pos, range, radius, objects)
    local n = 0
    for i, object in ipairs(objects) do
        if GetDistance(pos, object) <= radius then
            n = n + 1
        end
    end
    return n
end

function GetBestCircularFarmPosition(range, radius, objects)
    local BestPos 
    local BestHit = 0
    for i, object in ipairs(objects) do
        local hit = CountObjectsNearPos(object.pos or object, range, radius, objects)
        if hit > BestHit then
            BestHit = hit
            BestPos = Vector(object)
            if BestHit == #objects then
               break
            end
         end
    end
    return BestPos, BestHit
end

function CountObjectsOnLineSegment(StartPos, EndPos, width, objects)
    local n = 0
    for i, object in ipairs(objects) do
        local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(StartPos, EndPos, object)
        local pointSegment3D = {x=pointSegment.x, y=object.y, z=pointSegment.y}
		if isOnSegment and pointSegment3D and GetDistance(pointSegment3D, object) < object.boundingRadius + width then
            n = n + 1
        end
    end

    return n
end

function GetBestLineFarmPosition(range, width, objects)
    local BestPos 
    local BestHit = 0
    for i, object in ipairs(objects) do
        local EndPos = Vector(myHero.pos) + (Vector(object) - Vector(myHero.pos)):normalized() *range 
        local hit = CountObjectsOnLineSegment(myHero.pos, EndPos, width, objects)
        if hit > BestHit then
            BestHit = hit
            BestPos = Vector(object)
            if BestHit == #objects then
               break
            end
         end
    end

    return BestPos, BestHit
end	
function CastQ(unit)
	if not qStart and os.clock() - SpellE.last < 1 then return end
	
	if myHero:GetSpellData(1).level == 0 and GetDistance(unit) < myHero.range + unit.boundingRadius then
		CastQFast(unit)
		return
	end
	
	local d = GetDistance(unit)
	if not qStart and d < 2000 then
		CastSpell(0, unit.x, unit.z)
		qStart = os.clock()
		return
	end
	if qStart then
		Q2(unit)
	end
end
function Q2(unit, ks)
	qTime = os.clock() - qStart > 1.42 and 1.42 or os.clock() - qStart
	local qDistance = 925 + (((qTime)/1.42) * 700) -50
	local dashing, canHit, position = vPred:IsDashing(unit, SpellQ.delay, SpellQ.width, SpellQ.speed, myHero)
	if dashing and canHit and GetDistance(position) < qDistance then
		CastSpell(0, position.x, position.z)
		if Debug then print("Casting isdashing Q") end
		return
	end		
	
	local CastPosition, Hitchance = PredictionSuite(unit, SpellQ.delay, SpellQ.width, SpellQ.range + 100, SpellQ.speed, myHero, false, HP_Q)
	if CastPosition then
		local shoot = false
		
		if ks then
			if not vPred:CheckMinionCollision(unit, CastPosition, SpellQ.delay, SpellQ.width, GetDistance(CastPosition), SpellQ.speed, myHero, false, true) or qTime == 1.42 then
				local damag = (1+((qTime/1.42)/2))* myHero:CalcDamage(unit, SpellQ.dmgMin()) - 35
				if damag >= unit.health and GetDistance(unit) < qDistance-14 or qTime == 1.42 then
					shoot = true
				end
			end
		elseif (Hitchance >= 2 and GetDistance(CastPosition) < qDistance -10) or GetDistance(unit) < AARange then 
			if ComboKey and (GetDistance(unit) < AARange +unit.boundingRadius or qTime == 1.42) then
				shoot = true
			elseif HarassKey and qTime == 1.42 then
				shoot = true
			end
		end
		if shoot then
			local vec = D3DXVECTOR3(CastPosition.x, CastPosition.y, CastPosition.z)
			CastSpell2(0, vec)
			qStart = nil
			SpellQ.last = os.clock()
			return
		end
	end
end
function CastE(unit)
	if os.clock() - SpellQ.last < 1 then return end
	local dashingd, canhitd, positiond = vPred:IsDashing(unit, SpellE.delay, SpellE.width, SpellE.speed, myHero)
	if dashingd then
		if canhitd and GetDistance(positiond) < SpellE.range then
			CastSpell(2, positiond.x, positiond.z)
			if Debug then print("Casting isdashing E") end
		end
		return
	end		
	local CastPosition, Hitchance = vPred:GetCircularCastPosition(unit, SpellE.delay, SpellE.width, SpellE.range+ 50, SpellE.speed, myHero, false)
	if CastPosition and Hitchance >= 2 then 
		local dC = GetDistance(CastPosition)
		if dC > GetDistance(unit) then 
			castBestE(unit, CastPosition)
		else
			castBestE(unit, CastPosition, -50)
		end
	end
end
function castBestE(unit, pos, ad, management)
	if management then
		local castPos = Vector(pos) + (Vector(unit.pos) - Vector(pos)):normalized() * management
		CastSpell(2, castPos.x, castPos.z)
		SpellQ.last = os.clock()
		if Debug then print("antigapclose management adjust") end
		return true
	else
		local adjust = ad and ad or 0
		if not unit.isMoving then
			if GetDistance(myHero.pos, pos) < SpellE.range + adjust then
				CastSpell(2, pos.x, pos.z)
				SpellQ.last = os.clock()
				if Debug then print("not moving E") end
				return true
			end
		else
			local alternate = Vector(pos) + (Vector(unit.pos) - Vector(pos)):normalized() * (SpellE.width/2 - unit.boundingRadius/1.25)
			if GetDistance(alternate, myHero.pos) < SpellE.range + adjust then
				CastSpell(2, alternate.x, alternate.z)
				SpellQ.last = os.clock()
				if Debug then print("casting to best spot E") end
				return true
			elseif GetDistance(myHero.pos, pos) < SpellE.range + adjust then
				CastSpell(2, pos.x, pos.z)
				SpellQ.last = os.clock()
				return true
			end
		end
	end
end	

function BuyStuff()
	DelayAction(function()
		if GetInGameTimer() < 150 and not GetInventorySlotItem(1055) then
			BuyItem(3340)
			DelayAction(function()
				BuyItem(1055)
				DelayAction(function()
					BuyItem(2003)
				end, 0.6)
			end, 0.5)
			bought = true
		end
	end, 0.6)
end
function PredictionSuite(unit, delay, width, range, speed, from, collision, chosen)
	if VarusMenu.sett.pred == 3 and hpEnabled then
		local QPos, QHitChance = HPred:GetPredict(chosen, unit, myHero, false)
		return QPos, QHitChance + 1.85, QPos
	elseif VarusMenu.sett.pred == 2 and dpEnabled then
		local target = DPTarget(unit)
		local c = collision and 0 or math.huge
		local lineSS = LineSS(speed, range, width, delay*1000, c) 
		local state, hitPos, perc = DP:predict(target, lineSS)
		if state == SkillShot.STATUS.SUCCESS_HIT then
			CastSpell(1, hitPos.x, hitPos.z)
			if Debug then print("casting DP") end
			--if ks then SpellW.last = os.clock() end
			return hitPos, 2
		else
			return hitPos, 0
		end
	else
		local CastPosition, Hitchance, Position = vPred:GetLineCastPosition(unit, delay, width, range+ 150, speed, from, collision)
		return CastPosition, Hitchance
	end
end

function OnUpdateBuff(unit, buff, stacks)
	if not unit or not buff then return end

	if stacks == 3 and unit.type == myHero.type and buff.name:lower():find("varuswdebuff") then
		local insertion = {Name = unit.charName, EndT = buff.endTime, amount = 0}
		table.insert(wTargets, insertion)
	end
	if unit.isMe then
		if buff.name:lower():find("regenerationpotion") then
			potionOn = true
		end
	end
end


function OnRemoveBuff(unit, buff)
	if not unit or not buff then return end

	if unit.type == myHero.type then
		for i, TheBuff in ipairs(wTargets) do
			if TheBuff.Name == unit.charName then
				table.remove(wTargets, i)
				return
			end
		end
	end
end

function OnWndMsg(Msg, Key)
--print(Msg)
--print(Key)
	if Msg == WM_LBUTTONUP then
		if Debug then
		end
	end

	if Msg == WM_LBUTTONDOWN and VarusMenu.sett.sel then  --From Honda
		local minD = 0
		local starget = nil
		for i, enemy in ipairs(sEnemies) do
			if ValidTarget(enemy) then
				if GetDistance(enemy, mousePos) <= minD or starget == nil then
					minD = GetDistance(enemy, mousePos)
					starget = enemy
				end
			end
		end

		if starget and minD < 115 then
			if SelectedTarget and starget.charName == SelectedTarget.charName then
				SelectedTarget = nil
			else
				SelectedTarget = starget
				Print("New target selected, "..starget.charName)
			end
		end
	end
end

function OnDraw()
	if not AARange then return end
	if not myHero.dead then
		if not VarusMenu.sett.drawing.mDraw then	
			if VarusMenu.sett.drawing.aaDraw then 
				DrawCircleVarus(myHero.x, myHero.y, myHero.z, AARange, 4, ARGB(100, 57,255,20), 52)
			end
			if VarusMenu.sett.drawing.hitDraw then 
				DrawCircleVarus(myHero.x, myHero.y, myHero.z, myHero.boundingRadius, 4, ARGB(80, 0,255,100), 22)
			end
			
			if VarusMenu.sett.drawing.qDraw and SpellQ.ready then
				DrawCircleVarus(myHero.x, myHero.y, myHero.z, SpellQ.range, 4, ARGB(140, 150, 200, 255), 55)
			end
			
			if VarusMenu.sett.drawing.rDraw and SpellR.ready then
				DrawCircleVarus(myHero.x, myHero.y, myHero.z, SpellR.range, 4, ARGB(55, 255, 0, 77), 60)
			end
		
			if VarusMenu.sett.drawing.eDraw and SpellE.ready then
				DrawCircleVarus(myHero.x, myHero.y, myHero.z, SpellE.range, 2, ARGB(70, 233,133,253), 52)
			end
		end
		
		if VarusMenu.sett.drawing.Target then
			if Target then
				DrawCircleVarus(Target.x, Target.y, Target.z, Target.boundingRadius, 3, ARGB(211, 50, 20 , 255 ), 55)
			end
		end
		if ValidTarget(SelectedTarget) then
			DrawCircleVarus(SelectedTarget.x, SelectedTarget.y, SelectedTarget.z, SelectedTarget.boundingRadius/1.35, 2, ARGB(255, 255, 255, 0), 52)
		end
	end
end

function GetCustomTarget()
	if SelectedTarget ~= nil and ValidTarget(SelectedTarget, 1500) then
		return SelectedTarget
	elseif mmaused and _G.MMA_Target() then
		return _G.MMA_Target()
	elseif sacused and _G.AutoCarry and _G.AutoCarry.Crosshair.Attack_Crosshair.target and _G.AutoCarry.Crosshair.Attack_Crosshair.target.type == player.type and ValidTarget(_G.AutoCarry.Crosshair.Attack_Crosshair.target) then
		return _G.AutoCarry.Crosshair.Attack_Crosshair.target
	elseif sxorbused and SxOrb:GetTarget() then
		return SxOrb:GetTarget()
	end	

	TSAA:update()
	if TSAA.target and ValidTarget(TSAA.target) and TSAA.target.type == myHero.type then
		return TSAA.target
	end

	TargetSelector:update()	
	if TargetSelector.target and not TargetSelector.target.dead and TargetSelector.target.type == myHero.type then
		return TargetSelector.target
	else
		return nil
	end
end
function TargetSelectorMode()
	if VarusMenu.sett.Target == 1 then
		TargetSelector.mode = TARGET_LESS_CAST
	elseif VarusMenu.sett.Target == 2 then
		TargetSelector.mode = TARGET_NEAR_MOUSE
	elseif VarusMenu.sett.Target == 3 then
		TargetSelector.mode = TARGET_LESS_CAST_PRIORITY
	end
end

function DrawCircleNextVarus(x, y, z, radius, width, color, chordlength)
    radius = radius or 300
    quality = math.max(8,math.floor(180/math.deg((math.asin((chordlength/(2*radius)))))))
    quality = 2 * math.pi / quality
    radius = radius*.95
    local points = {}
    for theta = 0, 2 * math.pi + quality/2, quality do
        local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
        points[#points + 1] = D3DXVECTOR2(c.x, c.y)
    end
    DrawLines2(points, width, color or 4294967295)
end

function DrawCircleVarus(x, y, z, radius, width, color, chordlength)
    local vPos1 = Vector(x, y, z)
    local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
    local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
    local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
    if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y }) then
        DrawCircleNextVarus(x, y, z, radius, width, color, chordlength or 75)
    end
end

class "SxScriptUpdate"
function SxScriptUpdate:__init(LocalVersion,UseHttps, Host, VersionPath, ScriptPath, SavePath, CallbackUpdate, CallbackNoUpdate, CallbackNewVersion,CallbackError)
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

function SxScriptUpdate:print(str)
    print('<font color="#FFFFFF">'..os.clock()..': '..str)
end

function SxScriptUpdate:OnDraw()
    if self.DownloadStatus ~= 'Downloading Script (100%)' and self.DownloadStatus ~= 'Downloading VersionInfo (100%)'then
        DrawText('Download Status: '..(self.DownloadStatus or 'Unknown'),50,10,50,ARGB(0xFF,0xFF,0xFF,0xFF))
    end
end

function SxScriptUpdate:CreateSocket(url)
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

function SxScriptUpdate:Base64Encode(data)
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

function SxScriptUpdate:GetOnlineVersion()
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

function SxScriptUpdate:DownloadUpdate()
    if self.GotSxScriptUpdate then return end
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
        self.GotSxScriptUpdate = true
    end
end
assert(load(Base64Decode("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"), nil, "bt", _ENV))() ScriptStatus("XKNMKSPSSOJ") 