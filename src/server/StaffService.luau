local StaffService = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DeadBlackout = ReplicatedStorage:WaitForChild("Screens").DeadBlackout
local StaffRemote = ReplicatedStorage:WaitForChild("Remotes").StaffRemote
local Players = game:GetService("Players")
local RankService = require(script.Parent.RankService)
local Constants = require(ReplicatedStorage:WaitForChild("Shared").Constants)
local RagdollService = require(script.Parent:WaitForChild("RagdollService"))

local KNOCKBACK_FORCE = 12
local KNOCKBACK_LIFT = 4
local KNOCKBACK_SPIN = 20

function StaffService.CheckHitbox(player: Player)
	print("Checking hitbox")
	local character = player.Character
	local overlapParams = OverlapParams.new()
	overlapParams:AddToFilter(character)
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	local parts = workspace:GetPartBoundsInRadius(character.PrimaryPart.Position, 4, overlapParams)

	for _, part in parts do
		local enemyCharacter = part.Parent
		local humanoid = enemyCharacter:FindFirstChildOfClass("Humanoid")

		if not humanoid or enemyCharacter == character then
			continue
		end

		local enemyPlayer = Players:GetPlayerFromCharacter(enemyCharacter)
		local enemyPlayerGUI = enemyPlayer and enemyPlayer:FindFirstChild("PlayerGui")
		local rank = RankService.GetRank(player)
		local enemyRank = RankService.GetRank(enemyPlayer)

		if enemyRank > rank then
			continue
		end

		if enemyPlayerGUI and not enemyPlayerGUI:FindFirstChild("DeadBlackout") then
			local blackOut = DeadBlackout:Clone()
			blackOut.Parent = enemyPlayerGUI
		end

		RagdollService.Ragdoll(enemyCharacter)

		local enemyRoot = humanoid.RootPart

		if not enemyRoot then
			continue
		end

		local direction = enemyRoot.Position - character.PrimaryPart.Position
		direction = Vector3.new(direction.X, 0, direction.Z)

		if direction.Magnitude < 0.01 then
			direction = character.PrimaryPart.CFrame.LookVector
		end
		direction = direction.Unit

		local mass = enemyRoot.AssemblyMass
		enemyRoot:ApplyImpulse((direction * KNOCKBACK_FORCE + Vector3.new(0, KNOCKBACK_LIFT, 0)) * mass)
		enemyRoot:ApplyAngularImpulse(direction:Cross(Vector3.yAxis) * KNOCKBACK_SPIN * mass)
		print("Hit enemy")
		break
	end
end

function StaffService.TryCarry(player: Player)
	print("Trying to carry")
	local character = player.Character
	local rootPart: Part? = character and character:FindFirstChild("HumanoidRootPart")
	local currentlyCarrying: string? = character:GetAttribute("CarryingPlayer")

	if not rootPart then
		print("No root part")
		return
	end

	if currentlyCarrying then
		print("Already carrying someone, dropping them...")
		local enemy = game.Players:FindFirstChild(currentlyCarrying)
		local enemyCharacter = enemy and enemy.Character

		if not enemyCharacter then
			print("No enemy character found")
			return
		end

		local enemyRoot: BasePart? = enemyCharacter:FindFirstChild("HumanoidRootPart")
		local weld = rootPart:FindFirstChild("CarryWeld")
		if weld then
			weld:Destroy()
		end

		if enemyRoot then
			enemyRoot.CFrame = rootPart.CFrame * CFrame.new(0, 1, -3)
		end

		RagdollService.Ragdoll(enemyCharacter)
		character:SetAttribute("CarryingPlayer", nil)
		StaffRemote:FireClient(player, "StopCarry")
		return
	end

	for _, enemy in Players:GetPlayers() do
		if enemy == player then
			print("Skipping self")
			continue
		end

		local enemyCharacter = enemy.Character
		local humanoid = enemyCharacter and enemyCharacter:FindFirstChildOfClass("Humanoid")
		local enemyRoot: BasePart? = humanoid and humanoid.RootPart

		if not humanoid or not enemyRoot then
			print("No humanoid found")
			continue
		end

		if not enemyCharacter:GetAttribute("IsRagdolled") or enemyCharacter:GetAttribute("IsCarried") then
			print("Enemy is not down")
			continue
		end

		local distance = (rootPart.Position - enemyRoot.Position).Magnitude
		print("Distance", distance)

		if distance > Constants.CARRY_DISTANCE then
			print("Enemy too far to carry")
			continue
		end

		print("Carrying enemy")
		StaffRemote:FireClient(player, "PlayCarryAnim")
		RagdollService.Hold(enemyCharacter)
		StaffRemote:FireClient(enemy, "FreezeAnimations")
		enemyRoot.CFrame = rootPart.CFrame * CFrame.new(0, 0, -2)

		local carryWeld = Instance.new("WeldConstraint")
		carryWeld.Name = "CarryWeld"
		carryWeld.Part0 = rootPart
		carryWeld.Part1 = enemyRoot
		carryWeld.Parent = rootPart

		character:SetAttribute("CarryingPlayer", enemy.Name)
		StaffRemote:FireClient(player, "PlayCarryAnim")
		break
	end
end

function StaffService.TryJugOfWater(player: Player)
	if RankService.GetRank(player) < Constants.JUG_OF_WATER_LEVEL then
		print("Player is not staff")
		return
	end

	print("Trying to use jug of water")
	local character = player.Character
	local overlapParams = OverlapParams.new()
	overlapParams:AddToFilter(character)
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	local parts = workspace:GetPartBoundsInRadius(character.PrimaryPart.Position, 4, overlapParams)

	for _, part in parts do
		local enemyCharacter = part.Parent
		local humanoid = enemyCharacter:FindFirstChildOfClass("Humanoid")

		if not humanoid or enemyCharacter == character then
			print("No humanoid or self")
			continue
		end

		if not enemyCharacter:GetAttribute("IsRagdolled") then
			print("Enemy is not ragdolled")
			continue
		end

		local enemyPlayer = Players:GetPlayerFromCharacter(enemyCharacter)
		local enemyPlayerGUI = enemyPlayer and enemyPlayer:FindFirstChild("PlayerGui")
		local deadBlackout = enemyPlayerGUI and enemyPlayerGUI:FindFirstChild("DeadBlackout")

		if deadBlackout then
			deadBlackout:Destroy()
		end

		print("Recovering enemy from ragdoll")
		RagdollService.RecoverFromRagdoll(enemyCharacter)
	end
end

return StaffService
