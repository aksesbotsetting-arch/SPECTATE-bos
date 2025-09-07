-- Anti duplicate
if getgenv().NazamHubLoaded then return end
getgenv().NazamHubLoaded = true

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage") -- buat RemoteEvent

-- Player
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- Simpan objek yang dihapus
local deletedObjects = {}

-- Buat RemoteEvent jika belum ada
local deleteEvent = ReplicatedStorage:FindFirstChild("DeleteObjectEvent") or Instance.new("RemoteEvent")
deleteEvent.Name = "DeleteObjectEvent"
deleteEvent.Parent = ReplicatedStorage

local restoreEvent = ReplicatedStorage:FindFirstChild("RestoreObjectEvent") or Instance.new("RemoteEvent")
restoreEvent.Name = "RestoreObjectEvent"
restoreEvent.Parent = ReplicatedStorage

--=====================
-- GUI Setup
--=====================
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Function tween
local function tweenTransparency(obj, target, time)
    local tween = TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {TextTransparency = target})
    tween:Play()
    tween.Completed:Wait()
end

--===== Tampilan Pertama =====
local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.new(0,120,0,50)
openBtn.Position = UDim2.new(0.5,-60,0.5,-25)
openBtn.Text = "OPEN"
openBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
openBtn.TextColor3 = Color3.fromRGB(255,255,255)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextScaled = true
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0,10)
Instance.new("UIStroke", openBtn).Color = Color3.fromRGB(0,200,255)

--===== Tampilan Kedua =====
local menuFrame = Instance.new("Frame", gui)
menuFrame.Size = UDim2.new(0,250,0,150)
menuFrame.Position = UDim2.new(0.5,-125,0.5,-75)
menuFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
menuFrame.Visible = false
Instance.new("UICorner", menuFrame).CornerRadius = UDim.new(0,12)
local frameStroke = Instance.new("UIStroke", menuFrame)
frameStroke.Color = Color3.fromRGB(0,200,255)

-- Label
local titleLabel = Instance.new("TextLabel", menuFrame)
titleLabel.Size = UDim2.new(1,0,0,30)
titleLabel.Position = UDim2.new(0,0,0,0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "By Nazam"
titleLabel.TextColor3 = Color3.fromRGB(255,255,255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextScaled = true

-- Tombol DELETE OBJEK
local deleteBtn = Instance.new("TextButton", menuFrame)
deleteBtn.Size = UDim2.new(0.8,0,0,40)
deleteBtn.Position = UDim2.new(0.1,0,0.35,0)
deleteBtn.Text = "DELETE OBJEK"
deleteBtn.Font = Enum.Font.GothamBold
deleteBtn.TextScaled = true
deleteBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
deleteBtn.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", deleteBtn).CornerRadius = UDim.new(0,8)

-- Tombol BACK OBJEK
local backBtn = Instance.new("TextButton", menuFrame)
backBtn.Size = UDim2.new(0.8,0,0,40)
backBtn.Position = UDim2.new(0.1,0,0.65,0)
backBtn.Text = "BACK OBJEK"
backBtn.Font = Enum.Font.GothamBold
backBtn.TextScaled = true
backBtn.BackgroundColor3 = Color3.fromRGB(50,200,50)
backBtn.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", backBtn).CornerRadius = UDim.new(0,8)

-- Dragging
menuFrame.Active = true
menuFrame.Draggable = true

--=====================
-- Button Logic
--=====================
openBtn.MouseButton1Click:Connect(function()
    menuFrame.Visible = not menuFrame.Visible
end)

deleteBtn.MouseButton1Click:Connect(function()
    -- Cek objek depan player
    local ray = Ray.new(hrp.Position, hrp.CFrame.LookVector*10)
    local part, pos = Workspace:FindPartOnRay(ray, character)
    if part then
        table.insert(deletedObjects, {Parent=part.Parent, Part=part})
        part:Destroy()
        -- Notify ke semua client
        deleteEvent:FireAllClients(part)
    end
end)

backBtn.MouseButton1Click:Connect(function()
    if #deletedObjects > 0 then
        local last = table.remove(deletedObjects)
        last.Part.Parent = last.Parent
        -- Notify ke semua client
        restoreEvent:FireAllClients(last.Part)
    end
end)

--=====================
-- RemoteEvent Client
--=====================
deleteEvent.OnClientEvent:Connect(function(part)
    if part and part.Parent then
        part:Destroy()
    end
end)

restoreEvent.OnClientEvent:Connect(function(part)
    if part and part.Parent == nil then
        part.Parent = Workspace
    end
end)
