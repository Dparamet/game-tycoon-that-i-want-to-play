local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(script.Parent.Parent.constants.Remotes)

local RemoteRegistry = {}

function RemoteRegistry.getFolder(): Folder
	local folder = ReplicatedStorage:FindFirstChild("GameRemotes")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "GameRemotes"
		folder.Parent = ReplicatedStorage
	end

	return folder
end

function RemoteRegistry.ensureRemoteEvent(name: string): RemoteEvent
	local folder = RemoteRegistry.getFolder()
	local remote = folder:FindFirstChild(name)
	if not remote then
		remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = folder
	end

	return remote :: RemoteEvent
end

function RemoteRegistry.ensureAll()
	for _, name in pairs(Remotes) do
		RemoteRegistry.ensureRemoteEvent(name)
	end
end

return RemoteRegistry
