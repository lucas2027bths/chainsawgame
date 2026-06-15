local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local UserInputService = game:GetService("UserInputService")

local M1Event = game.ReplicatedStorage.Events.M1Event
local DashRF = script:WaitForChild("Dash")
local StunEvent = game.ReplicatedStorage.Events.StunEvent

local AbilityEvent = game.ReplicatedStorage.Events.AbilityEvent
local BlockEvent = game.ReplicatedStorage.Events.BlockEvent
local BlockEndEvent = game.ReplicatedStorage.Events.BlockEndEvent

local blockTrackvar: AnimationTrack? = nil
local defaultSpeed = 33

local function setupCharacter(character)
	Character = character

	local humanoid = character:WaitForChild("Humanoid")
	local animator = humanoid:WaitForChild("Animator")

	local animations = character:WaitForChild("Animations")
	local blockAnim = animations:WaitForChild("block")

	blockTrackvar = animator:LoadAnimation(blockAnim)
end

setupCharacter(Character)

Player.CharacterAdded:Connect(function(character)
	setupCharacter(character)
end)

StunEvent.OnClientEvent:Connect(function()
	local character = Player.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then
		return
	end

	humanoid.WalkSpeed = 0
	--humanoid.JumpPower = 0

	Player.PlayerDebounce.Value = true
	Player.IsStunned.Value = true

	print("Stunned")

	task.delay(1, function()
		local newCharacter = Player.Character
		if not newCharacter then
			return
		end

		local newHumanoid = newCharacter:FindFirstChild("Humanoid")
		if not newHumanoid then
			return
		end

		Player.PlayerDebounce.Value = false
		Player.IsStunned.Value = false

		if not UserInputService:IsKeyDown(Enum.KeyCode.F) then
			newHumanoid.WalkSpeed = defaultSpeed
		end

		--newHumanoid.JumpPower = 50

		print("UnStunned")
	end)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if gameProcessedEvent then
		return
	end

	if Player.PlayerDebounce.Value or Player.IsStunned.Value then
		return
	end

	if input.KeyCode == Enum.KeyCode.Q then
		local dir = "Front"

		if UserInputService:IsKeyDown(Enum.KeyCode.A) then
			dir = "Left"
		elseif UserInputService:IsKeyDown(Enum.KeyCode.D) then
			dir = "Right"
		elseif UserInputService:IsKeyDown(Enum.KeyCode.S) then
			dir = "Back"
		end

		DashRF:Invoke(dir)
	end

	if input.KeyCode == Enum.KeyCode.F then
		if blockTrackvar and not blockTrackvar.IsPlaying then
			blockTrackvar:Play()
			local blockAnimLength = blockTrackvar.Length * 0.98
			task.spawn(function()
				local currentTrack = blockTrackvar
			
				task.wait(blockAnimLength)
				
				if currentTrack.TimePosition >= blockAnimLength then
					currentTrack:AdjustSpeed(0)
				end
			end)
		end

		BlockEvent:FireServer()

		local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = 0
		end
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		M1Event:FireServer()
	end

	if input.KeyCode.Value >= 49 and input.KeyCode.Value <= 52 then
		-- Sends 1,2,3,4
		AbilityEvent:FireServer(input.KeyCode.Value - 48)
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
	if gameProcessedEvent then
		return
	end

	if input.KeyCode == Enum.KeyCode.F then
		
		if blockTrackvar then
			blockTrackvar:Stop(0.1)
		end

		BlockEndEvent:FireServer()

		local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
		if humanoid and not Player.IsStunned.Value then
			humanoid.WalkSpeed = defaultSpeed
		end
	end
end)