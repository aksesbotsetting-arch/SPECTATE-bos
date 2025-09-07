-- Anti duplicate
if getgenv().NazamHubLoaded then return end
getgenv().NazamHubLoaded = true

-- Services
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

-- Player setup
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Config
local jumpHeight = 50
local delayOnObstacle = 0.3

--=====================--
-- Checkpoints
--=====================--
local checkpointFolder = workspace:FindFirstChild("Checkpoints")
if not checkpointFolder then
    warn("Folder Checkpoints tidak ditemukan!")
    return
end

local checkpoints = {}
for _, cp in ipairs(checkpointFolder:GetChildren()) do
    if cp.Name:match("^POS%d+$") then
        table.insert(checkpoints, cp)
    end
end

table.sort(checkpoints, function(a,b)
    return tonumber(a.Name:match("%d+")) < tonumber(b.Name:match("%d+"))
end)

local currentCheckpointIndex = 1

--=====================--
-- GUI
--=====================--
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Tween function
local function tweenTransparency(obj, target, time)
    local tween = TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {TextTransparency = target})
    tween:Play()
    tween.Completed:Wait()
end

-- Logo Frame (OPEN)
local logoFrame = Instance.new("Frame", gui)
logoFrame.Size = UDim2.new(0,200,0,80)
logoFrame.Position = UDim2.new(0.5,-100,0.5,-40)
logoFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
Instance.new("UICorner", logoFrame).CornerRadius = UDim.new(0,12)

local logoText = Instance.new("TextButton", logoFrame)
logoText.Size = UDim2.new(1,0,1,0)
logoText.Text = "OPEN"
logoText.TextColor3 = Color3.fromRGB(255,255,255)
logoText.Font = Enum.Font.GothamBold
logoText.TextScaled = true
logoText.BackgroundTransparency = 1

-- Menu Frame
local menuFrame = Instance.new("Frame", gui)
menuFrame.Size = UDim2.new(0,300,0,600)
menuFrame.Position = UDim2.new(0.5,-150,0.5,-300)
menuFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
menuFrame.Visible = false
Instance.new("UICorner", menuFrame).CornerRadius = UDim.new(0,12)

local titleLabel = Instance.new("TextLabel", menuFrame)
titleLabel.Size = UDim2.new(1,0,0,50)
titleLabel.Position = UDim2.new(0,0,0,0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "By Nazam"
titleLabel.TextColor3 = Color3.fromRGB(255,255,255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextScaled = true

-- Fungsi Auto Move
local function moveToTarget(targetPosition)
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentJumpHeight = jumpHeight,
        AgentMaxSlope = 45
    })
    path:ComputeAsync(rootPart.Position, targetPosition)
    for _, wp in ipairs(path:GetWaypoints()) do
        humanoid:MoveTo(wp.Position)
        if wp.Action == Enum.PathWaypointAction.Jump then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
        humanoid.MoveToFinished:Wait()
    end
end

-- Fungsi auto run antar checkpoint
local function autoRunBetween(startIndex, endIndex)
    if startIndex ~= currentCheckpointIndex then
        warn("Harus mulai dari checkpoint sesuai urutan!")
        return
    end
    for i = startIndex, endIndex do
        local cp = checkpoints[i]
        moveToTarget(cp.Position)
        currentCheckpointIndex = i + 1
    end
    print("Sampai tujuan! Tekan tombol berikutnya untuk lanjut.")
end

-- Generate tombol POS 1 - 26
for i = 1, #checkpoints-1 do
    local btn = Instance.new("TextButton", menuFrame)
    btn.Size = UDim2.new(0.8,0,0,40)
    btn.Position = UDim2.new(0.1,0,0,50 + (i-1)*45)
    btn.Text = checkpoints[i].Name.." - "..checkpoints[i+1].Name
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    btn.BackgroundColor3 = Color3.fromRGB(0,200,255)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

    btn.MouseButton1Click:Connect(function()
        autoRunBetween(i, i+1)
    end)
end

-- Animasi Fade In/Out
logoText.MouseButton1Click:Connect(function()
    if logoFrame.Visible then
        tweenTransparency(logoText, 1, 0.5)
        task.wait(0.5)
        logoFrame.Visible = false
        menuFrame.Visible = true
        for _, child in ipairs(menuFrame:GetChildren()) do
            if child:IsA("TextButton") or child:IsA("TextLabel") then
                tweenTransparency(child, 0, 0.5)
            end
        end
    else
        menuFrame.Visible = false
        logoFrame.Visible = true
        tweenTransparency(logoText, 0, 0.5)
    end
end)
