-- GREG'S ULTIMATE FLY SCRIPT FOR KRNL
-- Persistent UI, solid noclip, mobile controls rebuild, fly toggle, anti-kick, Adonis admin loader, Forsaken Plead sound

local player = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldNamecall = mt.__namecall

-- Anti-Kick Hook
mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if method == "Kick" or tostring(self) == "Kick" then
        warn("[GREG ANTI-KICK] Blocked kick attempt!")
        return nil
    end
    return oldNamecall(self, unpack(args))
end)

-- Adonis Admin Loader
pcall(function()
    loadstring(game:HttpGet("https://www.roblox.com/asset/?id=7510622625"))()
end)

local speed = 50
local flying = false
local activeFly = nil
local noclip = false
local gui, box

-- Noclip apply function, runs every frame when noclip is ON to prevent Roblox re-enabling collisions
local function noclipLoop()
    rs:BindToRenderStep("GregNoclip", Enum.RenderPriority.Character.Value, function()
        if not noclip then
            rs:UnbindFromRenderStep("GregNoclip")
            return
        end
        local char = player.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function setNoclip(state)
    noclip = state
    if noclip then
        noclipLoop()
    else
        rs:UnbindFromRenderStep("GregNoclip")
        local char = player.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
    if box then
        box.Text = string.format("[GREG FLY ENABLED]\n• Press E to toggle Fly (PC)\n• Press N to toggle Noclip (%s)\n• Use Joystick (Mobile)\n• You are UNKICKABLE :)", noclip and "ON" or "OFF")
    end
end

local function toggleNoclip()
    setNoclip(not noclip)
end

-- Sound + Particle Feedback
local function announceFly()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local sfx = Instance.new("Sound")
    sfx.SoundId = "rbxassetid://136274352281439" -- Forsaken Plead
    sfx.Volume = 5
    sfx.PlayOnRemove = true
    sfx.Parent = hrp
    sfx:Destroy()

    local particle = Instance.new("ParticleEmitter")
    particle.Texture = "rbxassetid://301055640"
    particle.Rate = 200
    particle.Lifetime = NumberRange.new(0.5)
    particle.Speed = NumberRange.new(10)
    particle.Parent = hrp
    game.Debris:AddItem(particle, 1)
end

-- Fly logic
local function startFly()
    if flying or not player.Character then return end
    flying = true
    local hrp = player.Character:WaitForChild("HumanoidRootPart")
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.P = 1250
    bv.Velocity = Vector3.zero
    bv.Name = "GregVelocity"
    bv.Parent = hrp
    activeFly = bv

    announceFly()

    rs:BindToRenderStep("GregFly", Enum.RenderPriority.Input.Value, function()
        local cam = workspace.CurrentCamera
        local dir = Vector3.zero

        if uis:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
        if uis:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
        if uis:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
        if uis:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
        if uis:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
        if uis:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0,1,0) end
        if _G.GregMobileMove then dir += _G.GregMobileMove end

        activeFly.Velocity = dir.Magnitude > 0 and dir.Unit * speed or Vector3.zero
    end)
end

local function stopFly()
    flying = false
    rs:UnbindFromRenderStep("GregFly")
    if activeFly then
        activeFly:Destroy()
        activeFly = nil
    end
end

-- GUI & Mobile joystick
local mobileBtns = {}

local function buildMobileControls()
    -- Destroy any existing mobile buttons
    for _, b in ipairs(mobileBtns) do
        b:Destroy()
    end
    mobileBtns = {}

    if not uis.TouchEnabled then return end

    local dirs = {
        {Key = "↑", Vec = Vector3.new(0,1,0), Pos = UDim2.new(0.85, -30, 0.5, -80)},
        {Key = "↓", Vec = Vector3.new(0,-1,0), Pos = UDim2.new(0.85, -30, 0.5, 40)},
        {Key = "←", Vec = Vector3.new(-1,0,0), Pos = UDim2.new(0.85, -80, 0.5, -20)},
        {Key = "→", Vec = Vector3.new(1,0,0), Pos = UDim2.new(0.85, 20, 0.5, -20)}
    }

    _G.GregMobileMove = Vector3.zero

    for _, dir in pairs(dirs) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0,40,0,40)
        b.Position = dir.Pos
        b.Text = dir.Key
        b.BackgroundColor3 = Color3.fromRGB(40,40,40)
        b.TextColor3 = Color3.new(1,1,1)
        b.Parent = gui
        table.insert(mobileBtns, b)

        b.MouseButton1Down:Connect(function()
            _G.GregMobileMove += dir.Vec
        end)
        b.MouseButton1Up:Connect(function()
            _G.GregMobileMove -= dir.Vec
        end)
    end

    local dismiss = Instance.new("TextButton")
    dismiss.Size = UDim2.new(0, 140, 0, 40)
    dismiss.Position = UDim2.new(0.85, -70, 0.8, -40)
    dismiss.Text = "Dismiss Mobile"
    dismiss.BackgroundColor3 = Color3.fromRGB(255,0,0)
    dismiss.TextColor3 = Color3.new(1,1,1)
    dismiss.Parent = gui

    dismiss.MouseButton1Click:Connect(function()
        _G.GregMobileMove = Vector3.zero
        for _, b in ipairs(mobileBtns) do b:Destroy() end
        dismiss:Destroy()

        local reactivate = Instance.new("TextButton")
        reactivate.Size = UDim2.new(0, 160, 0, 40)
        reactivate.Position = UDim2.new(0.85, -80, 0.8, 10)
        reactivate.Text = "Reactivate Mobile"
        reactivate.BackgroundColor3 = Color3.fromRGB(0,150,255)
        reactivate.TextColor3 = Color3.new(1,1,1)
        reactivate.Parent = gui

        reactivate.MouseButton1Click:Connect(function()
            buildMobileControls()
            reactivate:Destroy()
        end)
    end)
end

local function createGUI()
    if gui then gui:Destroy() end
    gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))

    box = Instance.new("TextLabel")
    box.Size = UDim2.new(0, 360, 0, 80)
    box.Position = UDim2.new(0.5, -180, 0.05, 0)
    box.Text = string.format("[GREG FLY ENABLED]\n• Press E to toggle Fly (PC)\n• Press N to toggle Noclip (%s)\n• Use Joystick (Mobile)\n• You are UNKICKABLE :)", noclip and "ON" or "OFF")
    box.TextColor3 = Color3.new(1, 1, 1)
    box.TextScaled = true
    box.BackgroundColor3 = Color3.fromRGB(30,30,30)
    box.Font = Enum.Font.GothamBold
    box.Parent = gui

    if uis.TouchEnabled then
        buildMobileControls()
    end
end

-- Keybinds for fly and noclip
uis.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.E then
        if flying then stopFly() else startFly() end
    elseif input.KeyCode == Enum.KeyCode.N then
        toggleNoclip()
    end
end)

-- Reapply fly, noclip, and GUI on respawn
player.CharacterAdded:Connect(function()
    wait(1)
    createGUI()
    if flying then startFly() end
    if noclip then setNoclip(true) end
end)

-- Initial GUI build
createGUI()
