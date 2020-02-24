-- vim:fdm=marker sw=3 ts=3 sts=3 et ft=lua tw=0
-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
-- Vicious library
vicious = require("vicious")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}
-- {{{ Autostart applications
awful.spawn.once("xautoloc -time 20 -locker 'slock'")
awful.spawn.once("picom")
-- }}}
--
-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_configuration_dir() .. "theme.lua")


-- This is used later as the default terminal and editor to run.
terminal = os.getenv("TERM") or "alacritty"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.floating
    -- awful.layout.suit.tile.bottom,
    -- awful.layout.suit.tile.top,
    -- awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
    -- awful.layout.suit.max,
    -- awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.magnifier,
    -- awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}
-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

-- Vicious: CPU widget
mycpu = wibox.widget.textbox()
mycpu_tip = awful.tooltip({ objects = { mycpu }})
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

-- Vicious: Temp widget
mytemp = wibox.widget.textbox()
vicious.register(mytemp, vicious.widgets.hwmontemp, "  $1°C", 9, {"coretemp"})


-- Vicious: Mem widget
mymem = wibox.widget.textbox()
mymem_tip = awful.tooltip({ objects = { mymem }})
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


-- Vicious: Net widget
mynet = wibox.widget.textbox()
vicious.register(mynet, vicious.widgets.net, function (widget, args)
                    --local txt = {}
                    --for i,v in pairs(args) do
                    --   txt[#txt + 1] = i .. ": " .. v
                    --end
                    --mynet_tip:set_text(table.concat(txt, "\n"))
                    local down = args["{wlp2s0 down_kb}"] or args["{eno1 down_kb}"]
                    local up = args["{wlp2s0 up_kb}"] or args["{eno1 up_kb}"]
                    return down .. "  " .. up .. ""
                end, 13)

--mycpu:buttons (awful.util.table.join (
--        awful.button ({}, 1, function()
--		vicious.force ({ mycpu }) -- force refresh the widget when using the mouse on it
--	end)
--))


-- Vicious: Battery widget
mybattery = wibox.widget.textbox()
battwidget_tip = awful.tooltip({ objects = { mybattery }})
vicious.register(mybattery, vicious.widgets.bat, function (widget, args)
                    if args[1] == "+" then
                       txt = ""
                    else
                       txt = ""
                    end
                    
                    battwidget_tip:set_text( args[1] .. " " ..  args[3] )
                    if args[2] < 5 then
                       return txt .. " "
                    elseif args[2] < 25 then
                       return txt .. " "
                    elseif args[2] < 50 then
                       return txt .. " "
                    elseif args[2] < 75 then
                       return txt .. " "
                    else
                       return txt .. " "-- txt .. args[2]
                    end
 
                end, 39, 'BAT0')

mybattery:buttons (awful.util.table.join (
        awful.button ({}, 1, function()
		vicious.force ({ mybattery }) -- force refresh the widget when using the mouse on it
	end)
))

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


function check_wls()
 local wls_file = io.open("/sys/class/net/wlp2s0/operstate", "r")
 local wls_state = wls_file:read()
 wls_file:close()
 return wls_state
end

wls_widget = wibox.widget.textbox()

function wls_status()
    if (check_wls() == "up") then
        wls_widget:set_markup("  ")
    else
        wls_widget:set_markup()
    end
end
wls_status()

wls_timer = timer({timeout=113})
wls_timer:connect_signal("timeout",wls_status)
wls_timer:start()


-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function()
                                              awful.menu.client_list({ theme = { width = 250 } })
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        --gears.wallpaper.maximized(wallpaper, s, false)
        gears.wallpaper.centered(wallpaper, s, "#000b19", 0.5)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

 -- Writes a string representation of the current layout in a textbox widget
function updatelayoutbox(layout, s)
    local screen = s or 1
    local txt_l = beautiful["layout_txt_" .. awful.layout.getname(awful.layout.get(s))]
    layout:set_text(txt_l)
end

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5"}, s, awful.layout.layouts[1])

    s.mylayoutbox = wibox.widget.textbox(beautiful["layout_txt_" .. awful.layout.getname(awful.layout.get(s))])

    awful.tag.attached_connect_signal(s, "property::selected", function ()
        updatelayoutbox(s.mylayoutbox, s)
    end)
    awful.tag.attached_connect_signal(s, "property::layout", function ()
        updatelayoutbox(s.mylayoutbox, s)
    end)

    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons,
            widget_template = {
        {
            {
                {
                    id     = 'text_role',
                    widget = wibox.widget.textbox,
                },
                layout = wibox.layout.fixed.horizontal,
            },
            left  = 5,
            right = 5,
            widget = wibox.container.margin
        },
        id     = 'background_role',
        widget = wibox.container.background,
    },
    }

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            wibox.widget.systray(),
            wibox.widget.textbox(' | '),
            mycpu,
            mytemp,
            wibox.widget.textbox(' | '),
            mymem,
            wibox.widget.textbox(' | '),
            mynet,
            wls_widget,
            wibox.widget.textbox(' | '),
            mybattery,
            wibox.widget.textbox(' | '),
            mytextclock,
            wibox.widget.textbox(' '),
            wibox.widget.textbox(' | '),
            s.mylayoutbox,
        },
    }
end)
-- }}}
-- {{{ Mouse bindings
--root.buttons(gears.table.join(
--    awful.button({ }, 3, function () mymainmenu:toggle() end),
--    awful.button({ }, 4, awful.tag.viewnext),
--    awful.button({ }, 5, awful.tag.viewprev)
--))
-- }}}
-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),
-- Vim like motion for focus
   awful.key({ modkey }, "j",
      function()
         awful.client.focus.bydirection("down")
         if client.focus then client.focus:raise() end
      end),
   awful.key({ modkey }, "k",
      function()
         awful.client.focus.bydirection("up")
         if client.focus then client.focus:raise() end
      end),
   awful.key({ modkey }, "h",
      function()
         awful.client.focus.bydirection("left")
         if client.focus then client.focus:raise() end
      end),
   awful.key({ modkey }, "l",
      function()
         awful.client.focus.bydirection("right")
         if client.focus then client.focus:raise() end
      end),
    -- Layout manipulation
   awful.key({ modkey, "Shift"   }, "h", function () awful.client.swap.bydirection("left")    end),
   awful.key({ modkey, "Shift"   }, "l", function () awful.client.swap.bydirection("right")    end),
   awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.bydirection("down")    end),
   awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.bydirection("up")    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),
   awful.key({ modkey,           }, "b", function ()
      for s in screen do
         if s.mywibox.visible then
            vicious.suspend()
         else
            vicious.activate()
         end
         s.mywibox.visible = not s.mywibox.visible
      end
    end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "]",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "[",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "]",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "[",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"}),

   awful.key({ modkey, "Control" }, "l", function () awful.util.spawn("slock") end),
    -- Prompt
    awful.key({ modkey }, "r",
      function()
         awful.util.spawn("dmenu_run -i -p 'Run command:' -nb '" ..
         beautiful.bg_normal .. "' -nf '" .. beautiful.fg_normal ..
         "' -sb '" .. beautiful.bg_focus ..
         "' -sf '" .. beautiful.fg_focus .. "'")
      end)
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"}),
-- Backlight Control
   awful.key({}, "#233", function () awful.util.spawn("xbacklight -inc 1") end),
   awful.key({}, "#232", function () awful.util.spawn("xbacklight -dec 1") end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}
-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = false }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}
-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
