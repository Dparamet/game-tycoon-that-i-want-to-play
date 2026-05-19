local Time = {}

function Time.getCappedElapsed(lastTime: number, now: number, capSeconds: number): number
	return math.clamp(now - lastTime, 0, capSeconds)
end

return Time
