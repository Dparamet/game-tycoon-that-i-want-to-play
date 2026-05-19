export type Rewards = {
	cash: number,
	supplies: number,
}

export type UnitMissionResult = {
	xp: number,
	status: string,
	injury: any?,
}

export type MissionResult = {
	victory: boolean,
	rewards: Rewards,
	unitResults: {[string]: UnitMissionResult},
	territoryCaptured: boolean,
}

return {}
