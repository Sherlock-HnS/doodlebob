include("shared.lua")

local drawEnts = {}
function ENT:Draw()
    drawEnts[self] = true
end

local portalMat = Material("doodle_portal.png", "smooth")
hook.Add("PostDrawTranslucentRenderables", "Doodle", function(bDepth, bSkybox)
	if bSkybox then return end
    
    for ent, _ in pairs(drawEnts) do
        if IsValid(ent) then
            local ang = EyeAngles()
            ang:RotateAroundAxis(ang:Up(), 90)
            ang.r = 90
        
            local size = 1000*ent:GetModelScale()
            cam.Start3D2D(ent:GetPos(), ent:GetAngles(), .1)
            RNDX.DrawMaterial(0, -size/2, -size/2, size, size, color_white, portalMat)
            cam.End3D2D()
        end

        drawEnts[ent] = nil
    end
end)