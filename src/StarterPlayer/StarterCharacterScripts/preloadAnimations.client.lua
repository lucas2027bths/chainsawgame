
--Preload all animations beforehand
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local animationFolder = script.Parent:WaitForChild("Animations") 

local animationsToPreload = {}
for _, instance in ipairs(animationFolder:GetDescendants()) do
	if instance:IsA("Animation") then
		table.insert(animationsToPreload, instance)
	end
end

if #animationsToPreload > 0 then
	ContentProvider:PreloadAsync(animationsToPreload)
end
