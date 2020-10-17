require("discovery")
require("envoy")
require("timer")

function dbg(...)
   if (Properties['Debug Mode'] == 'On') then print(...) end
end

function OnDriverInit()
   C4:AllowExecute(true)
end

function OnDriverLateInit()
   TIMER.killAll()
   ENVOY.init()
   DISCOVERY.init()
end

function OnPropertyChanged(strProperty)
   local value = Properties[strProperty]
   if (value == nil) then value = '' end
   dbg('OnPropertyChanged: ' .. strProperty .. " -> " .. value)
   if (strProperty == "Poll Interval") then
      ENVOY.startPoll()
   end
end

function OnDriverDestroyed()
   TIMER.killAll()
end
