local KEY = "98821636884"
local Lobby_Id = 17017769292
local plr = game:GetService("Players").LocalPlayer

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
	['PC Name'] = 'Xenon Hub 1',
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
	
	["Farm Tower Of Eternity Mode"] = true
};

if getgenv().Configuration["Farm Tower Of Eternity Mode"] and game.GameId == Lobby_Id then
	loadstring(game:HttpGet('https://raw.githubusercontent.com/RamasaSakura/Anime_Defender_Helper/main/Helpers/AD_Auto_Tower.lua'))(KEY)
else
	loadstring(game:HttpGet('https://raw.githubusercontent.com/Xenon-Trash/Loader/main/Loader.lua'))(KEY)
end

