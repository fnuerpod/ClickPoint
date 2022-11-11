-- ClickPoint
-- itzfuneyy
-- 10/11/2022 19:49

export type ClickPoint = {
	New : (Instance) -> ClickPoint,
	
	MouseClick : any,

	MouseButton1Down : any,
	MouseButton2Down : any,

	MouseButton1Up : any,
	MouseButton2Up : any,
	
	ClickRemote : RemoteEvent,
	HoverRemote : RemoteEvent,

	MouseEnter : any,
	MouseLeave : any,
	
	Settings : {[string] : any},
	
	Instance : BasePart
}

-- Constant for ClickPoint tag.
local CLICKPOINT_TAG: string = "ClickPoint"

-- Initialise CollectionService.
local CollectionService = game:GetService("CollectionService")

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

--- @prop MouseButton1Down Signal
--- @within ClickPoint
--- This event is fired when a player presses down Button 1 (left click) on their mouse.

--- @prop MouseButton1Up Signal
--- @within ClickPoint
--- This event is fired when a player releases Button 1 (left click) on their mouse.

--- @prop MouseButton2Down Signal
--- @within ClickPoint
--- This event is fired when a player presses down Button 2 (right click) on their mouse.

--- @prop MouseButton2Up Signal
--- @within ClickPoint
--- This event is fired when a player releases Button 2 (right click) on their mouse.

--- @prop MouseEnter Signal
--- @within ClickPoint
--- This event is fired when a player's mouse enters the raycast/maximum activation range of a ClickPoint.

--- @prop MouseLeave Signal
--- @within ClickPoint
--- This event is fired when a player's mouse leaves the raycast/maximum activation range of a ClickPoint.

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
	
	-- Setup hooks.
	local OnClicked
	local OnHover
	-- Check if a ClickPoint already exists for this instance.
	if not CollectionService:HasTag(instance, CLICKPOINT_TAG) then
		-- Create events.
		OnClicked = Instance.new("RemoteEvent", instance)
		OnClicked.Name = "OnClicked"

		OnHover = Instance.new("RemoteEvent", instance)
		OnHover.Name = "OnHover"
	else
		-- We already have a ClickPoint for this instance. We can just "create" another but not set anything.
		-- This will give us access to the ClickPoint without re-instantising.

		OnClicked = instance.OnClicked
		OnHover = instance.OnHover
	end

	
	
	-- ClickDetector compatibility MouseClick event.
	Clicker.MouseClick = Signal.new()

	-- MouseButton1/2 pressed down events.
	Clicker.MouseButton1Down = Signal.new()
	Clicker.MouseButton2Down = Signal.new()

	-- MouseButton1/2 released events.
	Clicker.MouseButton1Up = Signal.new()
	Clicker.MouseButton2Up = Signal.new()

	-- Mouse enter/leave events.
	Clicker.MouseEnter = Signal.new()
	Clicker.MouseLeave = Signal.new()

	-- RemoteEvents.
	Clicker.ClickRemote = OnClicked
	Clicker.HoverRemote = OnHover
	
	Clicker.Instance = instance
	
	-- Set up settings
	Clicker.Settings = setmetatable({Instance = instance}, Settings)
	
	-- Add settings only if we haven't been instantised before.
	if not CollectionService:HasTag(instance, CLICKPOINT_TAG) then
		Clicker.Settings["MaxActivationDistance"] = MaxActivation
		Clicker.Settings["CursorIcon"] = CursorIcon

		-- Make detectable by client.
		Clicker.Settings["ClickDetectable"] = true
	end
	
	Clicker.HoverRemote.OnServerEvent:Connect(function(player, state)
		-- Perform checks.
		local Check = math.ceil((Clicker.Instance.Position - player.Character.HumanoidRootPart.Position).Magnitude)
		
		-- TODO: look into adding additional security here.
		if Check > Clicker.Settings["MaxActivationDistance"] then
			Clicker.MouseLeave:Fire(player)
			return
		end

		-- If we have entered hover, fire hover enter event.
		-- If not, fire hover leave event.
		if state then
			Clicker.MouseEnter:Fire(player)
		else
			Clicker.MouseLeave:Fire(player)
		end
	end)

	-- Event for click.
	Clicker.ClickRemote.OnServerEvent:Connect(function(player, button, state)
		-- Perform checks.
		local Check = math.ceil((Clicker.Instance.Position - player.Character.HumanoidRootPart.Position).Magnitude)
		
		if Check > Clicker.Settings["MaxActivationDistance"] then
			return
		end
		
		-- Perform checks
		if button == 1 then
			-- Mouse1
			if state then
				-- Mouse down
				Clicker.MouseButton1Down:Fire(player)
			else
				-- Mouse up
				-- This should also fire MouseClick - for compatibility with ClickDetectors.
				Clicker.MouseButton1Up:Fire(player)
				Clicker.MouseClick:Fire(player)
			end
		elseif button == 2 then
			-- Mouse2
			if state then
				-- Mouse down
				Clicker.MouseButton2Down:Fire(player)
			else
				-- Mouse up
				Clicker.MouseButton2Up:Fire(player)
			end
		end
	end)

	-- Add to constant tag as this is now configured.
	CollectionService:AddTag(instance, CLICKPOINT_TAG)
	
	return Clicker
end


return ClickPoint