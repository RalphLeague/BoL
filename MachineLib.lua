--Library for Machine Series by Ralphlol

class 'MachineLib'
function MachineLib:__init()
	self.version = 708
	
	self.lolPatch = GetGameVersion and GetGameVersion():sub(1,3) == "7.8" and 1 or 2
	self.notPresentPatch = GetGameVersion and GetGameVersion():sub(1,3) ~= "7.7" and GetGameVersion():sub(1,3) ~= "7.8"
	self.cn = self.notPresentPatch
	
	--Send--
		self.moveHeader = self.lolPatch == 1 and 312 or 43
		self.spellHeader = self.lolPatch == 1 and 156 or 127
		
		--cspell2
		self.cspell2Header = self.lolPatch == 1 and 57 or 287
		self.cspell2Pos = self.lolPatch == 1 and 6 or 6
		self.cspell2Byte = self.lolPatch == 1 and 0x42 or 0x42 
	
	--Rsv--
		self.goldHeader = self.lolPatch == 1 and 34 or 11
		
		--Buy
		self.bHeader = self.lolPatch == 1 and 52 or 0x46
		self.bPos = self.lolPatch == 1 and 14 or 19
		self.botrk = self.lolPatch == 1 and 202 or 212
		self.IE = self.lolPatch == 1 and 247 or 171
		self.Trinity = self.lolPatch == 1 and 125 or 206
	
		--Recall
		self.recallHeader = self.lolPatch == 1 and 43 or 333
		self.recallPos1 = self.lolPatch == 1 and 6 or 80 --id
		self.recallPos2 = self.lolPatch == 1 and  35 or 56
	
	local IDBytes = {	
	[1] =
		{[0x00] = 0x06, [0x01] = 0x0E, [0x02] = 0x07, [0x03] = 0x0F, [0x04] = 0x26, [0x05] = 0x2E, [0x06] = 0x27, [0x07] = 0x2F, [0x08] = 0x02, [0x09] = 0x0A, [0x0A] = 0x03, [0x0B] = 0x0B, [0x0C] = 0x22, [0x0D] = 0x2A, [0x0E] = 0x23, [0x0F] = 0x2B, [0x10] = 0x86, [0x11] = 0x8E, [0x12] = 0x87, [0x13] = 0x8F, [0x14] = 0xA6, [0x15] = 0xAE, [0x16] = 0xA7, [0x17] = 0xAF, [0x18] = 0x82, [0x19] = 0x8A, [0x1A] = 0x83, [0x1B] = 0x8B, [0x1C] = 0xA2, [0x1D] = 0xAA, [0x1E] = 0xA3, [0x1F] = 0xAB, [0x20] = 0x16, [0x21] = 0x1E, [0x22] = 0x17, [0x23] = 0x1F, [0x24] = 0x36, [0x25] = 0x3E, [0x26] = 0x37, [0x27] = 0x3F, [0x28] = 0x12, [0x29] = 0x1A, [0x2A] = 0x13, [0x2B] = 0x1B, [0x2C] = 0x32, [0x2D] = 0x3A, [0x2E] = 0x33, [0x2F] = 0x3B, [0x30] = 0x96, [0x31] = 0x9E, [0x32] = 0x97, [0x33] = 0x9F, [0x34] = 0xB6, [0x35] = 0xBE, [0x36] = 0xB7, [0x37] = 0xBF, [0x38] = 0x92, [0x39] = 0x9A, [0x3A] = 0x93, [0x3B] = 0x9B, [0x3C] = 0xB2, [0x3D] = 0xBA, [0x3E] = 0xB3, [0x3F] = 0xBB, [0x40] = 0x04, [0x41] = 0x0C, [0x42] = 0x05, [0x43] = 0x0D, [0x44] = 0x24, [0x45] = 0x2C, [0x46] = 0x25, [0x47] = 0x2D, [0x48] = 0x00, [0x49] = 0x08, [0x4A] = 0x01, [0x4B] = 0x09, [0x4C] = 0x20, [0x4D] = 0x28, [0x4E] = 0x21, [0x4F] = 0x29, [0x50] = 0x84, [0x51] = 0x8C, [0x52] = 0x85, [0x53] = 0x8D, [0x54] = 0xA4, [0x55] = 0xAC, [0x56] = 0xA5, [0x57] = 0xAD, [0x58] = 0x80, [0x59] = 0x88, [0x5A] = 0x81, [0x5B] = 0x89, [0x5C] = 0xA0, [0x5D] = 0xA8, [0x5E] = 0xA1, [0x5F] = 0xA9, [0x60] = 0x14, [0x61] = 0x1C, [0x62] = 0x15, [0x63] = 0x1D, [0x64] = 0x34, [0x65] = 0x3C, [0x66] = 0x35, [0x67] = 0x3D, [0x68] = 0x10, [0x69] = 0x18, [0x6A] = 0x11, [0x6B] = 0x19, [0x6C] = 0x30, [0x6D] = 0x38, [0x6E] = 0x31, [0x6F] = 0x39, [0x70] = 0x94, [0x71] = 0x9C, [0x72] = 0x95, [0x73] = 0x9D, [0x74] = 0xB4, [0x75] = 0xBC, [0x76] = 0xB5, [0x77] = 0xBD, [0x78] = 0x90, [0x79] = 0x98, [0x7A] = 0x91, [0x7B] = 0x99, [0x7C] = 0xB0, [0x7D] = 0xB8, [0x7E] = 0xB1, [0x7F] = 0xB9, [0x80] = 0x46, [0x81] = 0x4E, [0x82] = 0x47, [0x83] = 0x4F, [0x84] = 0x66, [0x85] = 0x6E, [0x86] = 0x67, [0x87] = 0x6F, [0x88] = 0x42, [0x89] = 0x4A, [0x8A] = 0x43, [0x8B] = 0x4B, [0x8C] = 0x62, [0x8D] = 0x6A, [0x8E] = 0x63, [0x8F] = 0x6B, [0x90] = 0xC6, [0x91] = 0xCE, [0x92] = 0xC7, [0x93] = 0xCF, [0x94] = 0xE6, [0x95] = 0xEE, [0x96] = 0xE7, [0x97] = 0xEF, [0x98] = 0xC2, [0x99] = 0xCA, [0x9A] = 0xC3, [0x9B] = 0xCB, [0x9C] = 0xE2, [0x9D] = 0xEA, [0x9E] = 0xE3, [0x9F] = 0xEB, [0xA0] = 0x56, [0xA1] = 0x5E, [0xA2] = 0x57, [0xA3] = 0x5F, [0xA4] = 0x76, [0xA5] = 0x7E, [0xA6] = 0x77, [0xA7] = 0x7F, [0xA8] = 0x52, [0xA9] = 0x5A, [0xAA] = 0x53, [0xAB] = 0x5B, [0xAC] = 0x72, [0xAD] = 0x7A, [0xAE] = 0x73, [0xAF] = 0x7B, [0xB0] = 0xD6, [0xB1] = 0xDE, [0xB2] = 0xD7, [0xB3] = 0xDF, [0xB4] = 0xF6, [0xB5] = 0xFE, [0xB6] = 0xF7, [0xB7] = 0xFF, [0xB8] = 0xD2, [0xB9] = 0xDA, [0xBA] = 0xD3, [0xBB] = 0xDB, [0xBC] = 0xF2, [0xBD] = 0xFA, [0xBE] = 0xF3, [0xBF] = 0xFB, [0xC0] = 0x44, [0xC1] = 0x4C, [0xC2] = 0x45, [0xC3] = 0x4D, [0xC4] = 0x64, [0xC5] = 0x6C, [0xC6] = 0x65, [0xC7] = 0x6D, [0xC8] = 0x40, [0xC9] = 0x48, [0xCA] = 0x41, [0xCB] = 0x49, [0xCC] = 0x60, [0xCD] = 0x68, [0xCE] = 0x61, [0xCF] = 0x69, [0xD0] = 0xC4, [0xD1] = 0xCC, [0xD2] = 0xC5, [0xD3] = 0xCD, [0xD4] = 0xE4, [0xD5] = 0xEC, [0xD6] = 0xE5, [0xD7] = 0xED, [0xD8] = 0xC0, [0xD9] = 0xC8, [0xDA] = 0xC1, [0xDB] = 0xC9, [0xDC] = 0xE0, [0xDD] = 0xE8, [0xDE] = 0xE1, [0xDF] = 0xE9, [0xE0] = 0x54, [0xE1] = 0x5C, [0xE2] = 0x55, [0xE3] = 0x5D, [0xE4] = 0x74, [0xE5] = 0x7C, [0xE6] = 0x75, [0xE7] = 0x7D, [0xE8] = 0x50, [0xE9] = 0x58, [0xEA] = 0x51, [0xEB] = 0x59, [0xEC] = 0x70, [0xED] = 0x78, [0xEE] = 0x71, [0xEF] = 0x79, [0xF0] = 0xD4, [0xF1] = 0xDC, [0xF2] = 0xD5, [0xF3] = 0xDD, [0xF4] = 0xF4, [0xF5] = 0xFC, [0xF6] = 0xF5, [0xF7] = 0xFD, [0xF8] = 0xD0, [0xF9] = 0xD8, [0xFA] = 0xD1, [0xFB] = 0xD9, [0xFC] = 0xF0, [0xFD] = 0xF8, [0xFE] = 0xF1, [0xFF] = 0xF9, }
	,[2] =
		{[0x00] = 0x06, [0x01] = 0x0E, [0x02] = 0x07, [0x03] = 0x0F, [0x04] = 0x26, [0x05] = 0x2E, [0x06] = 0x27, [0x07] = 0x2F, [0x08] = 0x02, [0x09] = 0x0A, [0x0A] = 0x03, [0x0B] = 0x0B, [0x0C] = 0x22, [0x0D] = 0x2A, [0x0E] = 0x23, [0x0F] = 0x2B, [0x10] = 0x86, [0x11] = 0x8E, [0x12] = 0x87, [0x13] = 0x8F, [0x14] = 0xA6, [0x15] = 0xAE, [0x16] = 0xA7, [0x17] = 0xAF, [0x18] = 0x82, [0x19] = 0x8A, [0x1A] = 0x83, [0x1B] = 0x8B, [0x1C] = 0xA2, [0x1D] = 0xAA, [0x1E] = 0xA3, [0x1F] = 0xAB, [0x20] = 0x16, [0x21] = 0x1E, [0x22] = 0x17, [0x23] = 0x1F, [0x24] = 0x36, [0x25] = 0x3E, [0x26] = 0x37, [0x27] = 0x3F, [0x28] = 0x12, [0x29] = 0x1A, [0x2A] = 0x13, [0x2B] = 0x1B, [0x2C] = 0x32, [0x2D] = 0x3A, [0x2E] = 0x33, [0x2F] = 0x3B, [0x30] = 0x96, [0x31] = 0x9E, [0x32] = 0x97, [0x33] = 0x9F, [0x34] = 0xB6, [0x35] = 0xBE, [0x36] = 0xB7, [0x37] = 0xBF, [0x38] = 0x92, [0x39] = 0x9A, [0x3A] = 0x93, [0x3B] = 0x9B, [0x3C] = 0xB2, [0x3D] = 0xBA, [0x3E] = 0xB3, [0x3F] = 0xBB, [0x40] = 0x04, [0x41] = 0x0C, [0x42] = 0x05, [0x43] = 0x0D, [0x44] = 0x24, [0x45] = 0x2C, [0x46] = 0x25, [0x47] = 0x2D, [0x48] = 0x00, [0x49] = 0x08, [0x4A] = 0x01, [0x4B] = 0x09, [0x4C] = 0x20, [0x4D] = 0x28, [0x4E] = 0x21, [0x4F] = 0x29, [0x50] = 0x84, [0x51] = 0x8C, [0x52] = 0x85, [0x53] = 0x8D, [0x54] = 0xA4, [0x55] = 0xAC, [0x56] = 0xA5, [0x57] = 0xAD, [0x58] = 0x80, [0x59] = 0x88, [0x5A] = 0x81, [0x5B] = 0x89, [0x5C] = 0xA0, [0x5D] = 0xA8, [0x5E] = 0xA1, [0x5F] = 0xA9, [0x60] = 0x14, [0x61] = 0x1C, [0x62] = 0x15, [0x63] = 0x1D, [0x64] = 0x34, [0x65] = 0x3C, [0x66] = 0x35, [0x67] = 0x3D, [0x68] = 0x10, [0x69] = 0x18, [0x6A] = 0x11, [0x6B] = 0x19, [0x6C] = 0x30, [0x6D] = 0x38, [0x6E] = 0x31, [0x6F] = 0x39, [0x70] = 0x94, [0x71] = 0x9C, [0x72] = 0x95, [0x73] = 0x9D, [0x74] = 0xB4, [0x75] = 0xBC, [0x76] = 0xB5, [0x77] = 0xBD, [0x78] = 0x90, [0x79] = 0x98, [0x7A] = 0x91, [0x7B] = 0x99, [0x7C] = 0xB0, [0x7D] = 0xB8, [0x7E] = 0xB1, [0x7F] = 0xB9, [0x80] = 0x46, [0x81] = 0x4E, [0x82] = 0x47, [0x83] = 0x4F, [0x84] = 0x66, [0x85] = 0x6E, [0x86] = 0x67, [0x87] = 0x6F, [0x88] = 0x42, [0x89] = 0x4A, [0x8A] = 0x43, [0x8B] = 0x4B, [0x8C] = 0x62, [0x8D] = 0x6A, [0x8E] = 0x63, [0x8F] = 0x6B, [0x90] = 0xC6, [0x91] = 0xCE, [0x92] = 0xC7, [0x93] = 0xCF, [0x94] = 0xE6, [0x95] = 0xEE, [0x96] = 0xE7, [0x97] = 0xEF, [0x98] = 0xC2, [0x99] = 0xCA, [0x9A] = 0xC3, [0x9B] = 0xCB, [0x9C] = 0xE2, [0x9D] = 0xEA, [0x9E] = 0xE3, [0x9F] = 0xEB, [0xA0] = 0x56, [0xA1] = 0x5E, [0xA2] = 0x57, [0xA3] = 0x5F, [0xA4] = 0x76, [0xA5] = 0x7E, [0xA6] = 0x77, [0xA7] = 0x7F, [0xA8] = 0x52, [0xA9] = 0x5A, [0xAA] = 0x53, [0xAB] = 0x5B, [0xAC] = 0x72, [0xAD] = 0x7A, [0xAE] = 0x73, [0xAF] = 0x7B, [0xB0] = 0xD6, [0xB1] = 0xDE, [0xB2] = 0xD7, [0xB3] = 0xDF, [0xB4] = 0xF6, [0xB5] = 0xFE, [0xB6] = 0xF7, [0xB7] = 0xFF, [0xB8] = 0xD2, [0xB9] = 0xDA, [0xBA] = 0xD3, [0xBB] = 0xDB, [0xBC] = 0xF2, [0xBD] = 0xFA, [0xBE] = 0xF3, [0xBF] = 0xFB, [0xC0] = 0x44, [0xC1] = 0x4C, [0xC2] = 0x45, [0xC3] = 0x4D, [0xC4] = 0x64, [0xC5] = 0x6C, [0xC6] = 0x65, [0xC7] = 0x6D, [0xC8] = 0x40, [0xC9] = 0x48, [0xCA] = 0x41, [0xCB] = 0x49, [0xCC] = 0x60, [0xCD] = 0x68, [0xCE] = 0x61, [0xCF] = 0x69, [0xD0] = 0xC4, [0xD1] = 0xCC, [0xD2] = 0xC5, [0xD3] = 0xCD, [0xD4] = 0xE4, [0xD5] = 0xEC, [0xD6] = 0xE5, [0xD7] = 0xED, [0xD8] = 0xC0, [0xD9] = 0xC8, [0xDA] = 0xC1, [0xDB] = 0xC9, [0xDC] = 0xE0, [0xDD] = 0xE8, [0xDE] = 0xE1, [0xDF] = 0xE9, [0xE0] = 0x54, [0xE1] = 0x5C, [0xE2] = 0x55, [0xE3] = 0x5D, [0xE4] = 0x74, [0xE5] = 0x7C, [0xE6] = 0x75, [0xE7] = 0x7D, [0xE8] = 0x50, [0xE9] = 0x58, [0xEA] = 0x51, [0xEB] = 0x59, [0xEC] = 0x70, [0xED] = 0x78, [0xEE] = 0x71, [0xEF] = 0x79, [0xF0] = 0xD4, [0xF1] = 0xDC, [0xF2] = 0xD5, [0xF3] = 0xDD, [0xF4] = 0xF4, [0xF5] = 0xFC, [0xF6] = 0xF5, [0xF7] = 0xFD, [0xF8] = 0xD0, [0xF9] = 0xD8, [0xFA] = 0xD1, [0xFB] = 0xD9, [0xFC] = 0xF0, [0xFD] = 0xF8, [0xFE] = 0xF1, [0xFF] = 0xF9, }
	}
	
	local rBytes = {	
	[1] =
		{[0x5A] = 0x00,[0xDB] = 0x40,[0x6C] = 0x00,[0xBB] = 0x40,[0xC4] = 0x23,[0x2A] = 0x1D,[0x40] = 0x1E,[0xBF] = 0x1D, [0x89] = 0x1F,[0x06] = 0x20,[0xE2] = 0x1F}	
	,[2] =
		{[0x6C] = 0x00,[0xBB] = 0x40,[0xBF] = 0x1D,[0x72] = 0x21,[0xC3] = 0x1E,[0xE2] = 0x1F,[0x27] = 0x26,[0xD4] = 0x20, [0x47] = 0x22,[0x16] = 0x24,[0x7B] = 0x23}
	}
	
	self.rBytes = rBytes[self.lolPatch]
	self.IDBytes = IDBytes[self.lolPatch]
	
	self:Level()
end

function MachineLib:SkinChange(what)
	if self.cn or not SetSkin then return end

	if self.lolPatch == 1 then
		local skinPB = what - 2
		SetSkin(myHero, skinPB)
	else
		local skinPB = what - 2
		SetSkin(myHero, skinPB)
	end
end

local lvlspell2 = _G.LevelSpell
function MachineLib:Level(id)
	_G.LevelSpell = function(id)
		if self.cn then return end
		
		if self.lolPatch == 1 then
			lvlspell2(id)
		else
			lvlspell2(id)
		end
	end
end

function MachineLib:UserID()
	local id = "%d+"
	local userid = GetCommandLine():reverse():sub(2, GetCommandLine():reverse():find(" ==")):reverse()
	return string.sub(userid, string.find(userid, id))
end