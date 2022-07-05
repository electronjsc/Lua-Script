require "lib.moonloader"
local imgui = require "imgui"
local mem = require "memory"
local encoding = require "encoding"
local key = require 'vkeys'
local ev = require "samp.events"
local main_window_state = imgui.ImBool(false)
local fps = "-"
---------------------------------------------------

---------------------------------------------------
encoding.default = 'CP1251'
u8 = encoding.UTF8
script_name('INFO PLAYER')
script_author('JavaScript')
---------------------------------------------------

function main()
	repeat wait(0) until isSampAvailable()
	sampAddChatMessage("{A52A2A}PLAYER INFO: {32CD32}Успешно загружен! {40E0D0}Ожидаем подключения на сервер...")
	repeat wait(0) until sampGetGamestate() == 3
    sampAddChatMessage("{A52A2A}PLAYER INFO: {32CD32}Подключены. {40E0D0}Авторы: {008080}JavaScript, {32CD32}Активация *X*")
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
