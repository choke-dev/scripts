--[[ Configuration ]]--
getgenv().BRS_Settings = {
    TIME_UNTIL_NEXT_EVENT = 4.5,
    BLACKLISTED_PLAYERS = {
        
    }
}

--[[ Services ]]--
local Players = game:GetService("Players")

--[[ Modules ]]--
local Events = loadstring(game:HttpGet("https://raw.githubusercontent.com/choke-dev/scripts/614dbed678aa860e95f172b1e3eee777bc6df6ed/Blockate/Events.lua",true))()

--[[ Variables ]]--
local PAUSED = true

--[[ Functions ]]--
local function shout(message)
    game:GetService("ReplicatedStorage").Sockets.Command:InvokeServer("!shout "..message)
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
    if PAUSED then repeat task.wait(1); shout([[
        ⏳






        Round paused. Waiting for players...
        ]]) until not PAUSED end
    task.wait(getgenv().BRS_Settings.TIME_UNTIL_NEXT_EVENT)
    Events[eventStrings[math.random(1, eventCount)]]()
end
