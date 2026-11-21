include("shared.lua")

function ENT:Particles()
    if (self.smokeCD or 0) > CurTime() or self:GetModelScale() >= 2 then return end
    self.smokeCD = CurTime() + .25

    local startpos = self:GetPos() + self:GetRight()*math.Rand(-5, 5) + self:GetForward()*math.Rand(-5, 5)
    local emitter = ParticleEmitter(startpos)

    local color = color_white
    for i = 1, 3 do
        local dir = VectorRand()
        local roll, rollDelta = math.Rand(0, 360), math.Rand(-1, 1)
        
        local particle = emitter:Add("particle/smokesprites_000"..math.random(1, 9), startpos)
        particle:SetVelocity(dir * 50)
        particle:SetDieTime(5)
        particle:SetStartAlpha(255)
        particle:SetEndAlpha(0)
        particle:SetStartSize(25)
        particle:SetEndSize(0)
        particle:SetRoll(roll)
        particle:SetRollDelta(rollDelta)
        particle:SetCollide(true)
        particle:SetNextThink(CurTime())
        particle:SetColor(color.r, color.g, color.b)
		particle:SetCollide(true)
        particle:SetGravity(Vector(0, 0, -1))
        particle:SetThinkFunction(function(particle)
            particle:SetNextThink(CurTime())
    
            if NIGHTVISION then
                particle:SetLifeTime(0)
            end
        end)
    end

    emitter:Finish()
end

local drawEnts = {}
function ENT:Draw()
    --self:DrawModel()
    drawEnts[self] = true
    self:Particles()
end

local bombMat = Material("doodle_bombent.png", "smooth")
hook.Add("PostDrawTranslucentRenderables", "Doodle2", function(bDepth, bSkybox)
	if bSkybox then return end
    
    for ent, _ in pairs(drawEnts) do
        if IsValid(ent) then
            local ang = EyeAngles()
            ang:RotateAroundAxis(ang:Up(), 90)
            ang.r = 90
        
            local size = 450*ent:GetModelScale()
            cam.Start3D2D(ent:GetPos(), ent:GetAngles(), .1)
            RNDX.DrawMaterial(0, -size/2, -size/2, size, size, color_white, bombMat)
            cam.End3D2D()
        end

        drawEnts[ent] = nil
    end
end)