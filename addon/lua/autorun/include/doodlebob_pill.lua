if SERVER then
    AddCSLuaFile()
else
    surface.CreateFont("Krabby65", {
        font = "Krabby Patty",
        size = 65,
        weight = 500,
    })
    surface.CreateFont("Krabby60", {
        font = "Krabby Patty",
        size = 60,
        weight = 500,
    })
    surface.CreateFont("Krabby45", {
        font = "Krabby Patty",
        size = 45,
        weight = 500,
    })
end

pk_pills.packStart("Doodlebob", "AnalogHorrorPills_blastnit_doodlebob", "pills/pill_blast_sider.png")
pk_pills.register('pill_doodlebob', {
    printName = 'Doodlebob',  
    model = "models/blast/Doodlebob.mdl",
    modelScale = '1',
    font = "Krabby",

    abilities = {
        {
            name = "Night Vision",
            key = KEY_F,
            cooldown = 1,
            mat = Material("doodle_nightvision.png", "smooth"),
            func = function(ply, pill) end -- Client Stuff
        },
        {
            name = "Portal",
            key = KEY_T,
            cooldown = 40,
            mat = Material("doodle_portal2.png", "smooth"),
            func = function(ply, pill)
                local puppet = pill:GetPuppet()
                local pillForm = pill:GetPillForm()
                local pillTbl = pill.formTable

                if pill:GetCollisionGroup() == COLLISION_GROUP_IN_VEHICLE then
                    pillTbl.muteSteps = nil

                    pill:SetCollisionGroup(COLLISION_GROUP_PLAYER)
                    puppet:SetColor(ColorAlpha(color_white, 255))

                    pill:PillAnim("portal_exit", true)
                    pill:PillSound("portal_exit")

                    pillTbl.moveSpeed.walk = 1
                    pillTbl.moveSpeed.run = 1
                    pillTbl.moveSpeed.ducked = 1

                    SlashModules.UpdateStats(ply)

                    timer.Simple(0.25, function()
                        local tr = util.TraceLine({
                            start = pill:GetPos(),
                            endpos = pill:GetPos() - Vector(0, 0, 10000),
                            filter = {ply, pill}
                        })
        
                        if !tr.Hit then return false end
        
                        local ang = tr.HitNormal:Angle()
                        ang.p = ang.p + 90
                        
                        local portal = ents.Create("doodle_portal")
                        portal:SetPos(pill:GetPos() + ang:Up())
                        portal:SetAngles(ang)
                        portal:SetOwner(ply)
                        portal:SetModelScale(0.01)
                        portal:Spawn()
                        portal:SetModelScale(1, .5)
        
                        SafeRemoveEntityDelayed(portal, 60)
                    end)

                    timer.Simple(3, function()
                        pillTbl.moveSpeed.walk = 200
                        pillTbl.moveSpeed.run = 600
                        pillTbl.moveSpeed.ducked = 150
        
                        SlashModules.UpdateStats(ply)
                    end)
                else
                    pillTbl.muteSteps = true
                    pill:PillAnim("portal_enter", true)
                    pill:PillSound("portal_enter")
                    pill:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
                    
                    pillTbl.moveSpeed.walk = 1
                    pillTbl.moveSpeed.run = 1
                    pillTbl.moveSpeed.ducked = 1
    
                    SlashModules.UpdateStats(ply)

                    timer.Simple(0.25, function()
                        local tr = util.TraceLine({
                            start = pill:GetPos(),
                            endpos = pill:GetPos() - Vector(0, 0, 10000),
                            filter = {ply, pill}
                        })
        
                        if !tr.Hit then return false end
        
                        local ang = tr.HitNormal:Angle()
                        ang.p = ang.p + 90
                        
                        local portal = ents.Create("doodle_portal")
                        portal:SetPos(pill:GetPos() + ang:Up())
                        portal:SetAngles(ang)
                        portal:SetOwner(ply)
                        portal:SetModelScale(0.01)
                        portal:Spawn()
                        portal:SetModelScale(1, 1.25)
        
                        SafeRemoveEntityDelayed(portal, 60)
                    end)
                    
                    timer.Simple(2.7, function()
                        puppet:SetColor(ColorAlpha(color_white, 0))
    
                        pillTbl.moveSpeed.walk = 1000
                        pillTbl.moveSpeed.run = 2500
                        pillTbl.moveSpeed.ducked = 1000
    
                        SlashModules.UpdateStats(ply)
    
                        timer.Simple(5, function()
                            SlashModules.PillAbility(ply, "Portal")
                        end)
                    end)

                    return 5
                end
            end
        },
        {
            name = "Highlight",
            key = KEY_R,
            cooldown = 60,
            mat = Material("doodle_highlight.png", "smooth"),
            func = function(ply, pill)
                if pill:GetCollisionGroup() == COLLISION_GROUP_IN_VEHICLE then return end
                
                for k, v in ipairs(player.GetAll()) do
                    if IsValid(v.pk_pill_ent) then continue end

                    v:HangEffect({
                        name = "Highlighted",
                        time = 10,
                    })
                end
                
                if math.random(10) == 1 then
                    pill:PillSound("highlight")
                else
                    pill:PillSound("highlight2")
                end

                pill:PillAnim("highlight", true)
            end
        },
        {
            name = "Bowling",
            key = KEY_B,
            cooldown = 25,
            mat = Material("doodle_bowling.png", "smooth"),
            func = function(ply, pill)
                if pill:GetCollisionGroup() == COLLISION_GROUP_IN_VEHICLE then return end

                timer.Simple(.7, function()
                    local bowling = ents.Create("doodle_bowling")
                    bowling:SetPos(pill:GetPos() + ply:GetRight()*25)
                    bowling:SetAngles(ply:GetAngles())
                    bowling:SetOwner(ply)
                    bowling.moveDir = ply:GetForward()
                    bowling:Spawn()
    
                    SafeRemoveEntityDelayed(bowling, 10)
                end)
                
                pill:PillSound("bowling")
                pill:PillAnim("bowling", true)
            end
        },
        {
            name = "Trap",
            key = KEY_G,
            cooldown = 40,
            mat = Material("doodle_bomb.png", "smooth"),
            func = function(ply, pill)
                if pill:GetCollisionGroup() == COLLISION_GROUP_IN_VEHICLE then return end
                
                local totalBombs = ents.FindByClass("doodle_bomb")
                if #totalBombs >= 3 then totalBombs[1]:Remove() end

                local tr = util.TraceLine({
                    start = pill:GetPos(),
                    endpos = pill:GetPos() - Vector(0, 0, 10000),
                    filter = {ply, pill}
                })

                if !tr.Hit then return false end

                local ang = tr.HitNormal:Angle()
                --ang.y = math.random(180)
                ang.p = ang.p + 90
                ang:RotateAroundAxis(ang:Up(), math.random(0, 360))

                local trap = ents.Create("doodle_bomb")
                trap:SetModelScale(.01)
                trap:SetAngles(ang)
                trap:SetPos(tr.HitPos + trap:GetUp())
                trap:SetOwner(ply)
                trap:Spawn()
                
                pill:PillSound("bomb")
                pill:PillAnim("bomb", true)
            end
        },
    },

    noragdoll = true,
    anims = {
        default = {
            highlight = "highlight",
            bomb = "bomb",
            bowling = "bowling",
            portal_enter = "portalenter",
            portal_exit = "portalexit",

            idle = "idle",
            jumpscare = "kill",
            walk = "walk",
            run = "run",
            attack = "attack 1",
            jump = "jump",
            crouch = "cidle",
            crouch_walk = "cwalk",
        },
    },
    moveSpeed = {
        walk = 200,
        run = 600,
        ducked = 150,
    },
    sounds = {
		step = {"doodle_walk1.wav", "doodle_walk2.wav"},
        highlight = "doodle_highlight.wav",
        highlight2 = "doodle_highlight2.wav",
        jumpscare = "doodle_kill.wav",
        portal_enter = "doodle_portal_enter.wav",
        portal_exit = "doodle_portal_exit.wav",
        bowling = "doodle_bowling.wav",
        bomb = "doodle_bomb.wav",
    },
    type = 'ply',
    camera = {
        offset = Vector(0, 0, 50),
        dist = 200,
    },
    jumpPower = 1,
    health = 2000,
    movePoseMode = "xy",
    aim = {
        xPose ="aim_yaw",
        yPose = "aim_pitch",
        nocrosshair = true
    },   
    canAim = function(ply,ent) return ent.active end,    
    attack = {
        mode = 'trigger',
        func = function(ply, ent)
            if ent:GetCollisionGroup() == COLLISION_GROUP_IN_VEHICLE then return end

            SlashModules.JumpscareV2(ply, {
                time = 4,
                bloodImpacts = {
                    4,
                }
            })
        end
    },
    attack2 = {
        mode = "trigger",
        func = function(ply, ent)
        end,
    },
    reload = function(ply,ent)
    end,
    flashlight = function(ply, ent)
    end,
    jump = function(ply, ent) end,
})

hook.Add("PlayerStepSoundTime", "Doodlebob", function(ply, foottype, walking)
    local ent = ply.pk_pill_ent

    if !IsValid(ent) then return end
    local pillForm = ent:GetPillForm()
    
    if pillForm != "pill_doodlebob" then return end

    return ply:IsSprinting() and 300 or 750
end)

hook.Add("SlashModules.Effects.Loaded", "Doodlebob", function()
    SlashModules.Effects.Register("Cartoony", {
        color = color_white,
        stats = {},
        maxstacks = 1,
    })
end)