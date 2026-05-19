return {
	Citizen = {
		order = 0,
		nextRank = "Recruit",
		minXP = 0,
		canCommand = false,
	},

	Recruit = {
		order = 1,
		nextRank = "Private",
		minXP = 10,
		canCommand = false,
	},

	Private = {
		order = 2,
		nextRank = "Corporal",
		minXP = 50,
		canCommand = false,
	},

	Corporal = {
		order = 3,
		nextRank = "Sergeant",
		minXP = 120,
		canCommand = true,
	},

	Sergeant = {
		order = 4,
		nextRank = "Lieutenant",
		minXP = 250,
		canCommand = true,
	},

	Lieutenant = {
		order = 5,
		nextRank = "Captain",
		minXP = 500,
		canCommand = true,
	},

	Captain = {
		order = 6,
		nextRank = "Major",
		minXP = 900,
		canCommand = true,
	},

	Major = {
		order = 7,
		nextRank = "Commander",
		minXP = 1500,
		canCommand = true,
	},

	Commander = {
		order = 8,
		nextRank = nil,
		minXP = 2500,
		canCommand = true,
	},
}
