local OverheadManager = {}
local ReplicatedStorage = game.ReplicatedStorage
local billboardTemplate = ReplicatedStorage.Billboards.OverheadBillboard

function OverheadManager.GiveBillboard(player: Player, role: string?, achievement: string?)
	local character = player.Character or player.CharacterAdded:Wait()
	local rootPart = character:WaitForChild("HumanoidRootPart")
	
	if not rootPart then return end

	local existing = rootPart:FindFirstChild("OverheadBillboard")
	if existing then existing:Destroy() end

	local billboard = billboardTemplate:Clone()
	billboard.Adornee = rootPart
	billboard.Parent = rootPart
	billboard.NameLabel.Text = player.Name
	
	if role then
		billboard.RoleLabel.Visible = true
		billboard.RoleLabel.Text = role
	else
		billboard.RoleLabel.Visible = false
	end
	
	if achievement then
		billboard.AchievementLabel.Visible = true
		billboard.AchievementLabel.Text = achievement
	else
		billboard.AchievementLabel.Visible = false
	end
	
	return billboard
end

return OverheadManager
