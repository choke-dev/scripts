--[[ Services ]]--
local Players = game:GetService("Players")

--[[ Functions ]]--
local function round(number, decimalPlaces)
    local decplaces = decimalPlaces or 0
	return math.round(number * 10^decplaces) * 10^-decplaces
end

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
    for i = startingNum, 0, -0.1 do
        shout(([[
        %s






        %s
        ]]):format(round(i, 1),text))
        task.wait()
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
        runCommand("!kill "..target.Name)
    end,
    ["MODIFY_GRAVITY"] = function()
        local gravity = countdown(5, "World gravity will change.", 2)
        for i = 1, 6 do
            shout("Choosing new world gravity: "..math.random(5, 500))
            task.wait(0.1)
        end
        shout("New world gravity: "..gravity)
        runCommand("!gravity "..gravity)
    end,
    ["RANDOM_PLAYER_GETS_SWORD"] = function()
        local target = countdown(5, "A random player will get a sword.", 1)
        shout("🗡| "..target.Name.." recieved a sword!")
        runCommand("!gear "..target.Name.." sword")
    end
}
