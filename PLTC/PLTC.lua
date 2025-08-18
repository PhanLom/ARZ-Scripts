script_name("PLTC")
script_author("PhanLom")

events = require "samp.events"
local font = renderCreateFont("Arial", 8, 5)
local inicfg = require 'inicfg'
local lfs = require 'lfs'
local config_path = 'PLTC/PLTC'
local config_dir = 'PLTC'
local default_cfg = {settings = {enabled = true}}

if not lfs.attributes(config_dir, 'mode') then
	lfs.mkdir('PLTC')
	lfs.mkdir(config_dir)
end

local config = inicfg.load(nil, config_path)
if not config or not config.settings or config.settings.enabled == nil then
	config = default_cfg
	inicfg.save(config, config_path)
end

local function get_status()
	local cfg = inicfg.load(nil, config_path)
	if cfg and cfg.settings and cfg.settings.enabled ~= nil then
		return cfg.settings.enabled == true or cfg.settings.enabled == 'true' or cfg.settings.enabled == 1 or cfg.settings.enabled == '1'
	end
	return true
end

function main()
	repeat wait(0) until isSampAvailable()
	if get_status() then
		sampAddChatMessage("{00FF00}[PLTC]{FFFFFF} Скрипт включен", -1)
	else
		sampAddChatMessage("{FF0000}[PLTC]{FFFFFF} Скрипт выключен", -1)
	end
	while true do
		local prev = nil
		while true do
			local now = get_status()
			if prev ~= nil and now ~= prev then
				if now then
					sampAddChatMessage("{00FF00}[PLTC]{FFFFFF} Скрипт включен", -1)
				else
					sampAddChatMessage("{FF0000}[PLTC]{FFFFFF} Скрипт выключен", -1)
				end
			end
			prev = now
			wait(1000)
		end
	end
end

function events.onShowDialog(dialogId)
	if dialogId == 3010 and get_status() then
		sampSendDialogResponse(dialogId, 1, 0, 0)
		sampAddChatMessage("{00FF00}[PLTC]{FFFFFF} Вы словили лавку!", -1)
	end
end

function events.onSetObjectMaterialText(ev, data)
	local text = tostring(data and data.text or "nil")
	if get_status() and string.find(text, "{30A332}Свободная!") then
		press_key()
	end
end

function press_key()
	setGameKeyState(21, 256)
	sampAddChatMessage("{FF0000}[AC]{FFFFFF} ALT отправлено!", -1)
end

function get_distance(Object)
	local result, posX, posY, posZ = getObjectCoordinates(Object)
	if result then
		if doesObjectExist(Object) then
			local pPosX, pPosY, pPosZ = getCharCoordinates(PLAYER_PED)
			local distance = (math.abs(posX - pPosX)^2 + math.abs(posY - pPosY)^2)^0.5
			local posX, posY = convert3DCoordsToScreen(posX, posY, posZ)
			if round(distance, 2) <= 0.9 then
				return true
			end
		end
	end
	return false
end

function round(x, n)
    n = math.pow(10, n or 0)
    x = x * n
    if x >= 0 then x = math.floor(x + 0.5) else x = math.ceil(x - 0.5) end
    return x / n
end
