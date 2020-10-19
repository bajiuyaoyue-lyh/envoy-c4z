require("discovery")
require("envoy")
require("timer")

DEBUGLOG = DEBUGLOG or {}

function dbg(str)
   if (Properties['Debug Mode'] == 'On') then
      table.insert(DEBUGLOG, str)
      print(str)
   end
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

function OnBindingChanged(idBinding, strClass, bIsBound)
   dbg('OnBindingChanged: binding ' .. idBinding .. '(' .. strClass .. ') -> ' .. (bIsBound and 'true' or 'false'))
   if (bIsBound) then
      ENVOY.notifyProxy()
   end
end

function OnDriverDestroyed()
   TIMER.killAll()
end
