--[[
    // Name: [The Mad Murderer X] Sheriff / Murderer / Gun ESP
    // Author: choke#3588 <@208876506146013185>
    // Desc: "wish there was something else i can use"
    // Date: 2023/05/26 [YYYY/MM/DD]
]]

local Services  = setmetatable({}, {
    __index = function(self, key)
        return game.GetService(game, key)
    end
})

local Players = Services.Players

function DroppedGun_Handler(Folder)
    local DroppedGun_Connection
    DroppedGun_Connection = Folder.ChildAdded:Connect(function(Child)
        if Child.Name ~= "DroppedGun" then return end

        local DroppedGun_Highlight_Instance            = Instance.new("Highlight")
        DroppedGun_Highlight_Instance.Parent           = Child
        DroppedGun_Highlight_Instance.Adornee          = Child:WaitForChild("GunMesh")
        DroppedGun_Highlight_Instance.Name             = "DroppedGun_Highlight"
        DroppedGun_Highlight_Instance.FillTransparency = 1
        DroppedGun_Highlight_Instance.OutlineColor     = Color3.new(0, 1, 0)
    end)
    return DroppedGun_Connection
end

function AddESPHook(Character)
    local ESPHook
    ESPHook = Character.ChildAdded:Connect(function(Child)
        if Child.Name ~= "WorldModel" then return end

        local Knife = Child:FindFirstChild("Knife")
        local Gun   = Child:FindFirstChild("Gun")

        local Murderer_Highlight = Character:FindFirstChild("Murderer_Highlight")
        local Sheriff_Highlight  = Character:FindFirstChild("Sheriff_Highlight")

        if not Murderer_Highlight and Knife then
            local Murderer_Highlight_Instance            = Instance.new("Highlight")
            Murderer_Highlight_Instance.Parent           = Character
            Murderer_Highlight_Instance.Name             = "Murderer_Highlight"
            Murderer_Highlight_Instance.FillTransparency = 1
            Murderer_Highlight_Instance.OutlineColor     = Color3.new(1, 0, 0)
        end

        if not Sheriff_Highlight and Gun then
            local Sheriff_Highlight_Instance            = Instance.new("Highlight")
            Sheriff_Highlight_Instance.Parent           = Character
            Sheriff_Highlight_Instance.Name             = "Sheriff_Highlight"
            Sheriff_Highlight_Instance.FillTransparency = 1
            Sheriff_Highlight_Instance.OutlineColor     = Color3.new(0, 0, 1)
        end
    end)

    local Character_Highlight_Instance
    Character_Highlight_Instance                  = Instance.new("Highlight")
    Character_Highlight_Instance.Parent           = Character
    Character_Highlight_Instance.Adornee          = Character
    Character_Highlight_Instance.Name             = "Character_Highlight"
    Character_Highlight_Instance.FillTransparency = 1
    Character_Highlight_Instance.OutlineColor     = Color3.new(1, 1, 1)

    return ESPHook, Character_Highlight_Instance
end 

--=[ Gun ESP ]=--
for _, Object in pairs(workspace:GetChildren()) do
    if not Object:IsA("Folder") then continue end
    if Object.Name ~= "Entities" then continue end

    DroppedGun_Handler(Object)
end

--=[ Removes Highlights from Dead Players ]=--
workspace.DebrisClient.PersistingDeathEffects.ChildAdded:Connect(function(Child)
    local Murderer_Highlight = Child:FindFirstChild("Murderer_Highlight")
    local Sheriff_Highlight  = Child:FindFirstChild("Sheriff_Highlight")

    if Murderer_Highlight then
        Murderer_Highlight:Destroy()
    end

    if Sheriff_Highlight then
        Sheriff_Highlight:Destroy()
    end
end)

--=[ Main ESP ]=--
Players.PlayerAdded:Connect(function(Player)
    Player.CharacterAdded:Connect(function(Character)
        AddESPHook(Character)
    end)
end)

for _, Player in pairs(Players:GetChildren()) do
    Player.CharacterAdded:Connect(function(Character)
        AddESPHook(Character)
    end)
    AddESPHook(Player.Character)
end
