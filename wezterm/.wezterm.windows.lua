local wezterm = require("wezterm")
local launch_menu = {}
local act = wezterm.action
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")
local config = wezterm.config_builder()

local resurrect_state_dir = wezterm.home_dir .. "\\.local\\share\\wezterm\\resurrect"

local function get_workspace_state_path(name)
	return string.format(
		"%s\\workspace\\%s.json",
		resurrect.state_manager.save_state_dir,
		name:gsub("[/\\]", "+")
	)
end

local function has_workspace_state(name)
	local file = io.open(get_workspace_state_path(name), "r")
	if file then
		file:close()
		return true
	end

	return false
end

local function save_current_workspace_state()
	local workspace_state = resurrect.workspace_state.get_workspace_state()
	resurrect.state_manager.save_state(workspace_state)
	resurrect.state_manager.write_current_state(workspace_state.workspace, "workspace")
end

local function restore_workspace_state(window, workspace_name)
	if not has_workspace_state(workspace_name) then
		resurrect.state_manager.write_current_state(workspace_name, "workspace")
		return
	end

	local state = resurrect.state_manager.load_state(workspace_name, "workspace")
	if state.window_states and #state.window_states > 0 then
		resurrect.workspace_state.restore_workspace(state, {
			window = window,
			relative = true,
			restore_text = true,
			resize_window = false,
			on_pane_restore = resurrect.tab_state.default_on_pane_restore,
		})
	end

	resurrect.state_manager.write_current_state(workspace_name, "workspace")
end

local function restore_saved_state(win, pane)
	resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id)
		local state_type = string.match(id, "^([^/]+)")
		local state_name = string.match(id, "([^/]+)$")
		state_name = state_name and string.match(state_name, "(.+)%..+$")

		if not state_type or not state_name then
			return
		end

		local opts = {
			relative = true,
			restore_text = true,
			resize_window = false,
			on_pane_restore = resurrect.tab_state.default_on_pane_restore,
		}

		if state_type == "workspace" then
			local state = resurrect.state_manager.load_state(state_name, "workspace")
			if state.window_states and #state.window_states > 0 then
				opts.spawn_in_workspace = true
				resurrect.workspace_state.restore_workspace(state, opts)
				wezterm.mux.set_active_workspace(state_name)
				resurrect.state_manager.write_current_state(state_name, "workspace")
			end
		elseif state_type == "window" then
			local state = resurrect.state_manager.load_state(state_name, "window")
			if state.tabs and #state.tabs > 0 then
				resurrect.window_state.restore_window(pane:window(), state, opts)
			end
		elseif state_type == "tab" then
			local state = resurrect.state_manager.load_state(state_name, "tab")
			if state.pane_tree then
				resurrect.tab_state.restore_tab(pane:tab(), state, opts)
			end
		end
	end)
end

resurrect.state_manager.change_state_save_dir(resurrect_state_dir)
resurrect.state_manager.set_max_nlines(5000)
resurrect.state_manager.periodic_save({
	interval_seconds = 15 * 60,
	save_workspaces = true,
})

wezterm.on("gui-startup", function()
	local ok = resurrect.state_manager.resurrect_on_gui_startup()
	if not ok then
		resurrect.state_manager.write_current_state(wezterm.mux.get_active_workspace(), "workspace")
	end
end)

wezterm.on("smart_workspace_switcher.workspace_switcher.selected", function()
	save_current_workspace_state()
end)

wezterm.on("smart_workspace_switcher.workspace_switcher.created", function(window, _, label)
	restore_workspace_state(window, label)
end)

wezterm.on("smart_workspace_switcher.workspace_switcher.chosen", function(_, workspace)
	resurrect.state_manager.write_current_state(workspace, "workspace")
end)

wezterm.on("smart_workspace_switcher.workspace_switcher.switched_to_prev", function(_, _, workspace)
	resurrect.state_manager.write_current_state(workspace, "workspace")
end)
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
			prompt = "$E]7;file://localhost/$P$E\\$E[32m$T$E[0m $E[35m$P$E[36m$_$G$E[0m ",
			cwd = "/home/eiat",
		},
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
		name = "my.ssh.server",
		remote_address = "127.0.0.1:22",
		username = "eiat",
		multiplexing = "WezTerm",
		ssh_option = { identityfile = "C:/Users/name/.ssh/id_ed25519" },
		-- If true, connect to this domain automatically at startup
		connect_automatically = false,
		-- When multiplexing == "None", default_prog can be used
		-- to specify the default program to run in new tabs/panes.
		-- Due to the way that ssh works, you cannot specify default_cwd,
		-- but you could instead change your default_prog to put you
		-- in a specific directory.
		default_prog = { "bash", "-l" },
		-- Specify an alternative read timeout
		timeout = 60,
		-- The path to the wezterm binary on the remote host.
		-- Primarily useful if it isn't installed in the $PATH
		-- that is configure for ssh.
		remote_wezterm_path = "/usr/bin/wezterm",
	},
}
-- ------------------------------ Unix Domain Configuration  ---------------------------- --
config.unix_domains = {
	{
		name = "unix",
		skip_permissions_check = true,
		socket_path = "C:\\Users\\Dev\\.local\\share\\wezterm\\unix-mux.sock",
		-- proxy_command = { 'nc', '-U', '/Users/Dev/.local/share/wezterm/sock' },
		local_echo_threshold_ms = 10,
		no_serve_automatically = false,
	},
}
-- -------------------  TLS Domain MUX Domain  --------------------------------------- --
config.tls_clients = {
	{
		-- A handy alias for this session; you will use `wezterm connect server.name`
		-- to connect to it.
		name = "my.tls.server",
		-- The host:port for the remote host
		remote_address = "127.0.0.1:8080",
		-- The value can be "user@host:port"; it accepts the same syntax as the
		-- `wezterm ssh` subcommand.
		bootstrap_via_ssh = "eiat@wsl-ubuntu",
	},
}
-- -------------------  Set Default_Multiplexer_Server_Domain  ----------------------- --
-- config.default_mux_server_domain = "wsl_domains"
-- -------------------  Set Default WSL Domain  ----------------------- --
-- ---------------------- Aesthetic Settings ---------------------------- --
config.color_scheme = "tokyonight"
config.window_background_opacity = 0.98
config.font_size = 13
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.allow_win32_input_mode = false
-- -------------------  TAB BAR CONFIGURATION  ------------------------ --
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = true
-- -----------------   SET WINDOW DECORATIONS   ---------------------- --
config.window_decorations = "RESIZE"
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
	-- Workspace workflow
	{ key = "s", mods = "LEADER", action = workspace_switcher.switch_workspace() },
	{
		key = "S",
		mods = "LEADER|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			save_current_workspace_state()
			window:perform_action(workspace_switcher.switch_to_prev_workspace(), pane)
		end),
	},
	{
		key = "S",
		mods = "LEADER|CTRL",
		action = wezterm.action_callback(function()
			save_current_workspace_state()
		end),
	},
	{
		key = "R",
		mods = "LEADER|SHIFT",
		action = wezterm.action_callback(function(win, pane)
			restore_saved_state(win, pane)
		end),
	},
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
		key = "E",
		mods = "CTRL|SHIFT",
		action = act.PromptInputLine({
			description = "Enter new name for tab",
			initial_value = "My Tab Name",
			action = wezterm.action_callback(function(window, pane, line)
				-- line will be `nil` if they hit escape without entering anything
				-- An empty string if they just hit enter
				-- Or the actual line of text they wrote
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
}
tabline.setup({
	options = {
		icons_enabled = true,
		theme = "Catppuccin Mocha",
		tabs_enabled = true,
		theme_overrides = {},
		section_separators = {
			left = wezterm.nerdfonts.pl_left_hard_divider,
			right = wezterm.nerdfonts.pl_right_hard_divider,
		},
		component_separators = {
			left = wezterm.nerdfonts.pl_left_soft_divider,
			right = wezterm.nerdfonts.pl_right_soft_divider,
		},
		tab_separators = {
			left = wezterm.nerdfonts.pl_left_hard_divider,
			right = wezterm.nerdfonts.pl_right_hard_divider,
		},
	},
	sections = {
		tabline_a = { "mode" },
		tabline_b = { "workspace" },
		tabline_c = { " " },
		tab_active = {
			"index",
			--			{ "parent", padding = 0 },
			--			"/",
			{ "cwd", padding = { left = 0, right = 1 } },
			{ "zoomed", padding = 0 },
		},
		tab_inactive = { "index", { "process", padding = { left = 0, right = 1 } } },
		tabline_x = { "ram" },
		tabline_y = { "" },
		tabline_z = { "domain" },
	},
	extensions = { "resurrect", "smart_workspace_switcher" },
})

launch_menu = launch_menu
config.mouse_bindings = mouse_bindings
config.keys = keys

return config
