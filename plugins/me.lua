-- Returns chat's total messages
local function get_msgs_chat(chat_id)
    local hash = 'chatmsgs:' .. chat_id
    local msgs = redis_get_something(hash)
    if not msgs then
        return 0
    end
    return msgs
end

local function run(msg, matches)
    mystat('/me')
    local chattotal = get_msgs_chat(msg.chat.id)
    local usermsgs = tonumber(redis_get_something('msgs:' .. msg.from.id .. ':' .. msg.chat.id) or 0)
    local percentage =(usermsgs * 100) / chattotal
    local txt = string.gsub(string.gsub(string.gsub(langs[msg.lang].meString, 'W', tostring(usermsgs)), 'X', string.format('%d', percentage)), 'Z', tostring(chattotal))
    local message_id = getMessageId(sendReply(msg, txt))
    io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' ..(message_id or '') .. '"')
    return
end

return {
    description = "ME",
    patterns =
    {
        "^[#!/]([Mm][Ee])$",
    },
    run = run,
    min_rank = 1,
    syntax =
    {
        "USER",
        "/me",
    },
}
-- idea taken from jack-telegram-bot