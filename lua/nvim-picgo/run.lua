local luv = vim.loop

M = {}

local err_keyword = {
    "ERROR",
    "does not exist",
    "can't get"
}

function M.register_task(command, args, resolve, reject)
    local handle

    local stdio = {
        luv.new_pipe(false),
        luv.new_pipe(false),
        luv.new_pipe(false)
    }

    handle =
        luv.spawn(
        command,
        {
            args = args,
            stdio = stdio
        },
        function()
            for _, pipe in ipairs(stdio) do
                pipe:read_stop()
                pipe:close()
            end
            handle:close()
        end
    )

    luv.read_start(
        stdio[2],
        vim.schedule_wrap(
            ---@diagnostic disable-next-line: unused-local
            function(err, data)
                if data then
                    for _, e in ipairs(err_keyword) do
                        if data:find(e) then
                            stdio[2]:read_stop()
                            reject(data)
                        end
                    end
                    local ss, sf = data:find("SUCCESS")
                    if ss then
                        local length = string.len(data)
                        local url = vim.fn.trim(string.sub(data, sf + 3, length))
                        resolve(url)
                    end
                end
            end
        )
    )
end

return M
