export type Resources = {
	cash: number,
	supplies: number,
}

export type BuildingState = {
	id: string,
	level: number,
	purchasedAt: number,
}

export type BaseData = {
	commandCenterLevel: number,
	buildings: {[string]: BuildingState},
}

export type PlayerData = {
	version: number,
	resources: Resources,
	base: BaseData,
	units: {[string]: any},
	squads: {[string]: any},
	territories: {[string]: any},
	trainingQueue: {[string]: any},
	recoveryQueue: {[string]: any},
	lastLogoutTime: number,
}

return {}
