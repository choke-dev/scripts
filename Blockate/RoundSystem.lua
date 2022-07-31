--[[ Configuration ]]--
getgenv().BRS_Settings = {
    TIME_UNTIL_NEXT_EVENT = 4.5,
    COUNTDOWN = 5,
    BLACKLISTED_PLAYERS = {
        game:GetService("Players").LocalPlayer.UserId
    },
    SOUNDS = {
        1837879082,
        9047050075
    },
    EVENT_CONFIG = {
        REQUIRED_AMOUNT_OF_PLAYERS_TO_ACTIVATE_HUB_EVENT = 15,
        BUILDER_PERM_DURATION = 30
    }
}
--[[ Services ]]--
local Players = game:GetService("Players")

--[[ Modules ]]--
local Events = loadstring(game:HttpGet("https://raw.githubusercontent.com/choke-dev/scripts/main/Blockate/Events.lua",true))()

--[[ Variables ]]--
local PAUSED = true

--[[ Functions ]]--
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
Players.PlayerAdded:Connect(function()
    playerCount += 1
end)
Players.PlayerRemoving:Connect(function()
    playerCount -= 1
end)
for _,v in pairs(Players:GetPlayers()) do
    playerCount += 1
end
for i,_ in pairs(Events) do
    table.insert(eventStrings, i)
end

--[[ Main ]]--
task.spawn(function()
    while true do
        task.wait()
        if playerCount > 1 then
            PAUSED = false
        else
            PAUSED = true
        end
    end
end)

while true do
    if PAUSED then repeat task.wait(3.1); shout([[
        ⏳


        Blockate Round System
        built by choke-dev on github
        v1.0.1


        Round paused. Waiting for players...
        ]]) until not PAUSED end
    task.wait(getgenv().BRS_Settings.TIME_UNTIL_NEXT_EVENT)
    Events[eventStrings[math.random(1, eventCount)]]()
end
