vim.api.nvim_create_user_command("DailyNote", function()
	local date = os.date("%Y-%m-%d")
	local filename = "daily/" .. date .. ".md"
	vim.cmd("edit " .. filename)
end, {})
