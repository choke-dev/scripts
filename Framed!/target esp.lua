--[[

	FAQ:
	Q: What gamemodes does this work in?
	A: Here's a list of the following gamemodes that this script works in:
		- Framed
		- Contacts

]]
getgenv().FramedTESP_Notifications = true
local start = tick()
local AkaliNotif = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/Dynissimo/main/Scripts/AkaliNotif.lua"))(); local Notify = AkaliNotif.Notify; local function notify(text, desc, time) if not getgenv().FramedTESP_Notifications then return end Notify({ Description = desc or "Description"; Title = text or "Title"; Duration = time or 3 }); end
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

-- // Modules \\ --
local ESPModule
pcall(function()
	ESPModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/choke-dev/RE-Script/main/Dependencies/ESP%20Module.lua",true))()
end)

-- // Variables \\ --
local Target
local inGame
local LPDied
local PPTriggered
local DiedTrigger

-- // Functions \\ --
local function highlightPlayer(playerName, color)
	ESPModule.Create2DESP(Players[tostring(playerName)].Character.Head, "\nTarget: "..Players[tostring(playerName)].DisplayName, color or Color3.fromRGB(136, 0, 255))
end

local function scanForNewTarget()
	pcall(function()
		notify("🔎", "Attempting to search for target...")
		Target = tostring(workspace.Events.GetTargetLocal:InvokeServer())

		if Target == nil or Target == Players.LocalPlayer.Name then return notify("❌", "Didn't find a target,\n\nPerhaps you can't have a target at this time?", 6.5) end
		if not inGame then return end

		highlightPlayer(tostring(Target))
		notify("✅", "Found target: "..Players[tostring(Target)].DisplayName)

		DiedTrigger = Players[tostring(Target)].Character.Humanoid.Died:Connect(function()
			notify("⚠️", "Target died, Attempting to scan for new target...")
			DiedTrigger:Disconnect()
			PPTriggered:Disconnect()
			scanForNewTarget()
		end)

		PPTriggered = PPS.PromptTriggered:Connect(function(prompt)
			if prompt.ActionText == "Get Target" and prompt.ObjectText == "Contact" then
				scanForNewTarget()
			end
		end)

		table.insert(getgenv().Connections, DiedTrigger)
		table.insert(getgenv().Connections, PPTriggered)
	end)
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
		LPDied:Disconnect()
		PPTriggered:Disconnect()
		DiedTrigger:Disconnect()
	end)

	LPDied = Players.LocalPlayer.Character:WaitForChild("Humanoid", 5).Died:Connect(function()
		inGame = false
		notify("❌", "You died!")
		PPTriggered:Disconnect()
		LPDied:Disconnect()
	end)

	checkInGameState()

	if inGame then
		scanForNewTarget()
		PPTriggered = PPS.PromptTriggered:Connect(function(prompt)
			if prompt.ActionText == "Get Target" and prompt.ObjectText == "Contact" then
				scanForNewTarget()
			end
		end)
	end
end))

LPDied = Players.LocalPlayer.Character.Humanoid.Died:Connect(function()
	inGame = false
	notify("❌", "You died!")
	PPTriggered:Disconnect()
	LPDied:Disconnect()
end)
table.insert(getgenv().Connections, LPDied)

-- // Main \\ --
notify("✅", "Script loaded successfully in "..tick() - start.." seconds!")

checkInGameState()
scanForNewTarget()