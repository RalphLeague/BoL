if myHero.charName ~= "Sona" then return end
local version = "1.03"
local enemyHeroes = GetEnemyHeroes()

function OnLoad()
	Variables()
	Menu()
	
	ScriptPrint("Version "..version.." Loaded")
end

function OnTick()
	if Sona == nil then return end
	
	Target = GetTarget(1050)
	qTarget = GetTarget(850)
	if exhaust then
		eTarget = GetTarget(650)
	end
	
	checkPressed()
	tickChecks()
end

function OnDraw()
	if AARange == nil then return end
	
	if Sona.Draws.Rbox then
		drawUlt()
	end
	if Target then
		DrawCircle3D(Target.x, Target.y, Target.z, 20, 2, ARGB(255, 0, 0, 255))
	end
	drawRange()
end

function ScriptPrint(msg)
	print("<font color=\"#0080ff\">Poke Machine Sona: </font><font color=\"#FFFFFF\">" .. msg)
end
function DebugPrint(msg)
	if Sona.Sett.Debug then	
		print("<font color=\"#4c934c\">Debug: </font><font color=\"#FFFFFF\">" .. msg)
	end
end

function Menu()
Sona = scriptConfig("Poke Machine Sona", "SonaLOL")
	if Sona.button then Sona.button = false end
	
	Sona:addSubMenu("Settings!", "Sett")
		Sona.Sett:addParam("info22","General Settings", SCRIPT_PARAM_INFO, "")
		Sona.Sett:addParam("Debug", "Debug", SCRIPT_PARAM_ONOFF, false)
		Sona.Sett:addParam("info22","", SCRIPT_PARAM_INFO, "")
		Sona.Sett:addParam("info22", "Harass Settings", SCRIPT_PARAM_INFO, "")
		Sona.Sett:addParam("HarassMana", "Do not use Q if mana % is < ", SCRIPT_PARAM_SLICE, 30, 0, 100, 1)
		Sona.Sett:addParam("WMana", "Do not use W if mana % is < ", SCRIPT_PARAM_SLICE, 20, 0, 100, 1)
		Sona.Sett:addParam("WH", "Heal if attacked and health <", SCRIPT_PARAM_SLICE, 70, 0, 100, 1)
		Sona.Sett:addParam("fast", "Get to lane faster", SCRIPT_PARAM_ONOFF, true)
	
	Sona:addSubMenu("Drawings","Draws")
		Sona.Draws:addParam("AA", "Draw AA Range", SCRIPT_PARAM_ONOFF, true)	
		Sona.Draws:addParam("Q", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
		Sona.Draws:addParam("R", "Draw R Range", SCRIPT_PARAM_ONOFF, false)
		Sona.Draws:addParam("Rbox", "Draw R Range", SCRIPT_PARAM_ONOFF, true)

	Sona:addSubMenu("Key Bindings","Binds")
		Sona.Binds:addParam("Combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
		Sona.Binds:addParam("Panic", "Panic Ult", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("T"))
		Sona.Binds:addParam("Flee", "Flee Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("G"))
		Sona.Binds:addParam("Harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("C"))
		if exhaust then	
			Sona.Binds:addParam("exh", "Exhaust", SCRIPT_PARAM_ONKEYDOWN, false, exhaust.key)
		end
	
	Sona:addParam("info22","", SCRIPT_PARAM_INFO, "")	
	Sona:addParam("info22","Ultimate Settings", SCRIPT_PARAM_INFO, "")	
	Sona:addParam("button", "Click For Ult Info", SCRIPT_PARAM_ONOFF, false)
	Sona.button = false
	Sona:addParam("comboMinEnemies", "Min Combo Ult", SCRIPT_PARAM_SLICE, 2, 1, 5, 1)
	Sona:addParam("autoMinEnemies", "Min Auto Ult", SCRIPT_PARAM_SLICE, 3, 1, 5, 1)
end
	
function GetTarget(range)
	local tH, hp = nil, 1000000
	for index, h in pairs(enemyHeroes) do
		if h and not h.isMe and h.team ~= myHero.team and h.visible and not h.dead and h.health > 0 and d(h.pos, myHero.pos) < range * 0.95 and h.health < hp then
			tH = h
            hp = h.health
		end	
	end
	return tH
end

function PopUp()
	ScriptPrint("Panic Ult Key will ult the highest priority target in range. Great for flash ulting or getting an assassin that pops out.")
end

function OnNewPath(unit, startPos, endPos, isDash, dashSpeed, dashGravity, dashDistance)
	if unit.isMe and Sona.Sett.fast then
		DelayAction(function()
			if SpellEready and GetInGameTimer() < 1400 then
				if InFountain() and GetDistance(myHero.endPath) > 2000 then
					CastSpell(2)
				elseif GetGame().map.shortName == "summonerRift" and GetDistance(basePos[myHero.team]) < 2000 and GetDistance(myHero.endPath) > 4000 then
					CastSpell(2)
				end
			end
		end, 1)
	end
end
function Variables()
	SpellQ = { range = 845, delay = 0.02, speed = 1500, width =  nil, ready = false, pos = nil, dmg = 0 }
	SpellR = { range =  1000, delay = 0.1, speed = 2400, width = 140, ready = false, pos = nil, dmg = 0 }
	
	--[[if myHero:GetSpellData(4).name:find("exhaust") then
		exhaust = { slot = 4, key = GetKey("D"), range =  650, ready = false }
	elseif myHero:GetSpellData(5).name:find("exhaust") then
		exhaust = { slot = 5, key = GetKey("F"), range =  650, ready = false }
	end]]
end

function tickChecks()
	AARange = myHero.range + myHero.boundingRadius
	SpellQ.ready = (myHero:CanUseSpell(0) == 0)
	SpellWready  = (myHero:CanUseSpell(1) == 0)
	SpellEready  = (myHero:CanUseSpell(2) == 0)
	SpellR.ready = (myHero:CanUseSpell(3) == 0)
	
	if exhaust ~= nil then
		if exhaust.slot ~= nil  then
			exhaust.ready = (myHero:CanUseSpell(exhaust.slot) == 0)
		end
	end
	if not Sona.Binds.Combo then
		CastR(Target, Sona.autoMinEnemies)
	end
	if Sona.button then
		PopUp()
		Sona.button = false
	end
end
function checkPressed()
	if Sona.Binds.Combo then 		
		Combo(Target)
	elseif Sona.Binds.Harass then
		Harass(qTarget)
	end
	Flee()
	if exhaust then
		if Sona.Binds.exh then 		
			exhFunction(eTarget)
		end 
	end
	if Sona.Binds.Panic then 		
		CastR(Target, 1)
	end 
end
function drawUlt()
	if not SpellR.ready then return false end
	if Target and DrawRec then
		DrawRec()
		DrawRec = nil
	end
end

function drawRange()
	if not myHero.dead then
		if Sona.Draws.AA then	
			DrawCircle3D(myHero.pos.x, myHero.pos.y, myHero.pos.z, AARange, 2, ARGB(80, 32,178,100))
		end 
		if Sona.Draws.Q and SpellQ.ready then
			DrawCircle3D(myHero.pos.x, myHero.pos.y, myHero.pos.z, SpellQ.range, 2, ARGB(255,0,128,255))
		end 
		if Sona.Draws.R and SpellR.ready  then
			DrawCircle3D(myHero.pos.x, myHero.pos.y, myHero.pos.z, SpellR.range, 2, ARGB(255, 230,230,170))
		end
	end
end

function exhFunction(unit)
	myHero:MoveTo(mousePos.x, mousePos.z)
	if ValidTarget(unit) and exhaust.ready then
		DebugPrint(tostring(exhaust.slot).." Trying to exhaust "..tostring(unit.charName))
		CastSpell(exhaust.slot, unit)
	end
end

function Combo(unit) --sbtw
	Walk()
	if unit then
		Attack(GetTarget(AARange+65))
		CastR(unit, Sona.comboMinEnemies)		
		CastQ(qTarget)
	end
end

function Flee()
	if Sona.Binds.Flee then
		if SpellEready then
			CastSpell(2)
		end
		local slot = CheckItem("itemwraithcollar")
		if slot then
			CastSpell(slot)
		end	
	end
end
function CheckItem(ItemName)
	for i = 6, 12 do
		local item = myHero:GetSpellData(i).name
		if item and item:lower() == ItemName then
			if myHero:CanUseSpell(i) == 0 then
				return i
			end
		end
	end
end
function Harass(unit)
	Walk()
	if unit then
		Attack(GetTarget(AARange+65))
		if (myHero.mana/myHero.maxMana)*100  < tonumber(Sona.Sett.HarassMana) then
			return false
		end
		CastQ(unit)
	end
end

function CastQ(unit)
	if not ValidTarget(unit) or not SpellQ.ready or d(myHero.pos, unit.pos) >= SpellQ.range - 3 then
		return false
	end	
	CastSpell(0)	
end	

function CastR(unit, count)
	count = tonumber(count)
	if not ValidTarget(unit) or not SpellR.ready or d(myHero.pos, unit.pos) >= SpellR.range + 100 then
		return false
	end
	
	local pos = prediction(unit, SpellR.delay, SpellR.speed)
	if CountEnemiesInUlt(myHero.pos, pos) >= count then
		CastSpell(3, pos.x, pos.z)
	end
end	

function prediction(unit, delay, speed)
	assert(unit, "Prediction:Prediction -> unit can't be nil")
	if unit.hasMovePath then  
		local pathPot = (unit.ms*((GetDistance(unit.pos)/speed)+delay))*.99
		for i = unit.path.curPath, unit.path.count do
			local pStart = i == unit.path.curPath and unit.pos or unit.path:Path(i-1)
			local pEnd = unit.path:Path(i) 
			local iPathDist = d(pStart, pEnd)
			if pathPot > iPathDist then
				pathPot = pathPot-iPathDist
			else 
				local v = Vector(pStart) + (Vector(pEnd) - Vector(pStart)):normalized()* pathPot
				return v, 2
			end
		end
		return unit.path.endPath, 1
	end
	return unit.path.endPath, 2
end

function CountEnemiesInUlt(startPos, endPos)
	local count = 0
	for _, enemy in ipairs(enemyHeroes) do
		if not enemy.dead and enemy.visible then
			local pos = prediction(enemy, SpellR.delay, SpellR.speed)
			if  Rectangle(startPos, endPos, enemy.pos)  then 
				count = count + 1 
			end
		end
	end
	DebugPrint("Count: "..tostring(count))
	return count
end

function Rectangle(startPos, endPos, unitpos)
	local realEndPos = Vector(startPos) + (Vector(endPos) - Vector(startPos)):normalized()*SpellR.range
	local x2, y2 = realEndPos.x, realEndPos.z
	local x1, y1 = startPos.x, startPos.z
	local o = { x = -(y2 - y1), y = x2 - x1 }
	local len = math.sqrt((o.x * o.x) + (o.y * o.y))
	local p = (SpellR.width)*2
	o.x, o.y = o.x / len * p / 2, o.y / len * p / 2

	local p1 = D3DXVECTOR2(x1 + o.x, y1 + o.y)
	local p2 = D3DXVECTOR2(x1 - o.x, y1 - o.y)
	local p3 = D3DXVECTOR2(x2 - o.x, y2 - o.y)
	local p4 = D3DXVECTOR2(x2 + o.x, y2 + o.y)
	DrawRec = function() DrawLineBorder3D(startPos.x, startPos.y, startPos.z, realEndPos.x, realEndPos.y, realEndPos.z, SpellR.width*2, ARGB(255, 255, 255, 0), 4) end
	
	local points = {
		p1,
		p2,
		p3,
		p4
	}

	polygon = Polygon(Point(points[1].x, points[1].y), Point(points[2].x, points[2].y), Point(points[3].x, points[3].y), Point(points[4].x, points[4].y))
	return polygon:contains(Point(unitpos.x, unitpos.z))
end

function ValidTarget(object, distance, enemyTeam)
	if object and object.valid and not object.dead and object.visible then
		return true 
	end
end

local BaseWindUpTime = 3
local BaseAnimationTime = 0.65
local LastAA = 0

function OnAnimation(unit, action)
	if unit.isMe then 
		--print(action)
		if action:lower():find("attack") or  action:lower():find("crit") then
			LastAA = os.clock()
		end
	end
end

function OnProcessSpell(unit, spell) 
	if spell.name:lower():find("attack")  then   --kOrbwalk
		if unit.isMe then
			BaseAnimationTime = 1 / (spell.animationTime * myHero.attackSpeed)
			BaseWindUpTime = 1 / (spell.windUpTime * myHero.attackSpeed)
		end
	end
	if spell.target and spell.target == myHero and unit.team ~= myHero.team then
		if not SpellWready or (myHero.mana/myHero.maxMana)*100  < tonumber(Sona.Sett.WMana) or  (myHero.health/myHero.maxHealth)*100  > tonumber(Sona.Sett.WH)then
			return false
		end
		if Sona.Binds.Combo or Sona.Binds.Harass then
			if myHero.health/myHero.maxHealth < 0.8 and d(unit.pos, myHero.pos) < 850 then
				CastSpell(1)
			end
		end
	end
end
function Walk()
	if CanMove() then
		if d(mousePos, myHero.pos) < 2500 then
			myHero:MoveTo(mousePos.x, mousePos.z)
		else
			local MouseMove = Vector(myHero.x, myHero.y, myHero.z) + (Vector(mousePos.x, mousePos.y, mousePos.z) - Vector(myHero.x, myHero.y, myHero.z)):normalized() * 500
			myHero:MoveTo(MouseMove.x, MouseMove.z)
		end
	end
end

function Attack(unit)
	if ValidTarget(unit, AARange) and CanAttack() then
		myHero:Attack(unit)
		--LastAA = os.clock() + GetWindUpTime() + (GetLatency()/1000)
	end
end 
function CanMove()
	if os.clock() > ((LastAA or 0) + GetWindUpTime()) then
		return true
	else
		return false
	end
end

function CanAttack()
	if os.clock() > ((LastAA or 0) + GetAnimationTime() - (GetLatency()/1000)) then
		return true
	else
		return false
	end
end
function GetWindUpTime()
	local k = 1 / (myHero.attackSpeed * BaseWindUpTime)
	--print(k)
	return k
end

function GetAnimationTime()
	return 1 / (myHero.attackSpeed * BaseAnimationTime)
end
function d(p1, p2)
	return GetDistance(p1, p2)
end