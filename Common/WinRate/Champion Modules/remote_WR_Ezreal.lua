
    class 'Ezreal'  

    function Ezreal:__init()
        --[[Data Initialization]]
        self.lastAttacked = myHero
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
            Width = 205,
            Collision = false,
            From = myHero,
            Type = "SkillShot"
        })
        self.Escape = Spell({
            Slot = nil,
            Range = 2000, --reduced on purpose
            Delay = 1,
            Speed = 2000,
            Radius = 2000,
            Collision = false,
            From = myHero,
            Type = "AOE"
        })
    end

    function Ezreal:Menu()
        --Q--
        Menu.Q:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.Q:MenuElement({id = "Combo", name = "Use on Combo", value = true})
        Menu.Q:MenuElement({id = "Pred", name = "Prediction Mode", value = 1, drop = {"Faster", "More Precise"}})
        Menu.Q:MenuElement({id = "Mana", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.Q:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.Q:MenuElement({id = "Harass", name = "Use on Harass", value = true})
        Menu.Q:MenuElement({id = "PredHarass", name = "Prediction Mode", value = 2, drop = {"Faster", "More Precise"}})
        Menu.Q:MenuElement({id = "ManaHarass", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.Q:MenuElement({name = " ", drop = {"Farm Settings"}})
        Menu.Q:MenuElement({id = "LastHit", name = "Use to LastHit", value = false})
        Menu.Q:MenuElement({id = "Jungle", name = "Use on JungleClear", value = false})
        Menu.Q:MenuElement({id = "Clear", name = "Use on LaneClear", value = false})
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
        Menu.R:MenuElement({id = "Combo", name = "Use When X Enemies", value = 2, min = 0, max = 5, step = 1})
        Menu.R:MenuElement({id = "Mana", name = "Min Mana %", value = 0, min = 0, max = 100, step = 1})
        Menu.R:MenuElement({name = " ", drop = {"Misc"}})
        Menu.R:MenuElement({id = "KS", name = "Use to KS", value = true})

        Menu:MenuElement({name = "[WR] "..charName.." Script", drop = {"Release_"..self.scriptVersion}})
        --
    end

    function Ezreal:OnTick() 
        if ShouldWait() then return end 
        --        
        self.enemies = GetEnemyHeroes(2000)
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
        self.lastAttacked = args.Target
    end

    function Ezreal:OnPostAttack()        
        local target = GetTargetByHandle(myHero.attackData.target)
        if ShouldWait() or not IsValidTarget(target) or not (self.Q:IsReady() or self.W:IsReady()) then return end
        --  
        local isMob, isHero = target.type == Obj_AI_Minion, target.type == myHero.type
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
        if ShouldWait() or not Menu.E.Gapcloser:Value() then return end   
        if IsValidTarget(unit) and GetDistance(unitPosTo) < 200 and unit.team == TEAM_ENEMY and IsFacing(unit, myHero) then --Gapcloser                        
            local bestPos = self:GetBestPos()
            if bestPos then
                self.E:Cast(bestPos)
            end            
        end
    end 

    function Ezreal:Auto() 
        local eMode = Menu.E.Mode:Value() 
        if self.mode ~= 1 or eMode == 1 then return end
        --        
        if eMode == 2 then
            local eTarget = GetTarget(self.E.Range + self.Q.Range, 0)
            if eTarget and #GetEnemyHeroes(600) == 0 then
                self.E:Cast(eTarget)
            end
        elseif eMode == 3 then 
            local eTarget = GetTarget(self.E.Range, 0)
            if eTarget and GetDanger(myHero.pos) > 0 then                
                local temp = self:GetBestPos()
                if temp then
                    self.E:Cast(temp)
                end
            end
        end
    end

    function Ezreal:Combo()        
        if self.enemies and #self.enemies ~= 0 and Menu.R.Combo:Value() ~= 0 and self.R:IsReady() and ManaPercent(myHero) >= Menu.R.Mana:Value() then
            local bestPos, hit = GetBestLinearCastPos(self.R, nil, self.enemies)                        
            if bestPos and hit >= Menu.R.Combo:Value() then

                self.R:Cast(bestPos)
            end
        end  
        --
        local qTarget, qPred = GetTarget(self.Q.Range, 0), Menu.Q.Pred:Value()
        if IsValidTarget(qTarget) and GetDistance(qTarget) >= GetTrueAttackRange(myHero) then
            if Menu.Q.Combo:Value() and self.Q:IsReady() and ManaPercent(myHero) >= Menu.Q.Mana:Value() then             
                self.Q:CastToPred(qTarget, qPred)
            elseif Menu.W.Combo:Value() and self.W:IsReady() and ManaPercent(myHero) >= Menu.W.Mana:Value() and GetDistance(qTarget) <= self.W.Range then             
                self.W:CastToPred(qTarget, 2)
            end
        end     
    end

    function Ezreal:Harass() 
        local qTarget, qPred = GetTarget(self.Q.Range, 0), Menu.Q.PredHarass:Value()
        if IsValidTarget(qTarget) and GetDistance(qTarget) >= GetTrueAttackRange(myHero) then
            if Menu.Q.Harass:Value() and self.Q:IsReady() and ManaPercent(myHero) >= Menu.Q.ManaHarass:Value() then             
                self.Q:CastToPred(qTarget, qPred)
            elseif Menu.W.Harass:Value() and self.W:IsReady() and ManaPercent(myHero) >= Menu.W.ManaHarass:Value() and GetDistance(qTarget) <= self.W.Range then             
                self.W:CastToPred(qTarget, 2)
            end
        end         
    end

    function Ezreal:Clear()        
    end

    function Ezreal:LastHit()        
        if Menu.Q.LastHit:Value() and self.Q:IsReady() then 
            local busy = myHero.attackData.state == STATE_WINDDOWN 
            local minions = GetEnemyMinions(self.Q.Range)          
            for i=1, #minions do
                local minion = minions[i]  
                local hp = GetHealthPrediction(minion, self.Q.Delay + GetDistance(minion)/self.Q.Speed)              
                if (minion.networkID ~= self.lastAttacked.networkID) and (busy or GetDistance(minion) >= GetTrueAttackRange(myHero)) and hp >= 20 and self.Q:GetDamage(minion) >= hp and #mCollision(myHero.pos, minion.pos, self.Q, minions) == 0 then
                    self.Q:Cast(minion); return
                end
            end
        end       
    end

    function Ezreal:KillSteal()
        local ksQ, ksW, ksR =  Menu.Q.KS:Value() and self.Q:IsReady(),  Menu.W.KS:Value() and self.W:IsReady(),  Menu.R.KS:Value() and self.R:IsReady()
        if ksQ or ksW or ksR then            
            for i=1, #self.enemies do
                local targ = self.enemies[i]                 
                local hp, dist = targ.health, GetDistance(targ)
                if (ksW and self.W:GetDamage(targ) >= hp) then
                    if self.W:CastToPred(targ, 2) then return end                
                elseif (ksQ and self.Q:GetDamage(targ) >= hp) then
                    if self.Q:CastToPred(targ, 2) then return end                
                elseif (ksR and self.R:GetDamage(targ) >= hp and (hp >= 200 or HeroesAround(600, targ.pos, TEAM_ALLY) == 0)) then
                    if self.R:CastToPred(targ, 3) then return end
                end
            end
        end
    end

    function Ezreal:OnDraw()    
        DrawSpells(self)    
    end

    --function Ezreal:GetBestPos()
    --    local nearby = GetEnemyHeroes(2000)
    --    for k, v in pairs(GetEnemyTurrets(2000)) do nearby[#nearby+1] = v end
    --    local mostDangerous = GetBestCircularCastPos(self.Escape, nil, nearby)
    --    local pos = (myHero.pos):Extended(mostDangerous, -self.E.Range) --farthest possible from most dangerous
    --    if GetDanger(myHero.pos) > GetDanger(pos) + 5 then
    --        DrawCircle(pos, 10)
    --        return pos
    --    end
    --end

    function Ezreal:GetBestPos()        
        local hPos, result = myHero.pos , {}
        local offset, rotateAngle = hPos + Vector(0, 0, self.E.Range), rotateAngle/360 * pi 
        --
        for i=0, 360, 40 do
            local pos = RotateAroundPoint(offset, hPos, i*pi/180)
            result[#result+1] = {pos, GetDanger(pos)}            
        end
        sort(result, function(a,b) 
            if MapPosition:inWall(a[1]) then
                return false
            end
            if a[2] ~= b[2] then
                return a[2] < b[2] 
            else
                return GetDistance(a[1], mousePos) < GetDistance(b[1], mousePos)
            end
        end)
        return result[1][2] == 0 and result[1][1]
    end


    Ezreal()