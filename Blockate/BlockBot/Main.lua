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
    
    Whitelisted_Users = {
        Services.Players.LocalPlayer.UserId
    }
}

local CommandsTable = loadstring(game:HttpGet("https://raw.githubusercontent.com/choke-dev/scripts/main/Blockate/BlockBot/Commands.lua"))()

--[[
if isfile(getgenv().BlockateBot_Settings.Commands_FilePath) then
    CommandsTable = loadstring(readfile(getgenv().BlockateBot_Settings.Commands_FilePath))()
else
    writefile(getgenv().BlockateBot_Settings.Commands_FilePath, game:HttpGet("foo.lua"))
    CommandsTable = loadstring(readfile(getgenv().BlockateBot_Settings.Commands_FilePath))()
end
]]

--=[ Functions ]=--
function commandHandler(user, message)
    local Arguments = message:split(" ")
    local Command = Arguments[1]:sub(#getgenv().BlockateBot_Settings.Commands_Prefix + 1)
    table.remove(Arguments, 1)

    if CommandsTable[Command] then
        CommandsTable[Command](user, Arguments)
    end
end

--=[ Internal Functions ]=--
function HookPlayerChat(Player)
    Player.Chatted:Connect(function(Message)
        if Message:sub(1, #getgenv().BlockateBot_Settings.Commands_Prefix) ~= getgenv().BlockateBot_Settings.Commands_Prefix then return end
        if not table.find(getgenv().BlockateBot_Settings.Whitelisted_Users, Player.UserId) then return end

        commandHandler(Player, Message)
    end)
end

--=[ Hooks ]=--
Services.Players.PlayerAdded:Connect(function(Player)
    HookPlayerChat(Player)
end)	

for _, Player in pairs(Services.Players:GetPlayers()) do
    HookPlayerChat(Player)
end

