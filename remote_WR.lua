
    --[[
        WR.lua
        RMAN
    --]]

    if _G.WR_Loaded then
        return 
    end

    _G.WR_Loaded = true

    local char_name          = myHero.charName 

    local open               = io.open
    local concat             = table.concat
    local rep                = string.rep 
    local format             = string.format

    local WR_PATH            = COMMON_PATH.."WinRate/"
    local ACTIVE_PATH        = "/Champion Modules/WR_"..char_name
    local CHAMP_PATH         = WR_PATH..'/Champion Modules'
    local SCRIPT_URL         = "https://raw.githubusercontent.com/rman200/WinRateEXT/master/"
    local WR_URL             = "https://raw.githubusercontent.com/rman200/WinRateEXT/master/Common/WinRate/"
    local CHAMP_URL          = "https://raw.githubusercontent.com/rman200/WinRateEXT/master/Common/WinRate/Champion%20Modules/"

    local versionControl     = WR_PATH .. "versionControl.lua"
    local versionControl2    = WR_PATH .. "versionControl2.lua"
    local dotlua             = ".lua" 
    
    --WR--
    local function readAll(file)
        local f = assert(open(file, "r"))
        local content = f:read("*all")
        f:close()
        return content
    end

    local function AutoUpdate()
        local function serializeTable(val, name, depth) --recursive function to turn a table into plain text, pls dont mess with this
            skipnewlines = false
            depth = depth or 0
            local res = rep(" ", depth)
            if name then res = res .. name .. " = " end
            if type(val) == "table" then
                res = res .. "{" .. "\n"
                for k, v in pairs(val) do
                    res =  res .. serializeTable(v, k, depth + 4) .. "," .. "\n" 
                end
                res = res .. rep(" ", depth) .. "}"
            elseif type(val) == "number" then
                res = res .. tostring(val)
            elseif type(val) == "string" then
                res = res .. format("%q", val)
            end    
            return res
        end
        --
        local function TextOnScreen(str)
            local res = Game.Resolution() 
            Callback.Add("Draw", function()                       
                Draw.Text(str, 64, res.x/2-(#str * 10), res.y/2, Draw.Color(255,255,0,0))
            end)                        
        end
        --
        local function DownloadFile(from, to, filename)
            DownloadFileAsync(from.."remote_"..filename, to..filename, function() end)            
            repeat until FileExist(to..filename)
        end
        --
        local function GetVersionControl()
            --[[First Time Being Run]]
            if not FileExist(versionControl) then 
                DownloadFileAsync(WR_URL.."remote_versionControl0", versionControl, function() end)          
                repeat until FileExist(versionControl)
            end             
            --[[Every Load]]  
            DownloadFileAsync(WR_URL.."remote_versionControl.lua", versionControl2, function() end)          
            repeat until FileExist(versionControl2)
        end
        --
        local function UpdateVersionControl(t)    
            local str = serializeTable(t, "Data") .. "\n\nreturn Data"    
            local f = assert(open(versionControl, "w"))
            f:write(str)
            f:close()
        end
        --
        local function CheckUpdate()
            local currentData, latestData = dofile(versionControl), dofile(versionControl2)
            --[[Loader Version Check]]
            if currentData.Loader.Version < latestData.Loader.Version then
                DownloadFile(SCRIPT_URL, SCRIPT_PATH, "WR.lua")        
                currentData.Loader.Version = latestData.Loader.Version
                TextOnScreen("Please Reload The Script! [F6]x2")
            end
            --[[Core Check]]
            if currentData.Core.Version < latestData.Core.Version then
                DownloadFile(WR_URL, WR_PATH, "core.lua")
                currentData.Core.Version = latestData.Core.Version
            end
            --[[Active Champ Module Check]]
            if currentData.Champions[char_name].Version < latestData.Champions[char_name].Version then
                DownloadFile(CHAMP_URL, CHAMP_PATH, "WR_"..char_name..dotlua)
                currentData.Champions[char_name].Version = latestData.Champions[char_name].Version
            end
            --[[Dependencies Check]]
            for k,v in pairs(latestData.Dependencies) do
                if not currentData.Dependencies.k or currentData.Dependencies.k.Version < v.Version then
                    DownloadFile(WR_URL, WR_PATH, k..dotlua)
                    currentData.Dependencies.k.Version = v.Version
                end
            end
            --[[Utilities Check]]
            for k,v in pairs(latestData.Utilities) do
                if not currentData.Utilities.k or currentData.Utilities.k.Version < v.Version then
                    DownloadFile(WR_URL, WR_PATH, k..dotlua)
                    currentData.Utilities.k.Version = v.Version
                end
            end
            UpdateVersionControl(currentData)
        end
        GetVersionControl()
        CheckUpdate()
    end

    local function LoadWR() --These 2 functions are only gonna be used here so there's no point of having out of LoadWR()'s chunk
        local function clearModule()
            local f = assert(open(WR_PATH.."activeModule.lua", "w"))
            f:write()
            f:close()        
        end
        --
        local function appendModule(content)
            local f = assert(open(WR_PATH.."activeModule.lua", "a"))
            local content = f:write(content)
            f:close()        
        end
        --
        local dependencies = {"menuLoad", "commonLib", "callbacks", "prediction", ACTIVE_PATH} 
        clearModule()
        for i=1, #dependencies do
            local dependency = readAll(concat({WR_PATH, dependencies[i], dotlua}))
            appendModule(dependency)    
        end                          
        dofile(WR_PATH.."activeModule"..dotlua) 
    end

    --WR--

    function OnLoad()
        AutoUpdate()
        --_G.versionData = versionData
        --_G.isUpdated, _G.timeCheck = isUpdated, timeCheck  
        LoadWR()
    end    
