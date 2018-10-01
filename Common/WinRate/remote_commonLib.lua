
    if _G.WR_COMMON_LOADED then
        return 
    end
    --
    _G.WR_COMMON_LOADED = true 

    require "MapPositionGOS"
    require "DamageLib"    
    require "2DGeometry"    

--
    local huge = math.huge
    local pi = math.pi
    local floor = math.floor 
    local ceil = math.ceil 
    local sqrt = math.sqrt 
    local max = math.max 
    local min = math.min 
    --
    local lenghtOf = math.lenghtOf
    local abs = math.abs 
    local deg = math.deg 
    local cos = math.cos 
    local sin = math.sin 
    local acos = math.acos 
    local atan = math.atan 
    --
    local contains = table.contains
    local insert   = table.insert 
    local remove   = table.remove 
    local sort     = table.sort
    --
    local TEAM_JUNGLE = 300 
    local TEAM_ALLY = myHero.team 
    local TEAM_ENEMY = TEAM_JUNGLE - TEAM_ALLY
    --
    local _STUN = 5
    local _TAUNT = 8    
    local _SLOW = 10    
    local _SNARE = 11
    local _FEAR = 21    
    local _CHARM = 22
    local _SUPRESS = 24        
    local _KNOCKUP = 29
    local _KNOCKBACK = 30 
    --
    local Vector       = Vector
    local KeyDown      = Control.KeyDown 
    local KeyUp        = Control.KeyUp
    local IsKeyDown    = Control.IsKeyDown
    local SetCursorPos = Control.SetCursorPos
    --
    local GameCanUseSpell      = Game.CanUseSpell
    local Timer                = Game.Timer
    local Latency              = Game.Latency
    local HeroCount            = Game.HeroCount
    local Hero                 = Game.Hero
    local MinionCount          = Game.MinionCount
    local Minion               = Game.Minion
    local TurretCount          = Game.TurretCount
    local Turret               = Game.Turret
    local WardCount            = Game.WardCount
    local Ward                 = Game.Ward
    local ObjectCount          = Game.ObjectCount
    local Object               = Game.Object
    local MissileCount         = Game.MissileCount
    local Missile              = Game.Missile
    local ParticleCount        = Game.ParticleCount
    local Particle             = Game.Particle 
    --
    local DrawCircle               = Draw.Circle    
    local DrawLine                 = Draw.Line
    local DrawColor                = Draw.Color
    local DrawMap                  = Draw.CircleMinimap
    local DrawText                 = Draw.Text
    --
    local barHeight     = 8
    local barWidth      = 103
    local barXOffset    = 18                            
    local barYOffset    = 10
    local DmgColor      = DrawColor(255,235,103,25)

    local Color = {
        Red     = DrawColor(255,255,0,0),
        Green   = DrawColor(255,0,255,0),
        Blue    = DrawColor(255,0,0,255),
        White   = DrawColor(255,255,255,255),
        Black   = DrawColor(255,0,0,0),
    }

    --<Interfaces Control>
    if not SDK then
        local res, str = Game.Resolution(), "PLEASE ENABLE ICS ORBWALKER"
        Callback.Add("Draw", function()                       
            DrawText(str, 64, res.x/2-(#str * 14), res.y/2, Color.Red)
        end)
        return 
    end
    local _ENV = _G
    local SDK               = _G.SDK
    local Orbwalker         = SDK.Orbwalker 
    local ObjectManager     = SDK.ObjectManager
    local TargetSelector    = SDK.TargetSelector
    local HealthPrediction  = SDK.HealthPrediction
    --local Prediction     = Pred --Wont work cuz its being initialized before the class
   --</Interfaces Control>

    --<IOrbwalker>

    local function GetMode() --1:Combo|2:Harass|3:LaneClear|4:JungleClear|5:LastHit|6:Flee 
        local modes = Orbwalker.Modes               
        for i=0, #modes do            
            if modes[i] then return i+1 end 
        end
        return nil 
    end

    local function GetMinions(range)        
        return ObjectManager:GetMinions(range)
    end

    local function GetAllyMinions(range)
        return ObjectManager:GetAllyMinions(range)
    end

    local function GetEnemyMinions(range)
        return ObjectManager:GetEnemyMinions(range)
    end

    local function GetMonsters(range)
        return ObjectManager:GetMonsters(range)
    end

    local function GetHeroes(range)
        return ObjectManager:GetHeroes(range)
    end

    local function GetAllyHeroes(range)
        return ObjectManager:GetAllyHeroes(range)
    end

    local function GetEnemyHeroes(range)
        return ObjectManager:GetEnemyHeroes(range)
    end

    local function GetTurrets(range)
        return ObjectManager:GetTurrets(range)
    end

    local function GetAllyTurrets(range)
        return ObjectManager:GetAllyTurrets(range)
    end

    local function GetEnemyTurrets(range)
        return ObjectManager:GetEnemyTurrets(range)
    end

    local function GetWards(range)
        return ObjectManager:GetOtherMinions(range)
    end

    local function GetAllyWards(range)
        return ObjectManager:GetOtherAllyMinions(range)
    end

    local function GetEnemyWards(range)
        return ObjectManager:GetOtherEnemyMinions(range)
    end

    local function OnPreMovement(fn)
        Orbwalker:OnPreMovement(fn)
    end

    local function OnPreAttack(fn)
        Orbwalker:OnPreAttack(fn)
    end

    local function OnAttack(fn)
        Orbwalker:OnAttack(fn)
    end

    local function OnPostAttack(fn)
        Orbwalker:OnPostAttack(fn)
    end

    local function OnPostAttackTick(fn)
        if Orbwalker.OnPostAttackTick then
            Orbwalker:OnPostAttackTick(fn)
        else
            Orbwalker:OnPostAttack(fn)
        end
    end

    local function OnUnkillableMinion(fn)
        if Orbwalker.OnUnkillableMinion then
            Orbwalker:OnUnkillableMinion(fn)
        end
    end

    local function SetMovement(bool)
        Orbwalker:SetMovement(bool)
    end

    local function SetAttack(bool)
        Orbwalker:SetAttack(bool)
    end

    local function GetTarget(range, mode)     --0:Physical|1:Magical|2:True
        return TargetSelector:GetTarget(range or huge, mode or 0)
    end

    local function ResetAutoAttack()
        Orbwalker:__OnAutoAttackReset()
    end

    local function IsAutoAttacking()
        return Orbwalker:IsAutoAttacking()
    end

    local function Orbwalk()
        Orbwalker:Orbwalk()
    end

    local function SetHoldRadius(value)
        Orbwalker.Menu.General.HoldRadius:Value(value)
    end

    local function SetMovementDelay(value)
        Orbwalker.Menu.General.MovementDelay:Value(value)
    end

    local function ForceTarget(unit)        
        Orbwalker.ForceTarget = unit
    end

    local function ForceMovement(pos)        
        Orbwalker.ForceMovement = pos
    end

    local function GetHealthPrediction(unit, delay)
        return HealthPrediction:GetPrediction(unit, delay)
    end

    local function GetPriority(unit)
        return TargetSelector:GetPriority(unit) or 1
    end    
    
    --</IOrbwalker>

    local function TextOnScreen(str) 
        local res = Game.Resolution()  
        Callback.Add("Draw", function()                  
            DrawText(str, 64, res.x/2-(#str * 10), res.y/2, Color.Red)
        end)
    end
 

    local function Ready(spell)
        return GameCanUseSpell(spell) == 0
    end

    local function RotateAroundPoint(v1,v2, angle)
        local cos, sin = cos(angle), sin(angle)
        local x = ((v1.x - v2.x) * cos) - ((v1.z - v2.z) * sin) + v2.x
        local z = ((v1.z - v2.z) * cos) + ((v1.x - v2.x) * sin) + v2.z
        return Vector(x, v1.y, z or 0)
    end

    local function GetDistanceSqr(p1, p2) 
        p2 = p2 or myHero
        p1 = p1.pos or p1
        p2 = p2.pos or p2

        local dx, dz = p1.x - p2.x, p1.z - p2.z 
        return dx * dx + dz * dz
    end

    local function GetDistance(p1, p2)
        return sqrt(GetDistanceSqr(p1, p2))
    end 

    local ItemHotKey = {[ITEM_1] = HK_ITEM_1, [ITEM_2] = HK_ITEM_2, [ITEM_3] = HK_ITEM_3, [ITEM_4] = HK_ITEM_4, [ITEM_5] = HK_ITEM_5, [ITEM_6] = HK_ITEM_6, [ITEM_7] = HK_ITEM_7}
    local function GetItemSlot(id) --returns Slot, HotKey
        for i = ITEM_1, ITEM_7 do
            if myHero:GetItemData(i).itemID == id then
               return i, ItemHotKey[i]
            end
        end
        return 0 
    end

    local wardItemIDs = {3340,2049,2301,2302,2303,3711}
    local function GetWardSlot() --returns Slot, HotKey
        for i=1, #wardItemIDs do            
            local ward, key = GetItemSlot(wardItemIDs[i])        
            if ward ~= 0 then               
                return ward , key
            end
        end
    end

    local rotateAngle = 0
    local function DrawMark(pos, thickness, size, color)
        rotateAngle = (rotateAngle + 2) % 720
        local hPos, thickness, color, size = pos or myHero.pos, thickness or 3, color or Color.Red, size*2 or 150
        local offset, rotateAngle, mod = hPos + Vector(0, 0, size), rotateAngle/360 * pi , 240/360*pi    
        local points = {
            hPos:To2D(),
            RotateAroundPoint(offset, hPos, rotateAngle):To2D() ,  
            RotateAroundPoint(offset, hPos, rotateAngle+mod):To2D() ,
            RotateAroundPoint(offset, hPos, rotateAngle+2*mod):To2D()
        }        
        --
        for i=1, #points do
            for j=1, #points do
                local lambda = i~=j and DrawLine(points[i].x-3, points[i].y-5, points[j].x-3, points[j].y-5, thickness, color)    -- -3 and -5 are offsets (because ext)
            end
        end
    end

    local function DrawRectOutline(vec1, vec2, width, color)
        local vec3, vec4 = vec2 - vec1, vec1 - vec2
        local A = (vec1 + (vec3:Perpendicular2():Normalized() * width )):To2D()
        local B = (vec1 + (vec3:Perpendicular():Normalized() * width )):To2D()
        local C = (vec2 + (vec4:Perpendicular2():Normalized() * width )):To2D()
        local D = (vec2 + (vec4:Perpendicular():Normalized() * width )):To2D()

        DrawLine(A, B, 3, color)
        DrawLine(B, C, 3, color)
        DrawLine(C, D, 3, color)
        DrawLine(D, A, 3, color)
    end      

    local function VectorPointProjectionOnLineSegment(v1, v2, v)
        local cx, cy, ax, ay, bx, by = v.x, v.z, v1.x, v1.z, v2.x, v2.z
        local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) * (bx - ax) + (by - ay) * (by - ay))
        local pointLine = { x = ax + rL * (bx - ax), z = ay + rL * (by - ay) }
        local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
        local isOnSegment = rS == rL
        local pointSegment = isOnSegment and pointLine or {x = ax + rS * (bx - ax), z = ay + rS * (by - ay)}
        return pointSegment, pointLine, isOnSegment
    end    

    local function mCollision(pos1, pos2, spell, list) --returns a table with minions (use #table to get count)
        local result, speed, width, delay, list = {}, spell.Speed, spell.Width + 65, spell.Delay , list
        --
        if not list then
            list = GetEnemyMinions(max(GetDistance(pos1), GetDistance(pos2)) + spell.Range + 100)
        end
        --
        for i = 1, #list do
            local m = list[i]
            local pos3 = delay and m:GetPrediction(speed, delay) or m.pos
            if m and m.team ~= TEAM_ALLY and m.dead == false and m.isTargetable and GetDistanceSqr(pos1, pos2) > GetDistanceSqr(pos1, pos3) then                
                local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(pos1, pos2, pos3)
                if isOnSegment and GetDistanceSqr(pointSegment, pos3) < width * width  then
                    result[#result+1] = m
                end
            end
        end               
        return result        
    end

    local function hCollision(pos1, pos2, spell, list)  --returns a table with heroes (use #table to get count)
        local result, speed, width, delay, list = {}, spell.Speed, spell.Width + 65, spell.Delay , list
        if not list then
            list = GetEnemyHeroes(max(GetDistance(pos1), GetDistance(pos2)) + spell.Range + 100)
        end
        for i = 1, #list do
            local h = list[i]
            local pos3 = delay and h:GetPrediction(speed, delay) or h.pos
            if h and h.team ~= TEAM_ALLY and h.dead == false and h.isTargetable and GetDistanceSqr(pos1, pos2) > GetDistanceSqr(pos1, pos3) then                
                local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(pos1, pos2, pos3)
                if isOnSegment and GetDistanceSqr(pointSegment, pos3) < width * width  then
                    insert(result, h)
                end
            end
        end
        return result
    end   

    local function HealthPercent(unit)
        return unit.maxHealth > 5 and unit.health/unit.maxHealth * 100 or 100
    end

    local function ManaPercent(unit)
        return unit.maxMana > 0 and unit.mana/unit.maxMana * 100 or 100
    end

    local function HasBuffOfType(unit, bufftype, delay)    --returns bool and endtime , why not starting at buffCOunt and check back to 1 ?
        local delay = delay or 0
        local bool = false
        local endT = Timer()
        for i=1, unit.buffCount do
            local buff = unit:GetBuff(i)
            if buff.type == bufftype and buff.expireTime >= Timer() and buff.duration > 0 then
                if buff.expireTime > endT then
                    bool = true 
                    endT = buff.expireTime
                end
            end
        end
        return bool, endT
    end

    local function HasBuff(unit, buffname)  --returns bool 
        return GotBuff(unit, buffname) == 1
    end

    local function GetBuffByName(unit, buffname)    --returns buff 
        return GetBuffData(unit, buffname)
    end

    local function GetBuffByType(unit, bufftype)    --returns buff 
        for i=1, unit.buffCount do
            local buff = unit:GetBuff(i)
            if buff.type == bufftype and buff.expireTime >= Timer() and buff.duration > 0  then
                return buff
            end
        end
        return nil
    end

    local UndyingBuffs = {
        ["Aatrox"] = function(target, addHealthCheck)
            return HasBuff(target, "aatroxpassivedeath")
        end,
        ["Fiora"] = function(target, addHealthCheck)
            return HasBuff(target, "FioraW")
        end,
        ["Tryndamere"] = function(target, addHealthCheck)
            return HasBuff(target, "UndyingRage") and (not addHealthCheck or target.health <= 30)
        end,
        ["Vladimir"] = function(target, addHealthCheck)
            return HasBuff(target, "VladimirSanguinePool")
        end,
    }

    local function HasUndyingBuff(target, addHealthCheck)
        --Self Casts Only
        local buffCheck = UndyingBuffs[target.charName]
        if buffCheck and buffCheck(target, addHealthCheck) then return true end
        --Can Be Casted On Others
        if HasBuff(target, "JudicatorIntervention") or ((not addHealthCheck or HealthPercent(target) <= 10) and (HasBuff(target, "kindredrnodeathbuff") or HasBuff(target, "ChronoShift") or HasBuff(target, "chronorevive"))) then
            return true
        end        
        return target.isImmortal
    end    

    local function IsValidTarget(unit, range) -- the == false check is faster than using "not"
        return unit and unit.valid and unit.visible and not unit.dead and unit.isTargetableToTeam and (not range or GetDistance(unit) <= range) and (not unit.type == myHero.type or not HasUndyingBuff(unit, true))
    end

    local function GetTrueAttackRange(unit, target)
        local extra = target and target.boundingRadius or 0
        return unit.range + unit.boundingRadius + extra
    end

    local function HeroesAround(range, pos, team)
        pos = pos or myHero.pos
        local dist = GetDistance(pos) + range + 100        
        local result = {}
        local heroes = (team == TEAM_ENEMY and GetEnemyHeroes(dist)) or (team == TEAM_ALLY and GetAllyHeroes(dist) or GetHeroes(dist))        
        for i = 1, #heroes do
            local h = heroes[i]
            if GetDistance(pos, h.pos) <= range then
                result[#result+1] = h
            end
        end
        return result
    end

    local function CountEnemiesAround(pos, range)
        return #HeroesAround(range, pos, TEAM_ENEMY)
    end 

    local function GetClosestEnemy(unit)
        local unit = unit or myHero 
        local closest, list = nil, GetHeroes()
        for i=1, #list do            
            local enemy = list[i]
            if IsValidTarget(enemy) and enemy.team ~= unit.team and (not closest or GetDistance(enemy, unit) < GetDistance(closest, unit)) then
                closest = enemy
            end        
        end
        return closest
    end

    local function MinionsAround(range, pos, team)
        pos = pos or myHero.pos
        local dist = GetDistance(pos) + range + 100
        local result = {}
        local minions = (team == TEAM_ENEMY and GetEnemyMinions(dist)) or (team == TEAM_ALLY and GetAllyMinions(dist) or GetMinions(dist))
        for i = 1, #minions do
            local m = minions[i]
            if m and not m.dead and GetDistance(pos, m.pos) <= range + m.boundingRadius then
                result[#result+1] = m
            end
        end
        return result
    end

    local function IsUnderTurret(pos, team)
        local turrets = GetTurrets(GetDistance(pos) + 1000)
        for i=1, #turrets do
            local turret = turrets[i]
            if GetDistance(turret, pos) <= 915 and turret.team == team then
                return turret
            end
        end        
    end

    local function GetDanger(pos)
        local result = 0
        --
        local turret = IsUnderTurret(pos, TEAM_ENEMY)
        if turret then
            result = result + floor((915-GetDistance(turret, pos))/17.3)
        end
        --
        local nearby = HeroesAround(700, pos, TEAM_ENEMY)
        for i=1, #nearby do
            local enemy = nearby[i]
            local dist, mod = GetDistance(enemy, pos), enemy.range < 350 and 2 or 1
            result = result + (dist <= GetTrueAttackRange(enemy) and 5 or 0) * mod
        end
        --
        result = result + #HeroesAround(400, pos, TEAM_ENEMY) * 1
        return result
    end

    local function IsImmobile(unit, delay) 
        if unit.ms == 0 then return true, unit.pos, unit.pos end
        local delay = delay or 0
        local debuff, timeCheck = {} , Timer() + delay
        for i=1, unit.buffCount do
            local buff = unit:GetBuff(i)
            if buff.expireTime >= timeCheck and buff.duration > 0 then
                debuff[buff.type] = true
            end
        end
        if  debuff[_STUN] or debuff[_TAUNT] or debuff[_SNARE] or debuff[_SLEEP] or
            debuff[_CHARM] or debuff[_SUPRESS] or debuff[_AIRBORNE] then            
            return true
        end            
    end

    local function IsFacing(unit, p2)
        p2 = p2 or myHero        
        p2 = p2.pos or p2
        local V = unit.pos - p2
        local D = unit.dir
        local Angle = 180 - deg(acos(V*D/(V:Len()*D:Len())))
        if abs(Angle) < 80 then 
            return true  
        end        
    end

    local function CheckHandle(tbl, handle)
        for i=1, #tbl do
            local v = tbl[i]            
            if handle == v.handle then return v end                                 
        end
    end

    local function GetTargetByHandle(handle)
        return CheckHandle(GetEnemyHeroes(1200), handle)    or 
               CheckHandle(GetMonsters(1200), handle)       or 
               CheckHandle(GetEnemyTurrets(1200), handle)   or
               CheckHandle(GetEnemyMinions(1200), handle)   or 
               CheckHandle(GetEnemyWards(1200), handle)
    end

    local function ShouldWait()
        return myHero.dead or HasBuff(myHero,"recall") or Game.IsChatOpen() or (ExtLibEvade and ExtLibEvade.Evading == true) 
    end

    local Emote = {
        Joke = HK_ITEM_1, 
        Taunt = HK_ITEM_2,
        Dance = HK_ITEM_3,
        Mastery = HK_ITEM_5,
        Laugh = HK_ITEM_7,
        Casting = false
    }  

    local function CastEmote(emote)        
        if not emote or Emote.Casting or myHero.attackData.state == STATE_WINDUP then return end
        --
        Emote.Casting = true        
        KeyDown(HK_LUS)        
        KeyDown(emote)            
        DelayAction(function()
            KeyUp(emote)
            KeyUp(HK_LUS)                
            Emote.Casting = false                
        end, 0.01)        
    end

    -- Farm Stuff

    local function ExcludeFurthest(average,lst,sTar)
        local removeID = 1 
        for i = 2, #lst do 
            if GetDistanceSqr(average, lst[i].pos) > GetDistanceSqr(average, lst[removeID].pos) then 
                removeID = i 
            end 
        end 

        local Newlst = {}
        for i = 1, #lst do 
            if (sTar and lst[i].networkID == sTar.networkID) or i ~= removeID then 
                Newlst[#Newlst + 1] = lst[i]
            end
        end
        return Newlst 
    end

    local function GetBestCircularCastPos(spell, sTar, lst)
        local average = {x = 0, z = 0, count = 0} 
        local heroList = lst and lst[1] and (lst[1].type == myHero.type)
        local range = spell.Range or 2000
        local radius = spell.Radius or 50
        if sTar and (not lst or #lst == 0) then 
            return Prediction:GetBestCastPosition(sTar,spell), 1
        end
        --
        for i = 1, #lst do 
            if IsValidTarget(lst[i], range) then
                local org = heroList and Prediction:GetBestCastPosition(lst[i],spell) or lst[i].pos
                average.x = average.x + org.x 
                average.z = average.z + org.z 
                average.count = average.count + 1
            end
        end 
        --
        if sTar and sTar.type ~= lst[1].type then 
            local org = heroList and Prediction:GetBestCastPosition(sTar,spell) or lst[i].pos
            average.x = average.x + org.x 
            average.z = average.z + org.z 
            average.count = average.count + 1
        end
        --
        average.x = average.x/average.count 
        average.z = average.z/average.count 
        --
        local inRange = 0 
        for i = 1, #lst do 
            local bR = lst[i].boundingRadius
            if GetDistanceSqr(average, lst[i].pos) - bR * bR < radius * radius then 
                inRange = inRange + 1 
            end
        end
        --
        local point = Vector(average.x,myHero.pos.y,average.z)
        --
        if inRange == #lst then 
            return point, inRange
        else 
            return GetBestCircularCastPos(spell, sTar, ExcludeFurthest(average, lst))
        end
    end 

    local function GetBestLinearCastPos(spell, sTar, list)
        startPos = spell.From.pos or myHero.pos
        local isHero =  list[1].type == myHero.type
        --
        local center = GetBestCircularCastPos(spell, sTar, list)
        local endPos = startPos + (center - startPos):Normalized() * spell.Range
        local MostHit = isHero and #hCollision(startPos, endPos, spell, list) or #mCollision(startPos, endPos, spell, list)      
        return endPos, MostHit
    end
    
    local function GetBestLinearFarmPos(spell)
        local minions = GetEnemyMinions(spell.Range+spell.Radius)
        if #minions == 0 then return nil, 0 end
        return GetBestLinearCastPos(spell, nil, minions)
    end

    local function GetBestCircularFarmPos(spell)
        local minions = GetEnemyMinions(spell.Range+spell.Radius)
        if #minions == 0 then return nil, 0 end
        return GetBestCircularCastPos(spell, nil, minions)
    end

    local function CircleCircleIntersection(c1, c2, r1, r2)
        local D = GetDistance(c1, c2)
        if D > r1 + r2 or D <= abs(r1 - r2) then return nil end
        local A = (r1 * r2 - r2 * r1 + D * D) / (2 * D)
        local H = sqrt(r1 * r1 - A * A)
        local Direction = (c2 - c1):Normalized()
        local PA = c1 + A * Direction
        local S1 = PA + H * Direction:Perpendicular()
        local S2 = PA - H * Direction:Perpendicular()
        return S1, S2
    end

    function PassivePercentMod(source, target, dmgMod)        
        local tarMinion = target.type == Obj_AI_Minion and target        
        local newMod = dmgMod

        if source.type == Obj_AI_Turret then
            if tarMinion and (tarMinion.charName:find("MinionSiege") or tarMinion.charName:find("MinionSuper")) then
                newMod = newMod * 0.7
            end
        end

        if source.type == Obj_AI_Minion then
            if tarMinion and Game.mapID == 10 then
                newMod = newMod * (1 + minion.percentDamageToBarracksMinionMod)
            end
        end

        if tarMinion then
            if tarMinion.charName:find("MinionMelee") and HasBuff(tarMinion, "exaltedwithbaronnashorminion") then
                newMod = newMod * 0.25
            end
        end

        if source.type == Obj_AI_Hero then            
            if tarMinion then
                if HasBuff(source, "barontarget") and tarMinion.charName:find("SRU_Baron") then
                    newMod = newMod * 0.5
                end
            end
        end

        return newMod
    end

    local reductions = {
        ["Alistar"]  = function(t) return HasBuff(t, "FerociousHowl")          and (0.45 + 0.1*t:GetSpellData(_R).level) end,
        ["Annie"]    = function(t) return HasBuff(t, "AnnieE")                 and (0.10 + 0.06*t:GetSpellData(_E).level) end,
        ["Galio"]    = function(t) return HasBuff(t, "GalioW")                 and (0.15 + 0.05*t:GetSpellData(_W).level + 0.08 * t.bonusMagicResist/100) end,
        ["Garen"]    = function(t) return HasBuff(t, "GarenW")                 and (0.30) end,
        ["Gragas"]   = function(t) return HasBuff(t, "gragaswself")            and (0.08 + 0.02*t:GetSpellData(_W).level + 0.04 * t.ap/100) end,
        ["Irelia"]   = function(t) return HasBuff(t, "ireliawdefense")         and (0.40 + 0.05*t:GetSpellData(_W).level + 0.07 * t.ap/100) end,
        ["Malzahar"] = function(t) return HasBuff(t, "malzaharpassiveshield")  and (0.90) end,
        ["MasterYi"] = function(t) return HasBuff(t, "Meditate")               and (0.45 + 0.05*t:GetSpellData(_W).level) end,
        ["Warwick"]  = function(t) return HasBuff(t, "WarwickE")               and (0.30 + 0.05*t:GetSpellData(_E).level) end,     
    }
    function CalcMagicalDamage(source, target, amount, time)
        local passiveMod = 0

        local totalMR = target.magicResist + target.bonusMagicResist
        if totalMR < 0 then
            passiveMod = 2 - 100 / (100 - totalMR)
        elseif totalMR * source.magicPenPercent - source.magicPen < 0 then
            passiveMod = 1
        else
            passiveMod = 100 / (100 + totalMR * source.magicPenPercent - source.magicPen)
        end

        local dmg = max(floor(PassivePercentMod(source, target, passiveMod) * amount), 0)

        if target.charName == "Kassadin" then
            dmg = dmg * 0.85
        elseif reductions[target.charName] then
            local reduction = reductions[target.charName](target) or 0
            dmg = dmg * (1-reduction)
        end

        if HasBuff(target, "cursedtouch") then
            dmg = dmg + amount * 0.1
        end 

        if HasBuff(myHero, "abyssalscepteraura") then
            damage = damage * 1.15
        end       

        return dmg
    end

    function CalcPhysicalDamage(source, target, amount, time)    
        local penPercent  = source.armorPenPercent
        local penPercentBonus = source.bonusArmorPenPercent
        local penFlat     = source.armorPen * (0.6 + 0.4 * source.levelData.lvl / 18)

        if source.type == Obj_AI_Minion then
            penFlat = 0
            penPercent = 1
            penPercentBonus = 1
        elseif source.type == Obj_AI_Turret then
            penFlat = 0
            penPercentBonus = 1
            penPercent = 0.7            
        end

        local armor = target.armor
        local bonusArmor = target.bonusArmor

        local value

        if armor < 0 then
            value = 2 - 100 / (100 - armor)
        elseif armor * penPercent - bonusArmor * (1 - penPercentBonus) - penFlat < 0 then
            value = 1
        else
            value = 100 / (100 + armor * penPercent - bonusArmor * (1 - penPercentBonus) - penFlat)
        end

        local dmg = max(floor(PassivePercentMod(source, target, value) * amount), 0)
        if reductions[target.charName] then
            local reduction = reductions[target.charName](target) or 0
            dmg = dmg * (1-reduction)
        end
        return dmg
    end

    function CalcMixedDamage(source, target, physicalAmount, magicalAmount)
        return CalcPhysicalDamage(source, target, physicalAmount) + CalcMagicalDamage(source, target, magicalAmount)
    end

    class "Spell"

    function Spell:__init(SpellData)
        self.Slot       = SpellData.Slot
        self.Range      = SpellData.Range or huge
        self.Delay      = SpellData.Delay or 0.25
        self.Speed      = SpellData.Speed or huge
        self.Radius     = SpellData.Radius or SpellData.Width or 0
        self.Width      = SpellData.Width or SpellData.Radius or 0
        self.From       = SpellData.From or myHero
        self.Collision  = SpellData.Collision or false
        self.Type       = SpellData.Type or "Press" 
        self.DmgType    = SpellData.DmgType or "Physical"       
        --
        return self
    end

    function Spell:IsReady()
        return GameCanUseSpell(self.Slot) == READY
    end

    function Spell:CanCast(unit, range, from)
        local from = from or self.From.pos
        local range = range or self.Range
        return unit and unit.valid and unit.visible and not unit.dead and (not range or GetDistance(from, unit) <= range)
    end

    function Spell:GetPrediction(target)
        return Prediction:GetBestCastPosition(target, self)        
    end

    function Spell:GetBestLinearCastPos(sTar, lst)
        return GetBestLinearCastPos(self, sTar, lst)
    end

    function Spell:GetBestCircularCastPos(sTar, lst)
        return GetBestCircularCastPos(self, sTar, lst)
    end

    function Spell:GetBestLinearFarmPos()
        return GetBestLinearFarmPos(self)
    end

    function Spell:GetBestCircularFarmPos()
        return GetBestCircularFarmPos(self)
    end

    function Spell:CalcDamage(target)
        local rawDmg = self:GetDamage(target, stage)
        if rawDmg <= 0 then return 0 end        
        --
        local damage = 0        
        if self.DmgType == 'Magical' then
            damage = CalcMagicalDamage(self.From, target, rawDmg)                        
        elseif self.DmgType == 'Physical' then
            damage = CalcPhysicalDamage(self.From, target, rawDmg);
        elseif self.DmgType == 'Mixed' then
            damage = CalcMixedDamage(self.From, target, rawDmg * .5, rawDmg * .5)
        end

        if self.DmgType ~= 'True' then
            if HasBuff(myHero, "summonerexhaustdebuff") then
                damage = damage * .6
            elseif HasBuff(myHero, "itemsmitechallenge") then
                damage = damage * .6
            elseif HasBuff(myHero, "itemphantomdancerdebuff") then
                damage = damage * .88
            end          
        else
            damage = rawDmg
        end       

        return damage
    end

    function Spell:GetDamage(target, stage)
        local slot = self:SlotToString()
        return self:IsReady() and getdmg(slot, target, self.From, stage or 1) or 0
    end

    function Spell:SlotToHK()
        return ({[_Q] = HK_Q, [_W] = HK_W, [_E] = HK_E, [_R] = HK_R, [SUMMONER_1] = HK_SUMMONER_1, [SUMMONER_2] = HK_SUMMONER_2})[self.Slot]
    end

    function Spell:SlotToString()
        return ({ [_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R" })[self.Slot]
    end

    function Spell:Cast(castOn)
        if not self:IsReady() or ShouldWait() then return end         
        --       
        local slot = self:SlotToHK()
        if self.Type == "Press" then
            KeyDown(slot)
            return KeyUp(slot)
        end
        --         
        local pos  = castOn.x and castOn
        local targ = castOn.health and castOn 
        --           
        if self.Type == "AOE" and pos then
            local bestPos, hit = self:GetBestCircularCastPos(targ, GetEnemyHeroes(self.Range+self.Radius))
            pos = hit >= 2 and bestPos or pos
        end
        --        
        if (targ and not targ.pos:To2D().onScreen) then
            return  
        elseif (pos and not pos:To2D().onScreen) then
            if self.Type == "AOE" then
                local mapPos = pos:ToMM()                
                Control.CastSpell(slot, mapPos.x, mapPos.y) 
            else
                pos = myHero.pos:Extended(pos, 200)
                if not pos:To2D().onScreen then return end
            end                                               
        end
        --                       
        return Control.CastSpell(slot, targ or pos)
    end

    function Spell:CastToPred(target, minHitchance)
        if not target then return end
        --
        local predPos, castPos, hC = self:GetPrediction(target)        
        if predPos and hC >= minHitchance then                         
            return self:Cast(predPos)            
        end
    end

    function Spell:OnImmobile(target)
        local TargetImmobile, ImmobilePos, ImmobileCastPosition = Prediction:IsImmobile(target, self)
        if self.Collision then
            local colStatus = #(mCollision(self.From.pos, Pos, self)) > 0
            if colStatus then return end
            return TargetImmobile, ImmobilePos, ImmobileCastPosition
        end
        return TargetImmobile, ImmobilePos, ImmobileCastPosition
    end

    local function DrawDmg(hero, damage)
        local screenPos = hero.pos:To2D()
        local barPos = {x=screenPos.x-50, y=screenPos.y-150, onScreen = screenPos.onScreen}
        if barPos.onScreen then                
            local percentHealthAfterDamage = max(0, hero.health - damage) / hero.maxHealth
            local xPosEnd   = barPos.x + barXOffset+ barWidth * hero.health/hero.maxHealth
            local xPosStart = barPos.x + barXOffset+ percentHealthAfterDamage * 100                            
            DrawLine(xPosStart, barPos.y + barYOffset, xPosEnd, barPos.y + barYOffset, 10, DmgColor)
        end        
    end

    local function DrawSpells(instance, extrafn)
        local drawSettings = Menu.Draw
        if drawSettings.ON:Value() then            
            local qLambda = drawSettings.Q:Value() and instance.Q and instance.Q:Draw(66, 244, 113)
            local wLambda = drawSettings.W:Value() and instance.W and instance.W:Draw(66, 229, 244)
            local eLambda = drawSettings.E:Value() and instance.E and instance.E:Draw(244, 238, 66)
            local rLambda = drawSettings.R:Value() and instance.R and instance.R:Draw(244, 66, 104)
            local tLambda = drawSettings.TS:Value() and instance.target and DrawMark(instance.target.pos, 3, instance.target.boundingRadius, Color.Red)
            if instance.enemies and drawSettings.Dmg:Value() then
                for i=1, #instance.enemies do
                    local enemy = instance.enemies[i]
                    local qDmg, wDmg, eDmg, rDmg = instance.Q and instance.Q:CalcDamage(enemy) or 0, instance.W and instance.W:CalcDamage(enemy) or 0, instance.E and instance.E:CalcDamage(enemy) or 0, instance.R and instance.R:CalcDamage(enemy) or 0
                    
                    DrawDmg(enemy, qDmg+wDmg+eDmg+rDmg)
                    if extrafn then
                        extrafn(enemy)
                    end
                end 
            end 
        end
    end

    function Spell:Draw(r, g, b)
        if not self.DrawColor then 
            self.DrawColor  = DrawColor(255, r, g, b)
            self.DrawColor2 = DrawColor(80 , r, g, b)
        end
        if self.Range and self.Range ~= huge then
            if self:IsReady() then 
                DrawCircle(self.From.pos, self.Range, 5, self.DrawColor)
            else
                DrawCircle(self.From.pos, self.Range, 5, self.DrawColor2)
            end
            return true
        end
    end  

    function Spell:DrawMap(r, g, b)
        if not self.DrawColor then 
            self.DrawColor  = DrawColor(255, r, g, b)
            self.DrawColor2 = DrawColor(80 , r, g, b)
        end
        if self.Range and self.Range ~= huge then
            if self:IsReady() then 
                DrawMap(self.From.pos, self.Range, 5, self.DrawColor)
            else
                DrawMap(self.From.pos, self.Range, 5, self.DrawColor2)
            end
            return true
        end        
    end

    print("[WR] Common Loaded")

