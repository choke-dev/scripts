local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local LocalPlayer = Players.LocalPlayer

pcall(function()
ContextActionService:UnbindAction("SteerLeft")
ContextActionService:UnbindAction("SteerRight")
ContextActionService:UnbindAction("Forwards")
end)

local function OnInput(actionName, inputState)
    Movements[actionName] = (inputState == Enum.UserInputState.Begin)
end

local Kayak = LocalPlayer.Character.Humanoid.SeatPart.Parent

function steerLeft()
    Kayak.UpperPreciseCollision.AssemblyAngularVelocity = Vector3.new(0, 1, 0)
end

function steerRight()
    Kayak.UpperPreciseCollision.AssemblyAngularVelocity = Vector3.new(0, -1, 0)
end

function forwards()
    local LV = LocalPlayer.Character.HumanoidRootPart.CFrame.LookVector
    Kayak.UpperPreciseCollision.AssemblyLinearVelocity = Vector3.new(LV.X * 10, 0, LV.Z * 10)
end

local Movements = {
    ["SteerLeft"] = {Enum.KeyCode.Z, steerLeft},
    ["SteerRight"] = {Enum.KeyCode.X, steerRight},
    ["Forwards"] = {Enum.KeyCode.C, forwards}
}

pcall(function()
    for name, key in pairs(Movements) do
        ContextActionService:UnbindAction(name, OnInput, false, key)
    end
end)

for name, key in pairs(Movements) do
    ContextActionService:BindAction(name, OnInput, false, key[1])
end

print("Steering Enabled")
