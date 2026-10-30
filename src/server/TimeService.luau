local TimeService = {}

local Constants = require(game:GetService("ReplicatedStorage").Shared.Constants)
local Lighting = game:GetService("Lighting")
local currentMinutes = Constants.START_DAY_MINUTES
local currentHour = math.floor(currentMinutes / 60)
local TweenService = game:GetService("TweenService")
local currentSound: Sound
local currentEmbient: Sound

function TimeService.AddHour()
	print("New hour: " .. currentHour)

	if Constants.TIME_SOUNDS[currentHour] then
		print("Found time sound for hour: " .. currentHour)

		if currentSound then
			TimeService.EndSound(currentSound)
		end

		local soundIds = Constants.TIME_SOUNDS[currentHour]
		local randomSoundId = soundIds[math.random(1, #soundIds)]
		currentSound = Instance.new("Sound")
		currentSound.SoundId = randomSoundId
		currentSound.Looped = true
		currentSound.Volume = 0
		currentSound.Parent = workspace
		local currentTween = TweenService:Create(currentSound, TweenInfo.new(2), { Volume = 0.2 })
		print("Playing sound for hour: " .. currentHour)
		currentSound:Play()
		currentTween:Play()
	end
end

function TimeService.EndSound(sound: Sound)
	local tween = TweenService:Create(sound, TweenInfo.new(2), { Volume = 0 })
	tween:Play()
	tween.Completed:Wait()
	sound:Stop()
	sound:Destroy()
end

function TimeService.RandomEmbient()
	print("Checking for random embient sounds at hour: " .. currentHour)

	for _, randomEmbient in ipairs(Constants.RANDOM_AMBIENT_SOUNDS) do
		if randomEmbient.startTime >= currentHour and randomEmbient.endTime <= currentHour then
			continue
		end

		if currentEmbient then
			currentEmbient:Stop()
			currentEmbient:Destroy()
		end

		currentEmbient = Instance.new("Sound")
		currentEmbient.SoundId = randomEmbient.soundId
		currentEmbient.Parent = workspace
		print("Playing random embient sound: " .. randomEmbient.soundId)
		currentEmbient:Play()
	end
end

function TimeService.Start()
	print("Starting TimeService at hour: " .. currentMinutes / 60)

	while true do
		if currentMinutes % 60 == 0 then
			TimeService.AddHour()
			TimeService.RandomEmbient()
		end

		currentMinutes = currentMinutes + 1
		Lighting.ClockTime = currentMinutes / 60
		currentHour = math.floor(currentMinutes / 60)

		if currentMinutes == 1440 then
			currentMinutes = 0
		end

		task.wait(1)
	end
end

return TimeService
