--==[ CONFIG ]==--
getgenv().BLOCKATEPLACE_CONFIG = {
    TIME_UNTIL_PAINT = 30,
}

--==[ INTERNAL VARIABLES ]==--
getgenv().BLOCKATEPLACE_INTERNALVARIABLES = {
    PLAYERS_ON_COOLDOWN = {},
    PLAYERS_ON_WHISPER_COOLDOWN = {},
    BLOCK_COLOR_DATA = {},
    PAINTBUCKET_GEAR_ID = 18474459
}

--==[ SERVICES ]==--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--==[ VARIABLES ]==--
local LocalPlayer = Players.LocalPlayer

--==[ FUNCTIONS ]==
local function runCommand(command)
    if typeof(command) ~= "string" then return error("Command must be a string") end
    ReplicatedStorage.Sockets.Command:InvokeServer(unpack(args))
end

local function whisperPlayer(playerName, message)
    ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(`/w {playerName} {message}`, "All")
end

local function paintBlock(block, color)
    task.spawn(function()
        local success, err = pcall(function()
            LocalPlayer.Character.PaintBucket.Remotes.ServerControls:InvokeServer("PaintPart", { ["Part"] = block, ["Color"] = color })
        end)
    
        if not success then
            warn("[paintBlock] "..err)
        end
    end)
end

local function canPlayerPaint(player)
    if getgenv().BLOCKATEPLACE_INTERNALVARIABLES.PLAYERS_ON_COOLDOWN[player.UserId] then
        return false
    end
    return true
end

local function addPlayerToCooldown(player)
    getgenv().BLOCKATEPLACE_INTERNALVARIABLES.PLAYERS_ON_COOLDOWN[player.UserId] = getgenv().BLOCKATEPLACE_CONFIG.TIME_UNTIL_PAINT
end

local function getBlockColor(block)
    return getgenv().BLOCKATEPLACE_INTERNALVARIABLES.BLOCK_COLOR_DATA[block]
end

local function updateBlockColor(block, color)
    getgenv().BLOCKATEPLACE_INTERNALVARIABLES.BLOCK_COLOR_DATA[block] = color
end

local function resolvePlayer(playerNameOrUserId)
    local inputType = typeof(playerNameOrUserId)

    if inputType == "string" then
        return Players:FindFirstChild(playerNameOrUserId) or false
    end

    if inputType == "number" then
        return Players:GetPlayerByUserId(playerNameOrUserId) or false
    end

    return error("playerName must be a string or number")
end

--==[ EVENTS ]==--
local function onPlayerPaintedBlock(playerName, block)
    local player = resolvePlayer(playerName)

    if not canPlayerPaint(player) then
        -- Undo Changes
        paintBlock(block, getgenv().BLOCKATEPLACE_INTERNALVARIABLES.BLOCK_COLOR_DATA[block])
        return
    end

    if playerName ~= LocalPlayer.Name then
        paintBlock(block, block.Color) -- change ownership to localplayer
        addPlayerToCooldown(player)
        print(playerName.." is now on cooldown.")
        whisperPlayer(playerName, "❗ You are now on cooldown for the next "..getgenv().BLOCKATEPLACE_CONFIG.TIME_UNTIL_PAINT.." seconds.")
        updateBlockColor(block, block.Color)
        print("Updated "..block.Name.."'s color to "..tostring(block.Color))
    end
end

local function onPainterChangedBlock(block)
    local painter = block:FindFirstChild("_Painter").Value
    if painter == LocalPlayer.Name then return end
    paintBlock(block, getBlockColor(block))
end

local function onBlockColorChanged(block)
    block:GetPropertyChangedSignal("Color"):Connect(function()
        local painter = block:FindFirstChild("_Painter") -- _Painter is a StringValue containing the Player Name of the player who painted the block
        if not painter then return end
        painter:GetPropertyChangedSignal("Value"):Wait()
        onPlayerPaintedBlock(painter.Value, block)
    end)
end

workspace.Blocks.ChildAdded:Connect(function(block)
    onBlockColorChanged(block)
    updateBlockColor(block, block.Color)
end)

workspace.Blocks.DescendantAdded:Connect(function(object)
    if object:IsA("StringValue") and object.Name == "_Painter" then
        onPainterChangedBlock(object.Parent)
    end
end)

for _, block in pairs(workspace.Blocks:GetChildren()) do
    onBlockColorChanged(block)
    updateBlockColor(block, block.Color)
end

for _, block in pairs(workspace.Blocks:GetDescendants()) do
    if block:IsA("StringValue") and block.Name == "_Painter" then
        onPainterChangedBlock(block.Parent)
    end
end

--==[ COOLDOWN LOOP ]==--
task.spawn(function()
    while task.wait(2) do
        -- check if there are any _Painter objects that does not have LocalPlayer.Name as the value
        for _, object in pairs(workspace.Blocks:GetDescendants()) do
            if object:IsA("StringValue") and object.Name == "_Painter" then
                onPainterChangedBlock(object.Parent)
            end
        end
    end
end)

while task.wait(1) do
    for playerUserId, cooldownSeconds in pairs(getgenv().BLOCKATEPLACE_INTERNALVARIABLES.PLAYERS_ON_COOLDOWN) do
        getgenv().BLOCKATEPLACE_INTERNALVARIABLES.PLAYERS_ON_COOLDOWN[playerUserId] -= 1

        if getgenv().BLOCKATEPLACE_INTERNALVARIABLES.PLAYERS_ON_COOLDOWN[playerUserId] <= 0 then
            getgenv().BLOCKATEPLACE_INTERNALVARIABLES.PLAYERS_ON_COOLDOWN[playerUserId] = nil
            local player = resolvePlayer(playerUserId)

            if not player then 
                warn(playerUserId.." left before their cooldown ended.")
                return
            end

            print(player.Name.." is no longer on cooldown.")
            whisperPlayer(player.Name, "✅ You can now paint again!")
        end
    end
end
