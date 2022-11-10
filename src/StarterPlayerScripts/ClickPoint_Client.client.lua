-- ClickPoint
-- itzfuneyy
-- 10/11/2022 19:27

local RayParams = RaycastParams.new()
RayParams.FilterType = Enum.RaycastFilterType.Whitelist
RayParams.FilterDescendantsInstances = {workspace}
RayParams.RespectCanCollide = true

local Player = game:GetService("Players").LocalPlayer

local Mouse = Player:GetMouse()

local HOVERING_OVER_CLICKER = false
local HOVER_OBJECT = nil

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
				HOVERING_OVER_CLICKER = false
				HOVER_OBJECT = nil
			else
				HOVERING_OVER_CLICKER = true
				HOVER_OBJECT = Raycast.Instance
			end
			
		else
			-- Not a clickpoint.
			HOVERING_OVER_CLICKER = false
			HOVER_OBJECT = nil
		end
	else
		-- Nothing to ray to.
		HOVERING_OVER_CLICKER = false
		HOVER_OBJECT = nil
	end
	
	-- Perform update
	if HOVERING_OVER_CLICKER then
		--print("Icon set.")
		Player:GetMouse().Icon = Raycast.Instance:GetAttribute("CursorIcon")
	else
		Player:GetMouse().Icon = ""
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
	HOVER_OBJECT:FindFirstChild("OnClicked"):FireServer()
end)