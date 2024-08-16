M = {}

-- qf 
function M.qf(command, opts)
	local time = os.date("%H:%M:%S")
	if opts == nil then
		opts = {}
	end
	local prompt = opts.prompt or 'qf'
	local silent = opts.silent or true
	local cmd = ''

	if command == nil then
		vim.notify("_quickfix() at least needs an argument <string> to execute",
			        3, {title = "_quickfix()"})
		return 238
	end
	-- for jumping to error right after execution, remove `get`
	-- -- `cgetexpr` -> `cexpr`
	if silent then
		cmd = string.format(":cgetexpr system('%s')", command)
	else
		cmd = string.format(":cexpr system('%s')", command)
	end
	vim.api.nvim_command(cmd)
	if vim.v.shell_error ~= 0 then
		vim.notify(string.format("%s Error [%s] \"%s\" [Returned %s]",
			                      time,
			                      prompt,
			                      string.gsub(command, "\n", ""),
			                      vim.v.shell_error
								), 3)
	else
		vim.notify(string.format("%s [%s] \"%s\"", time, prompt, string.gsub(command, "\n", "")), 2)
	end
	if prompt == "debug" then
		vim.api.nvim_command("copen")
	end
end


return M
