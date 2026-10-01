---------------------
---- KEYBINDINGS ----
---------------------
local localBinScript = os.getenv("HOME") .. "/.local/bin/"
local hyprScript = os.getenv("HOME") .. "/.config/hypr/scripts/"
local terminal    = "kitty"
local fileManager = "dolphin"
local browser     = "firefox"
local mainMod = "SUPER" -- Sets "Windows" key as main modifier
local noctCall = "noctalia msg "

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(mainMod .. " + X", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + X", hl.dsp.window.kill())
hl.bind(mainMod .. " + ALT + J", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + K", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))    -- dwindle only
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainMod .. " + CONTROL + F", hl.dsp.window.fullscreen_state({ internal = 0, client = 2 }))
-- Tell the app it is fullscreen while keeping its normal window geometry.
hl.bind(mainMod .. " + SHIFT + F", function()
    local window = hl.get_active_window()
    if not window then return end
    hl.dispatch(hl.dsp.window.fullscreen_state({
        internal = 0,
        client = window.fullscreen_client == 2 and 0 or 2,
    }))
end)
hl.bind(mainMod .. " + ALT + F",     hl.dsp.window.fullscreen_state({ internal = 0, client = 0 }))
-- hl.bind(mainMod .. " + D", hl.dsp.window.fullscreen({ mode = 1 }))
hl.bind(mainMod .. " + M", hl.dsp.exit())
-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))
hl.bind("ALT + Tab",           hl.dsp.window.cycle_next())      
hl.bind(mainMod .. " + Tab",   hl.dsp.exec_cmd(noctCall .. "window-switcher"))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i}))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end
-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))
hl.bind(mainMod .. " + SHIFT + Up",                   hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + Right",                hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + Left",                 hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + Down",                 hl.dsp.window.move({ direction = "d" }))
-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))
-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

--------------------
-- APPLICATIONS ----
--------------------
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(localBinScript .. "ocr-region.sh"))



-------------------
---- NOCTALIA -----
-------------------

-- Core binds
hl.bind(mainMod .. " + Space",      hl.dsp.exec_cmd(noctCall .. "panel-toggle launcher"))
hl.bind(mainMod .. " + Home",       hl.dsp.exec_cmd(noctCall .. "panel-toggle control-center"))
hl.bind(mainMod .. " + ALT + C",    hl.dsp.exec_cmd(noctCall .. "panel-toggle session"))
hl.bind(mainMod .. " + W",          hl.dsp.exec_cmd(noctCall .. "panel-toggle wallpaper"))
hl.bind(mainMod .. " + SHIFT + W",  hl.dsp.exec_cmd(noctCall .. "panel-toggle noctalia/wallhaven:browser"))
hl.bind(mainMod .. " + End",        hl.dsp.exec_cmd(noctCall .. "settings-toggle"))
hl.bind(mainMod .. " + L",          hl.dsp.exec_cmd(noctCall .. "session lock"))
hl.bind(mainMod .. " + comma",      hl.dsp.exec_cmd(noctCall .. "session logout"))
hl.bind(mainMod .. " + V",          hl.dsp.exec_cmd(noctCall .. "panel-toggle clipboard"))
hl.bind(mainMod .. " + A",          hl.dsp.exec_cmd(noctCall .. "panel-toggle control-center notifications"))


-- Audio
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(noctCall .. "volume-up"),   { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(noctCall .. "volume-down"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd(noctCall .. "volume-mute"), { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd(noctCall .. "mic-mute"),    { locked = true })

-- Media
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd(noctCall .. "media toggle"),   { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd(noctCall .. "media toggle"),   { locked = true })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd(noctCall .. "media next"),     { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd(noctCall .. "media previous"), { locked = true })

-- Brightness
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd(noctCall .. "brightness-up"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(noctCall .. "brightness-down"), { locked = true, repeating = true })

-------------------
---- UTILITIES ----
-------------------

-- Screen Capture
hl.bind(mainMod .. " + P",     hl.dsp.exec_cmd("hyprpicker -a"))
hl.bind("Print",                hl.dsp.exec_cmd("sh -c 'grim -g \"$(slurp)\" - | wl-copy'"))
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd(hyprScript .. "scan-qr-region.sh"))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(hyprScript .. "record-region.sh"))
hl.bind("CONTROL + Print",      hl.dsp.exec_cmd(noctCall .. "screenshot-region"))
hl.bind(mainMod .. " + Print",              hl.dsp.exec_cmd("sh -c 'grim -o $(hyprctl monitors -j | jq -r \".[] | select(.focused == true) | .name\") - | wl-copy'"))
hl.bind("CONTROL + " .. mainMod .. " + Print", hl.dsp.exec_cmd(noctCall .. "screenshot-fullscreen"))


-- Show/hide detected games on the current monitor.
hl.bind(mainMod .. " + G", hl.dsp.workspace.toggle_special("gaming"))

-- Gaming mode: toggle gaps on/off
hl.bind(mainMod .. " + SHIFT + G", hl.dsp.exec_cmd(
    "sh -c 'hyprctl getoption general:gaps_in | grep -q \"0 0 0 0\" && hyprctl eval \"hl.config({ general = { gaps_in = 3, gaps_out = 8 }, decoration = { rounding = 10 } })\" || hyprctl eval \"hl.config({ general = { gaps_in = 0, gaps_out = 0 }, decoration = { rounding = 0 } })\"'"
))

-- -- Special button binds
hl.bind("XF86Calculator", hl.dsp.exec_cmd("kcalc"))
require("app-scratchpads") -- Cider button, Super+F1 Teams, Super+F2 Discord
hl.bind("XF86Explorer", hl.dsp.exec_cmd("code"))
hl.bind("XF86Mail", hl.dsp.exec_cmd("thunderbird"))
hl.bind("CONTROL + SHIFT + Escape", hl.dsp.exec_cmd(terminal .. " -e btop"))
