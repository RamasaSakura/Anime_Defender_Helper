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

local Pairer_Id = 0 --If this starting value isn't 0 then it's testing if that happen change this to 0
local Pairer_Instance = nil :: Player

game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false) --Testing



local States = {
	occupied_booth = nil :: Model;
	trade_success = false
	
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


	--[[if not iswindowactive() then
		repeat task.wait() until iswindowactive()
	end]]

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

local MoveToFinished = Instance.new("BindableEvent")
local _STEP_NAME = 'Seller_Move_Step'

local function MoveTo(Position: Vector3)

	RunService:UnbindFromRenderStep(_STEP_NAME)
	task.wait()

	local TravelTime = math.min(0.25,(Position - character:GetPivot().Position).Magnitude/30)
	local TimeSpennt = 0

	local Origin = character:GetPivot()
	local _,size = character:GetBoundingBox()

	RunService:BindToRenderStep(_STEP_NAME, Enum.RenderPriority.Character.Value,function(dt)

		TimeSpennt += dt
		local Percent = math.min(TimeSpennt/TravelTime,1)

		character:PivotTo(Origin:Lerp(CFrame.new(Position),Percent) * CFrame.new(0,size.Y/2,0))

		if Percent >= 1 then
			RunService:UnbindFromRenderStep(_STEP_NAME)
			MoveToFinished:Fire(true)
		end
	end)

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
			reachedConnection = MoveToFinished.Event:Connect(function(reached)
				if reached and nextWaypointIndex < #waypoints then
					-- Increase waypoint index and move to next waypoint
					nextWaypointIndex += 1
					MoveTo(waypoints[nextWaypointIndex].Position)
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
		MoveTo(waypoints[nextWaypointIndex].Position)
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
	local Prompt = TrackingBooth:FindFirstChild("BoothClaimPrompt") :: ProximityPrompt

	if Prompt then
		fireproximityprompt(Prompt)
		
		task.wait(1)
		local Retry = 0
		
		while not States.occupied_booth do
			for _,v in occupied_folder:GetChildren() do
				if tonumber(v:GetAttribute("Occupant")) ~= plr.UserId then
					task.wait()
					continue
				end
				
				States.occupied_booth = v
				break
			end
			
			task.wait(0.25)
			fireproximityprompt(Prompt)
			Retry += 1
			
			if Retry >= 10 then
				TrackingBooth = PickABooth()
			end
		end
		
		task.wait(0.75)
		
		local InteractPrompt = States.occupied_booth:FindFirstChild('BoothInteractPrompt',true) :: ProximityPrompt
		
		if InteractPrompt then
			fireproximityprompt(InteractPrompt)
		end
		
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
	
	if not Pairer_Instance then
		repeat task.wait(0.25) until Pairer_Instance
	end
	
	local AddUnit = game:GetService("Players").LocalPlayer.PlayerGui.PAGES.PlayerBoothUI.AddButtons.AddUnitsButton :: TextButton
	local PromptGui = game:GetService("Players").LocalPlayer.PlayerGui.PromptGui :: ScreenGui
	task.wait(0.5)
	
	--Wait until pairer are close
	repeat task.wait(0.25) until (Pairer_Instance.Character:GetPivot().Position - plr.Character:GetPivot().Position).Magnitude <= 10
	
	
	local List = {}
	
	for _,v in PromptGui:GetChildren() do
		if not v:IsA("Frame") then
			continue
		end

		local cn : RBXScriptSignal
		
		cn = v:GetPropertyChangedSignal("Visible"):Connect(function()
			
			if not v.Visible then
				return
			end
			
			for _,v2 in List do
				v2[2]:Disconnect()
			end

			local Calculation_States = {}
			local ScrollingFrame = v.ScrollingFrame :: ScrollingFrame
			local Confirm = v.HolderButtons.ConfirmButton :: TextButton

			task.wait(0.5)

			local HighestRarityFrame = nil :: Frame
			local HighestRarity = 0

			for _,frame : Frame in ScrollingFrame:GetChildren() do
				
				if not frame:IsA("Frame") then
					continue
				end

				if not frame.Visible then
					continue
				end

				local cur_model = frame.Button.ViewportFrame.WorldModel:FindFirstChildOfClass("Model") :: Model

				local cur_rarity = UnitData[cur_model.Name].Rarity or 1

				if cur_rarity > HighestRarity then
					HighestRarityFrame = frame
					HighestRarity = cur_rarity
				end

			end
			
			local MaxPrice = getgenv().Local_Merge_States.Pairer_Budget

			if HighestRarity < 4 then
				MaxPrice = 20000
			end

			task.wait(0.5)

			click_this_gui(HighestRarityFrame)
			
			task.wait(0.35)
			click_this_gui(Confirm)
			
			local SellButton : ImageButton
			local SellTextbox : TextBox
			local Retry = 0
			
			while not SellButton or not SellTextbox do
				local Prompt = game:GetService("Players").LocalPlayer.PlayerGui.PromptGui :: ScreenGui
				
				task.wait(1)
				Prompt:WaitForChild("PromptDefault")

				SellTextbox = game:GetService("Players").LocalPlayer.PlayerGui.PromptGui.PromptDefault:FindFirstChild("Holder").SellTextBox.TextBoxHolder.TextBox
				SellButton = game:GetService("Players").LocalPlayer.PlayerGui.PromptGui.PromptDefault.Holder.Options.Sell
				
				task.wait(.5)
				
				Retry += 1
				
				if Retry >= 20 then
					break
				end
			end
			
			SellTextbox.Text = MaxPrice or 10000000
			
			task.wait(0.5)
			click_this_gui(SellButton)
			task.wait(0.5)
			
			local prefab = 0

			while task.wait(0.15) do
				if not BoothUI.Visible then
					break
				end

				prefab = 0
				for _,v in BoothUI.ScrollingFrame:GetChildren() do

					if v:IsA("Frame") then
						if not v.Visible then
							continue
						end

						if v.Name ~= "UnitGridPrefab" or not v:FindFirstChild("Button") then
							continue
						end

						prefab += 1
					end


				end

				task.wait(0.35)
				if prefab <= 0 then
					break
				end

			end
			
			game:GetService("StarterGui"):SetCore("SendNotification", {
				Title = "Teleporting...";
				Text = 'Getting back to lobby!';
				Duration = 10
			})
			_G.Teleport()
		end)
		
		table.insert(List,{v, cn})
	end
	
	click_this_gui(AddUnit)
	task.wait(0.5)
	
	States.trade_success = true
end

if BoothUI.Visible then
	OnBoothMenuOpened()
end

BoothUI:GetPropertyChangedSignal('Visible'):Connect(function()
	if BoothUI.Visible then
		OnBoothMenuOpened()
		
	else
		if States.trade_success then
			return
		end
		
		task.wait(0.25)
		OnBoothMenuOpened()
	end
end)



while Pairer_Id == 0 do

	for _,v in game:GetService("Players"):GetPlayers() do
		if v.Name ~= getgenv().Merge_States.Pair_With then
			continue
		end

		Pairer_Id = v.UserId
		Pairer_Instance = v
	end

	task.wait(0.5)
end



while task.wait(0.25) do
	ProximityPromptService.Enabled = true
	
	if not States.occupied_booth then
		local IsClaimable = IsBoothClaimable(TrackingBooth)

		if TrackingBooth then
			workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position,TrackingBooth.Position)
		end


		if not IsClaimable then

			if waypoints then
				for i = 1,#waypoints do
					humanoid:MoveTo(humanoid.RootPart.Position)
					task.wait(0.1)
				end
			end



			if reachedConnection then
				reachedConnection:Disconnect()
				reachedConnection = nil
			end

			if blockedConnection then
				blockedConnection:Disconnect()
				blockedConnection = nil
			end

			TrackingBooth = PickABooth()
		end

		if TrackingBooth and (not reachedConnection or not blockedConnection) and not IsCloseEnough() then
			followPath(TrackingBooth.Position)
		end
		
		if IsCloseEnough() then
			OnDestinationReached()
		end
	end
	
	
	
	task.wait(0.5)
	ProximityPromptService.Enabled = false
end
