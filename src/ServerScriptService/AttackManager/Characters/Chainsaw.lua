--Ideally this would be a OOP sort of object instead of procedural, but since we're only going to have one character it's not needed to convert it into a OOP module, and truman coded most of this already
local HB = game.ReplicatedStorage.Objs.CustomHB
local Beam = game.ReplicatedStorage.Objs.Beam
local Players= game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local StunEvent = game.ReplicatedStorage.Events.StunEvent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local animationEvent = ReplicatedStorage.Events.PlayAnimation
local vfxFolder = ReplicatedStorage.VFX
local chainGrabWindup = 0.383
local chainGrabHit = 0.1
--[[Send a request to a client to play a animation on character. Roblox replicates animations from client, playing on server causes weird issues]]
local function playAnimation(Player: Player, animation : string,action : string)
	animationEvent:FireClient(Player,animation,action)
end
local beamAnim = ReplicatedStorage.Animations.Beam
local beamByeAnim = ReplicatedStorage.Animations.beamBye
local Cooldowns = {}


Players.PlayerRemoving:Connect(function(player) --Make it so if a player leaves, their key from cooldown is removed
	if Cooldowns[player] then
		Cooldowns[player] = nil
	end
end)


local MinA1Speed = 0.2


--[[Set a cooldown for a player's ability]]
local function setCooldown(Player: Player, Ability : number, Value : boolean)
	if not Cooldowns[Player] then
		Cooldowns[Player] = {}
	end
	Cooldowns[Player][Ability] = Value
end

--[[Check if a player has a cooldown for that ability]]
local function checkCooldown(Player: Player, Ability : number)

	if (Cooldowns[Player]) then
		return Cooldowns[Player][Ability]
	end
	return false
end

local module = {}
module.DefaultSpeed = 33

function module.Attack1(player) 
	local button = player.PlayerGui.ScreenGui:WaitForChild("1")

	if (checkCooldown(player,1)) then return end

	player:FindFirstChild("PlayerDebounce").Value = true

	player.Character.Humanoid.WalkSpeed = 1
	--player.Character.Humanoid.JumpPower = 4

	button.UIGradient.Enabled = true --Not a good thing to change client UI on Server but truman already coded this 
	print(1)
	setCooldown(player,1,true)

	playAnimation(player,"chainGrab")

	task.wait(chainGrabWindup) --windup

	local hb = HB:Clone()
	hb.Parent = workspace
	hb.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -1)

	local sawAttatch = Instance.new("Attachment")
	local partAttatch = Instance.new("Attachment")
	sawAttatch.Parent = hb
	partAttatch.Parent = player.Character:FindFirstChild("Saw_int_R")

	local beam = vfxFolder.chain:Clone()

	beam.Parent = player.Character
	beam.Attachment0 = sawAttatch
	beam.Attachment1 = partAttatch	


	local Weld = Instance.new("WeldConstraint", hb)
	Weld.Part0 = nil
	Weld.Part1 = hb

	local HitGrab = false

	local function hit(thing)

		if thing.Parent == player.Character then return end

		if thing.Parent:FindFirstChild("Humanoid") then

			local blockval = thing.Parent:FindFirstChild("IsBlocking")

			if blockval then
				if blockval.Value == false then
					if not HitGrab then
						HitGrab = true
						Weld.Part0 = thing.Parent.HumanoidRootPart

						thing.Parent.Humanoid:TakeDamage(10)
						task.delay(0.8, function()
							thing.Parent.Humanoid:TakeDamage(10)
						end)
					end
				end
			else
				if not HitGrab then
					HitGrab = true
					Weld.Part0 = thing.Parent.HumanoidRootPart

					thing.Parent.Humanoid:TakeDamage(10)
					task.delay(0.8, function()
						thing.Parent.Humanoid:TakeDamage(10)
					end)
				end
			end
		end

	end

	hb.Touched:Connect(hit)

	local A1AtkSpeed = 2

	for i = 1, 20 do
		hb.CFrame = hb.CFrame * CFrame.new(0, 0, -A1AtkSpeed)

		A1AtkSpeed *= 0.95
		if A1AtkSpeed <= MinA1Speed then
			A1AtkSpeed = MinA1Speed
		end

		task.wait()
	end
	task.wait(chainGrabHit)
	for i = 1, 20 do
		hb.CFrame = hb.CFrame * CFrame.new(0, 0, A1AtkSpeed)

		A1AtkSpeed /= 0.95
		if A1AtkSpeed >= 2 then
			A1AtkSpeed = 2
		end

		task.wait()
	end	

	Weld:Destroy()
	hb:Destroy()
	beam:Destroy()
	sawAttatch:Destroy()
	partAttatch:Destroy()

	local isStunned = player:FindFirstChild("IsStunned")
	if isStunned.Value == false then
		player:FindFirstChild("PlayerDebounce").Value = false
		player.Character.Humanoid.WalkSpeed = module.DefaultSpeed
		--player.Character.Humanoid.JumpPower = 50
	end

	task.delay(3, function()
		setCooldown(player,1,false)
		button.UIGradient.Enabled = false
	end)
end

function module.Attack2(player) 

	local button = player.PlayerGui.ScreenGui:WaitForChild("2")

	if (checkCooldown(player,2)) then return end

	local DashDur = 1

	button.UIGradient.Enabled = true

	print(2)

	setCooldown(player,2,true)

	playAnimation(player,"rapidSlash")

	local hb = HB:Clone()
	hb.Parent = workspace
	hb.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
	hb.Anchored = false

	local Weld = Instance.new("WeldConstraint")
	Weld.Parent = hb
	Weld.Part0 = nil
	Weld.Part1 = hb

	local HitGrab = false
	local HitPlr = nil
	local function hit(thing)
		if thing.Parent == player.Character then return end

		if thing.Parent:FindFirstChild("Humanoid") then

			local blockval = thing.Parent:FindFirstChild("IsBlocking")

			if blockval then
				if blockval.Value == false then
					if not HitGrab then
						HitGrab = true
						HitPlr = thing.Parent.Humanoid
						thing.Parent.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
						Weld.Part0 = thing.Parent.HumanoidRootPart
						if thing.Parent:FindFirstChild("Humanoid").Health <= 10 then
							Weld:Destroy()
						end
						thing.Parent.Humanoid:TakeDamage(10)
					end
				end
			else
				if not HitGrab then
					HitGrab = true
					HitPlr = thing.Parent.Humanoid
					thing.Parent.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
					Weld.Part0 = thing.Parent.HumanoidRootPart
					if thing.Parent:FindFirstChild("Humanoid").Health <= 10 then
						Weld:Destroy()
					end
					thing.Parent.Humanoid:TakeDamage(10)
				end
			end
		end
	end

	hb.Touched:Connect(hit)

	local weld = Instance.new("WeldConstraint")
	weld.Parent = hb
	weld.Part0 = player.Character.HumanoidRootPart
	weld.Part1 = hb

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
		velo.Velocity = player.Character.HumanoidRootPart.CFrame.LookVector * DashStr

		if DashStr > MinStr then
			DashStr -= RemovalStr
			if DashStr < MinStr then
				DashStr = MinStr
			end
		end

		task.wait(0.05)
	end

	if HitGrab then
		local velo2 = Instance.new("BodyVelocity")
		velo2.Parent = player.Character.HumanoidRootPart
		velo2.MaxForce = Vector3.new(100000, 0, 100000)

		local DashDur2 = 3
		local DashStr2 = 50
		local MinStr2 = DashStr2 * 0.15
		local ItAmt2 = DashDur2 / 0.1
		local RemovalStr2 = DashStr2 / ItAmt2

		for i = 0, DashDur2, 0.1 do
			velo.Velocity = player.Character.HumanoidRootPart.CFrame.LookVector * DashStr2

			if DashStr2 > MinStr2 then
				DashStr2 -= RemovalStr2
				if DashStr2 < MinStr2 then
					DashStr2 = MinStr2
				end
			end

			if i % 0.3 == 0 then
				if HitPlr then
					if HitPlr.Health > 10 then
						HitPlr:TakeDamage(5)
					else
						weld:Destroy()
						Weld:Destroy()
						HitPlr:TakeDamage(10)
					end
				end
			end

			task.wait(0.05)
		end
		velo2:Destroy()
	end

	velo:Destroy()
	hb:Destroy()
	weld:Destroy()
	Weld:Destroy()
	playAnimation(player,"rapidSlash","Stop")
	local isStunned = player:FindFirstChild("IsStunned")
	if isStunned.Value == false then
		player:FindFirstChild("PlayerDebounce").Value = false
		player.Character.Humanoid.WalkSpeed = module.DefaultSpeed
		--player.Character.Humanoid.JumpPower = 50
	end

	task.delay(3, function()
		setCooldown(player,2,false)
		button.UIGradient.Enabled = false
	end)
end

function module.Attack3(player)

	local button = player.PlayerGui.ScreenGui:WaitForChild("3")

	if checkCooldown(player,3) then return end

	button.UIGradient.Enabled = true

	print(3)

	setCooldown(player,3,true)

	playAnimation(player,"gutRip")
	player.PlayerDebounce.Value = true
	player.Character.Humanoid.WalkSpeed = 0
	--player.Character.Humanoid.JumpPower = 0

	task.wait(0.2)

	local hb = HB:Clone()
	hb.CFrame = player.Character.HumanoidRootPart.CFrame
	hb.Parent = workspace

	local HitGrab = false
	local Victim = nil
	local FollowConnection = nil

	local function Hit(hit)
		if hit.Parent == player.Character then
			return
		end

		if HitGrab then
			return
		end

		local enemyCharacter = hit.Parent
		local enemyHumanoid = enemyCharacter:FindFirstChild("Humanoid")
		local enemyHRP = enemyCharacter:FindFirstChild("HumanoidRootPart")

		if not enemyHumanoid or not enemyHRP then
			return
		end

		HitGrab = true
		Victim = enemyCharacter

		enemyHRP:SetNetworkOwner(nil)

		for _, v in Victim:GetDescendants() do
			if v:IsA("BasePart") then
				v.CanCollide = false
			end
		end

		FollowConnection = game:GetService("RunService").PreSimulation:Connect(function() --Physics are weird so just every frame set the enemy player's cframe to the saw head cframe. better way to do this? maybe but its like 11 pm i gotta finish this
			if not Victim
				or not Victim.Parent
				or enemyHumanoid.Health <= 0
				or not player.Character
			then
				return
			end

			local sawHead = player.Character:FindFirstChild("Saw_int_head")

			if sawHead then
				enemyHRP.CFrame = sawHead.CFrame * CFrame.new(0,0,-1)
			end
		end)

		enemyHumanoid:TakeDamage(20)
	end

	hb.Touched:Connect(Hit)

	for i = 1,20 do
		hb.CFrame *= CFrame.new(0,0,-1)
		task.wait()
	end

	hb:Destroy()

	task.delay(0.9,function()

		if FollowConnection then
			FollowConnection:Disconnect()
		end

		if Victim and Victim.Parent then
			for _, v in Victim:GetDescendants() do
				if v:IsA("BasePart") then
					v.CanCollide = true
				end
			end
		end

		local isStunned = player:FindFirstChild("IsStunned")
		if not isStunned.Value then
			player.PlayerDebounce.Value = false
			player.Character.Humanoid.WalkSpeed = module.DefaultSpeed
			--player.Character.Humanoid.JumpPower = 50
		end
	end)

	task.delay(3,function()
		setCooldown(player,3,false)
		button.UIGradient.Enabled = false
	end)

end

function module.Attack4(player) 

	local button = player.PlayerGui.ScreenGui:WaitForChild("4")

	if (checkCooldown(player,4)) then return end

	player:FindFirstChild("PlayerDebounce").Value = true

	button.UIGradient.Enabled = true

	print(4)

	setCooldown(player,4,true)


	-----------------------------------------------------------

	local beam = Beam:Clone()
	beam.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, -5, 0)
	beam.Parent = workspace
	beam.Anchored = true

	local Weld = Instance.new("WeldConstraint")
	Weld.Part0 = player.Character.HumanoidRootPart
	Weld.Part1 = beam
	Weld.Parent = player.Character.HumanoidRootPart

	local hb = HB:Clone()
	hb.CFrame = beam.CFrame * CFrame.new(0, 0, -5)
	hb.Parent = workspace
	hb.Anchored = false

	local Weld2 = Instance.new("WeldConstraint")
	Weld2.Part0 = player.Character.HumanoidRootPart
	Weld2.Part1 = hb
	Weld2.Parent = hb

	local tweenInfo = TweenInfo.new(
		0.2, -- Time (seconds)
		Enum.EasingStyle.Linear, -- Easing style
		Enum.EasingDirection.In -- Easing direction
	)
	local tweenInfo2 = TweenInfo.new(
		0.3, -- Time (seconds)
		Enum.EasingStyle.Linear, -- Easing style
		Enum.EasingDirection.Out -- Easing direction
	)

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = beam.Beam.mouth
	weld.Part1 = nil
	weld.Parent = beam.Beam.mouth
	
	local beamTrack = beam.Beam.AnimationController:LoadAnimation(beamAnim)
	beamTrack:Play()
	local HitGrab = false
	local Victim = nil

	local function Hit(hit)

		if hit.Parent == player.Character then return end

		if hit.Parent:FindFirstChild("Humanoid") and hit.Parent:FindFirstChild("HumanoidRootPart") then
			if hit.Parent.Humanoid.Health <= 0 then return end
			if not HitGrab then
				HitGrab = true
				hit.Parent.HumanoidRootPart.CFrame = beam.Beam.mouth.CFrame
				Victim = hit.Parent
				if hit.Parent.Humanoid.Health <= 10 then
					Weld:Destroy()
					weld:Destroy()
					beam:Destroy()
				end
				hit.Parent.Humanoid:TakeDamage(10)
				weld.Part1 = hit.Parent.HumanoidRootPart
			end
		end
	end

	hb.Touched:Connect(Hit)

	local tween = game:GetService("TweenService"):Create(beam, tweenInfo, {CFrame = beam.CFrame * CFrame.new(0, 5, -15)})
	tween:Play()
	task.wait(0.2)
	local tween2 = game:GetService("TweenService"):Create(beam, tweenInfo, {CFrame = beam.CFrame * CFrame.new(0, -5, -15)})
	tween2:Play()
	task.wait(0.2)
	if Victim then
		if Victim.Humanoid.Health <= 10 then
			Weld:Destroy()
			weld:Destroy()
			beam:Destroy()
		end
		Victim.Humanoid:TakeDamage(10)
	end

	if HitGrab then
		for i = 1, 3 do
			local tween = game:GetService("TweenService"):Create(beam, tweenInfo, {CFrame = beam.CFrame * CFrame.new(0, 5, -15)})
			tween:Play()
			task.wait(0.2)
			local tween2 = game:GetService("TweenService"):Create(beam, tweenInfo, {CFrame = beam.CFrame * CFrame.new(0, -5, -15)})
			tween2:Play()
			task.wait(0.2)
			if Victim then
				if Victim.Humanoid.Health <= 10 then
					Weld:Destroy()
					weld:Destroy()
					
					if beam:FindFirstChild("Beam") then
						beam.Beam.AnimationController:LoadAnimation(beamByeAnim):Play()
					end

					task.delay(0.5,function()
						if beam then
							beam:Destroy()
						end
					end)
				end
				Victim.Humanoid:TakeDamage(10)
			end
		end
	end

	Weld:Destroy()
	hb:Destroy()
	weld:Destroy()
	
	beamTrack:Stop()
	
	
	if beam:FindFirstChild("Beam") then
		beam.Beam.AnimationController:LoadAnimation(beamByeAnim):Play()
	end
	
	task.delay(0.5,function()
		if beam then
			beam:Destroy()
		end
	end)
	
	

	local isStunned = player:FindFirstChild("IsStunned")
	if isStunned.Value == false then
		player:FindFirstChild("PlayerDebounce").Value = false
		player.Character.Humanoid.WalkSpeed = module.DefaultSpeed
		--player.Character.Humanoid.JumpPower = 50
	end


	task.delay(3, function()
		setCooldown(player,4,false)
		button.UIGradient.Enabled = false
	end)

end

return module
