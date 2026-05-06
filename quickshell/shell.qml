//@ pragma Env QSG_RENDER_LOOP=threaded
//@ pragma UseQApplication

// Singletons auto-instantiate on import
import "./services"
import "./dashboard"
import "./launcher"

// Scopes must be explicitly instantiated
import "./bar"
import Quickshell

ShellRoot {
    MainBars {}
    OledBar {}
    Dashboard {}
    EqOverlay {}
    CalendarOverlay {}
    NotifPopups {}
    NotifCenter {}
    Launcher {}
    ClipboardPicker {}
}
