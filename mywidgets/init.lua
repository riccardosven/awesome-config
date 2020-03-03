-- vim:fdm=marker sw=3 ts=3 sts=3 et ft=lua tw=0

local vicious = require("../vicious")
local wibox = require("wibox")
local awful = require("awful")

local mywidgets = {}

-- Textclock widget
local mytextclock = wibox.widget.textclock()
mywidgets.textclock = mytextclock

-- CPU widget
local mycpu = wibox.widget.textbox()
local mycpu_tip = awful.tooltip({ objects = { mycpu }})
vicious.register(mycpu, vicious.widgets.cpu, function (widget, args)
                    template = template or 'Core %d: %d %%'
                    local txt = {}
                    for i,v in pairs(args) do
                       if i > 1 then
                          txt[#txt + 1] = template:format(i,v)
                       end
                    end
                    mycpu_tip:set_text(table.concat(txt, "\n"))
                    return "" .. args[1] .. "%"
                end, 7)

mycpu:buttons (awful.util.table.join (
        awful.button ({}, 1, function()
		vicious.force ({ mycpu })
	end)
))

mywidgets.cpu = mycpu

-- Temp widget
local mytemp = wibox.widget.textbox()
vicious.register(mytemp, vicious.widgets.hwmontemp, "   $1°C", 9, {"coretemp"})

mywidgets.temp = mytemp



-- Mem widget
local mymem = wibox.widget.textbox()
local mymem_tip = awful.tooltip({ objects = { mymem }})
vicious.register(mymem, vicious.widgets.mem, function (widget, args)
                    local txt = {}
                    txt[1] = "Mem: " .. args[2] .. "/" .. args[3] .. " MiB (" .. args[1] .. "%)"
                    txt[2] = "Swap: " .. args[6] .. "/" .. args[7] .. " MiB (" .. args[5] .. "%)"
                    mymem_tip:set_text(table.concat(txt, "\n"))
                    return " "  .. args[1] .. "%"
                end, 11)

mymem:buttons (awful.util.table.join (
        awful.button ({}, 1, function()
		vicious.force ({ mymem }) -- force refresh the widget when using the mouse on it
	end)
))

mywidgets.mem = mymem


-- Net widget

local function get_active_interface ()
   local connections = io.popen([[ls /sys/class/net]])
   for conn in connections:lines() do
      local conn_file = io.open("/sys/class/net/" .. conn .."/operstate","r")
      local conn_status = conn_file:read()
      conn_file:close()
      if conn_status == "up" then
         connections:close()
         return conn
      end
   end
   connections:close()
end

local mynet = wibox.widget.textbox()

vicious.register(mynet, vicious.widgets.net, function (widget, args)
                    local interface = get_active_interface()
                    local out = ""
                    if interface ~= nil then
                        out = args["{" .. interface .. " down_kb}"] .. "  " .. args["{"..interface.." up_kb}"] .. ""
                        if interface:sub(1,1) == 'w' then
                           out = out .. "  "
                        end
                    end
                    return out
                end, 13)

mynet:buttons (awful.util.table.join (
        awful.button ({}, 1, function()
		vicious.force ({ mynet }) -- force refresh the widget when using the mouse on it
	end)
))

mywidgets.net = mynet


-- Vicious: Battery widget
local function get_active_battery ()
   local batteries = io.popen([[ls /sys/class/power_supply]])
   for battery in batteries:lines() do
      if battery:sub(1,2) == "BA" then
         return battery
      end
   end
   return "AC"
end


local mybattery = wibox.widget.textbox()
local battwidget_tip = awful.tooltip({ objects = { mybattery }})
vicious.register(mybattery, vicious.widgets.bat, function (widget, args)

                    if args[3] == "N/A" then
                       battwidget_tip:set_text("AC Connected")
                       return " "
                    end

                    if args[1] == "+" then
                       txt = ""
                    else
                       txt = ""
                    end
                    
                    battwidget_tip:set_text( args[2] .. "% - " ..  args[3] .. " left" )
                    if args[2] <= 5 then
                       return txt .. " "
                    elseif args[2] <= 25 then
                       return txt .. " "
                    elseif args[2] <= 50 then
                       return txt .. " "
                    elseif args[2] <= 75 then
                       return txt .. " "
                    else
                       return txt .. " "-- txt .. args[2]
                    end
 
                end, 39, get_active_battery())

mybattery:buttons (awful.util.table.join (
        awful.button ({}, 1, function()
		vicious.force ({ mybattery }) -- force refresh the widget when using the mouse on it
	end)
))

mywidgets.battery = mybattery

---- Ethernet connection widget
--local widget_separator= " | "
--
--eth_icon = widget_separator.." Eth: "
--
--function check_eth()
-- local eth_file = io.open("/sys/class/net/eno1/operstate", "r")
-- local eth_state = eth_file:read()
-- eth_file:close()
-- return eth_state
--end
--
--eth_widget = wibox.widget.textbox()
--
--function eth_status()
--    if (check_eth() == "up") then
--        eth_widget:set_markup(eth_icon.."on ")
--    else
--        eth_widget:set_markup(eth_icon.."off ")
--    end
--end
--eth_status()
--
--eth_timer = timer({timeout=60})
--eth_timer:connect_signal("timeout",eth_status)
--eth_timer:start()

local myseparator = wibox.widget.textbox(" | ")

mywidgets.separator = myseparator

return mywidgets

