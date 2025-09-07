-- Anti duplicate
if getgenv().NazamAutoWalkLoaded then return end
getgenv().NazamAutoWalkLoaded = true

-- Services
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Player setup
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Config
local jumpHeight = 50
local delayOnObstacle = 0.5

-- Collect POS parts dynamically
local checkpoints = {}
for _, obj in ipairs(Workspace:GetDescendants()) do
    if obj:IsA("BasePart") and obj.Name:match("^POS%d+$") then
        table.insert(checkpoints, obj)
    end
end

table.sort(checkpoints, function(a,b)
    return tonumber(a.Name:match("%d+")) < tonumber(b.Name:match("%d+"))
end)

-- Determine current checkpoint index
local currentCheckpointIndex = 1

--=====================--
-- GUI Setup
--=====================--
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local menuFrame = Instance.new("Frame", gui)
menuFrame.Size = UDim2.new(0, 300, 0, 400)
menuFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
menuFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
menuFrame.Visible = true
Instance.new("UICorner", menuFrame).CornerRadius = UDim.new(0,12)
local menuStroke = Instance.new("UIStroke", menuFrame)
menuStroke.Color = Color3.fromRGB(0,200,255)
menuStroke.Thickness = 2

local titleLabel = Instance.new("TextLabel", menuFrame)
titleLabel.Size = UDim2.new(1,0,0,50)
titleLabel.Position = UDim2.new(0,0,0,0)
titleLabel.Text = "Auto Walk POS 1-26"
titleLabel.TextColor3 = Color3.fromRGB(255,255,255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextScaled = true
titleLabel.BackgroundTransparency = 1

-- Container for buttons
local btnStartY = 60
for i = 1, #checkpoints-1 do
    local btn = Instance.new("TextButton", menuFrame)
    btn.Size = UDim2.new(0.8,0,0,40)
    btn.Position = UDim2.new(0.1,0,0, btnStartY)
    btnStartY = btnStartY + 50
    btn.Text = checkpoints[i].Name.." → "..checkpoints[i+1].Name
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    btn.BackgroundColor3 = Color3.fromRGB(0,200,255)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

    btn.MouseButton1Click:Connect(function()
        local startIndex = i
        local endIndex = i+1
        if startIndex ~= currentCheckpointIndex then
            warn("Tidak bisa mulai dari checkpoint ini. Harus sesuai urutan!")
            return
        end

        -- Auto walk function
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

        -- Walk through checkpoints
        for idx = startIndex, endIndex do
            local cp = checkpoints[idx]
            moveToTarget(cp.Position)
            currentCheckpointIndex = idx + 1
        end

        print("Sampai tujuan! Klik tombol selanjutnya untuk lanjut.")
    end)
end
