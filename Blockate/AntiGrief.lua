--[[

          ⚠️ WARNING ⚠️
    i would advise not using this

    Blockate Anti-Grief

    This Script Prevents These Types of Griefing:

    ✅ Block Deletion
    ✅ Paint Griefing
    TBA: Command-based griefing (!warp, !kill, !cannon, etc.)

    HOW TO USE:
    1. Run !logs
    2. Run script
    3. Enjoy
]]

-- // Configuration \\ --
getgenv().MAX_BLOCK_DELETE = 55 -- how many blocks have to be deleted per 2 seconds for the check to trigger
getgenv().MAX_BLOCK_PAINT = 490 -- how many blocks have to be painted per 2 seconds for the check to trigger
getgenv().MAX_BLOCK_CHANGED = 55 -- how many !warp, !cannon commands have to be run per 2 seconds on a block for the check to trigger
getgenv().MAX_CHANCES = 3 -- how many times does the person need to be hubbed before they get banned

-- // Services \\ --
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- // Setup \\ --
if not isfolder("./BlockateAntiGrief") then
    makefolder("./BlockateAntiGrief")
end
if not isfile("./BlockateAntiGrief/GrieferList.json") then
    writefile("./BlockateAntiGrief/GrieferList.json", "{}")
end

-- // Variables \\ --

local playerDestroyCount = {}
local playerPaintCount = {}
local grieferList = HttpService:JSONDecode(readfile("./BlockateAntiGrief/GrieferList.json"))

-- // Functions \\ --
local function shout(message)
    game:GetService("ReplicatedStorage").Sockets.Command:InvokeServer("!shout "..message)
end

local function ban(playerName, reason)
    if reason == nil then reason = "No reason given." end
    game:GetService("ReplicatedStorage").Sockets.Command:InvokeServer("!ban "..playerName)
    shout("\n\n\n\n\n\n\n✅ Banned Player: "..playerName.." with reason: "..reason)
    return true
end

local function hub(playerName, reason)
    if reason == nil then reason = "No reason given." end
    local response = game:GetService("ReplicatedStorage").Sockets.Command:InvokeServer("!hub "..playerName)
    print(response)
    if response:find("Hubbed") then
        shout("\n\n\n\n\n\n\n✅ Hubbed Player: "..playerName.." with reason: "..reason..".\nThey have "..grieferList[person].."/"..getgenv().MAX_CHANCES.." chances left until they get banned.")
        return true
    else
        shout("\n\n\n\n\n\n\n❗ Failed to hub player: "..playerName)
        return false
    end
end

local function increment(person)
    if not grieferList[person] then
        grieferList[person] = 0
    end
    grieferList[person] += 1
    writefile("./BlockateAntiGrief/GrieferList.json", HttpService:JSONEncode(grieferList))
    if grieferList[person] >= getgenv().MAX_CHANCES then
        ban(person, "Griefer")
    end
end

-- // Events \\ --
Players.LocalPlayer.PlayerGui:WaitForChild("MainGUI"):WaitForChild("Logs").Visible = true -- opens the logs gui so the event below wont freak out and hub/ban randoms
shout("\n\n\n\n\n\n\nBlockate Anti-Grief Started.")
Players.LocalPlayer.PlayerGui.MainGUI.Logs.LogsList.ChildAdded:Connect(function(child)
    if string.find(child.Text, "destroyed") then
        local Args = child.Text:split(" ")
        local player = Args[1]

        playerDestroyCount[player] = playerDestroyCount[player] + 1
        print("Block deleted by "..player..", their destroy count per two seconds is currently: "..playerDestroyCount[player])
    elseif string.find(child.Text, "painted") then
        local Args = child.Text:split(" ")
        local player = Args[1]
        local paintedBlocks = Args[3] == "a" and 1 or Args[3]
        playerPaintCount[player] = playerPaintCount[player] + paintedBlocks
        print("Block painted by "..player..", their paint count per two seconds is currently: "..playerPaintCount[player])
    end
end)

Players.PlayerAdded:Connect(function(player)
    pcall(function()
        if grieferList[player.Name] >= getgenv().MAX_CHANCES then
            return ban(player.Name, "Griefer")
        end
    end)
    playerDestroyCount[player.Name] = 0
    playerPaintCount[player.Name] = 0
end)

for _,v in pairs(Players:GetPlayers()) do
    pcall(function()
        if grieferList[v.Name] >= getgenv().MAX_CHANCES then
            return ban(v.Name, "Griefer")
        end
    end)
    playerDestroyCount[v.Name] = 0
    playerPaintCount[v.Name] = 0
end

while task.wait(2) do
    Players.LocalPlayer.PlayerGui:WaitForChild("MainGUI"):WaitForChild("Logs").Visible = true
    -- // Block Destroy \\ --
    task.spawn(function()
        for k,v in pairs(playerDestroyCount) do
            if v >= getgenv().MAX_BLOCK_DELETE then
                shout("\n\n\n\n\n\n\n⚠️ Hubbing Potential Griefer: "..k)
                hub(k, "Potential Griefer")
                playerDestroyCount[k] = nil
                playerPaintCount[k] = nil
                increment(k)
                continue
            end
            playerDestroyCount[k] = 0
        end
    end)
    -- // Block Paint \\ -- 
    task.spawn(function()
        for k,v in pairs(playerPaintCount) do
            if v >= getgenv().MAX_BLOCK_PAINT then
                shout("\n\n\n\n\n\n\n⚠️ Hubbing Potential Griefer: "..k)
                hub(k, "Potential Griefer")
                playerPaintCount[k] = nil
                playerDestroyCount[k] = nil
                increment(k)
                continue
            end
            playerPaintCount[k] = 0
        end
    end)
end
