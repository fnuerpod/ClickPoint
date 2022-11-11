# ClickPoint
[Get Latest Release](https://github.com/fnuerpod/ClickPoint/releases/latest) | [My ROBLOX Profile](https://roblox.com/users/69518131/profile)

[![Docs](https://github.com/fnuerpod/ClickPoint/actions/workflows/docs.yaml/badge.svg)](https://github.com/fnuerpod/ClickPoint/actions/workflows/docs.yaml)

This is a simple module that will allow you to create "ClickDetectors" that work with moving parts. This was a huge issue that I was running into while trying to build buses, trains and other vehicles with first-person clickable objects.

I accomplished this by creating ClickDetectors that update on the render step on the client. During testing I found this worked perfectly for my requirements.

As this seems to be a common issue with the standard ROBLOX ClickDetectors, I am releasing this module to the public.

# Usage
Place the latest RBXM file into Workspace and perform the following movements:
1. Move EVERYTHING in the **ReplicatedStorage** folder into **game.ReplicatedStorage**.
2. Move EVERYTHING in the **StarterPlayerScripts** folder into **game.StarterPlayer.StarterPlayerScripts**.
  
An example of how to use ClickPoint is below:
```lua
-- Import ClickPoint.
local ClickPoint: CLickPoint.ClickPoint = require(game.ReplicatedStorage.ClickPoint)

-- Create a new click detector for the BasePart we are a child of.
-- We should only be activatable from 10 studs away all-around and our cursor icon on hover should be Shrek.
-- Our tooltip should be "Hello, ClickPoint!"
local ClickDetector: ClickPoint.ClickPoint = ClickPoint.new(script.Parent, 10, "rbxassetid://1946950078", "Hello, ClickPoint!")

-- Change ClickPoint icon to show a pointer on hover.
ClickDetector.Settings["CursorIcon"] = "rbxassetid://569945340"

-- Change ClickPoint tooltip to say "Sample Tooltip".
ClickDetector.Settings["Tooltip"] = "Sample Tooltip"

-- Every click, print "I've been clicked!" to the screen.
-- Also, if the player's UserId is 69518131, one should be added to the MaxActivationDistance.
ClickDetector.MouseClick:Connect(function(player: Player)
	print("I've been clicked!")

	if player.UserId == 69518131 then
		ClickDetector.Settings["MaxActivationDistance"] += 1
	end
end)

-- When a player releases a right-click over us, print "Menu!!" to the console.
-- Also, change the tooltip to a random number between 1000 and 9999.
ClickDetector.MouseButton2Up:Connect(function()
	print("Menu!!")
	ClickDetector.Settings["Tooltip"] = tostring(math.random(1000,9999))
end)

-- Log that the script has loaded.
print("ClickPoint Tester Loaded.")
```

More documentation will be made available in due course.
