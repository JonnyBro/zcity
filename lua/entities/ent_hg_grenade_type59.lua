if SERVER then AddCSLuaFile() end
ENT.Base = "ent_hg_grenade"
ENT.Spawnable = false
ENT.Model = "models/weapons/w_jj_fraggrenade_thrown.mdl"
ENT.timeToBoom = 3.8
ENT.Fragmentation = 300 * 3
ENT.BlastDis = 5 --meters
ENT.Penetration = 5.5

function ENT:PoopBomb()
	return math.random(1, 50) == 1 -- китайская
end

ENT.playedSound = false
function ENT:AddThink()
	if not self.timer or not self.timeToBoom or self.playedSound then return end
		self.playedSound = true
end