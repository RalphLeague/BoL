--Version 0.11
--Library for Machine Series by Ralphlol

class 'MachineLib'
function MachineLib:__init()
	self.version = 0.11
	
	self.lolPatch = GetGameVersion and GetGameVersion():sub(1,3) == "6.2" and 1 or 2
	self.notPresentPatch = GetGameVersion and GetGameVersion():sub(1,3) ~= "6.1" and GetGameVersion():sub(1,3) ~= "6.2"
	self.cn = self.notPresentPatch  
	self.moveHeader = self.lolPatch == 1 and 137 or 197
	self.spellHeader = self.lolPatch == 1 and 299 or 126
	
	self:Level()
end

function MachineLib:SkinChange(what)
	if self.cn then return end
	
	if self.lolPatch == 1 then
		if SetSkin then
			local skinPB = what - 2
			SetSkin(myHero, skinPB)
		end
	else
		if SetSkin then
			local skinPB = what - 2
			SetSkin(myHero, skinPB)
		end
	end
end

local lvlspell2 = _G.LevelSpell
function MachineLib:Level(id)
	_G.LevelSpell = function(id)
		if self.cn then return end
		
		if self.lolPatch == 1 then
			lvlspell2(id)
		else
			 local offsets = { 
				[_Q] = 0x71,
				[_W] = 0xF1,
				[_E] = 0x31,
				[_R] = 0xB1,
			  }
			  local p = CLoLPacket(0x00DB)
			  p.vTable = 0xF6D830
			  p:EncodeF(myHero.networkID)
			  for i = 1, 4 do p:Encode1(0x30) end
			  p:Encode1(0x17)
			  for i = 1, 4 do p:Encode1(0x81) end
			  for i = 1, 4 do p:Encode1(0x6A) end
			  p:Encode1(offsets[id])
			  for i = 1, 4 do p:Encode1(0x00) end
			  SendPacket(p)
		end
	end
end
