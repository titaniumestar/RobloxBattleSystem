local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local PlayerAttack = ReplicatedStorage:WaitForChild("PlayerAttack")
local attackingPlayers = {}

local function findChildren(children,parents)
	local result = {}
	local success = true
	for count, child in ipairs(children) do
		local child = parents[count]:FindFirstChild(children[count])
		if not child then
			success = false
			break
		else
			table.insert(result,child)
		end
	end
	return result,success
end

local function recursiveFindChildren(children,parent,count,result,success)
	local child = parent:FindFirstChild(children[count])
	
	if not child then
		success = false
	else
		table.insert(result,child)
	end
	
	count += 1
	
	if count <= #children then
		result,success = recursiveFindChildren(children,child,count,result,success)
	end
	
	return result,success
end

local function hit(humanoidRootPart,size,overlapParams,hitTargets,character,damage)
	
	local boxCFrame = humanoidRootPart.CFrame * CFrame.new(0,0,-size.Z/2)

	local parts = Workspace:GetPartBoundsInBox(boxCFrame,size,overlapParams)
	
	for _, part in ipairs(parts) do
		local gotParent = part.Parent
		if not gotParent or hitTargets[gotParent] then continue end
		hitTargets[gotParent] = true
		local humanoid = gotParent:FindFirstChild("Humanoid")
		if humanoid and gotParent ~= character and humanoid.Health > 0 then
			humanoid.Health -= damage
		end
	end
	
	local debugPart = Instance.new("Part")
	debugPart.Size = size
	debugPart.CFrame = boxCFrame
	debugPart.Transparency = 0.9
	debugPart.Color = Color3.new(1, 0, 0)
	debugPart.Anchored = true
	debugPart.CanCollide = false
	debugPart.Material = Enum.Material.Neon
	debugPart.Parent = Workspace
	game.Debris:AddItem(debugPart, 0.25)
end

local function PlayerAttacked(player,character,item,attributes,humanoidRootPart)
	local gotChildren,success = findChildren({"Size","Damage","Interval","DurationMultiplier"},{attributes,attributes,attributes,attributes})
	if not success then
		return
	end
	
	local size = gotChildren[1].Value
	local damage = gotChildren[2].Value
	local interval = gotChildren[3].Value
	local durationMultiplier = gotChildren[4].Value

	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	overlapParams.FilterDescendantsInstances = {item}
	
	task.wait(interval/2)

	local hitTargets = {}

	for i = 1,(interval*durationMultiplier) do
		hit(humanoidRootPart,size,overlapParams,hitTargets,character,damage)
		task.wait(0.1)
	end
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		attackingPlayers[player] = false
	end)
end)

PlayerAttack.OnServerEvent:Connect(function(player)
	if attackingPlayers[player] == true then return end
	attackingPlayers[player] = true
	
	local character = player.Character
	if not character then
		attackingPlayers[player] = false
		return true
	end
	
	local gotChildren,success = findChildren({"Right Arm"},{character})
	if not success then
		attackingPlayers[player] = false
		return true
	end
	
	local rightArm = gotChildren[1]
	
	local item = nil
	for _, part in pairs(rightArm:GetChildren()) do
		if part:GetAttribute("IsItem") == true then
			item = part
			break
		end
	end
	if not item then
		attackingPlayers[player] = false
		return true
	end
	
	local children,parent,count,gotChildren,success = {"Attributes","Interval"},item,1,{},true
	
	gotChildren,success = recursiveFindChildren(children,parent,count,gotChildren,success)
	if not success then
		attackingPlayers[player] = false
		return true
	end
	
	local attributes = gotChildren[1]
	
	character = player.Character
	if not character then
		attackingPlayers[player] = false
		return true
	end
	
	local gotChildren,success = findChildren({"Right Arm","HumanoidRootPart"},{character,character})
	if not success then
		attackingPlayers[player] = false
		return true
	end
	
	rightArm = gotChildren[1]
	local humanoidRootPart = gotChildren[2]
	
	local hasItem = false
	
	for _, child in pairs(rightArm:GetChildren()) do
		if child == item then
			hasItem = true
			break
		end
	end
	
	if hasItem == false then
		attackingPlayers[player] = false
		return true
	end
	
	PlayerAttacked(player,character,item,attributes,humanoidRootPart)
	attackingPlayers[player] = false
	PlayerAttack:FireClient(player)
end)