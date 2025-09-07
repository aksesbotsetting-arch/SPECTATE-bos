
-- Anti duplicate
if getgenv().SpecHubLoaded then return end
getgenv().SpecHubLoaded = true

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

-- Player setup
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- GUI
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Start/Toggle Button
local startBtn = Instance.new("TextButton", gui)
startBtn.Size = UDim2.new(0,80,0,40)
startBtn.Position = UDim2.new(0.5,-40,0.5,-20)
startBtn.BackgroundColor3 = Color3.fromRGB(0,200,255)
startBtn.Text = "Start Spectate"
startBtn.TextColor3 = Color3.fromRGB(255,255,255)
startBtn.TextScaled = true
startBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0,6)
Instance.new("UIStroke", startBtn).Color = Color3.fromRGB(255,255,255)
startBtn.Active = true
startBtn.Draggable = true

-- Spectate GUI Frame
local frameWidth, frameHeight = 250, 120
local specFrame = Instance.new("Frame", gui)
specFrame.Size = UDim2.new(0, frameWidth, 0, frameHeight)
specFrame.Position = UDim2.new(0.5, -frameWidth/2, 0.5, -frameHeight/2) -- tengah layar
specFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
specFrame.Visible = false
Instance.new("UICorner", specFrame).CornerRadius = UDim.new(0,12)
local frameStroke = Instance.new("UIStroke", specFrame)
frameStroke.Color = Color3.fromRGB(0,200,255)

-- Label Target
local targetLabel = Instance.new("TextLabel", specFrame)
targetLabel.Size = UDim2.new(1,0,0,40)
targetLabel.Position = UDim2.new(0,0,0,0)
targetLabel.BackgroundTransparency = 1
targetLabel.TextColor3 = Color3.fromRGB(255,255,255)
targetLabel.Font = Enum.Font.GothamBold
targetLabel.TextScaled = true
targetLabel.Text = "Target: -"

-- Buttons Prev / Next
local prevBtn = Instance.new("TextButton", specFrame)
prevBtn.Size = UDim2.new(0.3,0,0,40)
prevBtn.Position = UDim2.new(0.05,0,0.5,0)
prevBtn.Text = "<"
prevBtn.Font = Enum.Font.GothamBold
prevBtn.TextScaled = true
prevBtn.BackgroundColor3 = Color3.fromRGB(0,200,255)
prevBtn.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", prevBtn).CornerRadius = UDim.new(0,6)

local nextBtn = Instance.new("TextButton", specFrame)
nextBtn.Size = UDim2.new(0.3,0,0,40)
nextBtn.Position = UDim2.new(0.65,0,0.5,0)
nextBtn.Text = ">"
nextBtn.Font = Enum.Font.GothamBold
nextBtn.TextScaled = true
nextBtn.BackgroundColor3 = Color3.fromRGB(0,200,255)
nextBtn.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", nextBtn).CornerRadius = UDim.new(0,6)

-- Teleport Button
local tpBtn = Instance.new("TextButton", specFrame)
tpBtn.Size = UDim2.new(0.9,0,0,30)
tpBtn.Position = UDim2.new(0.05,0,0.75,0)
tpBtn.Text = "Teleport to Target"
tpBtn.Font = Enum.Font.GothamBold
tpBtn.TextScaled = true
tpBtn.BackgroundColor3 = Color3.fromRGB(0,255,100)
tpBtn.TextColor3 = Color3.fromRGB(0,0,0)
Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0,6)

-- Spectate Logic
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
end

-- Button Connections
startBtn.MouseButton1Click:Connect(function()
    if not spectating then
        startSpectate()
        startBtn.Text = "Stop Spectate"
        specFrame.Visible = true
    else
        stopSpectate()
        startBtn.Text = "Start Spectate"
        specFrame.Visible = false
    end
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
        player.Character:SetPrimaryPartCFrame(hrp.CFrame + Vector3.new(0,3,0))
        stopSpectate() -- kamera kembali normal
        startBtn.Text = "Start Spectate"
        specFrame.Visible = false
    end
end)

-- Cleanup jika respawn
player.CharacterAdded:Connect(function()
    stopSpectate()
    startBtn.Text = "Start Spectate"
    startBtn.Visible = true
    specFrame.Visible = false
end)

