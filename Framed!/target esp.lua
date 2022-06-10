--[[


	Hunted Man

]]

local AkaliNotif = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/Dynissimo/main/Scripts/AkaliNotif.lua"))(); local Notify = AkaliNotif.Notify; local function notify(text, desc, time) Notify({ Description = desc or "Description"; Title = text or "Title"; Duration = time or 3 }); end
if getgenv().Connections then
	for i,v in ipairs(getgenv().Connections) do
		v:Disconnect()
	end
	notify("☁️➡💾", "Script updated.")
end

getgenv().Connections = {}

-- // Services \\ --
local Players = game:GetService("Players")

-- // Modules \\ --
local ESPModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/choke-dev/RE-Script/main/Dependencies/ESP%20Module.lua",true))()

-- // Variables \\ --
local Target
local inGame
local UnsupportedModes = {"Contacts"}

-- // Functions \\ --
local function highlightPlayer(playerName)
	ESPModule.Create2DESP(Players[tostring(playerName)].Character.Head, "\nTarget: "..Players[tostring(playerName)].DisplayName, Color3.fromRGB(136, 0, 255))
end

local function scanForNewTarget()
	pcall(function()
		notify("ℹ", "Attempting to search for target...")
		Target = workspace.Events.GetTargetLocal:InvokeServer()

		if Target == nil or Target == Players.LocalPlayer.Name then return notify("❌", "No target found.") end
		if not inGame then return notify("❌", "Not in-game, stopping scan.") end

		highlightPlayer(tostring(Target))
		notify("✅", "Found target: "..Players[tostring(Target)].DisplayName)

		local DiedTrigger = Players[tostring(Target)].Character.Humanoid.Died:Connect(function()
			notify("⚠️", "Target died, Scanning for new target...")
			scanForNewTarget()
			DiedTrigger:Disconnect()
		end)

		table.insert(getgenv().Connections, DiedTrigger)
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
	if character:WaitForChild("CharacterAttributes", 2) then -- checks if the localplayer is in game
		inGame = true
		scanForNewTarget()
	else
		inGame = false
		notify("❌", "Not in-game, stopping scan.")
	end
end))

-- // Main \\ --
if not getgenv().Connections then
	notify("✅", "Script loaded.")
end
checkInGameState()
scanForNewTarget()