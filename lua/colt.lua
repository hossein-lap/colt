M = {}

-- run {{{
function M.run(cmd, opts)

	-- args handling {{{
	if not opts then
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
		-- builtin {{{
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
					c = opt.cmd or "bash"
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
				vim.notify(string.format("[%s]: %s", "run", cmd), 2,
					{title = "run"})
			end
			-- }}}
		end
		-- }}}
	else
		-- toggleterm {{{
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

		-- }}}
	end
end
-- }}}

-- quickfix {{{
function M.quickfix(command, opts)
	if opts == nil then
		opts = {}
	end
	local prompt = opts.prompt or 'wrap'
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
		vim.notify(string.format("[error]: %s: [%s]: %s",
			                      vim.v.shell_error,
			                      prompt,
			                      string.gsub(command, "\n", "")
					), 3)
	else
		vim.notify(string.format("[%s]: %s", prompt, string.gsub(command, "\n", "")), 2)
	end
	if prompt == "debug" then
		vim.api.nvim_command("copen")
	end
end
-- }}}

-- setup {{{
function M.setup(opts)
	local ft = opts.filetype or vim.bo.filetype
	local exe = opts.work or "run"
	local window = opts.window or "t"
	local builtin = opts.builtin or true
	local silent = opts.silent or nil

	-- all commands {{{
	local command = function()
		local output = opts.exe
		local src_name = ''
		local out_name = ''
		if output ~= 'compile' then
			src_name = vim.fn.expand('%:p')
			out_name = vim.fn.expand('%:p:r')
		else
			src_name = vim.fn.expand('%')
			out_name = vim.fn.expand('%:r')
		end

		local cmd = {
			run = {
				python = 'python3 '..src_name,
				lua = 'lua5.4 '..src_name,
				javascript = 'node '..src_name,
				c = out_name,
				cpp = out_name,
				rust = out_name,
				go = out_name,
				sent = 'sent '..src_name,
				-- text = 'sent '..src_name,
				perl = 'perl '..src_name,
				-- markdown = string.format('pandoc %s %s -o %s.pdf',
				-- 	        pandoc_path, src_name, out_name),
				nroff = string.format('groff %s %s > %s.pdf',
							src_name, '-m me -keUs -Tpdf', out_name), -- -egGjkpRstU
				rmd = string.format([[Rscript -e "%s(input='%s', %s)"]],
							'rmarkdown::render', src_name,
							"output_format='pdf_document'")
			},
			compile = {
				-- programs
				c = string.format('gcc %s -o %s', src_name, out_name),
				cpp = string.format('g++ %s -o %s', src_name, out_name),
				rust = string.format('rustc %s -o %s', src_name, out_name),
				go = 'go build '..src_name,

				-- documents
				nroff = string.format('pdfroff -U -mspdf %s > %s.pdf', src_name,
							out_name),
				tex = 'xelatex ' .. src_name,
				markdown = string.format('pandoc %s -o %s.pdf',
										 src_name, out_name),
				rmd = string.format([[Rscript -e \"%s(input='%s', %s)\"]],
							'rmarkdown::render', src_name,
							"output_format='all'")
			},
			debug = {
				c = string.format('gcc -Wall %s -o %s', src_name, out_name),
				cpp = string.format('g++ -Wall %s -o %s', src_name, out_name),
				rust = string.format('rustc %s -o %s', src_name, out_name),
				go = 'go build '..src_name,

				-- documents
				nroff = string.format('pdfroff -Wall -U -mspdf %s > %s.pdf',
							src_name, out_name),
				tex = 'xelatex '..src_name,
				-- markdown = string.format('pandoc %s %s -o %s.pdf',
				-- 	        beamer_args, src_name, out_name),
				rmd = string.format([[%s(input='%s', %s)\"]],
							[[Rscript -e \"rmarkdown::render]], src_name,
							[[output_format = 'all']])
			}
		}

		-- WIP
		if opts.extra_cmd then
			cmd = vim.tbl_extend("force", cmd, opts.extra_cmd)
		end

		if cmd[output][ft] ~= nil then
			return tostring(cmd[output][ft])
		else
			if output == 'run' then
				return src_name
			else
				return nil
			end
		end
	end
	-- }}}

	if command == nil then
		vim.notify(string.format("[%s]: %s <%s> %s", exe,
			        "no command is defined for", ft, "filetype"),
			        3, {title = "wrapcmd()"})
		return 1
	end
	if command == nil then
		vim.notify("no filetype is specified for wrapcmd()",
			        3, {title = "wrapcmd()"})
		return 289
	end

	if exe == "run" then
		M.run(command, {builtin = builtin, window = window})
	else
		M.quickfix(command, {prompt = exe, silent = silent})
	end
end
-- }}}

return M
