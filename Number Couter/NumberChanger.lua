script_name('NumberChanger')
script_author('PhanLom')

local inicfg = require('inicfg')
local imgui = require('imgui')
local samp = require('sampfuncs')
local config_dir = getGameDirectory().."\\moonloader\\PhanLom\\NumberChanger"
local f_ini = config_dir.."\\NumberChanger.ini"
local DIALOG_STYLE_MSGBOX = 0
local DIALOG_STYLE_TABLIST = 2

local number = 0
local font
local config = {
    settings = {
        x = 300,
        y = 300,
        color = "FFFFFF",
        fontsize = 12,
        activate = true
    }
}

local moving = false

function loadConfig()
    if not doesDirectoryExist(config_dir) then createDirectory(config_dir) end
    if not doesFileExist(f_ini) then
        inicfg.save(config, f_ini)
    end
    local loaded = inicfg.load(nil, f_ini)
    if loaded then config = loaded end
end

function saveConfig()
    inicfg.save(config, f_ini)
end

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end

    loadConfig()
    font = renderCreateFont("Arial", config.settings.fontsize, 5)
    sampRegisterChatCommand("numshow", cmd_numshow)

    while true do
        wait(0)

        if isKeyJustPressed(0x6B) then
            number = number + 1
        elseif isKeyJustPressed(0x6D) then
            number = number - 1
        end

        if config.settings.activate or moving then
            if moving then
                sampToggleCursor(true)
                local x, y = getCursorPos()
                config.settings.x = x
                config.settings.y = y
                if isKeyJustPressed(0x01) then
                    moving = false
                    sampToggleCursor(false)
                    saveConfig()
                end
            end
            renderFontDrawText(font, tostring(number), config.settings.x, config.settings.y, "0xFF"..config.settings.color)
        end
    end
end

function cmd_numshow()
    lua_thread.create(function()
        local dtext = "Отображать число на экране\t" .. (config.settings.activate and "{45d900}ON\n" or "{ff0000}OFF\n") ..
                      "Размер шрифта:\t" .. config.settings.fontsize .. "\n" ..
                      "Цвет числа:\t{" .. config.settings.color .. "}||||||||||\n" ..
                      "Изменить положение"

        sampShowDialog(10, "{A77BCA}Number Clicker", dtext, "OK", "Отмена", DIALOG_STYLE_TABLIST)
        while sampIsDialogActive(10) do wait(0) end
        local result, button, list, input = sampHasDialogRespond(10)

        if result and button == 1 then
            if list == 0 then
                config.settings.activate = not config.settings.activate
                inicfg.save(config, f_ini)
                return true
            end

            if list == 1 then
                sampShowDialog(11, "{A77BCA}Number Counter", "{FFFFFF}Введите новое значение шрифта:", "OK", "Отмена", DIALOG_STYLE_INPUT)
                while sampIsDialogActive(11) do wait(0) end
                local result, button, list, input = sampHasDialogRespond(11)
                if result then
                    if tonumber(input) then
                        config.settings.fontsize = tonumber(input)
                        font = renderCreateFont('Arial', config.settings.fontsize, 5)
                        inicfg.save(config, f_ini)
                        return true
                    else
                        chatmsg("Значение должно быть числом!")
                        return true
                    end
                else
                    return true
                end
            end

            if list == 2 then
                sampShowDialog(11, "{A77BCA}Number Counter", "{FFFFFF}Введите новое значение цвета:\n{c3c3c3}Например: AE433D или A77BCA (по умолчанию FFFFFF)", "OK", "Отмена", DIALOG_STYLE_INPUT)
                while sampIsDialogActive(11) do wait(0) end
                local result, button, list, input = sampHasDialogRespond(11)
                if result then
                    if not input:match("[а-яА-ЯЁё]+") then
                        config.settings.color = input
                        inicfg.save(config, f_ini)
                        return true
                    else
                        chatmsg("Неправильный ввод.")
                        return true
                    end
                else
                    return true
                end
            end

            if list == 3 then
                moving = true
                chatmsg("Нажмите ЛКМ для сохранения положения.")
            end
        end
    end)
end

function chatmsg(text)
    sampAddChatMessage(string.format("[NumberChanger]: {FFFFFF}%s", text), 0xA77BCA)
end

local lua_thread = require('moonloader').thread
local wait = require('moonloader').wait
local sampRegisterChatCommand = require('sampfuncs').registerChatCommand
local sampShowDialog = require('sampfuncs').showDialog
local sampIsDialogActive = require('sampfuncs').isDialogActive
local sampHasDialogRespond = require('sampfuncs').hasDialogRespond
local sampToggleCursor = require('sampfuncs').toggleCursor
local getCursorPos = require('sampfuncs').getCursorPos
local isKeyJustPressed = require('sampfuncs').isKeyJustPressed
local renderCreateFont = require('moonloader').renderCreateFont
local renderFontDrawText = require('moonloader').renderFontDrawText
local doesDirectoryExist = require('moonloader').doesDirectoryExist
local createDirectory = require('moonloader').createDirectory
local doesFileExist = require('moonloader').doesFileExist
local isSampLoaded = require('sampfuncs').isSampLoaded
local isSampfuncsLoaded = require('sampfuncs').isSampfuncsLoaded
local isSampAvailable = require('sampfuncs').isSampAvailable
local sampAddChatMessage = require('sampfuncs').addChatMessage