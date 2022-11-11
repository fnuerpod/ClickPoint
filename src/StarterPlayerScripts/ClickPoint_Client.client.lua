-- ClickPoint
-- itzfuneyy
-- 10/11/2022 19:27

-- Constant for ClickPoint tag.
local CLICKPOINT_TAG: string = "ClickPoint"

-- Initialise CollectionService.
local CollectionService = game:GetService("CollectionService")

-- Local function to create RaycastParams.
local function _generateRayParams(): RaycastParams
	local RayParams = RaycastParams.new()
	RayParams.FilterType = Enum.RaycastFilterType.Whitelist
	RayParams.FilterDescendantsInstances = CollectionService:GetTagged(CLICKPOINT_TAG)
	RayParams.RespectCanCollide = true

	return RayParams
end

local RayParams = _generateRayParams()

local Player = game:GetService("Players").LocalPlayer

local Mouse = Player:GetMouse()

local HOVERING_OVER_CLICKER = false
local HOVER_OBJECT = nil

-- Messy local function for generating a tooltip.
local function _generateTooltip(instance: BasePart)

	local ui = Instance.new("ScreenGui", game.Players.LocalPlayer.PlayerGui)
	ui.Name = "Tooltip"
	
	local frame = Instance.new("Frame", ui)
	frame.Size = UDim2.new(0,175,0,18)
	
	frame.BackgroundTransparency = 1
	
	local label = Instance.new("TextLabel", frame)
	label.Size = UDim2.new(1,0,1,0)
	label.Font = Enum.Font.Gotham
	label.TextScaled = true
	label.BackgroundTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextStrokeColor3 = Color3.fromRGB(0,0,0)
	label.TextColor3 = Color3.fromRGB(255,255,255)
	label.TextStrokeTransparency = 0
	
	label.Text = instance:GetAttribute("Tooltip")
	
	local Connection
	local temp_connection

	temp_connection = instance:GetAttributeChangedSignal("Tooltip"):Connect(function()
		-- Set label text.
		label.Text = instance:GetAttribute("Tooltip")
	end)

	Connection = game:GetService("RunService").RenderStepped:Connect(function()
		if ui.Parent == nil then
			Connection:Disconnect()
			temp_connection:Disconnect()
		end
		
		frame.Position = UDim2.new(0, Mouse.X + 32, 0, Mouse.Y-9)
		
	end)

	
	
	
	return ui	
end

-- Storage for tooltip.
local TOOLTIP_STORAGE = nil

-- 0 for hover end event sent, 1 for hover start event sent.
local HOVER_EVENT_STATE = 0

-- Inefficient way of waiting for character to load before starting cycles.
if Player.Character == nil then
	Player.CharacterAdded:Wait()
end

-- Wait for render stepping.
game:GetService("RunService").RenderStepped:Connect(function()
	-- Perform a raycast.
	local OriginPos = workspace.CurrentCamera.CFrame.Position
	local Raycast = workspace:Raycast(OriginPos, (Mouse.Hit.Position - OriginPos) * 1.1, RayParams)
	
	if Raycast then
		if Raycast.Instance:GetAttribute("ClickDetectable") then
			-- This is a ClickPoint. Perform max Distance checks.
			
			local Check = math.ceil((Raycast.Instance.Position - Player.Character.HumanoidRootPart.Position).Magnitude)

			if Check > Raycast.Instance:GetAttribute("MaxActivationDistance") then
				if HOVER_OBJECT ~= nil then
					if HOVER_OBJECT:GetAttribute("ClickDetectable") and HOVER_OBJECT:FindFirstChild("OnHover") and HOVER_EVENT_STATE ~= 0 then
						HOVER_OBJECT.OnHover:FireServer(false)
						HOVER_EVENT_STATE = 0
					end
				end

				HOVERING_OVER_CLICKER = false
				HOVER_OBJECT = nil
			else
				HOVERING_OVER_CLICKER = true
				HOVER_OBJECT = Raycast.Instance

				if HOVER_OBJECT:GetAttribute("ClickDetectable") and HOVER_OBJECT:FindFirstChild("OnHover") and HOVER_EVENT_STATE ~= 1 then
					HOVER_OBJECT.OnHover:FireServer(true)
					HOVER_EVENT_STATE = 1
				end
			end
			
		else
			-- Not a clickpoint.
			
			-- Do not perform hover leave if we haven't hovered over anything.
			if HOVER_OBJECT ~= nil then
				if HOVER_OBJECT:GetAttribute("ClickDetectable") and HOVER_OBJECT:FindFirstChild("OnHover") and HOVER_EVENT_STATE ~= 0 then
					HOVER_OBJECT.OnHover:FireServer(false)
					HOVER_EVENT_STATE = 0
				end
			end

			HOVERING_OVER_CLICKER = false
			HOVER_OBJECT = nil
		end
	else
		-- Nothing to ray to.

		if HOVER_OBJECT ~= nil then
			if HOVER_OBJECT:GetAttribute("ClickDetectable") and HOVER_OBJECT:FindFirstChild("OnHover") and HOVER_EVENT_STATE ~= 0 then
				HOVER_OBJECT.OnHover:FireServer(false)
				HOVER_EVENT_STATE = 0
			end
		end

		HOVERING_OVER_CLICKER = false
		HOVER_OBJECT = nil
	end
	
	-- Perform update
	if HOVERING_OVER_CLICKER then
		--print("Icon set.")
		Player:GetMouse().Icon = Raycast.Instance:GetAttribute("CursorIcon")

		-- Check if instance has Tooltip text set.
		-- If it does, we want to use it.
		if HOVER_OBJECT:GetAttribute("Tooltip") and TOOLTIP_STORAGE == nil then
			-- Display a tooltip.
			TOOLTIP_STORAGE = _generateTooltip(HOVER_OBJECT)
		end
	else
		Player:GetMouse().Icon = ""

		-- If we are displaying a tooltip, destroy it.
		if TOOLTIP_STORAGE ~= nil then
			TOOLTIP_STORAGE:Destroy()
			TOOLTIP_STORAGE = nil
		end
	end
	
end)

Mouse.Button1Down:Connect(function()
	if not HOVERING_OVER_CLICKER then
		return
	end
	
	if HOVER_OBJECT == nil then
		return
	end
	
	if not HOVER_OBJECT:GetAttribute("ClickDetectable") then
		return
	end
	
	if not HOVER_OBJECT:FindFirstChild("OnClicked") then
		return
	end
	
	-- Now perform click fire.
	HOVER_OBJECT:FindFirstChild("OnClicked"):FireServer(1, true)
end)

Mouse.Button1Up:Connect(function()
	if not HOVERING_OVER_CLICKER then
		return
	end
	
	if HOVER_OBJECT == nil then
		return
	end
	
	if not HOVER_OBJECT:GetAttribute("ClickDetectable") then
		return
	end
	
	if not HOVER_OBJECT:FindFirstChild("OnClicked") then
		return
	end
	
	-- Now perform click fire.
	HOVER_OBJECT:FindFirstChild("OnClicked"):FireServer(1, false)
end)

Mouse.Button2Down:Connect(function()
	if not HOVERING_OVER_CLICKER then
		return
	end
	
	if HOVER_OBJECT == nil then
		return
	end
	
	if not HOVER_OBJECT:GetAttribute("ClickDetectable") then
		return
	end
	
	if not HOVER_OBJECT:FindFirstChild("OnClicked") then
		return
	end
	
	-- Now perform click fire.
	HOVER_OBJECT:FindFirstChild("OnClicked"):FireServer(2, true)
end)

Mouse.Button2Up:Connect(function()
	if not HOVERING_OVER_CLICKER then
		return
	end
	
	if HOVER_OBJECT == nil then
		return
	end
	
	if not HOVER_OBJECT:GetAttribute("ClickDetectable") then
		return
	end
	
	if not HOVER_OBJECT:FindFirstChild("OnClicked") then
		return
	end
	
	-- Now perform click fire.
	HOVER_OBJECT:FindFirstChild("OnClicked"):FireServer(2, false)
end)

-- Perform refresh of raycast parameters when a new instance is added to the taglist.
CollectionService:GetInstanceAddedSignal(CLICKPOINT_TAG):Connect(function(instance: Instance)
	RayParams = _generateRayParams()
end)