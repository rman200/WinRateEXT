class 'Lucian'

function Lucian:__init()
        --// Data Initialization //--

        self.scriptVersion = "1.0"

        self:Spells()
        self:Menu()

        --// Callbacks //--

        Callback.Add("Tick", function() self:OnTick() end)
        Callback.Add("Draw", function() self:OnDraw() end)
        OnPreAttack(function(...) self:OnPreAttack(...) end)
        OnPostAttack(function(...) self:OnPostAttack(...) end)
        OnPreMovement(function(...) self:OnPreMovement(...) end)
end

function Lucian:Spells()
        self.Q = Spell({
                Slot = 0,
                Range = 650,
                Delay = 0.35,
                Speed = huge,
                Radius = 30,
                Collision = false,
                From = myHero,
                Type = "Targetted"
        })

        self.Q2 = Spell({
                Slot = 0,
                Range = 900,
                Delay = 0.35,
                Speed = huge,
                Radius = 30,
                Collision = false,
                From = myHero,
                Type = "Targetted"
        })

        self.W = Spell({
                Slot = 1,
                Range = 1000,
                Delay = 0.30,
                Speed = 1600,
                Radius = 40,
                Collision = true,
                From = myHero,
                Type = "Skillshot"
        })

        self.E = Spell({
                Slot = 2,
                Range = 425,
                Type = "Skillshot"
        })

        self.R = Spell({
                Slot = 3,
                Range = 1200,
                Delay = 0.25,
                Speed = huge,
                Radius = 50,
                Collision = true,
                From = myHero,
                Type = "Skillshot"
        })
end

function Lucian:Menu()
        -- Q SETTINGS
        Menu.Q:MenuElement({name = " ", drop = {"Modes"}})
        Menu.Q:MenuElement({id = "Combo", name = "Combo", value = true})
        Menu.Q:MenuElement({id = "Harass", name = "Harass", value = true})
        Menu.Q:MenuElement({id = "KS", name = "KillSteal", value = true})
        Menu.Q:MenuElement({name = " ", drop = {"Mana Manager"}})
        Menu.Q:MenuElement({id = "ComboMana", name = "Combo - Min. Mana(%)", value = 0, min = 0, max = 100})
        Menu.Q:MenuElement({id = "HarassMana", name = "Harass - Min. Mana(%)", value = 50, min = 0, max = 100})
        Menu.Q:MenuElement({name = " ", drop = {"Customization"}})
        Menu.Q:MenuElement({type = MENU, name = "Harass White List", id = "HarassWhiteList"})
        Menu.Q.HarassWhiteList:MenuElement({id = "info", name = "Detecting Heroes, Please Wait...", drop = {" "}})
        Menu.Q:MenuElement({type = MENU, name = "KillSteal White List", id = "KSWhiteList"})
        Menu.Q.KSWhiteList:MenuElement({id = "info", name = "Detecting Heroes, Please Wait...", drop = {" "}})

        -- Q2 SETTINGS
        Menu.Q2:MenuElement({name = " ", drop = {"Modes"}})
        Menu.Q2:MenuElement({id = "Combo", name = "Combo", value = true})
        Menu.Q2:MenuElement({id = "Harass", name = "Harass", value = true})
        Menu.Q2:MenuElement({id = "AutoHarass", name = "Auto Harass", value = true})
        Menu.Q2:MenuElement({name = " ", drop = {"Mana Manager"}})
        Menu.Q2:MenuElement({id = "ComboMana", name = "Combo - Min. Mana(%)", value = 0, min = 0, max = 100})
        Menu.Q2:MenuElement({id = "HarassMana", name = "Harass - Min. Mana(%)", value = 50, min = 0, max = 100})
        Menu.Q2:MenuElement({id = "AutoHarassMana", name = "Auto Harass - Min. Mana(%)", value = 50, min = 0, max = 100})
        Menu.Q2:MenuElement({name = " ", drop = {"Customization"}})
        Menu.Q2:MenuElement({type = MENU, name = "Harass White List", id = "HarassWhiteList"})
        Menu.Q2.HarassWhiteList:MenuElement({id = "info", name = "Detecting Heroes, Please Wait...", drop = {" "}})
        Menu.Q2:MenuElement({type = MENU, name = "Auto Harass White List", id = "AutoHarassWhiteList"})
        Menu.Q2.AutoHarassWhiteList:MenuElement({id = "info", name = "Detecting Heroes, Please Wait...", drop = {" "}})

        -- W SETTINGS
        Menu.W:MenuElement({name = " ", drop = {"Modes"}})
        Menu.W:MenuElement({id = "Combo", name = "Combo", value = true})
        Menu.W:MenuElement({id = "Harass", name = "Harass", value = true})
        Menu.W:MenuElement({id = "KS", name = "KillSteal", value = true})
        Menu.W:MenuElement({name = " ", drop = {"Mana Manager"}})
        Menu.W:MenuElement({id = "ComboMana", name = "Combo - Min. Mana(%)", value = 0, min = 0, max = 100})
        Menu.W:MenuElement({id = "HarassMana", name = "Harass - Min. Mana(%)", value = 50, min = 0, max = 100})
        Menu.W:MenuElement({name = " ", drop = {"Customization"}})
        Menu.W:MenuElement({id = "IgnorePred", name = "Ignore Prediction", value = true})
        Menu.W:MenuElement({id = "IgnoreColl", name = "Ignore Collision", value = true})
        Menu.W:MenuElement({type = MENU, name = "Harass White List", id = "HarassWhiteList"})
        Menu.W.HarassWhiteList:MenuElement({id = "info", name = "Detecting Heroes, Please Wait...", drop = {" "}})
        Menu.W:MenuElement({type = MENU, name = "KillSteal White List", id = "KSWhiteList"})
        Menu.W.KSWhiteList:MenuElement({id = "info", name = "Detecting Heroes, Please Wait...", drop = {" "}})

        -- E SETTINGS
        Menu.E:MenuElement({name = " ", drop = {"Modes"}})
        Menu.E:MenuElement({id = "Combo", name = "Combo", value = true})
        Menu.E:MenuElement({name = " ", drop = {"Mana Manager"}})
        Menu.E:MenuElement({id = "ComboMana", name = "Combo - Min. Mana(%)", value = 0, min = 0, max = 100})
        Menu.E:MenuElement({name = " ", drop = {"Customization"}})
        Menu.E:MenuElement({name = "E Cast Mode", id = "Mode", value = 1, drop = {"To Side", "To Mouse", "To Target"}})

        -- R SETTINGS
        Menu.R:MenuElement({name = " ", drop = {"Modes"}})
        Menu.R:MenuElement({id = "Combo", name = "Combo", value = true})
        Menu.R:MenuElement({name = " ", drop = {"Mana Manager"}})
        Menu.R:MenuElement({id = "ComboMana", name = "Combo - Min. Mana(%)", value = 0, min = 0, max = 100})
        Menu.R:MenuElement({name = " ", drop = {"Customization"}})
        Menu.R:MenuElement({id = "Magnet",name = "Target Magnet", value = true})
        Menu.R:MenuElement({type = MENU, name = "Combo White List", id = "ComboWhiteList"})
        Menu.R.ComboWhiteList:MenuElement({id = "info", name = "Detecting Heroes, Please Wait...", drop = {" "}})

        -- OTHER
        Menu:MenuElement({name = " ", drop = {"Extra Settings"}})
        Menu:MenuElement({name = "Combo Rotation Priority",  id = "ComboRotation", value = 3, drop = {"Q", "W", "E"}})
        Menu:MenuElement({name = " ", drop = {"Script Info"}})
        Menu:MenuElement({name = myHero.charName.." Script version: ", drop = {self.scriptVersion}})

        self.menuLoadRequired = true
        Callback.Add("Tick", function() self:MenuLoad() end)
end

function Lucian:MenuLoad()
        if self.menuLoadRequired then
                local count = HeroCount()
                if count == 1 then return end 

                for i = 1, count do 
                        local unit = Hero(i)
                        local charName = unit.charName

                        if unit.team == TEAM_ENEMY then
                                local icon = "https://raw.githubusercontent.com/rman200/WinRateEXT/master/Icons/champions/" .. charName .. ".png"

                                Menu.Q.HarassWhiteList:MenuElement({name = unit.charName, id = unit.charName, value = true, leftIcon = icon})
                                Menu.Q.KSWhiteList:MenuElement({name = unit.charName, id = unit.charName, value = true, leftIcon = icon})

                                Menu.Q2.HarassWhiteList:MenuElement({name = unit.charName, id = unit.charName, value = true, leftIcon = icon})
                                Menu.Q2.AutoHarassWhiteList:MenuElement({name = unit.charName, id = unit.charName, value = true, leftIcon = icon})

                                Menu.W.HarassWhiteList:MenuElement({name = unit.charName, id = unit.charName, value = true, leftIcon = icon})
                                Menu.W.KSWhiteList:MenuElement({name = unit.charName, id = unit.charName, value = true, leftIcon = icon})

                                Menu.R.ComboWhiteList:MenuElement({name = unit.charName, id = unit.charName, value = true, leftIcon = icon})
                        end
                end

                Menu.Q.HarassWhiteList.info:Hide(true)
                Menu.Q.KSWhiteList.info:Hide(true)

                Menu.Q2.HarassWhiteList.info:Hide(true)
                Menu.Q2.AutoHarassWhiteList.info:Hide(true)

                Menu.W.HarassWhiteList.info:Hide(true)
                Menu.W.KSWhiteList.info:Hide(true)

                Menu.R.ComboWhiteList.info:Hide(true)

                self.menuLoadRequired = nil
        else
                Callback.Del("Tick", function() self:MenuLoad() end)
        end
end

function Lucian:EnoughMana(value)
        return ManaPercent(myHero) >= value
end

function Lucian:WhiteListValue(menu, target)
        return menu and menu[target.charName] and menu[target.charName]:Value()
end

function Lucian:ClosestToMouse(p1, p2)
        return (GetDistance(mousePos, p1) > GetDistance(mousePos, p2)) and p2 or p1
end

function Lucian:DashRange(target)
        local pred = target:GetPrediction(huge, 0.25)
        return GetDistance(pred) < (myHero.range + target.boundingRadius + myHero.boundingRadius) and 125 or 425
end

function Lucian:CastQ(target)
        if self.Q:IsReady() and self.Q:CanCast(target) then
                self.Q:Cast(target)
        end
end

function Lucian:CastQExtended(target)
        if self.Q2:IsReady() and self.Q2:CanCast(target) then
                local position, castPosition, hitChance = self.Q2:GetPrediction(target)

                if castPosition and hitChance >= 1 then
                        local targetPos = myHero.pos:Extended(castPosition, self.Q2.Range)

                        for i=1, #self.minions do
                                local minion = self.minions[i]
                                if minion and self.Q:CanCast(minion) then
                                        local minionPos = myHero.pos:Extended(minion.pos, self.Q2.Range)

                                        if GetDistance(targetPos, minionPos) <= self.Q2.Radius + target.boundingRadius then 
                                                self.Q:Cast(minion)
                                        end
                                end
                        end
                end
        end
end

function Lucian:CastW(target, checkPrediction, checkCollision)
        if self.W:IsReady() and self.W:CanCast(target) then
                self.W.Collision = not checkCollision

                local position, castPosition, hitChance = self.W:GetPrediction(target)
                castPosition = checkPrediction and target.pos or castPosition

                if castPosition and hitChance >= 1 then 
                        self.W:Cast(castPosition)
                end
        end
end

function Lucian:CastE(target, castMode, castRange)
        if castMode == 1 then
                local c1, c2, r1, r2 = myHero.pos, target.pos, myHero.range, 525
                local O1, O2 = CircleCircleIntersection(c1, c2, r1, r2)

                if O1 and O2 then
                        local closestPoint = Vector(self:ClosestToMouse(O1, O2))
                        local castPos = c1:Extended(closestPoint, castRange)

                        self.E:Cast(castPos)
                end
        elseif castMode == 2 then
                local castPos = myHero.pos:Extended(mousePos, castRange)
                
                self.E:Cast(castPos)
        elseif castMode == 3 then
                local castPos = myHero.pos:Extended(target.pos, castRange)
                
                self.E:Cast(castPos)
        end
        ResetAutoAttack()
end

function Lucian:Combo()        
        local target = self.target
        if not target or not (self.Q:IsReady() or self.W:IsReady() or self.E:IsReady()) then
            if self.R:IsReady() then
                local useR = Menu.R.Combo:Value()
                local mana = Menu.R.ComboMana:Value()
                local rTarg = GetTarget(self.R.Range, 0)
                if useR and self:EnoughMana(mana) and rTarg and self:WhiteListValue(Menu.R.ComboWhiteList, rTarg) then
                    self.R:CastToPred(rTarg, 2)
                end
            end
            return 
        end

        local useQ2 = Menu.Q2.Combo:Value()
        local mana = Menu.Q2.ComboMana:Value()
        if useQ2 and self:EnoughMana(mana) then
                self:CastQExtended(target)
        end
end

function Lucian:Harass()
        local target = self.target
        if not target then return end
        
        local useQ1 = Menu.Q.Harass:Value()
        local manaQ1 = Menu.Q.HarassMana:Value()
        if useQ1 and self.Q:IsReady() and self.Q:CanCast(target) and self:EnoughMana(manaQ1) and self:WhiteListValue(Menu.Q.HarassWhiteList, target) then
                self.Q:Cast(target)
        end

        local useQ2 = Menu.Q2.Harass:Value()
        local manaQ2 = Menu.Q2.HarassMana:Value()
        if useQ2 and self:EnoughMana(manaQ2) and self:WhiteListValue(Menu.Q2.HarassWhiteList, target) then
                self:CastQExtended(target)
        end

        local useW = Menu.W.Harass:Value()
        local manaW = Menu.W.HarassMana:Value()
        if useW and self:EnoughMana(manaW) and self:WhiteListValue(Menu.W.HarassWhiteList, target) then
                self:CastW(target, false, false)
        end        
end

function Lucian:AutoHarass()
        local target = self.target
        if not target then return end

        local useQ2 = Menu.Q2.AutoHarass:Value()
        local manaQ2 = Menu.Q2.AutoHarassMana:Value()
        if useQ2 and self:EnoughMana(manaQ2) and self:WhiteListValue(Menu.Q2.AutoHarassWhiteList, target) then
                self:CastQExtended(target)
        end
end

function Lucian:KillSteal()
        for i = 1, #(self.enemies) do  
                local unit = self.enemies[i]
                local health = unit.health 
                local shield = unit.shieldAD

                local useQ = Menu.Q.KS:Value()
                if self.Q:IsReady() and self.Q:CanCast(unit) and useQ and self:WhiteListValue(Menu.Q.KSWhiteList, unit) then
                        local damage = self.Q:GetDamage(unit)

                        if health + shield < damage then
                                self.Q:Cast(unit)
                        end
                end

                local useW = Menu.W.KS:Value()
                if self.W:IsReady() and self.W:CanCast(unit) and useW and self:WhiteListValue(Menu.W.KSWhiteList, unit) then
                        local damage = self.W:GetDamage(unit)

                        if health + shield < damage then
                                self:CastW(unit, false, false)
                        end
                end
        end
end

function Lucian:OnTick()
        if ShouldWait() then return end

        self.mode = GetMode()
        self.target = GetTarget(self.Q2.Range, 0)
        self.enemies = GetEnemyHeroes(self.W.Range)
        self.minions = GetEnemyMinions(self.Q2.Range)

        if myHero.isChanneling then return end

        self:AutoHarass()
        self:KillSteal()

        if not self.mode then return end

        local executeMode = 
            self.mode == 1 and self:Combo() or 
            self.mode == 2 and self:Harass()
end

function Lucian:OnDraw()  
        local rTarg = self.target or GetTarget(self.R.Range, 0)        
        if self.mode == 1 and Menu.R.Magnet:Value() and HasBuff(myHero, "LucianR") and rTarg then            
            local enemyMovement = rTarg:GetPrediction(huge, 0.3) - rTarg.pos            
            self.moveTo = myHero.pos+enemyMovement    
        else
            self.moveTo = nil 
        end 
        local drawSettings = Menu.Draw
        if drawSettings.ON:Value() then            
                local qLambda = drawSettings.Q:Value() and self.Q and self.Q:Draw(66, 244, 113) and self.Q2:Draw(66, 244, 113)
                local wLambda = drawSettings.W:Value() and self.W and self.W:Draw(66, 229, 244)
                local eLambda = drawSettings.E:Value() and self.E and self.E:Draw(244, 238, 66)
                local rLambda = drawSettings.R:Value() and self.R and self.R:Draw(244, 66, 104)            
                local tLambda = drawSettings.TS:Value() and self.target and DrawMark(self.target.pos, 3, self.target.boundingRadius, DrawColor(255,255,0,0)) 
        end 
end

function Lucian:OnPreMovement(args) 
        if ShouldWait() then 
                args.Process = false
                return 
        end 
        --R Magnet logic        
        if self.moveTo then
            if GetDistance(self.moveTo) < 20 then                  
                if myHero.pathing.hasMovePath then
                    args.Target = myHero.pos
                else
                    args.Process = false
                end
            elseif not MapPosition:inWall(self.moveTo) then 
                if GetDistance(self.moveTo) >= self.E.Range and self.E:IsReady() then
                    self.E:Cast(self.moveTo)
                end
                args.Target = self.moveTo 
            end 
        end 
end

function Lucian:OnPreAttack(args) 
        if ShouldWait() then 
                args.Process = false 
                return
        end 
end

function Lucian:OnPostAttack()
        local target = GetTarget(GetTrueAttackRange(myHero), 0)
        if not IsValidTarget(target) then return end
        local target_type = target.type

        if target_type == Obj_AI_Hero then
                if self.mode == 1 then
                        local comboRotation = Menu.ComboRotation:Value() - 1                        
                        if Menu.Q.Combo:Value() and (comboRotation == _Q or GameCanUseSpell(comboRotation) ~= READY) and self.Q:IsReady() and GetDistance(target) <= self.Q.Range then                                
                                self.Q:Cast(target)
                        elseif Menu.E.Combo:Value() and (comboRotation == _E or GameCanUseSpell(comboRotation) ~= READY) and self.E:IsReady() and GetDistance(target) <= (self.E.Range + myHero.range) then
                                local castMode = Menu.E.Mode:Value()
                                local castRange = self:DashRange(target)

                                self:CastE(target, castMode, castRange)
                        elseif Menu.W.Combo:Value() and (comboRotation == _W or GameCanUseSpell(comboRotation) ~= READY) and self.W:IsReady() and GetDistance(target) <= self.W.Range then
                                local checkPrediction = Menu.W.IgnorePred:Value()
                                local checkCollision = Menu.W.IgnoreColl:Value()

                                self:CastW(target, checkPrediction, checkCollision)
                        end
                end
        end
end

Lucian()
