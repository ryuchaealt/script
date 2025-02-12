local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService") -- Studio 감지
local TweenService = game:GetService("TweenService")

local Trigger = script.Parent.Trigger
local DL = script.Parent.DFL
local DR = script.Parent.DFR
local Sound = script.Parent.DFR.A
local light = script.Parent.Parent.Parent.Body.DoorLight.L
local driveSeat = script.Parent.Parent.Parent.DriveSeat
local url = "https://raw.githubusercontent.com/ryu-chae/License/refs/heads/main/license.txt?token=GHSAT0AAAAAAC6VI36L2OYVYR2D5QCVEKBKZ5MOHBQ" -- TXT 파일 URL

local fdoortime = 3.8
local fdoortime1 = 4.5
local F = {}

if RunService:IsStudio() then
	print("유출방지시스템 | Studio 환경 감지 → 스크립트 실행 중지")
	return
end

-- 허용된 플레이스 목록 가져오기
local function getAllowedPlaces()
	local success, result = pcall(function()
		return HttpService:GetAsync(url)
	end)

	if not success then
		warn("유출방지시스템 | HTTP 요청 실패! (설정 확인 필요)")
		return nil -- HTTP 요청 실패 시 nil 반환
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

-- 현재 플레이스가 허용된 플레이스인지 확인
local function isAllowedPlace(allowedPlaces)
	if not allowedPlaces then
		return false -- HTTP 요청 실패 시 기본적으로 비허용 처리
	end

	for _, placeId in ipairs(allowedPlaces) do
		if game.PlaceId == placeId then
			print("유출방지시스템 | 차량 사용이 허가되었습니다.")
			return true
		end
	end
	return false
end

-- 차량 삭제 처리
local function checkAndDestroyVehicle()
	local allowedPlaces = getAllowedPlaces()
	if not isAllowedPlace(allowedPlaces) then
		print("유출방지시스템 | 비허용 플레이스 감지 → 차량 삭제")
		script.Parent.Parent.Parent:Destroy()
	end
end

-- 차량 삭제 여부 확인
checkAndDestroyVehicle()

-- 좌석에 License 스크립트 없으면 차량 삭제
if driveSeat then
	local licenseScript = driveSeat:FindFirstChild("License")
	if not licenseScript then
		script.Parent.Parent.Parent:Destroy()
	end
end

-- 문 여닫기 기능
F.DoorTrigger = function()
	if Trigger.Value == 0 then
		Trigger.Value = 1
	else
		Trigger.Value = 0
	end
end

Trigger.Changed:Connect(function ()
	if Trigger.Value == 1 then
		Sound.Open:Play()
		TweenService:Create(DL.A.DFL, TweenInfo.new(fdoortime, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
			["C0"] = CFrame.Angles(0, math.rad(-85), 0),
		}):Play()
		TweenService:Create(DL.Int.A.DFLI, TweenInfo.new(fdoortime, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
			["C0"] = CFrame.Angles(0, math.rad(170), 0),
		}):Play()
		TweenService:Create(DR.A.DFR, TweenInfo.new(fdoortime, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
			["C0"] = CFrame.Angles(0, math.rad(90), 0),
		}):Play()
		TweenService:Create(DR.Int.A.DFRI, TweenInfo.new(fdoortime, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
			["C0"] = CFrame.Angles(0, math.rad(180), 0),
		}):Play()
		wait(1)
		light.Transparency = 0
		light.L.Enabled = true
	else
		Sound.Close:Play()
		TweenService:Create(DL.A.DFL, TweenInfo.new(fdoortime1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
			["C0"] = CFrame.Angles(0, 0, 0),
		}):Play()
		TweenService:Create(DL.Int.A.DFLI, TweenInfo.new(fdoortime1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
			["C0"] = CFrame.Angles(0, 0, 0),
		}):Play()
		TweenService:Create(DR.A.DFR, TweenInfo.new(fdoortime1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
			["C0"] = CFrame.Angles(0, 0, 0),
		}):Play()
		TweenService:Create(DR.Int.A.DFRI, TweenInfo.new(fdoortime1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
			["C0"] = CFrame.Angles(0, 0, 0),
		}):Play()
		wait(fdoortime1 + 0.47)
		light.Transparency = 1
		light.L.Enabled = false
	end
end)

script.Parent.RemoteEvent.OnServerEvent:Connect(function(pl, Fnc, ...)
	F[Fnc](...)
end)
