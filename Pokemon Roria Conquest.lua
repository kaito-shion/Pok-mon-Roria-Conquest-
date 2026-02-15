-- ================================================
-- KAITO UI - RAYFIELD EDITION
-- ================================================

-- ================================================
-- LOAD RAYFIELD LIBRARY
-- ================================================
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- ================================================
-- SERVICES
-- ================================================
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- ================================================
-- VARIABLES
-- ================================================
-- Grass removal
local removedGrass = {}
local grassRemoved = false

-- Sand removal
local removedSand = {}
local sandRemoved = false

-- Snow removal
local removedSnow = {}
local snowRemoved = false

-- Player stats
local wsValue = 16
local jpValue = 50

-- Lighting
local exposureValue = 0

-- Timer
local timerEnabled = true
local timerConnection = nil

-- Type chart
local chartWidth = 350
local chartHeight = 350
local frame = nil
local chartImg = nil
local minimized = false

-- Gym detection
local selectedGymNPC = nil
local gymOptions = {}
local currentGym = nil
local currentGymHighlight = nil

-- Chunk detection
local selectedChunkNPC = nil
local chunkOptions = {}
local currentChunk = nil
local currentChunkHighlight = nil

-- Item detection
local selectedItem = nil
local itemOptions = {}
local currentItemHighlight = nil

-- ================================================
-- HELPER FUNCTIONS
-- ================================================

-- Get player humanoid
local function getHumanoid()
	local char = player.Character or player.CharacterAdded:Wait()
	return char:FindFirstChildOfClass("Humanoid")
end

-- Get time period from clock time
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

-- Normalize dropdown option
local function normalizeOption(opt)
	if typeof(opt) == "table" then
		return opt[1]
	end
	return opt
end

-- Remove highlight function
local function removeHighlight(highlight)
	if highlight and highlight.Parent then
		highlight:Destroy()
	end
end

-- Add highlight to model
local function addHighlight(model, color)
	local highlight = Instance.new("Highlight")
	highlight.FillColor = color
	highlight.FillTransparency = 0.5
	highlight.OutlineColor = color
	highlight.OutlineTransparency = 0
	highlight.Parent = model
	return highlight
end

-- ================================================
-- CREATE WINDOW AND TABS
-- ================================================
local Window = Rayfield:CreateWindow({
	Name = "Kaito UI ⚡",
	LoadingTitle = "Kaito UI",
	LoadingSubtitle = "Rayfield Edition",
	KeySystem = false
})

local InfoTab = Window:CreateTab("ℹ️ Info")
local MainTab = Window:CreateTab("🏠 Main")
local MiscTab = Window:CreateTab("🧩 Misc")
local PlayerTab = Window:CreateTab("👤 Player")
local SettingsTab = Window:CreateTab("⚙️ Settings")

-- ================================================
-- INFO TAB
-- ================================================
InfoTab:CreateLabel("⚡ Kaito UI - Rayfield")
InfoTab:CreateLabel("⏰ Timer + 📊 Type Chart + 🛠️ Tools")

-- ================================================
-- MAIN TAB - TIMER HUD
-- ================================================
MainTab:CreateLabel("🖥️ HUD & Tools")

-- Create timer GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KaitoTimerHUD"
screenGui.Parent = player:WaitForChild("PlayerGui")

local timeFrame = Instance.new("Frame")
timeFrame.Size = UDim2.new(0, 260, 0, 50)
timeFrame.Position = UDim2.new(0.5, -130, 0, 10)
timeFrame.BackgroundTransparency = 1
timeFrame.BorderSizePixel = 0
timeFrame.Parent = screenGui

local timeFrameCorner = Instance.new("UICorner")
timeFrameCorner.CornerRadius = UDim.new(0, 10)
timeFrameCorner.Parent = timeFrame

local timeLabel = Instance.new("TextLabel")
timeLabel.Size = UDim2.new(1, 0, 1, 0)
timeLabel.Position = UDim2.new(0, 0, 0, 0)
timeLabel.BackgroundTransparency = 1
timeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
timeLabel.Font = Enum.Font.GothamBold
timeLabel.TextSize = 20
timeLabel.Parent = timeFrame

-- Add text stroke/outline
local timeLabelStroke = Instance.new("UIStroke")
timeLabelStroke.Color = Color3.fromRGB(0, 0, 0)
timeLabelStroke.Thickness = 2
timeLabelStroke.Parent = timeLabel

-- Start timer function
local function startTimer()
	if timerConnection then return end
	timerConnection = RunService.RenderStepped:Connect(function()
		local clock = Lighting.ClockTime
		local h = math.floor(clock)
		local m = math.floor((clock - h) * 60)
		local period = getTimePeriod(clock)
		timeLabel.Text = string.format("🕒 %02d:%02d - %s", h, m, period)
	end)
end

-- Stop timer function
local function stopTimer()
	if timerConnection then
		timerConnection:Disconnect()
		timerConnection = nil
	end
end

-- Start timer automatically
startTimer()

-- Toggle timer button
MainTab:CreateButton({
	Name = "⏰ Toggle Timer HUD",
	Callback = function()
		timerEnabled = not timerEnabled
		timeFrame.Visible = timerEnabled
		if timerEnabled then
			startTimer()
		else
			stopTimer()
		end
	end
})

-- ================================================
-- MAIN TAB - TYPE CHART
-- ================================================

-- Create type chart GUI
local typeGui = Instance.new("ScreenGui")
typeGui.Name = "TypeChartGui"
typeGui.Parent = player.PlayerGui
typeGui.Enabled = false

-- Create type chart function
local function createTypeChart()
	typeGui:ClearAllChildren()
	
	-- Main frame
	frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, chartWidth, 0, chartHeight)
	frame.Position = UDim2.new(0.5, -chartWidth / 2, 0.5, -chartHeight / 2)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.BorderSizePixel = 0
	frame.Active = true
	frame.Draggable = true
	frame.Parent = typeGui
	
	local frameCorner = Instance.new("UICorner")
	frameCorner.CornerRadius = UDim.new(0, 12)
	frameCorner.Parent = frame
	
	local frameStroke = Instance.new("UIStroke")
	frameStroke.Color = Color3.fromRGB(70, 70, 70)
	frameStroke.Thickness = 2
	frameStroke.Parent = frame
	
	-- Title bar
	local titleBar = Instance.new("Frame")
	titleBar.Size = UDim2.new(1, 0, 0, 40)
	titleBar.Position = UDim2.new(0, 0, 0, 0)
	titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	titleBar.BorderSizePixel = 0
	titleBar.Parent = frame
	
	local titleBarCorner = Instance.new("UICorner")
	titleBarCorner.CornerRadius = UDim.new(0, 12)
	titleBarCorner.Parent = titleBar
	
	-- Title
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -80, 1, 0)
	title.Position = UDim2.new(0, 10, 0, 0)
	title.Text = "⚡ Pokemon Type Chart"
	title.Font = Enum.Font.GothamBold
	title.TextSize = 16
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.BackgroundTransparency = 1
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = titleBar
	
	-- Close button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 40, 0, 40)
	closeBtn.Position = UDim2.new(1, -40, 0, 0)
	closeBtn.Text = "❌"
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 16
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	closeBtn.BorderSizePixel = 0
	closeBtn.Parent = titleBar
	
	local closeBtnCorner = Instance.new("UICorner")
	closeBtnCorner.CornerRadius = UDim.new(0, 8)
	closeBtnCorner.Parent = closeBtn
	
	closeBtn.MouseButton1Click:Connect(function()
		typeGui.Enabled = false
	end)
	
	-- Minimize button
	local minBtn = Instance.new("TextButton")
	minBtn.Size = UDim2.new(0, 40, 0, 40)
	minBtn.Position = UDim2.new(1, -85, 0, 0)
	minBtn.Text = "➖"
	minBtn.Font = Enum.Font.GothamBold
	minBtn.TextSize = 16
	minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	minBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	minBtn.BorderSizePixel = 0
	minBtn.Parent = titleBar
	
	local minBtnCorner = Instance.new("UICorner")
	minBtnCorner.CornerRadius = UDim.new(0, 8)
	minBtnCorner.Parent = minBtn
	
	-- Chart container
	local chartContainer = Instance.new("Frame")
	chartContainer.Size = UDim2.new(1, -20, 1, -60)
	chartContainer.Position = UDim2.new(0, 10, 0, 45)
	chartContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	chartContainer.BorderSizePixel = 0
	chartContainer.Parent = frame
	
	local containerCorner = Instance.new("UICorner")
	containerCorner.CornerRadius = UDim.new(0, 8)
	containerCorner.Parent = chartContainer
	
	-- Chart image
	chartImg = Instance.new("ImageLabel")
	chartImg.Size = UDim2.new(1, -10, 1, -10)
	chartImg.Position = UDim2.new(0, 5, 0, 5)
	chartImg.BackgroundTransparency = 1
	chartImg.ScaleType = Enum.ScaleType.Fit
	chartImg.Image = "rbxassetid://126725715476982"
	chartImg.Parent = chartContainer
	
	-- Resize handle (bottom-right corner)
	local resizeHandle = Instance.new("Frame")
	resizeHandle.Size = UDim2.new(0, 25, 0, 25)
	resizeHandle.Position = UDim2.new(1, -25, 1, -25)
	resizeHandle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	resizeHandle.BorderSizePixel = 0
	resizeHandle.Parent = frame
	
	local resizeCorner = Instance.new("UICorner")
	resizeCorner.CornerRadius = UDim.new(0, 6)
	resizeCorner.Parent = resizeHandle
	
	-- Resize indicator
	local resizeIcon = Instance.new("TextLabel")
	resizeIcon.Size = UDim2.new(1, 0, 1, 0)
	resizeIcon.Text = "↘️"
	resizeIcon.TextSize = 14
	resizeIcon.TextColor3 = Color3.fromRGB(200, 200, 200)
	resizeIcon.BackgroundTransparency = 1
	resizeIcon.Font = Enum.Font.GothamBold
	resizeIcon.Parent = resizeHandle
	
	-- Resize functionality
	local resizing = false
	local startSize = nil
	local startPos = nil
	
	resizeHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			resizing = true
			startSize = frame.Size
			startPos = input.Position
			frame.Draggable = false
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - startPos
			local newWidth = math.max(250, startSize.X.Offset + delta.X)
			local newHeight = math.max(200, startSize.Y.Offset + delta.Y)
			frame.Size = UDim2.new(0, newWidth, 0, newHeight)
			chartWidth = newWidth
			chartHeight = newHeight
		end
	end)
	
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if resizing then
				resizing = false
				frame.Draggable = true
			end
		end
	end)
	
	-- Minimize button event
	minBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		if minimized then
			chartContainer.Visible = false
			resizeHandle.Visible = false
			frame.Size = UDim2.new(0, chartWidth, 0, 40)
			minBtn.Text = "🔲"
			frame.Draggable = true
		else
			chartContainer.Visible = true
			resizeHandle.Visible = true
			frame.Size = UDim2.new(0, chartWidth, 0, chartHeight)
			minBtn.Text = "➖"
		end
	end)
end

-- Show type chart button
MainTab:CreateButton({
	Name = "📊 Show Pokemon Type Chart",
	Callback = function()
		typeGui.Enabled = not typeGui.Enabled
		if typeGui.Enabled then
			createTypeChart()
		end
	end
})

-- ================================================
-- MAIN TAB - GYM NPC TELEPORT
-- ================================================
MainTab:CreateLabel("🏟️ Gym NPCs")

-- Get gym NPCs function
local function getGymNPCs()
	gymOptions = {}
	currentGym = nil
	
	-- Search for any gym# or Gym# in workspace
	for _, v in pairs(workspace:GetChildren()) do
		local lowerName = string.lower(v.Name)
		if string.match(lowerName, "^gym%d+$") then
			currentGym = v
			print("[GYM] Found: " .. v.Name)
			break
		end
	end
	
	if not currentGym then
		table.insert(gymOptions, "NO GYM FOUND")
		print("[GYM] No gym detected in workspace")
		return
	end
	
	-- Find all models with HumanoidRootPart
	for _, model in pairs(currentGym:GetChildren()) do
		if model:IsA("Model") then
			local hasHRP = model:FindFirstChild("HumanoidRootPart")
			if hasHRP then
				table.insert(gymOptions, model.Name)
				print('[GYM] NPC Found: "' .. model.Name .. '"')
			end
		end
	end
	
	if #gymOptions == 0 then
		table.insert(gymOptions, "NO NPCs FOUND")
	end
end

-- Initialize gym NPCs
getGymNPCs()

-- Gym NPC dropdown
local GymDropdown = MainTab:CreateDropdown({
	Name = "👥 Select Gym NPC",
	Options = gymOptions,
	CurrentOption = nil,
	Callback = function(option)
		option = normalizeOption(option)
		selectedGymNPC = option
		print('[GYM] Selected: "' .. tostring(option) .. '"')
		
		-- Remove previous highlight
		removeHighlight(currentGymHighlight)
		currentGymHighlight = nil
		
		-- Add highlight to selected NPC
		if currentGym and option ~= "NO GYM FOUND" and option ~= "NO NPCs FOUND" then
			local npc = currentGym:FindFirstChild(option)
			if npc and npc:IsA("Model") then
				currentGymHighlight = addHighlight(npc, Color3.fromRGB(0, 255, 0))
				print('[GYM] Highlighted: "' .. option .. '"')
			end
		end
	end
})

-- Refresh gym NPC list button
MainTab:CreateButton({
	Name = "🔄 Refresh Gym NPC List",
	Callback = function()
		-- Remove highlight when refreshing
		removeHighlight(currentGymHighlight)
		currentGymHighlight = nil
		
		getGymNPCs()
		GymDropdown:Refresh(gymOptions, true)
		print("[GYM] NPC list refreshed")
	end
})

-- Teleport to gym NPC function
local function teleportToGymNPC(model)
	local char = player.Character or player.CharacterAdded:Wait()
	local root = char:FindFirstChild("HumanoidRootPart")
	
	if not root then
		print("[GYM] No HumanoidRootPart found on player")
		return
	end
	
	if model:IsA("Model") then
		local targetRoot = model:FindFirstChild("HumanoidRootPart")
		if targetRoot then
			root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, -4)
		elseif model.PrimaryPart then
			root.CFrame = model.PrimaryPart.CFrame * CFrame.new(0, 0, -4)
		else
			local part = model:FindFirstChildWhichIsA("BasePart", true)
			if part then
				root.CFrame = part.CFrame * CFrame.new(0, 0, -4)
			end
		end
	end
end

-- Teleport to gym NPC button
MainTab:CreateButton({
	Name = "🚀 Teleport to Gym NPC",
	Callback = function()
		if not selectedGymNPC or selectedGymNPC == "NO GYM FOUND" or selectedGymNPC == "NO NPCs FOUND" then
			print("[GYM] Invalid selection")
			return
		end
		
		if not currentGym then
			print("[GYM] No gym detected")
			return
		end
		
		local npc = currentGym:FindFirstChild(selectedGymNPC)
		if not npc then
			print('[GYM] NPC "' .. selectedGymNPC .. '" not found')
			return
		end
		
		print('[GYM] Teleporting to "' .. selectedGymNPC .. '"')
		teleportToGymNPC(npc)
	end
})

-- ================================================
-- MAIN TAB - CHUNK NPC TELEPORT
-- ================================================
MainTab:CreateLabel("🗺️ Chunk NPCs")

-- Get chunk NPCs function
local function getChunkNPCs()
	chunkOptions = {}
	currentChunk = nil
	
	-- Search for any chunk# or Chunk# in workspace
	for _, v in pairs(workspace:GetChildren()) do
		local lowerName = string.lower(v.Name)
		if string.match(lowerName, "^chunk%d+$") then
			currentChunk = v
			print("[CHUNK] Found: " .. v.Name)
			break
		end
	end
	
	if not currentChunk then
		table.insert(chunkOptions, "NO CHUNK FOUND")
		print("[CHUNK] No chunk detected in workspace")
		return
	end
	
	-- Find all models with HumanoidRootPart
	for _, model in pairs(currentChunk:GetChildren()) do
		if model:IsA("Model") then
			local hasHRP = model:FindFirstChild("HumanoidRootPart")
			if hasHRP then
				table.insert(chunkOptions, model.Name)
				print('[CHUNK] NPC Found: "' .. model.Name .. '"')
			end
		end
	end
	
	if #chunkOptions == 0 then
		table.insert(chunkOptions, "NO NPCs FOUND")
	end
end

-- Initialize chunk NPCs
getChunkNPCs()

-- Chunk NPC dropdown
local ChunkDropdown = MainTab:CreateDropdown({
	Name = "👥 Select Chunk NPC",
	Options = chunkOptions,
	CurrentOption = nil,
	Callback = function(option)
		option = normalizeOption(option)
		selectedChunkNPC = option
		print('[CHUNK] Selected: "' .. tostring(option) .. '"')
		
		-- Remove previous highlight
		removeHighlight(currentChunkHighlight)
		currentChunkHighlight = nil
		
		-- Add highlight to selected NPC
		if currentChunk and option ~= "NO CHUNK FOUND" and option ~= "NO NPCs FOUND" then
			local npc = currentChunk:FindFirstChild(option)
			if npc and npc:IsA("Model") then
				currentChunkHighlight = addHighlight(npc, Color3.fromRGB(255, 165, 0))
				print('[CHUNK] Highlighted: "' .. option .. '"')
			end
		end
	end
})

-- Refresh chunk NPC list button
MainTab:CreateButton({
	Name = "🔄 Refresh Chunk NPC List",
	Callback = function()
		-- Remove highlight when refreshing
		removeHighlight(currentChunkHighlight)
		currentChunkHighlight = nil
		
		getChunkNPCs()
		ChunkDropdown:Refresh(chunkOptions, true)
		print("[CHUNK] NPC list refreshed")
	end
})

-- Teleport to chunk NPC function
local function teleportToChunkNPC(model)
	local char = player.Character or player.CharacterAdded:Wait()
	local root = char:FindFirstChild("HumanoidRootPart")
	
	if not root then
		print("[CHUNK] No HumanoidRootPart found on player")
		return
	end
	
	if model:IsA("Model") then
		local targetRoot = model:FindFirstChild("HumanoidRootPart")
		if targetRoot then
			root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, -4)
		elseif model.PrimaryPart then
			root.CFrame = model.PrimaryPart.CFrame * CFrame.new(0, 0, -4)
		else
			local part = model:FindFirstChildWhichIsA("BasePart", true)
			if part then
				root.CFrame = part.CFrame * CFrame.new(0, 0, -4)
			end
		end
	end
end

-- Teleport to chunk NPC button
MainTab:CreateButton({
	Name = "🚀 Teleport to Chunk NPC",
	Callback = function()
		if not selectedChunkNPC or selectedChunkNPC == "NO CHUNK FOUND" or selectedChunkNPC == "NO NPCs FOUND" then
			print("[CHUNK] Invalid selection")
			return
		end
		
		if not currentChunk then
			print("[CHUNK] No chunk detected")
			return
		end
		
		local npc = currentChunk:FindFirstChild(selectedChunkNPC)
		if not npc then
			print('[CHUNK] NPC "' .. selectedChunkNPC .. '" not found')
			return
		end
		
		print('[CHUNK] Teleporting to "' .. selectedChunkNPC .. '"')
		teleportToChunkNPC(npc)
	end
})

-- ================================================
-- MAIN TAB - ITEM TELEPORT
-- ================================================
MainTab:CreateLabel("💎 Items")

-- Get items function
local function getItems()
	itemOptions = {}
	
	-- Search in all chunks
	for _, chunk in pairs(workspace:GetChildren()) do
		local lowerName = string.lower(chunk.Name)
		if string.match(lowerName, "^chunk%d+$") then
			for _, v in pairs(chunk:GetChildren()) do
				if v.Name == "#Item" and v:IsA("Model") then
					table.insert(itemOptions, v:GetFullName())
					print('[ITEM] Found: "' .. v:GetFullName() .. '"')
				end
			end
		end
	end
	
	if #itemOptions == 0 then
		table.insert(itemOptions, "NO ITEMS FOUND")
	end
end

-- Initialize items
getItems()

-- Item dropdown
local ItemDropdown = MainTab:CreateDropdown({
	Name = "💎 Select Item",
	Options = itemOptions,
	CurrentOption = nil,
	Callback = function(option)
		option = normalizeOption(option)
		selectedItem = option
		print('[ITEM] Selected: "' .. tostring(option) .. '"')
		
		-- Remove previous highlight
		removeHighlight(currentItemHighlight)
		currentItemHighlight = nil
		
		-- Add highlight to selected item
		if option ~= "NO ITEMS FOUND" then
			for _, chunk in pairs(workspace:GetChildren()) do
				local lowerName = string.lower(chunk.Name)
				if string.match(lowerName, "^chunk%d+$") then
					local item = chunk:FindFirstChild("#Item")
					if item and item:IsA("Model") then
						currentItemHighlight = addHighlight(item, Color3.fromRGB(255, 215, 0))
						print('[ITEM] Highlighted: "' .. option .. '"')
						break
					end
				end
			end
		end
	end
})

-- Refresh item list button
MainTab:CreateButton({
	Name = "🔄 Refresh Item List",
	Callback = function()
		-- Remove highlight when refreshing
		removeHighlight(currentItemHighlight)
		currentItemHighlight = nil
		
		getItems()
		ItemDropdown:Refresh(itemOptions, true)
		print("[ITEM] Item list refreshed")
	end
})

-- Teleport to item function
local function teleportToItem(model)
	local char = player.Character or player.CharacterAdded:Wait()
	local root = char:FindFirstChild("HumanoidRootPart")
	
	if not root then
		print("[ITEM] No HumanoidRootPart found on player")
		return
	end
	
	if model:IsA("Model") then
		if model.PrimaryPart then
			root.CFrame = model.PrimaryPart.CFrame * CFrame.new(0, 10, 0)
		else
			local part = model:FindFirstChildWhichIsA("BasePart", true)
			if part then
				root.CFrame = part.CFrame * CFrame.new(0, 10, 0)
			end
		end
	end
end

-- Teleport to item button
MainTab:CreateButton({
	Name = "🚀 Teleport to Item",
	Callback = function()
		if not selectedItem or selectedItem == "NO ITEMS FOUND" then
			print("[ITEM] Invalid selection")
			return
		end
		
		local item = nil
		for _, chunk in pairs(workspace:GetChildren()) do
			local lowerName = string.lower(chunk.Name)
			if string.match(lowerName, "^chunk%d+$") then
				item = chunk:FindFirstChild("#Item")
				if item then break end
			end
		end
		
		if not item then
			print("[ITEM] Item not found")
			return
		end
		
		print('[ITEM] Teleporting to Item')
		teleportToItem(item)
	end
})

-- ================================================
-- PLAYER TAB
-- ================================================
PlayerTab:CreateLabel("⚡ Player Stats")

-- WalkSpeed input
PlayerTab:CreateInput({
	Name = "🏃 WalkSpeed",
	PlaceholderText = "16",
	Callback = function(text)
		wsValue = tonumber(text) or 16
	end
})

-- Apply WalkSpeed button
PlayerTab:CreateButton({
	Name = "✅ Apply WalkSpeed",
	Callback = function()
		local hum = getHumanoid()
		if hum then
			hum.WalkSpeed = wsValue
		end
	end
})

-- JumpPower input
PlayerTab:CreateInput({
	Name = "🦘 JumpPower",
	PlaceholderText = "50",
	Callback = function(text)
		jpValue = tonumber(text) or 50
	end
})

-- Apply JumpPower button
PlayerTab:CreateButton({
	Name = "✅ Apply JumpPower",
	Callback = function()
		local hum = getHumanoid()
		if hum then
			hum.JumpPower = jpValue
		end
	end
})

-- ================================================
-- MISC TAB - WORLD TOOLS
-- ================================================
MiscTab:CreateLabel("🌍 World Tools")

-- Remove/Restore grass button
MiscTab:CreateButton({
	Name = "🌿 Remove / Restore Grass",
	Callback = function()
		if not grassRemoved then
			for _, v in pairs(workspace:GetChildren()) do
				local lowerName = string.lower(v.Name)
				if string.match(lowerName, "^chunk%d+$") then
					local grassVariants = {"MGrass", "Grass", "grass", "mgrass"}
					for _, variant in ipairs(grassVariants) do
						local grass = v:FindFirstChild(variant)
						if grass then
							removedGrass[v.Name .. "_" .. variant] = grass:Clone()
							grass:Destroy()
						end
					end
				end
			end
			grassRemoved = true
		else
			for key, clone in pairs(removedGrass) do
				local parts = string.split(key, "_")
				local chunkName = parts[1]
				local chunk = workspace:FindFirstChild(chunkName)
				if chunk and clone then
					clone.Parent = chunk
				end
			end
			removedGrass = {}
			grassRemoved = false
		end
	end
})

-- Remove/Restore sand button
MiscTab:CreateButton({
	Name = "🏖️ Remove / Restore Sand",
	Callback = function()
		if not sandRemoved then
			for _, v in pairs(workspace:GetChildren()) do
				local lowerName = string.lower(v.Name)
				if string.match(lowerName, "^chunk%d+$") then
					local sandVariants = {"MSand", "Sand", "sand", "msand"}
					for _, variant in ipairs(sandVariants) do
						local sand = v:FindFirstChild(variant)
						if sand then
							removedSand[v.Name .. "_" .. variant] = sand:Clone()
							sand:Destroy()
						end
					end
				end
			end
			sandRemoved = true
		else
			for key, clone in pairs(removedSand) do
				local parts = string.split(key, "_")
				local chunkName = parts[1]
				local chunk = workspace:FindFirstChild(chunkName)
				if chunk and clone then
					clone.Parent = chunk
				end
			end
			removedSand = {}
			sandRemoved = false
		end
	end
})

-- Remove/Restore snow button
MiscTab:CreateButton({
	Name = "❄️ Remove / Restore Snow",
	Callback = function()
		if not snowRemoved then
			for _, v in pairs(workspace:GetChildren()) do
				local lowerName = string.lower(v.Name)
				if string.match(lowerName, "^chunk%d+$") then
					local snowVariants = {"MSnow", "Snow", "snow", "msnow"}
					for _, variant in ipairs(snowVariants) do
						local snow = v:FindFirstChild(variant)
						if snow then
							removedSnow[v.Name .. "_" .. variant] = snow:Clone()
							snow:Destroy()
						end
					end
				end
			end
			snowRemoved = true
		else
			for key, clone in pairs(removedSnow) do
				local parts = string.split(key, "_")
				local chunkName = parts[1]
				local chunk = workspace:FindFirstChild(chunkName)
				if chunk and clone then
					clone.Parent = chunk
				end
			end
			removedSnow = {}
			snowRemoved = false
		end
	end
})

-- ================================================
-- MISC TAB - GYM 5
-- ================================================
MiscTab:CreateLabel("🏟️ GYM 5")

-- Delete AllStone button
MiscTab:CreateButton({
	Name = "🪨 Delete AllStone",
	Callback = function()
		local gym5 = workspace:FindFirstChild("gym5") or workspace:FindFirstChild("Gym5")
		if gym5 then
			for _, v in pairs(gym5:GetChildren()) do
				if v.Name == "AllStone" then
					v:Destroy()
				end
			end
		end
	end
})

-- Delete AllDirt button
MiscTab:CreateButton({
	Name = "🟫 Delete AllDirt",
	Callback = function()
		local gym5 = workspace:FindFirstChild("gym5") or workspace:FindFirstChild("Gym5")
		if gym5 then
			for _, v in pairs(gym5:GetChildren()) do
				if v.Name == "AllDirt" then
					v:Destroy()
				end
			end
		end
	end
})

-- ================================================
-- MISC TAB - LIGHTING
-- ================================================
MiscTab:CreateLabel("💡 Lighting")

-- Exposure input
MiscTab:CreateInput({
	Name = "☀️ Exposure Value",
	PlaceholderText = "0, 1, -2",
	Callback = function(text)
		exposureValue = tonumber(text) or 0
	end
})

-- Apply exposure button
MiscTab:CreateButton({
	Name = "✅ Apply Exposure",
	Callback = function()
		Lighting.ExposureCompensation = exposureValue
	end
})

-- ================================================
-- SETTINGS TAB
-- ================================================

-- Unload UI button
SettingsTab:CreateButton({
	Name = "❌ Unload UI",
	Callback = function()
		stopTimer()
		-- Remove highlights before unloading
		removeHighlight(currentGymHighlight)
		removeHighlight(currentChunkHighlight)
		removeHighlight(currentItemHighlight)
		if screenGui then
			screenGui:Destroy()
		end
		if typeGui then
			typeGui:Destroy()
		end
		Rayfield:Destroy()
	end
})
