pcall(function()
    -- selene: allow(undefined_variable)
    getgenv().Rayfield:Destroy()
end)


--=[ Services ]=--
-- selene: allow(incorrect_standard_library_use)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
-- selene: allow(undefined_variable)
getgenv().Rayfield = Rayfield
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--=[ Variables ]=--
local LocalPlayer = Players.LocalPlayer
local LocalPlayer_Char = LocalPlayer.Character
local Titles = {
    ["None"] = nil,
    ["Elite"] = "13",
    ["Master Thief I"] = "1",
    ["Master Thief II"] = "3",
    ["Master Thief III"] = "4",
    ["Master Thief IV"] = "5",
    ["Master Thief V"] = "6",
    ["Master Thief VI"] = "7",
    ["True Criminal"] = "2",
    ["Entrepreneur"] = "9",
    ["Executive"] = "10",
    ["CEO"] = "11",
    ["Mastermind"] = "12",
    ["Ninja"] = "8",
    ["Shadow Warrior"] = "14",
    ["Spooky"] = "15",
    ["Santa"] = "16",
    ["Fighter"] = "17",
    ["Killer"] = "18",
    ["Destroyer"] = "19",
    ["Annihilator"] = "20",
    ["Monster"] = "21",
    ["Infected"] = "22",
    ["Perfectionist"] = "23",
    ["Trick or Treater"] = "24",
    ["Premium"] = "25",
    ["Cheater"] = "26",
    ["Sus"] = "27",
    ["Contributor"] = "29",
    ["Tester"] = "30",
    ["Virtuoso"] = "31"
}
local TitlesDropdown = {}
-- sort the titles by value since dictionaries arent guaranteed to be sorted by key
for k,v in next, Titles do
    table.insert(TitlesDropdown, k)
end
table.sort(TitlesDropdown)

--=[ Variables ]=--
local Connections = {
    ["CameraName_Signal"] = {
        Debounce = false
    }
}

--=[ Remotes ]=--
local Remotes = {
    ["CompleteInteraction"] = ReplicatedStorage.RS_Package.Remotes.CompleteInteraction
}

--=[ Functions ]=--
function UINotify(title: string, content: string, duration: number, image: number, actions: table) 
    Rayfield:Notify({
        Title = title,
        Content = content,
        Duration = duration,
        Image = image,
        Actions = actions
    })
end

--=[ UI ]=--
local Window = Rayfield:CreateWindow({
    Name = "Notoriety Haxx",
    LoadingTitle = "Notoriety Haxx",
    LoadingSubtitle = "by choke",
})

local Functions = {
    ["MainFunctions"] = function()
        local DisableCamsDebounce = false
        local PermanentlyDisabledCameras = false
        local UIElements = {}
        local Connections_DisabledCameras = {}
        

        --// Main \\--
        local Tab_MainMenu = Window:CreateTab("Main", 4483362458)
        
        local Section_LocalPlayer = Tab_MainMenu:CreateSection("Localplayer Functions")
        local Toggle_InfiniteStamina = Tab_MainMenu:CreateToggle({
            Name = "Infinite Stamina",
            CurrentValue = false,
            Flag = "Toggle_InfiniteStamina", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
            Callback = function(Value)
                if Value then
                    LocalPlayer_Char.Stamina.Value = math.huge
                else
                    LocalPlayer_Char.Stamina.Value = LocalPlayer_Char.MaxStamina.Value
                end
            end,
        })

        local Section_NPC = Tab_MainMenu:CreateSection("NPC Functions")
        local Button_NPCESP = Tab_MainMenu:CreateButton({
            Name = "Load NPC ESP",
            Callback = function()
                -- selene: allow(incorrect_standard_library_use)
                loadstring(game:HttpGet("https://raw.githubusercontent.com/choke-dev/scripts/main/Notoriety/NPC%20ESP.lua"))()
                UINotify("Notoriety Haxx | Success", "NPC ESP has been loaded", 6.5, 10709790644)
            end,
        })
        local Button_RemoveNPC = Tab_MainMenu:CreateButton({
            Name = "Remove NPCs from Map",
            Callback = function()
                UINotify("Notoriety Haxx | Notice", "This function is under maintenance.", 6.5, 10747383470)
            end,
        })

        --// Map \\--
        local Tab_Map = Window:CreateTab("Map", 4483362458)

        local Section_Detection = Tab_Map:CreateSection("Detection Functions")
        local Toggle_DisableCameras = Tab_Map:CreateToggle({
            Name = "Disable Cameras",
            CurrentValue = false,
            Flag = "Toggle_DisableCameras",
            Callback = function(Value)
                if PermanentlyDisabledCameras and not DisableCamsDebounce then
                    DisableCamsDebounce = true
                    UIElements["Toggle_DisableCameras"]:Set(false)
                    UINotify("Notoriety Haxx | Error", "Cameras are permanently disabled.", 6.5, 10747384394)
                    DisableCamsDebounce = false
                    return
                end

                if not Value then
                    for _,v in pairs(Connections_DisabledCameras) do
                        v:Disconnect()
                    end
                    return table.clear(Connections_DisabledCameras) -- using table.remove() wont work since the index is shifted when removing
                end

                for _,v in pairs(workspace.Cameras:GetChildren()) do
                    -- Name check
                    if v.Name == "Disabled" then
                        PermanentlyDisabledCameras = true
                        UIElements["Toggle_DisableCameras"]:Set(false)
                        return
                    end

                    --[[
                        Create an event to fire when any child of workspace.Camera changes its name to "Disabled"

                        and run these functions
                        UIElements["Toggle_DisableCameras"]:Set(false)
                        UINotify("Notoriety Haxx | Notice", "Cameras have been permanently disabled.", 6.5, 10747384394)
                    ]]
                    

                    -- Camera disable loop
                    local Camera_DisableProximityPrompt = v:FindFirstChild("Union"):FindFirstChild("ProximityPrompt")
                    local Camera_DisableLoop = v.ChildRemoved:Connect(function(child)
                        if child:IsA("Folder") and child.Name == "Hacked" then
                            Remotes["CompleteInteraction"]:FireServer(Camera_DisableProximityPrompt)
                        end
                    end)
                    table.insert(Connections_DisabledCameras, Camera_DisableLoop)
                    Remotes["CompleteInteraction"]:FireServer(Camera_DisableProximityPrompt)
                end
            end
        })
        UIElements["Toggle_DisableCameras"] = Toggle_DisableCameras
    end
}
local PlaceIDFunctions = {
    [21532277] = function() -- Hub
        --=[ ModuleScripts ]=--
        local StatsModule = require(Players.LocalPlayer.PlayerScripts.LocalStatsModule)
        --=[ Folders ]=--
        local Folder_Lobbies = ReplicatedStorage.Lobbies

        --=[ Lobby Tab ]=--
        local Tab_MainMenu = Window:CreateTab("Lobby", 4483362458)

        local Section_Title = Tab_MainMenu:CreateSection("Title Functions")
        local Dropdown_SetTitle = Tab_MainMenu:CreateDropdown({
            Name = "Set Title",
            Options = TitlesDropdown,
            CurrentOption = {"None"},
            MultipleOptions = false,
            Flag = "Dropdown_SetTitle",
            Callback = function(Option)
                local SelectedTitle = Titles[Option[1]]
                ReplicatedStorage.SetTitle:FireServer(SelectedTitle)
            end,
        })

        local Section_Player = Tab_MainMenu:CreateSection("Player Functions")
        local Button_InfiniteSkillPoints = Tab_MainMenu:CreateButton({
            Name = "Infinite Skill Points",
            Callback = function()
                StatsModule.Inventory.Level = 999999999
            end,
        })
        local Button_UnlockAllSkillPoints = Tab_MainMenu:CreateButton({
            Name = "Unlock All Skill Points for Current Profile",
            Callback = function()
                return UINotify("Notoriety Haxx | Notice", "This function is under maintenance.", 6.5, 10747383470)
            end,
        })
        local Button_UnlockAllSkillPointsForAllProfiles = Tab_MainMenu:CreateButton({
            Name = "Unlock All Skill Points for All Profiles",
            Callback = function()
                return UINotify("Notoriety Haxx | Notice", "This function is under maintenance.", 6.5, 10747383470)
            end,
        })

        local Section_Lobby = Tab_MainMenu:CreateSection("Lobby Functions")
        local Button_InviteEveryoneToLobby = Tab_MainMenu:CreateButton({
            Name = "Invite Everyone To Lobby",
            Callback = function()
                local LocalPlayer_Lobby = Folder_Lobbies:FindFirstChild(LocalPlayer.DisplayName)
                if not LocalPlayer_Lobby then
                    return UINotify("Notoriety Haxx | Error", "You do not seem to own a lobby. Please create one and try again.", 6.5, 10747384394)
                end
                for _,v in next, Players:GetChildren() do
                    if v == Players.LocalPlayer then continue end
                    if not LocalPlayer_Lobby then return end
                    ReplicatedStorage.SendLobbyInvite:FireServer(v.Name, LocalPlayer_Lobby)
                end
                UINotify("Notoriety Haxx | Success", "Sent invites to everyone in the server.", 6.5, 10709790644)
            end,
        })
    end,
    [2088934656] = function() -- Shadow Raid
        local Tab_MainMenu = Window:CreateTab("Shadow Raid", 4483362458)
    end,
    [1242009557] = function() -- Brick Bank
        local Tab_MainMenu = Window:CreateTab("Brick Bank", 4483362458)
    end,
}

if game.PlaceId ~= 21532277 then
    Functions["MainFunctions"]()
end

if not PlaceIDFunctions[game.PlaceId] then return end
PlaceIDFunctions[game.PlaceId]()
