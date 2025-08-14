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
        log_cef("[CEF Parser] DOM ��������� � ����: "..log_file:gsub("%.log$", "_dom_dump.html"))
    end
end

function main()
    print("CEF Parser ��������")
    log_cef("CEF Parser ��������")
    if not isSampLoaded() then print("SAMP �� ������������") log_cef("SAMP �� ������������") return end
    while not isSampAvailable() or sampGetGamestate() ~= 3 do wait(1000) end
    print("SAMP ���������, ����� ������")
    log_cef("SAMP ���������, ����� ������")
    repeat wait(0) until sampIsLocalPlayerSpawned()
    print("������� �����������, ������ ��������")
    log_cef("������� �����������, ������ ��������")

    -- /cefparse <��������> � �����
    sampRegisterChatCommand("cefparse", function(arg)
        if not arg or arg == "" then
            sampAddChatMessage("[CEF Parser] ������������: /cefparse <css-��������>", 0xFF0000)
            log_cef("[CEF Parser] ������������: /cefparse <css-��������>")
            return
        end
        local js = [[
            (function(){
                try {
                    var el = document.querySelector("]]
                    .. arg .. [[");
                    if(!el){
                        console.log("[CEF Parser] ������� ']] .. arg .. [[' �� ��������");
                        return;
                    }
                    var text = el.innerText.trim();
                    if(!text){
                        console.log("[CEF Parser] �������� ']] .. arg .. [[' ����� �������");
                        return;
                    }
                    console.log("[CEF Parser] ���� ']] .. arg .. [[':\n" + text);
                } catch(err) {
                    console.log("[CEF Parser] �������: " + err.message);
                }
            })();
        ]]
        evalanon(js)
        sampAddChatMessage("[CEF Parser] ����� �������� ��� '"..arg.."'", 0x00FF00)
        log_cef("[CEF Parser] ����� �������� ��� '"..arg.."'")
    end)

    -- /cefparse.html <��������> � innerHTML
    sampRegisterChatCommand("cefparse.html", function(arg)
        if not arg or arg == "" then
            sampAddChatMessage("[CEF Parser] ������������: /cefparse.html <css-��������>", 0xFF0000)
            log_cef("[CEF Parser] ������������: /cefparse.html <css-��������>")
            return
        end
        local js = [[
            (function(){
                try {
                    var el = document.querySelector("]]
                    .. arg .. [[");
                    if(!el){
                        console.log("[CEF Parser] ������� ']] .. arg .. [[' �� ��������"); return; }
                    var html = el.innerHTML.trim();
                    if(!html){
                        console.log("[CEF Parser] �������� ']] .. arg .. [[' HTML �������"); return; }
                    console.log("[CEF Parser] HTML ']] .. arg .. [[':\n" + html);
                } catch(err) { console.log("[CEF Parser] �������: " + err.message); }
            })();
        ]]
        evalanon(js)
        sampAddChatMessage("[CEF Parser] HTML-����� �������� ��� '"..arg.."'", 0x00FF00)
        log_cef("[CEF Parser] HTML-����� �������� ��� '"..arg.."'")
    end)

    -- /cefparse.attrs <��������> � �� ��������
    sampRegisterChatCommand("cefparse.attrs", function(arg)
        if not arg or arg == "" then
            sampAddChatMessage("[CEF Parser] ������������: /cefparse.attrs <css-��������>", 0xFF0000)
            log_cef("[CEF Parser] ������������: /cefparse.attrs <css-��������>")
            return
        end
        local js = [[
            (function(){
                try {
                    var el = document.querySelector("]]
                    .. arg .. [[");
                    if(!el){ console.log("[CEF Parser] ������� ']] .. arg .. [[' �� ��������"); return; }
                    var attrs = Array.from(el.attributes).map(a => a.name + '="' + a.value + '"').join(' ');
                    console.log("[CEF Parser] �������� ']] .. arg .. [[':\n" + attrs);
                } catch(err) { console.log("[CEF Parser] �������: " + err.message); }
            })();
        ]]
        evalanon(js)
        sampAddChatMessage("[CEF Parser] ��������-����� �������� ��� '"..arg.."'", 0x00FF00)
        log_cef("[CEF Parser] ��������-����� �������� ��� '"..arg.."'")
    end)

    -- /cefparse.highlight <��������> � �������� �������
    sampRegisterChatCommand("cefparse.highlight", function(arg)
        if not arg or arg == "" then
            sampAddChatMessage("[CEF Parser] ������������: /cefparse.highlight <css-��������>", 0xFF0000)
            log_cef("[CEF Parser] ������������: /cefparse.highlight <css-��������>")
            return
        end
        local js = [[
            (function(){
                try {
                    var el = document.querySelector("]]
                    .. arg .. [[");
                    if(!el){ console.log("[CEF Parser] ������� ']] .. arg .. [[' �� ��������"); return; }
                    el.style.outline = '2px solid #00f';
                    el.style.background = 'rgba(0,0,255,0.1)';
                } catch(err) { console.log("[CEF Parser] �������: " + err.message); }
            })();
        ]]
        evalanon(js)
        sampAddChatMessage("[CEF Parser] ϳ���������� �������� ��� '"..arg.."'", 0x00FF00)
        log_cef("[CEF Parser] ϳ���������� �������� ��� '"..arg.."'")
    end)

    -- /cefparse.list � �� id � �����
    sampRegisterChatCommand("cefparse.list", function()
        local js = [[
            (function(){
                try {
                    var ids = Array.from(document.querySelectorAll('[id]')).map(e => '#' + e.id);
                    var classes = Array.from(document.querySelectorAll('[class]')).flatMap(e => Array.from(e.classList)).filter((v,i,a)=>a.indexOf(v)===i).map(c => '.'+c);
                    console.log('[CEF Parser] ID: ' + ids.join(', '));
                    console.log('[CEF Parser] �����: ' + classes.join(', '));
                } catch(err) { console.log('[CEF Parser] �������: ' + err.message); }
            })();
        ]]
        evalanon(js)
        sampAddChatMessage("[CEF Parser] ������ id/����� ��������", 0x00FF00)
        log_cef("[CEF Parser] ������ id/����� ��������")
    end)

    -- /cefparse.dom � ��������� ���� DOM �� ��������� ������
    sampRegisterChatCommand("cefparse.dom", function()
        local js = [[
            (function(){
                try {
                    var xhr = new XMLHttpRequest();
                    xhr.open('POST', 'http://127.0.0.1:8081', true);
                    xhr.setRequestHeader('Content-Type', 'text/html');
                    xhr.send(document.documentElement.outerHTML);
                } catch(err) { console.log('[CEF Parser] �������: ' + err.message); }
            })();
        ]]
        evalanon(js)
        sampAddChatMessage("[CEF Parser] DOM ���� ���������� �� ��������� ������", 0x00FF00)
        log_cef("[CEF Parser] DOM dump �������� ����� HTTP")
    end)

    while true do wait(1000) end -- ������ ����������� ����!
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
