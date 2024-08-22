local KEY = "98821636884"
local Lobby_Id = 17017769292
local plr = game:GetService("Players").LocalPlayer

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

-------------------------------
local function click_this_gui(to_click: GuiObject)
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

local function OnReachedDestination(action)
	if action == 'trade' then
		keypress(0x45)
	end


end

local function followPath(destination: Vector3, action)
	local TravelTime = 4
	
	local TimeSpent = 0
	
	local CN
	local original_pos = plr.Character:GetPivot().Position
	CN = RunService.PostSimulation:Connect(function(dt)
		
		TimeSpent += dt
		
		local percent = math.min(TimeSpent/TravelTime,1)
		
		plr.Character:PivotTo(CFrame.new(original_pos:Lerp(destination,percent)))
		
		if percent >= 1 then
			CN:Disconnect()
			task.wait(1)
			OnReachedDestination()
		end
		
	end)
end


---------------------------------------


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
--[[ ถ้าจะแจกหรือขาย ให้เปลี่ยน getgenv().secret_auto_trader เป้น

getgenv().secret_auto_trader = { 
	webhook_url = `` :: string;
	application_id = '' :: string;
	channel_id = '';
	server_id = ''	
}

]]

getgenv().secret_auto_trader = { 
	webhook_url = `https://discord.com/api/webhooks/1276124582910365769/T7VSeP_ySIr73EP_GDYIqIoCvvi7j_7sqng7W4xRu0V24TCjcnF1Imx_jGTg0_BrHCmy` :: string;
	application_id = '1273970162126819359' :: string;
	channel_id = '1276124504044867584';
	server_id = '1273513305608159284'
}
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
	
	["Farm Tower Of Eternity Mode"] = false; --ฟาร์มหอคอย true คือใช่ false คือไม่
	
};

getgenv().Merge_States = {
	['Enabled'] = true
}

local function IsInLobbyGame()
	return game.GameId == 17017769292 or game.GameId == 5836869368
end

if getgenv().Merge_States.Enabled then
	followPath(TowerLandingPoint.Position,'trade')
	return
end	

if getgenv().Configuration["Farm Tower Of Eternity Mode"] and IsInLobbyGame() then
	loadstring(game:HttpGet('https://raw.githubusercontent.com/RamasaSakura/Anime_Defender_Helper/main/Helpers/AD_Auto_Tower.lua'))(KEY)
else
	game:GetService("StarterGui"):SetCore("SendNotification", {
		Text = 'เปลี่ยนโหมดฟาร์ม';
		Title = "กำลังฟาร์ม ไก่ตัน";
		Duration = 5
	})
	loadstring(game:HttpGet('https://raw.githubusercontent.com/Xenon-Trash/Loader/main/Loader.lua'))(KEY)
end
