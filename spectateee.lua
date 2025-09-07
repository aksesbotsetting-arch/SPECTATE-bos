-- Anti duplicate
if getgenv().SpecHubLoaded then return end
getgenv().SpecHubLoaded = true

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- GUI
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

--=====================
-- Start Button
--=====================
local startBtn = Instance.new("TextButton", gui)
startBtn.Size = UDim2.new(0,100,0,40)
startBtn.Position = UDim2.new(0.5,-50,0.5,-20)
startBtn.BackgroundColor3 = Color3.fromRGB(0,200,255)
startBtn.Text = "Start Spectate"
startBtn.TextColor3 = Color3.fromRGB(255,255,255)
startBtn.TextScaled = true
startBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0,6)
startBtn.Active = true
startBtn.Draggable = true

--=====================
-- Spectate Mini GUI
--=====================
local specFrame = Instance.new("Frame", gui)
specFrame.Size = UDim2.new(0,220,0,80)
specFrame.Position = UDim2.new(0.5,-110,0.85,0)
specFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
specFrame.Visible = false
Instance.new("UICorner", specFrame).CornerRadius = UDim.new(0,12)
Instance.new("UIStroke", specFrame).Color = Color3.fromRGB(0,200,255)

local targetLabel = Instance.new("TextLabel", specFrame)
targetLabel.Size = UDim2.new(1,0,0,30)
targetLabel.Position = UDim2.new(0,0,0,0)
targetLabel.BackgroundTransparency = 1
targetLabel.TextColor3 = Color3.fromRGB(255,255,255)
targetLabel.Font = Enum.Font.GothamBold
targetLabel.TextScaled = true
targetLabel.Text = "Target: -"

local prevBtn = Instance.new("TextButton", specFrame)
prevBtn.Size = UDim2.new(0.3,0,0,30)
prevBtn.Position = UDim2.new(0.05,0,0.55,0)
prevBtn.Text = "<"
prevBtn.Font = Enum.Font.GothamBold
prevBtn.TextScaled = true
prevBtn.BackgroundColor3 = Color3.fromRGB(0,200,255)
prevBtn.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", prevBtn).CornerRadius = UDim.new(0,6)

local nextBtn = Instance.new("TextButton", specFrame)
nextBtn.Size = UDim2.new(0.3,0,0,30)
nextBtn.Position = UDim2.new(0.65,0,0.55,0)
nextBtn.Text = ">"
nextBtn.Font = Enum.Font.GothamBold
nextBtn.TextScaled = true
nextBtn.BackgroundColor3 = Color3.fromRGB(0,200,255)
nextBtn.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", nextBtn).CornerRadius = UDim.new(0,6)

local tpBtn = Instance.new("TextButton", specFrame)
tpBtn.Size = UDim2.new(0.9,0,0,25)
tpBtn.Position = UDim2.new(0.05,0,0.8,0)
tpBtn.Text = "Teleport to Target"
tpBtn.Font = Enum.Font.GothamBold
tpBtn.TextScaled = true
tpBtn.BackgroundColor3 = Color3.fromRGB(0,255,100)
tpBtn.TextColor3 = Color3.fromRGB(0,0,0)
Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0,6)

--=====================
-- Spectate Logic
--=====================
local function getPlayersList()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            table.insert(list, p)
        end
    end
    return list
end

local targetIndex = 1
local currentTarget = nil
local cameraConnection = nil
local spectating = false

local function updateTarget()
    local list = getPlayersList()
    if #list == 0 then
        targetLabel.Text = "Target: -"
        currentTarget = nil
        return
    end
    if targetIndex > #list then targetIndex = 1 end
    if targetIndex < 1 then targetIndex = #list end
    currentTarget = list[targetIndex]
    targetLabel.Text = "Target: "..currentTarget.Name
end

local function startSpectate()
    if spectating then return end
    spectating = true
    updateTarget()
    startBtn.Visible = false
    specFrame.Visible = true
    camera.CameraType = Enum.CameraType.Scriptable

    cameraConnection = RunService.RenderStepped:Connect(function()
        if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = currentTarget.Character.HumanoidRootPart
            camera.CFrame = CFrame.new(hrp.Position + Vector3.new(0,5,10), hrp.Position)
        end
    end)
end

local function stopSpectate()
    if not spectating then return end
    spectating = false
    if cameraConnection then
        cameraConnection:Disconnect()
        cameraConnection = nil
    end
    camera.CameraType = Enum.CameraType.Custom
    specFrame.Visible = false
    startBtn.Visible = true
end

--=====================
-- Button Connections
--=====================
startBtn.MouseButton1Click:Connect(function()
    startSpectate()
end)

prevBtn.MouseButton1Click:Connect(function()
    targetIndex = targetIndex - 1
    updateTarget()
end)

nextBtn.MouseButton1Click:Connect(function()
    targetIndex = targetIndex + 1
    updateTarget()
end)

tpBtn.MouseButton1Click:Connect(function()
    if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = currentTarget.Character.HumanoidRootPart
        local char = player.Character or player.CharacterAdded:Wait()
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = hrp.CFrame + Vector3.new(0,3,0)
            stopSpectate()
        end
    end
end)

-- Cleanup saat respawn
player.CharacterAdded:Connect(function()
    stopSpectate()
end)
