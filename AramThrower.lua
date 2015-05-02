require 'VPrediction'

lastCast = 0
function OnLoad()
	PrintChat("<font color=\"#FFFFFF\">Aram Thrower Helper Version Four Loaded ")
	ARAM = ARAMSlot()
	ARAMMenu = scriptConfig("ARAM Menu", "ARAM")
	ARAMMenu:addParam("comboKey", "Shoot", SCRIPT_PARAM_ONKEYDOWN, false, 32) 
	ARAMMenu:addParam("range", "Cast Range", SCRIPT_PARAM_SLICE, 1400, 800, 2500, 0) 
	TargetSelector = TargetSelector(TARGET_CLOSEST, 2500, DAMAGE_PHYSICAL)
	ARAMMenu:addTS(TargetSelector)
	vPred = VPrediction()
end

function OnTick()
	Target = getTarget()
	if ARAM and (myHero:CanUseSpell(ARAM) == READY) then 
		ARAMRdy = true
	else
		ARAMRdy = false
	end
	if ARAMMenu.comboKey then
		shootARAM(Target)
	end
end
--[[function OnApplyBuff(source, unit, buff)
	if source == myHero then
		if buff.name == "snowballfollowup" then
			snower = unit
		end
	end
end
function OnRemoveBuff(unit, buff)
	if unit == snower and buff.name == "snowballfollowup" then
		snower = nil
	end
end]]
function OnDraw()
	if not myHero.dead then
		DrawCircle3D(myHero.x, myHero.y, myHero.z, ARAMMenu.range, 2, ARGB(100, 0, 0, 255))
	end
	--if snower then
	--	DrawText3D("ARAM Target Hit!", snower.x +95, snower.y + 200, snower.z+103, 40, RGB(255, 69, 111), true)
	--end
	if hit() then
		DrawText3D("ARAM Target Hit!", myHero.x +95, myHero.y + 305, myHero.z+33, 40, RGB(255, 69, 111), true)
	end
end
function getTarget()
	TargetSelector:update()	
	if TargetSelector.target and not TargetSelector.target.dead and TargetSelector.target.type == myHero.type then
		return TargetSelector.target
	else
		return nil
	end
end

function ARAMSlot()
	if myHero:GetSpellData(SUMMONER_1).name:find("summonersnowball") then
		return SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("summonersnowball") then
		return SUMMONER_2
	else
		return nil
	end
end

function hit()
	if myHero:GetSpellData(SUMMONER_1).name:find("snowballfollowupcast") then
		return true
	elseif myHero:GetSpellData(SUMMONER_2).name:find("snowballfollowupcast") then
		return true
	else
		return false
	end
end

function shootARAM(unit)
	if lastCast > os.clock() - 10 then return end
	
	if  ValidTarget(unit, ARAMMenu.range + 50) and ARAMRdy then
		local CastPosition, Hitchance, Position = vPred:GetLineCastPosition(Target, .25, 75, ARAMMenu.range, 1200, myHero, true)
		if CastPosition and Hitchance >= 2 then
			d = CastPosition
			CastSpell(ARAM, CastPosition.x, CastPosition.z)
			lastCast = os.clock()
		end
	end
end