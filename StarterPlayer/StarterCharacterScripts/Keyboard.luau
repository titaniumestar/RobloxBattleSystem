local Players = game:GetService("Players")
local player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator")
local attackEvent = ReplicatedStorage:FindFirstChild("PlayerAttack")
local Animations = ReplicatedStorage.Animations
local rightArm = character:WaitForChild("Right Arm")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local attackEvent = ReplicatedStorage:WaitForChild("PlayerAttack")
local pickUpEvent = ReplicatedStorage:WaitForChild("PlayerPickUp")

local animationTarck = animator:LoadAnimation(Animations.DownwardChop)
local animationIsPlaying = false

local pickingUp = false

attackEvent.OnClientEvent:Connect(function()
	animationIsPlaying = false
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed == true then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.J then
		if animationIsPlaying == true then return end
		
		attackEvent:FireServer()

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
			speed = 1.4
		end

		animationTarck:Play(0.1,2,speed)
		animationIsPlaying = true
	elseif input.KeyCode == Enum.KeyCode.F then
		if pickingUp == true then return end
		pickingUp = true

		local overlapParams = OverlapParams.new()
		overlapParams.FilterType = Enum.RaycastFilterType.Exclude
		overlapParams.FilterDescendantsInstances = {character}

		local parts = Workspace:GetPartBoundsInRadius(humanoidRootPart.Position,9,overlapParams)
		
		local item = nil
		
		for _, part in ipairs(parts) do
			local gotParent = part.Parent
			if gotParent:GetAttribute("IsItem") == true and gotParent.Parent.Name ~= "Right Arm" then
				item = gotParent
				break
			end
		end
		
		if not item then
			pickingUp = false
			return
		end
		
		local result = pickUpEvent:InvokeServer(item)
		
		if result == true then
			pickingUp = false
		end
	end
end)