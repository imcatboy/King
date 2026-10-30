local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StaffRanks = ReplicatedStorage.Screens.StaffRanks
local OverheadManager = require(ServerScriptService.Server.OverheadManager)
local RankService = require(ServerScriptService.Server.RankService)
local Constants = require(ReplicatedStorage.Shared.Constants)

Players.PlayerAdded:Connect(function(player: Player)
	player.CharacterAdded:Connect(function(character: Model)
		local role = RankService.GetRole(player)
		local candle = RankService.GetCandle(player)
		local staff = RankService.GetStaff(player)
		OverheadManager.GiveBillboard(player, role.Name)

		if role and role.Rank >= Constants.WARD_LEVEL then
			local staffRanks = StaffRanks:Clone()
			staffRanks.Parent = player.PlayerGui
		end

		if candle then
			candle:Clone().Parent = player.Backpack
		end

		if staff then
			staff:Clone().Parent = player.Backpack
		end

		if role and role.Rank >= Constants.JUG_OF_WATER_LEVEL then
			local jugOfWater = Constants.JUG_OF_WATER
			jugOfWater:Clone().Parent = player.Backpack
		end

		if role and role.Rank >= Constants.BELL_LEVEL then
			local bell = Constants.BELL
			bell:Clone().Parent = player.Backpack
		end
	end)

	player:LoadCharacterAsync()
end)
