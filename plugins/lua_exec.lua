local function run(msg, matches)
    if is_sudo(msg) then
        mystat('/lua <command>')
        local output = loadstring(matches[1])()
        if output == nil then
            output = langs[msg.lang].doneNoOutput
        else
            if type(output) == 'table' then
                output = vardumptext(output)
            end
        end
        return tostring(output)
    else
        return langs[msg.lang].require_sudo
    end
end

return {
    description = "LUA_EXEC",
    patterns =
    {
        "^[#!/][Ll][Uu][Aa] (.*)",
    },
    run = run,
    min_rank = 5,
    syntax =
    {
        "SUDO",
        "/lua {command}",
    },
}