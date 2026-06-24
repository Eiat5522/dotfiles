local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.default_mux_server_domain = "local"

config.unix_domains = {
	{
		name = "unix",
		local_echo_threshold_ms = 10,
	},
}

config.tls_servers = {
	{
		bind_address = "127.0.0.1:8083",
	},
}
--[[
config.tls_clients = {
	{
		name = "tls.server",
		bootstrap_via_ssh = "wsl-ubuntu",
		remote_address = "127.0.0.1:8083",
		expected_cn = "wsl-ubuntu",
		read_timeout = 60,
		write_timeout = 60,
		remote_wezterm_path = "/home/eiat/.local/opt/wezterm-20260610-150805-891bed31/usr/bin/wezterm",
		local_echo_threshold_ms = 10,
	},
}
--]]
config.mux_enable_ssh_agent = true

return config
