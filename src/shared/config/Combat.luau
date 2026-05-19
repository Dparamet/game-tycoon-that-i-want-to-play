return {
	offlineCapSeconds = 28800,

	winChance = {
		min = 0.1,
		max = 0.9,
	},

	injuryRecoverySeconds = {
		Light = 300,
		Moderate = 900,
		Severe = 1800,
	},

	tactics = {
		FrontalAssault = {
			powerMultiplier = 1,
			casualtyMultiplier = 1,
		},
		Guerrilla = {
			powerMultiplier = 0.95,
			casualtyMultiplier = 0.8,
			terrainBonus = {
				Forest = 1.2,
				Urban = 1.1,
			},
		},
		DefendPosition = {
			powerMultiplier = 0.9,
			casualtyMultiplier = 0.7,
		},
		Recon = {
			powerMultiplier = 0.7,
			casualtyMultiplier = 0.5,
		},
		Retreat = {
			powerMultiplier = 0.4,
			casualtyMultiplier = 0.3,
		},
	},
}
