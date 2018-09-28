
    class 'TwistedFate'  

    function TwistedFate:__init()
        --[[Data Initialization]]
        self.Allies, self.Enemies = {}, {}
        self.scriptVersion = "1.0"
        self:Spells()
        self:Menu() 
        --[[Default Callbacks]]  
        Callback.Add("Tick",          function() self:OnTick()    end)
        Callback.Add("Draw",          function() self:OnDraw()    end)        
        --[[Orb Callbacks]]
        OnAttack(function(...) self:OnAttack(...) end)
        OnPreAttack(function(...) self:OnPreAttack(...) end)
        OnPreMovement(function(...) self:OnPreMovement(...) end)                   
    end

    function TwistedFate:Spells()
        self.Q = Spell({
            Slot = 0,
            Range = 1400,
            Delay = 0.25,
            Speed = huge,
            Radius = 50,
            Collision = false,
            From = myHero,
            Type = "SkillShot"
        })
        self.W = Spell({
            Slot = 1,
            Range = huge,            
            From = myHero,
            Type = "Press"
        })
        self.R = Spell({
            Slot = 3,
            Range = 5500,
            Delay = 1,
            Speed = huge,
            Radius = 150,
            Collision = false,
            From = myHero,
            Type = "AOE"
        })
        self.W.Pick = "DONTPICKSHIT"
        self.W.LastCast = 0
    end

    function TwistedFate:Menu()
        --Q--
        Menu.Q:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.Q:MenuElement({id = "Combo", name = "Use on Combo", value = true})
        Menu.Q:MenuElement({id = "Pred", name = "Prediction Mode", value = 2 , drop = {"Faster", "More Precise"}})
        Menu.Q:MenuElement({id = "Mana", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.Q:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.Q:MenuElement({id = "Harass", name = "Use on Harass", value = true})
        Menu.Q:MenuElement({id = "PredHarass", name = "Prediction Mode", value = 2 , drop = {"Faster", "More Precise"}})
        Menu.Q:MenuElement({id = "ManaHarass", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.Q:MenuElement({name = " ", drop = {"Misc"}})
        Menu.Q:MenuElement({id = "Auto", name = "Auto Use on Immobile", value = true})  
        Menu.Q:MenuElement({id = "KS", name = "Use on KS", value = true})                   
        --W--
        Menu.W:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.W:MenuElement({id = "Combo", name = "Use on Combo", value = true})
        Menu.W:MenuElement({id = "Mana", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.W:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.W:MenuElement({id = "Harass", name = "Use on Harass", value = true})
        Menu.W:MenuElement({id = "ManaHarass", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.W:MenuElement({name = " ", drop = {"Misc"}})
        Menu.W:MenuElement({id = "Auto", name = "Pick Gold Card On Ult", value = true})
        Menu.W:MenuElement({id = "ManaMin", name = "Pick Blue Card if Mana < X", value = 30, min = 0, max = 100, step = 1})
        Menu.W:MenuElement({id = "Flee", name = "Use on Flee", value = true}) 

        Menu:MenuElement({name = " ", drop = {"Extra Features"}})
        --CardPicker           
        Menu:MenuElement({id = "Key", name = "Card Picker", type = MENU})       
        Menu.Key:MenuElement({id = "Gold", name = "Pick Gold Card", key = string.byte("E")})
        Menu.Key:MenuElement({id = "Blue", name = "Pick Blue Card", key = string.byte("T")})
        Menu.Key:MenuElement({id = "Red" , name = "Pick Red Card" , key = string.byte("Z")}) 

        Menu:MenuElement({name = "[WR] "..charName.." Script", drop = {"Release_"..self.scriptVersion}})        
    end

    function TwistedFate:OnTick() 
        if ShouldWait() then return end 
        --        
        self.enemies = GetEnemyHeroes(self.Q.Range)
        self.target = GetTarget(GetTrueAttackRange(myHero), 0)
        self.mode = GetMode() 
        --              
        self:Auto()
        if myHero.isChanneling then return end
        self:KillSteal()
        --
        if not (self.mode and self.enemies) then return end        
        local executeMode = 
            self.mode == 1 and self:Combo()   or 
            self.mode == 2 and self:Harass()  or
            self.mode == 6 and self:Flee()      
    end

    function TwistedFate:OnPreMovement(args) --args.Process|args.Target
        if ShouldWait() then 
            args.Process = false
            return 
        end 
    end

    function TwistedFate:OnPreAttack(args) --args.Process|args.Target
        if ShouldWait() then 
            args.Process = false 
            return
        end
    end

    function TwistedFate:OnAttack()        
        if self.W:IsReady() and ManaPercent(myHero) <= Menu.W.ManaMin:Value() then
            self:PickCard("Blue")
        end
    end

    function TwistedFate:Auto() 
        if Menu.Key.Gold:Value() or Menu.W.Auto:Value() and HasBuff(myHero,"Gate") and self:CanPick() then            
            self:PickCard("Gold")
        elseif Menu.Key.Blue:Value() then            
            self:PickCard("Blue")            
        elseif Menu.Key.Red:Value() then            
            self:PickCard("Red")            
        end
        if HasBuff(myHero, "pickacard_tracker") then            
            self.IsPicking = true
            local spellName = myHero:GetSpellData(_W).name
            if spellName:find(self.W.Pick) and self.W:IsReady() then
                self.W:Cast() 
                self.W.Pick = "DONTPICKSHIT"        
            end            
        else
            self.IsPicking = false
        end         
       
        if self.Q:IsReady() and Menu.Q.Auto:Value() and ManaPercent(myHero) >= Menu.Q.Mana:Value() and self.enemies then
            for i=1, #self.enemies do
                local enemy = self.enemies[i]
                if IsImmobile(enemy) then
                    self.Q:Cast(enemy.pos)
                end
            end
        end                      
    end

    function TwistedFate:Combo() 
        if Menu.Q.Combo:Value() and ManaPercent(myHero) >= Menu.Q.Mana:Value() and self.Q:IsReady() then
            qTarget = GetTarget(self.Q.Range)
            self.Q:CastToPred(qTarget, Menu.Q.Pred:Value())
        end
        if Menu.W.Combo:Value() and ManaPercent(myHero) >= Menu.W.Mana:Value() and self:CanPick() and self.target then
            self:PickCard("Gold")
        end       
    end

    function TwistedFate:Harass()
        if Menu.Q.Harass:Value() and ManaPercent(myHero) >= Menu.Q.ManaHarass:Value() and self.Q:IsReady() then
            qTarget = GetTarget(self.Q.Range)
            self.Q:CastToPred(qTarget, Menu.Q.PredHarass:Value())
        end
        if Menu.W.Harass:Value() and ManaPercent(myHero) >= Menu.W.ManaHarass:Value() and self:CanPick() and self.target then
            self:PickCard("Gold")
        end        
    end

    function TwistedFate:Flee() 
        if not self.target then return end
        if Menu.W.Flee:Value() and self:CanPick() then
            self:PickCard("Gold")
        end     
        if HasBuff(myHero, "GoldCardPreAttack") then
            Control.Attack(self.target)
        end  
    end

    function TwistedFate:KillSteal()
        for i=1, #self.enemies do
            local unit = self.enemies[i]
            if IsValidTarget(unit) and self.Q:IsReady() and Menu.Q.KS:Value() then
                local damage = self.Q:GetDamage(unit)
                if unit.health + unit.shieldAP < damage then
                    self.Q:CastToPred(unit, 1); return
                end
            end          
        end
    end

    function TwistedFate:OnDraw()
        DrawSpells(self)    
    end

    function TwistedFate:PickCard(card)
        self.W.Pick = card        
        if self:CanPick() then            
            self.W.LastCast = Timer()
            self.W:Cast() 
        end
    end

    function TwistedFate:CanPick(card)
        return self.W:IsReady() and self.IsPicking == false and Timer() - self.W.LastCast >= 0.3 
    end

    TwistedFate()