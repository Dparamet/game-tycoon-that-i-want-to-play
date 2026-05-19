local Id = {}

function Id.create(prefix: string): string
	return string.format("%s_%d_%d", prefix, os.time(), math.random(1000, 9999))
end

return Id
