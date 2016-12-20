-- recursive to simplify code
local function check_tag(msg, user_id, user)
    if msg.entities then
        -- check if there's a mention
        if msg.entities.type == 'text_mention' and msg.entities.user then
            if tonumber(msg.entities.user.id) == tonumber(user_id) then
                return true
            end
        end
    end

    -- check if first name is in message
    if msg.text then
        if string.find(msg.text, user.first_name) then
            return true
        end
    end
    if msg.media then
        if msg.caption then
            if string.find(msg.caption, user.first_name) then
                return true
            end
        end
    end
    if user.username then
        -- check if username is in message
        if msg.text then
            if string.find(msg.text:lower(), user.username:lower()) then
                return true
            end
        end
        if msg.media then
            if msg.caption then
                if string.find(msg.caption:lower(), user.username:lower()) then
                    return true
                end
            end
        end
    end
    local tagged = false
    -- if forward check forward
    if msg.forward then
        if msg.forward_from then
            tagged = check_tag(msg.forward_from, user_id, user)
        elseif msg.forward_from_chat then
            tagged = check_tag(msg.forward_from_chat, user_id, user)
        end
    end
    return tagged
end

-- send message to sudoers when tagged
local function pre_process(msg)
    if msg then
        -- exclude private chats with bot
        if (msg.chat.type == 'group' or msg.chat.type == 'supergroup') then
            for v, user in pairs(sudoers) do
                -- exclude autotags and tags of tg-cli version
                if tonumber(msg.from.id) ~= tonumber(user.id) and tonumber(msg.from.id) ~= tonumber(bot.userVersion.id) then
                    if check_tag(msg, user.id, user) then
                        if msg.reply then
                            forwardMessage(user.id, msg.chat.id, msg.reply_to_message.message_id)
                        end
                        local text = langs[msg.lang].receiver .. msg.chat.print_name:gsub("_", " ") .. ' [' .. msg.chat.id .. ']\n' .. langs[msg.lang].sender
                        if msg.from.username then
                            text = text .. '@' .. msg.from.username .. ' [' .. msg.from.id .. ']\n'
                        else
                            text = text .. msg.from.print_name:gsub("_", " ") .. ' [' .. msg.from.id .. ']\n'
                        end
                        text = text .. langs[msg.lang].msgText

                        if msg.text then
                            text = text .. msg.text .. ' '
                        end
                        if msg.media then
                            if msg.caption then
                                text = text .. msg.media.caption
                            end
                        end
                        sendMessage(user.id, text)
                    end
                end
            end
        end
        return msg
    end
end

return {
    description = "CHECK_TAG",
    patterns = { },
    pre_process = pre_process,
    min_rank = 5
}