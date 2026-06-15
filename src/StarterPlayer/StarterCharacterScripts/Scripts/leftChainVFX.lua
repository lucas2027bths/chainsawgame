local RunService = game:GetService("RunService")

local chain = script.Parent.Parent.LeftLinks
local links = chain:GetChildren()
local sawChildren =script.Parent.Parent.Saw_int_L:GetChildren()
local attachments = {}

for _, v in ipairs(sawChildren) do
	if v:IsA("Attachment") and v.Name ~= "AttatchL" then
		table.insert(attachments, v)
	end
end

table.sort(attachments, function(a, b)
	local numA = tonumber(string.match(a.Name, "%d+"))
	local numB = tonumber(string.match(b.Name, "%d+"))
	return numA < numB
end)

local chainSpeed = 40 
local position = 0

RunService.Heartbeat:Connect(function(dt)
	position += chainSpeed * dt

	for i, link in ipairs(links) do

		local pos = position + (i - 1)

		local index1 = math.floor(pos) % #attachments + 1
		local index2 = index1 % #attachments + 1

		local alpha = pos % 1

		link.CFrame = attachments[index1].WorldCFrame:Lerp(
			attachments[index2].WorldCFrame,
			alpha
		)
	end
end)
