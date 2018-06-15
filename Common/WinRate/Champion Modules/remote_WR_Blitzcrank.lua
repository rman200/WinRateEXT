
    class 'Blitzcrank'  

    function Blitzcrank:__init()
        --[[Data Initialization]]       
        self.scriptVersion = "1.0"
        self:Spells()
        self:Menu() 
        --[[Default Callbacks]]           
        Callback.Add("Tick",          function() self:OnTick()    end)
        Callback.Add("Draw",          function() self:OnDraw()    end)        
        --[[Orb Callbacks]]        
        OnPreAttack(function(...) self:OnPreAttack(...) end)        
        OnPreMovement(function(...) self:OnPreMovement(...) end)
        --[[Custom Callbacks]]        
        OnInterruptable(function(unit, spell) self:OnInterruptable(unit, spell) end)
        OnDash(function(unit, unitPos, unitPosTo, dashSpeed, dashGravity, dashDistance) self:OnDash(unit, unitPos, unitPosTo, dashSpeed, dashGravity, dashDistance) end)                        
    end

    function Blitzcrank:Spells()
        self.Q = Spell({
            Slot = 0,
            Range = 950,
            Delay = 0.25,
            Speed = 1750,
            Radius = 60,
            Collision = true,
            From = myHero,
            Type = "SkillShot"
        })
        self.W = Spell({
            Slot = 1,            
            From = myHero,
            Type = "Press"
        })
        self.E = Spell({
            Slot = 2,
            Range = GetTrueAttackRange(myHero),                   
            From = myHero,
            Type = "Press"
        })
        self.R = Spell({
            Slot = 3,
            Range = 600,
            Delay = 0.25,
            Speed = huge,
            Radius = 600,
            Collision = false,
            From = myHero,
            Type = "Press"
        })
    end

    function Blitzcrank:Menu()
        --Q--
        Menu.Q:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.Q:MenuElement({id = "Blacklist"   , name = "Blacklist", type = MENU})
        Menu.Q:MenuElement({id = "Combo", name = "Use on Combo", value = true})
        Menu.Q:MenuElement({id = "MinRange", name = "Min Range", value = 250, min = 0, max = 950, step = 10})
        Menu.Q:MenuElement({id = "MaxRange", name = "Max Range", value = 950, min = 0, max = 950, step = 10})
        Menu.Q:MenuElement({id = "Mana", name = "Min Mana %"   , value = 15 , min = 0, max = 100, step = 1})
        Menu.Q:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.Q:MenuElement({id = "BlacklistHarass"   , name = "Blacklist", type = MENU})
        Menu.Q:MenuElement({id = "Harass", name = "Use on Harass"    , value = true})
        Menu.Q:MenuElement({id = "MinRangeHarass", name = "Min Range", value = 250, min = 0, max = 950, step = 10})
        Menu.Q:MenuElement({id = "MaxRangeHarass", name = "Max Range", value = 950, min = 0, max = 950, step = 10})
        Menu.Q:MenuElement({id = "ManaHarass", name = "Min Mana %"   , value = 15 , min = 0, max = 100, step = 1})        
        Menu.Q:MenuElement({name = " ", drop = {"Misc"}})
        Menu.Q:MenuElement({id = "Interrupt"       , name = "Auto Use To Interrupt" , value = true})                
        Menu.Q:MenuElement({id = "InterruptList"   , name = "Whitelist"                    , type = MENU })
            Menu.Q.InterruptList:MenuElement({id = "Loading", name = "Loading Champions...", type = SPACE})
        Menu.Q:MenuElement({id = "Gapcloser"  , name = "Auto Use On Dash"           , value = true})
        Menu.Q:MenuElement({id = "GapList"    , name = "Whitelist"                         , type = MENU })
            Menu.Q.GapList:MenuElement({id = "Loading", name = "Loading Champions..."      , type = SPACE})
        Menu.Q:MenuElement({id = "Auto"       , name = "Auto Use On Immobile"       , value = true})                     
        --W--
        Menu.W:MenuElement({name = " ", drop = {"Misc"}})        
        Menu.W:MenuElement({id = "Flee", name = "Use on Flee", value = true})
        --E--
        Menu.E:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.E:MenuElement({id = "Combo", name = "Use on Combo", value = true})
        Menu.E:MenuElement({id = "Mana", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.E:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.E:MenuElement({id = "Harass", name = "Use on Harass", value = false})
        Menu.E:MenuElement({id = "ManaHarass", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1}) 
        --R--
        Menu.R:MenuElement({name = " ", drop = {"Combo Settings"}})        
        Menu.R:MenuElement({id = "Combo", name = "Use on Combo", value = true})               
        Menu.R:MenuElement({id = "Heroes", name = "Combo Targets", type = MENU})
            Menu.R.Heroes:MenuElement({id = "Loading", name = "Loading Champions...", type = SPACE})
        Menu.R:MenuElement({id = "Mana", name = "Min Mana %", value = 0, min = 0, max = 100, step = 1})
        Menu.R:MenuElement({name = " ", drop = {"Misc"}})
        Menu.R:MenuElement({id = "Count", name = "Auto Use When X Enemies", value = 3, min = 0, max = 5, step = 1}) 
        Menu.R:MenuElement({id = "KS"   , name = "Use To KS", value = true})  
        Menu.R:MenuElement({id = "Interrupt"       , name = "Auto Use To Interrupt" , value = true})                
        Menu.R:MenuElement({id = "InterruptList"   , name = "Whitelist"                    , type = MENU })
            Menu.R.InterruptList:MenuElement({id = "Loading", name = "Loading Champions...", type = SPACE})
        
        Menu:MenuElement({name = "[WR] "..charName.." Script", drop = {"Release_"..self.scriptVersion}})
        --
        self.menuLoadRequired = true
        Callback.Add("Tick", function() self:MenuLoad() end)
    end

    function Blitzcrank:MenuLoad()
        if self.menuLoadRequired then 
            local count = HeroCount()
            if count == 1 then return end 
            for i = 1, count do 
                local hero = Hero(i)
                local charName = hero.charName
                if hero.team == TEAM_ENEMY then 
                    local priority = GetPriority(hero)
                    Interrupter:AddToMenu(hero, Menu.Q.InterruptList)                
                    Interrupter:AddToMenu(hero, Menu.R.InterruptList)
                    Menu.Q.GapList:MenuElement({        id = charName, name = charName, value = false        , leftIcon = "https://raw.githubusercontent.com/rman200/WinRateEXT/master/Icons/champions/"..charName..".png"})
                    Menu.Q.Blacklist:MenuElement({      id = charName, name = charName, value = priority <= 2, leftIcon = "https://raw.githubusercontent.com/rman200/WinRateEXT/master/Icons/champions/"..charName..".png"})
                    Menu.Q.BlacklistHarass:MenuElement({id = charName, name = charName, value = priority <= 3, leftIcon = "https://raw.githubusercontent.com/rman200/WinRateEXT/master/Icons/champions/"..charName..".png"})
                end
            end
            local count = -13
            for _ in pairs(Menu.R.InterruptList) do count = count+1 end            
            if count == 1 then
                Menu.R.InterruptList:MenuElement({name = "No Spells To Be Interrupted", drop = {" "}})
                Callback.Del("Tick", function() Interrupter:OnTick() end)
            end
            count = -13
            for _ in pairs(Menu.Q.InterruptList) do count = count+1 end            
            if count == 1 then
                Menu.Q.InterruptList:MenuElement({name = "No Spells To Be Interrupted", drop = {" "}})
                Callback.Del("Tick", function() Interrupter:OnTick() end)
            end            
            Menu.Q.GapList.Loading:Hide(true)
            Menu.Q.InterruptList.Loading:Hide(true)
            Menu.R.InterruptList.Loading:Hide(true)
            self.menuLoadRequired = nil         
        else
            Callback.Del("Tick", function() self:MenuLoad() end)
        end
    end 

    function Blitzcrank:OnTick() 
        if ShouldWait() then return end 
        --        
        self.enemies = GetEnemyHeroes(self.Q.Range)
        self.target = GetTarget(self.Q.Range, 1)
        self.mode = GetMode() 
        --         
        self:Auto()
        self:KillSteal()
        --
        if not (self.mode and self.target) then return end        
        local executeMode = 
            self.mode == 1 and self:Combo(self.target)   or 
            self.mode == 2 and self:Harass(self.target)  or            
            self.mode == 6 and self:Flee()      
    end

    function Blitzcrank:OnPreMovement(args) --args.Process|args.Target
        if ShouldWait() then 
            args.Process = false
            return 
        end 
    end

    function Blitzcrank:OnPreAttack(args) --args.Process|args.Target
        if ShouldWait() then 
            args.Process = false 
            return
        end 
    end

    function Blitzcrank:OnInterruptable(unit, spell)
        if unit.team ~= TEAM_ENEMY or ShouldWait() or not IsValidTarget(unit, self.Q.Range) then return end         
        if Menu.R.InterruptList[spell.name]:Value() and GetDistace(unit) <= self.R.Range and self.R:IsReady() then
            self.R:Cast()
        elseif Menu.Q.InterruptList[spell.name]:Value() and self.Q:IsReady() then  
            self.Q:CastToPred(unit, 1)
        end        
    end   

    function Blitzcrank:OnDash(unit, unitPos, unitPosTo, dashSpeed, dashGravity, dashDistance)  
        if unit.team ~= TEAM_ENEMY or ShouldWait() or not IsValidTarget(unit, self.Q.Range) then return end   
        if Menu.Q.GapList[unit.charName]:Value() and self.Q:IsReady() then 
            self.Q:CastToPred(unit, 3) 
        end
    end 

    function Blitzcrank:Auto() 
        local minCount =  Menu.R.Count:Value()
        if self.R:IsReady() and minCount ~= 0 and #GetEnemyHeroes(self.R.Range) >= minCount then
            self.R:Cast()
            return
        end
        --
        local qCheck, rCheck = self.Q:IsReady() and Menu.Q.Auto:Value(), self.R:IsReady() and Menu.R.Combo:Value() and ManaPercent(myHero) >= Menu.R.Mana:Value()              
        if qCheck or rCheck then
            for i=1, #self.enemies do
                local enemy = self.enemies[i]                
                if qCheck and IsImmobile(enemy, 0.5) then                             
                    self.Q:Cast(enemy)                   
                elseif self.mode == 1 and rCheck and GetDistance(enemy) <= 500 and myHero:GetSpellData(_E).currentCd > 0 then                             
                    self.R:Cast()                   
                end                
            end 
        end                          
    end

    function Blitzcrank:Combo(target)  
        local dist = GetDistance(target)   
        if self.Q:IsReady() and dist >= Menu.Q.MinRange:Value() and dist <= Menu.Q.MaxRange:Value() and Menu.Q.Combo:Value() and ManaPercent(myHero) >= Menu.Q.Mana:Value() and not Menu.Q.Blacklist[target.charName]:Value() then
            if self.Q:CastToPred(target, 2) then 
                return 
            end            
        end
        if self.E:IsReady() and Menu.E.Combo:Value() and ManaPercent(myHero) >= Menu.E.Mana:Value() then
            self.E.Range = (myHero.range + target.boundingRadius + myHero.boundingRadius)
            if self:IsBeingGrabbed(target) or dist <= self.E.Range then
                self.E:Cast()
                ResetAutoAttack()
                return                
            end
        end          
    end

    function Blitzcrank:Harass(target) 
        local dist = GetDistance(target)   
        if self.Q:IsReady() and dist >= Menu.Q.MinRangeHarass:Value() and dist <= Menu.Q.MaxRangeHarass:Value() and Menu.Q.Harass:Value() and ManaPercent(myHero) >= Menu.Q.ManaHarass:Value() and not Menu.Q.BlacklistHarass[target.charName]:Value() then
            if self.Q:CastToPred(target, 2) then 
                return 
            end            
        end
        if self.E:IsReady() and Menu.E.Harass:Value() and ManaPercent(myHero) >= Menu.E.ManaHarass:Value() then
            self.E.Range = (myHero.range + target.boundingRadius + myHero.boundingRadius)
            if self:IsBeingGrabbed(target) or dist <= self.E.Range then
                self.E:Cast()
                ResetAutoAttack()                
            end
        end        
    end

    function Blitzcrank:Flee()  
        if self.W:IsReady() then
            self.W:Cast()
        end      
    end

    function Blitzcrank:KillSteal()        
        if Menu.R.KS:Value() and self.R:IsReady() then            
            for i=1, #self.enemies do
                local targ = self.enemies[i]                
                if self.R:GetDamage(targ) >= targ.health + targ.shieldAP then
                    self.R:Cast()
                end
            end
        end
    end

    function Blitzcrank:OnDraw()
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
                    local qDmg, eDmg = self.Q:IsReady() and self.Q:GetDamage(enemy) or 0, self.E:IsReady() and self.E:GetDamage(enemy) or 0
                    self.R:DrawDmg(enemy, 1, qDmg+eDmg)
                end 
            end 
        end    
    end

    function Blitzcrank:IsBeingGrabbed(unit)
        return HasBuff(unit, "rocketgrab2")    
    end

    Blitzcrank()