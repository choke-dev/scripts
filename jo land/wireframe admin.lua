local Module = require(game:GetService("ReplicatedStorage").Modules.Client.LocalCommands)
local Players = game:GetService("Players")
local gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
local colorRed = Color3.new(1,0.3294117647058824,0.3294117647058824)
local colorGreen = Color3.new(0.3607843137254902,1,0.596078431372549)
local commandCount = 0
local Prefix = ";"

-- // Variables \\ --
local LoadedFlyBypass = false

-- // Functions \\ --
function newMessage(msg, clr)
    game.StarterGui:SetCore("ChatMakeSystemMessage", { 
        Text = "⌜ WIREFRAME ADMIN ⌟ "..msg, 
        Color = clr, 
        Font = Enum.Font.SourceSansBold, 
        FontSize = Enum.FontSize.Size24,
        TextStrokeTransparency = 0.75
    })
end

function findPlayer(string)
    local lowercase = string:lower()
    local result
    for _, plr in next, Players:GetPlayers() do
        if plr.Name:sub(1,#string):lower() == lowercase then
            result = plr
            return plr
        end
    end
    if not result then
        return newMessage("Player not found!", colorRed)
    end
end

function checkPrefix(message)
    if message:sub(1,1) == Prefix then
        return true
    end
end

-- // Commands \\ --
Commands = {}



-- // Command Handler \\ --
Players.LocalPlayer.Chatted:Connect(function(message)
    message = message:lower()
    if not checkPrefix(message) then return end

    local raw_args = string.split(message, " ")
    local args = {}
    local RequestedCommand = raw_args[1]:sub(2)
	
    for i = 2, #raw_args do
        table.insert(args, raw_args[i])
    end

    if Commands[RequestedCommand] then
        Commands[RequestedCommand](args)
        table.clear(args)
    else
        table.clear(args)
        return newMessage("\""..RequestedCommand.."\" is not a valid command.", colorRed)
    end
end)