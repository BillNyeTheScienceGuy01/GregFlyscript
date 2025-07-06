local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Clean old GUI if it exists
local existingGUI = PlayerGui:FindFirstChild("GregFlyGUI")
if existingGUI then existingGUI:Destroy() end

-- GUI Setup
local gui = Instance.new("ScreenGui", PlayerGui)
gui.Name = "GregFlyGUI"
gui.ResetOnSpawn = false

-- Main Frame
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 250, 0, 130)
frame.Position = UDim2.new(0.02, 0, 0.25, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

-- Title
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.Text = "Greg Fly Script"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.fromRGB(0, 255, 255)
title.TextSize = 18

-- Instruction Text
local instructions = Instance.new("TextLabel", frame)
instructions.Position = UDim2.new(0, 0, 0, 35)
instructions.Size = UDim2.new(1, 0, 0, 60)
instructions.BackgroundTransparency = 1
instructions.Text = "PC: E to toggle fly\nWASD/Space/Shift to move\nMobile: Use on-screen buttons"
instructions.TextColor3 = Color3.fromRGB(255, 255, 255)
instructions.Font = Enum.Font.Gotham
instructions.TextSize = 14
instructions.TextWrapped = true

-- Dismiss Button
local dismissButton = Instance.new("TextButton", frame)
dismissButton.Position = UDim2.new(0, 0, 1, -30)
dismissButton.Size = UDim2.new(1, 0, 0, 30)
dismissButton.Text = "Dismiss"
dismissButton.Font = Enum.Font.GothamBold
dismissButton.TextColor3 = Color3.fromRGB(255, 85, 85)
dismissButton.TextSize = 16
dismissButton.BackgroundColor3 = Color3.fromRGB(60, 0, 0)

dismissButton.MouseButton1Click:Connect(function()
	gui:Destroy()
end)
