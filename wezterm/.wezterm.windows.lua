-- Draft WezTerm config with the 401-causing plugin isolated.
-- Main fix: remove/comment ai-helper plugin require until the GitHub/plugin/auth issue is resolved.
-- Security fix: never hard-code API keys in .wezterm.lua; load from environment instead.

local wezterm = require("wezterm")
local mux = wezterm.mux
local act = wezterm.action

local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
local toggle_terminal = wezterm.plugin.require("https://github.com/zsh-sage/toggle_terminal.wez")

-- Temporarily disabled because this require is failing with HTTP 401.
-- local ai_helper = wezterm.plugin.require("https://github.com/Michal1993r/ai-helper.wezterm.wez")

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
		name = "my.ssh.server",
		remote_address = "127.0.0.1:22",
		username = "eiat",
		multiplexing = "WezTerm",
		ssh_option = { identityfile = "C:/Users/name/.ssh/id_ed25519" },
		connect_automatically = false,
		default_prog = { "bash", "-l" },
		timeout = 60,
		remote_wezterm_path = "/usr/bin/wezterm",
	},
}

config.unix_domains = {
	{
		name = "unix",
		skip_permissions_check = true,
		socket_path = "C:\\Users\\Dev\\.local\\share\\wezterm\\unix-mux.sock",
		local_echo_threshold_ms = 10,
		no_serve_automatically = false,
	},
}

config.tls_clients = {
	{
		name = "my.tls.server",
		remote_address = "127.0.0.1:8080",
		bootstrap_via_ssh = "eiat@wsl-ubuntu",
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

-- AI helper should only be re-enabled after the plugin require works again.
-- Also use an env var instead of hard-coding the key:
-- local google_api_key = os.getenv("GOOGLE_AI_API_KEY")
-- if ai_helper and google_api_key then
--   ai_helper.apply_to_config(config, {
--     type = "google",
--     api_key = google_api_key,
--     luarocks_path = "/usr/bin/luarocks",
--     keybinding = { key = "i", mods = "CTRL|SHIFT" },
--     keybinding_with_pane = { key = "I", mods = "CTRL|SHIFT" },
--     system_prompt = "you are an assistant that specializes in CLI and unix commands. "
--       .. "you will be brief and to the point, if asked for commands print them in a way that's easy to copy, "
--       .. "otherwise just answer the question. concatenate commands with && or || for ease of use. ",
--     timeout = 30,
--     show_loading = true,
--     share_n_lines = 150,
--   })
-- end

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

toggle_terminal.apply_to_config(config, {
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

return config
