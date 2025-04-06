Now(function()
  Add("linrongbin16/lsp-progress.nvim")
  local lsp_progress = require("lsp-progress")
  lsp_progress.setup({
    -- max_size = 20,
    client_format = function(client_name, spinner, series_messages)
      return #series_messages > 0 and ("[" .. client_name .. "] " .. spinner) or nil
    end,
    format = function(client_messages)
      -- icon: nf-fa-gear \uf013
      local sign = " "
      if #client_messages > 0 then
        return sign .. " " .. table.concat(client_messages, " ")
      end
      if #require("lsp-progress.api").lsp_clients() > 0 then
        return sign
      end
      return ""
    end,
  })

  Statusline = {}
  local filepath = function()
    local fpath = vim.fn.fnamemodify(vim.fn.expand("%"), ":.")
    if fpath == "" or fpath == "." then
      return " "
    end
    return string.format(" %%<%s", fpath) .. "%m | "
  end

  local lsp = function()
    local count = {}

    count["errors"] = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
    count["warnings"] = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
    count["hints"] = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
    count["info"] = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })

    local err_string = ""

    if count["errors"] ~= 0 then
      err_string = err_string .. " %#LspDiagnosticsSignError#" .. vim.g.diag_symbol_error .. " " .. count["errors"]
    end
    if count["warnings"] ~= 0 then
      err_string = err_string .. " %#LspDiagnosticsSignWarning#" .. vim.g.diag_symbol_warn .. " " .. count["warnings"]
    end
    if count["hints"] ~= 0 then
      err_string = err_string .. " %#LspDiagnosticsSignHint#" .. vim.g.diag_symbol_hint .. " " .. count["hints"]
    end
    if count["info"] ~= 0 then
      err_string = err_string .. " %#LspDiagnosticsSignInformation#" .. vim.g.diag_symbol_info .. " " .. count["info"]
    end

    if #err_string > 0 then
      err_string = err_string .. "%#Normal#" .. " | "
    end
    return err_string .. lsp_progress.progress()
  end

  Statusline.active = function()
    return table.concat({
      filepath(),
      lsp(),
      "%=%P | %l:%c ",
    })
  end

  vim.api.nvim_exec2(
    [[
    augroup Statusline
    au!
    au WinEnter,BufEnter * setlocal statusline=%!v:lua.Statusline.active()
    augroup END
  ]],
    {}
  )

  vim.api.nvim_create_augroup("lualine_augroup", { clear = true })
  vim.api.nvim_create_autocmd("User", {
    group = "lualine_augroup",
    pattern = "LspProgressStatusUpdated",
    callback = function()
      vim.cmd("redrawstatus")
    end,
  })
end)
