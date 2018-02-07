function Init(IsMannual)
    package.path = package.path .. ";".._luadir.."/?.lua"
    -- package.cpath = package.cpath .. ";".._luadir.."/?.dll"
    require "frame.initrequire"
    -- local function ShowMem()
    --     collectgarbage("collect")
    --     a_("lua memory: ", collectgarbage("count"))
    -- end
    -- TimerMgr:Get():On(ShowMem):Time(2)

    require "frame.debugger.debuggersetting"

    if _platform == "PLATFORM_WINDOWS" and _WITH_EDITOR then
        -- InitLuahotupdate()
    end
end

function InitLuahotupdate()
    if hasInitHoupdate then
        return
    end
    hasInitHoupdate = true
    local HU = require "luahotupdate"
    HU.Init("hotupdatelist", {_luadir}, A_)
    local function HotReloadUpdate()
        DebuggerPause()
        HU.Update() 
        DebuggerResume()
    end
    TimerMgr:Get():On(HotReloadUpdate):Time(1):Fire()
end

function Tick(delta)
    local function f()
        TimerMgr:Get():Tick(delta)
    end
    Xpcall(f)
end

--for object orientation
-- execution sequence : basec++ ctor -> baselua ctor -> derivedc++ ctor -> derivedlua ctor
function Ctor(classpath, inscpp, ...)

    ensure(inscpp~=nil, "inscpp is nil")
    
    local class = require(classpath)
    if type(inscpp) == "table" then
        if inscpp._meta_ ~= class then
            setmetatable(inscpp, class)
            if inscpp._meta_:IsChildOf(CppSingleton) then
                inscpp._meta_._ins = nil
            end
            if class:IsChildOf(CppSingleton) then
                class._ins = inscpp
            end
            local CtorFunc = rawget(class, "Ctor")
            if CtorFunc then
                CtorFunc(inscpp, ...)
            end
        end
    else
        local NewLuaIns = class:NewOn(inscpp, ...)
    end
end

function Call(functionName, inscpp, ...)
    if type(inscpp) == "table" and not inscpp._has_destroy_ then
        return inscpp[functionName](inscpp, ...)
    else
        -- ensure(false, "error in Call, No Exist such lua ins or ins has been released")
    end
end
-- *******************************

function GC()
    GlobalEvent.Fire("GC")
    -- collectgarbage("collect")
end

function Shutdown()
    GlobalEvent.Fire("LuaShutdown")
    a_("lua VM shutdown")
end