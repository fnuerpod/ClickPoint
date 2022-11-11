-- This script will build ClickPoint.

local BuildFolders = {
	{
		["Name"] = "ReplicatedStorage",
		["Path"] = game.ReplicatedStorage,
	},
	{
		["Name"] = "StarterPlayerScripts",
		["Path"] = game.StarterPlayer.StarterPlayerScripts,
	}
}

local ClickFolder = Instance.new("Folder", workspace)
ClickFolder.Name = "ClickPoint"

for _, path in next, BuildFolders do
	local new_folder = Instance.new("Folder", ClickFolder)
	new_folder.Name = path.Name

	for _, obj in next, path.Path:GetChildren() do
		obj:Clone().Parent = new_folder
	end
end

for _, data in next, game.ServerStorage.PackageRoot:GetChildren() do
	data:Clone().Parent = ClickFolder
end

print("Build successful.")
