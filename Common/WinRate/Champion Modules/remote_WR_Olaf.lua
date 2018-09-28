
--Written by JSN and provided on: 
--http://gamingonsteroids.com/topic/24468-817-project-winrate-v18-smoother-aa-resetsgsoorb-supported/?p=180176

class 'Olaf'

function Olaf:__init()
	--[[Data Initialization]]
	self.Allies, self.Enemies = {}, {}
	self.scriptVersion = "1.0"
	self:Spells()
	self:Menu() 
	--[[Default Callbacks]]   
	--Callback.Add("Load",          function() self:OnLoad()    end) --Just Use OnLoad()
	Callback.Add("Tick",          function() self:OnTick()    end)
	Callback.Add("Draw",          function() self:OnDraw()    end)
	--[[Orb Callbacks]]        
	OnPreAttack(function(...) self:OnPreAttack(...) end)
	OnPostAttack(function(...) self:OnPostAttack(...) end)
	OnPreMovement(function(...) self:OnPreMovement(...) end)
	--[[Custom Callbacks]]
	OnDash(function(unit, unitPos, unitPosTo, dashSpeed, dashGravity, dashDistance) self:OnDash(unit, unitPos, unitPosTo, dashSpeed, dashGravity, dashDistance) end)
end

function Olaf:Spells()
	self.Q = Spell({
		Slot = 0,
		Range = 1000,
		Delay = 0.25,
		Speed = 1600,
		Radius = 70,
		Collision = false,
		From = myHero,
		Type = "SkillShot"
	})
	self.W = Spell({
		Slot = 1,
		Range = 250, -- trigger range
		Delay = 0.25,
		Speed = huge,
		Radius = huge,
		Collision = false,
		From = myHero,
		Type = "Press"
	})
	self.E = Spell({
		Slot = 2,
		Range = 325,
		Delay = 0.25,
		Speed = 20,
		Radius = huge,
		Collision = false,
		From = myHero,
		Type = "Targetted",
		DmgType = "True"
	})
	self.R = Spell({
		Slot = 3,
		Range = 400,
		Delay = 0.25,
		Speed = 500,
		Radius = huge,
		Collision = false,
		From = myHero,
		Type = "Press"
	})
	self.Q.GetDamage = function(spellInstance, enemy, stage)
        if not spellInstance:IsReady() then return 0 end
        --
        local qLvl = myHero:GetSpellData(_Q).level 
        return 35 + 45*qLvl + myHero.bonusDamage                
    end
    self.E.GetDamage = function(spellInstance, enemy, stage)
        if not spellInstance:IsReady() then return 0 end
        --
        local eLvl = myHero:GetSpellData(_E).level
        return 25 + 45*eLvl + 0.5 * myHero.totalDamage                
    end
end

function Olaf:Menu()
	--Q--
	Menu.Q:MenuElement({name = " ", drop = {"Combo Settings"}})
	Menu.Q:MenuElement({id = "Combo", name = "Use on Combo", value = true})
	Menu.Q:MenuElement({id = "Mana", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
	Menu.Q:MenuElement({name = " ", drop = {"Harass Settings"}})
	Menu.Q:MenuElement({id = "Harass", name = "Use on Harass", value = true})
	Menu.Q:MenuElement({id = "ManaHarass", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
	Menu.Q:MenuElement({name = " ", drop = {"Farm Settings"}})
	Menu.Q:MenuElement({id = "Jungle", name = "Use on JungleClear", value = true})
	Menu.Q:MenuElement({id = "Clear", name = "Use on LaneClear", value = true})
	Menu.Q:MenuElement({id = "Min", name = "Minions To Cast", value = 3, min = 0, max = 8, step = 1})
	Menu.Q:MenuElement({id = "ManaClear", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})    
	Menu.Q:MenuElement({name = " ", drop = {"Misc"}})
	Menu.Q:MenuElement({id = "KS", name = "Use on KS", value = true})
	Menu.Q:MenuElement({id = "Flee", name = "Use on Flee", value = true})
	Menu.Q:MenuElement({id = "Auto", name = "Auto Use on Dashing Enemies", value = true})
	--W--
	Menu.W:MenuElement({name = " ", drop = {"Combo Settings"}})
	Menu.W:MenuElement({id = "Combo", name = "Use on Combo", value = true})
	Menu.W:MenuElement({id = "Mana", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
	Menu.W:MenuElement({name = " ", drop = {"Harass Settings"}})
	Menu.W:MenuElement({id = "Harass", name = "Use on Harass", value = false})
	Menu.W:MenuElement({id = "ManaHarass", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
	--E--
	Menu.E:MenuElement({name = " ", drop = {"Combo Settings"}})
	Menu.E:MenuElement({id = "Combo", name = "Use on Combo", value = true})
	Menu.E:MenuElement({name = " ", drop = {"Harass Settings"}})
	Menu.E:MenuElement({id = "Harass", name = "Use on Harass", value = false})
	Menu.E:MenuElement({name = " ", drop = {"Misc"}})
	Menu.E:MenuElement({id = "KS", name = "Use on KS", value = true})
	Menu.E:MenuElement({id = "MinHP", name = "Min Health %", value = 5, min = 0, max = 50, step = 1})  
	--R--
	Menu.R:MenuElement({name = " ", drop = {"Misc"}})
	Menu.R:MenuElement({id = "Auto", name = "Use if Hard CC'ed", value = true})
	Menu.R:MenuElement({id = "Min", name = "Min Duration", value = 0.5, min = 0, max = 3, step = 0.1})
	--Items--
	Menu:MenuElement({id = "Items", name = "Items Settings", type = MENU})
	Menu.Items:MenuElement({id = "Tiamat", name = "Use Tiamat", value = true})
	Menu.Items:MenuElement({id = "TitanicHydra", name = "Use Titanic Hydra", value = true})
	Menu.Items:MenuElement({id = "Hydra", name = "Use Ravenous Hydra", value = true})
	Menu.Items:MenuElement({id = "Youmuu", name = "Use Youmuu's", value = true})
	
	Menu:MenuElement({name = " ", drop = {" "}})
	Menu:MenuElement({name = "[WR] "..charName.." Script", drop = {"Release_"..self.scriptVersion}})
	Menu:MenuElement({name = "Olaf Module Created By", drop = {"JSN"}})	
end

function Olaf:OnTick() 
	if ShouldWait()then return end 
	--        
	self.enemies = GetEnemyHeroes(self.Q.Range)
	self.target = GetTarget(self.Q.Range, 0)
	self.mode = GetMode()
	--
	self:UpdateItems()
	self:KillSteal()
	self:Auto()
	--               
	if not self.mode then return end        
	local executeMode = 
		self.mode == 1 and self:Combo()   or 
		self.mode == 2 and self:Harass()  or
		self.mode == 3 and self:Clear()   or
		self.mode == 4 and self:Clear()   or
		self.mode == 6 and self:Flee()      
end

function Olaf:OnPreMovement(args) 
	if ShouldWait() then 
		args.Process = false
		return 
	end 
end

function Olaf:OnPreAttack(args) 
	if ShouldWait() then 
		args.Process = false
		return
	end
	--	
	if self.W:IsReady() then
		local isHero = args.Target and args.Target.type and args.Target.type == Obj_AI_Hero
		local comboCheck  = self.mode == 1 and Menu.W.Combo:Value()  and ManaPercent(myHero) >= Menu.W.Mana:Value()
		local harassCheck = self.mode == 2 and Menu.W.Harass:Value() and ManaPercent(myHero) >= Menu.W.ManaHarass:Value()
		if isHero and (comboCheck or harassCheck) then 
		   self.W:Cast()
		end
	end		
end

function Olaf:OnPostAttack()
	local target = GetTargetByHandle(myHero.attackData.target)
	if ShouldWait() or not IsValidTarget(target) then return end 
	--	
	if self.mode == 1 or self.mode == 2 then
		self:UseItems(target)           
	end   
end

function Olaf:OnDash(unit, unitPos, unitPosTo, dashSpeed, dashGravity, dashDistance)  
	if ShouldWait() then return end
	--   
	if unit.team == TEAM_ENEMY and Menu.Q.Auto:Value() and self.Q:IsReady() and IsValidTarget(unit, 500) then
		if IsFacing(unit, myHero) or GetDistance(unitPosTo) > 300 then
			self.Q:CastToPred(unit, 3)
		end
	end	
end

function Olaf:Auto()
	if Menu.R.Auto:Value() and IsImmobile(myHero, Menu.R.Min:Value()) then
		self.R:Cast()
	end
end

function Olaf:KillSteal()
	if self.enemies then
		for i = 1, #self.enemies do
			local enemy = self.enemies[i]
			if GetDistance(enemy) <= self.E.Range and Menu.E.KS:Value() and self.E:IsReady() and self.E:CalcDamage(enemy) >= enemy.health then
				self.E:Cast(enemy)				
			elseif Menu.Q.KS:Value() and self.Q:IsReady() and self.Q:CalcDamage(enemy) >= enemy.health + enemy.shieldAD then
				self.Q:CastToPred(enemy, 2)				
			end
		end
	end     
end

function Olaf:Combo()
	local qTarget = GetTarget(self.Q.Range, 0)	
	if qTarget and Menu.Q.Combo:Value() and self.Q:IsReady() and ManaPercent(myHero) >= Menu.Q.Mana:Value()then
		self.Q:CastToPred(qTarget, 2)
	end
	--
	local eTarget = GetTarget(self.E.Range, 2)
	if eTarget and Menu.E.Combo:Value() and self.E:IsReady() and HealthPercent(myHero) >= Menu.E.MinHP:Value()then
		self.E:Cast(eTarget)
	end
	--
	if self.target then		
		self:Youmuu(self.target)
	end
end
	
function Olaf:Harass()
	local qTarget = GetTarget(self.Q.Range, 0)	
	if qTarget and Menu.Q.Harass:Value() and self.Q:IsReady() and ManaPercent(myHero) >= Menu.Q.ManaHarass:Value()then
		self.Q:CastToPred(qTarget, 2)
	end
	--
	local eTarget = GetTarget(self.E.Range, 2)
	if eTarget and Menu.E.Harass:Value() and self.E:IsReady() and HealthPercent(myHero) >= Menu.E.MinHP:Value()then
		self.E:Cast(eTarget)
	end
end

function Olaf:Clear()            
	local qRange, jCheckQ, lCheckQ = self.Q.Range, Menu.Q.Jungle:Value(), Menu.Q.Clear:Value()
	if self.Q:IsReady() and (jCheckQ or lCheckQ) and ManaPercent(myHero) >= Menu.Q.ManaClear:Value() then
		local minions = (jCheckQ and GetMonsters(qRange)) or {}
		minions = (#minions == 0 and lCheckQ and GetEnemyMinions(qRange)) or minions
		if #minions == 0 then return end
		--
		local pos, hit = GetBestLinearCastPos(self.Q, nil, minions)
		if pos and hit >= Menu.Q.Min:Value() or (minions[1] and minions[1].team == TEAM_JUNGLE) then
			self.Q:Cast(pos)
		end
	end
end

function Olaf:Flee()        
	if #self.enemies > 0 and Menu.Q.Flee:Value() and self.Q:IsReady() then
		local qTarget = GetClosestEnemy()
		if IsValidTarget(qTarget, self.Q.Range) then                
			self.Q:CastToPred(qTarget, 2)
		end
	end
end        

function Olaf:OnDraw()
	DrawSpells(self)    
end

local ItemHotKey = {[ITEM_1] = HK_ITEM_1, [ITEM_2] = HK_ITEM_2, [ITEM_3] = HK_ITEM_3, [ITEM_4] = HK_ITEM_4, [ITEM_5] = HK_ITEM_5, [ITEM_6] = HK_ITEM_6}
function Olaf:UpdateItems()
	--[[
		Youmuu = 3142
		Tiamat = 3077
		Hidra = 3074
		Titanic = 3748
	]]
	for i = ITEM_1, ITEM_7 do
		local id = myHero:GetItemData(i).itemID
		--[[In Case They Sell Items]]
		if self.Youmuus and i == self.Youmuus.Index and id ~= 3142 then
			self.Youmuus = nil
		elseif self.Tiamat and i == self.Tiamat.Index and id ~= 3077 then
			self.Tiamat = nil
		elseif self.Hidra and i == self.Hidra.Index and id ~= 3074 then
			self.Hidra = nil
		elseif self.Titanic and i == self.Titanic.Index and id ~= 3748 then
			self.Titanic = nil
		end 
		--- 
		if id == 3142 then 
			self.Youmuus = {Index = i, Key = ItemHotKey[i]}
		elseif id == 3077 then
			self.Tiamat = {Index = i, Key = ItemHotKey[i]}
		elseif id == 3074 then
			self.Hidra = {Index = i, Key = ItemHotKey[i]}
		elseif id == 3748 then
			self.Titanic = {Index = i, Key = ItemHotKey[i]}
		end
	end
end

function Olaf:UseItems(target)	
	if self.Tiamat or self.Hidra then 
		self:Hydra(target)        
	elseif self.Titanic then
		self:TitanicHydra(target)            
	end
end

function Olaf:UseItem(key, reset)
    KeyDown(key)
    KeyUp(key)
    return reset and DelayAction(function() ResetAutoAttack() end, 0.2)
end

function Olaf:Youmuu(target)
	if self.Youmuus and Menu.Items.Youmuu:Value() and myHero:GetSpellData(self.Youmuus.Index).currentCd == 0 and IsValidTarget(target, 600) then
		self:UseItem(self.Youmuus.Key, false)                       
	end
end

function Olaf:TitanicHydra(target)
	if self.Titanic and Menu.Items.TitanicHydra:Value() and myHero:GetSpellData(self.Titanic.Index).currentCd == 0 and IsValidTarget(target, 380) then
		self:UseItem(self.Titanic.Key, true)
	end
end

function Olaf:Hydra(target)
	if self.Hidra and Menu.Items.Hydra:Value() and myHero:GetSpellData(self.Hidra.Index).currentCd == 0 and IsValidTarget(target, 380) then
		self:UseItem(self.Hidra.Key, true)
	elseif self.Tiamat and Menu.Items.Tiamat:Value() and myHero:GetSpellData(self.Tiamat.Index).currentCd == 0 and IsValidTarget(target, 380) then
		self:UseItem(self.Tiamat.Key, true)           
	end
end

Olaf() 