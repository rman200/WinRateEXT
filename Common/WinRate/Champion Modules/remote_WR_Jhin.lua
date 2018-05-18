class 'Jhin'

function Jhin:__init()
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

function Jhin:Spells()
        self.Q = Spell({
                Slot = 0,
                Range = 600,
                Type = "Targetted"
        })

        self.W = Spell({
                Slot = 1,
                Range = 2500,
                Delay = 0.75,
                Speed = 10000,
                Radius = 20,
                Collision = false,
                From = myHero,
                Type = "Skillshot"
        })

        self.E = Spell({
                Slot = 2,
                Range = 750,
                Delay = 1,
                Speed = 1600,
                Radius = 60,
                Collision = false,
                From = myHero,
                Type = "Skillshot"
        })

        self.E.LastCastT = 0

        self.R = Spell({
                Slot = 3,
                Range = 3500,
                Delay = 0.25,
                Speed = 5000,
                Radius = 40,
                Collision = false,
                From = myHero,
                Type = "Skillshot"
        })

        self.R.Angle = 65
        self.R.IsCasting = false
        self.R.IsChanneling = false
        self.R.CastPos = nil
end

function Jhin:Menu()
        -- Q SETTINGS
        Menu.Q:MenuElement({name = " ", drop = {"Modes"}})
        Menu.Q:MenuElement({id = "Combo", name = "Combo", value = true})
        Menu.Q:MenuElement({id = "Harass", name = "Harass", value = true})
        Menu.Q:MenuElement({id = "KS", name = "KillSteal", value = true})
        Menu.Q:MenuElement({name = " ", drop = {"Mana Manager"}})
        Menu.Q:MenuElement({id = "ComboMana", name = "Combo - Min. Mana(%)", value = 0, min = 0, max = 100})
        Menu.Q:MenuElement({id = "HarassMana", name = "Harass - Min. Mana(%)", value = 50, min = 0, max = 100})
        Menu.Q:MenuElement({name = " ", drop = {"Customization"}})
        Menu.Q:MenuElement({type = MENU, name = "Cast Settings", id = "CS"})
        Menu.Q.CS:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.Q.CS:MenuElement({name = "Cast Mode",  id = "ComboMode", value = 2, drop = {"Normal", "After Attack"}})
        Menu.Q.CS:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.Q.CS:MenuElement({name = "Cast Mode",  id = "HarassMode", value = 1, drop = {"Normal", "After Attack"}})
        Menu.Q:MenuElement({type = MENU, name = "Harass White List", id = "HarassWhiteList"})
        Menu.Q.HarassWhiteList:MenuElement({id = "info", name = "Detecting Heroes, Please Wait...", drop = {" "}})
        Menu.Q:MenuElement({type = MENU, name = "KillSteal White List", id = "KSWhiteList"})
        Menu.Q.KSWhiteList:MenuElement({id = "info", name = "Detecting Heroes, Please Wait...", drop = {" "}})

        -- W SETTINGS
        Menu.W:MenuElement({name = " ", drop = {"Modes"}})
        Menu.W:MenuElement({id = "Combo", name = "Combo", value = true})
        Menu.W:MenuElement({name = " ", drop = {"Mana Manager"}})
        Menu.W:MenuElement({id = "ComboMana", name = "Combo - Min. Mana(%)", value = 0, min = 0, max = 100})
        Menu.W:MenuElement({name = " ", drop = {"Customization"}})
        Menu.W:MenuElement({id = "OnImmobile", name = "On Immobile", value = true, tooltip = "Will use W on immobile enemy"})
        Menu.W:MenuElement({type = MENU, name = "On Immobile White List", id = "OnImmobileWhiteList"})
        Menu.W.OnImmobileWhiteList:MenuElement({id = "info", name = "Detecting Heroes, Please Wait...", drop = {" "}})
        Menu.W:MenuElement({type = MENU, name = "HitChance Settings", id = "HitChance"})
        Menu.W.HitChance:MenuElement({id = "info", name = "HitChance Info [?]", drop = {" "},
                tooltip = " 0  -  Out of range/Collision/No valid waypoints\n" ..
                " 1  -  Normal hitchance\n" ..
                " 2  -  High hitchance\n" ..
                " 3  -  Very High hitchance (Slowed, Casted spell or AA)\n" ..
                " 4  -  Target immobile\n" ..
                " 5  -  Target dashing"})
        Menu.W.HitChance:MenuElement({id = "Combo", name = "Combo - HitChance", value = 1, min = 1, max = 5})
        Menu.W.HitChance:MenuElement({id = "Harass", name = "Harass - HitChance", value = 1, min = 1, max = 5})

        -- E SETTINGS
        Menu.E:MenuElement({name = " ", drop = {"Modes"}})
        Menu.E:MenuElement({id = "Combo", name = "Combo", value = true})
        Menu.E:MenuElement({name = " ", drop = {"Mana Manager"}})
        Menu.E:MenuElement({id = "ComboMana", name = "Combo - Min. Mana(%)", value = 0, min = 0, max = 100})
        Menu.E:MenuElement({name = " ", drop = {"Customization"}})
        Menu.E:MenuElement({id = "OnImmobile", name = "On Immobile", value = true, tooltip = "Will use E on immobile enemy"})
        Menu.E:MenuElement({type = MENU, name = "On Immobile White List", id = "OnImmobileWhiteList"})
        Menu.E.OnImmobileWhiteList:MenuElement({id = "info", name = "Detecting Heroes, Please Wait...", drop = {" "}})

        -- R SETTINGS
        Menu.R:MenuElement({name = " ", drop = {"Modes"}})
        Menu.R:MenuElement({id = "Combo", name = "Combo", value = true})

        -- OTHER
        Menu:MenuElement({name = myHero.charName .. " Script version: ", drop = {self.scriptVersion}})

        self.menuLoadRequired = true
        Callback.Add("Tick", function() self:MenuLoad() end)
end

function Jhin:MenuLoad()
        if self.menuLoadRequired then
                local count = HeroCount()
                if count == 1 then return end 

                for i = 1, count do 
                        local unit = Hero(i)
                        local charName = unit.charName

                        if unit.team == TEAM_ENEMY then
                                local icon = "https://raw.githubusercontent.com/rman200/WinRateEXT/master/Icons/champions/" .. charName .. ".png"

                                Menu.Q.HarassWhiteList:MenuElement({name = charName, id = charName, value = true, leftIcon = icon})
                                Menu.Q.KSWhiteList:MenuElement({name = charName, id = charName, value = true, leftIcon = icon})

                                Menu.W.OnImmobileWhiteList:MenuElement({name = charName, id = charName, value = true, leftIcon = icon})

                                Menu.E.OnImmobileWhiteList:MenuElement({name = charName, id = charName, value = true, leftIcon = icon})
                        end
                end

                Menu.Q.HarassWhiteList.info:Hide(true)
                Menu.Q.KSWhiteList.info:Hide(true)

                Menu.W.OnImmobileWhiteList.info:Hide(true)

                Menu.E.OnImmobileWhiteList.info:Hide(true)

                self.menuLoadRequired = nil
        else
                Callback.Del("Tick", function() self:MenuLoad() end)
        end
end

function Jhin:EnoughMana(value)
        return ManaPercent(myHero) >= value
end

function Jhin:WhiteListValue(menu, target)
        return menu and menu[target.charName] and menu[target.charName]:Value()
end

function Jhin:CrossProduct(p1, p2)
        return (p2.z * p1.x - p2.x * p1.z)
end

function Jhin:Rotated(v, angle)
        local c = cos(angle)
        local s = sin(angle)
        return Vector(v.x * c - v.z * s, 0, v.z * c + v.x * s)
end

function Jhin:InCone(targetPos)
        if not self.R.CastPos then return false end

        local endPos = self.R.CastPos
        local range = self.R.Range
        local angle = self.R.Angle * pi / 180
        local v1 = self:Rotated(endPos - myHero.pos, -angle / 2)
        local v2 = self:Rotated(v1, angle)
        local v3 = targetPos - myHero.pos

        if GetDistanceSqr(v3, Vector()) < range * range and self:CrossProduct(v1, v3) > 0 and self:CrossProduct(v3, v2) > 0 then
                return true
        end

        return false
end

function Jhin:Update()
        local spell = myHero.activeSpell

        if spell and spell.valid and spell.name == "JhinR" then
                self.R.IsCasting = true
                self.R.CastPos = Vector(spell.placementPos)

                if spell.isChanneling then
                        self.R.IsChanneling = true
                end

                SetAttack(false)
                SetMovement(false)
        else 
                self.R.IsCasting = false
                self.R.CastPos = nil
                self.R.IsChanneling = false

                SetAttack(true)
                SetMovement(true)
        end
end

function Jhin:CastQ(target)
        if self.Q:IsReady() and self.Q:CanCast(target) then 
                self.Q:Cast(target)
        end
end

function Jhin:CastW(target, hitChance)
        if self.W:IsReady() and self.W:CanCast(target) then 
                self.W:CastToPred(target, hitChance)
        end
end

function Jhin:CastE(target, hitChance)
        if self.E:IsReady() and self.E:CanCast(target) then 
                self.E:CastToPred(target, hitChance)
                self.E.LastCastT = Game.Timer( )
        end
end

function Jhin:CastR(target, hitChance)
        if self.R:IsReady() and self.R:CanCast(target) and self.R.IsChanneling then
                self.R:CastToPred(target, hitChance)
        end
end

function Jhin:Combo()
        local target = self.target
        if not target then return end

        if self.R.IsCasting then
                local useR = Menu.R.Combo:Value()
                if useR then
                        self:CastR(target, 1)
                end 

                return
        end

        local reload = GotBuff(myHero, "JhinPassiveReload") > 0
        local useQ = Menu.Q.Combo:Value()
        local modeQ = Menu.Q.CS.ComboMode:Value()
        local manaQ = Menu.Q.ComboMana:Value()
        if useQ and (modeQ == 1 or reload) and self:EnoughMana(manaQ) then
                self:CastQ(target)
        end

        local useW = Menu.W.Combo:Value()
        local manaW = Menu.W.ComboMana:Value()
        local hitChanceW = Menu.W.HitChance.Combo:Value()
        local marked = GotBuff(target, "jhinespotteddebuff") > 0
        if useW and self:EnoughMana(manaW) and marked then
                self:CastW(target, hitChanceW)
        end

        local timer = Game.Timer()
        local useE = Menu.E.Combo:Value()
        local manaE = Menu.E.ComboMana:Value()
        if useE and self:EnoughMana(manaE) and reload and self.E.LastCastT + 2 < timer then
                self:CastE(target, 1)
        end
end

function Jhin:ComboR()
        local target = self.target
        if not target then return end

        if self.mode == 1 then
                if self.R.IsCasting then
                        local useR = Menu.R.Combo:Value()
                        if useR then
                                self:CastR(target, 1)
                        end 

                        return
                end
        end
end

function Jhin:Harass()
        local target = self.target
        if not target then return end
        if self.R.IsCasting then return end

        local reload = GotBuff(myHero, "JhinPassiveReload") > 0
        local useQ = Menu.Q.Harass:Value()
        local modeQ = Menu.Q.CS.HarassMode:Value()
        local manaQ = Menu.Q.HarassMana:Value()
        if useQ and (modeQ == 1 or reload) and self:EnoughMana(manaQ) and self:WhiteListValue(Menu.Q.HarassWhiteList, target) then
                self:CastQ(target)
        end
end

function Jhin:Immobile()
        for i = 1, #(self.enemies) do  
                local unit = self.enemies[i]

                local timer = Game.Timer()
                local marked = GotBuff(unit, "jhinespotteddebuff") > 0
                local useW = Menu.W.OnImmobile:Value()
                if useW and self:WhiteListValue(Menu.W.OnImmobileWhiteList, unit) then
                        local target, unitPosition, castPosition = self.W:OnImmobile(unit)

                        if target and unitPosition and marked then
                                self:CastW(unit, 1)
                        end
                end

                local useE = Menu.E.OnImmobile:Value()
                if useE and self:WhiteListValue(Menu.E.OnImmobileWhiteList, unit) then
                        local target, unitPosition, castPosition = self.E:OnImmobile(unit)

                        if target and unitPosition and self.E.LastCastT + 1 < timer then
                                self:CastE(unit, 1)
                        end
                end
        end
end

function Jhin:KillSteal()
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
        end
end

function Jhin:OnTick()
        self:Update()

        if ShouldWait() then return end

        self.mode = GetMode()
        self.target = GetTarget(self.R.Range, 0)
        self.enemies = GetEnemyHeroes(self.R.Range)

        self:ComboR()

        if myHero.isChanneling then return end

        self:Immobile()
        self:KillSteal()

        if not self.mode then return end

        local executeMode = 
            self.mode == 1 and self:Combo() or
            self.mode == 2 and self:Harass()
end

function Jhin:OnDraw()
        local drawSettings = Menu.Draw
        if drawSettings.ON:Value() then            
                local qLambda = drawSettings.Q:Value() and self.Q and self.Q:Draw(66, 244, 113)
                local wLambda = drawSettings.W:Value() and self.W and self.W:Draw(66, 229, 244)
                local eLambda = drawSettings.E:Value() and self.E and self.E:Draw(244, 238, 66)
                local rLambda = drawSettings.R:Value() and self.R and self.R:Draw(244, 66, 104)            
                local tLambda = drawSettings.TS:Value() and self.target and DrawMark(self.target.pos, 3, self.target.boundingRadius, DrawColor(255,255,0,0)) 
        end 
end

function Jhin:OnPreMovement(args) 
        if ShouldWait() then 
                args.Process = false
                return 
        end 
end

function Jhin:OnPreAttack(args) 
        if ShouldWait() then 
                args.Process = false 
                return
        end 
end

function Jhin:OnPostAttack()
        local handle = myHero.attackData.target
        local target = handle ~= 0 and GetTargetByHandle(handle) or self.target
        if target == nil then return end
        local target_type = target.type

        if target_type == Obj_AI_Hero then
                if self.mode == 1 then
                        local useQ = Menu.Q.Combo:Value()
                        local modeQ = Menu.Q.CS.ComboMode:Value()
                        local manaQ = Menu.Q.ComboMana:Value()
                        if useQ and modeQ == 2 and self:EnoughMana(manaQ) then
                                self:CastQ(target)
                        end
                elseif self.mode == 2 then
                        local useQ = Menu.Q.Harass:Value()
                        local modeQ = Menu.Q.CS.HarassMode:Value()
                        local manaQ = Menu.Q.HarassMana:Value()
                        if useQ and modeQ == 2 and self:EnoughMana(manaQ) and self:WhiteListValue(Menu.Q.HarassWhiteList, target) then
                                self:CastQ(target)
                        end
                end
        end
end

Jhin()
