--[[

	---------------- CLICKPOINT ----------------
	
	This is a simple module that will allow you to create "ClickDetectors" that work with moving parts. 
	
	This was a huge issue that I was running into while trying to build buses, trains and other vehicles
	with first-person clickable objects.

	I accomplished this by creating ClickDetectors that update on the render step on the client. During
	testing, I found this worked perfectly for my requirements.

	As this seems to be a common issue with the standard ROBLOX ClickDetectors, I am releasing this module 
	to the public.
	
	
	---------------- USAGE ----------------
	
	To use ClickPoint, perform the following movements:
		- move EVERYTHING in the ReplicatedStorage folder into game.ReplicatedStorage.
		- move EVERYTHING in the StarterPlayerScripts folder into game.StarterPlayer.StarterPlayerScripts.
		
	An example of how to use ClickPoint can be found in the GitHub repository.
	
]]

return "Read the above before using ClickPoint."