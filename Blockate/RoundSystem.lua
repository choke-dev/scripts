--[[ Configuration ]]--
getgenv().BlockateRoundSystem_Settings = {

}

--[[ Services ]]--
local Players = game:GetService("Players")

--[[ Modules ]]--
local Events = loadstring(game:HttpGet("https://raw.githubusercontent.com/choke-dev/scripts/main/Blockate/Events.lua",true))()

--[[ Functions ]]--
local function runCommand(text)
    game:GetService("ReplicatedStorage").Sockets.Command:InvokeServer(text)
end

local function shout(message)
    game:GetService("ReplicatedStorage").Sockets.Command:InvokeServer("!shout "..message)
end

local function getRandomPlayer()
    local players = Players:GetPlayers()
    local randomPlayer = players[math.random(1, #players)]
    return randomPlayer
end

local function countdown(startingNum, text, eventType)
    for i = startingNum, 0, -1 do
        shout(([[
        %s






        %s
        ]]):format(i,text))
        task.wait(0.5)
    end
    shout("")

    if eventType == 1 then
        return getRandomPlayer(), text
    elseif eventType == 2 then
        return math.random(5, 500), text
    end
end

local plr, runEvent = countdown(5, Events[math.random(1, #Events)], 1)
shout("💀 "..plr.Name.." was killed.")
runCommand(Events[runEvent]:format(plr.Name))