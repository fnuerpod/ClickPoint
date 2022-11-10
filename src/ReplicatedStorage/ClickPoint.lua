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

local Settings: {[string] : any} = {}
Settings.__index = function(tab, key)
	return tab.Instance:GetAttribute(key)
end

Settings.__newindex = function(tab, index, value)
	return tab.Instance:SetAttribute(index, value)
end

-- Import sleitnick signal.
local Signal = require(script.Parent.Packages.signal)

local ClickPoint: ClickPoint = {}
ClickPoint.__index = ClickPoint

-- New.
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