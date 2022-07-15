--[[

    Blockate Anti-Grief

    This Script Prevents These Types of Griefing:

    ✅ Block Deletion
    ✅ Paint Griefing
    TBA: Command-based griefing (!warp, !kill, !cannon, etc.)

    HOW TO USE:
    1. Run !logs
    2. Run script
    3. Enjoy

    made with a 🔥 passion and 💖
]]

-- // Configuration \\ --
getgenv().MAX_BLOCK_DELETE = 80 -- how many blocks have to be deleted per 2 seconds for the check to trigger
getgenv().MAX_BLOCK_PAINT = 490 -- how many blocks have to be painted per 2 seconds for the check to trigger
getgenv().MAX_BLOCK_CHANGED = 80 -- how many !warp, !cannon commands have to be run per 2 seconds on a block for the check to trigger

-- // Services \\ --
local Players = game:GetService("Players")

-- // Functions \\ --
local function shout(message)
    game:GetService("ReplicatedStorage").Sockets.Command:InvokeServer("!shout "..message)
end

local function ban(playerName, reason)
    if reason == nil then reason = "No reason given." end
    local response = game:GetService("ReplicatedStorage").Sockets.Command:InvokeServer("!ban "..playerName)
    if response:find("Banned") then
        shout("\n\n\n\n\n\n\n\n✅ Banned Player: "..playerName.." with reason: "..reason)
    else
        shout("\n\n\n\n\n\n\n\n⚠️ Failed to ban player: "..playerName)
    end
end

local function hub(playerName, reason)
    if reason == nil then reason = "No reason given." end
    local response = game:GetService("ReplicatedStorage").Sockets.Command:InvokeServer("!hub "..playerName)
    if response:find("Hubbed") then
        shout("\n\n\n\n\n\n\n\n✅ Hubbed Player: "..playerName.." with reason: "..reason)
    else
        shout("\n\n\n\n\n\n\n\n⚠️ Failed to hub player: "..playerName)
    end
end

-- // Variables \\ --

local playerDestroyCount = {}
local playerPaintCount = {}

-- // Events \\ --
Players.LocalPlayer.PlayerGui:WaitForChild("MainGUI"):WaitForChild("Logs").Visible = true -- opens the logs gui so the event below wont freak out and hub/ban randoms

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
    playerDestroyCount[player.Name] = 0
    playerPaintCount[player.Name] = 0
end)

for _,v in pairs(Players:GetPlayers()) do
    playerDestroyCount[v.Name] = 0
    playerPaintCount[v.Name] = 0
end

shout("\n\n\n\n\n\n\n\n✅ Blockate Anti-Grief Initialized.")

while task.wait(2) do
    -- // Block Destroy \\ --
    task.spawn(function()
        for k,v in pairs(playerDestroyCount) do
            print("Destroy Count", k,v, "\n")
            if v >= getgenv().MAX_BLOCK_DELETE then
                shout("\n\n\n\n\n\n\n\n⚠️ Hubbing Potential Griefer: "..k)
                hub(k, "Potential Griefer (Mass Block Deletion)")
                playerDestroyCount[k] = nil
                playerPaintCount[k] = nil
                continue
            end
            playerDestroyCount[k] = 0
        end
    end)
    -- // Block Paint \\ --
    task.spawn(function()
        for k,v in pairs(playerPaintCount) do
            print("Paint Count", k,v, "\n")
            if v >= getgenv().MAX_BLOCK_PAINT then
                shout("\n\n\n\n\n\n\n\n⚠️ Hubbing Potential Griefer: "..k)
                hub(k, "Potential Griefer (Mass Block Painting)")
                playerPaintCount[k] = nil
                playerDestroyCount[k] = nil
                continue
            end
            playerPaintCount[k] = 0
        end
    end)
end
