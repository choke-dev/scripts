--[[

	Framed! Target ESP

	FAQ:
	Q: What gamemodes does this work in?
	A: Here's a list of the following gamemodes that this script works in:
		- Framed
		- Contacts
		- No Secrets

	Q: Why did you make this script even though theres already a script that does the same thing???
	A: That other script was broken and wasn't working properly. This script does!

	Q: How do i turn off notifications?
        A: getgenv().FramedTESP_Notifications = false

]]
local start = tick()
local AkaliNotif = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/Dynissimo/main/Scripts/AkaliNotif.lua"))(); local Notify = AkaliNotif.Notify; local function notify(text, desc, time) if not getgenv().FramedTESP_Notifications then return end Notify({ Description = desc or "Description"; Title = text or "Title"; Duration = time or 3 }); end
if getgenv().Connections then
	pcall(function()
		for i,v in ipairs(getgenv().Connections) do
			v:Disconnect()
		end
	end)
end

if getgenv().ESPList then
	pcall(function()
		for i,v in ipairs(getgenv().ESPList) do
			v:Remove()
		end
	end)
end

getgenv().Connections = {}
getgenv().ESPList = {}

-- // Services \\ --
local Players = game:GetService("Players")
local PPS = game:GetService("ProximityPromptService")

-- // Modules \\ --
local ESP = loadstring(game:HttpGet("https://kiriot22.com/releases/ESP.lua"))()

-- // Variables \\ --
local Target
local inGame
local currentGameMode
local LPDied
local PPTriggered
local TargetDiedTrigger
local SupportedModes = {
	["Framed"] = true,
	["Contacts"] = true,
	["No Secrets"] = true,
	["Hunted Man"] = false,
	["Impostors"] = false,
	["Elimination"] = false,
	["Team Elimination"] = false,
	["Test"] = false
}

-- // Functions \\ --	
function AddESP(playerName)
	ESP.Color = Color3.fromRGB(112, 112, 112)
    local TEMP_ESP = ESP:Add(Players[playerName].Character.Head, {
        Name = "Target\n\n"..Players[playerName].DisplayName.." (@"..playerName..")",
        Color = Color3.fromRGB(255, 244, 88),
        Player = false,
        IsEnabled = "FramedTargetESP"
    })
	ESP.FramedTargetESP = true
	table.insert(getgenv().ESPList, TEMP_ESP)
    return TEMP_ESP
end

local function scanForNewTarget()
	notify("🔎", "Attempting to search for target...")
	pcall(function()
		Target = tostring(workspace.Events.GetTargetLocal:InvokeServer())
		currentGameMode = workspace.Values.GameMode.Value
	end)

	if not inGame or inGame == "nil" then return notify("❌", "Cannot start scan, You are not in-game.") end
	if not SupportedModes[currentGameMode] then return notify("❌", "Cannot start scan, Gamemode \""..currentGameMode.."\" is not supported.", 6.5) end
	if Target == "nil" or Target == Players.LocalPlayer.Name then return notify("❌", "Didn't find a target,\n\nPerhaps you can't have a target at this time?", 6.5) end

	AddESP(Target)
	notify("🎯", "Found target: "..Players[tostring(Target)].DisplayName)

	TargetDiedTrigger = Players[tostring(Target)].Character.Humanoid.Died:Connect(function()
		notify("⚠️", "Target died, Attempting to scan for new target...")
		TargetDiedTrigger:Disconnect()
		scanForNewTarget()
	end)

	table.insert(getgenv().Connections, TargetDiedTrigger)
end

local function checkInGameState()
	if Players.LocalPlayer.Character:WaitForChild("CharacterAttributes", 2) then
		inGame = true
	else
		inGame = false
	end
end

-- // Events \\ --
table.insert(getgenv().Connections, Players.LocalPlayer.CharacterAdded:Connect(function(character)
	pcall(function()
		for _,v in ipairs() do v:Remove() end
		LPDied:Disconnect()
		TargetDiedTrigger:Disconnect()
	end)

	LPDied = Players.LocalPlayer.Character:WaitForChild("Humanoid", 5).Died:Connect(function()
		pcall(function()
			inGame = false
			notify("❌", "Scanning stopped, You died.")
			LPDied:Disconnect()
			TargetDiedTrigger:Disconnect()
			for _,v in ipairs(getgenv().ESPList) do v:Remove() end
		end)
	end)

	checkInGameState()

	if inGame then
		scanForNewTarget()
	end
end))

LPDied = Players.LocalPlayer.Character.Humanoid.Died:Connect(function()
	pcall(function()
		inGame = false
		notify("❌", "Scanning stopped, You died.")
		LPDied:Disconnect()
		TargetDiedTrigger:Disconnect()
		for _,v in ipairs(getgenv().ESPList) do v:Remove() end
	end)
end)

PPTriggered = PPS.PromptTriggered:Connect(function(prompt)
	if prompt.ActionText == "Get Target" and prompt.ObjectText == "Contact" then
		scanForNewTarget()
	end
end)
table.insert(getgenv().Connections, LPDied)
table.insert(getgenv().Connections, PPTriggered)

-- // Main \\ --
notify("✅", "Script loaded successfully in "..tick() - start.." seconds!")

checkInGameState()
scanForNewTarget()
ESP:Toggle(true)
ESP.Players = false
