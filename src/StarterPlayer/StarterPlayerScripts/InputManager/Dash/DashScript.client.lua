local DashRF = script.Parent
local DashDebounces = {}
local DashDebouncesSide = {}
local DashDur = 0.5
local player = game.Players.LocalPlayer
local DashEvent = game.ReplicatedStorage.Events.DashEvent
local defaultSpeed = 33 

DashRF.OnInvoke = function(Dir)	
	
	
	if (Dir == "Front" or Dir == "Back") then
		if (DashDebounces[player]) then return end
		DashDebounces[player] = true
	elseif (Dir == "Left" or Dir == "Right") then
		if (DashDebouncesSide[player]) then return end
		DashDebouncesSide[player] = true
	end
	
	local player = game.Players.LocalPlayer
	local char = player.Character
	local animations = char:FindFirstChild("Animations")
	local animator : Animator = char:FindFirstChild("Humanoid"):FindFirstChild("Animator")
	
	if animator and animations then
		animator:LoadAnimation(animations:FindFirstChild(Dir)):Play()
	end
	
	
	
	player:FindFirstChild("PlayerDebounce").Value = true

	player.Character.Humanoid.WalkSpeed = 4
	--player.Character.Humanoid.JumpPower = 0

	local velo = Instance.new("BodyVelocity")
	velo.Parent = player.Character.HumanoidRootPart
	velo.MaxForce = Vector3.new(100000, 0, 100000)

	local DashStr = 100
	local MinStr = DashStr * 0.15
	local ItAmt = DashDur / 0.1
	local RemovalStr = DashStr / ItAmt

	for i = 0, DashDur, 0.1 do
		if (Dir == "Front") then
			velo.Velocity = player.Character.HumanoidRootPart.CFrame.LookVector * DashStr
		elseif (Dir == "Back") then
			velo.Velocity = player.Character.HumanoidRootPart.CFrame.LookVector * -DashStr
		elseif (Dir == "Left") then
			velo.Velocity = player.Character.HumanoidRootPart.CFrame.RightVector * -DashStr
		elseif (Dir == "Right") then
			velo.Velocity = player.Character.HumanoidRootPart.CFrame.RightVector * DashStr
		end

		if DashStr > MinStr then
			DashStr -= RemovalStr
			if DashStr < MinStr then
					DashStr = MinStr
				end
		end

		task.wait(0.05)
	end
	
	if (Dir == "Front") then
		DashEvent:FireServer(player)
	end

	velo:Destroy()
	player:FindFirstChild("PlayerDebounce").Value = false

	player.Character.Humanoid.WalkSpeed = defaultSpeed
	--player.Character.Humanoid.JumpPower = 50

	task.wait(3)

	if (DashDebounces[player] or DashDebouncesSide[player]) then
		DashDebounces[player] = nil
		DashDebouncesSide[player] = nil
	end
end