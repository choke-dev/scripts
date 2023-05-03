local TweenService = game:GetService("TweenService")
local Tween_1S = TweenInfo.new(1, Enum.EasingStyle.Linear)

local TweenQueue = {}

function findNearestStealable()


function interact(part)
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Interact"):FireServer(part)
end

function lootItem(item)
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("LootObject"):FireServer(item)
end

function sellItems(agent)
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Interact"):FireServer(agent, "SellHeistSCP")
end

function timeStamp()
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Timestamp"):FireServer()
end

function stealItems()
    local Items = workspace.SCPs["002"].Heist.Stealable
    local ItemLimit = 10
    for i,v in pairs(Items:GetDescendants()) do
        if v.Name ~= "Interact" then continue end
        if v.Parent.Name ~= "LivingRoomSample" then continue end
        if v.Transparency == 1 then continue end

        if ItemLimit <= 0 then break end
        print("adding")
        table.insert(TweenQueue, {
            ["CFrame"] = v.CFrame,
            ["Action"] = function()
                timeStamp()
                lootItem(v.Parent)
            end
        })
        ItemLimit = ItemLimit - 1
    end
end

function startHeist()
    local LivingRoom = workspace.SCPs["002"]
    for i,v in pairs(LivingRoom:GetDescendants()) do
        if v.Name == "Interact" and v.Parent.Name == "ActivateHeist" then
            print("Adding "..v.Parent.Name.." to queue")
            table.insert(TweenQueue, {
                ["CFrame"] = v.CFrame,
                ["Action"] = function()
                    interact(v.Parent)
                end
            })
            print("Added HeistStart: "..v.Parent.Name.." to queue")
        end
    end
    
end

function sellToMCD()
    for i,v in pairs(workspace.Contracts:GetChildren()) do
        if v.Name == "Agent" then
            table.insert(TweenQueue, {
                ["CFrame"] = v.HumanoidRootPart.CFrame,
                ["Action"] = function()
                    sellItems(v)
                end
            })
        end
    end
end


-- // Tween scan loop \\ --
task.spawn(function()
    while true do
        task.wait()
        for i,v in ipairs(TweenQueue) do
            local Tween = TweenService:Create(game.Players.LocalPlayer.Character.HumanoidRootPart, Tween_1S, {CFrame = v["CFrame"]})
            Tween:Play()
            table.remove(TweenQueue, i)
            Tween.Completed:Wait()
            wait(.5)
            v["Action"]()
            wait(.5)
        end 
    end
end)

startHeist()
task.wait(4)
stealItems()
task.wait(21)
sellToMCD()
