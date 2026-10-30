local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StaffRemote = ReplicatedStorage:WaitForChild("Remotes").StaffRemote
local BellRemote = ReplicatedStorage:WaitForChild("Remotes").BellRemote
local AnnounceRemote = ReplicatedStorage:WaitForChild("Remotes").AnnounceRemote
local RankRemote = ReplicatedStorage:WaitForChild("Remotes").RankRemote
local StaffService = require(script.Parent.StaffService)
local BellService = require(script.Parent.BellService)
local TimeService = require(script.Parent.TimeService)
local RankService = require(script.Parent.RankService)

StaffRemote.OnServerEvent:Connect(function(player: Player, action: string)
	print("Action handled" .. action)

	if action == "Attack" then
		StaffService.CheckHitbox(player)
	elseif action == "Carry" then
		StaffService.TryCarry(player)
	elseif action == "JugOfWater" then
		StaffService.TryJugOfWater(player)
	end
end)

BellRemote.OnServerEvent:Connect(function(player: Player)
	BellService:Ding(player)
end)

AnnounceRemote.OnServerEvent:Connect(function(player: Player, label: string, description: string)
	BellService:Announce(player, label, description)
end)

task.spawn(TimeService.Start)

RankRemote.OnServerEvent:Connect(function(player: Player, action: string)
	print("Action handled" .. action)
	
	if action == "SetWard" then
		RankService.SetWard(player)
	elseif action == "SetVengen" then
		RankService.SetVengen(player)
	elseif action == "RemoveImitation" then
		RankService.RemoveImitation(player)
	end
end)
