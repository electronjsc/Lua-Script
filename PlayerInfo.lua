require "lib.moonloader"
local imgui = require "imgui"
local inicfg = require "inicfg"
local mem = require "memory"
local encoding = require "encoding"
local key = require 'vkeys'
local ev = require "samp.events"
local ffi = require "ffi"
local dlstatus = require('moonloader').download_status
local getBonePosition = ffi.cast("int (__thiscall*)(void*, float*, int, bool)", 0x5E4280)
local main_window_state = imgui.ImBool(false)
---------------------------------------------------

local update_url = "https://github.com/JavaScript-ONE/moonloader-script-updater-playerifno/raw/main/update.ini"
local update_path = getWorkingDirectory() .. "/update.ini" 

local script_url = ""
local script_path = thisScript().path

local script_vers = 1
local script_vers_text = "1.0.1"

---------------------------------------------------
encoding.default = 'CP1251'
u8 = encoding.UTF8
script_name('moonloader-script-updater-playerifno')
script_author("JavaScript")
update_state = false
---------------------------------------------------


function main()

	repeat wait(0) until isSampAvailable()
	sampAddChatMessage("{A52A2A}PLAYER INFO: {32CD32}Успешно загружен! {40E0D0}Ожидаем подключения на сервер...")
	repeat wait(0) until sampGetGamestate() == 3
    sampAddChatMessage("{A52A2A}PLAYER INFO: {32CD32}Подключены. {40E0D0}Авторы: {008080}JavaScript, {32CD32}Активация *X*")
	sampAddChatMessage("{A52A2A}PLAYER INFO: {32CD32}Добавлена возможность смотреть модели Т/C, {32CD32} Активация *Z* - {A52A2A}NEW")
	downloadUrlToFile(update_url, update_path, function(id, status)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			updateIni = inicfg.load(nil, update_path)
			if tonumber(updateIni.info.vers) > script_vers then
				sampAddChatMessage("Имеется активное обновление, скачиваем! Версия ныншнего скрипта: v%s", script_vers_text, -1)
				update_state = true
			end
			os.remove(update_path)
		end
	end)
	
	
	while true do wait(0)
	
		if update_state then
			downloadUrlToFile(update_url, update_path, function(id, status)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then
					sampAddChatMessage("Обновление успешно скачалось, обновляем! Последняя версия скрипта: v" .. updateIni.info.vers_text)
					thisScript():reload()
				end
			end)
			break
		end
			
		if wasKeyPressed(key.VK_X) then
			main_window_state.v = not main_window_state.v
		end
		if isKeyDown(key.VK_Z) then
	   		activation = true
	   	else
	   		activation = false
	   	end
		imgui.Process = main_window_state.v
	end
end

--[[function ev.onShowDialog(dialogId, style, title, button1, button2, text)
	sampAddChatMessage(dialogId, -1)
end
]]
--[[
 function new()
	sampShowDialog(1999, "Новые обновления", "1.Добавлена команда /new(Просмотр обновлений).\n2. Добавлена возможность смотреть названия автомобилей(Активация Z).")
		wait(100)

		local result, button, list, input = sampHasDialogRespond(1999)
			if result then
				if button == 1 then
					if list == 0 then
						sampAddChatMessage("Данная команда была добавлена, для просмотра новых обновлений, вместе с описаннием тех.")
					end
					if list == 1 then
						sampAddChatMessage("При зажимании Z на клавиатуре, над автомобилем появиться белая надпись, и моделью транспорта.")
					end
				end
			end
		end
	end
end
]]
function imgui.OnDrawFrame()
	local _, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
	local name = sampGetPlayerNickname(id)
	local ping = sampGetPlayerPing(id)
	local hp = sampGetPlayerHealth(id)
	local armour = sampGetPlayerArmor(id)
	local money = getPlayerMoney(id)
	--if dialogId == 303 then
		--for line in text:gmatch("[^\n]+") do
			--if line:find('На вашем банковском счету: (%d+)$') then
				--local bank = line:match('На вашем банковском счету: (%d+)$')
				--if line:find('Наличные деньги: (%d+)$') then
					--local money = line:match('Деньги на банк.счёте: (%d+)$')
				--end
			--end
		--end
	--end
	if main_window_state.v then
		imgui.ShowCursor = false
		imgui.SetNextWindowSize(imgui.ImVec2(200, 230), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(30, 300))
		imgui.WindowFlags.NoMove = false
		imgui.Begin(u8'Статистика игрока', main_window_state)
		imgui.Text(u8(string.format('Текущее время: %s', os.date("%X"))))
		imgui.Text(u8(string.format('Текущая дата: %s', os.date("%x"))))
		imgui.Text(u8(string.format('ID: %s', id)))
		imgui.Text(u8(string.format('PING: %s', ping)))
		imgui.Text(u8(string.format('NAME: %s', name)))
		imgui.Text(u8(string.format('HP: %s', hp)))
		imgui.Text(u8(string.format('ARM: %s', armour)))
		--imgui.Text(u8(string.format('Наличные деньги: %s', money)))
		--imgui.Text(u8(string.format('Деньги на банк.счёте: %s', bank)))
		imgui.End()
	end
end

function getBodyPartCoordinates(id, handle)
  local pedptr = getCharPointer(handle)
  local vec = ffi.new("float[3]")
  getBonePosition(ffi.cast("void*", pedptr), vec, id, true)
  return vec[0], vec[1], vec[2]
end

lua_thread.create(function()
	font = renderCreateFont("Roboto", 9, 5)
	while true do
	wait(0)
	if activation then

	if isCharInAnyCar(PLAYER_PED) then
		mycar = getCarCharIsUsing(PLAYER_PED)
	end

    for _, handle in ipairs(getAllVehicles()) do
    	if handle ~= mycar and doesVehicleExist(handle) and isCarOnScreen(handle) then
      		vehName = getGxtText(getNameOfVehicleModel(getCarModel(handle)))
      			myX, myY, myZ = getBodyPartCoordinates(8, PLAYER_PED)
      			X, Y, Z = getCarCoordinates(handle)
      			result, point = processLineOfSight(myX, myY, myZ, X, Y, Z, true, false, false, true, false, false, false, false)
      			if not result then
      				distance = getDistanceBetweenCoords3d(X, Y, Z, myX, myY, myZ)
      				X, Y = convert3DCoordsToScreen(X, Y, Z + 1)
              _, id = sampGetVehicleIdByCarHandle(handle)
      				renderFontDrawText(font, vehName, X - 10, Y, -1)
      			end
      	end
  	end

  	end

  	end
end)