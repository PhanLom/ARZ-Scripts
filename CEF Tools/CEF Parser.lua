script_name     = "CEF Wrapper Parser"
script_version  = "1.1"
script_author   = "Olek Parser"

local log_file = getWorkingDirectory().."/cef_parser.log"

function log_cef(msg)
    local f = io.open(log_file, "a+")
    if f then
        f:write(os.date("[%Y-%m-%d %H:%M:%S] ")..msg.."\n")
        f:close()
    end
    if isSampfuncsLoaded and isSampfuncsLoaded() and sampfuncsLog then
        sampfuncsLog(msg)
    end
end

function save_dom_to_file(html)
    local f = io.open(log_file:gsub("%.log$", "_dom_dump.html"), "w+")
    if f then
        f:write(html)
        f:close()
        log_cef("[CEF Parser] DOM збережено у файл: "..log_file:gsub("%.log$", "_dom_dump.html"))
    end
end

function main()
    print("CEF Parser запущено")
    log_cef("CEF Parser запущено")
    if not isSampLoaded() then print("SAMP не завантажений") log_cef("SAMP не завантажений") return end
    while not isSampAvailable() or sampGetGamestate() ~= 3 do wait(1000) end
    print("SAMP підключено, чекаю спавну")
    log_cef("SAMP підключено, чекаю спавну")
    repeat wait(0) until sampIsLocalPlayerSpawned()
    print("Гравець заспавнений, скрипт активний")
    log_cef("Гравець заспавнений, скрипт активний")

    -- /cefparse <селектор> — текст
    sampRegisterChatCommand("cefparse", function(arg)
        if not arg or arg == "" then
            sampAddChatMessage("[CEF Parser] Використання: /cefparse <css-селектор>", 0xFF0000)
            log_cef("[CEF Parser] Використання: /cefparse <css-селектор>")
            return
        end
        local js = [[
            (function(){
                try {
                    var el = document.querySelector("]]
                    .. arg .. [[");
                    if(!el){
                        console.log("[CEF Parser] Елемент ']] .. arg .. [[' не знайдено");
                        return;
                    }
                    var text = el.innerText.trim();
                    if(!text){
                        console.log("[CEF Parser] Усередині ']] .. arg .. [[' текст відсутній");
                        return;
                    }
                    console.log("[CEF Parser] Вміст ']] .. arg .. [[':\n" + text);
                } catch(err) {
                    console.log("[CEF Parser] Помилка: " + err.message);
                }
            })();
        ]]
        evalanon(js)
        sampAddChatMessage("[CEF Parser] Запит виконано для '"..arg.."'", 0x00FF00)
        log_cef("[CEF Parser] Запит виконано для '"..arg.."'")
    end)

    -- /cefparse.html <селектор> — innerHTML
    sampRegisterChatCommand("cefparse.html", function(arg)
        if not arg or arg == "" then
            sampAddChatMessage("[CEF Parser] Використання: /cefparse.html <css-селектор>", 0xFF0000)
            log_cef("[CEF Parser] Використання: /cefparse.html <css-селектор>")
            return
        end
        local js = [[
            (function(){
                try {
                    var el = document.querySelector("]]
                    .. arg .. [[");
                    if(!el){
                        console.log("[CEF Parser] Елемент ']] .. arg .. [[' не знайдено"); return; }
                    var html = el.innerHTML.trim();
                    if(!html){
                        console.log("[CEF Parser] Усередині ']] .. arg .. [[' HTML відсутній"); return; }
                    console.log("[CEF Parser] HTML ']] .. arg .. [[':\n" + html);
                } catch(err) { console.log("[CEF Parser] Помилка: " + err.message); }
            })();
        ]]
        evalanon(js)
        sampAddChatMessage("[CEF Parser] HTML-запит виконано для '"..arg.."'", 0x00FF00)
        log_cef("[CEF Parser] HTML-запит виконано для '"..arg.."'")
    end)

    -- /cefparse.attrs <селектор> — всі атрибути
    sampRegisterChatCommand("cefparse.attrs", function(arg)
        if not arg or arg == "" then
            sampAddChatMessage("[CEF Parser] Використання: /cefparse.attrs <css-селектор>", 0xFF0000)
            log_cef("[CEF Parser] Використання: /cefparse.attrs <css-селектор>")
            return
        end
        local js = [[
            (function(){
                try {
                    var el = document.querySelector("]]
                    .. arg .. [[");
                    if(!el){ console.log("[CEF Parser] Елемент ']] .. arg .. [[' не знайдено"); return; }
                    var attrs = Array.from(el.attributes).map(a => a.name + '="' + a.value + '"').join(' ');
                    console.log("[CEF Parser] Атрибути ']] .. arg .. [[':\n" + attrs);
                } catch(err) { console.log("[CEF Parser] Помилка: " + err.message); }
            })();
        ]]
        evalanon(js)
        sampAddChatMessage("[CEF Parser] Атрибути-запит виконано для '"..arg.."'", 0x00FF00)
        log_cef("[CEF Parser] Атрибути-запит виконано для '"..arg.."'")
    end)

    -- /cefparse.highlight <селектор> — підсвітити елемент
    sampRegisterChatCommand("cefparse.highlight", function(arg)
        if not arg or arg == "" then
            sampAddChatMessage("[CEF Parser] Використання: /cefparse.highlight <css-селектор>", 0xFF0000)
            log_cef("[CEF Parser] Використання: /cefparse.highlight <css-селектор>")
            return
        end
        local js = [[
            (function(){
                try {
                    var el = document.querySelector("]]
                    .. arg .. [[");
                    if(!el){ console.log("[CEF Parser] Елемент ']] .. arg .. [[' не знайдено"); return; }
                    el.style.outline = '2px solid #00f';
                    el.style.background = 'rgba(0,0,255,0.1)';
                } catch(err) { console.log("[CEF Parser] Помилка: " + err.message); }
            })();
        ]]
        evalanon(js)
        sampAddChatMessage("[CEF Parser] Підсвічування виконано для '"..arg.."'", 0x00FF00)
        log_cef("[CEF Parser] Підсвічування виконано для '"..arg.."'")
    end)

    -- /cefparse.list — всі id і класи
    sampRegisterChatCommand("cefparse.list", function()
        local js = [[
            (function(){
                try {
                    var ids = Array.from(document.querySelectorAll('[id]')).map(e => '#' + e.id);
                    var classes = Array.from(document.querySelectorAll('[class]')).flatMap(e => Array.from(e.classList)).filter((v,i,a)=>a.indexOf(v)===i).map(c => '.'+c);
                    console.log('[CEF Parser] ID: ' + ids.join(', '));
                    console.log('[CEF Parser] Класи: ' + classes.join(', '));
                } catch(err) { console.log('[CEF Parser] Помилка: ' + err.message); }
            })();
        ]]
        evalanon(js)
        sampAddChatMessage("[CEF Parser] Список id/класів запитано", 0x00FF00)
        log_cef("[CEF Parser] Список id/класів запитано")
    end)

    -- /cefparse.dom — відправити весь DOM на локальний сервер
    sampRegisterChatCommand("cefparse.dom", function()
        local js = [[
            (function(){
                try {
                    var xhr = new XMLHttpRequest();
                    xhr.open('POST', 'http://127.0.0.1:8081', true);
                    xhr.setRequestHeader('Content-Type', 'text/html');
                    xhr.send(document.documentElement.outerHTML);
                } catch(err) { console.log('[CEF Parser] Помилка: ' + err.message); }
            })();
        ]]
        evalanon(js)
        sampAddChatMessage("[CEF Parser] DOM буде відправлено на локальний сервер", 0x00FF00)
        log_cef("[CEF Parser] DOM dump запитано через HTTP")
    end)

    while true do wait(1000) end -- Додаємо нескінченний цикл!
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
