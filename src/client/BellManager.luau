local BellManager = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BellRemote = ReplicatedStorage:WaitForChild("Remotes").BellRemote
local AnnounceRemote = ReplicatedStorage:WaitForChild("Remotes").AnnounceRemote
local LocalPlayer = game:GetService("Players").LocalPlayer
local TweenService = game:GetService("TweenService")
local BellGui: ScreenGui = LocalPlayer:WaitForChild("PlayerGui").BellGui
local Constants = require(ReplicatedStorage.Shared.Constants)
local ActionService = require(ReplicatedStorage.Shared.ActionService)
local bellTimeout = false
local announceTimeout = false

function BellManager.Open()
	BellGui.Enabled = true
end

function BellManager.Close()
	BellGui.Enabled = false
end

function BellManager.Ding()
	if bellTimeout then
		return
	end

	bellTimeout = true
	ActionService:PlaySound(Constants.SOUNDS.Bell)
	ActionService:PlayAnimation(LocalPlayer, Constants.ANIMATIONS.Bell)
	BellRemote:FireServer()
	task.delay(60, function()
		bellTimeout = false
	end)
end

function BellManager.Announce(label: string, description: string)
	if announceTimeout then
		return
	end

	announceTimeout = true
	ActionService:PlayAnimation(LocalPlayer, Constants.ANIMATIONS.Bell)
	AnnounceRemote:FireServer(label, description)
	task.delay(17, function()
		announceTimeout = false
	end)
end

AnnounceRemote.OnClientEvent:Connect(
	function(role: string, name: string, avatar: string, label: string, description: string)
		local Gui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("Announcements")
		local container = Gui.Container
		container.Position = UDim2.new(0, 0, -0.5, 0)
		local tween = TweenService:Create(container, TweenInfo.new(0.5), { Position = UDim2.new(0, 0, 0, 0) })
		container.AnnounceFrame.SenderNickname.Text = name
		container.AnnounceFrame.SenderRole.Text = role
		container.AnnounceFrame.AnnounceTitle.Text = label
		container.Announce.AnnounceDescription.Text = description
		container.AnnounceSender.Image = avatar
		Gui.Enabled = true
		tween:Play()
		local sound = ActionService:PlaySound(Constants.SOUNDS.Announce)

		task.delay(15, function()
			local tweenOut = TweenService:Create(container, TweenInfo.new(0.5), { Position = UDim2.new(0, 0, -0.5, 0) })
			tweenOut:Play()
			sound:Stop()
			sound:Destroy()
			tweenOut.Completed:Wait()
			Gui.Enabled = false
		end)
	end
)

return BellManager
