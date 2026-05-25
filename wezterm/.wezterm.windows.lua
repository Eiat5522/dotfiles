local wezterm = require("wezterm")
local launch_menu = {}
local act = wezterm.action
local config = wezterm.config_builder()
-- ----------------------- My Configuration Starts Here  ---------------------------- --
config.default_domain = "Ubuntu-24.04"
-- -------------------------------------------------------------------------------- --
config.default_prog = { "wsl.exe", "~", "-d", "Ubuntu-24.04", "--exec", "bash", "-l" }
-- ---------------------------- Launcher Menu Domain Selector ------------------------- --
config.launch_menu = {
	{
		label = "Pwsh",
		args = { "pwsh.exe", "-NoLogo" },
		cwd = "C:\\Users\\Dev\\",
	},
	{
		label = "Powershell",
		args = { "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe", "-NoLogo" },
		cwd = "C:\\Users\\Dev\\",
	},
	{
		label = "Command Prompt",
		args = { "cmd.exe", "/s", "/k", "c:/clink/clink_x64.exe", "inject", "-q" },
		cwd = "C:\\Users\\Dev\\",
		set_environment_variables = {
			prompt = "$E]7;file://localhost/$P$E\\$E[32m$T$E[0m $E[35m$P$E[36m$_$G$E[0m ",
			DIRCMD = "/d",
		},
	},
	{
		label = "WSL: Ubuntu-24.04",
		args = { "wsl.exe", "-d", "Ubuntu-24.04", "--exec", "bash", "-l" },
		set_environment_variables = {
			prompt = '$E]7;file://localhost/$P$E\\$E[32m$T$E[0m $E[35m$P$E[36m$_$G$E[0m ',
		},
		--args = { "bash", "-l" },
		--domain = 'DefaultDomain',
--		--cwd = "home/eiat/projects"
	},
}
-- ---------------------------------------------------------------------------------- --
-- -------------------- ---- MULTIPLEXER SERVER DOMAINS  ---------------------------- --
-- --------------------------- WSL Domains Configuration  ---------------------------- --
 config.wsl_domains = {
	{
		name = "Ubuntu-24.04",
		distribution = "Ubuntu-24.04",
		username = "eiat",
		default_cwd = "/home/eiat/",
		default_prog = { "bash", "-l" },
	},
}
-- --------------------------- SSH Domains Configuration  ----------------------------- --
config.ssh_domains = {
	{
		-- This name identifies the domain
		name = "my.server",
		remote_address = "127.0.0.1:22",
		username = "eiat",
		ssh_option = { identityfile = 'C:/Users/name/.ssh/id_ed25519' },
	},
}
-- --------------------------- Unix Domain Configuration  ---------------------------- --
config.unix_domains = {
	{
		name = "unix",
		skip_permissions_check = true,
		socket_path = "C:\\Users\\Dev\\.local\\share\\wezterm\\unix-mux.sock",
--		proxy_command = { '/Users/dev/.local/share/wezterm/sock' },
		local_echo_threshold_ms = 10,
		-- If true, do not attempt to start this server if we try and fail to connect to it.
		no_serve_automatically = false,
	},
}
-- This causes `wezterm` to act as though it was started as `wezterm connect unix`
-- by default, connecting to the unix domain on `wezterm` startup.
-- config.default_gui_startup_args = { 'connect', 'unix' }
-- ----------------------------------------------------------------------------------- --
-- Informing `wezterm` that all hosts are unix machines, so spawning a tab in the same directory
-- as an existing tab work even for a plain SSH session:
-- config.ssh_domains = wezterm.default_ssh_domains()
-- for _, dom in ipairs(config.ssh_domains) do
-- dom.assume_shell = "Posix"
-- end
-- -------------------  Set Default_Multiplexer_Server_Domain  ----------------------- --
 config.default_mux_server_domain = "wsl_domains"
-- -------------------  Set Default WSL Domain  ----------------------- --
for _, dom in ipairs(config.wsl_domains) do
	if dom.name == "Ubuntu-24.04" then
		dom.default_prog = { "bash", "-l" }
	end
end
-- --------------------- General Configuration ------------------------ --
-- ---------------------- Aesthetic Settings ---------------------------- --
config.color_scheme = "tokyonight"
config.window_background_opacity = 0.98
config.font_size = 13
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.allow_win32_input_mode = false
-- -------------------  TAB BAR CONFIGURATION  ------------------------ --
config.enable_tab_bar = true
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = false
-- -----------------   SET WINDOW DECORATIONS   ---------------------- --
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
-- -------------- INTEGRATED TITLE BAR BUTTONS STYLE ----------------- --
-- -----------  "Windows or  Gnome" -- Selectable Choice  ------------ --
config.integrated_title_button_style = "Gnome"
config.integrated_title_buttons = { "Hide", "Maximize", "Close" }
config.integrated_title_button_alignment = "Right"
config.integrated_title_button_color = "Auto"
-- ----------- CURSOR SETTINGS ------------- --
config.default_cursor_style = "BlinkingBlock"
config.cursor_blink_rate = 500
config.underline_thickness = "2px"
-- ----------- Extras ------------- --
config.enable_scroll_bar = true
config.hide_mouse_cursor_when_typing = true
-- ---------- QUALITY OF LIFE ----------
config.audible_bell = "SystemBeep"
config.warn_about_missing_glyphs = true
config.enable_wayland = false -- helps with WSL graphics consistency
-- --------------------------------------------------------------------- --
-- ------------------------ Mouse Binding ------------------------------ --
local mouse_bindings = {
	-- Bind 'Up' event of CTRL-Click to open hyperlinks
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = act.OpenLinkAtMouseCursor,
	},
	-- Disable the 'Down' event of CTRL-Click to avoid weird program behaviors
	{
		event = { Down = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = act.Nop,
	},
}
-- ---------------------------------------- Custom Key Binding ------------------------------------------------ --
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 2000 } -- CTRL+a as a "leader key" like tmux

local keys = {
	-- Pane splits (using current pane's domain and CWD)
	{ key = "/", mods = "CTRL|ALT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = ".", mods = "CTRL|ALT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	-- Split panes in different directions with CRTL|ALT + ArrowKey
	{ key = "LeftArrow", mods = "CTRL|ALT", action = act.ActivatePaneDirection("Left") },
	{ key = "RightArrow", mods = "CTRL|ALT", action = act.ActivatePaneDirection("Right") },
	{ key = "UpArrow", mods = "CTRL|ALT", action = act.ActivatePaneDirection("Up") },
	{ key = "DownArrow", mods = "CTRL|ALT", action = act.ActivatePaneDirection("Down") },
	-- Resize panes
	{ key = "H", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Left", 3 }) },
	{ key = "L", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Right", 3 }) },
	{ key = "K", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Up", 1 }) },
	{ key = "J", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Down", 1 }) },
	-- Close active pane
	{ key = "w", mods = "CTRL|ALT", action = act.CloseCurrentPane({ confirm = false }) },
	{ key = "x", mods = "CTRL|ALT", action = act.CloseCurrentPane({ confirm = false }) },
	-- Tab controls
	{ key = "t", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "x", mods = "LEADER", action = act.CloseCurrentTab({ confirm = true }) },
	{ key = "Tab", mods = "CTRL", action = act.ActivateTabRelative(1) },
	{ key = "Tab", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },
	-- Command palette
	{ key = "p", mods = "CTRL|SHIFT", action = act.ActivateCommandPalette },
	-- Show launcher menu
	{
		key = "l",
		mods = "CTRL|ALT",
		action = act.ShowLauncherArgs({ flags = "FUZZY|LAUNCH_MENU_ITEMS|DOMAINS|TABS|WORKSPACES" }),
	},
	-- Send "CTRL-A" to the terminal when pressing CTRL-A, CTRL-A
	{ key = "a", mods = "LEADER|CTRL", action = wezterm.action.SendKey({ key = "a", mods = "CTRL" }) },
	-- Detaches the domain associated with the current pane
	{
		key = "d",
		mods = "CTRL|SHIFT",
		action = act.DetachDomain("CurrentPaneDomain"),
	},
	-- Rename Current Tab
	{
    key = 'E',
    mods = 'CTRL|SHIFT',
    action = act.PromptInputLine {
      description = 'Enter new name for tab',
      initial_value = 'My Tab Name',
      action = wezterm.action_callback(function(window, pane, line)
        -- line will be `nil` if they hit escape without entering anything
        -- An empty string if they just hit enter
        -- Or the actual line of text they wrote
        if line then
          window:active_tab():set_title(line)
        end
      end),
    },
	}
}

launch_menu = launch_menu
config.mouse_bindings = mouse_bindings
config.keys = keys

return config
