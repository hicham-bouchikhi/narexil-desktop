-- This is an example Hyprland Lua config file.
-- Refer to the wiki for more information.
-- https://wiki.hypr.land/Configuring/Start/

-- Please note not all available settings / options are set here.
-- For a full list, see the wiki

-- You can (and should!!) split this configuration into multiple files
-- Create your files separately and then require them like this:
-- require("myColors")


------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "5120x1440@144.00",
    position = "auto",
    scale    = "1",
})


require("animations")
require("autostart") -- See autostart.lua for more  
require("colors") 
require("decorations") -- See decorations.lua for more
require("environment") -- See environment.lua for more
require("inputs") -- See inputs.lua for more
require("bindings") 
require("permissions") -- See permissions.lua for more
require("windowrules") -- See windowrules.lua for more
require("workspaces") -- See workspaces.lua for more
require("noctalia").apply_theme()
