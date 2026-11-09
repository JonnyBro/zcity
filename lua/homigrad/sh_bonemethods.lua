hg.bone = hg.bone or {} -- посттравматический синдром личности

local tbl = {
	["head"] = "ValveBiped.Bip01_Head1",
	["spine"] = "ValveBiped.Bip01_Spine",
	["spine1"] = "ValveBiped.Bip01_Spine1",
	["spine2"] = "ValveBiped.Bip01_Spine2",
	["pelvis"] = "ValveBiped.Bip01_Pelvis",
	["r_upperarm"] = "ValveBiped.Bip01_R_UpperArm",
	["r_forearm"] = "ValveBiped.Bip01_R_Forearm",
	["l_upperarm"] = "ValveBiped.Bip01_L_UpperArm",
	["l_forearm"] = "ValveBiped.Bip01_L_Forearm",
}

hg.bone.client_only = {
	["r_finger0"] = "ValveBiped.Bip01_R_Finger0",
	["r_finger1"] = "ValveBiped.Bip01_R_Finger1",
	["r_finger11"] = "ValveBiped.Bip01_R_Finger11",
	["r_finger12"] = "ValveBiped.Bip01_R_Finger12",
	["l_finger0"] = "ValveBiped.Bip01_L_Finger0",
	["l_finger01"] = "ValveBiped.Bip01_L_Finger01",
	["l_finger02"] = "ValveBiped.Bip01_L_Finger02",
	["l_finger1"] = "ValveBiped.Bip01_L_Finger1",
	["l_finger11"] = "ValveBiped.Bip01_L_Finger11",
	["l_finger2"] = "ValveBiped.Bip01_L_Finger2",
	["l_finger21"] = "ValveBiped.Bip01_L_Finger21",
	["l_finger3"] = "ValveBiped.Bip01_L_Finger3",
	["l_finger31"] = "ValveBiped.Bip01_L_Finger31",
	["l_finger4"] = "ValveBiped.Bip01_L_Finger4",
	["l_finger41"] = "ValveBiped.Bip01_L_Finger41",
}

local PLAYER = FindMetaTable("Player")

function PLAYER:MBPosition(bone, pos)

	timer.Simple(0, function()
		self:ManipulateBonePosition(bone, pos)
	end)
end

function PLAYER:MBAngles(bone, ang)

	timer.Simple(0, function()
		self:ManipulateBoneAngles(bone, ang)
	end)
end

hg.bone.matrixManual_Name = tbl

local matrix, matrixSet

local vecZero, angZero, vecFull = Vector(0, 0, 0), Angle(0, 0, 0), Vector(1, 1, 1)
local layer, name, boneName, boneID

local function reset(ply)
	ply.manipulated = ply.manipulated or {}

	for bone = 0, ply:GetBoneCount() do
		ply:ManipulateBonePosition(bone, vecZero, true)
		ply:ManipulateBoneAngles(bone, angZero, true)
		ply:ManipulateBoneScale(bone, vecFull, true)
	end

	ply.manipulated = {}
end

local function createLayer(ply, layer, lookup_name)
	boneName = hg.bone.matrixManual_Name[lookup_name]
	boneID = isnumber(lookup_name) and lookup_name or ply:LookupBone(boneName)

	if not boneID then return end

	ply.manipulated = ply.manipulated or {}
	ply.manipulated[boneID] = ply.manipulated[boneID] or {}
	ply.manipulated[boneID].Pos = ply.manipulated[boneID].Pos or Vector(0, 0, 0)
	ply.manipulated[boneID].Ang = ply.manipulated[boneID].Ang or Angle(0, 0, 0)
	ply.manipulated[boneID].layers = ply.manipulated[boneID].layers or {}
	ply.manipulated[boneID].layers[layer] = ply.manipulated[boneID].layers[layer] or {Pos = Vector(0, 0, 0), Ang = Angle(0, 0, 0)}
end

hook.Add("Player Getup", "homigrad-bones", function(ply) reset(ply) end)

local CurTime, LerpVector, LerpAngle = CurTime, LerpVector, LerpAngle
local m, mSet, mAngle, mPos
local vecZero, angZero = Vector(0, 0, 0), Angle(0, 0, 0)
local tickInterval = engine.TickInterval
local FrameTime = FrameTime
local math_min = math.min
local mul = 1
local timeHuy = CurTime()
local hook_Run = hook.Run
local angle = FindMetaTable("Angle")

function math.EqualWithTolerance(val1, val2, tol)
    return math.abs(val1 - val2) <= tol
end

function angle:IsEqualTol(ang, tol)
    if (tol == nil) then
        return self == ang
    end

    return math.EqualWithTolerance(self[1], ang[1], tol)
        and math.EqualWithTolerance(self[2], ang[2], tol)
        and math.EqualWithTolerance(self[3], ang[3], tol)
end

function angle:AngIsEqualTo(otherAng, huy)
	if not angle.IsEqualTol then return false end
	return self:IsEqualTol(otherAng, huy)
end

local hg_anims_draw_distance = ConVarExists("hg_anims_draw_distance") and GetConVar("hg_anims_draw_distance") or CreateClientConVar("hg_anims_draw_distance", 1024, true, nil, "Modify draw anims distance in hammer units (0 = infinite)", 0, 4096)
local hg_anim_fps = ConVarExists("hg_anim_fps") and GetConVar("hg_anim_fps") or CreateClientConVar("hg_anim_fps", 66, true, nil, "Modify bone manipulate frames amount (not tpik) (0 = maximum fps available)", 0, 250)

local dtime
function hg.HomigradBones(ply, dtime)
	if !IsValid(ply) or !ply:IsPlayer() or !ply:Alive() then return end

	local dist = CLIENT and LocalPlayer():GetPos():Distance(ply:GetPos()) or 0
	local drawdistance = CLIENT and hg_anims_draw_distance:GetInt() or 0
	local time = CurTime()

	if CLIENT and (!ply.shouldTransmit or ply.NotSeen) then return end

	local dtime2 = SysTime() - (ply.timeFrameasd or (SysTime() - 1))
	local fps = CLIENT and (hg_anim_fps:GetInt() != 0 and hg_anim_fps:GetInt() or 99999) or 15

	if CLIENT and (dtime2 < 1 / fps) then return end
	if SERVER and dtime2 < 0.2 then return end

	ply.timeFrameasd = SysTime()

	hook_Run("Bones", ply, dtime2)

	if ply.organism and ply.IsBerserk and ply:IsBerserk() and !IsValid(ply.FakeRagdoll) and ply.organism.llegamputated and ply.organism.rlegamputated then
		hg.bone.Set(ply, 0, -vector_up * 15, angle_zero, "berserk", 0.01, dtime2)
	end

	if IsValid(ply.FakeRagdoll) then return end

	if not ply.manipulated then reset(ply) return end

	for bone, tbl in pairs(ply.manipulated) do
		for layer, tbl in pairs(tbl.layers) do
			if (tbl.lastset != time) then
				if tbl.Pos:IsEqualTol(vector_origin, 0.01) and tbl.Ang:IsEqualTol(angle_zero, 0.01) then
					ply.manipulated[bone] = nil

					continue
				end

				hg.bone.Set(ply, bone, vector_origin, angle_zero, layer, 0.01, dtime2, true)
			end
		end
	end
end

hook.Add("Player Think", "homigrad-bones", function(ply, time, dtime)
	hg.HomigradBones(ply, dtime)
end)

function hg.bone.Set(ply, lookup_name, vec, ang, layer, lerp, dtime2)
	local dtime = dtime2 or dtime
	boneName = hg.bone.matrixManual_Name[lookup_name]
	boneID = isnumber(lookup_name) and lookup_name or ply:LookupBone(boneName ~= nil and boneName or lookup_name)

	if not boneID then return end

	layer = layer or "unspecified"

	if layer and layer != "all" then
		createLayer(ply, layer, boneID)

		if lerp then
			vec = LerpVector(hg.lerpFrameTime(lerp, dtime), ply.manipulated[boneID].layers[layer].Pos, vec)
			ang = LerpAngle(hg.lerpFrameTime(lerp, dtime), ply.manipulated[boneID].layers[layer].Ang, ang)
		end

		local oldpos, oldang = hg.bone.Get(ply, boneID)
		local setPos = oldpos - ply.manipulated[boneID].layers[layer].Pos + vec
		local setAng = oldang - ply.manipulated[boneID].layers[layer].Ang + ang

		hg.bone.SetRaw(ply, boneID, setPos, setAng)

		ply.manipulated[boneID].layers[layer].Pos = -(-vec)
		ply.manipulated[boneID].layers[layer].Ang = -(-ang)
		ply.manipulated[boneID].layers[layer].lastset = CurTime()
	end
end
function hg.bone.SetRaw(ply, boneID, vec, ang)
	ply.manipulated = ply.manipulated or {}
	ply.manipulated[boneID] = ply.manipulated[boneID] or {}

	ply.manipulated[boneID].Pos = vec
	ply.manipulated[boneID].Ang = ang

	ply:ManipulateBonePosition(boneID, vec, false)
	ply:ManipulateBoneAngles(boneID, ang, false)
end

function hg.bone.Get(ply, lookup_name)
	boneName = hg.bone.matrixManual_Name[lookup_name]
	boneID = isnumber(lookup_name) and lookup_name or ply:LookupBone(boneName)

	if not boneID or not ply.manipulated[boneID] then return end

	return ply.manipulated[boneID].Pos, ply.manipulated[boneID].Ang
end