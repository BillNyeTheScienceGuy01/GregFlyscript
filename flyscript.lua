-- GREG'S PERSONAL FLY SCRIPT FOR KRNL WITH PLATFORM DETECTION & EXIT
local player = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldNamecall = mt.__namecall

-- Anti-Kick and Anti-Ban Hook
mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if method == "Kick" or tostring(self) == "Kick" then
        warn("[GREG ANTI-KICK] Blocked kick attempt!")
        return nil
    end
    return oldNamecall(self, unpack(args))
end)

local speed = 50
local flying = false
local bodyVel = nil

function announceFly(targetPlayer)
    -- Sound Effect
    local sfx = Instance.new("Sound")
    sfx.SoundId = "rbxassetid://104537552188658" -- wings sound or customize
    sfx.Volume = 3
    sfx.PlayOnRemove = true
    sfx.Parent = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") or workspace
    sfx:Destroy() -- plays instantly

    -- Particles
    local particle = Instance.new("ParticleEmitter")
    particle.Texture = "rbxassetid://301055640" -- sparkle texture
    particle.Rate = 200
    particle.Lifetime = NumberRange.new(0.5)
    particle.Speed = NumberRange.new(10)
    particle.Parent = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") or workspace
    game.Debris:AddItem(particle, 1)

    -- Message
    game.StarterGui:SetCore("ChatMakeSystemMessage", {
        Text = "[GREG] " .. targetPlayer.Name .. " has taken flight!",
        Color = Color3.fromRGB(0,255,200),
        Font = Enum.Font.GothamBold,
        TextSize = 20
    })
end

local function startFly(char)
    local hrp = char:WaitForChild("HumanoidRootPart")
    if hrp:FindFirstChild("GregVelocity") then return end
    bodyVel = Instance.new("BodyVelocity")
    bodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bodyVel.P = 1250
    bodyVel.Velocity = Vector3.zero
    bodyVel.Name = "GregVelocity"
    bodyVel.Parent = hrp

    rs:BindToRenderStep("GregFly", Enum.RenderPriority.Input.Value, function()
        if not bodyVel or not hrp then return end
        local cam = workspace.CurrentCamera
        local moveDir = Vector3.zero

        -- Keyboard input (PC)
        if uis:IsKeyDown(Enum.KeyCode.W) then moveDir += cam.CFrame.LookVector end
        if uis:IsKeyDown(Enum.KeyCode.S) then moveDir -= cam.CFrame.LookVector end
        if uis:IsKeyDown(Enum.KeyCode.A) then moveDir -= cam.CFrame.RightVector end
        if uis:IsKeyDown(Enum.KeyCode.D) then moveDir += cam.CFrame.RightVector end
        if uis:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) end
        if uis:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir -= Vector3.new(0, 1, 0) end

        -- Joystick buttons (mobile)
        if _G.GregMobileMove then
            moveDir += _G.GregMobileMove
        end

        bodyVel.Velocity = moveDir.Magnitude > 0 and moveDir.Unit * speed or Vector3.zero
    end)
end

local function stopFly()
    rs:UnbindFromRenderStep("GregFly")
    if bodyVel then
        bodyVel:Destroy()
        bodyVel = nil
    end
end

-- Instruction GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "GregFlyGui"

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 120)
frame.Position = UDim2.new(0.5, -140, 0.1, 0)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BackgroundTransparency = 0.4
frame.BorderSizePixel = 0
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "Greg Fly Script"
title.TextColor3 = Color3.fromRGB(0, 255, 200)
title.Font = Enum.Font.GothamBold
title.TextSize = 26
title.Parent = frame

local instructions = {
    "Press E to toggle fly",
    "Use WASD + Space + Shift to move",
    "Mobile users: Use joystick buttons"
}

for i, text in ipairs(instructions) do
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 25)
    label.Position = UDim2.new(0, 10, 0, 30 + (i-1)*30)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 20
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
end

-- Mobile joystick UI with dismiss button
if uis.TouchEnabled then
    _G.GregMobileMove = Vector3.zero
    local directions = {
        {Key = "↑", Vec = Vector3.new(0,1,0), Pos = UDim2.new(0.85, -30, 0.5, -80)},
        {Key = "↓", Vec = Vector3.new(0,-1,0), Pos = UDim2.new(0.85, -30, 0.5, 40)},
        {Key = "←", Vec = Vector3.new(-1,0,0), Pos = UDim2.new(0.85, -80, 0.5, -20)},
        {Key = "→", Vec = Vector3.new(1,0,0), Pos = UDim2.new(0.85, 20, 0.5, -20)}
    }
    for _, dir in pairs(directions) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0,40,0,40)
        b.Position = dir.Pos
        b.Text = dir.Key
        b.BackgroundColor3 = Color3.fromRGB(40,40,40)
        b.TextColor3 = Color3.new(1,1,1)
        b.Parent = gui

        b.MouseButton1Down:Connect(function()
            _G.GregMobileMove += dir.Vec
        end)
        b.MouseButton1Up:Connect(function()
            _G.GregMobileMove -= dir.Vec
        end)
        b.TouchEnded:Connect(function()
            _G.GregMobileMove -= dir.Vec
        end)
    end

    -- Dismiss mobile controls button
    local dismissButton = Instance.new("TextButton")
    dismissButton.Size = UDim2.new(0, 140, 0, 40)
    dismissButton.Position = UDim2.new(0.85, -150, 0.8, -40)
    dismissButton.Text = "Dismiss Mobile Controls"
    dismissButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    dismissButton.TextColor3 = Color3.new(1, 1, 1)
    dismissButton.Parent = gui

    dismissButton.MouseButton1Click:Connect(function()
        for _, obj in pairs(gui:GetChildren()) do
            if obj:IsA("TextButton") and obj ~= dismissButton then
                obj:Destroy()
            end
        end
        _G.GregMobileMove = Vector3.zero
        dismissButton:Destroy()
    end)

    -- Make the whole GUI draggable
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

    uis.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                math.clamp(startPos.X.Scale, 0, 1),
                math.clamp(startPos.X.Offset + delta.X, 0, workspace.CurrentCamera.ViewportSize.X - frame.AbsoluteSize.X),
                math.clamp(startPos.Y.Scale, 0, 1),
                math.clamp(startPos.Y.Offset + delta.Y, 0, workspace.CurrentCamera.ViewportSize.Y - frame.AbsoluteSize.Y)
            )
        end
    end)
end

-- Reapply fly on respawn if flying
player.CharacterAdded:Connect(function(char)
    wait(1)
    if flying and player.Character then
        startFly(player.Character)
    end
end)

-- Toggle fly on E
uis.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.E then
        if flying then
            stopFly()
            flying = false
        else
            if player.Character then
                startFly(player.Character)
                announceFly(player)
                flying = true
            end
        end
    end
end)
