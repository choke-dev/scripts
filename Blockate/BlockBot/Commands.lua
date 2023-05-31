local Services  = setmetatable({}, {
    __index = function(self, key)
        return game.GetService(game, key)
    end
})

--=[ Variables ]=--
local Commands = {}
local LocalPlayer = Services.Players.LocalPlayer
local PermissionDictionary = {
    [5] = "Owner",
    [4] = "Admin",
    [3] = "Trusted",
    [2] = "Whitelisted",
    [1] = "Guest",
}

--=[ Functions ]=--
local function sayMessage(text, includeBotName, user)
    assert(type(text) == "string", "text must be a string")

    if includeBotName then
        text = "[ " .. getgenv().BlockateBot_Settings.Bot_Name .. " ] " .. text
    end

    if user then
        Services.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(text, "To " .. user.Name)
    else
        Services.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(text, "All")
    end
end

local function writeToFile(player, fileName, content)
    local folderName = "./Blockate/Bot/PlayerFiles/"..player.Name
    if not isfolder(folderName) then
        makefolder(folderName)
    end
    writefile(folderName.."/"..fileName, content)
end

local function readFromFile(player, fileName)
    local folderPath = "./Blockate/Bot/PlayerFiles/"..player.Name
    local filePath = folderPath.."/"..fileName
    if isfile(filePath) then
        return readfile(filePath)
    else
        return "File not found!"
    end
end

local function findPlayerByName(name)
    local Players = Services.Players:GetPlayers()
    local searchTerm = string.lower(name)
    local isDisplayNameSearch = true

    if string.sub(searchTerm, 1, 1) == "@" then
        isDisplayNameSearch = false
        searchTerm = string.sub(searchTerm, 2) -- Remove "@" symbol from the search term
    end

    for _, player in ipairs(Players) do
        local playerName = isDisplayNameSearch and player.DisplayName or player.Name
        if string.find(string.lower(playerName), searchTerm) then
            return player
        end
    end
    return nil
end

local function getCommandInfo(commandName)
    local command = Commands[commandName]
    if command then
        local description = command["Description"] or "No description provided."
        local usage = command["Usage"] or "No usage provided."
        return description, usage
    else
        return "Command not found.", ""
    end
end


--=[ Commands ]=--


--=[ Guest Commands ]=--
Commands["help"] = {
    ["Description"] = "Lists info about every command.",
    ["Usage"] = "help (command)",
    ["Permission"] = 1,
    ["Function"] = function(Player, Args)
        -- should only show commands that the player has permission to use, but only list the command name.
        -- if a command is specified, show the description and usage
        -- must not use any newlines or the server will reject the message
        local message = "Available commands for " .. Player.DisplayName .. " (@" .. Player.Name .. "): "
        if Args[1] and not Args[1]:match("^%s*$") then
            local description, usage = getCommandInfo(Args[1])
            message = "Description: " .. description .. " | Usage: " .. usage
            return sayMessage(message, true)
        else
            for commandName, command in pairs(Commands) do
                if command["Permission"] <= getgenv().BlockateBot_Settings.PermissionLevels[Player.UserId] then
                    message = message .. commandName .. ", "
                end
            end
            message = string.sub(message, 1, -3) -- Remove the last comma
            return sayMessage(message, true)
        end
    end
}

Commands["sourcecode"] = {
    ["Description"] = "View the source code for the bot.",
    ["Usage"] = "sourcecode",
    ["Permission"] = 1,
    ["Function"] = function(Player, Args)
        sayMessage("Visit this link in your browser to view the source code: shlink.choke.dev/Blockate_BotSrc", true)
    end
}


--=[ Whitelisted Commands ]=--
Commands["jump"] = {
    ["Permission"] = 2,
    ["Function"] = function(Player, Args)
        sayMessage(Player.Name.." requested me to jump!", true)
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
}

Commands["write"] = {
    ["Description"] = "Writes <textContent> to <fileName>.",
    ["Usage"] = "write <fileName> <textContent>",
    ["Permission"] = 2,
    ["Function"] = function(Player, Args)
        if Args[1] and Args[2] then
            local fileName = Args[1]
            table.remove(Args, 1)
            local content = table.concat(Args, " ")
            writeToFile(Player, fileName, content)
            sayMessage("Successfully wrote to file: " .. fileName, true)
        else
            sayMessage("Please specify a file name and content! Usage: write <fileName> <textContent>", true)
        end
    end
}

Commands["read"] = {
    ["Description"] = "Reads <fileName>.",
    ["Usage"] = "read <fileName>",
    ["Permission"] = 2,
    ["Function"] = function(Player, Args)
        if Args[1] then
            local fileName = Args[1]
            local content = readFromFile(Player, fileName)
            sayMessage("File content for " .. fileName .. ": " .. content, true)
        else
            sayMessage("File not found.", true)
        end
    end
}


--=[ Trusted Commands ]=--
Commands["pathfind"] = {
    ["Description"] = "Pathfinds to <player>.",
    ["Usage"] = "pathfind <player>",
    ["Permission"] = 3,
    ["Function"] = function(Player, Args)
        local TargetPlayer = findPlayerByName(Args[1])
        if not Args[1] then
            sayMessage("Player was not specified.", true)
            return
        end

        if not TargetPlayer then
            sayMessage("Player was not found.", true)
            return
        end

        if TargetPlayer == LocalPlayer then
            sayMessage("You cannot pathfind to yourself.", true)
            return
        end

        local PathfindingService = Services.PathfindingService
        local Path = PathfindingService:CreatePath()
        Path:ComputeAsync(LocalPlayer.Character.HumanoidRootPart.Position, TargetPlayer.Character.HumanoidRootPart.Position)
        local waypoints = Path:GetWaypoints()
        for _, waypoint in pairs(waypoints) do
            LocalPlayer.Character.Humanoid:MoveTo(waypoint.Position)
            LocalPlayer.Character.Humanoid.MoveToFinished:Wait()
        end
    end
}

Commands["reset"] = {
    ["Description"] = "Resets the bot.",
    ["Usage"] = "reset",
    ["Permission"] = 3,
    ["Function"] = function(Player, Args)
        sayMessage("Resetting...", true)
        LocalPlayer.Character.Humanoid.Health = 0
    end
}

--=[ Owner Commands ]=--
Commands["perm"] = {
    ["Description"] = "Sets the <permissionLevel> of <player>.",
    ["Usage"] = "perm <player> <permissionLevel>",
    ["Permission"] = 5,
    ["Function"] = function(Player, Args)
        local TargetPlayer = findPlayerByName(Args[1])
        local permissionLevel = tonumber(Args[2])

        if not Args[1] then
            sayMessage("Player was not specified.", true)
            return
        end

        if not TargetPlayer then
            sayMessage("Player was not found.", true)
            return
        end

        if not permissionLevel then
            sayMessage("Permission level was not specified.", true)
            return
        end

        if permissionLevel < 1 or permissionLevel > 4 then
            sayMessage("Permission level must be between 1 and 4.", true)
            return
        end

        if TargetPlayer == LocalPlayer then
            sayMessage("You cannot change your own permission level.", true)
            return
        end

        local PermissionTable = getgenv().BlockateBot_Settings.PermissionLevels
        local PlayerPermissionLevel = PermissionTable[TargetPlayer.UserId]

        if PlayerPermissionLevel then
            PermissionTable[TargetPlayer.UserId] = permissionLevel
            sayMessage("Successfully updated " .. TargetPlayer.DisplayName .. " (@" .. TargetPlayer.Name .. ")'s permission level to " .. PermissionDictionary[permissionLevel] .. ".", true)
        else
            PermissionTable[TargetPlayer.UserId] = permissionLevel
            sayMessage("Successfully set " .. TargetPlayer.DisplayName .. " (@" .. TargetPlayer.Name .. ") permission level to: " .. PermissionDictionary[permissionLevel] .. ".", true)
        end
    end
}

Commands["update"] = {
    ["Description"] = "Updates the bot's commands file.",
    ["Usage"] = "update",
    ["Permission"] = 5,
    ["Function"] = function(Player, Args)
        sayMessage("Updating...", true)
        getgenv().BlockateBot_Internal.CommandsTable = loadstring(game:HttpGet("https://raw.githubusercontent.com/choke-dev/scripts/main/Blockate/BlockBot/Main.lua"))()
        -- getgenv().BlockateBot_Internal.CommandsTable = loadstring(readfile(getgenv().BlockateBot_Settings.Commands_FilePath))()
    end
}

Commands["stop"] = {
    ["Description"] = "Stops the bot.",
    ["Usage"] = "stop",
    ["Permission"] = 5,
    ["Function"] = function(Player, Args)
        sayMessage("Stopping...", true)
        for _, Connection in pairs(getgenv().BlockateBot_Internal.Connections) do
            Connection:Disconnect()
        end
        sayMessage("Stopped.", true)
    end
}

return Commands
