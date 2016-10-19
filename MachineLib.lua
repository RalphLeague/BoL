--Library for Machine Series by Ralphlol

class 'MachineLib'
function MachineLib:__init()
	self.version = 621
	
	self.lolPatch = GetGameVersion and GetGameVersion():sub(1,4) == "6.21" and 1 or 2
	self.notPresentPatch = GetGameVersion and GetGameVersion():sub(1,4) ~= "6.20" and GetGameVersion():sub(1,4) ~= "6.21"
	self.cn = self.notPresentPatch
	
	--Send--
		self.moveHeader = self.lolPatch == 1 and 16 or 16
		self.spellHeader = self.lolPatch == 1 and 246 or 246
		
		--cspell2
		self.cspell2Header = self.lolPatch == 1 and 363 or 363
		self.cspell2Pos = self.lolPatch == 1 and 11 or 11
		self.cspell2Byte = self.lolPatch == 1 and 0x40 or 0x40
	
	--Rsv--
		self.goldHeader = self.lolPatch == 1 and 166 or 166
		
		--Buy
		self.bHeader = self.lolPatch == 1 and 369 or 369
		self.bPos = self.lolPatch == 1 and 13 or 13
		self.botrk = self.lolPatch == 1 and 98 or 98
		self.IE = self.lolPatch == 1 and 202 or 202
		self.Trinity = self.lolPatch == 1 and 249 or 249
	
		--Recall
		self.recallHeader = self.lolPatch == 1 and 101 or 101
		self.recallPos1 = self.lolPatch == 1 and 31 or 31 --id
		self.recallPos2 = self.lolPatch == 1 and  60 or 60
	
	local IDBytes = {	
	[1] =--6.21
		{[0x00] = 0xD6, [0x01] = 0xE6, [0x02] = 0x3D, [0x03] = 0xC8, [0x04] = 0x23, [0x05] = 0x03, [0x06] = 0x25, [0x07] = 0x7E, [0x08] = 0x7A, [0x09] = 0x0B, [0x0A] = 0x7D, [0x0B] = 0xBC, [0x0C] = 0xBF, [0x0D] = 0x38, [0x0E] = 0x3C, [0x0F] = 0xB4, [0x10] = 0xD1, [0x11] = 0x26, [0x12] = 0xA1, [0x13] = 0xFC, [0x14] = 0x1B, [0x15] = 0xD7, [0x16] = 0xB5, [0x17] = 0x87, [0x18] = 0xED, [0x19] = 0xB3, [0x1A] = 0xA4, [0x1B] = 0x6A, [0x1C] = 0xF0, [0x1D] = 0xF7, [0x1E] = 0x17, [0x1F] = 0xAF, [0x20] = 0xE0, [0x21] = 0x3A, [0x22] = 0x4F, [0x23] = 0x5F, [0x24] = 0x69, [0x25] = 0x2F, [0x26] = 0xE4, [0x27] = 0xA5, [0x28] = 0xDC, [0x29] = 0xBA, [0x2A] = 0xFD, [0x2B] = 0xBD, [0x2C] = 0x6B, [0x2D] = 0xF4, [0x2E] = 0xE1, [0x2F] = 0x41, [0x30] = 0xF1, [0x31] = 0xD5, [0x32] = 0x05, [0x33] = 0xCA, [0x34] = 0x3B, [0x35] = 0xF8, [0x36] = 0x40,[0x37] = 0x18, [0x38] = 0x74, [0x39] = 0x71, [0x3A] = 0xD4, [0x3B] = 0xA3, [0x3C] = 0x8C, [0x3D] = 0x72, [0x3E] = 0x0D, [0x3F] = 0xFA, [0x40] = 0xC1, [0x41] = 0x88, [0x42] = 0x1F, [0x43] = 0x49, [0x44] = 0x92, [0x45] = 0xA7, [0x46] = 0x73, [0x47] = 0xBE, [0x48] = 0x48, [0x49] = 0x91, [0x4A] = 0xE7, [0x4B] = 0x8F, [0x4C] = 0x30, [0x4D] = 0xEC, [0x4E] = 0x27, [0x4F] = 0xF9, [0x50] = 0xB9, [0x51] = 0x0C, [0x52] = 0x39, [0x53] = 0x36, [0x54] = 0x44, [0x55] = 0x10, [0x56] = 0x5A, [0x57] = 0xC0, [0x58] = 0xE5, [0x59] = 0x00, [0x5A] = 0x12, [0x5B] = 0xC9, [0x5C] = 0x63, [0x5D] = 0x1E, [0x5E] = 0x59, [0x5F] = 0x4B, [0x60] = 0x28, [0x61] = 0x6C, [0x62] = 0x47, [0x63] = 0x9B, [0x64] = 0xB8, [0x65] = 0x80, [0x66] = 0xDE, [0x67] = 0x16, [0x68] = 0x02, [0x69] = 0xC3, [0x6A] = 0x98, [0x6B] = 0x9D, [0x6C] = 0x50, [0x6D] = 0x97, [0x6E] = 0x11, [0x6F] = 0x37, [0x70] = 0x54, [0x71] = 0x58, [0x72] = 0x1C, [0x73] = 0x76, [0x74] = 0xCD, [0x75] = 0xA8, [0x76] = 0x96, [0x77] = 0x2A, [0x78] = 0x46, [0x79] = 0xD8, [0x7A] = 0xFE, [0x7B] = 0x8A, [0x7C] = 0x2D, [0x7D] = 0x61, [0x7E] = 0x24, [0x7F] = 0x08, [0x80] = 0x90, [0x81] = 0x29, [0x82] = 0x3F, [0x83] = 0xA2, [0x84] = 0xB0, [0x85] = 0xF6, [0x86] = 0xA0, [0x87] = 0xF3, [0x88] = 0x52, [0x89] = 0x5E, [0x8A] = 0xF2, [0x8B] = 0x8B, [0x8C] = 0xFF, [0x8D] = 0x6D, [0x8E] = 0x75, [0x8F] = 0x4E, [0x90] = 0x86, [0x91] = 0xAA, [0x92] = 0x66, [0x93] = 0x4D, [0x94] = 0x2B, [0x95] = 0x9C, [0x96] = 0x57, [0x97] = 0x0A, [0x98] = 0xAC, [0x99] = 0x7C, [0x9A] = 0x33, [0x9B] = 0x09, [0x9C] = 0x42, [0x9D] = 0x5B, [0x9E] = 0xD0, [0x9F] = 0x8E, [0xA0] = 0x06, [0xA1] = 0x45, [0xA2] = 0x78, [0xA3] = 0x7B, [0xA4] = 0x5C, [0xA5] = 0xD9, [0xA6] = 0x20, [0xA7] = 0x13, [0xA8] = 0xB7, [0xA9] = 0x1A, [0xAA] = 0xE8, [0xAB] = 0x81, [0xAC] = 0x14, [0xAD] = 0x7F, [0xAE] = 0x5D, [0xAF] = 0xEB, [0xB0] = 0x01, [0xB1] = 0x21, [0xB2] = 0xA6, [0xB3] = 0xC4, [0xB4] = 0xAD, [0xB5] = 0xBB, [0xB6] = 0x22, [0xB7] = 0x82, [0xB8] = 0xAB, [0xB9] = 0xDA, [0xBA] = 0xDD, [0xBB] = 0xCE, [0xBC] = 0xE9, [0xBD] = 0x07, [0xBE] = 0xF5, [0xBF] = 0x56, [0xC0] = 0x99, [0xC1] = 0x84, [0xC2] = 0x8D, [0xC3] = 0x9F, [0xC4] = 0x43, [0xC5] = 0x0F, [0xC6] = 0xEE, [0xC7] = 0x2C, [0xC8] = 0xC5, [0xC9] = 0x04, [0xCA] = 0x68, [0xCB] = 0x4A, [0xCC] = 0xA9, [0xCD] = 0xE3, [0xCE] = 0xEA, [0xCF] = 0x32, [0xD0] = 0x93, [0xD1] = 0x6E, [0xD2] = 0x9E, [0xD3] = 0x1D, [0xD4] = 0x77, [0xD5] = 0x89, [0xD6] = 0x19, [0xD7] = 0xFB, [0xD8] = 0x94, [0xD9] = 0x67, [0xDA] = 0x95, [0xDB] = 0x83, [0xDC] = 0x3E, [0xDD] = 0x51, [0xDE] = 0xDF, [0xDF] = 0x9A, [0xE0] = 0x0E, [0xE1] = 0xCB, [0xE2] = 0x55, [0xE3] = 0x62, [0xE4] = 0xDB, [0xE5] = 0xB1, [0xE6] = 0x35, [0xE7] = 0xC7, [0xE8] = 0xD3, [0xE9] = 0xEF, [0xEA] = 0x85, [0xEB] = 0x53, [0xEC] = 0x64, [0xED] = 0x79, [0xEE] = 0x15, [0xEF] = 0x2E, [0xF0] = 0x60, [0xF1] = 0x4C, [0xF2] = 0xC2, [0xF3] = 0xD2, [0xF4] = 0x6F, [0xF5] = 0xB2, [0xF6] = 0xCF, [0xF7] = 0xCC, [0xF8] = 0x31, [0xF9] = 0xB6, [0xFA] = 0x34, [0xFB] = 0xE2, [0xFC] = 0x70, [0xFD] = 0xC6, [0xFE] = 0x65, [0xFF] = 0xAE, }
	,[2] =--6.20
		{[0x00] = 0x42, [0x01] = 0x54, [0x02] = 0x66, [0x03] = 0x5D, [0x04] = 0x6E, [0x05] = 0x51, [0x06] = 0xB2, [0x07] = 0x2A, [0x08] = 0x6C, [0x09] = 0xA0, [0x0A] = 0x11, [0x0B] = 0x43, [0x0C] = 0x4B, [0x0D] = 0xF8, [0x0E] = 0x64, [0x0F] = 0xBC, [0x10] = 0x27, [0x11] = 0xE2, [0x12] = 0x14, [0x13] = 0x16, [0x14] = 0x99, [0x15] = 0x0F, [0x16] = 0x80, [0x17] = 0xEC, [0x18] = 0x17, [0x19] = 0x31, [0x1A] = 0x58, [0x1B] = 0x3D, [0x1C] = 0x8F, [0x1D] = 0x35, [0x1E] = 0x55, [0x1F] = 0xF0, [0x20] = 0x12, [0x21] = 0x6D, [0x22] = 0x84, [0x23] = 0xD4, [0x24] = 0x1D, [0x25] = 0xB4, [0x26] = 0x05, [0x27] = 0xD8, [0x28] = 0xD5, [0x29] = 0xE3, [0x2A] = 0xFC, [0x2B] = 0x0C, [0x2C] = 0x0A, [0x2D] = 0xC3, [0x2E] = 0x32, [0x2F] = 0x6B, [0x30] = 0x53, [0x31] = 0x2B, [0x32] = 0x36, [0x33] = 0xBE, [0x34] = 0x25, [0x35] = 0x33, [0x36] = 0xD1, [0x37] = 0x92, [0x38] = 0xEA, [0x39] = 0x44, [0x3A] = 0xAF, [0x3B] = 0xCE, [0x3C] = 0x76, [0x3D] = 0x3F, [0x3E] = 0x13, [0x3F] = 0x89, [0x40] = 0x9C, [0x41] = 0x2C, [0x42] = 0x69, [0x43] = 0x8A, [0x44] = 0x70, [0x45] = 0x5F, [0x46] = 0x1B, [0x47] = 0x38, [0x48] = 0xC2, [0x49] = 0xB6, [0x4A] = 0xFF, [0x4B] = 0x81, [0x4C] = 0x0D, [0x4D] = 0x1A, [0x4E] = 0xD9, [0x4F] = 0x34, [0x50] = 0xD2, [0x51] = 0x09, [0x52] = 0x96, [0x53] = 0xB5, [0x54] = 0xCA, [0x55] = 0x3E, [0x56] = 0xA3, [0x57] = 0xF2, [0x58] = 0x0B, [0x59] = 0x0E, [0x5A] = 0xB8, [0x5B] = 0xC1, [0x5C] = 0x2E, [0x5D] = 0x77, [0x5E] = 0xB1, [0x5F] = 0x61, [0x60] = 0x93, [0x61] = 0x47, [0x62] = 0x20, [0x63] = 0x86, [0x64] = 0x15, [0x65] = 0x03, [0x66] = 0x18, [0x67] = 0x19, [0x68] = 0xEB, [0x69] = 0xFD, [0x6A] = 0x48, [0x6B] = 0xD7, [0x6C] = 0xE0, [0x6D] = 0x40, [0x6E] = 0x57, [0x6F] = 0xF3, [0x70] = 0xE6, [0x71] = 0x7A, [0x72] = 0xE4, [0x73] = 0xEE, [0x74] = 0xC9, [0x75] = 0xEF, [0x76] = 0xC4, [0x77] = 0x82, [0x78] = 0x3B, [0x79] = 0xED, [0x7A] = 0x22, [0x7B] = 0x7E, [0x7C] = 0x50, [0x7D] = 0x85, [0x7E] = 0xA2, [0x7F] = 0x06, [0x80] = 0xDC, [0x81] = 0xA6, [0x82] = 0xE5, [0x83] = 0x52, [0x84] = 0x5C, [0x85] = 0xF1, [0x86] = 0x98, [0x87] = 0x07, [0x88] = 0xF4, [0x89] = 0x94, [0x8A] = 0x7D, [0x8B] = 0x45, [0x8C] = 0x68, [0x8D] = 0x71, [0x8E] = 0xF5, [0x8F] = 0x01, [0x90] = 0x2F, [0x91] = 0x39, [0x92] = 0xE8, [0x93] = 0x62, [0x94] = 0xCC, [0x95] = 0x3A, [0x96] = 0x73, [0x97] = 0x49, [0x98] = 0x46, [0x99] = 0xCD, [0x9A] = 0xD0, [0x9B] = 0x87, [0x9C] = 0xB7, [0x9D] = 0x02, [0x9E] = 0xFA, [0x9F] = 0x8B, [0xA0] = 0x5E, [0xA1] = 0x8C, [0xA2] = 0xE7, [0xA3] = 0xA8, [0xA4] = 0x72, [0xA5] = 0x56, [0xA6] = 0x4D, [0xA7] = 0x1F, [0xA8] = 0xFE, [0xA9] = 0xE9, [0xAA] = 0x23, [0xAB] = 0x65, [0xAC] = 0x29, [0xAD] = 0xCB, [0xAE] = 0xF9, [0xAF] = 0xBA, [0xB0] = 0x7B, [0xB1] = 0x4F, [0xB2] = 0x2D, [0xB3] = 0xC8, [0xB4] = 0x9D, [0xB5] = 0xDA, [0xB6] = 0xB9, [0xB7] = 0xBB, [0xB8] = 0xC6, [0xB9] = 0xFB, [0xBA] = 0xCF, [0xBB] = 0x6A, [0xBC] = 0xAE, [0xBD] = 0x67, [0xBE] = 0xAC, [0xBF] = 0x75, [0xC0] = 0x83, [0xC1] = 0xA5, [0xC2] = 0xD3, [0xC3] = 0xDF, [0xC4] = 0x90, [0xC5] = 0x79, [0xC6] = 0x3C, [0xC7] = 0x41, [0xC8] = 0x78, [0xC9] = 0xC7, [0xCA] = 0x95, [0xCB] = 0xE1, [0xCC] = 0x24, [0xCD] = 0xA4, [0xCE] = 0x28, [0xCF] = 0x91, [0xD0] = 0x97, [0xD1] = 0x37, [0xD2] = 0xA7, [0xD3] = 0xDD, [0xD4] = 0x9A, [0xD5] = 0x60, [0xD6] = 0x4C, [0xD7] = 0xF7, [0xD8] = 0xD6, [0xD9] = 0x04, [0xDA] = 0x5A, [0xDB] = 0x1C, [0xDC] = 0x74, [0xDD] = 0x6F, [0xDE] = 0xF6, [0xDF] = 0x9F, [0xE0] = 0xDB, [0xE1] = 0xBF, [0xE2] = 0x88, [0xE3] = 0xA1, [0xE4] = 0xC0, [0xE5] = 0x59, [0xE6] = 0xAA, [0xE7] = 0x21, [0xE8] = 0xAD, [0xE9] = 0x1E, [0xEA] = 0xC5, [0xEB] = 0xBD, [0xEC] = 0x00, [0xED] = 0x08, [0xEE] = 0x9B, [0xEF] = 0x4A, [0xF0] = 0x30, [0xF1] = 0x8D, [0xF2] = 0xB0, [0xF3] = 0xB3, [0xF4] = 0x8E, [0xF5] = 0x7F, [0xF6] = 0x63, [0xF7] = 0x26, [0xF8] = 0x5B, [0xF9] = 0x7C, [0xFA] = 0xDE, [0xFB] = 0x4E, [0xFC] = 0xAB, [0xFD] = 0x9E, [0xFE] = 0xA9, [0xFF] = 0x10, }
	}
	
	local rBytes = {	
	[1] =--6.21
		{[0x9C] = 0x00,[0x9D] = 0x40,[0x04] = 0x1A,[0x0C] = 0x1C,[0x1C] = 0x20,[0x14] = 0x1E,[0x10] = 0x1F,[0x18] = 0x21, [0xE1] = 0x23,[0xE5] = 0x22,[0x08] = 0x1D}	
	,[2] =--6.20
		{[0x9C] = 0x00,[0x9D] = 0x40,[0x04] = 0x1A,[0x0C] = 0x1C,[0x1C] = 0x20,[0x14] = 0x1E,[0x10] = 0x1F,[0x18] = 0x21, [0xE1] = 0x23,[0xE5] = 0x22,[0x08] = 0x1D}	
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