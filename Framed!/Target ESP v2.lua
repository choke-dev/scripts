getgenv().FramedTESP_Notifications = true

-- // Modules \\ --
local AkaliNotif = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/Dynissimo/main/Scripts/AkaliNotif.lua"))(); local Notify = AkaliNotif.Notify; local function notify(text, desc, time) if not getgenv().FramedTESP_Notifications then return end Notify({ Description = desc or "Description"; Title = text or "Title"; Duration = time or 3 }); end
local MODULE_PlayerESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/choke-dev/RE-Script/main/Dependencies/Player%20ESP%20Module.lua"))()

-- // Script Updater \\ --
if getgenv().Connections then
	pcall(function()
		for i,v in ipairs(getgenv().Connections) do
			v:Disconnect()
		end
	end)
	notify("☁️ >>> 💾", "Updating script...")
end
getgenv().Connections = {}

-- // Services \\ --
local Players = game:GetService("Players")
local PPS = game:GetService("ProximityPromptService")   

-- // Variables \\ --
local Target
local InGame
local LPDied
local LPAdded
local PlayerAddedEvent
local PPTriggered

-- // Functions \\ --
local function checkInGameState()
	if Players.LocalPlayer.Character:WaitForChild("CharacterAttributes", 2) then
		InGame = true
	else
		InGame = false
	end
end

local function scanForNewTarget()
	notify("🔎", "Attempting to search for target...")
	Target = tostring(workspace.Events.GetTargetLocal:InvokeServer())

	if not InGame then return notify("❌", "Cannot start scan, You are not in-game.") end
	if Target == "nil" or Target == Players.LocalPlayer.Name then return notify("❌", "Didn't find a target,\n\nPerhaps you can't have a target at this time?", 6.5) end

	MODULE_PlayerESP.CreateESP(Target, Color3.fromRGB(255, 89, 89), "Target: "..Players[Target].DisplayName.." (@"..Target..")")
	notify("🎯", "Found target: "..Players[tostring(Target)].DisplayName)
end

-- // Events \\ --
PlayerAddedEvent = Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Wait()
    local playerDiedEvent = player.Character:WaitForChild("Humanoid").Died:Connect(function()
        if player.Name == Target then
            notify("⚠️", "Target died, Attempting to scan for new target...")
            MODULE_PlayerESP.RemoveESP(Target)
            scanForNewTarget()
        end
    end)
    table.insert(getgenv().Connections, playerDiedEvent)
end)

LPDied = Players.LocalPlayer.Character.Humanoid.Died:Connect(function()
    pcall(function()
        InGame = false
        notify("❌", "Stopping scan, You died.")
        MODULE_PlayerESP.RemoveESP(Target)
    end)
end)

LPAdded = Players.LocalPlayer.CharacterAdded:Connect(function()
    pcall(function()
        MODULE_PlayerESP.RemoveESP(Target)
        checkInGameState()
        scanForNewTarget()
    end)
end)

PPTriggered = PPS.PromptTriggered:Connect(function(prompt)
	if prompt.ActionText == "Get Target" and prompt.ObjectText == "Contact" then
		scanForNewTarget()
	end
end)

for _,v in pairs(Players:GetPlayers()) do
    local initialPlayerDiedEvent = v.Character.Humanoid.Died:Connect(function()
        if v.Name == Target then
            notify("⚠️", "Target died, Attempting to scan for new target...")
            MODULE_PlayerESP.RemoveESP(Target)
            scanForNewTarget()
        end
    end)
    table.insert(getgenv().Connections, initialPlayerDiedEvent)
end

table.insert(getgenv().Connections, LPDied)
table.insert(getgenv().Connections, LPAdded)
table.insert(getgenv().Connections, PlayerAddedEvent)
table.insert(getgenv().Connections, PPTriggered)

-- // Main \\ --
pcall(function()
    Target = tostring(workspace.Events.GetTargetLocal:InvokeServer())
    MODULE_PlayerESP.RemoveESP(Target)
end)
checkInGameState()
scanForNewTarget()