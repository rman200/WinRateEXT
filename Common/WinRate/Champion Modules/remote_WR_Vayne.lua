    
    local mapPos = MapPosition
    local intersectsWall = MapPosition.intersectsWall
    class 'Vayne'  

    function Vayne:__init()
        --[[Data Initialization]]        
        self.scriptVersion = "1.1"
        self:Spells()
        self:Menu() 
        --[[Default Callbacks]]
        Callback.Add("Tick",          function() self:OnTick()    end)
        Callback.Add("Draw",          function() self:OnDraw()    end)
        --[[Orb Callbacks]]
        OnPreAttack(function(...) self:OnPreAttack(...) end)
        OnPostAttackTick(function(...) self:OnPostAttack(...) end)
        OnPreMovement(function(...) self:OnPreMovement(...) end)
        --[[Custom Callbacks]]
        OnInterruptable(function(unit, spell) self:OnInterruptable(unit, spell) end)
        OnDash(function(unit, unitPos, unitPosTo, dashSpeed, dashGravity, dashDistance) self:OnDash(unit, unitPos, unitPosTo, dashSpeed, dashGravity, dashDistance) end)                     
    end

    function Vayne:Spells()
        self.Q = Spell({
            Slot = 0,
            Range = 300,
            Delay = 0.25,
            Speed = 200,
            Radius = 200,
            Collision = false,
            From = myHero,
            Type = "SkillShot"
        })
        self.E = Spell({
            Slot = 2,
            Range = 650,
            Delay = 0.5,
            Speed = 2000,
            Radius = 100,
            Collision = false,
            From = myHero,
            Type = "Targetted"
        })
        self.R = Spell({
            Slot = 3,
            Range = 1000,
            Delay = 0.5,
            From = myHero,
            Type = "Press"
        })
        self.Q.LastReset = Timer()
    end

    function Vayne:Menu()
        Menu.Q:MenuElement({name = " ", drop = {"Combo Settings"}}) --
        Menu.Q:MenuElement({id = "Combo", name = "Use on Combo", value = true}) --
        Menu.Q:MenuElement({id = "Mana", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1}) --
        Menu.Q:MenuElement({name = " ", drop = {"Harass Settings"}}) --
        Menu.Q:MenuElement({id = "Harass", name = "Use on Harass", value = true}) --
        Menu.Q:MenuElement({id = "ManaHarass", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1}) --
        Menu.Q:MenuElement({name = " ", drop = {"Farm Settings"}}) --        
        Menu.Q:MenuElement({id = "Jungle", name = "Use on JungleClear", value = false}) --
        Menu.Q:MenuElement({id = "ManaClear", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1}) --
        Menu.Q:MenuElement({name = " ", drop = {"Misc"}}) --
        Menu.Q:MenuElement({id = "Logic", name = "Tumble Logic", value = 1, drop = {"Prestigious Smart", "Agressive", "Kite[To Mouse]"}}) --
        Menu.Q:MenuElement({id = "Flee", name = "Use on Flee", value = true}) --         
        --W--
        Menu.W:MenuElement({id = "Heroes" , name = "Force Marked Heroes" , value = true})   --
        Menu.W:MenuElement({id = "Minions", name = "Force Marked Minions", value = false})  -- 
        --E--      
        Menu.E:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.E:MenuElement({id = "Combo", name = "Use on Combo", value = true}) --
        Menu.E:MenuElement({id = "Mana", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1}) --
        Menu.E:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.E:MenuElement({id = "Third", name = "Use To Proc 3rd Mark", value = false})
        Menu.E:MenuElement({id = "ManaHarass", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        --
        Menu.E:MenuElement({name = " ", drop = {"Peel Settings"}})        
        Menu.E:MenuElement({id = "Gapcloser", name = "Use as Anti Gapcloser", value = true}) --
        Menu.E:MenuElement({id = "Flee"     , name = "Use on Flee"          , value = true}) --
        Menu.E:MenuElement({id = "AutoPeel" , name = "Auto Peel"            , value = true}) --
        Menu.E:MenuElement({id = "Peel"     , name = "Whitelist", type = MENU}) --
            Menu.E.Peel:MenuElement({id = "Loading", name = "Loading Champions...", type = SPACE}) --
        --
        Menu.E:MenuElement({name = " ", drop = {"Interrupter Settings"}})    --    
        Menu.E:MenuElement({id = "Interrupter" , name = "Use as Interrupter", value = true}) --
        Menu.E:MenuElement({id = "Interrupt"   , name = "Whitelist", type = MENU}) --
            Menu.E.Interrupt:MenuElement({id = "Loading", name = "Loading Champions...", type = SPACE}) --
        --
        Menu.E:MenuElement({name = " ", drop = {"Misc"}}) --
        Menu.E:MenuElement({id = "Auto", name = "Auto Stun", value = true})  --                       
        Menu.E:MenuElement({id = "Push"  , name = "Distance"  , value = 450, min = 400, max = 475, step = 25}) --              
        --R--
        Menu.R:MenuElement({id = "Count", name = "Use When X Enemies", value = 2, min = 0, max = 5, step = 1}) --
        Menu.R:MenuElement({id = "Combo", name = "Use on Duel", value = true})     --           
        Menu.R:MenuElement({id = "Duel", name = "Duel Targets", type = MENU}) --
            Menu.R.Duel:MenuElement({id = "Loading", name = "Loading Champions...", type = SPACE}) --
        Menu:MenuElement({name = "[WR] "..charName.." Script", drop = {"Release_"..self.scriptVersion}}) --
        --
        self.menuLoadRequired = true
        Callback.Add("Tick", function() self:MenuLoad() end)
    end

    function Vayne:MenuLoad()
        if self.menuLoadRequired then 
            local count = HeroCount()
            if count == 1 then return end 
            for i = 1, count do 
                local hero = Hero(i)
                local charName = hero.charName
                if hero.team == TEAM_ENEMY then
                    Interrupter:AddToMenu(hero, Menu.E.Interrupt)
                    if GetTrueAttackRange(hero) <= 500 then
                        Menu.E.Peel:MenuElement({id = charName, name = charName, value = false, leftIcon = "https://raw.githubusercontent.com/rman200/WinRateEXT/master/Icons/champions/"..charName..".png"})
                    end
                    Menu.R.Duel:MenuElement({id = charName, name = charName, value = false, leftIcon = "https://raw.githubusercontent.com/rman200/WinRateEXT/master/Icons/champions/"..charName..".png"})
                end
            end
            local count = -13
            for _ in pairs(Menu.E.Interrupt) do count = count+1 end            
            if count == 1 then
                Menu.E.Interrupt:MenuElement({name = "No Spells To Be Interrupted", drop = {" "}})
                Callback.Del("Tick", function() Interrupter:OnTick() end)
            end 
            Menu.E.Peel.Loading:Hide(true)           
            Menu.R.Duel.Loading:Hide(true)
            Menu.E.Interrupt.Loading:Hide(true)
            self.menuLoadRequired = nil         
        else
            Callback.Del("Tick", function() self:MenuLoad() end)
        end
    end 

    function Vayne:OnTick()        
        if ShouldWait() then return end 
        --        
        self.enemies = GetEnemyHeroes(self.E.Range+self.Q.Range)
        self.target = GetTarget(GetTrueAttackRange(myHero), 0)
        self.mode = GetMode() 
        --   
        self:ResetAA()            
        if myHero.isChanneling or not self.enemies then return end        
        self:Auto()
        --
        if not self.mode then return end        
        local executeMode = 
            self.mode == 6 and self:Flee()      
    end


    function Vayne:ResetAA()
        if Timer() > self.Q.LastReset + 1 and HasBuff(myHero, "vaynetumblebonus") then
            ResetAutoAttack()
            self.Q.LastReset = Timer()
        end
    end

    function Vayne:OnPreMovement(args) --args.Process|args.Target
        if ShouldWait() then 
            args.Process = false
            return 
        end 
    end

    function Vayne:OnPreAttack(args) --args.Process|args.Target
        if ShouldWait() then 
            args.Process = false 
            return
        end 
        --
        local range = GetTrueAttackRange(myHero)
        if HasBuff(myHero, "VayneTumbleFade") then
            for i=1, #self.enemies do 
                if GetDistance(self.enemies[i]) <= 300 then 
                    args.Process = false
                    return
                end
            end
        end
        if Menu.W.Heroes:Value() then
            local nearby = GetEnemyHeroes(range)
            for i=1, #nearby do
                local hero = nearby[i] 
                if self:GetStacks(hero) >= 2 then 
                    args.Target = hero
                    return
                end
            end    
        end
        if args.Target.type == myHero.type then return end
        if Menu.W.Minions:Value() then
            local nearby = GetEnemyMinions(range)
            for i=1, #nearby do
                local minion = nearby[i] 
                if self:GetStacks(minion) >= 2 then 
                    args.Target = minion
                    return
                end
            end
        end
    end

    function Vayne:OnPostAttack()
        local target = GetTargetByHandle(myHero.attackData.target)
        if ShouldWait() or not IsValidTarget(target) then return end
        --
        local tType, tTeam = target.type, target.team       
        
        if tType == Obj_AI_Hero then                                          
            if self.R:IsReady() and Menu.R.Combo:Value() and Menu.R.Duel[target.charName] and Menu.R.Duel[target.charName]:Value() then
                self.R:Cast()
            elseif self.mode == 2 and self.E:IsReady() and Menu.E.Third:Value() and ManaPercent(myHero) >= Menu.E.ManaHarass:Value() and self:GetStacks(target) == 1 then
                self.E:Cast(target) 
            elseif self.Q:IsReady() then
                local modeCheck = (self.mode == 1 and Menu.Q.Combo:Value()  and ManaPercent(myHero) >= Menu.Q.Mana:Value()) or (self.mode == 2 and Menu.Q.Harass:Value() and ManaPercent(myHero) >= Menu.Q.ManaHarass:Value()) 
                local tPos = self:GetBestTumblePos()                                          
                if modeCheck and tPos then 
                    self.Q:Cast(tPos)                     
                end               
            end            
        elseif self.Q:IsReady() and self.mode and self.mode >= 3 and Menu.Q.Jungle:Value() and ManaPercent(myHero) >= Menu.Q.ManaClear:Value() and tTeam == 300 then
            local tPos = self:GetKitingTumblePos(target)
            if tPos then 
                self.Q:Cast(tPos)                 
            end
        --elseif self.Q:IsReady() and tType == Obj_AI_Turret then
            --tumble to closest wall
        end
    end

    function Vayne:OnInterruptable(unit, spell)
        if ShouldWait() or not Menu.E.Interrupter:Value() or not self.E:IsReady() then return end         
        if IsValidTarget(unit, self.E.Range) and unit.team == TEAM_ENEMY and Menu.E.Interrupt[spell.name]:Value() then 
            self.E:Cast(unit)         
        end        
    end   

    function Vayne:OnDash(unit, unitPos, unitPosTo, dashSpeed, dashGravity, dashDistance)  
        if ShouldWait() or not Menu.E.Gapcloser:Value() or not self.E:IsReady() then return end   
        if IsValidTarget(unit) and GetDistance(unitPosTo) < 500 and unit.team == TEAM_ENEMY and IsFacing(unit, myHero) then 
            self.E:Cast(unit)                   
        end
    end 

    function Vayne:Auto()
        local rCount = Menu.R.Count:Value()             
        if self.R:IsReady() and rCount ~= 0 and #self.enemies >= rCount and self.mode == 1 then
            self.R:Cast()
        end
        local autoE, peelE, comboE = Menu.E.Auto:Value(), Menu.E.AutoPeel:Value(), (Menu.E.Combo:Value() and self.mode == 1 and ManaPercent(myHero) >= Menu.E.Mana:Value())
        if self.E:IsReady() and (autoE or peelE or comboE) then
            for i=1, #self.enemies do 
                local enemy = self.enemies[i]
                local enemyRange = GetTrueAttackRange(enemy)
                local autoPeel = GetDistance(enemy) <= enemyRange+50 and Menu.E.Peel[enemy.charName] and Menu.E.Peel[enemy.charName]:Value()                          
                if IsValidTarget(enemy, self.E.Range) and (((autoE or comboE) and self:CheckCondemn(enemy)) or (peelE and autoPeel)) then
                    self.E:Cast(enemy)
                    break                       
                end
            end
        end
    end

    function Vayne:Flee() 
        local closest = GetClosestEnemy()
        local dist = GetDistance(closest)
        local castCheck = dist <= GetTrueAttackRange(closest) or HealthPercent(myHero) <= 30
        --
        if IsValidTarget(closest) then
            if Menu.E.Flee:Value() and self.E:IsReady() and dist <= 400 and castCheck then
                self.E:Cast(closest)
            elseif Menu.Q.Flee:Value() and self.Q:IsReady() and dist <= 600 then
                local bestPos = self:GetBestTumblePos()
                if bestPos then self.Q:Cast(bestPos) end
            end
        end
    end

    function Vayne:OnDraw()               
        local drawSettings = Menu.Draw
        if drawSettings.ON:Value() then            
            local qLambda = drawSettings.Q:Value() and self.Q and self.Q:Draw(66, 244, 113)
            local wLambda = drawSettings.W:Value() and self.W and self.W:Draw(66, 229, 244)
            local eLambda = drawSettings.E:Value() and self.E and self.E:Draw(244, 238, 66)
            local rLambda = drawSettings.R:Value() and self.R and self.R:Draw(244, 66, 104)
            local tLambda = drawSettings.TS:Value() and self.target and DrawMark(self.target.pos, 3, self.target.boundingRadius, DrawColor(255,255,0,0))            
        end    
    end

    function Vayne:CheckCondemn(enemy, pos)
        local eP, pP, pD = enemy.pos, pos or myHero.pos, Menu.E.Push:Value()
        local segment = LineSegment(eP, eP:Extended(pP,-pD))
        return intersectsWall(mapPos, segment)       
    end

    function Vayne:GetStacks(target)
        if not target then error("", 2) end
        local buff = GetBuffByName(target, "VayneSilveredDebuff")        
        return buff and buff.count or 0
    end

    function Vayne:GetBestTumblePos()
        local logic = Menu.Q.Logic:Value()
        local target = GetClosestEnemy()
        if not target then return end
        --
        if logic == 1 then
            return self:GetSmartTumblePos(target)
        elseif logic == 2 then
            return self:GetAggressiveTumblePos(target)                  
        elseif logic == 3 then
            return self:GetKitingTumblePos(target)
        end        
    end

    function Vayne:GetAggressiveTumblePos(target)
        local root1, root2 = CircleCircleIntersection(myHero.pos, target.pos, GetTrueAttackRange(myHero), 500)
        if root1 and root2 then
            local closest = GetDistance(root1, mousePos) < GetDistance(root2, mousePos) and root1 or root2            
            return myHero.pos:Extended(closest, 300)
        end     
    end
    
    function Vayne:GetKitingTumblePos(target)
        local hP, tP = myHero.pos, target.pos       
        local posToKite  = hP:Extended(tP, -300)
        local posToMouse = hP:Extended(mousePos, 300) 
        local range = GetTrueAttackRange(myHero)
        --
        if     not self:IsDangerousPosition(posToKite)  and GetDistance(tP,posToKite)  <= range then
            return posToKite 
        elseif not self:IsDangerousPosition(posToMouse) and GetDistance(tP,posToMouse) <= range then 
            return posToMouse         
        end
    end

    function Vayne:GetSmartTumblePos(target)
        if not self.enemies or not self.Q:IsReady() then return end        
        local pP, range = myHero.pos, self.E.Range^2
        local offset, rAngle = pP + Vector(0, 0, 300), 360/16 * pi/180        
        --
        local result = {}          
        for i=1, 17 do 
            local pos = RotateAroundPoint(offset, pP, rAngle * (i-1))
            for j=1, #self.enemies do --Max 5
                local enemy = self.enemies[j]
                if GetDistanceSqr(pos, enemy) <= range and self:CheckCondemn(enemy, pos) then
                    result[i] = pos  
                    break
                else 
                    result[i] = 1  
                end          
            end
        end 
        return self:GetBestPoint(result) or self:GetKitingTumblePos(target)    
    end

    function Vayne:IsDangerousPosition(pos, turretList, heroList)       
        local turretList = turretList or GetEnemyTurrets(1200)
        for i=1, #turretList do --Max 2 (on nexus)
            local turret = turretList[i]
            if GetDistance(turret, pos) < 900 then return true end 
        end       
        --   
        local heroList = heroList or GetEnemyHeroes(1200)      
        for i=1, #heroList do --Max 5
            local enemy = heroList[i] 
            local range = GetTrueAttackRange(enemy)     
            if range < 500 and GetDistance(enemy, pos) < range then return true end      
        end        
    end

    function Vayne:GetBestPoint(t)
        local dist, best = 10000, nil 
        local heroList, turretList = GetEnemyHeroes(1200), GetEnemyTurrets(1200)      
        for i=1, #t do
            local point = t[i]
            if point and point ~= 1 then
                local dist2 = GetDistance(point, mousePos)
                if dist2 <= dist and not self:IsDangerousPosition(point, turretList, heroList) then
                    best = point 
                    dist = dist2
                end
            end
        end
        return best
    end

    Vayne()