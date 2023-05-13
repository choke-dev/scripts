--[[
    This script will highlight every NPC in the game.
    Every NPC will be given a highlight effect, and
    If the player's camera can see the NPC, the NPC's highlight effect will be removed.
    
    The game has a highlight limit of 31 instances.
    To circumvent this, we will create a model with a highlight instance and put the NPCs inside of it.

    The NPC folder path are as follows:
        - workspace.Police
        - workspace.Citizens

    The goal is to create a model with a highlight instance, and put the NPCs inside of it.
    Then we dynamically move out the NPCs from the model, and move them back in when they are out of the camera's view.
]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- PlaceIds
local NotorietyUniverse = {
    [2088934656] = function()
        warn("Executing special function for Shadow Raid")
        for _,v in ipairs(workspace.PoliceFolder:GetDescendants()) do
            if v:IsA("Hat") and v.Name == "Lanyard" then
                local Highlight = Instance.new("Highlight")
                Highlight.Parent = v
                Highlight.OutlineColor = Color3.fromRGB(255, 0, 255)
                Highlight.FillTransparency = 1
            end
        end
    end
}

-- Player
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- NPC Folder
local PoliceFolder = workspace:WaitForChild("Police")
local CitizensFolder = workspace:WaitForChild("Citizens")

-- Highlight Model
local PoliceHighlightModel = Instance.new("Model")
local CitizensHighlightModel = Instance.new("Model")

-- Highlight Instance
local PoliceHighlight = Instance.new("Highlight")
local CitizensHighlight = Instance.new("Highlight")

-- Highlight Color
PoliceHighlight.OutlineColor = Color3.fromRGB(255, 0, 0)
CitizensHighlight.OutlineColor = Color3.fromRGB(255, 160, 0)

-- Highlight Transparency
PoliceHighlight.FillTransparency = 1
CitizensHighlight.FillTransparency = 1

-- Highlight Model Name
PoliceHighlightModel.Name = "PoliceHighlightModel"
CitizensHighlightModel.Name = "CitizensHighlightModel"

-- Parenting
PoliceHighlight.Parent = PoliceHighlightModel
CitizensHighlight.Parent = CitizensHighlightModel

-- Parenting
PoliceHighlightModel.Parent = workspace.Police
CitizensHighlightModel.Parent = workspace.Citizens


-- Function to check if the NPC is in the camera's view
-- Use functions as WorldToViewportPoint() and GetPartsObscuringTarget() to check if the NPC is visible to the camera
function isNPCVisible(NPC)
    local Camera = workspace.CurrentCamera
    local NPCHRP = NPC:FindFirstChild("HumanoidRootPart")
    local NPCHRPPosition, OnScreen = Camera:WorldToViewportPoint(NPCHRP.Position)
    local PartsObscuringTarget = Camera:GetPartsObscuringTarget({NPCHRP.Position}, {Character, NPC})
    local IsVisible = OnScreen and #PartsObscuringTarget == 0
    return IsVisible
end

-- One-time items
local status, err = pcall(function()
    NotorietyUniverse[game.PlaceId]()
end)

-- Main loop
getgenv().NPC_SCAN = RunService.RenderStepped:Connect(function()
    for _, NPC in ipairs(PoliceFolder:GetDescendants()) do
        if NPC:IsA("Model") and NPC:FindFirstChild("HumanoidRootPart") then
            if isNPCVisible(NPC) then
                NPC.Parent = workspace.Police
            else
                NPC.Parent = PoliceHighlightModel
            end
        end
    end

    for _, NPC in ipairs(CitizensFolder:GetDescendants()) do
        if NPC:IsA("Model") and NPC:FindFirstChild("HumanoidRootPart") then
            if isNPCVisible(NPC) then
                NPC.Parent = workspace.Citizens
            else
                NPC.Parent = CitizensHighlightModel
            end
        end
    end
end)
