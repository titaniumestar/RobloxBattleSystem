local Players = game:GetService("Players")
local player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator")
local attackEvent = ReplicatedStorage:FindFirstChild("PlayerAttack")
local Animations = ReplicatedStorage.Animations
local rightArm = character:WaitForChild("Right Arm")
local Button = script.Parent

local animationTarck = animator:LoadAnimation(Animations.DownwardChop)
local animationIsPlaying = false

attackEvent.OnClientEvent:Connect(function()
	animationIsPlaying = false
end)

Button.Activated:Connect(function()
	if animationIsPlaying == true then return end
	local ItemName = ""

	for _, part in pairs(rightArm:GetChildren()) do
		if part:GetAttribute("IsItem") == true then
			ItemName = part.Name
			break
		end
	end

	if ItemName == "" then return end

	local speed = 1

	if ItemName == "IronSword" then
		animationTarck = animator:LoadAnimation(Animations:FindFirstChild("DownwardChop"))
		speed = 2
	elseif ItemName == "LongIronSword" then
		animationTarck = animator:LoadAnimation(Animations:FindFirstChild("LongDownwardChop"))
		speed = 1.25
	end
	
	animationTarck:Play(0.1,2,speed)
	animationIsPlaying = true

	attackEvent:FireServer()
end)
