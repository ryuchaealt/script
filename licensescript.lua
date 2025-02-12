local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService") -- Studio 환경 감지용
local url = "https://raw.githubusercontent.com/ryuchaealt/script/refs/heads/main/licenselist.txt" -- TXT 파일의 URL 변경

local function getAllowedPlaces()
	local success, result = pcall(function()
		return HttpService:GetAsync(url)
	end)

	if not success then
		warn("유출방지시스템 | HTTP 요청에 실패하였으니 설정에서 HTTP 요청을 켜주세요")
		return nil
	end

	local places = {}
	for placeId in result:gmatch("[^\r\n]+") do
		local id = tonumber(placeId)
		if id then
			table.insert(places, id)
		end
	end
	return places
end

local function isAllowedPlace(allowedPlaces)
	if not allowedPlaces then
		return false
	end

	for _, placeId in ipairs(allowedPlaces) do
		if game.PlaceId == placeId then
			print("유출방지시스템 | 차량 사용이 허가되었습니다.")
			return true
		end
	end
	return false
end

local allowedPlaces = getAllowedPlaces()

if not isAllowedPlace(allowedPlaces) then
	print("유출방지시스템 | HTTP 요청 실패 / 비허용 플레이스로 감지되었습니다. 차량이 삭제됩니다.")
	local vehicle = script.Parent.Parent
	vehicle:Destroy()
end
