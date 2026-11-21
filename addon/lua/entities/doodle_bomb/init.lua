AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self.InitTime = CurTime()

    self:SetModel("models/combine_helicopter/helicopter_bomb01.mdl")

    self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:PhysicsInit(SOLID_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
    self:DrawShadow(false)
    self:SetTrigger(true)
    
    self:SetModelScale(2, 2)
end

function ENT:Use(activator, caller)
end

function ENT:ExplodePlayer(ply)
    ply:ScreenFade(SCREENFADE.IN, Color(50, 0, 0, 255), 1, .05)

    timer.Simple(0, function()
        local effectdata = EffectData()
        effectdata:SetOrigin(ply:GetPos())
        
        util.Effect("Explosion", effectdata)
    end)

    ply:HangEffect({
        name = "Cartoony",
        time = 10,
    })
    
    ply:TakeDamage(50)
    self:Remove()
end

function ENT:StartTouch(ent)
    local sTime = self.InitTime+1-CurTime()
    
    if self.TOUCHED or !IsValid(ent) or !ent:IsPlayer() then return end
    if IsValid(ent.pk_pill_ent) then return end

    self.TOUCHED = true
    self:ExplodePlayer(ent)
end