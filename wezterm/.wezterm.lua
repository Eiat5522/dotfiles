local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.default_mux_server_domain = "local"

config.unix_domains = {
	{
		name = "unix",
		local_echo_threshold_ms = 10
	},
}

config.tls_servers = {
	{
		bind_address = "wsl-ubuntu:8080",
		local_echo_threshold_ms = 10 
	},
}

return config
