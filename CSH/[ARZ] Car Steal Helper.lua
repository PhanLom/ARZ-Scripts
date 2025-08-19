script_name('[ARZ] Car Steal Helper')
script_author('PhanLom')

local sampev = require 'samp.events'
local lastCarID, lastDialogID, lastDialogText = nil, nil, nil
local gossPrice = nil

function main()
    sampAddChatMessage("[ARZ] Car Steal Helper!", 0xFF0000)
    while not isSampAvailable() do wait(100) end
end

function sampev.onShowDialog(id, style, title, button1, button2, text)
    if id == 25766 then
        local model, carID = text:match('%[1%]%s*([^(]+)%s*%(%s*ID:%s*(%d+)%)')
        if model and carID then
            lastCarID = carID
            lastDialogID = id
            lastDialogText = text
            if gossPrice then
                local num = tonumber((gossPrice:gsub('%.', '')))
                local payout = math.floor(num * 0.535)
                local payoutLimit = 10600000
                local function formatNumber(n)
                    local s = tostring(n)
                    local res = ''
                    while #s > 3 do
                        res = '.' .. s:sub(-3) .. res
                        s = s:sub(1, -4)
                    end
                    res = s .. res
                    return res
                end
                local payoutStr = formatNumber(payout)
                local payoutLimitStr = formatNumber(payoutLimit)
                text = text .. '\n{FF8800}Гос. цена: {FFFFFF}$' .. gossPrice
                if payout > payoutLimit then
                    text = text .. '\n{73B461}Вы получите: {FFFFFF}$' .. payoutLimitStr .. ' {FF0000}(лимит без навыка)'
                else
                    text = text .. '\n{73B461}Вы получите: {FFFFFF}$' .. payoutStr
                end
            else
                sampSendChat('/getprice ' .. carID)
            end
        end
    end
    return {id, style, title, button1, button2, text}
end

function sampev.onServerMessage(color, text)
    if lastDialogID and text:find('Гос%.стоимость') and text:find('составляет') then
        local price = text:match('%$([%d%.]+)')
        if price then
            gossPrice = price
            lastDialogID = nil
            lastDialogText = nil
        end
    end
end
