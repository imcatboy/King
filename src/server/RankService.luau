local RankService = {}

type GroupRoleInfo = {
	Name: string,
	Rank: number,
	Id: number,
}

type GroupRolesList = { Roles: { GroupRoleInfo }, IsMember: boolean }

local imitationUsers: { [number]: GroupRoleInfo } = {}

local GroupService = game:GetService("GroupService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage.Shared.Constants)
local timeouts: { [number]: boolean } = {}

local function getRank(player: Player): number
	local success, roles: GroupRolesList = pcall(function()
		return GroupService:GetRolesInGroupAsync(player.User, Constants.GROUP_ID)
	end)

	if success and #roles.Roles > 0 then
		return roles.Roles[1].Rank
	else
		return 0
	end
end

local function getRole(player: Player): GroupRoleInfo
	local success, roles: GroupRolesList = pcall(function()
		return GroupService:GetRolesInGroupAsync(player.User, Constants.GROUP_ID)
	end)

	if success and #roles.Roles > 0 then
		return roles.Roles[1]
	end

	if roles.IsMember then
		return { Name = Constants.GUEST_ROLE, Rank = 1, Id = 0 }
	else
		return { Name = Constants.GUEST_ROLE, Rank = 0, Id = 0 }
	end
end

function RankService.GetRank(player: Player): number
	if imitationUsers[player.UserId] then
		return imitationUsers[player.UserId].Rank
	end

	return getRank(player)
end

function RankService.IsMember(player: Player): boolean
	if imitationUsers[player.UserId] then
		return true
	end

	local success, roles: GroupRolesList = pcall(function()
		return GroupService:GetRolesInGroupAsync(player.User, Constants.GROUP_ID)
	end)

	return success and roles.IsMember
end

function RankService.GetRole(player: Player): GroupRoleInfo
	if imitationUsers[player.UserId] then
		return imitationUsers[player.UserId]
	end

	return getRole(player)
end

function RankService.GetCandle(player: Player): Tool
	local role = RankService.GetRole(player)
	local candle = nil
	local maxLevel = -1

	for rank, item in pairs(Constants.CANDLE_LEVELS) do
		if role.Rank >= rank and rank > maxLevel then
			candle = item
			maxLevel = rank
		end
	end

	return candle
end

function RankService.GetStaff(player: Player): Tool
	local role = RankService.GetRole(player)
	local staff = nil
	local maxLevel = -1

	for rank, item in pairs(Constants.STAFF_LEVELS) do
		if role.Rank >= rank and rank > maxLevel then
			staff = item
			maxLevel = rank
		end
	end

	return staff
end

function RankService.SetWard(player: Player)
	print("Setting Ward for player:", player.Name)
	local rank = getRank(player)

	if timeouts[player.UserId] then
		print("Player is in timeout")
		return
	end

	if Constants.IMITATION_LEVEL > rank then
		print("Rank is lower than imitation level")
		return
	end

	if rank >= Constants.PRESTIGE_LEVEL then
		imitationUsers[player.UserId] =
			{ Name = Constants.WARD_PRESIGE_ROLE, Rank = Constants.WARD_PRESIGE_LEVEL, Id = 0 }
	else
		imitationUsers[player.UserId] = { Name = Constants.WARD_ROLE, Rank = Constants.WARD_LEVEL, Id = 0 }
	end
	player:LoadCharacterAsync()
	timeouts[player.UserId] = true
	task.delay(600, function()
		timeouts[player.UserId] = false
	end)
end

function RankService.SetVengen(player: Player)
	print("Setting Vengen for player:", player.Name)
	local rank = getRank(player)

	if timeouts[player.UserId] then
		print("Player is in timeout")
		return
	end

	if Constants.IMITATION_LEVEL > rank then
		print("Rank is lower than imitation level")
		return
	end

	local success, hasPass = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, Constants.VERGEN_GAMEPASS_ID)
	end)

	if not success or not hasPass then
		return
	end

	imitationUsers[player.UserId] = { Name = Constants.VERGEN_ROLE, Rank = Constants.VERGEN_LEVEL, Id = 0 }
	player:LoadCharacterAsync()
	timeouts[player.UserId] = true
	task.delay(600, function()
		timeouts[player.UserId] = false
	end)
end

function RankService.RemoveImitation(player: Player)
	print("Removing imitation for player:", player.Name)
	imitationUsers[player.UserId] = nil
	player:LoadCharacterAsync()
end

return RankService
