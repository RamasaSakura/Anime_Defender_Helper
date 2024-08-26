local KEY = "98821636884"
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

local function OnReachedDestination(action)
	if action == 'trade' then
		local teleport_prompt = workspace.Lobby.Build.Portal.TradeTeleport.ActionPrompt :: ProximityPrompt
		
		local Base = teleport_prompt.Parent :: BasePart
		
		workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position,Base.Position)
		
		VirtualInputManager:SendKeyEvent(true,Enum.KeyCode.E,false,game)
		VirtualInputManager:SendKeyEvent(false,Enum.KeyCode.E,false,game)
		
		task.wait()
		local vector: Vector3 = workspace.CurrentCamera:WorldToViewportPoint(Base.Position)
		local screenPoint = Vector2.new(vector.X, vector.Y)

		VirtualInputManager:SendMouseButtonEvent(vector.X,vector.Y,0,true,game,0)
		VirtualInputManager:SendMouseButtonEvent(vector.X,vector.Y,0,false,game,0)
		
		
		local PromptDefault =  game:GetService("Players").LocalPlayer.PlayerGui.PromptGui:WaitForChild("PromptDefault",3) :: Frame
		
		if not PromptDefault then --Retry
			OnReachedDestination(action)
			return
		end
		
		local teleport_trade_button = PromptDefault.Holder.Options.Teleport :: GuiButton
		
		task.wait(1)
		click_this_gui(teleport_trade_button)


	elseif action == "trade_follow" then
		
		local teleport_prompt = workspace.Lobby.Build.Portal.TradeTeleport.ActionPrompt :: ProximityPrompt

		local Base = teleport_prompt.Parent :: BasePart

		workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position,Base.Position)

		VirtualInputManager:SendKeyEvent(true,Enum.KeyCode.E,false,game)
		VirtualInputManager:SendKeyEvent(false,Enum.KeyCode.E,false,game)

		task.wait()
		local vector: Vector3 = workspace.CurrentCamera:WorldToViewportPoint(Base.Position)
		local screenPoint = Vector2.new(vector.X, vector.Y)

		VirtualInputManager:SendMouseButtonEvent(vector.X,vector.Y,0,true,game,0)
		VirtualInputManager:SendMouseButtonEvent(vector.X,vector.Y,0,false,game,0)


		local PromptDefault =  game:GetService("Players").LocalPlayer.PlayerGui.PromptGui:WaitForChild("PromptDefault",5) :: Frame

		if not PromptDefault then --Retry
			OnReachedDestination(action)
			return
		end
		
		local friend_name = getgenv().Merge_States.Pair_With
		local join_friend = game:GetService("Players").LocalPlayer.PlayerGui.PromptGui.PromptDefault.Holder.Options["Join Friend"] :: TextButton
		
		task.wait(0.2)
		click_this_gui(join_friend)
		
		task.wait(0.5)
		
		local prompt_default = game:GetService("Players").LocalPlayer.PlayerGui.PromptGui:WaitForChild("PromptDefault",5) :: ScreenGui
		--[[local Textbox = nil :: TextLabel
		local Retry = 0
		while task.wait(0.25) do
			Textbox = prompt_default:FindFirstChild('TextBox',true)
			
			if not Textbox then
				Retry += 1
				
				if Retry >= 10 then
					return
				end
			end
			
			
		end]]
		
		if not prompt_default then
			OnReachedDestination(action)
			return
		end
		

		local TextBox = prompt_default:WaitForChild('Holder'):WaitForChild("Friend",3):WaitForChild('TextBoxHolder'):WaitForChild('TextBox') :: TextBox
		local TeleportButton = game:GetService("Players").LocalPlayer.PlayerGui.PromptGui.PromptDefault.Holder.Options.Teleport
		TextBox.Text = friend_name
		
		task.wait(0.25)
		click_this_gui(TeleportButton)
		
		---
	end


end

local function followPath(destination: Vector3, action)
	local TravelTime = 3

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
			OnReachedDestination(action)
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
_G.Teleport = Teleport
getgenv().secret_auto_trader = { 
	webhook_url = `https://discord.com/api/webhooks/1276124582910365769/T7VSeP_ySIr73EP_GDYIqIoCvvi7j_7sqng7W4xRu0V24TCjcnF1Imx_jGTg0_BrHCmy` :: string;
	application_id = '1273970162126819359' :: string;
	channel_id = '1276124504044867584';
	server_id = '1273513305608159284';
	
	main_server = 'http://26.182.87.53';
	main_port = 8000
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

	["Farm Tower Of Eternity Mode"] = false; --ฟาร์มหอคอย true คือใช่ false คือไม่ (BROKEN!)
	
	['Status_Check_Interval'] = 2;
	
	['Enable Network Call'] = false --Auto merge and other cross-device feature (false if server down or closed)
	
};

getgenv().Merge_States = {
	['Enabled'] = false;
	
	['Pair_With'] = '';
	
	['Wait_Until_Pair_User_In_Trade_Hub'] = false;
	
	['Data'] = {};
	
	['Queue'] = -1
}

getgenv().Local_Merge_States = {}

local secret = getgenv().secret_auto_trader


local HS = game:GetService("HttpService")

local function UpdateMergeStatus()
	
	if not getgenv().Configuration['Enable Network Call'] then
		return
	end
	
	--Getting trade info
	
	local response, err = request({
		Url = `{secret.main_server}:{secret.main_port}/fetch-merge-queues`;
		Method = 'GET'
	})
	

	local response_2, err_2 = request({
		Url = `{secret.main_server}:{secret.main_port}/fetch-current-queue`;
		Method = 'GET'
	})

	

	if err then
		StarterGui:SetCore('SendNotification', {
			Title = 'Error';
			Text = err
		})

		warn(err)
		
		return
	end
	
	if err_2 then
		StarterGui:SetCore('SendNotification', {
			Title = 'Error';
			Text = err_2
		})

		warn(err_2)

		return
	end
	
	local Current_Queue = tonumber(HS:JSONDecode(response_2.Body))
	local Body = HS:JSONDecode(response.Body)
	
	local TabLevel = 0
	local plr = game:GetService("Players").LocalPlayer
	for i,v in Body do

		for index, value in v do
		
			if value == plr.Name then
				
				
				if not getgenv().Merge_States.Enabled then
					getgenv().Merge_States.Enabled = true
					getgenv().Merge_States.Pair_With = (index == 'user_1' and v.user_2) or v.user_1
					getgenv().Merge_States.Wait_Until_Pair_User_In_Trade_Hub = index ~= 'user_1'
					getgenv().Merge_States.Queue = v.queue
					getgenv().Merge_States.Data = v
					
				else
					if Current_Queue == v.queue then
						getgenv().Merge_States.Enabled = true
						getgenv().Merge_States.Pair_With = (index == 'user_1' and v.user_2) or v.user_1
						getgenv().Merge_States.Wait_Until_Pair_User_In_Trade_Hub = index ~= 'user_1'
						getgenv().Merge_States.Queue = v.queue
						getgenv().Merge_States.Data = v
						
						return
					end
					
					
				end
				
			end
		end

		
	end

end


local function PostToHTTPS(Input)
	
	if not getgenv().Configuration['Enable Network Call'] then
		return
	end
	
	Input = HS:JSONEncode(Input)

	local response, err = request({
		Url = secret.webhook_url;
		Method = "POST";
		Body = Input;
		Headers = {
			['Content-Type'] = 'application/json'
		}
	})

end


local function PostStringMessage(Message: string)
	task.spawn(function()
		PostToHTTPS({
			content = Message .. ` ({plr.Name}) [ID: {plr.UserId}]`;
			username = `Gems Trader`;

		})
	end)

end

local function IsInLobbyGame()
	return game.PlaceId == Lobby_Id
end

function IsInTradeHub()
	return game.PlaceId == 17490500437
end

local function WaitUntilPairInTradeHub()
	while task.wait(getgenv().Configuration.Status_Check_Interval) do
		UpdateMergeStatus()
		
		
		
		if getgenv().Merge_States.Data.user_1_data.location == 'trade_hub' then
			break
		end
	end
end


if IsInTradeHub() then --Captcha bypass
	

	local Captcha = game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("PAGES").CaptchaPage :: Frame
	
	local SentWarning = false

	local function refresh()

		StarterGui:SetCore('SendNotification', {
			Title = 'กรุณารอสักครู่';
			Text = 'บายพาสแคปชา'
		})

		task.wait(0.25)


		local Logged_Id = ''

		local EnterCodeBox = game:GetService("Players").LocalPlayer.PlayerGui.PAGES.CaptchaPage.Frame.Main.Options.EnterCodeBox.EnterCode :: TextBox
		local CaptchaImage = game:GetService("Players").LocalPlayer.PlayerGui.PAGES.CaptchaPage.Frame.Main.InfoDisplay.ImageLabel :: ImageLabel

		local Loggers = {}
		local Repeated_count = {}
		local Survey_Count = 0
		local MaxSurvey = 50 --Higher number mean more high accuracy but take longer to bypass but (30-50) is more than enough


		CaptchaImage:GetPropertyChangedSignal("Image"):Connect(function()

			if Survey_Count >= MaxSurvey then
				return
			end

			if not table.find(Loggers,CaptchaImage.Image) then
				table.insert(Loggers,CaptchaImage.Image)

			else
				if not Repeated_count[CaptchaImage.Image] then
					Repeated_count[CaptchaImage.Image] = 0
				end

				Repeated_count[CaptchaImage.Image] += 1


			end

			Survey_Count += 1

			if Survey_Count >= MaxSurvey then

				local Highscore = 0
				local Loading_Id = ''

				for i,v in Repeated_count do

					if v > Highscore then
						Highscore = v
						Loading_Id = i
					end

				end


				Logged_Id = Loading_Id

			end
		end)

		local Submit = game:GetService("Players").LocalPlayer.PlayerGui.PAGES.CaptchaPage.Frame.Main.Options.BlankFrame.SubmitButton :: TextButton

		local info

		while not CaptchaImage.IsLoaded or Logged_Id == '' do

			task.wait(0.25)
		end

		while not info do

			local id = string.gsub(Logged_Id,'rbxassetid://','')
			info = game:GetService("MarketplaceService"):GetProductInfo(tonumber(id),Enum.InfoType.Asset)

			if not info then
				task.wait(1)
			end

		end

		EnterCodeBox.Text = info.Name

		task.wait(1)
		
		
		task.delay(10, function()
			if SentWarning then
				return
			end
			
			SentWarning = true
			
			if Captcha.Visible then
				PostStringMessage(`บายพาสแคปชา [{info.Name}] ไม่สำเร็จกำลังรีจอยเอาแคปชาใหม่`)
				Teleport() --Rejoin if failed to bypass (Captcha possibly got filtered)
			end
		end)
		
		while task.wait(0.1) do
			click_this_gui(Submit)
			
			if not Captcha.Visible then
				break
			end
		end
	end

	if Captcha.Visible then
		refresh()
	end

	Captcha:GetPropertyChangedSignal("Visible"):Connect(function()
		if not Captcha.Visible then
			return
		end

		refresh()
	end)

end

UpdateMergeStatus()



--Disable Cryptic UI

local Inset = GuiService:GetGuiInset()

local x,y = workspace.CurrentCamera.ViewportSize.X/2 ,Inset.Y/2

VirtualInputManager:SendMouseButtonEvent(x+Inset.X,y,0,true,game,0)
VirtualInputManager:SendMouseButtonEvent(x+Inset.X,y,0,false,game,0)

if getgenv().Merge_States.Enabled then
	

	local UpdateUI = game:GetService("Players").LocalPlayer.PlayerGui.PAGES:WaitForChild("UpdatesUI",5) :: Frame

	if UpdateUI then
		if UpdateUI.Visible then
			UpdateUI:GetPropertyChangedSignal("Visible"):Connect(function()
				task.wait()

				if UpdateUI.Visible then
					UpdateUI.Visible = false
				end
			end)
		end
	end

	
	if IsInTradeHub() then
		--local Gems_Value = game:GetService("Players").LocalPlayer.leaderstats["💎 Gems"]
		task.spawn(function() --Only when in trade hub
			local StarterGui = game:GetService("StarterGui")

			local secret = getgenv().secret_auto_trader
			local HS = game:GetService('HttpService')

			while task.wait(4) do
				local response, err = request({
					Url = `{secret.main_server}:{secret.main_port}/fetch-current-queue`;
					Method = 'GET'
				})



				if err then
					StarterGui:SetCore('SendNotification', {
						Title = 'Error';
						Text = err
					})

					warn(err)

					return
				end

				local Body = HS:JSONDecode(response.Body)

				if tonumber(Body) ~= getgenv().Merge_States.Queue then --Rejoin if not in same queue
					_G.Teleport()
				end
			end


		end)
		
		if getgenv().Merge_States.Wait_Until_Pair_User_In_Trade_Hub then
			PostStringMessage(`จอยเซิฟเวอร์เทรดกับ {getgenv().Merge_States.Pair_With}`)
		else
			PostStringMessage(`เข้าเซิฟเทรดสำเร็จ`)
		end
		
		task.spawn(function()
			request({
				Url = `{secret.main_server}:{secret.main_port}/change-location`,
				Method = 'POST',
				Body = HS:JSONEncode({user=plr.Name,location='trade_hub'}),
				Headers = {['Content-Type'] = 'application/json'}})
		end)
		
		
		
		--Wait for pair to join
		repeat task.wait(0.5) until game:GetService("Players"):FindFirstChild(getgenv().Merge_States.Pair_With)
		
		
		local Gems_Value = game:GetService("Players")[`{getgenv().Merge_States.Pair_With}`]:WaitForChild('leaderstats')["💎 Gems"] :: NumberValue
		getgenv().Local_Merge_States = {
			Pairer_Budget = Gems_Value.Value
		}
		
		if getgenv().Merge_States.Data.user_1 == plr.Name then
			--User 1 will be buyer
			loadstring(game:HttpGet('https://raw.githubusercontent.com/RamasaSakura/Anime_Defender_Helper/main/Helpers/Anime_Defender/Gems_Buyer.lua'))()
		else
			--User 2 will be seller
			loadstring(game:HttpGet('https://raw.githubusercontent.com/RamasaSakura/Anime_Defender_Helper/main/Helpers/Anime_Defender/Gems_Seller.lua'))()
		end		
	else
		--Wait until own queue
		local Count = 0
		
		while task.wait(4) do
			--Anti Afk kick
			VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0)
			VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0)
			local response, err = request({
				Url = `{secret.main_server}:{secret.main_port}/fetch-current-queue`;
				Method = 'GET'
			})



			if err then
				StarterGui:SetCore('SendNotification', {
					Title = 'Error';
					Text = err
				})

				warn(err)

				return
			end

			local Body = HS:JSONDecode(response.Body)

			if tonumber(Body) == getgenv().Merge_States.Queue then --Finally queue?
				break
			end
			
			Count += 1
			
			if Count >= 5 then
				UpdateMergeStatus()
				Count = 0
			end

		end

		
		if getgenv().Merge_States.Wait_Until_Pair_User_In_Trade_Hub then
			WaitUntilPairInTradeHub()
			followPath(Locations.Trade_Portal.Position,'trade_follow')
			return
		end

		followPath(Locations.Trade_Portal.Position,'trade')
	end
	
	return
end

if IsInLobbyGame() and not IsInTradeHub() then
	
	if getgenv().Configuration['Enable Network Call'] then
		request({
			Url = `{secret.main_server}:{secret.main_port}/change-location`,
			Method = 'POST',
			Body = HS:JSONEncode({user=plr.Name,location='lobby'}),
			Headers = {['Content-Type'] = 'application/json'}})
	end
	
	
else
	local PAGES = game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("PAGES") :: ScreenGui
	PAGES.Enabled = false

	PAGES:GetPropertyChangedSignal("Enabled"):Connect(function()
		PAGES.Enabled = true
	end)
	
	
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

