local BoothLocation = workspace:WaitForChild("BoothLocations") :: Folder

local BoothUI = game:GetService("Players").LocalPlayer.PlayerGui.PAGES.PlayerBoothUI :: Frame

local TrackingBooth = nil :: BasePart

--Path Finder

local ProximityPromptService = game:GetService("ProximityPromptService")
local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local plr =Players.LocalPlayer

local UnitData = require(game:GetService("ReplicatedStorage").Modules.Bins.UnitData)
local occupied_folder = workspace:WaitForChild("Folder")
local path = PathfindingService:CreatePath()
game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true) --Testing

local States = {
	pair_occupied_booth = nil :: Model;
	
}

local character = plr.Character
local humanoid = character.Humanoid :: Humanoid

local waypoints
local nextWaypointIndex
local reachedConnection
local blockedConnection


local function click_this_gui(to_click: GuiObject)

	local GuiService = game:GetService("GuiService")
	local VirtualInputManager = game:GetService("VirtualInputManager")


	if not iswindowactive() then
		repeat task.wait() until iswindowactive()
	end

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

local function followPath(destination)
	
	local success, errorMessage = pcall(function()
		path:ComputeAsync(character.PrimaryPart.Position, destination)
	end)

	if success and path.Status == Enum.PathStatus.Success then
		-- Get the path waypoints
		waypoints = path:GetWaypoints()

		-- Detect if path becomes blocked
		blockedConnection = path.Blocked:Connect(function(blockedWaypointIndex)
			-- Check if the obstacle is further down the path
			if blockedWaypointIndex >= nextWaypointIndex then
				-- Stop detecting path blockage until path is re-computed
				blockedConnection:Disconnect()
				-- Call function to re-compute new path
				followPath(destination)
			end
		end)

		-- Detect when movement to next waypoint is complete
		if not reachedConnection then
			reachedConnection = humanoid.MoveToFinished:Connect(function(reached)
				if reached and nextWaypointIndex < #waypoints then
					-- Increase waypoint index and move to next waypoint
					nextWaypointIndex += 1
					humanoid:MoveTo(waypoints[nextWaypointIndex].Position)
				else
					reachedConnection:Disconnect()
					blockedConnection:Disconnect()
					
					reachedConnection = nil
					blockedConnection = nil
					
					OnDestinationReached()
				end
			end)
		end

		-- Initially move to second waypoint (first waypoint is path start; skip it)
		nextWaypointIndex = 2
		humanoid:MoveTo(waypoints[nextWaypointIndex].Position)
	else
		warn("Path not computed!", errorMessage)
	end
end

local function IsCloseEnough()
	
	if not TrackingBooth then
		return false
	end
	
	if (humanoid.RootPart.Position - TrackingBooth.Position).Magnitude > 6 then
		return false
	end

	return true
end

function OnDestinationReached()
	local InteractPrompt = States.pair_occupied_booth:FindFirstChild('BoothInteractPrompt',true) :: ProximityPrompt

	if InteractPrompt then
		fireproximityprompt(InteractPrompt)
		
		task.wait(1)
		
	end
end


local function IsBoothClaimable(Booth)
	
	if not Booth or not Booth.Parent then
		
		return false
	end
	
	local Prompt = Booth:FindFirstChild("BoothClaimPrompt") :: ProximityPrompt
	
	if not Prompt or not Prompt.Enabled then
		
		return false
	end
	
	
	return true
end

function PickABooth()
	for _,v in BoothLocation:GetChildren() do
		if not IsBoothClaimable(v) then
			continue
		end
		
		
		return v
	end
end

if not TrackingBooth then
	TrackingBooth = PickABooth()
end

local function IsThisUnitGrid()
	local PromptGui = game:GetService("Players").LocalPlayer.PlayerGui.PromptGui :: ScreenGui
	
	
	
end

local function OnBoothMenuOpened()
	
	local prefab = 0
	
	while prefab <= 0 do
		
		for _,v in BoothUI.ScrollingFrame:GetChildren() do
			if v.Name ~= "UnitGridPrefab" then
				continue
			end
			
			prefab += 1
		end
		
		task.wait()
	end
	
	local Prefab = BoothUI.ScrollingFrame.UnitGridPrefab :: Frame
	
	task.wait(0.5)
	click_this_gui(Prefab.Button)
	task.wait(0.75)
	
	if _G.IsCaptchaActive:Invoke() then
		repeat task.wait() until not _G.IsCaptchaActive:Invoke()
		click_this_gui(Prefab.Button)
	end
	
	local PromptDefault = game:GetService("Players").LocalPlayer.PlayerGui.PromptGui:WaitForChild("PromptDefault") :: Frame
	
	local BuyButton = PromptDefault.Holder.Options.Buy
	
	prefab = 0
	
	while task.wait(0.15) or prefab > 0 do
		if not BoothUI.Visible then
			break
		end
		
		for _,v in BoothUI.ScrollingFrame:GetChildren() do
			if v.Name ~= "UnitGridPrefab" then
				continue
			end

			prefab += 1
		end
		
		click_this_gui(BuyButton)
	end
	
end


local Pairer_Id = 0 --If this starting value isn't 0 then it's testing if that happen change this to 0

while Pairer_Id == 0 do
	
	for _,v in game:GetService("Players"):GetPlayers() do
		if v.Name ~= getgenv().Merge_States.Pair_With then
			continue
		end
		
		Pairer_Id = v.UserId
	end
	
	task.wait(0.5)
end

if BoothUI.Visible then
	OnBoothMenuOpened()
end

BoothUI:GetPropertyChangedSignal('Visible'):Connect(function()
	if BoothUI.Visible then
		OnBoothMenuOpened()
	end
end)

while task.wait(0.25) do
	ProximityPromptService.Enabled = true
	
	if not States.pair_occupied_booth then
		for _,v in occupied_folder:GetChildren() do
			if tonumber(v:GetAttribute("Occupant")) ~= Pairer_Id then
				task.wait()
				continue
			end

			States.pair_occupied_booth = v
			break
		end

		task.wait(0.25)
		
	else

		if States.pair_occupied_booth and (not reachedConnection or not blockedConnection) and not IsCloseEnough() then
			followPath(States.pair_occupied_booth:GetPivot().Position)
		end

		if IsCloseEnough() then
			OnDestinationReached()
		end
	end
	
	
	
	task.wait(0.5)
	ProximityPromptService.Enabled = false
end
