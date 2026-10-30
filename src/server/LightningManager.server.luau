local workspace = game:GetService("Workspace")
local alarm = false
local power = true
local alarmParts = {}
local alarmLights = {}
local powerParts = {}
local powerLights = {}

for _, child in ipairs(workspace:GetDescendants()) do
	if child.Name == "Alarm" then
		table.insert(alarmParts, child)
	end

	if child.Name == "AlarmModel" then
		table.insert(alarmLights, child)
	end

	if child.Name == "Power" then
		table.insert(powerParts, child)
	end

	if child.Name == "Wall" then
		table.insert(powerLights, child)
	end
end

for _, alarmPart in ipairs(alarmParts) do
	local clickDetector = alarmPart:FindFirstChildWhichIsA("ClickDetector", true)

	if not clickDetector then
		print("No ClickDetector found for alarm part: ", alarmPart.Name)
		continue
	end

	clickDetector.MouseClick:Connect(function()
		print("Alarm clicked, current state: ", alarm)
		alarm = not alarm

		if alarm then
			clickDetector.Parent.Color = Color3.fromRGB(75, 151, 75)
		else
			clickDetector.Parent.Color = Color3.fromRGB(151, 0, 0)
		end

		for _, alarmLight in ipairs(alarmLights) do
			local glass: MeshPart = alarmLight:FindFirstChild("AlarmGlass", true)
			local sound: Sound = alarmLight:FindFirstChild("AlarmSound", true)

			if not glass or not sound then
				print("Missing glass or sound for alarm light: ", alarmLight.Name)
				continue
			end

			for _, part in ipairs(alarmLight:GetDescendants()) do
				if part.Name ~= "AlarmLight" then
					continue
				end

				if alarm then
					part.Enabled = true
				else
					part.Enabled = false
				end
			end

			if alarm then
				print("Alarm turned on for glass: ", glass.Name)
				glass.Material = Enum.Material.Neon
				task.spawn(function()
					while alarm and glass and glass.Parent do
						local deltaTime = task.wait()
						glass.CFrame = glass.CFrame * CFrame.Angles(0, math.rad(180 * deltaTime), 0)
					end
				end)
				sound:Play()
			else
				glass.Material = Enum.Material.Glass
				sound:Stop()
			end
		end
	end)
end

for _, powerPart in ipairs(powerParts) do
	local clickDetector = powerPart:FindFirstChildWhichIsA("ClickDetector", true)

	if not clickDetector then
		print("No ClickDetector found for power part: ", powerPart.Name)
		continue
	end

	clickDetector.MouseClick:Connect(function()
		print("Power clicked, current state: ", power)
		power = not power

		if power then
			clickDetector.Parent.Color = Color3.fromRGB(75, 151, 75)
		else
			clickDetector.Parent.Color = Color3.fromRGB(151, 0, 0)
		end

		for _, powerLight in ipairs(powerLights) do
			if power then
				powerLight.Enabled = true
			else
				powerLight.Enabled = false
			end
		end
	end)
end
