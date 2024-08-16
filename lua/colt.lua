M = {}

function M.config(cfg)
    local default_config = {
        shell = "sh",
    }

    if cfg == nil or cfg == {} then
        cfg = default_config
    end

    return cfg
end

-- setup {{{
function M.trigger(opts)
    local qf = require("quickfix").qf
    local run = require("run").run
	local time = os.date("%H:%M:%S")
	if opts == nil then
		opts = {}
	end
	local ft = opts.filetype or vim.bo.filetype
	local exe = opts.work or "run"
	local window = opts.window or "t"
	local silent = opts.silent or nil

	local builtin = true
	if opts.builtin == nil then
		builtin = true
	else
		builtin = opts.builtin
	end

	-- all commands {{{
	local function all_commands()
		local src_name = ''
		local out_name = ''
		if exe ~= 'compile' then
			src_name = vim.fn.expand('%:p')
			out_name = vim.fn.expand('%:p:r')
		else
			src_name = vim.fn.expand('%')
			out_name = vim.fn.expand('%:r')
		end

		local cmd = {
			run = {
				python = 'python3 '..src_name,
				lua = 'lua '..src_name,
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
				c = string.format('gcc -s %s -o %s', src_name, out_name),
				cpp = string.format('g++ -s %s -o %s', src_name, out_name),
				rust = string.format('rustc %s -o %s', src_name, out_name),
				go = string.format('go build -o %s %s', out_name, src_name),

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
				c = string.format('gcc -g -Wall %s -o %s', src_name, out_name),
				cpp = string.format('g++ -g -Wall %s -o %s', src_name, out_name),
				rust = string.format('rustc %s -o %s', src_name, out_name),
				go = 'CGO_DISABLED=0 GOOS=linux go build .',

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

		if cmd[exe][ft] ~= nil then
			return tostring(cmd[exe][ft])
		else
			if exe == 'run' then
                vim.print(exe..": "..src_name)
			else
                vim.print(exe..": "..src_name)
			end
		end
	end
	-- }}}
	if ft == nil or ft == "" then
		vim.notify("no filetype is specified for trigger()",
			        3, {title = "trigger()"})
		return 289
	end
	local command = all_commands()

	if command == nil then
		vim.notify(string.format("%s [%s]: %s <%s> %s", time, exe,
			        "no command is defined for", ft, "filetype"),
			        3, {title = "trigger()"})
		return 1
	end

	-- error(command)

	if exe == "run" then
		run(command, {builtin = builtin, window = window})
	else
		qf(command, {prompt = exe, silent = silent})
	end
end
-- }}}

return M
