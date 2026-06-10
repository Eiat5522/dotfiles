local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()
local is_wsl = wezterm.running_under_wsl()
local local_domain = { DomainName = "local" }
local tls_domain_name = "local-tls"
local tls_cert_dir = wezterm.home_dir .. "/.local/share/wezterm/tls"

local function file_exists(path)
	local handle = io.open(path, "r")
	if handle then
		handle:close()
		return true
	end

	return false
end

local have_tls_certs = file_exists(tls_cert_dir .. "/server.pem")
	and file_exists(tls_cert_dir .. "/server.key")
	and file_exists(tls_cert_dir .. "/client.pem")
	and file_exists(tls_cert_dir .. "/client.key")
	and file_exists(tls_cert_dir .. "/ca.pem")

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
			args = { "bash", "-lc", command },
			domain = local_domain,
			position = { x = 100, y = 50 },
		}),
		pane
	)
end
-- ----------------------- My Configuration Starts Here  ------------------------------ --
config.default_domain = "local"
-- Keep the TLS mux domain available for manual attach, but don't auto-connect
-- it during GUI startup.
-- ------------------------------------------------------------------------------------ --
config.default_prog = { "bash", "-l" }
-- -------------------- ---- MULTIPLEXER SERVER DOMAINS  ------------------------------ --
-- ------------------------- SSH Domains Configuration  ------------------------------- --
config.ssh_domains = wezterm.default_ssh_domains()
for _, dom in ipairs(config.ssh_domains) do
	dom.assume_shell = "Posix"
	if type(dom.remote_address) == "string" and dom.remote_address:match(":22$") then
		dom.remote_address = dom.remote_address:gsub(":22$", ":2222")
		dom.ssh_option = dom.ssh_option or {}
		dom.ssh_option.port = "2222"
	end
end
-- ------------------------  SSH Server Configuration  -------------------------------  --

-- -----------------------------  TLS Server  ----------------------------------------  --
--[[if have_tls_certs then
	config.tls_servers = {
		{
			bind_address = "127.0.0.1:8080",
			pem_private_key = tls_cert_dir .. "/server.key",
			pem_cert = tls_cert_dir .. "/server.pem",
			pem_ca = tls_cert_dir .. "/ca.pem",
		},
	}}
else
	-- bootstrap_via_ssh can provision certs dynamically, so only bind_address is needed here.
  ]]
config.tls_servers = {
	{
		bind_address = "127.0.0.1:8080",
	},
}
-- end
-- --------------------    MUX Server Configuration  ---------------------------------  --
config.default_mux_server_domain = "local"
-- ------------------------- UI Settings ---------------------------------------------- --
config.color_scheme = "tokyonight"
config.window_background_opacity = 0.98
config.font_size = 14
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.allow_win32_input_mode = false
-- ------------------------  TAB BAR CONFIGURATION  ----------------------------------- --
config.enable_tab_bar = true
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = false
-- -----------------   SET WINDOW DECORATIONS   --------------------------------------- --
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
-- -------------- INTEGRATED TITLE BAR BUTTONS STYLE ---------------------------------- --
-- ---------------  "Windows or  Gnome" -- Selectable Choice  ------------------------- --
config.integrated_title_button_style = "Gnome"
config.integrated_title_buttons = { "Hide", "Maximize", "Close" }
config.integrated_title_button_alignment = "Right"
config.integrated_title_button_color = "Auto"
-- ------------------------- CURSOR SETTINGS ------------------------------------------ --
config.default_cursor_style = "BlinkingBlock"
config.cursor_blink_rate = 500
config.underline_thickness = "2px"
-- --------------------------------  Extras  ------------------------------------------ --
config.enable_scroll_bar = true
config.hide_mouse_cursor_when_typing = true
-- ----------------------------  QUALITY OF LIFE  ------------------------------------- --
config.audible_bell = "SystemBeep"
config.warn_about_missing_glyphs = true
config.enable_wayland = true
-- ------------------------------------------------------------------------------------ --
-- -----------------------------  Mouse Binding  -------------------------------------- --
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
-- ---------------------------------------- Custom Key Binding ------------------------------------------- --
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 2000 } -- CTRL+a as a "leader key" like tmux

local keys = {
	-- Pane splits (using current pane's domain and CWD)
	{ key = "/", mods = "CTRL|ALT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = ".", mods = "CTRL|ALT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	-- Split panes in different directions with CTRL|ALT + ArrowKey
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
	{
		key = "A",
		mods = "LEADER|SHIFT",
		action = act.AttachDomain(tls_domain_name),
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

config.mouse_bindings = mouse_bindings
config.keys = keys

return config
