-- ClickPoint
-- itzfuneyy
-- 10/11/2022 19:49

export type ClickPoint = {
	New : (Instance) -> ClickPoint,
	
	MouseClick : any,
	
	
	ClickRemote : RemoteEvent,
	
	Settings : {[string] : any},
	
	Instance : BasePart
}

--[=[
	@class Settings

	The Settings class handles the setting/retrieval of settings from a ClickPoint Instance.

	It uses a \_\_index and \_\_newindex metamethod to set the Attributes of the ClickPoint Instance.

	An example get/set in the Settings array would be:
	```lua
	Settings["MaxActivationDistance"] = 32
	print(Settings["CursorIcon"])
	```
]=]

--- @prop MaxActivationDistance number
--- @within Settings
--- Maximum distance a player can be away from a ClickPoint.

--- @prop CursorIcon string
--- @within Settings
--- Link to a ROBLOX image asset which will be displayed when the ClickPoint is hovered over.

local Settings: {[string] : any} = {}
Settings.__index = function(tab, key)
	return tab.Instance:GetAttribute(key)
end

Settings.__newindex = function(tab, index, value)
	return tab.Instance:SetAttribute(index, value)
end

-- Import sleitnick signal.
local Signal = require(script.Parent.Packages.signal)

--[=[
	@class ClickPoint

	The ClickPoint class is what sets up, configures and exposes user-managable endpoints for a ClickPoint.

]=]

--- @prop Settings Settings
--- @within ClickPoint
--- The settings for this ClickPoint Instance.

--- @prop MouseClick Signal
--- @within ClickPoint
--- This event is fired when a ClickPoint is clicked and security checks have passed.

local ClickPoint: ClickPoint = {}
ClickPoint.__index = ClickPoint

--[=[
	This function creates a new ClickPoint instance.

	@param instance Instance -- The BasePart that should be clickable.
	@param MaxActivation number|nil -- The maximum activation distance for the ClickPoint (default: 32).
	@param CursorIcon string|nil -- The cursor that should be displayed when a player hovers over the ClickPoint (defaults to "rbxassetid://569945340").

	@return ClickPoint -- Returns an initialised ClickPoint class.
]=]
function ClickPoint.new(instance: Instance, MaxActivation : number|nil, CursorIcon : string|nil) : ClickPoint
	assert(typeof(instance) == "Instance", "expected Instance, got " .. typeof(instance))
	assert(instance:IsA("BasePart"), "expected BasePart, got " .. instance.ClassName)
	
    -- Set maximum activation distance if not set already.
	if MaxActivation == nil then
		MaxActivation = 32
	end
	
    -- Set default cursor icon if not set already.
	if CursorIcon == nil then
		CursorIcon = "rbxassetid://569945340"
	end
	
	-- Create table.
	local Clicker: ClickPoint = setmetatable({}, ClickPoint)
	
	-- Set attribute for click detectable.
	instance:SetAttribute("ClickDetectable", true)
	
	-- Setup hooks.
	local OnClicked = Instance.new("RemoteEvent", instance)
	OnClicked.Name = "OnClicked"
	
	Clicker.MouseClick = Signal.new()
	
	Clicker.ClickRemote = OnClicked
	
	Clicker.Instance = instance
	
	-- Set up settings
	Clicker.Settings = setmetatable({Instance = instance}, Settings)
	
	Clicker.Settings["MaxActivationDistance"] = MaxActivation
	
	Clicker.Settings["CursorIcon"] = CursorIcon
	
	Clicker.ClickRemote.OnServerEvent:Connect(function(player)
		-- Perform checks.
		local Check = math.ceil((Clicker.Instance.Position - player.Character.HumanoidRootPart.Position).Magnitude)
		
		if Check > Clicker.Settings["MaxActivationDistance"] then
			return
		end
		
		-- Allow.
		Clicker.MouseClick:Fire(player)
	end)
	
	return Clicker
end


return ClickPoint