	
	local Thresh = {}

	function Thresh:__init()
        --[[Data Initialization]]
        self.scriptVersion = "1.0"
        self:Spells()
        self:Menu() 
        --[[Default Callbacks]] 
        Callback.Add("Tick",          function() self:OnTick()    end)
        Callback.Add("Draw",          function() self:OnDraw()    end)        
        --[[Custom Callbacks]]
        OnInterruptable(function(unit, spell) self:OnInterruptable(unit, spell) end)
        OnDash(function(unit, unitPos, unitPosTo, dashSpeed, dashGravity, dashDistance) self:OnDash(unit, unitPos, unitPosTo, dashSpeed, dashGravity, dashDistance) end)                      
    end

    function Thresh:Spells()
        self.Q = Spell({
            Slot = 0,
            Range = 1100 - 100,--max range misses most of the time zz
            Delay = 0.5,
            Speed = 1900,
            Radius = 70,
            Collision = true,
            From = myHero,
            Type = "SkillShot"
        })
        self.Q2 = Spell({
            Slot = 0,
            Range = huge,
            Delay = 0.5,
            Speed = 1900,
            Radius = 70,
            Collision = false,
            From = myHero,
            Type = "Press"
        })
        self.W = Spell({
            Slot = 1,
            Range = 950,
            Delay = 0.25,
            Speed = 1450,
            Radius = 150,
            Collision = false,
            From = myHero,
            Type = "AOE"
        })
        self.E = Spell({
            Slot = 2,
            Range = 450,
            Delay = 0.25,
            Speed = 1100,
            Radius = 150,
            Collision = false,
            From = myHero,
            Type = "SkillShot"
        })
        self.R = Spell({
            Slot = 3,
            Range = 375,
            Delay = 0.25,
            Speed = huge,
            Radius = 320,
            Collision = false,
            From = myHero,
            Type = "Press"
        })
    end

function Thresh:Menu()
	--Q--
    Menu.Q:MenuElement({name = " ", drop = {"Combo Settings"}})
    Menu.Q:MenuElement({id = "Combo", name = "Use on Combo", value = true})
    Menu.Q:MenuElement({id = "Mana", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
    Menu.Q:MenuElement({name = " ", drop = {"Harass Settings"}})
    Menu.Q:MenuElement({id = "Harass", name = "Use on Harass", value = true})
    Menu.Q:MenuElement({id = "ManaHarass", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
    Menu.Q:MenuElement({name = " ", drop = {"Interrupt Settings"}})
    Menu.Q:MenuElement({id = "Interrupter", name = "Use To Interrupt", value = true})
    Menu.Q:MenuElement({id = "Interrupt", name = "Interrupt Targets", type = MENU})
    	Menu.Q.Interrupt:MenuElement({id = "Loading", name = "Loading Champions...", type = SPACE})    
    Menu.Q:MenuElement({name = " ", drop = {"Misc"}})
    Menu.Q:MenuElement({id = "Auto", name = "Auto Use on Immobile", value = true})
    Menu.Q:MenuElement({id = "Dashing", name = "Auto Use on Dashing", value = true})
    --W--
    Menu.W:MenuElement({name = " ", drop = {"Combo Settings"}})
    Menu.W:MenuElement({id = "Combo", name = "Use on Combo", value = true})
    Menu.W:MenuElement({id = "Mana", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
    Menu.W:MenuElement({name = " ", drop = {"Misc"}})
    Menu.W:MenuElement({id = "Flee", name = "Use on Flee", value = true})  
    Menu.W:MenuElement({id = "HardCC", name = "Use on CCed Allies", value = true})    
    --E--
    Menu.E:MenuElement({name = " ", drop = {"Combo Settings"}})
    Menu.E:MenuElement({id = "Combo", name = "Use on Combo", value = true})
    Menu.E:MenuElement({id = "Mana", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
    Menu.E:MenuElement({name = " ", drop = {"Harass Settings"}})
    Menu.E:MenuElement({id = "Harass", name = "Use on Harass", value = false})
    Menu.E:MenuElement({id = "ManaHarass", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
    Menu.E:MenuElement({name = " ", drop = {"Interrupt Settings"}})
    Menu.E:MenuElement({id = "Interrupter", name = "Use To Interrupt", value = true})
    Menu.E:MenuElement({id = "Interrupt", name = "Interrupt Targets", type = MENU})
    	Menu.E.Interrupt:MenuElement({id = "Loading", name = "Loading Champions...", type = SPACE})
    Menu.E:MenuElement({name = " ", drop = {"Misc"}})
    Menu.E:MenuElement({id = "Dashing", name = "Auto Use on Dashing", value = true})
    Menu.E:MenuElement({id = "Flee", name = "Use on Flee", value = true}) 
    Menu.E:MenuElement({id = "Key", name = "Toggle Push-Pull", key = string.byte("T"), toggle = true})
    Menu.E:MenuElement({id = "Draw", name = "Draw Toggle State", value = false})        
    --R--
    Menu.R:MenuElement({name = " ", drop = {"Combo Settings"}})
    Menu.R:MenuElement({id = "Combo", name = "Use on Combo", value = true})
    Menu.R:MenuElement({id = "Count", name = "When X Enemies Around", value = 2, min = 1, max = 5, step = 1})
    Menu.R:MenuElement({name = " ", drop = {"Misc"}})
    Menu.R:MenuElement({id = "Auto", name = "Auto Use When X Enemies Around", value = 3, min = 0, max = 5, step = 1})
    
    Menu.R:MenuElement({id = "Mana", name = "Min Mana %", value = 0, min = 0, max = 100, step = 1})
    Menu:MenuElement({name = "[WR] "..charName.." Script", drop = {"Release_"..self.scriptVersion}})
    --
    self.menuLoadRequired = true
    Callback.Add("Tick", function() self:MenuLoad() end)	
end

function Thresh:MenuLoad()
    if self.menuLoadRequired then 
        local count = HeroCount()
        if count == 1 then return end 
        for i = 1, count do 
            local hero = Hero(i)
            local charName = hero.charName
            if hero.team == TEAM_ENEMY then                
                Interrupter:AddToMenu(hero, Menu.Q.Interrupt)
                Interrupter:AddToMenu(hero, Menu.E.Interrupt)                                        
            end
        end
        --
        local count = -13
        for _ in pairs(Menu.E.Interrupt) do count = count+1 end            
        if count == 1 then
        	Menu.Q.Interrupt:MenuElement({name = "No Spells To Be Interrupted", drop = {" "}})
            Menu.E.Interrupt:MenuElement({name = "No Spells To Be Interrupted", drop = {" "}})
            Callback.Del("Tick", function() Interrupter:OnTick() end)
        end 
        --           
        Menu.Q.Interrupt.Loading:Hide(true)
        Menu.E.Interrupt.Loading:Hide(true)
        self.menuLoadRequired = nil         
    else
        Callback.Del("Tick", function() self:MenuLoad() end)
    end
end

function Thresh:OnTick() 
    if ShouldWait() then return end 
    --        
    self.enemies = GetEnemyHeroes(self.Q.Range)
    self.target = GetTarget(self.E.Range, 0)
    self.mode = GetMode() 
    --               
    if myHero.isChanneling then return end        
    self:Auto()
    --
    if not self.mode then return end        
    local executeMode = 
        self.mode == 1 and self:Combo()   or 
        self.mode == 2 and self:Harass()  or
        self.mode == 6 and self:Flee()      
end

function Thresh:OnInterruptable(unit, spell)
    if not IsValidTarget(unit) or ShouldWait() then return end
    --         
    if self.E:IsReady() and GetDistance(unit) < self.E.Range and Menu.E.Interrupter:Value() and Menu.E.Interrupt[spell.name]:Value() then
    	self.E:Cast(self:GetPosE(unit, "Pull"))
    elseif self.Q:IsReady() and GetDistance(unit) < self.Q.Range and Menu.Q.Interrupter:Value() and Menu.Q.Interrupt[spell.name]:Value() then
    	self.Q:CastToPred(unit, 2)          
    end        
end   

function Thresh:OnDash(unit, unitPos, unitPosTo, dashSpeed, dashGravity, dashDistance)  
    if unit.team ~= TEAM_ENEMY or ShouldWait() or not IsValidTarget(unit, self.Q.Range) then return end
    -- 
    if self.E:IsReady() and GetDistance(unit) < self.E.Range then        
        if GetDistance(unitPosTo) < self.E.Range and IsFacing(unit, myHero) then --Gapcloser 
        	self.E:Cast(self:GetPosE(unit, "Push"))
   	    elseif GetDistance(unitPosTo) > self.E.Range and not IsFacing(unit, myHero) then --Running Away 
        	self.E:Cast(self:GetPosE(unit, "Pull"))
        end
    elseif Menu.Q.Dashing:Value() and self.Q:IsReady() then 
        self.Q:CastToPred(unit, 3)                              
    end
end 

function Thresh:OnDraw()
    DrawSpells(self)
    local pLambda = Menu.E.Draw:Value() and DrawText("E Mode:"..(Menu.E.Key:Value() and "Push" or "Pull") , 20, myHero.pos:To2D().x - 33, myHero.pos:To2D().y + 60, DrawColor(255, 000, 255, 000))    
end

function Thresh:Auto()
	local nearby = #GetEnemyHeroes(self.R.Range)
	--
	if self.R:IsReady() and nearby > 0 then
		local autoMin = Menu.R.Auto:Value()
		local autoCheck = autoMin ~= 0 and nearby >= autoMin and Menu.R.Auto:Value()
		local comboCheck = self.mode == 1 and nearby >= Menu.R.Count:Value() and Menu.R.Combo:Value()	
    	--
    	if autoCheck or comboCheck then
        	self.R:Cast()
        	return
        end
    end
    --
    if self.Q:IsReady() and Menu.Q.Auto:Value() then
        for i=1, #self.enemies do
            local enemy = self.enemies[i]                
            if IsImmobile(enemy, 0.75) then                             
                self.Q:Cast(enemy)
                return                   
            end                
        end 
    end
    --
    if self.W:IsReady() then
    	local comboCheck = Menu.W.Combo:Value() and self.mode == 1 and ManaPercent(myHero) >= Menu.W.Mana:Value()
    	if Menu.W.HardCC:Value() or comboCheck then
	    	local allies = GetAllyHeroes(self.W.Range)
	    	local furthest = myHero
	    	--
		    for i=1, #allies do
		        local ally = allies[i]
		        local enemyCount = CountEnemiesAround(ally, 800)
		        --
	            if ally.health < enemyCount * ally.levelData.lvl * 25 then
	                self.W:Cast(ally); return                
	            end
	            if hardCC and IsImmobile(ally) and enemyCount > 0 then
	                self.W:Cast(ally); return
	            end
	            --
	            if GetDistanceSqr(ally) >= GetDistanceSqr(furthest) then
	            	furthest = ally
	            end           
		    end
		    --
		    if comboCheck and not self.Q:IsReady() and GetDistance(furthest) >= 600 then
		    	self.W:Cast(furthest)
		    end		    
	    end         
    end                        
end

function Thresh:Flee()
	if self.target then
		if Menu.E.Flee:Value() and self.E:IsReady() then		
			self.E:Cast(self:GetPosE(self.target, "Push"))
		elseif Menu.W.Flee:Value() and self.W:IsReady() then
			self.W:Cast(myHero)
		end		
	end        
end

function Thresh:GetPosE(unit, mode)
	local push = mode == "Push" and true or Menu.E.Key:Value()
	--	
	return myHero.pos:Extended(unit.pos, self.E.Range * (push and 1 or -1))
end

------------------------------------------------------------------

function Thresh:Combo()
	local target = GetTarget(self.Q.Range, 0)
    if not target then return end
    --
    if self.E:IsReady() and Menu.E.Combo:Value() and GetDistance(target) < self.E.Range and ManaPercent(myHero) >= Menu.E.Mana:Value() then
        local flayTowards = self:GetPosE(target)      
        self.E:Cast(flayTowards)      
    elseif self.Q:IsReady() and Menu.Q.Combo:Value() and ManaPercent(myHero) >= Menu.Q.Mana:Value()then
        self.Q:CastToPred(target, 2)       
    end
end

function Thresh:Harass()
	local target = GetTarget(self.Q.Range, 0)
    if not target then return end
    --
    if self.E:IsReady() and Menu.E.Harass:Value() and GetDistance(target) < self.E.Range and ManaPercent(myHero) >= Menu.E.ManaHarass:Value() then
        local flayTowards = self:GetPosE(target)      
        self.E:Cast(flayTowards)      
    elseif self.Q:IsReady() and Menu.Q.Harass:Value() and ManaPercent(myHero) >= Menu.Q.ManaHarass:Value()then
        self.Q:CastToPred(target, 2)       
    end
end

Thresh:__init()