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

Commands.givestat = function(...)
    local arguments = {...}

    local statname = arguments[1]:lower()
    local method = arguments[2]

	local count = 0
	for i,v in pairs(workspace.Blocks:GetDescendants()) do
		if v.Name == statname and v:IsA("Folder") and v.Parent.Name == "StatGivers" then
			if method == "h" then
                Instance.new("Highlight", v.Parent.Parent.Parent).FillColor = Color3.new(0, 1, 0.384313)
            elseif method == "b" then
			    v.Parent.Parent.Parent.Position = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position
            else
                Module.feedback("h = Highlight Statgivers\nb = Bring Statgivers to you", "Popup", "Usage")
                return newMessage("Error: Invalid method!", colorRed) 
            end
			count = count + 1
		end
	end
	if count == 0 then
		return Module.feedback("No statgivers found for \""..statname.."\"", "Popup", "⚠ Warning ⚠")
	end
    return newMessage("Found "..count.." statgivers for \""..statname.."\"", colorGreen)
end

Commands.removestat = function(...)
    local arguments = {...}

    local statname = arguments[1]:lower()
    local method = arguments[2]

	local count = 0
	for i,v in pairs(workspace.Blocks:GetDescendants()) do
		if v.Name == statname and v:IsA("Folder") and v.Parent.Name == "StatRemovers" then
			if method == "h" then
                Instance.new("Highlight", v.Parent.Parent.Parent).FillColor = Color3.new(1, 0.380392, 0.380392)
            elseif method == "b" then
			    v.Parent.Parent.Parent.Position = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position
            else
                Module.feedback("h = Highlight Statremovers\nb = Bring Statremovers to you", "Popup", "Usage")
                return newMessage("Error: Invalid method!", colorRed) 
            end
			count = count + 1
		end
	end
	if count == 0 then
		return Module.feedback("No statremovers found for \""..statname.."\"", "Popup", "⚠ Warning ⚠")
	end
    return newMessage("Found "..count.." statremovers for \""..statname.."\"", colorRed)
end

Commands.printsigns = function(...)
    local foundwords = {}
    warn("================START WORLD SIGNS=====================")
    for i,v in pairs(workspace.Blocks:GetDescendants()) do
        if v:IsA("StringValue") and v.Name == "Sign" and not table.find(foundwords, v.Value) then
            print(v.Value)
            table.insert(foundwords, v.Value)
            task.wait()
        end
    end
    warn("================END WORLD SIGNS=====================")
    return newMessage("Printed all signs in world.", colorGreen)
end

Commands.flybypass = function(...)
    if LoadedFlyBypass then return newMessage("Flight bypass already loaded.", colorRed) end
    local m = game:GetService("Players").LocalPlayer.PlayerScripts.AutoRun.Flight
    local blacklisted = {"StartFlight", "StopFlight"}
    getsenv(m).canControlFlight = function() return true end

    local old;
    old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        if not checkcaller() and getnamecallmethod() == "FireServer" and table.find(blacklisted, self.Name) then
           return
        end
        return old(self, ...)
    end))
    LoadedFlyBypass = true
    return newMessage("Flight bypass loaded.", colorGreen)
end

Commands.cmds = function(...)
    local TEMP_cmdslist = {}
    for i,v in pairs(Commands) do
        if i == "cmds" then continue end
        table.insert(TEMP_cmdslist, i)
    end
    newMessage("Command list shown.", colorGreen)
    return Module.feedback(table.concat(TEMP_cmdslist, "\n"), "Popup", "Commands")
end
-- // Command Loaded Notification \\ --
for i,v in pairs(Commands) do
    commandCount += 1
end
newMessage("Loaded "..commandCount.." command(s) in \""..gameName.."\".", colorGreen)
newMessage("Type \""..Prefix.."cmds\" for a list of commands.", colorGreen)

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