local Services  = setmetatable({}, {
    __index = function(self, key)
        return game.GetService(game, key)
    end
})

local LocalPlayer = Services.Players.LocalPlayer

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


local CommandsModule = {}

CommandsModule["jump"] = function(Player, Args)
    sayMessage(Player.Name.." requested me to jump!", true)
    LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
end

CommandsModule["whitelist"] = function(Player, Args)
    if Player.UserId ~= LocalPlayer.UserId then return end
    
    if Args[1] == "add" then
        if Args[2] then
            local Player = findPlayerByName(Args[2])
            if Player then
                table.insert(getgenv().BlockateBot_Settings.Whitelisted_Users, Player.UserId)
                sayMessage("Added "..Player.DisplayName.." (@" .. Player.Name .. ") to the whitelist.", true)
            else
                sayMessage("Player not found!", true)
            end
        else
            sayMessage("Please specify a player!", true)
        end
    end
    
    if Args[1] == "remove" then
        if Args[2] then
            local Player = findPlayerByName(Args[2])
            if Player then
                for i, v in pairs(getgenv().BlockateBot_Settings.Whitelisted_Users) do
                    if v == Player.UserId then
                        table.remove(getgenv().BlockateBot_Settings.Whitelisted_Users, i)
                        sayMessage("Removed "..Player.DisplayName.." (@" .. Player.Name .. ") from the whitelist.", true)
                    end
                end
            else
                sayMessage("Player not found!", true)
            end
        else
            sayMessage("Please specify a player!", true)
        end
    end
end

CommandsModule["write"] = function(Player, Args)
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

CommandsModule["read"] = function(Player, Args)
    if Args[1] then
        local fileName = Args[1]
        local content = readFromFile(Player, fileName)
        sayMessage("File content for " .. fileName .. ": " .. content, true)
    else
        sayMessage("File not found.", true)
    end
end

CommandsModule["sourcecode"] = function(Player, Args)
    sayMessage("Visit this link in your browser to view the source code: shlink.choke.dev/Blockate_BotSrc", true)
end

return CommandsModule
