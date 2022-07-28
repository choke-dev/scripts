--[[ Services ]]--
local Players = game:GetService("Players")

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

return {
    ["RANDOM_PLAYER_KILLED"] = function()
        local target = countdown(5, "A random player will die.", 1)
        shout("💀| "..target.Name.." was killed.")
        runCommand(("!kill %s"):format(target.Name)) 
    end,
    ["DECREASE_GRAVITY"] = function()
        
    end
}