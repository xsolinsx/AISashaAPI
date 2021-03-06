local max_time = dateToUnix(0, 0, 48, 0, 0)

local text_table = {
    -- chat_id = text
}

local function run(msg, matches)
    if msg.cb then
        if matches[2] == 'DELETE' then
            if not deleteMessage(msg.chat.id, msg.message_id, true) then
                editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].stop)
            end
        elseif string.match(matches[2], '^%d+$') then
            if text_table[tostring(msg.from.id)] then
                local time = tonumber(matches[2])
                if matches[3] == 'BACK' then
                    answerCallbackQuery(msg.cb_id, langs[msg.lang].keyboardUpdated, false)
                    editMessageReplyMarkup(msg.chat.id, msg.message_id, keyboard_less_time('tempmessage', matches[4], time))
                elseif matches[3] == 'SECONDS' or matches[3] == 'MINUTES' or matches[3] == 'HOURS' then
                    local seconds, minutes, hours = unixToDate(time)
                    if matches[3] == 'SECONDS' then
                        if tonumber(matches[4]) == 0 then
                            answerCallbackQuery(msg.cb_id, langs[msg.lang].secondsReset, false)
                            time = time - dateToUnix(seconds, 0, 0, 0, 0)
                        else
                            if (time + dateToUnix(tonumber(matches[4]), 0, 0, 0, 0)) >= 0 and(time + dateToUnix(tonumber(matches[4]), 0, 0, 0, 0)) < 172800 then
                                time = time + dateToUnix(tonumber(matches[4]), 0, 0, 0, 0)
                            else
                                answerCallbackQuery(msg.cb_id, langs[msg.lang].errorTempTimeRange, true)
                            end
                        end
                    elseif matches[3] == 'MINUTES' then
                        if tonumber(matches[4]) == 0 then
                            answerCallbackQuery(msg.cb_id, langs[msg.lang].minutesReset, false)
                            time = time - dateToUnix(0, minutes, 0, 0, 0)
                        else
                            if (time + dateToUnix(0, tonumber(matches[4]), 0, 0, 0)) >= 0 and(time + dateToUnix(0, tonumber(matches[4]), 0, 0, 0)) < 172800 then
                                time = time + dateToUnix(0, tonumber(matches[4]), 0, 0, 0)
                            else
                                answerCallbackQuery(msg.cb_id, langs[msg.lang].errorTempTimeRange, true)
                            end
                        end
                    elseif matches[3] == 'HOURS' then
                        if tonumber(matches[4]) == 0 then
                            answerCallbackQuery(msg.cb_id, langs[msg.lang].hoursReset, false)
                            time = time - dateToUnix(0, 0, hours, 0, 0)
                        else
                            if (time + dateToUnix(0, 0, tonumber(matches[4]), 0, 0)) >= 0 and(time + dateToUnix(0, 0, tonumber(matches[4]), 0, 0)) < 172800 then
                                time = time + dateToUnix(0, 0, tonumber(matches[4]), 0, 0)
                            else
                                answerCallbackQuery(msg.cb_id, langs[msg.lang].errorTempTimeRange, true)
                            end
                        end
                    end
                    editMessageReplyMarkup(msg.chat.id, msg.message_id, keyboard_less_time('tempmessage', matches[5], time))
                    mystat(matches[1] .. matches[2] .. matches[3] .. matches[4] .. matches[5])
                elseif matches[3] == 'DONE' then
                    if is_mod2(msg.from.id, matches[4], false) then
                        answerCallbackQuery(msg.cb_id, langs[msg.lang].done, false)
                        local message_id = getMessageId(sendMessage(matches[4], text_table[tostring(msg.from.id)]))
                        text_table[tostring(msg.from.id)] = nil
                        if message_id then
                            io.popen('lua timework.lua "deletemessage" "' .. time .. '" "' .. matches[4] .. '" "' ..(message_id or '') .. '"')
                        end
                        if not deleteMessage(msg.chat.id, msg.message_id, true) then
                            editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].stop)
                        end
                        mystat(matches[1] .. matches[2] .. matches[3] .. matches[4])
                    end
                end
            else
                editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].errorTryAgain)
            end
        end
        return
    end
    if msg.chat.type ~= 'private' then
        if matches[1]:lower() == 'tempmsg' then
            if msg.from.is_mod then
                deleteMessage(msg.chat.id, msg.message_id)
                if matches[2] and matches[3] and matches[4] and matches[5] then
                    time = dateToUnix(matches[4], matches[3], matches[2])
                    if time >= max_time then
                        time = max_time - 1
                    end
                    local message_id = getMessageId(sendMessage(msg.chat.id, matches[5]))
                    if message_id then
                        io.popen('lua timework.lua "deletemessage" "' .. time .. '" "' .. msg.chat.id .. '" "' ..(message_id or '') .. '"')
                    end
                else
                    text_table[tostring(msg.from.id)] = matches[2]
                    if not sendKeyboard(msg.from.id, langs[msg.lang].tempmessageIntro:gsub('X', matches[2]), keyboard_less_time('tempmessage', msg.chat.id)) then
                        return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id)
                    end
                end
            else
                return langs[msg.lang].require_mod
            end
        end
    else
        return langs[msg.lang].useYourGroups
    end
end

return {
    description = "TEMPMESSAGE",
    patterns =
    {
        "^(###cbtempmessage)(DELETE)$",
        "^(###cbtempmessage)(%d+)(BACK)(%-%d+)$",
        "^(###cbtempmessage)(%d+)(SECONDS)([%+%-]?%d+)(%-%d+)$",
        "^(###cbtempmessage)(%d+)(MINUTES)([%+%-]?%d+)(%-%d+)$",
        "^(###cbtempmessage)(%d+)(HOURS)([%+%-]?%d+)(%-%d+)$",
        "^(###cbtempmessage)(%d+)(DONE)(%-%d+)$",

        -- X hour Y minutes Z seconds
        "^[#!/]([Tt][Ee][Mm][Pp][Mm][Ss][Gg]) (%d+) (%d+) (%d+) (.*)$",
        -- private keyboard
        "^[#!/]([Tt][Ee][Mm][Pp][Mm][Ss][Gg]) (.*)$",
    },
    run = run,
    min_rank = 2,
    syntax =
    {
        "MOD",
        "/tempmsg [{hours} {minutes} {seconds}] {text}",
    },
}