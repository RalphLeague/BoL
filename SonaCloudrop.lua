local version = "1.00"
local enemyHeroes = {}

Callback.Bind('GameStart', function() 
    if myHero.charName ~= "Sona" then return end
	createTables()
	Variables()
	Menu()
	--Game.SetMaxZoom(20000)

	ScriptPrint("Version "..version.." Loaded")
end)

Callback.Bind('Tick', function() 
	if Sona == nil then return end
	
	Target = GetTarget(1050)
	qTarget = GetTarget(850)
	if exhaust then
		eTarget = GetTarget(650)
	end
	
	checkPressed()
	tickChecks()
end)

Callback.Bind('Draw', function()
	if AARange == nil then return end
	
	if Sona.Draws.Rbox:Value() then
		drawUlt()
	end
	if Target then
		Diamond(Target.pos, Graphics.ARGB(255, 0, 0, 255))
	end
	drawRange()
end)

function ScriptPrint(msg)
	Game.Chat.Print("<font color=\"#0080ff\">Poke Machine Sona: </font><font color=\"#FFFFFF\">" .. msg)
end
function DebugPrint(msg)
	if Sona.Sett.Debug:Value() then	
		Game.Chat.Print("<font color=\"#4c934c\">Debug: </font><font color=\"#FFFFFF\">" .. msg)
	end
end

function Menu()
Sona = MenuConfig ("Sona") 
	Sona:Info("logo", "<img style=' width:300px;height:auto;' src='http://i.imgur.com/GL8EeAe.gif'>")
	Sona:Menu("Sett","Settings!")
		Sona.Sett:Section('General', 'General Settings')
		Sona.Sett:Boolean("Emote","Emote when target dies", true)
		Sona.Sett:Boolean("Debug","Debug", false)
		Sona.Sett:Section('Items', 'Item Settings')
		Sona.Sett:Boolean("Item","Use Frost Queen's Claim In Combo", true)
		Sona.Sett:Slider('ItemMe', 'Use item if my health % is < ', 70, 0, 100, 1)
		Sona.Sett:Slider('ItemTar', 'Use item if enemy health % % is < ', 70, 0, 100, 1)
		Sona.Sett:Section('Harass', 'Harass Settings')
		Sona.Sett:Slider('HarassMana', 'Do not use Q if mana % is < ', 30, 0, 100, 1)
	Sona:Menu("Draws","Drawings")
		Sona.Draws:Boolean("AA","Draw AA Range", true)
		Sona.Draws:Boolean("Q","Draw Q Range", true)
		Sona.Draws:Boolean("R","Draw R Range", false)
		Sona.Draws:Boolean("Rbox","Draw R Box", true)
	--Sona:TargetSelector('TS', "Target Selector", "PRIORITY", 1050, "Magic")
	
	Sona:Menu("Binds","Key Bindings")
		Sona.Binds:KeyBinding("Combo","Combo", "SPACE")
		Sona.Binds:KeyBinding("Panic","Panic Ult", "T")
		Sona.Binds:KeyBinding("Harass","Harass", "C")
		--Sona.Binds:KeyBinding("HarassToggle","Harass Toggle", "O")
	--	Sona.Binds.HarassToggle:Toggle(true)
		if exhaust then	
			Sona.Binds:KeyBinding("exh","Exhaust", exhaust.key)
		end
	Sona:Section('Ult', 'Ultimate Settings')
	Sona:Button('button', 'Click Here For Ult Info', PopUp) 
	Sona:Slider('comboMinEnemies', 'Min Combo Ult', 2, 1, 5, 1)
	Sona:Slider('autoMinEnemies', 'Min Auto Ult', 3, 1, 5, 1)
	
end
	
	--Sona.ultTS:Hide(true)
function GetTarget(range)
	local tH, hp = nil, 1000000
	for i = 0, Game.HeroCount() do
		local h = Game.Hero(i)
		if h and not h.isMe and h.team ~= myHero.team and h.visible and not h.dead and h.health > 0 and h.pos:DistanceTo(myHero.pos) < range * 0.95 and h.health < hp then
			tH = h
            hp = h.health
		end	
	end
	return tH
end

function PopUp()
	ScriptPrint("Panic Ult Key will ult the highest priority target in range. Great for flash ulting or getting an assassin that pops out.")
end

function Variables()
	
	SpellQ = { range = 845, delay = 0.02, speed = 1500, width =  nil, ready = false, pos = nil, dmg = 0 }
	SpellR = { range =  1000, delay = 0.1, speed = 2400, width = 140, ready = false, pos = nil, dmg = 0 }
	
	if myHero:GetSpellData(4).name:find("exhaust") then
		exhaust = { slot = 4, key = "D", range =  650, ready = false }
	elseif myHero:GetSpellData(5).name:find("exhaust") then
		exhaust = { slot = 5, key = "F", range =  650, ready = false }
	end
end

function tickChecks()
	AARange = myHero.range + myHero.boundingRadius
	emot(Target)
	SpellQ.ready = (myHero:CanUseSpell(0) == 0)
	SpellR.ready = (myHero:CanUseSpell(3) == 0)
	if exhaust ~= nil then
		if exhaust.slot ~= nil  then
			exhaust.ready = (myHero:CanUseSpell(exhaust.slot) == 0)
		end
	end
	if not Sona.Binds.Combo:IsPressed() then
		CastR(Target, Sona.autoMinEnemies:Value())
	end
end
function checkPressed()
	if Sona.Binds.Combo:IsPressed() then 		
		Combo(Target)
	elseif Sona.Binds.Harass:IsPressed() then
		Harass(qTarget)
	end
	if exhaust then
		if Sona.Binds.exh:IsPressed() then 		
			exhFunction(eTarget)
		end 
	end
	if Sona.Binds.Panic:IsPressed() then 		
		CastR(Target, 1)
	end 
end
function drawUlt()
	if not SpellR.ready then return false end
	if Target and RightE and RightS and LeftS and LeftE then
		local RightEnd1 = Geometry.Vector2(RightE.x, RightE.y)
		local LeftEnd1 = Geometry.Vector2(LeftE.x, LeftE.y)
		local RightStart1 = Geometry.Vector2(RightS.x, RightS.y)
		local LeftStart1 = Geometry.Vector2(LeftS.x, LeftS.y)
		Graphics.DrawLine(LeftStart1, RightStart1, 4, Graphics.ARGB(255, 255,255,0))
		Graphics.DrawLine(LeftEnd1, RightEnd1, 4, Graphics.ARGB(255, 255,255,0))
		Graphics.DrawLine(LeftStart1, LeftEnd1, 4, Graphics.ARGB(255, 255,255,0))
		Graphics.DrawLine(RightStart1, RightEnd1, 4, Graphics.ARGB(255, 255,255,0))
	end
end
function drawRange()
	if not myHero.dead then
		if Sona.Draws.AA:Value() then	
			Graphics.DrawCircle(myHero.pos.x, myHero.pos.y, myHero.pos.z, AARange, Graphics.ARGB(80, 32,178,100))
		end 
		if Sona.Draws.Q:Value() and SpellQ.ready then
			Graphics.DrawCircle(myHero.pos.x, myHero.pos.y, myHero.pos.z, SpellQ.range, Graphics.ARGB(255,0,128,255))
		end 
		if Sona.Draws.R:Value() and SpellR.ready  then
			Graphics.DrawCircle(myHero.pos.x, myHero.pos.y, myHero.pos.z, SpellR.range, Graphics.ARGB(255, 230,230,170))
		end
	end
	Core.OutputDebugString("8.51")
end
function exhFunction(unit)
	myHero:Move(mousePos.x, mousePos.z)
	if ValidTarget(unit) and exhaust.ready then
		DebugPrint(tostring(exhaust.slot).." Trying to exhaust "..tostring(unit.charName))
		myHero:CastSpell(exhaust.slot, unit)
	end
end
function emot(unit)
	do return end
	if unit ~= nil then
		if unit.dead and Sona.Sett.Emote:Value() then
			if unit.charName == "Annie" or unit.charName == "Fizz" or unit.charName == "Garen" or unit.charName == "Nocturne" or unit.charName == "Rammus" then
				Game.Chat.Send("/taunt")
			else
				Game.Chat.Send("/l")
			end
		end
	end
end
function Combo(unit) --sbtw
	Walk()
	if unit then
		Attack(unit)
		CastR(unit, Sona.comboMinEnemies:Value())		
		CastQ(qTarget)

	--[[	if Sona.Sett.Item:Value() then
			if CanUseItem(3092) and qTarget and not qTarget.dead and qTarget.visible then
				if qTarget.health / qTarget.maxHealth <  Sona.Sett.ItemTar:Value() / 100 then
					if myHero.health / myHero.maxHealth <  Sona.Sett.ItemMe:Value() / 100 then
						myHero:CastSpell(CanUseItem(3092), qTarget.pos.x, qTarget.pos.z)
					end
				end	
			end	
		end]]
	end
end

function Harass(unit)
	--Allclass.Orbwalk(unit)
	Walk()
	if unit then
		Attack(unit)
		if (myHero.mana/myHero.maxMana)*100  < Sona.Sett.HarassMana:Value() then
			return false
		end
		CastQ(unit)
	end
end

function createTables()
	for i=1, Game.HeroCount() do		
		local hero = Game.Hero(i)
		if hero.team ~= myHero.team then
			table.insert(enemyHeroes, table.maxn(enemyHeroes)+1, hero)
		end
	end
end

function CastQ(unit)
	if not ValidTarget(unit) or not SpellQ.ready or myHero.pos:DistanceTo(unit.pos) >= SpellQ.range - 3 then
		return false
	end	
	myHero:CastSpell(0)	
end	

function CastR(unit, count)
	count = tonumber(count)
	if not ValidTarget(unit) or not SpellR.ready or myHero.pos:DistanceTo(unit.pos) >= SpellR.range + 100 then
		return false
	end
	
	--local pos = prediction(unit, SpellR.delay, SpellR.speed)
	local pos = unit.pos

	if CountEnemiesInUlt(myHero.pos, pos) >= count then
		myHero:CastSpell(3, pos.x, pos.z)
		RightE = nil 
		RightS = nil
		LeftS = nil
		LeftE = nil 
		
	end
end	

function prediction(unit, delay, speed)
	assert(unit, "Prediction:Prediction -> unit can't be nil")
	if unit.hasMovePath then  
		local pathPot = (unit.ms*((myHero.pos:DistanceTo(unit.pos)/speed)+delay))*.99
		for i = unit.path.curPath, unit.path.count do
			local pStart = i == unit.path.curPath and unit.pos or unit.path:Path(i-1)
			local pEnd = unit.path:Path(i) 
			local iPathDist = pStart:DistanceTo(pEnd) 
			if pathPot > iPathDist then
				pathPot = pathPot-iPathDist
			else 
				local v = pStart + (pEnd - pStart):Normalize()* pathPot
				return v, 2
			end
		end
		return unit.path.endPath, 1
	end
	return unit.path.endPath, 2
end

function Diamond(spot, color)	
	local middle = Graphics.WorldToScreen(spot)
	local diamond = Geometry.Polygon()
	
	diamond:Add(Geometry.Point(middle.x + 7, middle.y))
	diamond:Add(Geometry.Point(middle.x, middle.y + 7))	
	diamond:Add(Geometry.Point(middle.x - 7, middle.y))
	diamond:Add(Geometry.Point(middle.x, middle.y - 7))
	
	diamond:DrawOutline(2, color)
end

function CountEnemiesInUlt(startPos, endPos)
	local count = 0
	for _, enemy in ipairs(enemyHeroes) do
		if not enemy.dead and enemy.visible then
			--local pos = prediction(enemy, SpellR.delay, SpellR.speed)
			local pos = enemy.pos
			if  Rectangle(startPos, endPos, pos)  then 
				count = count + 1 
			end
		end
	end
	DebugPrint("Count: "..tostring(count))
	return count
end
function Rectangle(startPos, endPos, unitpos)
	local function Perpendicular(envy) return Geometry.Vector3(-envy.z, envy.y, envy.x) end
	local function Perpendicular2(envy) return Geometry.Vector3(envy.z, envy.y, -envy.x) end
	local realEndPos = startPos + (endPos - startPos):Normalize()*SpellR.range
	local direction = startPos-realEndPos
	local endLeftDir = realEndPos + Perpendicular2(direction)
	local endRightDir = realEndPos + Perpendicular(direction)
	local endLeft = realEndPos + (realEndPos-endLeftDir):Normalize()*SpellR.width
	local endRight = realEndPos + (realEndPos-endRightDir):Normalize()*SpellR.width
	local direction2 = realEndPos-startPos
	local startLeftDir = startPos + Perpendicular2(direction2)
	local startRightDir = startPos + Perpendicular(direction2)
	local startLeft = startPos + (startPos-startLeftDir):Normalize()*SpellR.width
	local startRight = startPos + (startPos-startRightDir):Normalize()*SpellR.width
	local p1 = Graphics.WorldToScreen(Geometry.Vector3(endLeft.x, myHero.pos.y, endLeft.z))
	local p2 = Graphics.WorldToScreen(Geometry.Vector3(endRight.x, myHero.pos.y, endRight.z))
	local p3 = Graphics.WorldToScreen(Geometry.Vector3(startLeft.x, myHero.pos.y, startLeft.z))
	local p4 = Graphics.WorldToScreen(Geometry.Vector3(startRight.x, myHero.pos.y, startRight.z))
	local spellPoly = Geometry.Polygon()
	LeftS = p3
	LeftE = p2
	RightS = p4
	RightE = p1
	spellPoly:Add(Geometry.Point(p3.x, p3.y))
	spellPoly:Add(Geometry.Point(p4.x, p4.y))
	spellPoly:Add(Geometry.Point(p1.x, p1.y))
	spellPoly:Add(Geometry.Point(p2.x, p2.y))
	
	local myWTS = Graphics.WorldToScreen(unitpos)
	local myPoint = Geometry.Point(myWTS.x, myWTS.y)
	--spellPoly:DrawOutline(5, Graphics.ARGB(255, 255, 255, 0))
	if myPoint:IsInside(spellPoly) then
		return true
	else
		return false
	end
end

function CanUseItem(id) --PewPewPew
	for i=4, 10, 1 do
		local itemID = myHero:GetInventorySlot(i)
		if itemID == id and myHero:CanUseSpell(i) == 0 then
			return i
		end
	end
	return nil
end

function ValidTarget(object, distance, enemyTeam)
	if object and object.valid and not object.dead and object.visible then
		return true 
	end
end

local BaseWindUpTime = 3
local BaseAnimationTime = 0.65
local LastAA = 0
local GetLatency = Game.Latency
Callback.Bind('ProcessSpell', ProcessSpell)
function ProcessSpell(unit, spell) 
	if unit.isMe and spell.name:lower():find("attack")  then   --kOrbwalk
		BaseAnimationTime = 1 / (spell.animationTime * myHero.attackSpeed)
		BaseWindUpTime = 1 / (spell.windUpTime * myHero.attackSpeed)
	end
end
function Walk()
	if CanMove() then
		if d(mousePos, myHero.pos) < 2500 then
			myHero:Move(mousePos.x, mousePos.z)
		else
			MouseMove = myHero.pos + (mousePos - myHero.pos):Normalize() * 500
			myHero:Move(MouseMove.x, MouseMove.z)
		end
	end
end

function Attack(unit)
	if ValidTarget(unit, AARange) and CanAttack() then
		myHero:Attack(unit)
		LastAA = os.clock() + GetWindUpTime() + (GetLatency()/1000)
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
	return p1:DistanceTo(p2)
end