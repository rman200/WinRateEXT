
    class 'Twitch'  

    function Twitch:__init()
        --[[Data Initialization]]
        self.poisonTable = {}
        self.Killable    = {}
        self.scriptVersion = "1.0"
        self:Spells()
        self:Menu() 
        --[[Default Callbacks]]  
        Callback.Add("Tick",          function() self:OnTick()    end)
        Callback.Add("Draw",          function() self:OnDraw()    end)
        --[[Orb Callbacks]]
        OnPreAttack  (function(...) self:OnPreAttack(...)   end)
        OnPostAttack (function(...) self:OnPostAttack(...)  end)
        OnPreMovement(function(...) self:OnPreMovement(...) end)
        --[[Custom Callbacks]]
        OnDash(function(unit, unitPos, unitPosTo, dashSpeed, dashGravity, dashDistance) self:OnDash(unit, unitPos, unitPosTo, dashSpeed, dashGravity, dashDistance) end)                    
    end

    function Twitch:Spells()
        self.Q = Spell({
            Slot = 0,
            Range = 800,
            Delay = 0.85,
            Speed = huge,
            Radius = huge,
            Collision = false,
            From = myHero,
            Type = "Press"
        })
        self.W = Spell({
            Slot = 1,
            Range = 950,
            Delay = 0.25,
            Speed = 1400,
            Radius = 100,
            Collision = false,
            From = myHero,
            Type = "AOE"
        })
        self.E = Spell({
            Slot = 2,
            Range = 1200,
            Delay = 0.25,
            Speed = huge,
            Radius = 100,
            Collision = false,
            From = myHero,
            Type = "Press"
        })
        self.R = Spell({
            Slot = 3,
            Range = 850,
            Delay = 0.25,
            Speed = huge,
            Radius = 150,
            Collision = false,
            From = myHero,
            Type = "Press"
        })
        self.E.GetDamage = function(self, enemy, stage)
            if not self:IsReady() then return 0 end
            --
            local eLvl = myHero:GetSpellData(_E).level  
            local stacks = Twitch.poisonTable[enemy.networkID].stacks
            if stacks ~= 0 then
                local baseDmg, stacksDmg = 10 + 10 * eLvl, (10+5*eLvl + 0.35 * myHero.bonusDamage + 0.2 * myHero.ap) * stacks
                return baseDmg+stacksDmg
            end
            return 0
        end
    end

    function Twitch:Menu()
        --Q--
        Menu.Q:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.Q:MenuElement({id = "Combo", name = "Use on Combo", value = true})
        Menu.Q:MenuElement({id = "Mana", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.Q:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.Q:MenuElement({id = "Harass", name = "Use on Harass", value = true})
        Menu.Q:MenuElement({id = "ManaHarass", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.Q:MenuElement({name = " ", drop = {"Misc"}})
        Menu.Q:MenuElement({id = "Turret", name = "Use on Turret", value = true})  
        Menu.Q:MenuElement({id = "Flee", name = "Use on Flee", value = true})          
        --W--
        Menu.W:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.W:MenuElement({id = "Combo", name = "Use on Combo", value = true})
        Menu.W:MenuElement({id = "Mana", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.W:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.W:MenuElement({id = "Harass", name = "Use on Harass", value = true})
        Menu.W:MenuElement({id = "ManaHarass", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.W:MenuElement({name = " ", drop = {"Misc"}})  
        Menu.W:MenuElement({id = "Flee", name = "Use on Flee", value = true}) 
        Menu.W:MenuElement({id = "Gapcloser", name = "Use on Gapcloser", value = true})     
        --E--
        Menu.E:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.E:MenuElement({id = "Combo", name = "Use on Combo", value = true})
        Menu.E:MenuElement({id = "Min", name = "Min Stacks", value = 6, min = 1, max = 30, step = 1})
        Menu.E:MenuElement({id = "Mana", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.E:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.E:MenuElement({id = "Harass", name = "Use on Harass", value = false})
        Menu.E:MenuElement({id = "MinHarass", name = "Min Stacks", value = 6, min = 1, max = 30, step = 1})
        Menu.E:MenuElement({id = "ManaHarass", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.E:MenuElement({name = " ", drop = {"Misc"}})
        Menu.E:MenuElement({id = "KS", name = "Use to KS", value = true}) 
        Menu.E:MenuElement({id = "Dying", name = "Use If Dying", value = true}) 
        --R--
        Menu.R:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.R:MenuElement({id = "Count", name = "Use When X Enemies", value = 2, min = 0, max = 5, step = 1})
        Menu.R:MenuElement({id = "Duel", name = "Use on Duel", value = true})         
        Menu.R:MenuElement({id = "Heroes", name = "Duel Targets", type = MENU})
            Menu.R.Heroes:MenuElement({id = "Loading", name = "Loading Champions...", type = SPACE})
        Menu.R:MenuElement({id = "Mana", name = "Min Mana %", value = 0, min = 0, max = 100, step = 1})

        Menu:MenuElement({name = "[WR] "..charName.." Script", drop = {"Release_"..self.scriptVersion}})
        --
        self.menuLoadRequired = true
        Callback.Add("Tick", function() self:MenuLoad() end)
    end

    function Twitch:MenuLoad()
        if self.menuLoadRequired then 
            local count = HeroCount()
            if count == 1 then return end 
            for i = 1, count do 
                local hero = Hero(i)
                local charName = hero.charName
                if hero.team == TEAM_ENEMY then                
                    self.poisonTable[hero.networkID] = {stacks = 0, endTime = 0, dmg = 0}
                    Menu.R.Heroes:MenuElement({id = charName, name = charName, value = false, leftIcon = "https://raw.githubusercontent.com/rman200/WinRateEXT/master/Icons/champions/"..charName..".png"})
                end
            end        
            Menu.R.Heroes.Loading:Hide(true)
            self.menuLoadRequired = nil         
        else
            Callback.Del("Tick", function() self:MenuLoad() end)
        end
    end 

    function Twitch:OnTick() 
        if ShouldWait() then return end 
        --        
        self.enemies = GetEnemyHeroes(self.E.Range)
        self.target = GetTarget(GetTrueAttackRange(myHero), 0)
        self.mode = GetMode() 
        --               
        if myHero.isChanneling then return end        
        self:UpdatePoison() 
        self:KillSteal()
        --
        if not self.mode then return end        
        local executeMode = 
            self.mode == 1 and self:Combo()   or 
            self.mode == 2 and self:Harass()  or
            self.mode == 6 and self:Flee()      
    end

    function Twitch:OnPreMovement(args) --args.Process|args.Target
        if ShouldWait() then 
            args.Process = false
            return 
        end 
    end

    function Twitch:OnPreAttack(args) --args.Process|args.Target
        if ShouldWait() then 
            args.Process = false 
            return
        end 
    end

    function Twitch:OnPostAttack()        
        local target = GetTargetByHandle(myHero.attackData.target)
        if ShouldWait() or not IsValidTarget(target) then return end
        local tType = target.type 
        -- 
        if self.Q:IsReady() and not self:IsInvisible() then
            local qCombo, qHarass = self.mode == 1 and Menu.Q.Combo:Value() and ManaPercent(myHero) >= Menu.Q.Mana:Value() , not qCombo and self.mode == 2 and Menu.Q.Harass:Value() and ManaPercent(myHero) >= Menu.Q.ManaHarass:Value()
            if (tType == Obj_AI_Turret and Menu.Q.Turret:Value()) or (tType == Obj_AI_Hero and (qCombo or qHarass)) then
                self.Q:Cast()                
            end 
        end        
        if self.W:IsReady() and tType == Obj_AI_Hero and not self:IsUlting() then            
            local wCombo, wHarass = self.mode == 1 and Menu.W.Combo:Value() and ManaPercent(myHero) >= Menu.W.Mana:Value() , not wCombo and self.mode == 2 and Menu.W.Harass:Value() and ManaPercent(myHero) >= Menu.W.ManaHarass:Value()
            if wCombo or wHarass then                
                self.W:CastToPred(target, 2)
            end             
        end    
    end

    function Twitch:OnDash(unit, unitPos, unitPosTo, dashSpeed, dashGravity, dashDistance)  
        if ShouldWait() or not (Menu.W.Gapcloser:Value() and self.W:IsReady()) then return end   
        if not self:IsInvisible() and IsValidTarget(unit) and GetDistance(unitPosTo) < self.W.Range and unit.team == TEAM_ENEMY and IsFacing(unit, myHero) then --Gapcloser 
            self.W:CastToPred(unit, 2)
        end
    end 

    function Twitch:Combo()        
        if self.R:IsReady() and ManaPercent(myHero) >= Menu.R.Mana:Value() and Menu.R.Count:Value() ~= 0 then
            local rTarget = GetTarget(self.R.Range)
            if (#GetEnemyHeroes(self.R.Range) >= Menu.R.Count:Value()) or (Menu.R.Duel:Value() and IsValidTarget(rTarget) and Menu.R.Heroes[rTarget.charName]:Value()) then                       
                self.R:Cast() 
                return
            end
        end
        --
        if self.E:IsReady() and Menu.E.Combo:Value() and ManaPercent(myHero) >= Menu.E.Mana:Value() then
            local stacks = 0
            for i=1, #self.enemies do                
                stacks = stacks + self.poisonTable[self.enemies[i].networkID].stacks
            end
            if stacks >= Menu.E.Min:Value() then
                self.E:Cast() 
            end
        end
        --       
        if not self:IsInvisible() and not GetTarget(GetTrueAttackRange(myHero), 0) and GetTarget(self.W.Range, 0) then
            if self.Q:IsReady() and Menu.Q.Combo:Value() and ManaPercent(myHero) >= Menu.Q.Mana:Value()then            
                self.Q:Cast()                
            end        
            if self.W:IsReady() and not self:IsUlting() and Menu.W.Combo:Value() and ManaPercent(myHero) >= Menu.W.Mana:Value() then                 
                self.W:CastToPred(target, 2)
            end  
        end      
    end

    function Twitch:Harass() 
        if self.E:IsReady() and Menu.E.Harass:Value() and ManaPercent(myHero) >= Menu.E.ManaHarass:Value() then
            local stacks = 0
            for i=1, #self.enemies do                
                stacks = stacks + self.poisonTable[self.enemies[i].networkID].stacks
            end
            if stacks >= Menu.E.MinHarass:Value() then
                self.E:Cast() 
            end
        end  
        --    
        if not self:IsInvisible() and not GetTarget(GetTrueAttackRange(myHero), 0) and GetTarget(self.W.Range, 0) then
            if self.Q:IsReady() and Menu.Q.Harass:Value() and ManaPercent(myHero) >= Menu.Q.ManaHarass:Value() then            
                self.Q:Cast()                
            end        
            if self.W:IsReady() and not self:IsUlting() and Menu.W.Harass:Value() and ManaPercent(myHero) >= Menu.W.ManaHarass:Value() then                 
                self.W:CastToPred(target, 2)
            end  
        end        
    end

    function Twitch:Flee() 
        if #GetEnemyHeroes(1000) == 0 then return end
        local wTarget = GetTarget(600, 0)
        if not self:IsInvisible() and self.W:IsReady() and Menu.W.Flee:Value() and wTarget then
            self.W:CastToPred(wTarget, 2)
        elseif self.Q:IsReady() and Menu.Q.Flee:Value() then
            self.Q:Cast()
        end

    end

    function Twitch:KillSteal()
        if not self.E:IsReady() then return end
        if Menu.E.Dying:Value() and HealthPercent(myHero) <= 10 then
            self.E:Cast()
        elseif Menu.E.KS:Value() then
            for k, enemy in pairs(self.Killable) do                    
                if IsValidTarget(enemy, self.E.Range) then
                    self.E:Cast()
                end
            end 
        end
    end

    function Twitch:OnDraw()
        DrawSpells(self)
        --
        if Menu.Draw.ON:Value() then            
            for k, enemy in pairs(self.Killable) do                    
                local pos = enemy.toScreen
                if pos.onScreen and IsValidTarget(enemy, self.E.Range) then
                    DrawText("Killable", 50, pos.x-enemy.boundingRadius, pos.y, DrawColor(255, 66, 244, 98))                    
                end
            end            
        end    
    end

    function Twitch:IsInvisible()
        return HasBuff(myHero, "TwitchHideInShadows")
    end

    function Twitch:IsUlting()
        return myHero.range >= 800
    end

    function Twitch:CalcDamage(enemy)
        local eLvl = myHero:GetSpellData(_E).level  
        local stacks = self.poisonTable[enemy.networkID].stacks
        if stacks ~= 0 then
            local baseDmg, stacksDmg = 10 + 10 * eLvl, (10+5*eLvl + 0.25 * myHero.bonusDamage + 0.2 * myHero.ap) * stacks
            return CalcPhysicalDamage(myHero, enemy, baseDmg+stacksDmg)
        end
        return 0
    end

    function Twitch:UpdatePoison()             
        for i=1, #self.enemies do
            local enemy = self.enemies[i]   
            local ID = enemy.networkID  
            --    
            if not self.poisonTable[ID] then
                self.poisonTable[ID] = {stacks = 0, endTime = 0, dmg = 0}
            end
            --            
            local oldStacks, oldTime = self.poisonTable[ID].stacks, self.poisonTable[ID].endTime
            --
            local buff = GetBuffByName(enemy, "TwitchDeadlyVenom")
            if buff and buff.count > 0 and Timer() < buff.expireTime then
                if buff.expireTime > oldTime and oldStacks < 6 then
                    self.poisonTable[ID].stacks = oldStacks + 1
                end
                self.poisonTable[ID].endTime = buff.expireTime         
            else 
                self.poisonTable[ID].stacks = 0
            end
            --  
            local eDmg = self.E:CalcDamage(enemy)
            self.poisonTable[ID].dmg = eDmg                   
            if eDmg >= enemy.health + enemy.shieldAD then                
                self.Killable[ID] = enemy
            else
                self.Killable[ID] = nil
            end
        end        
    end 

    _G["Twitch"] = Twitch()