local ver = "1.0"

local function GetDistance(p1, p2)
	p2 = p2 and p2 or myHero.pos
	return p1:DistanceTo(p2)
end

local function ValidTarget(object, distance, enemyTeam) 
	local valid = object and object.valid and not object.dead and object.visible
	if valid and distance then 
		return GetDistance(object.pos) <= distance
	end
	return valid
end

local function Print(message) Game.Chat.Print("<font color=\"#0000e5\"><b>Ralphlol's Varus:</font> </b><font color=\"#FFFFFF\">".. message.."</font>") end

local sEnemies, wTargets = {}, {}

local function GetTarget(range)
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

local function Variables()
	SpellQ = {speed = 1900, range = 1625, delay = 0.25, width = 70, ready = false, last = 0, dmg = function() return (-40 + (myHero:GetSpellData(0).level*55) + (myHero.totalDamage*1.6))*1.05 end, dmgMin = function() return (-27 + (myHero:GetSpellData(0).level*37) + (myHero.totalDamage*1.54))*1.05 end}
	SpellW = {speed = 3300, range = 1500, delay = 0.601, width = 60, ready = false, last = 0, dmg = function() return (-40 + (myHero:GetSpellData(1).level*50) + (myHero.totalDamage*1.4))*1.08 end}
	SpellE = {speed = 1500, delay = 1, range = 925, width = 235, ready = false, last = 0, dmg = function() return (30 + (myHero:GetSpellData(2).level*35) + (myHero.totalDamage*0.6))*1.05 end}
	SpellR = {speed = 1950, delay = 0.25, range = 1075, width = 100, ready = false, last = 0, kill = 0, dmg = function() return (50 + (myHero:GetSpellData(3).level*10) + (myHero.ap))*1.05 end}
end

local function createTables()
	for i=1, Game.HeroCount() do		
		local hero = Game.Hero(i)
		if hero.team ~= myHero.team then
			table.insert(sEnemies, table.maxn(sEnemies)+1, hero)
		end
		Core.OutputDebugString("10")
	end
end

local function TickChecks()
	AARange = myHero.range + myHero.boundingRadius
	myMana = (myHero.mana/myHero.maxMana)*100
	SpellQ.ready = myHero:CanUseSpell(0) == 0
	SpellW.ready = myHero:CanUseSpell(1) == 0
	SpellE.ready = myHero:CanUseSpell(2) == 0
	SpellR.ready = myHero:CanUseSpell(3) == 0
	Target = GetTarget(1450)
end

local function Menu()
Varus = MenuConfig ("Ralphlol Varus") 

	Varus:Menu("combo","Combo Settings")
		Varus.combo:Slider('qMana', 'Use Q combo if  mana is above', 5, 0, 100, 0)
		Varus.combo:Slider('eMana', 'Use E combo if  mana is above', 30, 0, 100, 0)
		Varus.combo:Boolean("E","Use E in Combo", true)
		Varus.combo:Boolean("R","Use R in Combo", true)
		Varus.combo:Slider('Rcount', 'R min enemies to hit', 3, 1, 5, 0)
		
	Varus:Menu("harass","Harass Settings")
		Varus.harass:Slider('qMana', 'Use Q combo if  mana is above', 20, 0, 100, 0)
		Varus.harass:Slider('eMana', 'Use E combo if  mana is above', 75, 0, 100, 0)
		Varus.harass:Boolean("E","Use E in Combo", false)

	Varus:Menu("farm","Wave Clear Settings")
		Varus.farm:Slider('qMana', 'Use Q combo if  mana is above', 30, 0, 100, 0)
		Varus.farm:Slider('eMana', 'Use E combo if  mana is above', 70, 0, 100, 0)
		Varus.farm:Boolean("Q","Use Q in Wave Clear", true)
		Varus.farm:Boolean("E","Use E in Wave Clear", true)
		
	Varus:Menu("sett","General Settings")
		Varus.sett:Boolean("Debug","Debug", false)
		Varus.sett:Boolean("ksq","KS with Q", true)
		Varus.sett:Boolean("kse","KS with E", true)
		Varus.sett:Boolean("ksr","KS with R", false)
			
	Varus:Menu("Draws","Drawings")
		Varus.Draws:Boolean("mDraw","Disable All Range Draws", false)
		Varus.Draws:Boolean("Target","Draw Diamond on Target", true)
		Varus.Draws:Boolean("AA","Draw AA Range", false)
		Varus.Draws:Boolean("Q","Draw Q Range", true)
		Varus.Draws:Boolean("E","Draw E Range", false)
		Varus.Draws:Boolean("R","Draw R Range", true)
		
	Varus:Menu("Binds","Key Bindings")
		Varus.Binds:KeyBinding("Combo","Combo", "SPACE")
		Varus.Binds:KeyBinding("Harass","Harass", "C")
		Varus.Binds:KeyBinding("Lane","Wave Clear Key", "V")
		Varus.Binds:KeyBinding("forceUltKey","Force Ult", "T")
end

local function Combo(target, ws)
	if SpellR.ready and Varus.combo.R:Value() then
		CastRMec(target)
	end
	if ws == 1 then
		if (SpellQ.ready and myMana > Varus.combo.qMana:Value()) or qStart then
			CastQ(target)
		elseif SpellE.ready and Varus.combo.E:Value() and myMana > Varus.combo.eMana:Value() then
			CastE(target)
		end
	else
		if SpellE.ready and Varus.combo.E:Value() and myMana > Varus.combo.eMana:Value() then
			CastE(target)
		elseif (SpellQ.ready and myMana > Varus.combo.qMana:Value()) or qStart then
			CastQ(target)
		end
	end
end

local function Harass(target)
	if (SpellQ.ready and myMana > Varus.harass.qMana:Value()) or qStart then
		CastQ(target)
	elseif SpellE.ready and Varus.harass.E:Value() and myMana > Varus.harass.eMana:Value() then
		CastE(target)
	end	
end

function KS()
	for i, currentEnemy in ipairs(sEnemies) do
		if ValidTarget(currentEnemy, SpellQ.range) then
			if Varus.sett.ksq:Value() and SpellQ.ready and currentEnemy.health <= myHero:CalcDamage(currentEnemy, SpellQ.dmg()) - 5 then
				if not qStart then
					CastQ(currentEnemy)
				else
					Q2(currentEnemy, true)
					return true
				end
			elseif Varus.sett.kse:Value() and SpellE.ready and currentEnemy.health <= myHero:CalcDamage(currentEnemy, SpellE.dmg()) -5 then
				CastE(currentEnemy)
			elseif Varus.sett.ksr:Value() and SpellR.ready and currentEnemy.health <= myHero:CalcMagicDamage(currentEnemy, SpellR.dmg()) - 5 then
				CastR(currentEnemy)
			end
		end
	end
end

function checkW(unit)
	if not qStart and GetDistance(unit) < AARange + unit.boundingRadius + 15 then
		if myHero:GetSpellData(1).level > 0 then
			local currTime = Game.Timer()
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

local function moveToCursor()
	local moveToPos = myHero.pos + (mousePos - myHero.pos):Normalize()*500
	myHero:Move(moveToPos.x, moveToPos.z)  
end

local function prediction(unit, delay, speed, width, coll)
	local hit = 2
	speed = speed or math.huge
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
				if coll and #Coll(v, width) ~= 0 then
					hit = 0
				end
				return v, hit
			end
		end
		if coll and #Coll(unit.path.endPath, width) ~= 0 then
			hit = 0
		end
		return unit.path.endPath, hit
	end
	if coll and #Coll(unit.path.endPath, width) ~= 0 then
		hit = 0
	end
	return unit.path.endPath, hit
end

function CastR(unit)
	if GetDistance(unit) > SpellR.range + 100 then return end
	
	local CastPosition, Hitchance = prediction(unit, SpellR.delay, SpellR.speed, SpellR.width, false)
	if CastPosition and Hitchance >= 2 then 
		if GetDistance(myHero.pos, CastPosition) < (SpellR.range - 5) then
			myHero:CastSpell(3, CastPosition.x, CastPosition.z)
			return true
		end	
	end
end

function CastQFast(unit)
	if not qStart then
		myHero:CastSpell(0, unit.x, unit.z)
		qStart = os.clock()
		return
	else
		local vec = to3d(unit.pos)
		myHero:CastSpell2(0, vec)
		qStart = nil
		SpellQ.last = os.clock()
		return
	end
end

function CastRMec(unit)
	if GetDistance(unit) > SpellR.range + 100 then return end
	
	local CastPosition, Hitchance = prediction(unit, SpellR.delay, SpellR.speed, SpellR.width, false)
	if CastPosition and Hitchance >= 2 then 
		if GetDistance(myHero.pos, CastPosition) < (SpellR.range - 5) then
			if CountEnemiesNearUnit(unit, 550) >= Varus.combo.Rcount:Value() then
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
			local pos = prediction(currentEnemy, SpellR.delay)
			if GetDistance(pos, unit.pos) <= range then count = count + 1 end
		end
	end
	return count
end

function CastE(unit)
	if os.clock() - SpellQ.last < 1 then return end

	local CastPosition, Hitchance = prediction(unit, SpellE.delay, SpellE.speed, SpellE.width, false)
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
	local adjust = ad and ad or 0
	if not unit.hasMovePath then
		if GetDistance(myHero.pos, pos) < SpellE.range + adjust then
			myHero:CastSpell(2, pos.x, pos.z)
			SpellE.last = os.clock()
			if Debug then print("not moving E") end
			return true
		end
	else
		local alternate = pos + (unit.pos - pos):Normalize()*(SpellE.width/2 - unit.boundingRadius/1.25)
		if GetDistance(alternate, myHero.pos) < SpellE.range + adjust then
			myHero:CastSpell(2, alternate.x, alternate.z)
			SpellE.last = os.clock()
			if Debug then print("casting to best spot E") end
			return true
		elseif GetDistance(myHero.pos, pos) < SpellE.range + adjust then
			myHero:CastSpell(2, pos.x, pos.z)
			SpellE.last = os.clock()
			return true
		end
	end
end	

function CastQ(unit)
	if not qStart and os.clock() - SpellE.last < 1 then return end
	
	if myHero:GetSpellData(1).level == 0 and GetDistance(unit) < myHero.range + unit.boundingRadius then
		CastQFast(unit)
		return
	end
	
	local d = GetDistance(unit)
	if not qStart and d < 2000 then
		myHero:CastSpell(0, unit.x, unit.z)
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
	
	local CastPosition, Hitchance = prediction(unit, SpellQ.delay, SpellQ.speed, SpellQ.width, false)
	if CastPosition and GetDistance(CastPosition) < SpellQ.range + 100 then
		local shoot = false
		
		if ks then
			if #Coll(CastPosition, SpellQ.width) == 0 or qTime == 1.42 then
				local damag = (1+((qTime/1.42)/2))* myHero:CalcDamage(unit, SpellQ.dmgMin()) - 35
				if damag >= unit.health and GetDistance(CastPosition) < qDistance-15 or qTime == 1.42 then
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
			--DrawQ = CastPosition
			local vec = to3d(CastPosition)
			myHero:CastSpell2(0, vec)
			qStart = nil
			SpellQ.last = os.clock()
			return
		end
	end
end

function Coll(EndPos, width, startPos)
	startPos = startPos or myHero.pos
    local minTable = {}

	for index, object in pairs(enemyMins.objects) do
		if object.valid and not object.dead and GetDistance(myHero.pos, object.pos) < 1200 then
			--local pointSegment, isOnSegment = VectorPointProjectionOnLineSegment(StartPos, EndPos, object)
			local pointSegment, isOnSegment = to2d(object.pos):ProjectOnLineSegment(to2d(startPos), to2d(EndPos))
			if isOnSegment and GetDistance(pointSegment, to2d(object.pos)) < object.boundingRadius + width then
				table.insert(minTable, object)
			end
			
		end
    end
    return minTable
end
function to2d(pos)
	local c1 = Graphics.WorldToScreen(pos)
	return Geometry.Vector2(c1.x, c1.y)
end
function to3d(c1)
	--local c1 = Graphics.WorldToScreen(pos)
	return Geometry.Vector3(c1.x, c1.y, c1.z)
end
Callback.Bind('GameStart', function() 
    if myHero.charName ~= "Varus" then return end
	Print("Version "..ver.." loaded.")

	createTables()
	Variables()
	Menu()
	
	enemyMins = Minions()
	print("Ralphlol's Varus v"..ver.." Loaded")
end)

Callback.Bind('Tick', function() 
	if not Varus then return end

	LaneclearKey        = Varus.Binds.Lane:IsPressed()
	ComboKey			= Varus.Binds.Combo:IsPressed()
	HarassKey			= Varus.Binds.Harass:IsPressed()
	Debug               = Varus.sett.Debug:Value()
	
	TickChecks() 
	local shouldnot = KS()

	if LaneclearKey then
		Farm(enemyMins)
		--Farm(jungleMinions)
	elseif ValidTarget(Target) then
		if Varus.Binds.forceUltKey:IsPressed() then
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
end)

Callback.Bind('Draw', function()
	if not Varus then return end
	if Target then
		Diamond(Target.pos, Graphics.ARGB(255,255,165,0))
		--[[local CastPos = vPred:GetPredictedPos(Target, SpellR.mega.delay)
		if CastPos then
			Diamond(CastPos, Graphics.ARGB(255,255,255,255))
		end]]
		if DrawQ then
			Diamond(DrawQ, Graphics.ARGB(255,0,255,0))
		end
	end
		
	drawRange()
end)

function drawRange()
	if not myHero.dead then
		if not Varus.Draws.mDraw:Value() then
			if Varus.Draws.AA:Value() then	
				DrawCirc(myHero, AARange, 2, Graphics.ARGB(80, 32,178,100), 222, true, true)
			end 
			if Varus.Draws.Q:Value() and SpellQ.ready then
				DrawCirc(myHero, SpellQ.range + 45, 2, Graphics.ARGB(140, 150, 200, 255), 222, true, false)
			end 

			if Varus.Draws.E:Value() and SpellE.ready then
				DrawCirc(myHero, SpellE.range, 2, Graphics.ARGB(70, 233,133,253), 222, true, true)
			end
			if Varus.Draws.R:Value() and SpellR.ready then
				DrawCirc(myHero, SpellR.range, 2, Graphics.ARGB(55, 255, 0, 77), 222, true, true)
			end
		end
	end
end

function DrawCirc(position, radius, width, color, quality, lfc, onscreen)
	position 	= position or myHero
	radius 		= radius or 200
	width 		= width or 1
	quality 	= quality or 24
	color 		= color or Graphics.ARGB(255,255,255,255)
	lfc 		= lfc
	onscreen 	= onscreen or false
 
	if lfc == true then
		local screenMin = Graphics.WorldToScreen(Geometry.Vector3(position.x - radius, position.y, position.z + radius))
		if onscreen and (screenMin.x >= 0 and screenMin.x <= WINDOW_W) and (screenMin.y >= 0 and screenMin.y <= WINDOW_H) or not onscreen then
			radius = radius*.92
			local quality = quality and 2 * math.pi / quality or 2 * math.pi / math.floor(radius / 10)
			local width = width and width or 1
			local a = Graphics.WorldToScreen(Geometry.Vector3(position.x + radius * math.cos(0), position.y, position.z - radius * math.sin(0)))
			for theta = quality, 2 * math.pi + quality * 0.5, quality do
				local b = Graphics.WorldToScreen(Geometry.Vector3(position.x + radius * math.cos(theta), position.y, position.z - radius * math.sin(theta)))
				Graphics.DrawLine(Geometry.Vector2(a.x, a.y), Geometry.Vector2(b.x, b.y), tonumber(width), color)
				a = b
			end
		end
	elseif lfc == false then
		local radius = radius or 300
		Graphics.DrawCircle(position, radius, color)
	end
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

Callback.Bind('UpdateBuff', function(unit, buff, stacks)
	--Print("buff "..buff.name)
	--Print("stacks "..stacks)
	--Print("unit "..unit.health)
	
	if not unit or not buff then return end

	if stacks == 3 and unit.type == myHero.type and buff.name:lower():find("varuswdebuff") then
		local insertion = {Name = unit.charName, EndT = buff.endTime, amount = 0}
		table.insert(wTargets, insertion)
	end
end)


Callback.Bind('RemoveBuff', function(unit, buff)
	if not unit or not buff then return end

	if unit.type == myHero.type then
		for i, TheBuff in ipairs(wTargets) do
			if TheBuff.Name == unit.charName then
				table.remove(wTargets, i)
				return
			end
		end
	end
end)


function Farm(farmTable)
	if Varus.farm.Q:Value() and (SpellQ.ready and myMana > Varus.farm.qMana:Value()) or qStart then
		local BestPos, Count = GetBestLineFarmPosition(SpellQ.range, SpellQ.width, farmTable.objects)
		if BestPos and Count > 1 and GetDistance(BestPos) < SpellQ.range then
			--CastQ(BestPos)
			if not qStart then
				myHero:CastSpell(0, BestPos.x, BestPos.z)
				qStart = os.clock()
				return
			else
				local qTime = os.clock() - qStart > 1.42 and 1.42 or os.clock() - qStart
				if qTime == 1.42 then
					local vec = to3d(BestPos)
					myHero:CastSpell2(0, vec)
					qStart = nil
					SpellQ.last = os.clock()
					return
				end
			end
		end
	end
	if SpellE.ready and Varus.farm.E:Value() and myMana > Varus.farm.eMana:Value() then
		local BestPos, Count = GetBestCircularFarmPosition(SpellE.range, SpellE.width, farmTable.objects)
		
		if BestPos and Count > 1 and GetDistance(BestPos) < SpellE.range then
			myHero:CastSpell(2, BestPos.x, BestPos.z)
			SpellE.last = os.clock()
			return
		end
	end
end	
function CountObjectsNearPos(pos, range, radius, objects)
    local n = 0
    for i, object in ipairs(objects) do
        if GetDistance(pos, object.pos) <= radius then
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
            BestPos = object.pos
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
		local pointSegment, isOnSegment = to2d(object.pos):ProjectOnLineSegment(to2d(StartPos), to2d(EndPos))
		if isOnSegment and GetDistance(pointSegment, to2d(object.pos)) < object.boundingRadius + width then
            n = n + 1
        end
    end

    return n
end

function GetBestLineFarmPosition(range, width, objects)
    local BestPos 
    local BestHit = 0
    for i, object in ipairs(objects) do
        local EndPos = myHero.pos + (object.pos - myHero.pos):Normalize() *range 
        local hit = CountObjectsOnLineSegment(myHero.pos, EndPos, width, objects)
        if hit > BestHit then
            BestHit = hit
            BestPos = object.pos
            if BestHit == #objects then
               break
            end
         end
    end

    return BestPos, BestHit
end	

class 'Minions'

function Minions:__init()
	self.objects = {}
	for i = 0, Game.ObjectCount() do
		if self:IsValid(Game.Object(i)) then
			table.insert(self.objects, Game.Object(i))
		end
	end
	Callback.Bind('Tick', 	   function()  self:OnTick()	   end)
	Callback.Bind('CreateObj', function(o) self:OnCreateObj(o) end)
	Callback.Bind('DeleteObj', function(o) self:OnDeleteObj(o) end)
	return self
end

function Minions:IsValid(o)
	return o and o.valid and not o.dead and o.type == 'obj_AI_Minion' and o.team ~= myHero.team and o.charName
end

function Minions:OnTick()
	for i, m in ipairs(self.objects) do
		if not self:IsValid(m) then
			table.remove(self.objects, i)
			i = i - 2
		end
	end
end

function Minions:OnCreateObj(o)
	if self:IsValid(o) then
		table.insert(self.objects, #self.objects+1, o)
	end
end

function Minions:OnDeleteObj(o)
	for i, m in ipairs(self.objects) do
		if m.networkID == o.networkID then
			table.remove(self.objects, i)
			return
		end
	end
end
--[[End Minion Manager]]--