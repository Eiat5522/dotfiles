local wezterm = require("wezterm")
local mux = wezterm.mux
local act = wezterm.action
local wsl_domains = wezterm.default_wsl_domains()

local function load_remote_plugin(url, name)
	local ok, plugin = pcall(wezterm.plugin.require, url)
	if not ok then
		wezterm.log_warn("Failed to load remote plugin '" .. name .. "': " .. tostring(plugin))
		return nil
	end
	return plugin
end

local tabline = load_remote_plugin("https://github.com/michaelbrusegard/tabline.wez", "tabline.wez")
local toggle_terminal = load_remote_plugin("https://github.com/zsh-sage/toggle_terminal.wez", "toggle_terminal.wez")
local plugin_root = wezterm.home_dir .. "/.config/wezterm/plugin"

local function load_local_plugin(name)
	local plugin_lua_path = plugin_root .. "/" .. name .. "/plugin/?.lua"
	local plugin_init_path = plugin_root .. "/" .. name .. "/plugin/?/init.lua"
	package.path = package.path .. ";" .. plugin_lua_path .. ";" .. plugin_init_path

	local ok, plugin = pcall(dofile, plugin_root .. "/" .. name .. "/plugin/init.lua")
	if not ok then
		wezterm.log_warn("Failed to load local plugin '" .. name .. "': " .. tostring(plugin))
		return nil
	end
	return plugin
end

local agent_deck = load_local_plugin("wezterm-agent-deck")
local wezterm_sync = load_local_plugin("wezterm-sync")
-- Allow working with both the current release and the nightly
local config = {}
if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.default_prog = { "wsl.exe", "-d", "Ubuntu-24.04", "--cd", "~", "bash", "-l" }
config.default_domain = 'WSL:Ubuntu-24.04'

local function open_cht_sh(window, pane, line)
	if not line then
		return
	end

	local query = line:match("^%s*(.-)%s*$")
	local command = "cht.sh --shell=bash --mode=auto"
	if query ~= "" then
		command = command .. " " .. string.format("%q", query)
	end

	window:perform_action(
		act.SpawnCommandInNewWindow({
			label = query ~= "" and ("cht.sh: " .. query) or "cht.sh",
			args = { "bash", "-l", "-c", command },
			domain = "local",
			position = { x = 100, y = 50 },
		}),
		pane
	)
end

-- Custom Launcher Menu
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
		args = { "wsl.exe", "-d", "Ubuntu-24.04", "--cd", "~", "bash", "-l" },
	},
}

wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

-- set default wsl_domains
for idx, dom in ipairs(wsl_domains) do
	if dom.distribution == "Ubuntu-24.04" then
		dom.username = "eiat"
		dom.default_cwd = "/home/eiat/"
		dom.default_prog = { "bash" }
	end
end

-- set unix_domains
config.unix_domains = {
	{
		name = "unix",
		local_echo_threshold_ms = 10,
	},
}

local ssh_domains = {}

for host in pairs(wezterm.enumerate_ssh_hosts()) do
	table.insert(ssh_domains, {
		-- the name can be anything you want; we're just using the hostname
		name = host,
		-- remote_address must be set to `host` for the ssh config to apply to it
		remote_address = host,
		-- if you don't have wezterm's mux server installed on the remote
		-- host, you may wish to set multiplexing = "None" to use a direct
		-- ssh connection that supports multiple panes/tabs which will close
		-- when the connection is dropped.
		multiplexing = "WezTerm",
		-- if you know that the remote host has a posix/unix environment,
		-- setting assume_shell = "Posix" will result in new panes respecting
		-- the remote current directory when multiplexing = "None".
		assume_shell = "Posix",
		-- Whether agent auth should be disabled.
		-- Set to true to disable it.
		no_agent_auth = false,
		-- Specify an alternative read timeout
		timeout = 60,
		-- The path to the wezterm binary on the remote host
		remote_wezterm_path = "/home/eiat/.local/opt/wezterm-20260610-150805-891bed31/usr/bin/wezterm",
	})
end

config.tls_clients = {
	{
		-- The name of this specific domain.  Must be unique amongst
		-- all types of domain in the configuration file.
		name = "server.name",
		-- If set, use ssh to connect, start the server, and obtain
		-- a certificate.
		-- The value is "user@host:port", just like "wezterm ssh" accepts.
		bootstrap_via_ssh = "eiat@127.0.0.1:2222",
		-- identifies the host:port pair of the remote server.
		remote_address = "wsl-ubuntu:8080",
		accept_invalid_hostnames = false,
		-- Specify an alternate read timeout
		-- If true, connect to this domain automatically at startup
		connect_automatically = false,
		-- Specify an alternate read timeout
		read_timeout = 60,
		-- Specify an alternate write timeout
		write_timeout = 60,
		-- The path to the wezterm binary on the remote host
		remote_wezterm_path = "/home/eiat/.local/opt/wezterm-20260610-150805-891bed31/usr/bin/wezterm",
		-- Specify the round-trip latency threshold for enabling predictive local echo
		local_echo_threshold_ms = 10,
	},
}
-- When set to true (the default), wezterm will configure the
-- SSH_AUTH_SOCK environment variable for panes spawned in the local domain
config.mux_enable_ssh_agent = true
-- Performance Tuning
config.front_end = "WebGpu"
-- Custom Config
config.color_scheme = "tokyonight"
config.window_background_opacity = 0.98
config.font_size = 13
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.allow_win32_input_mode = true

config.enable_tab_bar = true
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = true

config.window_decorations = "RESIZE"
config.integrated_title_button_style = "Gnome"
config.integrated_title_buttons = { "Hide", "Close" }
config.integrated_title_button_alignment = "Right"
config.integrated_title_button_color = "Auto"

config.default_cursor_style = "BlinkingBlock"
config.cursor_blink_rate = 500
config.underline_thickness = "2px"

config.enable_scroll_bar = true
config.hide_mouse_cursor_when_typing = true
config.audible_bell = "SystemBeep"
config.warn_about_missing_glyphs = true
config.mouse_wheel_scrolls_tabs = true

config.mouse_bindings = {
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = act.OpenLinkAtMouseCursor,
	},
	{
		event = { Down = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = act.Nop,
	},
}

config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 3000 }

config.keys = {
	{ key = "/", mods = "CTRL|ALT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = ".", mods = "CTRL|ALT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

	{ key = "LeftArrow", mods = "CTRL|ALT", action = act.ActivatePaneDirection("Left") },
	{ key = "RightArrow", mods = "CTRL|ALT", action = act.ActivatePaneDirection("Right") },
	{ key = "UpArrow", mods = "CTRL|ALT", action = act.ActivatePaneDirection("Up") },
	{ key = "DownArrow", mods = "CTRL|ALT", action = act.ActivatePaneDirection("Down") },

	{ key = "H", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Left", 3 }) },
	{ key = "L", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Right", 3 }) },
	{ key = "K", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Up", 1 }) },
	{ key = "J", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Down", 1 }) },

	{ key = "w", mods = "CTRL|ALT", action = act.CloseCurrentPane({ confirm = false }) },
	{ key = "x", mods = "CTRL|ALT", action = act.CloseCurrentPane({ confirm = false }) },
	{ key = "x", mods = "LEADER", action = act.CloseCurrentTab({ confirm = true }) },

	{ key = "t", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "Tab", mods = "CTRL", action = act.ActivateTabRelative(1) },
	{ key = "Tab", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },

	{ key = "p", mods = "CTRL|SHIFT", action = act.ActivateCommandPalette },
	{
		key = "l",
		mods = "CTRL|ALT",
		action = act.ShowLauncherArgs({ flags = "FUZZY|LAUNCH_MENU_ITEMS|DOMAINS|TABS|WORKSPACES" }),
	},

	{ key = "a", mods = "LEADER|CTRL", action = act.SendKey({ key = "a", mods = "CTRL" }) },
	{ key = "d", mods = "CTRL|SHIFT", action = act.DetachDomain("CurrentPaneDomain") },
	{ key = "s", mods = "CTRL|SHIFT", action = act.AttachDomain("CurrentPaneDomain") },

	{
		key = "Y",
		mods = "CTRL|SHIFT",
		action = act.SpawnCommandInNewWindow({
			label = "Open Navi",
			args = { "navi" },
			cwd = "/home/eiat",
			domain = "CurrentPaneDomain",
			position = { x = 300, y = 500 },
		}),
	},

	{
		key = "C",
		mods = "LEADER|SHIFT",
		action = act.SpawnCommandInNewWindow({
			label = "Open Wezterm Config",
			args = { "bash", "-c", '$EDITOR "/mnt/c/Users/Dev/.wezterm.lua"' },
			domain = "CurrentPaneDomain",
			position = { x = 300, y = 500 },
		}),
	},
	{
		key = "B",
		mods = "LEADER|SHIFT",
		action = act.SpawnCommandInNewWindow({
			label = "Open btop",
			args = { "bash", "-c", "$EDITOR '/mnt/c/Users/Dev/.wezterm.lua'" },
			domain = "CurrentPaneDomain",
			position = { x = 300, y = 500 },
		}),
	},
	{
		key = "E",
		mods = "CTRL|SHIFT",
		action = act.PromptInputLine({
			description = "Enter new name for tab",
			initial_value = "My Tab Name",
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
	{
		key = "H",
		mods = "CTRL|SHIFT",
		action = act.PromptInputLine({
			description = "Enter package or library for cht.sh",
			action = wezterm.action_callback(function(window, pane, line)
				open_cht_sh(window, pane, line)
			end),
		}),
	},
}

if agent_deck then
	agent_deck.apply_to_config(config, {
		update_interval = 1000,
		notifications = {
			enabled = true,
			on_waiting = true,
			on_finished = true,
		},
	})
end

if wezterm_sync then
	wezterm_sync.apply_to_config(config)
end

if tabline then
	local ok, err = pcall(tabline.setup, {
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
	if not ok then
		wezterm.log_warn("Failed to initialize tabline.wez: " .. tostring(err))
	end
end

if toggle_terminal then
	local ok, err = pcall(toggle_terminal.apply_to_config, config, {
		key = ";",
		mods = "CTRL|SHIFT",
		direction = "Up",
		size = { Percent = 20 },
		change_invoker_id_everytime = false,
		zoom = {
			auto_zoom_toggle_terminal = false,
			auto_zoom_invoker_pane = true,
			remember_zoomed = true,
		},
	})
	if not ok then
		wezterm.log_warn("Failed to initialize toggle_terminal.wez: " .. tostring(err))
	end
end

-- Register your event listener directly on the 'wezterm' module
wezterm.on("update-status", function(window, pane)
	local meta = pane:get_metadata() or {}
	local overrides = window:get_config_overrides() or {}
	-- Display mux latency in the right status area
	if meta.is_tardy then
		local secs = meta.since_last_response_ms / 1000.0
		window:set_right_status(string.format("tardy: %5.1fs⏳", secs))
	else
		--  change the color scheme to exaggerate when a password is being input
		if meta.password_input then
			overrides.color_scheme = "Red Alert"
		else
			overrides.color_scheme = nil
		end
		window:set_config_overrides(overrides)
	end
end)

config.wsl_domains = wsl_domains

return config
