-- SERVICES
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera

-- GLOBAL MOBILE MOVE VECTOR (used by flight logic)
_G.GregMobileMove = Vector3.new(0,0,0)

-- FLY VARIABLES
local flying = false
local speed = 50
local velocity

-- ANTI KICK HOOK (optional)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if method == "Kick" then
        return wait(9e9)
    end
    return oldNamecall(self, ...)
end)

-- TOGGLE FLY WITH E KEY
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.E then
        flying = not flying
        if flying then
            velocity = Instance.new("BodyVelocity")
            velocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            velocity.Parent = hrp
            velocity.Velocity = Vector3.new(0, 0, 0)
        else
            if velocity then
                velocity:Destroy()
                velocity = nil
            end
        end
    end
end)

-- UPDATE VELOCITY EACH FRAME (FLY RELATIVE TO CAMERA)
RunService.RenderStepped:Connect(function()
    if flying and velocity then
        local camCFrame = camera.CFrame

        -- Keyboard horizontal input
        local moveInput = Vector3.new(
            (UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.A) and 1 or 0),
            0,
            (UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0)
        )

        -- Keyboard vertical input
        local verticalInput = 0
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            verticalInput = 1
        elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            verticalInput = -1
        end

        -- Calculate horizontal move vector relative to camera
        local moveVec = Vector3.new(0,0,0)
        if moveInput.Magnitude > 0 then
            local horDir = (camCFrame.RightVector * moveInput.X) + (camCFrame.LookVector * -moveInput.Z)
            horDir = Vector3.new(horDir.X, 0, horDir.Z).Unit
            moveVec = horDir * speed
        end

        -- Add vertical component
        moveVec = moveVec + Vector3.new(0, verticalInput * speed, 0)

        -- Add mobile movement, transformed like keyboard
        local mobileVec = _G.GregMobileMove
        if mobileVec.Magnitude > 0 then
            local mobileHor = Vector3.new(mobileVec.X, 0, mobileVec.Z)
            local camMobile = (camCFrame.RightVector * mobileHor.X) + (camCFrame.LookVector * -mobileHor.Z)
            camMobile = Vector3.new(camMobile.X, 0, camMobile.Z).Unit * mobileHor.Magnitude
            moveVec = moveVec + camMobile + Vector3.new(0, mobileVec.Y * speed, 0)
        end

        velocity.Velocity = moveVec
    end
end)

-- ===============================
-- UI SECTION (MOVEABLE + MOBILE FIXED DISMISS)
-- ===============================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GregFlyGui"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

-- MAIN FLY FRAME
local flyFrame = Instance.new("Frame")
flyFrame.Name = "FlyFrame"
flyFrame.Size = UDim2.new(0, 270, 0, 120)
flyFrame.Position = UDim2.new(0.05, 0, 0.7, 0)
flyFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
flyFrame.BorderSizePixel = 0
flyFrame.BackgroundTransparency = 0.2
flyFrame.Parent = screenGui

-- FLY FRAME TITLE
local flyTitle = Instance.new("TextLabel")
flyTitle.Name = "FlyTitle"
flyTitle.Size = UDim2.new(1, 0, 0, 30)
flyTitle.BackgroundTransparency = 1
flyTitle.Text = "Greg Fly Script"
flyTitle.Font = Enum.Font.GothamBold
flyTitle.TextSize = 20
flyTitle.TextColor3 = Color3.fromRGB(0, 255, 255)
flyTitle.Parent = flyFrame

-- INSTRUCTIONS LABEL
local flyInstructions = Instance.new("TextLabel")
flyInstructions.Name = "FlyInstructions"
flyInstructions.Size = UDim2.new(1, -20, 1, -40)
flyInstructions.Position = UDim2.new(0, 10, 0, 30)
flyInstructions.BackgroundTransparency = 1
flyInstructions.Text = "Press E to toggle fly\nWASD + Space/Shift to move\nDismiss mobile controls below"
flyInstructions.Font = Enum.Font.Gotham
flyInstructions.TextSize = 16
flyInstructions.TextColor3 = Color3.fromRGB(255, 255, 255)
flyInstructions.TextWrapped = true
flyInstructions.TextYAlignment = Enum.TextYAlignment.Top
flyInstructions.Parent = flyFrame

-- MOBILE CONTROLS FRAME
local mobileFrame = Instance.new("Frame")
mobileFrame.Name = "MobileControls"
mobileFrame.Size = UDim2.new(0, 260, 0, 160)
mobileFrame.Position = UDim2.new(0.05, 0, 0.5, 0)
mobileFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mobileFrame.BackgroundTransparency = 0.3
mobileFrame.BorderSizePixel = 0
mobileFrame.Parent = screenGui
mobileFrame.Visible = false -- starts hidden, shown by your mobile detection code

-- MOBILE TITLE
local mobileTitle = Instance.new("TextLabel")
mobileTitle.Name = "MobileTitle"
mobileTitle.Size = UDim2.new(1, 0, 0, 25)
mobileTitle.BackgroundTransparency = 1
mobileTitle.Text = "Mobile Fly Controls"
mobileTitle.Font = Enum.Font.GothamBold
mobileTitle.TextSize = 18
mobileTitle.TextColor3 = Color3.fromRGB(0, 255, 255)
mobileTitle.Parent = mobileFrame

-- MOBILE MOVE BUTTONS (WASD style)
local function createMobileButton(name, pos, text)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0, 50, 0, 50)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 28
    btn.TextColor3 = Color3.fromRGB(0, 255, 255)
    btn.Parent = mobileFrame
    return btn
end

local btnW = createMobileButton("BtnW", UDim2.new(0.35, 0, 0.35, 0), "W")
local btnA = createMobileButton("BtnA", UDim2.new(0.15, 0, 0.65, 0), "A")
local btnS = createMobileButton("BtnS", UDim2.new(0.35, 0, 0.65, 0), "S")
local btnD = createMobileButton("BtnD", UDim2.new(0.55, 0, 0.65, 0), "D")
local btnSpace = createMobileButton("BtnSpace", UDim2.new(0.75, 0, 0.35, 0), "↑")
local btnShift = createMobileButton("BtnShift", UDim2.new(0.75, 0, 0.65, 0), "↓")

-- MOBILE MOVE STATE TRACKING
local mobileMoveState = {
    W = false,
    A = false,
    S = false,
    D = false,
    Space = false,
    Shift = false,
}

local function updateMobileMoveVector()
    local x = 0
    local y = 0
    local z = 0

    if mobileMoveState.W then z = z - 1 end
    if mobileMoveState.S then z = z + 1 end
    if mobileMoveState.A then x = x - 1 end
    if mobileMoveState.D then x = x + 1 end
    if mobileMoveState.Space then y = y + 1 end
    if mobileMoveState.Shift then y = y - 1 end

    _G.GregMobileMove = Vector3.new(x, y, z)
end

local function bindMobileButton(btn, keyName)
    btn.MouseButton1Down:Connect(function()
        mobileMoveState[keyName] = true
        updateMobileMoveVector()
    end)
    btn.MouseButton1Up:Connect(function()
        mobileMoveState[keyName] = false
        updateMobileMoveVector()
    end)
    btn.TouchEnded:Connect(function()
        mobileMoveState[keyName] = false
        updateMobileMoveVector()
    end)
end

bindMobileButton(btnW, "W")
bindMobileButton(btnA, "A")
bindMobileButton(btnS, "S")
bindMobileButton(btnD, "D")
bindMobileButton(btnSpace, "Space")
bindMobileButton(btnShift, "Shift")

-- DISMISS MOBILE CONTROLS BUTTON
local dismissBtn = Instance.new("TextButton")
dismissBtn.Name = "DismissButton"
dismissBtn.Size = UDim2.new(0, 120, 0, 30)
dismissBtn.Position = UDim2.new(0.5, -60, 1, -35)
dismissBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
dismissBtn.BorderSizePixel = 0
dismissBtn.Text = "Dismiss Mobile Controls"
dismissBtn.Font = Enum.Font.GothamBold
dismissBtn.TextSize = 16
dismissBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
dismissBtn.Parent = mobileFrame

dismissBtn.MouseButton1Click:Connect(function()
    mobileFrame.Visible = false
    for k,_ in pairs(mobileMoveState) do
        mobileMoveState[k] = false
    end
    _G.GregMobileMove = Vector3.new(0,0,0)
end)

-- MAKE FRAME DRAGGABLE FUNCTION
local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                math.clamp(startPos.X.Scale,0,1),
                math.clamp(startPos.X.Offset + delta.X, 0, workspace.CurrentCamera.ViewportSize.X - frame.AbsoluteSize.X),
                math.clamp(startPos.Y.Scale,0,1),
                math.clamp(startPos.Y.Offset + delta.Y, 0, workspace.CurrentCamera.ViewportSize.Y - frame.AbsoluteSize.Y)
            )
        end
    end)
end

-- MAKE UI DRAGGABLE
makeDraggable(flyFrame)
makeDraggable(mobileFrame)
