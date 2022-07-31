--[[ Services ]]--
local Players = game:GetService("Players")

--[[ Modules ]]--
local ESP = loadstring(game:HttpGet("https://kiriot22.com/releases/ESP.lua"))()
synlog = NEON:github('belkworks', 'synlog')

--[[ Variables ]]--
local Target
local GameMode
local ServerState

--[[ Tables ]]--
local SupportedModes = {"Framed","Contacts","No Secrets"}

--[[ Functions ]]--
function AddESP(playerName:string, text:string, color:Color3)
	ESP.Color = Color3.fromRGB(112, 112, 112)
    local TEMP_ESP = ESP:Add(Players[playerName].Character.Head, {
        Name = text.."\n\n"..Players[playerName].DisplayName.." (@"..playerName..")",
        Color = color,
        Player = false,
        IsEnabled = gay
    })
	ESP.gay = true
    return TEMP_ESP
end

local function RefreshValues()
    Target = tostring(workspace.Events.GetTargetLocal:InvokeServer())
	GameMode = workspace.Values.GameMode.Value
	ServerState = workspace.Values.ServerMode.Value
    synlog:success("Refreshed values.")
end

local function CheckState()
    if Players.LocalPlayer.Character:WaitForChild("CharacterAttributes", 2) then
        synlog:info("Function \"CheckState\" returned true.")
		return true
	else
        synlog:info("Function \"CheckState\" returned false.")
		return false
	end
end

local function ScanNewTarget()
    if not CheckState() then return synlog:error("Function \"ScanNewTarget\" failed, you are not in-game.") end
    if not table.find(SupportedModes, GameMode) then return synlog:error("Function \"ScanNewTarget\" failed, you are not in a supported game mode.") end
    RefreshValues()
    if not Target then return end
    synlog:success("Found target.")
    return AddESP(Target.Name, "Target", Color3.fromRGB(255, 244, 88))
end

local function ScanUndercover()
    if not CheckState() then return synlog:error("Function \"ScanUndercover\" failed, you are not in-game.") end
    RefreshValues()
    if not Players.LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool") then repeat task.wait() until Players.LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool") end

    for i,v in ipairs(Players:GetPlayers()) do
		if v.Team.Name ~= "Framed" and v.Name ~= Players.LocalPlayer.Name then continue end
		if not v.Backpack:FindFirstChildWhichIsA("Tool") then repeat task.wait() until v.Backpack:FindFirstChildWhichIsA("Tool") end
        if not v.Backpack:FindFirstChild("Fake Check Target") then return end

        synlog:success("Found undercover.")
		return AddESP(v.Name, "Undercover", Color3.new(0, 1, 0.333333))
	end
end

local function SetupDiedEvent()
    local DiedEvent = Players.LocalPlayer.Character:WaitForChild("Humanoid").Died:Connect(function()
        DiedEvent:Disconnect()
    end)
end

--[[ Events ]]--
Players.LocalPlayer.CharacterAdded:Connect(function()
    
end)

--[[

ESP:Toggle(true)
ESP.Players = false

]]