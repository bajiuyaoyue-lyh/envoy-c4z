EVENT = EVENT or {}

function EVENT.fireEvent(strEvent)
   dbg("Firing event: " .. strEvent)
   C4:FireEvent(strEvent)
end

EVENT.isDiscovered = false

function EVENT.discovered(status)
   if (EVENT.isDiscovered ~= status) then
      EVENT.fireEvent(status and "Discovered" or "Offline")
   end
   EVENT.isDiscovered = status
end
