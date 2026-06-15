local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local head = character:WaitForChild("fakeHead")

local currentOffset = Vector3.zero

RunService.RenderStepped:Connect(function(dt) --smooth to offset relative to head in order to make the camera track the head
	local targetOffset =
		(rootPart.CFrame * CFrame.new(0, 1.5, 0)):PointToObjectSpace(head.Position)

	currentOffset = currentOffset:Lerp(targetOffset, math.clamp(dt * 15, 0, 1))

	humanoid.CameraOffset = currentOffset
end)