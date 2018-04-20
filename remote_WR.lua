
    --[[
        WR.lua
        RMAN
    --]]

    if _G.WR_Loaded then
        return 
    end

    _G.WR_Loaded = true

    local core_version       = 1.00

    local char_name          = myHero.charName 

    local open               = io.open
    local concat             = table.concat

    local WR_PATH            = COMMON_PATH.."WinRate/"
    local SCRIPT_URL         = "https://raw.githubusercontent.com/rman200/WinRateEXT/master/"
    local WR_URL             = "https://raw.githubusercontent.com/rman200/WinRateEXT/master/Common/WinRate/"
    local ACTIVE_PATH        = "/Champion Modules/WR_"..char_name
    local versionControl     = WR_PATH .. "versionControl.lua"
    local versionControl2    = WR_PATH .. "versionControl2.lua"
    local wr_module_data     = "wr_module_data.lua"
    local wr_core            = "wr_core.lua"
    local wr_check           = "wr_check.lua"  
    local luaString          = ".lua"  
    local wr_champ           = "wr_"..char_name..luaString
    local versionControl_url = WR_URL.."/remote_versionControl.lua"
    --local wr_champ_url       = "https://raw.githubusercontent.com/HiImWeedle/GoS/master/WinRate/Modules/winrate_"..char_name:lower()..luaString

    
    
    --WR--

    local function AutoUpdate()
        local function DownloadFile(from, to, filename)
            DownloadFileAsync(from.."remote_"..filename, to..filename, function() end)            
            repeat until FileExist(to..filename)
        end
        --
        local function GetVersionControl()
            --[[First Time Being Run]]
            if not FileExist(versionControl) then 
                DownloadFile(WR_URL, WR_PATH, "versionControl.lua") 
            end             
            --[[Every Load]]  
            DownloadFileAsync(WR_URL.."remote_versionControl.lua", versionControl2, function() end)          
            repeat until FileExist(versionControl2)
        end
        --
        local function TextOnScreen(str)
            local res = Game.Resolution()                         
            Callback.Add("Draw", function()                
                Draw.Text(str, 64, res.x/2, res.y/2, Draw.Color(255,255,0))
            end)
        end
        local function UpdateLoader()
            DownloadFile(SCRIPT_URL, SCRIPT_PATH, "WR.lua")
            TextOnScreen("Please Reload The Script! [F6]x2")
        end
        --
        local function CheckUpdate()
            local currentData, latestData = dofile(versionControl), dofile(versionControl2)
            if currentData.Utilities.loader <= latestData.Utilities.loader then
                UpdateLoader()
            end


            --if not FileExist(COMMON_PATH..wr_check) then 
            --    CreateUpdateTime()
            --    return true
            --end
            --local file = open(COMMON_PATH..wr_check, "r")
            --local current_time = os.time()
            --local check_time = file:read()
            --file:close()
            --CreateUpdateTime()
            --return current_time - check_time >= 300
        end
        --

        --
        --local function GetScriptData()
        --    local check_version = core_version
        --    DownloadFile(versionControl_url, versionControl, versionControl)
        --    --GetVersionControl()
        --    if check_version ~= core_version then
        --        DownloadFile(wr_core_url, COMMON_PATH..wr_core, wr_core.." | version: "..core_version) 
        --        isUpdated = true
        --    end
        --end
        --
        --local function GetModuleData()
        --    DownloadFile(wr_module_data_url, COMMON_PATH..wr_module_data, wr_module_data)
        --    dofile(COMMON_PATH..wr_module_data)
        --    module_data  = _G.WR_MODULE_DATA 
        --end
        --
        --local function UpdateModules()
        --    for i, utils in pairs(module_data.utilities) do 
        --        local wr_utility = "wr_"..utils..luaString
        --        local wr_utility_url = "https://raw.githubusercontent.com/HiImWeedle/GoS/master/WinRate/Modules/winrate_"..utils..luaString
        --        DownloadFile(wr_utility_url, COMMON_PATH..wr_utility, wr_utility)
        --    end 
        --    if module_data.champions[char_name] == nil then return end
        --    DownloadFile(wr_champ_url, COMMON_PATH..wr_champ, wr_champ) 
        --end
        --
        GetVersionControl()
        CheckUpdate(currentData, latestData)

        --    timeCheck = true
        --    GetScriptData()
        --    GetModuleData()
        --    UpdateModules()
        --end
    end

    local function LoadWR() --These 3 functions are only gonna be used here so there's no point of having out of LoadWR()'s chunk
        local function readAll(file)
            local f = assert(open(file, "r"))
            local content = f:read("*all")
            f:close()
            return content
        end
        --
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
            local dependency = readAll(concat({WR_PATH, dependencies[i], luaString}))
            appendModule(dependency)    
        end                          
        dofile(WR_PATH.."activeModule"..luaString) 
    end

    --WR--

    function OnLoad()
        AutoUpdate()
        --_G.versionData = versionData
        --_G.isUpdated, _G.timeCheck = isUpdated, timeCheck  
        LoadWR()
    end    
