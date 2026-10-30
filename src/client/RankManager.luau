local RankManager = {}

local RankRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes").RankRemote

function RankManager.SetWard()
	RankRemote:FireServer("SetWard")
end

function RankManager.SetVengen()
	RankRemote:FireServer("SetVengen")
end

function RankManager.RemoveImitation()
	RankRemote:FireServer("RemoveImitation")
end

return RankManager
