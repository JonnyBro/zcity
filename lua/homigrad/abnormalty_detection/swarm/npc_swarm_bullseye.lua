ENT={}

AddCSLuaFile()
ENT.Base = "base_ai"	--Why dont just create an NPC?
ENT.Type = "ai"

ENT.PrintName     = "Swarm _Bullseye"

ENT.m_fMaxYawSpeed = 0 -- Max turning speed
ENT.m_iClass = CLASS_HEADCRAB -- NPC Class

AccessorFunc( ENT, "m_iClass", "NPCClass" )
AccessorFunc( ENT, "m_fMaxYawSpeed", "MaxYawSpeed" )


function ENT:Initialize()

	if(SERVER)then

		self:SetHullType( HULL_TINY_CENTERED )
		self:SetHullSizeNormal()
		self:SetSolid( SOLID_BBOX )
		self:SetMoveType( MOVETYPE_STEP )
		self:CapabilitiesAdd( bit.bor( CAP_MOVE_GROUND, CAP_SQUAD, CAP_MOVE_JUMP, CAP_OPEN_DOORS, CAP_AUTO_DOORS ) )

		self:SetHealth( 1000 )
		self:DrawShadow(false)
	end
end

function ENT:Draw()
end

function ENT:OnTakeDamage( dmginfo )	--Taking damage...

end


function ENT:Think()

end

function ENT:Touch(ent)

end


----
----

function ENT:Classify(  )
	return self.m_iClass
end


function ENT:SelectSchedule( iNPCState )



end


function ENT:OnCondition( iCondition )

end

function ENT:RunAI( strExp )

end

scripted_ents.Register(ENT,"npc_swarm_bullseye")