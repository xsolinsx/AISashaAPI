local function run(msg, matches)
    return [[]]
end

return {
    description = "NEWS",
    patterns =
    {
        "^[#!/][Nn][Ee][Ww][Ss]$",
    },
    run = run,
    pre_process = pre_process,
    min_rank = 0,
    syntax =
    {
        "USER",
        "#news",
    },
}