export type InjuryData = {
	severity: string,
	startedAt: number,
	recoveryEndsAt: number,
	statPenalty: number?,
}

export type UnitData = {
	id: string,
	name: string,
	branch: string,
	rank: string,
	role: string,
	status: string,
	xp: number,
	health: number,
	injury: InjuryData?,
	squadId: string?,
	fireteamId: string?,
	createdAt: number,
	updatedAt: number,
}

return {}
