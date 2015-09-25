
local version = "1.00"

local enemyHeroes = {}
local enemyMins
local lasttform = 0
local lasttform2 = 0
local lasttform3 = 0
local timer = 0

local function d(p1, p2)
	p2 = p2 and p2 or myHero.pos
	return p1:DistanceTo(p2)
end
local function ValidTarget(object, distance, enemyTeam)
	return object and object.valid and not object.dead and object.visible
end
Callback.Bind('GameStart', function() 
    if myHero.charName ~= "Gnar" then return end
	
	--vPred = Initiate("VP")

	createTables()
	Variables()
	Menu()
	
	enemyMins = Minions().objects
	ScriptPrint("Version "..version.." Loaded")
	ScriptPrint("Warning: Script has no orbwalker. Use another orbwalker add-on combined with this.")
end)

Callback.Bind('Tick', function() 
	if not Gnar then return end
	
	--test()
	Target = GetTarget(1300)
	--Gnar.TS:GetTarget()
	--Game.Chat.Print(tostring(Target))
	checkPressed()
	tickChecks()
end)

Callback.Bind('Draw', function()
	if not Gnar then return end
	if Target then
		Diamond(Target.pos, Graphics.ARGB(255,255,165,0))
		--[[local CastPos = vPred:GetPredictedPos(Target, SpellR.mega.delay)
		if CastPos then
			Diamond(CastPos, Graphics.ARGB(255,255,255,255))
		end]]
	end
		
		
	if cool == 1 then
		local pos = to2d(myHero.pos)
		Graphics.DrawText(tostring(string.format("%.1f", ttimer, 1)), 30,  pos.x +95, pos.y + 11, Graphics.ARGB(255,255, 69, 0))
	end	
	drawRange()
	drawUlt()
	drawQCatch()
	--drawSmartHop()
end)
function cntdownDraw()
	if GnarBig then
		cool = 1
	end
	if cool == 1 then
		if myHero.mana == 0 then
			if os.clock() > lasttform3 + 40 and os.clock() < lasttform2 + 40 then
				timer = os.clock() + 0.8
				lasttform3 = os.clock()
			end
		elseif myHero.mana <= 10 then
			if os.clock() > lasttform2 + 40 and os.clock() < lasttform + 40 then
				timer = os.clock() + (myHero.mana/4.14)
				lasttform2 = os.clock()
			end
		elseif myHero.mana <= 50 then
			if os.clock() > lasttform + 40 then
				timer = os.clock() + (myHero.mana/5.85)
				lasttform = os.clock()
			end
		end
	end

	ttimer = timer - os.clock()
	if ttimer < 0 then 
		cool = 0
	end
end
function ScriptPrint(msg)
	Game.Chat.Print("<font color=\"#FF8C00\">Gnarly Gnar: </font><font color=\"#FFFFFF\">" .. msg)
end

function DebugPrint(msg)
	if Debug then
		Game.Chat.Print("<font color=\"#4c934c\">Debug: </font><font color=\"#FFFFFF\">" .. msg)
	end
end

function Menu()
Gnar = MenuConfig ("Gnarly  Gnar") 
	Core.OutputDebugString("2")	
	Gnar:Menu("Combo","Combo Settings")
		Gnar.Combo:Boolean("hopKite","Use Smart Hop - Kiting", true)
		Gnar.Combo:Boolean("hopAggro","Use Smart Hop - Aggressive", false)
		Gnar.Combo:Boolean("Emote","Emote when target dies", true)
	Gnar:Menu("Harass","Harass Settings")
		Gnar.Harass:Boolean("qMiniHarass","Use " .. SpellQ.mini.name .. " (Q) to Harass", true)
		Gnar.Harass:Boolean("qMegaHarass","Use " .. SpellQ.mega.name .. " (Q) to Harass", true)
		Gnar.Harass:Boolean("wMegaHarass","Use " .. SpellW.mega.name .. " (W) to Harass", true)
	Core.OutputDebugString("3")
	Gnar:Menu("Farm","Farm Settings")
	Gnar:Menu("General","General Settings")
		Gnar.General:Boolean("Debug","Debug", false)
	Gnar:Menu("Draws","Drawings")
		Gnar.Draws:Boolean("AA","Draw AA Range", false)
		Gnar.Draws:Boolean("Q","Draw Q Range", true)
		Gnar.Draws:Boolean("W","Draw W Range", false)
		Gnar.Draws:Boolean("E","Draw E Range", false)
		Gnar.Draws:Boolean("R","Draw R Range", true)
	Gnar:Menu("Binds","Key Bindings")
		Gnar.Binds:KeyBinding("Combo","Combo", "SPACE")
		Gnar.Binds:KeyBinding("Harass","Harass", "C")
		--Gnar.Binds:KeyBinding("HarassToggle","Harass Toggle", "O")
	--	Gnar.Binds.HarassToggle:Toggle(true)
		
		Gnar.Binds:KeyBinding("Hop","Hop", "E")
--	Gnar:TargetSelector('TS', 'TargetSelector', 'LESS_CAST', 1300)
	
	Gnar:Section('Ult', 'Wall Ultimate')
	--Gnar:Button('button', 'Click Here for Ult Info', PopUp) 
	Gnar:Slider('comboMinEnemies', 'Min Enemies Wall Ult Combo', 1, 1, 5, 1)
	Gnar:Slider('autoMinEnemies', 'Min Enemies Wall Ult Auto', 2, 1, 5, 1)
end

function Network.EnetPacket:EncodeStrP(text, len)
	self:EncodeStr(text)
	for i = #text, (len or #text) - 1 do
			self:Encode1(0)
	end
end
function Variables()
	LastR = 0
	--MyCondition = false
	newQRange = 1080
	GnarBig =  false
	SpellQ =
	{
		mini = { name = "Boomerang Throw",	range = 1100, delay = 0.25, speed = 1200, width =  60, ready = false, pos = nil, dmg = 0		 },
		mega = { name = "Boulder Toss",		range = 1085, delay = 0.9, speed = 1600, width =  90, ready = false, pos = nil, dmg = 0			 }
	}
	SpellW =
	{
		mega = { name = "Wallop",			range =  520, delay = .6001, speed =	4000, width =  78, ready = false, pos = nil, dmg = 0	 }
	}
	SpellE =
	{
		mini = { name = "Hop",				range =  475, delay = 0.1, speed = 1200, width = 150, ready = false, pos = nil, dmg = 0			 },
		mega = { name = "Crunch",			range =  475, delay = 0.6, speed = 2000, width = 350, ready = false, pos = nil, dmg = 0			 }
	}
	SpellR =
	{
		mega = { name = "GNAR!",			range =  425, delay = 0.31, speed = 1200, width = 210, ready = false, pos = nil, dmg = 0			 }
	}

	SH = { jumpEnd = nil, jumpStart	= nil, MoveTo = nil, enemySpot = nil }
	QHelper = {Start = nil, End = nil }
	Ult = { myPos = nil, enemyPos = nil, drawPush = nil, myWallCast = nil, drawPushEN = nil, enWallCast}
	
end

function tickChecks()
	--Target = Gnar:TargetSelector.TS:GetTarget(nil, nil, 1, 60, MyCondition)
	Debug = Gnar.General.Debug:Value()
	Aggro = Gnar.Combo.hopAggro:Value()
	Kiting = Gnar.Combo.hopKite:Value()
	--if Target and BasicCollision.GetMinionCollision(Target, myHero, 60) then
	--	print("there is")
	--end
	--ScriptPrint(tostring(Gnar.comboMinEnemies:Value()))
	if myHero.mana == 100 then
		GnarBig = true
	elseif myHero.mana == 0 then
		GnarBig = false
	end
	
	if GnarBig or not (Gnar.Binds.Combo:IsPressed() or Gnar.Binds.Harass:IsPressed()) then
		newQRange = 1080
	end
	if GnarBig and SpellR.mega.ready and Target then
		CastRAuto(Gnar.autoMinEnemies:Value(), 50, Target)
	end
	SpellQ.mini.ready = (myHero:CanUseSpell(0) == 0)
	SpellQ.mega.ready = SpellQ.mini.ready
	SpellW.mega.ready = (myHero:CanUseSpell(1) == 0)
	SpellE.mini.ready = (myHero:CanUseSpell(2) == 0)
	SpellE.mega.ready = SpellE.mini.ready
	SpellR.mega.ready = (myHero:CanUseSpell(3) == 0)
	
	cntdownDraw()
	Calcs()
end
function test()
	Game.Chat.Print("<font color=\"#FF8C00\">Gnarly Gnar: </font><font color=\"#FFFFFF\">&loz;</font>")
end
function checkPressed()
	if ValidTarget(Target) then
		--if  Gnar.Binds.HarassToggle:IsPressed() then
		--	Harass(Target)
		--end
		if Gnar.Binds.Combo:IsPressed() then 		
			Combo(Target)
		end 
		if Gnar.Binds.Harass:IsPressed() then 		
			Harass(Target)
		end 
		if Gnar.Binds.Hop:IsPressed() then
			UnitHop(Target)
		end
	end
end

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

function drawRange()
	if not myHero.dead then
		if Gnar.Draws.AA:Value() then	
			--Graphics.DrawCircle(myHero.pos.x, myHero.pos.y, myHero.pos.z, AARange, Graphics.ARGB(80, 32,178,100))
			DrawCirc(myHero, AARange, 2, Graphics.ARGB(80, 32,178,100), 222, true, true)
			Core.OutputDebugString("8.43") 
		end 
		Core.OutputDebugString("8.5")
		if Gnar.Draws.Q:Value() and SpellQ.mini.ready then
			Core.OutputDebugString("8.51")
			DrawCirc(myHero, newQRange + 45, 2, Graphics.ARGB(255, 255,165,0), 222, true, false)
			--Graphics.DrawCircle(myHero.pos.x, myHero.pos.y, myHero.pos.z, newQRange + 45, Graphics.ARGB(255, 172,51,22))
		end 
		Core.OutputDebugString("8.52")
		if Gnar.Draws.W:Value() and SpellW.mega.ready and GnarBig then
		Core.OutputDebugString("8.53")
			DrawCirc(myHero, SpellW.mega.range, 2, Graphics.ARGB(80, 32, 178, 170), 222, true, true)
			--Graphics.DrawCircle(myHero.pos.x, myHero.pos.y, myHero.pos.z, SpellW.mega.range, Graphics.ARGB(80, 32, 178, 170))
		end
		Core.OutputDebugString("8.54")
		if Gnar.Draws.E:Value() and SpellE.mega.ready then
			--Graphics.DrawCircle(myHero.pos.x, myHero.pos.y, myHero.pos.z, SpellE.mini.range, Graphics.ARGB(80, 111, 178, 170))
			DrawCirc(myHero, SpellE.mini.range, 2, Graphics.ARGB(80, 111, 178, 170), 222, true, true)
		end
		Core.OutputDebugString("8.55")
		if Gnar.Draws.R:Value() and SpellR.mega.ready and GnarBig then
			--Graphics.DrawCircle(myHero.pos.x, myHero.pos.y, myHero.pos.z, SpellR.mega.range, Graphics.ARGB(140, 22, 100, 244))
			DrawCirc(myHero, SpellR.mega.range, 2, Graphics.ARGB(140, 22, 100, 244), 222, true, true)
		end
		Core.OutputDebugString("8.56")
		--if mcDraw then
			Core.OutputDebugString("8.57")
			--Graphics.DrawCircle(mcDraw.pos.x, mcDraw.pos.y, mcDraw.pos.z, 90, Graphics.ARGB(250, 255,0,0))
			--DrawCirc(mcDraw, 45, 2, Graphics.ARGB(250, 255,0,0), 222, true, true)
		--end	
	end
end

function DrawCirc(position, radius, width, color, quality, lfc, onscreen) --prankStar
	position 	= position or myHero
	radius 		= radius
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

function drawUlt()
	if Ult.drawPush then
		Diamond(Ult.drawPush, Graphics.ARGB(255, 255, 0, 0))
	end
	if Ult.myWallCast then
		local aa1 = Graphics.WorldToScreen(Ult.myWallCast)
		local aa2 = Geometry.Vector2(aa1.x, aa1.y)
		Diamond(Ult.myWallCast, Graphics.ARGB(255, 0, 255, 0))
		if Ult.myPos and Ult.enemyPos and Ult.drawPush then
			local a1 = Graphics.WorldToScreen(Ult.enemyPos)
			local a2 = Geometry.Vector2(a1.x, a1.y)
			local b1 = Graphics.WorldToScreen(Ult.drawPush)
			local b2 = Geometry.Vector2(b1.x, b1.y)
			local c1 = Graphics.WorldToScreen(Ult.myPos)
			local c2 = Geometry.Vector2(c1.x, c1.y)
			Graphics.DrawLine(a2, b2, 2, Graphics.ARGB(100,240,0,0))
			Graphics.DrawLine(c2, aa2, 2, Graphics.ARGB(100,0,240,0))
		end
	end
	
	if Ult.drawPushEN then
		Diamond(Ult.drawPushEN, Graphics.ARGB(255, 255, 0, 0))
	end
	if Ult.enWallCast then
		local aa1 = Graphics.WorldToScreen(Ult.enWallCast)
		local aa2 = Geometry.Vector2(aa1.x, aa1.y)
		Diamond(Ult.enWallCast, Graphics.ARGB(255, 0, 255, 0))
		if Ult.myPos and Ult.enemyPos and Ult.drawPush then
			local a1 = Graphics.WorldToScreen(Ult.enemyPos)
			local a2 = Geometry.Vector2(a1.x, a1.y)
			local b1 = Graphics.WorldToScreen(Ult.drawPushEN)
			local b2 = Geometry.Vector2(b1.x, b1.y)
			local c1 = Graphics.WorldToScreen(Ult.myPos)
			local c2 = Geometry.Vector2(c1.x, c1.y)
			Graphics.DrawLine(a2, b2, 2, Graphics.ARGB(100,240,0,0))
			Graphics.DrawLine(c2, aa2, 2, Graphics.ARGB(100,0,240,0))
		end
	end
end
function drawQCatch()
	local color
	if QHelper.Start2 then
		local v3 = Geometry.Vector3( QHelper.Start2.pos.x, myHero.pos.y,  QHelper.Start2.pos.z)
		if myHero.pos:DistanceTo(v3) > 300 then
			--local pos = vPred:GetPredictedPos(myHero, 0.7) --need fixed
			local pos = prediction(myHero, 0.7, math.huge)
			local pEnd = v3 + (pos - v3):Normalize()*(1350 + myHero.pos:DistanceTo(v3))
			color = Rectangle(QHelper.Start2.pos, pEnd)
		end
	end
	if QHelper.End and QHelper.Start and QHelper.End.valid and QHelper.Start.valid then
		color = Rectangle(QHelper.Start.pos, QHelper.End.pos)
	end
		

	if RightE and RightS and LeftS and LeftE and color then
		local RightEnd1 = Geometry.Vector2(RightE.x, RightE.y)
		local LeftEnd1 = Geometry.Vector2(LeftE.x, LeftE.y)
		local RightStart1 = Geometry.Vector2(RightS.x, RightS.y)
		local LeftStart1 = Geometry.Vector2(LeftS.x, LeftS.y)
		Graphics.DrawLine(LeftStart1, RightStart1, 5, color)
		Graphics.DrawLine(LeftEnd1, RightEnd1, 5, color)
		Graphics.DrawLine(LeftStart1, LeftEnd1, 5, color)
		Graphics.DrawLine(RightStart1, RightEnd1, 5, color)
	end
end
function drawSmartHop()
	if SH.jumpEnd then
		Diamond(SH.jumpEnd, Graphics.ARGB(255,255,0,0))
	end
	if SH.jumpStart then
		Diamond(SH.jumpStart, Graphics.ARGB(255,0,255,0))
	end
	if SH.MoveTo then
		Diamond(SH.MoveTo, Graphics.ARGB(255,0,0,255))
	end
	if SH.enemySpot then
		Diamond(SH.enemySpot, Graphics.ARGB(255,128,0,0))
	end
end

function Calcs()
	AARange = myHero.range + myHero.boundingRadius
	--[[if GnarBig and myHero.mana ~= 100 then
		AARange = 250
	else
		AARange = 470 + 45 + (5 * myHero.level)
	end]]
	Core.OutputDebugString("9")
	SpellQ.mini.dmg, SpellQ.mega.dmg = (SpellQ.mini.ready and (10 + (35 * (myHero:GetSpellData(Game.Slots.SPELL_1).level - 1)) + myHero.totalDamage)) or 0, (SpellQ.mega.ready and (10 + (40 * (myHero:GetSpellData(Game.Slots.SPELL_1).level - 1)) + myHero.totalDamage * 1.2)) or 0
	SpellW.mega.dmg	= 	(SpellW.mega.ready and (25 + (20 * (myHero:GetSpellData(Game.Slots.SPELL_2).level - 1)) + myHero.totalDamage)) or 0		
end

function createTables()
	for i=1, Game.HeroCount() do		
		local hero = Game.Hero(i)
		if hero.team ~= myHero.team then
			table.insert(enemyHeroes, table.maxn(enemyHeroes)+1, hero)
		end
		Core.OutputDebugString("10")
	end
end

function checkQRange(unit, pos)
	--Game.Chat.Print("checkq")
	Core.OutputDebugString("11")
	if unit ~= nil then
		bool,mRange = closestMinion(unit, pos) 	
		if bool then
			newQRange = 117 * (mRange^0.337) - (20.7* (mRange^0.31)) + (70)
		end
		if newQRange > 1080 then
			newQRange = 1080
		end
		if GnarBig  then
			newQRange = 1080
		end
		--Game.Chat.Print(mRange)
		if mRange ~= nil then
			if mRange > 1080 then 
				newQRangee = 1080
			end
		else
			newQRange = 1080
		end
	end
	return newQRange
end
function closestMinion(unit, endpos)
	local collDist = 0
	minTable = Coll(endpos, 60)
	--Game.Chat.Print(tostring(#minTable.." closestminion"))
	--print(tostring(#minTable))
	if #minTable == 0 then
		return false
	else
		local closest = nil
	
		for i=1, #minTable do
			local minion = minTable[i]
			if closest == nil then
				closest = minTable[i]
			else
				if myHero.pos:DistanceTo(closest.pos) > myHero.pos:DistanceTo(minTable[i].pos) then
					closest = minTable[i]
				end
			end
		end
		if closest then
			mcDraw = closest
			local collDist = myHero.pos:DistanceTo(closest.pos)
			return true, collDist
		end
	end
end
function Coll(EndPos, width, startPos)
	startPos = startPos or myHero.pos
    local minTable = {}

	for index, object in pairs(enemyMins) do
		if object.valid and not object.dead and d(myHero.pos, object.pos) < 1200 then
			local pointSegment, isOnSegment = to2d(object.pos):ProjectOnLineSegment(to2d(startPos), to2d(EndPos))
			if isOnSegment then
				if d(pointSegment, to2d(object.pos)) < object.boundingRadius + width then
					table.insert(minTable, object)
				end
			end
			
		end
    end
    return minTable
end
function to2d(pos)
	local c1 = Graphics.WorldToScreen(pos)
	return Geometry.Vector2(c1.x, c1.y)
end
function Harass(unit)
	if ValidTarget(unit) then
		if GnarBig then 
			if Gnar.Harass.qMegaHarass:Value() then
				CastQ(unit)
			end
			if 	Gnar.Harass.wMegaHarass:Value() then
				CastW(unit)
			end
		elseif Gnar.Harass.qMiniHarass:Value() then
			CastQ(unit)
		end	
	end
end
function Combo(unit) --sbtw
	if unit ~= nil then
		if unit.dead and Gnar.Combo.Emote:Value() then
			if unit.charName == "Annie" or unit.charName == "Fizz" or unit.charName == "Garen" or unit.charName == "Nocturne" or unit.charName == "Rammus" then
				Game.Chat.Send("/taunt")
			else
				Game.Chat.Send("/l")
			end
		end
		
		if ValidTarget(unit) then 	
			if GnarBig and SpellR.mega.ready then
				CastR(Gnar.comboMinEnemies:Value(), 50, unit)
			end
				
			if GnarBig and SpellR.mega.ready then
			else
				if SpellW.mega.ready then
					CastW(unit)
				end
			end
			if Aggro or Kiting then
	
				if SpellE.mini.ready then
					if not GnarBig then
						if myHero.mana < 96 then
							local kitetarget = ClosestEnemy()
							smartHop(kitetarget)
						end	
					end
				end
			end
			if SpellE.mega.ready then
				CastE(unit)
			end
			
			if myHero.mana == 100 and myHero.pos:DistanceTo(unit.pos) > SpellE.mega.range + 55 then
			else
				if Ult.drawPush and SpellR.mega.ready then
				else
					CastQ(unit)
				end
			end	
			
			--[[if GnarMenu.combo.comboItems then
				if unit.health / unit.maxHealth <  GnarMenu.combo.ItemTar /	100 then
					if myHero.health / myHero.maxHealth <  GnarMenu.combo.ItemMe / 100 then
						UseItems(unit)
					end
				 end	
			end	]]
		end
	end
end

function CastRAuto(count, accuracy, unit)
	--if os.clock() <  LastR + 20 then
	--	return false
	--end

		--if not ValidTarget(unit, SpellR.mega.range + 150) then 
		--	return false
		--end

	if CountEnemiesNearUnit(myHero.pos, SpellR.mega.range) >= count then
		local jk = 0.301 + (-0.07 + Game.GetLatency() / 2000)
		local position = prediction(unit, jk, math.huge, false)
		
		if  myHero.pos:DistanceTo(position) <= SpellR.mega.range - 6  then
			local myWall = NearestWall(myHero.x, myHero.y, myHero.z, 985, accuracy)
			local pushLocation = myWall+(myWall-myHero.pos):Normalize()*40
			local enWall = NearestWall(position.x, position.y, position.z, 525, accuracy)			
			local pushLocationEN = enWall+(enWall-myHero.pos):Normalize()*40
			if pushLocation ~= nil and pushLocationEN ~=nil then
				if CountEnemiesNearUnit(pushLocation, 560) >= 2 then
					DebugPrint("RAuto distance me to enemy: "..math.floor(myHero.pos:DistanceTo(position)))
					if Game.IsWall(Geometry.Vector3(pushLocation.x, pushLocation.y, pushLocation.y)) then
						if pushLocation:DistanceTo(pushLocationEN) < 305 then 
							Ult.drawPush = pushLocation
							Ult.myWallCast = myHero.pos + (pushLocation - position):Normalize()*myHero:DistanceTo(pushLocation)
							Ult.drawPushEN = nil
							if Debug then
								Ult.enWallCast = nil
								Ult.myPos = Geometry.Vector3(myHero.x, myHero.y, myHero.z)
								Ult.enemyPos = Geometry.Vector3(position.x, position.y, position.z)
								DebugPrint("Casting RAuto, push/pushEN<305 enemydistancetowall: "..math.floor(myWall:DistanceTo(position)))
								DebugPrint("My distance from wall: "..math.floor(myHero.pos:DistanceTo(myWall)))
							end
								myHero:CastSpell(3, Ult.myWallCast.x, Ult.myWallCast.z)
								return true
						elseif pushLocation:DistanceTo(position) < 560 then
							Ult.myWallCast = myHero.pos + (pushLocation - position):Normalize()*myHero:DistanceTo(pushLocation)
							Ult.drawPush = pushLocation
							Ult.drawPushEN = nil
							if Debug then
								Ult.enWallCast = nil							
								Ult.myPos = Geometry.Vector3(myHero.x, myHero.y, myHero.z)
								Ult.enemyPos = Geometry.Vector3(position.x, position.y, position.z)
								DebugPrint("Casting RAuto, push<560 enemydistancetowall: "..math.floor(myWall:DistanceTo(position)))
								DebugPrint("My distance from wall: "..math.floor(myHero.pos:DistanceTo(myWall)))
							end
							myHero:CastSpell(3, Ult.myWallCast.x, Ult.myWallCast.z)
							return true
						end
					elseif Game.IsWall(Geometry.Vector3(pushLocationEN.x, pushLocationEN.y, pushLocationEN.y)) then
						if pushLocationEN:DistanceTo(position) < 560 then					
							Ult.drawPushEN = pushLocationEN
							Ult.enWallCast = myHero.pos + (pushLocationEN - position):Normalize()*myHero:DistanceTo(pushLocationEN)
							Ult.drawPush = nil
							if Debug then
								Ult.myWallCast = nil
								Ult.myPos = Geometry.Vector3(myHero.x, myHero.y, myHero.z)
								Ult.enemyPos = Geometry.Vector3(position.x, position.y, position.z)
								DebugPrint("Casting RAuto, pushEN<560 enemydistancetowall: "..math.floor(enWall:DistanceTo(position)))
								DebugPrint("My distance from wall: "..math.floor(myHero.pos:DistanceTo(enWall)))
							end
							myHero:CastSpell(3, Ult.enWallCast.x, Ult.enWallCast.z)
							return true
						end
					else
						DebugPrint("Not a wall")
					end
				end
			end
		end
	end	
end

function CastR(count, accuracy, unit)
	--if os.clock() <  LastR + 20 then
	--	return false
	--end
	unit = unit or nil
	if not unit then
		return false
	end
	
		--if not ValidTarget(unit, SpellR.mega.range + 150) or 
		----	return false
		--end
	
	if CountEnemiesNearUnit(myHero.pos, SpellR.mega.range) >= count then
		--local position = vPred:GetPredictedPos(unit, SpellR.mega.delay)
		local position = prediction(unit, SpellR.mega.delay, math.huge, false)
		if  myHero.pos:DistanceTo(position) <= SpellR.mega.range - 6  then
			local myWall = NearestWall(myHero.x, myHero.y, myHero.z, 985, accuracy)
			local pushLocation = myWall+(myWall-myHero.pos):Normalize()*40
			local enWall = NearestWall(position.x, position.y, position.z, 525, accuracy)			
			local pushLocationEN = enWall+(enWall-myHero.pos):Normalize()*40
			if pushLocation ~= nil and pushLocationEN ~=nil then
				DebugPrint("distance me to enemy: "..math.floor(myHero.pos:DistanceTo(position)))
				if Game.IsWall(Geometry.Vector3(pushLocation.x, pushLocation.y, pushLocation.y)) then
					if pushLocation:DistanceTo(pushLocationEN) < 305 then 
						Ult.drawPush = pushLocation
						Ult.myWallCast = myHero.pos + (pushLocation - position):Normalize()*myHero:DistanceTo(pushLocation)
						Ult.drawPushEN = nil
						if Debug then
							Ult.enWallCast = nil
							Ult.myPos = Geometry.Vector3(myHero.x, myHero.y, myHero.z)
							Ult.enemyPos = Geometry.Vector3(position.x, position.y, position.z)
							DebugPrint("My Wall (pushLocation, pushLocationEN) < 305 enemydistancetowall: "..math.floor(myWall:DistanceTo(position)))
							DebugPrint("My distance from wall: "..math.floor(myHero.pos:DistanceTo(myWall)))
						end
							myHero:CastSpell(3, Ult.myWallCast.x, Ult.myWallCast.z)
							return true
					elseif pushLocation:DistanceTo(position) < 560 then
						Ult.myWallCast = myHero.pos + (pushLocation - position):Normalize()*myHero:DistanceTo(pushLocation)
						Ult.drawPush = pushLocation
						Ult.drawPushEN = nil
						if Debug then
							Ult.enWallCast = nil							
							Ult.myPos = Geometry.Vector3(myHero.x, myHero.y, myHero.z)
							Ult.enemyPos = Geometry.Vector3(position.x, position.y, position.z)
							DebugPrint("My Wall (pushLocation, unit) < 560 enemydistancetowall: "..math.floor(myWall:DistanceTo(position)))
							DebugPrint("My distance from wall: "..math.floor(myHero.pos:DistanceTo(myWall)))
						end
						myHero:CastSpell(3, Ult.myWallCast.x, Ult.myWallCast.z)
						return true
					end
				elseif Game.IsWall(Geometry.Vector3(pushLocationEN.x, pushLocationEN.y, pushLocationEN.y)) then
					if pushLocationEN:DistanceTo(position) < 560 then					
						Ult.drawPushEN = pushLocationEN
						Ult.enWallCast = myHero.pos + (pushLocationEN - position):Normalize()*myHero:DistanceTo(pushLocationEN)
						Ult.drawPush = nil
						if Debug then
							Ult.myWallCast = nil
							Ult.myPos = Geometry.Vector3(myHero.x, myHero.y, myHero.z)
							Ult.enemyPos = Geometry.Vector3(position.x, position.y, position.z)
							DebugPrint("Enemy Wall(pushLocationEN, unit) < 560 enemydistancetowall: "..math.floor(enWall:DistanceTo(position)))
							DebugPrint("My distance from wall: "..math.floor(myHero.pos:DistanceTo(enWall)))
						end
						myHero:CastSpell(3, Ult.enWallCast.x, Ult.enWallCast.z)
						return true
					end
				else
					DebugPrint("Not a wall")
				end
			end
		end
	end	
end

function NearestWall(_x, _y, _z, _radius, accuracy)
	local vec =  Geometry.Vector3(_x, _y, _z)
	
	accuracy = accuracy or 50
	_radius = _radius and math.floor(_radius / accuracy) or math.huge
	
	_x, _z = math.round(_x / accuracy) * accuracy, math.round(_z / accuracy) * accuracy

	local radius = 2
	
	local function checkP(x, y) 
		vec.x, vec.z = _x + x * accuracy, _z + y * accuracy 

		return Game.IsWall(vec) 
	end
	
	while radius <= _radius do
		if checkP(0, radius) or checkP(radius, 0) or checkP(0, -radius) or checkP(-radius, 0) then
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

			if checkP(x, y) or checkP(-x, y) or checkP(x, -y) or checkP(-x, -y) or checkP(y, x) or checkP(-y, x) or checkP(y, -x) or checkP(-y, -x) then 
				return vec 
			end
		end
		radius = radius + 1
	end
end
function CountEnemiesNearUnit(unitpos, range)
	local count = 0
	for _, enemy in ipairs(enemyHeroes) do
		if not enemy.dead and enemy.visible then
			--local pos = vPred:GetPredictedPos(enemy, SpellR.mega.delay, SpellR.mega.speed)
			local pos = prediction(enemy, SpellR.mega.delay, SpellR.mega.speed)
			if  unitpos:DistanceTo(pos) < range  then 
				count = count + 1 
			end
		end
	end
	return count
end

function UnitHop(unit)
	if not unit then return end
	myHero:Move(mousePos.x, mousePos.z)
	if not GnarBig and SpellE.mini.ready and ValidTarget(unit) and myHero.pos:DistanceTo(unit.pos) < SpellE.mini.range + 250 then	
		if mousePos:DistanceTo(unit.pos) < mousePos:DistanceTo(myHero.pos) then
			--local pos = vPred:GetPredictedPos(unit, 0.02, 2000)
			local Position = prediction(unit, 0.02, 2000)
			if myHero.pos:DistanceTo(Position) < SpellE.mini.range then
				SH.jumpEnd = Position + (mousePos - myHero.pos):Normalize()*115
				SH.jumpStart = myHero.pos
				myHero:CastSpell(2, SH.jumpEnd.x, SH.jumpEnd.z)
				DebugPrint("Casting Unit Hop")
			end
		end
	end
end

function ClosestEnemy(obj)
	local unit = obj or myHero
    local closestEnemy = nil
    for _, enemy in ipairs(enemyHeroes) do
		if not enemy.dead and enemy.visible then
			if closestEnemy == nil or unit.pos:DistanceTo(enemy.pos) < unit.pos:DistanceTo(closestEnemy.pos) then
				closestEnemy = enemy
			end
		end
    end
	return closestEnemy
end

function moveToSpot(unit)
	local moveToPos = unit.pos + (mousePos - unit.pos):Normalize()*110
	SH.MoveTo = moveToPos
	myHero:Move(SH.MoveTo.x, SH.MoveTo.z)  
end

function smartHop(unit)
	--[[if (os.clock() < lastgc + 0.45 + (GetLatency()/1000)) or (os.clock() < lastpanth + 0.7 + (GetLatency()/1000)) then
		return false
	end
	for i = 1, #SmartHopExceptions do 
		local name =  SmartHopExceptions[i]
		if TargetHaveBuff(name, unit) then
			if Debug then
				print("Not casting Smart Hop")
			end
			return false
		end
	end]] 
	if not unit then return end
	local HtoU = myHero.pos:DistanceTo(unit.pos)
	local MtoU = mousePos:DistanceTo(unit.pos)
	local MtoH = mousePos:DistanceTo(myHero.pos)
	
	if HtoU < 205 + unit.boundingRadius then
		if Aggro and MtoU < MtoH and HtoU < 160 + unit.boundingRadius then
			--local Position = vPred:GetPredictedPos(unit, 0.02, 2000)
			local Position = prediction(unit, 0.02, 2000)
			SH.jumpEnd = Position + (mousePos - myHero.pos):Normalize()*115
			SH.jumpStart = myHero.pos
			myHero:CastSpell(2, SH.jumpEnd.x, SH.jumpEnd.z)
			DebugPrint("Casting Smart Hop Aggressive")
		elseif Kiting and MtoU > MtoH then
			if myHero.pos:DistanceTo(mousePos) < 400 then
				DebugPrint("False positive?")
				return false
			else
				if HtoU > 105 + unit.boundingRadius or HtoU  < 54 then
					--DebugPrint("Moving closer to target for Smart Hop")
					moveToSpot(unit)
				else
					--local Position = vPred:GetPredictedPos(unit, 0.02, 1200)
					local Position = prediction(unit, 0.02, 1200)
					if Triangle(unit.pos, mousePos) then
						
						if myHero.pos:DistanceTo(Position) > myHero.pos:DistanceTo(unit.pos) then
							DebugPrint("fleeing")
							return false
						end
						--local j = 140 + unit.boundingRadius - myHero.pos:DistanceTo(unit.pos)
						local y = 140 + unit.boundingRadius - myHero.pos:DistanceTo(Position)
					--	DebugPrint("j distance unit "..j)
						--DebugPrint("j distance Pos "..y)
						
						SH.jumpEnd = myHero.pos + (mousePos - myHero.pos):Normalize()*y
						SH.jumpStart = myHero.pos
						
						myHero:CastSpell(2, SH.jumpEnd.x, SH.jumpEnd.z)
						
						if Debug then
							SH.enemySpot = unit.pos
							DebugPrint("Casting Smart Hop Kiting  unitd  "..myHero.pos:DistanceTo(unit.pos))
						end
					else
						DebugPrint("Too much on side")
						moveToSpot(unit)
					end
				end
			end
		end
	end
end

function CastQMini(unit)
	--local CastPos1 = vPred:GetLineCastPosition(unit, SpellQ.mini.delay, SpellQ.mini.width, 1300, SpellQ.mini.speed, myHero, false)
	local CastPos1 = prediction(unit, SpellQ.mini.delay, SpellQ.mini.speed)
	if not CastPos1 then return end
	local qcastrange = checkQRange(unit, CastPos1)
	---local qcastrange = 1000
	
	if d(CastPos1) <= qcastrange then
		--local CastPos, HitChance = vPred:GetLineCastPosition(unit, SpellQ.mini.delay, SpellQ.mini.width, SpellQ.mini.range, SpellQ.mini.speed, myHero)
		local CastPos, HitChance = prediction(unit, SpellQ.mini.delay, SpellQ.mini.speed)
		if CastPos and HitChance >= 2 and d(CastPos) <= qcastrange then
			myHero:CastSpell(0, CastPos.x, CastPos.z)
			return true
		end
	end
end
function CastQMega(unit)
	--if (GnarMenu.spells.megaQ.howTo == 1 and GetDistanceSqr(unit, myHero) > AARange * AARange and not SpellR.mega.ready) or (GnarMenu.spells.megaQ.howTo == 1 and GetDistanceSqr(unit, myHero) > 450 * 450 and SpellR.mega.ready) or GnarMenu.spells.megaQ.howTo == 2 then
	
		--local CastPos, HitChance = vPred:GetLineCastPosition(unit, SpellQ.mega.delay, SpellQ.mega.width, SpellQ.mega.range, SpellQ.mega.speed, myHero)
		local CastPos, HitChance = prediction(unit, SpellQ.mega.delay, SpellQ.mega.speed)
		if HitChance >= 2 then
			local CastPos2 = CastPos+(CastPos-myHero.pos):Normalize()*-(33 + unit.boundingRadius)
			if #Coll(CastPos2, 60) == 0 then
				myHero:CastSpell(0, CastPos.x, CastPos.z)
				return true
			end
		end
	--end
end

function CastQ(unit)
	if os.clock() < LastR + 0.27 then return false end
	if unit == nil or not SpellQ.mini.ready or not SpellQ.mega.ready or myHero.pos:DistanceTo(unit.pos) > 1300 then
		return false
	end
	
	if not GnarBig then
		if CastQMini(unit) then
			return
		end
	else
		if CastQMega(unit) then
			return
		end
	end
	
	--local position4 = vPred:GetPredictedPos(unit, 0.1)
	local position4 = prediction(unit, 0.1)
	if d(unit.pos) < d(position4) and d(unit.pos) < 900 then
		if not GnarBig then
			--local CastPos, HitChance, Position = vPred:GetLineCastPosition(unit, SpellQ.mini.delay, SpellQ.mini.width, 1110, SpellQ.mini.speed, myHero, true)
			local CastPos, HitChance = prediction(unit, SpellQ.mini.delay, SpellQ.mini.speed, true)
			if HitChance >= 1 then
				CastSpell(_Q, CastPos.x, CastPos.z)
				return true
			end
		else
		--	local CastPos, HitChance, Position = vPred:GetCircularCastPosition(unit, SpellQ.mega.delay, SpellQ.mega.width, 1110, SpellQ.mega.speed, myHero, true)
			local CastPos, HitChance = prediction(unit, SpellQ.mega.delay, SpellQ.mega.speed, true)
			if HitChance >= 1 then
				CastSpell(_Q, CastPos.x, CastPos.z)
				return true
			end	
		end
	end
end	

function CastW(unit)
	if os.clock() <  LastR + 0.8 then 
		return false 
	end
	if unit == nil or not SpellW.mega.ready or not GnarBig or (myHero.pos:DistanceTo(unit.pos) <  40) then
		return false
	end
	
	--local CastPos, HitChance = vPred:GetLineCastPosition(unit, SpellW.mega.delay, SpellW.mega.width, SpellW.mega.range, SpellW.mega.speed, myHero, false)
	local CastPos, HitChance = prediction(unit, SpellW.mega.delay, SpellW.mega.speed)
	if CastPos and CastPos.x and CastPos.y and CastPos.z and HitChance >= 1 then
		myHero:CastSpell(1, CastPos.x, CastPos.z)
	end
end

function CastE(unit)
	if os.clock() <  LastR + 0.9 then 
		return false
	end
	if unit == nil or not SpellE.mega.ready or not GnarBig or myHero.mana == 100 then
		return false
	end
	
	--local CastPos, HitChance, Position = vPred:GetCircularCastPosition(unit, SpellE.mega.delay, SpellE.mega.width, SpellE.mega.range, SpellE.mega.speed, myHero, false)
	local CastPos, HitChance = prediction(unit, SpellE.mega.delay, SpellE.mega.speed)
	if CastPos and CastPos.x and CastPos.y and CastPos.z and HitChance >= 1 then
		myHero:CastSpell(2, CastPos.x, CastPos.z)
	end
end

function CountMinionsQ(pos)
	local count = 0
	local ExtendedVector = Vector(myHero) + Vector(Vector(pos) - Vector(myHero)):normalized()*SpellQ.mini.range
	for i, minion in ipairs(enemyMinions.objects) do
		local MinionPointSegment, MinionPointLine, MinionIsOnSegment =  VectorPointProjectionOnLineSegment(Vector(myHero), Vector(ExtendedVector), Vector(minion)) 
		local MinionPointSegment3D = { x = MinionPointSegment.x, y = pos.y, z = MinionPointSegment.y }
		if MinionIsOnSegment and d(MinionPointSegment3D, pos) < SpellQ.mini.width then
			count = count + 1
		end
	end
	return count
end

function GetBestQPositionFarm()
	local MaxQ = 1
	local MaxQPos
	for i, minion in pairs(enemyMinions.objects) do
		local hitQ = CountMinionsQ(minion)
		if hitQ > MaxQ or MaxQPos == nil then
			MaxQPos = minion
			MaxQ = hitQ
		end
	end

	if MaxQPos then
		return MaxQPos
	else
		return nil
	end
end

function JungleClear()
	jungleMinions:update()
	if GnarMenu.farming.jungle.jungleKey then
		for index, minion in pairs(jungleMinions.objects) do
			if minion ~= nil then
				local distance = d(minion.pos, myHero.pos)
				if SpellP.enabled then
					if GnarMenu.farming.jungle.qmegaJungle and distance <= SpellQ.mega.range then
						CastSpell(_Q, minion.x, minion.z)
					end
					if GnarMenu.farming.jungle.wmegaJungle and distance <= SpellW.mega.range then
						CastSpell(_W, minion.x, minion.z)
					end
					if GnarMenu.farming.jungle.emegaJungle and distance <= SpellE.mega.range then
						CastSpell(_E, minion.x, minion.z)
					end
				else
					if GnarMenu.farming.jungle.qminiJungle and distance <= SpellQ.mini.range then
						CastSpell(_Q, minion.x, minion.z)
					end
				end
			end
		end
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

function Rectangle(startPos, endPos)
	local function Perpendicular(envy) return Geometry.Vector3(-envy.z, envy.y, envy.x) end
	local function Perpendicular2(envy) return Geometry.Vector3(envy.z, envy.y, -envy.x) end
	local realEndPos = startPos + (endPos - startPos):Normalize()*((startPos:DistanceTo(endPos)) + 50)
	local realStartPos = startPos + (startPos - endPos):Normalize()*100
	local direction = startPos-realEndPos
	local endLeftDir = realEndPos + Perpendicular2(direction)
	local endRightDir = realEndPos + Perpendicular(direction)
	local endLeft = realEndPos + (realEndPos-endLeftDir):Normalize()*105
	local endRight = realEndPos + (realEndPos-endRightDir):Normalize()*105 
	local direction2 = realEndPos-startPos
	local startLeftDir = realStartPos + Perpendicular2(direction2)
	local startRightDir = realStartPos + Perpendicular(direction2)
	local startLeft = realStartPos + (realStartPos-startLeftDir):Normalize()*105
	local startRight = realStartPos + (realStartPos-startRightDir):Normalize()*105
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
	
	local myWTS = Graphics.WorldToScreen(myHero.pos)
	local myPoint = Geometry.Point(myWTS.x, myWTS.y)
	spellPoly:DrawOutline(2, Graphics.ARGB(255, 255, 255, 255))
	if myPoint:IsInside(spellPoly) then
		local green  = Graphics.ARGB(100,0,240,0)
		return green
	else
		local red = Graphics.ARGB(100,240,0,0)
		return red
	end
end

function Triangle(startPos, endPos)
	local function Perpendicular(envy) return Geometry.Vector3(-envy.z, envy.y, envy.x) end
	local function Perpendicular2(envy) return Geometry.Vector3(envy.z, envy.y, -envy.x) end
	local realEndPos = startPos + (endPos - startPos):Normalize()*400
	local direction = startPos-realEndPos
	local endLeftDir = realEndPos + Perpendicular2(direction)
	local endRightDir = realEndPos + Perpendicular(direction)
	local endLeft = realEndPos + (realEndPos-endLeftDir):Normalize()*440
	local endRight = realEndPos + (realEndPos-endRightDir):Normalize()*440 

	local p1 = Graphics.WorldToScreen(Geometry.Vector3(endLeft.x, myHero.pos.y, endLeft.z))
	local p2 = Graphics.WorldToScreen(Geometry.Vector3(endRight.x, myHero.pos.y, endRight.z))
	local p3 = Graphics.WorldToScreen(Geometry.Vector3(startPos.x, myHero.pos.y, startPos.z))
	local spellPoly = Geometry.Polygon()
	
	spellPoly:Add(Geometry.Point(p3.x, p3.y))
	spellPoly:Add(Geometry.Point(p1.x, p1.y))
	spellPoly:Add(Geometry.Point(p2.x, p2.y))
	
	local myWTS = Graphics.WorldToScreen(myHero.pos)
	local myPoint = Geometry.Point(myWTS.x, myWTS.y)
	spellPoly:DrawOutline(2, Graphics.ARGB(255, 255, 255, 0))
	if myPoint:IsInside(spellPoly) then
		return true
	else
		return false
	end
end
Callback.Bind('CreateObj', function(obj) 
--if obj.name:lower():find("q_mis.troy") then ScriptPrint(obj.name) end
		--print(obj.name)
	if obj.name:find("Q_mis.troy") then
		local aa1 = Graphics.WorldToScreen(myHero.pos)
		local aa2 = Geometry.Vector2(aa1.x, aa1.y)
		local bb1 = Graphics.WorldToScreen(myHero.path.endPath)
		local bb2 = Geometry.Vector2(bb1.x, bb1.y)
		local cc1 = Graphics.WorldToScreen(obj.pos)
		local cc2 = Geometry.Vector2(cc1.x, cc1.y)
	
		--local a, b = aa2:Interception(bb2, myHero.ms, cc2, 1200)

		--Diamond(b, Graphics.ARGB(255,255,165,0))
	    if myHero.pos:DistanceTo(obj.pos) < 75 then
			QHelper.Start2 = obj
		else
			QHelper.Start2 = nil
			QHelper.Start = obj
		end
	elseif obj.name:find("Q_Target.troy") then
		QHelper.End = obj
	end
end)
Callback.Bind('DeleteObj', function(obj) 
	if obj.name:find("Q_Target.troy") then
		QHelper.End, QHelper.Start, QHelper.Start2 = nil, nil, nil
	end
end)
Callback.Bind('ProcessSpell', function(unit, spell) 
	if spell.name:find("GnarR")  then
		LastR = os.clock()
	end
end)	
function ValidTarget(object, distance, enemyTeam)
	if object and object.valid and not object.dead and object.visible then
		return true 
	end
end

function prediction(unit, delay, speed, coll)
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
				if coll and #Coll(v, 60) ~= 0 then
					hit = 0
				end
				return v, hit
			end
		end
		if coll and #Coll(unit.path.endPath, 60) ~= 0 then
			hit = 0
		end
		return unit.path.endPath, hit
	end
	if coll and #Coll(unit.path.endPath, 60) ~= 0 then
		hit = 0
	end
	return unit.path.endPath, hit
end

--[[Minion Manager]]--
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

print("Gnarly Gnar v"..version.." loaded")
