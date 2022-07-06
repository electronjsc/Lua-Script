script_name('Vehicle Info')
script_author("Nishikinov")
local memory = require "memory"
local ffi = require "ffi"
local getBonePosition = ffi.cast("int (__thiscall*)(void*, float*, int, bool)", 0x5E4280)


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

function main()
	if not isSampLoaded() then return end
	while not isSampAvailable() do wait(100) end
	   sampAddChatMessage("", - 1)
	   while true do
	   	wait(0)
	   	if isKeyDown(88) then
	   		activation = true
	   	else
	   		activation = false
	   	end
	   end
end
