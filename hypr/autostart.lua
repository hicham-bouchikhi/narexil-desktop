-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
--
hl.on("hyprland.start", function () 
  hl.exec_cmd("dbus-update-activation-environment --systemd --all")
  hl.exec_cmd("noctalia") 
  hl.exec_cmd("xhost +SI:localuser:root")
  -- hl.exec_cmd("sleep 1 && /usr/lib/xdg-desktop-portal-hyprland")
  -- hl.exec_cmd("sleep 2 && /usr/lib/xdg-desktop-portal-kde")
  -- hl.exec_cmd("sleep 3 && /usr/lib/xdg-desktop-portal --replace")
  hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
  hl.exec_cmd("kwalletd6")
  hl.exec_cmd("/usr/lib/pam_kwallet_init")
  hl.exec_cmd("wl-clip-persist --clipboard both --reconnect-tries inf")
  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)



-- # 1. Tell services where the screen is
-- exec-once = dbus-update-activation-environment 
-- exec-once = sleep 1 && /usr/lib/xdg-desktop-portal-hyprland
-- exec-once = sleep 2 && /usr/lib/xdg-desktop-portal-kde
-- exec-once = sleep 3 && /usr/lib/xdg-desktop-portal --replace
-- # 2. Polkit authentication agent (handles Bluetovoth pairing dialogs, sudo prompts, etc.)
-- exec-once = /usr/lib/polkit-kde-authentication-agent-1

-- # 3. Start KWallet daemon
-- exec-once = kwalletd6

-- # 4. Unlock the wallet using the PAM password
-- exec-once = /usr/lib/pam_kwallet_init

-- # 5. Wallpaper
-- exec-once = awww-daemon
-- exec-once = sleep 0.5 && awww restore

-- # 6. Clipboard history
-- exec-once = wl-paste --type text --watch cliphist store
-- exec-once = wl-paste --type image --watch cliphist store

-- # 7. Idle daemon
-- exec-once = hypridle

-- # 9. QuickShell (replaces eww + waybar)
-- exec-once = qs -p /home/esperadoce/.config/quickshell
