local Lobby_Id = 17017769292
local ProximityPromptService = game:GetService("ProximityPromptService")
local GuiService = game:GetService('GuiService')
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local StarterGui = game:GetService("StarterGui")
local plr = game:GetService("Players").LocalPlayer

plr:WaitForChild("PlayerGui")
local PlayerGui = plr.PlayerGui

if not game:IsLoaded() then
	game.Loaded:Wait()
	task.wait(2)
end

local Locations = {
	Trade_Portal = CFrame.new(95.45,12.349,-322.2563,-0.7972,-0.32521,0.508,-0.264,0.945,0.190,-0.54277,0.0172,-0.839)
}


if not plr.Character then
	plr.CharacterAdded:Wait()
end

if not plr:HasAppearanceLoaded() then
	plr.CharacterAppearanceLoaded:Wait()
end

plr.Character:WaitForChild("Humanoid")


local PlaceID = Lobby_Id --Teleport to main game instead of subplace (Prevent some funky stuff)

---------------------------------------

if not getgenv().Helpers then
	getgenv().Helpers = {}
end	

getgenv().Configuration = {

	['Following'] = getgenv().Helpers.Following or '' --Leader name

};

local function IsInLobbyGame()
	return game.PlaceId == Lobby_Id
end

if IsInLobbyGame() then
	loadstring(game:HttpGet('https://raw.githubusercontent.com/RamasaSakura/Anime_Defender_Helper/main/Extra_Feature/PathFinder.lua'))()	
else
loadstring(game:HttpGet('https://raw.githubusercontent.com/RamasaSakura/Anime_Defender_Helper/main/Helpers/Anime_Defenders_Auto_Play_Agent.lua'))()

	if not game:IsLoaded() then
	game.Loaded:Wait()
	end

local plr = game:GetService("Players").LocalPlayer
local plr = game:GetService("Players").LocalPlayer

local function MakeItClear(v: Instance?)
	if v:IsA("BasePart") or v:IsA("Decal") or v:IsA("Texture") then
		v.Transparency = 1
		
	elseif v:IsA("Beam") or v:IsA("ParticleEmitter") or v:IsA('BillboardGui') then
		v.Enabled = false

	end
end


for _,v in game:GetDescendants() do
	MakeItClear(v)
end


game.DescendantAdded:Connect(MakeItClear)

if not plr.Character then
	plr.CharacterAdded:Wait()
end

if not plr:HasAppearanceLoaded() then
	plr.CharacterAppearanceLoaded:Wait()
end

plr.Character:WaitForChild("Humanoid")
end
