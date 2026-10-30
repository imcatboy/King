local Constants = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

Constants.GROUP_ID = 231914480
Constants.GUEST_ROLE = "🕯️ Admitee"
Constants.MEMBER_ROLE = "🕯️ Admitee"
Constants.CARRY_DISTANCE = 10
Constants.CANDLE_LEVELS = {
	[0] = ReplicatedStorage.Items.Candle,
	[1] = ReplicatedStorage.Items.BetterCandle,
	[30] = ReplicatedStorage.Items.WardCandle,
	[64] = ReplicatedStorage.Items.PrestigiousMeltedCandles,
	[75] = ReplicatedStorage.Items.NannyCandles,
	[150] = ReplicatedStorage.Items.ExcellentCandles,
	[238] = ReplicatedStorage.Items.LuxuryCandles,
	[246] = ReplicatedStorage.Items.RoyalCouncilCandles,
}
Constants.STAFF_LEVELS = {
	[0] = ReplicatedStorage.Items.SimpleStaff,
	[150] = ReplicatedStorage.Items.AwesomeStaff,
	[238] = ReplicatedStorage.Items.LuxuriousStaff,
	[246] = ReplicatedStorage.Items.GreatStaff,
}
Constants.JUG_OF_WATER = ReplicatedStorage.Items.JugOfWater
Constants.JUG_OF_WATER_LEVEL = 0
Constants.BELL = ReplicatedStorage.Items.EUSBell
Constants.BELL_LEVEL = 0
Constants.IMITATION_LEVEL = 0
Constants.WARD_ROLE = "🥀 Ward"
Constants.WARD_LEVEL = 30
Constants.PRESTIGE_LEVEL = 238
Constants.WARD_PRESIGE_ROLE = "⚜️ Prestigious Ward"
Constants.WARD_PRESIGE_LEVEL = 64
Constants.VERGEN_ROLE = "🪦 Vengeful Ward"
Constants.VERGEN_LEVEL = 50
Constants.VERGEN_GAMEPASS_ID = 2037603877
Constants.ANIMATIONS = {
	StaffAttack = "rbxassetid://135877945269659",
	StaffCarry = "rbxassetid://79061460491098",
	JugOfWater = "rbxassetid://112416711884630",
	Bell = "rbxassetid://129363550918185",
}
Constants.TIME_SOUNDS = {
	[6] = { "rbxassetid://1846088038", "rbxassetid://9116969962" },
	[9] = { "rbxassetid://140492661889585" },
	[11] = { "rbxassetid://1845734359" },
	[14] = { "rbxassetid://124564869520979" },
	[17] = { "rbxassetid://131352855561482" },
	[19] = { "rbxassetid://1838816264" },
	[20] = { "rbxassetid://135975888586873" },
	[23] = { "rbxassetid://102615842265981" },
	[2] = { "rbxassetid://118781787721058" },
}
Constants.RANDOM_AMBIENT_SOUNDS = {
	{
		startTime = 20,
		endTime = 6,
		soundId = "rbxassetid://16982775470",
	},
}
Constants.START_DAY_MINUTES = 1020
Constants.SOUNDS = {
	Bell = "rbxassetid://127488139302452",
	Announce = "rbxassetid://114963776337887",
}

return Constants
