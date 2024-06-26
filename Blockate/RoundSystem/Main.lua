--[[ Configuration ]]--
getgenv().BRS_Settings = {
    TIME_UNTIL_NEXT_EVENT = 4.5,
    COUNTDOWN = 5,
    BLACKLISTED_PLAYERS = {
        game:GetService("Players").LocalPlayer.UserId
    },
    SOUNDS = {
        1837879082,
        9047050075,
        1837454064,
        9048375035,
        1838055069,
        9047050075,
        1845554017,
        1838055069,
        1837779005,
        1846458016,
        9048375773,
        1836500792
    },
    EVENT_CONFIG = {
        REQUIRED_AMOUNT_OF_PLAYERS_TO_ACTIVATE_HUB_EVENT = 999,
        BUILDER_PERM_DURATION = 60
    }
}

--[[ Services ]]--
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

--[[ Modules ]]--
local Events = loadstring(game:HttpGet("https://raw.githubusercontent.com/choke-dev/scripts/main/Blockate/RoundSystem/Events.lua",true))()
local CheckPermModule = require(game:GetService("ReplicatedStorage").Modules.Client.Functions.CheckPerm)
local FeedbackModule = require(game:GetService("ReplicatedStorage").Modules.Client.LocalCommands)

if not CheckPermModule(2) then return FeedbackModule.feedback("You need admin permissions to run this script.", "AlsoChat") end
if getgenv().BRS_ALREADY_RAN then return FeedbackModule.feedback("Script is already running, if you wish to run a new instance please type \"/stop\".", "AlsoChat") end
getgenv().BRS_ALREADY_RAN = true
getgenv().INTERNAL_STOPPED = false

--[[ Variables ]]--
local PAUSED = true
local UPDATING = false
local Connections = {}
local TInsert = table.insert

--[[ Functions ]]--
local function stopAll()
    print("🛑 Stopping...")
    PAUSED = true
    getgenv().INTERNAL_STOPPED = true
    for _,v in pairs(Connections) do
        v:Disconnect()
    end
    Connections = {}
    print("✅ Stopped!")
    getgenv().BRS_ALREADY_RAN = false
end

local function runCommand(text)
    pcall(function()
        game:GetService("ReplicatedStorage").Sockets.Command:InvokeServer(text)
    end)
end

local function shout(message)
    pcall(function()
        game:GetService("ReplicatedStorage").Sockets.Command:InvokeServer("!shout "..message)
    end)
end

--[[ Setup ]]--
local eventCount = 0
local playerCount = 0
local eventStrings = {}
for _,v in pairs(Events) do
 eventCount += 1
end
Players.PlayerAdded:Connect(function(plr)
    if table.find(getgenv().BRS_Settings.BLACKLISTED_PLAYERS, plr.UserId) then return end
    playerCount += 1
end)
Players.PlayerRemoving:Connect(function(plr)
    if table.find(getgenv().BRS_Settings.BLACKLISTED_PLAYERS, plr.UserId) then return end
    playerCount -= 1
end)
for _,v in pairs(Players:GetPlayers()) do
    if table.find(getgenv().BRS_Settings.BLACKLISTED_PLAYERS, v.UserId) then continue end
    playerCount += 1
end
for i,_ in pairs(Events) do
    table.insert(eventStrings, i)
end

--[[ Main ]]--
task.spawn(function()
    while true do
        task.wait()
        if getgenv().INTERNAL_STOPPED then break end
        if UPDATING then repeat task.wait() until not UPDATING end
        if playerCount > 0 then
            PAUSED = false
        else
            PAUSED = true
        end
    end
end)

task.spawn(function()
    pcall(function()
        local function getNewSound()
            local newSound = getgenv().BRS_Settings.SOUNDS[math.random(1,#getgenv().BRS_Settings.SOUNDS)]
            if workspace.Audio.SoundId == "rbxassetid://"..newSound then
                return getNewSound()
            else
                return newSound
            end
        end

        local debounce = false

        if not workspace:FindFirstChild("Audio") then
            runCommand("!sound "..getNewSound())
        end

        if workspace.Audio.SoundId == nil then
            runCommand("!sound "..getNewSound())
        end

        TInsert(Connections, workspace:WaitForChild("Audio").DidLoop:Connect(function()
            if debounce then return end
            debounce = true
            local sound = getNewSound()
            print("Playing sound: "..MarketplaceService:GetProductInfo(sound).Name)
            runCommand("!sound "..sound)
            debounce = false
        end))
    end) -- too lazy to figure out whats wrong
end)

task.spawn(function()
    TInsert(Connections, Players.LocalPlayer.Chatted:Connect(function(msg)
        if msg == "/update" then
            UPDATING = true
            PAUSED = true
            shout("☁ Updating...")
            shout("📥 Fetching new events file...")
            Events = loadstring(game:HttpGet("https://raw.githubusercontent.com/choke-dev/scripts/main/Blockate/RoundSystem/Events.lua",true))()
            shout("✅ Events file updated!")
            UPDATING = false
        elseif msg == "/stop" then
            stopAll()
        elseif msg == "/updateplrcount" then
            playerCount = 0
            for _,v in pairs(Players:GetPlayers()) do
                if table.find(getgenv().BRS_Settings.BLACKLISTED_PLAYERS, v.UserId) then continue end
                playerCount += 1
            end
        end
    end))
end)

while true do
    if PAUSED then 
        repeat 
            if getgenv().INTERNAL_STOPPED then break end 
            task.wait(3.9);
            shout("Waiting for Players...") 
        until not PAUSED 
    end
    task.wait(getgenv().BRS_Settings.TIME_UNTIL_NEXT_EVENT)
    if not CheckPermModule(2) then FeedbackModule.feedback("You need admin permissions to continue running this script.", "AlsoChat"); stopAll(); break end
    if getgenv().INTERNAL_STOPPED then break end
    Events[eventStrings[math.random(1, eventCount)]]()
end
