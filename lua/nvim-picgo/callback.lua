local notice = require("nvim-picgo.notice")

M = {}

function M.yank_to_clipboard(url)
    notice.success("Uploaded image successfully")
    local markdown_link = "![](" .. url .. ")"
    vim.fn.setreg(vim.v.register, markdown_link)
end

function M.assert_error(err)
    assert(not err, err)
end

return M
