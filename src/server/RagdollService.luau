local RagdollService = {}

local ServerStorage = game:GetService("ServerStorage")
local storage = ServerStorage:WaitForChild("BackPackStorage")

type MotorState = {
	motor: Motor6D,
	wasEnabled: boolean,
}

type PartState = {
	part: BasePart,
	canCollide: boolean,
	massless: boolean,
}

type RagdollState = {
	humanoid: Humanoid,
	motors: { MotorState },
	attachments: { Attachment },
	constraints: { Instance },
	parts: { PartState },
	platformStand: boolean,
	autoRotate: boolean,
	requiresNeck: boolean,
	gettingUpEnabled: boolean,
	animateWasEnabled: boolean?,
}

local ragdollStates: { [Model]: RagdollState } = {}

local DEFAULT_LIMITS = { upper = 70, twist = 45 }
local JOINT_LIMITS = {
	Neck = { upper = 40, twist = 30 },
	Waist = { upper = 30, twist = 20 },
	Shoulder = { upper = 110, twist = 60 },
	Hip = { upper = 90, twist = 30 },
	Elbow = { upper = 90, twist = 10 },
	Knee = { upper = 90, twist = 10 },
}

local function getLimits(motorName: string)
	for key, limits in JOINT_LIMITS do
		if motorName:find(key) then
			return limits
		end
	end
	return DEFAULT_LIMITS
end

local function destroyJoints(state: RagdollState)
	for _, constraint in state.constraints do
		constraint:Destroy()
	end
	for _, attachment in state.attachments do
		attachment:Destroy()
	end
	table.clear(state.constraints)
	table.clear(state.attachments)
end

local function setServerOwned(humanoid: Humanoid, serverOwned: boolean)
	local root = humanoid.RootPart
	if not root or root.Anchored then
		return
	end
	pcall(function()
		if serverOwned then
			root:SetNetworkOwner(nil)
		else
			root:SetNetworkOwnershipAuto()
		end
	end)
end

function RagdollService.Ragdoll(character: Model): boolean
	if ragdollStates[character] then
		if not character:GetAttribute("IsCarried") then
			return true
		end

		RagdollService.RecoverFromRagdoll(character)
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local player = game.Players:GetPlayerFromCharacter(character)

	if not humanoid or humanoid.RigType ~= Enum.HumanoidRigType.R15 then
		return false
	end

	local state: RagdollState = {
		humanoid = humanoid,
		motors = {},
		attachments = {},
		constraints = {},
		parts = {},
		platformStand = humanoid.PlatformStand,
		autoRotate = humanoid.AutoRotate,
		requiresNeck = humanoid.RequiresNeck,
		gettingUpEnabled = humanoid:GetStateEnabled(Enum.HumanoidStateType.GettingUp),
	}
	ragdollStates[character] = state
	humanoid.RequiresNeck = false
	humanoid.AutoRotate = false
	humanoid.PlatformStand = true
	humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)

	for _, descendant in character:GetDescendants() do
		if descendant:IsA("BasePart") and descendant.Parent == character then
			table.insert(state.parts, {
				part = descendant,
				canCollide = descendant.CanCollide,
				massless = descendant.Massless,
			})
			descendant.CanCollide = descendant.Name ~= "HumanoidRootPart"
		elseif
			descendant:IsA("Motor6D")
			and descendant.Part0
			and descendant.Part1
			and descendant.Part0.Name ~= "HumanoidRootPart"
			and descendant.Part1.Name ~= "HumanoidRootPart"
		then
			local attachment0 = Instance.new("Attachment")
			attachment0.Name = "RagdollAttachment0"
			attachment0.CFrame = descendant.C0
			attachment0.Parent = descendant.Part0

			local attachment1 = Instance.new("Attachment")
			attachment1.Name = "RagdollAttachment1"
			attachment1.CFrame = descendant.C1
			attachment1.Parent = descendant.Part1

			local constraint = Instance.new("BallSocketConstraint")
			constraint.Name = "RagdollConstraint"
			constraint.Attachment0 = attachment0
			constraint.Attachment1 = attachment1
			local limits = getLimits(descendant.Name)
			constraint.LimitsEnabled = true
			constraint.UpperAngle = limits.upper
			constraint.TwistLimitsEnabled = true
			constraint.TwistLowerAngle = -limits.twist
			constraint.TwistUpperAngle = limits.twist
			constraint.Parent = descendant.Part0

			local noCollision = Instance.new("NoCollisionConstraint")
			noCollision.Name = "RagdollNoCollision"
			noCollision.Part0 = descendant.Part0
			noCollision.Part1 = descendant.Part1
			noCollision.Parent = descendant.Part0
			table.insert(state.constraints, noCollision)

			table.insert(state.motors, {
				motor = descendant,
				wasEnabled = descendant.Enabled,
			})
			table.insert(state.attachments, attachment0)
			table.insert(state.attachments, attachment1)
			table.insert(state.constraints, constraint)
			descendant.Enabled = false
		end
	end

	character:SetAttribute("IsRagdolled", true)
	setServerOwned(humanoid, true)
	RagdollService.LockInventory(player)
	humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	return true
end

function RagdollService.Hold(character: Model): boolean
	local state = ragdollStates[character]
	if not state then
		return false
	end

	for _, motorState in state.motors do
		if motorState.motor.Parent then
			motorState.motor.Enabled = true
		end
	end
	destroyJoints(state)

	for _, partState in state.parts do
		if partState.part.Parent then
			partState.part.CanCollide = false
			partState.part.Massless = true
		end
	end

	local animate = character:FindFirstChild("Animate")
	if animate and animate:IsA("LocalScript") then
		state.animateWasEnabled = animate.Enabled
		animate.Enabled = false
	end

	character:SetAttribute("IsCarried", true)
	return true
end

function RagdollService.RecoverFromRagdoll(character: Model): boolean
	local player = game.Players:GetPlayerFromCharacter(character)
	local state = ragdollStates[character]
	local humanoid = state.humanoid
	local animate = character:FindFirstChild("Animate")

	if not state then
		return false
	end

	for _, motorState in state.motors do
		if motorState.motor.Parent then
			motorState.motor.Enabled = motorState.wasEnabled
		end
	end

	destroyJoints(state)

	for _, partState in state.parts do
		if partState.part.Parent then
			partState.part.CanCollide = partState.canCollide
			partState.part.Massless = partState.massless
		end
	end

	if animate and animate:IsA("LocalScript") and state.animateWasEnabled ~= nil then
		animate.Enabled = state.animateWasEnabled
	end

	if humanoid.Parent then
		setServerOwned(humanoid, false)
		humanoid.RequiresNeck = state.requiresNeck
		humanoid.AutoRotate = state.autoRotate
		humanoid.PlatformStand = state.platformStand
		humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, state.gettingUpEnabled)
		if humanoid.Health > 0 and state.gettingUpEnabled and not state.platformStand then
			humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
	end

	ragdollStates[character] = nil
	character:SetAttribute("IsRagdolled", false)
	character:SetAttribute("IsCarried", nil)
	RagdollService.UnlockInventory(player)
	return true
end

function RagdollService.LockInventory(player: Player)
	local character = player.Character
	local backpack = player.Backpack
	local playerContainer = Instance.new("Folder")
	playerContainer.Name = tostring(player.UserId)
	playerContainer.Parent = storage

	if character then
		for _, item in ipairs(character:GetChildren()) do
			if item:IsA("Tool") then
				item.Parent = playerContainer
			end
		end
	end

	for _, item in ipairs(backpack:GetChildren()) do
		if item:IsA("Tool") then
			item.Parent = playerContainer
		end
	end
end

function RagdollService.UnlockInventory(player: Player)
	local backpack = player:FindFirstChild("Backpack")
	local playerContainer = storage:FindFirstChild(tostring(player.UserId))

	if backpack and playerContainer then
		for _, item in ipairs(playerContainer:GetChildren()) do
			item.Parent = backpack
		end

		playerContainer:Destroy()
	end
end

return RagdollService
