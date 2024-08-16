local KEY = "98821636884"


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

local PlaceID = game.PlaceId
local AllIDs = {}
local foundAnything = ""
local actualHour = os.date("!*t").hour
local Deleted = false
local File = pcall(function()
	AllIDs = game:GetService('HttpService'):JSONDecode(readfile("NotSameServers.json"))
end)
if not File then
	table.insert(AllIDs, actualHour)
	writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
end
function TPReturner()
	local Site;
	if foundAnything == "" then
		Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
	else
		Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
	end
	local ID = ""
	if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
		foundAnything = Site.nextPageCursor
	end
	local num = 0;
	for i,v in pairs(Site.data) do
		local Possible = true
		ID = tostring(v.id)
		if tonumber(v.maxPlayers) > tonumber(v.playing) then
			for _,Existing in pairs(AllIDs) do
				if num ~= 0 then
					if ID == tostring(Existing) then
						Possible = false
					end
				else
					if tonumber(actualHour) ~= tonumber(Existing) then
						local delFile = pcall(function()
							delfile("NotSameServers.json")
							AllIDs = {}
							table.insert(AllIDs, actualHour)
						end)
					end
				end
				num = num + 1
			end
			if Possible == true then
				table.insert(AllIDs, ID)
				wait()
				pcall(function()
					writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
					wait()
					game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID, game.Players.LocalPlayer)
				end)
				wait(4)
			end
		end
	end
end

function Teleport()
	while wait() do
		pcall(function()
			TPReturner()
			if foundAnything ~= "" then
				TPReturner()
			end
		end)
	end
end


task.spawn(function()

	local topbar = plr.PlayerGui:WaitForChild('TopBar',5)

	if not topbar then
		while task.wait(3) do
			Teleport()

			if plr.PlayerGui:FindFirstChild("TopBar") then
				break
			end
		end
	end
end)

getgenv().key = KEY
getgenv().Configuration = {
	['Enabled'] = true,
	['Enabled Challenge'] = false,
	['PC Name'] = 'dekonemillionbaht',
	['Delay'] = 20,
	['Leave Delay'] = 5,
	['EquipBest'] = true,
	['Leave At Wave'] = 31,
	['Leave Method'] = 2, -- 1 = Sell,  2 = Leave
	['TradingMode'] = false,
	['ClaimBattlepass'] = true,
	['Roll Mythic'] = false,
	['Roll Method'] = 1,
	['Auto Feed Mythic'] = false,
	['Use Auto Sell'] = false,
	['Sell Config'] = {
		['Rare'] = false,
		['Epic'] = false,
		['Legendary'] = false,
		['Rare Shiny'] = false,
		['Epic Shiny'] = false,
		['Legendary Shiny'] = false,
	},
	['Placement Distance'] = 9,
};

warn(KEY)
loadstring(game:HttpGet('https://raw.githubusercontent.com/Xenon-Trash/Loader/main/Loader.lua'))(KEY)
