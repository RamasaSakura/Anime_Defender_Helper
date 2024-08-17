-- Gui to Lua
-- Version: 3.2

-- Instances:

local MovePad = Instance.new("ScreenGui")
local container = Instance.new("Frame")
local up = Instance.new("Frame")
local button = Instance.new("TextButton")
local down = Instance.new("Frame")
local button_2 = Instance.new("TextButton")
local left = Instance.new("Frame")
local button_3 = Instance.new("TextButton")
local right = Instance.new("Frame")
local button_4 = Instance.new("TextButton")
local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")

--Properties:

MovePad.Name = "MovePad"
MovePad.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
MovePad.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

container.Name = "container"
container.Parent = MovePad
container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
container.BackgroundTransparency = 1.000
container.BorderColor3 = Color3.fromRGB(0, 0, 0)
container.BorderSizePixel = 0
container.Position = UDim2.new(0.0667202547, 0, 0.540942907, 0)
container.Size = UDim2.new(0.288585216, 0, 0.411910683, 0)

up.Name = "up"
up.Parent = container
up.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
up.BorderColor3 = Color3.fromRGB(0, 0, 0)
up.BorderSizePixel = 0
up.Position = UDim2.new(0.359331489, 0, 0, 0)
up.Size = UDim2.new(0.278551519, 0, 0.30120483, 0)

button.Name = "button"
button.Parent = up
button.BackgroundColor3 = Color3.fromRGB(117, 195, 255)
button.BorderColor3 = Color3.fromRGB(0, 0, 0)
button.BorderSizePixel = 0
button.Size = UDim2.new(1, 0, 1, 0)
button.Font = Enum.Font.SourceSansBold
button.Text = "หน้า"
button.TextColor3 = Color3.fromRGB(0, 0, 0)
button.TextScaled = true
button.TextSize = 14.000
button.TextWrapped = true

down.Name = "down"
down.Parent = container
down.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
down.BorderColor3 = Color3.fromRGB(0, 0, 0)
down.BorderSizePixel = 0
down.Position = UDim2.new(0.359331489, 0, 0.698795199, 0)
down.Size = UDim2.new(0.278551519, 0, 0.30120483, 0)

button_2.Name = "button"
button_2.Parent = down
button_2.BackgroundColor3 = Color3.fromRGB(117, 195, 255)
button_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
button_2.BorderSizePixel = 0
button_2.Size = UDim2.new(1, 0, 1, 0)
button_2.Font = Enum.Font.SourceSansBold
button_2.Text = "หลัง"
button_2.TextColor3 = Color3.fromRGB(0, 0, 0)
button_2.TextScaled = true
button_2.TextSize = 14.000
button_2.TextWrapped = true

left.Name = "left"
left.Parent = container
left.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
left.BorderColor3 = Color3.fromRGB(0, 0, 0)
left.BorderSizePixel = 0
left.Position = UDim2.new(0, 0, 0.3493976, 0)
left.Size = UDim2.new(0.278551519, 0, 0.30120483, 0)

button_3.Name = "button"
button_3.Parent = left
button_3.BackgroundColor3 = Color3.fromRGB(117, 195, 255)
button_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
button_3.BorderSizePixel = 0
button_3.Size = UDim2.new(1, 0, 1, 0)
button_3.Font = Enum.Font.SourceSansBold
button_3.Text = "ซ้าย"
button_3.TextColor3 = Color3.fromRGB(0, 0, 0)
button_3.TextScaled = true
button_3.TextSize = 14.000
button_3.TextWrapped = true

right.Name = "right"
right.Parent = container
right.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
right.BorderColor3 = Color3.fromRGB(0, 0, 0)
right.BorderSizePixel = 0
right.Position = UDim2.new(0.721448481, 0, 0.3493976, 0)
right.Size = UDim2.new(0.278551519, 0, 0.30120483, 0)

button_4.Name = "button"
button_4.Parent = right
button_4.BackgroundColor3 = Color3.fromRGB(117, 195, 255)
button_4.BorderColor3 = Color3.fromRGB(0, 0, 0)
button_4.BorderSizePixel = 0
button_4.Size = UDim2.new(1, 0, 1, 0)
button_4.Font = Enum.Font.SourceSansBold
button_4.Text = "ขวา"
button_4.TextColor3 = Color3.fromRGB(0, 0, 0)
button_4.TextScaled = true
button_4.TextSize = 14.000
button_4.TextWrapped = true

UIAspectRatioConstraint.Parent = container
UIAspectRatioConstraint.AspectRatio = 1.081

local Mapping = {
	["up"] = button;
	["down"] = button_2;
	["left"] = button_3;
	["right"] = button_4
}

MovePad.IgnoreGuiInset = true
MovePad.ResetOnSpawn = false
MovePad.DisplayOrder = 1000000

local camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local plr = game:GetService("Players").LocalPlayer

local function getHumanoid() : Humanoid
	return game:GetService("Players").LocalPlayer.Character.Humanoid
end


local movecn


Mapping.up.MouseButton1Down:Connect(function()
	local hum = getHumanoid()
	
	movecn = RunService.PreSimulation:Connect(function(delta)
		hum.RootPart.Velocity = camera.CFrame.LookVector * delta * hum.WalkSpeed * 60
	end)
	
end)

Mapping.down.MouseButton1Down:Connect(function()
	local hum = getHumanoid()
	
	
	movecn = RunService.PreSimulation:Connect(function(delta)
		hum.RootPart.Velocity = -camera.CFrame.LookVector * delta * hum.WalkSpeed * 60
	end)
end)

Mapping.left.MouseButton1Down:Connect(function()
	local hum = getHumanoid()
	
	movecn = RunService.PreSimulation:Connect(function(delta)
		hum.RootPart.Velocity = -camera.CFrame.RightVector * delta * hum.WalkSpeed * 60
	end)
end)

Mapping.right.MouseButton1Down:Connect(function()
	local hum = getHumanoid()
	
	
	movecn = RunService.PreSimulation:Connect(function(delta)
		hum.RootPart.Velocity = camera.CFrame.RightVector * delta * hum.WalkSpeed * 60

	end)
end)

for _,v : TextButton in Mapping do
	v.MouseButton1Up:Connect(function()
		local hum = getHumanoid()
		hum.RootPart.Velocity = Vector3.zero
		
		movecn:Disconnect()
	end)
end

MovePad.Destroying:Once(function()
	movecn:Disconnect()
end)

plr.Chatted:Connect(function(msg)
	if msg == "/e del" then
		MovePad:Destroy()
	end
end)
