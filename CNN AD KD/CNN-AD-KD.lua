local timerPosX = 500
local timerPosY = 500
local moving = false
local inicfg = require('inicfg')
local sampev = require 'lib.samp.events'
require 'lib.sampfuncs'
require 'lib.moonloader'

local config_dir = getGameDirectory().."\\moonloader\\config\\ADTimer"
local f_ini = config_dir .. "\\ADTimer.ini"
local timerConfig = {
    settings = {
        x = timerPosX,
        y = timerPosY,
        enabled = scriptEnabled
    }
}

function loadConfig()
    if not doesDirectoryExist(config_dir) then createDirectory(config_dir) end
    if not doesFileExist(f_ini) then
        inicfg.save(timerConfig, f_ini)
    end
    local loaded = inicfg.load(nil, f_ini)
    if loaded and loaded.settings then timerConfig = loaded end
    if timerConfig.settings and timerConfig.settings.x ~= nil then timerPosX = timerConfig.settings.x end
    if timerConfig.settings and timerConfig.settings.y ~= nil then timerPosY = timerConfig.settings.y end
    if timerConfig.settings and timerConfig.settings.enabled ~= nil then scriptEnabled = timerConfig.settings.enabled end
end

function saveConfig()
    timerConfig.settings.x = timerPosX
    timerConfig.settings.y = timerPosY
    timerConfig.settings.enabled = scriptEnabled
    inicfg.save(timerConfig, f_ini)
end

local font = renderCreateFont('Arial', 20, 5)
local adTimerActive = false
local adTimer = 0
local timerDuration = 15
local lastEditor = ""
local scriptEnabled = false

function onAdEdited(nick)
    lastEditor = nick
    if not adTimerActive then
        adTimerActive = true
        adTimer = os.time()
    end
end

function cmd_adtimer()
    lua_thread.create(function()
        local dtext = "Статус таймера:\t" .. (scriptEnabled and "{45d900}ON\n" or "{ff0000}OFF\n") ..
                      "Позиция таймера:\t" .. timerPosX .. ", " .. timerPosY .. "\n" ..
                      "\n{ff0000}Переместить таймер\n{c3c3c3}Сбросить позицию"
        sampShowDialog(101, "{A77BCA}AD Timer", dtext, "OK", "Вихід", 2)
        while sampIsDialogActive(101) do wait(0) end
        local result, button, list, input = sampHasDialogRespond(101)
        if result and button == 1 then
            if list == 0 then
                scriptEnabled = not scriptEnabled
                sampAddChatMessage("[AD TIMER] Таймер " .. (scriptEnabled and "Включен" or "Выключен"), 0xA77BCA)
                saveConfig()
            elseif list == 2 then
                moving = true
                sampAddChatMessage("[AD TIMER] Перемещение таймера: нажмите ЛКМ в нужном месте.", 0xA77BCA)
            elseif list == 3 then
                timerPosX = 120
                timerPosY = 120
                sampAddChatMessage("[AD TIMER] Позиция сброшена.", 0xA77BCA)
                saveConfig()
            end
        end
    end)
end

function main()
    loadConfig()
    sampRegisterChatCommand('adtimer', cmd_adtimer)
    while not isSampAvailable() do wait(100) end
    sampAddChatMessage("[AD TIMER] Скрипт загружен!", 0x00FF00)
    while true do
        wait(0)
        if moving then
            sampToggleCursor(true)
            local x, y = getCursorPos()
            timerPosX = x
            timerPosY = y
            if isKeyJustPressed(0x01) then
                moving = false
                sampToggleCursor(false)
                sampAddChatMessage("[AD TIMER] Позиция сохранена.", 0xA77BCA)
            end
        end
        if scriptEnabled and adTimerActive then
            local timeLeft = timerDuration - (os.time() - adTimer)
            if timeLeft > 0 then
                renderFontDrawText(font, "Таймер рекламы: " .. timeLeft .. " сек", timerPosX, timerPosY, 0xFFFFFFFF)
                renderFontDrawText(font, "Редактор: " .. lastEditor, timerPosX, timerPosY + 40, 0xFFDD00FF)
            elseif timeLeft <= 0 then
                adTimerActive = false
            end
        end
    end
end

function sampev.onServerMessage(color, text)
    local myNick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
    local cleanText = text:gsub("{%x+}", ""):gsub("^%s+", "")
    if scriptEnabled and cleanText:find("Отредактировал сотрудник СМИ") and cleanText:find(myNick) then
        onAdEdited(myNick)
    end
end