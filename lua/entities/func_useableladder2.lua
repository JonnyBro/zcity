

AddCSLuaFile()

ENT.Type = "point"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Ladder"
ENT.Category = "ZCity Other"
ENT.Spawnable = false
ENT.AdminOnly = true
ENT.AutomaticFrameAdvance = true -- Must be set on client

if SERVER then
    hook.Add("PostCleanupMap", "fuckthoseladders", function()
    end)

    hook.Add("PlayerUse", "daFuqIsThisShit", function(ply, ent)
    end)
end

function ENT:Initialize()
    print(self:GetNWVector("p1"))
    print(self:GetNWVector("p2"), 2)
end

local hull = Vector(64, 64, 32)
function ENT:Think()
    local p1, p2 = self:GetNWVector("p1"), self:GetNWVector("p2")
    local point1 = self:GetPos() + p1
    local point2 = self:GetPos() + p2
    local b1 = point1 - hull
    local b2 = point2 + hull

    for i, ent in pairs(ents.FindInBox(b1, b2)) do
        if !ent:IsPlayer() or IsValid(ent:GetNWEntity("Ladder")) then continue end

        if ent:KeyDown(IN_USE) then
            local dist, point, dist_line = util.DistanceToLine(point1, point2, ent:GetPos())

            ent:SetPos(point)
            ent:SetNWEntity("Ladder", self)
        end
    end
end