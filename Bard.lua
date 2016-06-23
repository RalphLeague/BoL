local ver = 0.961

if myHero.charName ~= "Bard" then return end

require "VPrediction"
vPred = VPrediction()
function CheckOrbwalk()
	 if _G.Reborn_Loaded and not _G.Reborn_Initialised then
        DelayAction(CheckOrbwalk, 1)
    elseif _G.Reborn_Initialised then
        sacUsed = true
		BardMenu.Orbwalking:addParam("info11","SAC Detected", SCRIPT_PARAM_INFO, "")
    elseif _G.MMA_IsLoaded then
		BardMenu.Orbwalking:addParam("info11","MMA Detected", SCRIPT_PARAM_INFO, "")
		mmaUsed = true
	elseif _Pewalk then
		BardMenu.Orbwalking:addParam("info11","Pewalk Detected", SCRIPT_PARAM_INFO, "")
		pewUsed = true
	elseif _G.NebelwolfisOrbWalkerLoaded then
		BardMenu.Orbwalking:addParam("info11","Nebel Orb Detected", SCRIPT_PARAM_INFO, "")
		norbUsed = true
	else
		if FileExist(LIB_PATH.."Nebelwolfi's Orb Walker.lua") then
			require "Nebelwolfi's Orb Walker"
			if NebelwolfisOrbWalkerClass then
				NebelwolfisOrbWalkerClass(BardMenu.Orbwalking)
				norbUsed = true
			end
		else
			if FileExist(LIB_PATH.."SxOrbWalk.lua") or FileExist(LIB_PATH.."SxOrbwalk.lua") then
				require "SxOrbWalk"
				SxOrb:LoadToMenu(BardMenu.Orbwalking, false) 
				sxorbUsed = true
				DelayAction(function()		
					if SxOrb.Version < 3.1 then
						Print("Your SxOrbWalk library is outdated, please get the latest version!")
					end
				end, 5)
			else
				Print("Download SxOrbWalk or other orbwalker to use the script!")
				Print("Download SxOrbWalk or other orbwalker to use the script!")
				Print("Download SxOrbWalk or other orbwalker to use the script!")
				Print("Download SxOrbWalk or other orbwalker to use the script!")
			end
		end
	end
end

DelayAction(CheckOrbwalk, 4)
function Print(message) print("<font color=\"#FF0066\"><b>Ralphlol's Bard:</font> </b><font color=\"#FFFFFF\">" .. message) end

Print("Version "..ver.." loaded")

local sEnemies = GetEnemyHeroes()
local sAllies = GetAllyHeroes()
local lasttime={}
local lastTime = 0
local lastpos={}

local function IsOnScreen(spot)
	local check = WorldToScreen(D3DXVECTOR3(spot.x, spot.y, spot.z))
	local x, y = check.x, check.y
	if x > 0 and x < WINDOW_W and y > 0 and y < WINDOW_H then
		return true
	end
end

function OnLoad()
	local ToUpdate = {}
    ToUpdate.Version = ver
    ToUpdate.UseHttps = true
    ToUpdate.Host = "raw.githubusercontent.com"
    ToUpdate.VersionPath = "/RalphLeague/BoL/master/Bard.version"
    ToUpdate.ScriptPath =  "/RalphLeague/BoL/master/Bard.lua"
    ToUpdate.SavePath = SCRIPT_PATH.._ENV.FILE_NAME
    ToUpdate.CallbackUpdate = function(NewVersion,OldVersion) Print("Updated to v"..NewVersion) end
    ToUpdate.CallbackNoUpdate = function(OldVersion) Print("No Updates Found") end
    ToUpdate.CallbackNewVersion = function(NewVersion) Print("New Version found ("..NewVersion.."). Please wait until its downloaded") end
    ToUpdate.CallbackError = function(NewVersion) Print("Error while Downloading. Please try again.") end
    Bard_07(ToUpdate.Version,ToUpdate.UseHttps, ToUpdate.Host, ToUpdate.VersionPath, ToUpdate.ScriptPath, ToUpdate.SavePath, ToUpdate.CallbackUpdate,ToUpdate.CallbackNoUpdate, ToUpdate.CallbackNewVersion,ToUpdate.CallbackError)

	
	ItemNames				= {
		[3303]				= "ArchAngelsDummySpell",
		[3007]				= "ArchAngelsDummySpell",
		[3144]				= "BilgewaterCutlass",
		[3188]				= "ItemBlackfireTorch",
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
		[3042]				= "Muramana",
		[3043]				= "Muramana",
		[3180]				= "OdynsVeil",
		[3056]				= "ItemFaithShaker",
		[2047]				= "OracleExtractSight",
		[3364]				= "TrinketSweeperLvl3",
		[2052]				= "ItemPoroSnack",
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
		[3090]				= "ZhonyasHourglass",
		[3154]				= "wrigglelantern",
		[3142]				= "YoumusBlade",
		[3157]				= "ZhonyasHourglass",
		[3512]				= "ItemVoidGate",
		[3131]				= "ItemSoTD",
		[3137]				= "ItemDervishBlade",
		[3352]				= "RelicSpotter",
		[3350]				= "TrinketTotemLvl2",
	}

	___GetInventorySlotItem	= rawget(_G, "GetInventorySlotItem")
	_G.GetInventorySlotItem	= GetSlotItem

	for _,c in pairs(GetEnemyHeroes()) do
		lastpos[ c.networkID ] = Vector(c)
	end
	
	Variables()
	Menu()
end



function Variables()
	SpellQ = {speed = 1600, range = 900, delay = 0.25, width = 108, ready = false, dmg = function() return (35 + (GetSpellData(0).level*45) + (myHero.ap*0.65)) end}
	SpellW = {speed = 1100, range = 800, delay = 0.25, width = 100, ready = false}
	SpellE = {ready = false}
	SpellR = {speed = 1500, range = 3400, delay = 0.25, width = 350, ready = false}
	
	SpellStop = {"crowstorm","luxmalicecannon","absolutezero","alzaharnethergrasp","caitlynaceinthehole","drainchannel","galioidolofdurand","infiniteduress","katarinar","missfortunebullettime","pantheon_grandskyfall_jump","shenstandunited","urgotswap2","zhonyashourglass","velkozr","ezrealtrueshotbarrage"}
	Support = {"Alistar", "Blitzcrank", "Janna", "Karma", "Leona", "Lulu", "Nami", "Nunu", "Sona", "Soraka", "Taric", "Thresh", "Zilean", "Braum", "Bard"}
	if myHero:GetSpellData(4).name:lower():find("exhaust") then
		exhaust = { slot = 4, key = "D", range =  650, ready = false }
	elseif myHero:GetSpellData(5).name:lower():find("exhaust") then
		exhaust = { slot = 5, key = "F", range =  650, ready = false }
	end
	enemyMinions = minionManager(MINION_ENEMY, 1300, myHero)
end

function GetSlotItem(id, unit)
	unit = unit or myHero

	if (not ItemNames[id]) then
		return ___GetInventorySlotItem(id, unit)
	end

	local name	= ItemNames[id]
	
	for slot = ITEM_1, ITEM_7 do
		local item = unit:GetSpellData(slot).name
		if ((#item > 0) and (item:lower() == name:lower())) then
			return slot
		end
	end
end

function OnApplyBuff(source, unit, buff)
	if not buff or not source or not source.valid or not unit or not unit.valid then return end
	
	if unit.team == myHero.team and BardMenu.mik[unit.charName] then
		if (source.charName == "Rammus" and buff.type ~= 8) or source.charName == "Alistar" or source.charName:lower():find("baron") or source.charName:lower():find("spiderboss") or source.charName == "LeeSin" or (source.charName == "Hecarim" and not buff.name:lower():find("fleeslow")) then return end	
		if buff.name and ((not cleanse and buff.type == 24) or buff.type == 5 or buff.type == 11 or buff.type == 22 or buff.type == 21 or buff.type == 8)
		or (buff.type == 10 and buff.name and buff.name:lower():find("fleeslow")) then
			if (source.charName == "Rammus" and buff.type ~= 8) or source.charName == "Alistar" or source.charName:lower():find("baron") or source.charName == "XinZhao" or source.charName:lower():find("spiderboss") or source.charName == "LeeSin" or (source.charName == "Hecarim" and not buff.name:lower():find("fleeslow")) then return end
			if buff.name and buff.name:lower():find("caitlynyor") and CountEnemiesNearUnitReg(myHero, 700) == 0   then
				return false
			elseif not source.charName:lower():find("blitzcrank") then
				UseMikael(unit)
			end          
		end                    
	end  
end

function UseMikael(unit)
	if GetDistance(unit) < 750 + myHero.boundingRadius and BardMenu.mik.health > unit.health/unit.maxHealth then
		local item = GetSlotItem(3222, myHero)
		if item then
			CastSpell(item, unit)
		end
	end
end

function dPredOn()
	if FileExist(LIB_PATH.."DivinePred.luac") and FileExist(LIB_PATH.."DivinePred.lua") then
		require "DivinePred"
		DP = DivinePred()
		if DP.VERSION < 3.5 then
			DelayAction(function()
				--Print("Redownload Divine Prediction to use it. Need minimum version 1.8")
			end, 1.2)
		else
			dpEnabled = true
		end
		--DivinePred.debugMode = true
	else
		--Print("Divine Prediction not installed, cannot use it")
	end
end
function hPredOn()
	if FileExist(LIB_PATH.."HPrediction.lua") then
		require 'HPrediction'
		HPred = HPrediction()

		if _G.HPrediction_Version then
			hpEnabled = true
			HP_Q = HPSkillshot({delay = SpellQ.delay, range = SpellQ.range, speed = SpellQ.speed, type = "DelayLine", width = SpellQ.width})
		else
			Print("Update HPrediction to use it.")
		end
	else
		--Print("HPrediction not installed, cannot use it")
	end
end
function kPredOn()
	if FileExist(LIB_PATH.."KPrediction.lua") then
		require 'KPrediction'
		KPred = KPrediction()
		kpEnabled = true
		KP_Q = KPSkillshot({delay = SpellQ.delay, range = SpellQ.range, speed = SpellQ.speed, type = "DelayLine", width = SpellQ.width*2})
	end
end

function Menu()
BardMenu = scriptConfig("Bard Menu", "BardLOL")
	BardMenu:addSubMenu("Combo Settings", "combo")
		BardMenu.combo:addParam("qMana", "Use Q combo if  mana is above", SCRIPT_PARAM_SLICE, 5, 0, 101, 0) 
		BardMenu.combo:addParam("bush", "Ward bush when they hide", SCRIPT_PARAM_ONOFF, true)
		BardMenu.combo:addParam("info51","", SCRIPT_PARAM_INFO, "")
		BardMenu.combo:addParam("W", "Use W heal", SCRIPT_PARAM_ONOFF, true)
		BardMenu.combo:addParam("wMana", "Use W combo if  mana is above", SCRIPT_PARAM_SLICE, 25, 0, 101, 0) 
		BardMenu.combo:addParam("WSelf", "Heal self at life", SCRIPT_PARAM_SLICE, 40, 0, 90, 0) 
		BardMenu.combo:addParam("WOther", "Heal others at life", SCRIPT_PARAM_SLICE, 30, 0, 90, 0) 
	BardMenu:addSubMenu("Harass Settings", "harass") 
		BardMenu.harass:addParam("qMana", "Use Q harass if  mana is above", SCRIPT_PARAM_SLICE, 35, 0, 101, 0) 
	BardMenu:addSubMenu("Ultimate Settings", "ult") 
		BardMenu.ult:addParam("RCount", "Use R if # enemies near =", SCRIPT_PARAM_SLICE, 3, 1, 5, 0) 
		BardMenu.ult:addParam("RSelf", "Use R if your health <", SCRIPT_PARAM_SLICE, 75, 0, 101, 0)
		BardMenu.ult:addParam("ROther", "Use R if ally health <", SCRIPT_PARAM_SLICE, 65, 0, 101, 0)
	BardMenu:addSubMenu("Mikael's Settings", "mik") 
		BardMenu.mik:addParam("health", "Use if ally health below", SCRIPT_PARAM_SLICE, 75, 0, 101, 0)
		BardMenu.mik:addParam("","", SCRIPT_PARAM_INFO, "")
		BardMenu.mik:addParam("","          ---Whitelist---", SCRIPT_PARAM_INFO, "")
		for i, ally in ipairs(sAllies) do
			BardMenu.mik:addParam(ally.charName, "Use on "..ally.charName, SCRIPT_PARAM_ONOFF, true)
		end
	BardMenu:addSubMenu("General Settings", "sett")
		BardMenu.sett:addParam("qlast", "Q farm minions out of AA", SCRIPT_PARAM_ONOFF, true)
		BardMenu.sett:addParam("qclear", "Wave clear with Q", SCRIPT_PARAM_ONOFF, true)
		BardMenu.sett:addParam("afkH", "AFK Heal Spots", SCRIPT_PARAM_ONOFF, true)
		BardMenu.sett:addParam("sel", "Focus Selected Target", SCRIPT_PARAM_ONOFF, true) 
		BardMenu.sett:addParam("Target", "Target Mode:", SCRIPT_PARAM_LIST, 3, { "Less Cast", "Near Mouse", "Less Cast Priority" })
		BardMenu.sett:addParam("pred", "Predict Mode:", SCRIPT_PARAM_LIST, 1, { "VPrediction", "DPrediction", "HPrediction", "FHPrediction", "KPrediction"})
	
		local function fhPredOn()
			if FileExist(LIB_PATH.."FHPrediction.lua") then
				require("FHPrediction")
				if FHPrediction then
					fhQ = {range = SpellQ.range, speed = SpellQ.speed, delay = SpellQ.delay, radius = SpellQ.width}
					fhPredEnabled = true
					return true
				end
			end
		end
			
		local hpOn = false
		local dpOn = false
		local fhOn = false
		local kpOn = false
		
		if BardMenu.sett.pred == 4 then
			fhPredOn()
			fhOn = true
		elseif BardMenu.sett.pred == 3 then
			hPredOn()
			hpOn = true
		elseif BardMenu.sett.pred == 2 then
			dPredOn()
			if dpEnabled then
				lineSS = LineSS(SpellQ.speed, SpellQ.range, SpellQ.width, 250, math.huge)
				DP:bindSS("Q",lineSS,50)
			end
			dpOn = true
		elseif BardMenu.sett.pred == 5 then
			kPredOn()
			kpOn = true
		end
		
		local function predChange(set)
			if not hpOn and set == 3 then
				hpOn = true
				hPredOn()
			elseif not kpOn and set == 5 then
				kpOn = true
				kPredOn()
			elseif not dpOn and set == 2 then
				dPredOn()
				if dpEnabled then
					lineSS = LineSS(SpellQ.speed, SpellQ.range, SpellQ.width, 250, math.huge)
					DP:bindSS("Q",lineSS,50)
				end
				dpOn = true
			elseif not fhOn and set == 4 then
				fhPredOn()
				fhOn = true
			end
		end
		
		BardMenu.sett:setCallback("pred", predChange)
		BardMenu.sett:addSubMenu("   Draw Settings", "drawing") 
			BardMenu.sett.drawing:addParam("mDraw", "Disable All Range Draws", SCRIPT_PARAM_ONOFF, false) 
			BardMenu.sett.drawing:addParam("Target", "Draw Circle on Target", SCRIPT_PARAM_ONOFF, true)  
			BardMenu.sett.drawing:addParam("aaDraw", "Draw AA Range", SCRIPT_PARAM_ONOFF, false)
			BardMenu.sett.drawing:addParam("hitDraw", "Draw My Hitbox", SCRIPT_PARAM_ONOFF, true)
			BardMenu.sett.drawing:addParam("qDraw", "Draw (Q) Range", SCRIPT_PARAM_ONOFF, true)
			BardMenu.sett.drawing:addParam("qLine", "Draw (Q) Line", SCRIPT_PARAM_ONOFF, true)			
			BardMenu.sett.drawing:addParam("chime", "Draw Neareset Chime", SCRIPT_PARAM_ONOFF, true) 
			
	BardMenu:addSubMenu("Orbwalking Settings", "Orbwalking") 	
		
	BardMenu:addSubMenu("Keybindings", "keys") 
		BardMenu.keys:addParam("info51","Combat Keys are connected to your orbwalker keys.", SCRIPT_PARAM_INFO, "")
		BardMenu.keys:addParam("info51","", SCRIPT_PARAM_INFO, "")
		if exhaust then	
			BardMenu.keys:addParam("exh", "Exhaust Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey(exhaust.key)) 
		end
		--BardMenu.keys:addParam("tunnel", "Tunnel Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("G")) 

	TSex = TargetSelector(TARGET_PRIORITY, 600, DAMAGE_MAGIC)
		
	TargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, 1000, DAMAGE_MAGIC)
	TSex.name = "EX"
	TargetSelector.name = "Bard"
end

function IsCombo()
	if sacUsed and _G.AutoCarry.Keys.AutoCarry then
		return true
	elseif sxorbUsed and SxOrb.isFight then
		return true
	elseif mmaUsed and _G.MMA_IsOrbwalking() then
		return true
	elseif norbUsed and _G.NebelwolfisOrbWalker.Config.k.Combo then
		return true
	elseif pewUsed and _Pewalk.GetActiveMode()["Carry"] then
		return true
	end
end
function IsHarass()
	if sacUsed and _G.AutoCarry.Keys.MixedMode then
		return true
	elseif sxorbUsed and SxOrb.isHarass then
		return true
	elseif mmaUsed and _G.MMA_IsDualCarrying() then
		return true
	elseif norbUsed and _G.NebelwolfisOrbWalker.Config.k.Harass then
		return true
	elseif pewUsed and _Pewalk.GetActiveMode()["Mixed"] then
		return true
	end
end
function IsLaneclear()
	if sacUsed and _G.AutoCarry.Keys.LaneClear then
		return true
	elseif sxorbUsed and SxOrb.isLaneClear then
		return true
	elseif mmaUsed and _G.MMA_IsLaneClearing() then
		return true
	elseif norbUsed and _G.NebelwolfisOrbWalker.Config.k.LaneClear then
		return true
	elseif pewUsed and _Pewalk.GetActiveMode()["LaneClear"] then
		return true
	end
end
function IsLastHit()
	if sacUsed and _G.AutoCarry.Keys.LastHit then
		return true
	elseif sxorbUsed and SxOrb.isLastHit then
		return true
	elseif mmaUsed and _G.MMA_IsLastHitting() then
		return true
	elseif norbUsed and _G.NebelwolfisOrbWalker.Config.k.LastHit then
		return true
	elseif pewUsed and _Pewalk.GetActiveMode()["Farm"] then
		return true
	end
end

function OnTick()
	ComboKey			= IsCombo()
	HarassKey			= IsHarass()
	LastHitKey          = IsLastHit()
	Debug               = BardMenu.sett.debug
	
	TickChecks()

	if ComboKey then
		if Target then 
			ComboMode(Target)
		end
		if  BardMenu.combo.bush then
			bushfind()
		end
	elseif HarassKey and Target then
		HarassMode(Target)
	elseif BardMenu.sett.qlast and LastHitKey and SpellQ.ready and CountAlliesNearUnit(myHero, 900) == 0 then
		farming()
	end
	CastR()

	if exhaust and BardMenu.keys.exh then 
		if exhaust.slot then
			exhaust.ready = (myHero:CanUseSpell(exhaust.slot) == 0)
		end
		if exhaust.ready then
			TSex:update()
			if ValidTarget(TSex.target) and TSex.target.type == myHero.type then
				exhFunction(TSex.target) 
			end
		end
	end
	for _,c in pairs(sEnemies) do		
		if c.visible then
			lastpos [ c.networkID ] = Vector(c) 
			lasttime[ c.networkID ] = os.clock() 
		end
	end
	if BardMenu.sett.afkH and not checkSpecific(myHero, 'recall') then
		afkHeal()
	end
	--if BardMenu.keys.tunnel then
	--	doTunnel()
	--end
end

function checkSpecific(unit, buffname)
	for i = 1, unit.buffCount do
		local buff = unit:getBuff(i)
		if buff and buff.valid and buff.name then
			if buff.name:lower():find(buffname) then
				return true
			end
		end
	end
end

function farming()
	enemyMinions:update()
	for index, minion in pairs(enemyMinions.objects) do
		if minion and minion.valid and not minion.dead then
			local d = GetDistance(minion)
			if d < SpellQ.range and d > myHero.range + myHero.boundingRadius + 75 and isQKill(minion) then
				CastSpell(0, minion.x, minion.z)
			end
		end
	end
end

function isQKill(unit)
	local phealth = vPred:GetPredictedHealth(unit, .25 + GetDistance(unit)/SpellQ.speed)
	local qDamage = SpellQ.dmg()

	return phealth < qDamage and phealth > 0
end

function aaReset(aaTarget)
	if not ValidTarget(aaTarget) then return end
	
	if not Target and BardMenu.sett.qclear and IsLaneclear() and aaTarget.health > 2*myHero.totalDamage then
		CastQ(aaTarget)
	end
end

function exhFunction(unit)
	moveToCursor()
	CastSpell(exhaust.slot, unit)
end


function ProcessAttack(unit, spell)
	if not spell or not unit or not unit.valid then return end
	
	if unit.isMe then
		if spell.name:lower():find("attack") then
			aaReset(myHero.spell.target)
		end
	end
end
if AddProcessAttackCallback then
	AddProcessAttackCallback(function(unit, spell) ProcessAttack(unit, spell) end)
end

function OnProcessSpell(unit, spell)
	if not unit or not unit.valid then return end

	if SpellQ.ready and spell.name:lower():find("deceive") and GetDistance(spell.endPos, myHero.pos) < SpellQ.range then
		local cPos = spell.endPos
		if Debug then Print("Casting Q on "..spell.name) end
		CastSpell(0, cPos.x, cPos.z)
	end

end
function TickChecks()
	myMana = (myHero.mana/myHero.maxMana )*100
	SpellQ.ready = myHero:CanUseSpell(0) == 0
	SpellW.ready = myHero:CanUseSpell(1) == 0
	SpellE.ready = myHero:CanUseSpell(2) == 0
	SpellR.ready = myHero:CanUseSpell(3) == 0
	Target = GetCustomTarget()
	TargetSelectorMode()
end

function GetCustomTarget()
	if ValidTarget(SelectedTarget, 1000) and (Ignore == nil or (Ignore.networkID ~= SelectedTarget.networkID)) then
		return SelectedTarget
	end
	TargetSelector:update()	
	if ValidTarget(TargetSelector.target) and TargetSelector.target.type == myHero.type then
		return TargetSelector.target
	else
		return nil
	end
end

function notCombat()
	return not IsCombo() and not IsHarass() and not IsLaneclear() and not IsLastHit()
end

local healSpots = {
	team1 = {
		Vector(10988,49,1302),
		Vector(10910,49,1050),
		Vector(11031,49,1333),
		Vector(12324,49,1218), --bush
		Vector(12694,49,1475),
	},
	team2 = {
		Vector(13618,49,2736),
		Vector(13485,49,2395),	
		Vector(13789,49,3903),
		Vector(13395,49,4248),
	}
}
local theta2 = math.pi/180
function afkHeal()
	if SpellW.ready and myMana > 85 and notCombat() then
		local ene = findClosestEnemy(myHero)
		if not ene or GetDistance(ene) > 1200 then
			if myHero.team == 100 then
				for i, spot in pairs(healSpots.team1) do
					local a = (math.random()* 360)*theta2
					local randomSpot = Vector(spot.x + 100 * math.cos(a), spot.y, spot.z - 100 * math.sin(a))
					if GetDistance(randomSpot) <= SpellW.range and GetDistance(randomSpot) > 150 then
						CastSpell(1, randomSpot.x, randomSpot.z)
						return
					end
				end
			else

			end
		end
	end
end

--WINDOW_H
--WINDOW_W
function DrawRectangleAL(x, y, w, h, color)
    local Points = {}
    Points[1] = D3DXVECTOR2(math.floor(x), math.floor(y))
    Points[2] = D3DXVECTOR2(math.floor(x + w), math.floor(y))
    DrawLines2(Points, math.floor(h), color)
end

local chimes = {}
function drawChimes()
	local closest
	local closestD
	for i, chime in pairs(chimes) do
		if not closest then
			closest = chime
			closestD = GetDistance(chime)
		else
			local currCloseD = GetDistance(chime)
			if currCloseD < closestD then
				closest = chime
				closestD = currCloseD
			end
		end
	end
	
	local chime = closest
	if chime then
		local color
		if closestD < 3600 then
			local distance = closestD / 3600
			color = ARGB(255,255*distance,255-255*distance,0)
		else
			color = ARGB(255,255,0,0)
		end
		if IsOnScreen(chime) then
			local extend = Vector(chime) + (Vector(myHero) - Vector(chime)):normalized() * (40)
			DrawCircle3D(chime.x, chime.y, chime.z, 40, 2, color, 52)
			DrawLine3D(extend.x, extend.y, extend.z, myHero.x, myHero.y, myHero.z, 2,color)
		else
			local t2 = GetDistance(chime)
			for i = 0.1, 1, 0.05 do
				local extend = Vector(myHero) + (Vector(chime) - Vector(myHero)):normalized() * (t2*i)
				if not IsOnScreen(extend) then
					screen = WorldToScreen(D3DXVECTOR3(extend.x, extend.y, extend.z))
					if screen.x < 0 then
						screen.x = 34
					elseif screen.x > WINDOW_W-34 then
						screen.x = WINDOW_W-34
					end
					if screen.y < 0 then
						screen.y = 18
					elseif screen.y > WINDOW_H-18 then
						screen.y = WINDOW_H-18
					end 
					DrawLineBorder(screen.x - 32, screen.y, screen.x + 32, screen.y, 34, color, 2)
					DrawTextA(tostring(string.format("%.2i",t2)), 30, screen.x, screen.y, color,"center","center")
					break
				end
			end
		end
	end
end

local tunnels = {
	{start = Vector(316,183,660), stop = Vector(496.036,49,3386.09423)},
	{start = Vector(846,178,362), stop = Vector(995.6557,173.704,371.14862)},
	{start = Vector(10988,49,1302), stop = Vector(10988,49,1302)},
	{start = Vector(10988,49,1302), stop = Vector(10988,49,1302)},
}
if GetGame().map.shortName ~= "summonerRift" then
	tunnels = {}
end

function doTunnel()
	for x, tunnel in pairs(tunnels) do
		local s = tunnel.start
		local e = tunnel.stop
		if GetDistance(s) < 10 then
			if SpellE.ready then
				--local adjusted = Vector(myHero) + (e - Vector(myHero)):normalized() * 50
				CastSpell(2, e.x, e.z)
				return
			end
		elseif GetDistance(mousePos, s) < 100 then
			myHero:MoveTo(s.x, s.z)
			return
		end
	end
	moveToCursor()
end
	--[[for x, tunnel in pairs(tunnels) do
		local s = tunnel.start
		if GetDistanceSqr(s) < 7000*7000 then
			local d = GetDistanceSqr(s, mousePos) <= 125*125
			local spotcolor = d and ARGB(255, 0, 255, 0) or  ARGB(255, 255, 255, 0)
			DrawCircle3D(s.x, s.y, s.z, 75, 2, spotcolor, 45)
			DrawText3D('G', s.x, s.y, s.z, 30, spotcolor, true)
		end
	end]]
function OnDraw()
	if BardMenu.sett.drawing.chime then
		drawChimes()
	end
	
	if Target and SpellQ.ready and BardMenu.sett.drawing.qLine then
		local w = 65
		local MouseMove = Vector(myHero) + (Vector(Target) - Vector(myHero)):normalized() * (450 + myHero.boundingRadius)
		DrawLineBorder3D(MouseMove.x, myHero.y, MouseMove.z, myHero.x, myHero.y, myHero.z, w, ARGB(100, 206, 22, 22), 5)
		DrawLineBorder3D(MouseMove.x, myHero.y, MouseMove.z, myHero.x, myHero.y, myHero.z, w, ARGB(115, 255, 255, 255), 2)
		
		local MouseMove = Vector(myHero) + (Vector(Target) - Vector(myHero)):normalized() * (950)
		DrawLineBorder3D(MouseMove.x, myHero.y, MouseMove.z, myHero.x, myHero.y, myHero.z, w, ARGB(100, 206, 22, 22), 5)
		DrawLineBorder3D(MouseMove.x, myHero.y, MouseMove.z, myHero.x, myHero.y, myHero.z, w, ARGB(115, 255, 255, 255), 2)
	end
		
	if Debug then
		if vPred then
			local dp = GetDistance(myHero.pos, mousePos)
			if dp < SpellQ.range then
				local extend = SpellQ.range - dp 
				if extend > 1 then
					
					local extendedCollision = Vector(mousePos) + (Vector(mousePos) - Vector(myHero)):normalized() * (extend)
					for i, enemy in pairs(sEnemies) do
						if vPred:CheckCol(extendedCollision, enemy, mousePos, SpellQ.delay, SpellQ.width, SpellQ.range, SpellQ.speed, myHero) then
							DrawLine3D(mousePos.x, mousePos.y, mousePos.z, extendedCollision.x, myHero.y, extendedCollision.z, 2,ARGB(255,255,0,0))
							return
						end
					end
					local col = vPred:CheckMinionCollision(mousePos, extendedCollision, SpellQ.delay, SpellQ.width, extend, SpellQ.speed, mousePos, false, true)
					if col then
						DrawLine3D(mousePos.x, mousePos.y, mousePos.z, extendedCollision.x, myHero.y, extendedCollision.z, 2,ARGB(255,0,0,255))
						return
					end
					local amount = extend/10
					local count = 1
					while count <= 10 do
						local extendedWall = Vector(mousePos) + (Vector(mousePos) - Vector(myHero)):normalized() * (amount*count)
						local vec1 = D3DXVECTOR3(extendedWall.x, extendedWall.y,extendedWall.z)
						if IsWall(vec1) then
							DrawLine3D(mousePos.x, mousePos.y, mousePos.z, extendedCollision.x, myHero.y, extendedCollision.z, 2,ARGB(255,0,255,0))
							return
						end
						count = count + 1
					end
					DrawLine3D(mousePos.x, mousePos.y, mousePos.z, extendedCollision.x, myHero.y, extendedCollision.z, 2,ARGB(255,255,255,255))
				end
			end
			
			if Target then
				local dp = GetDistance(myHero.pos, Target)
				if dp < SpellQ.range then
					local extend = SpellQ.range - dp 
					if extend > 1 then
						local extendedCollision = Vector(Target) + (Vector(Target) - Vector(myHero)):normalized() * (extend)
						for i, enemy in pairs(sEnemies) do
							if enemy ~= Target then
								if vPred:CheckCol(extendedCollision, enemy, Target, SpellQ.delay, SpellQ.width, SpellQ.range, SpellQ.speed, myHero) then
									DrawLine3D(Target.x, Target.y, Target.z, extendedCollision.x, myHero.y, extendedCollision.z, 2,ARGB(255,255,0,0))
									return
								end
							end
						end
						local col = vPred:CheckMinionCollision(Target, extendedCollision, SpellQ.delay, SpellQ.width, extend, SpellQ.speed, Target, false, true)
				
						if col then
							DrawLine3D(Target.x, Target.y, Target.z, extendedCollision.x, myHero.y, extendedCollision.z, 2,ARGB(255,0,0,255))
							return
						end
						local amount = extend/10
						local count = 1
						while count <= 10 do
							local extendedWall = Vector(Target) + (Vector(Target) - Vector(myHero)):normalized() * (amount*count)
							local vec1 = D3DXVECTOR3(extendedWall.x, extendedWall.y,extendedWall.z)
							if IsWall(vec1) then
								DrawLine3D(Target.x, Target.y, Target.z, extendedCollision.x, myHero.y, extendedCollision.z, 2,ARGB(255,0,255,0))
								return
							end
							count = count + 1
						end
						DrawLine3D(Target.x, Target.y, Target.z, extendedCollision.x, myHero.y, extendedCollision.z, 2,ARGB(255,255,255,255))
					end
				end
			end
		end
	end
	
	if not myHero.dead then
		if not BardMenu.sett.drawing.mDraw then	
			if BardMenu.sett.drawing.aaDraw then 
				DrawCircle3D(myHero.x, myHero.y, myHero.z, myHero.boundingRadius + myHero.range, 4, ARGB(100, 57,255,20), 52)
			end
			if BardMenu.sett.drawing.hitDraw then 
				DrawCircle3D(myHero.x, myHero.y, myHero.z, myHero.boundingRadius, 4, ARGB(80, 0,255,100), 52)
			end
		
			if BardMenu.sett.drawing.qDraw and SpellQ.ready then
				DrawCircle3D(myHero.x, myHero.y, myHero.z, SpellQ.range, 2, ARGB(70, 233,133,253), 52)
			end
			if BardMenu.sett.drawing.Target and Target then
				DrawCircle3D(Target.x, Target.y, Target.z, Target.boundingRadius, 3, ARGB(211, 255, 20 , 147 ), 55)
			end
			if ValidTarget(SelectedTarget) then
				DrawCircle3D(SelectedTarget.x, SelectedTarget.y, SelectedTarget.z, 10, 20, ARGB(244, 255, 255 , 0 ), 55)
			end
		end
	end
end

function ComboMode(unit)	
	if myMana > BardMenu.combo.qMana then
		CastQ(unit)
	end
	
	CastW()
end

function HarassMode(unit)
	if myMana > BardMenu.harass.qMana then
		CastQ(unit)
	end
end

function getHealthP(unit)
	return unit.health/unit.maxHealth
end

function CastW()
	if SpellW.ready and myMana > BardMenu.combo.wMana then
		if getHealthP(myHero) < BardMenu.combo.WSelf/100 then
			local enemy = findClosestEnemy(myHero)
			if ValidTarget(enemy, 600) then
				CastSpell(1, myHero)
			end
		end
		for i, ally in pairs(sAllies) do
			if GetDistance(ally) < SpellW.range - 100 and getHealthP(ally) < BardMenu.combo.WOther/100 then
				local enemy = findClosestEnemy(myHero)
				if ValidTarget(enemy, 600) then
					CastSpell(1, ally)
				end
			end
		end
	end
end

function findClosestEnemy(obj)
    local closestEnemy = nil
    local currentEnemy = nil
	for i, currentEnemy in pairs(sEnemies) do
        if ValidTarget(currentEnemy) then
            if closestEnemy == nil then
                closestEnemy = currentEnemy
			end
            if GetDistanceSqr(currentEnemy.pos, obj) < GetDistanceSqr(closestEnemy.pos, obj) then
				closestEnemy = currentEnemy
            end
        end
    end
	return closestEnemy
end

function CountEnemiesNearUnitReg(unit, range)
	local count = 0
	for i, enemy in pairs(sEnemies) do
		if not enemy.dead and enemy.visible then
			if  GetDistanceSqr(unit, enemy) < range * range  then
				count = count + 1
			end
		end
	end
	return count
end

function CountAlliesNearUnit(unit, range)
	local count = 0
	for i, ally in pairs(sAllies) do
		if GetDistanceSqr(ally, unit) <= range * range and not ally.dead then count = count + 1 end
	end
	return count
end

function CastR()
	if not SpellR.ready then return end
	
	if getHealthP(myHero) < BardMenu.ult.RSelf/100 then
		if CountEnemiesNearUnitReg(myHero, 550) >= BardMenu.ult.RCount then
			local pos = vPred:GetPredictedPos(myHero, 0.5)
			CastSpell(3, pos.x, pos.z)
		end
	end
	
	for i, ally in pairs(sAllies) do
		if GetDistance(ally) < SpellR.range - 1200 and getHealthP(ally) < BardMenu.ult.ROther/100 then
			if CountEnemiesNearUnitReg(ally, 550) >= BardMenu.ult.RCount then
				local pos = vPred:GetPredictedPos(ally, 1)
				CastSpell(3, pos.x, pos.z)
			end
		end
	end
end
function PredictionSuite(unit, delay, width, range, speed, from, collision)
	if not ValidTarget(unit) then return end
	if BardMenu.sett.pred == 3 and hpEnabled then
		local QPos, QHitChance = HPred:GetPredict(HP_Q, unit, myHero, false)
		return QPos, QHitChance + 1
	elseif BardMenu.sett.pred == 5 and kpEnabled then
		local CastPosition, Hitchance = KPred:GetPrediction(KP_Q, unit, myHero)
		return CastPosition, Hitchance
	elseif BardMenu.sett.pred == 2 and dpEnabled then
		local c = collision and 0 or math.huge
		local state, hitPos, perc = DP:predict("Q",unit)
		if state == SkillShot.STATUS.SUCCESS_HIT then
			return hitPos, 2
		else
			return hitPos, 0
		end
	elseif BardMenu.sett.pred == 4 and fhPredEnabled then
		local pos, hc, info = FHPrediction.GetPrediction(fhQ, unit)
		return pos, hc + 1
	else
		local CastPosition, Hitchance, Position = vPred:GetLineCastPosition(unit, delay, width, range+ 150, speed, from, collision)
		return CastPosition, Hitchance
	end
end

function CastQ(unit)
	if not SpellQ.ready or not ValidTarget(unit) then return end

	local CastPosition, Hitchance = PredictionSuite(unit, SpellQ.delay, SpellQ.width, SpellQ.range, SpellQ.speed, myHero, true)
	if CastPosition then 
		local dp = GetDistance(myHero.pos, CastPosition)
		if dp < SpellQ.range then
			local extend = 450
			if extend > 1 then
				local extendedCollision = Vector(CastPosition) + (Vector(CastPosition) - Vector(myHero)):normalized() * (extend)
				if Hitchance >= 2 then
					if myHero.health/myHero.maxHealth < 0.4 or unit.health/unit.maxHealth < 0.4 then
						CastSpell(0, CastPosition.x, CastPosition.z)
						return
					end
					for i, enemy in pairs(sEnemies) do
						if enemy ~= unit then
							if vPred:CheckCol(extendedCollision, enemy, CastPosition, SpellQ.delay, SpellQ.width, SpellQ.range, SpellQ.speed, myHero) then
								if Debug then print("hero coll castq") end
								CastSpell(0, CastPosition.x, CastPosition.z)
								return
							end
						end
					end
					local col = vPred:CheckMinionCollision(unit, extendedCollision, SpellQ.delay, SpellQ.width, extend, SpellQ.speed, CastPosition, false, true)
					if col then
						if Debug then print("minion behind coll castq") end
						CastSpell(0, CastPosition.x, CastPosition.z)
						return
					end
					local amount = extend/10
					local count = 1
					while count <= 10 do
						local extendedWall = Vector(CastPosition) + (Vector(CastPosition) - Vector(myHero)):normalized() * (amount*count)
						local vec1 = D3DXVECTOR3(extendedWall.x, extendedWall.y,extendedWall.z)
						if IsWall(vec1) then
							CastSpell(0, CastPosition.x, CastPosition.z)
							if Debug then print("wall coll castq") end
							return
						end
						count = count + 1
					end
				end
				local mBool, mTable = GetMinionCollision(myHero, CastPosition, unit)
				if mBool and #mTable == 1 then
					if Debug then print("minion or hero infront coll castq") end
					CastSpell(0, CastPosition.x, CastPosition.z)
					return
				end
			end
		end
	end
end

function WndMsg(Msg, Key)
--print(Msg)
--print(Key)
	if Msg == WM_LBUTTONUP then
		if Debug then
			--print(GetSpellData(_R).channelDuration)
		end
			--local a = Vector(995.6557,173.704,371.14862)
			
			--local vec = D3DXVECTOR3(995.6557,173.704,371.14862)
			--CastSpell2(2, vec)
			--CastSpell(2, a.x, a.y, a.z)
			--print(Vector(mousePos))
	end
	
	if Msg == WM_LBUTTONDOWN and BardMenu.sett.sel then  --From Honda
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
AddMsgCallback(function(Msg,Key) WndMsg(Msg,Key) end)

function moveToCursor()
	if notCombat() then
		local MouseMove = Vector(myHero) + (Vector(mousePos) - Vector(myHero)):normalized() * 500
		myHero:MoveTo(MouseMove.x, MouseMove.z)	
	end
end


function TargetSelectorMode()
	if BardMenu.sett.Target == 1 then
		TargetSelector.mode = TARGET_LESS_CAST
	elseif BardMenu.sett.Target == 2 then
		TargetSelector.mode = TARGET_NEAR_MOUSE
	elseif BardMenu.sett.Target == 3 then
		TargetSelector.mode = TARGET_LESS_CAST_PRIORITY
	end
end

function OnCreateObj(obj)
	if not obj or not obj.valid then return end
	--if GetDistance(obj) < 333 then print(obj.name.." "..GetDistance(obj)) end
	if obj.name:lower():find('chime.troy') then
		table.insert(chimes, obj)
	end

	if obj.spellOwner and obj.spellOwner == myHero then
		--if obj.name:lower():find('q_aoe_resolve.') then
		--	qReturn = obj
		--end
	end
end

function OnDeleteObj(obj)
	if not obj or not obj.valid then return end
	if obj.name:lower():find('chime.troy') then
		for i, chime in pairs(chimes) do
			if chime == obj then
				table.remove(chimes, i)
			end
		end
	end
end
function bushfind()
	if lastTime +15 > os.clock() then return end
	for _,c in pairs(sEnemies) do		
		if not c.dead and not c.visible then
			local time=lasttime[ c.networkID ]  --last seen time
			local pos=lastpos [ c.networkID ]   --last seen pos
			local clock=os.clock()
			
			if time and pos and clock-time < 5 and GetDistanceSqr(pos)< 1005000 then
				local FoundBush = FindBush(pos.x,pos.y,pos.z,100)
		
				if FoundBush and GetDistanceSqr(FoundBush)<600*600 then
					local WardSlot = ItemS()
					
					if WardSlot then
						CastSpell(WardSlot,FoundBush.x,FoundBush.z)
						lastTime = os.clock()
						return
					end
				end
			end
		end
	end
end
function ItemS()
	local WardSlot = nil
	if GetInventorySlotItem(2045) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(2045)) == READY then
		WardSlot = GetInventorySlotItem(2045)
	elseif GetInventorySlotItem(2049) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(2049)) == READY then
		WardSlot = GetInventorySlotItem(2049)
	elseif GetInventorySlotItem(3340) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(3340)) == READY or 
	GetInventorySlotItem(3350) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(3350)) == READY or 
	GetInventorySlotItem(3361) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(3361)) == READY or 
	GetInventorySlotItem(3363) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(3363)) == READY or
	GetInventorySlotItem(3411) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(3411)) == READY or
	GetInventorySlotItem(3342) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(3342)) == READY or
	GetInventorySlotItem(3362) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(3362)) == READY  then
		WardSlot = 12
	elseif GetInventorySlotItem(2044) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(2044)) == READY then
		WardSlot = GetInventorySlotItem(2044)
	elseif GetInventorySlotItem(2043) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(2043)) == READY then
		WardSlot = GetInventorySlotItem(2043)
	end

	return WardSlot
end
function FindBush(x0, y0, z0, maxRadius, precision) --returns the nearest non-wall-position of the given position(Credits to gReY)
    
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

-------------------------------------------
function getHitBoxRadius(target)
	return GetDistance(target, target.minBBox)/2
end

function GetMinionCollision(pStart, pEnd, unit) --From Collision 1.1.1 by Klokje
	enemyMinions:update()
	mCollision = {} 
		
	local distance =  GetDistance(pStart, pEnd)
	local prediction = VP
	if distance > SpellQ.range then
		distance = SpellQ.range
	end
 
	local V = Vector(pEnd) - Vector(pStart)
	local k = V:normalized()
    local P = V:perpendicular2():normalized()
 
    local t,i,u = k:unpack()
    local x,y,z = P:unpack()
 
    local startLeftX = pStart.x + (x *(SpellQ.width/2))
    local startLeftY = pStart.y + (y *(SpellQ.width/2))
    local startLeftZ = pStart.z + (z *(SpellQ.width/2))
    local endLeftX = pStart.x + (x * (SpellQ.width/2)) + (t * distance)
    local endLeftY = pStart.y + (y * (SpellQ.width/2)) + (i * distance)
    local endLeftZ = pStart.z + (z * (SpellQ.width/2)) + (u * distance)
     
    local startRightX = pStart.x - (x * (SpellQ.width/2 ))
    local startRightY = pStart.y - (y * (SpellQ.width/2 ))
    local startRightZ = pStart.z - (z * (SpellQ.width/2 ))
    local endRightX = pStart.x - (x * (SpellQ.width/2)) + (t * distance)
    local endRightY = pStart.y - (y * (SpellQ.width/2)) + (i * distance)
    local endRightZ = pStart.z - (z * (SpellQ.width/2)) + (u * distance)
 
    local startLeft = WorldToScreen(D3DXVECTOR3(startLeftX, startLeftY, startLeftZ))
    local startRight = WorldToScreen(D3DXVECTOR3(startRightX, startRightY, startRightZ))    local endLeft = WorldToScreen(D3DXVECTOR3(endLeftX, endLeftY, endLeftZ))

    local endRight = WorldToScreen(D3DXVECTOR3(endRightX, endRightY, endRightZ))
      
    local poly = Polygon(Point(startLeft.x, startLeft.y),  Point(endLeft.x, endLeft.y), Point(startRight.x, startRight.y),   Point(endRight.x, endRight.y))
 
    for index, minion in pairs(enemyMinions.objects) do
		if minion ~= nil and minion.valid and not minion.dead then
			if GetDistance(pStart, minion) < distance then
				
				local pos, t, vec = vPred:GetLineCastPosition(pEnd, SpellQ.delay, SpellQ.width, SpellQ.range, SpellQ.speed, myHero)	
                local lineSegmentLeft = LineSegment(Point(startLeftX,startLeftZ), Point(endLeftX, endLeftZ))
                local lineSegmentRight = LineSegment(Point(startRightX,startRightZ), Point(endRightX, endRightZ))
                local toScreen, toPoint
                if pos ~= nil then
					toScreen = WorldToScreen(D3DXVECTOR3(minion.x, minion.y, minion.z))
                    toPoint = Point(toScreen.x, toScreen.y)
                else
					toScreen = WorldToScreen(D3DXVECTOR3(minion.x, minion.y, minion.z))
                    toPoint = Point(toScreen.x, toScreen.y)
                end
 
 
                if poly:contains(toPoint) then
					table.insert(mCollision, minion)
                else
                    if pos ~= nil then
						distance1 = Point(pos.x, pos.z):distance(lineSegmentLeft)
                        distance2 = Point(pos.x, pos.z):distance(lineSegmentRight)
                    else
                        distance1 = Point(minion.x, minion.z):distance(lineSegmentLeft)
                        distance2 = Point(minion.x, minion.z):distance(lineSegmentRight)
                    end
                    if (distance1 < (getHitBoxRadius(minion)*2+10) or distance2 < (getHitBoxRadius(minion) *2+10)) then
                        table.insert(mCollision, minion)
                    end
				end
			end
		end
	end
	 for index, minion in pairs(sEnemies) do
		if minion ~= unit and minion ~= nil and minion.valid and not minion.dead then
			if GetDistance(pStart, minion) < distance then
				
				local pos, t, vec = vPred:GetLineCastPosition(pEnd, SpellQ.delay, SpellQ.width, SpellQ.range, SpellQ.speed, myHero)	
                local lineSegmentLeft = LineSegment(Point(startLeftX,startLeftZ), Point(endLeftX, endLeftZ))
                local lineSegmentRight = LineSegment(Point(startRightX,startRightZ), Point(endRightX, endRightZ))
                local toScreen, toPoint
                if pos ~= nil then
					toScreen = WorldToScreen(D3DXVECTOR3(minion.x, minion.y, minion.z))
                    toPoint = Point(toScreen.x, toScreen.y)
                else
					toScreen = WorldToScreen(D3DXVECTOR3(minion.x, minion.y, minion.z))
                    toPoint = Point(toScreen.x, toScreen.y)
                end
 
 
                if poly:contains(toPoint) then
					table.insert(mCollision, minion)
                else
                    if pos ~= nil then
						distance1 = Point(pos.x, pos.z):distance(lineSegmentLeft)
                        distance2 = Point(pos.x, pos.z):distance(lineSegmentRight)
                    else
                        distance1 = Point(minion.x, minion.z):distance(lineSegmentLeft)
                        distance2 = Point(minion.x, minion.z):distance(lineSegmentRight)
                    end
                    if (distance1 < (getHitBoxRadius(minion)*2+10) or distance2 < (getHitBoxRadius(minion) *2+10)) then
                        table.insert(mCollision, minion)
                    end
				end
			end
		end
	end
	if #mCollision == 0 then return false, mCollision else return true, mCollision end
end

do --Updater
class "Bard_07"
function Bard_07:__init(LocalVersion,UseHttps, Host, VersionPath, ScriptPath, SavePath, CallbackUpdate, CallbackNoUpdate, CallbackNewVersion,CallbackError)
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

function Bard_07:print(str)
    print('<font color="#FFFFFF">'..os.clock()..': '..str)
end

function Bard_07:OnDraw()
    if self.DownloadStatus ~= 'Downloading Script (100%)' and self.DownloadStatus ~= 'Downloading VersionInfo (100%)'then
        DrawText('Download Status: '..(self.DownloadStatus or 'Unknown'),50,10,50,ARGB(0xFF,0xFF,0xFF,0xFF))
    end
end

function Bard_07:CreateSocket(url)
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

function Bard_07:Base64Encode(data)
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

function Bard_07:GetOnlineVersion()
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

function Bard_07:DownloadUpdate()
    if self.GotBard_07 then return end
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
        self.GotBard_07 = true
    end
end
end