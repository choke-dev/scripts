--[[ Services ]]--
local Players = game:GetService("Players")

--[[ Functions ]]--
local function round(number, decimalPlaces)
    local decplaces = decimalPlaces or 0
	return math.round(number * 10^decplaces) * 10^-decplaces
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

local function place(position, color)
    -- i hate blockate coordinates
    position = tostring((math.round(position.X / 4)).." "..(math.round((position.Y) / 4)).."+ "..(math.round(position.Z / 4)).."/0")
    
    local block = game:GetService("ReplicatedStorage").Sockets.Edit.Place:InvokeServer(position, {
        ["Reflectance"] = 0,
        ["CanCollide"] = true,
        ["Color"] = color,
        ["LightColor"] = Color3.new(1,1,1),
        ["Transparency"] = 0,
        ["Size"] = 2,
        ["Material"] = 15,
        ["Shape"] = 1,
        ["Light"] = 0
    })
    return block.Position
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
    elseif eventType == 2 then -- fog
        return math.random(300, 600), text
    elseif eventType == 3 then -- gravity
        return math.random(10, 200), text
    end
end

--[[ Main Events ]]--

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
        if #Players:GetPlayers() < 10 then return end
        local target = countdown(getgenv().BRS_Settings.COUNTDOWN, "A random player will be hubbed.", 1)
        runCommand("!hub "..target.Name)
    end,
    ["ALL_PLAYERS_TP_TO_PLAYER"] = function()
        local target = countdown(getgenv().BRS_Settings.COUNTDOWN, "All players will be teleported to a random player.", 1)
        runCommand("!tp all "..target.Name)
    end,
    ["RANDOM_PLAYER_RECIEVES_FLIGHT"] = function()
        local target = countdown(getgenv().BRS_Settings.COUNTDOWN, "A random player will be given flight.", 1)
        runCommand("!fly "..target.Name)
    end,

    --[[ World Events ]]--
    ["MODIFY_GRAVITY"] = function()
        local gravity = countdown(getgenv().BRS_Settings.COUNTDOWN, "The world gravity is changing!", 3)
        for i = 1, 6 do
            shout("Choosing new world gravity: "..math.random(10, 200))
            task.wait(0.5)
        end
        shout("New world gravity: "..gravity)
        runCommand("!gravity "..gravity)
    end,
    ["MODIFY_FOG"] = function()
        local fog = countdown(getgenv().BRS_Settings.COUNTDOWN, "The fog radius is changing!", 2)
        for i = 1, 6 do
            shout("Choosing new fog radius: "..math.random(300, 600))
            task.wait(0.3)
        end
        shout("New fog radius: "..fog)
        runCommand("!fog "..fog)
    end,
    ["SMALL_PLATE_PLACED_ON_PLAYER"] = function()
        local target = countdown(getgenv().BRS_Settings.COUNTDOWN, "A small plate will be placed on a random player.", 1)
        local HRPos = target.Character.HumanoidRootPart.Position
        place(HRPos, Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255)))
    end,
    ["PLATE_PLACED_ON_PLAYER"] = function()
        local target = countdown(getgenv().BRS_Settings.COUNTDOWN, "A plate will be placed on a random player.", 1)
        local Temp_HRPos = target.Character.HumanoidRootPart.Position
        local HRPos = Temp_HRPos
        Temp_HRPos = nil
        local randomcolor = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
        HRPos = place(Vector3.new(HRPos.X, HRPos.Y - 5, HRPos.Z), randomcolor)
        place(Vector3.new(HRPos.X - 5, HRPos.Y, HRPos.Z), randomcolor)
        place(Vector3.new(HRPos.X - 5, HRPos.Y, HRPos.Z - 5), randomcolor)
        place(Vector3.new(HRPos.X, HRPos.Y, HRPos.Z - 5), randomcolor)
        place(Vector3.new(HRPos.X + 5, HRPos.Y, HRPos.Z - 5), randomcolor)
        place(Vector3.new(HRPos.X + 5, HRPos.Y, HRPos.Z), randomcolor)
        place(Vector3.new(HRPos.X + 5, HRPos.Y, HRPos.Z + 5), randomcolor)
        place(Vector3.new(HRPos.X, HRPos.Y, HRPos.Z + 5), randomcolor)
        place(Vector3.new(HRPos.X - 5, HRPos.Y, HRPos.Z + 5), randomcolor)
    end,
    ["LARGE_PLATE_PLACED_ON_PLAYER"] = function()
        local target = countdown(getgenv().BRS_Settings.COUNTDOWN, "A large plate will be placed on a random player.", 1)
        local Temp_HRPos = target.Character.HumanoidRootPart.Position
        local HRPos = Temp_HRPos
        Temp_HRPos = nil
        local randomcolor = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
        HRPos = place(Vector3.new(HRPos.X, HRPos.Y - 5, HRPos.Z), randomcolor)
        place(Vector3.new(HRPos.X - 5, HRPos.Y, HRPos.Z), randomcolor)
        place(Vector3.new(HRPos.X - 5, HRPos.Y, HRPos.Z - 5), randomcolor)
        place(Vector3.new(HRPos.X, HRPos.Y, HRPos.Z - 5), randomcolor)
        place(Vector3.new(HRPos.X + 5, HRPos.Y, HRPos.Z - 5), randomcolor)
        place(Vector3.new(HRPos.X + 5, HRPos.Y, HRPos.Z), randomcolor)
        place(Vector3.new(HRPos.X + 5, HRPos.Y, HRPos.Z + 5), randomcolor)
        place(Vector3.new(HRPos.X, HRPos.Y, HRPos.Z + 5), randomcolor)
        place(Vector3.new(HRPos.X - 5, HRPos.Y, HRPos.Z + 5), randomcolor)
        place(Vector3.new(HRPos.X - 8, HRPos.Y, HRPos.Z), randomcolor)
        place(Vector3.new(HRPos.X + 8, HRPos.Y, HRPos.Z), randomcolor)
        place(Vector3.new(HRPos.X, HRPos.Y, HRPos.Z - 8), randomcolor)
        place(Vector3.new(HRPos.X, HRPos.Y, HRPos.Z + 8), randomcolor)
        place(Vector3.new(HRPos.X + 8, HRPos.Y, HRPos.Z + 8), randomcolor)
        place(Vector3.new(HRPos.X - 8, HRPos.Y, HRPos.Z + 8), randomcolor)
        place(Vector3.new(HRPos.X + 8, HRPos.Y, HRPos.Z - 8), randomcolor)
        place(Vector3.new(HRPos.X - 8, HRPos.Y, HRPos.Z - 8), randomcolor)
        place(Vector3.new(HRPos.X - 5, HRPos.Y, HRPos.Z - 8), randomcolor)
        place(Vector3.new(HRPos.X + 5, HRPos.Y, HRPos.Z + 8), randomcolor)
        place(Vector3.new(HRPos.X - 5, HRPos.Y, HRPos.Z + 8), randomcolor)
        place(Vector3.new(HRPos.X + 5, HRPos.Y, HRPos.Z - 8), randomcolor)
        place(Vector3.new(HRPos.X - 8, HRPos.Y, HRPos.Z - 5), randomcolor)
        place(Vector3.new(HRPos.X + 8, HRPos.Y, HRPos.Z + 5), randomcolor)
        place(Vector3.new(HRPos.X - 8, HRPos.Y, HRPos.Z + 5), randomcolor)
        place(Vector3.new(HRPos.X + 8, HRPos.Y, HRPos.Z - 5), randomcolor)
    end
}
