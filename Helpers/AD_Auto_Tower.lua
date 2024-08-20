local plr = game:GetService("Players").LocalPlayer
local GuiService = game:GetService("GuiService")
local StartGui = game:GetService("StarterGui")

plr:WaitForChild("PlayerGui")

if not plr.Character then
	plr.CharacterAdded:Wait()
	plr.Character:WaitForChild("Humanoid")
	plr.Character:WaitForChild("HumanoidRootPart")
end

local PlayerGui = plr.PlayerGui
local PAGES = PlayerGui.PAGES :: Frame
local HUD = PlayerGui.HUD :: ScreenGui
local MatchDisplayHolder = HUD.MatchDisplayHolder :: Frame
local MatchDisplayFrame = MatchDisplayHolder.MatchDisplayFrame :: Frame
local MatchOptionHolder = MatchDisplayFrame.OptionsHolder :: Frame --Location of Start/Leave button
local StartButtonHolder = MatchOptionHolder.StartButtonHolder :: Frame


local VirtualInputManager = game:GetService("VirtualInputManager")
local TowerLandingPoint = CFrame.new(12.0216541, 13.5041513, -322.700439, -0.756511867, -0.25962615, 0.600236952, -0.193016335, 0.965575814, 0.174379855, -0.624847889, 0.016064899, -0.780581594)

local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local path = PathfindingService:CreatePath({
	WaypointSpacing = 6
})

local character = plr.Character
local humanoid = character.Humanoid

local waypoints
local nextWaypointIndex
local reachedConnection
local blockedConnection

local PAGES_FRAMES = {
	TowerOfEternity = PAGES:WaitForChild("TowerOfEternity") :: Frame
}

local function click_this_gui(to_click: GuiObject)
	local Inset = GuiService:GetGuiInset()


	local AbsoluteSize = to_click.AbsoluteSize
	local Offset = {
		x = AbsoluteSize.X/2,
		y = AbsoluteSize.Y/2
	}

	local x,y = to_click.AbsolutePosition.X + Offset.x ,to_click.AbsolutePosition.Y + Offset.y

	VirtualInputManager:SendMouseButtonEvent(x+Inset.X,y+Inset.Y,0,true,game,0)
	VirtualInputManager:SendMouseButtonEvent(x+Inset.X,y+Inset.Y,0,false,game,0)
end

local function OnReachedDestination()
	local TowerOfEternity_Button = PAGES_FRAMES.TowerOfEternity.PlayButton :: TextButton


	VirtualInputManager:SendKeyEvent(true,Enum.KeyCode.E,false,game)

	if not PAGES_FRAMES.TowerOfEternity.Visible then
		PAGES_FRAMES.TowerOfEternity:GetPropertyChangedSignal("Visible"):Wait()
	end

	task.wait(1)

	click_this_gui(TowerOfEternity_Button)


	local old_pos = plr.Character:GetPivot().Position

	repeat task.wait() until (plr.Character:GetPivot().Position - old_pos).Magnitude >= 5 --Wait until player teleport (May wait for server)

	task.wait(1)
	click_this_gui(StartButtonHolder)


end

local function followPath(destination: Vector3)
	local TravelTime = 4
	
	local TimeSpent = 0
	
	local CN
	
	CN = RunService.PostSimulation:Connect(function(dt)
		
		TimeSpent += dt
		
		local percent = math.min(TimeSpent/TravelTime,1)
		
		plr.Character:PivotTo(CFrame.new(plr.Character:GetPivot().Position:Lerp(destination,percent)))
		
		if percent >= 1 then
			CN:Disconnect()
			task.wait(1)
			OnReachedDestination()
		end
		
	end)
end


followPath(TowerLandingPoint.Position)

StartGui:SetCore("SendNotification", {
	Title = 'เปลี่ยนโหมดฟาร์ม';
	Text = "กำลังฟาร์ม หอคอย";
	Duration = 3
})
