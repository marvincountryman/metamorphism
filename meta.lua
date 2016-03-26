local shell_path_in  = "shell.source.lua"
local shell_path_out = "shell.lua"

local operators = {
    "(", ")", ".", "%", "^", "-", "+", "=", "{", "}",
    ",", "/", "\\", ";", "*"
}

function read(path)
    local data
    local file

    file = assert(io.open(path, "r"))
    data = file:read("*a")

    file:close()

    return data
end
function write(path, data)
    local file

    file = assert(io.open(path, "w+"))
    file:write(data)
    file:close()
end
function sleep(seconds)
    local time  = os.clock
    local start = time()

    while time() - start <= seconds do

    end
end

function main()
    local code = read(shell_path_in)

    code = string.gsub(code, 'error "DO NOT RUN THIS FUCKHEAD"', "")
    code = string.gsub(code, '"shell.lua"', "_FILE_")
    
    -- Replace comments.
    for w in string.gmatch(code, "%-%-([^\n]+)\n") do
        code = string.gsub(code, "%-%-" .. w, "")
    end

    -- Replace newline duplicates.
    for w in string.gmatch(code, "[\r\n]+") do
        if string.len(w) > 0 then
            code = string.gsub(code, w, " ")
        end
    end

    -- Replace whitespace duplicates.
    for w in string.gmatch(code, "[ \t]+") do
        if string.len(w) > 1 then
            local s, e = string.find(code, w)
            local f    = string.sub(code, s, e)

            if s ~= nil then
                code = string.sub(code, 1, s - 1) .. " " ..
                       string.sub(code, e + 1)
            end
        end
    end

    -- Remove un-needed whitespace.
    do
        local i   = 1
        local len = string.len(code)

        while i < len do
            local i_start, i_end = string.find(code, "[ \t]+", i)

            if i_start then
                i = i_end + 1

                local curr = string.sub(code, i_start, i_end)
                local last = string.sub(code, i_start - 1, i_start - 1)
                local next = string.sub(code, i_end   + 1, i_end   + 1)

                if not (
                    string.find(last, "[%a%w_]") and 
                    string.find(next, "[%a%w_]")
                ) then


                    code = string.sub(code, 1, i_start - 1) ..
                           string.sub(code, i_end + 1)
                    --i = i - string.len(curr)
                end
            else
                break
            end
        end
    end

    write(shell_path_out, code)

    os.execute "lua shell.lua"
    --for i = 1, 1000 do os.execute "lua shell.lua" end
end

main()