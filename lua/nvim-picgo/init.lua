--[[
    A picgo-core based image bed image upload tool written in pure Lua language
]]

local notice = require("nvim-picgo.notice")
local callback = require("nvim-picgo.callback")
local run = require("nvim-picgo.run")

M = {}

M.setup = function()
    local result = vim.fn.system("picgo -v")
    if not result:match("^%d") then
        notice.failed("You have to install picgo-core")
        return
    end
end

M.upload_clipboard = function()
    -- upload image from system clipboard
    run.register_task("picgo", {"u"}, callback.yank_to_clipboard, callback.assert_error)
end

M.upload_imagefile = function()
    -- select image from disk to upload
    vim.fn.inputsave()
    local image_path = vim.fn.input("Input the image path: ")
    vim.fn.inputrestore()

    -- if the user logs out
    if string.len(image_path) == 0 then
        return
    end

    -- picgo-core does not support uploading from the plus directory, so you need to convert the path to an absolute path
    if image_path:find("~") then
        local home_dir = vim.fn.trim(vim.fn.shellescape(vim.fn.fnamemodify("~", ":p")), "'")
        image_path = home_dir .. image_path:sub(3)
    end

    assert(vim.fn.filereadable(image_path) == 1, "The image path is not valid")
    run.register_task("picgo", {"u", image_path}, callback.yank_to_clipboard, callback.assert_error)
end

return M
