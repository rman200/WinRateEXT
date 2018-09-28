
    class 'Talon'  

    function Talon:__init()
        --[[Data Initialization]] 
        self.fleeTimer = Timer()       
        self.scriptVersion = "1.0"
        self:Spells()
        self:Menu() 
        --[[Default Callbacks]]
        Callback.Add("Tick",          function() self:OnTick()    end)
        Callback.Add("Draw",          function() self:OnDraw()    end)                            
    end

    function Talon:Spells()
        self.Q = Spell({
            Slot = 0,
            Range = 500,
            Delay = 0.25,
            Speed = huge,
            Radius = 0,
            Collision = false,
            From = myHero,
            Type = "Targetted"
        })
        self.W = Spell({
            Slot = 1,
            Range = 750,
            Delay = 0.25,
            Speed = 1450,
            Radius = 250,
            Collision = false,
            From = myHero,
            Type = "Skillshot"
        })
        self.E = Spell({
            Slot = 2,
            Range = 0,
            Delay = 0.25,
            Speed = 0,
            Radius = 0,
            Collision = false,
            From = myHero,
            Type = "Press"
        })
        self.R = Spell({
            Slot = 3,
            Range = 550,
            Delay = 0.25,
            Speed = huge,
            Radius = 550,
            Collision = false,
            From = myHero,
            Type = "Press"
        })
        local flashData = myHero:GetSpellData(SUMMONER_1).name:find("Flash") and SUMMONER_1 or myHero:GetSpellData(SUMMONER_2).name:find("Flash") and SUMMONER_2 or nil
        self.Flash = flashData and Spell({
            Slot = flashData,
            Range = 400,
            Delay = 0.25,
            Speed = huge,
            Radius = 200,
            Collision = false,
            From = myHero,
            Type = "Press"
        })
    end

    function Talon:Menu()
        --Q--
        Menu.Q:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.Q:MenuElement({id = "Combo", name = "Use on Combo", value = true})
        Menu.Q:MenuElement({id = "Mana", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.Q:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.Q:MenuElement({id = "Harass", name = "Use on Harass", value = true})
        Menu.Q:MenuElement({id = "ManaHarass", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.Q:MenuElement({name = " ", drop = {"Farm Settings"}})
        Menu.Q:MenuElement({id = "LastHit", name = "Use to LastHit", value = false})
        Menu.Q:MenuElement({id = "ManaClear", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.Q:MenuElement({name = " ", drop = {"Misc"}})
        Menu.Q:MenuElement({id = "Auto", name = "Auto Proc Passive", value = true})           
        --W--
        Menu.W:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.W:MenuElement({id = "Combo", name = "Use on Combo", value = true})
        Menu.W:MenuElement({id = "Mana", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.W:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.W:MenuElement({id = "Harass", name = "Use on Harass", value = true})
        Menu.W:MenuElement({id = "ManaHarass", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.W:MenuElement({name = " ", drop = {"Farm Settings"}})
        Menu.W:MenuElement({id = "Clear", name = "Use on LaneClear", value = false})
        Menu.W:MenuElement({id = "Min", name = "Minions To Cast", value = 3, min = 0, max = 6, step = 1})
        Menu.W:MenuElement({id = "ManaClear", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        --E--
        Menu.E:MenuElement({name = " ", drop = {"Misc"}})
        Menu.E:MenuElement({id = "Flee", name = "Use on Flee", value = true})     
        --R--
        Menu.R:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.R:MenuElement({id = "Auto", name = "Use When Surrounded", value = true})
        Menu.R:MenuElement({id = "Min", name = "Min X Enemies Around", value = 2, min = 1, max = 5, step = 1})
        Menu.R:MenuElement({id = "Combo", name = "Use To Assassinate", value = true})                 
        Menu.R:MenuElement({id = "Heroes", name = "Assassinate Targets", type = MENU})
            Menu.R.Heroes:MenuElement({id = "Loading", name = "Loading Champions...", type = SPACE})        
        Menu.R:MenuElement({id = "Mana", name = "Min Mana %", value = 0, min = 0, max = 100, step = 1})
        --Burst            
        Menu:MenuElement({id = "Burst", name = "Burst Settings", type = MENU})
        Menu.Burst:MenuElement({id = "Flash", name = "Allow Flash On Burst", value = true}) 
        Menu.Burst:MenuElement({id = "Key", name = "Burst Key", key = string.byte("T")})        
        Menu:MenuElement({name = "[WR] "..charName.." Script", drop = {"Release_"..self.scriptVersion}})
        --
        self.menuLoadRequired = true
        Callback.Add("Tick", function() self:MenuLoad() end)
    end

    function Talon:MenuLoad()
        if self.menuLoadRequired then 
            local count = HeroCount()
            if count == 1 then return end 
            for i = 1, count do 
                local hero = Hero(i)
                local charName = hero.charName
                if hero.team == TEAM_ENEMY then                    
                    Menu.R.Heroes:MenuElement({id = charName, name = charName, value = false, leftIcon = "https://raw.githubusercontent.com/rman200/WinRateEXT/master/Icons/champions/"..charName..".png"})
                end
            end            
            Menu.R.Heroes.Loading:Hide(true)            
            self.menuLoadRequired = nil         
        else
            Callback.Del("Tick", function() self:MenuLoad() end)
        end
    end 

    function Talon:OnTick() 
        if ShouldWait() then return end 
        --        
        self.enemies = GetEnemyHeroes(self.W.Range)
        self.target  = GetTarget(self.W.Range, 0)
        self.mode    = GetMode() 
        --
        if Menu.Burst.Key:Value() then
            self:Burst()
            return
        end               
        if myHero.isChanneling then return end        
        self:Auto()        
        --
        if not self.mode then return end        
        local executeMode = 
            self.mode == 1 and self:Combo()   or 
            self.mode == 2 and self:Harass()  or
            self.mode == 3 and self:Clear()   or
            self.mode == 4 and self:Clear()   or
            self.mode == 5 and self:LastHit() or
            self.mode == 6 and self:Flee()      
    end

    function Talon:Auto()
        if not self.target then return end
        --
        if self.Q:IsReady() and Menu.Q.Auto:Value() then
            self:ProcQ()  
        end  
        if self.mode == 1 and self.R:IsReady() and Menu.R.Auto:Value() and #self.enemies >= Menu.R.Min:Value() and not self:Stealthed() then
            self.R:Cast()
        end                   
    end

    function Talon:Combo() 
        local wTarget = self.target
        if not wTarget then return end 
        --
        if self.R:IsReady() and Menu.R.Combo:Value() and ManaPercent(myHero) >= Menu.R.Mana:Value() and not self:Stealthed() then
            if GetDistance(wTarget) <= self.R.Range and Menu.R.Heroes[wTarget.charName] and Menu.R.Heroes[wTarget.charName]:Value() then
                self.R:Cast()
                return
            end
        end
        if self.W:IsReady() and Menu.W.Combo:Value() and not self:Stealthed() and ManaPercent(myHero) >= Menu.W.Mana:Value() then                                      
            self.W:CastToPred(wTarget, 2)
        elseif self.Q:IsReady() and Menu.Q.Combo:Value() and ManaPercent(myHero) >= Menu.Q.Mana:Value() then
            self.Q:Cast(wTarget)  
            ResetAutoAttack()       
        end       
    end

    function Talon:Harass()
        local wTarget = self.target
        if not wTarget then return end 
        --
        if self.W:IsReady() and Menu.W.Harass:Value() and not self:Stealthed() and ManaPercent(myHero) >= Menu.W.ManaHarass:Value() then                                                         
            self.W:CastToPred(wTarget, 2)
        elseif self.Q:IsReady() and Menu.Q.Harass:Value() and ManaPercent(myHero) >= Menu.Q.ManaHarass:Value() then
            self:ProcQ()  
        end
    end

    function Talon:Clear()
        if self.W:IsReady() and Menu.W.Clear:Value() and ManaPercent(myHero) >= Menu.W.ManaClear:Value() then
            local pos, hit = GetBestCircularFarmPos(self.W)
            if hit >= Menu.W.Min:Value() then
                self.W:Cast(pos)
            end
        end        
    end

    dmgTableClean = 0
    function Talon:LastHit()        
        if self.Q:IsReady() and Menu.Q.LastHit:Value() and ManaPercent(myHero) >= Menu.Q.ManaClear:Value() then
            --
            if Timer() - dmgTableClean >= 1 then
                self.dmgTable = {Melee = {}, Ranged = {}}
                self.minions  = GetEnemyMinions(self.Q.Range)
                dmgTableClean = Timer()
            end
            --            
            for i = 1, #self.minions do
                local minion = self.minions[i] 
                --                
                local range = GetDistance(minion) <= 225 and "Melee" or "Ranged"
                local qDmg = self.dmgTable[range][minion.charName]
                if not qDmg then
                    qDmg = self:GetDamage(_Q, minion)
                    self.dmgTable[range][minion.charName] = qDmg                
                end               
                --                           
                if qDmg >= minion.health then
                    self.Q:Cast(minion) 
                    return                                                                                                                                                 --Last Hit
                end                                
            end
        end    
    end
    
    function Talon:Flee() 
        if Timer() - self.fleeTimer >= 0.5 then
            self.E:Cast()
            self.fleeTimer = Timer()
        end
    end

    function Talon:OnDraw()
        DrawSpells(self) 
    end

    function Talon:Burst()          
        Orbwalk()        
        if self.Q:IsReady() and self.W:IsReady() and self.R:IsReady() then
            local canFlash = self.Flash and self.Flash:IsReady() and Menu.Burst.Flash:Value()
            local range = self.Q.Range + (canFlash and self.Flash.Range or 0)
            local bTarget, eTarget = GetTarget(range, 0), GetTarget(self.Q.Range, 0)
            local shouldFlash = canFlash and bTarget ~= eTarget
            --
            if bTarget then                
                self:BurstCombo(bTarget, shouldFlash, shouldFlash and 1 or 2)                
            end          
        end        
    end

    function Talon:BurstCombo(target, shouldFlash, step)        
        if step == 1 then       
            if shouldFlash then 
                local pos, hK = mousePos, self.Flash:SlotToHK()
                SetCursorPos(target.pos)
                KeyDown(hK)
                KeyUp(hK)
                DelayAction(function() SetCursorPos(pos) end, 0.05)                
            end
            DelayAction(function() self:BurstCombo(target, shouldFlash, 2) end, 0.3)
        elseif step == 2 then
            self.W:CastToPred(target, 1)
            DelayAction(function() 
                self.Q:Cast(target) 
                self.R:Cast()
            end, 0.3)                            
        end
    end

    function Talon:CalculatePhysicalDamage(target, damage)
        if target and damage then
            local targetArmor = target.armor * myHero.armorPenPercent - myHero.armorPen
            local damageReduction = 100 / ( 100 + targetArmor)
            if targetArmor < 0 then
                damageReduction = 2 - (100 / (100 - targetArmor))
            end     
            damage = damage * damageReduction   
            return damage
        end
        return 0
    end

    function Talon:GetDamage(skill, targ)
        if skill == _Q then
            local level = myHero:GetSpellData(_Q).level
            local IsMelee = targ and GetDistance(targ) <= 225
            local rawDmg = (40 + 25 * level + 1.1 * myHero.bonusDamage) * (IsMelee and 1.5 or 1)
            return self:CalculatePhysicalDamage(targ, rawDmg)
        end
    end

    function Talon:Stealthed()
        return HasBuff(myHero, "TalonRStealth")
    end

    function Talon:ProcQ()
        for i = 1, #self.enemies do
            local target = self.enemies[i]
            if GetDistance(target) <= self.Q.Range then
                local buff = GetBuffByName(target, "TalonPassiveStack")
                if buff and buff.count == 2 then
                    self.Q:Cast(target)
                    return  
                end                          
            end
        end
    end

    Talon()