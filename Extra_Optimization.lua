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
