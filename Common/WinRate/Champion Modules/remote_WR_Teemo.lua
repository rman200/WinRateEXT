
    class 'Teemo'  

    function Teemo:__init()
        --[[Data Initialization]]
        self:ShroomData()
        self.Color1 = DrawColor(255, 35, 219, 81)
        self.Color2 = DrawColor(255, 216, 121, 26)
        self.scriptVersion = "1.0"
        self:Spells()
        self:Menu() 
        --[[Default Callbacks]] 
        Callback.Add("Tick",          function() self:OnTick()    end)
        Callback.Add("Draw",          function() self:OnDraw()    end)
        Callback.Add("WndMsg",        function(msg, param) self:OnWndMsg(msg, param) end)                      
    end

    function Teemo:Spells()
        self.Q = Spell({
            Slot = 0,
            Range = 680,
            Delay = 0.25,
            Speed = 0,
            Radius = 0,
            Collision = false,
            From = myHero,
            Type = "Targetted"
        })
        self.W = Spell({
            Slot = 1,
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
            Range = 400,
            Delay = 1.0,
            Speed = 1600,
            Radius = 150,
            Collision = false,
            From = myHero,
            Type = "AOE"
        })
        self.R.LastCast = 0
    end

    function Teemo:Menu()
        --Q--
        Menu.Q:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.Q:MenuElement({id = "Combo", name = "Use on Combo", value = true})
        Menu.Q:MenuElement({id = "Mana" , name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.Q:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.Q:MenuElement({id = "Harass"    , name = "Use on Harass", value = true})
        Menu.Q:MenuElement({id = "ManaHarass", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.Q:MenuElement({name = " ", drop = {"Misc"}})
        Menu.Q:MenuElement({id = "Melee", name = "Auto Use on Melee", value = true})                    
        --W--
        Menu.W:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.W:MenuElement({id = "Combo", name = "Use on Combo", value = true})
        Menu.W:MenuElement({id = "Mana" , name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.W:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.W:MenuElement({id = "Harass"    , name = "Use on Harass", value = false})
        Menu.W:MenuElement({id = "ManaHarass", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.W:MenuElement({name = " ", drop = {"Misc"}}) 
        Menu.W:MenuElement({id = "Flee", name = "Use on Flee", value = true})      
        --E--
        Menu.E:MenuElement({name = " ", drop = {"Misc"}})
        Menu.E:MenuElement({id = "Auto", name = "Free ELO", value = true})    
        --R--
        Menu.R:MenuElement({name = " ", drop = {"WR Shroom Helper"}})
        Menu.R:MenuElement({id = "Enabled"   , name = "Enabled", value = true})
        Menu.R:MenuElement({id = "MinAmmo"  , name = "Save Min X Shrooms", value = 2, min = 0, max = 2, step = 1})
        Menu.R:MenuElement({id = "Draw"     , name = "Draw Nearby Spots", value = true}) 

        Menu.R:MenuElement({name = " ", drop = {"Combo Settings"}})  
        Menu.R:MenuElement({id = "Combo", name = "Use on Combo", value = true}) 
        Menu.R:MenuElement({id = "Mana" , name = "Min Mana %", value = 0, min = 0, max = 100, step = 1})
        Menu:MenuElement({name = "[WR] "..charName.." Script", drop = {"Release_"..self.scriptVersion}})
        --
    end

    function Teemo:OnTick() 
        if ShouldWait() then return end 
        --        
        self.enemies = GetEnemyHeroes(1500)
        self.target = GetTarget(self.Q.Range+300, 0)
        self.mode = GetMode() 
        --  
        self:UpdateSpots()             
        if myHero.isChanneling then return end        
        self:Auto()
        --
        if not self.target or not self.mode then return end        
        local executeMode = 
            self.mode == 1 and self:Combo()   or 
            self.mode == 2 and self:Harass()  or
            self.mode == 3 and self:Clear()   or
            self.mode == 4 and self:Clear()   or
            self.mode == 5 and self:LastHit() or
            self.mode == 6 and self:Flee()      
    end

    function Teemo:OnWndMsg(msg, param)
        if param == HK_R then
            for delay=1, 2, 0.5 do            
                DelayAction(function()
                    self:FindShrooms()                
                end, delay)
            end
        end

        local level = myHero:GetSpellData(_R).level
        if level > 1 then
            self.R.Range = 150 + 250*level
        end
    end

    function Teemo:Auto() 
        local qMelee = GetTarget(300, 1)         
        if self.Q:IsReady() and qMelee and Menu.Q.Melee:Value() then
            self.Q:Cast(qMelee)
        end    
        
        if self.mode ~= 6 and self.R:IsReady() and Timer() - self.R.LastCast >= 1.5 and Menu.R.Enabled:Value() and myHero:GetSpellData(_R).ammo > Menu.R.MinAmmo:Value() then
            for i=1, #self.nearbySpots do
                local spot = self.nearbySpots[i]
                if GetDistance(myHero, spot) <= self.R.Range and not spot.active then                    
                    self.R:Cast(spot.pos)
                    self.R.LastCast = Timer()
                    return
                end
            end  
        end             
    end

    function Teemo:Combo()
        local target = self.target 
        local distance = GetDistance(myHero, target)
        --
        if self.W:IsReady() and Menu.W.Combo:Value() and ManaPercent(myHero) >= Menu.W.Mana:Value() and (distance <= 300 or distance >= 550) then
            self.W:Cast() 
        elseif self.Q:IsReady() and Menu.Q.Combo:Value() and ManaPercent(myHero) >= Menu.Q.Mana:Value() and distance <= self.Q.Range then
            self.Q:Cast(target)  
        elseif self.R:IsReady() and Timer() - self.R.LastCast >= 3 and Menu.R.Combo:Value() and ManaPercent(myHero) >= Menu.R.Mana:Value() and distance <= self.R.Range then
            self.R:CastToPred(target, 3)  
            self.R.LastCast = Timer()       
        end     
    end

    function Teemo:Harass()  
        local target = self.target 
        local distance = GetDistance(myHero, target)
        --
        if self.W:IsReady() and Menu.W.Combo:Value() and ManaPercent(myHero) >= Menu.W.Mana:Value() and (distance <= 300 or distance >= 550) then
            self.W:Cast() 
        elseif self.Q:IsReady() and Menu.Q.Combo:Value() and ManaPercent(myHero) >= Menu.Q.Mana:Value() and distance <= self.Q.Range then
            self.Q:Cast(target)            
        end      
    end

    function Teemo:Flee()         
        if self.W:IsReady() and Menu.W.Flee:Value() and GetTarget(self.Q.Range, 1) then
            self.W:Cast()
        end       
    end

    function Teemo:OnDraw()
        DrawSpells(self)
        --
        if Menu.Draw.ON:Value() then            
            if self.nearbySpots and Menu.R.Draw:Value() then
                for i=1, #self.nearbySpots do
                    local spot = self.nearbySpots[i]
                    DrawCircle(spot.pos, 30, spot.active and self.Color1 or self.Color2)                    
                end 
            end             
        end    
    end

    function Teemo:UpdateSpots()        
        for k, obj in pairs(self.nearbyShrooms) do
            if not obj or not obj.valid or obj.dead then                
                self:SectorDataExecutor(obj, function(spot, obj) 
                    if GetDistanceSqr(spot, obj) <= 200*200 then
                        spot.active = false                           
                    end 
                end)
                self.nearbyShrooms[k] = nil 
            end
        end

        self.nearbySpots = {}        
        self:SectorDataExecutor(myHero, function(spot, obj) 
            if GetDistanceSqr(spot.pos, myHero) <= 1000*1000 and spot.pos:To2D().onScreen then
                self.nearbySpots[#self.nearbySpots+1] = spot
            end 
        end)
    end

    function Teemo:CheckNearbySpots(x,z)
        if self.shroomSpots[x][z] then
            local t = self.shroomSpots[x][z]
            for i=1, #t do --Worst Case = 3
                local spot = t[i]                
                if GetDistanceSqr(spot.pos, myHero) <= 1000*1000 and spot.pos:To2D().onScreen then
                    self.nearbySpots[#self.nearbySpots+1] = spot
                end 
            end
        end 
    end

    function Teemo:FindShrooms()        
        for i = ObjectCount(), 1, -1 do
            local obj = Object(i)
            if obj and not obj.dead and obj.name == "Noxious Trap" then     
                self:SectorDataExecutor(obj, function(spot, obj) 
                    if GetDistanceSqr(spot, obj) <= 200*200 then
                        spot.active = true                            
                    end 
                end)                
                self.nearbyShrooms[obj.networkID] = obj           
            end
        end
    end

    function Teemo:SectorDataExecutor(obj, func)
        local xFloor, zFloor = floor(obj.pos.x/1000), floor(obj.pos.z/1000)
        for x = xFloor-1, xFloor+1 do
            if self.shroomSpots[x] then
                for z = zFloor-1, zFloor+1 do
                    if self.shroomSpots[x][z] then                 
                        local t = self.shroomSpots[x][z]
                        for j=1, #t do
                            local spot = t[j]
                            func(spot, obj)                         
                        end
                    end
                end
            end
        end
    end

    function Teemo:ShroomData()
        self.nearbySpots   = {}
        self.nearbyShrooms = {}        
        self.shroomSpots = {
            [1] = {
                [12] = {
                    {active=false, pos=Vector(1170,0,12320)}
                },
                [13] = {
                    {active=false, pos=Vector(1671,0,13000)}
                }
            },
            [2] = {
                [4] = {
                    {active=false, pos=Vector(2742,0,4959)}
                },
                [7] = {
                    {active=false, pos=Vector(2997,0,7597)}
                },
                [11] = {
                    {active=false, pos=Vector(2807,0,11909)},
                    {active=false, pos=Vector(2247,0,11847)}
                },
                [12] = {
                    {active=false, pos=Vector(2875,0,12553)}
                },
                [13] = {
                    {active=false, pos=Vector(2400,0,13511)}
                }
            },
            [3] = {
                [7] = {
                    {active=false, pos=Vector(3157,0,7206)}
                },
                [9] = {
                    {active=false, pos=Vector(3548,0,9286)},
                    {active=false, pos=Vector(3752,0,9437)}
                },
                [10] = {
                    {active=false, pos=Vector(3067,0,10899)}
                },
                [11] = {
                    {active=false, pos=Vector(3857,0,11358)}
                },
                [12] = {
                    {active=false, pos=Vector(3900,0,12829)}
                }
            },
            [4] = {
                [2] = {
                    {active=false, pos=Vector(4972,0,2882)}
                },
                [6] = {
                    {active=false, pos=Vector(4698,0,6140)}
                },
                [7] = {
                    {active=false, pos=Vector(4750,0,7211)}
                },
                [8] = {
                    {active=false, pos=Vector(4749,0,8022)}
                },
                [10] = {
                    {active=false, pos=Vector(4703,0,10063)}
                },
                [11] = {
                    {active=false, pos=Vector(4467,0,11841)}
                }
            },
            [5] = {
                [3] = {
                    {active=false, pos=Vector(5716,0,3505)}
                }
            },
            [6] = {
                [4] = {
                    {active=false, pos=Vector(6546,0,4723)}
                },
                [9] = {
                    {active=false, pos=Vector(6200,0,9288)}
                },
                [10] = {
                    {active=false, pos=Vector(6019,0,10405)}
                },
                [11] = {
                    {active=false, pos=Vector(6800,0,11558)}
                },
                [12] = {
                    {active=false, pos=Vector(6780,0,13011)}
                }
            },
            [7] = {
                [2] = {
                    {active=false, pos=Vector(7968,0,2197)}
                },
                [3] = {
                    {active=false, pos=Vector(7973,0,3362)},
                    {active=false, pos=Vector(7117,0,3100)}
                },
                [6] = {
                    {active=false, pos=Vector(7225,0,6216)}
                },
                [11] = {
                    {active=false, pos=Vector(7768,0,11808)}
                },
                [12] = {
                    {active=false, pos=Vector(7252,0,12546)}
                }
            },
            [8] = {
                [5] = {
                    {active=false, pos=Vector(8619,0,5622)}
                },
                [10] = {
                    {active=false, pos=Vector(8280,0,10245)}
                }
            },
            [9] = {
                [2] = {
                    {active=false, pos=Vector(9222,0,2129)}
                },
                [6] = {
                    {active=false, pos=Vector(9702,0,6319)}
                },
                [11] = {
                    {active=false, pos=Vector(9371,0,11445)}
                },
                [12] = {
                    {active=false, pos=Vector(9845,0,12060)}
                }
            },
            [10] = {
                [1] = {
                    {active=false, pos=Vector(10900,0,1970)}
                },
                [3] = {
                    {active=false, pos=Vector(10407,0,3091)}
                },
                [4] = {
                    {active=false, pos=Vector(10097,0,4972)}
                },
                [6] = {
                    {active=false, pos=Vector(10081,0,6590)}
                },
                [7] = {
                    {active=false, pos=Vector(10070,0,7299)}
                }
            },
            [11] = {
                [2] = {
                    {active=false, pos=Vector(11700,0,2036)},
                    {active=false, pos=Vector(11866,0,3186)}
                },
                [3] = {
                    {active=false, pos=Vector(11024,0,3883)},
                    {active=false, pos=Vector(11866,0,3186)}
                },
                [4] = {
                    {active=false, pos=Vector(11730,0,4091)}
                },
                [5] = {
                    {active=false, pos=Vector(11230,0,5575)}
                },
                [7] = {
                    {active=false, pos=Vector(11627,0,7103)},
                    {active=false, pos=Vector(11873,0,7530)}
                }
            },
            [12] = {
                [1] = {
                    {active=false, pos=Vector(12225,0,1292)}
                },
                [2] = {
                    {active=false, pos=Vector(12987,0,2028)}
                },
                [3] = {
                    {active=false, pos=Vector(12827,0,3131)}
                },
                [5] = {
                    {active=false, pos=Vector(12611,0,5318)}
                },
                [8] = {
                    {active=false, pos=Vector(12133,0,8821)}
                },
                [9] = {
                    {active=false, pos=Vector(12063,0,9974)}
                }
            },
            [13] = {
                [2] = {
                    {active=false, pos=Vector(13499,0,2837)}
                }
            }
        }    
    end

    Teemo()