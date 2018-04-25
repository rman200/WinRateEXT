    local char_name, summoner_name, myId = myHero.charName, myHero.name, myHero.networkID
    --
    local huge, pi, floor, ceil, sqrt, max, min = math.huge, math.pi, math.floor, math.ceil, math.sqrt, math.max, math.min 
    --
    local lenghtOf, abs, deg, cos, sin, acos, atan = math.lenghtOf, math.abs, math.deg, math.cos, math.sin, math.acos, math.atan 
    --
    local contains, insert, remove = table.contains, table.insert, table.remove
    --
    local TEAM_JUNGLE, TEAM_ALLY, TEAM_ENEMY = 300, myHero.team, 300 - myHero.team
    --
    local _STUN, _TAUNT, _SLOW, _SNARE, _FEAR, _CHARM, _SUPRESS, _KNOCKUP, _KNOCKBACK = 5, 8, 10, 11, 21, 22, 24, 29, 30
    --
    local Vector, KeyDown, KeyUp    = Vector, Control.KeyDown, Control.KeyUp
    --
    local DrawCircle, DrawLine, DrawColor = Draw.Circle, Draw.Line, Draw.Color
    --
    local barHeight, barWidth, barYOffset = 8, 103, -8
    --
    local Timer                   = Game.Timer
    local Hero, HeroCount         = Game.Hero, Game.HeroCount
    local Ward, WardCount         = Game.Ward, Game.WardCount
    local Minion, MinionCount     = Game.Minion, Game.MinionCount    
    local Turret, TurretCount     = Game.Turret, Game.TurretCount
    local Object, ObjectCount     = Game.Object, Game.ObjectCount
    local Missile, MissileCount   = Game.Missile, Game.MissileCount
    local Particle, ParticleCount = Game.Particle, Game.ParticleCount

    class 'Ezreal'  

    function Ezreal:__init()
        --[[Data Initialization]]
        self.scriptVersion = "1.0"
        self:Spells()
        self:Menu() 
        --[[Default Callbacks]]   
        Callback.Add("Tick",          function() self:OnTick()    end)
        Callback.Add("Draw",          function() self:OnDraw()    end)
        --[[Orb Callbacks]]
        OnPreAttack(function(...) self:OnPreAttack(...) end)
        OnPostAttack(function(...) self:OnPostAttack(...) end)
        OnPreMovement(function(...) self:OnPreMovement(...) end)
        --[[Custom Callbacks]]
        OnDash(function(unit, unitPos, unitPosTo, dashSpeed, dashGravity, dashDistance) self:OnDash(unit, unitPos, unitPosTo, dashSpeed, dashGravity, dashDistance) end) 
                    
    end

    function Ezreal:Spells()
        self.Q = Spell({
            Slot = 0,
            Range = 1150,
            Delay = 0.25,
            Speed = 2000,
            Width = 60,
            Collision = true,
            From = myHero,
            Type = "SkillShot"
        })
        self.W = Spell({
            Slot = 1,
            Range = 1000,
            Delay = 0.25,
            Speed = 1600,
            Radius = 80,
            Collision = false,
            From = myHero,
            Type = "SkillShot"
        })
        self.E = Spell({
            Slot = 2,
            Range = 475,
            Delay = 0.25,
            Speed = 2500,
            Radius = 100,
            Collision = false,
            From = myHero,
            Type = "SkillShot"
        })
        self.R = Spell({
            Slot = 3,
            Range = 2000, --reduced on purpose
            Delay = 1,
            Speed = 2000,
            Width = 160,
            Collision = false,
            From = myHero,
            Type = "SkillShot"
        })
    end

    function Ezreal:Menu()
        --Q--
        Menu.Q:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.Q:MenuElement({id = "Combo", name = "Use on Combo", value = true})
        Menu.Q:MenuElement({id = "Mana", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.Q:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.Q:MenuElement({id = "Harass", name = "Use on Harass", value = true})
        Menu.Q:MenuElement({id = "ManaHarass", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.Q:MenuElement({name = " ", drop = {"Farm Settings"}})
        Menu.Q:MenuElement({id = "LastHit", name = "Use to LastHit", value = false})
        Menu.Q:MenuElement({id = "Jungle", name = "Use on JungleClear", value = false})
        Menu.Q:MenuElement({id = "Clear", name = "Use on LaneClear", value = false})
        Menu.Q:MenuElement({id = "Min", name = "Minions To Cast", value = 3, min = 0, max = 6, step = 1})
        Menu.Q:MenuElement({id = "ManaClear", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.Q:MenuElement({name = " ", drop = {"Misc"}})
        Menu.Q:MenuElement({id = "KS", name = "Use to KS", value = true})       
        --W--
        Menu.W:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.W:MenuElement({id = "Combo", name = "Use on Combo", value = true})
        Menu.W:MenuElement({id = "Mana", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.W:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.W:MenuElement({id = "Harass", name = "Use on Harass", value = true})
        Menu.W:MenuElement({id = "ManaHarass", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.W:MenuElement({name = " ", drop = {"Misc"}})
        Menu.W:MenuElement({id = "KS", name = "Use to KS", value = true})     
        --E--
        Menu.E:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.E:MenuElement({id = "Mode", name = "Combo Mode", value = 2,drop = {"Never", "Aggressive", "Peel" }})
        Menu.E:MenuElement({id = "Mana", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.E:MenuElement({name = " ", drop = {"Misc"}})
        Menu.E:MenuElement({id = "Gapcloser", name = "Use on Gapcloser", value = true})
        --R--
        Menu.R:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.R:MenuElement({id = "Count", name = "Use When X Enemies", value = 2, min = 1, max = 5, step = 1})
        Menu.R:MenuElement({id = "Mana", name = "Min Mana %", value = 0, min = 0, max = 100, step = 1})
        Menu.R:MenuElement({name = " ", drop = {"Misc"}})
        Menu.R:MenuElement({id = "KS", name = "Use to KS", value = true})

        Menu:MenuElement({name = "[WR] "..charName.." Script", drop = {"Release_"..self.scriptVersion}})
        --
    end

    function Ezreal:OnTick() 
        if ShouldWait() then return end 
        --        
        self.enemies = GetEnemyHeroes(self.Q.Range)
        self.target = GetTarget(GetTrueAttackRange(myHero), 0)
        self.mode = GetMode() 
        --               
        if myHero.isChanneling then return end       
        self:KillSteal()
        --
        if not self.mode then return end 
        self:Auto()       
        local executeMode = 
            self.mode == 1 and self:Combo()   or 
            self.mode == 2 and self:Harass()  or
            self.mode == 3 and self:Clear()   or
            self.mode == 4 and self:Clear()   or
            self.mode == 5 and self:LastHit()     
    end

    function Ezreal:OnPreMovement(args) --args.Process|args.Target
        if ShouldWait() then 
            args.Process = false
            return 
        end 
    end

    function Ezreal:OnPreAttack(args) --args.Process|args.Target
        if ShouldWait() then 
            args.Process = false 
            return
        end 
    end

    function Ezreal:OnPostAttack()        
        local target = GetTargetByHandle(myHero.attackData.target)
        if ShouldWait() or not IsValidTarget(target) or not (self.Q.IsReady() or self.W.IsReady()) then return end
        --  
        local isMob, isHero = tType == Obj_AI_Minion, target.type == myHero.type
        local modeCheck, manaCheck, spell
        --
        if isMob then            
            local laneClear, jungleClear = self.mode == 3, self.mode == 4
            modeCheck = laneClear or jungleClear
            castCheck = target.team == TEAM_JUNGLE and Menu.Q.Jungle:Value() or target.team == TEAM_ENEMY and Menu.Q.Clear:Value()
            manaCheck = ManaPercent(myHero) >= Menu.Q.ManaClear:Value() 
            if modeCheck and castCheck and manaCheck then
                self.Q:Cast(target.pos)
            end
        elseif isHero then 
            local spell = (self.Q:IsReady() and "Q") or "W"
            local combo, harass = self.mode == 1, self.mode == 2
            modeCheck = (combo or harass)
            castCheck = combo and Menu[spell].Combo:Value() or harass and Menu[spell].Harass:Value()
            manaCheck = combo and ManaPercent(myHero) >= Menu[spell].Mana:Value() or harass and ManaPercent(myHero) >= Menu[spell].ManaHarass:Value()
            if modeCheck and castCheck and manaCheck then
                self[spell]:CastToPred(target,2)
            end
        end
    end

    function Ezreal:OnDash(unit, unitPos, unitPosTo, dashSpeed, dashGravity, dashDistance)  
        if ShouldWait() then return end   
        if IsValidTarget(unit) and GetDistance(unitPosTo) < 500 and unit.team == TEAM_ENEMY and IsFacing(unit, myHero) then --Gapcloser                    
        end
    end 

    function Ezreal:Auto() 
        local eMode = Menu.E.Mode:Value() 
        if self.mode ~= 1 or eMode == 0 then return end
        --
        if eMode == 1 then
            local eTarget = GetTarget(self.E.Range + self.Q.Range, 0)
            if #self.enemies == 0 and eTarget then
                self.E:Cast(eTarget)
            end
        elseif eMode == 2 then 
            local eTarget = GetTarget(self.E.Range, 0)
            if #self.enemies == 0 and eTarget then
                self.E:Cast(eTarget)
            end
        end
    end

    function Ezreal:Combo() 
        if Menu.R.Mode:Value() and self.R:IsReady() and ManaPercent(myHero) >= Menu.R.Mana:Value() then 
            local rTarget = GetTarget(self.R.Range, 1)
            if target == nil then return end
            self:CastR(target)
        end  
        --
        local qTarget = GetTarget(self.Q.Range, 0) 
        if IsValidTarget(qTarget) and GetDistance(qTarget) >= GetTrueAttackRange(myHero) then
            if Menu.Q.Combo:Value() and self.Q:IsReady() and ManaPercent(myHero) >= Menu.Q.Mana:Value() then             
                self.Q:CastToPred(qTarget, 2)
            elseif Menu.W.Combo:Value() and self.W:IsReady() and ManaPercent(myHero) >= Menu.W.Mana:Value() and GetDistance(qTarget) <= self.W.Range then             
                self.W:CastToPred(qTarget, 2)
            end
        end     
    end

    function Ezreal:Harass() 
        local qTarget = GetTarget(self.Q.Range, 0) 
        if IsValidTarget(qTarget) and GetDistance(qTarget) >= GetTrueAttackRange(myHero) then
            if Menu.Q.Harass:Value() and self.Q:IsReady() and ManaPercent(myHero) >= Menu.Q.ManaHarass:Value() then             
                self.Q:CastToPred(qTarget, 2)
            elseif Menu.W.Harass:Value() and self.W:IsReady() and ManaPercent(myHero) >= Menu.W.ManaHarass:Value() and GetDistance(qTarget) <= self.W.Range then             
                self.W:CastToPred(qTarget, 2)
            end
        end         
    end

    function Ezreal:Clear()        
    end

    function Ezreal:LastHit()        
    end

    function Ezreal:KillSteal()
    end

    function Ezreal:OnDraw()
        local drawSettings = Menu.Draw
        if drawSettings.ON:Value() then            
            local qLambda = drawSettings.Q:Value() and self.Q and self.Q:Draw(66, 244, 113)
            local wLambda = drawSettings.W:Value() and self.W and self.W:Draw(66, 229, 244)
            local eLambda = drawSettings.E:Value() and self.E and self.E:Draw(244, 238, 66)
            local rLambda = drawSettings.R:Value() and self.R and self.R:Draw(244, 66, 104)
            local tLambda = drawSettings.TS:Value() and self.target and DrawMark(self.target.pos, 3, self.target.boundingRadius, DrawColor(255,255,0,0))
            if self.enemies and drawSettings.Dmg:Value() then
                for i=1, #self.enemies do
                    local enemy = self.enemies[i]                    
                    self.R:DrawDmg(enemy, 1, 0)
                end 
            end 
        end    
    end

    function Ezreal:GetBestPos()
        local hPos = myHero.pos
        local offset, rotateAngle = hPos + Vector(0, 0, self.E.Range), rotateAngle/360 * pi 
        --
        for i=0, 360, 20 do
            local pos = RotateAroundPoint(offset, hPos, i*pi/180)
            DrawCircle(pos, 50)
        end
    end