local M1Event = game.ReplicatedStorage.Events.M1Event
local DashEvent = game.ReplicatedStorage.Events.DashEvent
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local AbilityEvent = game.ReplicatedStorage.Events.AbilityEvent
local BlockEvent = game.ReplicatedStorage.Events.BlockEvent
local BlockEndEvent = game.ReplicatedStorage.Events.BlockEndEvent

--local Character = require(game.ServerScriptService.AttackManager.Characters.Chainsaw)

local AttackManager = require(game.ServerScriptService.AttackManager)
--This isn't really modular but we're only having 1 character right now so it doesn't really matter
local Character = require(game.ServerScriptService.AttackManager.Characters.Chainsaw)

local AttackManagers = {}

local Abilitys = {
	[1] = Character.Attack1,
	[2] = Character.Attack2,
	[3] = Character.Attack3,
	[4] = Character.Attack4
}
------------------------------------------------------

local function onPlayerAdded(player : Player)
	
	AttackManagers[player] = AttackManager.new(player)
	
	local ComboVal = Instance.new("IntValue")
	ComboVal.Name = "Combo"
	ComboVal.Value = 0
	ComboVal.Parent = player
	
	local PlayerDebounces = Instance.new("BoolValue")
	PlayerDebounces.Name = "PlayerDebounce"
	PlayerDebounces.Value = false
	PlayerDebounces.Parent = player
	
	local IsStunned = Instance.new("BoolValue")
	IsStunned.Name = "IsStunned"
	IsStunned.Value = false
	IsStunned.Parent = player
	
	local IsBlocking = Instance.new("BoolValue")
	IsBlocking.Name = "IsBlocking"
	IsBlocking.Value = false
	IsBlocking.Parent = player
	
	player.CharacterAdded:Connect(function()
		player.Character.Parent = workspace.Alive
		player.Character.Humanoid.WalkSpeed = Character.DefaultSpeed
	end)	
	
end
Players.PlayerAdded:Connect(onPlayerAdded)

------------------------------------------------------

M1Event.OnServerEvent:Connect(function(player)
	AttackManagers[player]:M1(Character.DefaultSpeed)
end)

DashEvent.OnServerEvent:Connect(function(player)
	AttackManagers[player]:Dash()
end)

------------------------------------------------------

AbilityEvent.OnServerEvent:Connect(function(player,Ability : number)
	Abilitys[Ability](player)
end)

BlockEvent.OnServerEvent:Connect(function(player)
	AttackManagers[player]:Block(player)
end)

BlockEndEvent.OnServerEvent:Connect(function(player)
	AttackManagers[player]:BlockEnd(player)
end)