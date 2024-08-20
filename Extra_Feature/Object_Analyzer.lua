local TabLevel = 0
local plr = game:GetService("Players").LocalPlayer

local Overlap = OverlapParams.new()
Overlap.FilterDescendantsInstances = {plr.Character}
Overlap.FilterType = Enum.RaycastFilterType.Exclude

local List_Of_Instances = {}
local CN = {}

--Make billboard above player head
local function MakeAboveHead(Part: BasePart)
	local Selected_Color = BrickColor.Random().Color

	local Billboard = Instance.new("BillboardGui")
	Billboard.Parent = Part
	Billboard.Adornee = Part
	Billboard.Size = UDim2.fromScale(6,6)
	Billboard.AlwaysOnTop = true
	Billboard.StudsOffset = Vector3.new(0,2,0)
	Billboard.LightInfluence = 0
	Billboard.MaxDistance = 100
	Billboard.SizeOffset = Vector2.new(0,0)

	local TextLabel = Instance.new("TextLabel")
	TextLabel.RichText = true
	TextLabel.BackgroundTransparency = 1
	TextLabel.Text = `{Part.Name}<br/>Parent: ({Part.Parent.Name})`
	TextLabel.TextColor3 = Selected_Color
	TextLabel.Size = UDim2.fromScale(1,1)
	TextLabel.TextScaled = true
	TextLabel.Parent = Billboard
	
	local SelectionBox = Instance.new('SelectionBox')
	SelectionBox.Color3 = Selected_Color
	SelectionBox.Adornee = Part
	SelectionBox.LineThickness = 0.05
	SelectionBox.Parent = Part
	
	Billboard.Parent = Part
	
	table.insert(List_Of_Instances,Billboard)
	table.insert(List_Of_Instances,SelectionBox)
end	

local function PrintTable(Table)
	for Key,Value in pairs(Table) do
		if typeof(Value) == "table" then
			TabLevel = TabLevel + 1
			warn(string.rep("    ",TabLevel - 1)..Key.." : {")
			PrintTable(Value)
			warn(string.rep("    ",TabLevel - 1).."}")
			TabLevel = TabLevel - 1
		else
			warn(string.rep("    ",TabLevel)..Key,Value)
		end
	end
end

CN.Chatted = plr.Chatted:Connect(function(msg)
	if msg ~= '/e clear' then
		return
	end
	
	for _,v in List_Of_Instances do
		v:Destroy()
	end
	
	for _,v in CN do
		v:Disconnect()
	end
end)

for _,v in workspace:GetPartBoundsInBox(plr.Character:GetPivot(),Vector3.one * 40,Overlap) do
	MakeAboveHead(v)
	--PrintTable(workspace:GetPartBoundsInBox(plr.Character:GetPivot(),Vector3.one * 40,Overlap))
end

