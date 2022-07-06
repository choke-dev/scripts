-- // Services \\ --
local Players = game:GetService("Players")

-- // Modules \\ --
local ESP = loadstring(game:HttpGet("https://kiriot22.com/releases/ESP.lua"))()
local AkaliNotif = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/Dynissimo/main/Scripts/AkaliNotif.lua"))(); local Notify = AkaliNotif.Notify;

-- // Variables \\ --
local Target
local CurrentGamemode
local ServerState
local InGame
local ContactTriggered
local TargetDied
local TargetESP
local LocalPlayerDied
local SupportedModes = {"Framed","Contacts","No Secrets"}

-- // Functions  \\ --
local function notify(text, desc, time)
    if not getgenv().FramedTESP_Notifications then return end
    Notify({
        Description = desc or "Description";
        Title = text or "Title";
        Duration = time or 3
    });
end

local function AddESP(playerName, text, color, istemp)
    if not istemp then istemp = true end
	ESP.Color = Color3.fromRGB(112, 112, 112)
    local TEMP_ESP = ESP:Add(Players[playerName].Character.Head, {
        Name = text.."\n\n"..Players[playerName].DisplayName.." (@"..playerName..")",
        Color = color or Color3.fromRGB(255, 141, 88),
        Player = false,
        IsEnabled = "FramedTargetESP"
    })
	ESP.FramedTargetESP = true
	if istemp then
        table.insert(getgenv().ESPList, TEMP_ESP)
    end
    return TEMP_ESP
end

local function scanAllowed()
    if not InGame or InGame == "nil" then 
        notify("❌", "Not in-game!")
        return false
    end
	if not table.find(SupportedModes, tostring(CurrentGamemode)) then 
        notify("❌", "Cannot start scan, Gamemode \""..CurrentGamemode.."\" is not supported.", 6.5)
        return false
    end
    return true
end

local function refreshValues()
    Target = tostring(workspace.Events.GetTargetLocal:InvokeServer())
	CurrentGamemode = workspace.Values.GameMode.Value
	ServerState = workspace.Values.ServerMode.Value
end

local function ScanUndercover()
    if not Players.LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool") then 
        notify("⌛", "Waiting until game starts before scanning for undercover."); 
        repeat task.wait() until Players.LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool") 
    end
        notify("🔎", "Attempting to search for undercover...")

    for i,v in ipairs(Players:GetPlayers()) do
        if v.Team.Name ~= "Framed" and v.Name ~= Players.LocalPlayer.Name then continue end
        if not v.Backpack:FindFirstChildWhichIsA("Tool") then repeat task.wait() until v.Backpack:FindFirstChildWhichIsA("Tool") end

        if v.Backpack:FindFirstChild("Fake Check Target") then
            AddESP(v.Name, "Undercover", Color3.new(0, 1, 0.333333), false)
            notify("🕵️", "Found undercover: "..v.DisplayName)
        end

    end
 end

local function Scan()
    if not scanAllowed() then return end
    refreshValues()
    if not Target or Target == Players.LocalPlayer.Name then return notify("❌", "No target found!") end
    TargetESP = AddESP(Target, "Target")
    TargetDied = Players[Target].Character.Humanoid.Died:Connect(function()
        TargetDied:Disconnect()
        TargetESP:Remove()
        if CurrentGamemode == "Contacts" then return end
        Scan()
    end)
    ScanUndercover()
end