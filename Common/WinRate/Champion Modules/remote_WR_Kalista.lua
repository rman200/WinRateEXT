
    local Kalista = {}  

    function Kalista:__init()
        --[[Data Initialization]]
        self.recentTargets = {}
        self.rendDmg = {}
        self.Color1 = DrawColor(255, 35, 219, 81)
        self.Color2 = DrawColor(255, 216, 121, 26)
        self.SentinelSpots = {
            Baron  = {obj = false, pos = Vector(4956, 0, 10444)}, 
            Dragon = {obj = false, pos = Vector(9866, 0, 4414)},
            Mid    = {obj = false, pos = Vector(8428, 0, 6465)},
            Blue   = {obj = false, pos = Vector(3871, 0, 7901)},
            Red    = {obj = false, pos = Vector(7862, 0, 4111)},        
            Mid2   = {obj = false, pos = Vector(6545, 0, 8361)},
            Blue2  = {obj = false, pos = Vector(10931, 0, 6990)},
            Red2   = {obj = false, pos = Vector(7016, 0, 10775)},
        }
        self.supportedAllies = {
            ["Blitzcrank"] = "tahmkenchwdevoured",
            ["Skarner"]    = "SkarnerImpale",
            ["TahmKench"]  = "tahmkenchwdevoured"            
        }
        self.scriptVersion = "1.0"
        self:Spells()
        self:Menu() 
        --[[Default Callbacks]]
        Callback.Add("Tick",          function() self:OnTick()    end)
        Callback.Add("Draw",          function() self:OnDraw()    end)
        Callback.Add("WndMsg",        function(msg, param) self:OnWndMsg(msg, param) end)   
        --[[Orb Callbacks]]
        OnPreAttack(function(...) self:OnPreAttack(...)   end)
        OnAttack(function(...) self:OnAttack(...)   end)
        OnUnkillableMinion(function(...) self:OnUnkillable(...)  end)
        --[[Custom Callbacks]]        
        OnLoseVision(function(unit) self:OnLoseVision(unit) end)        
    end

    function Kalista:Spells()
        self.Q = Spell({
            Slot = 0,
            Range = 1150,
            Delay = 0.35,
            Speed = 2100,
            Radius = 70,
            Collision = true,
            From = myHero,
            Type = "SkillShot"
        })
        self.W = Spell({
            Slot = 1,
            Range = 5000,
            Delay = 0.25,
            Speed = 450,
            Radius = 100,
            Collision = false,
            From = myHero,
            Type = "AOE"
        })
        self.E = Spell({
            Slot = 2,
            Range = 1000,
            Delay = 0.25,
            Speed = huge,
            Radius = 100,
            Collision = false,
            From = myHero,
            Type = "Press"
        })
        self.R = Spell({
            Slot = 3,
            Range = 1200,
            Delay = 0.85,
            Speed = huge,
            Radius = 150,
            Collision = false,
            From = myHero,
            Type = "Press"
        })
        self.W.LastCast = Timer()
        self.W.LastSpot = nil
        --
        self.W.GetDamage = function(spellInstance, enemy, stage)
            local wLvl = myHero:GetSpellData(_W).level
            local baseDmg = 5 * wLvl
            --
            if HasBuff(enemy, "kalistacoopstrikeally")  then
                if enemy.type == Obj_AI_Minion and enemy.health <= 125 then          
                    return enemy.health
                end
                return baseDmg + (0.025 + 0.025 * wLvl) * enemy.maxHealth
            end
            return baseDmg
        end
        self.E.GetDamage = function(spellInstance, enemy, stage)
            if not spellInstance:IsReady() then return 0 end
            --
            local buff = self.recentTargets[enemy.networkID] and self.recentTargets[enemy.networkID].buff
            if buff and buff.count > 0 then
                local eLvl = myHero:GetSpellData(_E).level 
                local baseDmg = 10+ 10*eLvl + 0.6 * myHero.totalDamage
                local dmgPerSpear = (eLvl * (eLvl*0.5 + 2.5) + 7) + (3.75*eLvl + 16.25) * myHero.totalDamage/100
                --
                return baseDmg + dmgPerSpear * buff.count                
            end
            return 0
        end
    end

    function Kalista:Menu()
        --Q--
        Menu.Q:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.Q:MenuElement({id = "Combo", name = "Use on Combo", value = true})
        Menu.Q:MenuElement({id = "Mana", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.Q:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.Q:MenuElement({id = "Harass", name = "Use on Harass", value = true})
        Menu.Q:MenuElement({id = "ManaHarass", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.Q:MenuElement({name = " ", drop = {"Farm Settings"}})
        Menu.Q:MenuElement({id = "Unkillable", name = "Use on Unkillable", value = false})
        Menu.Q:MenuElement({id = "ManaClear", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.Q:MenuElement({name = " ", drop = {"Misc"}})
        --Menu.Q:MenuElement({id = "Wall"  , name = "Use to WallJump [Flee Key]", value = true})                   
        --W--
        Menu.W:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.W:MenuElement({id = "Combo", name = "Use on Combo", value = true})
        Menu.W:MenuElement({id = "Mana", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.W:MenuElement({name = " ", drop = {"Misc"}})
        Menu.W:MenuElement({id = "Draw", name = "Draw Spots", value = true})
        Menu.W:MenuElement({id = "Key" , name = "Send Sentinel [Closest To Mouse]", key = string.byte("G")})
        Menu.W:MenuElement({id = "Dra", name = "Dragon", value = true}) 
        Menu.W:MenuElement({id = "Bar" , name = "Baron[Exploit]" , value = true})
        Menu.W:MenuElement({id = "Mid"   , name = "Mid"   , value = true})
        Menu.W:MenuElement({id = "Blu"  , name = "Blue"  , value = true})
        Menu.W:MenuElement({id = "Red"   , name = "Red"   , value = true})      
        --E--
        Menu.E:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.E:MenuElement({id = "Combo", name = "Use on Combo", value = true})
        Menu.E:MenuElement({id = "Mana", name = "Min Mana %", value = 0, min = 0, max = 100, step = 1})
        Menu.E:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.E:MenuElement({id = "Harass", name = "Use on Harass", value = false})
        Menu.E:MenuElement({id = "ManaHarass", name = "Min Mana %", value = 0, min = 0, max = 100, step = 1})
        Menu.E:MenuElement({name = " ", drop = {"Farm Settings"}})
        Menu.E:MenuElement({id = "LastHit", name = "Use on LastHit" , value = true})
        Menu.E:MenuElement({id = "Jungle" , name = "Use on JungleClear", value = false})
        Menu.E:MenuElement({id = "Clear", name = "Use on LaneClear", value = false})
        Menu.E:MenuElement({id = "Min"  , name = "Minions To Cast" , value = 2, min = 0, max = 6, step = 1})
        Menu.E:MenuElement({id = "ManaClear", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.E:MenuElement({name = " ", drop = {"Misc"}}) 
        Menu.E:MenuElement({id = "Epic" , name = "Steal Baron/Dragon", value = true})       
        Menu.E:MenuElement({id = "KS"   , name = "Use on KS", value = true})
        Menu.E:MenuElement({id = "Dying", name = "Use When Dying", value = true})
        Menu.E:MenuElement({id = "MinHP", name = "   HP <= X %", value = 15, min = 5, max = 100, step = 5})
        Menu.E:MenuElement({id = "DmgMod", name = "Dmg Calculations Multiplier", value = 1, min = 0.1, max = 5, step = 0.1})
        
        --R--
        Menu.R:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.R:MenuElement({id = "Combo", name = "Use on Combo", value = true})
        Menu.R:MenuElement({id = "Count", name = "Min Enemies Around", value = 2, min = 1, max = 5, step = 1})
        Menu.R:MenuElement({id = "Mana", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})        
        Menu.R:MenuElement({name = " ", drop = {"Oath Settings"}})
        Menu.R:MenuElement({id = "Save" , name = "Save Ally", value = true})
        Menu.R:MenuElement({id = "MinHP", name = "When HP% < X", value = 20, min = 1, max = 100, step = 1})
        Menu.R:MenuElement({name = " ", drop = {"Balista Settings"}})
        Menu.R:MenuElement({id = "Balista"  , name = "Pull Enemy", value = true})
        Menu.R:MenuElement({id = "BalistaHP", name = "Only If HP% > X", value = 20, min = 1, max = 100, step = 1})
        Menu.R:MenuElement({id = "Turret"   , name = "Only Under Turret", value = false})

        Menu:MenuElement({name = "[WR] "..charName.." Script", drop = {"Release_"..self.scriptVersion}})
    end

    function Kalista:OnTick() 
        if ShouldWait() then return end 
        --        
        self.enemies = GetEnemyHeroes(self.R.Range+1000)
        self.target = GetTarget(GetTrueAttackRange(myHero), 0)
        self.lastTarget = self.target or self.lastTarget 
        self.mode = GetMode() 
        --               
        if myHero.isChanneling then return end
        self.rendDmg = {}        
        self:SentinelManager()  
        self:OathManager()      
        self:Auto()
        --
        if not self.mode then return end        
        local executeMode = 
            self.mode == 1 and self:Combo()   or 
            self.mode == 2 and self:Harass()  or
            self.mode == 6 and self:Flee()                
    end

    function Kalista:OnWndMsg(msg, param)
        if param == HK_W then
            DelayAction(function()
                self:FindSentinels()
            end, 0.25)            
        end
    end

    function Kalista:OnPreAttack(args)
        local target = args.Target
        local tType = target and target.type
        if not (IsValidTarget(target) and (tType == Obj_AI_Hero or tType == Obj_AI_Minion)) then return end
        --
        local netID = target.networkID
        local rendTarget = self.recentTargets[netID]
        if not rendTarget then
            self.recentTargets[netID] = {obj = target, buff = GetBuffByName(target, "kalistaexpungemarker")}
        end
    end

    function Kalista:OnAttack()
        local target = GetTargetByHandle(myHero.attackData.target)
        local tType = target and target.type
        if not (IsValidTarget(target) and (tType == Obj_AI_Hero or tType == Obj_AI_Minion)) then return end
        --
        local netID = target.networkID
        local rendTarget = self.recentTargets[netID]
        if not rendTarget then
            self.recentTargets[netID] = {obj = target, buff = GetBuffByName(target, "kalistaexpungemarker")}
        end
    end

    function Kalista:OnUnkillable(minion)
        if self.Q:IsReady() and Menu.Q.Unkillable:Value() and ManaPercent(myHero) >= Menu.Q.ManaClear:Value() then
            local col = mCollision(myHero, minion, self.Q, GetEnemyMinions(self.Q.Range))
            for i=1, #col do
                local min = col[i]
                if min ~= minion then
                    return
                end
            end
            self.Q:Cast(minion)
        end        
    end

    function Kalista:OnLoseVision(unit)  
        if self.mode == 1 and self.W:IsReady() and self.lastTarget and unit.valid and not unit.dead and unit.networkID == self.lastTarget.networkID  then
            if Menu.W.Combo:Value() and ManaPercent(myHero) >= Menu.W.Mana:Value() then
                self.W:Cast(unit.pos)
            end
        end      
    end

    function Kalista:Auto()
        if not self.E:IsReady() then return end
        if Menu.E.Dying:Value() and HealthPercent(myHero) < Menu.E.MinHP:Value() then
            self.E:Cast(); return
        end        
        --
        local KS, Epic = Menu.E.KS:Value(), Menu.E.Epic:Value()
        local eCombo  = not KS and self.mode == 1 and Menu.E.Combo:Value() and ManaPercent(myHero) >= Menu.E.Mana:Value() 
        local eHarass = not (KS or eCombo) and self.mode == 2 and Menu.E.Harass:Value() and ManaPercent(myHero) >= Menu.E.ManaHarass:Value()
        local eClear  = not (eCombo or eHarass) and ((self.mode == 3 and Menu.E.Clear:Value()) or (self.mode == 4 and Menu.E.Jungle:Value()) or (self.mode == 5 and Menu.E.LastHit:Value())) and ManaPercent(myHero) >= Menu.E.ManaClear:Value()
        --
        if not (KS or Epic or eCombo or eHarass or eClear) then return end
        local killableMinions, minMinions = 0, Menu.E.Min:Value()        
        local manaCheck = myHero.mana >= 60       
        --
        for netID, rendData in pairs(self.recentTargets) do
            local target = rendData.obj
            local tType = target.type
            -- 
            if IsValidTarget(target, self.E.Range) then                
                if tType == Obj_AI_Minion and (eClear or Epic) then
                    local DmgPercent = self:DmgPercent(target)
                    if DmgPercent > 100 then
                        killableMinions = killableMinions + 1 
                        if target.team == 300 and Epic and (target.charName:lower():find("dragon") or target.charName == "SRU_Baron" or target.charName == "SRU_RiftHerald") then
                            self.E:Cast(); return
                        end                       
                    end
                elseif tType == Obj_AI_Hero and (KS or eCombo or eHarass) then
                    local DmgPercent = self:DmgPercent(target) 
                    if DmgPercent > 100 or (manaCheck and killableMinions >= 1) then              
                        self.E:Cast(); return
                    end
                end
            end
        end
        --        
        if eClear and killableMinions >= minMinions then
            self.E:Cast()
        end
    end

    function Kalista:Combo() 
        if #self.enemies >= 1 and not self.target then   
            --attack minions to gapclose
        end
        --
        local qTarget = GetTarget(self.Q.Range, 0) 
        if qTarget and self.Q:IsReady() and Menu.Q.Combo:Value() and ManaPercent(myHero) >= Menu.Q.Mana:Value() then
            self.Q:CastToPred(qTarget, 2)
        end
    end

    function Kalista:Harass()
        if #self.enemies >= 1 and not self.target then   
            --attack minions to gapclose
        end
        --
        local qTarget = GetTarget(self.Q.Range, 0) 
        if qTarget and self.Q:IsReady() and Menu.Q.Combo:Value() and ManaPercent(myHero) >= Menu.Q.Mana:Value() then
            self.Q:CastToPred(qTarget, 2)
        end        
    end

    function Kalista:Flee()
        if self.Q:IsReady() and Menu.Q.Wall:Value() then
            --TODO walljump logic
        end     
    end

    function Kalista:OnDraw()
        self:UpdateTargets()
        self:DrawSpots()        
        DrawSpells(self, function(enemy)
            local screenPos = enemy.pos:To2D()
            if screenPos.onScreen then
                DrawText(tostring(self:DmgPercent(enemy))..'%', 40, screenPos.x, screenPos.y, Color.Green)                
            end        
        end)        
    end

    function Kalista:SentinelManager()
        self:UpdateSentinels()
        if Menu.W.Key:Value() and self.W:IsReady() and Timer() - self.W.LastCast > 1 then
            local closestToMouse, bestDistance = nil, 3000
            for k, spot in pairs(self.SentinelSpots) do                
                if GetDistance(spot) <= self.W.Range and spot.obj == nil then
                    local id = k:sub(1,3)
                    local dist = GetDistance(mousePos, spot)
                    if Menu.W[id]:Value() and dist <= bestDistance then                        
                        closestToMouse = spot 
                        bestDistance = dist
                        self.W.LastSpot = k                        
                    end
                end
            end
            if closestToMouse then                
                self.W:Cast(closestToMouse.pos)
                self.W.LastCast = Timer()                
            end
        end
    end

    function Kalista:DrawSpots()   
        if Menu.W.Draw:Value() then     
            for k, spot in pairs(self.SentinelSpots) do
                if GetDistance(spot) <= self.W.Range then                 
                    DrawMap(spot.pos, 200, 5, spot.obj and self.Color1 or self.Color2)
                end
            end
        end
    end

    function Kalista:FindSentinels()        
        for i = ObjectCount(), 1, -1 do
            local obj = Object(i);
            if obj and obj.isAlly and obj.charName == 'KalistaSpawn' then                
                self.SentinelSpots[self.W.LastSpot].obj = obj                                
            end
        end
    end
    
    function Kalista:UpdateSentinels()
        for k, spot in pairs(self.SentinelSpots) do
            local obj = spot.obj
            if not obj or not obj.valid or obj.dead then   
                self.SentinelSpots[k].obj = nil 
            end
        end
    end   

    function Kalista:UpdateTargets()        
        local time = Timer()
        --        
        for netID, rendData in pairs(self.recentTargets) do
            local buff = rendData.buff
            local enemy = rendData.obj
            if not (enemy and enemy.valid) or enemy.dead then
                self.recentTargets[netID] = nil
            else
                self.recentTargets[netID].buff = GetBuffByName(enemy, "kalistaexpungemarker")
                if enemy.team == 300 then
                    local screenPos = enemy.pos:To2D()
                    if screenPos.onScreen then
                        DrawText(tostring(self:DmgPercent(enemy))..'%', 40, screenPos.x, screenPos.y, Color.Green)                
                    end
                end                
            end
        end
    end

    function Kalista:DmgPercent(target)        
        if self.rendDmg[target.networkID] then
            return self.rendDmg[target.networkID]
        end
        --
        local dmg = floor((self.E:CalcDamage(target) * 100 * Menu.E.DmgMod:Value()/(target.health+target.shieldAD))*100)/100
        self.rendDmg[target.networkID] = dmg
        return dmg
    end

    function Kalista:GetSwornAlly()   
        for i = 1, HeroCount() do
            local hero = Hero(i)
            if hero and not hero.isMe and hero.isAlly and HasBuff(hero, "kalistacoopstrikeally") then            
                return hero
            end
        end 
    end

    function Kalista:OathManager()
        if not self.swornAlly then
            self.swornAlly = self:GetSwornAlly()
        end
        --
        local ally = self.swornAlly        
        if self.R:IsReady() and ally and GetDistance(ally) < self.R.Range then
            local Menu = Menu.R
            --[[Combo Stuff]]
            if self.mode == 1 and Menu.Combo:Value() and ManaPercent(myHero) >= Menu.R.Mana:Value() then
                if CountEnemiesAround(myHero.pos, self.R.Range) > Menu.Count:Value() then
                    self.R:Cast(); return
                end
            end
            --[[Balista Stuff]]
            local balistaBuff = self.supportedAllies[ally.charName]
            local balistaCheck = balistaBuff and (not Menu.Turret:Value() or IsUnderTurret(myHero.pos, TEAM_ALLY))
            if Menu.Balista:Value() and balistaCheck and HealthPercent(myHero) >= Menu.BalistaHP:Value() then
                for i = 1, #self.enemies do
                    local enemy = self.enemies[i]
                    if enemy and HasBuff(enemy, balistaBuff) then            
                        self.R:Cast(); return
                    end
                end 
            end
            --[[Save Ally]]
            if Menu.Save:Value() and HealthPercent(ally) <= Menu.MinHP:Value() then
                self.R:Cast(); return
            end
        end
    end   

    Kalista:__init()
