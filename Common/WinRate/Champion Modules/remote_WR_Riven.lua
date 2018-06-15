
    class 'Riven'  

    function Riven:__init()
        --[[Data Initialization]]
        self.Allies, self.Enemies = {}, {}
        self.scriptVersion = "1.0"
        self:Spells()
        self:Menu() 
        --[[Default Callbacks]]
        Callback.Add("Tick",          function() self:OnTick()    end)
        Callback.Add("Tick",          function() self:OnProcessSpell() end)
        Callback.Add("Tick",          function() self:OnSpellLoop() end)
        Callback.Add("Draw",          function() self:OnDraw()    end)
        Callback.Add("WndMsg",        function(msg, param) self:OnWndMsg(msg, param) end)        
        --[[Orb Callbacks]]
        OnAttack(function(...) self:OnAttack(...) end)
        OnPreAttack(function(...) self:OnPreAttack(...) end)
        OnPostAttack(function(...) self:OnPostAttack(...) end)
        OnPreMovement(function(...) self:OnPreMovement(...) end)                        
    end

    function Riven:Spells()
        self.Flash = myHero:GetSpellData(SUMMONER_1).name:find("Flash") and {Index = SUMMONER_1, Key = HK_SUMMONER_1} or
                     myHero:GetSpellData(SUMMONER_2).name:find("Flash") and {Index = SUMMONER_2, Key = HK_SUMMONER_2} or nil
        self.Q = Spell({
            Slot = 0,
            Range = 275,
            Delay = 0.25,
            Speed = huge,
            Radius = 100,
            Collision = false,
            From = myHero,
            Type = "Targetted"
        })
        self.W = Spell({
            Slot = 1,
            Range = 260,
            Delay = 0.25,
            Speed = huge,
            Radius = 260,
            Collision = false,
            From = myHero,
            Type = "Press"
        })
        self.E = Spell({
            Slot = 2,
            Range = 325,
            Delay = 0.25,
            Speed = 2500,
            Radius = 100,
            Collision = false,
            From = myHero,
            Type = "Skillshot"
        })
        self.R1 = Spell({
            Slot = 3,
            Range = huge,
            Delay = 0.5,
            Speed = huge,
            Radius = huge,
            Collision = false,
            From = myHero,
            Type = "Press"
        })
        self.R2 = Spell({
            Slot = 3,
            Range = 1100,
            Delay = 0.25,
            Speed = huge,
            Radius = 150,
            Collision = false,
            From = myHero,
            Type = "Skillshot"
        })
        self.Q.Stacks = 0 
        self.Q.LastCast  = Timer()

    end

    function Riven:Menu()
        --Q--
        Menu.Q:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.Q:MenuElement({id = "Combo", name = "Use on Combo", value = true})        
        Menu.Q:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.Q:MenuElement({id = "Harass", name = "Use on Harass", value = true})        
        Menu.Q:MenuElement({name = " ", drop = {"Farm Settings"}})        
        Menu.Q:MenuElement({id = "JungleClear", name = "Use on JungleClear", value = false})
        Menu.Q:MenuElement({id = "LaneClear", name = "Use on LaneClear", value = false})
        Menu.Q:MenuElement({name = " ", drop = {"Misc"}})
        Menu.Q:MenuElement({id = "KS", name = "Use on KS", value = true})
        Menu.Q:MenuElement({id = "Flee", name = "Use on Flee", value = true}) 
        Menu.Q:MenuElement({id = "Alive", name = "Keep Alive", value = false})
        Menu.Q:MenuElement({id = "Delay", name = "Animation Cancelling", type = MENU})
        Menu.Q.Delay:MenuElement({id = "Q1", name = "Extra Q1 Delay", value = 100, min = 0, max = 200})
        Menu.Q.Delay:MenuElement({id = "Q2", name = "Extra Q2 Delay", value = 100, min = 0, max = 200})
        Menu.Q.Delay:MenuElement({id = "Q3", name = "Extra Q3 Delay", value = 100, min = 0, max = 200})            
        --W--
        Menu.W:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.W:MenuElement({id = "Combo", name = "Use on Combo", value = true})        
        Menu.W:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.W:MenuElement({id = "Harass", name = "Use on Harass", value = true})        
        Menu.W:MenuElement({name = " ", drop = {"Farm Settings"}})
        Menu.W:MenuElement({id = "JungleClear", name = "Use on JungleClear", value = false})
        Menu.W:MenuElement({id = "LaneClear", name = "Use on LaneClear", value = false})                
        Menu.W:MenuElement({name = " ", drop = {"Misc"}})
        Menu.W:MenuElement({id = "AutoStun", name = "Auto Stun Nearby", value = 2, min = 0, max = 5, step = 1})
        Menu.W:MenuElement({id = "KS", name = "Use on KS", value = true})  
        Menu.W:MenuElement({id = "Flee", name = "Use on Flee", value = true})      
        --E--
        Menu.E:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.E:MenuElement({id = "Combo", name = "Use on Combo", value = true})        
        Menu.E:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.E:MenuElement({id = "Harass", name = "Use on Harass", value = false})        
        Menu.E:MenuElement({name = " ", drop = {"Farm Settings"}})
        Menu.E:MenuElement({id = "JungleClear", name = "Use on JungleClear", value = false})
        Menu.E:MenuElement({id = "LaneClear", name = "Use on LaneClear", value = false})
        Menu.E:MenuElement({name = " ", drop = {"Misc"}})
        Menu.E:MenuElement({id = "KS", name = "Use to Allow KS", value = true})
        Menu.E:MenuElement({id = "Flee", name = "Use on Flee", value = true})     
        --R--
        Menu.R:MenuElement({name = " ", drop = {"R1 Settings"}})
        Menu.R:MenuElement({id = "ComboR1", name = "Use on Combo", value = true})
        Menu.R:MenuElement({id = "Heroes", name = "Combo Targets", type = MENU})
            Menu.R.Heroes:MenuElement({id = "Loading", name = "Loading Champions...", type = SPACE})
        Menu.R:MenuElement({id = "DmgPercent", name = "Min. Damage Percent to Cast", value = 100, min = 50, max = 200})
        Menu.R:MenuElement({id = "MinHealth", name = "Min. Enemy %Health to Cast", value = 5, min = 1, max = 100})
        Menu.R:MenuElement({name = " ", drop = {"R2 Settings"}})
        Menu.R:MenuElement({id = "ComboR2", name = "Use R2 on Combo", value = true})
        Menu.R:MenuElement({id = "KS", name = "Use To KS", value = true})
        --
        Menu:MenuElement({name = " ", drop = {"Extra Features"}})
        --Burst            
        Menu:MenuElement({id = "Burst", name = "Burst Settings", type = MENU})
        Menu.Burst:MenuElement({id = "Flash", name = "Allow Flash On Burst", value = true}) 
        Menu.Burst:MenuElement({id = "ShyKey", name = "Shy Burst Key", key = string.byte("G")})
        Menu.Burst:MenuElement({id = "WerKey", name = "Werhli Burst Key", key = string.byte("T")})
        --Items
        Menu:MenuElement({id = "Items", name = "Items Settings", type = MENU})
        Menu.Items:MenuElement({id = "Tiamat", name = "Use Tiamat", value = true})
        Menu.Items:MenuElement({id = "TitanicHydra", name = "Use Titanic Hydra", value = true})
        Menu.Items:MenuElement({id = "Hydra", name = "Use Ravenous Hydra", value = true})
        Menu.Items:MenuElement({id = "Youmuu", name = "Use Youmuu's", value = true})
        -- 
        Menu:MenuElement({name = "[WR] "..charName.." Script", drop = {"Release_"..self.scriptVersion}})
        --
        self.menuLoadRequired = true
        Callback.Add("Tick", function() self:MenuLoad() end)
    end

    function Riven:MenuLoad()
        if self.menuLoadRequired then 
            local count = HeroCount()
            if count == 1 then return end 
            for i = 1, count do 
                local hero = Hero(i)
                local charName = hero.charName
                if hero.team == TEAM_ENEMY then        
                    Menu.R.Heroes:MenuElement({id = charName, name = charName, value = true, leftIcon = "https://raw.githubusercontent.com/rman200/WinRateEXT/master/Icons/champions/"..charName..".png"})
                end
            end                      
            Menu.R.Heroes.Loading:Hide(true)            
            self.menuLoadRequired = nil         
        else
            Callback.Del("Tick", function() self:MenuLoad() end)
        end
    end 

    function Riven:OnTick() 
        if ShouldWait() then return end 
        --        
        self.enemies = GetEnemyHeroes(1300)
        self.target = GetTarget(self.R2.Range, 0)
        self.mode = GetMode() 
        --        
        self:UpdateSpells()
        self.BurstMode = self:GetActiveBurst()     

        ---- 
        if self.BurstMode ~= 0 then return end
        self:Auto()             
        self:KillSteal()
        --
        if not self.mode then return end        
        local executeMode = 
            self.mode == 1 and self:Combo()   or 
            self.mode == 2 and self:Harass()  or
            self.mode == 3 and self:Clear()   or
            self.mode == 4 and self:Clear()   or            
            self.mode == 6 and self:Flee()      
    end

    function Riven:OnWndMsg(msg, param)
        DelayAction(function() self:UpdateItems() end, 0.1)
        if msg ~= 257 then return end
        --
        local spell
        if param == HK_Q then 
            spell = "RivenTriCleave"                   
        elseif param == HK_E then 
            spell = "RivenFeint"                   
        end                
        if not spell then return end
        --           
        if self.mode and self.mode == 1 then
            self:OnProcessSpellCombo(spell)
        elseif self.BurstMode == 1 then
            self:OnProcessSpellShy(spell)
        elseif self.BurstMode == 2 then
            self:OnProcessSpellWer(spell)
        end           
    end

    function Riven:OnPreMovement(args) --args.Process|args.Target
        if ShouldWait() then 
            args.Process = false
            return 
        end 
    end

    function Riven:OnPreAttack(args) --args.Process|args.Target
        if ShouldWait() then 
            args.Process = false 
            return
        end 
    end

    function Riven:OnAttack()
        local target = GetTargetByHandle(myHero.attackData.target)
        if ShouldWait() or not IsValidTarget(target) then return end 
        --
        if self.mode == 1 or self.mode == 2 then
            self:UseItems(target)           
        end
    end

    function Riven:OnPostAttack()        
        local target = GetTarget(400, 0)
        if ShouldWait() or not IsValidTarget(target) then return end        
        --       
        if self.BurstMode == 1 then
            self:AfterAttackShy(target)
        elseif self.BurstMode == 2 then 
            self:AfterAttackWer(target)
        end
        --
        if not self.mode then return end
        if self.mode == 1 then
            self:AfterAttackCombo(target)
        elseif self.mode == 2 then
            self:AfterAttackHarass(target)    
        end  
    end

    function Riven:Auto() 
        --
        local time = Timer()
        local qBuff = GetBuffByName(myHero, "RivenTriCleave")        
        if qBuff and qBuff.expireTime >= time and Menu.Q.Alive:Value() and qBuff.expireTime - time <= 0.3 and not IsUnderTurret(myHero.pos + myHero.dir * self.Q.Range, TEAM_ENEMY) then            
            self.Q:Cast(mousePos)
        end
        --
        local minW = Menu.W.AutoStun:Value()
        if minW ~= 0 and self.W:IsReady() and #(GetEnemyHeroes(self.W.Range)) >= minW then
            self.W:Cast()
        end
        --        
        if self:IsR2() and (Menu.R.KS:Value() or (Menu.R.ComboR2:Value() and self.mode == 1)) then
            for i=1, #self.enemies do  
                local target = self.enemies[i]
                if IsValidTarget(target) then --checks for immortal and etc                        
                    local dmg = getdmg("R", target)                 
                    if dmg > target.health + target.shieldAD then                        
                        self:CastR2(target, 2)
                    end
                end
            end
            --
            local rBuff = GetBuffByName(myHero, "rivenwindslashready") 
            if rBuff and rBuff.expireTime >= time and rBuff.expireTime - time <= 1 or HealthPercent(myHero) <= 20 then
                local targ = GetTarget(self.R2.Range, 0)
                self:CastR2(targ, 1)                
            end
        end                              
    end

    function Riven:Combo()
        local target = GetTarget(900, 0) 
        if not target then return end
        --
        local attackRange, dist = GetTrueAttackRange(myHero), GetDistance(target)
        if Menu.E.Combo:Value() and self.E:IsReady() and dist <= 600 and dist > attackRange then
            self:CastE(target)
        end
        self:CastYoumuu(target)
        if Menu.Q.Combo:Value() and self.Q:IsReady() and dist <= attackRange + self.Q.Range and dist > attackRange and Timer() - self.Q.LastCast > 1.1 and not myHero.pathing.isDashing then
            self:CastQ(target)            
        end
        if Menu.W.Combo:Value() and self.W:IsReady() and dist <= self.W.Range then
            self:CastW(target)
        end
        self:UseItems(target)
        if Menu.R.ComboR1:Value() and self.R1:IsReady() and dist <= 600 and target.health < self:TotalDamage(target) * Menu.R.DmgPercent:Value()/100 then
            self:CastR1(target)
        end        
    end

    function Riven:OnProcessSpellCombo(spell)
        local target = GetTarget(self.R2.Range, 0)
        if not (spell and target) then return end
        local dist = GetDistance(target)
        if spell:find("Tiamat") then
            if Menu.W.Combo:Value() and self.W:IsReady() and dist <= self.W.Range then
                self.W:Cast()                
            elseif self.Q:IsReady() and dist <= 400 then
                self:CastQ(target)             
            end
        elseif spell:find("RivenMartyr") then
            if Menu.R.ComboR2:Value() and self.R1:IsReady() and self:IsR2() then
                self:CheckCastR2(target)
            end
        elseif spell:find("RivenFeint") then
            self:UseItems(target)
            if Menu.R.ComboR1:Value() and self.R1:IsReady() and dist <= 600 and target.health < self:TotalDamage(target) * Menu.R.DmgPercent:Value()/100 then
                self:CastR1(target)
            elseif Menu.W.Combo:Value() and self.W:IsReady() and dist <= self.W.Range then
                self.W:Cast()
            elseif self.Q:IsReady() and dist <= 400 then
                self:CastQ(target)
            elseif Menu.R.ComboR2:Value() and self.R1:IsReady() and self:IsR2() then
                self:CheckCastR2(target)
            end
        elseif spell:find("RivenFengShuiEngine") then
            if Menu.W.Combo:Value() and self.W:IsReady() and dist <= self.W.Range then
                self.W:Cast()
            end
        elseif spell:find("RivenIzunaBlade") and self.Q.Stacks == 2 then
            if self.Q:IsReady() and dist <= 400 and myHero.attackData.state ~= STATE_WINDUP then
                self:CastQ(target)
            end
        end
    end

    function Riven:AfterAttackCombo(target)
        local dist = GetDistance(target)
        if Menu.Q.Combo:Value() and self.Q:IsReady() and dist <= 400 then
            self:CastQ(target)           
        elseif Menu.R.ComboR2:Value() and self.R1:IsReady() and self.Q:IsReady() then
            self:CheckCastR2(target)
        elseif Menu.W.Combo:Value() and self.W:IsReady() and dist <= self.W.Range then
            self:CastW(target)
        elseif Menu.E.Combo:Value() and not self.Q:IsReady() and not self.W:IsReady() and self.E:IsReady() and dist <= 400 then
            self:CastE(target)
        end
    end

    function Riven:Harass() 
        local target = GetTarget(900, 0) 
        if not target then return end
        local attackRange = GetTrueAttackRange(myHero)
        if Menu.E.Harass:Value() and self.E:IsReady() and target.distance <= 600 and target.distance > attackRange then
            self:CastE(target)
        end        
        if Menu.Q.Harass:Value() and self.Q:IsReady() and target.distance <= attackRange + self.Q.Range and target.distance > attackRange and Timer() - self.Q.LastCast > 1.1 and not myHero.pathing.isDashing then
            self:CastQ(target)
        end
        if Menu.W.Harass:Value() and self.W:IsReady() and target.distance <= self.W.Range then
            self:CastW(target)
        end
        self:UseItems(target)        
    end

    function Riven:AfterAttackHarass(target)
        if Menu.Q.Harass:Value() and target.distance <= 400 then
            self:CastQ(target)
        elseif Menu.W.Harass:Value() and target.distance <= self.W.Range then
            self:CastW(target)
        elseif Menu.E.Harass:Value() and not self.Q:IsReady() and not self.W:IsReady() and target.distance <= 400 then
            self:CastE(target)
        end
    end

    function Riven:Clear()
        local monsters = GetMonsters(self.E.Range)               
        if #monsters > 0 then
            local qJungle, wJungle, eJungle = self.Q:IsReady() and Menu.Q.JungleClear:Value(), self.W:IsReady() and Menu.W.JungleClear:Value(), self.E:IsReady() and Menu.E.JungleClear:Value() 
            for i=1, #monsters do 
                self:UseItems(monsters[i])
                if     qJungle and monsters[i].distance <= self.Q.Range then                
                    self.Q:Cast(monsters[i]); return
                elseif wJungle and monsters[i].distance <= self.W.Range then                
                    self:PressKey(HK_W); return
                elseif eJungle then                
                    self:PressKey(HK_E); return
                end            
            end
        else        
            local minions = GetEnemyMinions(self.Q.Range)
            if #minions == 0 then return end             
            --
            local qClear, wClear = self.Q:IsReady() and Menu.Q.LaneClear:Value(), self.W:IsReady() and Menu.W.LaneClear:Value()                           
            for i=1, #minions do
                local minion = minions[i]
                self:UseItems(minion) 
                if wClear and minion.distance <= self.W.Range and getdmg("W", minion) >= minion.health then                
                    self:PressKey(HK_W); return
                elseif qClear and minion.distance <= self.Q.Range and getdmg("Q", minion) >= minion.health then                
                    self:CastQ(minion); return                    
                end         
            end            
        end        
    end

    function Riven:Flee()
        Orbwalk() 
        DelayAction(function()
            if self.W:IsReady() and Menu.W.Flee:Value() and #(GetEnemyHeroes(self.W.Range)) >= 1 then
                self.W:Cast()
            elseif self.E:IsReady() and Menu.E.Flee:Value() then                
                self:PressKey(HK_E) 
            elseif self.Q:IsReady() and Menu.Q.Flee:Value() then                 
                self:PressKey(HK_Q)
            end      
        end, 0.2)        
    end

    function Riven:KillSteal()
    end

    function Riven:OnDraw()
        local drawSettings = Menu.Draw
        if drawSettings.ON:Value() then            
            local qLambda = drawSettings.Q:Value() and self.Q and self.Q:Draw(66, 244, 113)
            local wLambda = drawSettings.W:Value() and self.W and self.W:Draw(66, 229, 244)
            local eLambda = drawSettings.E:Value() and self.E and self.E:Draw(244, 238, 66)
            local rLambda = drawSettings.R:Value() and self.R2 and self.R2:Draw(244, 66, 104)
            local tLambda = drawSettings.TS:Value() and self.target and DrawMark(self.target.pos, 3, self.target.boundingRadius, DrawColor(255,255,0,0))            
            if self.enemies and drawSettings.Dmg:Value() then
                for i=1, #self.enemies do
                    local enemy = self.enemies[i]
                    local dmg = self:TotalDamage(enemy)
                    self.R1:DrawDmg(enemy, 0, dmg)
                    if IsValidTarget(enemy) and dmg >= enemy.health + enemy.shieldAD then
                        local screenPos = enemy.pos:To2D()
                        DrawText("Killable", 20, screenPos.x - 30, screenPos.y, DrawColor(255,255,0,0))
                    end
                end 
            end 
        end    
    end

    function Riven:ShyCombo()      
        local enemy = GetTarget(1500, 0)        
        if enemy and enemy.distance <= GetTrueAttackRange(myHero) then
            Orbwalker.ForceTarget = enemy
        else
            Orbwalker.ForceTarget = nil
        end 
        Orbwalk()        
        if not enemy then return end        
        --
        if Menu.Items.Youmuu:Value() then            
            self:CastYoumuu(enemy)
        end
        --
        if self.Flash and Ready(self.Flash.Index) and Menu.Burst.Flash:Value() then
            if IsValidTarget(enemy, 500 + self.Q.Range) then
                if self.E:IsReady() then                    
                    KeyDown(HK_E)
                    DelayAction(function() KeyUp(HK_E) end, 0.01)                   
                end
                if self.R1:IsReady() and self:IsR1() then
                    DelayAction(function() self.R1:Cast() end, 0.05)
                end                
                if self.W:IsReady() and Ready(self.Flash.Index) and enemy.distance > self.E.Range + 100 then
                    DelayAction(function()
                        local delay = (Latency() < 60 and 0) or 0.1 + Latency()/1000
                        DelayAction(function() self.W:Cast() end, delay)                                                        
                        Control.CastSpell(self.Flash.Key, enemy.pos:Extended(myHero.pos, 50))                                                                       
                    end, 0.1)
                end
                if self.W:IsReady() and enemy.distance < self.W.Range then
                    DelayAction(function() self.W:Cast() end, 0.15)
                end
                if self:HasItems() then
                    DelayAction(function() self:UseItems(enemy) end, 0.2)
                end
                if self.R1:IsReady() and self:IsR2() and enemy.distance < self.R2.Range then
                    DelayAction(function() self.R2:Cast(enemy.pos) end, 0.3)
                end
                if self.Q:IsReady() and enemy.distance < self.Q.Range then
                    DelayAction(function() self.Q:Cast(enemy) end, 0.6)
                end
            end
        elseif enemy.distance < self.E.Range + 100 then
            if IsValidTarget(enemy, self.E.Range) then
                if self.E:IsReady() then
                    KeyDown(HK_E)
                    DelayAction(function() KeyUp(HK_E) end, 0.01)
                end
                if self.R1:IsReady() and self:IsR1() then
                    DelayAction(function() self.R1:Cast() end, 0.05)              
                end
                if self.W:IsReady() and enemy.distance < self.W.Range then
                    DelayAction(function() self.W:Cast() end, 0.1)
                end
                if self:HasItems() then
                    DelayAction(function() self:UseItems(enemy) end, 0.15)
                end
                if self.R1:IsReady() and self:IsR2() and enemy.distance < self.R2.Range then
                    DelayAction(function() self.R2:Cast(enemy.pos) end, 0.3)
                end
                if self.Q:IsReady() and enemy.distance < self.Q.Range then
                    DelayAction(function() self.Q:Cast(enemy) end, 0.6)
                end
            end
        end
    end

    function Riven:OnProcessSpellShy(spell)
        local target = GetTarget(1500, 0)
        if not (spell and target) then return end
        --       
        if spell:find("Tiamat") then            
            if self.W:IsReady() and target.distance <= self.W.Range then
                self.W:Cast()                
            elseif self.Q:IsReady() and target.distance <= 400 then
                self:CastQ(target)
            end        
        elseif spell:find("RivenFeint") then            
            if self.R1:IsReady() and self:IsR1() then
                self.R1:Cast()
            elseif self.W:IsReady() and target.distance <= self.W.Range then
                self.W:Cast()
            end
        elseif spell:find("RivenMartyr") then            
            if self.R1:IsReady() and self:IsR2() then
                self.R2:Cast(target.pos)
            elseif self.Q:IsReady() and target.distance <= 400 then
                self:CastQ(target)
            end
        elseif spell:find("RivenIzunaBlade") and self.Q.Stacks ~= 2 then            
            if self.Q:IsReady() and target.distance <= 400 then
                self:CastQ(target)
            end
        end
    end

    function Riven:AfterAttackShy(target)
        self:UseItems(target)         
        if self.W:IsReady() and target.distance <= self.W.Range then
            self.W:Cast()
        elseif self.R1:IsReady() and self:IsR2() and IsValidTarget(target, self.R2.Range) then
            self.R2:Cast(target.pos)
        elseif not self.R1:IsReady() and not self.W:IsReady() and self.Q:IsReady() and IsValidTarget(target, self.Q.Range) then
            self:CastQ(target)           
        end
    end

    function Riven:WerCombo()
        local enemy = GetTarget(1200, 0)        
        if enemy and enemy.distance <= GetTrueAttackRange(myHero) then
            Orbwalker.ForceTarget = enemy
        else
            Orbwalker.ForceTarget = nil
        end 
        Orbwalk()        
        if not enemy then return end 
        --   
        if Menu.Items.Youmuu:Value() then            
            self:CastYoumuu(enemy)
        end
        --
        if self.R1:IsReady() and self:IsR1() then
            DelayAction(function() self.R1:Cast() end, 0.01)
        end
        if self.Flash and Ready(self.Flash.Index) and Menu.Burst.Flash:Value() and enemy.distance > 600 then
            if IsValidTarget(enemy, self.R2.Range - 100) then                
                if not self:IsR2() then return end
                if self.E:IsReady() then                    
                    KeyDown(HK_E)
                    DelayAction(function() KeyUp(HK_E) end, 0.01)                 
                end
                if self.R2:IsReady() then
                    DelayAction(function() self.R2:Cast(enemy.pos) end, 0.1)
                end                                
                if self.W:IsReady() and Ready(self.Flash.Index) and GetDistance(myHero, enemy) > self.E.Range + 100 then
                    DelayAction(function()
                        if not self.R1:IsReady() then
                            local delay = (Latency() < 60 and 0) or 0.1 + Latency()/1000
                            DelayAction(function() self.W:Cast() end, delay)                                                        
                            Control.CastSpell(self.Flash.Key, enemy.pos + (myHero.pos-enemy.pos):Normalized() * 50)
                        end                                                                       
                    end, 0.35)
                end
                if self.W:IsReady() and enemy.distance < self.W.Range then
                    DelayAction(function() self.W:Cast() end, 0.4)
                end
                if self.Q:IsReady() and enemy.distance < self.R2.Range then
                    DelayAction(function() self:CastQ(enemy) end, 0.45)
                end
                if self:HasItems() then
                    DelayAction(function() self:UseItems(enemy) end, 0.5)
                end               
            end
        elseif enemy.distance < 600 then
            if IsValidTarget(enemy, 600) then
                if not self:IsR2() then return end
                if self.E:IsReady() then                    
                    KeyDown(HK_E)
                    DelayAction(function() KeyUp(HK_E) end, 0.01)                   
                end
                if self.R2:IsReady() then
                    DelayAction(function() self.R2:Cast(enemy.pos) end, 0.1)
                end                      
                if self.W:IsReady() and enemy.distance < self.W.Range then
                    DelayAction(function()
                        self.W:Cast()
                        KeyUp(HK_W)
                    end, 0.2)
                end
                if self.Q:IsReady() and enemy.distance < self.R2.Range then
                    DelayAction(function() self:CastQ(enemy) end, 0.25)
                end
                if self:HasItems() then
                    DelayAction(function() self:UseItems(enemy) end, 0.3)
                end
            end
        end
    end

    function Riven:OnProcessSpellWer(spell)
        local target = GetTarget(self.R2.Range, 0)
        if not (spell and target) then return end
        --
        if Menu.Items.Youmuu:Value() then
            self:CastYoumuu(enemy)
        end        
        --        
        if spell:find("Tiamat") then            
            if self.W:IsReady() and target.distance <= self.W.Range then
                self.W:Cast()
            elseif self.Q:IsReady() and target.distance <= 400 then
                self:CastQ(target)
            end        
        elseif spell:find("RivenFeint") then            
            if self.R1:IsReady() and self:IsR2() then
                self.R2:Cast(target.pos)
            elseif self.W:IsReady() and target.distance <= self.W.Range then
                self.W:Cast()
            end
        elseif spell:find("RivenMartyr") then            
            if self.Q:IsReady() and IsValidTarget(target, 400) then
                self:CastQ(target)
            end
        elseif spell:find("RivenIzunaBlade") and self.Q.Stacks ~= 2 then            
            if self.Q:IsReady() and target.distance <= 400 then
                self:CastQ(target)
            end
        end
    end

    function Riven:AfterAttackWer(target)
        self:UseItems(target)
        if self.R1:IsReady() and self:IsR2() and IsValidTarget(target, self.R2.Range) then
            self.R2:Cast(target.pos)
        elseif self.W:IsReady() and target.distance <= self.W.Range then
            self.W:Cast()       
        elseif self.Q:IsReady() and IsValidTarget(target, self.Q.Range) then
            self:CastQ(target)           
        end
    end

    function Riven:OnSpellLoop()
        local time = Timer()        
        if not self.Q:IsReady() then
            local spellQ = myHero:GetSpellData(_Q)  
            for i= 1, 3 do
                local i3 = i ~= 3
                if (i3 and spellQ.cd or 0.25) + time - spellQ.castTime  < 0.1 and (i3 and i or 0) == spellQ.ammo and (i3 or self.Q.Stacks ~= 0) and self.Q.Stacks ~= i then 
                    --print("Q"..i.." Cast")
                    self.Q.LastCast = time
                    self.Q.Stacks = i            
                    self:ResetQ(i);return               
                end
            end
        end  
    end

    local lastSpell = {"Spell Reset", Timer()}
    function Riven:OnProcessSpell()
        local spell = myHero.activeSpell
        local time = Timer()
        if time - lastSpell[2] > 1 then
            lastSpell = {"Spell Reset", time}
        end      
        if spell.valid and spell.name ~= lastSpell[1] then            
            if self.mode and self.mode == 1 then
                self:OnProcessSpellCombo(spell.name)                
            elseif self.BurstMode == 1 then
                self:OnProcessSpellShy(spell.name)
            elseif self.BurstMode == 2 then
                self:OnProcessSpellWer(spell.name)
            end
            lastSpell = {spell.name, time}
        end        
    end

    function Riven:ResetQ(x)
        if not self.mode or self.mode >= 3 then return end
        local extraDelay = Menu.Q.Delay["Q"..x]:Value()        
        DelayAction(function()
            ResetAutoAttack()
            Control.Move(myHero.posTo)            
        end,extraDelay/1000) 
    end

    function Riven:CastQ(targ) 
        local target = targ or mousePos
        if not self.Q:IsReady() or (Orbwalker:CanAttack() and GetDistance(targ) <= GetTrueAttackRange(myHero)) then return end             
        self.Q:Cast(targ)     
    end

    function Riven:CastW(target)
        if not (self.W:IsReady() and IsValidTarget(target, self.W.Range)) then return end
        if self.Q.Stacks ~= 0 or (self.Q.Stacks == 0 and not self.Q:IsReady()) or HasBuff(myHero, "RivenFeint") or not IsFacing(target) then
            self.W:Cast()
        end
    end
    
    function Riven:CastE(target)
        if not (self.E:IsReady() and IsValidTarget(target)) then return end 
        local dist, aaRange = GetDistance(target), GetTrueAttackRange(myHero)
        if Menu.Q.Combo:Value() and self.Q:IsReady() and dist <= aaRange + 260 and self.Q.Stacks == 0 then return end
        --
        local qReady, wReady = self.Q:IsReady(), self.W:IsReady() 
        local qRange, wRange, eRange = (qReady and self.Q.Stacks == 0 and 260 or 0), (wReady and self.W.Range or 0), self.E.Range      
        if (dist <= eRange + qRange) or (dist <= eRange + wRange) or (not wReady and not qReady and dist <= eRange + aaRange) then
            self.E:Cast(target.pos) 
        end
    end

    function Riven:CastR1(target)        
        if not (IsValidTarget(target, self.R2.Range) and self:IsR1() and Menu.R.ComboR1:Value()) or HealthPercent(target) <= Menu.R.MinHealth:Value() then return end
        self.R1:Cast()        
    end

    function Riven:CastR2(target, hC)
        if not (IsValidTarget(target) and self:IsR2()) then return end
        --
        self.R2.Radius = GetDistance(target) * 0.8
        self.R2:CastToPred(target, hC)        
    end

    function Riven:CheckCastR2(target)
        if not (IsValidTarget(target) and self:IsR2()) then return end
        local rDmg, aaDmg = getdmg("R", target), getdmg("AA", target)
        --        
        local rBuff = GetBuffByName(myHero, "rivenwindslashready") 
        local time = Timer()      
        if rBuff and rBuff.expireTime >= time and rBuff.expireTime - time <= 1 or HealthPercent(myHero) <= 20 or (target.health > rDmg + aaDmg * 2 and HealthPercent(target) < 40) or target.health <= rDmg then
            self:CastR2(target, 2)
        end        
    end

    function Riven:UpdateSpells()
        if self.Q.Stacks ~= 0 and Timer() - self.Q.LastCast > 3.8 then self.Q.Stacks = 0 end
        if self:IsR2() then self.W.Range = 330 else self.W.Range = 260 end
    end

    function Riven:GetActiveBurst()
        if Menu.Burst.ShyKey:Value() then            
            self:ShyCombo()
            return 1
        elseif Menu.Burst.WerKey:Value() then
            self:WerCombo()
            return 2
        end
        return 0
    end

    function Riven:HasItems()
        return self.Youmuu or self.Tiamat or self.Hydra or self.Titanic or false
    end

    function Riven:IsR1()
        return myHero:GetSpellData(_R).name:find("RivenFengShuiEngine")
    end

    function Riven:IsR2()
        return myHero:GetSpellData(_R).name:find("RivenIzunaBlade")
    end

    local itemID = {Youmuu = 3142, Tiamat = 3077, Hydra = 3074, Titanic = 3748}
    local itemName = {[3142] = "Youmuu", [3077] = "Tiamat", [3074] = "Hydra", [3748] = "Titanic"}
    function Riven:UpdateItems()              
        for i = ITEM_1, ITEM_7 do
            local id = myHero:GetItemData(i).itemID
            local name = itemName[id]
            if name then                
                if (self[name] and i == self[name].Index and id ~= itemID[name]) then self[name] = nil end --In Case They Sell Items Or Change Slots                
                self[name] = {Index = i, Key = ItemHotKey[i]}                
            end    
        end
    end

    function Riven:GetPassive()        
        return 0.2 + floor(myHero.levelData.lvl/3) * 0.05
    end

    function Riven:TotalDamage(target)
        local damage = 0
        if self.Q:IsReady() or HasBuff(myHero, "RivenTriCleave") then
            local Qleft = 3 - self.Q.Stacks 
            local Qpassive = Qleft * (1+self:GetPassive())            
            damage = damage +  getdmg("Q", target) * (Qleft + Qpassive)
        end
        if self.W:IsReady() then
            damage = damage + getdmg("W", target)
        end
        if self.R1:IsReady() then
            damage = damage + getdmg("R", target)
        end
        damage = damage + getdmg("AA", target)
        return damage        
    end

    function Riven:UseItems(target)
        if self.Tiamat or self.Hydra then 
            self:CastHydra(target)        
        elseif self.Titanic then
            self:CastTitanicHydra(target)            
        end
    end

    function Riven:CastYoumuu(target)        
        if self.Youmuu and Menu.Items.Youmuu:Value() and myHero:GetSpellData(self.Youmuu.Index).currentCd == 0 and IsValidTarget(target, 600) then
            self:PressKey(self.Youmuu.Key)            
        end
    end

    function Riven:CastTitanicHydra(target)
        if self.Titanic and Menu.Items.TitanicHydra:Value() and myHero:GetSpellData(self.Titanic.Index).currentCd == 0 and IsValidTarget(target, 380) then
            self:PressKey(self.Titanic.Key)
            ResetAutoAttack()            
        end
    end

    function Riven:CastHydra(target)
        if not IsValidTarget(target, 380) then return end 
        if self.Hydra and Menu.Items.Hydra:Value() and myHero:GetSpellData(self.Hydra.Index).currentCd == 0 then
            self:PressKey(self.Hydra.Key)
            ResetAutoAttack()            
        elseif self.Tiamat and Menu.Items.Tiamat:Value() and myHero:GetSpellData(self.Tiamat.Index).currentCd == 0 then
            self:PressKey(self.Tiamat.Key)
            ResetAutoAttack()                        
        end
    end

    function Riven:PressKey(k)
        KeyDown(k)
        KeyUp(k)
    end

    Riven()