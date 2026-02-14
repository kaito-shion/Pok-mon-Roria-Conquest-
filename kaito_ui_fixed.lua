--================================
-- LOAD RAYFIELD
--================================
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

--================================
-- SERVICES
--================================
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

--================================
-- STATE
--================================
local removedGrass = {}
local grassRemoved = false

local removedSand = {}
local sandRemoved = false

local wsValue = 16
local jpValue = 50
local exposureValue = 0

local timerEnabled = true
local timerConnection = nil

--================================
-- HELPERS
--================================
local function getHumanoid()
	local char = player.Character or player.CharacterAdded:Wait()
	return char:FindFirstChildOfClass("Humanoid")
end

local function getTimePeriod(clock)
	if clock >= 5 and clock < 11 then
		return "Morning"
	elseif clock >= 11 and clock < 17 then
		return "Afternoon"
	elseif clock >= 17 and clock < 19 then
		return "Evening"
	else
		return "Night"
	end
end

--================================
-- WINDOW
--================================
local Window = Rayfield:CreateWindow({
	Name = "Kaito UI ⚡",
	LoadingTitle = "Kaito UI",
	LoadingSubtitle = "Rayfield Edition",
	KeySystem = false
})

local InfoTab     = Window:CreateTab("ℹ️ Info")
local MainTab     = Window:CreateTab("🏠 Main")
local MiscTab     = Window:CreateTab("🧩 Misc")
local PlayerTab   = Window:CreateTab("👤 Player")
local SettingsTab = Window:CreateTab("⚙️ Settings")

--================================
-- INFO TAB
--================================
InfoTab:CreateLabel("Kaito UI - Rayfield")
InfoTab:CreateLabel("Timer + Type Chart + Tools")

--================================
-- MAIN TAB
--================================
MainTab:CreateLabel("HUD & Tools")

--================================
-- TIMER HUD
--================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KaitoTimerHUD"
screenGui.Parent = player:WaitForChild("PlayerGui")

local timeLabel = Instance.new("TextLabel")
timeLabel.Size = UDim2.new(0, 240, 0, 40)
timeLabel.Position = UDim2.new(0.5, -120, 0, 10)
timeLabel.BackgroundColor3 = Color3.fromRGB(30,30,30)
timeLabel.TextColor3 = Color3.fromRGB(255,255,255)
timeLabel.Font = Enum.Font.GothamBold
timeLabel.TextSize = 18
timeLabel.Parent = screenGui

local function startTimer()
	if timerConnection then return end
	timerConnection = RunService.RenderStepped:Connect(function()
		local clock = Lighting.ClockTime
		local h = math.floor(clock)
		local m = math.floor((clock - h)*60)
		timeLabel.Text = string.format("🕒 %02d:%02d - %s", h, m, getTimePeriod(clock))
	end)
end

local function stopTimer()
	if timerConnection then
		timerConnection:Disconnect()
		timerConnection = nil
	end
end

startTimer()

MainTab:CreateButton({
	Name = "Toggle Timer HUD",
	Callback = function()
		timerEnabled = not timerEnabled
		timeLabel.Visible = timerEnabled
		if timerEnabled then startTimer() else stopTimer() end
	end
})

--================================
-- TYPE CHART WINDOW
--================================
local typeGui = Instance.new("ScreenGui", player.PlayerGui)
typeGui.Name = "TypeChartGui"
typeGui.Enabled = false

local chartWidth, chartHeight = 200, 300
local frame, chartImg
local minimized = false

local function createTypeChart()
	typeGui:ClearAllChildren()

	frame = Instance.new("Frame")      
	frame.Size = UDim2.new(0, chartWidth, 0, chartHeight)      
	frame.Position = UDim2.new(0.5, -chartWidth/2, 0.5, -chartHeight/2)      
	frame.BackgroundColor3 = Color3.fromRGB(20,20,20)      
	frame.BorderSizePixel = 0      
	frame.Active = true      
	frame.Draggable = true      
	frame.Parent = typeGui      

	local title = Instance.new("TextLabel", frame)      
	title.Size = UDim2.new(1, -60, 0, 25)      
	title.Text = "Pokémon Type Chart"      
	title.Font = Enum.Font.GothamBold      
	title.TextSize = 14      
	title.TextColor3 = Color3.new(1,1,1)      
	title.BackgroundColor3 = Color3.fromRGB(40,40,40)      

	local closeBtn = Instance.new("TextButton", frame)      
	closeBtn.Size = UDim2.new(0,30,0,25)      
	closeBtn.Position = UDim2.new(1,-30,0,0)      
	closeBtn.Text = "X"      
	closeBtn.TextColor3 = Color3.fromRGB(255,100,100)      
	closeBtn.BackgroundTransparency = 1      
	closeBtn.MouseButton1Click:Connect(function()      
		typeGui.Enabled = false      
	end)      

	local minBtn = Instance.new("TextButton", frame)      
	minBtn.Size = UDim2.new(0,30,0,25)      
	minBtn.Position = UDim2.new(1,-60,0,0)      
	minBtn.Text = "-"      
	minBtn.TextColor3 = Color3.fromRGB(200,200,200)      
	minBtn.BackgroundTransparency = 1      

	chartImg = Instance.new("ImageLabel", frame)      
	chartImg.Size = UDim2.new(1, -10, 1, -80)      
	chartImg.Position = UDim2.new(0,5,0,25)      
	chartImg.BackgroundTransparency = 1      
	chartImg.ScaleType = Enum.ScaleType.Fit      
	chartImg.Image = "rbxassetid://126725715476982"      

	local widthBox = Instance.new("TextBox", frame)      
	widthBox.Size = UDim2.new(0.45,0,0,25)      
	widthBox.Position = UDim2.new(0.05,0,1,-30)      
	widthBox.Text = tostring(chartWidth)      
	widthBox.PlaceholderText = "Width"      
	widthBox.BackgroundColor3 = Color3.fromRGB(35,35,35)      
	widthBox.TextColor3 = Color3.new(1,1,1)      
	widthBox.ClearTextOnFocus = false      

	local heightBox = Instance.new("TextBox", frame)      
	heightBox.Size = UDim2.new(0.45,0,0,25)      
	heightBox.Position = UDim2.new(0.5,0,1,-30)      
	heightBox.Text = tostring(chartHeight)      
	heightBox.PlaceholderText = "Height"      
	heightBox.BackgroundColor3 = Color3.fromRGB(35,35,35)      
	heightBox.TextColor3 = Color3.new(1,1,1)      
	heightBox.ClearTextOnFocus = false      

	widthBox.FocusLost:Connect(function()      
		chartWidth = tonumber(widthBox.Text) or chartWidth      
		if not minimized then      
			frame.Size = UDim2.new(0, chartWidth, 0, chartHeight)      
		end      
	end)      

	heightBox.FocusLost:Connect(function()      
		chartHeight = tonumber(heightBox.Text) or chartHeight      
		if not minimized then      
			frame.Size = UDim2.new(0, chartWidth, 0, chartHeight)      
		end      
	end)      

	minBtn.MouseButton1Click:Connect(function()      
		minimized = not minimized      
		if minimized then      
			chartImg.Visible = false      
			widthBox.Visible = false      
			heightBox.Visible = false      
			frame.Size = UDim2.new(0, chartWidth, 0, 25)      
		else      
			chartImg.Visible = true      
			widthBox.Visible = true      
			heightBox.Visible = true      
			frame.Size = UDim2.new(0, chartWidth, 0, chartHeight)      
		end      
	end)
end

MainTab:CreateButton({
	Name = "Show Pokémon Type Chart",
	Callback = function()
		typeGui.Enabled = not typeGui.Enabled
		if typeGui.Enabled then
			createTypeChart()
		end
	end
})

--================================
-- PLAYER TAB
--================================
PlayerTab:CreateLabel("Player Stats")

PlayerTab:CreateInput({
	Name = "WalkSpeed",
	PlaceholderText = "16",
	Callback = function(text)
		wsValue = tonumber(text) or 16
	end
})

PlayerTab:CreateButton({
	Name = "Apply WalkSpeed",
	Callback = function()
		local hum = getHumanoid()
		if hum then hum.WalkSpeed = wsValue end
	end
})

PlayerTab:CreateInput({
	Name = "JumpPower",
	PlaceholderText = "50",
	Callback = function(text)
		jpValue = tonumber(text) or 50
	end
})

PlayerTab:CreateButton({
	Name = "Apply JumpPower",
	Callback = function()
		local hum = getHumanoid()
		if hum then hum.JumpPower = jpValue end
	end
})

--================================
-- MISC TAB
--================================
MiscTab:CreateLabel("World Tools")

-- Remove / Restore Grass
MiscTab:CreateButton({
	Name = "Remove / Restore Grass",
	Callback = function()
		if not grassRemoved then
			for _,v in pairs(workspace:GetChildren()) do
				if string.match(v.Name, "^chunk%d+$") then
					local grass = v:FindFirstChild("MGrass")
					if grass then
						removedGrass[v] = grass:Clone()
						grass:Destroy()
					end
				end
			end
			grassRemoved = true
		else
			for chunk,clone in pairs(removedGrass) do
				if chunk and clone then clone.Parent = chunk end
			end
			removedGrass = {}
			grassRemoved = false
		end
	end
})

-- Remove / Restore Sand
MiscTab:CreateButton({
	Name = "Remove / Restore Sand",
	Callback = function()
		if not sandRemoved then
			for _,v in pairs(workspace:GetChildren()) do
				if string.match(v.Name, "^chunk%d+$") then
					local sand = v:FindFirstChild("Sand") or v:FindFirstChild("MSand")
					if sand then
						removedSand[v] = sand:Clone()
						sand:Destroy()
					end
				end
			end
			sandRemoved = true
		else
			for chunk,clone in pairs(removedSand) do
				if chunk and clone then
					clone.Parent = chunk
				end
			end
			removedSand = {}
			sandRemoved = false
		end
	end
})

-- ================================
-- GYM 5 SECTION
-- ================================
MiscTab:CreateLabel("GYM 5")

-- Delete AllStone (inside gym5)
MiscTab:CreateButton({
	Name = "Delete AllStone",
	Callback = function()
		local gym5 = workspace:FindFirstChild("gym5")
		if gym5 then
			for _,v in pairs(gym5:GetChildren()) do
				if v.Name == "AllStone" then
					v:Destroy()
				end
			end
		end
	end
})

-- Delete AllDirt (inside gym5)
MiscTab:CreateButton({
	Name = "Delete AllDirt",
	Callback = function()
		local gym5 = workspace:FindFirstChild("gym5")
		if gym5 then
			for _,v in pairs(gym5:GetChildren()) do
				if v.Name == "AllDirt" then
					v:Destroy()
				end
			end
		end
	end
})

-- Lighting
MiscTab:CreateLabel("Lighting")

MiscTab:CreateInput({
	Name = "Exposure Value",
	PlaceholderText = "0, 1, -2",
	Callback = function(text)
		exposureValue = tonumber(text) or 0
	end
})

MiscTab:CreateButton({
	Name = "Apply Exposure",
	Callback = function()
		Lighting.ExposureCompensation = exposureValue
	end
})

-- ================================
-- GYM 6 SECTION (FILTERED NPCs)
-- ================================
MiscTab:CreateLabel("GYM 6")

local selectedGym6NPC = nil
local gym6Options = {}

-- Whitelist of NPCs to show
local allowedNPCs = {
	["Camper Davis"] = true,
	["Camper Samuel"] = true,
	["Picnicker Beth"] = true,
	["Picnicker Gale"] = true,
	["Leader"] = true
}

local function normalizeOption(opt)
	if typeof(opt) == "table" then
		return opt[1]
	end
	return opt
end

local function getGym6NPCs()
	gym6Options = {}

	local gym6 = workspace:FindFirstChild("gym6")  
	if not gym6 then  
		table.insert(gym6Options, "NOT IN GYM 6")  
		print("[GYM6] gym6 model not found")  
		return  
	end  

	for _,v in pairs(gym6:GetChildren()) do  
		if v:IsA("Model") and allowedNPCs[v.Name] then  
			table.insert(gym6Options, v.Name)  
			print('[GYM6] Model Found : "'..v.Name..'"')  
		end  
	end  

	if #gym6Options == 0 then  
		table.insert(gym6Options, "NO NPC FOUND")  
	end
end

getGym6NPCs()

local Gym6Dropdown = MiscTab:CreateDropdown({
	Name = "Select NPC",
	Options = gym6Options,
	CurrentOption = nil,
	Callback = function(option)
		option = normalizeOption(option)
		selectedGym6NPC = option
		print('[GYM6] Selected : "'..tostring(option)..'"')
	end
})

MiscTab:CreateButton({
	Name = "Refresh NPC List",
	Callback = function()
		getGym6NPCs()
		Gym6Dropdown:Refresh(gym6Options, true)
		print("[GYM6] NPC list refreshed")
	end
})

local function teleportToModel(model)
	local char = player.Character or player.CharacterAdded:Wait()
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then
		print("[GYM6] No HumanoidRootPart")
		return
	end

	if model:IsA("Model") then  
		if model.PrimaryPart then  
			root.CFrame = model.PrimaryPart.CFrame * CFrame.new(0,0,-4)  
		else  
			local part = model:FindFirstChildWhichIsA("BasePart", true)  
			if part then  
				root.CFrame = part.CFrame * CFrame.new(0,0,-4)  
			end  
		end  
	end
end

MiscTab:CreateButton({
	Name = "Teleport to Selected NPC",
	Callback = function()
		if not selectedGym6NPC or selectedGym6NPC == "NOT IN GYM 6" then
			print("[GYM6] Invalid selection")
			return
		end

		local gym6 = workspace:FindFirstChild("gym6")  
		if not gym6 then  
			print("[GYM6] gym6 not found")  
			return  
		end  

		local npc = gym6:FindFirstChild(selectedGym6NPC)  
		if not npc then  
			print('[GYM6] NPC "'..selectedGym6NPC..'" not found')  
			return  
		end  

		print('[GYM6] Teleporting to "'..selectedGym6NPC..'"')  
		teleportToModel(npc)  
	end
})

--================================
-- SETTINGS
--================================
SettingsTab:CreateButton({
	Name = "Unload UI",
	Callback = function()
		stopTimer()
		if screenGui then screenGui:Destroy() end
		if typeGui then typeGui:Destroy() end
		Rayfield:Destroy()
	end
})
