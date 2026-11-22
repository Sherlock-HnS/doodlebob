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

    if SherlockHNS then
        SherlockHNS.Kill(ply, self:GetOwner(), { reason = "trap", inflictor = self })
        self:Remove()
        return
    end
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

    if SherlockHNS and (not IsValid(self:GetOwner()) or not SherlockHNS.CanTarget(ent, self:GetOwner())) then return end
    self.TOUCHED = true
    self:ExplodePlayer(ent)
end

function ENT:Think()
    if SherlockHNS and not self.TOUCHED then
        local mins, maxs = self:WorldSpaceAABB()
        for _, target in ipairs(ents.FindInBox(mins, maxs)) do
            self:StartTouch(target)
            if self.TOUCHED then break end
        end
    end
    self:NextThink(CurTime() + 0.1)
    return true
end