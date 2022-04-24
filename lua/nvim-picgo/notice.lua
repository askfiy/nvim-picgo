M = {}

M.success = function(message)
    vim.notify(message, "info", {title = "nvim-picgo"})
end

M.failed = function(message)
    vim.notify(message, "error", {title = "nvim-picgo"})
end

M.warning = function(message)
    vim.notify(message, "warn", {title = "nvim-picgo"})
end

return M
