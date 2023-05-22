--[[ Services ]]--
local Players = game:GetService("Players")

--[[ Modules ]]--
local GearIDs = loadstring(game:HttpGet("https://raw.githubusercontent.com/choke-dev/scripts/main/Dependencies/GearIDs.lua",true))()

--[[ Variables ]]--
local BuilderPerm = {}

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
    -- url encode the whole message string
    message = message:gsub("([^%w ])", function(c)
        return ("%%%02X"):format(string.byte(c))
    end)
    pcall(function()
        game:GetService("ReplicatedStorage").Sockets.Command:InvokeServer("!shout "..message)
    end)
end

local function getTwoCorners(centerPosition:Vector3, size:number)
    local x = math.round(centerPosition.X - size)
    local y = math.round(centerPosition.Y - size)
    local z = math.round(centerPosition.Z - size)
    local x2 = math.round(centerPosition.X + size)
    local y2 = math.round(centerPosition.Y + size)
    local z2 = math.round(centerPosition.Z + size)
    return Vector3.new(x, y, z), Vector3.new(x2, y2, z2)
end

local getAxisString
for i,v in pairs(getgc()) do
    if type(v) == "function" and getfenv(v).script == game.ReplicatedStorage.Modules.BlockPosition then
        if getinfo(v).name == "getAxisString" then
            getAxisString = v
        end
    end
end

function toBlockateCoordinates(position)
    return ("%s %s %s/0"):format(getAxisString(position.X), getAxisString(position.Y), getAxisString(position.Z))
end 

local function place(blockateposition, color, material)
    task.spawn(function()
        -- i hate blockate coordinates
        blockateposition = tostring((math.round(blockateposition.X / 4)).." "..(math.round((blockateposition.Y) / 4)).."+ "..(math.round(blockateposition.Z / 4)).."/0")
        --blockateposition = toBlockateCoordinates(blockateposition)

	--[[
        local args = {
            [1] = blockateposition,
            [2] = {
                ["Reflectance"] = 0,
                ["CanCollide"] = true,
                ["Color"] = color,
                ["LightColor"] = Color3.fromRGB(248,248,248),
                ["Transparency"] = 0,
                ["Size"] = 2,
                ["Material"] = material or math.round(math.random(0, 35)),
                ["Shape"] = 1,
                ["Light"] = 0
            }
        }

        game:GetService("ReplicatedStorage"):WaitForChild("Sockets"):WaitForChild("Edit"):WaitForChild("Place"):InvokeServer(unpack(args))
	]]

        local block = game:GetService("ReplicatedStorage").Sockets.Edit.Place:InvokeServer(blockateposition, {
            ["Reflectance"] = 0,
            ["CanCollide"] = true,
            ["Color"] = color,
            ["LightColor"] = Color3.fromRGB(248,248,248),
            ["Transparency"] = 0,
            ["Size"] = 2,
            ["Material"] = material or math.random(0, 35),
            ["Shape"] = 1,
            ["Light"] = 0
        })
    end)
end

local function fill(centerPosition:Vector3, radius:number, color:Color3, material:number)
    local x, y = getTwoCorners(centerPosition, ((radius - 1) * 2))
    for x1 = x.X, y.X, 4 do
        for z1 = x.Z, y.Z, 4 do
            task.wait(0.02)
            place(Vector3.new(x1, centerPosition.Y - 4, z1), color, material)
        end
    end
end

local function getRandomPlayer()
    local players = Players:GetPlayers()
    local randomPlayer = players[math.random(1, #players)]
    if #Players:GetPlayers() == 1 then return Players.LocalPlayer end
    if table.find(getgenv().BRS_Settings.BLACKLISTED_PLAYERS, randomPlayer.UserId) then return getRandomPlayer() end
    return randomPlayer
end

local function countdown(text, eventType)
    for i = getgenv().BRS_Settings.COUNTDOWN, 0, -1 do
        shout(("[%s] %s"):format(i,text))
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

local function getRandomColor()
	return BrickColor.new(Color3.fromRGB(math.random(0,255),math.random(0,255),math.random(0,255)))
end

local function whisper(plrName, message)
    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/w "..plrName.." "..message, "All")
end

--[[ Main Events ]]--

task.spawn(function()
    while true do
        if getgenv().INTERNAL_STOPPED then break end
        task.wait(1)
        for i,v in pairs(BuilderPerm) do
            BuilderPerm[i] = v - 1
            print(i.."'s builder time left: "..v)
            if v == 30 then
                whisper(i, "⚠️ You have 30 seconds remaining until your builder permission expires.")
            elseif v == 15 then
                whisper(i, "❕ You have 15 seconds remaining until your builder permission expires.")
            elseif v == 10 then
                whisper(i, "❗ You have 10 seconds remaining until your builder permission expires.")
            elseif v == 5 then
                whisper(i, "❗❗ You have 5 seconds remaining until your builder permission expires.")
            elseif v <= 0 then
                whisper(i, "❌ Your builder permission has expired.")
                runCommand("!perm "..i.." visitor")
                BuilderPerm[i] = nil
            end
        end
    end
end)

return {
    --[[ Player Events ]]--
    ["RANDOM_PLAYER_KILLED"] = function()
        local target = countdown("A random player will die.", 1)
        runCommand("!kill "..target.Name)
    end,
    ["RANDOM_PLAYER_GETS_SWORD"] = function()
        local target = countdown("A random player will get a sword.", 1)
        runCommand("!gear "..target.Name.." sword")
    end,
    ["RANDOM_PLAYER_FLINGED"] = function()
        local target = countdown("A random player will be flung.", 1)
        runCommand("!fling "..target.Name)
    end,
    ["RANDOM_PLAYER_TRIPPED"] = function()
        local target = countdown("A random player will be tripped.", 1)
        runCommand("!trip "..target.Name)
    end,
    ["RANDOM_PLAYER_BALLED"] = function()
        local target = countdown("A random player will be balled.", 1)
        runCommand("!ball "..target.Name)
    end,
    ["RANDOM_PLAYER_HUBBED"] = function()
        if #Players:GetPlayers() < getgenv().BRS_Settings.EVENT_CONFIG.REQUIRED_AMOUNT_OF_PLAYERS_TO_ACTIVATE_HUB_EVENT then return end
        local target = countdown("A random player will be hubbed.", 1)
        runCommand("!hub "..target.Name)
    end,
    ["RANDOM_PLAYER_RECIEVES_GEAR"] = function()
        local target = countdown("A random player will receive a random gear.", 1)
        runCommand("!gear "..target.Name.." "..GearIDs[math.random(1, #GearIDs)])
    end,
    ["ALL_PLAYERS_TP_TO_PLAYER"] = function()
        local target = countdown("All players will be teleported to a random player.", 1)
        runCommand("!tp all "..target.Name)
    end,
    ["RANDOM_PLAYER_RECIEVES_FLIGHT"] = function()
        local target = countdown("A random player will be given flight.", 1)
        runCommand("!fly "..target.Name)
    end,
    ["RANDOM_PLAYER_RECIEVES_BUILDER"] = function()
        local target = countdown("A random player will be given [ 🔨 BUILDER ] permissions for [ "..getgenv().BRS_Settings.EVENT_CONFIG.BUILDER_PERM_DURATION.." ] seconds.", 1)
        runCommand("!perm "..target.Name.." builder")
        if BuilderPerm[target.Name] then
            BuilderPerm[target.Name] += getgenv().BRS_Settings.EVENT_CONFIG.BUILDER_PERM_DURATION
            whisper(target.Name, "🍀 Your builder permission timer has been extended by +60 seconds!")
        else
            BuilderPerm[target.Name] = getgenv().BRS_Settings.EVENT_CONFIG.BUILDER_PERM_DURATION
            whisper(target.Name, "🔨 You recieved builder permissions for "..getgenv().BRS_Settings.EVENT_CONFIG.BUILDER_PERM_DURATION.." seconds!")
        end
    end,

    --[[ World Events ]]--
    ["MODIFY_GRAVITY"] = function()
        local gravity = countdown("The world gravity is changing!", 3)
        --[[for i = 1, 6 do
            shout("Choosing new world gravity: "..math.random(10, 200))
            task.wait(0.5)
        end]]
        shout("New world gravity: "..gravity)
        runCommand("!gravity "..gravity)
    end,
    ["FLASHBANG"] = function()
        countdown("A flashbang is about to be thrown!", 2)
        task.spawn(function()
            runCommand("!filter brightness 1")
            for i = 0.9, 0, -0.1 do
                task.wait(0.3)
                runCommand("!filter brightness "..i)
            end
            runCommand("!filter brightness 0") -- for good measure
        end)
    end,
    ---[[[ Plate Events ]]]---
    ["SMALL_PLATE_PLACED_ON_PLAYER"] = function()
        local target = countdown("A small plate will be placed on a random player.", 1)
        task.spawn(function()
            local HRPos = target.Character.HumanoidRootPart.Position
            local randomcolor = getRandomColor()
            local randommaterial = math.random(1, 35)
            place(Vector3.new(HRPos.X, HRPos.Y - 4, HRPos.Z), randomcolor, randommaterial)
        end)
    end,
    ["PLATE_PLACED_ON_PLAYER"] = function()
        local target = countdown("A plate will be placed on a random player.", 1)
        task.spawn(function()
            local HRPos = target.Character.HumanoidRootPart.Position
            local randomcolor = getRandomColor()
            local randommaterial = math.random(1, 35)
            place(Vector3.new(HRPos.X, HRPos.Y - 4, HRPos.Z), randomcolor, randommaterial)
            fill(HRPos, 3, randomcolor, randommaterial)
        end)
    end,
    ["LARGE_PLATE_PLACED_ON_PLAYER"] = function()
        local target = countdown("A large plate will be placed on a random player.", 1)
        task.spawn(function()
            local HRPos = target.Character.HumanoidRootPart.Position
            local randomcolor = getRandomColor()
            local randommaterial = math.random(1, 35)
            place(Vector3.new(HRPos.X, HRPos.Y - 4, HRPos.Z), randomcolor, randommaterial)
            fill(HRPos, 5, randomcolor, randommaterial)
        end)
    end,
    ["HUGE_PLATE_PLACED_ON_PLAYER"] = function()
        local target = countdown("A HUGE plate will be placed on a random player.", 1)
        task.spawn(function()
            local HRPos = target.Character.HumanoidRootPart.Position
            local randomcolor = getRandomColor()
            local randommaterial = math.random(1, 35)
            place(Vector3.new(HRPos.X, HRPos.Y - 4, HRPos.Z), randomcolor, randommaterial)
            fill(HRPos, 7, randomcolor, randommaterial)
        end)
    end,
}

--[[
    ["MODIFY_FOG"] = function()
        local fog = countdown("The fog radius is changing!", 2)
        for i = 1, 6 do
            shout("Choosing new fog radius: "..math.random(300, 600))
            task.wait(0.3)
        end
        shout("New fog radius: "..fog)
        runCommand("!fog "..fog)
    end,
]]
