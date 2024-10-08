M = {}

-- run 
function M.run(cmd, opts)
    local time = os.date("%H:%M:%S")
	-- args handling {{{
	if opts == nil then
		opts = {}
	end

	if opts.builtin == nil then
		opts.builtin = false
	end

	if not opts.window or opts.window == nil then
		opts.window = "t"
	end
	-- }}}

	if opts.builtin then
		-- builtin 
		local style = {
			t = "",
			v = "vs ",
			h = "split ",
		}
		if opts.window == "f" then
			-- float_term {{{
			local float_term = function(opt)
				local work, title, c
					work = opt.work
					c = opt.cmd or M.config
					title = opt.title or "Terminal"

				-- create window {{{
				local buf, win
					buf = vim.api.nvim_create_buf(false, true) -- create new emtpy buffer
					win = vim.api.nvim_get_current_win()

				vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

				-- get dimensions {{{
				local width = vim.api.nvim_get_option("columns")
				local height = vim.api.nvim_get_option("lines")
				-- }}}
				-- calculate our floating window size {{{
				local scale = 0.9
				local win_height = math.ceil(height * scale - 4)
				local win_width = math.ceil(width * scale)
				-- }}}
				-- and its starting position {{{
				local row = math.ceil((height - win_height) / 2 - 2)
				local col = math.ceil((width - win_width) / 2)
				-- }}}
				-- border style {{{
				local border_color = "String"
				local borderstyle = {
					ascii = {
						{ "/", border_color },
						{ "-", border_color },
						{ "\\", border_color },
						{ "|", border_color },
					},
					single = {
						{ "┌", border_color },
						{ "─", border_color },
						{ "┐", border_color },
						{ "│", border_color },
						{ "┘", border_color },
						{ "─", border_color },
						{ "└", border_color },
						{ "│", border_color },
					},
					double = {
						{ "╔", border_color },
						{ "═", border_color },
						{ "╗", border_color },
						{ "║", border_color },
						{ "╝", border_color },
						{ "═", border_color },
						{ "╚", border_color },
						{ "║", border_color },
					},
					round = {
						{ "╭", border_color },
						{ "─", border_color },
						{ "╮", border_color },
						{ "│", border_color },
						{ "╯", border_color },
						{ "─", border_color },
						{ "╰", border_color },
						{ "│", border_color },
					},
				}
				-- }}}
				-- settings {{{
				opts = {
					noautocmd = true,
					style = "minimal",
					border = borderstyle.single,
					relative = "editor",
					width = win_width,
					height = win_height,
					row = row,
					col = col
				}
				-- }}}

				vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
				vim.api.nvim_buf_set_option(buf, "filetype", "Terminal")
				vim.api.nvim_win_set_option(win, "winhighlight", "Normal:Normal")
				-- and finally create it with buffer attached
				vim.api.nvim_open_win(buf, true, opts)
				vim.api.nvim_buf_set_option(buf, "bufhidden", "delete")
				-- }}}

				-- run cmd in terminal {{{
				if work == "shell" then
					vim.api.nvim_buf_call(buf, function() vim.cmd("setlocal nornu nonu") end)
					if c then
						vim.api.nvim_buf_call(buf, function() vim.cmd("term " .. c) end)
					else
						vim.api.nvim_buf_call(buf, function() vim.cmd("term") end)
					end
					vim.api.nvim_buf_call(buf, function() vim.cmd("startinsert") end)
				end

				vim.api.nvim_buf_set_name(buf, title)
				-- }}}
			end

			float_term({work = "shell", cmd = cmd})
			-- }}}
		else
			-- others {{{
			local buffercmd = style[opts.window] or "t"
			if buffercmd ~= nil or buffercmd ~= "" then
				vim.api.nvim_command(buffercmd)
			end
			if cmd then
				vim.api.nvim_command("term " .. cmd)
			else
				vim.api.nvim_command("term")
			end
			vim.api.nvim_command("setlocal nornu nonu signcolumn=yes")
			vim.api.nvim_command("startinsert")
			if cmd ~= nil then
				vim.notify(string.format("%s [%s] \"%s\"", time, "run", cmd), 2,
					{title = "run"})
			end
			-- }}}
		end

	else

		-- toggleterm 
		-- custom terminals {{{
		local Term  = require("toggleterm.terminal").Terminal

		-- horizontal terminal {{{
		local terminal_horizontal = function(wrapand)
			local theterm = Term:new({
				direction = "horizontal",
				cmd = wrapand,
			})
			theterm:toggle()
		end
		-- }}}
		-- vertical terminal {{{
		local terminal_vertival = function(wrapand)
			local theterm = Term:new({
				direction = "vertical",
				cmd = wrapand,
			})
			theterm:toggle()
		end
		-- }}}
		-- float terminal {{{
		local terminal_float = function(wrapand)
			local theterm = Term:new({
				direction = "float",
				cmd = wrapand,
				size = 0.1,
			})
			theterm:toggle()
		end
		-- }}}
		-- float terminal {{{
		local terminal_tab = function(wrapand)
			local theterm = Term:new({
				direction = "tab",
				cmd = wrapand,
				-- size = 0.1,
			})
			theterm:toggle()
		end
		-- }}}

		-- }}}
		local style = {
			f = terminal_float,
			v = terminal_vertival,
			h = terminal_horizontal,
			t = terminal_tab,
		}

		-- less code, no if conditions
		-- NOTE: the args must be t, f, h, v else it raise an error
		style[opts.window](cmd)

	end
end

return M
