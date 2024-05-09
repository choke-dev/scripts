pcall(function()
    for _, Connection in pairs(getgenv().Connections) do
        Connection:Disconnect()
        Connection = nil
    end
end)

getgenv().CTF_Settings = {
    TimeUntilFlagReturn = 30,
    TimeUntilRestart = 10,
    CaptureLimit = 3,

    Team1 = {
        Name = "RED",
        Color = BrickColor.new("Bright red"),
    };
    Team2 = {
        Name = "BLUE",
        Color = BrickColor.new("Bright blue"),
    };
    Spectator = {
        Name = "Lobby",
        Color = BrickColor.new("Dark stone grey"),
    };
}

getgenv().CTF_Internal = {
    Team1 = {
        Flag = nil,
        DroppedFlag = nil,
        DroppedFlag_Connection = nil,
        isFlagTaken = false
    },
    Team2 = {
        Flag = nil,
        DroppedFlag = nil,
        DroppedFlag_Connection = nil,
        isFlagTaken = false
    },
    matchOver = false
}

--[[ Services ]]--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")

--[[ Variables ]]--
local LocalMouse = Players.LocalPlayer:GetMouse()
getgenv().Connections = {}
local Objects = {}
local Team1Flag = nil
local Team2Flag = nil
local FlagCarriers = {
    Team1 = nil,
    Team2 = nil,
}
local FlagCaptures = {
    Team1 = 0,
    Team2 = 0,
}
local isFlagTaken = {
    Team1 = false,
    Team2 = false,
}
local Colors = {
    ["Bright red"] = Color3.fromRGB(196.00000351667404, 40.00000141561031, 28.000000230968),
    ["Bright blue"] = Color3.fromRGB(13.000000175088644, 105.00000134110451, 172.00000494718552)
}
local Materials = {
    ["Plastic"] = 1,
    ["Brick"] = 2,
    ["Cobblestone"] = 3,
    ["Concrete"] = 4,
    ["CorrodedMetal"] = 5,
    ["DiamondPlate"] = 6,
    ["Fabric"] = 7,
    ["Foil"] = 8,
    ["Grass"] = 10,
    ["Ice"] = 11,
    ["Metal"] = 13,
    ["Neon"] = 14,
    ["Glass"] = 15,
    ["Pebble"] = 16,
    ["SmoothPlastic"] = 17,
    ["Sand"] = 18,
    ["Slate"] = 19,
    ["Wood"] = 20,
    ["WoodPlanks"] = 21,
    ["ForceField"] = 22,
    ["Asphalt"] = 23,
    ["Basalt"] = 24,
    ["CrackedLava"] = 25,
    ["Glacier"] = 26,
    ["Ground"] = 27,
    ["LeafyGrass"] = 28,
    ["Limestone"] = 29,
    ["Mud"] = 30,
    ["Pavement"] = 31,
    ["Rock"] = 32,
    ["Salt"] = 33,
    ["Sandstone"] = 34,
    ["Snow"] = 35
}

-- [[ Functions ]]--
local Feedback = require(ReplicatedStorage.Modules.Client.LocalCommands).feedback
local CheckPerm = require(ReplicatedStorage.Modules.Client.Functions.CheckPerm)

if not CheckPerm(2) then
    return Feedback("You need [ Admin+ ] permissions to run this script properly.", "AlsoChat")
end

function RunCommand(command)
    pcall(function()
            ReplicatedStorage:WaitForChild("Sockets"):WaitForChild("Command"):InvokeServer(command)
    end)
end

function EditBlock(Attribute, Block, Value)
    local args = {
        [1] = Attribute,
        [2] = Block,
        [3] = Value
    }
    
    pcall(function()
        game:GetService("ReplicatedStorage"):WaitForChild("Sockets"):WaitForChild("Edit"):WaitForChild("EditBlock"):FireServer(unpack(args))
    end)
end    

function Shout(Message)
    RunCommand("!shout "..Message)
end

function Place(Position, Properties)
    Position = math.round(Position.X / 4) .. " " .. math.round(Position.Y / 4) .. " " .. math.round(Position.Z / 4) .. "/0"
    return ReplicatedStorage:WaitForChild("Sockets"):WaitForChild("Edit"):WaitForChild("Place"):InvokeServer(Position, Properties)
end

function Delete(Block)
    pcall(function()
            ReplicatedStorage:WaitForChild("Sockets"):WaitForChild("Edit"):WaitForChild("Delete"):FireServer(Block)
    end)
end

function PaintBlock(Block, Properties, PropertiesToChange)
    local args = {
        [1] = {
            [1] = {
                [1] = Block,
                [2] = Block,
                [3] = Properties,
                [4] = 1,
                [5] = PropertiesToChange
            }
        }
    }
    
    pcall(function()
        game:GetService("ReplicatedStorage"):WaitForChild("Sockets"):WaitForChild("Edit"):WaitForChild("Paint"):FireServer(unpack(args))
    end)
end

function GameSetup()
    local Team1Flag = nil
    local Team2Flag = nil

    local SelectionBox = Instance.new("SelectionBox")
    SelectionBox.Color3 = BrickColor.new("Bright blue").Color
    SelectionBox.LineThickness = 0.1
    SelectionBox.Parent = workspace
    table.insert(Objects, SelectionBox)

    local Setup = RunService.RenderStepped:Connect(function()
        local Target = LocalMouse.Target
        if not Target then return end
        SelectionBox.Adornee = Target
    end)
    table.insert(getgenv().Connections, Setup)

    local function GetTeam1Flag()
        Feedback("Please select "..getgenv().CTF_Settings.Team1.Name.."'s flag.", "AlsoChat")
        LocalMouse.Button1Down:Wait()
        local TEMP_Team1Flag = LocalMouse.Target

        if not TEMP_Team1Flag then
            return GetTeam1Flag()
        end

        return TEMP_Team1Flag
    end

    local function GetTeam2Flag()
        Feedback("Please select "..getgenv().CTF_Settings.Team2.Name.."'s flag.", "AlsoChat")
        LocalMouse.Button1Down:Wait()
        local TEMP_Team2Flag = LocalMouse.Target

        if not TEMP_Team2Flag then
            return GetTeam2Flag()
        end

        if TEMP_Team2Flag == Team1Flag then
            Feedback("You cannot select the same flag twice.", "AlsoChat")
            return GetTeam2Flag()
        end

        return TEMP_Team2Flag
    end

    Team1Flag = GetTeam1Flag()
    Team2Flag = GetTeam2Flag()

    -- Cleanup
    for _,v in pairs(getgenv().Connections) do
        v:Disconnect()
    end

    for _,v in pairs(Objects) do
        v:Destroy()
    end

    Feedback("Game setup complete", "AlsoChat")
    
    return Team1Flag, Team2Flag
end

function ResetGame()
    -- reset captures
    FlagCaptures.Team1 = 0
    FlagCaptures.Team2 = 0

    -- reset flag carriers
    FlagCarriers.Team1 = nil
    FlagCarriers.Team2 = nil

    -- Reset Flag Visibility
    ToggleFlagVisibility(getgenv().CTF_Internal.Team1.Flag, true)
    ToggleFlagVisibility(getgenv().CTF_Internal.Team2.Flag, true)

    -- reset team names
    UpdateTeamName(getgenv().CTF_Settings.Team1.Color.Name, getgenv().CTF_Settings.Team1.Name)
    UpdateTeamName(getgenv().CTF_Settings.Team2.Color.Name, getgenv().CTF_Settings.Team2.Name)

    RunCommand("!team set all "..Teams[getgenv().CTF_Settings.Spectator.Name].TeamColor.Name)
    RunCommand("!kill others")
    getgenv().CTF_Internal.matchOver = false
end

function EvaluateTouched(Part)
    local PlayerHumanoid = Part.Parent:FindFirstChild("Humanoid") or nil
    if not PlayerHumanoid then return end

    local PlayerName = PlayerHumanoid.Parent
    local Player = Players[PlayerName.Name]

    return Player
end

function ToggleFlagVisibility(Flag, Visible)
    PaintBlock(Flag, {
        ["Reflectance"] = 0,
        ["CanCollide"] = true,
        ["Color"] = Color3.fromRGB(242.0000159740448, 243.00001591444016, 243.00001591444016),
        ["LightColor"] = Color3.fromRGB(242.0000159740448, 243.00001591444016, 243.00001591444016),
        ["Transparency"] = Visible and 0 or 1,
        ["Size"] = 1,
        ["Material"] = 1,
        ["Shape"] = 29,
        ["Light"] = 0
    }, {
        ["Transparency"] = true,
    })
end

function HandlePlayerLeave(Player)
    if FlagCarriers.Team1 == Player then
        ReturnFlag("Team1", "Team2")
    end

    if FlagCarriers.Team2 == Player then
        ReturnFlag("Team2", "Team1")
    end
end

function HandlePlayerTeamChange(Player)
    local Connection = Player:GetPropertyChangedSignal("Team"):Connect(function()
        if FlagCarriers.Team1 == Player then
            ReturnFlag("Team1", "Team2")
        end
    
        if FlagCarriers.Team2 == Player then
            ReturnFlag("Team2", "Team1")
        end
    end)

    table.insert(getgenv().Connections, Connection)
end

function ReturnFlag(Team, OppositeTeam)
    FlagCarriers[Team] = nil
    isFlagTaken[Team] = false
    Shout(getgenv().CTF_Settings[OppositeTeam].Name .. "'s flag has been returned to their base!")
    ToggleFlagVisibility(getgenv().CTF_Internal[OppositeTeam].Flag, true)
end

function DropFlag(PlayerDeathPosition, Team)
    local DroppedFlag = Place(PlayerDeathPosition, {
        ["Reflectance"] = 0,
        ["CanCollide"] = true,
        ["Color"] = Colors[getgenv().CTF_Settings[Team].Color.Name],
        ["LightColor"] = Colors[getgenv().CTF_Settings[Team].Color.Name],
        ["Transparency"] = 0,
        ["Size"] = 1,
        ["Material"] = 1,
        ["Shape"] = 29,
        ["Light"] = 0
    })
    return DroppedFlag
end

function HandlePlayerDeath(Player)
    local PlayerCharacter = Player.Character

    local function PlayerDeath(PlayerTeam, OppositeTeam)

        FlagCarriers[PlayerTeam] = nil

        local PlayerDeathPosition = PlayerCharacter:FindFirstChild("HumanoidRootPart").Position
        local DroppedFlag = DropFlag(PlayerDeathPosition, OppositeTeam)
        if not DroppedFlag then
            return ReturnFlag(PlayerTeam, OppositeTeam)
        end

        Shout(getgenv().CTF_Settings[OppositeTeam].Name .. "'s flag has been dropped!")

        -- use gettouchingparts to detect if the flag is picked up
        local DroppedFlag_Connection = RunService.RenderStepped:Connect(function()
            local DroppedFlagParts = DroppedFlag:GetTouchingParts()

            for _, Part in pairs(DroppedFlagParts) do
                HandleFlagTouch(Part, OppositeTeam, PlayerTeam, true, DroppedFlag)
            end

        end)
        table.insert(getgenv().Connections, DroppedFlag_Connection)
        getgenv().CTF_Internal[OppositeTeam].DroppedFlag_Connection = DroppedFlag_Connection
        getgenv().CTF_Internal[OppositeTeam].DroppedFlag = DroppedFlag

        task.spawn(function()
            local StartTime = tick()
            while true do
                if FlagCarriers[PlayerTeam] then
                    -- Flag has been picked up by team
                    pcall(function()
                        return Delete(DroppedFlag)
                    end)
                end
                if tick() - StartTime >= getgenv().CTF_Settings.TimeUntilFlagReturn then
                    -- Flag has not been picked up by the opposite team
                    -- Flag has been returned to the base
                    Delete(DroppedFlag)
                    return
                end

                EditBlock("sign", DroppedFlag, tostring(math.floor(getgenv().CTF_Settings.TimeUntilFlagReturn - (tick() - StartTime))) )
                task.wait(1)
            end
        end)
    end

    -- check hum state if its dead
    local DiedConnection
    local CharacterRemovingConnection

    DiedConnection = PlayerCharacter:WaitForChild("Humanoid").StateChanged:Connect(function(_OldState, NewState)
        if NewState ~= Enum.HumanoidStateType.Dead then return end
        -- check if flag carrier
        if FlagCarriers.Team1 == Player then
            PlayerDeath("Team1", "Team2")
        end

        if FlagCarriers.Team2 == Player then
            PlayerDeath("Team2", "Team1")
        end
        CharacterRemovingConnection:Disconnect()
        DiedConnection:Disconnect()
    end)

    -- detect if children removing from character
    CharacterRemovingConnection = PlayerCharacter.ChildRemoved:Connect(function(Child)
        if Child.Name ~= "HumanoidRootPart" then return end
        -- check if flag carrier
        
        if FlagCarriers.Team1 == Player then
            ReturnFlag("Team1", "Team2")
        end

        if FlagCarriers.Team2 == Player then
            ReturnFlag("Team2", "Team1")
        end
        CharacterRemovingConnection:Disconnect()
        DiedConnection:Disconnect()
    end)

    table.insert(getgenv().Connections, CharacterRemovingConnection)
    table.insert(getgenv().Connections, DiedConnection)
end

function UpdateTeamName(TeamColorName, Name)
    ReplicatedStorage:WaitForChild("Sockets"):WaitForChild("Command"):InvokeServer("!team name "..TeamColorName.." "..Name)
end

function HandleFlagTouch(Hit: Instance, teamFlagName: string, oppositeTeamFlagName: string, isDroppedFlag: boolean, droppedFlag: Instance)
    if getgenv().CTF_Internal.matchOver then return end
    
    local Player = EvaluateTouched(Hit)

    if not Player then return end

    -- Is player alive?
    if not Player.Character then return end
    if Player.Character:FindFirstChild("Humanoid").Health <= 0 then return end
    if Player.Character:FindFirstChild("Humanoid"):GetState() == Enum.HumanoidStateType.Dead then return end

    -- Check if player is on valid team
    local PlayerTeamColor = Player.Team.TeamColor
    local AllyTeam = getgenv().CTF_Settings[teamFlagName].Color
    local EnemyTeam = getgenv().CTF_Settings[oppositeTeamFlagName].Color
    if PlayerTeamColor ~= AllyTeam and PlayerTeamColor ~= EnemyTeam then
        return
    end

    -- Check if opposite team
    if Player.Team.TeamColor == EnemyTeam then
        -- Check if flag is being carried by opposite team
        if FlagCarriers[oppositeTeamFlagName] then
            return
        end 

        -- check if flag is taken already
        if isFlagTaken[oppositeTeamFlagName] and not isDroppedFlag then
            return
        end

        -- Flag is not being carried
        FlagCarriers[oppositeTeamFlagName] = Player
        isFlagTaken[oppositeTeamFlagName] = true
        print("[ "..getgenv().CTF_Settings[oppositeTeamFlagName].Name.." ] "..Player.DisplayName.." took "..getgenv().CTF_Settings[teamFlagName].Name.."'s flag!")
        Shout("Player.DisplayName .. " has taken " .. getgenv().CTF_Settings[teamFlagName].Name .. "'s flag!")
        ToggleFlagVisibility(getgenv().CTF_Internal[teamFlagName].Flag, false)

        if isDroppedFlag then
            -- delete the dropped flag
            Delete(droppedFlag)
        end

        return
    end

    if Player.Team.TeamColor == AllyTeam then
        -- Check if flag is being carried
        if not FlagCarriers[teamFlagName] then
            return
        end

        -- Check if flag carrier is player
        if FlagCarriers[teamFlagName] ~= Player then
            return
        end

        if isDroppedFlag then
            return -- makes sure they cant capture the opposite team's flag from a dropped flag
        end

        -- Flag carrier is player
        FlagCarriers[teamFlagName] = nil
        isFlagTaken[teamFlagName] = false
        print("[ "..getgenv().CTF_Settings[teamFlagName].Name.." ] "..Player.DisplayName.." captured "..getgenv().CTF_Settings[oppositeTeamFlagName].Name.."'s flag!")
        Shout("[🏁] "..Player.DisplayName .. " has captured " .. getgenv().CTF_Settings[oppositeTeamFlagName].Name .. "'s flag!")
        ToggleFlagVisibility(getgenv().CTF_Internal[oppositeTeamFlagName].Flag, true)
        FlagCaptures[teamFlagName] = FlagCaptures[teamFlagName] + 1

        if FlagCaptures[teamFlagName] >= getgenv().CTF_Settings.CaptureLimit then
            getgenv().CTF_Internal.matchOver = true
            Shout(getgenv().CTF_Settings[teamFlagName].Name .. " has won the game!")
            UpdateTeamName(Player.Team.TeamColor.Name, getgenv().CTF_Settings[teamFlagName].Name .. " (WINNER)")
            task.wait(5)

            for i = getgenv().CTF_Settings.TimeUntilRestart, 0, -1 do
                Shout(`Game restarting in: {i}`)
                task.wait(0.5)
            end
            ResetGame()
            return
        end

        UpdateTeamName(Player.Team.TeamColor.Name, getgenv().CTF_Settings[teamFlagName].Name .. " (" .. FlagCaptures[teamFlagName] .. "/"..getgenv().CTF_Settings.CaptureLimit..")")
    end
end

function GetFlagCarrier(Team)
    return FlagCarriers[Team]
end

--[[ Main ]]--
getgenv().CTF_Internal.Team1.Flag, getgenv().CTF_Internal.Team2.Flag = GameSetup()

-- Start handling flag touches
local FlagGetTouchingParts_Connection = RunService.RenderStepped:Connect(function()
    local Team1Flag = getgenv().CTF_Internal.Team1.Flag
    local Team2Flag = getgenv().CTF_Internal.Team2.Flag

    local Team1FlagParts = Team1Flag:GetTouchingParts()
    local Team2FlagParts = Team2Flag:GetTouchingParts()

    for _, Part in pairs(Team1FlagParts) do
        HandleFlagTouch(Part, "Team1", "Team2")
    end

    for _, Part in pairs(Team2FlagParts) do
        HandleFlagTouch(Part, "Team2", "Team1")
    end
end)

local FlagDestroyed_Connection = workspace.Blocks.ChildRemoved:Connect(function(Child)
    if Child == getgenv().CTF_Internal.Team1.DroppedFlag then
        if FlagCarriers.Team2 then return end

        FlagCarriers.Team2 = nil
        isFlagTaken.Team2 = false
        getgenv().CTF_Internal.Team1.DroppedFlag = nil
        Shout(getgenv().CTF_Settings.Team1.Name .. "'s flag has been returned to their base!")
        ToggleFlagVisibility(getgenv().CTF_Internal.Team1.Flag, true)
        return
    end

    if Child == getgenv().CTF_Internal.Team2.DroppedFlag then
        if FlagCarriers.Team1 then return end

        FlagCarriers.Team1 = nil
        isFlagTaken.Team1 = false
        getgenv().CTF_Internal.Team2.DroppedFlag = nil
        Shout(getgenv().CTF_Settings.Team2.Name .. "'s flag has been returned to their base!")
        ToggleFlagVisibility(getgenv().CTF_Internal.Team2.Flag, true)
        return
    end
end)
table.insert(getgenv().Connections, FlagDestroyed_Connection)

local PlayerAdded_Connection = Players.PlayerAdded:Connect(function(Player)
    HandlePlayerTeamChange(Player)
    
    local PlayerCharacterAdded_Connection = Player.CharacterAdded:Connect(function(Character)
        HandlePlayerDeath(Player)
    end)
    table.insert(getgenv().Connections, PlayerCharacterAdded_Connection)
end)

local PlayerDisconnected_Connection = Players.PlayerRemoving:Connect(function(Player)
    HandlePlayerLeave(Player)
end)

for _, Player in pairs(Players:GetChildren()) do
    local PlayerCharacterAdded_Connection = Player.CharacterAdded:Connect(function(Character)
        HandlePlayerDeath(Player)
    end)
    HandlePlayerTeamChange(Player)
    HandlePlayerDeath(Player)
    table.insert(getgenv().Connections, PlayerCharacterAdded_Connection)
end

table.insert(getgenv().Connections, Team1Flag_Connection)
table.insert(getgenv().Connections, FlagGetTouchingParts_Connection)
table.insert(getgenv().Connections, PlayerAdded_Connection)
table.insert(getgenv().Connections, PlayerDisconnected_Connection)
