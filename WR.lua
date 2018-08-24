
    --[[
        WR.lua
        RMAN
    --]]

    if _G.WR_Loaded then
        return 
    end

    local Menu
    local open               = io.open
    local concat             = table.concat
    local rep                = string.rep 
    local format             = string.format
    local insert             = table.insert
    local remove             = table.remove

    local charName           = myHero.charName 
    local ShouldLoad         = {}
    local DownloadQueue      = {}

    local WR_PATH            = COMMON_PATH.."WinRate/"
    local CHAMP_PATH         = WR_PATH..'/Champion Modules/'
    local SCRIPT_URL         = "https://raw.githubusercontent.com/rman200/WinRateEXT/master/"
    local WR_URL             = "https://raw.githubusercontent.com/rman200/WinRateEXT/master/Common/WinRate/"
    local CHAMP_URL          = "https://raw.githubusercontent.com/rman200/WinRateEXT/master/Common/WinRate/Champion%20Modules/"
    local versionControl     = WR_PATH .. "versionControl.lua"
    local versionControl2    = WR_PATH .. "versionControl2.lua"
 
    local relativePath       = "/Champion Modules/WR_"
    --WR--

    class 'Warn'  

    function Warn:__init(str)
        if not Menu then
            self:FirstInstance()  
        end
        Menu:MenuElement({id = str, name = "Error:  "..str, value = 1,drop = {""}})                            
    end

    function Warn:FirstInstance()
        Menu = MenuElement({id = "WR_AutoUpdate", name = "Project WinRate | Error Manager!", type = MENU, leftIcon = "https://raw.githubusercontent.com/rman200/WinRateEXT/master/Icons/WinRateLogo.png"})
        Menu:MenuElement({id = "ErrorHelper1", name = "Oops, Looks Like Something Didnt Work!" , value = 1,drop = {""}})
        Menu:MenuElement({id = "ErrorHelper2", name = "Try pressing F6x2, if it doesnt solve"  , value = 1,drop = {""}})
        Menu:MenuElement({id = "ErrorHelper3", name = "Ask on forums for help and I'll try to!", value = 1,drop = {""}})
        Menu:MenuElement({id = "space"       , name = "", type = SPACE})

        local res = Game.Resolution()
        Callback.Add("Draw", function() 
            local str = "Something Went Wrong!\n Check Shift Menu."                       
            Draw.Text(str, 64, res.x/2-(#str * 7), res.y/5, Draw.Color(255,255,0,0))
        end)
    end

    class 'Utils' 

    function Utils:Sleep(s)
        local wait = os.clock()
        repeat until os.clock() - wait >= s
    end 

    function Utils:ReadAll(file)
        local f = assert(open(file, "r"))
        if f then
            local content = f:read("*all")
            f:close()
            return content
        end
    end

    function Utils:SerializeTable(val, name, depth) --recursive function to turn a table into plain text, pls dont mess with this
        skipnewlines = false
        depth = depth or 0
        local res = rep(" ", depth)
        if name then res = res .. name .. " = " end
        if type(val) == "table" then
            res = res .. "{" .. "\n"
            for k, v in pairs(val) do
                res =  res .. self:SerializeTable(v, k, depth + 4) .. "," .. "\n" 
            end
            res = res .. rep(" ", depth) .. "}"
        elseif type(val) == "number" then
            res = res .. tostring(val)
        elseif type(val) == "string" then
            res = res .. format("%q", val)
        end    
        return res
    end

    function Utils:CheckRights()
        --
        --[[Checks Write Permission]]
        local  WRITE_PERMISSION_TEST = assert(open(COMMON_PATH.."WR_CHECK_RIGHTS", "w"))
        if not WRITE_PERMISSION_TEST then
            Warn("EXT MISSING WRITE RIGHTS! LAUNCH AS ADMIN!")
            return false 
        end
        WRITE_PERMISSION_TEST:close()
        --
        --[[Checks Read Permission]]
        local  READ_PERMISSION_TEST = FileExist(COMMON_PATH.."WR_CHECK_RIGHTS")
        if not READ_PERMISSION_TEST then
            Warn("EXT MISSING READ RIGHTS! LAUNCH AS ADMIN!")
            return false 
        end
        --
        --[[Checks Download Permission]]
        DownloadFileAsync("https://raw.githubusercontent.com/rman200/WinRateEXT/master/Common/WinRate/DL_PERMISSION_TEST.lua", COMMON_PATH.."WR_CHECK_DL", function() end)
        Utils:Sleep(1)
        local  DL_PERMISSION_TEST = FileExist(COMMON_PATH.."WR_CHECK_DL")
        if not DL_PERMISSION_TEST then
            Warn("EXT MISSING DOWNLOAD RIGHTS! CHECK FIREWALL!")
            return false 
        end
        --
        return true
    end

    function Utils:CheckFolders()
        --Custom Folder Structure, helps keep things organized
        local f = open(CHAMP_PATH.."folderTest", "w")
        if f then
            f:close()
            return true 
        end

        --Absolutely Barbaric
        --Warn("Couldnt Find Custom Folders!")
        WR_PATH            = COMMON_PATH
        CHAMP_PATH         = COMMON_PATH       
        versionControl     = COMMON_PATH .. "versionControl.lua"
        versionControl2    = COMMON_PATH .. "versionControl2.lua"
        relativePath       = "WR_"
        return true
    end

    function Utils:DownloadFile(from, to, filename)
        DownloadFileAsync(from.."remote_"..filename, to..filename, function() end) 
        insert(DownloadQueue, to..filename)       
    end

    function Utils:CheckSupported()
        local Data = dofile(versionControl2)
        return Data.Champions[charName]
    end

    function Utils:CheckDependencies()
        --[[ICs Orbwalker]]
        if not (_G.SDK and _G.SDK.Orbwalker) then
            Warn("ICs Orbwalker Is Required!")
            return
        end

        return true
    end

    class 'Updater'  

    function Updater:__init()
        self.Stage = 0;
        Callback.Add("Tick", function() self:OnTick() end)
        --        
        if Utils:CheckRights() and Utils:CheckFolders() and Utils:CheckDependencies() then           
            self:GetVersionControl()
            DelayAction(function() self.Stage = 1 end, 0.5)
        end
    end

    function Updater:GetVersionControl()
        --[[First Time Being Run]]
        if not FileExist(versionControl) then 
            DownloadFileAsync(WR_URL.."remote_versionControl0", versionControl, function() end)       
        end             
        --[[Every Load]]  
        DownloadFileAsync(WR_URL.."remote_versionControl.lua", versionControl2, function() end)        
    end
    --
    function Updater:UpdateVersionControl(t)    
        local str = Utils:SerializeTable(t, "Data") .. "\n\nreturn Data"    
        local f = assert(open(versionControl, "w"))
        f:write(str)
        f:close()
    end
    --
    function Updater:CheckUpdate()        
        self.Stage = 2
        local currentData, latestData = dofile(versionControl), dofile(versionControl2)
        --[[Loader Version Check]]
        if currentData.Loader.Version < latestData.Loader.Version then
            Utils:DownloadFile(SCRIPT_URL, SCRIPT_PATH, "WR.lua")        
            currentData.Loader.Version = latestData.Loader.Version
            Warn("Please Reload The Script! [F6]x2")                
        end
        --[[Core Check]]
        if currentData.Core.Version < latestData.Core.Version then            
            currentData.Core.Version = latestData.Core.Version
            currentData.Core.Changelog = latestData.Core.Changelog
        end
        --[[Active Champ Module Check]]            
        if not currentData.Champions[charName] or currentData.Champions[charName].Version < latestData.Champions[charName].Version then
            Utils:DownloadFile(CHAMP_URL, CHAMP_PATH, "WR_"..charName..".lua")
            currentData.Champions[charName] = {}
            currentData.Champions[charName].Version   = latestData.Champions[charName].Version
            currentData.Champions[charName].Changelog = latestData.Champions[charName].Changelog
        end
        --[[Dependencies Check]]
        for k,v in pairs(latestData.Dependencies) do                
            if not currentData.Dependencies[k] or currentData.Dependencies[k].Version < v.Version then
                Utils:DownloadFile(WR_URL, WR_PATH, k..".lua")
                currentData.Dependencies[k] = {}
                currentData.Dependencies[k].Version = v.Version
            end
            local name = tostring(k)
            if v.Version >=1 and name ~= "commonLib" and name ~= "changelog" and name ~= "menuLoad" then
                ShouldLoad[#ShouldLoad+1] = name
            end
        end
        --[[Utilities Check]]
        for k,v in pairs(latestData.Utilities) do
            if not currentData.Utilities[k] or currentData.Utilities[k].Version < v.Version then
                Utils:DownloadFile(WR_URL, WR_PATH, k..".lua")
                currentData.Utilities[k] = {}
                currentData.Utilities[k].Version = v.Version
            end
            if v.Version >=1 then
                ShouldLoad[#ShouldLoad+1] = tostring(k)
            end
        end
        table.sort(ShouldLoad)
        insert(ShouldLoad, 1, "commonLib")
        insert(ShouldLoad, 2, "menuLoad")
        insert(ShouldLoad, relativePath..charName)
        self:UpdateVersionControl(currentData)
    end

    function Updater:OnTick()
        if _G.WR_Loaded then return end
        --        
        if self.Stage == 1 and FileExist(versionControl) and FileExist(versionControl2) then           
            if Utils:CheckSupported() then  
                self:CheckUpdate()                
            else
                self.Stage = -1
            end                        
        elseif self.Stage == 2 then        
            local DownloadsLeft = 0;
            for k, v in pairs(DownloadQueue) do
                DownloadsLeft = DownloadsLeft + 1
                if FileExist(v) then
                    remove(DownloadQueue, k)
                    DownloadsLeft = DownloadsLeft - 1
                end
            end
            if DownloadsLeft == 0 then
                _G.WR_Loaded = true                             
                Loader()                
            end
        end
    end

    class 'Loader'  

    function Loader:__init()        
        self:WriteModule()
        --
        for i=1, #ShouldLoad do            
            local dependency = Utils:ReadAll(concat({WR_PATH, ShouldLoad[i], ".lua"}))
            self:WriteModule(dependency)    
        end
        --
        dofile(WR_PATH.."changelog"..".lua")                          
        dofile(WR_PATH.."activeModule"..".lua") 
    end

    function Loader:WriteModule(content)            
        local f = assert(open(WR_PATH.."activeModule.lua", content and "a" or "w"))
        if content then
            f:write(content)
        end
        f:close()
    end

    --WR--

    function OnLoad()
        Updater()
    end    
