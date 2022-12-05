-- Author：askfiy
-- Updated: 2022-05-26

local nvim_picgo = {}

local default_config = {
    notice = "notify",
    image_name = false,
    debug = false,
}

local stop_jobs_message = {
    "%[PicGo WARN%]: can't get",
    -- Well, I did forget the full command for these 2 strings, but this will also match
    -- just doesn't look pretty ..
    "%[PicGo ERROR%]",
    "does not exist",
}

local function notice(state)
    if state then
        local msg = "Upload image success"
        if default_config.notice == "notify" then
            vim.notify(msg, "info", { title = "Nvim-picgo" })
        else
            vim.api.nvim_echo({ { msg, "MoreMsg" } }, true, {})
        end
    else
        local msg = "Upload image failed"
        if default_config.notice == "notify" then
            vim.notify(msg, "error", { title = "Nvim-picgo" })
        else
            vim.api.nvim_echo({ { msg, "ErrorMsg" } }, true, {})
        end
    end
end

local function callbackfn(job_id, data, _)
    if default_config.debug then
        vim.pretty_print(data)
    end

    for _, err in ipairs(stop_jobs_message) do
        if data[1]:match(err) then
            notice(false)
            vim.fn.jobstop(job_id)
            return
        end
    end

    if data[1]:match("%[PicGo SUCCESS%]:") then
        notice(true)
        local markdown_image_link
        if default_config.image_name then
            markdown_image_link = string.format("![%s](%s)", vim.fn.fnamemodify(data[2], ":t:r"), data[2])
        else
            markdown_image_link = string.format("![](%s)", data[2])
        end
        vim.fn.setreg(vim.v.register, markdown_image_link)
    end
end

function nvim_picgo.setup(conf)
    if vim.fn.executable("picgo") ~= 1 then
        vim.api.nvim_echo({ { "Missing picgo-core dependencies", "ErrorMsg" } }, true, {})
        return
    end
    default_config = vim.tbl_extend("force", default_config, conf or {})

    -- Create autocommand
    vim.api.nvim_create_user_command(
        "UploadClipboard",
        nvim_picgo.upload_clipboard,
        { desc = "Upload image from clipboard to picgo" }
    )
    vim.api.nvim_create_user_command(
        "UploadImagefile",
        nvim_picgo.upload_imagefile,
        { desc = "Upload image from filepath to picgo" }
    )
end

function nvim_picgo.upload_clipboard()
    vim.fn.jobstart({ "picgo", "u" }, {
        on_stdout = callbackfn,
    })
end

function nvim_picgo.upload_imagefile()
    local image_path = vim.fn.input("Image path: ")

    -- If the user logs out
    if string.len(image_path) == 0 then
        return
    end

    -- Well, picgo-core doesn't support ~ relative path commits
    -- So here replace ~ with $HOME
    if image_path:find("~") then
        local home_dir = vim.fn.trim(vim.fn.shellescape(vim.fn.fnamemodify("~", ":p")), "'")
        image_path = home_dir .. image_path:sub(3)
    end

    assert(vim.fn.filereadable(image_path) == 1, "The image path is not valid")

    vim.fn.jobstart({ "picgo", "u", image_path }, {
        on_stdout = callbackfn,
    })
end

return nvim_picgo
