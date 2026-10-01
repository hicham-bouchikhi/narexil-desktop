-- workspace rules
hl.workspace_rule({ workspace = "1", monitor = "HDMI-A-1", persistent = true })
-- Hyprland 0.56.2: scrolling fullscreen loses mouse capture when notification layers appear.
-- Use dwindle for the game workspace until the upstream fix (#15795) is installed.
hl.workspace_rule({ workspace = "2", monitor = "HDMI-A-1", layout = "dwindle", persistent = true })
hl.workspace_rule({ workspace = "3", monitor = "HDMI-A-1", persistent = true })
hl.workspace_rule({ workspace = "4", monitor = "HDMI-A-1", persistent = true })
hl.workspace_rule({ workspace = "5", monitor = "HDMI-A-1", persistent = true })
hl.workspace_rule({ workspace = "6", monitor = "DP-1", persistent = true })
hl.workspace_rule({ workspace = "7", monitor = "DP-1", persistent = true })
hl.workspace_rule({ workspace = "8", monitor = "HDMI-A-2", persistent = true })
hl.workspace_rule({ workspace = "9", monitor = "HDMI-A-2", persistent = true })
hl.workspace_rule({ workspace = "10", monitor = "HDMI-A-2", persistent = true })

-- Keep games on dwindle to avoid the scrolling mouse-capture issue above.
hl.workspace_rule({ workspace = "special:gaming", layout = "dwindle" })
