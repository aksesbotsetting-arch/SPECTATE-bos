-- Anti duplicate
if getgenv().NazamHubLoaded then return end
getgenv().NazamHubLoaded = true

-- Services
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Config
local jumpHeight = 50
local delayOnObstacle = 0.5

-- Checkpoints
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

-- GUI
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Function Tween Fade
local function fadeIn(obj, time)
    obj.Visible = true
    local tween = TweenService:Create(obj, TweenInfo.new(time), {BackgroundTransparency = 0})
    tween:Play()
end

local function fadeOut(obj, time)
    local tween = TweenService:Create(obj, TweenInfo.new(time), {BackgroundTransparency = 1})
    tween:Play()
    tween.Completed:Wait()
    obj.Visible = false
end

--=====================
-- Logo / Open Button
--=====================
local logoFrame = Instance.new("Frame", gui)
logoFrame.Size = UDim2.new(0,200,0,100)
logoFrame.Position = UDim2.new(0.5,-100,0.5,-50)
logoFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
logoFrame.Visible = true
Instance.new("UICorner", logoFrame).CornerRadius = UDim.new(0,12)

local logoBtn = Instance.new("TextButton", logoFrame)
logoBtn.Size = UDim2.new(1,0,1,0)
logoBtn.Text = "OPEN"
logoBtn.Font = Enum.Font.GothamBold
logoBtn.TextScaled = true
logoBtn.BackgroundTransparency = 1
logoBtn.TextColor3 = Color3.fromRGB(0,200,255)

--=====================
-- Menu Frame
--=====================
local menuFrame = Instance.new("Frame", gui)
menuFrame.Size = UDim2.new(0,250,0,600)
menuFrame.Position = UDim2.new(0.5,-125,0.3,0)
menuFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
menuFrame.Visible = false
Instance.new("UICorner", menuFrame).CornerRadius = UDim.new(0,12)

local menuStroke = Instance.new("UIStroke", menuFrame)
menuStroke.Color = Color3.fromRGB(0,200,255)

-- Close Button
local closeBtn = Instance.new("TextButton", menuFrame)
closeBtn.Size = UDim2.new(0,25,0,25)
closeBtn.Position = UDim2.new(1,-30,0,5)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextScaled = true
closeBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,6)

-- By Nazam Label
local creditLabel = Instance.new("TextLabel", menuFrame)
creditLabel.Size = UDim2.new(1,0,0,30)
creditLabel.Position = UDim2.new(0,0,1,-35)
creditLabel.Text = "By Nazam"
creditLabel.Font = Enum.Font.GothamBold
creditLabel.TextColor3 = Color3.fromRGB(200,200,200)
creditLabel.BackgroundTransparency = 1
creditLabel.TextScaled = true

--=====================
-- Generate Buttons POS
--=====================
local buttonY = 40
for i = 1,#checkpoints-1 do
    local btn = Instance.new("TextButton", menuFrame)
    btn.Size = UDim2.new(0.9,0,0,30)
    btn.Position = UDim2.new(0.05,0,0,buttonY)
    btn.Text = checkpoints[i].Name.." - "..checkpoints[i+1].Name
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    btn.BackgroundColor3 = Color3.fromRGB(0,200,255)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
    
    btn.MouseButton1Click:Connect(function()
        if currentCheckpointIndex ~= i then
            warn("Harus klik tombol sesuai urutan!")
            return
        end
        
        -- Auto walk
        local path = PathfindingService:CreatePath({
            AgentRadius = 2,
            AgentHeight = 5,
            AgentCanJump = true,
            AgentJumpHeight = jumpHeight,
            AgentMaxSlope = 45
        })
        path:ComputeAsync(rootPart.Position, checkpoints[i+1].Position)
        for _, wp in ipairs(path:GetWaypoints()) do
            humanoid:MoveTo(wp.Position)
            if wp.Action == Enum.PathWaypointAction.Jump then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
            humanoid.MoveToFinished:Wait()
        end
        currentCheckpointIndex = i+1
        print("Sampai tujuan! Klik tombol selanjutnya.")
    end)
    
    buttonY = buttonY + 40
end

--=====================
-- Button Connections
--=====================
logoBtn.MouseButton1Click:Connect(function()
    logoFrame.Visible = not logoFrame.Visible
    menuFrame.Visible = not menuFrame.Visible
end)

closeBtn.MouseButton1Click:Connect(function()
    menuFrame.Visible = false
    logoFrame.Visible = true
end)
