local luv = vim.loop

local errs = require("nvim-picgo.error")

M = {}

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
            function(err, data)
                assert(not err, err)

                if data then
                    -- failed
                    for _, e in ipairs(errs) do
                        if data:find(e) then
                            stdio[2]:read_stop()
                            reject(data)
                        end
                    end

                    -- success
                    local ss, sf = data:find("SUCCESS")
                    if ss then
                        local url = vim.fn.trim(string.sub(data, sf + 3))
                        resolve(url)
                    end
                end
            end
        )
    )
end

return M
