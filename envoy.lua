require("event")

GRID_STATUS_CONNECTION_BINDINGID = 8

ENVOY = ENVOY or {}

function ENVOY.init()
   ENVOY.setDiscovered(false)
   ENVOY.setGridStatus("closed") -- We assume the grid is up? It probably is....
end

function ENVOY.setDiscovered(tDevice)
   if (tDevice) then
      ENVOY.ip = tDevice["ipv4"]
      dbg("Envoy discovered at " .. ENVOY.ip)
      C4:UpdateProperty("IP Address", ENVOY.ip)
      EVENT.discovered(true)
      ENVOY.fetchInfo()
      ENVOY.startPoll()
   else
      ENVOY.ip = nil
      C4:UpdateProperty("IP Address", "")
      EVENT.discovered(false)
      ENVOY.stopPoll()
   end
end

function ENVOY.setGridStatus(status)
   local strCommand = "OPENED"
   if (status == true or string.upper(status) == "CLOSED") then
      strCommand = "CLOSED"
   end
   dbg("Grid Status is " .. strCommand)
   if (ENVOY.gridStatus ~= strCommand) then
      ENVOY.gridStatus = strCommand
      ENVOY.notifyProxy()
   end
end

function ENVOY.notifyProxy()
   dbg("Notifying proxy that grid is now " .. ENVOY.gridStatus)
   C4:SendToProxy(GRID_STATUS_CONNECTION_BINDINGID, ENVOY.gridStatus, {}, "NOTIFY")
end

function ENVOY.fetchInfo()
   local url = "http://" .. ENVOY.ip .. "/info.xml"
   dbg("Sending request to " .. url)
   C4:urlGet(url, {}, false, function(...) ENVOY.handleInfoResponse(...) end)
end

function ENVOY.handleInfoResponse(ticketId, strData, responseCode, tHeaders, strError)
   if (strError ~= nil) then
      dbg("We encountered an error for info.xml: " .. strError)
      ENVOY.setDiscovered(false)
      DISCOVERY.startTimer()
      return
   end

   if (tonumber(responseCode) ~= 200) then
      dbg("Got an unexpected response code for info.xml: " .. responseCode)
      return
   end

   ENVOY.info = C4:ParseXml(strData)

   if (ENVOY.info == nil) then
      dbg("We could not parse the response XML:\n" .. strData)
   end

   ENVOY.handleInfo(ENVOY.info)
end

function ENVOY.handleInfo(info)
   -- root node is envoy_info, we want its 'device' child
   for k,v in pairs(info.ChildNodes) do
      if (v.Name == "device") then
         -- now that we have the device, let's look for its sn
         for dk,dv in pairs(v.ChildNodes) do
            if (dv.Name == "sn") then
               ENVOY.serialNum = dv.Value
               C4:UpdateProperty("Serial Number", ENVOY.serialNum)
            end
         end
      end
   end
end

function ENVOY.startPoll()
   if (ENVOY.ip ~= nil) then
      TIMER.set("envoy_poll",
                Properties["Poll Interval"] * 1000,
                function() ENVOY.query() end,
                true)
   end
end

function ENVOY.query()
   local url = "http://" .. ENVOY.ip .. "/home.json"
   dbg("Sending request to " .. url)
   C4:urlGet(url, {}, false, function(...) ENVOY.handleHomeResponse(...) end)
end

function ENVOY.handleHomeResponse(ticketId, strData, responseCode, tHeaders, strError)
   if (strError ~= nil) then
      dbg("We encountered an error for home.json: " .. strError)
      ENVOY.setDiscovered(false)
      DISCOVERY.startTimer()
      return
   end

   if (tonumber(responseCode) ~= 200) then
      dbg("Got an unexpected response code for home.json: " .. responseCode)
      return
   end

   local hm, jsonErr = C4:JsonDecode(strData)

   if (hm == nil) then
      dbg("We could not parse the response JSON: " .. jsonErr .. "\n" .. strData)
      return
   end

   ENVOY.handleUpdate(hm)
end

function ENVOY.handleUpdate(tData)
   if (tData.enpower and tData.enpower.grid_status) then
      ENVOY.setGridStatus(tData.enpower.grid_status)
   end
end

function ENVOY.stopPoll()
   TIMER.cancel("envoy_poll")
end
