-- --------------- Add Yazi Plug in to this file ----------------- --
-- ----------------------- Full Boarder -------------------------- --
require("full-border"):setup {
	-- Available values: ui.Border.PLAIN, ui.Border.ROUNDED
	type = ui.Border.ROUNDED,
}
-- ---------------------- Smart Enter ---------------------------- --
require("smart-enter"):setup {
	open_multi = true,
}
-- --------------------- Recycling Bin --------------------------- --
require("recycle-bin"):setup({
  -- Optional: Override automatic trash directory discovery
  -- trash_dir = "~/.local/share/Trash/",  -- Uncomment to use specific directory
})
-- -----------------  Preview Configuration ---------------------- --
Status:children_add(function(self)
	local h = self._current.hovered
	if h and h.link_to then
		return " -> " .. tostring(h.link_to)
	else
		return ""
	end
end, 3300, Status.LEFT)

Status:children_add(function()
	local h = cx.active.current.hovered
	if not h or ya.target_family() ~= "unix" then
		return ""
	end

	return ui.Line {
		ui.Span(ya.user_name(h.cha.uid) or tostring(h.cha.uid)):fg("magenta"),
		":",
		ui.Span(ya.group_name(h.cha.gid) or tostring(h.cha.gid)):fg("magenta"),
		" ",
	}
end, 500, Status.RIGHT)

if os.getenv("NVIM") then
	require("toggle-pane"):entry("min-preview")
end
