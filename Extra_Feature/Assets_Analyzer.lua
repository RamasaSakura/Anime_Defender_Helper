local TabLevel = 0
local plr = game:GetService("Players").LocalPlayer
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

PrintTable(plr.PlayerGui.PAGES:GetChildren())
