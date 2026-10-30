local BellService = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AnnounceRemote = ReplicatedStorage:WaitForChild("Remotes").AnnounceRemote
local ServerScriptService = game:GetService("ServerScriptService")
local TextService = game:GetService("TextService")
local BellWarningGui = ReplicatedStorage:WaitForChild("Billboards").BellWarning
local RankService = require(ServerScriptService.Server.RankService)
local Constants = require(ReplicatedStorage.Shared.Constants)
local bellTimeout = false
local announceTimeout = false

local function highlightPlayer(player: Player)
	local character = player.Character
	local highlight = Instance.new("Highlight")
	highlight.Adornee = character
	highlight.Parent = workspace
	task.delay(10, function()
		highlight:Destroy()
	end)
end

local function BellWarning(player: Player)
	if RankService.GetRank(player) < Constants.BELL_LEVEL then
		print("Player does not have the required rank for bell warning:", player.Name)
		return
	end

	local character = player.Character

	if not character then
		print("Character not found for player:", player.Name)
		return
	end

	local rootPart: Part = character:WaitForChild("HumanoidRootPart")

	if not rootPart then
		print("HumanoidRootPart not found for player:", player.Name)
		return
	end

	print("Highlighting player and creating bell warning for player:", player.Name)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CFrame = rootPart.CFrame
	part.Parent = workspace
	part.Transparency = 1
	local billboard = BellWarningGui:Clone()
	billboard.Adornee = part
	billboard.Parent = workspace
	task.delay(60, function()
		part:Destroy()
		billboard:Destroy()
		bellTimeout = false
	end)
end

function BellService:Ding(player: Player)
	if bellTimeout then
		return
	end

	bellTimeout = true
	highlightPlayer(player)
	BellWarning(player)
end

function BellService:Announce(player: Player, label: string, description: string)
	if RankService.GetRank(player) < Constants.BELL_LEVEL then
		print("Player does not have the required rank for announce:", player.Name)
		return
	end

	if label:len() > 15 or label:len() == 0 or description:len() == 0 or description:len() > 375 then
		print("Label or description is invalid for player:", player.Name)
		return
	end

	if announceTimeout then
		print("Announce is on timeout for player:", player.Name)
		return
	end

	announceTimeout = true
	local role = RankService.GetRole(player)

	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		local Gui = targetPlayer:WaitForChild("PlayerGui"):FindFirstChild("Announcements")

		if not Gui then
			print("Announcements GUI not found for player:", targetPlayer.Name)
			continue
		end

		local filteredLabel = TextService:FilterStringAsync(label, player.UserId, Enum.TextFilterContext.PublicChat)
		local filteredDescription =
			TextService:FilterStringAsync(description, player.UserId, Enum.TextFilterContext.PublicChat)
		label = filteredLabel:GetNonChatStringForBroadcastAsync()
		description = filteredDescription:GetNonChatStringForBroadcastAsync()
		local thumbType = Enum.ThumbnailType.AvatarBust
		local thumbSize = Enum.ThumbnailSize.Size420x420
		local content, _ = Players:GetUserThumbnailAsync(player.UserId, thumbType, thumbSize)
		AnnounceRemote:FireClient(targetPlayer, role.Name, player.Name, content, label, description)

		task.delay(17, function()
			announceTimeout = false
		end)
	end
end

return BellService
