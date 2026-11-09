--SOMEWHERE IN PLUVTOWN

local PLUGIN = hg.PluvTown

PLUGIN.AddHook("PostDrawAppearance", function(ent, ply)
		if ply.NotSeen then return end
		if IsValid(ply.FakeRagdoll) then return end
		if !ply:Alive() then return end

		local head = ent:LookupBone("ValveBiped.Bip01_Head1")
		if !head then return end
		local matrix = ent:GetBoneMatrix(head)
		if !matrix then return end

		local pos = matrix:GetTranslation()

		local angle = matrix:GetAngles()

		local ent = LocalPlayer():GetViewEntity()
		local Diff = math.AngleDifference(ent:GetAngles().y, angle.y) % 360 - 180

		angle:RotateAroundAxis( angle:Up(), -75)
		angle:RotateAroundAxis( angle:Right(), -90 - (Diff / 4))


		ply.PluvAngles = LerpAngle(FrameTime() * 5, ply.PluvAngles or angle, angle)
		PluvAngle = ply.PluvAngles

		pos = pos + PluvAngle:Forward() * -4 + PluvAngle:Up() * (8 - (math.abs(Diff) / 80)) + PluvAngle:Right() * -4.5

		local light1 = render.GetLightColor(pos)
		local light2 = render.ComputeLighting(pos, PluvAngle:Up() * 2)
		local light3 = render.ComputeDynamicLighting(pos, PluvAngle:Up() * 2)

		local light = (light1 + light2 + light3) * 3

		local CurrentPluv = hg.PluvTown.PluvMats[ply:GetNetVar("CurPluv", "pluv")]
		local PluvLayer = hg.PluvTown.PluvLayers[ply:GetNetVar("CurPluvLayer")]

		cam.Start3D()
			cam.Start3D2D( pos, PluvAngle, 0.05)
				surface.SetMaterial(CurrentPluv)
				surface.SetDrawColor(255 * light[1], 255 * light[2], 255 * light[3])
				surface.DrawTexturedRect(0, 0, 150, 130)

				if PluvLayer then
					surface.SetMaterial(PluvLayer)
					surface.DrawTexturedRect(0, 0, 150, 130)
				end
			cam.End3D2D()
		cam.End3D()
end)