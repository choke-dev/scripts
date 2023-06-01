local Services  = setmetatable({}, {
    __index = function(self, key)
        return game.GetService(game, key)
    end
})

--=[ Configuration ]=--
getgenv().BlockateBot_Settings = {
    Bot_Name = "BlockBot",
    Commands_FilePath = "./Blockate/Bot/Commands.lua",
    Commands_Prefix = ".",
    
    PermissionLevels = {
        [Services.Players.LocalPlayer.UserId] = 5
    },

    CHATGPT_API_KEY = "" -- join this server: https://discord.gg/pawan-krd-1055397662976905229, go to #bot, type /key and paste it here
}

--=[ ! DO NOT EDIT ANYTHING BELOW THIS LINE ! ]=--

getgenv().BlockateBot_Internal = {
    CommandsTable = loadstring(game:HttpGet("https://raw.githubusercontent.com/choke-dev/scripts/main/Blockate/BlockBot/Commands.lua"))(),
    --CommandsTable = loadstring(readfile(getgenv().BlockateBot_Settings.Commands_FilePath))(),
    Connections = {},
}

--=[ Functions ]=--
function sayMessage(text, includeBotName, user)
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

function commandHandler(user, message)
    local commandName = message:sub(#getgenv().BlockateBot_Settings.Commands_Prefix + 1, #message):split(" ")[1]
    local commandArgs = message:sub(#getgenv().BlockateBot_Settings.Commands_Prefix + #commandName + 2, #message):split(" ")

    local command = getgenv().BlockateBot_Internal.CommandsTable[commandName]
    local permissionLevel = getgenv().BlockateBot_Settings.PermissionLevels[user.UserId]

    if not command then return end
    
    if permissionLevel < command["Permission"] then
        --sayMessage("You do not have permission to use this command.", true)
        return
    end

    command["Function"](user, commandArgs)
end

--=[ Internal Functions ]=--
function HookPlayerChat(Player)
    if Player ~= Services.Players.LocalPlayer then
        getgenv().BlockateBot_Settings.PermissionLevels[Player.UserId] = 1
    end
    local PlayerChatted_Connection = Player.Chatted:Connect(function(Message)
        if Message:sub(1, #getgenv().BlockateBot_Settings.Commands_Prefix) ~= getgenv().BlockateBot_Settings.Commands_Prefix then return end

        commandHandler(Player, Message)
    end)
    table.insert(getgenv().BlockateBot_Internal.Connections, PlayerChatted_Connection)
end

--=[ Hooks ]=--
local PlayerAdded_Hook = Services.Players.PlayerAdded:Connect(function(Player)
    HookPlayerChat(Player)
end)

for _, Player in pairs(Services.Players:GetPlayers()) do
    HookPlayerChat(Player)
end

table.insert(getgenv().BlockateBot_Internal.Connections, PlayerAdded_Hook)
