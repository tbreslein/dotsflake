local M = {}

function M.find_root(additional_markers)
  local markers = { ".git/" }
  vim.list_extend(markers, additional_markers)
  return vim.fs.dirname(vim.fs.find(markers, { upward = true }))
end

return M
