AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self.initTime = CurTime() - .25

    self:SetModel("models/blast/bowlingball.mdl")

    self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:PhysicsInit(SOLID_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
    self:DrawShadow(false)
    self:SetTrigger(true)
end

function ENT:ExplodePlayer(ply)
    ply:TakeDamage(25, self:GetOwner())
    ply:EmitSound("doodle_bowlinghit.wav")
end

function ENT:StartTouch(ent)
    if !IsValid(ent) or !ent:IsPlayer() or !ent:Alive() then return end
    if IsValid(ent.pk_pill_ent) then return end
    self:ExplodePlayer(ent)
end

local vec = Vector(0, 0, 100)

function ENT:Think()
    local moveFrac = math.Clamp(1 - (self.initTime + 3 - CurTime())/3, 0, 1)
    local moveSpeed = self.moveDir*2500*FrameTime()*moveFrac

    local pos = self:GetPos()
    local origin = pos
    local tr = util.TraceLine({
        start = origin + vec,
        endpos = origin - vec*100,
        mask = MASK_SOLID_BRUSHONLY
    })

    if tr.Hit then
        pos = tr.HitPos
    end

    local origin = pos + self:OBBCenter()
    local tr = util.TraceLine({
        start = origin,
        endpos = origin + self.moveDir*100 + vec,
        mask = MASK_SOLID_BRUSHONLY
    })

    local upDot = tr.HitNormal:Dot(Vector(0,0,1))
    if tr.Hit and upDot < math.cos(math.rad(45)) then
        self:Remove()
        return
    end

    local ang = self:GetAngles()
    ang.p = ang.p + 1000*FrameTime()*moveFrac

    if ang.p >= 360 then
        ang.p = 0
    end

    self:SetAngles(ang)
    self:SetPos(pos + moveSpeed + Vector(0, 0, self:OBBMaxs().z/2*self:GetModelScale()))

    self:NextThink(CurTime())
    return true
end