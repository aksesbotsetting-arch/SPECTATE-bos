-- Anti duplicate
if getgenv().SpectateHubLoaded then return end
getgenv().SpectateHubLoaded = true

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Player setup
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

--=====================--
-- GUI Setup
--=====================--
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local function createButton(parent, text, position, size)
    local btn = Instance.new("TextButton", parent)
    btn.Size = size or UDim2.new(0,100,0,40)
    btn.Position = position
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    btn.BackgroundColor3 = Color3.fromRGB(0,200,255)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
    return btn
end

-- Main Frame
local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0,300,0,150)
mainFrame.Position = UDim2.new(0.5,-150,0.5,-75)
mainFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
mainFrame.Active = true
mainFrame.Draggable = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0,12)

-- Close Button
local closeBtn = createButton(mainFrame, "X", UDim2.new(1,-35,0,5), UDim2.new(0,30,0,30))
closeBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.MouseButton1Click:Connect(function()
    gui.Enabled = false
end)

-- Target label
local targetLabel = Instance.new("TextLabel", mainFrame)
targetLabel.Size = UDim2.new(1,0,0,40)
targetLabel.Position = UDim2.new(0,0,0.1,0)
targetLabel.BackgroundTransparency = 1
targetLabel.TextColor3 = Color3.fromRGB(255,255,255)
targetLabel.Font = Enum.Font.GothamBold
targetLabel.TextScaled = true
targetLabel.Text = "Target: None"

-- Navigation buttons
local prevBtn = createButton(mainFrame, "<", UDim2.new(0.1,0,0.5,0))
local nextBtn = createButton(mainFrame, ">", UDim2.new(0.8,0,0.5,0))

-- Teleport button
local tpBtn = createButton(mainFrame, "Teleport To Target", UDim2.new(0.3,0,0.75,0), UDim2.new(0.4,0,0,40))

--=====================--
-- Spectate Logic
--=====================--
local targetIndex = 1
local targetPlayer = nil
local allPlayers = {}

local function updatePlayerList()
    allPlayers = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(allPlayers, p)
        end
    end
end

local function updateTarget(index)
    updatePlayerList()
    if #allPlayers == 0 then
        targetPlayer = nil
        targetLabel.Text = "Target: None"
        return
    end
    if index < 1 then index = #allPlayers end
    if index > #allPlayers then index = 1 end
    targetIndex = index
    targetPlayer = allPlayers[targetIndex]
    targetLabel.Text = "Target: " .. targetPlayer.Name
end

-- Camera follow
RunService.RenderStepped:Connect(function()
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local cam = workspace.CurrentCamera
        local targetPos = targetPlayer.Character.HumanoidRootPart.Position
        cam.CFrame = CFrame.new(targetPos + Vector3.new(0,5,10), targetPos)
    end
end)

-- Button actions
prevBtn.MouseButton1Click:Connect(function()
    updateTarget(targetIndex - 1)
end)

nextBtn.MouseButton1Click:Connect(function()
    updateTarget(targetIndex + 1)
end)

tpBtn.MouseButton1Click:Connect(function()
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        rootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
    end
end)

-- Initial target
updateTarget(1)
