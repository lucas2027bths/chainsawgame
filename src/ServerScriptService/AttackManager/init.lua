local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local animationEvent = ReplicatedStorage.Events.PlayAnimation
--[[Send a request to a client to play a animation on character. Roblox replicates animations from client, playing on server causes weird issues]]
local function playAnimation(Player: Player, Animation : string)
	animationEvent:FireClient(Player,Animation)
end

local StunEvent = game.ReplicatedStorage.Events.StunEvent


local HitboxClass = require(ReplicatedStorage.Modules.HitboxClass) --Used open source hitbox module, was going to use for the abilities as well but Truman coded it without it, so probably won't integrate it into the abilities since they're basiaclly done
local HitboxTypes = require(ReplicatedStorage.Modules.HitboxClass.Types)




local AttackController = {}
AttackController.__index = AttackController

local HITBOX_PARAMS = {
	SizeOrPart = 3,
	DebounceTime = 100,
	UseClient = nil,
} :: HitboxTypes.HitboxParams

local HITBOX_OFFSET = CFrame.new(0, 0, -2)
local dashTime = 0.2

local lastAttack = os.clock()

function AttackController.new(player: Player)
	local self = setmetatable({}, AttackController) --metatables are weird but basiaclly just a way to implement OOP

	self.Player = player
	self.M1Debounce = false
	self.CanM1 = true
	self.CurrentM1 = false
	self.Dashing = false
	return self
end

function AttackController:CreateHitbox(hrp: BasePart, duration: number, player : Player)
	
	local params = table.clone(HITBOX_PARAMS)
	params.UseClient = self.Player
	
	local hitbox = HitboxClass.new(HITBOX_PARAMS)

	hitbox:Start()
	hitbox:WeldTo(hrp, HITBOX_OFFSET)
	
	hitbox.HitSomeone:Connect(function(hitChars)
		print("Hit:", hitChars)
		
		for i, hitModel : Model in pairs(hitChars) do
			
			if Players:GetPlayerFromCharacter(hitModel) == player then
				continue
			end
			
			if not hitModel:FindFirstChild("Humanoid") then
				continue
			end
			
			local Debounces = hitModel:FindFirstChild("PlayerDebounce")
			local Blocking = hitModel:FindFirstChild("IsBlocking")
			
			if Blocking then
				if Blocking.Value == false then
					if Debounces then
						Debounces.Value = true

						task.delay(1, function()
							Debounces.Value = false
						end)
					end
					hitModel.Humanoid:TakeDamage(5)
				end
			else 
				if Debounces then
					Debounces.Value = true

					task.delay(1, function()
						Debounces.Value = false
					end)
				end
				hitModel.Humanoid:TakeDamage(5)
			end
		end
	end)

	task.delay(duration, function()
		if hitbox then
			hitbox:Destroy()
		end
	end)

	return hitbox
end

function AttackController:M1(defaultSpeed : number)
	if not self.CanM1 or self.M1Debounce then
		return
	end

	local player = self.Player
	local character = player.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")
	local hrp = character:FindFirstChild("HumanoidRootPart")
	
	if not humanoid or not hrp then
		warn(character.Name .. " is missing Humanoid or HumanoidRootPart")
		return
	end

	local combo = player:FindFirstChild("Combo")

	if not combo then
		warn("Combo value missing")
		return
	end
	
	

	self.M1Debounce = true
	self.CurrentM1 = true

	if os.clock() > lastAttack + 3 then
		combo.Value = 0
	end
	lastAttack = os.clock()
	
	combo.Value += 1
	print(combo.Value)

	humanoid.WalkSpeed = 8
	
	
	if combo.Value == 1 then
		playAnimation(player,"attack1")
	elseif combo.Value == 2 then
		playAnimation(player,"attack2")
	elseif combo.Value == 3 then
		playAnimation(player,"attack1")
	elseif combo.Value == 4 then
		playAnimation(player,"attack3")
	end
	
	task.delay(0.1,function()
		local hitbox = self:CreateHitbox(hrp, 0.2,player)
		if self.Dashing and hitbox then
			hitbox:Destroy()
		end
	end)


	task.delay(0.2, function()
		self.CurrentM1 = false
	end)

	if combo.Value > 3 then
		combo.Value = 0

		task.delay(1, function()
			self.M1Debounce = false
			humanoid.WalkSpeed = defaultSpeed
		end)
	else
		task.delay(0.2, function()
			self.M1Debounce = false
			humanoid.WalkSpeed = defaultSpeed
		end)
	end
end

local function dashEnd(self)
	self.CanM1 = true
	self.Dashing = false
end

function AttackController:Block(player)
	print("Blocking...")
	
	local blockval = player:FindFirstChild("IsBlocking")
	blockval.Value = true
	
	local PlayerDenounce = player:FindFirstChild("PlayerDebounce")
	PlayerDenounce.Value = true
end

function AttackController:BlockEnd(player)
	print("BlockEnded")

	local blockval = player:FindFirstChild("IsBlocking")
	blockval.Value = false
	
	local PlayerDenounce = player:FindFirstChild("PlayerDebounce")
	PlayerDenounce.Value = false
end

function AttackController:Dash()
	self.Dashing = true

	if self.CurrentM1 then
		task.delay(dashTime, function()
			dashEnd(self)
		end)
		return
	end

	self.CanM1 = false

	local player = self.Player
	local character = player.Character

	if not character then
		task.delay(dashTime, function()
			dashEnd(self)
		end)
		return
	end

	local hrp = character:FindFirstChild("HumanoidRootPart")

	if not hrp then
		task.delay(dashTime, function()
			dashEnd(self)
		end)
		return
	end

	self:CreateHitbox(hrp, dashTime,player)
	playAnimation(player,"attack2")
	
	
	task.delay(dashTime, function()
		dashEnd(self)
	end)
	
end

return AttackController