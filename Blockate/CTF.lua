pcall(function()
    for _, Connection in pairs(getgenv().Connections) do
        Connection:Disconnect()
        Connection = nil
    end
end)

getgenv().CTF_Settings = {
    TimeUntilFlagReturn = 30,
    CaptureLimit = 3,

    Team1 = {
        Name = "RED",
        Color = BrickColor.new("Bright red"),
    };
    Team2 = {
        Name = "BLU",
        Color = BrickColor.new("Bright blue"),
    };
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
local FlagCarriers = {
    Team1 = nil,
    Team2 = nil,
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

function Shout(Message)
    local args = {
        [1] = "!shout "..Message
    }
    
    ReplicatedStorage:WaitForChild("Sockets"):WaitForChild("Command"):InvokeServer(unpack(args))    
end

function Place(Properties)
    return ReplicatedStorage:WaitForChild("Sockets"):WaitForChild("Edit"):WaitForChild("Place"):InvokeServer(Properties)
end

function Delete(Block)
    ReplicatedStorage:WaitForChild("Sockets"):WaitForChild("Edit"):WaitForChild("Delete"):FireServer(Block)
end

function PaintBlock(Block, Properties, PropertiesToChange)
    local args = {
        [1] = {
            [1] = {
                [1] = Block,
                [2] = Block,
                [3] = {
                    ["Reflectance"] = 0,
                    ["CanCollide"] = true,
                    ["Color"] = Color3.fromRGB(13.000000175088644, 105.00000134110451, 172.00000494718552),
                    ["LightColor"] = Color3.fromRGB(242.0000159740448, 243.00001591444016, 243.00001591444016),
                    ["Transparency"] = 0,
                    ["Size"] = 1,
                    ["Material"] = 1,
                    ["Shape"] = 29,
                    ["Light"] = 0
                },
                [4] = 1,
                [5] = {
                    ["Color"] = false,
                    ["Material"] = false,
                    ["Transparency"] = true,
                    ["CanCollide"] = true
                }
            }
        }
    }
    
    game:GetService("ReplicatedStorage"):WaitForChild("Sockets"):WaitForChild("Edit"):WaitForChild("Paint"):FireServer(unpack(args))
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

    return Team1Flag, Team2Flag
end

function EvaluateTouched(Part)
    local PlayerHumanoid = Part.Parent:FindFirstChild("Humanoid") or nil
    if not PlayerHumanoid then return end

    local PlayerName = PlayerHumanoid.Parent
    local Player = Players[PlayerName.Name]

    return Player
end

function HandlePlayerLeave(Player)
    if FlagCarriers.Team1 == Player then
        FlagCarriers.Team1 = nil
        Shout(getgenv().CTF_Settings.Team1.Name .. "'s flag has been dropped and has been returned their base!")
    end

    if FlagCarriers.Team2 == Player then
        FlagCarriers.Team2 = nil
        Shout(getgenv().CTF_Settings.Team2.Name .. "'s flag has been dropped and has been returned their base!")
    end
end

function HandlePlayerTeamChange(Player)
    local Connection = Player:GetPropertyChangedSignal("Team"):Connect(function()
        if FlagCarriers.Team1 == Player then
            FlagCarriers.Team1 = nil
            Shout(getgenv().CTF_Settings.Team1.Name .. "'s flag has been dropped and has been returned their base!")
        end
    
        if FlagCarriers.Team2 == Player then
            FlagCarriers.Team2 = nil
            Shout(getgenv().CTF_Settings.Team2.Name .. "'s flag has been dropped and has been returned their base!")
        end
    end)

    table.insert(getgenv().Connections, Connection)
end

function HandlePlayerDeath(Player)
    local Connection = Player.Character:WaitForChild("Humanoid").Died:Connect(function()
        if FlagCarriers.Team1 == Player then
            FlagCarriers.Team1 = nil
            Shout(getgenv().CTF_Settings.Team1.Name .. "'s flag has been dropped and has been returned their base!")
        end
    
        if FlagCarriers.Team2 == Player then
            FlagCarriers.Team2 = nil
            Shout(getgenv().CTF_Settings.Team2.Name .. "'s flag has been dropped and has been returned their base!")
        end
    end)

    table.insert(getgenv().Connections, Connection)
end

function HandleFlagTouch(Hit, teamFlagName, oppositeTeamFlagName)
    local Player = EvaluateTouched(Hit)

    if not Player then return end

    -- Check if valid team
    if Player.Team.Name ~= Teams[getgenv().CTF_Settings[teamFlagName].Name].Name and Player.Team.Name ~= Teams[getgenv().CTF_Settings[oppositeTeamFlagName].Name].Name then
        return
    end

    -- Check if opposite team
    if Player.Team ~= Teams[getgenv().CTF_Settings[teamFlagName].Name] then
        -- Check if flag is being carried by opposite team
        if FlagCarriers[oppositeTeamFlagName] then
            return
        end 

        -- Flag is not being carried
        FlagCarriers[oppositeTeamFlagName] = Player
        Shout(Player.Name .. " has taken " .. getgenv().CTF_Settings[teamFlagName].Name .. "'s flag!")
        return
    end

    if Player.Team == Teams[getgenv().CTF_Settings[teamFlagName].Name] then
        -- Check if flag is being carried
        if not FlagCarriers[teamFlagName] then
            return
        end

        -- Check if flag carrier is player
        if FlagCarriers[teamFlagName] ~= Player then
            return
        end

        -- Flag carrier is player
        FlagCarriers[teamFlagName] = nil
        Shout(Player.Name .. " has captured " .. getgenv().CTF_Settings[oppositeTeamFlagName].Name .. "'s flag!")
    end
end

function GetFlagCarrier(Team)
    return FlagCarriers[Team]
end

--[[ Main ]]--
local Team1Flag, Team2Flag = GameSetup()

-- Start hooking on flags
local Team1Flag_Connection = Team1Flag.Touched:Connect(function(Hit)
    HandleFlagTouch(Hit, "Team1", "Team2")
end)

local Team2Flag_Connection = Team2Flag.Touched:Connect(function(Hit)
    HandleFlagTouch(Hit, "Team2", "Team1")
end)

local PlayerAdded_Connection = Players.PlayerAdded:Connect(function(Player)
    HandlePlayerTeamChange(Player)
    
    Player.CharacterAdded:Connect(function(Character)
        HandlePlayerDeath(Player)
    end)
end)

local PlayerDisconnected_Connection = Players.PlayerRemoving:Connect(function(Player)
    HandlePlayerLeave(Player)
end)

for _, Player in pairs(Players:GetPlayers()) do
    HandlePlayerTeamChange(Player)
    
    Player.CharacterAdded:Connect(function(Character)
        HandlePlayerDeath(Player)
    end)
end

table.insert(getgenv().Connections, Team1Flag_Connection)
table.insert(getgenv().Connections, Team2Flag_Connection)
table.insert(getgenv().Connections, PlayerAdded_Connection)
table.insert(getgenv().Connections, PlayerDisconnected_Connection)

--[[
    for _, Connection in pairs(getgenv().Connections) do
        Connection:Disconnect()
    end
]]
