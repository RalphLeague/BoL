--[[
Summoner & Item Usage by Ralphlol
Updated May 12th 2016
]]--

local version = 1.28
local sEnemies = GetEnemyHeroes()
local sAllies = GetAllyHeroes()
local lastRemove = 0

function Print(message) print("<font color=\"#7BF6B6\"><b>Summoner & Item Usage:</font> </b><font color=\"#FFFFFF\">" .. message) end

require 'VPrediction'
vPred = VPrediction()

local function Slot(name)
	if myHero:GetSpellData(SUMMONER_1).name:lower():find(name) then
		return SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:lower():find(name) then
		return SUMMONER_2
	end
end

function OnLoad()
    local ToUpdate = {}
    ToUpdate.Version = version
    ToUpdate.UseHttps = true
    ToUpdate.Host = "raw.githubusercontent.com"
    ToUpdate.VersionPath = "/RalphLeague/BoL/master/SIUsage.version"
    ToUpdate.ScriptPath =  "/RalphLeague/BoL/master/SIUsage.lua"
    ToUpdate.SavePath = SCRIPT_PATH.._ENV.FILE_NAME
    ToUpdate.CallbackUpdate = function(NewVersion,OldVersion) Print("Updated to v"..NewVersion) end
    ToUpdate.CallbackNoUpdate = function(OldVersion) Print("No Updates Found") end
    ToUpdate.CallbackNewVersion = function(NewVersion) Print("New Version found ("..NewVersion.."). Please wait until its downloaded") end
    ToUpdate.CallbackError = function(NewVersion) Print("Error while Downloading. Please try again.") end
    SIUsage_Update(ToUpdate.Version,ToUpdate.UseHttps, ToUpdate.Host, ToUpdate.VersionPath, ToUpdate.ScriptPath, ToUpdate.SavePath, ToUpdate.CallbackUpdate,ToUpdate.CallbackNoUpdate, ToUpdate.CallbackNewVersion,ToUpdate.CallbackError)

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
		--[2041]				= "ItemCrystalFlask",
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
		--[2004]				= "FlaskOfCrystalWater",
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
		[5000]				= "ItemTitanicHydraCleave",
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
		[3085]              = "AtmasImpalerDummySpell",
	}
	--[[Items = {
		["QSS"]	        = { id = 3140, range = 2500 },
		["MercScim"]	= { id = 3139, range = 2500 },
	}]]
	Items = {
		["ELIXIR"]      = { id = 2140, range = 2140, target = false},
		["QSS"]	        = { id = 3140, range = 2500, target = false},
		["MercScim"]	= { id = 3139, range = 2500, target = false},
		["BRK"]			= { id = 3153, range = 550, target = true},
		["BWC"]			= { id = 3144, range = 550, target = true},
		--["DFG"]			= { id = 3128, range = 750, target = false},
		["HXG"]			= { id = 3146, range = 700, target = false},
		["ODYNVEIL"]	= { id = 3180, range = 525, target = false},
		["DVN"]			= { id = 3131, range = 200, target = false},
		["ENT"]			= { id = 3184, range = 350, target = false},
		["HYDRA"]		= { id = 3074, range = 350, target = false},
		["TIAMAT"]		= { id = 3077, range = 350, target = false},
		["TITANIC"]		= { id = 5000, range = 350, target = false},
		["RanduinsOmen"]	= { id = 3143, range = 500, target = false},
		["YGB"]			= { id = 3142, range = 600, target = false},
		["HEX"]			= { id = 5555, range = 600, target = false},
	}
	___GetInventorySlotItem	= rawget(_G, "GetInventorySlotItem")
	_G.GetInventorySlotItem	= GetSlotItem
	if myHero:GetSpellData(4).name:lower():find("exhaust") then
		exhaust = { slot = 4, key = "D", range =  650, ready = false }
	elseif myHero:GetSpellData(5).name:lower():find("exhaust") then
		exhaust = { slot = 5, key = "F", range =  650, ready = false }
	end
	SummonerSlot = Slot("summonerboost")
	ignite = Slot("summonerdot")
	heal = HealSlot()
	
	ItemMenu()
	Debug = false
	TargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, 1250, DAMAGE_MAGIC)
end

function GetCustomTarget()
	TargetSelector:update()	
	if ValidTarget(TargetSelector.target) and TargetSelector.target.type == myHero.type then
		return TargetSelector.target
	else
		return nil
	end
end

function ItemMenu()
	MainMenu = scriptConfig("Summoner & Item Usage", "SIUSE")
		MainMenu:addSubMenu("Health Potions", "potion")
			MainMenu.potion:addParam("Key", "Use While Pressed", SCRIPT_PARAM_ONKEYDOWN, false, 32)
			MainMenu.potion:addParam("Always", "Use Always", SCRIPT_PARAM_ONOFF, true)
			MainMenu.potion:addParam("enemy", "Use if no enemies", SCRIPT_PARAM_ONOFF, true)
			MainMenu.potion:addParam("health", "If My Health % is <", SCRIPT_PARAM_SLICE, 60, 0, 100, 0) 
	--	MainMenu:addSubMenu("Mana Potions", "potionMana")
	--		MainMenu.potionMana:addParam("Key", "Use While Pressed", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	--		MainMenu.potionMana:addParam("Always", "Use Always", SCRIPT_PARAM_ONOFF, false)
	--		MainMenu.potionMana:addParam("health", "If My Mana % is <", SCRIPT_PARAM_SLICE, 30, 0, 100, 0)
		MainMenu:addSubMenu("Remove CC", "cc")
			MainMenu.cc:addParam("Key", "Use While Pressed", SCRIPT_PARAM_ONKEYDOWN, false, 32)
			MainMenu.cc:addParam("Always", "Use Always", SCRIPT_PARAM_ONOFF, true)
			--MainMenu.cc:addParam("Exhaust", "Remove Exhaust", SCRIPT_PARAM_ONOFF, false)		
			if SummonerSlot then
				MainMenu.cc:addParam("Summoner", "Use Cleanse Summoner", SCRIPT_PARAM_ONOFF, true) 
			end
			MainMenu.cc:addParam("delay", "Removal delay (ms)", SCRIPT_PARAM_SLICE, 0, 0, 400, 0)
		MainMenu:addSubMenu("Normal Items/Smite", "nItems")		
			MainMenu.nItems:addParam("comboItems", "Use Items", SCRIPT_PARAM_ONOFF, true)
			
			MainMenu.nItems:addParam("Key", "Use While Pressed", SCRIPT_PARAM_ONKEYDOWN, false, 32)
			MainMenu.nItems:addParam("Always", "Use Always", SCRIPT_PARAM_ONOFF, false)
			MainMenu.nItems:addParam("smite", "Also use champ Smite", SCRIPT_PARAM_ONOFF, true)
			MainMenu.nItems:addParam("zhon", "Use Zhonyas/Seraphs Before Death", SCRIPT_PARAM_ONOFF, true)
			MainMenu.nItems:addParam("ItemMe", "If My Health % is Less Than", SCRIPT_PARAM_SLICE, 90, 0, 100, 0) 
			MainMenu.nItems:addParam("ItemTar", "If Target Health % is Less Than", SCRIPT_PARAM_SLICE, 90, 0, 100, 0)
			
		if ignite then
			MainMenu:addSubMenu("Ignite", "ignite")
				MainMenu.ignite:addParam("set", "Use Smart Ignite", SCRIPT_PARAM_LIST, 2, {"OFF", "Optimal", "Aggressive"})
				
		end
		if exhaust then	
			MainMenu:addSubMenu("Summoner Exhaust", "exhaust")
			MainMenu.exhaust:addParam("exh", "Exhaust Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey(exhaust.key)) 
			TSex = TargetSelector(TARGET_PRIORITY, 600, DAMAGE_MAGIC)	
			TSex.name = "EX"
		end
		if heal then
			MainMenu:addSubMenu("Summoner Heal/Barrier", "heal")
			MainMenu.heal:addParam("enable", "Use Summoner", SCRIPT_PARAM_ONOFF, true)
			MainMenu.heal:addParam("health", "If My Health % is Less Than", SCRIPT_PARAM_SLICE, 10, 0, 100, 0)
			if realheals then
				MainMenu.heal:addParam("ally", "Also use on ally", SCRIPT_PARAM_ONOFF, false)
			end
		end	
end

function findClosestAlly(obj)
    local closestAlly = nil
    local currentAlly = nil
	for i, currentAlly in pairs(sAllies) do
        if currentAlly and not currentAlly.dead then
            if closestAlly == nil then
                closestAlly = currentAlly
			end
            if GetDistanceSqr(currentAlly.pos, obj) < GetDistanceSqr(closestAlly.pos, obj) then
				closestAlly = currentAlly
            end
        end
    end
	return closestAlly
end

function OnTick()
	if exhaust and MainMenu.exhaust.exh then 
		if myHero:CanUseSpell(exhaust.slot) == 0 then
			TSex:update()
			if ValidTarget(TSex.target) and TSex.target.type == myHero.type then
				exhFunction(TSex.target) 
			end
		end
	end
	if MainMenu.nItems.zhon then
		Zhonya()
	end
	if heal then
		if ValidTarget(GetCustomTarget(), 1000) then
			if MainMenu.heal.enable and myHero:CanUseSpell(heal) == 0 then
				if myHero.level > 5 and myHero.health/myHero.maxHealth < MainMenu.heal.health/100 then
					CastSpell(heal)
				elseif  myHero.level < 6 and myHero.health/myHero.maxHealth < (MainMenu.heal.health/100)*.75 then
					CastSpell(heal)
				end
				
				if realheals and MainMenu.heal.ally then
					local ally = findClosestAlly(myHero)
					if ally and not ally.dead and GetDistance(ally) < 850 then
						if  ally.health/ally.maxHealth < MainMenu.heal.health/100 then
							CastSpell(heal)
						end
					end
				end
			end
		end
	end
	if MainMenu.nItems.comboItems and (MainMenu.nItems.Key or MainMenu.nItems.Always) then
		if myHero.health / myHero.maxHealth <=  MainMenu.nItems.ItemMe / 100 then
			local unit = GetCustomTarget()
			if ValidTarget(unit, 1000) then
				if unit.health / unit.maxHealth <=  MainMenu.nItems.ItemTar /	100 then
					UseItems(unit)
				end
			end
		end	
	end	
	if not myHero.dead then
		if (MainMenu.potion.Key or MainMenu.potion.Always) and not potionOn and not InFountain() and (myHero.health/myHero.maxHealth)*100 < MainMenu.potion.health then
			UsePotion()
		--elseif (MainMenu.potionMana.Key or MainMenu.potionMana.Always) and not potionOnMana and not InFountain() and (myHero.mana/myHero.maxMana)*100 < MainMenu.potionMana.health then
		--	UsePotionMana()
		end
	end
	
	if ignite and MainMenu.ignite.set > 1 and (myHero:CanUseSpell(ignite) == READY) then 
		AutoIgnite()
	end
end

function Zhonya()	
	local h = myHero.health/myHero.maxHealth
	if myHero.level > 5 and h < .15 then
		CastZhonya()
	elseif  myHero.level < 6 and h < .10 then
		CastZhonya()
	end
end

function checkSpecific(unit, buffname)
	if unit.buffCount then
		for i = 1, unit.buffCount do
			local buff = unit:getBuff(i)
			if buff and buff.valid and buff.name then
				if buff.name:lower():find(buffname) then
					return true
				end
			end
		end
	end
end

function CastZhonya()
	if not myHero.dead and not checkSpecific("kindredrnodeathbuff") and not checkSpecific("judicatorinter") then
		local item = CheckItem("zhonyashourglass")
		if item and myHero:CanUseSpell(item) == 0 then
			CastSpell(item) 
			return true
		end
		if GetInventoryItemIsCastable(3040) then
			CastItem(3040)
		end
	end
end

function CheckItem(ItemName)
	for i = 6, 12 do
		local item = myHero:GetSpellData(i).name
		if item and item:lower() == ItemName then
			return i
		end
	end
end

function exhFunction(unit)
	moveToCursor()
	CastSpell(exhaust.slot, unit)
end

function moveToCursor()
	local MouseMove = Vector(myHero) + (Vector(mousePos) - Vector(myHero)):normalized() * 500
	myHero:MoveTo(MouseMove.x, MouseMove.z)	
end

function OnUpdateBuff(unit, buff, stacks)
	if not unit or not buff then return end
	if unit.isMe then
		if buff.name:lower():find("regenerationpotion") or buff.name:lower():find("itemminiregenpotion") or buff.name:lower():find("crystalflask") then
			potionOn = true
		end
	end
end

function OnRemoveBuff(unit, buff)
	if not unit or not buff then return end
	if unit.isMe then
		if buff.name:lower():find("regenerationpotion") or buff.name:lower():find("itemminiregenpotion") or buff.name:lower():find("crystalflask") then
			potionOn = false
		end
	end
end

local lastPotion = 0
function UsePotion()
	if os.clock() - lastPotion < 8 then return end
	if not MainMenu.potion.enemy then
		if CountEnemiesNearUnitReg(myHero, 750) == 0 then return end
	end
	
	local slot = GetSlotItemFromName("crystalflask")
	if not slot then
		slot = GetSlotItemFromName("RegenerationPotion")
	end
	if not slot then
		slot = GetSlotItemFromName("itemminiregenpotion")
	end
	if slot then
		CastSpell(slot)
		lastPotion = os.clock()
	end
end

local lastPotionMana = 0
function UsePotionMana()
	if CountEnemiesNearUnitReg(myHero, 1000) == 0 then return end
	if os.clock() - lastPotionMana < 8 then return end
	local slot = GetSlotItemFromName("crystalflask")
	if not slot then
		slot = GetSlotItemFromName("flaskofcrystalwater")
	end
	if slot then
		CastSpell(slot)
		lastPotionMana = os.clock()
	end
end

function GetSlotItemFromName(itemname)
	local slot
	for i = 6, 12 do
		local item = myHero:GetSpellData(i).name
		if item and item:lower():find(itemname:lower()) and myHero:CanUseSpell(i) == READY then
			slot = i
		end
	end
	return slot
end

function GetSlotItem(id, unit)
	unit = unit or myHero

	if (not ItemNames[id]) then
		return ___GetInventorySlotItem(id, unit)
	end

	local name	= ItemNames[id]
	
	for slot = ITEM_1, ITEM_7 do
		local item = unit:GetSpellData(slot).name
		if item and item:lower() == name:lower() and myHero:CanUseSpell(slot) == READY then
			return slot
		end
	end
end
--[[
Buff Types
5-stun
6-stealth
7-silence
8-taunt
10-slow?? i think
10-name "fleeslow" = terrorize
11-root
12-DoT
13-healthregen
14-ms 
15-morge, dunno what else
17-zhonya, dunno what else
19-truevision, i think?
23-poisons
24-suppresion
25-blind
27-armor/mr reduction
29-knockup
30-displacement
31-disarm
]]
local lastTAttack = 0
local tDamage = 1
if AddProcessAttackCallback and heal and MainMenu.heal.enable then
	AddProcessAttackCallback(function(unit, spell) AProc(unit, spell) end)
end

function AProc(unit, spell)
	if not unit or not unit.valid or not spell then return end

	if spell.target and spell.target.type == myHero.type and spell.target.team == myHero.team and (spell.name:lower():find("_turret_chaos") or spell.name:lower():find("_turret_order")) and not (spell.name:lower():find("4") or spell.name:lower():find("3")) then
		if GetDistance(unit) < 2000 then
			if clock() - lastTAttack < 1.75 then
				if tDamage < 1.75 then
					tDamage = tDamage + 0.375
				else
					tDamage = tDamage + 0.250
					tDamage = tDamage > 2.25 and 2.25 or tDamage
				end
			else
				tDamage = 1
			end
			lastTAttack = clock()
			
			if myHero:CanUseSpell(heal) == 0 and spell.target.isMe then
				local realDamage = unit.totalDamage / (((myHero.armor * 0.7) / 100) + 1)

				if vPred:GetPredictedHealth(myHero, 0.5) + myHero.shield <= realDamage * tDamage then
					DelayAction(function()
						CastSpell(heal)
						Print("Saving from tower")
					end, 0.5)
				end
			end
		end
	end
end
function OnProcessSpell(unit, spell)
	if not unit or not unit.valid or not spell then return end
	
	if heal and MainMenu.heal.enable and myHero:CanUseSpell(heal) == 0 and spell.target and spell.target.isMe and unit.team ~= myHero.team and unit.type == myHero.type then
		if myHero.health/myHero.maxHealth <= (MainMenu.heal.health/100)*1.5 then
			CastSpell(heal)
		end
	end
	if spell.name:lower():find("zedr") and spell.target == myHero then
		DelayAction(function()
			--UseItemsCC(myHero, true)
			DelayAction(function()
				CastZhonya()
			end, 0.3)
		end, 1.7)
	end
end
function OnApplyBuff(source, unit, buff)
	if not buff or not source or not source.valid or not unit or not unit.valid then return end
	
	if unit.isMe and (MainMenu.cc.Always or MainMenu.cc.Key) then
		if (source.charName == "Rammus" and buff.type ~= 8) or source.charName == "Alistar" or source.charName:lower():find("baron") or source.charName:lower():find("spiderboss") or source.charName == "LeeSin" or (source.charName == "Hecarim" and not buff.name:lower():find("fleeslow")) then return end	
		if buff.name and ((not cleanse and buff.type == 24) or buff.type == 5 or buff.type == 11 or buff.type == 22 or buff.type == 21 or buff.type == 8)
		or (buff.type == 10 and buff.name and buff.name:lower():find("fleeslow")) then
		--or (MainMenu.cc.Exhaust and buff.name and buff.name:lower():find("summonerexhaust")) then
			if buff.name and buff.name:lower():find("caitlynyor") and CountEnemiesNearUnitReg(myHero, 700) == 0   then
				return false
			elseif not source.charName:lower():find("blitzcrank") then
				UseItemsCC(myHero, true)
			end          
		end                    
	end  
end


--[[function isCC(cleanse)
	for i = 1, myHero.buffCount, 1 do      
		local buff = myHero:getBuff(i)
		--if buff.name and buff.valid then print(buff.type.." "..buff.name)  end
		if buff.valid and buff.name and ((not cleanse and buff.type == 24) or buff.type == 5 or buff.type == 11 or buff.type == 22 or buff.type == 21 or buff.type == 8)
		or (buff.type == 10 and buff.name and buff.name:lower():find("fleeslow"))
		or (MainMenu.cc.Exhaust and buff.name and buff.name:lower():find("summonerexhaust")) then
			if buff.name and buff.name:lower():find("caitlynyor") and CountEnemiesNearUnitReg(myHero, 700) == 0   then
			else
				if not buff.name:lower():find("rocketgrab2") then
					return true
				end
			end          
		end                    
	end  
end	]]

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

function UseItemsCC(unit, scary)
	if os.clock() - lastRemove < 1 then return end
	for i, Item in pairs(Items) do
		local Item = Items[i]
		if GetInventoryItemIsCastable(Item.id) and GetDistanceSqr(unit) <= Item.range * Item.range then
			if Item.id == 3139 or Item.id ==  3140 then
				if scary then
					DelayAction(function()
						CastItem(Item.id)
					end, MainMenu.cc.delay/1000)	
					lastRemove = os.clock()
					return true
				end
			end
		end
	end
	if MainMenu.cc.Summoner and SummonerSlot and myHero:CanUseSpell(SummonerSlot) == 0 then
		DelayAction(function()
			CastSpell(SummonerSlot)
		end, MainMenu.cc.delay/1000)
		lastRemove = os.clock()
	end
end
function UseItems(unit, scary)
	if not ValidTarget(unit) and unit ~= myHero then return end
	if MainMenu.nItems.smite then
		local smiteSpell = Slot("summonersmiteduel")
		if not smiteSpell then
			smiteSpell = Slot("summonersmiteplayerganker")
		end
		if smiteSpell and myHero:CanUseSpell(smiteSpell) and GetDistance(unit) < 500 + myHero.boundingRadius + unit.boundingRadius then
			CastSpell(smiteSpell, unit)
		end
	end
	for i, Item in pairs(Items) do
		local Item = Items[i]
		if Item.id ~= 3140 and Item.id ~= 3139 then
			if GetInventoryItemIsCastable(Item.id) and GetDistanceSqr(unit) <= Item.range * Item.range then
				if Item.id == 3143 or Item.id == 3077 or Item.id == 3074 or 5000 == Item.id or Item.id == 3131 or Item.id == 3142 or Item.id == 2140 then
					CastItem(Item.id)
				--[[elseif Item.id == 3092 then
					local CastPosition, Hitchance, Position = vPred:GetLineCastPosition(unit, 0.25, 60, Item.range, 1400, myHero, true)
					if CastPosition and Hitchance >= 2 then
						CastItem(Item.id, CastPosition.x, CastPosition.z)
					end]]
				else
					CastItem(Item.id, unit) return true
				end
			end
		end
	end

	if GetDistance(unit) < 455 then
		local ite = CheckItem('itemsofboltspellbase')
		if ite then
			CastSpell(ite, mousePos.x, mousePos.z)
		end
		local ite = CheckItem('itemwillboltspellbase')
		if ite then
			CastSpell(ite, unit.x, unit.z)
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
Print("Version "..version.." loaded.") 

function HealSlot()
	if myHero:GetSpellData(SUMMONER_1).name:lower():find("summonerheal") or myHero:GetSpellData(SUMMONER_2).name:lower():find("summonerheal") then
		realheals = true
	end
	if myHero:GetSpellData(SUMMONER_1).name:lower():find("summonerheal")  or myHero:GetSpellData(SUMMONER_1).name:lower():find("summonerbar") then
		return SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:lower():find("summonerheal") or myHero:GetSpellData(SUMMONER_2).name:lower():find("summonerbar") then
		return SUMMONER_2
	end
end

function AutoIgnite()
	local IgniteDmg = 50 + (20 * myHero.level)
	local aggro = MainMenu.ignite.set == 3 and 0.05 or 0
	for i, enemy in pairs(sEnemies) do
		if ValidTarget(enemy, 600) then
			local spellDamage = 0
			local adDamage = myHero:CalcDamage(enemy, myHero.totalDamage)
			spellDamage = spellDamage + adDamage
			if myHero.health < myHero.maxHealth*(0.35+aggro) and enemy.health < enemy.maxHealth*(0.34+aggro)  and GetDistanceSqr(enemy) < 420 * 420 then
				CastSpell(ignite, enemy)							
				if Debug then
					print("It's time to DDDDDDDUEL")
				end
			end
			local r = myHero.range+65
			local trange = r < 575 and r or 575
			if isFleeingFromMe(enemy, trange) then
				if enemy.health < IgniteDmg + spellDamage  + 10 then		
					if myHero.ms < enemy.ms then
						CastSpell(ignite, enemy)	
						if Debug then
							print("We Got a Runner!")
						end	
					else
						if Debug then
							print("not doing runner you can chase them down.")
						end
					end
				end	
			end
			if (GetDistanceSqr(enemy) > 160000 and (myHero.health+myHero.shield) < myHero.maxHealth*0.3) then 
				if enemy.health > spellDamage-(500*aggro) and enemy.health < IgniteDmg + spellDamage-(500*aggro)  then
					CastSpell(ignite, enemy)							
					if Debug then
						print("ignite Q")
					end
				end
			end
		end
	end
end
function CountAlliesNearUnit(unit, range)
	local count = 0
	for i, ally in pairs(sAllies) do
		if GetDistanceSqr(ally, unit) <= range * range and not ally.dead then count = count + 1 end
	end
	return count
end

function isFleeingFromMe(target, range)
	local pos = vPred:GetPredictedPos(target, 0.26)
	
	if pos and GetDistanceSqr(pos) > range*range then
		return true
	end
	return false
end
function amIFleeing(target, range)
	local pos = vPred:GetPredictedPos(myHero, 0.26)
	
	if pos and GetDistanceSqr(pos, target) > range*range then
		return true
	end
	return false
end

class "SIUsage_Update"
function SIUsage_Update:__init(LocalVersion,UseHttps, Host, VersionPath, ScriptPath, SavePath, CallbackUpdate, CallbackNoUpdate, CallbackNewVersion,CallbackError)
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

function SIUsage_Update:print(str)
    print('<font color="#FFFFFF">'..os.clock()..': '..str)
end

function SIUsage_Update:OnDraw()
    if self.DownloadStatus ~= 'Downloading Script (100%)' and self.DownloadStatus ~= 'Downloading VersionInfo (100%)'then
        DrawText('Download Status: '..(self.DownloadStatus or 'Unknown'),50,10,50,ARGB(0xFF,0xFF,0xFF,0xFF))
    end
end

function SIUsage_Update:CreateSocket(url)
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

function SIUsage_Update:Base64Encode(data)
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

function SIUsage_Update:GetOnlineVersion()
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

function SIUsage_Update:DownloadUpdate()
    if self.GotSIUsage_Update then return end
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
        self.GotSIUsage_Update = true
    end
end