local cache_file = vim.fn.stdpath("cache") .. "/konfig.nvim.cache"
local cache = {}

---@class Config
local config = {}

local function load_cache()
	local f = io.open(cache_file, "r")
	if f then
		for line in f:lines() do
			local cwd, allow = line:match("^(.-)=(%a+)$")
			cache[cwd] = allow == "true"
		end
		f:close()
	end
end

local function save_cache()
	local f = io.open(cache_file, "w")
	for cwd, allow in pairs(cache) do
		f:write(cwd .. "=" .. tostring(allow) .. "\n")
	end
	f:close()
end

local function prompt_for_permission(cwd)
	if cache[cwd] ~= nil then
		return cache[cwd]
	end

	local choice = vim.fn.input("Load local config from " .. cwd .. "? (y/n): ")
	local allow = choice:lower():sub(1, 1) == "y"
	cache[cwd] = allow
	save_cache()
	return allow
end

local function load_local_config()
	local cwd = vim.fn.getcwd()
	local local_config_path = cwd .. "/.nvim"

	load_cache()

	if vim.loop.fs_stat(local_config_path) and prompt_for_permission(cwd) then
		-- Load all Lua files from the local config directory.
		local lua_files = vim.fn.glob(local_config_path .. "/*.lua", false, true)
		for _, file in ipairs(lua_files) do
			pcall(dofile, file)
		end

		-- Optionally, also load Vimscript files.
		local vim_files = vim.fn.glob(local_config_path .. "/*.vim", false, true)
		for _, file in ipairs(vim_files) do
			vim.cmd("source " .. file)
		end
	end
end

---@class Konfig
local M = {}

---@type Config
M.config = config

---@param opts Config?
M.setup = function(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})

	vim.api.nvim_create_autocmd({ "UiEnter" }, {
		callback = load_local_config,
	})

	vim.api.nvim_create_user_command("KonfigReload", function()
		load_local_config()
	end, { desc = "Reloads the local configuration" })

	vim.api.nvim_create_user_command("KonfigAllow", function()
		load_cache()
		local cwd = vim.fn.getcwd()
		cache[cwd] = true
		save_cache()
	end, { desc = "Explicitly allows loading configuration in this directory" })

	vim.api.nvim_create_user_command("KonfigDisallow", function()
		load_cache()
		local cwd = vim.fn.getcwd()
		cache[cwd] = false
		save_cache()
	end, { desc = "Explicitly disallows loading configuration in this directory" })
end

M.load_local_config = load_local_config

return M
