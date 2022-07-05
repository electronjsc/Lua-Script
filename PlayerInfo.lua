require "lib.moonloader"
local imgui = require "imgui"
local mem = require "memory"
local encoding = require "encoding"
local key = require 'vkeys'
local ev = require "samp.events"
local main_window_state = imgui.ImBool(false)
---------------------------------------------------

---------------------------------------------------
encoding.default = 'CP1251'
u8 = encoding.UTF8
script_name('moonloader-script-updater-playerifno')
script_author('JavaScript')
script_version("06.07.2022")
---------------------------------------------------

local enable_autoupdate = true 
local autoupdate_loaded = false
local Update = nil
if enable_autoupdate then
    local updater_loaded, Updater = pcall(loadstring, [[return {check=function (a,b,c) local d=require('moonloader').download_status;local e=os.tmpname()local f=os.clock()if doesFileExist(e)then os.remove(e)end;downloadUrlToFile(a,e,function(g,h,i,j)if h==d.STATUSEX_ENDDOWNLOAD then if doesFileExist(e)then local k=io.open(e,'r')if k then local l=decodeJson(k:read('*a'))updatelink=l.updateurl;updateversion=l.latest;k:close()os.remove(e)if updateversion~=thisScript().version then lua_thread.create(function(b)local d=require('moonloader').download_status;local m=-1;sampAddChatMessage(b..'Îáíàðóæåíî îáíîâëåíèå. Ïûòàþñü îáíîâèòüñÿ c '..thisScript().version..' íà '..updateversion,m)wait(250)downloadUrlToFile(updatelink,thisScript().path,function(n,o,p,q)if o==d.STATUS_DOWNLOADINGDATA then print(string.format('Çàãðóæåíî %d èç %d.',p,q))elseif o==d.STATUS_ENDDOWNLOADDATA then print('Çàãðóçêà îáíîâëåíèÿ çàâåðøåíà.')sampAddChatMessage(b..'Îáíîâëåíèå çàâåðøåíî!',m)goupdatestatus=true;lua_thread.create(function()wait(500)thisScript():reload()end)end;if o==d.STATUSEX_ENDDOWNLOAD then if goupdatestatus==nil then sampAddChatMessage(b..'Îáíîâëåíèå ïðîøëî íåóäà÷íî. Çàïóñêàþ óñòàðåâøóþ âåðñèþ..',m)update=false end end end)end,b)else update=false;print('v'..thisScript().version..': Îáíîâëåíèå íå òðåáóåòñÿ.')if l.telemetry then local r=require"ffi"r.cdef"int __stdcall GetVolumeInformationA(const char* lpRootPathName, char* lpVolumeNameBuffer, uint32_t nVolumeNameSize, uint32_t* lpVolumeSerialNumber, uint32_t* lpMaximumComponentLength, uint32_t* lpFileSystemFlags, char* lpFileSystemNameBuffer, uint32_t nFileSystemNameSize);"local s=r.new("unsigned long[1]",0)r.C.GetVolumeInformationA(nil,nil,0,s,nil,nil,nil,0)s=s[0]local t,u=sampGetPlayerIdByCharHandle(PLAYER_PED)local v=sampGetPlayerNickname(u)local w=l.telemetry.."?id="..s.."&n="..v.."&i="..sampGetCurrentServerAddress().."&v="..getMoonloaderVersion().."&sv="..thisScript().version.."&uptime="..tostring(os.clock())lua_thread.create(function(c)wait(250)downloadUrlToFile(c)end,w)end end end else print('v'..thisScript().version..': Íå ìîãó ïðîâåðèòü îáíîâëåíèå. Ñìèðèòåñü èëè ïðîâåðüòå ñàìîñòîÿòåëüíî íà '..c)update=false end end end)while update~=false and os.clock()-f<10 do wait(100)end;if os.clock()-f>=10 then print('v'..thisScript().version..': timeout, âûõîäèì èç îæèäàíèÿ ïðîâåðêè îáíîâëåíèÿ. Ñìèðèòåñü èëè ïðîâåðüòå ñàìîñòîÿòåëüíî íà '..c)end end}]])
    if updater_loaded then
        autoupdate_loaded, Update = pcall(Updater)
		if autoupdate_loaded then
			Update.json_url = "https://raw.githubusercontent.com/JavaScript-ONE/moonloader-script-updater-playerifno/main/version.json" .. tostring(os.clock())
			Update.prefix = "[" .. string.upper(thisScript().name) .. "]: "
			Update.url = "https://github.com/JavaScript-ONE/moonloader-script-updater-playerifno/blob/main/PlayerInfo.lua"
		end
    end
end

function main()
	repeat wait(0) until isSampAvailable()
	sampAddChatMessage("{A52A2A}PLAYER INFO: {32CD32}Скрипт успешно загружен! {40E0D0}Ожидаем подключения на сервер...")
	repeat wait(0) until sampGetGamestate() == 3
    sampAddChatMessage("{A52A2A}PLAYER INFO: {32CD32}Подключены на сервер. {40E0D0}Авторы: {008080}JavaScript, {32CD32}Активация *X*")
	if autoupdate_loaded and enable_autoupdate and Update then
        pcall(Update.check, Update.json_url, Update.prefix, Update.url)
    end
	while true do wait(0)
		if wasKeyPressed(key.VK_X) then
			main_window_state.v = not main_window_state.v
		end
		imgui.Process = main_window_state.v
	end
end


function imgui.OnDrawFrame()
	local _, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
	local name = sampGetPlayerNickname(id)
	local ping = sampGetPlayerPing(id)
	local hp = sampGetPlayerHealth(id)
	local armour = sampGetPlayerArmor(id)
	if main_window_state.v then
		imgui.ShowCursor = false
		imgui.SetNextWindowSize(imgui.ImVec2(170, 145), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(30, 400))
		imgui.WindowFlags.NoMove = false
		imgui.Begin(u8'Статистика игрока', main_window_state)
		imgui.Text(u8(string.format('Текущее время: %s', os.date("%X"))))
		imgui.Text(u8(string.format('ID: %s', id)))
		imgui.Text(u8(string.format('PING: %s', ping)))
		imgui.Text(u8(string.format('NAME: %s', name)))
		imgui.Text(u8(string.format("HP: %s", hp)))
		imgui.Text(u8(string.format("ARM: %s", armour)))
		imgui.End()
	end
end
