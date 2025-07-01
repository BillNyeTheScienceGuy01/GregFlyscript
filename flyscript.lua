-- GREG'S FIXED WORKING FLY SCRIPT FOR KRNL
-- TextBox-based user fly toggler: type username, and that player can fly
-- Now supports a list of usernames + mobile button

local player = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local ts = game:GetService("TeleportService")
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
local activeBodies = {}
local currentFlyList = {}

function startFly(char, username)
	local hrp = char:WaitForChild("HumanoidRootPart")
	if hrp:FindFirstChild("GregVelocity") then return end
	local bodyVel = Instance.new("BodyVelocity")
	bodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
	bodyVel.P = 1250
	bodyVel.Velocity = Vector3.zero
	bodyVel.Name = "GregVelocity"
	bodyVel.Parent = hrp
	activeBodies[username] = bodyVel

	rs:BindToRenderStep("GregFly_"..username, Enum.RenderPriority.Input.Value, function()
		if not bodyVel or not hrp then return end
		local cam = workspace.CurrentCamera
		local moveDir = Vector3.zero
		if uis:IsKeyDown(Enum.KeyCode.W) then moveDir += cam.CFrame.LookVector end
		if uis:IsKeyDown(Enum.KeyCode.S) then moveDir -= cam.CFrame.LookVector end
		if uis:IsKeyDown(Enum.KeyCode.A) then moveDir -= cam.CFrame.RightVector end
		if uis:IsKeyDown(Enum.KeyCode.D) then moveDir += cam.CFrame.RightVector end
		if uis:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) end
		if uis:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir -= Vector3.new(0, 1, 0) end
		if moveDir.Magnitude > 0 then
			bodyVel.Velocity = moveDir.Unit * speed
		else
			bodyVel.Velocity = Vector3.zero
		end
	end)
end

function stopFly(username)
	rs:UnbindFromRenderStep("GregFly_"..username)
	if activeBodies[username] then
		activeBodies[username]:Destroy()
		activeBodies[username] = nil
	end
end

-- Morph-to-player function (username based)
local function morphTo(username)
	local success, userId = pcall(function()
		return game.Players:GetUserIdFromNameAsync(username)
	end)
	if success and userId then
		local morphHumanoidDesc = game.Players:GetHumanoidDescriptionFromUserId(userId)
		if player.Character then
			player.Character:FindFirstChildOfClass("Humanoid"):ApplyDescription(morphHumanoidDesc)
			warn("[GREG MORPH] Morphed into " .. username)
		else
			warn("[GREG MORPH] Character not found")
		end
	else
		warn("[GREG MORPH] Failed to get user ID for " .. username)
	end
end

-- GUI in the center with textbox
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
local box = Instance.new("TextBox")
box.Size = UDim2.new(0, 300, 0, 40)
box.Position = UDim2.new(0.5, -150, 0.5, -20)
box.PlaceholderText = "Type usernames separated by commas"
box.Text = ""
box.TextScaled = true
box.BackgroundColor3 = Color3.fromRGB(30,30,30)
box.TextColor3 = Color3.fromRGB(255,255,255)
box.Font = Enum.Font.GothamSemibold
box.Parent = gui

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 100, 0, 40)
button.Position = UDim2.new(0.5, -50, 0.5, 30)
button.Text = "Activate Fly"
button.TextScaled = true
button.Font = Enum.Font.GothamBold
button.BackgroundColor3 = Color3.fromRGB(40,40,40)
button.TextColor3 = Color3.new(1,1,1)
button.Parent = gui

local function activateUsers(text)
	local input = text:split(",")
	currentFlyList = {}
	for _, username in pairs(input) do
		username = username:match("^%s*(.-)%s*$")
		table.insert(currentFlyList, username)
		local target = game.Players:FindFirstChild(username)
		if target and target.Character then
			startFly(target.Character, username)
			warn("[GREGFLY] "..username.." is now flying.")
		else
			warn("[GREGFLY] Player not found: "..username)
		end
	end
end

box.FocusLost:Connect(function(enter)
	if enter and box.Text ~= "" then
		activateUsers(box.Text)
	end
end)

button.MouseButton1Click:Connect(function()
	if box.Text ~= "" then
		activateUsers(box.Text)
	end
end)

-- Safety rebind on respawn
player.CharacterAdded:Connect(function(char)
	wait(1)
	for _, username in pairs(currentFlyList) do
		local target = game.Players:FindFirstChild(username)
		if target and target.Character then
			startFly(target.Character, username)
		end
	end
end)
