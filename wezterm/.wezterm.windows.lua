local wezterm = require("wezterm")
local mux = wezterm.mux
local act = wezterm.action

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

local ai_helper = load_local_plugin("ai-helper.wezterm")
local agent_deck = load_local_plugin("wezterm-agent-deck")
local wezterm_sync = load_local_plugin("wezterm-sync")

local config = wezterm.config_builder()

config.default_domain = "Ubuntu-24.04"
config.default_prog = { "wsl.exe", "-d", "Ubuntu-24.04", "--cd", "~", "--exec", "bash", "-l" }

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
		args = { "wsl.exe", "-d", "Ubuntu-24.04", "--cd", "~", "--exec", "bash", "-l" },
	},
	{
		label = "Open Yazi",
		args = { "wsl.exe", "-d", "Ubuntu-24.04", "--cd", "~", "--exec", "bash", "-lc", "yazi" },
	},
}

wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

config.wsl_domains = {
	{
		name = "Ubuntu-24.04",
		distribution = "Ubuntu-24.04",
		username = "eiat",
		default_cwd = "/home/eiat/",
		default_prog = { "bash", "-l" },
	},
}

config.ssh_domains = {
	{
		name = "SSH:wsl-ubuntu",
		remote_address = "127.0.0.1:2222",
		username = "eiat",
		ssh_option = {
			IdentityFile = "C:/Users/Dev/.ssh/id_ed25519",
			UserKnownHostsFile = "C:/Users/Dev/.ssh/known_hosts",
			IdentitiesOnly = "yes",
			StrictHostKeyChecking = "no",
		},
		connect_automatically = false,
	},
		{
			name = "SSHMUX:wsl-ubuntu",
			remote_address = "127.0.0.1:2222",
		username = "eiat",
		multiplexing = "WezTerm",
		ssh_option = {
			IdentityFile = "C:/Users/Dev/.ssh/id_ed25519",
			UserKnownHostsFile = "C:/Users/Dev/.ssh/known_hosts",
			IdentitiesOnly = "yes",
			StrictHostKeyChecking = "no",
		},
			connect_automatically = false,
			default_prog = { "bash", "-l" },
			timeout = 60,
			remote_wezterm_path = "/home/eiat/.local/bin/wezterm",
		},
	}

config.unix_domains = {
	{
		name = "wsl",
		skip_permissions_check = true,
		-- Start wezterm-mux-server inside WSL2 when connecting.
		-- The mux server uses the WSL-side socket path configured in
		-- wezterm/.wezterm.lua (/mnt/c/Users/Dev/.local/share/wezterm/sock).
		serve_command = {
			"wsl.exe", "-d", "Ubuntu-24.04", "--",
			"wezterm-mux-server", "--daemonize",
		},
		local_echo_threshold_ms = 10,
	},
}

-- Use explicit startup args for mux attach; this is more reliable than
-- relying on default-domain behavior for initial GUI startup.
config.default_gui_startup_args = { "connect", "wsl" }

config.tls_clients = {
	{
		name = "my.tls.server",
		remote_address = "127.0.0.1:8080",
		bootstrap_via_ssh = "eiat@wsl-ubuntu:2222",
	},
}

config.color_scheme = "tokyonight"
config.window_background_opacity = 0.98
config.font_size = 13
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.allow_win32_input_mode = false

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

config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 2000 }

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

	{
		key = "Y",
		mods = "CTRL|SHIFT",
		action = act.SpawnCommandInNewWindow({
			label = "Open Navi",
			args = { "bash", "-l", "navi" },
			cwd = "/home/eiat",
			domain = "CurrentPaneDomain",
			position = { x = 300, y = 300 },
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
}

local google_api_key = os.getenv("GOOGLE_AI_API_KEY")
if ai_helper and google_api_key and google_api_key ~= "" then
	ai_helper.apply_to_config(config, {
		type = "google",
		api_key = google_api_key,
		luarocks_path = "C:/Users/Dev/.local/bin/luarocks",
		keybinding = { key = "i", mods = "CTRL|SHIFT" },
		keybinding_with_pane = { key = "i", mods = "CTRL|SHIFT|ALT" },
		system_prompt = "you are an assistant that specializes in CLI and unix commands. "
			.. "you will be brief and to the point, if asked for commands print them in a way that's easy to copy, "
			.. "otherwise just answer the question. concatenate commands with && or || for ease of use. ",
		timeout = 30,
		show_loading = true,
		share_n_lines = 150,
	})
elseif ai_helper then
	wezterm.log_warn("ai-helper.wezterm loaded, but GOOGLE_AI_API_KEY is not set; skipping ai-helper keybindings")
end

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

return config
