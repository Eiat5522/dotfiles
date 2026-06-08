# WezTerm Multiplexing Features Implementation Plan

> **For Hermes:** Use subagent-driven-development skill to implement this plan task-by-task.

**Goal:** Configure WezTerm to successfully utilize multiplexing features including persistent sessions, shell integration, TLS domain, SSH domain, and WSL integration.

**Architecture:** Modify the existing WezTerm Lua configuration file to add SSH domains, Unix domains for WSL, TLS clients/servers, enable shell integration, and set up default domain and startup args for persistent multiplexing.

**Tech Stack:** WezTerm Lua configuration, wezterm multiplexing documentation.

---

### Task 1: Backup Current Configuration

**Objective:** Create a backup of the existing WezTerm config before making changes.

**Files:**
- Read: `/home/eiat/.dotfiles/wezterm/.wezterm.lua`
- Create: `/home/eiat/.dotfiles/wezterm/.wezterm.lua.backup-$(date +%Y%m%d_%H%M%S)`

**Step 1: Read current config to verify content**

Run: `cat /home/eiat/.dotfiles/wezterm/.wezterm.lua`
Expected: Should display the current Lua config (as previously seen).

**Step 2: Create backup copy**

Run: `cp /home/eiat/.dotfiles/wezterm/.wezterm.lua /home/eiat/.dotfiles/wezterm/.wezterm.lua.backup-$(date +%Y%m%d_%H%M%S)`
Expected: Backup file created successfully.

**Step 3: Commit backup (if using git)**

Run: `cd /home/eiat/.dotfiles && git add wezterm/.wezterm.lua.backup-$(date +%Y%m%d_%H%M%S) && git commit -m "chore: backup wezterm config before multiplexing changes"`
Expected: Backup committed.

---

### Task 2: Add SSH Domain Configuration

**Objective:** Configure SSH domains for remote multiplexing based on user's SSH hosts.

**Files:**
- Modify: `/home/eiat/.dotfiles/wezterm/.wezterm.lua`

**Step 1: Fetch SSH domain documentation**

Run: `web_extract --urls "https://wezterm.org/multiplexing.html#ssh-domains"` (conceptual; we already have content)
But we can just note we have the docs.

**Step 2: Insert SSH domains configuration after the multiplexer server domains comment**

We'll add a sample SSH domain; user can adjust.

```lua
-- SSH Domains Configuration
config.ssh_domains = {
  {
    name = 'my.remote.host',
    remote_address = 'example.com:22',
    username = 'eiat',
    -- assume_shell = 'Posix', -- optional
  },
}
```

**Step 3: Apply patch to insert after line containing '-- -------------------- ---- MULTIPLEXER SERVER DOMAINS  ------------------------------ --'**

We'll use patch tool with context.

**Step 4: Verify syntax**

Run: `wezterm config-file` (or `luac -p` on the file) to ensure no syntax errors.

Expected: No errors.

**Step 5: Commit changes**

Run: `cd /home/eiat/.dotfiles && git add wezterm/.wezterm.lua && git commit -m "feat: add SSH domain configuration for multiplexing"`
Expected: Changes committed.

---

### Task 3: Configure WSL Unix Domain for Multiplexing

**Objective:** Set up Unix domain socket for WSL integration to enable persistent sessions between Windows host and WSL.

**Files:**
- Modify: `/home/eiat/.dotfiles/wezterm/.wezterm.lua`

**Step 1: Add Unix domain for WSL (host side)**

Insert after SSH domains section.

```lua
-- Unix Domains for WSL Integration
config.unix_domains = {
  {
    name = 'wsl',
    serve_command = { 'wsl', 'wezterm-mux-server', '--daemonize' },
    -- Optional: specify socket path if needed; default is fine.
    -- skip_permissions_check = true, -- may be needed on NTFS
  },
}
```

**Step 2: Set default GUI startup args to connect to WSL domain**

Add line: `config.default_gui_startup_args = { 'connect', 'wsl' }`

**Step 3: Apply patch with appropriate context**

**Step 4: Validate Lua syntax**

Run: `wezterm config-file` (or `luac -p`)

Expected: No syntax errors.

**Step 5: Commit**

Run: `cd /home/eiat/.dotfiles && git add wezterm/.wezterm.lua && git commit -m "feat: add WSL unix domain for persistent multiplexing"`
Expected: Committed.

---

### Task 4: Configure TLS Domain (Client and Server)

**Objective:** Enable TLS-encrypted multiplexing over TCP bootstrapped via SSH.

**Files:**
- Modify: `/home/eiat/.dotfiles/wezterm/.wezterm.lua`

**Step 1: Add TLS client configuration**

Example for a remote server; user can adjust.

```lua
-- TLS Clients for encrypted multiplexing
config.tls_clients = {
  {
    name = 'tls.server.example', -- alias used with `wezterm connect`
    remote_address = 'example.com:8080', -- host:port for TLS traffic
    bootstrap_via_ssh = 'example.com', -- SSH host to launch server
  },
}
```

**Step 2: Ensure TLS server is enabled (already present in config)**

Current config has:
```lua
config.tls_servers = {
  {
    bind_address = "0.0.0.0:8080",
  },
}
```
We may keep as is or adjust.

**Step 3: Insert after unix_domains section**

**Step 4: Validate syntax**

Run: `wezterm config-file`

Expected: No errors.

**Step 5: Commit**

Run: `cd /home/eiat/.dotfiles && git add wezterm/.wezterm.lua && git commit -m "feat: add TLS client/server configuration for encrypted multiplexing"`
Expected: Committed.

---

### Task 5: Enable Shell Integration

**Objective:** Install and configure WezTerm shell integration for OSC sequences, prompt detection, etc.

**Files:**
- Modify: `/home/eiat/.dotfiles/wezterm/.wezterm.lua` (maybe just ensure enabled)
- Possibly run shell integration install script.

**Step 1: Check if shell integration already enabled**

Look for any existing shell integration config; if not, we can rely on default (should be on). According to docs, shell integration is automatic if wezterm is installed via shell integration script.

We'll ensure we run the install script for the shell.

**Step 2: Install shell integration for bash (default_prog)**

Run: `curl -fsSL https://raw.githubusercontent.com/wez/wezterm/main/assets/shell-integration/install.sh | bash`

But we need to be careful; we can instead instruct user to run.

Better: Add a note that user should run `wezterm install-shell-integration --shell bash` inside WSL or host.

Since we cannot modify user's shell rc files directly, we'll provide guidance.

**Step 3: Add config to enable shell integration features (if needed)**

Usually no extra config needed; but we can ensure `allow_win32_input_mode = false` already present.

**Step 4: Validate**

Run: `wezterm config-file` (no change needed)

**Step 5: Commit (if we added any config)**

If we add nothing, skip commit.

We'll add a comment: `-- Shell integration is enabled via install script; ensure you run 'wezterm install-shell-integration' in your shell.`

Insert near top after imports.

**Step 6: Commit comment**

Run: `cd /home/eiat/.dotfiles && git add wezterm/.wezterm.lua && git commit -m "docs: add comment about shell integration installation"`
Expected: Committed.

---

### Task 6: Set Default Domain and Persistent Server Settings

**Objective:** Ensure the default domain is set and the mux server runs daemonized for persistent sessions.

**Files:**
- Modify: `/home/eiat/.dotfiles/wezterm/.wezterm.lua`

**Step 1: Verify existing settings**

Current config has:
```lua
config.default_domain = "local"
config.default_prog = { "bash", "-lc", "wezterm-mux-server", "--daemonized" }
config.default_mux_server_domain = "local"
```
These are already present and appropriate for persistent local mux server.

**Step 2: Possibly adjust to use WSL domain as default if desired**

We could set `config.default_domain = "wsl"` to start in WSL domain.

Decision: Keep as local for flexibility; user can connect via CLI.

We'll leave as is but ensure they are present.

**Step 3: No changes needed; just validate**

Run: `wezterm config-file`

Expected: No errors.

**Step 4: Commit if we added anything (none)**

Skip commit.

---

### Task 7: Validate Configuration and Reload Instructions

**Objective:** Ensure the configuration is correct and provide instructions to test.

**Files:**
- None (just verification)

**Step 1: Run config validation**

Run: `wezterm config-file`
Expected: Output shows effective config without errors.

**Step 2: Restart WezTerm and test**

Instructions for user:
- Press `Ctrl+Shift+R` to reload config, or quit and restart WezTerm.
- Test SSH domain: Run `wezterm connect my.remote.host` (after adjusting name/username).
- Test WSL domain: Run `wezterm connect wsl` or simply start WezTerm (should connect to wsl due to default_gui_startup_args).
- Test TLS domain: Run `wezterm connect tls.server.example` (after setting up server).
- Verify multiplexing: Check that wezterm-mux-server processes are running (`pgrep wezterm-mux-server`).

**Step 3: Provide troubleshooting tips**

If unable to lock pid file (as seen in scenario 3), ensure only one instance runs or delete stale pid file.

**Step 4: Commit final validation script (optional)**

Create a simple validation script in ~/.hermes/scripts/ but not required.

We'll skip.

**End of Plan**
