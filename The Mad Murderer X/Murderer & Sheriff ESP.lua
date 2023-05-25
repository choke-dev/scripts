--[[
    // Name: [The Mad Murderer X] Sheriff / Murderer ESP
    // Author: choke#3588 <@208876506146013185>
    // Desc: "wish there was something else i can use"
    // Date: 2023/05/25 [YYYY/MM/DD]
]]

local Services  = setmetatable({}, {
    __index = function(self, key)
        return game.GetService(game, key)
    end
})

local Players = Services.Players

function DroppedGun_Handler()
    -- workspace.Entities.DroppedGun.Handle
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
            print("Adding Highlight to Murderer: "..Character.Name)
            local Murderer_Highlight_Instance            = Instance.new("Highlight")
            Murderer_Highlight_Instance.Parent           = Character
            Murderer_Highlight_Instance.Name             = "Murderer_Highlight"
            Murderer_Highlight_Instance.FillTransparency = 1
            Murderer_Highlight_Instance.OutlineColor     = Color3.new(1, 0, 0)
        end

        if not Sheriff_Highlight and Gun then
            print("Adding Highlight to Sheriff: "..Character.Name)
            local Sheriff_Highlight_Instance            = Instance.new("Highlight")
            Sheriff_Highlight_Instance.Parent           = Character
            Sheriff_Highlight_Instance.Name             = "Sheriff_Highlight"
            Sheriff_Highlight_Instance.FillTransparency = 1
            Sheriff_Highlight_Instance.OutlineColor     = Color3.new(0, 0, 1)
        end
    end)
    return ESPHook
end 

function AddAliveHook(Character)
    local AliveHook
    AliveHook = Character.ChildAdded:Connect(function(Child)
        if not Child:IsA("Folder") then return end
        if Child.Name ~= "NoCollisionConstraints" then return end

        local Murderer_Highlight = Character:FindFirstChild("Murderer_Highlight")
        local Sheriff_Highlight  = Character:FindFirstChild("Sheriff_Highlight")

        if Murderer_Highlight then
            Murderer_Highlight:Destroy()
        end
        
        if Sheriff_Highlight then
            Sheriff_Highlight:Destroy()
        end

    end)
    return AliveHook
end



Players.PlayerAdded:Connect(function(Player)
    Player.CharacterAdded:Connect(function(Character)
        AddESPHook(Character)
        AddAliveHook(Character)
    end)
end)

for _,Player in pairs(Players:GetChildren()) do
    Player.CharacterAdded:Connect(function(Character)
        AddESPHook(Character)
        AddAliveHook(Character)
    end)
    AddESPHook(Player.Character)
    AddAliveHook(Player.Character)
end
