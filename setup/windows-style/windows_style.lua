-- Windows-style desktop behaviour on top of Omarchy.
-- Loaded last from hyprland.lua. To return to Omarchy's tiling defaults,
-- comment out require("hypr.windows_style") there and save.
-- Tracked in ~/omarchy-setup/setup/windows-style/.

-- Command overrides ----------------------------------------------------------
-- Put ~/.local/lib/omarchy-overrides/bin first on PATH for commands the
-- compositor starts, so the drifting-landscape omarchy-launch-screensaver
-- replaces Omarchy's ASCII one. The idle service itself runs `bash -lc`, which
-- resets PATH, so ~/.bash_profile prepends the same folder. The folder holds
-- only deliberate overrides; delete a file there to restore the stock command.
do
  local overrides = os.getenv("HOME") .. "/.local/lib/omarchy-overrides/bin"
  local kept = { overrides }
  for entry in (os.getenv("PATH") or ""):gmatch("[^:]+") do
    if entry ~= overrides then table.insert(kept, entry) end
  end
  hl.env("PATH", table.concat(kept, ":"))
end

-- Qt apps (Dolphin, Kate, Gwenview) take their palette from GTK via Omarchy's
-- QT_QPA_PLATFORMTHEME=gtk3. This JSON overrides that mapping with fixed
-- near-black greys, subtle alternating rows, and the title-bar blue.
hl.env("QT_GUI_GTK_JSON", os.getenv("HOME") .. "/.config/omarchy/qt-gtk-palette.json")

-- Window behaviour -----------------------------------------------------------

hl.config({
  general = {
    -- Resize floating windows by dragging their edges.
    resize_on_border = true,
    -- Floating windows stick to screen edges and to each other.
    snap = { enabled = true },
  },
  input = {
    -- Click to focus. The window under the cursor still receives scrolling.
    follow_mouse = 2,
  },
})

-- Open every window floating and centred instead of tiled.
o.window(".*", { float = true })
o.window(".*", { center = true })
-- Remember a window's size when the same app opens it again.
o.window(".*", { persistent_size = true })
-- Omarchy tiles Chromium-based browsers (tile = true by tag); that put
-- Chrome full-size behind every floating window. Float them like the rest.
o.window({ tag = "chromium-based-browser" }, { tile = false, float = true, center = true })
-- App maximize requests stay suppressed (Omarchy's default): Chrome asks to
-- start maximized, which opened it tiled behind everything. Maximizing from
-- Grabbar's button or Win+Up still works through the handler below.
-- Thin 1px borders in exactly the title-bar colours, so with rounded corners
-- the join between title bar and window shows no extra line.
-- Hyprland can't drop the top edge alone; matching Grabbar's strip colour
-- makes it blend into the title bar. Overrides the theme's border colours.
hl.config({
  general = {
    border_size = 1,
    col = {
      active_border = "rgb(253040)",
      inactive_border = "rgb(1c1c1c)",
    },
  },
})
-- Rounded corners like Windows 11 (8px; Omarchy uses 0). Grabbar rounds the
-- title bar's top corners to match.
hl.config({ decoration = { rounding = 8 } })
-- Every window is fully opaque, as on Windows (Omarchy draws them at
-- 98.5% focused / 96% unfocused). Super+Backspace no longer toggles this.
o.window(".*", { opacity = "1.0 override 1.0 override" })

-- Raise a floating window whenever it gains focus, from the taskbar or
-- anywhere else, as Windows does. Hyprland only focuses it otherwise.
hl.on("window.active", function(window)
  if window and window.floating then
    hl.dispatch(hl.dsp.window.alter_zorder({ window = "address:" .. window.address, mode = "top" }))
  end
end)

-- When a pop-up that holds the keyboard closes (Start menu, Omarchy panels),
-- Hyprland keeps showing the window as active but, with click-to-focus, never
-- hands the keyboard back: the terminal cursor turns hollow and clicking the
-- same window does nothing. Re-focus the active window so it gets the keyboard.
-- Delayed: at the moment layer.closed fires the layer may still hold the
-- keyboard, so an immediate re-focus is lost (seen in practice).
hl.on("layer.closed", function()
  hl.timer(function()
    local window = hl.get_active_window()
    if window then
      hl.dispatch(hl.dsp.focus({ window = "address:" .. window.address }))
    end
  end, { timeout = 150, type = "oneshot" })
end)

-- Title bars (Grabbar) -------------------------------------------------------
-- Dark slate blue-grey #253040 for the focused window, near-black #1c1c1c
-- for the rest (Josh: darker than grey, but clearly different).
-- Only set while Grabbar is loaded, so its options never produce config
-- errors at login; after `hyprctl plugin load`, run `hyprctl reload`.
-- A counted loop: Omarchy's keybindings menu evaluates this file with a stub
-- `hl` whose get_loaded_plugins() never ends under ipairs().
local plugins = hl.get_loaded_plugins()
for i = 1, #plugins do
  if plugins[i].name == "grabbar" then
    hl.config({ plugin = { grabbar = {
      bar_color = 0xff253040,
      inactive_bar_color = 0xff1c1c1c,
      text_color = 0xffffffff,
      text_font = "JetBrainsMono Nerd Font",
    } } })
  end
end

-- Snapping (Win+Arrow) -------------------------------------------------------

local gap = 10
local restore_geometry = {}

local function work_area(monitor)
  local r = monitor.reserved
  local width = monitor.width / monitor.scale
  local height = monitor.height / monitor.scale
  if monitor.transform % 2 == 1 then
    width, height = height, width
  end
  return monitor.x + r.left, monitor.y + r.top, width - r.left - r.right, height - r.top - r.bottom
end

local function remember(window)
  if not restore_geometry[window.address] then
    restore_geometry[window.address] = { at = window.at, size = window.size }
  end
end

local function unmaximize(window)
  if window.fullscreen ~= 0 then
    hl.dispatch(hl.dsp.window.fullscreen({ action = "unset", mode = "maximized" }))
  end
end

local function snap(side)
  local window = hl.get_active_window()
  if not window then
    return
  end
  local x, y, width, height = work_area(window.monitor or hl.get_active_monitor())
  unmaximize(window)
  if not window.floating then
    hl.dispatch(hl.dsp.window.float({ action = "enable" }))
  end
  if maximized[window.address] then
    restore_geometry[window.address] = maximized[window.address]
    maximized[window.address] = nil
  end
  remember(window)
  local half = math.floor((width - 3 * gap) / 2)
  local left = side == "left" and x + gap or x + 2 * gap + half
  hl.dispatch(hl.dsp.window.resize({ x = half, y = height - 2 * gap }))
  hl.dispatch(hl.dsp.window.move({ x = left, y = y + gap }))
end

-- Windows-style maximize. Hyprland's "maximized" state draws a window beneath
-- all floating windows, so with everything floating a maximized window (e.g.
-- Chrome restoring its last state) ended up behind the rest. Instead, any
-- maximize request (app, Grabbar's button, Win+Up) turns into a floating
-- window that fills the work area, stacked normally; asking again restores
-- the previous geometry. Real fullscreen (state 2) is left alone.
local maximized = {}

local function place(address, at, size)
  local target = "address:" .. address
  hl.dispatch(hl.dsp.window.resize({ window = target, x = size[1], y = size[2] }))
  hl.dispatch(hl.dsp.window.move({ window = target, x = at[1], y = at[2] }))
end

local function xy(v)
  return { v.x or v[1], v.y or v[2] }
end

local function toggle_maximize(window)
  local address = window.address
  local x, y, width, height = work_area(window.monitor or hl.get_active_monitor())
  local saved = maximized[address]
  if saved then
    maximized[address] = nil
    place(address, saved.at, saved.size)
    return
  end
  local at, size = xy(window.at), xy(window.size)
  -- A window that opened already maximized has no smaller size to return to;
  -- give it a centred 70% window instead.
  if size[1] >= width - 2 and size[2] >= height - 2 then
    size = { math.floor(width * 0.7), math.floor(height * 0.7) }
    at = { x + math.floor((width - size[1]) / 2), y + math.floor((height - size[2]) / 2) }
  end
  maximized[address] = { at = at, size = size }
  restore_geometry[address] = nil
  place(address, { x, y }, { width, height })
  hl.dispatch(hl.dsp.window.alter_zorder({ window = "address:" .. address, mode = "top" }))
end

hl.on("window.fullscreen", function(window)
  -- The screensaver must stay truly fullscreen over the taskbar (OLED).
  if not window or window.fullscreen ~= 1 or window.class == "org.omarchy.screensaver" then
    return
  end
  hl.dispatch(hl.dsp.window.fullscreen({ window = "address:" .. window.address, action = "unset", mode = "maximized" }))
  if not window.floating then
    hl.dispatch(hl.dsp.window.float({ window = "address:" .. window.address, action = "enable" }))
  end
  toggle_maximize(window)
end)

local function maximize()
  local window = hl.get_active_window()
  if window and window.fullscreen == 0 and not maximized[window.address] then
    toggle_maximize(window)
  end
end

-- Win+Down: leave maximized, or return a snapped window to its earlier size.
local function restore()
  local window = hl.get_active_window()
  if not window then
    return
  end
  if maximized[window.address] then
    toggle_maximize(window)
    return
  end
  if window.fullscreen ~= 0 then
    unmaximize(window)
    return
  end
  local saved = restore_geometry[window.address]
  if saved then
    restore_geometry[window.address] = nil
    hl.dispatch(hl.dsp.window.resize({ x = saved.size.x or saved.size[1], y = saved.size.y or saved.size[2] }))
    hl.dispatch(hl.dsp.window.move({ x = saved.at.x or saved.at[1], y = saved.at.y or saved.at[2] }))
  end
end

-- Win+D: switch to an empty workspace; press again to come back. Windows are
-- never moved, so nothing can be stranded if the config reloads.
local function show_desktop()
  local workspace = hl.get_active_workspace()
  if workspace and #hl.get_workspace_windows(workspace) == 0 then
    hl.dispatch(hl.dsp.focus({ workspace = "previous" }))
  else
    hl.dispatch(hl.dsp.focus({ workspace = "emptym" }))
  end
end

-- Keybindings ----------------------------------------------------------------
-- Each unbind notes the Omarchy default it replaces.

-- Was: focus the window in that direction.
hl.unbind("SUPER + LEFT")
hl.unbind("SUPER + RIGHT")
hl.unbind("SUPER + UP")
hl.unbind("SUPER + DOWN")
o.bind("SUPER + LEFT", "Snap window left", function() snap("left") end)
o.bind("SUPER + RIGHT", "Snap window right", function() snap("right") end)
o.bind("SUPER + UP", "Maximize window", maximize)
o.bind("SUPER + DOWN", "Restore window", restore)

o.bind("ALT + F4", "Close window", hl.dsp.window.close())
o.bind("SUPER + E", "File Explorer", { launch = "dolphin --new-window" })
-- Dolphin is the only file manager. Was: Nautilus, and Nautilus in the
-- terminal's current directory.
hl.unbind("SUPER + SHIFT + F")
hl.unbind("SUPER + ALT + SHIFT + F")
o.bind("SUPER + SHIFT + F", "File manager", { launch = "dolphin --new-window" })
o.bind("SUPER + ALT + SHIFT + F", "File manager (cwd)", 'uwsm-app -- dolphin --new-window "$(omarchy-cmd-terminal-cwd)"')
o.bind("SUPER + D", "Show desktop", show_desktop)
o.bind("SUPER + PERIOD", "Emoji picker", "omarchy-shell shell toggle omarchy.emojis")
o.bind("SUPER + H", "Dictation", "voxtype record toggle")
o.bind("SUPER + N", "Notification center", "omarchy-shell shell toggle jankeesvw.notification-center")
o.bind("SUPER + A", "Quick settings", "omarchy-shell shell toggle aryal.control-center")
o.bind("CTRL + SHIFT + ESCAPE", "Task manager", { tui = "btop" })
o.bind("SUPER + I", "Settings", "omarchy-menu toggle root")

-- Was: toggle workspace layout (now Win+Ctrl+Alt+L).
hl.unbind("SUPER + L")
o.bind("SUPER + L", "Lock", "omarchy-system-lock")
o.bind("SUPER + CTRL + ALT + L", "Toggle workspace layout", "omarchy-hyprland-workspace-layout-toggle")

-- Was: Google Maps web app.
hl.unbind("SUPER + SHIFT + S")
o.bind("SUPER + SHIFT + S", "Screenshot", "omarchy-capture-screenshot")

-- Was: universal paste (Ctrl+V still pastes everywhere except terminals).
hl.unbind("SUPER + V")
o.bind("SUPER + V", "Clipboard history", "omarchy-shell shell toggle omarchy.clipboard")

-- Was: close ALL windows without asking.
hl.unbind("CTRL + ALT + DELETE")
o.bind("CTRL + ALT + DELETE", "System menu", "omarchy-menu toggle system")

-- Was: next workspace. Win+Ctrl+Left/Right were grouped-window focus.
hl.unbind("SUPER + TAB")
hl.unbind("SUPER + CTRL + LEFT")
hl.unbind("SUPER + CTRL + RIGHT")
o.bind("SUPER + TAB", "Task View", "omarchy-shell shell toggle se.mindfulstack.omascape")
o.bind("SUPER + CTRL + RIGHT", "Next desktop", hl.dsp.focus({ workspace = "e+1" }))
o.bind("SUPER + CTRL + LEFT", "Previous desktop", hl.dsp.focus({ workspace = "e-1" }))

-- Tapping Win alone opens the Start menu (tyrsolution.app-launcher; the
-- earlier Simple Start Menu is installed but disabled).
o.bind("SUPER + SUPER_L", "Start menu", "omarchy-shell shell toggle tyrsolution.app-launcher '{}'", { release = true })

-- Windows-style Alt+Tab (hold Alt, most recently used first). The plugin
-- replaces Omarchy's Alt+Tab bindings itself. Guarded so a removed plugin
-- cannot break config loading.
local altswitch = os.getenv("HOME") .. "/.config/omarchy/plugins/io.github.pablo-merino.altswitch/altswitch.lua"
local altswitch_file = io.open(altswitch)
if altswitch_file then
  altswitch_file:close()
  dofile(altswitch)
end
