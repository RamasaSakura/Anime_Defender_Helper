--[[ Reference sheet

@ Comp Behavior

Spread upgrade: Upgrade Prioritized unit first but will switch two second most important unit and
switch to third most important when no more unit to switch it will switch to Proritized unit


NOTES:
Config may not work because I just dumb.

]]

warn("Auto Play Pre-Build v 1.1.0.3")
local Config = {
	["Node Distance From Spawner"] = 4; --This always be 1 on Hall of mirror
	["Minimum Distance From Node"] = 4
};

local AI_Config = {
	["AI Preset"] = 'Rarest' :: 'Rarest' | 'Most Expensive' | 'Highest Level' | 'Slot Order' ;  --ตั้งค่า AI auto-play เว้นว่างถ้าจะปรับเอง

	['Comp Settings'] = { --Place unit based on priority (must place to that amount first before switch to lower priority)
		Unit_Placement = {
			[1] = 2;
			[2] = 2;
		};

		Upgrade_Switch_Count = {
			[1] = 2 --Upgrade prioritized unit 2 levels before switching
		}
	};


	['Comp Behavior'] = 'Spread Upgrade' :: 'Spread Upgrade' | 'Maxed Prioritized Unit'

}


local Preset = {
	AI = {
		['Most Expensive'] = { --วางตัวแพงสุดก่อน
			Price = 100;
			Level = 0.5;
			Rarity = 1;
			Slot = 0.1
		};

		['Highest Level'] = { --วางตัวเวลสูงสุด
			Price = 0.1;
			Rarity = 0.1;
			Level = 100;
			Slot = 0.1
		};

		['Slot Order'] = { --วางตัวตามอันดับที่ใส่มา
			Price = 0.1;
			Level = 0.1;
			Rarity = 0.1;
			Slot = 100
		};

		['Rarest'] = { --วางตัวหายากสุดก่อน
			Price = -50;
			Level = -50;
			Rarity = 200;
			Slot = -10
		};

		[''] = { --ปรับเองได้
			Price = 1;
			Level = 1;
			Rarity = 1;
			Slot = 1
		}
	}
}


local Rarity_Level_From_String = {
	['Rare'] = 1;
	['Epic'] = 2;
	['Legendary'] = 3;
	['Mystical'] = 4;
	['Limited'] = 5;
	['Secret'] = 6
}

local Possible_Colors = {
	['Secret'] = {
		Color3.new(1, 0, 0);
		Color3.new(1, 1, 1);
	};

	['Limited'] = {
		Color3.new(1, 0.0666667, 1);
		Color3.new(1, 1, 1)
	};

	['Mystical'] = {
		Color3.fromRGB(255,0,0);
		Color3.fromRGB(255,255,0);
		Color3.fromRGB(0,255,0);
		Color3.fromRGB(0,255,255);
		Color3.fromRGB(0,0,255);
		Color3.fromRGB(255,0,255)
	};

	["Legendary"] = {
		Color3.new(1,0.584314,0);
		Color3.new(0.988235,1,0.188235)
	};

	['Epic'] = {
		Color3.new(0.368627, 0.0745098, 1);
		Color3.new(0.521569, 0.4, 1)
	};

	['Rare'] = {
		Color3.new(0.12549, 0.619608, 1);
		Color3.new(0.25098, 0.537255, 1)
	}
}

local blacklist_location = {} --Not allowed placing unit on position in this table

--print(Color_Similarity(Color3.new(1, 0.501961, 0.215686),Possible_Colors.Legendary[1]))
--print(Color_Similarity(Color3.new(1, 0.501961, 0.215686),Possible_Colors.Legendary[2]))

-------------------------------------------------------------------

local Paths_Folder = workspace.Paths :: Folder
local PhysicalMap = workspace.PhysicalMap :: Folder
local Units_Folder = workspace.Units :: Folder

local VirtualInputManager = game:GetService("VirtualInputManager")
local TextChatService = game:GetService("TextChatService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local plr = game:GetService("Players").LocalPlayer
local GuiService = game:GetService("GuiService")
local GameInitialized = false

local Checked = false

local Player_Index = 0

for i,v in game:GetService("Players"):GetPlayers() do
	if v == plr then
		Player_Index = i
		break
	end
end


local Random = Random.new()

local Upgrade_Data = require(game:GetService("ReplicatedStorage").Modules.Bins.UnitUpgradeData) :: {[string] : {
	Cost: number,
	Range: number,
	Damage: number,
	Cooldown: number}}


local leaderstats = plr:WaitForChild("leaderstats") :: Folder
local yen_value = leaderstats.Yen :: NumberValue
local Camera = workspace.CurrentCamera

------GUI
local Toolbar = game:GetService("Players").LocalPlayer.PlayerGui.HUD.Toolbar :: Frame
local MatchResultPage = game:GetService("Players").LocalPlayer.PlayerGui.PAGES.MatchResultPage :: Frame
local UnitBar = Toolbar.UnitBar :: Frame
local UnitHolder = UnitBar.UnitHolder :: Frame
local Upgrade_Text = game:GetService("Players").LocalPlayer.PlayerGui.UI.GUIs.LocalUnitBillboard.MainFrame.HolderButtons.UpgradeButton.TextLabel --Value as price?
local HolderButtons = game:GetService("Players").LocalPlayer.PlayerGui.UI.GUIs.LocalUnitBillboard.MainFrame.HolderButtons
local Upgrade_Button = HolderButtons:WaitForChild('UpgradeButton',5) :: TextButton

local UnitBillboard = game:GetService("Players").LocalPlayer.PlayerGui.UI.GUIs.LocalUnitBillboard :: BillboardGui

local HallOfMirrorId = 17018663967

Toolbar.Visible = true

local PathSplitter = Paths_Folder:GetChildren()

local Selected_Path = 1 --Just leave it be should be fine outside hall of mirror
local Selected_Folder = Paths_Folder:FindFirstChild(tostring(Selected_Path)) :: Folder


local Total_Nodes = #Selected_Folder:GetChildren()
local Starting_Node = Selected_Folder:FindFirstChild(tostring(Total_Nodes - math.round(((Config["Node Distance From Spawner"] or 0)+(Player_Index*3)))))

local Current_Tracking_Node = Starting_Node :: BasePart

local Raycast = RaycastParams.new()
Raycast.FilterDescendantsInstances = {PhysicalMap, Units_Folder}
Raycast.FilterType = Enum.RaycastFilterType.Include

local Placed_On_Nodes = {}

type rarity = 'Rare' | 'Epic' | 'Legendary' | 'Mystical' | 'Limited' | 'Secret'
type problems = 'queue_placement' | 'queue_upgrade'
type ai_interest = 'Price' | 'Level' | 'Rarity' | 'Slot' --These data are static when loaded into inventory
type askable_topic = 'yen_goal' | 'cur_upgrade_level' | 'rarity_level' | 'slot_order'
type queue_status = 'placement' | 'upgrade'

local function create_event(name)
	local new = Instance.new("BindableEvent")
	new.Name = name
	return new
end

local function create_event_function(name)
	local new = Instance.new("BindableFunction")
	new.Name = name
	return new
end

local Available_Units_Info = {}
local Connections = {
	comps = {};

	general = {};
}

local States = {
	comps = {
		cycle = 1
	};

	general = {
		last_placing_unit = nil :: string;

		last_placing_model = nil :: Model
	}
}

local Events = {
	comps = {
		OnUnitPlaced = create_event("OnUnitPlaced");
		OnUnitUpgraded = create_event('OnUnitUpgraded');


		IsCompSatisfied = create_event_function("IsCompSatisfied")
	};

	core = {
		OnGameStarted = create_event("OnGameStarted");
		OnUnitAddedToInventory = create_event("OnUnitAddedToInventory")
	}
}

local Queues = {

}

local Info_Ranking = {
	Price = {};
	Rarity = {};
	Level = {};
	Slot = {}
}


local ProblemsSolver = {
	['queue_placement'] = function(option_1,option_2)
		local default_score = 10
		local option_score = {
			[1] = 0;
			[2] = 0
		}

		--[[local cloned_option_1 = (typeof(option_1) == 'table' and table.clone(option_1)) or nil
		local cloned_option_2 = (typeof(option_2) == 'table' and table.clone(option_2)) or nil

		local function Ask_Interest(topic: askable_topic, asking: ai_interest)
			option_score[1] += How_Much_Are_You_Interested_In_This(cloned_option_1[topic],asking,cloned_option_1)
			option_score[2] += How_Much_Are_You_Interested_In_This(cloned_option_2[topic],asking,cloned_option_2)
		end

		if cloned_option_2 and cloned_option_1 then
			Ask_Interest('yen_goal','Price')
			Ask_Interest('cur_upgrade_level','Level')
			Ask_Interest('rarity_level','Rarity')
			Ask_Interest('slot_order','Slot')
		end]]

		Adjust_Queues(option_1,option_2,option_score, "queue_placement")

	end,

	['queue_upgrade'] = function(option_1,option_2, IsRecursive: boolean?)
		local default_score = 10
		local option_score = {
			[1] = 0;
			[2] = 0
		}

		--[[local cloned_option_1 = (typeof(option_1) == 'table' and table.clone(option_1)) or nil
		local cloned_option_2 = (typeof(option_2) == 'table' and table.clone(option_2)) or nil

		local function Ask_Interest(topic: askable_topic, asking: ai_interest)
			option_score[1] += How_Much_Are_You_Interested_In_This(cloned_option_1[topic],asking,cloned_option_1,cloned_option_1.action_status == 'upgrade' and 0.1)
			option_score[2] += How_Much_Are_You_Interested_In_This(cloned_option_2[topic],asking,cloned_option_2,cloned_option_2.action_status == 'upgrade' and 0.1)
		end

		if cloned_option_2 and cloned_option_1 then
			Ask_Interest('yen_goal','Price')
			Ask_Interest('cur_upgrade_level','Level')
			Ask_Interest('rarity_level','Rarity')
			Ask_Interest('slot_order','Slot')
		end]]

		Adjust_Queues(option_1,option_2,option_score, "queue_upgrade")



	end,
}

local Queue_Actions = {
	['placement'] = function(cur_queue_data)

		Place_Unit_Here(cur_queue_data,Seek_Placeable_Position())

		return true
	end,

	['upgrade'] = function(cur_queue_data)
		Upgrade_This_Unit(cur_queue_data)

		return true
	end,
}



local function IsHallOfMirror()
	return game.PlaceId == HallOfMirrorId
end

function Adjust_Rank()
	task.wait(1)


	for _,v in Available_Units_Info do
		if not table.find(Info_Ranking.Rarity,v.rarity_level) then
			table.insert(Info_Ranking.Rarity,v.rarity_level)
		end

		if not table.find(Info_Ranking.Price,v.yen_goal) then
			table.insert(Info_Ranking.Price,v.yen_goal)
		end


		if not table.find(Info_Ranking.Level,v.cur_upgrade_level) then
			table.insert(Info_Ranking.Level,v.cur_upgrade_level)
		end

		if not table.find(Info_Ranking.Slot,v.slot_order) then
			table.insert(Info_Ranking.Slot,v.slot_order)
		end


	end

	table.sort(Info_Ranking.Rarity, function(a,b)
		return a > b
	end)

	table.sort(Info_Ranking.Price, function(a,b)
		return a > b
	end)

	table.sort(Info_Ranking.Level, function(a,b)
		return a > b
	end)

	table.sort(Info_Ranking.Slot, function(a,b)
		return a < b
	end)
end

function Adjust_Queues(option_1,option_2,score_sheet, last_problem: problems)
	table.insert(Queues,option_1)
end

function Ask_AI_Decision(option_1, option_2, problem: problems,...)
	return ProblemsSolver[problem](option_1,option_2,...)
end

function GetPrioritized_Level(full_data) --Lower number mean higher priority

end

function deepCopy(original)
	local copy = {}
	for key, value in pairs(original) do
		if type(value) == 'table' then
			copy[key] = deepCopy(value)
		else
			copy[key] = value
		end
	end
	return copy
end

function AddUpgradeQueue(Added_Data,placed_position)

	local data = Added_Data
			--[[local new = {}

			for i,v in data do
				if typeof(v) == 'table' then
					continue
				end

				new[i] = v
			end

			new.statics = {}

			new.placed_info = {}

			for i,v in data.statics do
				new.statics[i] = v
			end]]

	data.action_status = 'upgrade'
	data.action_in_progress = false
	local new = deepCopy(data)

	table.insert(data.placed_info,new)

	local data = new
	local index = #data.placed_info



	if not data.position and placed_position then
		data.position = placed_position
	end

	--data.unit_name = States.general.last_placing_unit

	local next_level_data = Upgrade_Data[data.unit_name][data.cur_upgrade_level]

	--data.cur_upgrade_level += 1



	--data.action_status = 'upgrade'
	--data.action_in_progress = false

	if not next_level_data then
		--table.remove(Queues,1)
		return
	end

	data.yen_goal = next_level_data.Cost
	Ask_AI_Decision(data,Queues[1], "queue_upgrade")


end

local Comp_Handler = {
	["Spread Upgrade"] = function(data)


		Connections.comps.OnUnitPlaced = Events.comps.OnUnitPlaced.Event:Connect(function(data, placed_position)
			AddUpgradeQueue(data,placed_position)
		end)

		Connections.comps.OnUnitUpgraded = Events.comps.OnUnitUpgraded.Event:Connect(function(data)
			AddUpgradeQueue(data)
		end)

		Connections.comps.OnUnitAddedToInventory = Events.core.OnUnitAddedToInventory.Event:Connect(function(unit_id)


		end)

		Connections.comps.OnGameStarted = Events.core.OnGameStarted.Event:Once(function()

			local option_score = {}


			local options = {}

			for i,v in Available_Units_Info do
				options[i] = deepCopy(v)

				option_score[i] = {0,v}
			end

			local function Ask_Interest(topic: askable_topic, asking: ai_interest)
				for i,v in options do
					option_score[i][1] += How_Much_Are_You_Interested_In_This(v[topic],asking,v)
				end
			end

			Ask_Interest('yen_goal','Price')
			Ask_Interest('cur_upgrade_level','Level')
			Ask_Interest('rarity_level','Rarity')
			Ask_Interest('slot_order','Slot')

			table.sort(option_score, function(a,b)
				return a[1] > b[1]
			end)

			table.clear(Queues)

			for i,v in option_score do
				for _ = 1, math.min(2,AI_Config["Comp Settings"].Unit_Placement[i] or 2) do
					Ask_AI_Decision(deepCopy(v[2]),Queues[1], "queue_placement")
				end
			end
		end)

		Events.comps.IsCompSatisfied.OnInvoke = function(data)
			if not Upgrade_Data[data.unit_name] then --No upgrade data?
				return false
			end

			local next_level_data = Upgrade_Data[data.unit_name][data.cur_upgrade_level]

			if not next_level_data then --Maxed out?
				return true
			end

			return data.cur_upgrade_level > 2 * States.comps.cycle
			--return false --Test
		end
	end,
}

local function Color_Similarity(Color_1: Color3, Color_2: Color3) --Higher mean not closer
	local R1, G1, B1 = Color_1.R, Color_1.G, Color_1.B
	local R2, G2, B2 = Color_2.R, Color_2.G, Color_2.B
	local R, G, B = (R1 - R2), (G1 - G2), (B1 - B2)

	return math.sqrt((R^2) +( G^2) + (B^2))
end

local function IsAPlacingUnit(Model: Model?)

	if not Model:IsA("Model") then
		return false
	end

	if not Model:FindFirstChildOfClass("Humanoid") or game:GetService("Players"):GetPlayerFromCharacter(Model) then
		return false
	end

	if not Model:GetAttribute("Entity") or not Model:GetAttribute("ClientEntity") then
		return true
	end

	return true
end

local function Predict_Rarity(Gradient_To_Predict_From : UIGradient) : rarity

	if #Gradient_To_Predict_From.Color.Keypoints >= 6 then

		local Lean_To_White = 0
		local Required = #Gradient_To_Predict_From.Color.Keypoints/2

		for _, keypoint in Gradient_To_Predict_From.Color.Keypoints do
			if Color_Similarity(Color3.new(1,1,1),keypoint.Value) <= 0.45 then
				Lean_To_White += 1
			end
		end

		if Lean_To_White >= Required then
			return "Limited"

		else
			return 'Mystical'
		end

	end


	for rarity, list_color in Possible_Colors do
		--Score_Sheet[i] = 10 + (0.5 * #list_color)  --Score will be subtract more when a color is not similair (also slightly add score on multiple color check)


		local Half = math.floor(#list_color/2)
		local Similair_Count = 0
		for _, keypoint in Gradient_To_Predict_From.Color.Keypoints do


			for _,v : Color3 in list_color do
				if Color_Similarity(keypoint.Value,v) <= 0.3 then
					Similair_Count += 1
				end

				if Similair_Count > Half or Similair_Count == #list_color then
					return rarity
				end
			end
		end

	end

	return warn("Can't predict rarity")
end

function Upgrade_This_Unit(queue_data)

	if not queue_data or not queue_data.position then
		return
	end

	local Guis_Folder = game:GetService("Players").LocalPlayer.PlayerGui.UI.GUIs :: Folder
	local UnitBillboard = game:GetService("Players").LocalPlayer.PlayerGui.UI.GUIs.LocalUnitBillboard :: BillboardGui
	local Price_Label = HolderButtons:WaitForChild('UpgradeButton',5).TextLabel :: TextLabel

	Camera.CameraType = Enum.CameraType.Scriptable

	local cur_unit_button = queue_data.statics.frame :: Frame
	local Position = queue_data.position

	Toolbar.Visible = false

	local Tween = TweenService:Create(Camera,TweenInfo.new(0.35), {CFrame = CFrame.new(Position+ Vector3.new(0,8,0), Position)})


	Tween.Completed:Once(function()
		--click_this_gui(cur_unit_button)
		task.wait(0.25)


		local vector: Vector3 = Camera:WorldToViewportPoint(Position)
		local screenPoint = Vector2.new(vector.X, vector.Y)

		VirtualInputManager:SendMouseButtonEvent(vector.X,vector.Y,0,true,game,0)
		VirtualInputManager:SendMouseButtonEvent(vector.X,vector.Y,0,false,game,0)

		local SameTarget = 0 --Increased when found unit (possibly not your?)

		while not UnitBillboard.Enabled do
			task.wait(0.35)

			if SameTarget >= 10 then
				--Ditch this thing (Probably goes out of sync?)
				table.remove(Queues,1)
				AddUpgradeQueue(queue_data,queue_data.position)
				Toolbar.Visible = true
				ZoomOut()

				return
			end

			vector= Camera:WorldToViewportPoint(Position)
			screenPoint = Vector2.new(vector.X, vector.Y)
			
			local offset = {
				x = 0 + (SameTarget * Random:NextNumber(-2,2));
				y = 0 + (SameTarget * Random:NextNumber(-2,2))
			}


			VirtualInputManager:SendMouseButtonEvent(vector.X+offset.x,vector.Y+offset.y,0,true,game,0)
			VirtualInputManager:SendMouseButtonEvent(vector.X+offset.x,vector.Y+offset.y,0,false,game,0)

			--[[local Result = workspace:Raycast(Position, Vector3.yAxis * -20,Raycast)
			
			if IsInvalidToPlace(Result) or IsAPlacingUnit(Result.Instance.Parent) then
				
			end]]
			SameTarget += 1
		end

		if SameTarget >= 10 then
			Toolbar.Visible = true
			ZoomOut()
			return
		end

		Upgrade_Button.Parent = Guis_Folder

		local Retry = 0

		while task.wait(0.25) do

			local Result = Price_Label.Text:gsub(",",""):match("%d+")

			if Result and (#Result > 0 or Retry >= 20) then
				break
			end

			Retry += 1
		end

		if Retry >= 20 then
			Toolbar.Visible = true
			Upgrade_Button.Parent = HolderButtons

			ZoomOut()
			AddUpgradeQueue(queue_data,queue_data.position)

			return
		end

		task.wait(0.5)

		Retry = 0

		local old_price = tonumber(Price_Label.Text:gsub(",",""):match("%d+"))

		while not old_price or old_price == tonumber(Price_Label.Text:gsub(",",""):match("%d+")) do

			if not old_price then
				old_price = tonumber(Price_Label.Text:gsub(",",""):match("%d+"))
			end

			task.wait(0.25)
			click_this_gui(Upgrade_Button)

			Retry += 1

			if Retry >= 10 then
				table.remove(Queues,1)

				Toolbar.Visible = true
				ZoomOut()

				Upgrade_Button.Parent = HolderButtons
				AddUpgradeQueue(queue_data,queue_data.position)

				return
			end
		end

		if Price_Label.Text == "" or string.lower(Price_Label.Text) == "max" then
			table.remove(Queues,1)

			Toolbar.Visible = true
			ZoomOut()

			Upgrade_Button.Parent = HolderButtons
			AddUpgradeQueue(queue_data,queue_data.position)
			return
		end


		Upgrade_Button.Parent = HolderButtons
		task.wait(0.1)

		--table.remove(Queues,table.find(Queues,queue_data))

		local next_level_data = Upgrade_Data[queue_data.unit_name][queue_data.cur_upgrade_level+1]

		if not next_level_data then
			table.remove(Queues,1)

			Toolbar.Visible = true
			ZoomOut()
			AddUpgradeQueue(queue_data,queue_data.position)


			return
		end

		queue_data.cur_upgrade_level += 1

		queue_data.yen_goal = next_level_data.Cost

		ZoomOut()

		Toolbar.Visible = true

		queue_data.action_in_progress = false
		if Retry >= 10 then
			return true
		end
		table.remove(Queues,1)

		Events.comps.OnUnitUpgraded:Fire(queue_data, Position)

		task.wait(0.25)

		if not next_level_data then --Maxed?
			return true
		end

		return
	end)


	Tween:Play()

	return true
end

function ZoomOut()
	TweenService:Create(Camera,TweenInfo.new(1,Enum.EasingStyle.Sine), {CFrame = CFrame.new(Camera.CFrame.Position + (Vector3.yAxis * 30))*Camera.CFrame.Rotation}):Play()
end

function CancelPlacement()
	if game:GetService("UserInputService").TouchEnabled and game:GetService("Players").LocalPlayer.PlayerGui.HUD:FindFirstChild("MobileButtonHolder") then

		while task.wait(0.5) do

			if game:GetService("Players").LocalPlayer.PlayerGui.HUD.MobileButtonHolder.Visible then
				click_this_gui(game:GetService("Players").LocalPlayer.PlayerGui.HUD.MobileButtonHolder.CancelButton)
			end


		end	


	else
		VirtualInputManager:SendKeyEvent(true,Enum.KeyCode.C,false,game)
		VirtualInputManager:SendKeyEvent(false,Enum.KeyCode.C,false,game)
	end
end

function Place_Unit_Here(queue_data, Position: Vector3, Counter :number?)


	Position = Position or Seek_Placeable_Position()

	if not Position then
		queue_data.action_in_progress = false
		return
	end

	Camera.CameraType = Enum.CameraType.Scriptable

	local cur_unit_button = queue_data.statics.frame :: Frame

	local Goal = CFrame.new(Position+ Vector3.new(0,8,0), Position)
	local Tween = TweenService:Create(Camera,TweenInfo.new(0.1), {CFrame = Goal})

	Toolbar.Visible = true
	Upgrade_Button.Parent = HolderButtons
	task.wait()
	Tween.Completed:Once(function()
		--click_this_gui(cur_unit_button)
		task.wait(0.15)

		local Retry = 0

		while not States.general.last_placing_model do

			if Retry >= 15 then
				CancelPlacement()


				table.insert(blacklist_location,Position)

				task.wait(0.5)
				if Counter then
					Counter += 1
				end

				Place_Unit_Here(queue_data,Seek_Placeable_Position(), Counter or 0)



				return
			end

			Retry += 1
			click_this_gui(cur_unit_button)

			task.wait(0.5)
		end

		if Retry >= 15 or not States.general.last_placing_model then
			return
		end

		Toolbar.Visible = false

		local model = States.general.last_placing_model:: Model

		model:WaitForChild("Humanoid")
		model:WaitForChild("HumanoidRootPart")

		local vector: Vector3 = Camera:WorldToScreenPoint(Position)
		--local screenPoint = Vector2.new(vector.X, vector.Y)


		--VirtualInputManager:SendMouseButtonEvent(vector.X,vector.Y,0,true,game,0)
		--VirtualInputManager:SendMouseButtonEvent(vector.X,vector.Y,0,false,game,0)

		task.wait(0.5)


		Retry = 0
		local _,size = model:GetBoundingBox()

		local ValidFailed = 0
		while model.Parent do

			if Retry >= 10 then

				table.insert(blacklist_location, Position)
				Toolbar.Visible = true
				task.wait()
				if Counter then
					Counter += 1
				end

				Place_Unit_Here(queue_data,Seek_Placeable_Position(), Counter or 0)
				return
			end

			--Toolbar.Visible = false
			task.wait(0.125)

			local offset = {
				x = 0 + (Retry * Random:NextNumber(-5,5));
				y = 0 + (Retry * Random:NextNumber(-5,5))
			}

			--print(`Distance: {(Vector3.new(model.HumanoidRootPart.Position.X,Position.Y,model.HumanoidRootPart.Position.X) - Position).Magnitude}`)

			Camera.CFrame = Goal
			if Retry <= 6 or (model:FindFirstChild("HumanoidRootPart") and (Vector3.new(model.HumanoidRootPart.Position.X,Position.Y,model.HumanoidRootPart.Position.Z) - Position).Magnitude > 3) then
				--Test area to see if it placeable
				VirtualInputManager:SendMouseMoveEvent(vector.X+offset.x,vector.Y+offset.y,game)
				model:PivotTo(CFrame.new(Position + Vector3.new(0,size.Y/2,0)))
			else
				VirtualInputManager:SendMouseButtonEvent(vector.X+offset.x,vector.Y+offset.y,0,true,game,0)
				VirtualInputManager:SendMouseButtonEvent(vector.X+offset.x,vector.Y+offset.y,0,false,game,0)

			end

			Retry += 1
		end

		ZoomOut()
		task.wait(0.5)

		if Retry >= 10 then
			return
		end

		Toolbar.Visible = true

		table.remove(Queues,1)

		--queue_data.action_in_progress = false
		Events.comps.OnUnitPlaced:Fire(queue_data, Position)

	end)
	Tween:Play()

end

function IsInvalidToPlace(Result : RaycastResult)
	return not Result or Result.Instance.Parent.Name == "Path" or IsAPlacingUnit(Result.Instance.Parent)
end

function Seek_Placeable_Position()

	if not Current_Tracking_Node then
		return warn("Ran out of tracking node")
	end

	--Raycast 4 directions
	local Directions = {
		Vector3.new(1, 0, 0),
		Vector3.new(-1, 0, 0),
		Vector3.new(0, 0, 1),
		Vector3.new(0, 0, -1)
	}

	local Placement_Position
	local blacklist_distance = 1 --Can't place with these distance of blacklisted location

	for _, dir in Directions do
		local Result = workspace:Raycast(Current_Tracking_Node.Position + (dir * Config["Minimum Distance From Node"]) + (Vector3.yAxis * 8), Vector3.yAxis * -20,Raycast)


		if IsInvalidToPlace(Result) then
			if Result then
				table.insert(blacklist_location, Result.Position)

			end

			continue
		end

		Placement_Position = Result.Position

		for _,v in blacklist_location do
			if (Vector3.new(Result.Position.X,v.Y,Result.Position.Z) - v).Magnitude <= blacklist_distance then
				Placement_Position = nil
				break
			end	
		end

		if not Placement_Position then
			continue
		end

		break
	end


	if not Placement_Position then

		local old_name = tonumber(Current_Tracking_Node.Name)

		Current_Tracking_Node = nil

		while not Current_Tracking_Node do

			old_name = old_name - 1
			Current_Tracking_Node = Selected_Folder:FindFirstChild(tostring(old_name))
			task.wait()
		end



		Placement_Position = Seek_Placeable_Position() --Recursive?
	end


	return Placement_Position
end



local function Add_Information(Unit_Frame: Frame?)
	local Button = Unit_Frame.Button :: TextButton
	local UnitLevel = tonumber(Button.UnitNameLabel.Text:gsub(",",""):match("%d+"))
	local UnitCost = tonumber(Button.TowerCostFrame.CostLabel.Text:gsub(",",""):match("%d+"))

	Available_Units_Info[Unit_Frame.LayoutOrder] = {

		statics = {
			level = UnitLevel; --Unit level not upgrade
			cost = UnitCost; --Placement cost
			rarity = Predict_Rarity(Button.BackgroundFrame.UIGradient); --Rarity in string

			frame = Unit_Frame
		};

		unit_name = `{Button.ViewportFrame.WorldModel:FindFirstChildOfClass("Model").Name}`;
		rarity_level = 0;
		yen_goal = 0; --Required yen to perform action
		cur_upgrade_level = 1;
		slot_order = Unit_Frame.LayoutOrder;
		action_status = 'placement' :: queue_status;
		action_in_progress = false;

		placed_info = {

		};

	}

	Available_Units_Info[Unit_Frame.LayoutOrder].rarity_level = Rarity_Level_From_String[Available_Units_Info[Unit_Frame.LayoutOrder].statics.rarity]
	Available_Units_Info[Unit_Frame.LayoutOrder].yen_goal = UnitCost

	--warn(`Unit with cost: {UnitCost} Have rarity of: {Available_Units_Info[Unit_Frame.LayoutOrder].statics.rarity}`)

	--warn(``)
	Events.core.OnUnitAddedToInventory:Fire(Unit_Frame.LayoutOrder)
end

local function Initialize_Available_Unit()

	if GameInitialized then
		return
	end

	GameInitialized = true

	if not game:IsLoaded() then
		game.Loaded:Wait()
	end

	if not plr.Character then
		plr.CharacterAdded:Wait()
	end



	repeat task.wait() until plr:GetMouse().X ~= 0 and plr:GetMouse().Y ~= 0
	
	Starting_Node = Selected_Folder:FindFirstChild(tostring(Total_Nodes - math.round(((Config["Node Distance From Spawner"] or 0)+(Player_Index*3)))))
	Current_Tracking_Node = Starting_Node


	for _,v in Connections do
		for _,v2 in v do
			v2:Disconnect()
		end
	end
	task.wait()

	Connections.general.yen_tracking = yen_value.Changed:Connect(Queues_Checker)

	Connections.general.match_tracker = MatchResultPage:GetPropertyChangedSignal("Visible"):Connect(function()
		if not MatchResultPage.Visible then
			return
		end

		Clear_For_Next_Stage()
	end)

	Comp_Handler[AI_Config["Comp Behavior"]]()

	StarterGui:SetCore("SendNotification", {
		Title = 'ระบบกำลังคำนวน';
		Text = 'กำลังรอข้อมูลตัวละคร'
	})



	for _,v in UnitHolder:GetChildren() do

		if not v:IsA("Frame") then
			continue
		end

		if v.Name == "LockedFrame" then
			v:GetPropertyChangedSignal("Name"):Once(function()
				Add_Information(v)
			end)
		else
			Add_Information(v)
		end
	end

	--[[while task.wait() do
		for _,v in UnitHolder:GetChildren() do
			if not v:IsA("Frame") then
				continue
			end

			if v.Name ~= "LockedFrame" then
				Adjust_Rank()
				break
			end
		end
	end]]

	--Connections.general.Toolbar_Visibility = Toolbar:GetPropertyChangedSignal("Visible")
	Events.core.OnGameStarted:Fire()


	task.wait(3)
	StarterGui:SetCore("SendNotification", {
		Title = 'ระบบเริ่มทำงานแล้ว';
		Text = 'เริ่มทำการ เล่นอัตโนมัติ'
	})


end


function How_Much_Are_You_Interested_In_This(base_score: number, asking_about: ai_interest, options_data, topic_multiplier: boolean)

	local multiplier = 1
	local value = Preset.AI[AI_Config["AI Preset"]][asking_about]

	if options_data then
		if Events.comps.IsCompSatisfied:Invoke(options_data) then --Massively lower interest if already satisfied comp
			multiplier = 0.01


		end
	end

	if value < 0 then --Increase if value is negative
		multiplier = -10
		topic_multiplier = -10
	end

	return base_score * value * multiplier * (topic_multiplier or 1)
end

function Queues_Checker(current_yen)

	if not Checked then
		return
	end
	
	task.wait(0.5)

	local cur_queue_data = Queues[1]

	if not cur_queue_data or not cur_queue_data.yen_goal or (cur_queue_data.yen_goal > current_yen) or cur_queue_data.action_in_progress then

		if cur_queue_data and not cur_queue_data.yen_goal then
			table.remove(Queues,1) --Remove from queue
		end

		return
	end


	cur_queue_data.action_in_progress = true


	local recorded_action = cur_queue_data.action_status

	_G.LastAction = recorded_action
	local sucess, err = Queue_Actions[cur_queue_data.action_status](cur_queue_data)

	--cur_queue_data.action_in_progress = false

	if sucess then
		warn("SUCCESS!")
	end

	if not sucess then
		warn('Recorded Action: ', recorded_action)
		print(err)
		error(err)
	end

end

function click_this_gui(to_click: GuiObject)
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

workspace.ChildAdded:Connect(function(child)
	if not child:IsA("Model") then
		return
	end

	if not IsAPlacingUnit(child) then
		return
	end

	States.general.last_placing_unit = child.Name
	States.general.last_placing_model = child

	child.AncestryChanged:Connect(function(_,parent)
		if not parent then
			States.general.last_placing_model = nil
		end
	end)

	child.Destroying:Once(function(_,parent)
		States.general.last_placing_model = nil
	end)
end)




--TextChatService.ChatVersion = Enum.ChatVersion.LegacyChatService

local TextChatService = game:GetService("TextChatService")

if TextChatService:FindFirstChild("ClearCommand") then
	TextChatService.ClearCommand:Destroy()
end

local ClearCommand = Instance.new("TextChatCommand")

ClearCommand.Name = 'ClearCommand'

ClearCommand.PrimaryAlias = '/clear'
ClearCommand.SecondaryAlias = '/c'
ClearCommand.Parent = TextChatService

function Clear_For_Next_Stage()

	Checked = false
	GameInitialized = false
	table.clear(Queues)
	table.clear(Available_Units_Info)
	table.clear(blacklist_location)
	table.clear(Info_Ranking)

	task.wait(0.15)

	local vp_size = workspace.CurrentCamera.ViewportSize

	VirtualInputManager:SendMouseButtonEvent(vp_size.X/2,vp_size.Y/2,0,true,game,0)
	VirtualInputManager:SendMouseButtonEvent(vp_size.X/2,vp_size.Y/2,0,false,game,0)
	local PlayNext = game:GetService("Players").LocalPlayer.PlayerGui.PAGES.MatchResultPage.Main.Options.PlayNextButton :: TextButton

	if PlayNext.Visible then
		StarterGui:SetCore("SendNotification", {
			Title = 'ไปชั้นถัดไป';
			Text = 'กำลังล้างข้อมูล ด่านที่แล้ว';
			Duration = 3
		})
	else
		StarterGui:SetCore("SendNotification", {
			Title = 'ไม่ผ่านด่าน';
			Text = 'ระบบจะไม่ทำการออโต้หากแพ้';
			Duration = 10
		})

		return
	end
	task.wait(1)

	while MatchResultPage.Visible do
		click_this_gui(PlayNext)

		task.wait(0.15)
	end

	Queues_Checker(yen_value.Value)

	Toolbar.Visible = true
	Upgrade_Button.Parent = HolderButtons

	Initialize_Available_Unit()
end



ClearCommand.Triggered:Once(function()
	--Disconnect all connections

	StarterGui:SetCore("SendNotification", {
		Title = 'Disconnect';
		Text = 'Clear Auto Play Successfully';
		Duration = 3
	})
	for _,v in Connections do
		for _,v2 in v do
			v2:Disconnect()
		end
	end

	for _,v in Events do
		for _,v2 in v do
			v2:Destroy()
		end
	end
end)


--[[TextChatService.OnIncomingMessage:Connect(function(txt)
	command_process(txt.Text)
	
	return txt
end)
]]

local WaveText = game:GetService("Players").LocalPlayer.PlayerGui.HUD.WaveNumberNotification.WaveNumberText :: TextLabel

local function RefreshWave()
	if Checked then
		return
	end

	local cur_wave = tonumber(WaveText.Text:gsub(",",""):match("%d+"))

	if not cur_wave or cur_wave < 4 then
		return
	end

	local distance = {}

	for _,v in game:GetService("Players"):GetPlayers() do
		table.insert(distance, {v, v.Character:GetPivot().Position.Magnitude})
	end

	table.sort(distance, function(a,b)
		return a[2] < b[2]
	end)

	for i,v in distance do
		if v[1] == plr then
			Player_Index = i

			break
		end
	end

	Starting_Node = Selected_Folder:FindFirstChild(tostring(Total_Nodes - math.round(((Config["Node Distance From Spawner"] or 0)+(Player_Index*4)))))
	Current_Tracking_Node = Starting_Node

	Checked = true
end

WaveText:GetPropertyChangedSignal("Text"):Connect(function()

	RefreshWave()
end)

RefreshWave()

if not MatchResultPage.Visible then
	Initialize_Available_Unit()

	Queues_Checker(yen_value.Value)
else
	Clear_For_Next_Stage()
end



StarterGui:SetCore("SendNotification", {
	Title = 'Finished';
	Text = 'Auto Play Agent Ready';
	Duration = 3
})

--TODO: Add upgrade interest function
_G.Queues = Queues
local TimeSpent = 0
local Queue_Time_Spent = 0
local cur_queue

local function Restore()


	Toolbar.Visible = true
	ZoomOut()

	Upgrade_Button.Parent = HolderButtons
end

game:GetService("RunService").PostSimulation:Connect(function(dt)
	
	if cur_queue and cur_queue ~= Queues[1] then --Reset timer when queue changed
		Queue_Time_Spent = 0
	end
	
	cur_queue = Queues[1]
	
	if cur_queue then
		if cur_queue.yen_goal <= yen_value.Value and cur_queue.action_in_progress then
			Queue_Time_Spent += dt

			if Queue_Time_Spent >= 15 then --Restore states if stuck in same action for too long
				Queue_Time_Spent = 0
				cur_queue.action_in_progress = false

				if cur_queue.action_status == 'upgrade' then
					cur_queue.action_status = 'placement'
					table.remove(Queues, 1)
					Ask_AI_Decision(deepCopy(cur_queue),Queues[1], "queue_placement")
				else
					--table.remove(Queues, 1)
				end

				Restore()
			end

		else
			Queue_Time_Spent = 0
		end
	end

	if Upgrade_Button:IsDescendantOf(HolderButtons) then
		TimeSpent = 0
		return
	end
	
	TimeSpent += dt
	
	if TimeSpent >= 6 then
		local Price_Label = Upgrade_Button:WaitForChild('TextLabel') :: TextLabel
		if Price_Label.Text == "" or Price_Label.Text:lower() == 'max' then

			
			
			if Price_Label.Text:lower() ~= 'max' then
				AddUpgradeQueue(Queues[1],Queues[1].position)
			end
			
			

			Restore()
			table.remove(Queues,1)
			
			TimeSpent = 0
		end
	end
end)

game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Chat,false)
