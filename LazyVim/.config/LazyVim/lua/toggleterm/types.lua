---@meta
-- Types used by toggleterm module so that annotations are recognized by the
-- Lua language server across files. This file contains only annotations and
-- returns an empty table; it is safe to require at runtime by other modules.

---@alias ToggleTermHighlights table<string, table<string, string>>

---@alias Mode "n" | "i" | "?"

---@class Terminal

--- @class Responsiveness
--- @field horizontal_breakpoint number

--- @class WinbarOpts
--- @field name_formatter fun(term: Terminal):string
--- @field enabled boolean

--- @class ToggleTermConfig
--- @field size number
--- @field shade_filetypes string[]
--- @field hide_numbers boolean
--- @field open_mapping string | string[]
--- @field shade_terminals boolean
--- @field insert_mappings boolean
--- @field terminal_mappings boolean
--- @field start_in_insert boolean
--- @field persist_size boolean
--- @field persist_mode boolean
--- @field close_on_exit boolean
--- @field clear_env boolean
--- @field direction  'horizontal' | 'vertical' | 'float'
--- @field shading_factor number
--- @field shading_ratio number
--- @field shell string|fun():string
--- @field auto_scroll boolean
--- @field float_opts table<string, any>
--- @field highlights ToggleTermHighlights
--- @field winbar WinbarOpts
--- @field autochdir boolean
--- @field title_pos 'left' | 'center' | 'right'
--- @field responsiveness Responsiveness

---@class TerminalView
---@field terminals number[]
---@field focus_term_id number

--- @class TerminalWindow
--- @field term_id number
--- @field window number

--- @class TerminalState
--- @field mode Mode

--- @class TermCreateArgs
--- @field newline_chr? string user specified newline chararacter
--- @field cmd? string a custom command to run
--- @field direction? string the layout style for the terminal
--- @field id number?
--- @field highlights ToggleTermHighlights?
--- @field dir string? the directory for the terminal
--- @field count number? the count that triggers that specific terminal
--- @field display_name string?
--- @field hidden boolean?
--- @field close_on_exit boolean?
--- @field auto_scroll boolean?
--- @field float_opts table<string, any>?
--- @field on_stdout fun(t: Terminal, job: number, data: string[]?, name: string?)?
--- @field on_stderr fun(t: Terminal, job: number, data: string[], name: string)?
--- @field on_exit fun(t: Terminal, job: number, exit_code: number?, name: string?)?
--- @field on_create fun(term: Terminal)?
--- @field on_open fun(term: Terminal)?
--- @field on_close fun(term: Terminal)?
--- @field newline_chr string
--- @field cmd string
--- @field direction string
--- @field id number
--- @field bufnr number
--- @field window number
--- @field job_id number
--- @field highlights ToggleTermHighlights
--- @field dir string
--- @field name string
--- @field count number
--- @field hidden boolean
--- @field close_on_exit boolean?
--- @field auto_scroll boolean?
--- @field float_opts table<string, any>?
--- @field display_name string?
--- @field env table<string, string>
--- @field clear_env boolean
--- @field on_stdout fun(t: Terminal, job: number, data: string[]?, name: string?)?
--- @field on_stderr fun(t: Terminal, job: number, data: string[], name: string)?
--- @field on_exit fun(t: Terminal, job: number, exit_code: number?, name: string?)?
--- @field on_create fun(term: Terminal)?
--- @field on_open fun(term: Terminal)?
--- @field on_close fun(term: Terminal)?
--- @field _display_name fun(term: Terminal): string
--- @field __state TerminalState

local M = {}

return M
