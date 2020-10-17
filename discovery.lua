require("mdns")

discoveryTimerTime = 10000

DISCOVERY = DISCOVERY or {}

function DISCOVERY.init()
   DISCOVERY.startTimer()
end

function DISCOVERY.startTimer()
   TIMER.set("discovery",
             discoveryTimerTime,
             function() DISCOVERY.discover() end,
             false)
end

function DISCOVERY.discover()
   local serviceName = "_enphase-envoy._tcp.local"
   dbg("Starting MDNS query of " .. serviceName)
   local res = mdns_query(serviceName)
   if (res) then
      for k,v in pairs(res) do
         dbg("MDNS: " .. k)
         for k1,v1 in pairs(v) do
            dbg("MDNS: " .. "  " .. k1 .. ": " .. v1)
         end
         ENVOY.setDiscovered(v)
      end
   else
      dbg("No MDNS result")
      ENVOY.setDiscovered(nil)
      DISCOVERY.startTimer()
   end
end
