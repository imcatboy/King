local ActionService = {}

function ActionService:PlayAnimation(player: Player, animationId: string): AnimationTrack
	local character = player.Character
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	local track = humanoid:LoadAnimation(animation)
	track:Play()
	return track
end

function ActionService:PlaySound(soundId: string): Sound
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Parent = workspace
	sound:Play()
	return sound
end

return ActionService
