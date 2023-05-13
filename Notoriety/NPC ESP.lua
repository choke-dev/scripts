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
