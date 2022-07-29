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

local function place(position)
    -- i hate blockate coordinates
    position = tostring((math.round(position.X / 4)).." "..(math.round(position.Y / 4)).."- "..(math.round(position.Z / 4)).."/0")
    print(position)
    
    game:GetService("ReplicatedStorage").Sockets.Edit.Place:InvokeServer(position, {
        ["Reflectance"] = 0,
        ["CanCollide"] = true,
        ["Color"] = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255)),
        ["LightColor"] = Color3.new(1,1,1),
        ["Transparency"] = 0,
        ["Size"] = 2,
        ["Material"] = 15,
        ["Shape"] = 1,
        ["Light"] = 0
    })
end

local function getRandomPlayer()
    local players = Players:GetPlayers()
    local randomPlayer = players[math.random(1, #players)]
    if table.find(getgenv().BRS_Settings.BLACKLISTED_PLAYERS, randomPlayer.UserId) then return getRandomPlayer() end
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
        return math.random(5, 200), text
    end
end

return {
    --[[ Player Events ]]--
    ["RANDOM_PLAYER_KILLED"] = function()
        local target = countdown(getgenv().BRS_Settings.COUNTDOWN, "A random player will die.", 1)
        runCommand("!kill "..target.Name)
    end,
    ["RANDOM_PLAYER_GETS_SWORD"] = function()
        local target = countdown(getgenv().BRS_Settings.COUNTDOWN, "A random player will get a sword.", 1)
        runCommand("!gear "..target.Name.." sword")
    end,
    ["RANDOM_PLAYER_FLINGED"] = function()
        local target = countdown(getgenv().BRS_Settings.COUNTDOWN, "A random player will be flung.", 1)
        runCommand("!fling "..target.Name)
    end,
    ["RANDOM_PLAYER_TRIPPED"] = function()
        local target = countdown(getgenv().BRS_Settings.COUNTDOWN, "A random player will be tripped.", 1)
        runCommand("!trip "..target.Name)
    end,
    ["RANDOM_PLAYER_BALLED"] = function()
        local target = countdown(getgenv().BRS_Settings.COUNTDOWN, "A random player will be balled.", 1)
        runCommand("!ball "..target.Name)
    end,
    ["RANDOM_PLAYER_HUBBED"] = function()
        local target = countdown(getgenv().BRS_Settings.COUNTDOWN, "A random player will be hubbed.", 1)
        runCommand("!hub "..target.Name)
    end,
    ["ALL_PLAYERS_TP_TO_PLAYER"] = function()
        local target = countdown(getgenv().BRS_Settings.COUNTDOWN, "All players will be teleported to a random player.", 1)
        runCommand("!tp all "..target.Name)
    end,

    --[[ World Events ]]--
    ["MODIFY_GRAVITY"] = function()
        local gravity = countdown(getgenv().BRS_Settings.COUNTDOWN, "The world gravity is changing!", 2)
        for i = 1, 6 do
            shout("Choosing new world gravity: "..math.random(5, 200))
            task.wait(0.3)
        end
        shout("New world gravity: "..gravity)
        runCommand("!gravity "..gravity)
    end,
    ["MODIFY_FOG"] = function()
        local fog = countdown(getgenv().BRS_Settings.COUNTDOWN, "The fog radius is changing!", 2)
        for i = 1, 6 do
            shout("Choosing new fog radius: "..math.random(5, 200))
            task.wait(0.3)
        end
        shout("New fog radius: "..fog)
        runCommand("!fog "..fog)
    end,
    ["PLATE_PLACED_ON_PLAYER"] = function()
        local target = countdown(getgenv().BRS_Settings.COUNTDOWN, "A plate will be placed on a random player.", 1)
        local HRPos = target.Character.HumanoidRootPart.Position
        place(Vector3.new(HRPos.X, HRPos.Y - 2, HRPos.Z))
    end
}
