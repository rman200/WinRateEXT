
    class 'Varus'  

    function Varus:__init()
        --[[Data Initialization]]
        self.Allies, self.Enemies = {}, {}
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
        OnDash(function(unit, unitPos, unitPosTo, dashSpeed, dashGravity, dashDistance) self:OnDash(unit, unitPos, unitPosTo, dashSpeed, dashGravity, dashDistance) end) 
    end

    function Varus:Spells()
        self.Q = Spell({
            Slot = 0,
            Range = 975,
            Delay = 0.25,
            Speed = 1900,
            Radius = 70,
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
        self.E = Spell({
            Slot = 2,
            Range = 925,
            Delay = 0.25,
            Speed = 1500,
            Radius = 250,
            Collision = false,
            From = myHero,
            Type = "AOE"
        })
        self.R = Spell({
            Slot = 3,
            Range = 1075,
            Delay = 0.25,
            Speed = 1950,
            Radius = 120,
            Collision = false,
            From = myHero,
            Type = "SkillShot"
        })
        self.Q.MaxRange = 1550
    end

    function Varus:Menu()
        --Q--
        Menu.Q:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.Q:MenuElement({id = "Combo"      , name = "Use on Combo"          , value = true})
        Menu.Q:MenuElement({id = "Stack"      , name = "Save To Proc 3 Stacks" , value = true})        
        Menu.Q:MenuElement({id = "Pred"       , name = "Prediction Mode"       , value = 2 , drop = {"Faster", "More Precise"}})
        Menu.Q:MenuElement({id = "Mana"       , name = "Min Mana %"            , value = 15, min = 0, max = 100, step = 1})
        Menu.Q:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.Q:MenuElement({id = "Harass"     , name = "Use on Harass"         , value = true})
        Menu.Q:MenuElement({id = "StackHarass", name = "Save To Proc 3 Stacks" , value = false})
        Menu.Q:MenuElement({id = "PredHarass" , name = "Prediction Mode"       , value = 1 , drop = {"Faster", "More Precise"}})
        Menu.Q:MenuElement({id = "ManaHarass" , name = "Min Mana %"            , value = 15, min = 0, max = 100, step = 1})
        Menu.Q:MenuElement({name = " ", drop = {"Misc"}})        
        Menu.Q:MenuElement({id = "KS"         , name = "Use on KS"             , value = true})                  
        --W--
        Menu.W:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.W:MenuElement({id = "Combo"      , name = "Use on Combo"           , value = true})
        Menu.W:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.W:MenuElement({id = "Harass"     , name = "Use on Harass"          , value = true})     
        --E--
        Menu.E:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.E:MenuElement({id = "Combo"      , name = "Use on Combo"           , value = true})
        Menu.E:MenuElement({id = "Stack"      , name = "Save To Proc 3 Stacks"  , value = true})
        Menu.E:MenuElement({id = "Mana"       , name = "Min Mana %"             , value = 15, min = 0, max = 100, step = 1})
        Menu.E:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.E:MenuElement({id = "Harass"     , name = "Use on Harass"          , value = false})
        Menu.E:MenuElement({id = "StackHarass", name = "Save To Proc 3 Stacks"  , value = true})
        Menu.E:MenuElement({id = "ManaHarass" , name = "Min Mana %"             , value = 15, min = 0, max = 100, step = 1})        
        Menu.E:MenuElement({name = " ", drop = {"Misc"}})
        Menu.E:MenuElement({id = "KS"         , name = "Use on KS"              , value = true})
        Menu.E:MenuElement({id = "Flee"       , name = "Use on Flee"            , value = true})     
        --R--
        Menu.R:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.R:MenuElement({id = "Combo"      , name = "Use on Duel"             , value = true})
        Menu.R:MenuElement({id = "Min"        , name = "Min Target HP%"          , value = 15, min = 0, max = 100, step = 1})
        Menu.R:MenuElement({id = "Heroes"     , name = "Duel Targets"                 ,   type = MENU })
            Menu.R.Heroes:MenuElement({id = "Loading", name = "Loading Champions...",   type = SPACE})
        Menu.R:MenuElement({name = " ", drop = {"Misc"}})
        Menu.R:MenuElement({id = "Peel"       , name = "Auto Use To Peel"        , value = true})                
        Menu.R:MenuElement({id = "PeelList"   , name = "Whitelist"                      , type = MENU })
            Menu.R.PeelList:MenuElement({id = "Loading", name = "Loading Champions...", type = SPACE})
        Menu.R:MenuElement({id = "Gapcloser"  , name = "Auto Use On Dash"        , value = true})
        Menu.R:MenuElement({id = "GapList"    , name = "Whitelist"                     ,  type = MENU })
            Menu.R.GapList:MenuElement({id = "Loading", name = "Loading Champions...",  type = SPACE})
        Menu.R:MenuElement({id = "Auto"       , name = "Auto Use On Immobile"    , value = true})  
        --          
        Menu:MenuElement({name = "[WR] "..charName.." Script", drop = {"Release_"..self.scriptVersion}})
        --
        self.menuLoadRequired = true
        Callback.Add("Tick", function() self:MenuLoad() end)
    end

    function Varus:MenuLoad()
        if self.menuLoadRequired then 
            local count = HeroCount()
            if count == 1 then return end 
            for i = 1, count do 
                local hero = Hero(i)
                local charName = hero.charName
                if hero.team == TEAM_ENEMY then 
                    Menu.R.Heroes  :MenuElement({id = charName, name = charName, value = false, leftIcon = "https://raw.githubusercontent.com/rman200/WinRateEXT/master/Icons/champions/"..charName..".png"})                   
                    Menu.R.PeelList:MenuElement({id = charName, name = charName, value = true, leftIcon = "https://raw.githubusercontent.com/rman200/WinRateEXT/master/Icons/champions/"..charName..".png"})
                    Menu.R.GapList :MenuElement({id = charName, name = charName, value = true, leftIcon = "https://raw.githubusercontent.com/rman200/WinRateEXT/master/Icons/champions/"..charName..".png"})
                end
            end   
            Menu.R.Heroes.Loading:Hide(true)                 
            Menu.R.PeelList.Loading:Hide(true)
            Menu.R.GapList .Loading:Hide(true)
            self.menuLoadRequired = nil         
        else
            Callback.Del("Tick", function() self:MenuLoad() end)
        end
    end 

    function Varus:OnTick() 
        if ShouldWait() then return end 
        --        
        self.enemies = GetEnemyHeroes(self.Q.MaxRange)
        self.target = GetTarget(GetTrueAttackRange(myHero), 0)
        self.mode = GetMode() 
        --
        self:LogicQ()               
        if myHero.isChanneling then return end        
        self:Auto()
        self:KillSteal()
        --
        if not self.mode then return end        
        local executeMode = 
            self.mode == 1 and self:Combo()   or 
            self.mode == 2 and self:Harass()  or
            self.mode == 6 and self:Flee()      
    end

    function Varus:OnPreMovement(args) --args.Process|args.Target
        if ShouldWait() then 
            args.Process = false
            return 
        end 
    end

    function Varus:OnPreAttack(args) --args.Process|args.Target
        if self.Charging or ShouldWait() then 
            args.Process = false 
            return
        end 
    end

    function Varus:OnDash(unit, unitPos, unitPosTo, dashSpeed, dashGravity, dashDistance)  
        if ShouldWait() or not (self.R:IsReady() and Menu.R.Gapcloser:Value()) then return end   
        if IsValidTarget(unit) and GetDistance(unitPosTo) < 500 and unit.team == TEAM_ENEMY and Menu.R.GapList[unit.charName] and Menu.R.GapList[unit.charName]:Value() and IsFacing(unit, myHero) then --Gapcloser 
            self.R:CastToPred(unit, 3)                   
        end
    end 

    function Varus:Auto()
        if not self.R:IsReady() then return end
        local autoCheck, peelCheck = Menu.R.Auto:Value(), Menu.R.Peel:Value()
        if autoCheck or peelCheck then
            for i=1, #self.enemies do
                local enemy = self.enemies[i]                
                if autoCheck and GetDistance(enemy) <= self.R.Range and IsImmobile(enemy, 0.5) then                             
                    self.R:Cast(enemy)                   
                end   
                if peelCheck and GetDistance(enemy) <= 400 and Menu.R.PeelList[enemy.charName] and Menu.R.PeelList[enemy.charName]:Value() then
                    self.R:CastToPred(enemy, 2) 
                end
            end 
        end                              
    end

    function Varus:Combo()
        local target = GetTarget(self.R.Range, 0) 
        if not IsValidTarget(target) then return end               
        --
        local validTarg = Menu.R.Heroes[target.charName] and Menu.R.Heroes[target.charName]:Value() and HealthPercent(target) >= Menu.R.Min:Value()
        if Menu.R.Combo:Value() and validTarg and HealthPercent(myHero) <= 60 then            
            self.R:CastToPred(target, 2)
        end     
        if Menu.E.Combo:Value() and ManaPercent(myHero) >= Menu.E.Mana:Value() then
            local waitForStacks = self.mode == 1 and Menu.E.Stack:Value()
            local target = self:GetBestTarget(waitForStacks, self.E.Range)
            if target then            
                self.E:CastToPred(target, 2)
            end
        end            
    end

    function Varus:Harass() 
        local waitForStacks = self.mode == 2 and Menu.E.StackHarass:Value()
        local target = self:GetBestTarget(waitForStacks, self.E.Range)
        if not IsValidTarget(target) then return end
        --        
        if Menu.E.Harass:Value() and ManaPercent(myHero) >= Menu.E.ManaHarass:Value() then
            self.E:CastToPred(target, 2)
        end       
    end

    function Varus:Flee() 
        if not self.E:IsReady() then return end
        for i=1, #self.enemies do 
            local enemy = self.enemies[i]
            if Menu.E.Flee:Value() then
                self.E:CastToPred(enemy, 2)
            end 
        end      
    end

    function Varus:KillSteal()
    end

    function Varus:OnDraw()
        DrawSpells(self)   
    end

    function Varus:LogicQ()
        self.Charging = self:IsCharging()
        self:UpdateCharge()        
                              
        if not (self.Q:IsReady() and #self.enemies >= 1 and self.mode and self.mode <= 2) then return end
        --
        local isCombo, isHarass = self.mode == 1, self.mode == 2 
        local waitForStacks = ((isCombo and Menu.Q.Stack:Value()) or (isHarass and Menu.Q.StackHarass:Value()))
        local target = self:GetBestTarget(waitForStacks, self.Q.Range)
        --        
        if not self:IsCastE(target) then return end        
        if target or not waitForStacks then
            if not self.Charging then
                if isCombo and ManaPercent(myHero) >= Menu.Q.Mana:Value() or isHarass and ManaPercent(myHero) >= Menu.Q.ManaHarass:Value() then
                    self.W:Cast()                
                    KeyDown(HK_Q)
                end
            elseif target then
                local minHitChance = isCombo and Menu.Q.Pred:Value() or isHarass and Menu.Q.PredHarass:Value()
                local bestPos, castPos, hC = self.Q:GetPrediction(target)
                if bestPos and hC >= minHitChance then
                    print("release")
                    self:ReleaseSpell(bestPos)
                end
            end
        end       
    end

    function Varus:UpdateCharge()        
        if self.Charging then
            self.Q.Range = min(975 + 425 * (Timer() - myHero.activeSpell.startTime), 1550)
        else
            self.Q.Range = 975
            if IsKeyDown(HK_Q) then
                DelayAction(function() 
                    if IsKeyDown(HK_Q) and not self.Charging then
                        KeyUp(HK_Q)
                    end
                end, Latency() * 2 /1000)
            end
        end  
    end

    function Varus:GetBestTarget(waitStacks, range)
        local lowestHealth, bestTarget =  10000, nil
        for i=1, #self.enemies do
            local enemy = self.enemies[i]
            local health = enemy.health            
            if health <= lowestHealth and IsValidTarget(enemy, range) and (not waitStacks or self:GetStacks(enemy) == 3) then
                bestTarget   = enemy         
                lowestHealth = health     
            end
        end        
        return bestTarget
    end

    local spellData = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
    function Varus:ReleaseSpell(pos)    --Noddy's Cast Method adapted to my needs
        if ShouldWait() then return end
        local ticker, latency = GetTickCount(), Latency()        
        if spellData.state == 0 and GetDistance(myHero.pos,pos) < self.Q.Range and ticker - spellData.casting > self.Q.Delay + latency then
            spellData.state = 1
            spellData.mouse = mousePos
            spellData.tick = ticker
        end
        if spellData.state == 1 then            
            if ticker - spellData.tick < latency then
                if not pos:ToScreen().onScreen then
                    local dist = GetDistance(pos)
                    repeat 
                        dist = dist - 100
                        pos = myHero.pos:Extended(pos, dist) 
                    until (pos:ToScreen().onScreen)
                end 
                local pos2 = pos:To2D()
                Control.LeftClick(pos2.x, pos2.y)                          
                spellData.casting = ticker 
                DelayAction(function()
                    if spellData.state == 1 then
                        SetCursorPos(spellData.mouse)
                        spellData.state = 0
                    end
                end,latency/1000)
            end
            if ticker - spellData.casting > latency then
                SetCursorPos(spellData.mouse)
                spellData.state = 0
            end
        end
    end

    function Varus:IsCharging()
        local spell = myHero.activeSpell
        return spell and spell.valid and spell.name == "VarusQ"
    end

    function Varus:GetStacks(target)        
        local buff = GetBuffByName(target, "VarusWDebuff")     
        return buff and buff.expireTime >= Timer() and buff.count
    end

    function Varus:IsCastE(target)
        local spell = myHero:GetSpellData(_E)
        local checkMode = (self.mode == 1 and Menu.E.Combo:Value() and ManaPercent(myHero) >= Menu.E.Mana:Value()) or (self.mode == 3 and Menu.E.Harass:Value() and ManaPercent(myHero) >= Menu.E.ManaHarass:Value())
        return (not target or GetDistance(target) > self.E.Range) or (checkMode and spell.currentCd ~= 0 and spell.cd - spell.currentCd >= 1)
    end


    Varus()
