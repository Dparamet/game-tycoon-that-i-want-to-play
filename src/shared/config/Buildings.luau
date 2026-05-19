return {
	CommandCenter = {
		maxLevel = 5,
		cost = {
			cash = 0,
			supplies = 0,
		},
	},

	RecruitmentOffice = {
		requires = {
			commandCenterLevel = 1,
		},
		cost = {
			cash = 50,
			supplies = 0,
		},
	},

	TrainingGround = {
		requires = {
			commandCenterLevel = 1,
		},
		cost = {
			cash = 100,
			supplies = 0,
		},
	},

	Barracks = {
		requires = {
			commandCenterLevel = 2,
		},
		cost = {
			cash = 250,
			supplies = 25,
		},
	},

	MedicalTent = {
		requires = {
			commandCenterLevel = 3,
		},
		cost = {
			cash = 350,
			supplies = 75,
		},
	},

	Armory = {
		requires = {
			commandCenterLevel = 4,
		},
		cost = {
			cash = 500,
			supplies = 150,
		},
	},

	CashGenerator = {
		requires = {
			commandCenterLevel = 1,
		},
		cost = {
			cash = 0,
			supplies = 0,
		},
	},

	SupplyDepot = {
		requires = {
			commandCenterLevel = 1,
		},
		cost = {
			cash = 150,
			supplies = 0,
		},
	},
}
