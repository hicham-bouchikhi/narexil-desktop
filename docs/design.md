# narexil-desktop — Design Document

## Stack

| Tool | Role |
|------|------|
| **Hyprland** | Window manager (via UWSM) |
| **Waybar** | Top bar — workspaces, tray, system modules |
| **Eww** | On-demand floating dashboard panel |
| **QuickShell** | Notifications (native DBus server) |
| **Hypridle** | Idle daemon — DPMS + screen lock |
| **Hyprlock** | Lock screen |
| **Rofi** | App launcher, clipboard picker, power menu |
| **awww** | Wallpaper daemon (per-monitor, animated) |
| **KDE tools** | Bluetooth (kcmshell6), auth (polkit-kde), wallet (kwallet) |

---

## Monitor Layout

| Output | Hardware | Resolution | Bar | Wallpaper |
|--------|----------|------------|-----|-----------|
| `HDMI-A-1` | MSI MPG 491C OLED | 5120×1440 | Auto-hide overlay | Solid black — black OLED pixels are off, prevents burn-in |
| `DP-1` | Dell S2721DS | 2560×1440 | Persistent | User-defined |
| `HDMI-A-2` | Dell S2721DS | 2560×1440 | Persistent | User-defined |

DDC/CI bus map (used by eww brightness daemon):

| Bus | Output |
|-----|--------|
| `/dev/i2c-1` | HDMI-A-1 (OLED) |
| `/dev/i2c-2` | DP-1 |
| `/dev/i2c-3` | HDMI-A-2 |

---

## Waybar

### Bar instances

Two separate instances launched from `hypr/autostart.conf`:

| Instance | Config | Monitors | Layer | Exclusive zone |
|----------|--------|----------|-------|----------------|
| `bar-main` | `config-main.jsonc` | DP-1, HDMI-A-2 | top | 52px |
| `bar-oled` | `config-oled.jsonc` | HDMI-A-1 | overlay | -1 |

Both share `style.css`.

### Bar layout

```
[ Workspaces ] [ Scratchpad ] [ Window Title ] [ ◀ Media ▶ ]   [ Weather · Clock ]   [ CPU ] [ RAM ] [ GPU ] [ VRAM ] [ Tray ] [ BT ] [ Net ] [ Vol ] [ VPN ] [ ⏻ ]
```

### OLED auto-hide

`waybar/scripts/oled-autohide.sh` — background daemon:
- Polls cursor position every 80ms via `hyprctl cursorpos`
- **Shows** bar when cursor Y ≤ 4px within OLED X range → sends `SIGUSR1` to waybar PID
- **Hides** bar 2000ms after cursor leaves the top zone → sends `SIGUSR1` again
- Single instance enforced via `/tmp/oled-autohide.lock`

### Custom modules

| Module | Script | Interval |
|--------|--------|----------|
| `custom/gpu` | `gpu.sh` — `nvidia-smi` utilization % | 2s |
| `custom/vram` | `vram.sh` — VRAM used in GB | 5s |
| `custom/nordvpn` | `nordvpn.sh` — status + city; toggle on click | 10s |
| `custom/weather` | `weather.sh` — wttr.in Lyon, 30min cache | 30min |
| `custom/media` | `media.sh` — MPRIS artist/title/time; play-pause on click | 2s |
| `custom/media-prev` | `media-prev.sh` — prev button when playing | 2s |
| `custom/media-next` | `media-next.sh` — next button when playing | 2s |
| `custom/scratchpad` | `scratchpad.sh` — window count in `special:magic` | 2s |
| `custom/power` | `power-menu.sh` — Rofi power menu | on-click |

---

## Eww Dashboard

On-demand floating overlay triggered by `SUPER+HOME`. Opens on the monitor where the cursor is. Slides in from the top on open, slides out on close.

### Architecture

```
eww/
├── eww.yuck          # Widget definitions + window
├── eww.scss          # Styling
└── scripts/
    ├── toggle-panel.sh        # Open/close with monitor detection + animation
    ├── brightness-daemon.sh   # Cache daemon — reads all 3 monitors in parallel every 5s
    ├── brightness-get.sh      # Read from cache (instant, no DDC hit)
    ├── brightness-set.sh      # Debounced per-bus write (300ms debounce + flock)
    └── media-status.sh        # Play/pause icon
```

### Brightness system

Brightness uses DDC/CI via `ddcutil`. Naïve polling would saturate the I2C bus, so:

1. **Daemon** reads all 3 monitors in parallel (`&` + `wait`) every 5s → writes `/tmp/eww-brightness-{1,2,3}`
2. **Reads** are instant file reads (no DDC hit)
3. **Writes** are debounced: latest desired value written to `/tmp/eww-brightness-pending-{bus}`, a background process holds `flock` and waits 300ms before applying the final value — rapid slider moves collapse into one `ddcutil setvcp` call

### Panel sections

| Section | Content |
|---------|---------|
| Clock | Live HH:MM:SS + date |
| Brightness | DDC/CI slider + −5/+5 buttons per monitor |
| Volume | PipeWire slider + −5/+5 buttons |
| System | CPU% · RAM used · GPU% · VRAM used |
| Media | Prev / Play-Pause / Next + track title |
| Footer | Network interface + NordVPN status/toggle |

### Monitor detection

`toggle-panel.sh` gets cursor position via `hyprctl cursorpos`, finds the monitor whose bounding box contains it via `hyprctl monitors -j` + `jq`, then calls `eww open dashboard --screen <index>`.

---

## Hypridle + Hyprlock

`hypridle` manages idle timeouts (configured in `hypr/autostart.conf`):
- **10 min** → lock screen via `hyprlock`
- **15 min** → DPMS off (monitors sleep)

`hyprlock` lock screen per monitor:
- `HDMI-A-1` (OLED) → solid black, no widgets (burn-in prevention)
- `DP-1` / `HDMI-A-2` → blurred screenshot + clock + date + password field

---

## Styling

| Property | Value |
|----------|-------|
| Accent gradient | `#33ccff` → `#00ff99` |
| Background (bar) | `rgba(26, 26, 26, 0.85)` |
| Background (eww) | `rgba(12, 12, 12, 0.96)` |
| Font (bar) | Rubik 13px + Material Symbols Rounded (icons) |
| Font (eww) | Noto Sans + MesloLGS Nerd Font (icons) |
| Border radius | 12px (panels), 8px (pills) |

---

## File Structure

```
narexil-desktop/
├── hypr/
│   ├── hyprland.conf       # Sources the other files
│   ├── autostart.conf      # All exec-once entries
│   ├── bind.conf           # Keybinds
│   ├── monitors.conf       # Monitor layout + scale
│   ├── general.conf        # Window rules, gaps, HDR
│   ├── rules.conf          # Window rules
│   ├── hyprlock.conf       # Lock screen layout
│   ├── workspaces.conf     # Workspace rules
│   └── scripts/
│       ├── zoom-cycle.sh
│       └── lock-models-ram.sh
├── waybar/
│   ├── config-main.jsonc   # Bar for DP-1 + HDMI-A-2
│   ├── config-oled.jsonc   # Bar for HDMI-A-1 (overlay)
│   ├── style.css           # Shared styling
│   └── scripts/            # All custom modules + oled-autohide daemon
├── eww/
│   ├── eww.yuck            # Widgets + window definition
│   ├── eww.scss            # Styling
│   └── scripts/            # Brightness daemon, toggle, media
├── rofi/                   # Theme + modes
└── docs/
    └── design.md
```

---

## Key Binds (highlights)

| Bind | Action |
|------|--------|
| `SUPER+Home` | Toggle Eww dashboard on current monitor |
| `SUPER+B` | Open Vivaldi |
| `SUPER+L` | Lock screen (hyprlock) |
| `SUPER+R` | Rofi launcher |
| `SUPER+Shift+V` | Clipboard history |
| `SUPER+Alt+F` | French text correction (Ollama/mistral-nemo) |
| `SUPER+Z` | Zoom cycle (1× → 1.5× → 2.5× → 4×) |
| `SUPER+S` | Toggle scratchpad |
| `Print` | Screenshot (full / region / window) |
