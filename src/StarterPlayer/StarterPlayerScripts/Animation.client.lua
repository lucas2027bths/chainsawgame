local ReplicatedStorage = game:GetService("ReplicatedStorage")
local animationEvent = ReplicatedStorage.Events.PlayAnimation
local player = game.Players.LocalPlayer

local tracks = {}

local function handleAnimation(animationName : string, action : string)
	local character = player.Character
	if not character then return end

	local animator : Animator = character.Humanoid.Animator
	local animationFolder = character:FindFirstChild("Animations")
	if not animationFolder then return end

	if action == "Play" or action == nil then
		if not tracks[animationName] then
			local animation = animationFolder:FindFirstChild(animationName)
			if not animation then
				warn("Animation doesn't exist:", animationName)
				return
			end

			tracks[animationName] = animator:LoadAnimation(animation)
		end

		tracks[animationName]:Play()

	elseif action == "Stop" then
		if tracks[animationName] then
			tracks[animationName]:Stop()
		end
	end
end

animationEvent.OnClientEvent:Connect(handleAnimation)