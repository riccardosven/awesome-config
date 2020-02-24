--[[
                                      
     Multicolor Awesome WM config 2.0 
     github.com/copycat-killer        
                                      
--]]


theme                               = {}

theme.confdir                       = os.getenv("HOME") .. "/.config/awesome/"
theme.wallpaper                     = theme.confdir .. "/wall.png"

theme.font                          = "Terminus 8"
--theme.taglist_font                =
theme.menu_bg_normal                = "#000000"
theme.menu_bg_focus                 = "#000000"
theme.bg_normal                     = "#000000"
theme.bg_focus                      = "#000000"
theme.bg_urgent                     = "#000000"
theme.fg_normal                     = "#aaaaaa"
theme.fg_focus                      = "#ff1c00"
-- theme.fg_focus                      = "#ff8c00" -- ORANGE
-- theme.fg_focus                      = "#0491AC" -- MELLOW BLUE
--theme.fg_urgent                     = "#af1d18"
theme.fg_urgent                     = "#02687B"
theme.fg_minimize                   = "#ffffff"
theme.fg_black                      = "#424242"
theme.fg_red                        = "#ce5666"
theme.fg_green                      = "#80a673"
theme.fg_yellow                     = "#ffaf5f"
theme.fg_blue                       = "#7788af"
theme.fg_magenta                    = "#94738c"
theme.fg_cyan                       = "#778baf"
theme.fg_white                      = "#aaaaaa"
theme.useless_gap		    = "0"
theme.fg_blu                        = "#8ebdde"
theme.border_width                  = "1"
theme.border_normal                 = "#00242B"
--theme.border_focus                  = "#606060"
-- theme.border_focus                 = "#0491AC"
theme.border_focus                  = theme.fg_focus
theme.border_marked                 = "#02687B"
theme.menu_width                    = "110"
theme.menu_border_width             = "0"
theme.menu_fg_normal                = "#aaaaaa"
theme.menu_fg_focus                 = "#0491AC"
theme.menu_bg_normal                = "#050505dd"
theme.menu_bg_focus                 = "#050505dd"

--hade 0 = #02687B = rgb(  2,104,123) = rgba(  2,104,123,1)
--shade 1 = #39A5BA = rgb( 57,165,186) = rgba( 57,165,186,1)
--shade 2 = #0491AC = rgb(  4,145,172) = rgba(  4,145,172,1)
--shade 3 = #014C59 = rgb(  1, 76, 89) = rgba(  1, 76, 89,1)
--shade 4 = #00242B = rgb(  0, 36, 43) = rgba(  0, 36, 43,1

theme.taglist_squares_sel           = theme.confdir .. "/icons/square_a.png"
theme.taglist_squares_unsel         = theme.confdir .. "/icons/square_b.png"

theme.tasklist_disable_icon         = true
theme.tasklist_floating             = ""
theme.tasklist_maximized_horizontal = ""
theme.tasklist_maximized_vertical   = ""

theme.layout_txt_tile = "[["
theme.layout_txt_tileleft = "]]"
theme.layout_txt_floating = '][' 


return theme
