--Path Finder
local MoveToTarget = getgenv().Configuration.Following or "" --ชื่อของตัวที่จะเดินไปหา
local plr = game:GetService("Players").LocalPlayer

local Target = workspace:FindFirstChild(MoveToTarget) :: Model

if not Target then
	Target = workspace:WaitForChild(MoveToTarget)
end

local Humanoid = plr.Character.Humanoid :: Humanoid

local StarterGui = game:GetService("StarterGui")
local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local path = PathfindingService:CreatePath()

local character = plr.Character
local humanoid = Humanoid

local waypoints
local nextWaypointIndex
local reachedConnection
local blockedConnection


local MoveToFinished = Instance.new("BindableEvent")
local _STEP_NAME = 'Buyer_Move_Step'

local function MoveTo(Position: Vector3)

	RunService:UnbindFromRenderStep(_STEP_NAME)
	task.wait()

	local TravelTime = math.min(2,(Position - character:GetPivot().Position).Magnitude/60)
	local TimeSpennt = 0

	local Origin = character:GetPivot()
	local _,size = character:GetBoundingBox()

	RunService:BindToRenderStep(_STEP_NAME, Enum.RenderPriority.Character.Value,function(dt)

		dt = math.min(0.25,dt)

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
	
	if reachedConnection then
		reachedConnection:Disconnect()
	end
	
	if blockedConnection then
		reachedConnection:Disconnect()
	end

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

					--OnDestinationReached()
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


while task.wait(4) do
	MoveTo(Target.PrimaryPart.Position + Target.PrimaryPart.CFrame.LookVector)
end
