TIMER = TIMER or {}

TIMER.timers = TIMER.timers or {}
TIMER.functions = TIMER.functions or {}

function TIMER.set(timerId, delay, timerFunc, repeating)
   TIMER.cancel(timerId)
   if (type(timerFunc) ~= "function") then return nil end

   local _timer = function(timer, skips)
      if (TIMER.functions[timer]) then
         pcall(TIMER.functions[timer], timer, skips)
      end
      if (repeating ~= true) then
         TIMER.cancel(timerId)
      end
   end

   local timer = C4:SetTimer(delay, _timer, (repeating == true))
   TIMER.timers[timerId] = timer
   TIMER.functions[timer] = timerFunc
   return timer
end

function TIMER.cancel(timerId)
   if (TIMER.timers[timerId]) then
      local timer = TIMER.timers[timerId]
      TIMER.functions[timer] = nil
      if (timer.Cancel) then
         TIMER.timers[timerId] = timer:Cancel()
      else
         TIMER.timers[timerId] = nil
      end
   end
end

function TIMER.killAll()
   for timerId, _ in pairs(TIMER.timers) do
      TIMER.cancel(timerId)
   end
end
