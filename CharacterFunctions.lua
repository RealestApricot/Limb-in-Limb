--SERVICES--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
--FOLDERS--
--MODULES--
--VARIABLES + EVENT CONNECTIONS--
--FUNCTIONS--
local RagdollOn = function(Character: Model, Limb)
	local LimbPart = Character:FindFirstChild(Limb)
	if not LimbPart then
		return
	end
	local Joint: Motor6D = LimbPart:FindFirstChildOfClass("Motor6D")
	if not Joint then
		return
	end

	local Attachment0 = Instance.new("Attachment")
	Attachment0.Name = "CharacterFunctions_RagdollAttachment0"
	Attachment0.CFrame = Joint.C0
	Attachment0.Parent = Joint.Part0

	local Attachment1 = Instance.new("Attachment")
	Attachment1.Name = "CharacterFunctions_RagdollAttachment1"
	Attachment1.CFrame = Joint.C1
	Attachment1.Parent = Joint.Part1

	local BallSocketConstraint = Instance.new("BallSocketConstraint")
	BallSocketConstraint.Name = "CharacterFunctions_RagdollJoint"
	BallSocketConstraint.Attachment0 = Attachment0
	BallSocketConstraint.Attachment1 = Attachment1
	BallSocketConstraint.LimitsEnabled = true
	BallSocketConstraint.TwistLimitsEnabled = true
	BallSocketConstraint.Parent = Joint.Parent

	Joint.Enabled = false
end

local RagdollOff = function(Character: Model, Limb)
	local LimbPart = Character:FindFirstChild(Limb)
	if not LimbPart then
		return
	end
	local Joint: Motor6D = LimbPart:FindFirstChildOfClass("Motor6D")
	if not Joint then
		return
	end
	local BallSocketConstraint: BallSocketConstraint =
		LimbPart:FindFirstChild("CharacterFunctions_RagdollJoint") :: BallSocketConstraint
	if not BallSocketConstraint then
		return
	end

	local Attachment0 = BallSocketConstraint.Attachment0
	local Attachment1 = BallSocketConstraint.Attachment1

	Attachment0:Destroy()
	Attachment1:Destroy()
	BallSocketConstraint:Destroy()

	Joint.Enabled = true
end
--SCRIPT--
CharacterFunctions = {}

--[[
Loops through parts of the Characters Body Parts Setting Values to each
]]
--
function CharacterFunctions.CharacterAdded(
	Character: Model,
	AdditionalParts,
	BlacklistParts,
	AdditionalAttributes,
	BlacklistAttributes
)
	if not Character then
		return
	end
	repeat
		RunService.Heartbeat:Wait()
	until Character.Parent ~= nil
	Character.Parent = workspace.Live

	local LimbsTable = {
		"Head",
		"Right Arm",
		"Left Arm",
		"Torso",
		"Right Leg",
		"Left Leg",
		"RightUpperArm",
		"RightLowerArm",
		"RightHand",
		"RightUpperLeg",
		"RightLowerLeg",
		"RightFoot",
		"LeftUpperArm",
		"LeftLowerArm",
		"LeftHand",
		"LeftUpperLeg",
		"LeftLowerLeg",
		"LeftFoot",
		"UpperTorso",
		"LowerTorso",
	}

	local AttributeTable = {
		["IsALimb"] = true,
		["Health"] = 100,
		["MaxHealth"] = 100,
		["Strength"] = 100,
		["MaxStrength"] = 100,
		["CanRegen"] = true,
		["Enabled"] = true,
	}

	local SetUpAttributes = function(Part: Part)
		for Attribute, Value in pairs(AttributeTable) do
			if BlacklistAttributes and table.find(BlacklistAttributes, Attribute) then
				continue
			end
			Character:SetAttribute(Attribute, Value)
		end
		if not AdditionalAttributes or #AdditionalAttributes == 0 then
			return
		end
		for Attribute, Value in pairs(AdditionalAttributes) do
			Character:SetAttribute(Attribute, Value)
		end
	end

	--Set Up Attributes based off of Default Values, Additional Attributes, and BlacklistAttributes
	for Index, Child in pairs(Character:GetChildren()) do
		if table.find(BlacklistParts, Child.Name) then
			continue
		end
		if table.find(LimbsTable, Child.Name) or table.find(AdditionalParts, Child.Name) then
			SetUpAttributes(Child)
		end
	end

	Character:SetAttribute("Loaded", true)
end

function CharacterFunctions.DisableLimb(Character: Model, Limb)
	local LimbPart = Character:FindFirstChild(Limb)
	if LimbPart then
		LimbPart:SetAttribute("LimbEnabled", false)
	end
end

function CharacterFunctions.EnableLimb(Character: Model, Limb)
	function CharacterFunctions.DisableLimb(Character: Model, Limb)
		local LimbPart = Character:FindFirstChild(Limb)
		if LimbPart then
			LimbPart:SetAttribute("LimbEnabled", true)
		end
	end
end

function CharacterFunctions.HealLimb(Character: Model, Limb, HealAmount)
	local LimbPart = Character:FindFirstChild(Limb)
	if not Limb then
		return
	end
	if LimbPart:GetAttribute("Health") < LimbPart:GetAttribute("MaxHealth") then
		LimbPart:SetAttribute("Health", LimbPart:GetAttribute("Health") + HealAmount)
	end
end

function CharacterFunctions.RagdollOn(Character: Model, LimbsToRagdoll, LimbsToNotRagdoll)
	if not Character then
		return
	end
	if LimbsToRagdoll and #LimbsToRagdoll > 0 then
		for Index, Limb in pairs(LimbsToRagdoll) do
			if LimbsToNotRagdoll and table.find(LimbsToNotRagdoll, Limb) then
				continue
			end
			RagdollOn(Character, Limb)
		end
	else
		for Index, Child in pairs(Character:GetChildren()) do
			if Child:GetAttribute("IsALimb") == true then
				RagdollOn(Character, Child)
			end
		end
	end
end

function CharacterFunctions.RagdollOff(Character: Model, LimbsToUnragdoll, LimbsNotToUnragdoll)
	if not Character then
		return
	end
	if LimbsToUnragdoll and #LimbsToUnragdoll > 0 then
		for Index, Limb in pairs(LimbsToUnragdoll) do
			if LimbsNotToUnragdoll and table.find(LimbsNotToUnragdoll, Limb) then
				continue
			end
			RagdollOff(Character, Limb)
		end
	else
		for Index, Child in pairs(Character:GetChildren()) do
			if Child:GetAttribute("IsALimb") == true then
				if LimbsNotToUnragdoll and table.find(LimbsNotToUnragdoll, Child.Name) then
					continue
				end
				RagdollOff(Character, Child.Name)
			end
		end
	end
end

function CharacterFunctions.RemoveLimb(Character: Model, Limb)
	local Humanoid: Humanoid = Character:WaitForChild("Humanoid") :: Humanoid
	local JointTable = {
		["Head"] = "Neck",
		["Right Arm"] = "Right Shoulder",
		["Left Arm"] = "Left Shoulder",
		["Right Leg"] = "Right Hip",
		["Left Leg"] = "Left Hip",
	}
	local RemoveMeansDeath = { "Head", "Torso", "UpperTorso", "LowerTorso" }
	local LimbPart: Part = Character:FindFirstChild(Limb) :: Part
	if LimbPart then
		LimbPart.CanCollide = true
	end
	local RemoveJoint = Character:WaitForChild("Torso"):FindFirstChild(JointTable[Limb])
	if RemoveJoint then
		RemoveJoint:Destroy()
	end
	if table.find(RemoveMeansDeath, Limb) then
		Humanoid.Health = 0
	end
end

return CharacterFunctions