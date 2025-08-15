script_name = "[ARZ] HUD Stamina"
script_author = "PhanLom"
script_version = "1.0"


_G.evalanon = evalanon
_G.evalcef = evalcef
local memory = require 'memory'


function main()
  if not isSampLoaded or not isSampLoaded() then return end
  if not isSampfuncsLoaded or not isSampfuncsLoaded() then return end
  repeat wait(0) until isSampAvailable and isSampAvailable()
    local refreshInterval = 60000 -- 60 секунд
    local lastRefresh = os.clock() * 1000

    while true do
      local now = os.clock() * 1000
      if now - lastRefresh > refreshInterval then
        refreshCustomIndicator()
        lastRefresh = now
      end
      tryAddCustomIndicator()
      local stamina = getSprintLocalPlayer()
      updateStaminaIndicator(stamina)
      wait(500)
    end
end

  -- Видаляє кастомний індикатор, якщо він є
  function removeCustomIndicator()
    local eval = _G.evalcef or _G.evalanon
    local js = [[
      (function() {
        var el = document.getElementById('custom_indicator');
        if (el && el.parentNode) el.parentNode.removeChild(el);
      })();
    ]]
    if eval then pcall(function() eval(js) end) end
  end

  -- Оновлює індикатор: видаляє і додає заново
  function refreshCustomIndicator()
    removeCustomIndicator()
    wait(100)
    tryAddCustomIndicator()
  end


function tryAddCustomIndicator()
  local eval = _G.evalcef or _G.evalanon
  local js = [[
    (function() {
      var indicators = document.querySelector('.player-info__indicators');
      if (!indicators) return false;
      if (document.getElementById('custom_indicator')) return true;
      var html = `<div id="custom_indicator" class="player-info__indicator">
        <div class="circle-indicator" style="--svg-width:66px; --icon-color:rgba(56, 251, 7, 1); box-shadow: rgb(255, 254, 254) 0px 0px 30px 1px;">
          <div class="circle-indicator__lines">
            <svg class="circle-indicator__svg-zone" style="--dashoffset:0; --dasharray:188.496;">
              <circle class="circle-indicator__total" cx="33" cy="33" r="30"></circle>
              <circle class="circle-indicator__current" cx="33" cy="33" r="30"></circle>
            </svg>
          </div>
          <div class="circle-indicator__light"></div>
          <i class="circle-indicator__icon" style="width: 19px; height: 19px; transform: scale(1.5) translateX(-1px);">
            <svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-run" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round">
              <path stroke="none" d="M0 0h24v24H0z" fill="none"></path>
              <path d="M13 4m-1 0a1 1 0 1 0 2 0a1 1 0 1 0 -2 0"></path>
              <path d="M4 17l5 1l.75 -1.5"></path>
              <path d="M15 21l0 -4l-4 -3l1 -6"></path>
              <path d="M7 12l0 -3l5 -1l3 3l3 1"></path>
            </svg>
          </i>
          <i class="circle-indicator__wave-icon ui-wave"></i>
          <p class="circle-indicator__count">100 </p>
        </div>
      </div>`;
      indicators.insertAdjacentHTML('beforeend', html);
      return true;
    })();
  ]]
  if eval then
    local ok = false
    pcall(function()
      eval(js)
      ok = true
    end)
    return ok and isIndicatorPresent()
  end
  return false
end

function isIndicatorPresent()
  local eval = _G.evalcef or _G.evalanon
  local js = [[
    (function() {
      return !!document.getElementById('custom_indicator');
    })();
  ]]
  return true
end


function getSprintLocalPlayer()
  local float = memory.getfloat(0xB7CDB4)
  local percent = math.floor(float / 31.47000244)
  if percent > 100 then percent = 100 end
  if percent < 0 then percent = 0 end
  return percent
end


function updateStaminaIndicator(value)
  local js = ([=[
    var el = document.querySelector('#custom_indicator .circle-indicator__count');
    if (el) {
      el.textContent = "%d";
      var svg = document.querySelector('#custom_indicator .circle-indicator__svg-zone');
      if (svg) {
        var dasharray = 188.496;
        var dashoffset = dasharray * (1 - (%d / 100));
        svg.style.setProperty('--dashoffset', dashoffset);
      }
    }
  ]=]):format(value, value)
  local eval = _G.evalcef or _G.evalanon
  if eval then eval(js) end
end


function evalanon(code)
  evalcef(("(() => {%s})()"):format(code))
end


function evalcef(code, encoded)
  encoded = encoded or 0
  local bs = raknetNewBitStream()
  raknetBitStreamWriteInt8(bs, 17)
  raknetBitStreamWriteInt32(bs, 0)
  raknetBitStreamWriteInt16(bs, #code)
  raknetBitStreamWriteInt8(bs, encoded)
  raknetBitStreamWriteString(bs, code)
  raknetEmulPacketReceiveBitStream(220, bs)
  raknetDeleteBitStream(bs)
end