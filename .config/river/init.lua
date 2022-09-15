#!/usr/bin/lua

--[[
NOTE:
- execp() needs 'lua-posix' package
- bitwise operands for tag mappings need Lua version >= 5.3
--]]

-- Convenient functions ────────────────────────────────────────────────────────
local browser = 'firefox'

-- Wrapper around table.concat() to also handle other types
local function concat(...)
  local list, sep, i, j = ...

  if type(list) == 'table' then
    return table.concat(list, sep, i, j)
  else
    return tostring(list)
  end
end

-- All the setting tables ──────────────────────────────────────────────────────

local drun_menu = 'rofi -show drun'
local run_menu = 'rofi -show run'

local startup_commands = {
  -- Inform dbus about the environment variables
  {
    'dbus-update-activation-environment',
    'DISPLAY',
    'WAYLAND_DISPLAY',
    'XDG_SESSION_TYPE',
    'XDG_CURRENT_DESKTOP',
  },
  {
    'pipewire',
    'pipewire-pulse',
    'pipewire-media-session',
    'mpd',
    '/usr/lib/xfce-polkit/xfce-polkit',
  },
}

-- Wallpaper
os.execute('swaybg -i /home/soliprem/.config/bg &')
-- Dunst
os.execute('dunst &')
-- Configure outputs
os.execute("wlr-randr --output HDMI-A-1 --mode 1920x1080@120Hz")

local inputs = {
  ['pointer-2-7-SynPS/2_Synaptics_TouchPad'] = {
    ['events'] = 'disabled-on-external-mouse',
    ['drag'] = 'enabled',
    ['tap'] = 'enabled',
    ['tap-button-map'] = 'left-right-middle',
    ['disable-while-typing'] = 'enabled',
    ['natural-scroll'] = 'enabled',
    ['scroll-method'] = 'two-finger',
  },
}

local river_options = {
  -- Theme options
  ['border-width'] = 2,
  ['border-color-focused'] = '0xeceff4',
  ['border-color-unfocused'] = '0x81a1c1',
  ['border-color-urgent'] = '0xbf616a',
  ['xcursor-theme'] = { 'Bibata-Modern-Ice', 24 },
  ['background-color'] = '0x2e3440',

  -- Other options
  ['set-repeat'] = { 50, 300 },
  -- ['focus-follows-cursor'] = 'normal',
  ['set-cursor-warp'] = 'on-output-change',
  ['attach-mode'] = 'bottom',
  ['default-layout'] = 'rivertile',
}

local gsettings = {
  ['org.gnome.desktop.interface'] = {
    ['gtk-theme'] = 'gruvbox-material',
    ['icon-theme'] = 'Papirus-Dark',
    ['cursor-theme'] = river_options['xcursor-theme'][1],
    ['cursor-size'] = river_options['xcursor-theme'][2],
  },
}

local window_rules = {
  ['float-filter-add'] = {
    ['app-id'] = {
      'float',
      'popup',
      'swappy',
      'pinentry-qt',
      'pavucontrol-qt',
    },
    ['title'] = {
      'Picture-in-Picture',
      -- 'About *',
    },
  },
  ['csd-filter-add'] = {
    ['app-id'] = { 'swappy' },
  },
}

-- Additional modes and their mappings to switch between them and 'normal' mode
--
-- name: string (the name of the additional mode)
-- mod: string|list (modifiers for key binding, concanated by '+')
-- key: string
local modes = {
  {
    name = 'passthrough',
    mod = 'Super',
    key = 'F11',
  },
}

-- Each mapping contains 4 keys:
--
-- mod: string|list (modifiers, concanated by '+')
-- key: string
-- command: string|list (the command passed to riverctl)
-- opt: string ('release' or 'repeat')
local mappings = {
  -- Key bindings
  map = {
    normal = {
      {
        mod = "Super",
        key = "t",
        command = {"spawn", [['time_date']]},
      },
      {
        mod = "Super",
        key = "s",
        command = {"spawn", [['dictionary']]},
      },
      {
        mod = "Super",
        key = "BackSpace",
        command = {"spawn", [['sysact']]},
      },
      -- Terminal emulators
      {
        mod = 'Super',
        key = 'Return',
        command = { 'spawn', 'foot' },
      },
      {
        mod = 'Super',
        key = 'e',
        command = {'spawn', string.format([['foot -e neomutt']])},
      },
      {
        mod = 'Super',
        key = 'r',
        command = {'spawn', string.format([['foot -e nnn -e']])},
      },
      {
        mod = {'Super', 'Shift'},
        key = 'R',
        command = {'spawn', string.format([['foot -e btop']])},
      },
      {
        mod = 'Super',
        key = 'v',
        command = {'spawn', string.format([['foot -e nvim +VimwikiIndex']])},
      },
      {
        mod = { 'Super', 'Shift' },
        key = 'Return',
        command = { 'spawn', 'alacritty' },
      },
      {
        mod = 'Super',
        key = 'w',
        command = { 'spawn', browser },
      },
      -- Application launcher
      {
        mod = 'Super',
        key = 'D',
        command = { 'spawn', string.format([['%s']], drun_menu) },
      },
      {
        mod = { 'Super', 'Shift' },
        key = 'D',
        command = { 'spawn', string.format([['%s']], run_menu) },
      },
      -- Rofi has qalc and file-browser-extended plugins
      {
        mod = { 'Super', 'Shift' },
        key = 'T',
        command = { 'spawn', [['rofi -show calc']] },
      },
      {
        mod = { 'Super', 'Shift' },
        key = 'F',
        command = { 'spawn', [['rofi -show filebrowser']] },
      },
      -- Clipboard management with clipman
      {
        mod = { 'Super', 'Alt' },
        key = 'D',
        command = { 'spawn', string.format([['%s/clipboard --rofi']], wl_script_dir) },
      },
      {
        mod = { 'Super', 'Alt' },
        key = 'C',
        command = { 'spawn', string.format([['%s/clipboard --clear']], wl_script_dir) },
      },
      {
        mod = 'Super',
        key = 'C',
        command = { 'spawn', string.format([['%s/clipboard --rofi-clear']], wl_script_dir) },
      },
      -- Dismiss notifications
      {
        mod = { 'Super', 'Alt' },
        key = 'N',
        command = { 'spawn', string.format([['%s/dismiss_notify']], wl_script_dir) },
      },
      -- Launch Emacs
      {
        mod = { 'Super', 'Alt' },
        key = 'E',
        command = { 'spawn', [['emacsclient -c -a emacs']] },
      },
      -- Taking screenshots
      {
        key = 'Print',
        command = { 'spawn', string.format([['screenshot']])},
      },
      {
        mod = 'Super',
        key = 'Print',
        command = { 'spawn', string.format([['%s/screenshot --full']], wl_script_dir) },
      },
      {
        mod = 'None',
        key = 'Print',
        command = { 'spawn', string.format([['%s/screenshot --region']], wl_script_dir) },
      },
      {
        mod = 'Alt',
        key = 'Print',
        command = { 'spawn', string.format([['%s/screenshot --region-optional']], wl_script_dir) },
      },
      {
        mod = 'Control',
        key = 'Print',
        command = { 'spawn', string.format([['%s/screenshot --full-optional']], wl_script_dir) },
      },
      {
        mod = { 'Super', 'Alt' },
        key = 'Print',
        command = { 'spawn', string.format([['%s/screenshot --region-copy']], wl_script_dir) },
      },
      {
        mod = { 'Super', 'Control' },
        key = 'Print',
        command = { 'spawn', string.format([['%s/screenshot --full-copy']], wl_script_dir) },
      },
      -- Super+Q to close the focused view
      {
        mod = 'Super',
        key = 'Q',
        command = 'close',
      },
      -- Super+Shift+Q to exit river (requires 'swaynag' program from sway)
      {
        mod = { 'Super', 'Shift' },
        key = 'Q',
        command = { 'spawn', [['swaynag -t warning -m "Exit river?" -b "Yes" "riverctl exit"']] },
      },
      -- Super+Shift+X to lock the screen
      {
        mod = { 'Super', 'Shift' },
        key = 'X',
        command = { 'spawn', 'swaylock' },
      },
      -- Super+{J,K} to focus next/previous view in the layout stack
      {
        mod = 'Super',
        key = 'J',
        command = { 'focus-view', 'next' },
      },
      {
        mod = 'Super',
        key = 'K',
        command = { 'focus-view', 'previous' },
      },
      -- Super+Shift+{J,K} to swap focused view with the next/previous view in the layout stack
      {
        mod = { 'Super', 'Shift' },
        key = 'J',
        command = { 'swap', 'next' },
      },
      {
        mod = { 'Super', 'Shift' },
        key = 'K',
        command = { 'swap', 'previous' },
      },
      -- Super+{P,N} to focus next/previous output
      {
        mod = 'Super',
        key = 'P',
        command = { 'focus-output', 'previous' },
      },
      {
        mod = 'Super',
        key = 'N',
        command = { 'focus-output', 'next' },
      },
      -- Super+Shift+{P,N} to send the focused view to next/previous output
      {
        mod = { 'Super', 'Shift' },
        key = 'P',
        command = { 'send-to-output', 'previous' },
      },
      {
        mod = { 'Super', 'Shift' },
        key = 'N',
        command = { 'send-to-output', 'next' },
      },
      -- Super+zoom to bump the focused view to the top of the layout stack
      {
        mod = 'Super',
        key = 'Space',
        command = 'zoom',
      },
      -- Super+{H,L} to decrease/increase the main_factor value of rivertile by 0.02
      {
        mod = 'Super',
        key = 'H',
        command = { 'send-layout-cmd', 'rivertile', [['main-ratio -0.02']] },
      },
      {
        mod = 'Super',
        key = 'L',
        command = { 'send-layout-cmd', 'rivertile', [['main-ratio +0.02']] },
      },
      -- Super+Shift+{H,L} to increment/decrement the main_count value of rivertile
      {
        mod = { 'Super', 'Shift' },
        key = 'H',
        command = { 'send-layout-cmd', 'rivertile', [['main-count +1']] },
      },
      {
        mod = { 'Super', 'Shift' },
        key = 'L',
        command = { 'send-layout-cmd', 'rivertile', [['main-count -1']] },
      },
      -- Control+Alt+{H,J,K,L} to change layout orientation
      {
        mod = { 'Control', 'Alt' },
        key = 'H',
        command = { 'send-layout-cmd', 'rivertile', [['main-location left']] },
      },
      {
        mod = { 'Control', 'Alt' },
        key = 'J',
        command = { 'send-layout-cmd', 'rivertile', [['main-location bottom']] },
      },
      {
        mod = { 'Control', 'Alt' },
        key = 'K',
        command = { 'send-layout-cmd', 'rivertile', [['main-location top']] },
      },
      {
        mod = { 'Control', 'Alt' },
        key = 'L',
        command = { 'send-layout-cmd', 'rivertile', [['main-location right']] },
      },
      -- Super+Alt+{H,J,K,L} to move views (floating)
      {
        mod = { 'Super', 'Alt' },
        key = 'H',
        command = { 'move', 'left', 100 },
      },
      {
        mod = { 'Super', 'Alt' },
        key = 'J',
        command = { 'move', 'down', 100 },
      },
      {
        mod = { 'Super', 'Alt' },
        key = 'K',
        command = { 'move', 'up', 100 },
      },
      {
        mod = { 'Super', 'Alt' },
        key = 'L',
        command = { 'move', 'right', 100 },
      },
      -- Super+Control+{H,J,K,L} to resize views
      {
        mod = { 'Super', 'Control' },
        key = 'H',
        command = { 'resize', 'horizontal', -100 },
      },
      {
        mod = { 'Super', 'Control' },
        key = 'J',
        command = { 'resize', 'vertical', 100 },
      },
      {
        mod = { 'Super', 'Control' },
        key = 'K',
        command = { 'resize', 'vertical', -100 },
      },
      {
        mod = { 'Super', 'Control' },
        key = 'L',
        command = { 'resize', 'horizontal', 100 },
      },
      -- Super+Alt+Control+{H,J,K,L} to snap views to screen edges
      {
        mod = { 'Super', 'Alt', 'Control' },
        key = 'H',
        command = { 'snap', 'left' },
      },
      {
        mod = { 'Super', 'Alt', 'Control' },
        key = 'J',
        command = { 'snap', 'down' },
      },
      {
        mod = { 'Super', 'Alt', 'Control' },
        key = 'K',
        command = { 'snap', 'up' },
      },
      {
        mod = { 'Super', 'Alt', 'Control' },
        key = 'L',
        command = { 'snap', 'right' },
      },
      -- Super+Space to toggle float
      {
        mod = {'Super', 'Shift'},
        key = 'Space',
        command = 'toggle-float',
      },
      -- Super+F to toggle fullscreen
      {
        mod = 'Super',
        key = 'F',
        command = 'toggle-fullscreen',
      },
    },
    locked = {
      -- Eject optical drives
      {
        mod = 'None',
        key = 'XF86Eject',
        command = { 'spawn', [['eject -T']] },
      },
      -- Control pulseaudio volume
      {
        mod = 'None',
        key = 'XF86AudioRaiseVolume',
        command = { 'spawn', string.format([['pamixer -i 5']]) },
        opt = 'repeat',
      },
      {
        mod = 'None',
        key = 'XF86AudioLowerVolume',
        command = { 'spawn', string.format([['pamixer -d 5']]) },
        opt = 'repeat',
      },
      {
        mod = 'None',
        key = 'XF86AudioMute',
        command = { 'spawn', string.format([['pamixer --toggle-mute']], wl_script_dir) },
      },
      {
        mod = 'None',
        key = 'XF86AudioMicMute',
        command = { 'spawn', string.format([['%s/volumecontrol --toggle-source']], wl_script_dir) },
      },
      -- Control MPRIS aware media players with 'playerctl'
      {
        mod = 'None',
        key = 'XF86AudioMedia',
        command = { 'spawn', [['playerctl play-pause']] },
      },
      {
        mod = 'None',
        key = 'XF86AudioPlay',
        command = { 'spawn', [['playerctl play-pause']] },
      },
      {
        mod = 'None',
        key = 'XF86AudioPrev',
        command = { 'spawn', [['playerctl previous']] },
      },
      {
        mod = 'None',
        key = 'XF86AudioNext',
        command = { 'spawn', [['playerctl next']] },
      },
      -- Control screen backlight brightness
      {
        mod = 'None',
        key = 'XF86MonBrightnessUp',
        command = { 'spawn', string.format([['%s/brightness up']], wl_script_dir) },
        opt = 'repeat',
      },
      {
        mod = 'None',
        key = 'XF86MonBrightnessDown',
        command = { 'spawn', string.format([['%s/brightness down']], wl_script_dir) },
        opt = 'repeat',
      },
    },
  },
  -- Mappings for pointer (mouse)
  ['map-pointer'] = {
    normal = {
      -- Super + Left Mouse Button to move views
      {
        mod = 'Super',
        key = 'BTN_LEFT',
        command = 'move-view',
      },
      -- Super + Right Mouse Button to resize views
      {
        mod = 'Super',
        key = 'BTN_RIGHT',
        command = 'resize-view',
      },
    },
  },
}

-- These mappings are repeated, so they are separated from the mappings table
local function tag_mappings()
  for i = 1, 9 do
    local tag_num = 1 << (i - 1)

    -- Super+[1-9] to focus tag [0-8]
    os.execute(string.format('riverctl map normal Super %s set-focused-tags %s', i, tag_num))

    -- Super+Shift+[1-9] to tag focused view with tag [0-8]
    os.execute(string.format('riverctl map normal Super+Shift %s set-view-tags %s', i, tag_num))

    -- Super+Control+[1-9] to toggle focus of tag [0-8]
    os.execute(string.format('riverctl map normal Super+Control %s toggle-focused-tags %s', i, tag_num))

    -- Super+Alt+[1-9] to toggle tag [0-8] of focused view
    os.execute(string.format('riverctl map normal Super+Alt %s toggle-view-tags %s', i, tag_num))
  end

  -- river has a total of 32 tags
  local all_tags = (1 << 32) - 1
  os.execute(string.format('riverctl map normal Super 0 set-focused-tags %s', all_tags))
  os.execute(string.format('riverctl map normal Super+Shift 0 set-view-tags %s', all_tags))
end

-- Apply settings ──────────────────────────────────────────────────────────────

-- Run startup commands
--
-- 'riverctl spawn ...' always returns (even when the child process is a daemon)
-- so we don't need to resort to posix.unistd.spawn()
for _, cmd in ipairs(startup_commands) do
  os.execute(string.format([[riverctl spawn '%s']], concat(cmd, ' ')))
end


-- Configure input devices
for device, options in pairs(inputs) do
  for key, val in pairs(options) do
    os.execute(string.format('riverctl input %s %s %s', device, key, val))
  end
end

-- GNOME-related settings
for group, tbl in pairs(gsettings) do
  for key, value in pairs(tbl) do
    os.execute(string.format('gsettings set %s %s %s', group, key, value))
  end
end

-- Set river's options
for key, value in pairs(river_options) do
  os.execute(string.format('riverctl %s %s', key, concat(value, ' ')))
end

-- Additional modes (beside 'normal' and 'locked')
for _, mode in ipairs(modes) do
  local mode_name = mode.name
  local modifiers = concat(mode.mod, '+')

  -- Declare the mode
  os.execute('riverctl declare-mode ' .. mode_name)

  -- Setup key bindings to enter/exit the mode
  os.execute(string.format('riverctl map normal %s %s enter-mode %s', modifiers, mode.key, mode_name))
  os.execute(string.format('riverctl map %s %s %s enter-mode normal', mode_name, modifiers, mode.key))
end

-- Keyboard and mouse bindings
for map_type, tbl in pairs(mappings) do
  for mode, value in pairs(tbl) do
    for _, binding in ipairs(value) do
      local modifiers = concat(binding.mod, '+')
      local cmd = concat(binding.command, ' ')

      -- Options -release and -repeat for 'map' and 'unmap' commands
      local opt = binding.opt
      if opt ~= 'release' and opt ~= 'repeat' then
        opt = ''
      else
        opt = '-' .. opt
      end

      os.execute(string.format('riverctl %s %s %s %s %s %s', map_type, opt, mode, modifiers, binding.key, cmd))

      -- Duplicate mappings of mode 'locked' for mode 'normal'
      if mode == 'locked' then
        os.execute(string.format('riverctl %s %s normal %s %s %s', map_type, opt, modifiers, binding.key, cmd))
      end
    end
  end
end

-- Mappings for tag management
tag_mappings()

-- Window rules (float/csd filters)
for key, value in pairs(window_rules) do
  for type, patterns in pairs(value) do
    for _, pattern in ipairs(patterns) do
      os.execute(string.format('riverctl %s %s %s', key, type, pattern))
    end
  end
end

-- Launch the layout generator as the final initial process.
--
-- River run the init file as a process group leader and send
-- SIGTERM to the group on exit. Therefore, keep the main init
-- process running (replace it with the layout generator process).
local unistd = require('posix.unistd')
unistd.execp('rivertile', {
  '-view-padding', 5,
  '-outer-padding', 5,
  '-main-location', 'left',
  '-main-count', 1,
  '-main-ratio', 0.54,
})
