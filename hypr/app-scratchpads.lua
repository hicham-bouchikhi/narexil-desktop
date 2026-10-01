-- Each app has a private scratchpad, shown on the focused monitor.
local M = {}
local apps = {
    cider = { command = "cider", classes = { cider = true, ["sh.cider.genten"] = true }, match = "^([Cc]ider|sh\\.cider\\.genten)$", keys = { "XF86Tools" } },
    teams = { command = "teams-for-linux --gtk-version=3", classes = { ["teams-for-linux"] = true }, match = "^([Tt]eams-for-linux)$", keys = { "SUPER + F1" } },
    discord = { command = "discord", classes = { discord = true, vesktop = true }, match = "^([Dd]iscord|[Vv]esktop)$", keys = { "SUPER + F2", "XF86HomePage" } },
}
local launching = {}

function M.toggle(name)
    local app = assert(apps[name], "Unknown app scratchpad")
    local workspace = "special:" .. name
    local active = hl.get_active_special_workspace()
    if active and active.name == workspace then
        hl.dispatch(hl.dsp.workspace.toggle_special(name))
        return
    end

    -- Reuse existing windows, including ones opened before the config reload.
    local found = false
    for _, window in ipairs(hl.get_windows()) do
        if window.mapped and app.classes[window.class:lower()] then
            found = true
            if not window.workspace or window.workspace.name ~= workspace then
                hl.dispatch(hl.dsp.window.move({ window = window, workspace = workspace, follow = false }))
            end
        end
    end

    -- Avoid launching duplicates while an Electron app is still starting.
    if found then
        launching[name] = nil
    elseif not launching[name] or os.time() - launching[name] >= 15 then
        launching[name] = os.time()
        hl.exec_cmd(app.command, { workspace = workspace .. " silent" })
    end

    hl.dispatch(hl.dsp.workspace.toggle_special(name))
end

for name, app in pairs(apps) do
    hl.window_rule({
        name = "scratchpad-" .. name,
        match = { class = app.match },
        workspace = "special:" .. name .. " silent",
    })
    for _, key in ipairs(app.keys) do
        hl.bind(key, function() M.toggle(name) end)
    end
end

return M
