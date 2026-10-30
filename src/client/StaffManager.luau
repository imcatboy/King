local StaffManager = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage.Shared.Constants)
local StaffRemote = ReplicatedStorage:WaitForChild("Remotes").StaffRemote
local player = game.Players.LocalPlayer
local carryAnimationTrack: AnimationTrack

local function playAnimation(animationId: string)
	print("Playing animation " .. animationId)
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	local animator: Animator = humanoid:WaitForChild("Animator")
	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	local animationTrack = animator:LoadAnimation(animation)
	animationTrack.Priority = Enum.AnimationPriority.Action4
	animationTrack:Play()

	if animationId == Constants.ANIMATIONS.StaffCarry then
		if carryAnimationTrack then
			carryAnimationTrack:Stop(0)
		end
		carryAnimationTrack = animationTrack
	end
end

function StaffManager.RequestAttack()
	playAnimation(Constants.ANIMATIONS.StaffAttack)
	StaffRemote:FireServer("Attack")
	print("Requested attack")
end

function StaffManager.RequestCarry()
	StaffRemote:FireServer("Carry")
	print("Requested carry")
end

function StaffManager.RequestJugOfWater()
	playAnimation(Constants.ANIMATIONS.JugOfWater)
	StaffRemote:FireServer("JugOfWater")
	print("Requested jug of water")
end

StaffRemote.OnClientEvent:Connect(function(action)
	if action == "StopCarry" then
		if carryAnimationTrack then
			carryAnimationTrack:Stop(0)
			carryAnimationTrack:Destroy()
		end
		print("Stopping carry animation")
	elseif action == "PlayCarryAnim" then
		playAnimation(Constants.ANIMATIONS.StaffCarry)
	elseif action == "FreezeAnimations" then
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
		if animator then
			for _, track in animator:GetPlayingAnimationTracks() do
				track:Stop(0)
			end
		end
	end
end)

return StaffManager
